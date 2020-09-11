FROM nvidia/cuda:10.0-devel-ubuntu18.04

ENV BLENDER_MAJOR="2.90"
ENV BLENDER_VERSION="2.90.0"
ENV BLENDER_URL="https://ftp.nluug.nl/pub/graphics/blender/release/Blender${BLENDER_MAJOR}/blender-${BLENDER_VERSION}-linux64.tar.xz"
ENV MODEL3D_PATH="./media3d"
ENV MODEL3D_FULL_PATH="/${MODEL3D_PATH}"
ENV MODEL3D_FILE="boycup.blend"
ENV BLENDER_PATH="/usr/local/blender"
ENV RENDER_EXPORT="${MODEL3D_FULL_PATH}/render/"

RUN apt-get update && \
	apt-get install -y \
		curl wget nano \
		bzip2 libfreetype6 libgl1-mesa-dev \
		libglu1-mesa \
		libxi6 libxrender1 && \
	apt-get -y autoremove

# Install blender
RUN wget --quiet "${BLENDER_URL}" -O blender.tar.xz && \
    mkdir "${BLENDER_PATH}" && \
    tar -xf blender.tar.xz -C ${BLENDER_PATH} --strip-components=1 && \
	rm blender.tar.xz && \
	ln -s ${BLENDER_PATH}/blender /usr/bin/blender;

COPY ${MODEL3D_PATH} MODEL3D_FULL_PATH
RUN mkdir "${RENDER_EXPORT}"

VOLUME ${MODEL3D_FULL_PATH}/render

WORKDIR ${MODEL3D_FULL_PATH}
ENTRYPOINT blender --python "${MODEL3D_FULL_PATH}/force_gpu.py" -b "${MODEL3D_FULL_PATH}/${MODEL3D_FILE}" -x 1 -E "CYCLES" -o "//{MODEL3D_FILE}.mkv" -a;
