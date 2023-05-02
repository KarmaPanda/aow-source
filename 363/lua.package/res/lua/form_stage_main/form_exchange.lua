require("utils")
require("util_gui")
require("share\\view_define")
require("share\\itemtype_define")
require("define\\gamehand_type")
require("util_functions")
require("custom_sender")
require("game_object")
require("form_stage_main\\form_chat_system\\chat_util_define")
local g_ex_capital_type = 2
function main_form_init(self)
  self.Fixed = false
  self.is_success = false
  return 1
end
function main_form_open(self)
  self.lbl_15.Visible = false
  self.lbl_18.Visible = false
  self.goods_self.typeid = VIEWPORT_SELFEXCHANGE
  for i = 1, 10 do
    self.goods_self:SetBindIndex(nx_int(i - 1), nx_int(i))
  end
  self.goods_self.canselect = false
  self.goods_self.candestroy = false
  self.goods_self.cansplit = false
  self.goods_self.canlock = false
  self.goods_other.typeid = VIEWPORT_OTHEREXCHANGE
  for i = 1, 10 do
    self.goods_other:SetBindIndex(nx_int(i - 1), nx_int(i))
  end
  self.goods_other.canselect = false
  self.goods_other.candestroy = false
  self.goods_other.cansplit = false
  self.goods_other.canlock = false
  self.ipt_0.Text = nx_widestr(nx_string(0))
  self.ipt_1.Text = nx_widestr(nx_string(0))
  self.ipt_2.Text = nx_widestr(nx_string(0))
  self.ipt_3.Text = nx_widestr(nx_string(0))
  self.ipt_4.Text = nx_widestr(nx_string(0))
  self.ipt_5.Text = nx_widestr(nx_string(0))
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_SELFEXCHANGE, self.goods_self, "form_stage_main\\form_exchange", "on_self_exchange_view_operat")
  databinder:AddViewBind(VIEWPORT_OTHEREXCHANGE, self.goods_other, "form_stage_main\\form_exchange", "on_other_exchange_view_operat")
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_bag", true)
  return 1
end
function main_form_close(self)
  local databinder = nx_value("data_binder")
  databinder:DelViewBind(self.goods_self)
  databinder:DelViewBind(self.goods_other)
  nx_execute("custom_sender", "custom_exchange_cancel")
  nx_destroy(self)
  nx_set_value("form_stage_main\\form_exchange", nx_null())
end
function on_ipt_changed(ipt)
  local form = ipt.ParentForm
  local text = nx_string(ipt.Text)
  if string.find(text, "%D") then
    text = string.gsub(text, "%D", "")
    ipt.Text = nx_widestr(text)
    return
  end
  local capital_manager = nx_value("CapitalModule")
  local max_silver = capital_manager:GetCapital(g_ex_capital_type)
  local silver0 = nx_number(form.ipt_3.Text)
  local silver1 = nx_number(form.ipt_4.Text)
  local silver2 = nx_number(form.ipt_5.Text)
  local silver = silver0 * 1000000 + silver1 * 1000 + silver2
  if max_silver < silver then
    silver = max_silver
    local ding, liang, wen = trans_price(silver)
    form.ipt_3.Text = nx_widestr(ding)
    form.ipt_4.Text = nx_widestr(liang)
    form.ipt_5.Text = nx_widestr(wen)
  end
  nx_execute("custom_sender", "custom_exchange_setmoney", g_ex_capital_type, silver)
end
function on_mylock_changed(self)
  nx_execute("custom_sender", "custom_exchange_lock")
  local form = self.ParentForm
  if nx_int(1) == nx_int(form.cbtn_lock_self.Checked) then
    form.lbl_18.Visible = true
    form.ipt_3.BackImage = ""
    form.ipt_4.BackImage = ""
    form.ipt_5.BackImage = ""
  else
    form.lbl_18.Visible = false
    form.ipt_3.BackImage = "gui\\common\\form_line\\ibox_1.png"
    form.ipt_4.BackImage = "gui\\common\\form_line\\ibox_1.png"
    form.ipt_5.BackImage = "gui\\common\\form_line\\ibox_1.png"
  end
  return 1
end
function on_myexchange_changed(self)
  local form = self.Parent.Parent
  if self.Checked then
    if form.cbtn_lock_self.Checked and form.cbtn_lock_other.Checked then
      self.Enabled = false
      self.Checked = false
      self.Enabled = true
      nx_execute("custom_sender", "custom_exchange_ok")
    else
      self.Enabled = false
      self.Checked = false
      self.Enabled = true
      local gui = nx_value("gui")
      local text = ""
      if nx_int(0) == nx_int(form.cbtn_lock_self.Checked) then
        text = "ui_weisuodingxianjiaoyi"
      elseif nx_int(0) == nx_int(form.cbtn_lock_other.Checked) then
        text = "ui_dengdaiduifangjiaoyi"
      end
      text = gui.TextManager:GetText(text)
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(text, 2)
      end
    end
  else
    nx_execute("custom_sender", "custom_exchange_ok")
  end
