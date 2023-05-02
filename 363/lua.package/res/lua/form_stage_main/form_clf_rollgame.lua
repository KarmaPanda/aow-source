require("util_gui")
require("util_functions")
local GTYPE_ITEM = 0
local GTYPE_SUIYIN = 1
local GTYPE_GUANYIN = 2
local GTYPE_POINT = 3
local TOTAL_TIME = 15
local SHACK_TIME = 0
local COVER_PIC = 1
local COVER_POS_TOP = 248
local COVER_POS_LEFT = 104
local CLIENT_SUB_MSG_XIAZHU = 0
local CLIENT_SUB_MSG_CANCEL = 1
local SERVER_SUB_MSG_RESULT = 0
local SERVER_SUB_MSG_FAIL = 1
local RESULT = {
  ["1"] = {
    "gui\\special\\prison_dice\\jianyu_shaizi_yi_1.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_yi_2.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_yi_3.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_yi_4.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_yi_5.png"
  },
  ["2"] = {
    "gui\\special\\prison_dice\\jianyu_shaizi_er_1.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_er_2.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_er_3.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_er_4.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_er_5.png"
  },
  ["3"] = {
    "gui\\special\\prison_dice\\jianyu_shaizi_er_1-11.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_san_2.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_san_3.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_san_4.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_san_5.png"
  },
  ["4"] = {
    "gui\\special\\prison_dice\\jianyu_shaizi_si_1.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_si_2.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_si_3.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_si_4.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_si_5.png"
  },
  ["5"] = {
    "gui\\special\\prison_dice\\jianyu_shaizi_wu_1.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_wui_2.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_wu_3.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_wu_4.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_wu_5.png"
  },
  ["6"] = {
    "gui\\special\\prison_dice\\jianyu_shaizi_liu_1.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_liu_2.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_liu_3.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_liu_4.png",
    "gui\\special\\prison_dice\\jianyu_shaizi_liu_5.png"
  }
}
function main_form_init(self)
  self.Fixed = true
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.check_side = 0
  self.game_type = GTYPE_ITEM
  self.item_id = ""
  self.couma_num = 0
  self.point = 0
end
function on_main_form_open(self)
  self.btn_ok.Enabled = false
  self.lbl_cover.ClickEvent = false
  self.lbl_cover.Visible = false
  self.lbl_rock_one.Visible = false
  self.lbl_rock_two.Visible = false
  self.pic_cover_big.Visible = false
  self.pic_cover_small.Visible = false
  local game_type = nx_int(self.game_type)
  if nx_int(GTYPE_ITEM) == game_type then
    self.btn_ok.Text = util_text("adv0090224")
  elseif nx_int(GTYPE_SUIYIN) == game_type then
    self.btn_ok.Text = util_text("adv0090225")
  elseif nx_int(GTYPE_GUANYIN) == game_type then
    self.btn_ok.Text = util_text("adv0090226")
  elseif nx_int(GTYPE_POINT) == game_type then
    self.btn_ok.Text = util_text("adv0090227")
  end
  return
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_move_in", self)
  timer:UnRegister(nx_current(), "on_rock", self)
  timer:UnRegister(nx_current(), "on_disappear", self)
  nx_destroy(self)
end
function on_cbtn_click_changed(self)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  if self.Checked then
    form.check_side = self.DataSource
    form.btn_ok.Enabled = true
    if nx_int(self.DataSource) == nx_int(1) then
      form.cbtn_small.Checked = false
    elseif nx_int(self.DataSource) == nx_int(2) then
      form.cbtn_big.Checked = false
    end
  end
end
function on_rbtn_checked_ok(self)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local game_type = nx_int(form.game_type)
  if nx_int(GTYPE_ITEM) == game_type then
    local CLFRollGame = nx_value("CLFRollGame")
    if not nx_is_valid(CLFRollGame) then
      return
    end
    local itemNum = CLFRollGame:GetItemNum(nx_string(form.item_id))
    if nx_int(itemNum) < nx_int(form.couma_num) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("adv0090219"), 2)
      end
      return
    end
  elseif nx_int(GTYPE_SUIYIN) == game_type then
    local todayleave = client_player:QueryProp("TodayCapitalLeave1")
    local capital = client_player:QueryProp("CapitalType1")
    if todayleave <= capital then
      capital = todayleave
    end
    local bGrid = client_player:QueryProp("CapitalGird")
    if nx_int(bGrid) == nx_int(1) then
      capital = capital + client_player:QueryProp("CapitalType2")
    end
    if nx_int(capital) < nx_int(form.couma_num) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("adv0090220"), 2)
      end
      return
    end
  elseif nx_int(GTYPE_GUANYIN) == game_type then
    local capital = client_player:QueryProp("CapitalType2")
    if nx_int(capital) < nx_int(form.couma_num) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("adv0090221"), 2)
      end
      return
    end
  elseif nx_int(GTYPE_POINT) == game_type and nx_int(form.point) < nx_int(form.couma_num) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("adv0090222"), 2)
    end
    return
  end
  form.btn_ok.Enabled = false
  shake_bowl(form)
end
function on_lbl_cover_click(self)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  if self.Visible == true and nx_int(SHACK_TIME) == nx_int(0) then
    form.lbl_cover.ClickEvent = false
    if nx_int(form.check_side) ~= nx_int(0) then
      nx_execute("custom_sender", "custom_send_clf_roll_game", nx_int(CLIENT_SUB_MSG_XIAZHU), nx_int(form.check_side))
    end
  end
