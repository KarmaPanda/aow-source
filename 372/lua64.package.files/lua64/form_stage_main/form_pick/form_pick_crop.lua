require("share\\view_define")
require("util_gui")
local MAX_DROP_BOX_CAPACITY = 16
local ITEMCOUNT_PER_PAGE = 4
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  form.grid_items.typeid = VIEWPORT_CROP_BOX
  form.grid_items.canselect = false
  form.grid_items.candestroy = false
  form.grid_items.cansplit = false
  form.grid_items.canlock = false
  form.grid_items.canarrange = false
  form.grid_items.add_item_callback_file = nx_current()
  form.grid_items.add_item_callback_func = "update_item_info"
  form.nCurrentPage = 1
  form.nMaxPage = MAX_DROP_BOX_CAPACITY / ITEMCOUNT_PER_PAGE
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_CROP_BOX, form, nx_current(), "on_viewport_change")
  end
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form)
  end
end
function on_btn_close_click(btn)
  local gui = nx_value("gui")
  gui:Delete(btn.Parent)
end
function on_viewport_change(form, optype, view_ident, index)
  refresh_all_item_info(form)
end
function on_btn_pageup_click(btn)
  local form = btn.Parent
  if form.nCurrentPage > 1 then
    form.nCurrentPage = form.nCurrentPage - 1
    refresh_all_item_info(form)
  end
end
function on_btn_pagedown_click(btn)
  local form = btn.Parent
  if form.nCurrentPage < form.nMaxPage then
    form.nCurrentPage = form.nCurrentPage + 1
    refresh_all_item_info(form)
  end
end
function on_btn_pick_click(btn)
  nx_execute("custom_sender", "custom_pick_all_crop")
end
function on_grid_items_select_changed(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local view_index = grid:GetBindIndex(index)
  nx_execute("custom_sender", "custom_pick_crop", view_index)
end
function on_grid_items_mousein_grid(grid, index)
  local GoodsGrid = nx_value("GoodsGrid")
  local item_data
  if nx_is_valid(GoodsGrid) then
    item_data = GoodsGrid:GetItemData(grid, index)
  end
  nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_grid_items_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function refresh_all_item_info(form)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_CROP_BOX))
  if not nx_is_valid(view) then
    return
  end
  local view_items = view:GetViewObjList()
  if table.getn(view_items) == 0 then
    return
  end
  local max_page = math.floor(table.getn(view_items) / ITEMCOUNT_PER_PAGE)
  if table.getn(view_items) % ITEMCOUNT_PER_PAGE > 0 then
    max_page = max_page + 1
  end
  if max_page < form.nCurrentPage then
    form.nCurrentPage = max_page
  end
  if form.nCurrentPage == 1 then
    form.nCurrentPage = 1
  end
  form.nMaxPage = max_page
  local start_index = (form.nCurrentPage - 1) * ITEMCOUNT_PER_PAGE + 1
  local end_index = form.nCurrentPage * ITEMCOUNT_PER_PAGE
  local grid_index = 0
  for view_index = start_index, end_index do
    form.grid_items:SetBindIndex(grid_index, view_index)
    grid_index = grid_index + 1
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:ViewRefreshGrid(form.grid_items)
  end
  refresh_all_btn(form)
end
function update_item_info(grid, grid_index)
  local view_index = grid:GetBindIndex(grid_index)
  if view_index < 0 then
    return
  end
  local game_client = nx_value("game_client")
  local gui = nx_value("gui")
  local view = game_client:GetView(nx_string(VIEWPORT_CROP_BOX))
  if not nx_is_valid(view) then
    return
  end
  local item = view:GetViewObj(nx_string(view_index))
  if not nx_is_valid(item) then
    return
  end
  local name_id = item:QueryProp("Name")
  local photo = item:QueryProp("Photo")
  grid:AddItem(grid_index, photo, nx_widestr(""), 0, 0)
  grid:ShowItemAddInfo(grid_index, true)
  grid:SetItemInfo(grid_index, gui.TextManager:GetText("name_id"))
end
function refresh_all_btn(form)
  form.btn_pageup.Enabled = true
  form.btn_pagedown.Enabled = true
  if form.nCurrentPage <= 1 then
    form.btn_pageup.Enabled = false
  end
  if form.nCurrentPage >= form.nMaxPage then
    form.btn_pagedown.Enabled = false
  end
  local page_show = nx_string(nx_int(form.nCurrentPage)) .. "/" .. nx_string(nx_int(form.nMaxPage))
  form.lbl_page_show.Text = nx_widestr(page_show)
end
