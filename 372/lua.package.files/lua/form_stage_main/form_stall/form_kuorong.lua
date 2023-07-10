require("util_gui")
require("util_functions")
require("share\\capital_define")
require("share\\client_custom_define")
require("game_object")
require("define\\sysinfo_define")
function main_form_init(self)
  self.Fixed = false
  self.Type = 1
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  move_position(self)
  init_info(self)
  return 1
end
function on_main_form_close(self)
  self.Visible = false
  nx_destroy(self)
  return 1
end
function init_info(self)
  local MaxCount = 0
  local cur_count = 0
  local shengji_count = 0
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if self.Type == 1 then
    MaxCount = get_MaxSellCount()
    cur_count = nx_execute("form_stage_main\\form_stall\\form_stall_main", "GetSellCount", client_player)
    self.lbl_duixiang.Text = gui.TextManager:GetText("ui_stall_chushoulan")
  else
    MaxCount = get_MaxBuyCount()
    cur_count = nx_execute("form_stage_main\\form_stall\\form_stall_main", "GetBuyCount", client_player)
    self.lbl_duixiang.Text = gui.TextManager:GetText("ui_stall_shougoulan")
  end
  if nx_number(cur_count + 5) <= nx_number(MaxCount) then
    shengji_count = 5
  else
    shengji_count = nx_number(MaxCount) - nx_number(cur_count)
  end
  local capital_manager = nx_value("CapitalModule")
  if not nx_is_valid(capital_manager) then
    return
  end
  local cur_gold = capital_manager:GetCapital(CAPITAL_TYPE_GOLDEN)
  local gezi_gold = get_gezi_price()
  local xuyao_gold = shengji_count * gezi_gold
  self.lbl_gezi.Text = nx_widestr(cur_count .. "->" .. nx_string(cur_count + shengji_count))
  self.lbl_price.Text = nx_widestr(xuyao_gold)
  self.lbl_yongyou.Text = nx_widestr(cur_gold)
end
function on_btn_ok_click(self)
  local form = self.Parent
  local price = nx_int64(form.lbl_price.Text)
  local yongyou = nx_int64(form.lbl_yongyou.Text)
  if not isHaveMoney(CAPITAL_TYPE_GOLDEN, price) then
    sysinfo("7048")
    form:Close()
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_STALL_SHENGJI), nx_int(form.Type))
  form:Close()
  return 1
end
function on_btn_cancel_click(self)
  local form = self.ParentForm
  nx_gen_event(form, "stall_kuorong_return", "cancel")
  form:Close()
  return 1
end
function on_btn_close_click(self)
  local form = self.ParentForm
  nx_gen_event(form, "stall_kuorong_return", "cancel")
  form:Close()
  return 1
end
function move_position(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function get_gezi_price()
  local price = nx_execute("form_stage_main\\form_stall\\stall_ini", "getIniRuleValue", "UnitGeZi")
  return nx_number(price)
end
function get_MaxSellCount()
  local val = nx_execute("form_stage_main\\form_stall\\stall_ini", "getIniRuleValue", "MaxSellCount")
  return nx_number(val)
end
function get_MaxBuyCount()
  local val = nx_execute("form_stage_main\\form_stall\\stall_ini", "getIniRuleValue", "MaxBuyCount")
  return nx_number(val)
end
function isHaveMoney(capital_type, capital_num)
  local capital_manager = nx_value("CapitalModule")
  if not nx_is_valid(capital_manager) then
    return false
  end
  return capital_manager:CanDecCapital(capital_type, capital_num)
end
function sysinfo(text)
  local form_main_sysinfo_logic = nx_value("form_main_sysinfo")
  if not nx_is_valid(form_main_sysinfo_logic) then
    return
  end
  local form_sysinfo = nx_value("form_stage_main\\form_main\\form_main_sysinfo")
  if not nx_is_valid(form_sysinfo) then
    return
  end
  if form_sysinfo.info_group.Visible == true then
    form_main_sysinfo_logic:AddSystemInfo(util_text(text), 0, 0)
  else
    form_main_sysinfo_logic:AddSystemInfo(util_text(text), SYSTYPE_FIGHT, 0)
  end
end
