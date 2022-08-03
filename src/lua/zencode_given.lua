--[[
--This file is part of zenroom
--
--Copyright (C) 2018-2021 Dyne.org foundation
--designed, written and maintained by Denis Roio <jaromil@dyne.org>
--
--This program is free software: you can redistribute it and/or modify
--it under the terms of the GNU Affero General Public License v3.0
--
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU Affero General Public License for more details.
--
--Along with this program you should have received a copy of the
--GNU Affero General Public License v3.0
--If not, see http://www.gnu.org/licenses/agpl.txt
--
--Last modified by Denis Roio
--on Saturday, 13th November 2021
--]]

-- TODO: use strict table
-- https://stevedonovan.github.io/Penlight/api/libraries/pl.strict.html

-- the main security concern in this Zencode module is that no data
-- passes without validation from IN to ACK or from inline input.

-- data coming in is analyzed through a series of functions:
-- guess_conversion(raw, conv or name) -> zenode_data.lua L:100 approx 
--- |_ if luatype(string) && format -> input encoding(format)

-- GIVEN
local function gc()
   TMP = {}
   collectgarbage 'collect'
end

-- safely take any zenroom object as index
local function _index_to_string(what)
   local t = type(what)
   if t == 'string' then
      return what
   elseif iszen(t) then
      return what:octet():string()
   end
   error("Invalid type to index variable in heap: "..t, 3)
   return nil
end

---
-- Pick a generic data structure from the <b>IN</b> memory
-- space. Looks for named data on the first and second level and makes
-- it ready in TMP for @{validate} or @{ack}.
--
-- @function pick(name, data, encoding)
-- @param what string descriptor of the data object
-- @param conv[opt] optional encoding spec (default CONF.input.encoding)
-- @return true or false
local function pick(what, conv)
   local guess
   local data
   local raw
   local name = _index_to_string(what)
   raw = KIN[name] or IN[name]
   if not raw then error("Cannot find '" .. name .. "' anywhere (null value?)", 2) end
   if raw == '' then error("Found empty string in '" .. name) end
   -- if not conv and ZEN.schemas[what] then conv = what end
   TMP = guess_conversion(raw, conv or name)
   if not TMP then error('Cannot guess any conversion for: ' ..
         luatype(raw) .. ' ' .. (conv or name or '(nil)')) end
   TMP.name = name
   TMP.schema = conv
   assert(ZEN.OK)
   if DEBUG > 1 then
      ZEN:ftrace('pick found ' .. name .. '('..TMP.zentype..')')
   end
end

---
-- Pick a data structure named 'what' contained under a 'section' key
-- of the at the root of the <b>IN</b> memory space. Looks for named
-- data at the first and second level underneath IN[section] and moves
-- it to TMP[what][section], ready for @{validate} or @{ack}. If
-- TMP[what] exists already, every new entry is added as a key/value
--
-- @function pickin(section, name)
-- @param section string descriptor of the section containing the data
-- @param what string descriptor of the data object
-- @param conv string explicit conversion or schema to use
-- @param fail bool bail out or continue on error
-- @return true or false
local function pickin(section, what, conv, fail)
   ZEN.assert(section, 'No section specified')
   local root  -- section
   local raw  -- data pointer
   local bail  -- fail
   local name = _index_to_string(what)
   root = KIN[section]
   if not root then
      root = IN[section]
   end
   if not root then
      error("Cannot find '"..section.."'", 2)
   end
   if luatype(root) ~= 'table' then
      error("Object is not a table: "..section, 2)
   end
   if #root == 1 then
      raw = root[name]
      if not raw and luatype(root[1]) == 'table' then
	 raw = root[1][name]
      end
   else
      raw = root[name]
   end
   if not raw then
      error("Object not found: "..name.." in "..section, 2)
   end

   if raw == '' then
      error("Found empty string '" .. name .."' inside '"..section.."'", 2) end
   -- conv = conv or name
   -- if not conv and ZEN.schemas[name] then conv = name end
   -- if no encoding provided then conversion is same as name (schemas etc.)
   TMP = guess_conversion(raw, conv or name)
   TMP.name = name
   TMP.root = section
   TMP.schema = conv
   assert(ZEN.OK)
   if DEBUG > 1 then
      ZEN:ftrace('pickin found ' .. name .. ' in ' .. section)
   end
end

local function ack_table(key, val)
   ZEN.assert(
      luatype(key) == 'string',
      'ZEN:table_add arg #1 is not a string'
   )
   ZEN.assert(
      luatype(val) == 'string',
      'ZEN:table_add arg #2 is not a string'
   )
   if not ACK[key] then
      ACK[key] = {}
   end
   ACK[key][val] = operate_conversion(TMP)
   if key ~= TMP.name then
      ZEN.CODEC[key] = ZEN.CODEC[TMP.name]
      ZEN.CODEC[TMP.name] = nil
   end
