require("share\\view_define")
require("goods_grid")
require("util_gui")
require("util_functions")
require("form_stage_main\\form_charge_shop\\charge_shop_define")
require("share\\capital_define")
require("util_vip")
local DEPOT_CAPACITY = 136
local ADD_DEPOT_CAPACITY = 6
local DEPOT_BASE_CAPACITY = 72
local SMALL_DEPOT_MAX_CAPACITY = 16
local PAGE_COUNT = 3
local DSD_ASK_ACPICTY = 4
local DSD_BUY_ACPICTY = 5
local DSD_BUY_ACPICTY_ITEM = 6
function main_form_init(self)
  self.Fixed = false
  locked = false
  return 1
end
function FormatMoney(money_type, money_count)
  local retStr = nx_widestr("")
  if money_type ~= 1 and money_type ~= 2 or not (nx_number(money_count) >= nx_number(0)) then
    return retStr
  end
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return retStr
  end
  local gui = nx_value("gui")
  local tab_money = capital:SplitCapital(money_count, money_type)
  if table.getn(tab_money) == 3 then
    if nx_number(tab_money[1]) == nx_number(0) and nx_number(tab_money[2]) == nx_number(0) and nx_number(tab_money[3]) == nx_number(0) then
      return nx_widestr("0") .. gui.TextManager:GetText("ui_wen")
    end
    if nx_number(tab_money[1]) ~= nx_number(0) then
      retStr = retStr .. nx_widestr(tab_money[1]) .. gui.TextManager:GetText("ui_ding")
    end
    if nx_number(tab_money[2]) ~= nx_number(0) then
      retStr = retStr .. nx_widestr(tab_money[2]) .. gui.TextManager:GetText("ui_liang")
    end
    if nx_number(tab_money[3]) ~= nx_number(0) then
      retStr = retStr .. nx_widestr(tab_money[3]) .. gui.TextManager:GetText("ui_wen")
    end
    return nx_widestr(retStr)
  end
end
function main_form_open(self)
  nx_execute("custom_sender", "send_depot_msg", DSD_ASK_ACPICTY)
  local gui = nx_value("gui")
  self.AbsLeft = 0
  self.goods_grid.typeid = VIEWPORT_DEPOT
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
  self.igrid_smalldepot.typeid = VIEWPORT_ADDDEPOTBOX
  for i = 1, 6 do
    self.igrid_smalldepot:SetBindIndex(nx_int(i - 1), nx_int(i))
  end
  self.igrid_smalldepot.canselect = true
  self.igrid_smalldepot.candestroy = false
  self.igrid_smalldepot.cansplit = false
  self.igrid_smalldepot.canlock = false
  self.igrid_smalldepot.canarrange = false
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_DEPOT, self.goods_grid, "form_stage_main\\form_depot", "on_view_operat")
  databinder:AddViewBind(VIEWPORT_ADDDEPOTBOX, self.igrid_smalldepot, "form_stage_main\\form_depot", "on_view_operat")
  view_grid_fresh_all(self.goods_grid)
  view_grid_fresh_all(self.igrid_smalldepot)
  self.igrid_smalldepot.addbox1 = nil
  self.igrid_smalldepot.addbox2 = nil
  self.igrid_smalldepot.addbox3 = nil
  self.igrid_smalldepot.addbox4 = nil
  self.igrid_smalldepot.addbox5 = nil
  self.igrid_smalldepot.addbox6 = nil
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
  self.maxsilver = 0
  self.maxcard = 0
  self.needsilver = 0
  self.needcard = 0
  self.cursilver = 0
  self.curcard = 0
  self.next_type = 0
  self.next_type_item = 0
  self.next_type_newitem = 0
  self.next_type_silver = 0
  self.next_type_card = 0
  self.next_type_xiuwei = 0
  self.cur_page = 0
  set_depot_capital(self, true)
  update_page(self)
  return 1
