package._cache = package._cache or {}

function my_init(namespace)
	local mod = package._cache[namespace]
	if not (mod) then
		local org = getfenv(2)
		local mt = {
			__index = function (t, key)
				return rawget(t, key)
				 or rawget(org, key)
				 or rawget(_G, key);
			end
		}
		mod = setmetatable({}, mt)

		local errfunc = function (...)
			print("[error]", namespace,  GetTime(), ...)
		end

		local safe = function (f)
			return function (...)
				local args = {...}
				local ret = {}
				xpcall(function ()
					ret = { f(unpack(args)) }
				end, errfunc)
				return unpack(ret)
			end
		end

		local import = function (filename)
			-- todo rollback loaded when failed
			package.loaded[filename] = nil
			local ret = {}
			xpcall(function ()
			  ret = { require(filename) }
			end, errfunc)
			return unpack(ret)
		end

		mod._f = safe
		mod._err = errfunc
		mod._M = mod
		mod.import = import

		package._cache[namespace] = mod
	end

  setfenv(2, mod)
  return mod
end

function my_get(namespace)
  return package._cache[namespace]
end

package.my_init = my_init;

return my_init;