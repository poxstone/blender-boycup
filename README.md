# Blender + container AI-Platform GPU

- GCP Througthput:
  - cpu &gt; 4 = 60min aprox.
  - p100 x 1   = 27min aprox.
  - p100 x 4   = 14min aprox.


> ***Note:*** blender_init.py has camera name to activate
> ***Note:*** main.blend is main file and must be configure to eport to vídeo or default action to render

## variables

```bash
source varibles.sh;
```

## Local tests
> **note:** Previous you need installed nvidia-drivers and nvidia-container-toolkit for your linux distro.

### Render Run commandline with GPU
- Render frame:
```bash
blender --python "./3dmodel/blender_init.py" -b "./3dmodel/main.blend" -x 1 -E "CYCLES" -o "./render" -f 1 -b "./3dmodel/main.blend" -x 1 -E "CYCLES" -o "./render10" -f 10;
```
- Render animation/video 1-240:
```bash
blender --python "./3dmodel/blender_init.py" -b "./3dmodel/main.blend" -x 1 -E "CYCLES" -o "./render" -s 0 -e 3 -a;
blender.exe --python "3dmodel\blender_init.py" -b "3dmodel\main.blend" -x 1 -E "CYCLES" -o "render" -s 0 -e 3 -a
```
- utils
```bash
watch -n1 nvidia-smi;
```

## Container local

- Build master
  ```bash
  cd "blender_master"; docker build -t "${CONTAINER_IMAGE_MASTER}" "./"; cd ..;
  ```
- Build from master
  ```bash
  docker build -t "${CONTAINER_IMAGE_NAME}" \
    --build-arg "GOOGLE_CLOUD_PROJECT=${GOOGLE_CLOUD_PROJECT}" \
    --build-arg "ACCOUNTSERVICE_EMAIL=${ACCOUNTSERVICE_EMAIL}" \
    --build-arg "GCP_CREDENTIALS_FILE=${GCP_CREDENTIALS_FILE}" \
    --build-arg "BUCKET_EXPORT=${BUCKET_EXPORT}" \
    ".";
  ```
- Run simple
  ```bash
  docker run -it --rm --name "3dmodel" --gpus all "${CONTAINER_IMAGE_NAME}";
  
  # customize files
  docker run -it --rm --name "3dmodel" -v "$(pwd)/3dmodel:/3dmodel" -e "MODEL3D_FILE=main.blend" -v "$(pwd)/entrypoint.sh:/3dmodel/entrypoint.sh"  "${CONTAINER_IMAGE_NAME}";
  # enter to container run
  docker run -it --entrypoint sh "${CONTAINER_IMAGE_NAME}";
  ```
- Run multiple render and simulate GCP AI platform parameters
  ```bash
  docker run -it --rm --name "3dmodel" --gpus all -e "CLOUD_ML_JOB=${CLOUD_ML_JOB}" "${CONTAINER_IMAGE_NAME}";
  
  # customize local arguments
  LOCAL_JOB='{"args":[{ "renders":[ { "blender_params":"--python ./blender_init.py --background ./main.blend --render-output ./render/image_ --render-format PNG --use-extension 1 --engine CYCLES --threads 8 --frame-start 1 --frame-end 1 --render-anim"}] }]}';
  docker run -it --rm --name "3dmodel" -v "/home/poxstone/3DObjects/apto/:/3dmodel" -v "$(pwd)/entrypoint.sh:/3dmodel/entrypoint.sh" -e "MODEL3D_FILE=main.blend" -e "LOCAL_JOB=${LOCAL_JOB}" "${CONTAINER_IMAGE_NAME}";

  ```
- Run with debug
  ```bash
  docker run -it --rm --name "3dmodel" --gpus all --entrypoint "/bin/bash" "${CONTAINER_IMAGE_NAME}";
  ```
- Connect to docker running
  ```bash
  docker exec -it "3dmodel" sh;
  ```

## GCP

- Copy blender model to Cloud Storage
  ```bash
  gsutil -m cp -r "./3dmodel/*" "${BUCKET_MODEL_SAVED}";
  ```
- Build master
  ```bash
  cd "blender_master"; gcloud builds submit --tag "${CONTAINER_IMAGE_MASTER}" "./"  --project "${GOOGLE_CLOUD_PROJECT}"; cd ..;
  ```

- Build
  ```bash
  gcloud builds submit --tag "${CONTAINER_IMAGE_NAME}" "./"  --project "${GOOGLE_CLOUD_PROJECT}";
  ```
- Render K8 X 1 (38 min 32 sec)
  ```bash
  gcloud ai-platform jobs submit training "${JOB_NAME}" --project "${GOOGLE_CLOUD_PROJECT}" \
  --region "${REGION}" \
  --master-image-uri "${CONTAINER_IMAGE_NAME}" \
  --scale-tier "${SCALE_TIER}" \
  --stream-logs \
  -- \
  "${CLOUD_ML_JOB}"
  ```
- Render P100 X 2 (36 min 2 sec)
  ```bash
  gcloud ai-platform jobs submit training "${JOB_NAME}" --project "${GOOGLE_CLOUD_PROJECT}" \
  --region "${REGION}" \
  --master-image-uri "${CONTAINER_IMAGE_NAME}" \
  --scale-tier "CUSTOM" \
  --master-accelerator="count=2,type=NVIDIA_TESLA_P100" \
  --master-machine-type="n1-standard-4" \
  --stream-logs \
  -- \
  "${CLOUD_ML_JOB}"
  ```
