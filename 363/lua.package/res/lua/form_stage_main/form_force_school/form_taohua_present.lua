require("util_gui")
require("util_functions")
require("game_object")
require("define\\gamehand_type")
require("share\\view_define")
require("share\\capital_define")
require("share\\client_custom_define")
require("menu_game")
require("define\\map_lable_define")
local PRESENT_FORM = "form_stage_main\\form_force_school\\form_taohua_present"
local monster_pos = {
  [0] = "-22,-177",
  [2] = "-561,197",
  [4] = "-1073,-210",
  [6] = "-600,-572",
  [8] = "-55,-326"
}
function show_present_form()
  local form = nx_execute("util_gui", "util_get_form", PRESENT_FORM)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
  form = nx_execute("util_gui", "util_get_form", PRESENT_FORM, true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
end
function close_present_form()
  local form = nx_execute("util_gui", "util_get_form", PRESENT_FORM)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function main_form_init(self)
  self.Fixed = false
  self.Visible = true
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 4
  self.Top = (gui.Height - self.Height) / 3
  return 1
end
function on_main_form_open(self)
  refresh_form(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function refresh_form(self)
  self.postbox.persistid = -1
  self.postbox.oldphoto = ""
  self.postbox.num = 0
  self.postbox:Clear()
  self.lbl_num.Text = nx_widestr("")
  local gui = nx_value("gui")
  self.lettercontent.Text = gui.TextManager:GetText("ui_thdpresent_to_npc_menu")
  local selectobj = nx_value(GAME_SELECT_OBJECT)
  if not nx_is_valid(selectobj) then
    return
  end
  local common_execute = nx_value("common_execute")
  if not nx_is_valid(common_execute) then
    return
  end
  common_execute:RemoveExecute("CheckDisToTaohuaNpc", self)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_scene_obj = game_visual:GetSceneObj(selectobj.Ident)
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  common_execute:AddExecute("CheckDisToTaohuaNpc", self, 1, visual_scene_obj)
end
function on_btn_cancle_click(btn)
  local form = btn.ParentForm
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    common_execute:RemoveExecute("CheckDisToTaohuaNpc", btn)
  end
  form:Close()
end
function on_btn_send_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if form.postbox.persistid ~= -1 and nx_is_valid(form.postbox.persistid) then
    local unique_id = form.postbox.persistid:QueryProp("UniqueID")
    local item_id = form.postbox.persistid:QueryProp("ConfigID")
    local color_level_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    nx_execute("form_common\\form_confirm", "show_common_text", color_level_dialog, nx_widestr(util_format_string("ui_present_to_npc_makesure")))
    color_level_dialog.ok_btn.Text = nx_widestr(util_format_string("ui_present_to_npc_give"))
    color_level_dialog.cancel_btn.Text = nx_widestr(util_format_string("ui_present_to_npc_cancel"))
    color_level_dialog:ShowModal()
    local gui = nx_value("gui")
    color_level_dialog.Left = (gui.Width - color_level_dialog.Width) / 2
    color_level_dialog.Top = (gui.Height - color_level_dialog.Height) / 2
    local res = nx_wait_event(100000000, color_level_dialog, "confirm_return")
    if res == "cancel" then
      return
    end
    if not nx_is_valid(form) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FORCE_ACTIVITY), nx_int(1), nx_string(unique_id), form.postbox.num)
  end
  reset_grid(form)
end
function on_postbox_select_changed(grid)
  local form = grid.ParentForm
  if grid.oldphoto == "" then
    grid.oldphoto = grid.BackImage
  end
  local gui = nx_value("gui")
  local src_viewid = nx_int(gui.GameHand.Para1)
  local src_pos = nx_int(gui.GameHand.Para2)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(src_viewid))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(src_pos))
  if not nx_is_valid(viewobj) then
    return
  end
  if not can_present(grid, viewobj) then
    return
  end
  gui.GameHand:ClearHand()
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
  reset_grid(form, viewobj)
  on_postbox_mousein_grid(form.postbox, 0)
end
function on_postbox_doubleclick_grid(grid)
  if grid.persistid ~= -1 then
    local form = grid.ParentForm
    reset_grid(form, nil)
  end
end
function on_postbox_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_postbox_mousein_grid(self, index)
  if self.persistid == -1 then
    return
  end
  nx_execute("tips_game", "show_goods_tip", self.persistid, self:GetMouseInItemLeft() + 32, self:GetMouseInItemTop(), 32, 32, self.ParentForm)
