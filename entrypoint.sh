#!/bin/bash

args="$(echo $CLOUD_ML_JOB | jq -r '.args' | ascii2uni -a U -q)";
DIR_RENDER_M="./internal_render/";
DATE_INIT="$(date '+%Y%m%d_%H_%M')";
IS_FINISHED="FALSE";
SLEEP=300;

echo "---> ENV $(env)";
echo "---> TEST_GSUTIL_PERMISSIONS $(gsutil ls)";

function gsCopySleep {
  echo "--> SEND_COPY_SLEEPING";
  local original_dir="${1}";
  local bucket_export="${2}";
  while [[ "${IS_FINISHED}" == "FALSE" ]];do
    gsutil -m cp -r "${original_dir}" "${bucket_export}";
    sleep ${SLEEP};
  done;
}

function blenderRenderWithPrams {
  local ARGS="${1}";
  local INDX="${2}";
  local is_cloudstorage="${3}";
  local arg_inx=$(echo $ARGS | jq -r '.[0]' | jq -r ".renders[$INDX]");
  local blender_params=$(echo $arg_inx | jq -r '.blender_params');
  
  # download blender from cloud storage
  if [[ "${is_cloudstorage}" != "" ]];then
    echo "--->6 COPY_FROM_BUCKET arg_inx= ${arg_inx}";
    local bucket_model=$(echo $arg_inx | jq -r '.bucket_model' | awk '{gsub("/+$","",$0);print($0)}');
    mkdir -p "${DIR_RENDER_M}";
    cd "${DIR_RENDER_M}";
    gsutil -m cp -r "${bucket_model}/*" ".";
  fi;
  
  pwd;
  ls -lha;
  echo "--->7 PARAMS_TO_BLENDER: blender ${blender_params}";
  DIR_RENDER_M='./render';
  gsCopySleep "${DIR_RENDER_M}/*" "${BUCKET_EXPORT}${DATE_INIT}/" & \
  blender ${blender_params};
  ls -lha;
  setFinalize;
  
  if [[ "${is_cloudstorage}" != "" ]];then
    echo "--->8 UPLOAD renders"
    cd ..;
    gsutil -m cp -r "${DIR_RENDER_M}/*" "${BUCKET_EXPORT}${DATE_INIT}/";
  fi;
}

function setFinalize {
  echo "--> CHANGE_VAR IS_FINISHED=TRUE";
  IS_FINISHED="TRUE";
}

# run with arguments or not
if [[ $args == "null" || $args == "" ]];then
  echo "--->1 RUN_INTERNAL_RENDER_MODEL";

  if [[ $LOCAL_JOB == "null" || $LOCAL_JOB == "" ]];then
    echo "--->2 RUN_INTERNAL_WITOUTH_PARAMETERS";      
    # execute blender -a = animation; -t = threads; -s init frame -e = end frame;
    gsCopySleep "${DIR_RENDER_M}/*" "${BUCKET_EXPORT}${DATE_INIT}/" & \
    blender --python "${MODEL3D_FULL_PATH}/blender_init.py" --background "${MODEL3D_FULL_PATH}/${MODEL3D_FILE}" --render-output "${RENDER_EXPORT}/${MODEL3D_FILE}" --use-extension 1 --engine "CYCLES" --render-anim;
    # render for specific frames animation and format
    #blender --python "${MODEL3D_FULL_PATH}/blender_init.py" --background "${MODEL3D_FULL_PATH}/${MODEL3D_FILE}" --render-output "${RENDER_EXPORT}/${MODEL3D_FILE}" --render-format "PNG" --use-extension 1 --engine "CYCLES" --threads 8 --frame-start 1 --frame-end 1 --render-anim;
    # copy to bucket
    setFinalize;
    gsutil -m cp -r "${RENDER_EXPORT}/*" "${BUCKET_EXPORT}${DATE_INIT}/";
 
  # Docker recive LOCAL_JOB parameters
  else
    echo "--->3 RUN_INTERNAL_WITH_PARAMS_BLENDER";
    args="$(echo $LOCAL_JOB | jq -r '.args' | ascii2uni -a U -q)";
    blenderRenderWithPrams "${args}" 0;
    setFinalize;
  fi;
else
  echo "--->4 RUN_EXTERNAL_RENDER_MODELS";
  render_len=$(echo $args | jq -r '.[0]' | jq -r '.renders | length');
  for i in $(seq 0 $(( $render_len - 1 )));do
    echo "--->5 RUN_EXECUTING_MODEL_NUMBER: ${i} of ${render_len}";
    # render model
    blenderRenderWithPrams "${args}" "$i" "is_cloudstorage";
    setFinalize;
  done;
fi;
