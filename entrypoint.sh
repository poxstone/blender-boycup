#!/bin/bash

args="$(echo $CLOUD_ML_JOB | jq -r '.args' | ascii2uni -a U -q)";
dir_render_m="./internal_render/";
echo "---env $(env)";
echo "---gsutil $(gsutil ls)";

function blenderRenderWithPrams {
    local ARGS="${1}";
    local INDX="${2}";
    local is_cloudstorage="${3}";
    local arg_inx=$(echo $ARGS | jq -r '.[0]' | jq -r ".renders[$INDX]");
    local blender_params=$(echo $arg_inx | jq -r '.blender_params');
    
    # download blender from cloud storage
    if [[ "${is_cloudstorage}" != "" ]];then
        echo "---6 COPY FROM BUCKET arg_inx= ${arg_inx}";
        local bucket_model=$(echo $arg_inx | jq -r '.bucket_model' | awk '{gsub("/+$","",$0);print($0)}');
        mkdir -p "${dir_render_m}";
        cd "${dir_render_m}";
        gsutil -m cp -r "${bucket_model}/*" ".";
    fi;

    pwd;
    ls -lha;
    echo "---7 PARAMS_TO_BLENDER: blender ${blender_params}";
    blender ${blender_params};
    ls -lha;

    if [[ "${is_cloudstorage}" != "" ]];then
      echo "---8 UPLOAD renders"
      cd ..;
      gsutil -m cp -r "${dir_render_m}/*" "${BUCKET_EXPORT}$(date '+%Y%m%d_%H_%M')/";
      rm -rf "${dir_render_m}";
    fi;
}

# run with arguments or not
if [[ $args == "null" || $args == "" ]];then
    echo "---1 RUN internal render model";
    if [[ $LOCAL_JOB == "null" || $LOCAL_JOB == "" ]];then
      echo "---2 witouth parameters";      
      # execute blender -a = animation; -t = threads; -s init frame -e = end frame;
      blender --python "${MODEL3D_FULL_PATH}/blender_init.py" --background "${MODEL3D_FULL_PATH}/${MODEL3D_FILE}" --render-output "${RENDER_EXPORT}/${MODEL3D_FILE}" --use-extension 1 --engine "CYCLES" --render-anim;
      # render for specific frames animation and format
      #blender --python "${MODEL3D_FULL_PATH}/blender_init.py" --background "${MODEL3D_FULL_PATH}/${MODEL3D_FILE}" --render-output "${RENDER_EXPORT}/${MODEL3D_FILE}" --render-format "PNG" --use-extension 1 --engine "CYCLES" --threads 8 --frame-start 1 --frame-end 1 --render-anim;
      # copy to bucket
      gsutil -m cp -r "${RENDER_EXPORT}/*" "${BUCKET_EXPORT}$(date '+%Y%m%d_%H_%M')/";
    fi;
    # Docker recive parameters
    if [[ $LOCAL_JOB != "null" && $LOCAL_JOB != "" ]];then
        echo "---3 RUN internal render model for test";
        args="$(echo $LOCAL_JOB | jq -r '.args' | ascii2uni -a U -q)";
        blenderRenderWithPrams "${args}" 0;
    fi;
else
    echo "---4 RUN external render models";
    render_len=$(echo $args | jq -r '.[0]' | jq -r '.renders | length');
    for i in $(seq 0 $(( $render_len - 1 )));do
        echo "---5 EXECUTING model number:${i} of ${render_len}";

        # render model
        blenderRenderWithPrams "${args}" "$i" "is_cloudstorage";
    done;
fi;
