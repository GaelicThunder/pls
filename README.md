# pls

#### ✨ Natural language to shell commands using Ollama ✨

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## What is this?

`pls` is a lightweight CLI tool that converts natural language into shell commands using local Large Language Models via [Ollama](https://ollama.ai). Heavily inspired by [uwu](https://github.com/context-labs/uwu) (which now support custom providers, which make this 2 repo too similar but oh well). Unlike cloud-based alternatives, `pls` runs entirely on your machine, ensuring privacy and offline functionality.

```bash
pls find all log files larger than 10MB
# ↓ generates and suggests:
find . -name "*.log" -size +10M
```

After a response is generated, you can edit it before pressing enter to execute the command. The command is automatically added to your shell history for easy retrieval.

## Key Features

- 🔒 **Privacy-first**: Uses local Ollama models, no data sent to external services
- 🐚 **Multi-shell support**: Works with Fish, Bash, and Zsh
- ⚙️ **Highly configurable**: Custom models, prompts, and settings
- 🎯 **Shell-aware**: Generates commands appropriate for your specific shell
- 📝 **History integration**: Commands are automatically added to shell history
- 🎨 **Live streaming**: Real-time command generation with animated feedback
- 📋 **Safe execution**: Review and edit commands before execution

## Installation

### Prerequisites

1. **Ollama**: Install from [ollama.ai](https://ollama.ai)
2. **A code model**: Download a suitable model (e.g., `ollama pull gemma3:4b`)
3. **jq**: JSON processor (`sudo pacman -S jq` on Arch Linux)

### Quick Install

```bash
git clone https://github.com/GaelicThunder/pls.git
cd pls
chmod +x install.sh
./install.sh
```

### Manual Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/GaelicThunder/pls.git
   cd pls
   ```

2. **Install the engine**:
   ```bash
   sudo cp bin/pls-engine /usr/local/bin/
   sudo chmod +x /usr/local/bin/pls-engine
   ```

3. **Set up shell integration**:

   **For Fish** (add to `~/.config/fish/config.fish`):
   ```bash
   cat shell-integrations/fish.fish >> ~/.config/fish/config.fish
   ```

   **For Bash** (add to `~/.bashrc`):
   ```bash
   cat shell-integrations/bash.sh >> ~/.bashrc
   ```

   **For Zsh** (add to `~/.zshrc`):
   ```bash
   cat shell-integrations/zsh.sh >> ~/.zshrc
   ```

4. **Reload your shell configuration**:
   ```bash
   # Fish
   source ~/.config/fish/config.fish

   # Bash
   source ~/.bashrc

   # Zsh
   source ~/.zshrc
   ```

## Usage

Once installed and configured:

```bash
pls compress all jpg files in this directory into a zip archive
# ↓ Streams and generates:
zip images.zip *.jpg

pls show me disk usage sorted by size
# ↓ Generates:
du -h | sort -hr

pls kill all python processes
# ↓ Generates:
pkill python
```

You'll see the generated command appear in your shell's input line with a streaming animation. Press **Enter** to run it, **edit** it first, or **Ctrl+C** to cancel. All suggested commands are automatically added to your shell history.

## Configuration

The first time you run `pls`, it creates a configuration file at `~/.config/pls/config.json`. 

### Example Configuration

```json
{
  "model": "gemma3:4b",
  "ollama_url": "http://localhost:11434",
  "temperature": 0.1,
  "stream": true,
  "max_tokens": 100,
  "system_prompt": "You are a helpful shell command generator. Generate only the command, no explanations.",
  "shell_specific_prompts": {
    "fish": "Generate Fish shell commands. Use Fish-specific syntax when appropriate.",
    "bash": "Generate Bash shell commands. Use standard POSIX syntax.",
    "zsh": "Generate Zsh shell commands. You can use Zsh-specific features."
  }
}
```

### Advanced Configuration

See [docs/configuration.md](docs/configuration.md) for detailed configuration options.

## Shell-Specific Features

`pls` automatically detects your shell and generates appropriate commands:

- **Fish**: Uses Fish-specific syntax for variables, functions, and conditionals
- **Bash**: Standard POSIX-compliant commands
- **Zsh**: Can leverage Zsh-specific features and expansions

## Supported Models

Any Ollama model that can generate code works well. Recommended models:

- `gemma3:4b` - Faster and best, actually the default model
- `codellama:13b` - Best balance of speed and accuracy
- `codegemma:7b` - Faster, good for basic commands
- `deepseek-coder:6.7b` - Excellent for complex shell scripting
- `llama3.1:8b` - General purpose, works well for commands

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Troubleshooting

### Common Issues

1. **"jq not found"**: Install jq with your package manager
2. **"Connection refused"**: Make sure Ollama is running (`ollama serve`)
3. **"Model not found"**: Pull the model first (`ollama pull gemma3:4b`)
4. **Slow responses**: Try a smaller model like `gemma3:4b`

### Debug Mode

Run with debug output:
```bash
DEBUG=1 pls your command here
```

## Similar Projects

- [uwu](https://github.com/context-labs/uwu) - Uses OpenAI GPT models
- [shell_gpt](https://github.com/TheR1D/shell_gpt) - Another AI shell assistant
- [butterfish](https://butterfi.sh) - CLI tools for LLMs

---

Made with ❤️ for the terminal enthusiasts
