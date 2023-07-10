require("util_functions")
require("custom_sender")
require("goods_grid")
require("share\\view_define")
require("custom_sender")
require("share\\itemtype_define")
function main_form_init(form)
  form.Fixed = true
  return 1
end
function on_main_form_open(form)
  for i = 1, 6 do
    form.buy_back_goods:SetBindIndex(nx_int(i - 1), nx_int(i))
  end
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_BUY_BACK, form, "form_stage_main\\form_shop\\form_buy_back", "on_view_operat")
  refresh_buy_back_item(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_view_operat(form, optype, view_ident, index)
  refresh_buy_back_item(form)
  return 1
end
function refresh_buy_back_item(self)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_BUY_BACK))
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:GridClear(self.buy_back_goods)
  end
  if not nx_is_valid(view) then
    return
  end
  local prop_table = {}
  local viewobj_list = view:GetViewObjList()
  for i, item in pairs(viewobj_list) do
    local index = nx_number(item.Ident)
    local proplist = item:GetPropList()
    for i, prop in pairs(proplist) do
      prop_table[prop] = item:QueryProp(prop)
    end
    local GoodsGrid = nx_value("GoodsGrid")
    if nx_is_valid(GoodsGrid) then
      local item_data = nx_create("ArrayList", nx_current())
      for prop, value in pairs(prop_table) do
        nx_set_custom(item_data, prop, value)
      end
      GoodsGrid:GridAddItem(self.buy_back_goods, index - 1, item_data)
    end
    self.buy_back_goods:SetBindIndex(index - 1, index)
  end
end
function form_grid_on_rightclick_grid(grid)
  local selected_index = grid:GetRBClickItemIndex()
  if grid:IsEmpty(selected_index) then
    return
  end
  local bindindex = grid:GetBindIndex(selected_index)
  nx_execute("custom_sender", "custom_buy_back", nx_int(bindindex))
end
function form_grid_on_select_changed(grid)
  local selected_index = grid:GetSelectItemIndex()
  if grid:IsEmpty(selected_index) then
    return
  end
  local bindindex = grid:GetBindIndex(selected_index)
  local game_client = nx_value("game_client")
  local otherstall_view = game_client:GetView(nx_string(VIEWPORT_BUY_BACK))
  local item = otherstall_view:GetViewObj(nx_string(bindindex))
  if not nx_is_valid(item) then
    return
  end
  local buy_money = item:QueryProp("SellPrice1") * 2 * item:QueryProp("Amount")
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  gui.TextManager:Format_SetIDName("ui_buy_back_confirm")
  gui.TextManager:Format_AddParam(buy_money)
  text = gui.TextManager:Format_GetText()
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_buy_back", nx_int(bindindex))
  end
end
function on_form_shop_goods_mousein_grid(self, index)
  if self:IsEmpty(index) then
    return 0
  end
  local bindindex = self:GetBindIndex(index)
  local game_client = nx_value("game_client")
  local game_gui = nx_value("gui")
  local otherstall_view = game_client:GetView(nx_string(VIEWPORT_BUY_BACK))
  local viewobj = otherstall_view:GetViewObj(nx_string(bindindex))
  if not nx_is_valid(viewobj) then
    return
  end
  viewobj.IsShop = false
  viewobj.is_static = false
  nx_execute("tips_game", "show_goods_tip", viewobj, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), 32, 32, self.ParentForm)
end
function on_form_shop_goods_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
