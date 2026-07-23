# Animus_Dark_Matter Local Intelligence Multiplier (LIM) Framework
An instruction set to clone and establish mirrors of targeted content + create an agentic file structure based on the paper "Interpretable Context Methodology: Folder Structure as Agent Architecture" (https://arxiv.org/html/2603.16021v1) to handle when to access pertinent information situationally
This framework scales parametric reasoning on lightweight, local models by decoupling knowledge retrieval and state tracking from internal model weights. It turns a static local directory structure into a physical state machine (ICM), while offloading raw domain-knowledge ingestion onto standard input/output protocols (MCP).

```text
[ LOCAL MODEL CONTEXT BOUNDARY ]
 ├── Layer 0: System Identity (Enforces strict execution constraints)
 ├── Layer 1: Context Routing Matrix (Maps problems to data targets)
 ├── Layer 2: Isolated Functional Stages (One directory per state swap)
 ├── Layer 3: Hard-Gated Markdown Reference (MCP Data Ingestion Engine)
 └── Layer 4: Stateful Artifact Output (Shared scratchpad tokens)
```

### Core Execution Architecture

* **The Local Model Constraints**: Target small-footprint open-weights models (e.g., Llama-3-8B, Qwen-2.5-7B) optimized for high-speed local inference.
* **The ICM Engine (The State Machine)**: The file hierarchy enforces strict operational isolation. The model cannot jump between parsing intent, fetching documentation, and generating code within a single prompt cycle. It physically navigates separate directories to change operational states, keeping the context window pristine.
* **The MCP Layer (The Knowledge Vault)**: Raw developer documentation is mirrored purely as clean, isolated Markdown text. An `stdio` MCP server tool loads these text fragments dynamically, eliminating HTML overhead and ensuring the active context window contains near-zero token bloat.

---

### The Master Framework Prompt for Coding Agents

```markdown
Initialize a local AI architecture implementing the Local Intelligence Multiplier (LIM) framework, combining an stdio-based Model Context Protocol (MCP) server with an Interpretable Context Methodology (ICM) filesystem state machine to enable high-reasoning local execution. Establish a strict 5-layer folder hierarchy: `00_identity/` (system persona constraints), `01_routing/` (problem-to-documentation mapping matrices), `02_stages/` (isolated, sequential step folders enforcing "One Stage, One Job"), `03_reference/` (raw Markdown domain-knowledge mirrors), and `04_artifacts/` (state patches and active file canvas). The agent must only read/write files matching its current directory layer, never mixing intent-parsing with data-fetching or code-generation. Build a low-overhead, stdio-driven Rust/Python MCP server to pull clean text chunks from the reference layer via a single target function (`fetch_isolated_context`), ensuring the local model's context window remains highly accurate, text-only, and completely free from parametric saturation.
```

---

### Next Steps to Proceed
Would you like to build out the **exact file-switching algorithms** that force the local model to jump folders between tasks? Or should we focus on the **JSON schema design** for the state files that pass information across these layers?
