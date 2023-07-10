require("util_gui")
require("util_functions")
require("share\\itemtype_define")
local g_form_name = "form_stage_main\\form_give_item"
function on_main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("GiveItemRec", form, "form_stage_main\\form_give_item", "on_give_item_rec_refresh")
  end
end
function on_main_form_close(form)
  nx_execute("custom_sender", "custom_give_item", 2, -1, form.npc)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function refresh_form(form)
  if not nx_is_valid(form) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.groupbox_1.Visible = false
  form.groupbox_2.Visible = false
  local g_lbl = {
    [1] = {
      form.groupbox_1,
      form.imagegrid_1,
      form.mltbox_2
    },
    [2] = {
      form.groupbox_2,
      form.imagegrid_2,
      form.mltbox_3
    }
  }
  local rownum = client_player:GetRecordRows("GiveItemRec")
  if rownum == 0 then
    util_show_form(g_form_name, false)
    return
  end
  for row = 1, rownum do
    local lbls = g_lbl[row]
    if lbls == nil then
      break
    end
    lbls[1].Visible = true
    local item_id = client_player:QueryRecord("GiveItemRec", row - 1, 0)
    local item_num = client_player:QueryRecord("GiveItemRec", row - 1, 1)
    local bExist = ItemQuery:FindItemByConfigID(item_id)
    if bExist then
      local item_type = nx_number(ItemQuery:GetItemPropByConfigID(item_id, "ItemType"))
      local photo = ""
      if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
        photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", item_id, "Photo")
      else
        photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
      end
      local name = gui.TextManager:GetFormatText(item_id)
      local tiemtype = ItemQuery:GetItemPropByConfigID(item_id, "ItemType")
      lbls[2]:AddItem(0, nx_string(photo), nx_widestr(item_id), nx_int(item_num), 0)
      lbls[3].HtmlText = name
    end
  end
end
function on_give_item_rec_refresh(form, recordname, optype, row, clomn)
  refresh_form(form)
end
function on_mousein_grid(lbl)
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local itemtype = nx_custom(lbl, "itemtype")
  local itemid = nx_custom(lbl, "itemid")
  nx_execute("tips_game", "show_tips_common", itemid, nx_number(itemtype), x, y, lbl.ParentForm)
end
function on_mouseout_grid(lbl)
  nx_execute("tips_game", "hide_tip", lbl.ParentForm)
end
function on_imagegrid_mousein_grid(grid, index)
  local prize_id = grid:GetItemName(nx_int(index))
  local prize_count = grid:GetItemNumber(nx_int(index))
  if nx_string(prize_id) == "" or nx_number(prize_count) <= 0 then
    return
  end
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  local ItemQuery = nx_value("ItemQuery")
  local tiemtype = ItemQuery:GetItemPropByConfigID(prize_id, "ItemType")
  nx_execute("tips_game", "show_tips_common", prize_id, nx_number(itemtype), x, y, grid.ParentForm)
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_item_select_changed(lbl)
  local form = lbl.ParentForm
  local group = nx_custom(lbl, "groupbox")
  group.Visible = false
  nx_execute("custom_sender", "custom_give_item", 0, nx_custom(lbl, "index"), form.npc)
end
function on_imagegrid_select_changed(grid, index)
  local form = grid.ParentForm
  local index = nx_int(grid.DataSource)
  nx_execute("custom_sender", "custom_give_item", 0, index, form.npc)
end
function on_btn_pick_all_click(btn)
  local form = btn.ParentForm
  nx_execute("custom_sender", "custom_give_item", 1, -1, form.npc)
end
function on_btn_mail_click(btn)
  local form = btn.ParentForm
  nx_execute("custom_sender", "custom_give_item", 2, -1, form.npc)
  form:Close()
end
function is_grid_empty(grid)
  local num = grid.RowNum * grid.ClomnNum
  if num <= 0 then
    return true
  end
  for i = 1, num do
    if not grid:IsEmpty(i - 1) then
      return false
    end
  end
  return true
end