end
function on_postbox_rightclick_grid(grid)
  if grid.persistid ~= -1 then
    local form = grid.ParentForm
    reset_grid(form, nil)
  end
end
function on_drop_in_postbox(grid, index)
  local gui = nx_value("gui")
  local gamehand = gui.GameHand
  if gamehand.IsDragged and not gamehand.IsDropped then
    on_postbox_select_changed(grid, index)
    gamehand.IsDropped = true
  end
end
function can_present(grid, viewobj)
  if not nx_is_valid(viewobj) then
    return false
  end
  local gui = nx_value("gui")
  if gui.GameHand:IsEmpty() then
    return false
  end
  if gui.GameHand.Type ~= GHT_VIEWITEM then
    return false
  end
  if grid.persistid ~= -1 and nx_id_equal(grid.persistid, viewobj) then
    gui.GameHand:ClearHand()
    return false
  end
  local bind = 0
  if nx_is_valid(viewobj) then
    bind = viewobj:QueryProp("BindStatus")
    if nx_int(bind) > nx_int(0) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7043"))
      return
    end
  end
  local SellPrice1 = nx_number(viewobj:QueryProp("SellPrice1"))
  if SellPrice1 <= 0 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("37045"))
    gui.GameHand:ClearHand()
    return false
  end
  local cant_exchange = viewobj:QueryProp("CantExchange")
  if nx_int(cant_exchange) > nx_int(0) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7055"))
    gui.GameHand:ClearHand()
    return false
  end
  local lock_status = viewobj:QueryProp("LockStatus")
  if nx_int(lock_status) > nx_int(0) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7054"))
    gui.GameHand:ClearHand()
    return false
  end
  local pack = viewobj:QueryProp("LogicPack")
  local cant_delete = nx_execute("util_static_data", "item_static_query", pack, "CantDelete", STATIC_DATA_ITEM_LOGIC)
  cant_delete = nx_int(cant_delete)
  if cant_delete >= nx_int(1) then
    gui.GameHand:ClearHand()
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if nx_int(client_player:QueryProp("StallState")) == nx_int(2) then
    gui.GameHand:ClearHand()
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7040"))
    return false
  end
  return true
end
function reset_grid(form, viewobj)
  if nx_is_valid(viewobj) then
    local amount = viewobj:QueryProp("Amount")
    form.postbox.num = amount
    form.lbl_num.Text = nil
    if form.postbox.num > 1 then
      form.lbl_num.Text = nx_widestr(form.postbox.num)
    end
    local value = nx_execute("util_static_data", "queryprop_by_object", viewobj, "Photo")
    local photo
    if value ~= nil and value ~= "" then
      photo = value
    end
    form.postbox:AddItem(0, nx_string(photo), "", 1, -1)
    form.postbox.persistid = viewobj
  else
    form.postbox:Clear()
    form.lbl_num.Text = nil
    form.postbox.num = 0
    form.postbox.persistid = -1
  end
end
function on_server_msg(...)
  local activity_type = nx_int(arg[1])
  if nx_int(activity_type) == nx_int(1) then
    local is_open = nx_int(arg[2])
    if nx_int(is_open) == nx_int(1) then
      show_present_form()
    else
      close_present_form()
    end
  elseif nx_int(activity_type) == nx_int(2) then
    local activity_phase = nx_string(arg[2])
    local show_flag = nx_int(arg[3])
    local pos_xy = util_split_string(nx_string(monster_pos[nx_number(activity_phase)]), ",")
    if show_flag == nx_int(1) then
      nx_execute("form_stage_main\\form_map\\form_map_scene", "add_label_to_map", TAOHUA_ENEMY_MONSTER, nx_int(pos_xy[1]), nx_int(pos_xy[2]))
    else
      nx_execute("form_stage_main\\form_map\\form_map_scene", "delete_map_label", TAOHUA_ENEMY_MONSTER)
    end
  elseif nx_int(activity_type) == nx_int(3) then
    nx_execute("form_stage_main\\form_school_war\\form_new_school_msg_info", "fresh_force_msg", unpack(arg))
  end
end
function HB_DisCheck()
  local form = nx_value("form_stage_main\\form_force_school\\form_taohua_present")
  if nx_is_valid(form) then
    on_btn_cancle_click(form.btn_cancle)
  end
end