end

---
-- Final step inside the <b>Given</b> block towards the <b>When</b>:
-- pass on a data structure into the ACK memory space, ready for
-- processing.  It requires the data to be present in TMP[name] and
-- typically follows a @{pick}. In some restricted cases it is used
-- inside a <b>When</b> block following the inline insertion of data
-- from zencode.
--
-- @function ack(name)
-- @param name string key of the data object in TMP[name]
local function ack(what)
   local name = _index_to_string(what)
   ZEN.assert(TMP, 'No valid object found: ' .. name)
   empty(name)
   ACK[name] = operate_conversion(TMP)
   -- name of schema may differ from name of object
   -- new_codec(name, { schema = TMP.schema })

   -- if TMP.schema and (TMP.schema ~= 'number') and ( TMP.schema ~= TMP.encoding ) then
   --    ZEN.CODEC[name].schema = TMP.schema
   -- end

end

Given(
   'nothing',
   function()
      ZEN.assert(
         (next(IN) == nil) and (next(KIN) == nil),
         'Undesired data passed as input'
      )
   end
)

-- maybe TODO: Given all valid data
-- convert and import data only when is known by schema and passes validation
-- ignore all other data structures that are not known by schema or don't pass validation

Given(
   "am ''",
   function(name)
      Iam(name)
   end
)

Given(
   "my name is in a '' named ''",
   function(sc, name)
      pick(name, sc)
      assert(TMP.name, 'No name found in: ' .. name)
      Iam(O.to_string(operate_conversion(TMP)))
      ZEN.CODEC[name] = nil -- just used to get name
   end
)

Given(
   "my name is in a '' named '' in ''",
   function(sc, name, struct)
      pickin(struct, name, sc)
      assert(TMP.name,  'No name found in: '..name)
      Iam(O.to_string(operate_conversion(TMP)))
      ZEN.CODEC[name] = nil -- just name string
   end
)

-- variable names:
-- s = schema of variable (or encoding)
-- n = name of variable
-- t = table containing the variable

-- TODO: I have a '' as ''
Given(
   "a ''",
   function(n)
      pick(n)
      ack(n)
      gc()
   end
)

Given(
   "a '' in ''",
   function(s, t)
      pickin(t, s)
      ack(s) -- save it in ACK.obj
      gc()
   end
)

-- public keys for keyring arrays
-- returns a special array for upcoming session:
-- public_key_session : { name : value }
Given(
   "a '' public key from ''",
   function(s, t)
      -- if not pickin(t, s, nil, false) then
      -- 	pickin(s, t)
      -- end
      pickin(t, s..'_public_key', s..'_public_key', false)
      ack_table('public_key_session', t)
   end
)

Given(
   "a '' from ''",
   function(s, t)
      -- if not pickin(t, s, nil, false) then
      -- 	pickin(s, t)
      -- end
      pickin(t, s, s, false)
      ack_table(s, t)
      gc()
   end
)

Given(
   "a '' named ''",
   function(s, n)
      -- ZEN.assert(encoder, "Invalid input encoding for '"..n.."': "..s)
      pick(n, s)
      ack(n)
      gc()
   end
)

Given(
   "a '' named by ''",
   function(s, n)
      -- local name = have(n)
      local name = _index_to_string(KIN[n] or IN[n])
      -- ZEN.assert(encoder, "Invalid input encoding for '"..n.."': "..s)
      pick(name, s)
      ack(name)
      gc()
   end
)

Given(
   "a '' named '' in ''",
   function(s, n, t)
      pickin(t, n, s)
      ack(n) -- save it in ACK.name
      gc()
   end
)

Given(
   "a '' named by '' in ''",
   function(s, n, t)
      local name = _index_to_string(KIN[n] or IN[n])
      pickin(t, name, s)
      ack(name) -- save it in ACK.name
      gc()
   end
)

Given(
   "my ''",
   function(n)
      ZEN.assert(WHO, 'No identity specified, use: Given I am ...')
      pickin(WHO, n)
      ack(n)
      gc()
   end
)

Given(
   "my '' named ''",
   function(s, n)
      -- ZEN.assert(encoder, "Invalid input encoding for '"..n.."': "..s)
      pickin(WHO, n, s)
      ack(n)
      gc()
   end
)
Given(
   "my '' named by ''",
   function(s, n)
      -- ZEN.assert(encoder, "Invalid input encoding for '"..n.."': "..s)
      local name = _index_to_string(KIN[n] or IN[n])
      pickin(WHO, name, s)
      ack(name)
      gc()
   end
)

Given(
   "a '' is valid",
   function(n)
      pick(n)
      gc()
   end
)
Given(
   "my '' is valid",
   function(n)
      pickin(WHO, n)
      gc()
   end
)
