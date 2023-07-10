require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_small_game\\form_game_bee"
local timelimit = 0
local formtimelimit = 0
local back = ""
local btnnormalred = ""
local btnfocusred = ""
local btnpushred = ""
local btnnormalgreen = ""
local btnfocusgreen = ""
local btnpushgreen = ""
local btntime = 0
local liferight = ""
local lifewrong = ""
local rate = 0
local losenum = 0
local lifepos = {}
local lifewidth = 0
local lifeheight = 0
local btnpos = {}
local btnwidth = 0
local btnheight = 0
local lifelist = {}
local btnlist = {}
local last_btn
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
    timer:UnRegister(nx_current(), "on_next_btn_time", self)
    timer:UnRegister(nx_current(), "on_update_form_time", self)
  end
  local ret = check_result()
  if self.is_start == false then
    ret = 0
  end
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
  form.lifenum = nx_int(table.getn(lifelist))
  init_form()
  form.Visible = true
  form:Show()
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
function close_form_force()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form.is_start = false
    form:Close()
  end
end
function on_btn_start_click(btn)
  btn.ParentForm.is_start = 1
  local form = btn.ParentForm
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_update_time", form, -1, -1)
  btn.Visible = false
  start_bee()
end
function on_btn_close_click(btn)
  btn.ParentForm.is_start = false
  close_form()
end
function on_btn_ok_click(btn)
  close_form()
end
function on_btn_click(btn)
  btn.Visible = false
  if btn.NormalImage == btnnormalgreen then
    lifelist[table.getn(lifelist)].BackImage = lifewrong
    table.remove(lifelist, table.getn(lifelist))
    btn.ParentForm.lifenum = nx_int(btn.ParentForm.lifenum) - nx_int(1)
    if nx_number(table.getn(lifelist)) <= nx_number(0) then
      close_form()
    end
  end
end
function on_update_time(form)
  if nx_int(form.lbl_time.Text) == nx_int(0) then
    close_form()
    return
  end
  form.lbl_time.Text = nx_widestr(nx_int(form.lbl_time.Text) - 1)
  form.pbar_1.Value = nx_int(form.lbl_time.Text)
end
function on_next_btn_time(form)
  local btn = last_btn
  if not nx_is_valid(btn) then
    return
  end
  if btn.NormalImage == btnnormalred and btn.Visible == true then
    lifelist[table.getn(lifelist)].BackImage = lifewrong
    table.remove(lifelist, table.getn(lifelist))
    btn.ParentForm.lifenum = nx_int(btn.ParentForm.lifenum) - nx_int(1)
    if nx_number(table.getn(lifelist)) <= nx_number(0) then
      close_form()
      return
    end
  end
  btn.Visible = false
  form.index = form.index + 1
  show_bee_btn(form.index)
end
function load_resource(diff)
  local ini = get_ini("share\\Life\\BeeGame.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local sec_index = ini:FindSectionIndex(nx_string(diff))
  if sec_index < 0 then
    return false
  end
  timelimit = ini:ReadInteger(sec_index, "timelimit", 0)
  formtimelimit = ini:ReadInteger(sec_index, "formtimelimit", 0)
  back = ini:ReadString(sec_index, "back", "")
  btnnormalred = ini:ReadString(sec_index, "btnnormalred", "")
  btnfocusred = ini:ReadString(sec_index, "btnfocusred", "")
  btnpushred = ini:ReadString(sec_index, "btnpushred", "")
  btnnormalgreen = ini:ReadString(sec_index, "btnnormalgreen", "")
  btnfocusgreen = ini:ReadString(sec_index, "btnfocusgreen", "")
  btnpushgreen = ini:ReadString(sec_index, "btnpushgreen", "")
  btntime = ini:ReadInteger(sec_index, "btntime", 0)
  liferight = ini:ReadString(sec_index, "liferight", "")
  lifewrong = ini:ReadString(sec_index, "lifewrong", "")
  rate = ini:ReadInteger(sec_index, "rate", 0)
  losenum = ini:ReadInteger(sec_index, "losenum", 0)
  lifewidth = ini:ReadInteger(sec_index, "lifewidth", 0)
  lifeheight = ini:ReadInteger(sec_index, "lifeheight", 0)
  btnwidth = ini:ReadInteger(sec_index, "btnwidth", 0)
  btnheight = ini:ReadInteger(sec_index, "btnheight", 0)
  local lifestr = ini:ReadString(sec_index, "lifepos", "")
  lifepos = {}
  lifepos = util_split_string(nx_string(lifestr), ";")
  local btnstr = ini:ReadString(sec_index, "btnpos", "")
  btnpos = {}
  btnpos = util_split_string(nx_string(btnstr), ";")
  return true
end
function init_form()
  init_time()
  init_back_and_life()
  init_bee_btn()
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
end
function init_time()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_time.Text = nx_widestr(timelimit)
  form.formtimelimit = formtimelimit
  form.pbar_1.Maximum = timelimit
  form.pbar_1.Minimum = 0
  form.pbar_1.Value = timelimit
end
function init_back_and_life()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_back.BackImage = back
  lifelist = {}
  for i = 1, table.getn(lifepos) do
    local pos = util_split_string(lifepos[i], ",")
    if nx_int(table.getn(pos)) == nx_int(0) then
      break
    end
    local x = nx_int(pos[1])
    local y = nx_int(pos[2])
    local gui = nx_value("gui")
    local lbl = gui:Create("Label")
    lbl.Left = x
    lbl.Top = y
    lbl.Width = lifewidth
    lbl.Height = lifeheight
    lbl.DrawMode = FitWindow
    lbl.BackImage = liferight
    form.groupbox_main:Add(lbl)
    table.insert(lifelist, lbl)
  end
  form.lifenum = nx_int(table.getn(lifelist))
  if nx_int(table.getn(lifelist)) == nx_int(0) then
    close_form()
  end
end
function init_bee_btn()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  btnlist = {}
  for i = 1, table.getn(btnpos) do
    local pos = util_split_string(btnpos[i], ",")
    if nx_int(table.getn(pos)) == nx_int(0) then
      break
    end
    local x = nx_int(pos[1])
    local y = nx_int(pos[2])
    local gui = nx_value("gui")
    local btn = gui:Create("Button")
    btn.Left = x
    btn.Top = y
    btn.Width = btnwidth
    btn.Height = btnheight
    btn.DrawMode = FitWindow
    btn.Visible = false
    nx_bind_script(btn, nx_current())
    nx_callback(btn, "on_click", "on_btn_click")
    form.groupbox_main:Add(btn)
    table.insert(btnlist, btn)
  end
end
function start_bee()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  form.index = 1
  show_bee_btn(1)
end
function show_bee_btn(index)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local real_index = (index - 1) % table.getn(btnlist) + 1
  local btn = btnlist[real_index]
  local rand = math.random(1, 100)
  if nx_int(rand) <= nx_int(rate) then
    btn.NormalImage = btnnormalgreen
    btn.FocusImage = btnfocusgreen
    btn.PushImage = btnpushgreen
  else
    btn.NormalImage = btnnormalred
    btn.FocusImage = btnfocusred
    btn.PushImage = btnpushred
  end
  btn.Visible = true
  last_btn = btn
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_next_btn_time", form)
  timer:Register(nx_int(btntime) * 1000, -1, nx_current(), "on_next_btn_time", form, -1, -1)
end
function check_result()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return 0
  end
  if nx_int(form.lifenum) == nx_int(0) then
    return 0
  end
  return 1
end
function custom_sender(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(773), unpack(arg))
end
