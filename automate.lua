#!/bin/env lua
--[[

  automate

  A small script used for my personal home automation.
  It reads, interprets and triggers actions based on incoming MQTT messages.

  dependencies (arch):
    pacman -S mosquitto lua lua-filesystem
    luarocks install lua-mosquitto
    luarocks install dkjson

]]--

local lfs = require("lfs")
local json = require("dkjson")
local mqtt = require("mosquitto")
local client = mqtt.new()

local modules = {}
function Subscribe(pattern, func)
  modules[func] = {
    pattern = string.gsub(pattern, "([%+%-%*%(%)%?%[%]%^])", "%%%1"),
    cache = {}
  }
end

function Publish(topic, value)
  client:publish(topic, value, 1, true)
end

-- loading all modules
local count = 0
for file in lfs.dir("modules/") do
  local attr = lfs.attributes("modules/" .. file)

  if attr and attr.mode == "file" then
    dofile("modules/" .. file)
    count = count + 1
  end
end
print("Loaded " .. count .. " automation modules")


client.ON_CONNECT = function()
  print("connected")
  client:subscribe("#")
end

client.ON_MESSAGE = function(mid, topic, payload)
  local data = json.decode(payload)
  local datatype = "JSON"

  if not data then
    data = payload
    datatype = "PLAIN"
  end

  for func, mod in pairs(modules) do
    if string.find(topic, mod.pattern) then
      func(data, mod.cache)
    end
  end
end

client:connect("mqtt.midgard")
client:loop_forever()
