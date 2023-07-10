require("share\\view_define")
require("share\\logicstate_define")
require("define\\tip_define")
require("define\\gamehand_type")
require("custom_handler")
local FORM_NAME = "form_stage_main\\form_life\\form_newtreasure_transfer"
local MATERIAL_BACK_IMAGE = "gui\\special\\newtersure\\item02.png"
local OnlyUseBindType = 0
local OnlyUseUnbindType = 1
local UseAllType = 2
function on_main_form_init(form)
  form.sel_view_1 = -1
  form.sel_index_1 = -1
  form.sel_view_2 = -1
  form.sel_index_2 = -1
  form.Fixed = false
end
function on_main_form_open(form)
  local form_tersure = nx_value("form_recast_tersure")
  if nx_is_valid(form_tersure) then
    nx_destroy(form_tersure)
  end
  form_tersure = nx_create("form_recast_tersure")
  if nx_is_valid(form_tersure) then
    nx_set_value("form_recast_tersure", form_tersure)
  end
  form.btn_upgrade.Enabled = false
  change_form_size()
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) then
    form_bag.btn_arrange.Enabled = false
  end
  form.groupbox_notice.Visible = false
end
function on_main_form_close(form)
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) then
    form_bag.btn_arrange.Enabled = true
  end
  if nx_int(form.sel_view_1) ~= -1 and nx_int(form.sel_index_1) ~= -1 then
    nx_execute("custom_sender", "custom_newtersure_unlock", form.sel_view_1, form.sel_index_1)
  end
  if nx_int(form.sel_view_2) ~= -1 and nx_int(form.sel_index_2) ~= -1 then
    nx_execute("custom_sender", "custom_newtersure_stuff_unlock", form.sel_view_2, form.sel_index_2)
  end
  nx_destroy(form)
end
function change_form_size()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function on_btn_upgrade_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not check_player_status() then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local form_tersure = nx_value("form_recast_tersure")
  if not nx_is_valid(form_tersure) then
    return
  end
  local item_1 = game_client:GetViewObj(nx_string(form.sel_view_1), nx_string(form.sel_index_1))
  if not nx_is_valid(item_1) then
    return
  end
  local item_2 = game_client:GetViewObj(nx_string(form.sel_view_2), nx_string(form.sel_index_2))
  if not nx_is_valid(item_2) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local level_1 = item_1:QueryProp("Level")
  local text = gui.TextManager:GetText("ui_newtreasrue_upgrade_queding")
  local level_1 = item_1:QueryProp("Level")
  local level_2 = item_2:QueryProp("Level")
  if nx_int(level_1) < nx_int(level_2) then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_upgrade_info_6")
    form.btn_upgrade.Enabled = false
    return
  end
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "newtreasure_upgrade")
  if nx_is_valid(dialog) then
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
  end
  if nx_is_valid(dialog) then
    local res = nx_wait_event(100000000, dialog, "newtreasure_upgrade_confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_newtersure_transfer", form.sel_view_1, form.sel_index_1)
    end
  end
end
function get_photo_amont(item)
  local photo = ""
  local amount = 0
  if nx_is_valid(item) then
    photo = nx_execute("util_static_data", "query_equip_photo_by_sex", item)
    amount = item:QueryProp("Amount")
  end
  return photo, amount
