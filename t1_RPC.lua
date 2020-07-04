

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
