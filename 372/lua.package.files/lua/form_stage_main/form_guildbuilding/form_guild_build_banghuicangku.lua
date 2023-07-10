require("util_gui")
require("custom_sender")
require("util_functions")
require("share\\view_define")
require("define\\gamehand_type")
require("form_stage_main\\form_main\\form_main_centerinfo")
local FORM_NAME = "form_stage_main\\form_guildbuilding\\form_guild_build_banghuicangku"
local FORM_CONTRIBUTE_NAME = "form_stage_main\\form_guildbuilding\\form_guild_build_banghuicangku_contributemoneyconfirm"
local FORM_PUTITEM_NAME = "form_stage_main\\form_guildbuilding\\form_guild_build_banghuicangku_putitemconfirm"
local FORM_CONTRIBUTE_ERROR_NAME = "form_stage_main\\form_guildbuilding\\form_guild_build_banghuicangku_contributemoneyerror"
local FORM_PLAYER_BAG_NAME = "form_stage_main\\form_bag"
function main_form_init(form)
  form.mouse_index = -1
  form.depot_npc = nil
end
function on_main_form_open(form)
  form.Fixed = false
  form.goods_grid.typeid = VIEWPORT_GUILD_DEPOT
  form.goods_grid.canselect = true
  form.goods_grid.candestroy = true
  form.goods_grid.cansplit = true
  form.goods_grid.canlock = true
  form.goods_grid.canarrange = true
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_GUILD_DEPOT, form.goods_grid, FORM_NAME, "on_view_operat")
  end
  refresh_goods_grid_index(form)
end
function on_main_form_close(form)
  nx_execute("freshman_help", "form_on_close_callback", FORM_NAME)
  local databinder = nx_value("data_binder")
  databinder:DelViewBind(form.goods_grid)
  nx_destroy(form)
  nx_execute("tips_game", "hide_tip", form)
  nx_set_value(FORM_NAME, nx_null())
  local bag_form = nx_value(FORM_PLAYER_BAG_NAME)
  if nx_is_valid(bag_form) and bag_form.Visible == true then
    nx_execute(FORM_PLAYER_BAG_NAME, "auto_show_hide_bag")
  end
end
function on_btn_close_click(btn)
  nx_execute("util_gui", "util_show_form", FORM_NAME, false)
end
function on_goods_grid_select_changed(grid, index)
  local form = grid.ParentForm
  local gui = nx_value("gui")
  if gui.GameHand:IsEmpty() then
    if nx_execute("animation", "check_has_animation", nx_string("ShopBoxShow"), nx_int(selected_index)) then
      nx_execute("animation", "del_animation", nx_string("ShopBoxShow"))
    end
    if not grid:IsEmpty(index) then
      local item_view_index = grid:GetBindIndex(index)
      local photo = grid:GetItemImage(index)
      local amount = grid:GetItemNumber(index)
      gui.GameHand:SetHand(GHT_VIEWITEM, photo, nx_string(grid.typeid), nx_string(item_view_index), nx_string(amount), nx_string(form.depot_npc))
    end
  elseif gui.GameHand.Type == GHT_VIEWITEM then
    local src_view_id = nx_number(gui.GameHand.Para1)
    local src_view_index = nx_number(gui.GameHand.Para2)
    local src_amount = nx_number(gui.GameHand.Para3)
    local src_name = nx_string(gui.GameHand.Para4)
    local game_client = nx_value("game_client")
    local item_obj = game_client:GetViewObj(nx_string(src_view_id), nx_string(src_view_index))
    if not nx_is_valid(item_obj) then
      gui.GameHand:ClearHand()
      return
    end
    if item_obj:QueryProp("LockStatus") >= 1 or 1 <= item_obj:QueryProp("CantDepot") or 1 <= item_obj:QueryProp("BindStatus") then
      gui.GameHand:ClearHand()
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("1354"), 2)
      end
      return
    end
    local goods_grid = nx_value("GoodsGrid")
    if nx_is_valid(goods_grid) and goods_grid:IsToolBoxViewport(nx_int(src_view_id)) then
      show_put_item_confirm_form(form, nx_int(src_view_id), nx_int(src_view_index), nx_int(src_amount), nx_int(VIEWPORT_GUILD_DEPOT), nx_int(grid:GetBindIndex(index)))
      gui.GameHand:ClearHand()
    elseif nx_string(src_view_id) == nx_string(VIEWPORT_GUILD_DEPOT) then
      nx_execute("custom_sender", "custom_move_item_from_guilddepot_to_guilddepot", nx_int(src_view_id), nx_int(src_view_index), nx_int(src_amount), nx_int(VIEWPORT_GUILD_DEPOT), nx_int(grid:GetBindIndex(index)), form.depot_npc)
      gui.GameHand:ClearHand()
    end
  end
