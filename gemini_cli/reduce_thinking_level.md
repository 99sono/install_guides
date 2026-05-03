# Reducing Gemini CLI Thinking Level

This guide explains how to configure the Gemini CLI to use a "minimal" thinking level by default.

## Why Reduce Thinking Level?
- **Faster Responses**: Less time spent on deep internal reasoning means quicker initial output.
- **Lower Latency**: Ideal for simple tasks where deep analysis isn't required.
- **Token Efficiency**: Reduces the number of internal "thought" tokens generated.

## 1. Locate the Configuration File
On Linux, the Gemini CLI configuration is stored in:
- Path: `~/.gemini/settings.json`

## 2. Update the Configuration
To set the thinking level to minimal globally, add a `customOverrides` section to your `settings.json`.

### Example settings.json
```json
{
  "security": {
    "auth": {
      "selectedType": "oauth-personal"
    }
  },
  "modelConfigs": {
    "customOverrides": [
      {
        "match": {
          "model": ".*"
        },
        "modelConfig": {
          "generateContentConfig": {
            "thinkingConfig": {
              "includeProcess": true,
              "thinkingLevel": "MINIMAL"
            }
          }
        }
      }
    ]
  }
}
```

> **Note on `includeProcess`**: Even with `thinkingLevel: "MINIMAL"`, if `includeProcess` is set to `true`, you will still see the brief reasoning process. Set it to `false` if you want to hide reasoning entirely.

## 3. Model Compatibility
The `thinkingLevel` setting primarily applies to "Thinking" models (Gemini 3 Pro series and above).
- **Supported**: `gemini-3-pro-preview`, `gemini-3.1-pro-preview`, and aliases like `auto` or `pro`.
- **Not Applicable**: Flash or Flash-Lite models (e.g., `gemini-3-flash`) do not use this reasoning mechanism.

## 4. Verification
Since `customOverrides` are a power-user feature, they may not appear in simple config lists. To verify:
1. **Check the File**: Ensure your `~/.gemini/settings.json` matches the example above.
2. **Chat Test**: Run the CLI with a thinking model (e.g., `gemini --model pro`) and ask a complex question. The response should be significantly faster and the "Thought" section (if enabled) should be very brief.
