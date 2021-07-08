-- Quick lists
vim.api.nvim_set_keymap('n', '<C-j>', "<cmd>cnext<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<C-k>', "<cmd>cprev<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<C-l><C-l>', "<cmd>cclose<cr>", { noremap = true })

-- Local lists
vim.api.nvim_set_keymap('n', '<M-j>', "<cmd>lnext<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<M-k>', "<cmd>lprev<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<M-l><M-l>', "<cmd>lclose<cr>", { noremap = true })

-- Telescope
vim.api.nvim_set_keymap('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fr', "<cmd>lua require('telescope.builtin').git_branches()<cr>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fs', "<cmd>lua require('telescope.builtin').git_status()<cr>", { noremap = true })

vim.api.nvim_set_keymap('n', '<leader>fs', "<cmd>lua dotnet_picker()<cr>", { noremap = true })

-- Other
vim.api.nvim_set_keymap('n', '<leader>ss', "<cmd>nohlsearch<cr>", { noremap = true })
--vim.api.nvim_set_keymap('n', '<leader>sl', "<cmd><cr>", { noremap = true })