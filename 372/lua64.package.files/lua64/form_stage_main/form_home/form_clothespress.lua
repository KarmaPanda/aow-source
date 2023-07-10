require("util_functions")
require("util_gui")
require("util_static_data")
require("define\\gamehand_type")
require("share\\itemtype_define")
require("share\\client_custom_define")
local ClientMsg = {
  MSG_HEADER = CLIENT_CUSTOMMSG_FURNITURE,
  SUBMSG_REQ_OPEN_CLOTHESPRESS = 29,
  SUBMSG_REQ_PUSH_CLOTH = 30,
  SUBMSG_REQ_POP_CLOTH = 31
}
local ServerSubMsg = {
  SUBMSG_ALL_DATA = 1,
  SUBMSG_PUSHED = 2,
  SUBMSG_POPED = 3
}
function on_main_form_init(form)
  if not nx_is_valid(form) then
    return
  end
  form.Fixed = false
  form.LimitInScreen = true
  return
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    form:Close()
  end
  form.AbsLeft = form.Width / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  gui.Desktop:ToFront(form)
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
  return
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
  return
end
function close_form()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  return
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
  return
end
function on_ImageControlGrid_type_rightclick_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == "" then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if not nx_find_custom(form, "ClothespressNpc") or not nx_find_custom(form, "FurnLevel") then
    return
  end
  if index >= form.FurnLevel then
    return
  end
  game_visual:CustomSend(nx_int(ClientMsg.MSG_HEADER), nx_int(ClientMsg.SUBMSG_REQ_POP_CLOTH), form.ClothespressNpc, nx_int(index))
  return
end
function on_ImageControlGrid_type_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if gui.GameHand:IsEmpty() then
    return
  end
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) ~= "" then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "home_item_failed_02")
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  if gui.GameHand.Type == GHT_VIEWITEM then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local src_pos = nx_int(gui.GameHand.Para2)
    local src_amount = nx_int(gui.GameHand.Para3)
    local game_client = nx_value("game_client")
    if not nx_is_valid(game_client) then
      return
    end
    local view = game_client:GetView(nx_string(src_viewid))
    if not nx_is_valid(view) then
      return
    end
    local viewobj = view:GetViewObj(nx_string(src_pos))
    if not nx_is_valid(viewobj) then
      return
    end
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    if not nx_find_custom(form, "ClothespressNpc") or not nx_find_custom(form, "FurnLevel") then
      return
    end
    if index >= form.FurnLevel then
      return
    end
    game_visual:CustomSend(nx_int(ClientMsg.MSG_HEADER), nx_int(ClientMsg.SUBMSG_REQ_PUSH_CLOTH), form.ClothespressNpc, nx_int(src_viewid), nx_int(src_pos), nx_int(index))
    gui.GameHand:ClearHand()
  end
  return
end
function on_ImageControlGrid_type_mousein_grid(grid, index)
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == "" then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(item_config)
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
  return
end
function on_ImageControlGrid_type_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
  return
end
function CanOperation()
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return false
  end
  return HomeManager:IsMyHome()
end
function handle_message(sub_msg, ...)
  if not CanOperation() then
    return
  end
  local arg_num = table.getn(arg)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  if ServerSubMsg.SUBMSG_ALL_DATA == sub_msg then
    if arg_num < 2 then
      return
    end
    local form = nx_value(nx_current())
    if nx_is_valid(form) then
      form:Close()
    end
    form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
    if not nx_is_valid(form) then
      return
    end
    local grid = form.ImageControlGrid_type
    if not nx_is_valid(grid) then
      form:Close()
      return
    end
    local num_of_grid = grid.RowNum * grid.ClomnNum
    local FurnLevel = nx_number(arg[1])
    if FurnLevel <= 0 or num_of_grid < FurnLevel then
      form:Close()
      return
    end
    form.FurnLevel = FurnLevel
    for i = FurnLevel, num_of_grid - 1 do
      grid:CoverItem(i, true)
    end
    form.ClothespressNpc = nx_object(arg[2])
    for i = 3, arg_num - 1, 2 do
      local index = arg[i]
      local config_id = arg[i + 1]
      if 0 <= index and FurnLevel > index and config_id ~= "" then
        local art_pack = ItemQuery:GetItemPropByConfigID(nx_string(config_id), nx_string("ArtPack"))
        local photo = nx_string(item_static_query(nx_int(art_pack), "Photo", STATIC_DATA_ITEM_ART))
        grid:AddItem(index, photo, nx_widestr(config_id), nx_int(0), nx_int(-1))
        grid:ShowItemAddInfo(index, nx_int(0), false)
      end
    end
    form.Visible = true
    form:Show()
  elseif ServerSubMsg.SUBMSG_PUSHED == sub_msg then
    if arg_num < 2 then
      return
    end
    local form = nx_value(nx_current())
    if not nx_is_valid(form) then
      return
    end
    local grid = form.ImageControlGrid_type
    if not nx_is_valid(grid) then
      return
    end
    local index = arg[1]
    local config_id = arg[2]
    if 0 <= index and index < form.FurnLevel and config_id ~= "" then
      local art_pack = ItemQuery:GetItemPropByConfigID(nx_string(config_id), nx_string("ArtPack"))
      local photo = nx_string(item_static_query(nx_int(art_pack), "Photo", STATIC_DATA_ITEM_ART))
      grid:AddItem(index, photo, nx_widestr(config_id), nx_int(0), nx_int(-1))
      grid:ShowItemAddInfo(index, nx_int(0), false)
    end
  elseif ServerSubMsg.SUBMSG_POPED == sub_msg then
    if arg_num < 1 then
      return
    end
    local form = nx_value(nx_current())
    if not nx_is_valid(form) then
      return
    end
    local grid = form.ImageControlGrid_type
    if not nx_is_valid(grid) then
      return
    end
    local index = arg[1]
    grid:DelItem(index)
  end
  return
end
