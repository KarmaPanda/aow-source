require("util_gui")
require("util_functions")
require("util_static_data")
require("define\\sysinfo_define")
require("custom_sender")
require("form_stage_main\\form_taosha\\taosha_util")
local FORM_NAME = "form_stage_main\\form_taosha\\form_rank1"
local AWARDS_FORM_NAME = "form_stage_main\\form_taosha\\form_taosha_awards"
function open_form(...)
  local form = get_form()
  if not nx_is_valid(form) then
    util_show_form(FORM_NAME, true)
  end
end
function close_form()
  local form = get_form()
  if nx_is_valid(form) then
    form:Close()
  end
end
function main_form_init(form)
end
function on_main_form_open(form)
  nx_execute(AWARDS_FORM_NAME, "reset_form_position")
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function get_form()
  local form = nx_value(FORM_NAME)
  return form
end
