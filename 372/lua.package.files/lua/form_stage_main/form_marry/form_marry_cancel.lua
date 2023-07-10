require("form_stage_main\\form_marry\\form_marry_util")
function main_form_init(form)
  form.Fixed = false
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
function on_btn_ok_click(self)
  local form = self.ParentForm
  custom_marry(CLIENT_MSG_SUB_MARRY_REQUEST_CANCEL)
end
function on_btn_cancel_click(self)
  local form = self.ParentForm
  form:Close()
end
function show_data(player_name)
  local gui = nx_value("gui")
  local form = util_get_form(FORM_MARRY_CANCEL, true)
  if not nx_is_valid(form) then
    return 0
  end
  form.mltbox_info.HtmlText = gui.TextManager:GetFormatText("ui_marry_cancel_info", player_name)
  util_show_form(FORM_MARRY_CANCEL, true)
end
