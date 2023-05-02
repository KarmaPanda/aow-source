require("util_gui")
require("custom_handler")
require("share\\client_custom_define")
require("util_functions")
require("share\\view_define")
require("define\\tip_define")
require("define\\gamehand_type")
require("form_stage_main\\form_bag")
local FORM_NAME = "form_stage_main\\form_life\\form_treasure_repair"
function main_form_init(form)
  form.sel_view = -1
  form.sel_index = -1
  form.Fixed = true
end
function open_form()
  if not check_player_status() then
    return false
  end
  local form_reset_add = nx_value("form_stage_main\\form_life\\form_treasure_reset_add")
  if nx_is_valid(form_reset_add) then
    nx_execute("form_stage_main\\form_life\\form_treasure_reset_add", "on_btn_close_click", form_reset_add.btn_close)
    return false
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_treasure_repair", true, false)
  if not nx_is_valid(form) then
    return false
  end
  form:Show()
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Desktop.Width - form.Width) / 2
  form.AbsTop = (gui.Desktop.Height - form.Height) / 2
  clear_target(form)
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) then
    form_bag.btn_arrange.Enabled = false
  end
end
function get_player()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nx_null()
  end
  return game_client:GetPlayer()
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) then
    form_bag.btn_arrange.Enabled = true
  end
  if form.sel_view ~= -1 and form.sel_index ~= -1 then
    nx_execute("custom_sender", "custom_tersure_unlock", form.sel_view, form.sel_index)
  end
  nx_destroy(form)
end
function clear_target(form)
  if not nx_is_valid(form) then
    return
  end
  local imagegrid_target = form.imagegrid_target
  if not nx_is_valid(imagegrid_target) then
    return
  end
  imagegrid_target:Clear()
  form.sel_index = -1
  form.sel_view = -1
  form.btn_ok.Enabled = false
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
  local src_viewid_1 = nx_int(gui.GameHand.Para1)
  local src_pos_1 = nx_int(gui.GameHand.Para2)
  if form.sel_view == src_viewid_1 and form.sel_index == src_pos_1 then
    gameHand:ClearHand()
    return
  end
  if not GoodsGrid:IsToolBoxViewport(nx_int(src_viewid_1)) then
    gameHand:ClearHand()
    custom_sysinfo(1, 1, 1, 2, "9215")
    return
  end
  local item = nx_execute("goods_grid", "get_view_item", src_viewid_1, src_pos_1)
  if not nx_is_valid(item) then
    gameHand:ClearHand()
    return
  end
  local lock_status = item:QueryProp("LockStatus")
  if 0 < lock_status then
    custom_sysinfo(1, 1, 1, 2, "1500")
    gameHand:ClearHand()
    return
  end
  if item:QueryProp("EquipType") ~= nx_string("Treasure") then
    custom_sysinfo(1, 1, 1, 2, "sys_treasure_repair_1")
    gameHand:ClearHand()
    return
  end
  if not can_repair(item) then
    gameHand:ClearHand()
    custom_sysinfo(1, 1, 1, 2, "sys_treasure_repair_2")
    return
  end
  if not item:FindRecord("RandomSkillRec") then
    return
  end
  local photo, amount = get_photo_amont(item)
  if "" == photo then
    gameHand:ClearHand()
    return
  end
  if form.sel_view ~= -1 and form.sel_index ~= -1 then
    nx_execute("custom_sender", "custom_tersure_unlock", form.sel_view, form.sel_index)
  end
  clear_target(form)
  grid:AddItem(index, photo, "", amount, -1)
  form.sel_view = src_viewid_1
  form.sel_index = src_pos_1
  nx_execute("custom_sender", "custom_tersure_lock", form.sel_view, form.sel_index)
  gameHand:ClearHand()
  form.btn_ok.Enabled = true
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
  if form.sel_view ~= VIEWPORT_EQUIP_TOOL then
    return
  end
  local view_item = game_client:GetViewObj(nx_string(form.sel_view), nx_string(form.sel_index))
  if not nx_is_valid(view_item) then
    return
  end
  nx_execute("custom_sender", "custom_tersure_unlock", form.sel_view, form.sel_index)
  grid:Clear()
  form.sel_view = -1
  form.sel_index = -1
  clear_target(form)
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
  if form.sel_view ~= VIEWPORT_EQUIP_TOOL then
    return
  end
  local view_item = game_client:GetViewObj(nx_string(form.sel_view), nx_string(form.sel_index))
  if not nx_is_valid(view_item) then
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
  if form.sel_view ~= VIEWPORT_EQUIP_TOOL then
    return
  end
  local view_item = game_client:GetViewObj(nx_string(form.sel_view), nx_string(form.sel_index))
  if not nx_is_valid(view_item) then
    return
  end
  nx_execute("tips_game", "show_3d_tips_one", view_item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm, false)
