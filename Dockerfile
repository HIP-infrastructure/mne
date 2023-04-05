ARG CI_REGISTRY_IMAGE
ARG TAG
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
ARG JUPYTERLAB_DESKTOP_VERSION
FROM ${CI_REGISTRY_IMAGE}/jupyterlab-desktop:${JUPYTERLAB_DESKTOP_VERSION}${TAG}
LABEL maintainer="anthony.boyer@univ-amu.fr"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG

WORKDIR /apps/${APP_NAME}
    
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
    curl && \
    curl -sSLO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /apps/conda && \
    rm Miniconda3-latest-Linux-x86_64.sh && \
    export PATH=/apps/conda/bin:$PATH && \
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*    
   
ENV PATH="/apps/conda/bin:${PATH}"

# Create jupyter global config file
RUN mkdir /etc/jupyter \
 && echo "c.ServerApp.terminado_settings = { 'shell_command': ['/usr/bin/bash'] }" > /etc/jupyter/jupyter_lab_config.py \
 && echo "c.KernelSpecManager.whitelist = { 'mne' }" >> /etc/jupyter/jupyter_lab_config.py \
 && echo "c.KernelSpecManager.ensure_native_kernel = False" >> /etc/jupyter/jupyter_lab_config.py

#ENV APP_SPECIAL="jupyterlab-desktop"
ENV APP_SPECIAL="jupyterlab-desktop"
ENV APP_CMD=""
ENV PROCESS_NAME=""
ENV APP_DATA_DIR_ARRAY=".jupyter"
ENV DATA_DIR_ARRAY=""

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
