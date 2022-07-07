#!/bin/bash

export PATH=/apps/jlab_server/bin:$PATH
export HOME=/home/$(whoami)
echo 'export HOME=/home/$(whoami)' > /home/$(whoami)/.bashrc
echo 'export PATH=/apps/jlab_server/bin:$PATH' >> /home/$(whoami)/.bashrc
python3 -m ipykernel install --user --name MNE
echo '{
 "argv": [
  "/apps/jlab_server/bin/python3",
  "-m",
  "ipykernel_launcher",
  "-f",
  "{connection_file}"
 ],
 "display_name": "MNE",
 "language": "python",
 "metadata": {
  "debugger": true
 },' > ~/.local/share/jupyter/kernels/mne/kernel.json
echo "
  \"env\": { \"HOME\": \"$HOME\" }
}" >> ~/.local/share/jupyter/kernels/mne/kernel.json

jlab=/apps/jupyterlab-desktop
$jlab/node_modules/electron/dist/electron --no-sandbox $jlab
