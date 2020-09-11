# Blender + container AI-Platform GPU

## Local tests
> **note:** Previous you need installed nvidia-drivers and nvidia-container-toolkit for your linux distro.

### Render Run commandline with GPU
- Render frame:
```bash
blender --python "force_gpu.py" -b "boycup.blend" -x 1 -E "CYCLES" -o "//render.png" -f 1;
```
- Render animation/video 1-240:
```bash
blender --python "force_gpu.py" -b "boycup.blend" -x 1 -E "CYCLES" -o "//render.mkv" -s 0 -e 240 -a;
```
- utils
```bash
watch -n1 nvidia-smi;
```

## Container local

- Build
  ```bash
  docker build -t poxstone/blender-gpu-10:2.9 .;
  ```
- Run
  ```bash
  docker run -it --rm --name "blender" --gpus all poxstone/blender-gpu-10:2.9;
  ```
- Run debug
  ```bash
  docker run -it --rm --name "blender" --gpus all --entrypoint sh poxstone/blender-gpu-10:2.9;
  ```
- Connect
  ```bash
  docker exec -it "blender" sh;
  ```

blender --python "force_gpu.py" -b "boycup.blend" -x 1 -E "CYCLES" -o "//render.mkv" -s 0 -e 240 -a;