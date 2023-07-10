require("util_gui")
require("form_stage_main\\form_world_war\\form_world_war_define")
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.lbl_yyzcjd_npc001.Text = gui.TextManager:GetText("ui_worldwar_point_state_3")
  form.lbl_yyzcjd_npc002.Text = gui.TextManager:GetText("ui_worldwar_point_state_3")
  form.lbl_yyzcjd_npc003.Text = gui.TextManager:GetText("ui_worldwar_point_state_3")
  form.lbl_yyzcjd_npc004.Text = gui.TextManager:GetText("ui_worldwar_point_state_3")
  form.lbl_yyzcjd_npc005.Text = gui.TextManager:GetText("ui_worldwar_point_state_3")
  form.lbl_yyzcjd_npc006.Text = gui.TextManager:GetText("ui_worldwar_point_state_3")
  req_station_info()
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function req_station_info()
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  if not client_scene:FindRecord("WorldWarNpcStateRec") then
    return
  end
  local rows = client_scene:GetRecordRows("WorldWarNpcStateRec")
  for i = 0, rows - 1 do
    local config_id = client_scene:QueryRecord("WorldWarNpcStateRec", tonumber(i), 0)
    local state = client_scene:QueryRecord("WorldWarNpcStateRec", tonumber(i), 1)
    set_station_state(config_id, state)
  end
end
function set_station_state(config_id, state)
  local form = util_get_form("form_stage_main\\form_world_war\\form_world_war_sub_details", true, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local worldwar_manager = nx_value("WorldWarManager")
  if not nx_is_valid(worldwar_manager) then
    return
  end
  local is_station = worldwar_manager:CheckIsStation(config_id)
  if is_station == 1 then
    local groupbox_1 = form.groupbox_1
    local control_name = "lbl_" .. nx_string(config_id)
    local control = groupbox_1:Find(control_name)
    if nx_is_valid(control) then
      control.Text = gui.TextManager:GetText("ui_worldwar_point_state_" .. nx_string(state))
    end
  end
end
