ARG MASTER_IMAGE="gcr.io/co-oortiz-internal/blender-master:v2.9"
FROM ${MASTER_IMAGE}

# args
ARG GOOGLE_CLOUD_PROJECT="co-oortiz-internal"
ARG ACCOUNTSERVICE_EMAIL="blender-ai-render@co-oortiz-internal.iam.gserviceaccount.com"
ARG GCP_CREDENTIALS_FILE="./service-key.json"
ARG BUCKET_EXPORT="gs://co-oortiz-internal-3dmodels/"

ENV MODEL3D_PATH="./3dmodel"
ENV MODEL3D_FULL_PATH="/${MODEL3D_PATH}"
ENV MODEL3D_FILE="model.blend"
ENV RENDER_EXPORT="${MODEL3D_FULL_PATH}/render/"
ENV ENTRYPOINT_FILE="./entrypoint.sh"

# google 
ENV GOOGLE_CLOUD_PROJECT="${GOOGLE_CLOUD_PROJECT}"
ENV ACCOUNTSERVICE_EMAIL="${ACCOUNTSERVICE_EMAIL}"
ENV GOOGLE_APPLICATION_CREDENTIALS="${MODEL3D_FULL_PATH}/${GCP_CREDENTIALS_FILE}"
ENV BUCKET_EXPORT="${BUCKET_EXPORT}"

RUN mkdir -p "${RENDER_EXPORT}"

# copying needed files
COPY ${MODEL3D_PATH} ${MODEL3D_FULL_PATH}
COPY ${GCP_CREDENTIALS_FILE} ${GOOGLE_APPLICATION_CREDENTIALS}
COPY ${ENTRYPOINT_FILE} ${MODEL3D_FULL_PATH}

# GCP authorize service account
RUN gcloud auth activate-service-account "${ACCOUNTSERVICE_EMAIL}" \
    --key-file "${GOOGLE_APPLICATION_CREDENTIALS}" -q;

WORKDIR ${MODEL3D_FULL_PATH}
ENTRYPOINT sh ${ENTRYPOINT_FILE}
