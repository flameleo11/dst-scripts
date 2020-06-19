#!/usr/bin/lua5.1

local push = table.insert
local tjoin = table.concat
local newline = "\n"
local delim = " "
------------------------------------------------------------
-- english for default ?
------------------------------------------------------------


-- see if the file exis`ts
function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- get all lns from a file, returns an empty
-- list/table if the file does not exist
function lines_from(file)
  if not file_exists(file) then return {} end
  local arr = {}
  for ln in io.lines(file) do
    arr[#arr+1] = ln
  end
  return arr
end


function starts_with(str, prefix)
   return string.sub(str,1,string.len(prefix))==prefix
end

function after_prefix(str, prefix)
   return string.sub(str,string.len(prefix)+1,-1)
end


function parse_kv(ln)
  return ln:match([[([%w._]+) "(.-)"]])
end


function parse_rem(ln)
  return ln:match([[#%.%s+([%w._]+)]])
end


------------------------------------------------------------
-- read lang1.po and lang2.po , combine it
------------------------------------------------------------

function quote(str)
	return ([["%s"]]):format(str)
end

function format_kv(k, v)
	return ([[%s %s]]):format(k, quote(v))
end

function WritePOFile(path, header, arr_item)
	f = io.open(path, "w")
	f:write(header, newline)
	f:write(newline)
	for i, item in ipairs(arr_item) do
		-- if (i>10) then
		-- 	break
		-- end
		f:write("#. ", item["name"], newline)
		f:write(format_kv("msgctxt", item["msgctxt"]), newline)
		f:write(format_kv("msgid", item["msgid"]), newline)
		f:write(format_kv("msgstr", item["msgstr"]), newline)
		f:write(newline)
	end

	f:write(newline)
	f:close()
end

function escape_magic(s)
  return (s:gsub('[%^%$%(%)%%%.%[%]%*%+%-%?]','%%%1'))
end

function erase_format_str(s)
	if (find_str(s, "%")) then
		return ""
	end
	return s
end

function WritePOFile_Mix(path, header, arr_item)
	f = io.open(path, "w")
	f:write(header, newline)
	f:write(newline)
	local mix
	for i, item in ipairs(arr_item) do
		-- if (i>10) then
		-- 	break
		-- end
		mix = item["msgstr"].." "..erase_format_str(item["msgid"])
		f:write("#. ", item["name"], newline)
		f:write(format_kv("msgctxt", item["msgctxt"]), newline)
		f:write(format_kv("msgid", item["msgid"]), newline)
		f:write(format_kv("msgstr", mix), newline)
		f:write(newline)
	end

	f:write(newline)
	f:close()
end

function find_str(str)
	return string.find(str, "%", 1, true)
end

function LoadPOFile(path)
	local arr_line = lines_from(path)

	local arr_header = {}
	local arr_item = {}
	local mk, k, v
	local cursor
	local item_num = 0
	local inited = false
	for i, ln in pairs(arr_line) do
		if (starts_with(ln, "#.")) then
			inited = true

			mk = parse_rem(ln)
			item_num = item_num + 1
			arr_item[item_num] = {}
			cursor = arr_item[item_num]
			cursor.name = mk
		end

		if not (inited) then
			push(arr_header, ln)
		end

		if (starts_with(ln, "#.")) then

		end

		if (starts_with(ln, "msgctxt")) then
			k, v = parse_kv(ln)
			if (cursor) then
				cursor.msgctxt = v
			end
		end
		if (starts_with(ln, "msgid")) then
			k, v = parse_kv(ln)
			if (cursor) then
				cursor.msgid = v
			end
		end
		if (starts_with(ln, "msgstr")) then
			k, v = parse_kv(ln)
			if (cursor) then
				cursor.msgstr = v
			end
		end

		-- test
		-- if (find_str(ln, "%")) then
		-- 	print(mk, k)
		-- 	print(ln)
		-- 	print("")
		-- end

	end

	local header = tjoin(arr_header)
	return header, arr_item
end


require "tprint"

------------------------------------------------------------
-- main chinese_s.po
------------------------------------------------------------

local folder = "/drive_d/game/dstserver/dst/data/scripts/languages"
local lang1 = "chinese_s (copy).po"
local lang2 = "chinese_s.po"


local header, arr_item = LoadPOFile(lang1)
-- print(header)
-- tprint(arr_item)
WritePOFile_Mix(lang2, header, arr_item)


local msg = ("from %s to %s"):format(lang1, lang2)
print(msg)
print("conv ok.")