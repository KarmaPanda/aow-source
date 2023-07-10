require("util_gui")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_sworn\\form_sworn_jinlanpu"
function form_main_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_update_time", form, -1, -1)
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", form)
  end
  nx_destroy(form)
  nx_execute("form_stage_main\\form_sworn\\form_sworn_jinlanpu_question", "close_form")
end
function on_update_time(form)
  if nx_int(form.lbl_time.Text) <= nx_int(0) then
    on_btn_start_click(form.btn_start)
    return
  end
  form.lbl_time.Text = nx_widestr(nx_int(form.lbl_time.Text) - nx_int(1))
end
function on_btn_close_click(btn)
  close_form()
end
function on_btn_start_click(btn)
  nx_execute("custom_sender", "custom_sworn", 1)
  form.groupbox_start.Visible = false
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", form)
  end
end
function open_form(...)
  form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  local is_leader = nx_int(arg[1])
  if is_leader == nx_int(1) then
    form.groupbox_start.Visible = true
  end
  local member_list = util_split_wstring(nx_widestr(arg[2]), ",")
  for i = 1, table.getn(member_list) do
    if nx_widestr(member_list[i]) ~= nx_widestr("") then
      local lbl = form.groupbox_1:Find("lbl_player_" .. nx_string(i))
      if nx_is_valid(lbl) then
        lbl.Text = nx_widestr(member_list[i])
      end
    end
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local self_name = client_player:QueryProp("Name")
  form.lbl_player_self.Text = nx_widestr(self_name)
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return ""
  end
  local date_time = msg_delay:GetServerDateTime()
  local year, month, day, hour, mins, sec = nx_function("ext_decode_date", date_time)
  form.lbl_year.Text = nx_widestr(year)
  form.lbl_month.Text = nx_widestr(month)
  form.lbl_day.Text = nx_widestr(day)
  if nx_int(client_player:QueryProp("Sex")) == nx_int(1) then
    form.lbl_sear.BackImage = "gui\\special\\sworn\\sworn_jlp_synv.png"
  else
    form.lbl_sear.BackImage = "gui\\special\\sworn\\sworn_jlp_synan.png"
  end
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
