{
  "$schema": "https://opencode.ai/config.json",

  "model": "local/Qwen3.6-35B-A3B-NVFP4",

  "provider": {

    "local": {
      "name": "Qwen3.6-35B-A3B-NVFP4 (Local RTX 5090)",
      "options": {
        "baseURL": "https://localhost:8443/v1",
        "apiKey": "YOUR_API_KEY_HERE"
      },
      "models": {
        "Qwen3.6-35B-A3B-NVFP4": {
          "name": "Qwen3.6-35B-A3B-NVFP4",
          "limit": { "context": 64000, "output": 8192 }
        }
      }
    },

    "dgx-spark": {
      "name": "Qwen3.6-35B-A3B-NVFP4 (DGX Spark Remote)",
      "options": {
        "baseURL": "https://dgx-spark-hostname:8443/v1",
        "apiKey": "YOUR_API_KEY_HERE"
      },
      "models": {
        "Qwen3.6-35B-A3B-NVFP4": {
          "name": "Qwen3.6-35B-A3B-NVFP4",
          "limit": { "context": 262144, "output": 32768 }
        }
      }
    }

  }

}