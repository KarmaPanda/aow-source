require("util_gui")
require("util_functions")
require("game_object")
require("define\\gamehand_type")
require("share\\view_define")
require("share\\capital_define")
require("share\\client_custom_define")
require("menu_game")
local xinge_photo = "icon\\prop\\prop_xinge.png"
function show_present_form(npc_id, scene_id, type)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_present_to_npc")
  if nx_is_valid(form) then
    nx_destroy(form)
  end
  form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_present_to_npc", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.npc_id = npc_id
  form.scene_id = scene_id
  form.type = type
  form:Show()
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
end
function main_form_init(self)
  self.Fixed = false
  self.allow_empty = true
  self.Visible = true
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 4
  self.Top = (gui.Height - self.Height) / 3
  self.npc_id = nil
  self.scene_id = nil
  self.type = nil
  return 1
end
function on_main_form_open(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("rec_npc_relation", self, nx_current(), "on_rec_relation_changed")
  end
  refresh_form(self)
end
function on_main_form_close(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(self)
    databinder:DelRolePropertyBind("Dead", self)
    databinder:DelTableBind("rec_npc_relation", self)
  end
end
function refresh_form(self)
  self.postbox.persistid = -1
  self.postbox.oldphoto = ""
  self.postbox.num = 0
  self.postbox:Clear()
  self.lbl_num.Text = nx_widestr("")
  local gui = nx_value("gui")
  local target_name = gui.TextManager:GetText(self.npc_id)
  self.ipt_target.Text = nx_widestr(target_name)
  local scene_name = gui.TextManager:GetText("ui_scene_" .. self.scene_id)
  self.ipt_topic.Text = nx_widestr(scene_name)
  local content = gui.TextManager:GetText("ui_present_to_npc_menu")
  self.lettercontent.Text = content
  if nx_int(self.type) == nx_int(1) then
    self.imagegrid_pigeon.Visible = false
    self.lbl_pigeon_num.Visible = false
    local selectobj = nx_value(GAME_SELECT_OBJECT)
    if not nx_is_valid(selectobj) then
      return
    end
    local common_execute = nx_value("common_execute")
    if not nx_is_valid(common_execute) then
      return
    end
    common_execute:RemoveExecute("CheckDisToGiftNpc", self)
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    local visual_scene_obj = game_visual:GetSceneObj(selectobj.Ident)
    if not nx_is_valid(visual_scene_obj) then
      return
    end
    common_execute:AddExecute("CheckDisToGiftNpc", self, 1, visual_scene_obj)
  else
    self.imagegrid_pigeon.Visible = true
    self.lbl_pigeon_num.Visible = true
    self.imagegrid_pigeon:AddItem(0, xinge_photo, "", 1, -1)
    local databinder = nx_value("data_binder")
    if nx_is_valid(databinder) then
      databinder:AddViewBind(VIEWPORT_TOOL, self, "form_stage_main\\form_present_to_npc", "show_pigeon_number")
    end
  end
  local text_relation = get_npc_relation(self.npc_id)
  self.ipt_yx.Text = nx_widestr(text_relation)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("Dead", "int", self, nx_current(), "dead_changed")
  end
end
function on_btn_cancle_click(btn)
  local form = btn.ParentForm
  form.Visible = false
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    common_execute:RemoveExecute("CheckDisToGiftNpc", btn)
  end
  form:Close()
  nx_destroy(form)
  local confirm_form = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", false, false, "colorlevel_confirm")
  if nx_is_valid(confirm_form) then
    confirm_form:Close()
  end
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
    local color_level = form.postbox.persistid:QueryProp("ColorLevel")
    if not CheckPresent(item_id, form.npc_id, form.scene_id) then
      local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(util_format_string("333333")))
      dialog.ok_btn.Visible = false
      dialog.cancel_btn.Text = nx_widestr(util_format_string("ui_ok"))
      dialog:ShowModal()
      local gui = nx_value("gui")
      dialog.Left = (gui.Width - dialog.Width) / 2
      dialog.Top = (gui.Height - dialog.Height) / 2
      local res = nx_wait_event(100000000, dialog, "confirm_return")
      if res == "ok" or res == "cancel" then
        return
      end
    end
    if nx_number(color_level) >= nx_number(4) then
      local color_level_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false, "colorlevel_confirm")
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
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_PRESENT_TO_NPC), nx_int(form.scene_id), form.npc_id, nx_string(unique_id), nx_int(form.postbox.num), nx_int(form.type))
  end
  reset_grid(form)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_postbox_drag_move(grid)
