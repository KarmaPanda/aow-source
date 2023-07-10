require("share\\view_define")
require("define\\gamehand_type")
require("share\\client_custom_define")
require("share\\itemtype_define")
require("util_functions")
local WEAPON_CARD_INDEX_NONE = 0
local WEAPON_CARD_INDEX_BLADE = 1
local WEAPON_CARD_INDEX_SWORD = 2
local WEAPON_CARD_INDEX_THORN = 3
local WEAPON_CARD_INDEX_DBLADE = 4
local WEAPON_CARD_INDEX_DSWORD = 5
local WEAPON_CARD_INDEX_DTHORN = 6
local WEAPON_CARD_INDEX_ROD = 7
local WEAPON_CARD_INDEX_COSH = 8
local WEAPON_CARD_INDEX_BOW = 9
local WEAPON_CARD_INDEX_MIN = WEAPON_CARD_INDEX_BLADE
local WEAPON_CARD_INDEX_MAX = WEAPON_CARD_INDEX_BOW
local ClientMsg = {
  MSG_HEADER = CLIENT_CUSTOMMSG_FURNITURE,
  SUBMSG_REQ_OPEN_WEAPON_RACK = 26,
  SUBMSG_REQ_PUSH_WEAPON_CARD = 27,
  SUBMSG_REQ_POP_WEAPON_CARD = 28
}
local ServerSubMsg = {
  SUBMSG_ALL_DATA = 1,
  SUBMSG_PUSHED_CARD = 2,
  SUBMSG_POPED_CARD = 3
}
function main_form_init(form)
  if not nx_is_valid(form) then
    return
  end
  form.Fixed = false
  return
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Top = (gui.Height - form.Height) / 2 - 40
  return
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
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
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
  return
end
function on_imagegrid_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not gui.GameHand:IsEmpty() and gui.GameHand.Type == GHT_VIEWITEM then
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
    if not IsMatchedPos(viewobj, grid.DataSource) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "home_jiaju_001")
      return
    end
    if viewobj:QueryProp("BindStatus") ~= 1 then
      local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
      if not nx_is_valid(dialog) then
        return
      end
      local tips_str = util_text("ui_home_weaponrack_warning")
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(tips_str))
      dialog:ShowModal()
      dialog.Left = (gui.Width - dialog.Width) / 2
      dialog.Top = (gui.Height - dialog.Height) / 2
      local res = nx_wait_event(100000000, dialog, "confirm_return")
      if res ~= "ok" then
        gui.GameHand:ClearHand()
        return
      end
    end
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    if not nx_find_custom(form, "WeaponRackNpc") then
      return
    end
    game_visual:CustomSend(nx_int(ClientMsg.MSG_HEADER), nx_int(ClientMsg.SUBMSG_REQ_PUSH_WEAPON_CARD), form.WeaponRackNpc, nx_int(src_viewid), nx_int(src_pos), nx_int(grid.DataSource))
    gui.GameHand:ClearHand()
  end
  return
end
function on_imagegrid_rightclick_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if not nx_find_custom(form, "WeaponRackNpc") then
    return
  end
  game_visual:CustomSend(nx_int(ClientMsg.MSG_HEADER), nx_int(ClientMsg.SUBMSG_REQ_POP_WEAPON_CARD), form.WeaponRackNpc, nx_int(grid.DataSource))
  return
end
function on_imagegrid_mousein_grid(grid, index)
  if not nx_find_custom(grid, "card_config_id") or grid.card_config_id == nil then
    return
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return WEAPON_CARD_INDEX_NONE
  end
  local item_type = ItemQuery:GetItemPropByConfigID(nx_string(grid.card_config_id), "ItemType")
  nx_execute("tips_game", "show_tips_common", grid.card_config_id, item_type, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), form)
  return
end
function on_imagegrid_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
  return
end
function IsMatchedPos(item, pos)
  if not nx_is_valid(item) then
    return false
  end
  if nx_number(pos) < WEAPON_CARD_INDEX_MIN or nx_number(pos) > WEAPON_CARD_INDEX_MAX then
    return false
  end
  local pos_index = GetMatchedPos(item)
  if nx_number(pos_index) == nx_number(WEAPON_CARD_INDEX_NONE) or nx_number(pos_index) ~= nx_number(pos) then
    return false
  end
  return true
