return {
  'hrsh7th/nvim-cmp',           -- Autocompletion plugin
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',     -- LSP source for nvim-cmp
    'saadparwaiz1/cmp_luasnip', -- Snippets source for nvim-cmp	}
    'L3MON4D3/LuaSnip',         -- Snippets plugin
  },

  config = function()
    -- Add additional capabilities supported by nvim-cmp
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local lspconfig = require('lspconfig')
    local servers = {
      { name = 'clangd', settings = {} },
      { name = 'zls',    settings = {} },
      {
        name = 'rust_analyzer',
        settings = {
          ["rust-analyzer"] = {
            imports = {
              granularity = {
                group = "module",
              },
              prefix = "self",
            },
            cargo = {
              buildScripts = {
                enable = true,
              },
            },
            procMacro = {
              enable = true
            },
          },
        },
      },
      { name = 'ts_ls', settings = {} },
      { name = 'gopls', settings = {} },
      { name = 'zls',   settings = {} },
      {
        name = 'bashls',
        settings = {
          bash = {
            command = "bash-language-server",
            args = { "start" },
            filetypes = { "sh" },
            ignoredRootPaths = { "~" }
          }
        }
      },
      {
        name = 'lua_ls',
        settings = {
          Lua = {
            runtime = {
              version = "lua5.4"
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME
              }
            }
          }
        }
      },
      {
        name = 'texlab',
        settings = {
          texlab = {
            build = {
              args = { "-pdf", "-pv", "-interaction=nonstopmode", "-synctex=1", "-jobname=main",
                "-output-directory=cache", "-aux-directory=cache", "-use-make",
                "%f" },
              executable = "latexmk", -- default value
              pdfDirectory = "cache",
              forwardSearchAfter = true,
              onSave = true
            },
            chktex = {
              onEdit = false,
              onOpenAndSave = true,
            },
            forwardSearch = {
              executable = "zathura",
              args = {
                '--synctex-editor-command',
                [[nvim-texlabconfig -file '%%%{input}' -line %%%{line} -server ]] .. vim.v.servername,
                '--synctex-forward',
                '%l:1:%f',
                '%p',
              }
            },
          },
        },
      }
    }

    for _, lsp in ipairs(servers) do
      local opts = {
        settings = lsp.settings,
        capabilities = capabilities,
      }

      if lsp.name == 'rust_analyzer' then
        opts.single_file_support = true
        opts.root_dir = function(fname)
          local cargo_root = require('lspconfig.util').root_pattern('Cargo.toml')(fname)
          return cargo_root or vim.fn.fnamemodify(fname, ':h')
        end
        opts.on_init = function(client)
          local root = client.config.root_dir
          local has_cargo = vim.fn.filereadable(root .. '/Cargo.toml') == 1
          if not has_cargo then
            local bufname = vim.api.nvim_buf_get_name(0)
            client.config.settings["rust-analyzer"].detachedFiles = { bufname }
            client.notify("workspace/didChangeConfiguration", {
              settings = client.config.settings
            })
          end
        end
      end

      lspconfig[lsp.name].setup(opts)
    end
    -- luasnip setup
    local luasnip = require 'luasnip'

    -- nvim-cmp setup
    local cmp = require 'cmp'
    cmp.setup {
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
      }),
      sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
      },
    }
  end
}