end
function check_player_status()
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_client) or not nx_is_valid(game_visual) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local dead = client_player:QueryProp("Dead")
  if nx_int(dead) > nx_int(0) then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_failed_dead")
    return false
  end
  local logic_state = client_player:QueryProp("LogicState")
  if nx_int(logic_state) == nx_int(LS_FIGHTING) then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_failed_fighting")
    return false
  end
  if nx_int(logic_state) == nx_int(LS_STALLED) then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_failed_baitanzhong")
    return false
  end
  if nx_int(logic_state) == nx_int(LS_SERIOUS_INJURY) then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_failed_zhongshang")
    return false
  end
  if nx_int(logic_state) == nx_int(LS_DIED) then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_failed_siren")
    return false
  end
  local isexchange = client_player:QueryProp("IsExchange")
  if nx_int(isexchange) == 1 then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_failed_jiaoyizhong")
    return false
  end
  local OnTransToolState = client_player:QueryProp("OnTransToolState")
  if nx_int(OnTransToolState) ~= nx_int(0) then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_failed_machezhong")
    return false
  end
  local self = game_visual:GetPlayer()
  local pos_x = self.PositionX
  local pos_y = self.PositionY
  local pos_z = self.PositionZ
  local terrain = game_visual.Terrain
  if terrain:GetWalkWaterExists(pos_x, pos_z) and pos_y < terrain:GetWalkWaterHeight(pos_x, pos_z) then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_failed_shuizhong")
    return false
  end
  return true
end
function clear_form()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.sel_view_1 = -1
  form.sel_index_1 = -1
  form.sel_view_2 = -1
  form.sel_index_2 = -1
  form.imagegrid_target:Clear()
  form.imagegrid_material:Clear()
  clear_need_stuff()
end
function show_need_stuff(upgrade_info)
  local form = nx_value(FORM_NAME)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(form) or not nx_is_valid(ItemQuery) then
    return
  end
  local item_list = util_split_string(nx_string(upgrade_info), ";")
  local size = table.getn(item_list)
  for i = 1, size do
    local item = util_split_string(nx_string(item_list[i]), ",")
    local count = table.getn(item)
    if count ~= 2 then
      return
    end
    local config_id = item[1]
    local need_num = item[2]
    local photo = ItemQuery:GetItemPropByConfigID(nx_string(config_id), "Photo")
    local ImageGrid = form.groupbox_serve:Find("imagegrid_" .. nx_string(i))
    local mltbox_num_info = form.groupbox_serve:Find("mltbox_num_" .. nx_string(i))
    if not nx_is_valid(ImageGrid) then
      return
    end
    ImageGrid:AddItem(0, nx_string(photo), nx_widestr(nx_string(config_id)), 0, -1)
    ImageGrid.binditemid = config_id
    ImageGrid.BackImage = ""
    ImageGrid:SetItemBackImage(0, MATERIAL_BACK_IMAGE)
    ImageGrid.GridBackOffsetX = -3
    ImageGrid.GridBackOffsetY = -3
    ImageGrid:ChangeItemImageToBW(nx_int(0), false)
    if not nx_is_valid(mltbox_num_info) then
      return
    end
    local current_num = get_item_num(config_id, UseAllType)
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    if nx_int(current_num) >= nx_int(need_num) then
      gui.TextManager:Format_SetIDName("ui_newtreasrue_upgrade_2")
    else
      gui.TextManager:Format_SetIDName("ui_newtreasrue_upgrade_1")
    end
    gui.TextManager:Format_AddParam(nx_int(current_num))
    gui.TextManager:Format_AddParam(nx_int(need_num))
    mltbox_num_info.HtmlText = nx_widestr(gui.TextManager:Format_GetText())
  end
end
function clear_need_stuff()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.imagegrid_1:Clear()
  form.imagegrid_2:Clear()
  form.imagegrid_3:Clear()
  form.imagegrid_1.binditemid = ""
  form.imagegrid_2.binditemid = ""
  form.imagegrid_3.binditemid = ""
  form.mltbox_num_1.HtmlText = ""
  form.mltbox_num_2.HtmlText = ""
  form.mltbox_num_3.HtmlText = ""
