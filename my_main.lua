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


function t_ls(t)
	print("---------<<<<<<<<", t)
	for k,v in pairs(t) do
		print(k,v)
	end
	print(">>>>>>>>----------", t)
end

function t_pick()
	t_inst = TheInput:GetWorldEntityUnderMouse();
	print(t_inst);
end



------------------------------------------------------------
-- func
------------------------------------------------------------

this._Networking_SystemMessage = Networking_SystemMessage
function Networking_SystemMessage(msg)
	-- local prefix = "##RPC_PRIVATE##"
	-- if not (starts_with(str, prefix)) then
	-- 	return 
	-- end
	-- local code = after_prefix(msg, "-")

	-- if  then
	-- 	if TheNet:GetIsClient() then
	-- 	    local RPC = loadstring("HandleClientRPC("..string.sub(message, 4)..")")
	-- 	    setfenv(RPC, {HandleClientRPC = HandleClientRPC})
	-- 	    RPC()
	-- 	end
	-- else
	--     _Networking_SystemMessage(message)
	-- end
	this._Networking_SystemMessage(msg)
end


------------------------------------------------------------
-- test
------------------------------------------------------------

local namespace = "AAABBBCCC"
local name = "fish"


AddModRPCHandler("AAABBBCCC", "fish", function(...)
	print(">>>>>>>>>>>AAABBBCCC", "fish", ...)
end)

-- TheNet:SendModRPCToServer("AAABBBCCC", 1, 1, 2, 3)


print("init my_main ok..222..", MOD_RPC[namespace][name])



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