end
function on_goods_grid_mousein_grid(grid, index)
  local form = grid.ParentForm
  form.mouse_index = index
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local item_data = GoodsGrid:GetItemData(grid, index)
  nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_goods_grid_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.mouse_index = -1
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_contribute_money_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  show_contribute_money_confirm_form(form)
end
function on_view_operat(grid, optype, view_ident, index)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  local form = grid.ParentForm
  if optype == "createview" then
    GoodsGrid:ViewRefreshGrid(grid)
  elseif optype == "deleteview" then
    GoodsGrid:ViewRefreshGrid(grid)
    gui:Delete(grid.Parent)
  elseif optype == "additem" then
    GoodsGrid:ViewUpdateItem(grid, index)
  elseif optype == "delitem" then
    GoodsGrid:ViewDeleteItem(grid, index)
  elseif optype == "updateitem" then
    GoodsGrid:ViewUpdateItem(grid, index)
  end
end
function on_Upgrade_guild_capital(...)
  if table.getn(arg) < 1 then
    return 1
  end
  local capital = nx_int(arg[1])
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local ding = math.floor(nx_number(capital) / 1000000)
  local liang = math.floor(nx_number(capital) % 1000000 / 1000)
  local wen = math.floor(nx_number(capital) % 1000)
  local text = nx_widestr("0")
  if 0 < ding then
    text = nx_widestr(nx_int(ding))
  end
  form.lbl_ding_count.Text = text
  text = nx_widestr("0")
  if 0 < liang then
    text = nx_widestr(nx_int(liang))
  end
  form.lbl_liang_count.Text = text
  text = nx_widestr("0")
  if 0 < wen then
    text = nx_widestr(nx_int(wen))
  end
  form.lbl_wen_count.Text = text
end
function on_Reveive_Contribute_Money_Ack(...)
  if table.getn(arg) < 2 then
    return 1
  end
  local capital = nx_int(arg[1])
  local result = nx_int(arg[2])
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if nx_number(result) == 0 then
    show_Contribute_money_error_form(capital)
  end
