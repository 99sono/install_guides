# See: https://gemini-console.com/docs#get-started-installation
conda create -y -n gemini_env -c conda-forge nodejs
conda activate gemini_env

sudo npm install -g @google/gemini-cli@latest