end
function on_postbox_drag_enter(grid)
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
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
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
function on_HeartBeatCheck()
  local form = nx_value("form_stage_main\\form_present_to_npc")
  if nx_is_valid(form) then
    on_btn_cancle_click(form.btn_cancle)
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
function on_HeartBeatCheck()
  local form = nx_value("form_stage_main\\form_present_to_npc")
  if nx_is_valid(form) then
    on_btn_cancle_click(form.btn_cancle)
  end
end
function reset_scene()
  local form = nx_value("form_stage_main\\form_present_to_npc")
  if nx_is_valid(form) then
    on_btn_cancle_click(form.btn_cancle)
  end
end
function dead_changed(form, prop_name, prop_type, prop_value)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if nx_int(client_player:QueryProp("Dead")) ~= nx_int(0) then
    on_btn_cancle_click(form.btn_cancle)
  end
end
function get_item_num_by_configid(configid)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  local view_id = goods_grid:GetToolBoxViewport(nx_string(configid))
  local toolbox_view = game_client:GetView(nx_string(view_id))
  local pigeon_number = 0
  if nx_is_valid(toolbox_view) then
    local viewobj_list = toolbox_view:GetViewObjList()
    for j, obj in pairs(viewobj_list) do
      local obj_id = obj:QueryProp("ConfigID")
      if nx_string(obj_id) == nx_string(configid) then
        local num = obj:QueryProp("Amount")
        pigeon_number = pigeon_number + num
      end
    end
  end
  return pigeon_number
end
function show_pigeon_number(self)
  if not nx_is_valid(self) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\post.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(nx_string("Post"))
  if index < 0 then
    return
  end
  local strPlaceItem = ini:ReadString(index, "ReplaceItem", "")
  local str_lst = util_split_string(nx_string(strPlaceItem), ",")
  local arg_count = table.getn(str_lst)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local pigeon_number = get_item_num_by_configid("mail_xinge")
  if client_player:FindRecord("sable_rec") then
    local row_num = client_player:GetRecordRows("sable_rec")
    for i = 0, row_num - 1 do
      local config = client_player:QueryRecord("sable_rec", i, 3)
      for j = 1, arg_count do
        if str_lst[j] == config then
          pigeon_number = 999
          break
        end
      end
    end
  end
  self.lbl_pigeon_num.Text = nx_widestr(pigeon_number)
  if nx_number(pigeon_number) == nx_number(0) then
    self.imagegrid_pigeon:ChangeItemImageToBW(0, true)
  else
    self.imagegrid_pigeon:ChangeItemImageToBW(0, false)
  end
end
function CheckPresent(item_id, npc_id, scene_id)
  return true
end
function get_npc_relation(npc_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return util_text("ui_karma_rela4")
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return util_text("ui_karma_rela4")
  end
  if not client_player:FindRecord("rec_npc_relation") then
    return util_text("ui_karma_rela4")
  end
  local row = client_player:FindRecordRow("rec_npc_relation", 0, nx_string(npc_id))
  if nx_number(row) < nx_number(0) then
    return util_text("ui_karma_rela4")
  end
  local karma = client_player:QueryRecord("rec_npc_relation", row, 2)
  return get_relation_desc_by_karma(karma)
end
function on_rec_relation_changed(self, recordname, optype, row, clomn)
  if optype ~= "update" and optype ~= "add" then
    return 0
  end
  if not (nx_is_valid(self) and self.Visible) or not nx_find_custom(self, "npc_id") then
    return 0
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindRecord("rec_npc_relation") then
    return 0
  end
  local npc_id = client_player:QueryRecord("rec_npc_relation", row, 0)
  if nx_string(self.npc_id) == nx_string(npc_id) then
    refresh_form(self)
  end
  return 1
end
function get_relation_desc_by_karma(karma)
  local karma_text = "ui_karma_rela4"
  local ini = nx_execute("util_functions", "get_ini", "share\\sns\\msg_config.ini")
  if not nx_is_valid(ini) then
    return util_text(nx_string(karma_text))
  end
  local sec_index = ini:FindSectionIndex("Karma")
  if nx_int(sec_index) < nx_int(0) then
    return util_text(nx_string(karma_text))
  end
  local GroupMsgData = ini:GetItemValueList(sec_index, nx_string("r"))
  for i = 1, nx_number(table.getn(GroupMsgData)) do
    local stepData = util_split_string(GroupMsgData[i], ",")
    if nx_int(stepData[1]) <= nx_int(karma) and nx_int(karma) <= nx_int(stepData[2]) then
      karma_text = nx_string(stepData[3])
    end
  end
  return util_text(nx_string(karma_text))
end