end
function get_item_num(item_id, bind_type)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_MATERIAL_TOOL))
  local tool = game_client:GetView(nx_string(VIEWPORT_TOOL))
  local task = game_client:GetView(nx_string(VIEWPORT_TASK_TOOL))
  if not nx_is_valid(view) then
    return nx_int(0)
  end
  if not nx_is_valid(tool) then
    return nx_int(0)
  end
  if not nx_is_valid(task) then
    return nx_int(0)
  end
  local cur_amount = nx_int(0)
  local count = view:GetViewObjCount()
  for j = 1, count do
    local obj = view:GetViewObjByIndex(j - 1)
    if not nx_is_valid(obj) then
      return nx_int(0)
    end
    local tempid = obj:QueryProp("ConfigID")
    local bind_status = obj:QueryProp("BindStatus")
    if nx_ws_equal(nx_widestr(tempid), nx_widestr(item_id)) and (bind_type == OnlyUseBindType and bind_status == 1 or bind_type == OnlyUseUnbindType and bind_status == 0 or bind_type == UseAllType) then
      cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
    end
  end
  if nx_int(cur_amount) == nx_int(0) then
    local count = tool:GetViewObjCount()
    for j = 1, count do
      local obj = tool:GetViewObjByIndex(j - 1)
      if not nx_is_valid(obj) then
        return nx_int(0)
      end
      local tempid = obj:QueryProp("ConfigID")
      if nx_ws_equal(nx_widestr(tempid), nx_widestr(item_id)) and (bind_type == OnlyUseBindType and bind_status == 1 or bind_type == OnlyUseUnbindType and bind_status == 0 or bind_type == UseAllType) then
        cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
      end
    end
  end
  if nx_int(cur_amount) == nx_int(0) then
    local count = task:GetViewObjCount()
    for j = 1, count do
      local obj = task:GetViewObjByIndex(j - 1)
      if not nx_is_valid(obj) then
        return nx_int(0)
      end
      local tempid = obj:QueryProp("ConfigID")
      if nx_ws_equal(nx_widestr(tempid), nx_widestr(item_id)) and (bind_type == OnlyUseBindType and bind_status == 1 or bind_type == OnlyUseUnbindType and bind_status == 0 or bind_type == UseAllType) then
        cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
      end
    end
  end
  return nx_int(cur_amount)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_btn_notice_click(btn)
  local form = btn.ParentForm
  form.groupbox_notice.Visible = true
  btn.Visible = false
  form.btn_notice_close.Visible = true
end
function on_btn_notice_close_click(btn)
  local form = btn.ParentForm
  form.groupbox_notice.Visible = false
  btn.Visible = false
  form.btn_notice.Visible = true
end
function on_btn_help_click(btn)
  local form = btn.ParentForm
  form.groupbox_notice.Visible = true
  form.btn_notice.Visible = false
  form.btn_notice_close.Visible = true
end
function add_item_by_rightclick(grid, index)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.imagegrid_target) and not nx_is_valid(form.imagegrid_material) then
    return
  end
  local src_viewid = grid.typeid
  local src_pos = index + 1
  local view_index = grid:GetBindIndex(index)
  local addbag_index = nx_execute("form_stage_main\\form_bag_func", "get_addbag_index", view_index)
  if addbag_index ~= 0 then
    src_pos = view_index
  end
  local view = game_client:GetView(nx_string(src_viewid))
  local viewobj = view:GetViewObj(nx_string(src_pos))
  if not nx_is_valid(viewobj) then
    return
  end
  if viewobj:FindProp("CantExchange") then
    local cant_exchange = viewobj:QueryProp("CantExchange")
    if nx_int(cant_exchange) > nx_int(0) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7055"))
      return
    end
  end
  if viewobj:FindProp("LockStatus") then
    local lock_status = viewobj:QueryProp("LockStatus")
    if nx_int(lock_status) > nx_int(0) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7054"))
      return
    end
  end
  if viewobj:QueryProp("EquipType") ~= nx_string("NewTreasure") then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_upgrade_info_1")
    return
  end
  if not viewobj:FindRecord("RandomPropRec") then
    return
  end
  local level = viewobj:QueryProp("ColorLevel")
  if level < 3 then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_upgrade_info_1")
    return
  end
  local item_config = viewobj:QueryProp("ConfigID")
  local item_name = gui.TextManager:GetText(item_config)
  local photo, amount = get_photo_amont(viewobj)
  if "" == photo then
    return
  end
  local gameHand = gui.GameHand
  local grid_1 = form.imagegrid_target
  local grid_2 = form.imagegrid_material
  if grid_1:IsEmpty(0) then
    form.sel_view_1 = src_viewid
    form.sel_index_1 = src_pos
    local bind_state = viewobj:QueryProp("BindStatus")
    if bind_state == 1 then
      grid_1:AddItem(0, photo, nx_widestr(item_name), amount, -1)
    else
      gameHand:ClearHand()
      form.sel_view_1 = -1
      form.sel_index_1 = -1
      custom_sysinfo(1, 1, 1, 2, "newtreasure_upgrade_info_2")
      return
    end
    nx_execute("custom_sender", "custom_newtersure_lock", form.sel_view_1, form.sel_index_1)
  elseif grid_2:IsEmpty(0) then
    form.sel_view_2 = src_viewid
    form.sel_index_2 = src_pos
    local row_count = viewobj:GetRecordRows("RandomPropRec")
    if 1 < row_count then
      grid_2:AddItem(0, photo, nx_widestr(item_name), amount, -1)
    else
      gameHand:ClearHand()
      form.sel_view_2 = -1
      form.sel_index_2 = -1
      custom_sysinfo(1, 1, 1, 2, "newtreasure_upgrade_info_3")
      return
    end
    nx_execute("custom_sender", "custom_newtersure_stuff_lock", form.sel_view_2, form.sel_index_2)
  end
  check_transfer_state()
