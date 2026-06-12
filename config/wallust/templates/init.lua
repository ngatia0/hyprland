-- ~/.config/lite-xl/init.lua
local style = require "core.style"
local common = require "core.common"

-- 1. FONT SIZE
style.font:set_size(14)
style.code_font:set_size(13)

-- 2. WALLUST COLORS
-- REMOVED the extra { } from around common.color
style.background     = common.color "{{background}}"
style.background2    = common.color "{{color0}}"
style.background3    = common.color "{{color8}}"
style.text           = common.color "{{foreground}}"
style.caret          = common.color "{{color4}}"
style.accent         = common.color "{{color4}}"
style.dim            = common.color "{{color7}}"
style.divider        = common.color "{{background}}"
style.selection      = common.color "{{color8}}"
style.line_number    = common.color "{{color8}}"
style.line_number2   = common.color "{{color7}}"
style.line_highlight = common.color "{{color0}}"
style.scrollbar      = common.color "{{color0}}"
style.scrollbar2     = common.color "{{color4}}"

-- 3. SYNTAX HIGHLIGHTING
style.syntax["normal"]   = common.color "{{foreground}}"
style.syntax["symbol"]   = common.color "{{foreground}}"
style.syntax["comment"]  = common.color "{{color8}}"
style.syntax["keyword"]  = common.color "{{color5}}"
style.syntax["keyword2"] = common.color "{{color6}}"
style.syntax["number"]   = common.color "{{color3}}"
style.syntax["literal"]  = common.color "{{color3}}"
style.syntax["string"]   = common.color "{{color2}}"
style.syntax["operator"] = common.color "{{color1}}"
style.syntax["function"] = common.color "{{color4}}"