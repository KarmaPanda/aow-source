require("util_gui")
require("util_functions")
require("util_static_data")
require("define\\sysinfo_define")
require("custom_sender")
require("form_stage_main\\form_taosha\\taosha_util")
local FORM_NAME = "form_stage_main\\form_taosha\\form_taosha_awards"
local RANK1_FORM_NAME = "form_stage_main\\form_taosha\\form_rank1"
function open_form(...)
  local form = get_form()
  if not nx_is_valid(form) then
    util_show_form(FORM_NAME, true)
  end
  receive_ui(unpack(arg))
end
function close_form()
  local form = get_form()
  if nx_is_valid(form) then
    form:Close()
  end
end
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  reset_form_position()
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_see_click(btn)
  nx_execute("form_stage_main\\form_taosha\\taosha_util", "see_other")
  nx_execute("form_stage_main\\form_taosha\\form_taosha_notice", "show_stopsee_btn")
  close_form()
end
function on_btn_close_click(btn)
  local ok = request_quit()
  if ok then
    close_form()
  end
end
function on_cbtn_box_checked_changed(btn)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  if btn.Checked then
    btn.Enabled = false
    request_get_prize()
  end
end
function reset_form_position()
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local no1_form = nx_execute(RANK1_FORM_NAME, "get_form")
  if nx_is_valid(no1_form) then
    local gap = 1
    local total_height = form.Height + no1_form.Height + gap
    no1_form.AbsLeft = (gui.Width - no1_form.Width) / 2
    no1_form.AbsTop = (gui.Height - total_height) / 2
    form.AbsLeft = (gui.Width - form.Width) / 2
    form.AbsTop = no1_form.AbsTop + no1_form.Height + gap
  else
    form.AbsLeft = (gui.Width - form.Width) / 2
    form.AbsTop = (gui.Height - form.Height) / 2
  end
end
function request_open_ui()
  custom_taosha(nx_int(104))
end
function request_quit()
  confirm_quit()
end
function request_get_prize()
  custom_taosha(nx_int(106))
end
function receive_ui(...)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  local n = #arg
  if n < 4 then
    return
  end
  local rank = nx_int(arg[1])
  local kill = nx_int(arg[2])
  local is_get_prize = nx_int(arg[3])
  local can_see = nx_int(arg[4])
  form.lbl_score.Text = nx_widestr(rank)
  form.lbl_time_hour.Text = nx_widestr(kill)
  form.cbtn_box.Enabled = is_get_prize == nx_int(0)
  form.cbtn_box.Checked = false
  form.btn_see.Enabled = can_see > nx_int(0)
  form.lbl_2.Visible = form.btn_see.Enabled
  if rank == nx_int(1) then
    nx_execute(RANK1_FORM_NAME, "open_form")
  else
    nx_execute(RANK1_FORM_NAME, "close_form")
  end
end
function l(info)
  nx_msgbox(nx_string(info))
end
function get_form()
  local form = nx_value(FORM_NAME)
  return form
end
