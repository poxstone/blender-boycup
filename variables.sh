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