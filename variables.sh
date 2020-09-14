export GOOGLE_CLOUD_PROJECT="co-oortiz-internal";
export ACCOUNTSERVICE_EMAIL="blender-ai-render@co-oortiz-internal.iam.gserviceaccount.com";
export GCP_CREDENTIALS_FILE="./service-key.json";
export BUCKET_EXPORT="gs://co-oortiz-internal-3dmodels/";

export CONTAINER_VERSION="1.0";
export CONTAINER_IMAGE_MASTER="gcr.io/${GOOGLE_CLOUD_PROJECT}/blender-master:v2.9";
export CONTAINER_IMAGE_NAME="gcr.io/${GOOGLE_CLOUD_PROJECT}/model3d-gpu:${CONTAINER_VERSION}";
export REGION="us-east1";
export SCALE_TIER="basic-gpu";
export JOB_NAME="render$(date '+%Y%m%d%H%M')";
export CLOUD_ML_JOB='{ "scale_tier": "BASIC_GPU", "args": ["{ \"renders\":[ { \"kucket_model\":\"gs://co-oortiz-internal-3dmodels/3dmodel\", \"blender_params\":\"--python ./force_gpu.py -b ./model.blend -x 1 -E CYCLES -o ./render -f 1\"}] }"], "region": "us-east1", "run_on_raw_vm": true, "master_config": { "image_uri": "gcr.io/co-oortiz-internal/model3d-gpu:1.0" }}'
