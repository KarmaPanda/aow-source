require("util_gui")
require("util_functions")
require("const_define")
require("share\\view_define")
require("game_object")
local CTS_STAR_GAME = 0
local CTS_CHANGE_FQ = 1
local CTS_CHANGE_VEl = 2
local CTS_CANCLE_GAME = 3
local CTS_FRISH_GAME = 4
local STC_StarGame = 0
local STC_FailGame = 1
local STC_WinGame = 2
local STC_MAINPOS = 3
local STC_OpenGame = 4
local SKILL_ID = "xjz_01"
local game_out = 0
local game_ing = 1
local oval_key = {
  a = 0,
  b = 0,
  cx = 0,
  cy = 0,
  a2 = 0,
  b2 = 0
}
local line_key = {
  k = 0,
  cx = 0,
  cy = 0
}
local cz_sx = {}
local frequency = {}
local game_lvs = {}
local BaseDate = {
  MainLong = 0,
  MainVel = 0,
  Maximum = 0,
  Minimum = 0,
  Ares = 0,
  Center = 0,
  LeftAddVel = 0,
  RightAddVel = 0
}
function main_form_init(self)
end
function InitGameDate(form)
  local ini_base = nx_execute("util_functions", "get_ini", "share\\Force\\JiaHuoDate.ini")
  if not nx_is_valid(ini_base) then
    nx_msgbox("not ini")
    return
  end
  local index = ini_base:FindSectionIndex("base_info")
  BaseDate.MainLong = ini_base:ReadInteger(index, "MainLong", 0)
  BaseDate.MainVel = ini_base:ReadInteger(index, "MainVel", 0)
  BaseDate.Maximum = ini_base:ReadInteger(index, "Maximum", 0)
  BaseDate.Minimum = ini_base:ReadInteger(index, "Minimum", 0)
  BaseDate.Ares = ini_base:ReadInteger(index, "Region_long", 0)
  BaseDate.Center = (BaseDate.Maximum - BaseDate.Minimum) / 2
  BaseDate.LeftAddVel = ini_base:ReadInteger(index, "Add", 0)
  BaseDate.RightAddVel = ini_base:ReadInteger(index, "Dec", 0)
  local str_frequency = ini_base:ReadString(index, "Frequency", "")
  frequency = util_split_string(str_frequency, ",")
  index = ini_base:FindSectionIndex("level_info")
  local str_level = ini_base:ReadString(index, "level", "")
  local str_socre = ini_base:ReadString(index, "Socre", "")
  local str_velbase = ini_base:ReadString(index, "VelBase", "")
  local level_list = util_split_string(str_level, ",")
  local socre_list = util_split_string(str_socre, ",")
  local velbase_list = util_split_string(str_velbase, ",")
  for i = 1, table.getn(level_list) do
    local nLevel = nx_number(level_list[i])
    local nSocre = nx_int(socre_list[i])
    local nVelBase = nx_float(velbase_list[i])
    game_lvs[nLevel] = {socre = nSocre, vel = nVelBase}
  end
  form.pebar_1.Maximun = BaseDate.Maximum - BaseDate.Minimum
  form.pebar_main.Maximum = BaseDate.MainLong
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.gamelevel = 1
  clear_game(self)
  InitGameDate(self)
  InitGameXZ(self)
  Init_yz(self)
  change_form_size()
  self.ani_vic1.Visible = false
  self.ani_vic1.Loop = false
  self.ani_vic2.Visible = false
  self.ani_vic2.Loop = false
  self.ani_lost1.Visible = false
  self.ani_lost1.Loop = false
  self.ani_lost2.Visible = false
  self.ani_lost2.Loop = false
end
function on_main_form_close(self)
  fail_game(self)
  if nx_is_valid(self) then
    nx_destroy(self)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function clear_game(self)
  self.state = game_out
  self.lasttime = 0
  self.pl_index = 1
  self.vel_base = 0
  self.vel_bs1 = 0
  self.vel_bs2 = 0
  self.pebar_main.Value = 0
  self.Value = 0
  self.count = 0
  self.pass_time = 0
