require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("const_define")
require("util_functions")
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function on_btn_close_click(btn)
  local form_talk = nx_value("form_stage_main\\form_small_game\\form_itemminigameresult")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2 + gui.Height / 15
end
function on_main_form_close(form)
  nx_destroy(form)
end
function forminit(conunt, ConfigID, bEneAward, bMaterialAward, bNumAward, bRankAward)
  local ItemQuery = nx_value("ItemQuery")
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_small_game\\form_itemminigameresult")
  if not nx_is_valid(ItemQuery) or not nx_is_valid(gui) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  form.item_name.Text = nx_widestr(gui.TextManager:GetFormatText(nx_string(ConfigID)))
  local item_type = nx_number(ItemQuery:GetItemPropByConfigID(nx_string(ConfigID), "ItemType"))
  if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
    photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(ConfigID), "Photo")
  else
    photo = ItemQuery:GetItemPropByConfigID(nx_string(ConfigID), nx_string("Photo"))
  end
  if nx_int(bEneAward) > nx_int(0) then
    form.mltbox_award:AddHtmlText(gui.TextManager:GetText("12555"), -1)
  end
  if nx_int(bMaterialAward) > nx_int(0) then
    form.mltbox_award:AddHtmlText(gui.TextManager:GetText("12556"), -1)
  end
  if nx_int(bNumAward) > nx_int(0) then
    form.mltbox_award:AddHtmlText(gui.TextManager:GetText("12557"), -1)
  end
  if nx_int(bRankAward) > nx_int(0) then
    form.mltbox_award:AddHtmlText(gui.TextManager:GetText("12558"), -1)
  end
  form.item_grid.BackImage = photo
  form.item_grid:AddItem(0, photo, nx_widestr(ConfigID), 1, -1)
end
function on_item_grid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_item_grid_mousein_grid(grid, index)
  local item_config = nx_string(grid:GetItemName(index))
  if item_config == "" then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
  if bExist == false then
    return
  end
  local item_name = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Name"))
  local item_type = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("ItemType"))
  local item_sellPrice1 = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("sellPrice1"))
  local photo = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Photo"))
  local prop_array = {}
  prop_array.ConfigID = nx_string(item_config)
  prop_array.ItemType = nx_int(item_type)
  prop_array.SellPrice1 = nx_int(item_sellPrice1)
  prop_array.Photo = nx_string(photo)
  prop_array.PZKey = nx_string(item_key)
  if not nx_is_valid(grid.Data) then
    grid.Data = nx_create("ArrayList", nx_current())
  end
  grid.Data:ClearChild()
  for prop, value in pairs(prop_array) do
    nx_set_custom(grid.Data, prop, value)
  end
  grid.Data.is_static = true
  nx_execute("tips_game", "show_goods_tip", grid.Data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
