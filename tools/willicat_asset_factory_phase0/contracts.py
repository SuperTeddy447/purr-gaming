"""Small Phase 0 pure contracts. No scheduler, catalog or production publisher."""
from __future__ import annotations
import base64,hashlib,json,math,re,subprocess,tempfile,unicodedata
from decimal import Decimal
from pathlib import Path
from jsonschema import Draft202012Validator, RefResolver

ROOT=Path(__file__).parent/'contracts'

def load_contract(name):
    return json.loads((ROOT/(name+'.json')).read_text())

def sha(data):
    return hashlib.sha256(data).hexdigest()

def canonical(value):
    """restricted-json-1: ASCII keys, NFC strings, integer numbers, UTF8 sorted compact."""
    def visit(v):
        if v is None or type(v) is bool: return
        if type(v) is int:
            if abs(v)>9007199254740991: raise ValueError('integer outside exact JSON domain')
        elif isinstance(v,str):
            if unicodedata.normalize('NFC',v)!=v or any(0xD800<=ord(c)<=0xDFFF for c in v): raise ValueError('noncanonical Unicode')
        elif isinstance(v,list):
            for x in v: visit(x)
        elif isinstance(v,dict):
            for k,x in v.items():
                if not isinstance(k,str) or not re.fullmatch(r'[A-Za-z0-9_./:-]+',k): raise ValueError('invalid canonical key')
                visit(x)
        else: raise ValueError('floats/unsupported values cannot be signed')
    visit(value)
    return json.dumps(value,sort_keys=True,separators=(',',':'),ensure_ascii=False,allow_nan=False).encode('utf-8')

def parse_json(data):
    def pairs(ps):
        d={}
        for k,v in ps:
            if k in d: raise ValueError('duplicate JSON key')
            d[k]=v
        return d
    return json.loads(data,object_pairs_hook=pairs,parse_constant=lambda x: (_ for _ in ()).throw(ValueError(x)))

def valid_schema(name,data):
    schema=load_contract(name+'.schema')
    resolver=RefResolver(base_uri=ROOT.as_uri()+'/',referrer=schema,store={p.name:json.loads(p.read_text()) for p in ROOT.glob('*.schema.json')})
    Draft202012Validator(schema,resolver=resolver).validate(data)

def decimal_string(value):
    d=Decimal(str(value))
    if not d.is_finite(): raise ValueError('nonfinite authority value')
    if d==0:return '0'
    s=format(d,'f')
    return s.rstrip('0').rstrip('.') if '.' in s else s

def project(snapshot):
    # Snapshot is read-only Godot extraction, extra unrelated fields deliberately excluded.
    names=load_contract('world_projection_recipe')['selection']
    p={k:snapshot[k] for k in names}  # missing is an error, never inferred/defaulted
    def numbers(v):
        if isinstance(v,list):return [numbers(x) for x in v]
        if isinstance(v,dict):return {k:numbers(x) for k,x in v.items()}
        if type(v) is float or isinstance(v,Decimal):return decimal_string(v)
        return v
    p=numbers(p)
    for field in ['global_transform']:
        p[field]=[decimal_string(v) for v in p[field]]
    p['attachment']['local_transform']=[decimal_string(v) for v in p['attachment']['local_transform']]
    p['shadow']['local_transform']=[decimal_string(v) for v in p['shadow']['local_transform']]
    for field in ['global_transform','footprint_size']:
        p['collision'][field]=[decimal_string(v) for v in p['collision'][field]]
    p['collision']['navigation_outline']=[[decimal_string(v) for v in pair] for pair in p['collision']['navigation_outline']]
    p['navigation']['agent_clearance']=decimal_string(p['navigation']['agent_clearance'])
    p['depth_chain']=sorted(p['depth_chain'],key=lambda v:v['path'])
    if len({v['path'] for v in p['depth_chain']})!=len(p['depth_chain']):raise ValueError('duplicate depth identity')
    p['semantic_event_ids']=sorted(p['semantic_event_ids'])
    valid_schema('world_projection',p)
    return p

def projection_hash(snapshot):return sha(canonical(project(snapshot)))

