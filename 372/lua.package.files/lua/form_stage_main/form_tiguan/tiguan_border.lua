require("util_functions")
require("game_effect")
local eff_tab = {}
local eff_name = "func_hold_2"
local ShowDistance = 20
local TwoPointDistance = 1
function show_tiguan_border(id)
  local tiguan_border = nx_value("tiguan_border")
  if not nx_is_valid(tiguan_border) then
    return
  end
  tiguan_border.EffectName = eff_name
  tiguan_border.ShowDistance = ShowDistance
  tiguan_border:LoadResource(nx_string(id))
  tiguan_border:SplitBorderPoint(TwoPointDistance)
end
