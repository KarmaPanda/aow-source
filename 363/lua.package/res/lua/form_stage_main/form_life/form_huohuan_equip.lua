require("share\\view_define")
require("define\\gamehand_type")
require("util_functions")
require("util_gui")
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local grid = self.imagegrid_equip
  grid:SetBindIndex(nx_int(0), nx_int(1))
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.Left = (gui.Desktop.Width - self.Width) / 2
    self.Top = (gui.Desktop.Height - self.Height) / 2
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_CHANGEEQUIPATT_BOX, self.imagegrid_equip, nx_current(), "on_view_operat")
  end
  nx_execute("util_gui", "ui_show_attached_form", self)
end
function on_main_form_close(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(VIEWPORT_CHANGEEQUIPATT_BOX)
  end
  ui_destroy_attached_form(self)
  nx_destroy(self)
  nx_execute("custom_sender", "custom_cancel_change_equip")
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function on_btn_help_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function on_main_form_active(form)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", form)
end
function on_imagegrid_equip_select_changed(grid, index)
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  local gamehand_type = game_hand.Type
  if gamehand_type == GHT_VIEWITEM then
    local view_id = nx_number(game_hand.Para1)
    local view_ident = nx_number(game_hand.Para2)
    nx_execute("custom_sender", "custom_add_change_equip", view_id, view_ident, grid:GetBindIndex(index))
    game_hand:ClearHand()
  end
end
function on_imagegrid_equip_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    nx_execute("tips_game", "show_text_tip", util_text("ui_huohuan_ep_tip"), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 150, grid.ParentForm)
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_CHANGEEQUIPATT_BOX))
  if not nx_is_valid(view) then
    return
  end
  local item = view:GetViewObj(nx_string(grid:GetBindIndex(index)))
  if not nx_is_valid(item) then
    return
  end
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_imagegrid_equip_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_cost_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    nx_execute("tips_game", "show_text_tip", util_text("ui_huohuan_it_tip"), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 150, grid.ParentForm)
    return
  end
  local ConfigID = grid.DataSource
  nx_execute("tips_game", "show_tips_by_config", ConfigID, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_imagegrid_cost_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_equip_rightclick_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  nx_execute("custom_sender", "custom_remove_change_equip", grid:GetBindIndex(index))
end
function on_btn_ok_click(btn)
  nx_execute("custom_sender", "custom_start_change_equip", 4)
end
function on_view_operat(grid, optype, view_ident, item_index, prop_name)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return
  end
  local fuse_formula_query = nx_value("FuseFormulaQuery")
  if not nx_is_valid(fuse_formula_query) then
    return
  end
  local form = grid.ParentForm
  grid:Clear()
  form.imagegrid_cost:Clear()
  form.lbl_equipname.Text = nx_widestr("")
  form.mltbox_cost:Clear()
  form.lbl_pic.BackImage = "gui\\language\\ChineseS\\huohuan\\lbl_bottom_ty.png"
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  local view_index = grid:GetBindIndex(0)
  local item = view:GetViewObj(nx_string(view_index))
  if nx_is_valid(item) then
    local photo = nx_execute("util_static_data", "queryprop_by_object", item, "Photo")
    grid:AddItem(0, photo, "", 1, -1)
    form.lbl_equipname.Text = tips_manager:GetItemBaseName(item)
    local wx_formula = fuse_formula_query:GetZbProperty(item)
    set_back_img(form, wx_formula)
    show_consumeitem(form, item)
  end
end
function set_back_img(form, wx_formula)
  local img = "gui\\language\\ChineseS\\huohuan\\lbl_bottom_ty.png"
  if wx_formula == "tai_ji" then
    img = "gui\\language\\ChineseS\\huohuan\\lbl_bottom_tj.png"
  elseif wx_formula == "yang_gang" then
    img = "gui\\language\\ChineseS\\huohuan\\lbl_bottom_yg.png"
  elseif wx_formula == "ying_rou" then
    img = "gui\\language\\ChineseS\\huohuan\\lbl_bottom_yr.png"
  end
  form.lbl_pic.BackImage = img
end
function show_consumeitem(form, item)
  local fuse_formula_query = nx_value("FuseFormulaQuery")
  if not nx_is_valid(fuse_formula_query) then
    return
  end
  local ItemsQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemsQuery) then
    return
  end
  local cost = fuse_formula_query:GetCost(item)
  if table.getn(cost) ~= 2 then
    return
  end
  local configid = cost[1]
  local num = cost[2]
  local photo = ItemsQuery:GetItemPropByConfigID(configid, "Photo")
  local grid = form.imagegrid_cost
  grid:Clear()
  grid:AddItem(0, photo, "", 1, -1)
  grid.DataSource = configid
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local max_count = nx_int(GoodsGrid:GetItemCount(configid))
  local ui_id = "ui_huohuan_cost"
  if max_count == nx_int(0) then
    ui_id = "ui_huohuan_cost_1"
  elseif max_count < nx_int(num) then
    ui_id = "ui_huohuan_cost_2"
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText(ui_id, nx_string(configid), nx_int(num))
  form.mltbox_cost:Clear()
  form.mltbox_cost:AddHtmlText(nx_widestr(text), -1)
end
function on_btn_duihuan_click(btn)
  nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_life\\form_huohuan_duihuan")
end
function clear()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
  end
end
