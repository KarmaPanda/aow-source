require("util_gui")
require("util_functions")
local CLIENT_SUB_NOR_PLAY_GAME = 1
local CLIENT_SUB_DEAD_PLAY_GAME = 2
local SERVER_SUB_NOR_PLAY_GAME = 10
local SERVER_SUB_DEAD_PLAY_GAME = 20
local SERVER_SUB_GAME_RESULT = 30
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
local SHACK_TIME = 0
local TOTAL_TIME = 15
local COVER_PIC = 1
function out_open(type, base_cost)
  if type == nil or base_cost == nil then
    return false
  end
  local form = util_get_form("form_stage_main\\form_bribe\\form_bribe", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.bribe_type = type
  form.base_cost = base_cost
  form.Visible = true
  form:Show()
end
function main_form_init(self)
  self.bribe_type = 0
  self.check_side = 0
  self.base_cost = 0
  self.Fixed = true
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
end
function on_main_form_open(self)
  self.btn_ok.Enabled = false
  self.lbl_cover.ClickEvent = false
  self.lbl_cover.Visible = false
  self.lbl_rock_one.Visible = false
  self.lbl_rock_two.Visible = false
  self.pic_cover_big.Visible = false
  self.pic_cover_small.Visible = false
  self.lbl_flash_big.Visible = false
  self.lbl_flash_small.Visible = false
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("PowerLevel", "int", self, nx_current(), "on_cost_change")
    databinder:AddRolePropertyBind("PKValue", "int", self, nx_current(), "on_cost_change")
  end
  return
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  local databinder = nx_value("data_binder")
  databinder:DelRolePropertyBind("PowerLevel", self)
  databinder:DelRolePropertyBind("PKValue", self)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_move_in", self)
  timer:UnRegister(nx_current(), "on_rock", self)
  timer:UnRegister(nx_current(), "on_disappear", self)
  nx_destroy(self)
  return
end
function on_cbtn_click_changed(self)
  local form = self.Parent
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
  form.lbl_flash_big.Visible = false
  form.lbl_flash_small.Visible = false
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local yinzi = client_player:QueryProp("CapitalType1")
  local yinka = client_player:QueryProp("CapitalType2")
  local todayleave = client_player:QueryProp("TodayCapitalLeave1")
  local capital = 0
  if yinzi >= todayleave then
    capital = todayleave
  else
    capital = yinzi
  end
  local bGrid = client_player:QueryProp("CapitalGird")
  if nx_int(bGrid) == nx_int(1) then
    capital = capital + yinka
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local pk_value = client_player:QueryProp("PKValue")
  local power_level = client_player:QueryProp("PowerLevel")
  local need_money = 0
  if pk_value < 8000 then
    need_money = form.base_cost * nx_int(power_level / 10) + 5000
  else
    need_money = 2 * form.base_cost * nx_int(power_level / 10) + 10000
  end
  if nx_int(capital) < nx_int(need_money) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("11357"), 2)
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
      send_play(form)
    end
  end
end
function on_btn_close_click(self)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function send_play(form)
  local sock = nx_value("game_sock")
  if not nx_is_valid(sock) then
    return false
  end
  if nx_int(form.bribe_type) == nx_int(SERVER_SUB_NOR_PLAY_GAME) then
    nx_execute("custom_sender", "custom_send_bribe", CLIENT_SUB_NOR_PLAY_GAME, form.check_side)
    return
  end
  if nx_int(form.bribe_type) == nx_int(SERVER_SUB_DEAD_PLAY_GAME) then
    nx_execute("custom_sender", "custom_send_bribe", CLIENT_SUB_DEAD_PLAY_GAME, form.check_side)
    return
  end
end
function on_msg(...)
  if table.getn(arg) < 1 then
    return
  end
  local sub_cmd = arg[1]
  if nx_int(sub_cmd) == nx_int(SERVER_SUB_NOR_PLAY_GAME) or nx_int(sub_cmd) == nx_int(SERVER_SUB_DEAD_PLAY_GAME) then
    out_open(sub_cmd, arg[2])
  end
  if nx_int(sub_cmd) == nx_int(SERVER_SUB_GAME_RESULT) then
    local form = util_get_form("form_stage_main\\form_bribe\\form_bribe", true, false)
    if not nx_is_valid(form) then
      return
    end
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:Register(20, -1, nx_current(), "on_disappear", form.lbl_cover, -1, -1)
    end
    form.cbtn_small.Checked = false
    form.cbtn_big.Checked = false
    form.btn_ok.Enabled = false
    local result_one = arg[2]
    local result_two = arg[3]
    local result_three = arg[4]
    show_result(result_one, result_two, result_three)
    local result_all = result_one + result_two + result_three
    if nx_int(result_all) == nx_int(3) and nx_int(form.check_side) == nx_int(2) then
      form.lbl_flash_small.Visible = true
    elseif nx_int(result_all) == nx_int(18) and nx_int(form.check_side) == nx_int(1) then
      form.lbl_flash_big.Visible = true
    end
  end
end
function show_result(result_one, result_two, result_three)
  local form = util_get_form("form_stage_main\\form_bribe\\form_bribe", true, false)
  if not nx_is_valid(form) then
    return
  end
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
function on_move_in(self)
  if not nx_is_valid(self) then
    return
  end
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  self.Top = self.Top + 20
  if nx_int(self.Top) >= nx_int(136) then
    self.Top = 136
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "on_move_in", self)
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:Register(80, -1, nx_current(), "on_rock", form, -1, -1)
    end
  end
end
function shake_bowl(form)
  form.pic_cover_big.Visible = true
  form.pic_cover_small.Visible = true
  form.lbl_cover.Left = 144
  form.lbl_cover.Top = 0
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
function on_cost_change(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local pk_value = client_player:QueryProp("PKValue")
  local power_level = client_player:QueryProp("PowerLevel")
  if pk_value <= 1000 then
    form:Close()
    return 0
  end
  local need_money = 0
  if pk_value < 8000 then
    need_money = form.base_cost * nx_int(power_level / 10) + 5000
  else
    need_money = 2 * form.base_cost * nx_int(power_level / 10) + 10000
  end
  local cost_text = trans_capital_string(need_money)
  form.btn_ok.Text = nx_widestr(util_text("ui_xiazhu")) .. nx_widestr("(") .. nx_widestr(cost_text) .. nx_widestr(")")
end
