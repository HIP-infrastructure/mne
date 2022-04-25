FROM ubuntu:20.04

LABEL maintainer=""

ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir /apps

# Install wget
RUN apt-get update && \
    apt-get install -y wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Init a new user "mne_user" - Python environment about to be created using Conda and Jupyterlab desktop shd not be root
ARG MNE_USER="mne_user" 
ARG HOME_DIR="/home/${MNE_USER}"
ENV MNE_USER=${MNE_USER}
ENV HOME_DIR=${HOME_DIR}
RUN useradd -ms /bin/bash -d ${HOME_DIR} ${MNE_USER}

# Install Miniconda
ARG CONDA_DIR="/apps/conda/"
ENV PATH="${CONDA_DIR}/bin:${PATH}"
ARG PATH="${CONDA_DIR}/bin:${PATH}"
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    sh ./Miniconda3-latest-Linux-x86_64.sh -b -p ${CONDA_DIR} && \
    rm -f ./Miniconda3-latest-Linux-x86_64.sh
        
# MNE-Python and other Python packages are installed in a dedicated "mne-env" Python environment of "mne_user" using Conda

USER $MNE_USER 

ARG mne_v=v0.23.0   

RUN conda init && \
    conda create --name=mne-env
    
RUN conda install --yes \
    -n mne-env \
    -c conda-forge \
    python==3.9 \
    python-blosc \
    cytoolz \
    dask==2021.4.0 \
    lz4 \
    nomkl \
    numpy==1.21.0 \
    pandas==1.3.0 \
    tini==0.18.0 \
    && conda clean -tipsy && \
    conda run -n mne-env pip install s3fs && \
    conda run -n mne-env pip install bokeh && \
    conda run -n mne-env pip install nibabel joblib h5py && \
    conda run -n mne-env pip install pooch && \
    conda run -n mne-env pip install https://github.com/mne-tools/mne-python/archive/${mne_v}.zip && \
    conda run -n mne-env pip install vtk pyvista pyvistaqt PyQt5 matplotlib && \
    conda run -n mne-env pip install jupyterlab ipywidgets ipyvtklink
    # Install requested/missing Python packages here using Conda or PIP    
USER root

# 3D plot dependencies
RUN apt-get update && \
    apt-get install -y xvfb qt5-default && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
# Freesurfer dependencies
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository universe && \
    apt-get update && \
    apt-get install -y tcsh
    
# JupyterDesktop dependencies
RUN apt-get install -y libnotify4 && \
    apt-get install -y libnss3 && \
    apt-get install -y libxss1 && \
    apt-get install -y xdg-utils && \
    apt-get install -y libsecret-1-0
    
# Install Freesurfer
# TODO
    
# Install JupyterDesktop  
RUN wget https://github.com/jupyterlab/jupyterlab-desktop/releases/latest/download/JupyterLab-Setup-Debian.deb
RUN dpkg -i JupyterLab-Setup-Debian.deb
RUN rm JupyterLab-Setup-Debian.deb

# Jupyterlab desktop configuration file specifying the location of the "mne-env" Python environment
RUN mkdir -p /home/mne_user/.config/jupyterlab-desktop/
COPY ./config/jupyterlab-desktop-data /home/mne_user/.config/jupyterlab-desktop/jupyterlab-desktop-data 
RUN chmod 777 /home/mne_user/.config/jupyterlab-desktop/ 
    
USER $MNE_USER
WORKDIR $HOME_DIR

# 3D plot ENV
ENV \
    MNE_3D_BACKEND=pyvista \
    MNE_3D_OPTION_ANTIALIAS=false\
    START_XVFB=true
        
CMD jlab --no-sandbox # Sandbox mode might be enabled if requested





       









