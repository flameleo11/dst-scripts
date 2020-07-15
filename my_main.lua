-- todo similar modinit set mod env

require("tprint")

local my_init = require("my_init")
local mod = my_init("my_main")
mod.import("my_import")
_G.import("common")

