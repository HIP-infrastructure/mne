ARG CI_REGISTRY_IMAGE
ARG TAG
ARG JUPYTERLAB_DESKTOP__VERSION
FROM ${CI_REGISTRY_IMAGE}/jupyterlab-desktop:${JUPYTERLAB_DESKTOP_VERSION}${TAG}
LABEL maintainer="anthony.boyer@univ-amu.fr"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG

RUN mkdir /apps
    
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install ca-certificates -y && \
    apt-get install --no-install-recommends -y \
    curl && \
    curl -sSLO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /apps/conda && \
    rm Miniconda3-latest-Linux-x86_64.sh && \
    export PATH=/apps/conda/bin:$PATH && \
    conda install -c conda-forge -y nodejs constructor && \
    npm install -g yarn && \
    cd /apps && \
    curl -sSL https://github.com/jupyterlab/jupyterlab-desktop/archive/refs/tags/v${JUPYTERLAB_DESKTOP_VERSION}.tar.gz | tar xzf - && \
    mv jupyterlab-desktop-${JUPYTERLAB_DESKTOP_VERSION} jupyterlab-desktop && \
    cd jupyterlab-desktop && \
    conda update -y nodejs && \
    yarn install && \
    yarn build && \
    yarn create_env_installer:linux && \
    env_installer/JupyterLabDesktopAppServer-*-Linux-x86_64.sh -b -p /apps/jlab_server && \
    # rm -rf env_installer && \
    export PATH=/apps/jlab_server/bin:$PATH && \
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*    
   
# JupyterDesktop dependencies
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository universe && \
    apt-get update && \ 
    apt-get install -y libnotify4 && \
    apt-get install -y libnss3 && \
    apt-get install -y libxss1 && \
    apt-get install -y xdg-utils && \
    apt-get install -y libsecret-1-0 && \
    apt-get install -y libgbm-dev && \   
    apt-get install -y libasound2 && \
    apt-get install -y libasound2-dev
         
# Add conda and jlab_server to PATH    
ENV PATH="/apps/conda/bin:${PATH}"
ENV PATH="/apps/jlab_server/bin:${PATH}"

# Create jupyter global config file
RUN mkdir /etc/jupyter \
 && echo "c.ServerApp.terminado_settings = { 'shell_command': ['/usr/bin/bash'] }" > /etc/jupyter/jupyter_lab_config.py \
 && echo "c.KernelSpecManager.whitelist = { 'mne' }" >> /etc/jupyter/jupyter_lab_config.py \
 && echo "c.KernelSpecManager.ensure_native_kernel = False" >> /etc/jupyter/jupyter_lab_config.py

ENV APP_CMD="/apps/start_jlab.sh"
ENV PROCESS_NAME="electron"
ENV DIR_ARRAY=".jupyter"

# Set user environment and create jupyter user config file
COPY start_jlab.sh /apps

COPY docker_entrypoint.sh /apps

# Use conda to install MNE and other Python packages into the jlab_server
ARG mne_v=v0.23.0   
    
RUN conda install --yes \
    -n base \
    -c conda-forge \
    python \
    python-blosc \
    cytoolz \
    dask \
    lz4 \
    nomkl \
    numpy \
    pandas \
    tini \
    && conda clean -tip && \
    conda run -n base pip install s3fs && \
    conda run -n base pip install bokeh && \
    conda run -n base pip install nibabel joblib h5py && \
    conda run -n base pip install pooch && \
    conda run -n base pip install https://github.com/mne-tools/mne-python/archive/${mne_v}.zip && \
    conda run -n base pip install vtk pyvista pyvistaqt PyQt5 matplotlib && \
    conda run -n base pip install jupyterlab ipywidgets ipyvtklink
    # Install requested/missing Python packages here using Conda or PIP  

# MNE - 3D plot dependencies
# apt-get install -y qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools -> for 21.04 OR apt-get install -y qt5-default -> for 20.04
RUN apt-get update && \
    apt-get install -y qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools && \
    apt-get install -y xvfb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
# MNE - Freesurfer dependencies (not sure we need it since the user can just run Freesurfer as a separate app)
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository universe && \
    apt-get update && \
    apt-get install -y tcsh 
   
# MNE - 3D plot ENV
ENV \
    MNE_3D_BACKEND=pyvista \
    MNE_3D_OPTION_ANTIALIAS=false\
    START_XVFB=true
        
ENTRYPOINT ["/apps/docker_entrypoint.sh"]
