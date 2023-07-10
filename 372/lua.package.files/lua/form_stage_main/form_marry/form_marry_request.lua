require("form_stage_main\\form_marry\\form_marry_util")
require("util_gui")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  set_form_pos(form)
  gui.Focused = form.edit_name
  return 1
end
function on_main_form_close(form)
  ui_destroy_attached_form(form)
  nx_destroy(form)
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function on_btn_colse_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_btn_ok_click(self)
  local form = self.ParentForm
  local player_name = form.edit_name.Text
  if nx_string(player_name) == "" then
    return 0
  end
  local money = nx_number(form.edit_ding_1.Text) * 1000000 + nx_number(form.edit_liang_1.Text) * 1000 + nx_number(form.edit_wen_1.Text)
  custom_marry(CLIENT_MSG_SUB_MARRY_REQUEST_SEND, player_name, nx_int64(money))
end
function on_btn_cancel_click(self)
  local form = self.ParentForm
  form:Close()
end
function show_data(opt_type)
  if nx_number(opt_type) == 0 then
    local form = util_get_form(FORM_MARRY_REQUEST, false)
    if nx_is_valid(form) then
      form:Close()
    end
    return 0
  end
  local form = util_get_form(FORM_MARRY_REQUEST, true)
  if not nx_is_valid(form) then
    return 0
  end
  local marry_main_ini = nx_execute("util_functions", "get_ini", INI_FILE_MARRY_MAIN)
  if not nx_is_valid(marry_main_ini) then
    return 0
  end
  local index = marry_main_ini:FindSectionIndex("BaseProp")
  if index < 0 then
    return 0
  end
  local money = marry_main_ini:ReadString(index, "RequestMoney", 0)
  form.edit_liang_2.Text = nx_widestr(nx_number(money) / 1000)
  util_show_form(FORM_MARRY_REQUEST, true)
  nx_execute("util_gui", "ui_show_attached_form", form)
end
