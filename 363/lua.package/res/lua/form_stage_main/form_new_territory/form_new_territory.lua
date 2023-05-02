require("util_functions")
require("util_gui")
require("share\\client_custom_define")
function main_form_init(self)
  self.Fixed = false
  self.Visible = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("NewTerritoryCampIndex", "int", self, "form_stage_main\\form_new_territory\\form_new_territory", "on_change")
  end
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
  return 1
end
function on_change(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local index = client_player:QueryProp("NewTerritoryCampIndex")
  form.lbl_light_join_info.Visible = false
  form.lbl_dark_join_info.Visible = false
  if nx_int(index) == nx_int(1) then
    form.lbl_light_join_info.Visible = true
  elseif nx_int(index) == nx_int(2) then
    form.lbl_dark_join_info.Visible = true
  end
end
function on_btn_light_click(self)
  local form = self.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog:ShowModal()
  local text = nx_widestr(util_text("ui_newterritroy_join_light_camp"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_TERRITORY), 0, 1)
  end
  return 1
end
function on_btn_dark_click(self)
  local form = self.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog:ShowModal()
  local text = nx_widestr(util_text("ui_newterritroy_join_dark_camp"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_TERRITORY), 0, 2)
  end
  return 1
end
function on_btn_trans_click(self)
  local form = self.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_TERRITORY), 1)
  form:Close()
  return 1
end
function on_pvp_begin()
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog:ShowModal()
  local text = nx_widestr(util_text("ui_apply_pvpactivty"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if res == "ok" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_TERRITORY), 2)
  elseif res == "cancel" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_TERRITORY), 3)
  end
end
function on_pvp_cancel()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_TERRITORY), 3)
end
function on_pvp_quit()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_TERRITORY), 4)
end
function on_server_msg(...)
  local type = nx_int(arg[1])
  if nx_int(type) == nx_int(0) then
    util_show_form("form_stage_main\\form_new_territory\\form_new_territory", true)
  elseif nx_int(type) == nx_int(1) then
    util_show_form("form_stage_main\\form_new_territory\\form_main_new_territory", true)
  elseif nx_int(type) == nx_int(2) then
    util_show_form("form_stage_main\\form_new_territory\\form_main_new_territory", false)
  elseif nx_int(type) == nx_int(3) then
    local light_count = nx_int(arg[2])
    local dark_count = nx_int(arg[3])
    nx_execute("form_stage_main\\form_new_territory\\form_main_new_territory", "on_inform_camp_count", light_count, dark_count)
  elseif nx_int(type) == nx_int(4) then
    local light_count = nx_int(arg[2])
    local dark_count = nx_int(arg[3])
    refresh_pbar(light_count, dark_count)
  end
end
function refresh_pbar(light_count, dark_count)
  local form = nx_value("form_stage_main\\form_new_territory\\form_new_territory")
  if not nx_is_valid(form) then
    return
  end
  form.pbar_camp_count.Visible = true
  form.pbar_camp_count.Maximum = nx_int(light_count) + nx_int(dark_count)
  form.pbar_camp_count.Value = nx_int(light_count)
  form.lbl_camp_count.Text = nx_widestr(light_count) .. nx_widestr("/") .. nx_widestr(dark_count)
end
function on_btn_goback_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_TERRITORY), 5)
  form:Close()
end
function custom_clear_camp_item(view_id_num, view_index_num)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog:ShowModal()
  local text = nx_widestr(util_text("ui_newterritroy_clear_camp"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_use_item", view_id_num, view_index_num)
  end
end
