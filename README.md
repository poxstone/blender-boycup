- Render frame:
```bash
blender -b "boycup.blend" -x 1 -E "CYCLES" -o "//render.png" -f 1;
```
- REnder animation/video 1-240:
```bash
blender -b "boycup.blend" -x 1 -E "CYCLES" -o "//render.mkv" -s 0 -e 240 -a;
```
