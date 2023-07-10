require("util_gui")
require("form_stage_main\\form_world_war\\form_world_war_define")
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  for i = 1, 20 do
    local groupbox_2 = form.groupbox_2
    local control_name = "btn_" .. nx_string(i)
    local control = groupbox_2:Find(control_name)
    if nx_is_valid(control) then
      control.index = nx_int(i)
      control.state = 0
    end
  end
  req_aga_info()
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function btn_show_info_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local worldwar_manager = nx_value("WorldWarManager")
  if not nx_is_valid(worldwar_manager) then
    return
  end
  local index = btn.index
  local state = btn.state
  local info_list = worldwar_manager:GetWujiangByIndex(index)
  local length = table.getn(info_list)
  if length < 2 then
    return
  end
  local config_id = info_list[1]
  local pho = info_list[2]
  local gui = nx_value("gui")
  form.lbl_image.BackImage = nx_string(pho)
  form.lbl_name.Text = gui.TextManager:GetText(nx_string(config_id))
  form.mltbox_desc.HtmlText = gui.TextManager:GetText("ui_" .. nx_string(config_id) .. "_desc")
  form.lbl_state.Text = gui.TextManager:GetText("ui_worldwar_live_state_" .. nx_string(state))
  if state == 1 then
    form.lbl_state.ForeColor = "255,220,18,0"
  else
    form.lbl_state.ForeColor = "255,0,36,220"
  end
end
function req_aga_info()
  local worldwar_manager = nx_value("WorldWarManager")
  if not nx_is_valid(worldwar_manager) then
    return
  end
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
    local is_wujing = worldwar_manager:CheckIsWujing(config_id)
    if is_wujing == 1 then
      local index = worldwar_manager:GetIndexByConfigID(nx_string(config_id))
      set_btn_state(index, state)
    end
  end
end
function set_btn_state(index, state)
  local form = nx_value("form_stage_main\\form_world_war\\form_world_war_sub_details_aga")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local groupbox_2 = form.groupbox_2
  local control_name = "btn_" .. nx_string(index)
  local control = groupbox_2:Find(control_name)
  if nx_is_valid(control) then
    control.state = state
    if state == 1 then
      control.ForeColor = "255,220,18,0"
    else
      control.ForeColor = "255,0,36,220"
    end
  end
end
