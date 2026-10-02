"""Read-only receipt verification for Store archives. Phase 0 temp writers stay unchanged."""
from willicat_asset_factory_phase0.contracts import valid_schema,canonical,sha

def verify_archive(store,receipt):
    valid_schema('bundle_receipt',receipt)
    members=receipt['members'];mapping=receipt['resource_map'];root=store.path('canonical/bundle')
    expected={r['path']:r['sha256'] for r in members}
    if len(expected)!=len(members):raise ValueError('duplicate bundle member')
    paths=[]
    for p in root.rglob('*'):
        if p.is_symlink():raise ValueError('archive symlink')
        if p.is_file():paths.append(str(p.relative_to(root)))
    if set(paths)!=set(expected):raise ValueError('archive member set changed')
    logical=set();mapped=set()
    for r in mapping:
        if r['logical_path']!='res://'+r['member_path'] or r['logical_path'] in logical or r['member_path'] in mapped:raise ValueError('resource map mismatch')
        logical.add(r['logical_path']);mapped.add(r['member_path'])
    if mapped!=set(expected):raise ValueError('resource/member coverage mismatch')
    for rel in expected:
        if '.godot' in rel.split('/') or rel.endswith(('.uid','.import')):raise ValueError('cache in immutable bundle')
        data=store.read('canonical/bundle/'+rel)
        if sha(data)!=expected[rel]:raise ValueError('archive member hash mismatch')
    return sha(canonical(receipt))