end
function GetMatchedPos(item)
  if not nx_is_valid(item) then
    return WEAPON_CARD_INDEX_NONE
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return WEAPON_CARD_INDEX_NONE
  end
  local config_id = nx_execute("util_static_data", "get_prop_in_object", item, "ConfigID")
  local script = ItemQuery:GetItemPropByConfigID(config_id, "script")
  if nx_string(script) == nx_string("CardItem") then
    local collect_card_manager = nx_value("CollectCardManager")
    if not nx_is_valid(collect_card_manager) then
      return WEAPON_CARD_INDEX_NONE
    end
    local card_id = item:QueryProp("CardID")
    local card_info_table = {}
    card_info_table = collect_card_manager:GetCardInfo(card_id)
    local length = table.getn(card_info_table)
    if nx_number(length) < nx_number(12) then
      return WEAPON_CARD_INDEX_NONE
    end
    local main_type = card_info_table[2]
    if nx_number(main_type) ~= nx_number(1) then
      return WEAPON_CARD_INDEX_NONE
    end
    local item_type = nx_number(card_info_table[4])
    if ITEMTYPE_WEAPON_BLADE == item_type then
      return WEAPON_CARD_INDEX_BLADE
    elseif ITEMTYPE_WEAPON_SWORD == item_type then
      return WEAPON_CARD_INDEX_SWORD
    elseif ITEMTYPE_WEAPON_THORN == item_type then
      return WEAPON_CARD_INDEX_THORN
    elseif ITEMTYPE_WEAPON_SBLADE == item_type then
      return WEAPON_CARD_INDEX_DBLADE
    elseif ITEMTYPE_WEAPON_SSWORD == item_type then
      return WEAPON_CARD_INDEX_DSWORD
    elseif ITEMTYPE_WEAPON_STHORN == item_type then
      return WEAPON_CARD_INDEX_DTHORN
    elseif ITEMTYPE_WEAPON_STUFF == item_type then
      return WEAPON_CARD_INDEX_ROD
    elseif ITEMTYPE_WEAPON_COSH == item_type then
      return WEAPON_CARD_INDEX_COSH
    elseif ITEMTYPE_WEAPON_BOW == item_type then
      return WEAPON_CARD_INDEX_BOW
    else
      return WEAPON_CARD_INDEX_NONE
    end
  end
  return WEAPON_CARD_INDEX_NONE
end
function handle_message(sub_msg, ...)
  local arg_num = table.getn(arg)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  if ServerSubMsg.SUBMSG_ALL_DATA == sub_msg then
    if arg_num < 1 then
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
    form.Visible = true
    form:Show()
    form.WeaponRackNpc = nx_object(arg[1])
    for i = 2, arg_num - 1, 2 do
      local card_index = arg[i]
      local control_name = "imagegrid_" .. nx_string(card_index)
      local imagegrid = form:Find(control_name)
      if nx_is_valid(imagegrid) then
        local card_config_id = arg[i + 1]
        local photo = ItemQuery:GetItemPropByConfigID(nx_string(card_config_id), nx_string("Photo"))
        imagegrid:AddItem(0, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
        imagegrid.card_config_id = card_config_id
      end
    end
  elseif ServerSubMsg.SUBMSG_PUSHED_CARD == sub_msg then
    if arg_num < 2 then
      return
    end
    local form = nx_value(nx_current())
    if not nx_is_valid(form) then
      return
    end
    local card_index = arg[1]
    local control_name = "imagegrid_" .. nx_string(card_index)
    local imagegrid = form:Find(control_name)
    if nx_is_valid(imagegrid) then
      local card_config_id = arg[2]
      local photo = ItemQuery:GetItemPropByConfigID(nx_string(card_config_id), nx_string("Photo"))
      imagegrid:AddItem(0, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
      imagegrid.card_config_id = card_config_id
    end
  elseif ServerSubMsg.SUBMSG_POPED_CARD == sub_msg then
    if arg_num < 1 then
      return
    end
    local form = nx_value(nx_current())
    if not nx_is_valid(form) then
      return
    end
    local card_index = arg[1]
    local control_name = "imagegrid_" .. nx_string(card_index)
    local imagegrid = form:Find(control_name)
    if nx_is_valid(imagegrid) then
      imagegrid:Clear()
      imagegrid.card_config_id = nil
    end
  end
  return
end
