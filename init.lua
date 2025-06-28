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
require("plugins.stage_2")
-- Ensure latest
require("plugins.stage_3")

--- Startup times for process: Embedded ---
-- times in msec
--
-- 000.001  000.001: --- NVIM STARTING ---
-- 000.144  000.144: event init
-- .....
-- .....
-- 022.423  016.826  000.378: require('plugins.loader')
-- .....
-- .....
-- 034.140  011.715  007.955: require('plugins.stage_1')
-- .....
-- .....
-- 040.565  006.421  001.088: require('plugins.stage_2')
-- 040.820  000.255  000.255: require('plugins.stage_3')
-- 040.822  036.415  000.038: sourcing /home/vaz/.config/nvim/init.lua
-- 040.828  000.465: sourcing vimrc file(s)
-- .....
-- .....
-- .....
-- 056.981  000.077: before starting main loop
-- 057.425  000.444: first screen update
-- 057.427  000.002: --- NVIM STARTED ---
