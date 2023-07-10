require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_small_game\\form_game_balance"
local timelimit = 0
local formtimelimit = 0
local basespeed = 0
local minspeed = 0
local clickspeed = 0
local speedadd = 0
local speedrate = 0
local ballx = 0
local bally = 0
local ballwidth = 0
local ballheight = 0
local ballback = ""
local basex = 0
local basey = 0
local basewidth = 0
local baseheight = 0
local baseback = ""
local xinfa_backImage = {}
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.Left = (gui.Width - self.Width) / 2
    self.Top = (gui.Height - self.Height) / 2
  end
  self.is_start = false
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_update_form_time", self, -1, -1)
end
function on_update_form_time(form)
  if nx_int(form.formtimelimit) == nx_int(0) then
    close_form()
    return
  end
  form.formtimelimit = nx_widestr(nx_int(form.formtimelimit) - 1)
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", self)
    timer:UnRegister(nx_current(), "on_balance_time", self)
    timer:UnRegister(nx_current(), "on_update_form_time", self)
  end
  local ret = check_result()
  nx_execute("custom_sender", "custom_ancient_tomb_sender", 1, nx_int(ret))
  nx_destroy(self)
end
function open_form_by_diff(diff)
  if load_resource(diff) == false then
    return
  end
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  init_form()
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_start_click(btn)
  btn.ParentForm.is_start = 1
  local form = btn.ParentForm
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_update_time", form, -1, -1)
  btn.Visible = false
  form.speed = basespeed
  form.old_speed = form.speed
  timer:Register(100, -1, nx_current(), "on_balance_time", form, -1, -1)
end
function on_update_time(form)
  if nx_int(form.lbl_time.Text) == nx_int(0) then
    close_form()
    return
  end
  form.lbl_time.Text = nx_widestr(nx_int(form.lbl_time.Text) - 1)
  form.pbar_1.Value = nx_int(form.lbl_time.Text)
end
function on_balance_time(form)
  if form.speed < minspeed and form.speed >= 0 then
    form.speed = minspeed
  end
  if form.speed < 0 and form.speed > -minspeed then
    form.speed = -minspeed
  end
  if form.old_speed == form.speed then
    form.speed = form.speed * (100 + speedrate) / 100
  end
  form.lbl_ball.Left = form.lbl_ball.Left + form.speed
  if form.lbl_ball.Left <= form.lbl_base.Left or form.lbl_ball.Left + ballwidth >= form.lbl_base.Left + basewidth then
    close_form()
    return
  end
  form.old_speed = form.speed
end
function on_btn_close_click(btn)
  close_form()
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  local old_speed = form.speed
  form.speed = form.speed - clickspeed
  if old_speed >= minspeed and form.speed < minspeed then
    local ball_center = form.lbl_ball.Left + math.floor(form.lbl_ball.Width / 2)
    local base_center = form.lbl_base.Left + math.floor(form.lbl_base.Width / 2)
    form.speed = -math.floor(math.abs(ball_center - base_center) / speedadd)
  end
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  local old_speed = form.speed
  form.speed = form.speed + clickspeed
  if old_speed <= -minspeed and form.speed > -minspeed then
    local ball_center = math.floor(form.lbl_ball.Left + form.lbl_ball.Width / 2)
    local base_center = math.floor(form.lbl_base.Left + form.lbl_base.Width / 2)
    form.speed = math.floor(math.abs(ball_center - base_center) / speedadd)
  end
end
function load_resource(diff)
  local ini = get_ini("share\\Life\\BalanceGame.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local sec_index = ini:FindSectionIndex(nx_string(diff))
  if sec_index < 0 then
    return false
  end
  timelimit = ini:ReadInteger(sec_index, "timelimit", 0)
  formtimelimit = ini:ReadInteger(sec_index, "formtimelimit", 0)
  basespeed = ini:ReadInteger(sec_index, "basespeed", 0)
  minspeed = ini:ReadInteger(sec_index, "minspeed", 0)
  clickspeed = ini:ReadInteger(sec_index, "clickspeed", 0)
  speedadd = ini:ReadInteger(sec_index, "speedadd", 0)
  speedrate = ini:ReadInteger(sec_index, "speedrate", 0)
  ballx = ini:ReadInteger(sec_index, "ballx", 0)
  bally = ini:ReadInteger(sec_index, "bally", 0)
  ballwidth = ini:ReadInteger(sec_index, "ballwidth", 0)
  ballheight = ini:ReadInteger(sec_index, "ballheight", 0)
  ballback = ini:ReadString(sec_index, "ballback", "")
  basex = ini:ReadInteger(sec_index, "basex", 0)
  basey = ini:ReadInteger(sec_index, "basey", 0)
  basewidth = ini:ReadInteger(sec_index, "basewidth", 0)
  baseheight = ini:ReadInteger(sec_index, "baseheight", 0)
  baseback = ini:ReadString(sec_index, "baseback", "")
  xinfa_backImage = {}
  local strbackimage = ini:ReadString(sec_index, "xinfaback", "")
  xinfa_backImage = util_split_string(nx_string(strbackimage), ",")
  return true
end
function init_form()
  init()
  create_ball()
  init_bind_callback()
end
function init_bind_callback()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  nx_bind_script(form.btn_close, nx_current())
  nx_callback(form.btn_close, "on_click", "on_btn_close_click")
  nx_bind_script(form.btn_start, nx_current())
  nx_callback(form.btn_start, "on_click", "on_btn_start_click")
  nx_bind_script(form.btn_left, nx_current())
  nx_callback(form.btn_left, "on_click", "on_btn_left_click")
  nx_bind_script(form.btn_right, nx_current())
  nx_callback(form.btn_right, "on_click", "on_btn_right_click")
end
function init()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local index = math.random(table.getn(xinfa_backImage))
  form.lbl_4.BackImage = xinfa_backImage[index]
  form.lbl_time.Text = nx_widestr(timelimit)
  form.formtimelimit = formtimelimit
  form.pbar_1.Maximum = timelimit
  form.pbar_1.Minimum = 0
  form.pbar_1.Value = timelimit
end
function create_ball()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local base = gui:Create("Label")
  base.Left = basex
  base.Top = basey
  base.Width = basewidth
  base.Height = baseheight
  base.DrawMode = "FitWindow"
  base.BackImage = baseback
  form.groupbox_main:Add(base)
  form.lbl_base = base
  local ball = gui:Create("Label")
  ball.Left = ballx
  ball.Top = bally
  ball.Width = ballwidth
  ball.Height = ballheight
  ball.DrawMode = "FitWindow"
  ball.BackImage = ballback
  form.groupbox_main:Add(ball)
  form.lbl_ball = ball
end
function check_result()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.lbl_time.Text) == nx_int(0) then
    return 1
  end
  return 0
end
function custom_sender(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(773), unpack(arg))
end
