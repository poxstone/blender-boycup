FROM nvidia/cuda:10.0-devel-ubuntu18.04

# env
ENV BLENDER_MAJOR="2.90"
ENV BLENDER_VERSION="2.90.0"
ENV BLENDER_URL="https://ftp.nluug.nl/pub/graphics/blender/release/Blender${BLENDER_MAJOR}/blender-${BLENDER_VERSION}-linux64.tar.xz"
ENV BLENDER_PATH="/usr/local/blender"

# update
RUN apt-get update && \
	apt-get install -y \
		curl wget nano \
		bzip2 libfreetype6 libgl1-mesa-dev \
		libglu1-mesa \
        uni2ascii \
        jq \
		libxi6 libxrender1 && \
	apt-get -y autoremove
 RUN apt-get install -y python python-pip

# install gcloud
RUN wget -nv \
    https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz && \
    mkdir -p /opt/&& \
    tar xvzf google-cloud-sdk.tar.gz -C /opt/&& \
    rm google-cloud-sdk.tar.gz && \
    /opt/google-cloud-sdk/install.sh --usage-reporting=false \
        --path-update=false --bash-completion=false \
        --disable-installation-options && \
    rm -rf /opt/onfig/* && \
    ln -s /opt/onfig /config && \
    # Remove the backup directory that gcloud creates
    rm -rf /opt/google-cloud-sdk/.install/.backup; \
    # create links
    ln -s /opt/google-cloud-sdk/bin/gsutil /bin/gsutil; \
    ln -s /opt/google-cloud-sdk/bin/gcloud /bin/gcloud;

# Install blender
RUN wget --quiet "${BLENDER_URL}" -O blender.tar.xz && \
    mkdir "${BLENDER_PATH}" && \
    tar -xf blender.tar.xz -C ${BLENDER_PATH} --strip-components=1 && \
	rm blender.tar.xz && \
	ln -s ${BLENDER_PATH}/blender /usr/bin/blender;


ENTRYPOINT echo "ready to load renders"