end
function on_btn_star_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.state == nil then
    return
  end
  if form.state == game_ing then
    return
  end
  form.state = game_ing
  form.Value = BaseDate.Center
  local level = form.gamelevel
  form.vel_base = game_lvs[level].vel
  form.vel_bs1 = 1
  form.vel_bs2 = 0
  nx_execute("custom_sender", "custom_xjz_jh_game", CTS_STAR_GAME, level)
end
function run_game(form)
  form.count = form.count + 1
  if not nx_is_valid(form) then
    return
  end
  local xz = 1
  local now_time = os.clock()
  if form.lasttime ~= 0 then
    local pass_time = nx_int((now_time - form.lasttime) * 1000)
    form.pass_time = form.pass_time + pass_time
    local xz = pass_time / nx_int(frequency[form.pl_index])
  end
  form.lasttime = now_time
  local nVel = (form.vel_bs1 + form.vel_bs2 / 100) * form.vel_base
  form.Value = form.Value + nVel * xz
  form.lbl_val.Left, form.lbl_val.Top = GetPos1()
  form.pebar_main.Value = form.pebar_main.Value + BaseDate.MainVel
  if form.pebar_main.Value >= form.pebar_main.Maximum then
    nx_execute("custom_sender", "custom_xjz_jh_game", CTS_FRISH_GAME, nx_int(form.pass_time), form.pebar_main.Value, form.Value, nx_int(form.count))
    return
  end
  if nx_int(form.Value) >= nx_int(form.pebar_1.Maximum) or nx_int(form.Value) <= nx_int(0) then
    fail_game(form)
    return
  end
  local ss = nx_int(form.Value) - BaseDate.Center
  if form.Value < BaseDate.Center then
    ss = BaseDate.Center - nx_int(form.Value)
  end
  local nIndex1 = ss / BaseDate.Ares
  local nIndex = nx_int(nIndex1)
  if nIndex + 1 ~= form.pl_index then
    form.pl_index = nIndex + 1
    local now_frequency = frequency[form.pl_index]
    local timer = nx_value("timer_game")
    timer:UnRegister(nx_current(), "run_game", form)
    timer:Register(nx_int(now_frequency), -1, nx_current(), "run_game", form, -1, -1)
    nx_execute("custom_sender", "custom_xjz_jh_game", CTS_CHANGE_FQ, nx_int(form.pass_time), form.pebar_main.Value, form.Value, nx_int(form.count), nx_int(now_frequency))
    form.pass_time = 0
    form.count = 0
  end
end
function on_btn_add_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local nVel = BaseDate.RightAddVel
  form.vel_bs2 = form.vel_bs2 + nVel
  if form.vel_bs2 >= 100 then
    form.vel_bs1 = form.vel_bs1 + 1
    form.vel_bs2 = form.vel_bs2 - 100
  end
  if form.vel_bs1 == 0 and form.vel_bs2 == 0 then
    form.vel_bs1 = 1
  end
  nx_execute("custom_sender", "custom_xjz_jh_game", CTS_CHANGE_VEl, nx_int(form.pass_time), form.pebar_main.Value, form.Value, nx_int(form.count), nVel)
  form.pass_time = 0
  form.count = 0
end
function on_btn_dec_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local nVel = -1 * BaseDate.RightAddVel
  form.vel_bs2 = form.vel_bs2 - BaseDate.RightAddVel
  if form.vel_bs2 < 0 then
    form.vel_bs1 = form.vel_bs1 - 1
    form.vel_bs2 = form.vel_bs2 + 100
  end
  if form.vel_bs1 == 0 and form.vel_bs2 == 0 then
    form.vel_bs1 = -1
  end
  nx_execute("custom_sender", "custom_xjz_jh_game", CTS_CHANGE_VEl, nx_int(form.pass_time), form.pebar_main.Value, form.Value, nx_int(form.count), nVel)
  form.pass_time = 0
  form.count = 0
