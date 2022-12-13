set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
if has('unix')
    source ~/.vimrc
else " windows
    source ~/_vimrc
endif
" enable rust-analyzer lsp and auto-completion via nvim-completion
lua << EOF
--    -- Setup lspconfig.
--    -- local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
--
--    require'lspconfig'.rust_analyzer.setup({
--        --- capabilities = capabilities
--    }) -- connect to RLS server
EOF

" enable lspsaga for diagnostics, definition-search, reference-search, etc UI
lua << EOF
--    require'lspsaga'.init_lsp_saga{
--        border_style = "round",
--    }
EOF
nnoremap <silent> <C-j> <Cmd>Lspsaga diagnostic_jump_next<CR>
nnoremap <silent>K <Cmd>Lspsaga hover_doc<CR>
inoremap <silent> <C-k> <Cmd>Lspsaga signature_help<CR>
nnoremap <silent> gh <Cmd>Lspsaga lsp_finder<CR>

" enable tree-sitter
lua << EOF
--    require'nvim-treesitter.configs'.setup {
--        highlight = {
--            enable = true,
--            disable = {}
--        },
--        indent = {
--            enable = false,
--            disable = {},
--        },
--        ensure_installed = {
--            "rust",
--        }
--    }
EOF
nnoremap <silent> <C-j> <Cmd>Lspsaga diagnostic_jump_next<CR>
nnoremap <silent>K <Cmd>Lspsaga hover_doc<CR>
inoremap <silent> <C-k> <Cmd>Lspsaga signature_help<CR>
nnoremap <silent> gh <Cmd>Lspsaga lsp_finder<CR>

" enable completion with nvim-cmp
lua <<EOF
--     -- Setup nvim-cmp.
--     local cmp = require'cmp'
-- 
--     cmp.setup({
-- 
--         snippet = {
--             -- REQUIRED - you must specify a snippet engine
--             expand = function(args)
--                 vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
--             end,
--         },
-- 
--         window = {
--             -- completion = cmp.config.window.bordered(),
--             -- documentation = cmp.config.window.bordered(),
--         },
-- 
--         mapping = cmp.mapping.preset.insert({
--             -- ['<C-b>'] = cmp.mapping.scroll_docs(-4),
--             -- ['<C-f>'] = cmp.mapping.scroll_docs(4),
--             ['<C-Space>'] = cmp.mapping.complete(),
--             -- ['<C-e>'] = cmp.mapping.abort(),
--             ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
--         }),
--         sources = cmp.config.sources(
--         {
--             { name = 'nvim_lsp' },
--             { name = 'vsnip' },
--         }, 
--         {
--             { name = 'buffer' },
--         })
--     })
-- 
--   -- Set configuration for specific filetype.
--   -- cmp.setup.filetype('gitcommit', {
--   --   sources = cmp.config.sources({
--   --     { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
--   --   }, {
--   --     { name = 'buffer' },
--   --   })
--   -- })
-- 
--   -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
--   -- cmp.setup.cmdline('/', {
--   --   mapping = cmp.mapping.preset.cmdline(),
--   --   sources = {
--   --     { name = 'buffer' }
--   --   }
--   -- })
-- 
--   -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
--   -- cmp.setup.cmdline(':', {
--   --   mapping = cmp.mapping.preset.cmdline(),
--   --   sources = cmp.config.sources({
--   --     { name = 'path' }
--   --   }, {
--   --     { name = 'cmdline' }
--   --   })
--   -- })
EOF

