# Tracked GitHub Issues

Issues from the [anomalyco/opencode](https://github.com/anomalyco/opencode) repository that I am monitoring.

---

## #24316 — Progress halts with Qwen 3.6 35B-A3B due to naked tool call XML

| Field | Value |
|-------|-------|
| **URL** | https://github.com/anomalyco/opencode/issues/24316 |
| **Labels** | bug, core |
| **Author** | @boutello |

**Summary:** Qwen 3.6 models (especially quantized variants like IQ4_XS, IQ4_NL, Q8_K_XL) running via llama.cpp or vLLM sometimes output raw XML tool call tags directly in their response text instead of properly parsing them as tool invocations. This causes the OpenCode TUI to stall with the model's progress halting mid-thought. The issue started around OpenCode v1.14.22/1.14.23 and affects long-running tasks. Cline CLI does not have this problem with the same models.

**Related issues:** #9674, #8877, #16488, #26162

---

*Add new issues below this line as you encounter them.*