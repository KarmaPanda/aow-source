require("const_define")
require("util_functions")
require("custom_sender")
require("util_gui")
require("tips_data")
require("role_composite")
require("share\\client_custom_define")
require("define\\request_type")
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
end
function on_main_form_close(form)
end
function on_btn_gui_ze_click(btn)
  util_show_form("form_stage_main\\form_newhongbao\\form_newhongbao_guize", true)
end
function on_btn_gain_2_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local pack_id = form.imagegrid:GetItemMark(0)
  custom_pick_daypacket(2)
  form:Close()
end
function on_imagegrid_mousein_grid(grid, index)
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == nx_string("") then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(item_config)
  item.ItemType = get_ini_prop("share\\Item\\tool_item.ini", nx_string(item_config), "ItemType", "0")
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_server_msg(submsg, ...)
  if submsg == 1 then
    local index = nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_item", REQUESTTYPE_DAY_PACKET, "", 120)
  elseif submsg == 2 then
    local redpacket = nx_value("RedPacket")
    if not nx_is_valid(redpacket) then
      return
    end
    local form = util_get_form("form_stage_main\\form_newhongbao\\form_newhongbao", true, false)
    if not nx_is_valid(form) then
      return
    end
    local imagegrid = form.imagegrid
    local item = nx_string(arg[1])
    local photo = get_item_info(item, "photo")
    imagegrid:AddItem(0, photo, nx_widestr(item), 1, nx_string(arg[1]))
    form.Visible = true
    form:Show()
  end
end
function get_item_info(configid, prop)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return ""
  end
  if not ItemQuery:FindItemByConfigID(nx_string(configid)) then
    return ""
  end
  return ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string(prop))
end
