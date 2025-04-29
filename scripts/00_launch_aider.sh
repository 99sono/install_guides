#!/bin/bash

# Get the directory where the script is located
SCRIPT_PATH="$(dirname "$(realpath "$0")")"


# NOTE: There is no need to configure the environment variable OLLAMA_API_BASE since
# the .aider.conf.yml already contains the approapriate configuration
# https://aider.chat/docs/llms/ollama.html
# export OLLAMA_API_BASE=http://127.0.0.1:11434
# other parameters like --model ollama/qwen2.5:7b are also contained in the .aider.conf.yml 


# Run aider with the parent directory as its context, without changing the working directory of the current shell
( cd "$SCRIPT_PATH/.." && aider   )