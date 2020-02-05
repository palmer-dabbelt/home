local naughty = require("naughty")

local defaultOutput = 'eDP-1'

outputMapping = {
}

screens = {
    ['default'] = {
        ['connected'] = function (xrandrOutput)
            if xrandrOutput ~= defaultOutput then
                return '--output ' .. xrandrOutput .. ' --auto --same-as ' .. defaultOutput
            end
            return nil
        end,
        ['disconnected'] = function (xrandrOutput)
            if xrandrOutput ~= defaultOutput then
                return '--output ' .. xrandrOutput .. ' --off --output ' .. defaultOutput .. ' --auto'
            end
            return nil
        end
    },
    ['227111110'] = { -- Google desk monitor
        ['connected'] = function (xrandrOutput)
            if xrandrOutput ~= defaultOutput then
                return '--output ' .. xrandrOutput .. ' --primary --auto --right-of ' .. defaultOutput
            end
            return nil
        end,
        ['disconnected'] = function (xrandrOutput)
            naughty.notify({title = "desktop disconnected"})
            if xrandrOutput ~= defaultOutput then
                return '--output ' .. xrandrOutput .. ' --off --output ' .. defaultOutput .. ' --auto --primary'
            end
            return nil
        end
    },
    ['40171551020'] = { -- Home desk monitor
        ['connected'] = function (xrandrOutput)
            if xrandrOutput ~= defaultOutput then
                return '--output ' .. xrandrOutput .. ' --primary --auto --scale 0.75x0.75 --same-as ' .. defaultOutput
            end
            return nil
        end,
        ['disconnected'] = function (xrandrOutput)
            if xrandrOutput ~= defaultOutput then
                return '--output ' .. xrandrOutput .. ' --off --output ' .. defaultOutput .. ' --auto --primary'
            end
            return nil
        end
   },
   ['226000024'] = { -- Smaller Google monitors
       ['connected'] = function (xrandrOutput)
           if xrandrOutput ~= defaultOutput then
               return '--output ' .. xrandrOutput .. ' --auto --primary --above ' .. defaultOutput
           end
           return nil
       end,
       ['disconnected'] = function (xrandrOutput)
           if xrandrOutput ~= defaultOutput then
           return '--output ' .. xrandrOutput .. ' --off --output ' .. defaultOutput .. ' --auto'
           end
           return nil
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

--    ['000000'] = { -- HDMI-A-1
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
