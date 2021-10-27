local naughty = require("naughty")

local defaultOutput = 'eDP-1'

outputMapping = {
}

screens = {
    -- The internal monitor.  This used to just show up as "default", but is
    -- now showing up with a proper EDID.  Not entirely sure why that's the case,
    -- so I just have two of these in here doing the same thing.
    ['default'] = {
        ['connected'] = function (xrandrOutput)
            return '--output ' .. xrandrOutput .. ' --auto --primary --scale 0.5x0.5'
        end,
        ['disconnected'] = function (xrandrOutput)
            return '--output ' .. defaultOutput .. ' --auto --primary --scale 0.5x0.5'
        end
    },
    ['700001'] = { -- /sys/class/drm/card0/card0-eDP-1
        ['connected'] = function (xrandrOutput)
            return '--output ' .. xrandrOutput .. ' --auto --primary --scale 0.5x0.5'
        end,
        ['disconnected'] = function (xrandrOutput)
            return '--output ' .. defaultOutput .. ' --auto --primary --scale 0.5x0.5'
        end
    },
    -- Main Google desk monitor
    ['227111110'] = {
        ['connected'] = function (xrandrOutput)
            return '--output ' .. xrandrOutput .. ' --auto --primary --left-of ' .. defaultOutput
        end,
        ['disconnected'] = function (xrandrOutput)
            return '--output ' .. xrandrOutput .. ' --off'
        end
    }
}

--
--
--
-- New monitors come after here
--
--
--

--    ['40171551020'] = { -- DP-4
--        ['connected'] = function (xrandrOutput)
--            if xrandrOutput ~= defaultOutput then
--                return '--output ' .. xrandrOutput .. ' --auto --same-as ' .. defaultOutput
--            end
--            return nil
--        end,
--        ['disconnected'] = function (xrandrOutput)
--            if xrandrOutput ~= defaultOutput then
--            return '--output ' .. xrandrOutput .. ' --off --output ' .. defaultOutput .. ' --auto'
--            end
--            return nil
--        end
--    }
--    ['1000049'] = { -- DP-2
--        ['connected'] = function (xrandrOutput)
--            if xrandrOutput ~= defaultOutput then
--                return '--output ' .. xrandrOutput .. ' --auto --same-as ' .. defaultOutput
--            end
--            return nil
--        end,
--        ['disconnected'] = function (xrandrOutput)
--            if xrandrOutput ~= defaultOutput then
--            return '--output ' .. xrandrOutput .. ' --off --output ' .. defaultOutput .. ' --auto'
--            end
--            return nil
--        end
--    }
