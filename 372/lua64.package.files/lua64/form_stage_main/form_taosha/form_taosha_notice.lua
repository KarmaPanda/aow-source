require("util_gui")
require("util_functions")
require("util_static_data")
require("define\\sysinfo_define")
require("custom_sender")
require("form_stage_main\\form_taosha\\taosha_util")
local FORM_NAME = "form_stage_main\\form_taosha\\form_taosha_notice"
function open_form(...)
  local form = get_form()
  if not nx_is_valid(form) then
    util_show_form(FORM_NAME, true)
  end
  receive_ui(unpack(arg))
  nx_execute("form_stage_main\\form_taosha\\form_taosha_main", "hide_handle")
end
function request_open_form()
  request_ui()
end
function close_form()
  local form = get_form()
  if nx_is_valid(form) then
    form:Close()
  end
end
local array_event = {}
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.AbsLeft = gui.Width - form.Width * 1.3
    form.AbsTop = (gui.Height - form.Height) / 2
  end
  clear()
  form.original_width = form.Width
  form.original_height = form.Height
  form.lbl_4.original_top = form.lbl_4.Top
  form.lbl_5.original_top = form.lbl_5.Top
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  stop_timer()
  nx_destroy(form)
end
function on_btn_quit_click(btn)
  local ok = request_quit()
  if ok then
    close_form()
  end
end
function on_btn_stopsee_click(btn)
  nx_execute("form_stage_main\\form_taosha\\form_taosha_awards", "request_open_ui")
  nx_execute("form_stage_main\\form_taosha\\taosha_util", "clear_see_state")
  btn.Visible = false
end
function on_btn_minimum_click(btn)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_main\\form_main_map", "show_taosha_ctrl")
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    local player = get_player()
    if not nx_is_valid(player) then
      return
    end
    form.original_center_x = get_center_x(form)
    form.original_center_y = get_center_y(form)
    form.start_minimum_time = os.clock()
    timer:UnRegister(nx_current(), "timer_minimum", player)
    timer:Register(1, -1, nx_current(), "timer_minimum", player, -1, -1)
  end
end
function request_ui()
  custom_taosha(nx_int(109))
end
function request_quit()
  confirm_quit()
end
function receive_ui(...)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local n = #arg
  if n < 7 then
    return
  end
  local war_step = nx_int(arg[1])
  local sub_step = nx_int(arg[2])
  local live = nx_int(arg[3])
  local all = nx_int(arg[4])
  local kill = nx_int(arg[5])
  local rank = nx_int(arg[6])
  clear()
  form.remain_seconds = nx_number(arg[7])
  form.Height = form.original_height
  form.lbl_4.Top = form.lbl_4.original_top
  form.lbl_5.Top = form.lbl_5.original_top
  form.lbl_3.Text = get_step_name(war_step, sub_step)
  form.lbl_4.Text = get_timer_name(war_step, sub_step)
  if war_step == nx_int(1) then
    form.lbl_6.Text = util_format_string("ui_taosha_1")
    form.lbl_4.Top = form.lbl_6.Top + form.lbl_6.Height + 10
    form.lbl_5.Top = form.lbl_4.Top + form.lbl_4.Height + 10
    form.Height = form.original_height - 25
  elseif war_step == nx_int(2) or war_step == nx_int(3) then
    form.lbl_8.Visible = true
    form.lbl_9.Visible = true
    form.lbl_6.Text = util_format_string("ui_taosha_2")
    if war_step == nx_int(2) and sub_step == nx_int(2) then
      form.lbl_10.Visible = true
      form.lbl_4.Top = form.lbl_10.Top + form.lbl_10.Height + 10
      form.lbl_5.Top = form.lbl_4.Top + form.lbl_4.Height + 10
      form.Height = form.original_height + 32
    end
  end
  form.lbl_7.Text = util_format_string("ui_taosha_0", live, all)
  form.lbl_9.Text = util_format_string("ui_taosha_6", kill)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "timer_update_time", player)
    timer:Register(1000, -1, nx_current(), "timer_update_time", player, -1, -1)
  end
  form.btn_stopsee.Visible = nx_execute("form_stage_main\\form_taosha\\see_util", "is_see")
  local event_index = 1
  for i = 8, n, 2 do
    if n < i + 1 then
      break
    end
    local event_id = nx_string(arg[i])
    local event_remain_time = nx_int(arg[i + 1])
    show_special_event(event_index, event_id, event_remain_time)
    event_index = event_index + 1
  end
  show_time()
end
function l(info)
  nx_msgbox(nx_string(info))
end
function get_form()
  local form = nx_value(FORM_NAME)
  return form
end
function get_main_map_form()
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  return form
end
function timer_update_time()
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  form.remain_seconds = form.remain_seconds - 1
  local n = #array_event
  for i = 1, n do
    local event = array_event[i]
    local event_remain_time = nx_int(event.event_remain_time)
    event.event_remain_time = event_remain_time - nx_int(1)
  end
  show_time()
end
function show_time()
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  form.lbl_5.Text = get_format_time_text(form.remain_seconds)
  local n = #array_event
  for i = 1, n do
    local event = array_event[i]
    local event_box = event.event_box
    if nx_is_valid(event_box) then
      local event_remain_time = nx_int(event.event_remain_time)
      event_box.lbl_time.Text = get_format_time_text(event_remain_time)
    end
  end
