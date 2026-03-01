# Squad BMAD: Automated Project Orchestration Assistant with Gemini & Claude Code

*Read this in other languages: [English](README.md), [Tiếng Việt](README.vi.md).*

Welcome to **Squad BMAD** – a boilerplate/design solution to transform **Gemini CLI** into a true **Project Manager & Principal Tech Lead**. By combining Gemini's orchestration power with **Claude Code's** excellent coding and reasoning capabilities via **Tmux**, this project automates and optimizes the software development workflow based on the **BMAD** methodology.

---

## 🌟 Benefits

The BMAD (Build-Measure-Analyze-Deploy) methodology is known for maintaining strictness, clear structure, and being strongly **spec-driven**. However, its biggest drawback is that the operation process requires many steps and manual actions.

**Squad BMAD completely solves this problem:**
- **Seamless Automation:** Makes operating a project with the BMAD method smooth and continuous without requiring your intervention in every small step.
- **An Indefatigable Project Assistant:** This assistant will help you answer and handle BMAD steps, automatically operating and implementing all Epics and Stories.
- **Focus on Core Value:** You only need to talk to the Assistant (Gemini), make high-level decisions, and the Assistant will automatically delegate tasks and monitor the other Agents (Claude Code).

---

## 📋 System Requirements

To run this system smoothly, you need to prepare:

- **Claude Code Account:** Required to launch the Execution (Implement) and Reasoning (Brainstorm) Agents.
- **Gemini Account (Gemini CLI):** Acts as the "Orchestrator" coordinating the entire workflow.
- **Tmux Environment:** Installed on your machine (MacOS/Linux) to manage multi-threaded work sessions.
- **Experience:** Have used or possess a basic understanding of the **BMAD** method.

---

## 🧠 Core Philosophy

Squad BMAD is built on immutable principles:

1. **Strict Adherence to BMAD Processes:** All tasks from ideation, writing specifications, to coding and reviewing strictly follow BMAD's workflows. This ensures the project always stays on track and technical documentation is always synchronized with the actual code.
2. **Fresh Chat & Context Isolation:** Before starting a new workflow, the system must clear the context (by sending the `/clear` command). This prevents the AI (Claude) from hallucinating due to carrying too much old information, keeping its reasoning sharp.
3. **Clear Agent Roles:** Applying the true spirit of BMAD, the system divides Agents into specialized "personas" (PM, Architect, Dev, QA) to optimize the performance of each AI Model.

---

## ⚙️ System Architecture & Operation

The system operates based on the smooth coordination of **3 Tmux sessions**:

1. **Session 1: Gemini Orchestrator**
   - The master operating the other 2 tmux sessions.
   - Communicates directly with you, understands requirements, and maps them to BMAD workflows.
   - Monitors, accepts the results, and makes transition decisions.

2. **Session 2: Claude Code - Implement**
   - Acts as a **Developer**.
   - Specialized in writing code, fixing bugs, and running tests.
   - Uses the **Claude 3.5 Sonnet** model to ensure fast speed, excellent coding, and cost savings.

3. **Session 3: Claude Code - Brainstorm**
   - Acts as an **Architect / PM / QA**.
   - Specialized in reasoning about architecture, solving complex problems, designing systems, and reviewing code.
   - Uses the **Claude 3.5 Sonnet** (or **Opus** depending on configuration) model for tasks requiring deep logical thinking.

### 🔄 Event-Driven System with Hooks

Instead of Gemini having to constantly poll the screen to see if Claude Code is done, this project uses an **Event-driven Hooks** mechanism via the `.claude/settings.json` file.

Whenever Claude Code (in tmux 2 or 3) completes a task or needs to stop, the system automatically triggers a bash script (like `.claude/hooks/wakeup-gemini.sh`). This script immediately sends a signal back to Gemini's Tmux Session, "waking up" Gemini to:
1. Read the work results.
2. Evaluate and accept the source code.
3. Report back to you or automatically proceed to the next step according to the BMAD process.

---

## 🚀 Workflow Summary

1. You open 3 Tmux sessions (1 for Gemini, 2 for Claude Code).
2. You chat with Gemini: *"Please implement Story #123 for me."*
3. Gemini receives the command, analyzes it according to the BMAD workflow, and sends the command (along with `/clear` to reset context) to `Claude Code - Implement` via a secure shell script.
4. Gemini goes into an "Idle" state, waiting.
5. `Claude Code - Implement` busily writes code. When done, it automatically triggers the Hook.
6. The Hook runs the bash script, sending an `Enter` keystroke and a notification message to Gemini's screen.
7. Gemini "wakes up", reads Claude Code's screen log, accepts the results, and reports back to you.

---

With **Squad BMAD**, you are no longer a coder painstakingly typing every line of code; you are a true **Project Manager** commanding an elite AI squad!

---

## 🛠 Setup & Usage

### 1. Prepare the Tmux Environment
You need to initialize 3 separate Tmux sessions. You can name them whatever you like, for example:
- Session 1 (Gemini): `gemini-orchestrator`
- Session 2 (Claude Implement): `claude-implement`
- Session 3 (Claude Brainstorm): `claude-brainstorm`

Open 3 terminals and run consecutively:
```bash
tmux new -s gemini-orchestrator
tmux new -s claude-implement
tmux new -s claude-brainstorm
```

### 2. Launch the Agents
- **In Tmux 1 (`gemini-orchestrator`)**: Launch Gemini CLI.
  ```bash
  gemini --yolo
  ```
- **In Tmux 2 (`claude-implement`)**: Launch Claude Code. By default, Claude Code uses the Sonnet model.
  ```bash
  claude --dangerously-skip-permissions
  ```
- **In Tmux 3 (`claude-brainstorm`)**: Launch Claude Code. (You should configure it to use the Opus model if you need complex architectural reasoning).
  ```bash
  claude --dangerously-skip-permissions
  ```

### 3. Configure Session Names for Gemini
So Gemini knows who to send commands to, in the chat window of **Gemini (Tmux 1)**, type the slash command to configure (Make sure to replace the session names with the ones you created):

```text
/withClaudeCodeTmux "claude-implement" "claude-brainstorm"
```

### 4. Start Working
The system is now ready. You simply communicate with Gemini like a project manager:
- *"Start this project for me using the generate-project-context flow."*
- *"Which Epic are we in? Create a new story for the login feature."*
- *"Implement Story #5 according to the dev-story process."*

Gemini will automatically analyze, clear the context (send `/clear`), route the command to the appropriate Claude session, and will automatically "wake up" to accept the work when it receives the Hook feedback signal from Claude.