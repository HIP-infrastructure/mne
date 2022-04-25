## Use

Build: `docker build . -t hip-mne -f Dockerfile`
Use on a Ubuntu 20.04 host : `xhost +;docker-compose build;docker-compose up`

## Warnings

Needs to be further tested, especially regarding 3D plotting and multi-windows.

`/home/mne_user/.config/jupyterlab-desktop` and `/home/mne_user/.conda` directories are critical and should not be overwritten/lost when mounting volumes. They contain Jupyterlab Desktop configuration files and Conda-Python environments respectively.

`/home/mne_user/.bashrc` Initializes Conda. The user can `exec bash` in a Jupyter Notebook terminal to initialize/activate/use Conda environments.

By default, Jupyter Desktop uses the "mne-env" Conda-Python environment and all its packages are accessible without activation, including MNE-Python.
