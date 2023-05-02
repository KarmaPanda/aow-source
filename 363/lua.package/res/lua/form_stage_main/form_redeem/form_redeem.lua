require("share\\view_define")
require("util_gui")
function main_form_init(form)
  form.Fixed = true
  form.cur_page = 1
  form.max_page = 3
  return 1
end
function on_main_form_open(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local grid = form.icg_goods
  local count = grid.RowNum * grid.ClomnNum
  for i = 1, count do
    grid:SetBindIndex(nx_int(i - 1), nx_int(i))
  end
  grid.typeid = VIEWPORT_PUNISH_BOX
  grid.canselect = true
  grid.candestroy = false
  grid.cansplit = false
  grid.canlock = false
  grid.canarrange = false
  grid.Transparent = true
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_PUNISH_BOX, grid, "form_stage_main\\form_redeem\\form_redeem", "on_goods_view_oper")
  form.lbl_page.Text = nx_widestr(form.cur_page .. "/" .. nx_string(form.max_page))
  local CLIENT_SUB_FRESH_PRICE = 3
  nx_execute("custom_sender", "custom_msg_pk_punish", nx_int(CLIENT_SUB_FRESH_PRICE))
  return 1
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_goods_view_oper(grid, op_type, view_ident, index)
  if not nx_is_valid(grid) then
    return false
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return false
  end
  local form = grid.ParentForm
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return false
  end
  if op_type == "createview" then
    do_wait_to_refresh_grid(form)
  elseif op_type == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif op_type == "additem" then
    do_wait_to_refresh_grid(form)
  elseif op_type == "delitem" then
    GoodsGrid:ViewDeleteItem(grid, index)
  elseif op_type == "updateitem" then
    do_wait_to_refresh_grid(form)
  end
  return true
end
function do_wait_to_refresh_grid(form)
  if nx_running(nx_current(), "wait_to_refresh_grid", form) then
    nx_kill(nx_current(), "wait_to_refresh_grid", form)
  end
  nx_execute(nx_current(), "wait_to_refresh_grid", form)
end
function wait_to_refresh_grid(form)
  nx_pause(0.1)
  if not nx_is_valid(form) then
    return false
  end
  refresh_grid(form)
end
function on_icg_goods_mousein_grid(grid, index)
  local form = grid.ParentForm
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local item_data = GoodsGrid:GetItemData(grid, index)
  if nx_is_valid(item_data) then
    nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
  else
    nx_execute("tips_game", "hide_tip", grid.ParentForm)
  end
end
function on_icg_goods_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_pageup_click(btn)
  local form = btn.ParentForm
  if form.cur_page <= 1 then
    return
  end
  form.cur_page = form.cur_page - 1
  refresh_grid(form)
  form.lbl_page.Text = nx_widestr(form.cur_page .. "/" .. nx_string(form.max_page))
end
function on_btn_pagedown_click(btn)
  local form = btn.ParentForm
  if nx_int(form.cur_page) < nx_int(form.max_page) then
    form.cur_page = form.cur_page + 1
    refresh_grid(form)
  end
  form.lbl_page.Text = nx_widestr(form.cur_page .. "/" .. nx_string(form.max_page))
end
function refresh_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.icg_goods
  grid:Clear()
  grid:SetSelectItemIndex(-1)
  local count = grid.RowNum * grid.ClomnNum
  local base = nx_int((form.cur_page - 1) * count)
  for i = 1, count do
    grid:SetBindIndex(nx_int(i - 1), nx_int(i) + base)
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:ViewRefreshGrid(grid)
  end
  show_redeem_info(form)
end
function show_redeem_info(form)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_PUNISH_BOX))
  if not nx_is_valid(view) then
    return
  end
  if not view:FindRecord("punish_item_rec") then
    return
  end
  if view:GetRecordRows("punish_item_rec") <= 0 then
    return
  end
  local viewobj_list = view:GetViewObjList()
  for i, item_obj in pairs(viewobj_list) do
    local item_uid = item_obj:QueryProp("UniqueID")
    local row = view:FindRecordRow("punish_item_rec", 0, nx_string(item_uid))
    if 0 <= row then
      local enemy_name = view:QueryRecord("punish_item_rec", row, 1)
      local price = view:QueryRecord("punish_item_rec", row, 2)
      show_grid_redeem_info(form.icg_goods, item_obj.Ident, price, enemy_name)
    end
  end
end
function on_icg_goods_click_addbutton(self, grid_index, btn_index)
  local form = self.ParentForm
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_PUNISH_BOX))
  if not nx_is_valid(view) then
    return
  end
  local view_index = self:GetBindIndex(grid_index)
  local item_obj = view:GetViewObj(nx_string(view_index))
  if not nx_is_valid(item_obj) then
    return
  end
  local item_config = item_obj:QueryProp("ConfigID")
  local item_uid = item_obj:QueryProp("UniqueID")
  local sub_msg = btn_index + 1
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local info = gui.TextManager:GetFormatText("ui_sns_redeem_affirm_" .. nx_string(sub_msg), item_config)
  dialog.mltbox_info:Clear()
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), nx_int(-1))
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_msg_pk_punish", sub_msg, item_uid)
  end
end
function show_grid_redeem_info(grid, view_index, price, enemy_name)
  local gui = nx_value("gui")
  local gird_index = get_gridindex(grid, view_index)
  local price_text = nx_execute("util_functions", "trans_capital_string", nx_int(price))
  grid:SetItemAddInfo(gird_index, 1, gui.TextManager:GetText("ui_redeem_price"))
  grid:ShowItemAddInfo(gird_index, 1, true)
  grid:ShowItemAddInfo(gird_index, 2, true)
  grid:SetItemAddInfo(gird_index, 3, gui.TextManager:GetText("ui_redeem_person"))
  grid:ShowItemAddInfo(gird_index, 3, true)
  grid:SetItemAddInfo(gird_index, 4, nx_widestr(price_text))
  grid:ShowItemAddInfo(gird_index, 4, true)
  grid:SetItemAddInfo(gird_index, 5, nx_widestr(enemy_name))
  grid:ShowItemAddInfo(gird_index, 5, true)
end
function get_gridindex(grid, view_index)
  local count = grid.RowNum * grid.ClomnNum
  for i = 1, count do
    local bind_index = grid:GetBindIndex(i - 1)
    if nx_number(bind_index) == nx_number(view_index) then
      return i - 1
    end
  end
  return -1
end
