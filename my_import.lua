local push = table.insert
local tjoin = table.concat

------------------------------------------------------------
-- utils
------------------------------------------------------------

-- data | scripts main.lua
-- .. mylib/
-- step = 1
function concat_path(...)
  local arr = {...}
  return tjoin(arr, "/")
end

function str_split(str, sep)
  sep = sep or "%s"
  local pattern = ("([^%s]+)"):format(sep)
  -- print(pattern)
  local arr = {}
  for s in string.gmatch(str, pattern) do
    table.insert(arr, s)
  end
  return arr
end

------------------------------------------------------------
-- base
------------------------------------------------------------

local _print = function (...)
  local arr = {}
  for i,v in ipairs({...}) do
    push(arr, tostring(v))
  end
  return tjoin(arr, "  ")
end

local _err = function (...)
  local arr = {}
  for i,v in ipairs({...}) do
    -- todo nil str
    push(arr, tostring(v))
  end
  error(tjoin(arr, "  ")) 
end

local _f = function (f)
  return function (...)
    local args = {...}
    local ret = {}
    xpcall(function ()
      ret = { f(unpack(args)) }
    end, print)
    return unpack(ret)
  end
end

------------------------------------------------------------
-- api
------------------------------------------------------------

function CreateEnvWithModAPI(isworldgen)
  isworldgen = isworldgen or false

  local env = {
    -- lua
    pairs    = pairs,
    ipairs   = ipairs,
    print    = print,
    math     = math,
    table    = table,
    type     = type,
    string   = string,
    tostring = tostring,
    Class    = Class,
    -- runtime
    TUNING=TUNING,
    -- worldgen
    GROUND = GROUND,
    LOCKS = LOCKS,
    KEYS = KEYS,
    LEVELTYPE = LEVELTYPE,
    -- utility
    GLOBAL = _G,
    modname = "",
  }

  if isworldgen == false then
    env.CHARACTERLIST = GetActiveCharacterList()
  end

  env.env = env
  env.modimport = function(modulename) end

  local modutil = require("modutil")
  modutil.InsertPostInitFunctions(env, isworldgen, "myimport")

  return env
end

local function env_set_alias(env)
  env.push  = table.insert;
  env.pop   = table.remove;
  env.tjoin = table.concat;
end

------------------------------------------------------------
-- func
------------------------------------------------------------

function _resolveLookupPaths(filename)
  local pattern = "?.lua;?/index.lua;?/init.lua"
  local paths = str_split(string.gsub(pattern, "?", filename), ";")
  return paths
end

-- todo for itor
function _nodeModulePaths()
  -- from = from or "."
  local dirname = "node_modules"
  local paths = {
    concat_path(".", dirname);
    concat_path("..", dirname);
    concat_path("..", "..", dirname);
    concat_path("..", "..", "..", dirname);
    concat_path("..", "..", "..", "..", dirname);
  }
  -- local exist = fn_exists(path)
  return paths
end

function _resolveFilename(fillname, fn_exists)
  local dir_paths = _nodeModulePaths()
  local file_paths = _resolveLookupPaths(fillname)

  for i, dir in ipairs(dir_paths) do
    for j, filepath in ipairs(file_paths) do
      local path = concat_path(dir, filepath);
      local exist = fn_exists(path)
      if (exist) then
        return path
      end
    end
  end
  return nil;
end

------------------------------------------------------------
-- main
------------------------------------------------------------


local modenv = CreateEnvWithModAPI(false)
local mt = {
  __index = function (t, key)
    return rawget(t, key)
     or rawget(modenv, key)
     or rawget(_G, key);
  end
}

local _import = function (modname, ...)
  if not (modname and #modname > 0) then
    _err("[error] import modname is ", modname)
  end

  local arr_lookup = {}
  local path = _resolveFilename(modname, 
    function (path)
      -- print(path)
      push(arr_lookup, path)
      return (kleifileexists(path) and true or false)
    end)
  if not (path) then
    tprint(arr_lookup)
    _err("[error] import not find src")
    return 
  end

  local fn = kleiloadlua(path)
  if not (fn and type(fn) == "function") then
    _err("import path", path, fn) 
  end

  local args = {...}
  args.n = #args
  args[0] = modname;

  local env = package._cache[modname]
  if (not env) then
    env = setmetatable({}, mt) 
  end

  env._err = _err;
  env._f = _f;
  env._path = path;
  env._M = env;
  env.arg = args;
  env_set_alias(env)

  setfenv(fn, env)
  local ret = {fn()}
  package._cache[modname] = env

  print("import", path)
  return unpack(ret)
end

function modget(modname)
  local env = package._cache[modname]
  if not (env) then
    import(modname)
  end
  return env
end

function modset(modname, env)
  package._cache[modname] = env 
end

import = _f(_import);

-- modset("t4", nil)
-- print(111, import("t4").gg)


print(">>>>>>>>>>>>........my_import........ok")