end
function GetPos1()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_small_game\\form_jia_huo_game", true, false)
  if not nx_is_valid(form) then
    return
  end
  local nLong = nx_float(form.lbl_end.Left - form.lbl_star.Left)
  local x = form.Value * nLong / form.pebar_1.Maximum
  x = x + form.lbl_star.Left
  local x1, x2, x3, x4, x5 = cz_sx[1].x, cz_sx[2].x, cz_sx[3].x, cz_sx[4].x, cz_sx[5].x
  local y11 = cz_sx[1].y * (x - x2) * (x - x3) * (x - x4) * (x - x5) / cz_sx[1].fm
  local y12 = cz_sx[2].y * (x - x1) * (x - x3) * (x - x4) * (x - x5) / cz_sx[2].fm
  local y13 = cz_sx[3].y * (x - x2) * (x - x1) * (x - x4) * (x - x5) / cz_sx[3].fm
  local y14 = cz_sx[4].y * (x - x2) * (x - x3) * (x - x1) * (x - x5) / cz_sx[4].fm
  local y15 = cz_sx[5].y * (x - x2) * (x - x3) * (x - x4) * (x - x1) / cz_sx[5].fm
  local y = y11 + y12 + y13 + y14 + y15
  return x, y
end
function get_skill()
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_SKILL))
  if not nx_is_valid(view) then
    return
  end
  local viewobj_list = view:GetViewObjList()
  for i = 1, table.getn(viewobj_list) do
    local configID = viewobj_list[i]:QueryProp("ConfigID")
    if SKILL_ID == configID then
      return viewobj_list[i]:QueryProp("Level")
    end
  end
  return 0
end
function InitGameXZ(form)
  local level = get_skill()
  if level == 0 then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  for i = 1, level do
    local rbtn = form.groupscrollbox_1:Find("rbtn_" .. nx_string(i))
    if not nx_is_valid(rbtn) then
      rbtn = gui:Create("RadioButton")
      rbtn.Name = "rbtn_" .. nx_string(i)
      rbtn.Width = 90
      rbtn.Height = 20
      rbtn.Font = "font_main"
      rbtn.ForeColor = "255,255,180,0"
      rbtn.NormalImage = get_treeview_bg(2, "out")
      rbtn.FocusImage = get_treeview_bg(2, "on")
      rbtn.CheckedImage = get_treeview_bg(2, "on")
      rbtn.Left = 5
      rbtn.Top = 23 * i - 10
      nx_bind_script(rbtn, nx_current())
      nx_callback(rbtn, "on_checked_changed", "on_checked_changed_btn")
    end
    rbtn.level = i
    rbtn.Text = nx_widestr("@Game_level_") .. nx_widestr(i)
    form.groupscrollbox_1:Add(rbtn)
  end
  local rbtn = form.groupscrollbox_1:Find("rbtn_" .. nx_string(1))
  rbtn.Checked = true
end
function on_checked_changed_btn(btn)
  if not btn.Checked then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.gamelevel = btn.level
end
function get_treeview_bg(bglvl, bgtype)
  local path = "gui\\common\\treeview\\tree_" .. nx_string(bglvl) .. "_" .. nx_string(bgtype) .. ".png"
  return nx_string(path)
end
function Initparabola(form)
  oval_key.a = (form.lbl_end.Left - form.lbl_star.Left) / 2
  oval_key.b = form.lbl_end.Top - form.lbl_star.Top
  oval_key.cx = form.lbl_star.Left + oval_key.a
  oval_key.cy = form.lbl_star.Top
  oval_key.a2 = oval_key.a * oval_key.a
  oval_key.b2 = oval_key.b * oval_key.b
