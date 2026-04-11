# Pilot.nvim

Pure Lua Neovim AI code completion plugin with real-time suggestions.

## Features

- Real-time inline code completion as you type
- Multiple AI provider support (OpenAI, MiniMax)
- Extensible adapter system
- Debounced requests to reduce API calls
- Completion caching for instant responses
- Floating text preview with syntax highlighting

## Requirements

- Neovim 0.8+
- curl command-line tool
- Valid API key for your chosen provider

## Installation

### Lazy.nvim

```lua
return {
  {
    'zetatez/pilot.nvim',
    ft = { 'python', 'javascript', 'typescript', 'lua', 'go', 'rust', 'cpp', 'c', 'java' },
    config = function()
      require('pilot').setup({})
      vim.g.pilot_provider = 'minimax'
      vim.g.pilot_model = 'MiniMax-M2.7'
      vim.g.pilot_api_key_env = 'MINIMAX_API_KEY'
    end,
  },
}
```

## Configuration

 | Variable                  | Default          | Description                        |
 | ----------                | ---------        | -------------                      |
 | `vim.g.pilot_provider`    | `openai`         | AI provider: `openai` or `minimax` |
 | `vim.g.pilot_model`       | `gpt-4o`         | Model name                         |
 | `vim.g.pilot_api_key_env` | `OPENAI_API_KEY` | Environment variable for API key   |
 | `vim.g.pilot_endpoint`    | provider default | Custom API endpoint (optional)     |
 | `vim.g.pilot_enabled`     | `1`              | Enable/disable plugin (1/0)        |

## Providers

### OpenAI

```lua
vim.g.pilot_provider = 'openai'
vim.g.pilot_model = 'gpt-4o'
vim.g.pilot_api_key_env = 'OPENAI_API_KEY'
```

### MiniMax

```lua
vim.g.pilot_provider = 'minimax'
vim.g.pilot_model = 'MiniMax-M2.7'
vim.g.pilot_api_key_env = 'MINIMAX_API_KEY'
```

## Environment Variables

```bash
# ~/.zshrc or ~/.bashrc
export OPENAI_API_KEY=sk-...
# or
export MINIMAX_API_KEY=...
```

## Commands

- `:Pilot enable` - Enable completions
- `:Pilot disable` - Disable completions and clear suggestions

## Keybindings

| Key | Action |
|-----|--------|
| `<C-l>` | Accept suggestion |
| `<C-h>` | Dismiss suggestion |

To customize keybindings, override them after `require('pilot').setup({})`:

```lua
require('pilot').setup({})

vim.keymap.set('i', '<C-]>', function()
  if require('pilot').accept() then return false end
  return ''
end, { expr = true })

vim.keymap.set('i', '<C-[>', function()
  require('pilot').clear()
  return ''
end, { expr = true })
```

## Architecture

```
pilot.nvim
├── lua/pilot/
│   ├── init.lua           # Core completion logic
│   ├── adapter.lua        # Base adapter class
│   └── adapters/
│       ├── init.lua       # Adapter factory
│       ├── openai.lua     # OpenAI adapter
│       └── minimax.lua    # MiniMax adapter
└── plugin/pilot.lua       # Plugin entry point
```

## License

MIT