end
function check_transfer_state()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.btn_upgrade.Enabled = false
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local form_tersure = nx_value("form_recast_tersure")
  if not nx_is_valid(form_tersure) then
    return
  end
  local item_1 = nx_execute("goods_grid", "get_view_item", form.sel_view_1, form.sel_index_1)
  if nx_is_valid(item_1) then
    if item_1:QueryProp("EquipType") ~= nx_string("NewTreasure") then
      return
    end
    if not form_tersure:NewTreasureCanUpgrade(item_1) then
      custom_sysinfo(1, 1, 1, 2, "newtreasure_upgrade_info_4")
      return
    end
    local stuff = form_tersure:GetUpgradeInfo()
    show_need_stuff(stuff)
  else
    clear_need_stuff()
  end
  local item_2 = nx_execute("goods_grid", "get_view_item", form.sel_view_2, form.sel_index_2)
  if not nx_is_valid(item_2) then
    return
  end
  if item_2:QueryProp("EquipType") ~= nx_string("NewTreasure") then
    return
  end
  if nx_is_valid(item_1) and nx_is_valid(item_2) then
    form.btn_upgrade.Enabled = true
  else
    form.btn_upgrade.Enabled = false
  end
end
function on_imagegrid_target_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local gameHand = gui.GameHand
  if gameHand:IsEmpty() then
    return
  end
  if gameHand.Type ~= GHT_VIEWITEM then
    gameHand:ClearHand()
    return
  end
  if not check_player_status() then
    return
  end
  local child_form = nx_value("form_stage_main\\form_life\\form_newtreasure_update_confirm")
  if nx_is_valid(child_form) then
    gameHand:ClearHand()
  end
  local src_viewid_1 = nx_int(gui.GameHand.Para1)
  local src_pos_1 = nx_int(gui.GameHand.Para2)
  if form.sel_view_1 == src_viewid_1 and form.sel_index_1 == src_pos_1 then
    gameHand:ClearHand()
    return
  end
  if not GoodsGrid:IsToolBoxViewport(nx_int(src_viewid_1)) then
    gameHand:ClearHand()
    custom_sysinfo(1, 1, 1, 2, "9215")
    return
  end
  local item_1 = nx_execute("goods_grid", "get_view_item", src_viewid_1, src_pos_1)
  if not nx_is_valid(item_1) then
    gameHand:ClearHand()
    return
  end
  local lock_status = item_1:QueryProp("LockStatus")
  if 0 < lock_status then
    custom_sysinfo(1, 1, 1, 2, "1500")
    gameHand:ClearHand()
    return
  end
  local bind_state = item_1:QueryProp("BindStatus")
  if bind_state == 0 then
    gameHand:ClearHand()
    custom_sysinfo(1, 1, 1, 2, "newtreasure_upgrade_info_2")
    return
  end
  if item_1:QueryProp("EquipType") ~= nx_string("NewTreasure") then
    gameHand:ClearHand()
    custom_sysinfo(1, 1, 1, 2, "newtreasure_upgrade_info_1")
    return
  end
  if not item_1:FindRecord("RandomPropRec") then
    return
  end
  local level = item_1:QueryProp("ColorLevel")
  if level < 3 then
    gameHand:ClearHand()
    custom_sysinfo(1, 1, 1, 2, "newtreasure_upgrade_info_1")
    return
  end
  local photo, amount = get_photo_amont(item_1)
  if "" == photo then
    gameHand:ClearHand()
    return
  end
  if form.sel_view_1 ~= -1 and form.sel_index_1 ~= -1 then
    nx_execute("custom_sender", "custom_newtersure_unlock", form.sel_view_1, form.sel_index_1)
  end
  grid:AddItem(index, photo, "", amount, -1)
  form.sel_view_1 = src_viewid_1
  form.sel_index_1 = src_pos_1
  nx_execute("custom_sender", "custom_newtersure_lock", form.sel_view_1, form.sel_index_1)
  gameHand:ClearHand()
  check_transfer_state()
