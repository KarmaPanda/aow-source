require("share\\view_define")
require("util_gui")
require("define\\gamehand_type")
require("game_object")
require("util_functions")
CupGame_CupCountLowLv = 3
CupGame_CupsPosLowLv = {
  {48, 200},
  {200, 200},
  {352, 200}
}
CupGame_CupCountHighLv = 5
CupGame_CupsPosHighLv = {
  {48, 200},
  {200, 200},
  {352, 200},
  {112, 64},
  {280, 64}
}
CupGame_CupSpeed = {
  400,
  300,
  200
}
CupGame_DelayWhenStart = 5000
CupGame_WaitWhenTip = 5000
CupGame_DelayWhenTip = 3000
CupGame_CupWidth = 140
CupGame_CupHeight = 150
CupGame_Stages = {
  "prepare",
  "running",
  "guessing",
  "success",
  "failed"
}
CupGame_CurStages = "prepare"
local CupGame_EmptyCup_NormalPic = "gui\\smallgame\\b-feixingqi-on.png"
local CupGame_EmptyCup_FocusPic = "gui\\smallgame\\b-feixingqi-down.png"
local CupGame_EmptyCup_ClickPic = "gui\\smallgame\\b-feixingqi-out.png"
local CupGame_SolidCup_NormalPic = "gui\\smallgame\\b-duobaoqibin-on.png"
local CupGame_SolidCup_FocusPic = "gui\\smallgame\\b-duobaoqibin-down.png"
local CupGame_SolidCup_ClickPic = "gui\\smallgame\\b-duobaoqibin-out.png"
function on_main_form_init(self)
  return 1
end
function on_main_form_open(self)
  self.Fixed = false
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  on_game_init(self)
  return 1
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(self)
  local form = self.Parent
  form:Close()
  local gui = nx_value("gui")
  gui:Delete(form)
end
function on_update_game(form, param1, param2)
end
function on_btn_start_click(self)
  random_realcup(self.Parent)
  CupGame_CurStages = "running"
end
function on_btn_tip_click(self)
end
function on_game_init(form)
  create_cups(form)
  refresh_cups(form)
  CupGame_CurStages = "prepare"
end
function create_cups(form)
  for index = 1, CupGame_CupCountHighLv do
    local gui = nx_value("gui")
    local CupCtrl = gui:Create("Button")
    CupCtrl.Top = CupGame_CupsPosHighLv[index][1]
    CupCtrl.Left = CupGame_CupsPosHighLv[index][2]
    CupCtrl.Width = CupGame_CupWidth
    CupCtrl.Height = CupGame_CupHeight
    CupCtrl.DrawMode = "Expand"
    CupCtrl.Visible = false
    CupCtrl.Name = "Cup" .. index
    form.groupbox_platform:Add(CupCtrl)
  end
end
function refresh_cups(form)
  for index = 1, CupGame_CupCountHighLv do
    local CupName = "Cup" .. index
    local CupCtrl = form.groupbox_platform:Find(CupName)
    CupCtrl.Top = CupGame_CupsPosHighLv[index][1]
    CupCtrl.Left = CupGame_CupsPosHighLv[index][2]
    CupCtrl.Width = CupGame_CupWidth
    CupCtrl.Height = CupGame_CupHeight
    CupCtrl.Visible = false
    CupCtrl.NormalImage = nx_string(CupGame_EmptyCup_NormalPic)
    CupCtrl.EmptyMark = false
  end
  local game_difficute = form.groupbox_setting.ipt_diff.Text
  if nx_int(game_difficute) == nx_int(1) then
    for index = 1, CupGame_CupCountLowLv do
      local CupName = "Cup" .. index
      local CupCtrl = form.groupbox_platform:Find(CupName)
      CupCtrl.Visible = true
    end
    return
  end
  if nx_int(game_difficute) == nx_int(2) then
    for index = 1, CupGame_CupCountHighLv do
      local CupName = "Cup" .. index
      local CupCtrl = form.groupbox_platform:Find(CupName)
      CupCtrl.Visible = true
    end
    return
  end
end
function random_realcup(form)
  local game_difficute = form.groupbox_setting.ipt_diff.Text
  local nRandNumber = 0
  if nx_int(game_difficute) == nx_int(1) then
    nRandNumber = math.random(CupGame_CupCountLowLv)
  end
  if nx_int(game_difficute) == nx_int(2) then
    nRandNumber = math.random(CupGame_CupCountHighLv)
  end
  local SolidCupName = "Cup" .. nRandNumber
  local SolidCup = form.groupbox_platform:Find(SolidCupName)
  SolidCup.EmptyMark = false
  return
end
