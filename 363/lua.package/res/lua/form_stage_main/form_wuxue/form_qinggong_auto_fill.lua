require("util_functions")
require("share\\client_custom_define")
require("util_gui")
require("share\\view_define")
require("util_static_data")
require("define\\sysinfo_define")
require("tips_data")
local CLIENT_SUB_AUTO_FILL = 3
local CLIENT_SUB_REQUEST_AUTO_FILL = 4
FORM_QINGGONG_AUTO_FILL = "form_stage_main\\form_wuxue\\form_qinggong_auto_fill"
function on_main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function get_desc_by_id(text_id)
end
function server_msg(...)
end
function on_btn_ok_click(btn)
end
function on_btn_cancel_click(btn)
end
