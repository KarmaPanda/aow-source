require("utils")
require("util_gui")
require("const_define")
require("custom_sender")
local FORM_MAIN_SELECT = "form_stage_main\\form_main\\form_main_select"
local FORM_MAIN_BUFF = "form_stage_main\\form_main\\form_main_buff"
local FORM_BATTLEFIELD_TRACE = "form_stage_main\\form_battlefield\\form_battlefield_trace"
local PHOTO_TAB = {
  "gui\\language\\ChineseS\\battlefield\\battle_hz.png",
  "gui\\language\\ChineseS\\battlefield\\battle_zw.png"
}
local BOUT_IMAGE_TAB = {
  "gui\\language\\ChineseS\\battlefield\\battle_d1.png",
  "gui\\language\\ChineseS\\battlefield\\battle_d2.png",
  "gui\\language\\ChineseS\\battlefield\\battle_d3.png",
  "gui\\language\\ChineseS\\battlefield\\battle_d4.png",
  "gui\\language\\ChineseS\\battlefield\\battle_d5.png",
  "gui\\language\\ChineseS\\battlefield\\battle_d6.png",
  "gui\\language\\ChineseS\\battlefield\\battle_d7.png",
  "gui\\language\\ChineseS\\battlefield\\battle_d8.png",
  "gui\\language\\ChineseS\\battlefield\\battle_d9.png"
}
local control_inarena_close_table = {}
local arena_form_table = {
  "form_stage_main\\form_battlefield\\form_battlefield_trace",
  "form_stage_main\\form_battlefield\\form_battlefield_score",
  "form_stage_main\\form_main\\form_main_buff",
  "form_stage_main\\form_main\\form_main_select",
  "form_stage_main\\form_main\\form_main_player",
  "form_stage_main\\form_main\\form_main_team",
  "form_stage_main\\form_main\\form_main_shortcut",
  "form_stage_main\\form_main\\form_notice_shortcut",
  "form_stage_main\\form_main\\form_main_sysinfo",
  "form_stage_main\\form_main\\form_main_chat",
  "form_stage_main\\form_common_notice",
  "form_stage_main\\form_main\\form_main_func_btns"
}
function main_form_init(self)
  self.Fixed = true
  self.time = 0
end
function on_main_form_open(self)
  self.lbl_damage_self.Text = nx_widestr("")
  self.lbl_damage_other.Text = nx_widestr("")
  hide_other_form()
  on_size_change()
end
function on_main_form_close(self)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "refresh_count_down_time", self)
  end
  nx_destroy(self)
end
function on_main_form_shut(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  show_other_form()
  local form_main_select = nx_value(FORM_MAIN_SELECT)
  if nx_is_valid(form_main_select) then
    form_main_select.Left = -form_main_select.Width / 2
  end
  local form_main_buff = nx_value(FORM_MAIN_BUFF)
  if nx_is_valid(form_main_buff) then
    form_main_buff.Top = 0
    form_main_buff.Left = gui.Width - form_main_buff.Width - 200
  end
end
function on_size_change()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local form = nx_value(FORM_BATTLEFIELD_TRACE)
  if nx_is_valid(form) then
    form.AbsTop = 0
    form.AbsLeft = 0
    form.Width = gui.Desktop.Width
    form.Height = gui.Desktop.Height
    local form_main_select = nx_value(FORM_MAIN_SELECT)
    if nx_is_valid(form_main_select) then
      form_main_select.Left = gui.Desktop.Width / 2 - form_main_select.Width + 60
    end
    local form_main_buff = nx_value(FORM_MAIN_BUFF)
    if nx_is_valid(form_main_buff) then
      form_main_buff.Left = 120
      form_main_buff.Top = 80
    end
  end
end
function close_wrestle_flow()
  local form = util_get_form(FORM_BATTLEFIELD_TRACE, false)
  if not nx_is_valid(form) then
    return 0
  end
  form:Close()
end
function refresh_wrestle_flow(type, ...)
  local form = util_get_form(FORM_BATTLEFIELD_TRACE, true)
  if not nx_is_valid(form) then
    return 0
  end
  local arg_count = table.getn(arg)
  if type == 1 then
    if arg_count < 3 then
      return 0
    end
    form.time = nx_number(arg[1])
    form.lbl_text.BackImage = ""
    form.lbl_text.Text = util_text("ui_arena_main_1")
    form.lbl_time.Text = nx_widestr(form.time)
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "refresh_count_down_time", form)
      timer:Register(1000, -1, nx_current(), "refresh_count_down_time", form, -1, -1)
    end
    local player_name = get_player_prop("Name")
    if nx_widestr(player_name) == nx_widestr(arg[2]) or nx_widestr(player_name) == nx_widestr(arg[3]) then
      form.ani_reandy:Stop()
      form.ani_reandy:Play()
    end
  elseif type == 2 then
    if arg_count < 2 then
      return 0
    end
    form.time = nx_number(arg[2])
    if 0 < nx_number(arg[1]) and nx_number(arg[1]) <= table.getn(BOUT_IMAGE_TAB) then
      form.lbl_text.BackImage = BOUT_IMAGE_TAB[nx_number(arg[1])]
    else
      form.lbl_text.BackImage = ""
    end
    form.lbl_text.Text = nx_widestr("")
    form.lbl_time.Text = nx_widestr(form.time)
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "refresh_count_down_time", form)
      timer:Register(1000, -1, nx_current(), "refresh_count_down_time", form, -1, -1)
    end
  elseif type == 3 then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "refresh_count_down_time", form)
    end
  elseif type == 4 then
    if arg_count < 1 then
      return 0
    end
    form.time = nx_number(arg[1])
    form.lbl_text.BackImage = ""
    form.lbl_text.Text = util_text("ui_battlefield_close")
    form.lbl_time.Text = nx_widestr(form.time)
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "refresh_count_down_time", form)
      timer:Register(1000, -1, nx_current(), "refresh_count_down_time", form, -1, -1)
    end
  end
  util_show_form(FORM_BATTLEFIELD_TRACE, true)
  return 1
