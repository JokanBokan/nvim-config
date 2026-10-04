local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 8
vim.opt.updatetime = 250
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"
if vim.g.neovide then
  vim.o.guifont = "JetBrainsMonoNL NF"
end

require("lazy").setup({
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        compile = false,
        undercurl = true,
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = false,
        dimInactive = false,
        terminalColors = true,
        colors = {
          palette = {},
          theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
        },
        overrides = function(colors)
          return {}
        end,
        theme = "dragon",
        background = {
          dark = "dragon",
          light = "lotus",
        },
      })
      vim.cmd("colorscheme kanagawa")
    end,
  },

  {
    "rcarriga/nvim-notify",
    config = function()
      local notify = require("notify")
      notify.setup({
        background_colour = "#000000",
        stages = "fade_in_slide_out",
        timeout = 3000,
        render = "default",
      })
      vim.notify = notify

      local config_path = vim.fn.stdpath("config") .. "/init.lua"
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = config_path,
        callback = function()
          vim.cmd("source " .. config_path)
          vim.notify("Nvim config successfully reloaded!", "info", { title = "nvim-config" })
        end,
      })

      vim.keymap.set("n", "<leader>rc", function()
        vim.cmd("source " .. config_path)
        vim.notify("Nvim config successfully reloaded!", "info", { title = "nvim-config" })
      end, { desc = "Reload nvim config" })
    end,
  },

{
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Zaštita od SessionWritePre greške na Windows/Neovim verzijama
      local orig_autocmd = vim.api.nvim_create_autocmd
      vim.api.nvim_create_autocmd = function(event, opts)
        local safe_event = event
        if type(event) == "table" then
          safe_event = {}
          for _, e in ipairs(event) do
            if e ~= "SessionWritePre" then
              table.insert(safe_event, e)
            end
          end
        elseif event == "SessionWritePre" then
          return
        end
        return orig_autocmd(safe_event, opts)
      end

      require("nvim-tree").setup({
        view = { width = 32 },
        renderer = {
          group_empty = true,
          icons = { show = { git = true, folder = true, file = true, folder_arrow = true } },
        },
        filters = { dotfiles = false },
        git = { enable = true },
      })

      vim.api.nvim_create_autocmd = orig_autocmd

      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file tree" })
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.fn.argc() == 0 then
            require("nvim-tree.api").tree.open()
          end
        end,
      })
    end,
  },

  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          numbers = "ordinal",
          diagnostics = "nvim_lsp",
          offsets = {
            { filetype = "NvimTree", text = "NvimTree", highlight = "Directory", separator = true },
          },
          show_buffer_close_icons = true,
          show_close_icon = false,
          separator_style = "slant",
        },
      })
      vim.keymap.set("n", "<S-l>", ":BufferLineCycleNext<CR>")
      vim.keymap.set("n", "<S-h>", ":BufferLineCyclePrev<CR>")
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "kanagawa", globalstatus = true },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = { "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  {
    "karb94/neoscroll.nvim",
    config = function()
      require("neoscroll").setup()
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    branch = "master",
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if ok then
        configs.setup({
          ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "rust", "markdown", "markdown_inline", "ron", "toml" },
          auto_install = true,
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },
          indent = { enable = true },
        })
      else
        require("nvim-treesitter").setup({
          ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "rust", "markdown", "markdown_inline", "ron", "toml" },
        })
      end
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup()
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          preview = {
            treesitter = false,
          },
        },
      })
      vim.keymap.set("n", "<C-p>", ":Telescope find_files<CR>")
      vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>")
      vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>")
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        direction = "vertical",
        size = 95,
      })
      vim.keymap.set("n", "<C-t>", ":ToggleTerm<CR>")
    end,
  },

  {
    "vyfor/cord.nvim",
    build = ":Cord update",
    config = function()
      require("cord").setup({
        usercmds = true,
        display = {
          show_time = true,
          show_repository = true,
        },
      })
    end,
  },

  { "neovim/nvim-lspconfig" },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

      vim.keymap.set({ "i", "s" }, "<C-k>", function() luasnip.jump(1) end, { silent = true })
      vim.keymap.set({ "i", "s" }, "<C-j>", function() luasnip.jump(-1) end, { silent = true })
    end,
  },
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local on_attach = function(_, bufnr)
  local opts = { buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)
end

vim.lsp.config("clangd", {
  capabilities = capabilities,
  on_attach = on_attach,
  cmd = {
    "clangd",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--clang-tidy",
  },
})
vim.lsp.enable("clangd")

vim.lsp.config("rust_analyzer", {
  capabilities = capabilities,
  on_attach = on_attach,
  cmd = { "rust-analyzer" },
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = true,
      check = {
        command = "clippy",
      },
      diagnostics = { enable = true },
      cargo = { allFeatures = true },
      procMacro = { enable = true },
    },
  },
})
vim.lsp.enable("rust_analyzer")

vim.lsp.config("lua_ls", {
  capabilities = capabilities,
  on_attach = on_attach,
  cmd = { "lua-language-server" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = {
        enable = true,
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})
vim.lsp.enable("lua_ls")

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "rust", "lua" },
  callback = function()
    pcall(vim.treesitter.start)
  end,
})