end
function stop_timer()
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "timer_update_time", player)
    timer:UnRegister(nx_current(), "timer_minimum", player)
  end
end
function get_format_time_text(time)
  time = nx_number(time)
  if nx_number(time) <= 0 then
    time = 0
  end
  local format_time = nx_widestr("")
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
  return nx_widestr(format_time)
end
function get_timer_name(war_step, sub_step)
  local tip_id = ""
  if war_step == nx_int(1) then
    tip_id = "ui_taosha_3"
  elseif war_step == nx_int(2) then
    if sub_step == nx_int(1) then
      tip_id = "ui_taosha_4"
    elseif sub_step == nx_int(2) then
      tip_id = "ui_taosha_7"
    end
  elseif war_step == nx_int(3) then
    tip_id = "ui_taosha_5"
  end
  local timer_name = nx_widestr(util_format_string(tip_id))
  return timer_name
end
function get_step_name(war_step, sub_step)
  local tip_id = ""
  if war_step == nx_int(1) then
    tip_id = "ui_th_zb"
  elseif war_step == nx_int(2) then
    if sub_step == nx_int(1) then
      tip_id = "ui_th_fight_001"
    elseif sub_step == nx_int(2) then
      tip_id = "ui_th_fight_002"
    end
  elseif war_step == nx_int(3) then
    tip_id = "ui_th_fight_003"
  end
  local step_name = nx_widestr(util_format_string(tip_id))
  return step_name
end
function clear()
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  form.remain_seconds = 0
  form.lbl_7.Text = nx_widestr("")
  form.lbl_8.Visible = false
  form.lbl_9.Visible = false
  form.lbl_10.Visible = false
  form.btn_stopsee.Visible = false
  clear_special_event()
end
function show_stopsee_btn()
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  form.btn_stopsee.Visible = true
end
function clone(old_control, new_name)
  local gui = nx_value("gui")
  local copy = gui.Designer:Clone(old_control)
  if nx_is_valid(copy) then
    local child_list = old_control:GetChildControlList()
    for _, old_child in pairs(child_list) do
      if nx_is_valid(old_child) then
        local new_child = gui.Designer:Clone(old_child)
        new_child.fatherctl = new_control
        new_child.DesignMode = false
        new_child.Name = old_child.Name
        new_child.aid = aid
        copy:Add(new_child)
      end
    end
    copy.Name = nx_string(new_name)
    nx_bind_script(copy, nx_current())
    return copy
  end
end
function clear_special_event()
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  local n = #array_event
  for i = 1, n do
    local event = array_event[i]
    local event_box = event.event_box
    if nx_is_valid(event_box) then
      form:Remove(event_box)
    end
  end
  form.groupbox_1.Visible = false
  array_event = {}
end
function show_special_event(event_index, event_id, event_remain_time)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  local shot_text = util_format_string(nx_string("ui_dataosha_") .. nx_string(event_id))
  local long_text = util_format_string(nx_string("tip_dataosha_") .. nx_string(event_id))
  local be_copy = form.groupbox_1
  local copy = clone(be_copy, nx_widestr(event_id))
  copy.Top = form.lbl_5.Top + form.lbl_5.Height + 10 + (event_index - 1) * 25
  copy.Left = be_copy.Left
  copy.lbl_time = copy:Find("lbl_time")
  copy.lbl_daojishi = copy:Find("lbl_daojishi")
  copy.lbl_daojishi.Text = shot_text
  copy.lbl_daojishi.HintText = long_text
  copy.Visible = true
  form:Add(copy)
  form:ToFront(copy)
  local event = {}
  event.event_id = nx_widestr(event_id)
  event.event_remain_time = nx_int(event_remain_time)
  event.event_box = copy
  table.insert(array_event, event)
  form.Height = copy.Top + copy.Height + 38
end
function get_center_x(control)
  return control.AbsLeft + control.Width / 2
end
function get_center_y(control)
  return control.AbsTop + control.Height / 2
end
function set_center(control, x, y)
  control.AbsLeft = x - control.Width / 2
  control.AbsTop = y - control.Height / 2
end
function timer_minimum()
  local form = get_form()
  local main_map_form = get_main_map_form()
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(main_map_form) then
    return
  end
  local MinumumTime = 300
  local now = os.clock()
  local pass = (now - form.start_minimum_time) * 1000
  local percent = pass / MinumumTime
  local is_end = MinumumTime < pass
  if is_end then
    close_form()
    return
  end
  local final_width = main_map_form.btn_taosha.Width / 2
  local final_height = main_map_form.btn_taosha.Height / 2
  form.Width = form.original_width + (final_width - form.original_width) * percent
  form.Height = form.original_height + (final_height - form.original_height) * percent
  local final_x = get_center_x(main_map_form.btn_taosha)
  local final_y = get_center_y(main_map_form.btn_taosha)
  local x = form.original_center_x + (final_x - form.original_center_x) * percent
  local y = form.original_center_y + (final_y - form.original_center_y) * percent
  set_center(form, x, y)
end
