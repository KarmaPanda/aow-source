require("share\\view_define")
require("define\\gamehand_type")
require("share\\client_custom_define")
require("util_gui")
MSG_CS_ALCHEMY_BEGIN = 0
MSG_CS_ALCHEMY_CANCEL = 1
MSG_CS_ALCHEMY_ADD = 2
MSG_CS_ALCHEMY_RMV = 3
MSG_CS_ALCHEMY_CLOSE = 4
MSG_SC_ALCHEMY_SHOW_FORM = 0
MSG_SC_ALCHEMY_CANCEL_BTN = 1
MSG_SC_ALCHEMY_CLOSE_FORM = 2
local TotalCellCount = 30
local FORM_TITLE = {sh_ys = "ui_zhenqi2", sh_ds = "ui_zhenqi3"}
local FORM_IMAGEBACK = {
  sh_ys = "gui\\special\\ronghe\\bg_pbr_2.png",
  sh_ds = "gui\\special\\ronghe\\bg_pbr_1.png"
}
local FORM_IMAGEPER = {
  sh_ys = "gui\\special\\ronghe\\pbr_2.png",
  sh_ds = "gui\\special\\ronghe\\pbr_1.png"
}
function FormatMoney(money_count, money_type)
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
function main_form_init(self)
  self.Fixed = false
  self.jobid = nill
  self.guanyin = nill
  self.suiyin = nill
  self.price = nill
end
function on_form_open(self)
  setGridCount(self.goods_grid)
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_ALCHEMY, self.goods_grid, "form_stage_main\\form_life\\form_item_alchemy", "on_view_operat")
  self.lbl_guanyin.Text = nx_widestr(FormatMoney(self.guanyin, 2))
  self.lbl_suiyin.Text = nx_widestr(FormatMoney(self.suiyin, 1))
  self.btn_ok.Visible = true
  self.btn_cancel.Visible = false
  self.btn_ok.Enabled = false
  self.lbl_per.Text = nx_widestr("0%")
  self.pbar_per.Value = 0
  if nx_find_custom(self, "jobid") then
    local text = FORM_TITLE[nx_string(self.jobid)]
    self.lbl_title.Text = nx_widestr(util_text(text))
    self.pbar_per.BackImage = FORM_IMAGEBACK[nx_string(self.jobid)]
    self.pbar_per.ProgressImage = FORM_IMAGEPER[nx_string(self.jobid)]
  end
  self.cbtn_guanyin.Checked = false
  self.cbtn_suiyin.Checked = true
end
function on_form_close(self)
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  custom_alchemy_close()
  local databinder = nx_value("data_binder")
  databinder:DelViewBind(self.goods_grid)
  nx_destroy(self)
end
function on_goods_grid_select_changed(grid, index)
  local gui = nx_value("gui")
  local form = grid.ParentForm
  local selected_index = grid:GetSelectItemIndex()
  local playerCount = nx_int(grid.playerCount)
  if nx_number(selected_index) >= nx_number(playerCount) then
    gui.GameHand:ClearHand()
    return
  end
  local view_index = grid:GetBindIndex(selected_index)
  local gamehand_type = gui.GameHand.Type
  if gamehand_type == GHT_VIEWITEM then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local src_pos = nx_int(gui.GameHand.Para2)
    local src_amount = nx_int(gui.GameHand.Para3)
    local game_client = nx_value("game_client")
    local view = game_client:GetView(nx_string(src_viewid))
    local viewobj = view:GetViewObj(nx_string(src_pos))
    local lock_status = 0
    if nx_is_valid(viewobj) then
      lock_status = viewobj:QueryProp("LockStatus")
      if nx_int(lock_status) > nx_int(0) then
        nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7054"))
        return
      end
    end
    local client_player = game_client:GetPlayer()
    if nx_int(client_player:QueryProp("StallState")) == nx_int(2) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7040"))
      return
    end
    if not check_can_alchemy_item(viewobj) then
      return
    end
    gui.GameHand:ClearHand()
    custom_alchemy_add_item(src_viewid, src_pos, view_index)
  end
end
function on_goods_grid_rightclick_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local view_index = grid:GetBindIndex(index)
  custom_alchemy_remove_item(view_index)
end
function on_goods_grid_mousein_grid(grid, index)
  local GoodsGrid = nx_value("GoodsGrid")
  local item_data
  if nx_is_valid(GoodsGrid) then
    item_data = GoodsGrid:GetItemData(grid, index)
  end
  if nx_is_valid(item_data) then
    nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
  end
