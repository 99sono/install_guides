{
  "$schema": "https://opencode.ai/config.json",

  "model": "local/qwen3.6-27b-mtp",

  "provider": {

    "local": {
      "name": "local (RTX 5090)",
      "options": {
        "baseURL": "http://localhost:8000/v1",
        "apiKey": "YOUR_API_KEY_HERE"
      },
      "models": {
        "gemma-4-26b-it-nvfp4": {
          "name": "gemma-4-26b-it-nvfp4",
          "limit": { "context": 192000, "output": 32768 }
        }, 
        "qwen3.6-27b-mtp": {
          "name": "unsloth/Qwen3.6-27B-MTP-GGUF:UD-Q4_K_XL",
          "limit": { "context": 131072, "output": 32768 }
        }
      }
    },    

    "dgx-spark": {
      "name": "Qwen3.6-35B-A3B-NVFP4 (DGX Spark)",
      "options": {
        "baseURL": "https://dgx-spark-hostname/v1",
        "apiKey": "YOUR_API_KEY_HERE"
      },
      "models": {
        "Qwen3.6-35B-A3B-NVFP4": {
          "name": "Qwen3.6-35B-A3B-NVFP4",
          "limit": { "context": 262144, "output": 32768 }
        }
      }
    },
  
   "dgx-spark-debug": {
      "name": "Qwen3.6-35B-A3B-NVFP4 (DGX Spark debug)",
      "options": {
        "baseURL": "http://dgx-spark-hostname:8888/v1",
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


