require("util_gui")
require("share\\client_custom_define")
local LEVELINFO = {
  [1] = "sanhill_level1",
  [2] = "sanhill_level2",
  [3] = "sanhill_level3",
  [4] = "sanhill_level4",
  [5] = "sanhill_level5",
  [6] = "sanhill_level6",
  [7] = "sanhill_level7",
  [8] = "sanhill_level8",
  [9] = "sanhill_level9",
  [10] = "sanhill_level10",
  [11] = "sanhill_level11",
  [12] = "sanhill_level12",
  [13] = "sanhill_level13",
  [14] = "sanhill_level14",
  [15] = "sanhill_level15",
  [16] = "sanhill_level16",
  [17] = "sanhill_level17",
  [18] = "sanhill_level18",
  [19] = "sanhill_level19",
  [20] = "sanhill_level20",
  [21] = "sanhill_level21",
  [22] = "sanhill_level22",
  [23] = "sanhill_level23",
  [24] = "sanhill_level24",
  [25] = "sanhill_level25",
  [26] = "sanhill_level26",
  [27] = "sanhill_level27",
  [28] = "sanhill_level28",
  [29] = "sanhill_level29",
  [30] = "sanhill_level30"
}
local FORM_NAME = "form_stage_main\\form_skyhill\\form_sanhill_fight"
local CLOSE_SEC = 30
function on_main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form_main) then
    return
  end
  form.Left = form_main.ani_sanhill_content.Left
  form.Top = form_main.ani_sanhill_content.Top
  nx_execute("custom_sender", "custom_sanhill_msg", 13)
end
function on_main_form_close(form)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "delay_close", form)
  nx_destroy(form)
end
function open_form(...)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local level = arg[1]
  local sur_time = arg[2]
  local dead_count = nx_int(arg[3])
  local content1 = arg[4]
  local content2 = arg[5]
  form.lbl_content1.Text = nx_widestr(gui.TextManager:GetText(nx_string(content1)))
  form.lbl_content2.Text = nx_widestr(gui.TextManager:GetText(nx_string(gui.TextManager:GetFormatText(content2, dead_count))))
  form.lbl_level.Text = nx_widestr(gui.TextManager:GetText(LEVELINFO[nx_number(level)]))
  form.lbl_surtime.Text = nx_widestr("")
end
function set_fighttimes(...)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  local sur_time = arg[1]
  form.remain_sec = sur_time
  form.lbl_surtime.Text = nx_widestr(format_time(form.remain_sec))
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "delay_close", form)
  timer:Register(1000, -1, nx_current(), "delay_close", form, -1, -1)
end
function on_btn_quit_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = gui.TextManager:GetText("ui_sanhill_isdolive")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_sanhill_msg", 5)
    form:Close()
  end
end
function delay_close(form)
  form.remain_sec = form.remain_sec - 1
  if form.remain_sec < 0 then
    local timer = nx_value("timer_game")
    timer:UnRegister(nx_current(), "delay_close", form)
    form:Close()
    return
  end
  form.lbl_surtime.Text = nx_widestr(format_time(form.remain_sec))
end
function format_time(sec)
  local minute = nx_int(nx_number(sec) / nx_number(60))
  local second = nx_int(nx_number(sec) - nx_number(minute) * nx_number(60))
  local str_min = nx_string(minute)
  if nx_int(minute) < nx_int(10) then
    str_min = "0" .. nx_string(minute)
  end
  local str_sec = nx_string(second)
  if nx_int(second) < nx_int(10) then
    str_sec = "0" .. nx_string(second)
  end
  local str_time = str_min .. ": " .. str_sec
  return str_time
end