end
function main_form_close(self)
  local databinder = nx_value("data_binder")
  databinder:DelViewBind(self.goods_grid)
  databinder:DelViewBind(self.igrid_smalldepot)
  for i = 1, 6 do
    close_add_depot_by_index(self.igrid_smalldepot, i)
  end
  nx_destroy(self)
end
function close_form()
  local form = nx_value("form_stage_main\\form_depot")
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_close_click(self)
  local form = self.Parent
  util_show_form("form_stage_main\\form_depot", false)
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
function goods_grid_select(self, index)
  local gui = nx_value("gui")
  local form = self.Parent
  local limit_index = form.goods_grid.capicity
  local bind_index = self:GetBindIndex(index)
  if nx_int(bind_index) > nx_int(limit_index) then
    local form_prompt = nx_value("form_stage_main\\form_addpot")
    if nx_is_valid(form_prompt) then
      form_prompt:Close()
    end
    form_prompt = util_show_form("form_stage_main\\form_addpot", true)
    form_prompt.info_mltbox.HtmlText = gui.TextManager:GetText("ui_adddepot_text")
    form_prompt.next_type = form.next_type
    form_prompt.next_type_item = form.next_type_item
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
    if view_ident == VIEWPORT_ADDDEPOTBOX then
      close_add_depot_by_index(grid, index)
    end
  elseif optype == "updateitem" then
    GoodsGrid:ViewUpdateItem(grid, index)
  end
  set_depot_capital(grid.ParentForm, true)
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
function on_igrid_smalldepot_rightclick_grid(self, index)
  if self:IsEmpty(index) then
    return 0
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(self.typeid))
  if nx_is_valid(view) then
    local obj = view:GetViewObj(nx_string(index + 1))
    if nx_is_valid(obj) then
      local beginindex = obj:QueryProp("BeginPos")
      local endindex = obj:QueryProp("EndPos")
      if 0 < beginindex and beginindex < endindex then
        auto_show_and_hide_adddepot(self, index + 1, beginindex, endindex)
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
function on_btn_savegold_click(self)
  return 1
end
function on_btn_savesilver_click(self)
  return 1
end
function auto_show_and_hide_adddepot(self, index, beginindex, endindex)
  if index == 1 then
    self.addbox1 = show_new_adddepotbox(self, self.addbox1, beginindex, endindex)
  elseif index == 2 then
    self.addbox2 = show_new_adddepotbox(self, self.addbox2, beginindex, endindex)
  elseif index == 3 then
    self.addbox3 = show_new_adddepotbox(self, self.addbox3, beginindex, endindex)
  elseif index == 4 then
    self.addbox4 = show_new_adddepotbox(self, self.addbox4, beginindex, endindex)
  elseif index == 5 then
    self.addbox5 = show_new_adddepotbox(self, self.addbox5, beginindex, endindex)
  elseif index == 6 then
    self.addbox6 = show_new_adddepotbox(self, self.addbox6, beginindex, endindex)
  end
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
function close_add_depot_by_index(grid, index)
  if index == 1 and nx_is_valid(grid.addbox1) then
    grid.addbox1:Close()
  elseif index == 2 and nx_is_valid(grid.addbox2) then
    grid.addbox2:Close()
  elseif index == 3 and nx_is_valid(grid.addbox3) then
    grid.addbox3:Close()
  elseif index == 4 and nx_is_valid(grid.addbox4) then
    grid.addbox4:Close()
  elseif index == 5 and nx_is_valid(grid.addbox5) then
    grid.addbox5:Close()
  elseif index == 6 and nx_is_valid(grid.addbox6) then
    grid.addbox6:Close()
  end
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
function set_depot_capital(form, bInit)
  local game_client = nx_value("game_client")
  local box = game_client:GetView(nx_string(VIEWPORT_DEPOT))
  if not nx_is_valid(box) then
    return
  end
  if not box:FindProp("DepotLevel") then
    return
  end
  local level = box:QueryProp("DepotLevel")
  if level == 3 then
    form.btn_upgrade.Visible = false
  end
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return
  end
  local silver = nx_int64(box:QueryProp("DepotSilver"))
  form.mltbox_1.HtmlText = FormatMoney(CAPITAL_TYPE_SILVER, nx_int64(silver))
  local silver_card = nx_int64(box:QueryProp("DepotSilverCard"))
  form.mltbox_2.HtmlText = FormatMoney(CAPITAL_TYPE_SILVER_CARD, nx_int64(silver_card))
  form.btn_get.Enabled = silver > nx_int64(0) or silver_card > nx_int64(0)
  form.cursilver = silver
  form.curcard = silver_card
  if bInit then
    local max_silver, max_card, need_silver, need_card = 0, 0, 0, 0
    local ini = get_ini("share\\Rule\\depotbox.ini")
    if nx_is_valid(ini) then
      local index = ini:FindSectionIndex("LevelInfo")
      local info = ini:GetItemValueList(index, "info")
      local count = table.getn(info)
      for i = 1, count do
        local str = util_split_string(info[i], ",")
        if table.getn(str) == 5 and nx_int(str[1]) == nx_int(level) then
          max_silver = nx_int64(str[2])
          max_card = nx_int64(str[3])
          need_silver = nx_int64(str[4])
          need_card = nx_int64(str[5])
        end
      end
    end
    form.maxsilver = max_silver
    form.maxcard = max_card
    form.needsilver = need_silver
    form.needcard = need_card
  end
