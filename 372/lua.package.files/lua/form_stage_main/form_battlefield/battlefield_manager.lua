require("define\\map_lable_define")
require("form_stage_main\\form_battlefield\\battlefield_define")
local TYPE_BATTLE = 23
function show_banner_place(...)
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) then
    return
  end
  local count = table.getn(arg)
  if count == 1 then
    delete_battle_banner_lable(arg[1])
  end
  if 3 <= count then
    local side = arg[1]
    local x = arg[2]
    local z = arg[3]
    add_battle_banner_lable(side, x, z)
  end
  if 6 <= count then
    local side = arg[4]
    local x = arg[5]
    local z = arg[6]
    add_battle_banner_lable(side, x, z)
  end
end
function add_battle_banner_lable(side, x, z)
  if side == SIDE_WHITE then
    nx_execute("form_stage_main\\form_map\\form_map_scene", "add_label_to_map", BATTLE_WHITE_BANNER, x, z)
  elseif side == SIDE_BLACK then
    nx_execute("form_stage_main\\form_map\\form_map_scene", "add_label_to_map", BATTLE_BLACK_BANNER, x, z)
  end
end
function delete_battle_banner_lable(side)
  if side == SIDE_WHITE then
    nx_execute("form_stage_main\\form_map\\form_map_scene", "delete_map_label", BATTLE_WHITE_BANNER)
  elseif side == SIDE_BLACK then
    nx_execute("form_stage_main\\form_map\\form_map_scene", "delete_map_label", BATTLE_BLACK_BANNER)
  end
end
function show_banner_graping(...)
  local count = table.getn(arg)
  if count == 0 then
    nx_execute("form_stage_main\\form_common_notice", "ClearText", TYPE_BATTLE)
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local desc = nx_widestr("")
  if 2 <= count then
    local str_id = get_text_id(arg[1])
    local force = gui.TextManager:GetText(nx_string(arg[2]))
    desc = desc .. gui.TextManager:GetFormatText(str_id, force)
  end
  if 4 <= count then
    local str_id = get_text_id(arg[3])
    local force = gui.TextManager:GetText(nx_string(arg[4]))
    desc = desc .. nx_widestr("<br>") .. gui.TextManager:GetFormatText(str_id, force)
  end
  nx_execute("form_stage_main\\form_common_notice", "NotifyText", TYPE_BATTLE, desc)
end
function get_text_id(side)
  if SIDE_WHITE == side then
    return "ui_battle_despoil_r"
  elseif SIDE_BLACK == side then
    return "ui_battle_despoil_b"
  end
  return ""
end
