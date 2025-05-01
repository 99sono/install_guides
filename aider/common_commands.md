# Common Commands for Aider

This document provides a quick reference to essential and advanced Aider commands, offering detailed explanations of their usage.

---

## **Basic Commands**

### **Start Aider**
Launch Aider using the preconfigured settings in `.aider.conf.yml`:
```bash
aider
```

This command initializes Aider and applies all settings defined in your configuration file.

---

### **Help**
View the general help menu or ask specific questions about commands:
```bash
/help
/help <question>
```
Example:
```bash
/help add
```
Provides details about the `/add` command.

---

## **File Management Commands**

### **Add Files**
Include files in the chat session for editing or review:
```bash
/add <filename>
```
Example:
```bash
/add main.py
```

### **Remove Files**
Remove files from the chat session to free up context space:
```bash
/drop <filename>
```

### **List Files**
View all known files and indicate which are currently part of the chat session:
```bash
/ls
```

### **Read-Only Files**
Add files as references (read-only) or convert existing files to read-only mode:
```bash
/read-only <filename>
```

---

## **Repository Exploration Commands**

### **Repository Map**
Display the current repository structure to explore relationships between files:
```bash
/map
```

### **Refresh Repository Map**
Force an update to the repository map:
```bash
/map-refresh
```

---

## **Code Editing Commands**

### **Enter Code Mode**
Switch to a mode that focuses on editing code:
```bash
/code
```

### **Lint Files**
Perform linting and automatic fixes on files within the chat session:
```bash
/lint
```
If no files are actively in the chat, all dirty files are linted.

---

## **Git Commands**

### **Commit Changes**
Commit edits made outside the chat directly to the repository:
```bash
/commit <message>
```
Example:
```bash
/commit "Fixed issue in user authentication"
```

### **Undo Commit**
Undo the last Git commit if it was done by Aider:
```bash
/undo
```

### **Run Git Command**
Execute custom Git commands:
```bash
/git <command>
```
Example:
```bash
/git status
```

---

## **Model Management Commands**

### **Switch Main Model**
Change the primary model used by Aider:
```bash
/model <model-name>
```

### **Switch Editor Model**
Set the model used for architect/editor mode:
```bash
/editor-model <model-name>
```

### **Search Models**
List all available models for use in Aider:
```bash
/models
```

### **Weak Model**
Switch to a lightweight model for tasks such as commit message generation:
```bash
/weak-model <model-name>
```

---

## **Session and Context Management Commands**

### **Clear History**
Remove all chat history in the current session:
```bash
/clear
```

### **Save Session**
Save commands to a file that can reconstruct the chat session's files:
```bash
/save <filename>
```

### **Load Session**
Load and execute commands from a previously saved file:
```bash
/load <filename>
```

---

## **Advanced Commands**

### **Run Shell Command**
Execute shell commands directly and optionally add output to the chat:
```bash
/run <command>
```
Alias:
```bash
! <command>
```

### **Paste Clipboard Content**
Paste text or images from the clipboard into the chat:
```bash
/paste [name]
```

### **Web Scraping**
Scrape a webpage and convert its content to Markdown:
```bash
/web <url>
```

---

## **Resources**

For a complete list of commands, visit the [Aider Documentation](https://aider.chat/docs/usage/commands.html).

---

## Acknowledgment

Special thanks to **Microsoft Edge Copilot** for its invaluable assistance in structuring this guide and improving the clarity of documentation. The support provided by this tool has greatly enhanced the usability and quality of this guide.