end
function on_self_exchange_view_operat(grid, optype, view_ident, index)
  local gui = nx_value("gui")
  if not nx_is_valid(grid) then
    return 1
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local form = grid.ParentForm
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return 1
  end
  if optype == "createview" then
    GoodsGrid:GridClear(grid)
    local target_name = nx_widestr(view:QueryProp("ExchangeTarget"))
    if is_strangeness(target_name) then
      target_name = target_name .. nx_widestr("(")
      target_name = target_name .. nx_widestr(gui.TextManager:GetText("ui_exchange_relation"))
      target_name = target_name .. nx_widestr(")")
    end
    form.label_name_other.HtmlText = nx_widestr(target_name)
  elseif optype == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "additem" then
    GoodsGrid:ViewUpdateItem(grid, index)
  elseif optype == "delitem" then
    GoodsGrid:ViewDeleteItem(grid, index)
  elseif optype == "updateitem" then
    GoodsGrid:ViewUpdateItem(grid, index)
  end
  if optype == "updateview" then
    local islock = view:QueryProp("ExchangeIsLock")
    form.cbtn_lock_self.Enabled = false
    form.cbtn_lock_self.Checked = nx_int(islock)
    form.cbtn_lock_self.Enabled = true
    local isok = view:QueryProp("ExchangeIsOk")
    form.cbtn_ok_self.Enabled = false
    form.cbtn_ok_self.Checked = nx_int(isok)
    form.cbtn_ok_self.Enabled = true
    local read_only = false
    if nx_int(islock) == nx_int(1) then
      read_only = true
    end
    form.ipt_3.ReadOnly = read_only
    form.ipt_4.ReadOnly = read_only
    form.ipt_5.ReadOnly = read_only
    if nx_int(1) == nx_int(islock) then
      form.lbl_18.Visible = true
      form.ipt_3.ShadowColor = "0,255,255,255"
    else
      form.lbl_18.Visible = false
      form.ipt_3.ShadowColor = "255,255,255,255"
    end
  end
  cover_goods_grid(VIEWPORT_SELFEXCHANGE)
  return 1
end
function on_other_exchange_view_operat(grid, optype, view_ident, index)
  if not nx_is_valid(grid) then
    return 1
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return 1
  end
  local form = grid.ParentForm
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return 1
  end
  if optype == "createview" then
    GoodsGrid:GridClear(grid)
    local target_name = view:QueryProp("ExchangeTarget")
    form.label_name_self.Text = target_name
  elseif optype == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "additem" then
    GoodsGrid:ViewUpdateItem(grid, index)
  elseif optype == "delitem" then
    GoodsGrid:ViewDeleteItem(grid, index)
  elseif optype == "updateitem" then
    GoodsGrid:ViewUpdateItem(grid, index)
  end
  if optype == "updateview" then
    local islock = view:QueryProp("ExchangeIsLock")
    form.cbtn_lock_other.Enabled = false
    form.cbtn_lock_other.Checked = nx_int(islock)
    form.cbtn_lock_other.Enabled = true
    local isok = view:QueryProp("ExchangeIsOk")
    form.cbtn_ok_other.Enabled = false
    form.cbtn_ok_other.Checked = nx_int(isok)
    form.cbtn_ok_other.Enabled = true
    if nx_int(1) == nx_int(islock) then
      form.lbl_15.Visible = true
      form.ipt_3.ShadowColor = "0,255,255,255"
    else
      form.lbl_15.Visible = false
      form.ipt_3.ShadowColor = "255,255,255,255"
    end
    local money = view:QueryProp("ExchangeMoney")
    local ding, liang, wen = trans_price(nx_number(money))
    form.ipt_0.Text = nx_widestr(nx_string(ding))
    form.ipt_1.Text = nx_widestr(nx_string(liang))
    form.ipt_2.Text = nx_widestr(nx_string(wen))
  end
  return 1
end
function close_on_click(self)
  util_show_form("form_stage_main\\form_exchange", false)
  nx_execute("custom_sender", "custom_exchange_cancel")
  return 1
end
function on_exchange_grid_select(grid)
  local gui = nx_value("gui")
  local selected_index = grid:GetSelectItemIndex()
  local view_index = grid:GetBindIndex(selected_index)
  if nx_execute("animation", "check_has_animation", nx_string("BoxShow"), nx_int(selected_index)) then
    nx_execute("animation", "del_animation", nx_string("BoxShow"))
  end
  if gui.GameHand:IsEmpty() then
    return
  end
  if not grid:IsEmpty(selected_index) then
    return
  end
  if gui.GameHand.Type == GHT_VIEWITEM and grid.typeid > 0 then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local src_pos = nx_int(gui.GameHand.Para2)
    local amount = nx_int(gui.GameHand.Para3)
    nx_execute("custom_sender", "custom_exchange_add_item", src_viewid, src_pos, amount, grid.typeid, view_index)
    gui.GameHand:ClearHand()
  end
end
function on_exchange_grid_right_click(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local view_index = grid:GetBindIndex(index)
  nx_execute("custom_sender", "custom_exchange_remove_item", view_index)
end
function on_mousein_grid(self, index)
  if self:IsEmpty(index) then
    return 0
  end
  local item_data = self.Data:GetChild(nx_string(index))
  if not nx_is_valid(item_data) then
    return 0
  end
  nx_execute("tips_game", "show_goods_tip", item_data, self:GetMouseInItemLeft() + 32, self:GetMouseInItemTop(), 32, 32, self.ParentForm)
end
function on_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function trans_price(price)
  local price_ding = nx_int64(price / 1000000)
  local temp = nx_int64(price - price_ding * 1000000)
  local price_liang = nx_int64(temp / 1000)
  local price_wen = nx_int64(temp - price_liang * 1000)
  return price_ding, price_liang, price_wen
end
function cover_goods_grid(viewport)
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) then
    nx_execute("form_stage_main\\form_bag", "refresh_lock_item", form_bag)
  end
end
