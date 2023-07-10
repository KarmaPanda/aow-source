require("share\\view_define")
require("goods_grid")
require("util_gui")
require("util_functions")
require("form_stage_main\\form_charge_shop\\charge_shop_define")
require("share\\capital_define")
HDEPOT_BACKMSG_CAPICITY = 1
HDEPOT_BACKMSG_CLOSE_FORM = 2
local DEPOT_BASE_CAPACITY = 24
local DSD_ASK_ACPICTY = 4
local DSD_BUY_ACPICTY = 5
local DSD_BUY_ACPICTY_ITEM = 6
local SUB_MSG_ITEM_BUY = 10
local FORM_NAME = "form_stage_main\\form_home\\form_home_depot"
function open_form()
  util_auto_show_hide_form(FORM_NAME)
end
function main_form_init(self)
  self.Fixed = false
  locked = false
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = 0
  self.goods_grid.typeid = VIEWPORT_HOME_DEPOT
  self.goods_grid.beginindex = 1
  self.goods_grid.endindex = 40
  for i = 1, DEPOT_BASE_CAPACITY do
    self.goods_grid:SetBindIndex(nx_int(i - 1), nx_int(i))
  end
  self.goods_grid.capicity = 0
  self.goods_grid.canselect = true
  self.goods_grid.candestroy = true
  self.goods_grid.cansplit = true
  self.goods_grid.canlock = true
  self.goods_grid.canarrange = true
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_HOME_DEPOT, self.goods_grid, FORM_NAME, "on_view_operat")
  view_grid_fresh_all(self.goods_grid)
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
  self.next_type = 0
  return 1
end
function main_form_close(self)
  local databinder = nx_value("data_binder")
  databinder:DelViewBind(self.goods_grid)
  nx_destroy(self)
end
function on_btn_close_click(self)
  local form = self.Parent
  form:Close()
end
function tidy_btn_click(self)
  goods_grid_fresh(self.goods_grid)
end
function get_depot_basecap()
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\depotbox.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local sec_index = ini:FindSectionIndex("Capacity")
  if sec_index < 0 then
    return 0
  end
  local depot_size = ini:ReadInteger(sec_index, "BaseCap", "36")
  return nx_number(depot_size)
end
function add_size()
  local form_depot = nx_value(FORM_NAME)
  if not nx_is_valid(form_depot) then
    return
  end
  local next_type = form_depot.next_type
  if next_type == -1 then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local depot_item_list = {
    "home_expand_01*1,home_bm_01*50",
    "home_expand_01*1,home_bm_02*30"
  }
  local depot_cap = {6, 6}
  local strlst = util_split_string(depot_item_list[next_type + 1], ",")
  local item1_str = util_split_string(strlst[1], "*")
  local item2_str = util_split_string(strlst[2], "*")
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("sys_home_bag_open_01")
  gui.TextManager:Format_AddParam(gui.TextManager:GetText(item1_str[1]))
  gui.TextManager:Format_AddParam(nx_int(item1_str[2]))
  gui.TextManager:Format_AddParam(gui.TextManager:GetText(item2_str[1]))
  gui.TextManager:Format_AddParam(nx_int(item2_str[2]))
  gui.TextManager:Format_AddParam(nx_int(depot_cap[next_type + 1]))
  local text = gui.TextManager:Format_GetText()
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "send_home_depot_msg", 54, SUB_MSG_ITEM_BUY)
  end
end
function goods_grid_select(self, index)
  local gui = nx_value("gui")
  local form = self.Parent
  local limit_index = form.goods_grid.capicity
  local bind_index = self:GetBindIndex(index)
  if nx_int(bind_index) > nx_int(limit_index) then
    add_size()
    return
  end
  local goodsgrid = nx_value("GoodsGrid")
  if not nx_is_valid(goodsgrid) then
    return
  end
  goodsgrid:ViewGridOnSelectItem(self, index)
end
function lock_btn_click(self)
end
function destroy_btn_click(self)
end
function bag_grid_select(self)
  local goodsgrid = nx_value("GoodsGrid")
  if not nx_is_valid(goodsgrid) then
    return
  end
  goodsgrid:ViewGridOnSelectItem(self, -1)
end
function destroy_btn_click(self)
  local gui = nx_value("gui")
  gui.GameHand:SetHand(GHT_FUNC, GHT_FUNC_ICON.destroy, "destroy", "", "", "")
end
function split_btn_click(self)
  local gui = nx_value("gui")
  gui.GameHand:SetHand(GHT_FUNC, GHT_FUNC_ICON.split, "split", "", "", "")
end
function on_view_operat(grid, optype, view_ident, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  if optype == "createview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "updateview" then
  elseif optype == "additem" then
    GoodsGrid:ViewUpdateItem(grid, index)
  elseif optype == "delitem" then
    GoodsGrid:ViewDeleteItem(grid, index)
  elseif optype == "updateitem" then
    GoodsGrid:ViewUpdateItem(grid, index)
  end
  return 1
end
function on_mousein_grid(self, index)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local item_data = GoodsGrid:GetItemData(self, index)
  nx_execute("tips_game", "show_goods_tip", item_data, self:GetMouseInItemLeft() + 32, self:GetMouseInItemTop(), 32, 32, self.ParentForm)
end
function on_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_goods_grid_rightclick_grid(self, index)
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) and form_bag.Visible then
    local view_index = self:GetBindIndex(index)
    local view_obj = get_view_item(self.typeid, view_index)
    if nx_is_valid(view_obj) then
      local view_id = ""
      local goods_grid = nx_value("GoodsGrid")
      if nx_is_valid(goods_grid) then
        view_id = goods_grid:GetToolBoxViewport(view_obj)
        goods_grid:ViewGridPutToAnotherView(self, view_id)
      end
    end
  end