end
function refresh_goods_grid_index(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local viewport = game_client:GetView(nx_string(VIEWPORT_GUILD_DEPOT))
  if not nx_is_valid(viewport) then
    return
  end
  local grid_count = viewport:QueryProp("BaseCap")
  form.lbl_capability.Text = nx_widestr(grid_count)
  form.goods_grid.ClomnNum = nx_int(10)
  form.goods_grid.RowNum = nx_int(grid_count / 10)
  for view_index = 1, grid_count do
    form.goods_grid:SetBindIndex(view_index - 1, view_index)
  end
  reset_form_size(form)
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:ViewRefreshGrid(form.goods_grid)
  end
end
function reset_form_size(form)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  form.groupscrollbox.IsEditMode = true
  local bag_total_size = form.goods_grid.ClomnNum * form.goods_grid.RowNum
  local grid_GridWidth = form.goods_grid.GridWidth
  local grid_GridHeight = form.goods_grid.GridHeight
  local cols = 10
  local rows = nx_int(bag_total_size / cols)
  if bag_total_size % cols ~= 0 then
    rows = rows + 1
  end
  local grid_offset_x = 12
  local grid_offset_y = 10
  local grid_index = 0
  local posstr = nx_string("")
  for row = 0, rows - 1 do
    for col = 0, cols - 1 do
      grid_index = grid_index + 1
      if bag_total_size < grid_index then
        break
      end
      local left = col * (grid_GridWidth + grid_offset_x) + grid_offset_x
      local top = row * (grid_GridHeight + grid_offset_y) + grid_offset_y
      posstr = posstr .. nx_string(left) .. "," .. nx_string(top) .. ";"
    end
  end
  form.goods_grid.GridsPos = posstr
  local grid_w = cols * (grid_GridWidth + grid_offset_x) + grid_offset_x + 3
  local grid_h = rows * (grid_GridHeight + grid_offset_y) + grid_offset_y + 3
  form.goods_grid.Width = grid_w
  form.goods_grid.Height = grid_h
  form.goods_grid.ViewRect = "0,0," .. grid_w .. "," .. grid_h
  form.goods_grid.Left = 5
  form.groupbox_capical.Width = form.goods_grid.Width
  form.groupbox_capical.Left = (form.Width - form.goods_grid.Width) / 2
  form.groupscrollbox.IsEditMode = false
  form.groupscrollbox.HasVScroll = true
  form.groupscrollbox.VScrollBar.Value = 0
end
function show_contribute_money_confirm_form(form)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", FORM_CONTRIBUTE_NAME, true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local game_client = nx_value("game_client")
  local player_obj = game_client:GetPlayer()
  local capital_type_2 = player_obj:QueryProp("CapitalType2")
  nx_set_value("configID", "CapitalType1")
  nx_set_value("MaxValue", capital_type_2)
  nx_set_value("contribute", 1.5)
  dialog.Left = (gui.Desktop.Width - dialog.Width) / 2
  dialog.Top = (gui.Desktop.Height - dialog.Height) / 2
  local guild_depot_npc = form.depot_npc
  dialog:ShowModal()
  local result, capital = nx_wait_event(100000000, dialog, "form_guild_depot_contributemoneyconfirm_return")
  if result == "ok" then
    nx_execute("custom_sender", "custom_contribute_money", capital, guild_depot_npc)
  end
  return -1
end
function show_put_item_confirm_form(form, src_view_id, src_view_index, src_amount, dest_view_id, dest_view_index)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", FORM_PUTITEM_NAME, true, false)
  dialog.Left = (gui.Desktop.Width - dialog.Width) / 2
  dialog.Top = (gui.Desktop.Height - dialog.Height) / 2
  local item_name = ""
  local game_client = nx_value("game_client")
  local toolbox_view = game_client:GetView(nx_string(src_view_id))
  if nx_is_valid(toolbox_view) then
    local viewobj = toolbox_view:GetViewObj(nx_string(src_view_index))
    if nx_is_valid(viewobj) then
      local configid = viewobj:QueryProp("ConfigID")
      item_name = nx_widestr(gui.TextManager:GetText(nx_string(configid)))
    end
  end
  dialog.mltbox_info.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_guilddepot_putitem_confirm", nx_string(item_name)))
  local guild_depot_npc = form.depot_npc
  dialog:ShowModal()
  local result = nx_wait_event(100000000, dialog, "form_guild_depot_putitemconfirm_return")
  if result == "ok" then
    nx_execute("custom_sender", "custom_put_item_from_toolbox_to_guilddepot", src_view_id, src_view_index, src_amount, dest_view_id, dest_view_index, guild_depot_npc)
  end
end
function show_Contribute_money_error_form(capital)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", FORM_CONTRIBUTE_ERROR_NAME, true, false)
  dialog.Left = (gui.Desktop.Width - dialog.Width) / 2
  dialog.Top = (gui.Desktop.Height - dialog.Height) / 2
  dialog.mltbox_info.HtmlText = nx_widestr(gui.TextManager:GetText("ui_guilddepot_contributemoney_error"))
  dialog:ShowModal()
end
function log(info)
  local form_main_chat_logic = nx_value("form_main_chat")
  if nx_is_valid(form_main_chat_logic) then
    form_main_chat_logic:AddChatInfoEx(nx_widestr(info), 11, false)
  end
end
