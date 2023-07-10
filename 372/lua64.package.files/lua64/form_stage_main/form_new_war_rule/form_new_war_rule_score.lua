require("util_gui")
require("util_functions")
local UBST_NEW_SCHOOL_FIGHT = 3
local UBST_NEW_CROSS_SCHOOL_FIGHT = 4
function open_form()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local sub_type = client_player:QueryProp("BattleSubType")
  if nx_int(sub_type) == nx_int(UBST_NEW_SCHOOL_FIGHT) or nx_int(sub_type) == nx_int(UBST_NEW_CROSS_SCHOOL_FIGHT) then
    util_auto_show_hide_form("form_stage_main\\form_new_war_rule\\form_new_war_rule_score_school_fight")
  end
end
