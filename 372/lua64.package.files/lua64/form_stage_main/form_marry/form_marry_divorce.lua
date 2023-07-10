require("form_stage_main\\form_marry\\form_marry_util")
function main_form_init(form)
  form.Fixed = false
  form.money_t = 0
  form.money_m = 0
  form.target_name = nx_widestr("")
end
function on_main_form_open(form)
  set_form_pos(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_colse_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_btn_divorce_t_click(self)
  local form = self.ParentForm
  custom_marry(CLIENT_MSG_SUB_MARRY_DIVORCE_T)
end
function on_btn_divorce_m_click(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local info = gui.TextManager:GetFormatText("ui_marry_rite_info2", nx_int(nx_number(form.money_m) / 1000), form.target_name)
  local res = show_confirm(info)
  if res == "cancel" then
    return 0
  end
  custom_marry(CLIENT_MSG_SUB_MARRY_DIVORCE_M)
end
function show_data(opt_type, player_name, money1, money2)
  if nx_number(opt_type) == 0 then
    local form = util_get_form(FORM_MARRY_DIVORCE, false)
    if nx_is_valid(form) then
      form:Close()
    end
    return 0
  end
  local gui = nx_value("gui")
  local form = util_get_form(FORM_MARRY_DIVORCE, true)
  if not nx_is_valid(form) then
    return 0
  end
  form.money_t = money1
  form.money_m = money2
  form.target_name = player_name
  form.mltbox_info.HtmlText = gui.TextManager:GetFormatText("ui_divorce_info", player_name, nx_int(nx_number(money1) / 1000), nx_int(nx_number(money2) / 1000))
  util_show_form(FORM_MARRY_DIVORCE, true)
end
