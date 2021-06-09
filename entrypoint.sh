#!/bin/bash

# CLOUD_ML_JOB is GCP arguments pass from gcloud
#CLOUD_ML_JOB='{ "scale_tier": "BASIC_GPU", "args": ["{ \"renders\":[ { \"kucket_model\":\"gs://stunning-tract-311613-3dmodels/20200913_06_19\", \"blender_params\":\"--python ./3dmodel/force_gpu.py -b ./3dmodel/model.blend -x 1 -E CYCLES -o ./render -f 1\"}] }"], "region": "us-east1", "run_on_raw_vm": true, "master_config": { "image_uri": "gcr.io/stunning-tract-311613/model3d-gpu:1.0" }}'
args="$(echo $CLOUD_ML_JOB | jq -r '.args' | ascii2uni -a U -q)";

# run with arguments or not
if [[ $args == "null" || $args == "" ]];then
    echo "RUN internal render model";
    # execute blender
    blender --python "${MODEL3D_FULL_PATH}/force_gpu.py" -b "${MODEL3D_FULL_PATH}/${MODEL3D_FILE}" -x 1 -E "CYCLES" -o "${RENDER_EXPORT}/${MODEL3D_FILE}" -a;
    # copy to bucket
    gsutil -m cp -r "${RENDER_EXPORT}/*" "${BUCKET_EXPORT}$(date '+%Y%m%d_%H_%M')/";
else
    echo "RUN external render models";
    dir_render_m="./internal_render/";
    render_len=$(echo $args | jq -r '.[0]' | jq -r '.renders | length');
    for i in $(seq 0 $(( $render_len - 1 )));do
        echo "EXECUTING model number:${i} of ${render_len}";
        arg_inx=$(echo $args | jq -r '.[0]' | jq -r ".renders[$i]");
        kucket_model=$(echo $arg_inx | jq -r '.kucket_model' | awk '{gsub("/+$","",$0);print($0)}');
        blender_params=$(echo $arg_inx | jq -r '.blender_params');
        
        # download blender from cloud storage
        mkdir -p "${dir_render_m}";
        gsutil -m cp -r "${kucket_model}/*" "${dir_render_m}";
        cd "${dir_render_m}";
        ls -lha;
        # render model
        blender ${blender_params};
        ls -lha;
        cd ..;
        gsutil -m cp -r "${dir_render_m}/*" "${BUCKET_EXPORT}$(date '+%Y%m%d_%H_%M')/";
        rm -rf "${dir_render_m}";
    done;
fi;