end
function on_imagegrid_target_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function get_photo_amont(item)
  local photo = ""
  local amount = 0
  if nx_is_valid(item) then
    photo = nx_execute("util_static_data", "query_equip_photo_by_sex", item)
    amount = 1
  end
  return photo, amount
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
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
  if not nx_is_valid(form.imagegrid_target) then
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
  if viewobj:QueryProp("EquipType") ~= nx_string("Treasure") then
    custom_sysinfo(1, 1, 1, 2, "sys_treasure_repair_1")
    return
  end
  if not viewobj:FindRecord("RandomSkillRec") then
    custom_sysinfo(1, 1, 1, 2, "sys_treasure_repair_1")
    return
  end
  if not can_repair(viewobj) then
    custom_sysinfo(1, 1, 1, 2, "sys_treasure_repair_2")
    return
  end
  local item_config = viewobj:QueryProp("ConfigID")
  local item_name = gui.TextManager:GetText(item_config)
  local photo, amount = get_photo_amont(viewobj)
  if "" == photo then
    return
  end
  local grid_1 = form.imagegrid_target
  if grid_1:IsEmpty(0) then
    form.sel_view = src_viewid
    form.sel_index = src_pos
    grid_1:AddItem(0, photo, nx_widestr(item_name), amount, -1)
    nx_execute("custom_sender", "custom_tersure_lock", form.sel_view, form.sel_index)
  end
  form.btn_ok.Enabled = true
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_treasure_repair", form.sel_view, form.sel_index)
end
function show_repair_result()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.imagegrid_target
  nx_execute("custom_sender", "custom_tersure_unlock", form.sel_view, form.sel_index)
  grid:Clear()
  form.sel_view = -1
  form.sel_index = -1
  clear_target(form)
end
function can_repair(item)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local ini = get_ini("share\\Rule\\RandomEquipRule\\TreasureRepair.ini")
  if not nx_is_valid(ini) then
    return
  end
  if not nx_is_valid(item) then
    return
  end
  if not item:FindRecord("RandomSkillRec") then
    return
  end
  local row_count = item:GetRecordRows("RandomSkillRec")
  local count = ini:GetSectionCount()
  if count < 0 then
    return
  end
  local can_add = false
  for i = 0, row_count - 1 do
    local target_num = 0
    local repair_id = nx_string(item:QueryRecord("RandomSkillRec", i, 0))
    if ini:FindSection(repair_id) then
      local sec_index = ini:FindSectionIndex(repair_id)
      local cost_num = ini:GetSectionItemValue(sec_index, 0)
      for j = 0, row_count - 1 do
        local repair_value = item:QueryRecord("RandomSkillRec", i, 1)
        local id = nx_string(item:QueryRecord("RandomSkillRec", j, 0))
        if nx_int(repair_id) == nx_int(id) then
          target_num = target_num + 1
        end
      end
      if target_num < cost_num + 1 then
        can_add = true
      end
    end
  end
  if not can_add then
    custom_sysinfo(1, 1, 1, 2, "sys_treasure_repair_2")
    return false
  end
  return true
end
function check_player_status()
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local dead = client_player:QueryProp("Dead")
  if nx_int(dead) > nx_int(0) then
    custom_sysinfo(1, 1, 1, 2, "recast_failed_siren")
    return false
  end
  local logic_state = client_player:QueryProp("LogicState")
  if nx_int(logic_state) == nx_int(LS_FIGHTING) then
    custom_sysinfo(1, 1, 1, 2, "recast_failed_fighting")
    return false
  end
  if nx_int(logic_state) == nx_int(LS_STALLED) then
    custom_sysinfo(1, 1, 1, 2, "recast_failed_baitanzhong")
    return false
  end
  if nx_int(logic_state) == nx_int(LS_SERIOUS_INJURY) then
    custom_sysinfo(1, 1, 1, 2, "recast_failed_zhongshang")
    return false
  end
  if nx_int(logic_state) == nx_int(LS_DIED) then
    custom_sysinfo(1, 1, 1, 2, "recast_failed_siren")
    return false
  end
  local isexchange = client_player:QueryProp("IsExchange")
  if nx_int(isexchange) == 1 then
    custom_sysinfo(1, 1, 1, 2, "recast_failed_jiaoyizhong")
    return false
  end
  local OnTransToolState = client_player:QueryProp("OnTransToolState")
  if nx_int(OnTransToolState) ~= nx_int(0) then
    custom_sysinfo(1, 1, 1, 2, "recast_failed_machezhong")
    return false
  end
  local self = game_visual:GetPlayer()
  local pos_x = self.PositionX
  local pos_y = self.PositionY
  local pos_z = self.PositionZ
  local terrain = game_visual.Terrain
  if terrain:GetWalkWaterExists(pos_x, pos_z) and pos_y < terrain:GetWalkWaterHeight(pos_x, pos_z) then
    custom_sysinfo(1, 1, 1, 2, "recast_failed_shuizhong")
    return false
  end
  return true
end
