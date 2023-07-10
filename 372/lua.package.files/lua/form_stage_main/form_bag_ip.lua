require("util_gui")
require("util_vip")
require("share\\view_define")
require("define\\gamehand_type")
IP_DEFAULT_NUM = 5
IP_DEFAULT_VIP_NUM = 15
IP_PRICE = 10000
IP_MAX_NUM = 32
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("itemprotect_rec", self, nx_current(), "on_rec_change")
    databinder:AddViewBind(VIEWPORT_EQUIP_TOOL, self, nx_current(), "on_rec_change")
    databinder:AddViewBind(VIEWPORT_TOOL, self, nx_current(), "on_rec_change")
    databinder:AddViewBind(VIEWPORT_MATERIAL_TOOL, self, nx_current(), "on_rec_change")
    databinder:AddViewBind(VIEWPORT_TASK_TOOL, self, nx_current(), "on_rec_change")
    databinder:AddViewBind(VIEWPORT_EQUIP, self, nx_current(), "on_rec_change")
  end
end
function on_main_form_close(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("itemprotect_rec", self)
    databinder:DelViewBind(self)
  end
  nx_destroy(self)
end
function on_imagegrid_ip_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local row_index = grid:GetBindIndex(index)
  local form_bag_logic = nx_value("form_bag_logic")
  if not nx_is_valid(form_bag_logic) then
    return
  end
  local item = form_bag_logic:get_item(row_index)
  if not nx_is_valid(item) then
    return
  end
  local form = grid.ParentForm
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, form)
end
function on_imagegrid_ip_mouseout_grid(grid, index)
  local form = grid.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function on_imagegrid_ip_select_changed(grid, index)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form_bag_logic = nx_value("form_bag_logic")
  if not nx_is_valid(form_bag_logic) then
    return
  end
  local game_hand = gui.GameHand
  if GHT_VIEWITEM ~= game_hand.Type then
    return
  end
  local view_id = game_hand.Para1
  if not is_protected_view(view_id) then
    return
  end
  local view_index = game_hand.Para2
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local item = game_client:GetViewObj(nx_string(view_id), nx_string(view_index))
  if not nx_is_valid(item) then
    return
  end
  if not form_bag_logic:item_can_be_protected(item) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("24020"))
    return
  end
  local tips_form = false
  if not form_bag_logic:is_protected_item(item) and is_full(grid) then
    tips_form = true
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return
    end
    local text = util_format_string("ui_item_protect_tips_03", IP_PRICE)
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if "ok" ~= res then
      game_hand:ClearHand()
      return
    end
  end
  if not tips_form then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return
    end
    local text = util_text("ui_item_protect_tips_04")
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if "ok" ~= res then
      game_hand:ClearHand()
      return
    end
  end
  nx_execute("custom_sender", "custom_add_protect_item", view_id, view_index)
  game_hand:ClearHand()
end
function on_imagegrid_ip_rightclick_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local row_index = grid:GetBindIndex(index)
  local form_bag_logic = nx_value("form_bag_logic")
  if not nx_is_valid(form_bag_logic) then
    return
  end
  local item = form_bag_logic:get_item(row_index)
  if not nx_is_valid(item) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = util_text("ui_item_protect_tips_01")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if "ok" == res then
    local uid = item:QueryProp("UniqueID")
    nx_execute("custom_sender", "custom_del_protect_item", nx_string(uid))
  end
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function is_protected_view(view_id)
  view_id = nx_number(view_id)
  return view_id == VIEWPORT_EQUIP or view_id == VIEWPORT_TOOL or view_id == VIEWPORT_EQUIP_TOOL or view_id == VIEWPORT_MATERIAL_TOOL or view_id == VIEWPORT_TASK_TOOL or false
end
function on_rec_change(form, recordname, optype, row, clomn)
  local form_bag_logic = nx_value("form_bag_logic")
  if nx_is_valid(form_bag_logic) then
    form_bag_logic:refresh_ip_grid(form.imagegrid_ip)
  end
end
function is_full(grid)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local is_vip_normal = nx_execute("util_vip", "is_vip", client_player, VT_NORMAL)
  if not nx_is_valid(grid) then
    return false
  end
  local grid_size = grid.RowNum * grid.ClomnNum
  local used_num = 0
  for i = 0, grid_size - 1 do
    if not grid:IsEmpty(i) then
      used_num = used_num + 1
    end
  end
  if is_vip_normal then
    return used_num >= IP_DEFAULT_VIP_NUM
  else
    return used_num >= IP_DEFAULT_NUM
  end
end
