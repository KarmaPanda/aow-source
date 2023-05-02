require("util_gui")
local VIEWPORT_DAMAGE_STATISTICS = 166
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.refresh_time = 0
  self.sum_time = 0
  self.Left = gui.Width - self.Width
  self.Top = gui.Height - self.Height - 312
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_DAMAGE_STATISTICS, self, nx_current(), "on_damage_view_oper")
  local thd_manager = nx_value("TaohuadaoManager")
  if not nx_is_valid(thd_manager) then
    nx_msgbox("In valid taohuad")
    return 0
  end
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_msg_initial_form(chander, arg_num, msg_type, ...)
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_fight\\form_masses_fight", true, false)
  if nx_is_valid(dialog) then
    dialog:Show()
    nx_set_value("form_stage_main\\form_fight\\form_masses_fight", dialog)
  end
end
function on_server_msg(...)
  local form = nx_value("form_stage_main\\form_fight\\form_masses_fight")
  if not nx_is_valid(form) then
    return
  end
  local type = arg[1]
  if nx_int(type) == nx_int(2) then
    form:Close()
  elseif nx_int(type) == nx_int(3) then
  end
end
function on_main_form_close(self)
  ui_destroy_attached_form(self)
  nx_destroy(self)
end
function on_damage_view_oper(form, op_type, view_ident, index)
  if not nx_is_valid(form) or not form.Visible then
    return false
  end
  local new_time = nx_function("ext_get_tickcount")
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return false
  end
  if op_type == "createview" then
    get_map_data(form)
  elseif op_type == "deleteview" then
  elseif op_type == "additem" then
    get_map_data(form)
  elseif op_type == "delitem" then
    get_map_data(form)
  elseif op_type == "updateview" then
    get_map_data(form)
  elseif op_type == "updaterecord" then
    get_map_data(form)
  end
  return true
end
function get_map_data(form)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_DAMAGE_STATISTICS))
  if not nx_is_valid(view) then
    return false
  end
  local damage_all = view:QueryProp(nx_string("EgWarOneDamageTarget"))
  local dodge = view:QueryProp(nx_string("EgWarDodge"))
  local baoji_count = view:QueryProp(nx_string("EgWarVa"))
  form.lbl_1_1.Text = nx_widestr(damage_all)
  form.lbl_2_2.Text = nx_widestr(dodge)
  form.lbl_5_5.Text = nx_widestr(baoji_count)
  if form.btn_Hiden.Visible then
  end
  form.lbl_damage.Text = nx_widestr(damage_all)
  form.lbl_baoji.Text = nx_widestr(baoji_count)
end
function on_btn_show_panel_click(btn)
  local form_buttons = nx_value("form_clone_damage_")
  if not nx_is_valid(form_buttons) then
    return
  end
  form_buttons.Visible = true
  form_buttons:Show()
end
function on_btn_Hiden_click(btn)
  local form = btn.ParentForm
  form.Width = 270
  form.Height = 25
  form.btn_show_all.Visible = true
  btn.Visible = false
end
function on_btn_show_all_click(btn)
  local form = btn.ParentForm
  form.Width = 270
  form.Height = 180
  form.btn_Hiden.Visible = true
  btn.Visible = false
end
function on_time_changed(time_count, remain_count)
  local form = nx_value("form_stage_main\\form_fight\\form_masses_fight")
  if not nx_is_valid(form) then
    return
  end
  form.lbl_6_6.Text = nx_widestr(time_count)
  form.lbl_7.Text = nx_widestr(remain_count)
end
