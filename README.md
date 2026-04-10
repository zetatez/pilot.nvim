# Pilot.nvim

Pure Lua Neovim code completion.

## Setup with Lazy.nvim

```lua
-- ~/.config/nvim/lua/plugins/pilot.lua
return {
  {
    'zetatez/pilot.nvim',
    ft = { 'python', 'javascript', 'typescript', 'lua', 'go', 'rust', 'cpp', 'c', 'java' },
    config = function()
      require('pilot').setup({ })
      vim.g.pilot_provider = 'minimax'
      vim.g.pilot_model = 'MiniMax-M2.7'
      vim.g.pilot_api_key_env = 'MINIMAX_API_KEY'
    end,
  }
}
```

## Environment Variables (~/.zshrc)

```bash
export OPENAI_API_KEY=sk-...
# or
export MINIMAX_API_KEY=...
```

## Lua Config

```lua
-- init.lua or config function
vim.g.pilot_provider = 'openai'
vim.g.pilot_model = 'gpt-5.4'
vim.g.pilot_api_key_env = 'OPENAI_API_KEY'
```

## Providers

### OpenAI (default)
```lua
vim.g.pilot_provider = 'openai'
vim.g.pilot_model = 'gpt-5.4'
vim.g.pilot_api_key_env = 'OPENAI_API_KEY'
```

### MiniMax
```lua
vim.g.pilot_provider = 'minimax'
vim.g.pilot_model = 'MiniMax-M2.7'
vim.g.pilot_api_key_env = 'MINIMAX_API_KEY'
```

## Keys

- `<Tab>` accept
- `<C-]>` dismiss
