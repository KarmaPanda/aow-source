require("util_functions")
require("share\\client_custom_define")
require("form_stage_main\\form_home\\form_home_msg")
local FT_OpenFrom = 0
local FT_CloseForm = 1
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = self.Width
  self.AbsTop = self.Height / 4
end
function on_main_form_close(self)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", self)
    timer:UnRegister(nx_current(), "on_delay_show_form_time", self)
  end
  nx_destroy(self)
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_home\\form_ceaseb_meun", false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_quit_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HOME), nx_int(CLIENT_SUB_INTER_BUILDING))
  end
end
function show_form(gotten_faculty, total_faculty, per_nums, total_gain, rest_time)
  local form_cease_menu = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_home\\form_ceaseb_meun", true, false)
  if not nx_is_valid(form_cease_menu) then
    return
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    gui.Desktop:ToFront(form_cease_menu)
  end
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  if nx_number(rest_time) > 0 then
    form_cease_menu.rest_time = nx_number(rest_time)
  end
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
    timer:UnRegister(nx_current(), "on_delay_show_form_time", form_cease_menu)
    timer:Register(2000, -1, nx_current(), "on_delay_show_form_time", form_cease_menu, -1, -1)
  else
    form_cease_menu:Show()
  end
  form_cease_menu.pbar_1.Value = nx_int(gotten_faculty / total_faculty * 100)
  local text = string.format("%d/%d", nx_number(gotten_faculty), nx_number(total_faculty))
  form_cease_menu.lbl_faculty.Text = nx_widestr(text)
  if nx_find_custom(form_cease_menu, "rest_time") and 0 < nx_number(form_cease_menu.rest_time) then
    timer:UnRegister(nx_current(), "on_update_time", form_cease_menu)
    timer:Register(1000, -1, nx_current(), "on_update_time", form_cease_menu, -1, -1)
  end
  on_update_time(form_cease_menu)
  gui.TextManager:Format_SetIDName("ui_inter_num")
  gui.TextManager:Format_AddParam(nx_int(per_nums))
  gui.TextManager:Format_AddParam(nx_int(total_gain))
  local text = gui.TextManager:Format_GetText()
  form_cease_menu.lbl_gain:Clear()
  form_cease_menu.lbl_gain:AddHtmlText(nx_widestr(text), -1)
end
function on_update_time(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "rest_time") then
    return
  end
  local rest_time = nx_number(form.rest_time)
  if rest_time <= 0 then
    return
  end
  local time = get_format_time_text(rest_time)
  form.lbl_lefttime.Text = nx_widestr(time)
  form.rest_time = rest_time - 1
end
function on_delay_show_form_time(form)
  if not nx_is_valid(form) then
    return
  end
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
    return
  end
  form:Show()
  local delay_timer = nx_value("timer_game")
  delay_timer:UnRegister(nx_current(), "on_delay_show_form_time", form)
end
function get_format_time_text(time)
  local format_time = ""
  if nx_number(time) >= 3600 then
    local hour = nx_int(time / 3600)
    local min = nx_int(math.mod(time, 3600) / 60)
    local sec = nx_int(math.mod(math.mod(time, 3600), 60))
    format_time = string.format("%02d:%02d:%02d", nx_number(hour), nx_number(min), nx_number(sec))
  elseif nx_number(time) >= 60 then
    local min = nx_int(time / 60)
    local sec = nx_int(math.mod(time, 60))
    format_time = string.format("%02d:%02d", nx_number(min), nx_number(sec))
  else
    local sec = nx_int(time)
    format_time = string.format("00:%02d", nx_number(sec))
  end
  return nx_string(format_time)
end
function on_server_msg(op_type, ...)
  if nx_int(op_type) == nx_int(FT_OpenFrom) then
    show_form(unpack(arg))
  elseif nx_int(op_type) == nx_int(FT_CloseForm) then
    close_form()
  end
end
