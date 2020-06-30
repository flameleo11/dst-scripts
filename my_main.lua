-- todo similar modinit set mod env

require("tprint")

local my_init = require("my_init")
my_init("my_main")

print(my_get("my_main").this)

this = this or {}

-- function import(filename)
-- 	package.loaded[filename] = nil
-- 	require(filename)
-- end

-- local _f = function (f)
-- 	return function (...)
-- 		local args = {...}
-- 		local ret = {}
-- 		xpcall(function ()
-- 			ret = { f(unpack(args)) }
-- 		end, errfunc)
-- 		return unpack(ret)
-- 	end
-- end

function test1()
	print(111, ".............")
end


function test2()
	print(222, AddUserCommand, AddModRPCHandler)
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


-- function AddModRPCHandler(namespace, name, fn)
--     if MOD_RPC[namespace] == nil then
--         MOD_RPC[namespace] = {}
--         MOD_RPC_HANDLERS[namespace] = {}

--         setmetadata(MOD_RPC[namespace])
--         setmetadata(MOD_RPC_HANDLERS[namespace])
--     end

--     table.insert(MOD_RPC_HANDLERS[namespace], fn)
--     MOD_RPC[namespace][name] = { namespace = namespace, id = #MOD_RPC_HANDLERS[namespace] }

--     setmetadata(MOD_RPC[namespace][name])
-- end

this.hide = _f(function ()
	print(1111)
end)

this.regenerate = _f(function ()
	print(222)
end)


this.test = _f(function ()
	print(123)
	-- UserToPlayer("KU__9qL15UL").components.talker:Say("123");
end)

local namespace = "my_main3"
local namespace2 = "my_test2"

this.inited = false
if not (this.inited) then
	this.inited = true
	AddModRPCHandler(namespace, "my_main3", function ()
		-- this.hide()
		this.test()
	end)
	AddModRPCHandler(namespace, "regenerate", function ()
		this.regenerate()
	end)
	AddModRPCHandler(namespace, "my_main3", function ()
		this.test()
	end)
	AddModRPCHandler(namespace2, "my_test", function ()
		this.test()
	end)
	print("AddModRPCHandler...........")
end



print("init my_main ok....", this, _f, import)


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