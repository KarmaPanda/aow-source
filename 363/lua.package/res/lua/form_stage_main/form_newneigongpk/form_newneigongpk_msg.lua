require("util_gui")
require("util_functions")
local g_form_name = "form_stage_main\\form_newneigongpk\\form_newneigongpk_main"
local g_task_trace_name = "form_stage_main\\form_task\\form_task_trace"
local g_select_name = "form_stage_main\\form_main\\form_main_select"
function on_recive_msg(...)
  local msg_type = arg[1]
  if msg_type == 1 then
    util_show_form(g_form_name, true)
    util_show_form(g_task_trace_name, false)
    local form = nx_value(g_select_name)
    if nx_is_valid(form) then
      form.Visible = false
    end
  elseif msg_type == 3 then
    local hp_frd_total = arg[2]
    local hp_enm_total = arg[3]
    local hp_frd = arg[4]
    local hp_enm = arg[5]
    nx_execute("form_stage_main\\form_newneigongpk\\form_newneigongpk_main", "refresh_state", hp_frd_total, hp_enm_total, hp_frd, hp_enm)
  elseif msg_type == 2 then
    util_show_form(g_form_name, false)
    util_show_form(g_task_trace_name, true)
  end
end