def verify_approval(envelope,trust,allow_test_fixture=False):
    """Verification only. Trust registry must come from external protected configuration."""
    try:
        valid_schema('approval_envelope',envelope)
        payload=envelope['payload']; key=trust['credentials'][payload['credential_id']]
        if key['state']!='active' or key['principal']!=payload['reviewer_principal']:return False
        if payload['reviewer_role'] not in key['roles']:return False
        if key['test_fixture'] and not allow_test_fixture:return False
        message=canonical(payload)
        if sha(message)!=envelope['signed_payload_hash']:return False
        signature=base64.b64decode(envelope['signature'],validate=True)
        with tempfile.TemporaryDirectory(prefix='willicat-verify-') as directory:
            d=Path(directory); (d/'payload').write_bytes(message); (d/'signature').write_bytes(signature); (d/'public.pem').write_text(key['public_key_pem'])
            # Public verification has no signing key or signing operation.
            info=subprocess.run(['/usr/bin/openssl','rsa','-pubin','-in',str(d/'public.pem'),'-text','-noout'],capture_output=True,text=True,check=True).stdout
            match=re.search(r'\((\d+) bit\)',info)
            if not match or int(match.group(1))<3072:return False
            r=subprocess.run(['/usr/bin/openssl','dgst','-sha256','-verify',str(d/'public.pem'),'-signature',str(d/'signature'),'-sigopt','rsa_padding_mode:pss','-sigopt','rsa_pss_saltlen:32','-sigopt','rsa_mgf1_md:sha256',str(d/'payload')],capture_output=True)
            return r.returncode==0
    except Exception:
        # Fail-closed prototype, including schema/I/O/verifier errors.
        return False

def scopes_permitted(manifest,action,current_revision):
    required=load_contract('rights_actions')['actions'][action]
    matches=[e for e in manifest['rights_evaluations'] if e['action']==action and e['decision_revision']==current_revision and sorted(e['required_scopes'])==sorted(required)]
    if len(matches)!=1:return False
    e=matches[0]
    if e['result']!='passed':return False
    assessments={a['scope']:a for a in e['assessments']}
    if len(assessments)!=len(e['assessments']):return False
    return all(s in assessments and assessments[s]['outcome']=='permitted' and assessments[s]['evidence'] for s in required)

def validate_manifest(m):
    valid_schema('tree_manifest',m)
    stages=load_contract('lifecycle')['stages']; at=stages.index(m['lifecycle_stage'])
    if at>=2 and m['style_calibration']['status']!='approved':raise ValueError('unapproved SOURCE calibration')
    if at>=1 and m['world_authority']['world_authority_projection_hash']!=projection_hash(m['world_authority']['projection']):raise ValueError('projection hash mismatch')
    if at>=3:
        a=m['animation']
        if len(a['frame_map'])!=len(a['durations_ms']) or a['rest_frame']>=len(a['frame_map']):raise ValueError('frame/time map mismatch')
        if len({f['frame_id'] for f in a['frame_map']})!=len(a['frame_map']):raise ValueError('duplicate frame identity')
        if any(f['atlas_rect_px'][2]==0 or f['atlas_rect_px'][3]==0 for f in a['frame_map']):raise ValueError('zero-size atlas region')
    for g,r in m['gates'].items():
        if r['status']=='not_applicable':raise ValueError('tree cannot waive gates')
        if r['status']=='passed':
            record=r['record']
            if record['gate']!=g or record['result']!='passed':raise ValueError('gate/review mismatch')
            if any(record[k]!=m[k] for k in ['asset_id','asset_version','attempt_id']):raise ValueError('wrong-version review')
    if at>=4:
        profile=load_contract('tree_profile');required=profile['required_validators']['structural'][:]
        if at>=5:required+=profile['required_validators']['motion']
        if at>=9:required+=profile['required_validators']['runtime']
        if any(id not in m['validator_results'] or m['validator_results'][id]['result']!='passed' for id in required):raise ValueError('required validator missing/failed')
    if at>=5:
        mr=m['motion_review']
        if mr['owner_role']!='technical_animator' or mr['gate']!='motion' or mr['result']!='passed':raise ValueError('motion human review required')
        criteria=mr.get('criteria_results',[])
        required_human=set(load_contract('tree_profile')['required_motion_criteria'])
        if len(criteria)!=len(required_human) or set(x['criterion_id'] for x in criteria)!=required_human or any(x['result']!='passed' for x in criteria):raise ValueError('human motion criteria incomplete/rejected')
        required=set(load_contract('tree_profile')['required_motion_policy_criteria'])
        results=m['motion_policy_results']
        if len({x['criterion_id'] for x in results})!=len(results) or set(x['criterion_id'] for x in results)!=required:raise ValueError('motion policies incomplete')
        if any(x['result']!='passed' or x['policy_version'] in ['UNMEASURED','CANDIDATE_REQUIRES_CALIBRATION'] for x in results):raise ValueError('uncalibrated/failed motion policy')
    if at>=6 and (m['visual_review']['owner_role']!='art_lead' or m['visual_review']['result']!='passed' or m['visual_review']['gate']!='visual'):raise ValueError('visual review required')
    for review in [m.get('motion_review'),m.get('visual_review')]:
        if review and any(review[k]!=m[k] for k in ['asset_id','asset_version','attempt_id']):raise ValueError('review pin mismatch')
    if at>=9 and m['runtime_proof']['record']!=m['gates']['runtime']['record']:raise ValueError('runtime record mismatch')

