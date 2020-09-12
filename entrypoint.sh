#!/bin/sh

# parse and read argumets to json
#CLOUD_ML_JOB={ "scale_tier": "BASIC_GPU", "args": ["--hola\u003dmundo", "--perro\u003dchango"], "region": "us-east1", "run_on_raw_vm": true, "master_config": { "image_uri": "gcr.io/co-oortiz-internal/model3d-gpu:1.0" }}
echo $CLOUD_ML_JOB | jq -r ".args";

# Todo: parse arguments and set dynamic 

# execute blender
blender --python "${MODEL3D_FULL_PATH}/force_gpu.py" -b "${MODEL3D_FULL_PATH}/${MODEL3D_FILE}" -x 1 -E "CYCLES" -o "${RENDER_EXPORT}/${MODEL3D_FILE}" -a;

# copy to bucket
gsutil cp -r "${RENDER_EXPORT}/*" "${BUCKET_EXPORT}$(date '+%Y%m%d_%H_%M')/";
