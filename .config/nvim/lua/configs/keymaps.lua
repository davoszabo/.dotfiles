-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete single character without copying into register
keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>rr", ":%s/<C-r><C-w>/<C-r><C-w>/gc<Left><Left><Left>", { desc = "Replace all occurrences of word under cursor in file" })
--
-- Helper: get the visual selection as a string
local function get_visual_selection()
  vim.cmd('normal! "vy')   -- yank to register 'v'
  local text = vim.fn.getreg('v')
  vim.fn.setreg('v', '')   -- clean register
  return text:gsub('\n$', '')  -- remove trailing newline if any
end

-- Helper: escape special characters for \V (very nomagic) – only \ and /
local function escape_for_regex(text)
  return vim.fn.escape(text, '\\/')
end

-- Replace visual selection in current file
vim.keymap.set("v", "<leader>rr", function()
  local old = get_visual_selection()
  if old == '' then return end
  local new = vim.fn.input("Replace with: ")
  if new == '' then return end  -- if user cancels, skip
  local old_esc = escape_for_regex(old)
  local new_esc = escape_for_regex(new)
  local cmd = string.format("%%s/\\V%s/%s/gc | update", old_esc, new_esc)
  vim.cmd(cmd)
end, { desc = "Replace visual selection in current file (confirm & save)" })

-- Replace visual selection in ALL files in quickfix list
vim.keymap.set("v", "<leader>ra", function()
  local old = get_visual_selection()
  if old == '' then return end
  local new = vim.fn.input("Replace with: ")
  if new == '' then return end
  local old_esc = escape_for_regex(old)
  local new_esc = escape_for_regex(new)
  local cmd = string.format("cfdo %%s/\\V%s/%s/gc | update", old_esc, new_esc)
  vim.cmd(cmd)
end, { desc = "Replace visual selection across ALL files (quickfix, confirm & save)" })
-- :Telescope live_grep, then Ctrl-q to put it in quickfix
-- keymap.set("n", "<leader>ra", ":cdo %s/<C-r><C-w>/<C-r><C-w>/gc<Left><Left><Left>", { desc = "Replace all occurrences of word under cursor in ALL files" })

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab
