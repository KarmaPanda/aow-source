require("util_gui")
require("game_object")
local FORM_NAME = "form_stage_main\\form_guildbuilding\\form_guild_build_banghuicangku_contributemoneyconfirm"
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  gui.Focused = self.ipt_capital
  self.lbl_0.Visible = false
  self.lbl_contribution.Text = nx_widestr("0")
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
  local capital_1 = nx_int64(form.ipt_capital.Text)
  local capital_2 = nx_int64(form.fipt_replace.Text)
  nx_gen_event(form, "form_guild_depot_contributemoneyconfirm_return", "ok", capital_1, capital_2)
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
    local guildbuilding_Manager = nx_value("GuildbuildingManager")
    if not nx_is_valid(goods_grid) or not nx_is_valid(guildbuilding_Manager) then
      return false
    end
    count = goods_grid:GetItemCount(configid)
  end
  if nx_int64(MaxValue) > nx_int64(count) then
    form.ipt_capital.Text = nx_widestr(count)
  else
    form.ipt_capital.Text = nx_widestr(MaxValue)
  end
end
function on_btn_max_replace_click(btn)
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
  local goods_grid = nx_value("GoodsGrid")
  local guildbuilding_Manager = nx_value("GuildbuildingManager")
  if not nx_is_valid(goods_grid) or not nx_is_valid(guildbuilding_Manager) then
    return false
  end
  local equal_cfg = guildbuilding_Manager:GetReplaceRes(configid)
  if nx_int(table.getn(equal_cfg)) == nx_int(0) then
    return false
  end
  local equal_item_name = equal_cfg[1]
  if equal_item_name == nil then
    return false
  end
  count = goods_grid:GetItemCount(equal_item_name)
  if nx_int64(MaxValue) > nx_int64(count) then
    form.fipt_replace.Text = nx_widestr(count)
  else
    form.fipt_replace.Text = nx_widestr(MaxValue)
  end
end
function on_ipt_capital_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_string(form.ipt_capital.Text) == "-" then
    form.ipt_capital.Text = nx_widestr("0")
    return
  end
  if nx_string(form.fipt_replace.Text) == "-" then
    form.fipt_replace.Text = nx_widestr("0")
    return
  end
  local value = nx_int(form.ipt_capital.Text)
  local replace_value = nx_int(form.fipt_replace.Text)
  if nx_int(value) < nx_int(0) then
    form.ipt_capital.Text = nx_widestr("0")
    return
  end
  if nx_int(replace_value) < nx_int(0) then
    form.fipt_replace.Text = nx_widestr("0")
    return
  end
  refresh_contribution(form, nx_int(value), nx_int(replace_value))
end
function refresh_contribution(form, capital, replace_num)
  local guildbuilding_Manager = nx_value("GuildbuildingManager")
  if not nx_is_valid(form) or not nx_is_valid(guildbuilding_Manager) then
    return
  end
  if nx_int(capital) < nx_int(0) or nx_int(replace_num) < nx_int(0) then
    form.lbl_contribution.Text = nx_widestr("0")
    return
  end
  local contribute = nx_value("contribute")
  local contribution = 0
  if contribute ~= nil then
    contribution = math.ceil(nx_int(capital) * contribute)
  end
  local res = guildbuilding_Manager:GetReplaceResContriValue()
  contribution = nx_int(contribution) + nx_int(res[1]) * nx_int(replace_num)
  form.lbl_contribution.Text = nx_widestr(contribution)
end
