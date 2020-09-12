# Blender + container AI-Platform GPU

- GCP Througthput:
  - cpu &gt; 4 = 60min aprox.
  - p100 x 1   = 27min aprox.
  - p100 x 4   = 14min aprox.


## variables

```bash
source varibles.sh;
```

## Local tests
> **note:** Previous you need installed nvidia-drivers and nvidia-container-toolkit for your linux distro.

### Render Run commandline with GPU
- Render frame:
```bash
blender --python "./3dmodel/force_gpu.py" -b "./3dmodel/model.blend" -x 1 -E "CYCLES" -o "./render" -f 1;
```
- Render animation/video 1-240:
```bash
blender --python "./3dmodel/force_gpu.py" -b "./3dmodel/model.blend" -x 1 -E "CYCLES" -o "./render" -s 0 -e 3 -a;
```
- utils
```bash
watch -n1 nvidia-smi;
```

## Container local

- Build
  ```bash
  cd blender_master; gdocker build -t "${CONTAINER_IMAGE_MASTER}" "./"; cd ..;

  docker build -t "${CONTAINER_IMAGE_NAME}" \
    --build-arg "GOOGLE_CLOUD_PROJECT=${GOOGLE_CLOUD_PROJECT}" \
    --build-arg "ACCOUNTSERVICE_EMAIL=${ACCOUNTSERVICE_EMAIL}" \
    --build-arg "GCP_CREDENTIALS_FILE=${GCP_CREDENTIALS_FILE}" \
    --build-arg "BUCKET_EXPORT=${BUCKET_EXPORT}" \
    "./";
  ```
- Run
  ```bash
  docker run -it --rm --name "3dmodel" --gpus all "${CONTAINER_IMAGE_NAME}";
  ```
- Run debug
  ```bash
  docker run -it --rm --name "3dmodel" --gpus all --entrypoint "/bin/bash" "${CONTAINER_IMAGE_NAME}";
  ```
- Connect
  ```bash
  docker exec -it "3dmodel" sh;
  ```

## GCP

- Build master
  ```bash
  cd blender_master; gcloud builds submit --tag "${CONTAINER_IMAGE_MASTER}" "./"  --project "${GOOGLE_CLOUD_PROJECT}"; cd ..;
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
  --async;
  ```
- Render P100 X 2 (36 min 2 sec)
  ```bash
  gcloud ai-platform jobs submit training "${JOB_NAME}" --project "${GOOGLE_CLOUD_PROJECT}" \
  --region "${REGION}" \
  --master-image-uri "${CONTAINER_IMAGE_NAME}" \
  --scale-tier "CUSTOM" \
  --master-accelerator="count=2,type=NVIDIA_TESLA_P100" \
  --master-machine-type="n1-standard-4" \
  --async;
  ```


  CLOUD_ML_JOB='{ "scale_tier": "BASIC_GPU", "args": ["--hola\u003dmundo", "--perro\u003dchango"], "region": "us-east1", "run_on_raw_vm": true, "master_config": { "image_uri": "gcr.io/co-oortiz-internal/model3d-gpu:1.0" }}'