end
function on_igrid_smalldepot_select_changed(self)
  local goodsgrid = nx_value("GoodsGrid")
  if not nx_is_valid(goodsgrid) then
    return
  end
  goodsgrid:ViewGridOnSelectItem(self, -1)
end
function show_new_adddepotbox(self, addbox, beginindex, endindex)
  if nx_is_valid(addbox) then
    addbox:Close()
  else
    local gui = nx_value("gui")
    addbox = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. "form_stage_main\\form_small16_depot" .. ".xml")
    nx_execute("form_stage_main\\form_small16_depot", "form_adddepot_bind", addbox, VIEWPORT_DEPOT, beginindex, endindex)
    addbox:Show()
  end
  return addbox
end
function on_captial_changed(label, propname, proptype, value)
  if proptype == "int" then
    local money_value = nx_int64(value)
    local money1 = 0
    local money2 = 0
    local money3 = 0
    if 9999 < money_value then
      money1 = money_value / 10000
      money_value = money_value % 10000
    end
    if 99 < money_value then
      money2 = money_value / 100
      money_value = money_value % 100
    end
    if money_value ~= 0 then
      money3 = money_value
    end
    if 0 < money1 then
      if money2 < 10 then
        money2 = "0" .. nx_string(nx_int(money2))
      else
        money2 = nx_string(nx_int(money2))
      end
      if money3 < 10 then
        money3 = "0" .. nx_string(nx_int(money3))
      else
        money3 = nx_string(nx_int(money3))
      end
      label.Text = nx_widestr(nx_string(nx_int(money1)) .. "," .. money2 .. "," .. money3)
    elseif 0 < money2 then
      if money3 < 10 then
        money3 = "0" .. nx_string(nx_int(money3))
      else
        money3 = nx_string(nx_int(money3))
      end
      label.Text = nx_widestr(nx_string(nx_int(money2)) .. "," .. money3)
    else
      label.Text = nx_widestr(nx_string(nx_int(money3)))
    end
  end
end
function on_btn_upgrade_click(btn)
  util_show_form("form_stage_main\\form_depot_upgrade", true)
end
function on_btn_item_arrange_click(btn)
  local form_depot = btn.ParentForm
  local n_basecap = form_depot.goods_grid.capicity
  nx_execute("custom_sender", "custom_arrange_item", VIEWPORT_DEPOT, 1, n_basecap)
end
function on_btn_save_click(btn)
  local form = btn.ParentForm
  nx_execute("form_stage_main\\form_depot_capital", "show_form_save", form.maxsilver, form.maxcard, form.cursilver, form.curcard)
end
function on_btn_get_click(btn)
  local form = btn.ParentForm
  nx_execute("form_stage_main\\form_depot_capital", "show_form_putout", form.cursilver, form.curcard)
end
function on_btn_shop_click(btn)
  util_open_charge_shop(CHARGE_NORMAL_SHOP)
end
function update_grid()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.goods_grid
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  GoodsGrid:GridClear(grid)
  local depot_size = grid.capicity
  grid.DrawCover = ""
  for i = 1, nx_number(depot_size) do
    grid:CoverItem(i - 1, false)
  end
  grid.DrawCover = "gui\\common\\imagegrid\\icon_lock2.png"
  for i = nx_number(depot_size + 1), DEPOT_BASE_CAPACITY do
    grid:CoverItem(i - 1, true)
  end
  for i = 1, DEPOT_BASE_CAPACITY do
    grid:SetBindIndex(nx_int(i - 1), nx_int(i))
    view_grid_on_update_item(grid, i)
  end
end
function on_btn_item_arrange_click(btn)
  local form_depot = btn.ParentForm
  if not nx_is_valid(form_depot) then
    return
  end
  local n_basecap = form_depot.goods_grid.capicity
  nx_execute("custom_sender", "custom_arrange_item", VIEWPORT_HOME_DEPOT, 1, n_basecap)
end
function on_server_msg(submsg, ...)
  if nx_int(submsg) == nx_int(HDEPOT_BACKMSG_CAPICITY) then
    local depot_size = arg[1]
    local next_type = arg[2]
    local form_depot = nx_value(FORM_NAME)
    if not nx_is_valid(form_depot) then
      open_form()
      form_depot = nx_value(FORM_NAME)
    end
    if form_depot.Visible == false then
      form_depot.Visible = true
    end
    form_depot.goods_grid.capicity = depot_size
    update_grid()
    form_depot.next_type = next_type
  elseif nx_int(submsg) == nx_int(HDEPOT_BACKMSG_CLOSE_FORM) then
    local form_depot = nx_value(FORM_NAME)
    if nx_is_valid(form_depot) then
      form_depot:Close()
    end
  end
end
