require("util_gui")
require("form_stage_main\\form_world_war\\form_world_war_define")
local FORM_NAME = "form_stage_main\\form_world_war\\form_world_war_stat"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  local form_stage = util_get_form("form_stage_main\\form_world_war\\form_world_war_stage", true, false)
  if form.groupbox_main:Add(form_stage) then
    form.form_stage = form_stage
    form_stage.Visible = false
  end
  local form_ranking = util_get_form("form_stage_main\\form_world_war\\form_world_war_ranking", true, false)
  if form.groupbox_main:Add(form_ranking) then
    form.form_ranking = form_ranking
    form_ranking.Visible = false
  end
  local form_details = util_get_form("form_stage_main\\form_world_war\\form_world_war_details", true, false)
  if form.groupbox_main:Add(form_details) then
    form.form_details = form_details
    form_details.Visible = false
  end
  local form_sub_details = util_get_form("form_stage_main\\form_world_war\\form_world_war_sub_details", true, false)
  if form.groupbox_sub_details:Add(form_sub_details) then
    form.form_sub_details = form_sub_details
    form_sub_details.Visible = true
  end
  local form_sub_details_aga = util_get_form("form_stage_main\\form_world_war\\form_world_war_sub_details_aga", true, false)
  if form.groupbox_sub_details:Add(form_sub_details_aga) then
    form.form_sub_details_aga = form_sub_details_aga
    form_sub_details_aga.Visible = true
  end
  form.rbtn_tab_1.Checked = true
  on_rbtn_tab_1_checked_changed(form.rbtn_tab_1)
  req_army_info()
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function on_rbtn_tab_1_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  hide_all_sub_form(form)
  if nx_find_custom(form, "form_stage") and nx_is_valid(form.form_stage) then
    form.form_stage.Visible = true
  end
end
function on_rbtn_tab_2_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  hide_all_sub_form(form)
  if nx_find_custom(form, "form_ranking") and nx_is_valid(form.form_ranking) then
    form.form_ranking.Visible = true
  end
  send_world_war_custom_msg(CLIENT_WORLDWAR_STAT_INFO, nx_int(form.form_ranking.selected_side), nx_int(1), nx_int(12))
end
function on_rbtn_tab_3_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  hide_all_sub_form(form)
  if nx_find_custom(form, "form_details") and nx_is_valid(form.form_details) then
    form.form_details.Visible = true
  end
end
function on_btn_open_map_click(rbtn)
  local form = util_get_form("form_stage_main\\form_world_war\\form_world_war_map", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function on_btn_exit_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = gui.TextManager:GetText("ui_main_leaveinfo", name)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_WAR), nx_int(CLIENT_WORLDWAR_LEAVE))
  end
end
function send_world_war_custom_msg(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_WAR), nx_int(sub_msg), unpack(arg))
end
function hide_all_sub_form(form)
  if nx_find_custom(form, "form_stage") and nx_is_valid(form.form_stage) then
    form.form_stage.Visible = false
  end
  if nx_find_custom(form, "form_ranking") and nx_is_valid(form.form_ranking) then
    form.form_ranking.Visible = false
  end
  if nx_find_custom(form, "form_details") and nx_is_valid(form.form_details) then
    form.form_details.Visible = false
  end
  form.Width = form.groupbox_form.Width
end
function req_army_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_WAR), nx_int(CLIENT_WORLDWAR_ARMY))
end
function rev_army_info(...)
  local form = util_get_form(FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_soldier_number_1.Text = nx_widestr(arg[1])
  form.lbl_soldier_number_2.Text = nx_widestr(arg[2])
end
function close_form()
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    form:Close()
  end
end
