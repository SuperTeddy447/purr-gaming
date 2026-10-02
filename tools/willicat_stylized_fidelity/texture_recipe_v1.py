"""Original procedural painted albedo recipe, confined to fresh DEV temp output."""
from pathlib import Path
import argparse
import numpy as np
from PIL import Image
parser=argparse.ArgumentParser();parser.add_argument("--out",required=True);args=parser.parse_args()
raw=Path(args.out)
if not raw.is_absolute() or ".." in raw.parts or raw.is_symlink():raise ValueError("Fresh /private/tmp output required")
A=raw.resolve()
if A.exists() or Path("/private/tmp") not in A.parents:raise ValueError("Fresh /private/tmp output required")
A.mkdir(parents=True);rng=np.random.default_rng(41071)
N=512; yy,xx=np.mgrid[0:N,0:N]; x=xx/N; y=yy/N
# Original algorithmic painted albedo; no reference/image pixels or photographs used.
def noise(scale):
 q=rng.normal(0,1,(scale,scale)); im=Image.fromarray(np.uint8(np.clip(q*35+128,0,255))).resize((N,N),Image.Resampling.BICUBIC); return (np.asarray(im).astype(float)-128)/35
broad=noise(9); fine=noise(80); tiny=noise(200)
def save(name,base,v):
 a=np.array(base)[None,None,:]*(1+v[:,:,None]); a[:,:,0]+=broad*1.5; a[:,:,2]-=broad*.8
 im=Image.fromarray(np.uint8(np.clip(a,0,255)));im.save(A/(name+'.png'))
warped=y+ .025*np.sin(x*8+noise(5)*.5)+.010*np.sin(x*32)
grain=.021*np.sin(warped*190)+.013*np.sin(warped*480)
knot=np.sqrt(((x-.63)*1.5)**2+((y-.42)*4)**2)
grain+=.028*np.sin(knot*105)*np.exp(-knot*3)
save('plaster_painted',(237,220,192),broad*.026+fine*.008+tiny*.004)
save('sage_woven',(115,131,93),broad*.02+fine*.008+(np.sin(xx*1.15)*np.sin(yy*1.3))*.010)
save('ceramic_painted',(233,225,205),broad*.018+fine*.005)
save('foliage_painted',(105,132,78),broad*.045+fine*.013)
