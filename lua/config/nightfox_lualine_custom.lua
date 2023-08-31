--[[
    Copyright 2023 Oscar Wallberg

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]

local Color = require("nightfox.lib.color")
local spec = require("nightfox.spec").load("nightfox")

local pal = spec.pallet
local bg = Color.from_hex(spec.bg1)
local fg = spec.fg2

local function generate_mode(color, amount)
  amount = amount or 0.3
  local fade = bg:blend(Color.from_hex(color), amount):to_css()
  local b = bg:to_css()
  local f = fg

  return {
    a = { bg = color, fg = b },
    b = { bg = fade, fg = f },
    c = { bg = b, fg = f },
  }
end

-- stylua: ignore
local nightfox =  {
  normal   = generate_mode(pal.blue.base),
  insert   = generate_mode(pal.green.base),
  command  = generate_mode(pal.yellow.base),
  visual   = generate_mode(pal.magenta.base),
  replace  = generate_mode(pal.red.base),
  inactive = generate_mode(spec.fg3),
}

return nightfox
