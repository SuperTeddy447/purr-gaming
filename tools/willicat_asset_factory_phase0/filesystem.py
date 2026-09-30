"""Isolated filesystem safety spike; not a production capability boundary."""
from pathlib import Path,PurePosixPath
import fcntl,json,os,shutil,tempfile
from .contracts import canonical,sha,valid_schema

def safe_path(root,relative):
    root=Path(root).resolve(strict=True)
    if Path('/private/tmp') not in root.parents:raise ValueError('Phase 0 writes require an isolated /private/tmp root')
    if not isinstance(relative,str) or not relative or '\\' in relative:raise ValueError('invalid path')
    parts=PurePosixPath(relative).parts
    if PurePosixPath(relative).is_absolute() or any(p in ['.','..'] for p in parts) or relative.startswith('res://'):raise ValueError('path escape')
    # Reject all symlink components, including dangling links. Private root ownership required.
    p=root
    for piece in parts:
        p=p/piece
        if p.is_symlink():raise ValueError('symlink forbidden')
    resolved=p.resolve()
    if resolved!=root and root not in resolved.parents:raise ValueError('outside root')
    return resolved

def write_once(root,relative,data):
    dest=safe_path(root,relative); dest.parent.mkdir(parents=True,exist_ok=True)
    dest=safe_path(root,relative)  # recheck immediately before write
    fd=os.open(dest,os.O_WRONLY|os.O_CREAT|os.O_EXCL|getattr(os,'O_NOFOLLOW',0),0o400)
    with os.fdopen(fd,'wb') as f:f.write(data);f.flush();os.fsync(f.fileno())

def atomic_pointer(root,relative,data,interrupt=False):
    """Serial lock + atomic replace demonstration. Root is isolated and owned by caller."""
    root=Path(root); lock=safe_path(root,'.publisher.lock')
    fd=os.open(lock,os.O_RDWR|os.O_CREAT|getattr(os,'O_NOFOLLOW',0),0o600)
    with os.fdopen(fd,'w') as f:
        fcntl.flock(f,fcntl.LOCK_EX)
        dest=safe_path(root,relative)
        tmp_fd,tmp=tempfile.mkstemp(prefix='.pointer-',dir=dest.parent)
        try:
            with os.fdopen(tmp_fd,'wb') as out:out.write(data);out.flush();os.fsync(out.fileno())
            if interrupt:raise InterruptedError('diagnostic interruption before replace')
            safe_path(root,relative);os.replace(tmp,dest)
            parent_fd=os.open(dest.parent,os.O_RDONLY)
            try:os.fsync(parent_fd)
            finally:os.close(parent_fd)
        finally:
            if os.path.exists(tmp):os.unlink(tmp)

def bundle_receipt(root,resource_map,registration_hash,rights_hash,fingerprint_hash):
    mapping=sorted(resource_map,key=lambda x:x['logical_path'])
    if len({x['logical_path'] for x in mapping})!=len(mapping) or len({x['member_path'] for x in mapping})!=len(mapping):raise ValueError('duplicate mapping')
    for x in mapping:
        if x['logical_path']!='res://'+x['member_path']:raise ValueError('resource mapping drift')
    members=[]
    for x in sorted(mapping,key=lambda x:x['member_path']):
        p=safe_path(root,x['member_path'])
        if '.godot' in p.parts or p.suffix in ['.import','.uid']:raise ValueError('ancillary cache forbidden')
        members.append({'path':x['member_path'],'sha256':sha(p.read_bytes())})
    r={'bundle_format_version':'tree-candidate-1','resource_map':mapping,'members':members,'registration_hash':registration_hash,'rights_reference_hash':rights_hash,'timing_recipe_version':'godot-ms-weight-1','toolchain_fingerprint_hash':fingerprint_hash}
    valid_schema('bundle_receipt',r);return r

def check_bundle(root,receipt):
    r=bundle_receipt(root,receipt['resource_map'],receipt['registration_hash'],receipt['rights_reference_hash'],receipt['toolchain_fingerprint_hash'])
    if r!=receipt:raise ValueError('bundle bytes changed: new candidate cycle required')
    return sha(canonical(r))

def promote_simulation(source,destination,receipt,expected_hash):
    """Only temporary roots in tests; copies bytes, never calls compiler or source provider."""
    if check_bundle(source,receipt)!=expected_hash:raise ValueError('unapproved bundle')
    for member in receipt['members']:write_once(destination,member['path'],safe_path(source,member['path']).read_bytes())
    if check_bundle(destination,receipt)!=expected_hash:raise ValueError('copy parity failed')
    # No visible release pointer until all member bytes verified.
    atomic_pointer(destination,'active.json',canonical({'bundle_hash':expected_hash}))
    return expected_hash
