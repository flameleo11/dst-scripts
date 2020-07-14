-- todo similar modinit set mod env

require("tprint")

local my_init = require("my_init")
my_init("my_main")

print(my_get("my_main").this)


------------------------------------------------------------
-- base
------------------------------------------------------------

this = this or {}


------------------------------------------------------------
-- utils
------------------------------------------------------------

function starts_with(str, prefix)
   return string.sub(str,1,string.len(prefix))==prefix
end

function t_pick()
	t_inst = TheInput:GetWorldEntityUnderMouse();
	print(t_inst);
end



------------------------------------------------------------
-- func
------------------------------------------------------------

------------------------------------------------------------
-- test
------------------------------------------------------------


--[[
t_ls(MOD_RPC["my_main3"])
t_ls(MOD_RPC_HANDLERS["my_main2"])

my_get("my_main").import("my_main")
my_get("my_main").this.test()
 test
TheNet:SendModRPCToServer("cmc_maxstats",1)
TheNet:SendModRPCToServer("cmc_maxstats",1)

TheNet:SendModRPCToServer("my_main2", "test")
TheNet:SendModRPCToServer("my_main2", 1)
]]