end
function Init_yz(form)
  local x1, y1, x2, y2, x3, y3 = form.lbl_star.Left, form.lbl_star.Top, form.lbl_4.Left, form.lbl_4.Top, form.lbl_pz.Left, form.lbl_pz.Top
  local x4, y4, x5, y5 = form.lbl_5.Left, form.lbl_5.Top, form.lbl_end.Left, form.lbl_end.Top
  local nL1, nL2, nL3 = (x1 - x2) * (x1 - x3) * (x1 - x4) * (x1 - x5), (x2 - x1) * (x2 - x3) * (x2 - x4) * (x2 - x5), (x3 - x1) * (x3 - x2) * (x3 - x4) * (x3 - x5)
  local nL4, nL5 = (x4 - x1) * (x4 - x2) * (x4 - x3) * (x4 - x5), (x5 - x1) * (x5 - x2) * (x5 - x3) * (x5 - x4)
  cz_sx[1] = {
    x = x1,
    y = y1,
    fm = nL1
  }
  cz_sx[2] = {
    x = x2,
    y = y2,
    fm = nL2
  }
  cz_sx[3] = {
    x = x3,
    y = y3,
    fm = nL3
  }
  cz_sx[4] = {
    x = x4,
    y = y4,
    fm = nL4
  }
  cz_sx[5] = {
    x = x5,
    y = y5,
    fm = nL5
  }
end
function on_jia_huo_msg(...)
  local form = nx_value(nx_current())
  if arg[1] == STC_OpenGame then
    if not nx_is_valid(form) then
      form = util_get_form(nx_current(), true)
    end
    form:Show()
    form.Visible = true
  end
  if not nx_is_valid(form) then
    return
  end
  if arg[1] == STC_StarGame then
    local timer = nx_value("timer_game")
    local now_frequency = frequency[form.pl_index]
    if nx_is_valid(timer) then
      timer:Register(nx_int(now_frequency), -1, nx_current(), "run_game", form, -1, -1)
    end
    form.btn_star.Visible = false
  end
  if arg[1] == STC_FailGame then
    clear_game(form)
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "run_game", form)
    showResult(form, 2)
  end
  if arg[1] == STC_WinGame then
    clear_game(form)
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "run_game", form)
    showResult(form, 1)
  end
  if arg[1] == STC_MAINPOS then
    form.pebar_main.value = nx_int(arg[2])
  end
end
function fail_game(form)
  clear_game(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "run_game", form)
  nx_execute("custom_sender", "custom_xjz_jh_game", CTS_CANCLE_GAME)
  showResult(form, 2)
end
function change_form_size()
  local form = util_get_form(nx_current(), false)
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(form) then
    local gui = nx_value("gui")
    form.AbsLeft = 0
    form.AbsTop = 0
    form.Width = gui.Width
    form.Height = gui.Height
    form.groupbox_back.Left = 0
    form.groupbox_back.Top = 0
    form.groupbox_back.Width = gui.Width
    form.groupbox_back.Height = gui.Height
    form.groupbox_main.AbsLeft = (gui.Width - form.groupbox_main.Width) / 2
    form.groupbox_main.AbsTop = (gui.Height - form.groupbox_main.Height) / 5 * 2
  end
end
function showResult(form, res)
  local gui = nx_value("gui")
  local Label = gui:Create("Label")
  form.groupbox_main.Visible = false
  Label.AutoSize = true
  Label.Name = "lab_res"
  if nx_int(res) == nx_int(1) then
    Label.BackImage = "gui\\language\\ChineseS\\minigame\\xjz_minigame\\kaishi\\victory.png"
    Label.AbsTop = (gui.Height - Label.Height) / 2
  else
    Label.BackImage = "gui\\language\\ChineseS\\minigame\\xjz_minigame\\kaishi\\lost.png"
    Label.AbsTop = (gui.Height - Label.Height) / 2
  end
  local timer = nx_value("timer_game")
  timer:Register(2500, -1, nx_current(), "auto_close_form", form, 1, -1)
  Label.AbsLeft = (form.Width - Label.Width) / 2
  form:Add(Label)
end
function auto_close_form(form)
  console_log("end")
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "auto_close_form", form)
  form:Close()
end
function on_key_up(key_value)
  local form = util_get_form(nx_current(), false)
  if not nx_is_valid(form) then
    return
  end
  local key = ""
  if nx_int(key_value) == nx_int(65) or nx_int(key_value) == nx_int(37) then
    key = "A"
  elseif nx_int(key_value) == nx_int(68) or nx_int(key_value) == nx_int(39) then
    key = "D"
  end
  if key == "" then
    return
  end
end