end
function on_goods_grid_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_view_operat(grid, optype, view_ident, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return 0
  end
  if optype == "createview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "updateview" then
    GoodsGrid:ViewUpdateItem(grid, index)
  elseif optype == "additem" then
    GoodsGrid:ViewUpdateItem(grid, index)
    update_form_by_viewchange(grid)
  elseif optype == "delitem" then
    GoodsGrid:ViewDeleteItem(grid, index)
    update_form_by_viewchange(grid)
  elseif optype == "updateitem" then
    GoodsGrid:ViewUpdateItem(grid, index)
  end
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local use_silvercard = 0
  if form.cbtn_guanyin.Checked then
    use_silvercard = 1
  end
  use_silvercard = 1
  custom_alchemy_item_begin(use_silvercard)
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  btn.Visible = false
  form.btn_ok.Visible = true
  custom_alchemy_item_cancel()
end
function on_cbtn_suiyin_checked_changed(btn)
  if btn.Checked then
    btn.ParentForm.cbtn_guanyin.Checked = false
  end
end
function on_cbtn_guanyin_checked_changed(btn)
  if btn.Checked then
    btn.ParentForm.cbtn_suiyin.Checked = false
  end
end
function setGridCount(grid)
  local playerSellCount = TotalCellCount
  local cellCount = TotalCellCount
  grid.typeid = VIEWPORT_ALCHEMY
  grid.beginindex = 1
  grid.endindex = nx_int(cellCount)
  grid.playerCount = playerSellCount
  local grid_index = 0
  for view_index = grid.beginindex, grid.endindex do
    grid:SetBindIndex(grid_index, view_index)
    grid_index = grid_index + 1
  end
  grid.canselect = false
  grid.candestroy = false
  grid.cansplit = false
  grid.canlock = false
  grid.canarrange = false
end
function getGridItemsPrice(grid)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local view = game_client:GetView(nx_string(grid.typeid))
  if not nx_is_valid(view) then
    return 0
  end
  local totleprice = 0
  for index = 0, TotalCellCount - 1 do
    local bind_index = grid:GetBindIndex(index)
    local viewobj = view:GetViewObj(nx_string(bind_index))
    if nx_is_valid(viewobj) then
      local itemprice = viewobj:QueryProp("SellPrice1") * viewobj:QueryProp("Amount")
      totleprice = totleprice + itemprice
    end
  end
  return totleprice
end
function update_form_by_viewchange(grid)
  local price = getGridItemsPrice(grid)
  local per_value = price / grid.ParentForm.price * 100
  local form = grid.ParentForm
  if 100 < per_value then
    per_value = 100
  end
  form.pbar_per.Value = per_value
  form.lbl_per.Text = nx_widestr(nx_string(per_value) .. "%")
  form.btn_ok.Enabled = per_value == 100
end
function check_can_alchemy_item(item)
  if not nx_is_valid(item) then
    return false
  end
  local itemtype = item:QueryProp("ItemType")
  if itemtype ~= 2082 then
    return false
  end
  return true
end
function custom_alchemy_item_begin(use_silvercard)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ALCHEMY_MSG), nx_int(MSG_CS_ALCHEMY_BEGIN), nx_int(use_silvercard))
end
function custom_alchemy_item_cancel()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ALCHEMY_MSG), nx_int(MSG_CS_ALCHEMY_CANCEL))
end
function custom_alchemy_add_item(src_viewid, src_pos, dest_pos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ALCHEMY_MSG), nx_int(MSG_CS_ALCHEMY_ADD), nx_int(src_viewid), nx_int(src_pos), nx_int(dest_pos))
end
function custom_alchemy_remove_item(src_pos)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ALCHEMY_MSG), nx_int(MSG_CS_ALCHEMY_RMV), nx_int(src_pos))
end
function custom_alchemy_close()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ALCHEMY_MSG), nx_int(MSG_CS_ALCHEMY_CLOSE))
end
function on_server_msg(...)
  local form_alchemy = util_get_form("form_stage_main\\form_life\\form_item_alchemy", true)
  if not nx_is_valid(form_alchemy) then
    return
  end
  local type = arg[1]
  if type == MSG_SC_ALCHEMY_SHOW_FORM then
    form_alchemy.jobid = nx_string(arg[2])
    form_alchemy.price = arg[3]
    form_alchemy.guanyin = arg[4]
    form_alchemy.suiyin = arg[5]
    util_show_form("form_stage_main\\form_life\\form_item_alchemy", true)
    nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
  elseif type == MSG_SC_ALCHEMY_CANCEL_BTN then
    local show_break = arg[2]
    if show_break == 1 then
      form_alchemy.btn_ok.Visible = false
      form_alchemy.btn_cancel.Visible = true
    elseif show_break == 0 then
      form_alchemy.btn_ok.Visible = true
      form_alchemy.btn_cancel.Visible = false
    end
  elseif type == MSG_SC_ALCHEMY_CLOSE_FORM then
    util_show_form("form_stage_main\\form_life\\form_item_alchemy", false)
    nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", false)
  end
end
