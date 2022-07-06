ARG CI_REGISTRY_IMAGE
ARG JUPYTERLAB_DESKTOP_VERSION
FROM ${CI_REGISTRY_IMAGE}/jupyterlab-desktop:${JUPYTERLAB_DESKTOP_VERSION}
LABEL maintainer="anthony.boyer@univ-amu.fr"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION

ARG CONDA_DIR="/apps/conda/"
ENV PATH="${CONDA_DIR}/bin:${PATH}"

LABEL app_version=$APP_VERSION

WORKDIR /apps/${APP_NAME}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# MNE-Python and other Python packages are installed in a dedicated "mne-env" Python environment of "mne_user" using Conda
RUN conda init && \
    conda create --name=mne-env

RUN conda install -y -n mne-env -c conda-forge \
    python \
    python-blosc \
    cytoolz \
    dask \
    lz4 \
    nomkl \
    numpy \
    pandas && \
#    conda clean -tipsy && \
    rm -rf /opt/conda/pkgs
#    conda run -n mne-env pip install s3fs && \
#    conda run -n mne-env pip install bokeh && \
#    conda run -n mne-env pip install nibabel joblib h5py && \
#    conda run -n mne-env pip install pooch && \
#    conda run -n mne-env pip install https://github.com/mne-tools/mne-python/archive/v${APP_VERSION}.zip && \
#    conda run -n mne-env pip install vtk pyvista pyvistaqt PyQt5 matplotlib

ENV APP_SPECIAL="jupyterlab-desktop"
ENV APP_CMD=""
ENV PROCESS_NAME=""
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""
ENV CONFIG_ARRAY=".bash_profile"

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/
COPY ./apps/${APP_NAME}/config config/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