def production_ready(m,c,trust,artifact_bytes,allow_test_fixture=False):
    """Pure decision: no filesystem writes. Context from protected ledgers, not agent input."""
    try:
        validate_manifest(m); valid_schema('predicate_context',c)
        if m['lifecycle_stage']!='human_approved' or m['disposition']!='current' or m['attempt_id']!=c['current_attempt_id']:return False
        if m['invalidation']['blocking_dependencies'] or c['blocking_dependencies'] or c['release_eligibility']!='eligible':return False
        if any(c['current_motion_policy_versions'][r['criterion_id']]!=r['policy_version'] for r in m['motion_policy_results']):return False
        if c['trust_store_revision']!=trust['revision']:return False
        def compatible(kind,pinned,current):
            if pinned==current:return True
            return any(a['kind']==kind and a['pinned_identity']==pinned and a['current_identity']==current and a['record_hash'] in c['trusted_review_record_hashes'] for a in c['compatibility_affirmations'])
        if not compatible('template',sha(canonical(m['template'])),sha(canonical(c['current_template']))):return False
        style={k:m['style_calibration'][k] for k in ['id','version']}
        if not compatible('style',sha(canonical(style)),sha(canonical(c['current_style_calibration']))):return False
        world=m['world_authority']['world_authority_projection_hash']
        if not compatible('world',world,c['current_world_projection_hash']):return False
        if m['style_calibration']['status']!='approved' or not scopes_permitted(m,c['action'],c['rights_decision_revision']):return False
        if any(g['status']!='passed' for g in m['gates'].values()):return False
        approval=m['human_approval']; p=approval['payload']
        if not verify_approval(approval,trust,allow_test_fixture):return False
        if c['credential_id']!=p['credential_id']:return False
        if p['asset_contract_hash']!=sha(canonical(asset_contract_view(m))):return False
        for k in ['asset_id','asset_version','job_id','attempt_id']:
            if p[k]!=m[k]:return False
        if p['template']!=m['template'] or p['style_calibration']!=style or p['world_authority_projection_hash']!=world or p['rights_decision_revision']!=c['rights_decision_revision']:return False
        if any(p['gate_results'][g]!=m['gates'][g]['status'] for g in p['gate_results']):return False
        hashes=[m['candidate_bundle']['candidate_bundle_hash'],m['runtime_proof']['runtime_proof_bundle_hash'],p['approved_bundle_hash'],p['runtime_proof_bundle_hash'],c['bundle_hash'],c['published_bundle_hash']]
        if 'publication' in m:
            if m['publication']['eligibility']!='eligible':return False
            hashes.append(m['publication']['published_bundle_hash'])
        if len(set(hashes))!=1:return False
        if m['runtime_proof']['authority_projection_hash']!=world:return False
        # Evidence IDs are unique. Approval signs the complete evaluated artifact set.
        receipt=parse_json(artifact_bytes[m['candidate_bundle']['receipt_ref']])
        valid_schema('bundle_receipt',receipt)
        if sha(canonical(receipt))!=hashes[0]:return False
        fp=m['normalized']['toolchain_fingerprint']
        if sha(canonical(fp))!=receipt['toolchain_fingerprint_hash']:return False
        if fp['source_file_hash']!=m['source']['files'][0]['sha256']:return False
        if any(file not in fp['output_hashes'] for file in m['normalized']['files']):return False
        for member in receipt['members']:
            if sha(artifact_bytes[member['path']])!=member['sha256']:return False
        for file in m['source']['files']+m['normalized']['files']:
            if sha(artifact_bytes[file['path']])!=file['sha256']:return False
        ev=p['evidence']; ids={e['evidence_id'] for e in ev}
        required_ids=set(c['required_evidence_ids'])|set(load_contract('tree_profile')['required_review_evidence'])
        if len(ids)!=len(ev) or not required_ids.issubset(ids):return False
        for e in ev:
            if e['artifact_ref'] not in artifact_bytes or sha(artifact_bytes[e['artifact_ref']])!=e['sha256']:return False
        def collect_evidence(value):
            if isinstance(value,dict):
                if set(value)=={'evidence_id','artifact_ref','sha256'}:return [value]
                return [e for v in value.values() for e in collect_evidence(v)]
            if isinstance(value,list):return [e for v in value for e in collect_evidence(v)]
            return []
        if any(e not in ev for e in collect_evidence(asset_contract_view(m))):return False
        evhash={e['sha256'] for e in ev}
        records=[g['record'] for g in m['gates'].values()]+[m['motion_review'],m['visual_review']]+list(m['validator_results'].values())
        for r in records:
            if sha(canonical(r)) not in evhash or any(e not in ev for e in r['evidence']):return False
        for x in m['motion_policy_results']:
            if any(e not in ev for e in x['evidence']):return False
        return True
    except Exception:return False

