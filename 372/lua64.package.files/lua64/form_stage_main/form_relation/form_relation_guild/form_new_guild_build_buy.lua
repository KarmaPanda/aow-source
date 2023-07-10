require("util_gui")
require("game_object")
require("share\\client_custom_define")
local SUB_CUSTOMMSG_REQUEST_GUILD_CAPITAL = 68
local FORM_BUY = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_build_buy"
local wen_to_ding = 1000000
local wen_to_liang = 1000
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  local form_levelup = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_levelup")
  if not nx_is_valid(form_levelup) then
    return
  end
  self.ratio = nx_int(form_levelup.ratio)
  self.left_establish = nx_int64(form_levelup.lbl_9.Text)
  self.limited = nx_int64(form_levelup.limited)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  gui.Focused = self.ipt_buy
  self.guild_capital = 0
  custom_guild_capital()
  return 1
end
function on_main_form_close(self)
  if nx_is_valid(self) then
    nx_destroy(self)
  end
  return 1
end
function on_btn_cancel_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_gen_event(form, "buy_return", "cancel")
  form:Close()
end
function on_btn_confirm_click(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local buy_num = nx_int64(form.ipt_buy.Text)
  if nx_int64(buy_num) <= nx_int64(0) then
    return
  end
  local need_momey = nx_int64(form.ratio * buy_num)
  if nx_int64(form.guild_capital) < nx_int64(need_momey) then
    local text = gui.TextManager:GetText("ui_newguild_money_tips_1")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return
  end
  local tatol = buy_num + form.left_establish
  if nx_int64(form.limited) < nx_int64(tatol) then
    local text = gui.TextManager:GetText("ui_newguild_money_tips_2")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return
  end
  nx_gen_event(form, "buy_return", "ok", buy_num)
  form:Close()
end
function on_ipt_buy_changed(ipt)
  local form = ipt.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local input_num = nx_number(ipt.Text)
  if nx_number(input_num) < nx_number(0) then
    input_num = 0
  end
  local total_money = input_num * form.ratio
  local left_money = form.guild_capital - total_money
  if nx_number(left_money) < nx_number(0) then
    form.lbl_capital.Text = nx_widestr(0)
  else
    local left_ding = nx_int(left_money / wen_to_ding)
    local left_liang = nx_int((left_money - left_ding * wen_to_ding) / wen_to_liang)
    local left_wen = left_money - left_ding * wen_to_ding - left_liang * wen_to_liang
    form.lbl_capital.Text = nx_widestr(gui.TextManager:GetFormatText("ui_newguild_money", nx_int(left_ding), nx_int(left_liang), nx_int(left_wen)))
  end
  local cost_ding = nx_int(total_money / wen_to_ding)
  local cost_liang = nx_int((total_money - cost_ding * wen_to_ding) / wen_to_liang)
  local cost_wen = total_money - cost_ding * wen_to_ding - cost_liang * wen_to_liang
  form.lbl_cost.Text = nx_widestr(gui.TextManager:GetFormatText("ui_newguild_money", nx_int(cost_ding), nx_int(cost_liang), nx_int(cost_wen)))
end
function custom_guild_capital()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_CAPITAL))
end
function on_rec_guild_capital(...)
  local form = nx_value(FORM_BUY)
  if not nx_is_valid(form) then
    return
  end
  local rec_guild_capital = arg[1]
  if nx_number(rec_guild_capital) < nx_number(0) then
    rec_guild_capital = 0
  end
  form.guild_capital = rec_guild_capital
  local ding = nx_int(rec_guild_capital / wen_to_ding)
  local liang = nx_int((rec_guild_capital - ding * wen_to_ding) / wen_to_liang)
  local wen = rec_guild_capital - ding * wen_to_ding - liang * wen_to_liang
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.lbl_capital.Text = nx_widestr(gui.TextManager:GetFormatText("ui_newguild_money", nx_int(ding), nx_int(liang), nx_int(wen)))
end
