-- minivi by vazw.
-- load personal config such as keymaps, autocmds, options and so on
require("config")

-- load MiniDeps
require("plugins.loader")

-- STAGE 1: Load treesister, lspconfig and blink.cmp
-- STAGE 2: Load Basic plugin such as mason, comform(formatter) and statusline
-- STAGE 3: Load appearance such as Colorizer, Icons/Themes and Git things
--
-- *OR* You can just create plugins/init.lua with the same contents
-- ```lua
-- require("plugins.stage_1")
-- require("plugins.stage_2")
-- require("plugins.stage_3")
-- ```
require("plugins.stage_1")
-- Load it later
MiniDeps.later(function()
  require("plugins.stage_2")
  require("plugins.stage_3")
end)
--- Startup times for process: Embedded ---
-- times in msec
--
-- 000.000  000.000: --- NVIM STARTING ---
-- .....
-- 005.325  001.025  000.032: require('config')
-- .....
-- .....
-- 031.707  010.789  007.101: require('plugins.stage_1')
-- 032.008  000.298  000.298: require('plugins.stage_2')
-- 033.117  001.106  001.106: require('plugins.stage_3')
-- 033.121  028.837  000.035: sourcing /home/vaz/.config/nvim/init.lua
-- 033.131  000.411: sourcing vimrc file(s)
-- .....
-- .....
-- 050.759  000.086: before starting main loop
-- 051.704  000.945: first screen update
-- 051.707  000.003: --- NVIM STARTED ---
