require("util_gui")
require("game_object")
local FORM_NAME = "form_stage_main\\form_guildbuilding\\form_guild_build_banghuicangku_contributemoneyconfirm2"
local money_ding_wen = 1000000
local money_siliver_wen = 1000
function main_form_init(self)
  self.Fixed = false
  self.cur_capital = 0
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  gui.Focused = self.ipt_price_ding
  self.lbl_contribution.Text = nx_widestr("0")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  self.cur_capital = client_player:QueryProp("CapitalType2")
  local remain_money = nx_widestr(gui.TextManager:GetFormatText("ui_gc_money", nx_int(self.cur_capital)))
  if nx_number(remain_money) < nx_number(0) then
    self.lbl_capital.Text = nx_widestr(0)
  else
    self.lbl_capital.Text = nx_widestr(remain_money)
  end
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
  nx_gen_event(form, "form_guild_depot_contributemoneyconfirm_return", "cancel")
  form:Close()
end
function on_btn_confirm_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local ding = nx_int(form.ipt_price_ding.Text)
  local liang = nx_int(form.ipt_price_liang.Text)
  local wen = nx_int(form.ipt_price_wen.Text)
  local capital = ding * money_ding_wen + liang * money_siliver_wen + wen
  if nx_int64(capital) <= nx_int64(0) then
    return
  end
  nx_gen_event(form, "form_guild_depot_contributemoneyconfirm_return", "ok", capital, 0)
  form:Close()
end
function on_btn_max_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local count = 0
  local MaxValue = nx_value("MaxValue")
  local configid = nx_value("configID")
  if configid == nil or MaxValue == nil then
    return
  end
  if configid == "CapitalType1" then
    local game_client = nx_value("game_client")
    local player_obj = game_client:GetPlayer()
    count = player_obj:QueryProp("CapitalType2")
  else
    local goods_grid = nx_value("GoodsGrid")
    if not nx_is_valid(goods_grid) then
      return false
    end
    count = goods_grid:GetItemCount(configid)
  end
  local show_value = 0
  if nx_int64(MaxValue) > nx_int64(count) then
    show_value = count
  else
    show_value = MaxValue
  end
  local d = nx_int(show_value / money_ding_wen)
  local l = nx_int((show_value - d * money_ding_wen) / money_siliver_wen)
  local w = show_value - d * money_ding_wen - l * money_siliver_wen
  form.ipt_price_ding.Text = nx_widestr(d)
  form.ipt_price_liang.Text = nx_widestr(l)
  form.ipt_price_wen.Text = nx_widestr(w)
end
function refresh_contribution(form, capital)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(capital) < nx_int(0) then
    form.lbl_contribution.Text = nx_widestr("0")
    return
  end
  local contribute = nx_value("contribute")
  if contribute ~= nil then
    local contribution = math.ceil(nx_int(capital) * contribute)
    form.lbl_contribution.Text = nx_widestr(contribution)
  end
end
function on_ipt_changed(ipt)
  local form = ipt.ParentForm
  local ding = nx_int(form.ipt_price_ding.Text)
  local liang = nx_int(form.ipt_price_liang.Text)
  local wen = nx_int(form.ipt_price_wen.Text)
  local silver = 0
  if nx_int(ding) > nx_int(0) then
    silver = ding * nx_int(money_ding_wen)
  end
  if nx_int(liang) > nx_int(0) then
    silver = silver + nx_int(liang) * nx_int(money_siliver_wen)
  end
  if nx_int(wen) > nx_int(0) then
    silver = silver + nx_int(wen)
  end
  local left_capital = form.cur_capital - silver
  local gui = nx_value("gui")
  local remain_money = nx_widestr(gui.TextManager:GetFormatText("ui_gc_money", nx_int(left_capital)))
  if nx_number(remain_money) < nx_number(0) then
    form.lbl_capital.Text = nx_widestr(0)
  else
    form.lbl_capital.Text = nx_widestr(remain_money)
  end
  refresh_contribution(form, silver)
end
