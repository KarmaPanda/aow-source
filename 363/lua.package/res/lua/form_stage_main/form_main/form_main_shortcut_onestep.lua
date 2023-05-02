require("const_define")
require("util_gui")
require("share\\view_define")
require("share\\itemtype_define")
require("custom_sender")
require("define\\shortcut_key_define")
require("tips_data")
require("form_stage_main\\switch\\switch_define")
require("util_role_prop")
local CHANGE_OLD_ID_1 = 0
local CHANGE_OLD_ID_2 = 1
local CHANGE_OLD_ID_3 = 2
local CHANGE_OLD_ID_4 = 3
local CHANGE_NEW_ID_1 = 100
local CHANGE_NEW_ID_2 = 101
local CHANGE_NEW_ID_3 = 102
local CHANGE_NEW_ID_4 = 103
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("ShortcutKey", "string", self, nx_current(), "on_shortcutkey_prop_change")
    databinder:AddRolePropertyBind("VipStatus", "int", self, nx_current(), "on_vip_change")
  end
  local grid = self.imagegrid_1
  for i = 1, grid.ClomnNum do
    local file = "gui\\mainform\\" .. nx_string(i) .. ".png"
    grid:AddItem(i - 1, file, "", 1, -1)
    grid:SetCoolType(i - 1, 652)
  end
  self.Visible = false
  self.show_equip = false
  return 1
end
function main_form_close(form)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:DelRolePropertyBind("ShortcutKey", form)
    data_binder:DelRolePropertyBind("VipStatus", form)
  end
end
function check_vip_player()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  return client_player:QueryProp("VipStatus")
end
function on_vip_change(form)
  if not nx_is_valid(form) then
    return
  end
  local is_vip = check_vip_player()
  if nx_int(is_vip) == nx_int(0) then
    form.Visible = false
  end
end
function on_imagegrid_select_changed(grid, index)
  local form = grid.ParentForm
  local real_index = get_real_projid(index)
  nx_execute("custom_sender", "custom_onestep_equip_msg_equipall", real_index)
  nx_execute("form_stage_main\\form_role_info\\form_onestep_jingmai", "one_key_active_jingmai", real_index)
end
function on_groupbox_keyequip_lost_capture(groupbox)
end
function on_groupbox_keyequip_get_capture(groupbox)
end
function on_shortcutkey_prop_change()
  local shortcut_keys = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_keys) then
    return
  end
  update_shortcut_key()
end
function update_shortcut_key()
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_onestep")
  if not nx_is_valid(form) then
    return
  end
  local shortcut_keys = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_keys) then
    return
  end
  form.lbl_equip_1.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_OneEquipShortcutGrid_index1))
  form.lbl_equip_2.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_OneEquipShortcutGrid_index2))
  form.lbl_equip_3.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_OneEquipShortcutGrid_index3))
  form.lbl_equip_4.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_OneEquipShortcutGrid_index4))
end
function show_shortcut_equip(show)
  util_show_form("form_stage_main\\form_main\\form_main_shortcut_onestep", true)
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_onestep")
  if not nx_is_valid(form) then
    return
  end
  form.Visible = show
  form.show_equip = show
  local n_show = 0
  if show == true then
    n_show = 1
  end
  local game_config_info = nx_value("game_config_info")
  if nx_is_valid(game_config_info) then
    util_set_property_key(game_config_info, "show_change_equip", nx_int(n_show))
  end
  local CustomizingManager = nx_value("customizing_manager")
  if nx_is_valid(CustomizingManager) then
    CustomizingManager:SaveConfigToServer()
  end
end
function get_real_projid(rbtn_index)
  local bIsNewJHModule = is_newjhmodule()
  if not bIsNewJHModule then
    return rbtn_index
  elseif rbtn_index == 0 then
    return CHANGE_NEW_ID_1
  elseif rbtn_index == 1 then
    return CHANGE_NEW_ID_2
  elseif rbtn_index == 2 then
    return CHANGE_NEW_ID_3
  elseif rbtn_index == 3 then
    return CHANGE_NEW_ID_4
  end
  return -1
end
