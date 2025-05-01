# Model Metadata for Ollama

## Overview

To ensure Ollama functions correctly, it requires detailed metadata for each model it uses. This metadata helps define crucial parameters such as:
- **Maximum tokens**: The total token limit for a model.
- **Maximum input tokens**: The maximum number of tokens allowed in the input prompt.
- **Maximum output tokens**: The maximum number of tokens the model can generate in response.
- **Cost per token**: Token-based pricing for input and output processing.
- **Model provider**: Defines the backend provider that serves the model.
- **Mode**: Specifies whether the model operates in **chat**, **completion**, or other modes.

### Importance of Metadata
Providing accurate metadata ensures:
- Optimal performance and efficiency of models.
- Avoidance of hallucinations or errors due to incorrect token limits.
- Proper resource allocation when dealing with multiple models.

---

## **Context Length Considerations**

Some models allow **significantly larger context windows**, meaning they can handle more tokens in conversations. However, if your local Ollama Docker container is configured with:
```yaml
- OLLAMA_CONTEXT_LENGTH=8192
```
It is essential to **align your model metadata settings with this limitation** to avoid inconsistencies between the configured environment and model expectations.

### Ensuring Consistency
When setting up the `.aider.model.metadata.json` file, ensure that the **max_tokens**, **max_input_tokens**, and **max_output_tokens** values reflect the constraints of your local Ollama setup.

---

## Example Model Metadata Configuration

An example `.aider.model.metadata.json` file, structured for Ollama, could look like this:

```json
{
    "qwen2.5:7b": {
        "max_tokens": 8192,
        "max_input_tokens": 8192,
        "max_output_tokens": 8192,
        "input_cost_per_token": 0.00000014,
        "output_cost_per_token": 0.00000028,
        "litellm_provider": "ollama_chat",
        "mode": "chat"
    },
    "gemma3:1b": {
        "max_tokens": 8192,
        "max_input_tokens": 8192,
        "max_output_tokens": 8192,
        "input_cost_per_token": 0.00000014,
        "output_cost_per_token": 0.00000028,
        "litellm_provider": "ollama_chat",
        "mode": "chat"
    },
    "gemma3:4b": {
        "max_tokens": 8192,
        "max_input_tokens": 8192,
        "max_output_tokens": 8192,
        "input_cost_per_token": 0.00000014,
        "output_cost_per_token": 0.00000028,
        "litellm_provider": "ollama_chat",
        "mode": "chat"
    },
    "gemma3:12b": {
        "max_tokens": 8192,
        "max_input_tokens": 8192,
        "max_output_tokens": 8192,
        "input_cost_per_token": 0.00000014,
        "output_cost_per_token": 0.00000028,
        "litellm_provider": "ollama_chat",
        "mode": "chat"
    }
}
```

### Configuration Tips:
- Ensure the **`litellm_provider`** is set to `"ollama_chat"` to avoid issues where Aider hallucinates non-existent files.
- Validate that **`max_tokens`**, **`max_input_tokens`**, and **`max_output_tokens`** match your configured **OLLAMA_CONTEXT_LENGTH** to maintain consistency.

---

## Acknowledgment

Special thanks to **Microsoft Edge Copilot** for its invaluable assistance in structuring this guide and improving the clarity of documentation. The support provided by this tool has greatly enhanced the usability and quality of this guide.