end
function on_imagegrid_target_rightclick_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local gui = nx_value("gui")
  if form.sel_view_1 ~= VIEWPORT_EQUIP_TOOL then
    return
  end
  local view_item_1 = game_client:GetViewObj(nx_string(form.sel_view_1), nx_string(form.sel_index_1))
  if not nx_is_valid(view_item_1) then
    return
  end
  nx_execute("custom_sender", "custom_newtersure_unlock", form.sel_view_1, form.sel_index_1)
  grid:Clear()
  form.sel_view_1 = -1
  form.sel_index_1 = -1
  check_transfer_state()
end
function on_imagegrid_target_drag_move(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  if form.sel_view_1 ~= VIEWPORT_EQUIP_TOOL then
    return
  end
  local view_item_1 = game_client:GetViewObj(nx_string(form.sel_view_1), nx_string(form.sel_index_1))
  if not nx_is_valid(view_item_1) then
    return
  end
  local gui = nx_value("gui")
  if gui.GameHand:IsEmpty() then
    local photo = grid:GetItemImage(index)
    gui.GameHand:SetHand("recast_weapon", photo, "", "", "", "")
  end
end
function on_imagegrid_target_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  if form.sel_view_1 ~= VIEWPORT_EQUIP_TOOL then
    return
  end
  local view_item_1 = game_client:GetViewObj(nx_string(form.sel_view_1), nx_string(form.sel_index_1))
  if not nx_is_valid(view_item_1) then
    return
  end
  nx_execute("tips_game", "show_3d_tips_one", view_item_1, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm, false)
end
function on_imagegrid_target_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_material_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local gameHand = gui.GameHand
  if gameHand:IsEmpty() then
    return
  end
  if gameHand.Type ~= GHT_VIEWITEM then
    gameHand:ClearHand()
    return
  end
  if not check_player_status() then
    return
  end
  local src_viewid_2 = nx_int(gui.GameHand.Para1)
  local src_pos_2 = nx_int(gui.GameHand.Para2)
  if form.sel_view_2 == src_viewid_2 and form.sel_index_2 == src_pos_2 then
    gameHand:ClearHand()
    return
  end
  if not GoodsGrid:IsToolBoxViewport(nx_int(src_viewid_2)) then
    gameHand:ClearHand()
    custom_sysinfo(1, 1, 1, 2, "9215")
    return
  end
  local item_2 = nx_execute("goods_grid", "get_view_item", src_viewid_2, src_pos_2)
  if not nx_is_valid(item_2) then
    gameHand:ClearHand()
    return
  end
  local lock_status = item_2:QueryProp("LockStatus")
  if 0 < lock_status then
    custom_sysinfo(1, 1, 1, 2, "1500")
    gameHand:ClearHand()
    return
  end
  if item_2:QueryProp("EquipType") ~= nx_string("NewTreasure") then
    gameHand:ClearHand()
    custom_sysinfo(1, 1, 1, 2, "newtreasure_upgrade_info_1")
    return
  end
  if not item_2:FindRecord("RandomPropRec") then
    return
  end
  local level = item_2:QueryProp("ColorLevel")
  if level < 3 then
    gameHand:ClearHand()
    custom_sysinfo(1, 1, 1, 2, "newtreasure_upgrade_info_1")
    return
  end
  local rows = item_2:GetRecordRows("RandomPropRec")
  if rows < 2 then
    gameHand:ClearHand()
    custom_sysinfo(1, 1, 1, 2, "newtreasure_upgrade_info_3")
    return
  end
  local photo, amount = get_photo_amont(item_2)
  if "" == photo then
    gameHand:ClearHand()
    return
  end
  if form.sel_view_2 ~= -1 and form.sel_index_2 ~= -1 then
    nx_execute("custom_sender", "custom_newtersure_stuff_unlock", form.sel_view_2, form.sel_index_2)
  end
  grid:AddItem(index, photo, "", amount, -1)
  form.sel_view_2 = src_viewid_2
  form.sel_index_2 = src_pos_2
  nx_execute("custom_sender", "custom_newtersure_stuff_lock", form.sel_view_2, form.sel_index_2)
  gameHand:ClearHand()
  check_transfer_state()
end
function on_imagegrid_material_rightclick_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local gui = nx_value("gui")
  if form.sel_view_2 ~= VIEWPORT_EQUIP_TOOL then
    return
  end
  local view_item_2 = game_client:GetViewObj(nx_string(form.sel_view_2), nx_string(form.sel_index_2))
  if not nx_is_valid(view_item_2) then
    return
  end
  nx_execute("custom_sender", "custom_newtersure_stuff_unlock", form.sel_view_2, form.sel_index_2)
  grid:Clear()
  form.sel_view_2 = -1
  form.sel_index_2 = -1
  check_transfer_state()
end
function on_imagegrid_material_drag_move(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  if form.sel_view_2 ~= VIEWPORT_EQUIP_TOOL then
    return
  end
  local view_item_2 = game_client:GetViewObj(nx_string(form.sel_view_2), nx_string(form.sel_index_2))
  if not nx_is_valid(view_item_2) then
    return
  end
  local gui = nx_value("gui")
  if gui.GameHand:IsEmpty() then
    local photo = grid:GetItemImage(index)
    gui.GameHand:SetHand("recast_weapon", photo, "", "", "", "")
  end
end
function on_imagegrid_material_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  if form.sel_view_2 ~= VIEWPORT_EQUIP_TOOL then
    return
  end
  local view_item_2 = game_client:GetViewObj(nx_string(form.sel_view_2), nx_string(form.sel_index_2))
  if not nx_is_valid(view_item_2) then
    return
  end
  nx_execute("tips_game", "show_3d_tips_one", view_item_2, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm, false)
end
function on_imagegrid_material_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(grid, "binditemid") then
    return
  end
  local itemid = grid.binditemid
  if itemid ~= nil and itemid ~= "" then
    nx_execute("tips_game", "show_tips_by_config", nx_string(itemid), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), form)
  else
    nx_execute("tips_game", "hide_tip", form)
  end
end
function on_imagegrid_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function open_form()
  local form_grave = nx_value("form_stage_main\\form_life\\form_newtreasure_grave")
  if nx_is_valid(form_grave) then
    nx_execute("form_stage_main\\form_life\\form_newtreasure_grave", "on_btn_close_click", form_grave.btn_close)
    return false
  end
  local form_help = nx_value("form_stage_main\\form_help\\form_help_fcww")
  if nx_is_valid(form_help) then
    nx_execute("form_stage_main\\form_help\\form_help_fcww", "on_btn_close_click", form_help.btn_close)
    return false
  end
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
end