def transition_allowed(previous,next_manifest,current_rights_revision,artifact_bytes,trust,allow_test_fixture=False):
    """Pure adjacent-transition proof; not a workflow runner."""
    try:
        validate_manifest(previous);validate_manifest(next_manifest)
        stages=load_contract('lifecycle')['stages'];i=stages.index(previous['lifecycle_stage'])
        if i==len(stages)-1 or next_manifest['lifecycle_stage']!=stages[i+1]:return False
        if previous['disposition']!='current' or next_manifest['disposition']!='current':return False
        if next_manifest['invalidation']['blocking_dependencies']:return False
        for field in ['profile_id','asset_id','asset_version','attempt_id','job_id','request_id','family_id','style_family_id']:
            if previous[field]!=next_manifest[field]:return False
        for field in ['template','style_calibration','world_authority','source','normalized','animation','candidate_bundle']:
            if field in previous and previous[field]!=next_manifest.get(field):return False
        transition=load_contract('lifecycle')['transitions'][i]
        if not scopes_permitted(next_manifest,transition['rights_action'],current_rights_revision):return False
        if any(next_manifest['gates'][g]['status']!='passed' for g in transition['required_gates']):return False
        def verify_refs(value):
            if isinstance(value,dict):
                if set(value)=={'evidence_id','sha256','artifact_ref'}:
                    return value['artifact_ref'] in artifact_bytes and sha(artifact_bytes[value['artifact_ref']])==value['sha256']
                return all(verify_refs(v) for v in value.values())
            if isinstance(value,list):return all(verify_refs(v) for v in value)
            return True
        if not verify_refs(next_manifest):return False
        for container in ['source','normalized']:
            if container in next_manifest:
                for file in next_manifest[container]['files']:
                    if file['path'] not in artifact_bytes or sha(artifact_bytes[file['path']])!=file['sha256']:return False
        if next_manifest['lifecycle_stage']=='human_approved' and not verify_approval(next_manifest['human_approval'],trust,allow_test_fixture):return False
        return True
    except Exception:return False


def asset_contract_view(manifest):
    """Signed semantic contract; lifecycle progress/release pointers do not alter immutable content."""
    return {k:v for k,v in manifest.items() if k not in ['human_approval','publication','lifecycle_stage']}