end
function refresh_wrestle_player_num(...)
  local form = util_get_form(FORM_BATTLEFIELD_TRACE, true)
  if not nx_is_valid(form) then
    return 0
  end
  if table.getn(arg) < 4 then
    return 0
  end
  local self_total_count = nx_number(arg[1])
  local self_leave_count = nx_number(arg[2])
  local other_total_count = nx_number(arg[3])
  local other_leave_count = nx_number(arg[4])
  form.grid_player_self:Clear()
  local clomn_num = form.grid_player_self.ClomnNum
  for i = 1, self_total_count do
    if i <= self_leave_count then
      form.grid_player_self:AddItem(nx_int(clomn_num - self_total_count + i - 1), PHOTO_TAB[1], "", 1, -1)
    else
      form.grid_player_self:AddItem(nx_int(clomn_num - self_total_count + i - 1), PHOTO_TAB[2], "", 1, -1)
    end
  end
  form.grid_player_other:Clear()
  for i = 1, other_total_count do
    if i <= other_leave_count then
      form.grid_player_other:AddItem(nx_int(other_total_count - i), PHOTO_TAB[1], "", 1, -1)
    else
      form.grid_player_other:AddItem(nx_int(other_total_count - i), PHOTO_TAB[2], "", 1, -1)
    end
  end
  util_show_form(FORM_BATTLEFIELD_TRACE, true)
  return 1
end
function refresh_wrestle_damage(...)
  local form = util_get_form(FORM_BATTLEFIELD_TRACE, false)
  if not nx_is_valid(form) then
    return 0
  end
  if table.getn(arg) < 2 then
    return 0
  end
  form.lbl_damage_self.Text = nx_widestr(arg[1])
  form.lbl_damage_other.Text = nx_widestr(arg[2])
  return 1
end
function refresh_count_down_time(form)
  if not nx_is_valid(form) then
    return 0
  end
  if not nx_find_custom(form, "time") then
    return 0
  end
  local time = nx_number(form.time) - 1
  if time < 0 then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "refresh_count_down_time", form)
    end
    return 0
  end
  form.time = time
  form.lbl_time.Text = nx_widestr(time)
  return 1
end
function hide_other_form()
  local gui = nx_value("gui")
  local child_list = gui.Desktop:GetChildControlList()
  for i = table.maxn(child_list), 1, -1 do
    local control = child_list[i]
    if nx_is_valid(control) and control.Visible and not is_need_show_form(control) then
      control.Visible = false
      table.insert(control_inarena_close_table, control)
    end
  end
end
function show_other_form()
  local gui = nx_value("gui")
  for i = table.maxn(control_inarena_close_table), 1, -1 do
    local control = control_inarena_close_table[i]
    if nx_is_valid(control) then
      control.Visible = true
    end
  end
  control_inarena_close_table = {}
end
function is_need_show_form(form)
  if not nx_is_valid(form) then
    return false
  end
  local script = nx_script_name(form)
  for i, para in pairs(arena_form_table) do
    if script == para then
      return true
    end
  end
  return false
end
function get_player_prop(prop_name)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if not client_player:FindProp(nx_string(prop_name)) then
    return ""
  end
  return client_player:QueryProp(nx_string(prop_name))
end