end
function on_btn_close_click(self)
  local form = util_get_form("form_stage_main\\form_clf_rollgame", false)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  nx_execute("custom_sender", "custom_send_clf_roll_game", CLIENT_SUB_MSG_CANCEL)
end
function on_start(...)
  if table.getn(arg) < 1 then
    return
  end
  local game_type = nx_int(arg[1])
  if nx_int(GTYPE_ITEM) == game_type then
    if table.getn(arg) < 3 then
      return
    end
  elseif nx_int(GTYPE_SUIYIN) == game_type then
    if table.getn(arg) < 2 then
      return
    end
  elseif nx_int(GTYPE_GUANYIN) == game_type then
    if table.getn(arg) < 2 then
      return
    end
  elseif nx_int(GTYPE_POINT) == game_type and table.getn(arg) < 3 then
    return
  end
  local form = util_get_form("form_stage_main\\form_clf_rollgame", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.game_type = game_type
  if nx_int(GTYPE_ITEM) == game_type then
    form.item_id = nx_string(arg[2])
    form.couma_num = nx_int(arg[3])
  elseif nx_int(GTYPE_SUIYIN) == game_type then
    form.couma_num = nx_int(arg[2])
  elseif nx_int(GTYPE_GUANYIN) == game_type then
    form.couma_num = nx_int(arg[2])
  elseif nx_int(GTYPE_POINT) == game_type then
    form.couma_num = nx_int(arg[2])
    form.point = nx_int(arg[3])
  end
  form.Visible = true
  form:Show()
end
function on_stop(...)
  local form = util_get_form("form_stage_main\\form_clf_rollgame", false)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_cancel(...)
end
function custom_message_callback(...)
  if table.getn(arg) < 1 then
    return
  end
  local form = util_get_form("form_stage_main\\form_clf_rollgame", false)
  if not nx_is_valid(form) then
    return
  end
  local sub_id = nx_int(arg[1])
  if nx_int(SERVER_SUB_MSG_RESULT) == sub_id then
    if table.getn(arg) < 4 then
      return
    end
    local result_one = arg[2]
    local result_two = arg[3]
    local result_three = arg[4]
    if table.getn(arg) == 5 then
      form.point = nx_int(arg[5])
    end
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:Register(20, -1, nx_current(), "on_disappear", form.lbl_cover, -1, -1)
    end
    form.cbtn_small.Checked = false
    form.cbtn_big.Checked = false
    form.btn_ok.Enabled = false
    show_result(form, result_one, result_two, result_three)
  elseif nx_int(SERVER_SUB_MSG_FAIL) == sub_id then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:Register(20, -1, nx_current(), "on_disappear", form.lbl_cover, -1, -1)
    end
    form.cbtn_small.Checked = false
    form.cbtn_big.Checked = false
    form.btn_ok.Enabled = false
    show_result(form, 1, 1, 1)
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("adv0090223"), 2)
    end
  end
end
function shake_bowl(form)
  form.pic_cover_big.Visible = true
  form.pic_cover_small.Visible = true
  form.lbl_cover.Left = COVER_POS_TOP
  form.lbl_cover.Top = -50
  form.lbl_cover.Visible = true
  form.lbl_cover.ClickEvent = false
  SHACK_TIME = 0
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(20, -1, nx_current(), "on_move_in", form.lbl_cover, -1, -1)
  end
  form.lbl_result_1.Visible = false
  form.lbl_result_2.Visible = false
  form.lbl_result_3.Visible = false
end
function on_move_in(self)
  if not nx_is_valid(self) then
    return
  end
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  self.Top = self.Top + 20
  if nx_int(self.Top) >= nx_int(COVER_POS_LEFT) then
    self.Top = COVER_POS_LEFT
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "on_move_in", self)
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:Register(80, -1, nx_current(), "on_rock", form, -1, -1)
    end
  end
end
function on_disappear(self)
  if not nx_is_valid(self) then
    return
  end
  self.Left = self.Left + 20
  self.Top = self.Top - 20
  if nx_int(self.Top) <= nx_int(-50) then
    self.Visible = false
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "on_disappear", self)
  end
end
function on_rock(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(COVER_PIC) == nx_int(1) then
    form.lbl_rock_one.Visible = true
    form.lbl_rock_two.Visible = false
    COVER_PIC = 2
  elseif nx_int(COVER_PIC) == nx_int(2) then
    form.lbl_rock_one.Visible = false
    form.lbl_rock_two.Visible = true
    COVER_PIC = 1
  end
  SHACK_TIME = SHACK_TIME + 1
  if nx_int(SHACK_TIME) >= nx_int(TOTAL_TIME) then
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "on_rock", form)
    form.lbl_cover.Visible = true
    form.lbl_cover.ClickEvent = true
    form.lbl_rock_one.Visible = false
    form.lbl_rock_two.Visible = false
    SHACK_TIME = 0
  end
end
function show_result(form, result_one, result_two, result_three)
  local pic_one = math.random(5)
  local pic_two = math.random(5)
  local pic_three = math.random(5)
  form.lbl_result_1.BackImage = RESULT[nx_string(result_one)][pic_one]
  form.lbl_result_2.BackImage = RESULT[nx_string(result_two)][pic_two]
  form.lbl_result_3.BackImage = RESULT[nx_string(result_three)][pic_three]
  form.lbl_result_1.Visible = true
  form.lbl_result_2.Visible = true
  form.lbl_result_3.Visible = true
  form.pic_cover_big.Visible = false
  form.pic_cover_small.Visible = false
end
