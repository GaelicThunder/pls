# Configuration Guide

The `pls` configuration file is located at `~/.config/pls/config.json`. It's automatically created with default values when you first run `pls`.

## Basic Configuration

### Model Selection

```json
{
  "model": "codellama:13b"
}
```

Recommended models:
- `codellama:13b` - Best balance of accuracy and speed
- `codegemma:7b` - Faster, good for simple commands  
- `deepseek-coder:6.7b` - Excellent for complex shell scripting
- `llama3.1:8b` - General purpose, works well

To see available models: `ollama list`
To install a model: `ollama pull model-name`

### Ollama Connection

```json
{
  "ollama_url": "http://localhost:11434"
}
```

Change this if:
- Ollama runs on a different port
- Using a remote Ollama instance
- Using a custom Ollama setup

### Response Behavior

```json
{
  "temperature": 0.1,
  "stream": true,
  "max_tokens": 100
}
```

**Temperature** (0.0 - 1.0):
- `0.0-0.2`: Very consistent, deterministic commands
- `0.3-0.5`: Balanced creativity and consistency
- `0.6-1.0`: More creative but potentially inconsistent

**Stream**: 
- `true`: Real-time streaming with animation
- `false`: Wait for complete response

**Max Tokens**:
- Shell commands are typically short
- 100 tokens is usually sufficient
- Increase if you need longer, complex commands

## Advanced Configuration

### Custom System Prompts

```json
{
  "system_prompt": "You are a helpful shell command generator..."
}
```

Modify this to change the AI's behavior globally. For example:
- Add safety restrictions
- Request more verbose commands
- Focus on specific tools or patterns

### Shell-Specific Prompts

```json
{
  "shell_specific_prompts": {
    "fish": "Use Fish-specific syntax...",
    "bash": "Use Bash/POSIX syntax...",
    "zsh": "Use Zsh features when helpful..."
  }
}
```

These are appended to the base system prompt. Customize them to:
- Emphasize shell-specific features
- Prefer certain command patterns
- Avoid problematic constructs

## Environment Variables

Some settings can be overridden with environment variables:

```bash
export PLS_MODEL="llama3.1:8b"
export PLS_TEMPERATURE="0.2"
```

## Troubleshooting

### Connection Issues

If you get "Connection refused" errors:

1. Check if Ollama is running: `ps aux | grep ollama`
2. Start Ollama: `ollama serve`
3. Test connection: `curl http://localhost:11434/api/tags`

### Model Issues

If you get "Model not found" errors:

1. List available models: `ollama list`
2. Pull the model: `ollama pull codellama:13b`
3. Update config.json with the correct model name

### Performance Issues

If responses are slow:

1. Try a smaller model (e.g., `codegemma:7b`)
2. Reduce `max_tokens`
3. Check system resources: `htop`

### Command Quality Issues

If generated commands aren't good:

1. Adjust `temperature` (lower = more deterministic)
2. Modify the `system_prompt` to be more specific
3. Try a different model specialized for code
4. Provide more specific natural language prompts

## Example Configurations

### Performance-focused

```json
{
  "model": "codegemma:7b",
  "temperature": 0.0,
  "stream": false,
  "max_tokens": 50
}
```

### Accuracy-focused

```json
{
  "model": "deepseek-coder:6.7b",
  "temperature": 0.1,
  "max_tokens": 200,
  "system_prompt": "You are an expert system administrator. Generate precise, safe shell commands. Always prefer the most reliable and widely supported syntax."
}
```

### Creative/Experimental

```json
{
  "model": "llama3.1:8b",
  "temperature": 0.4,
  "system_prompt": "Generate creative shell command solutions. You may use advanced features and one-liners when they're more elegant."
}
```

## Configuration Validation

To validate your configuration:

```bash
pls-engine "test command" 2>&1 | grep -i error
```

Or enable debug mode:

```bash
pls-engine --debug "test command"
```
