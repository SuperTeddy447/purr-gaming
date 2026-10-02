"""Development-only immutable store. No production publisher capability."""
from pathlib import Path,PurePosixPath
import os,fcntl,secrets,json
from willicat_asset_factory_phase0.contracts import canonical,sha,parse_json

class Store:
    def __init__(self,root,repo):
        self.repo=Path(repo).resolve(strict=True); p=Path(root)
        if not p.is_absolute():raise ValueError('absolute development root required')
        if any(x=='..' for x in p.parts):raise ValueError('root traversal')
        for parent in [p,*p.parents]:
            if parent.is_symlink():raise ValueError('symlink root forbidden')
        p=p.resolve()
        allowed=self.repo/'artifacts/asset_factory/mvp_and_tree_pilot_v1'
        if Path('/private/tmp') not in p.parents and p!=allowed and allowed not in p.parents:raise ValueError('no production write capability')
        p.mkdir(parents=True,exist_ok=True);self.root=p
    def path(self,relative):
        if not isinstance(relative,str) or not relative or '\\' in relative:raise ValueError('invalid relative path')
        parts=relative.split('/')
        if any(v in ['', '.', '..'] for v in parts) or PurePosixPath(relative).is_absolute() or ':' in relative:raise ValueError('path traversal/URI')
        p=self.root
        for piece in parts:
            p=p/piece
            if p.is_symlink():raise ValueError('symlink escape')
        if self.root not in p.resolve().parents:raise ValueError('root escape')
        return p
    def _parent_fd(self,relative):
        self.path(relative)
        fd=os.open(self.root,os.O_RDONLY|os.O_DIRECTORY|os.O_NOFOLLOW)
        try:
            for part in relative.split('/')[:-1]:
                try:os.mkdir(part,mode=0o700,dir_fd=fd)
                except FileExistsError:pass
                new=os.open(part,os.O_RDONLY|os.O_DIRECTORY|os.O_NOFOLLOW,dir_fd=fd);os.close(fd);fd=new
            return fd,relative.split('/')[-1]
        except BaseException:os.close(fd);raise
    def once(self,relative,data):
        parent,name=self._parent_fd(relative)
        try:
            fd=os.open(name,os.O_WRONLY|os.O_CREAT|os.O_EXCL|os.O_NOFOLLOW,0o400,dir_fd=parent)
            with os.fdopen(fd,'wb') as f:f.write(data);f.flush();os.fsync(f.fileno())
            os.fsync(parent)
        finally:os.close(parent)
        return {'evidence_id':relative.replace('/','_'),'artifact_ref':relative,'sha256':sha(data)}
    def json(self,relative,value):return self.once(relative,canonical(value))
    def read(self,relative):
        parent,name=self._parent_fd(relative)
        try:
            fd=os.open(name,os.O_RDONLY|os.O_NOFOLLOW,dir_fd=parent)
            with os.fdopen(fd,'rb') as f:return f.read()
        finally:os.close(parent)
    def pointer(self,relative,value):
        parent,name=self._parent_fd(relative);lock=os.open('.store.lock',os.O_CREAT|os.O_RDWR|os.O_NOFOLLOW,0o600,dir_fd=parent)
        temp='.pointer-'+secrets.token_hex(12)
        try:
            fcntl.flock(lock,fcntl.LOCK_EX)
            fd=os.open(temp,os.O_CREAT|os.O_EXCL|os.O_WRONLY|os.O_NOFOLLOW,0o600,dir_fd=parent)
            with os.fdopen(fd,'wb') as f:f.write(canonical(value));f.flush();os.fsync(f.fileno())
            os.replace(temp,name,src_dir_fd=parent,dst_dir_fd=parent);os.fsync(parent)
        finally:
            try:os.unlink(temp,dir_fd=parent)
            except FileNotFoundError:pass
            os.close(lock);os.close(parent)
    def artifacts(self):
        return {str(p.relative_to(self.root)):self.read(str(p.relative_to(self.root))) for p in self.root.rglob('*') if p.is_file() and not p.is_symlink()}
