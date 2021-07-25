export GOOGLE_CLOUD_PROJECT="zinc-anvil-320815";
export ACCOUNTSERVICE_EMAIL="blender@zinc-anvil-320815.iam.gserviceaccount.com";
export GCP_CREDENTIALS_FILE="./service-key.json";
export BUCKET_EXPORT="gs://zinc-anvil-320815-3dmodels/";
export BUCKET_MODEL_SAVED="gs://zinc-anvil-320815-3dmodels/3dmodel/";

export CONTAINER_IMAGE_MASTER="gcr.io/${GOOGLE_CLOUD_PROJECT}/blender-master:v2.9.3";
export CONTAINER_IMAGE_NAME="gcr.io/${GOOGLE_CLOUD_PROJECT}/model3d-gpu:1.0";
export REGION="us-east1";
export SCALE_TIER="basic-gpu";
export JOB_NAME="render$(date '+%Y%m%d%H%M')";
export CLOUD_ML_JOB='{ "renders":[ { "bucket_model":"gs://zinc-anvil-320815-3dmodels/3dmodel", "blender_params":"--python ./blender_init.py -b ./main.blend -o ./render/render_ -F PNG -x 1 -E CYCLES -t 8 -s 1 -e 1 -a"}] }'
