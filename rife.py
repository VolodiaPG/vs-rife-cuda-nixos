import vapoursynth as vs
from vsrife import RIFE
core = vs.core

clip = video_in

clip = vs.core.resize.Bicubic(clip, format=vs.RGBS, matrix_in_s='709')
clip = RIFE(clip, fp16=True, scale=0.25, device_type='cuda')
clip = vs.core.resize.Bicubic(clip, format=vs.YUV420P8, matrix_s="709")

clip.set_output()