end
function update_page(form)
  form.lbl_page.Text = nx_widestr(form.cur_page + 1) .. nx_widestr("/") .. nx_widestr(PAGE_COUNT)
end
function on_btn_up_page_click(btn)
  local form = btn.ParentForm
  if form.cur_page <= 0 then
    return
  end
  form.cur_page = form.cur_page - 1
  update_grid()
  update_page(form)
end
function on_btn_next_page_click(btn)
  local form = btn.ParentForm
  if form.cur_page >= PAGE_COUNT - 1 then
    return
  end
  form.cur_page = form.cur_page + 1
  update_grid()
  update_page(form)
end
function update_grid()
  local form = nx_value("form_stage_main\\form_depot")
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
  local cur_size = depot_size - form.cur_page * 72
  if 72 < cur_size then
    cur_size = 72
  end
  grid.DrawCover = ""
  for i = 1, nx_number(cur_size) do
    grid:CoverItem(i - 1, false)
  end
  grid.DrawCover = "gui\\common\\imagegrid\\icon_lock2.png"
  for i = nx_number(cur_size + 1), 72 do
    grid:CoverItem(i - 1, true)
  end
  for i = 1, DEPOT_BASE_CAPACITY do
    local index = get_index(grid, i)
    grid:SetBindIndex(nx_int(i - 1), nx_int(index))
    view_grid_on_update_item(grid, index)
  end
end
function get_index(grid, index)
  local form = grid.ParentForm
  return nx_number(form.cur_page * DEPOT_BASE_CAPACITY + index)
end
function reflesh_form(form)
end
function on_server_msg(submsg, ...)
  local depot_size = arg[1]
  local next_type = arg[2]
  local next_type_item = arg[3]
  local next_type_newitem = arg[4]
  local next_type_silver = arg[5]
  local next_type_card = arg[6]
  local next_type_xiuwei = arg[7]
  local form_depot = nx_value("form_stage_main\\form_depot")
  if nx_is_valid(form_depot) and form_depot.Visible then
    form_depot.goods_grid.capicity = depot_size
    update_grid()
    form_depot.next_type = next_type
    form_depot.next_type_item = next_type_item
    form_depot.next_type_newitem = next_type_newitem
    form_depot.next_type_silver = next_type_silver
    form_depot.next_type_card = next_type_card
    form_depot.next_type_xiuwei = next_type_xiuwei
  end
end
