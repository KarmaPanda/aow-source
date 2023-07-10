require("form_stage_main\\form_wuxue\\form_wuxue_util")
require("share\\qinggong_define")
require("share\\client_custom_define")
local CLIENT_SUB_ACTIVE = 1
local CLIENT_SUB_CLOSE = 2
function main_form_init(form)
  form.Fixed = true
  form.sel_item_index = -1
  form.sel_item_index_for_ref = nx_number(-1)
  return 1
end
function main_form_open(form)
  hide_item_data(form)
  form.lbl_ani_photo.Visible = false
  form.is_open = false
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_QINGGONG, form, nx_current(), "on_view_qgskill_operat")
    databinder:AddTableBind(TABLE_NAME_ACTIVE_QGSKILL, form, nx_current(), "on_rec_activeqgrec_change")
    databinder:AddTableBind(TABLE_NAME_ACTIVE_QGACTION, form, nx_current(), "on_rec_activeqgactionrec_change")
    databinder:AddTableBind(TABLE_NAME_QINGGONG, form, nx_current(), "on_rec_qingqongrec_change")
  end
  form.is_open = true
  form.btn_active.Visible = false
  form.btn_show.Visible = false
  show_type_data(form)
  return 1
end
function main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form)
    databinder:DelTableBind(TABLE_NAME_ACTIVE_QGSKILL, form)
    databinder:DelTableBind(TABLE_NAME_QINGGONG, form)
  end
  if nx_find_custom(form, "Actor2") and nx_is_valid(form.Actor2) then
    form.scenebox_show.Scene:Delete(form.Actor2)
  end
  nx_execute("scene", "delete_scene", form.scenebox_show.Scene)
  nx_destroy(form)
end
function on_grid_photo_mousein_grid(grid, index)
  local form = grid.ParentForm
  if grid.DataSource == "" then
    form.lbl_ani_photo.Visible = false
    form.type_name = ""
    form.item_name = ""
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return 0
  end
  local item_data = GoodsGrid:GetItemData(grid, index)
  if not nx_is_valid(item_data) then
    if nx_find_custom(grid, "type_name") and grid.type_name ~= nil then
      local item = nx_execute("tips_game", "get_tips_ArrayList")
      if nx_is_valid(item) then
        item.ConfigID = grid.type_name
        item.ItemType = 1016
        local tips_manager = nx_value("tips_manager")
        if nx_is_valid(tips_manager) then
          tips_manager.InShortcut = false
        end
        nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
      end
    end
    return 0
  end
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager.InShortcut = false
  end
  nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_grid_photo_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_faculty_get_capture(self)
  show_faculty_info(self, "item_name", WUXUE_QGSKILL)
end
function on_btn_faculty_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_pbar_gate_get_capture(self)
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local text = gui.TextManager:GetFormatText("tips_ng_xw_01", nx_int(self.Value), nx_int(self.Maximum))
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), x, y)
end
function on_pbar_gate_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function on_tree_types_select_changed(self, cur_node, pre_node)
  local form = self.ParentForm
  if nx_find_custom(form, "type_name") and nx_find_custom(cur_node, "type_name") and form.type_name ~= cur_node.type_name then
    form.lbl_ani_photo.Visible = false
    form.type_name = ""
    form.item_name = ""
    form.btn_active.Visible = false
    form.btn_show.Visible = false
  end
  show_item_data(form)
  show_qg_action(form)
end
function on_grid_photo_select_changed(grid, index)
  select_one_item(grid.ParentForm, grid.DataSource)
end
function on_btn_select_click(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "sel_item_index") or nx_number(form.sel_item_index) ~= nx_number(self.DataSource) then
    form.lbl_ani_photo.Visible = false
    form.type_name = ""
    form.item_name = ""
  end
  select_one_item(form, self.DataSource)
end
function on_btn_faculty_click(self)
  if not nx_find_custom(self, "item_name") then
    return 0
  end
  local bSuccess = nx_execute("faculty", "set_faculty_wuxue", self.item_name)
  if bSuccess == true then
    auto_show_hide_wuxue()
  end
end
function on_view_qgskill_operat(form, optype, view_ident, index)
  if nx_is_valid(form) and not form.is_open then
    return 0
  end
  if nx_string(optype) == "updateitem" then
    local timer = nx_value("timer_game")
    timer:Register(CALLBACK_WAIT_TIME, 1, nx_current(), "show_item_data", form, -1, -1)
    return 1
  end
  local item = get_view_object(view_ident, index)
  if not nx_is_valid(item) then
    return 0
  end
  local item_name = item:QueryProp("ConfigID")
  local type_name = get_type_by_wuxue_id(item_name, WUXUE_QGSKILL)
  if type_name == "" then
    return 0
  end
  form.type_name = type_name
  form.item_name = item_name
  show_type_data(form)
  set_radio_btns()
  switch_sub_page(WUXUE_QGSKILL)
end
function on_rec_qingqongrec_change(form, record, optype, row, col)
  if nx_is_valid(form) and not form.is_open then
    return 0
  end
  if nx_string(optype) == "add" then
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    local type_name = client_player:QueryRecord(TABLE_NAME_QINGGONG, row, 0)
    form.type_name = type_name
    form.item_name = ""
    show_type_data(form)
    set_radio_btns()
    switch_sub_page(WUXUE_QGSKILL)
  end
end
function on_rec_activeqgrec_change(form, record, optype, row, col)
  if nx_is_valid(form) and not form.is_open then
    return 0
  end
  local timer = nx_value("timer_game")
  timer:Register(CALLBACK_WAIT_TIME, 1, nx_current(), "show_item_data", form, -1, -1)
end
function on_rec_activeqgactionrec_change(form, record, optype, row, col)
  if nx_is_valid(form) and not form.is_open then
    return 0
  end
  local timer = nx_value("timer_game")
  timer:Register(CALLBACK_WAIT_TIME, 1, nx_current(), "show_item_data", form, -1, -1)
end
function show_type_data(form)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return 0
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local root = form.tree_types:CreateRootNode(nx_widestr(""))
  local learned_qg_count = 0
  local sel_type_node
  form.tree_types:BeginUpdate()
  local type_tab = wuxue_query:GetMainNames(WUXUE_QGSKILL)
  for i = 1, table.getn(type_tab) do
    local type_name = type_tab[i]
    local type_node = root:CreateNode(gui.TextManager:GetText(nx_string(type_name)))
    if nx_is_valid(type_node) then
      type_node.type_name = type_name
      set_node_prop(type_node, 1)
      if wuxue_query:CheckLearn_QingGong(nx_string(type_name)) then
        type_node.ForeColor = "255,101,80,63"
        learned_qg_count = learned_qg_count + 1
      else
        type_node.ForeColor = "255,123,114,106"
      end
      type_node.ShowCoverImage = not wuxue_query:CheckLearn_QingGong(type_name)
      if nx_find_custom(form, "type_name") and nx_string(form.type_name) == nx_string(type_name) then
        sel_type_node = type_node
      end
    end
  end
  form.lbl_qgcount.Text = nx_widestr(learned_qg_count)
  if nx_is_valid(sel_type_node) then
    form.tree_types.SelectNode = sel_type_node
  else
    auto_select_first(form.tree_types)
  end
  root.Expand = true
  form.tree_types:EndUpdate()
end
function hide_item_data(form)
  for i = 1, ITEM_BOX_COUNT do
    local gbox_item = form.gpsb_items:Find("gbox_item_" .. nx_string(i))
    if nx_is_valid(gbox_item) then
      gbox_item.Visible = false
    end
  end
  form.gpsb_items:ResetChildrenYPos()
  set_name_color(form, form.sel_item_index, false)
  form.sel_item_index = -1
  form.mltbox_desc:Clear()
end
function show_item_data(form)
  local gui = nx_value("gui")
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return 0
  end
  if not nx_find_custom(sel_node, "type_name") then
    return 0
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  hide_item_data(form)
  show_qinggong_data(form, sel_node.type_name)
  local show_count = 1
  local sel_item_index = -1
  local has_learn = false
  local item_tab = wuxue_query:GetItemNames(WUXUE_QGSKILL, sel_node.type_name)
  for i = 1, table.getn(item_tab) do
    local item_name = item_tab[i]
    local item = wuxue_query:GetLearnID_QGSkill(item_name)
    if nx_is_valid(item) then
      has_learn = true
      local gbox_item = form.gpsb_items:Find(nx_string("gbox_item_" .. show_count))
      if not nx_is_valid(gbox_item) then
        break
      end
      local lbl_name = gbox_item:Find("lbl_name_" .. show_count)
      local lbl_ani = gbox_item:Find("lbl_ani_" .. show_count)
      local lbl_level = gbox_item:Find("lbl_level_" .. show_count)
      local grid_photo = gbox_item:Find("grid_photo_" .. show_count)
      local btn_select = gbox_item:Find("btn_select_" .. show_count)
      if not (nx_is_valid(lbl_name) and nx_is_valid(lbl_ani) and nx_is_valid(lbl_level) and nx_is_valid(grid_photo)) or not nx_is_valid(btn_select) then
        break
      end
      btn_select.item_name = item_name
      lbl_name.Text = gui.TextManager:GetText(item_name)
      set_grid_data(grid_photo, item, VIEWPORT_QINGGONG)
      show_wuxue_level(lbl_level, item, WUXUE_QGSKILL)
      local is_active = check_qgskill_is_avtive(item_name)
      lbl_ani.Visible = is_active
      if nx_find_custom(form, "item_name") and nx_string(form.item_name) == nx_string(item_name) then
        sel_item_index = show_count
      end
      gbox_item.Visible = true
      show_count = show_count + 1
    end
  end
  form.gpsb_items:ResetChildrenYPos()
  if has_learn == true then
    if sel_item_index <= 0 then
      sel_item_index = 1
    end
    if form.sel_item_index_for_ref ~= nx_number(-1) then
      sel_item_index = form.sel_item_index_for_ref
    end
  end
  select_one_item(form, sel_item_index)
  if 1 < show_count then
    form.lbl_qgskill_back.Visible = false
    form.lbl_back_1.Visible = true
  else
    form.lbl_qgskill_back.BackImage = QINGGONG_BACKIMAGE_DIR .. sel_node.type_name .. ".png"
    form.lbl_qgskill_back.Visible = true
    form.lbl_back_1.Visible = false
  end
end
function select_one_item(form, sel_item_index)
  local gui = nx_value("gui")
  local gbox_item = form.gpsb_items:Find(nx_string("gbox_item_" .. nx_string(sel_item_index)))
  if not nx_is_valid(gbox_item) then
    return 0
  end
  local btn_select = gbox_item:Find(nx_string("btn_select_" .. nx_string(sel_item_index)))
  if not nx_is_valid(btn_select) then
    return 0
  end
  set_name_color(form, form.sel_item_index, false)
  form.sel_item_index = nx_number(sel_item_index)
  set_name_color(form, form.sel_item_index, true)
  form.sel_item_index_for_ref = nx_number(sel_item_index)
  if not nx_find_custom(btn_select, "item_name") then
    return 0
  end
  local qg_name = get_qinggong_name_by_staticdata(btn_select.item_name)
  if nx_string(qg_name) == nx_string("qinggong_gaojie") then
    form.btn_active.Visible = true
    form.btn_show.Visible = true
  else
    form.btn_active.Visible = false
    form.btn_show.Visible = false
  end
  show_qgskill_data(form, btn_select.item_name)
  show_item_action(form, btn_select.item_name, WUXUE_SHOW_SKILL, true)
end
function hide_qinggong_data(form)
  form.lbl_name.Text = nx_widestr("")
  form.btn_faculty.item_name = nil
  form.lbl_level.Text = nx_widestr("")
  form.mltbox_desc:Clear()
  form.grid_photo:Clear()
  form.grid_photo:SetSelectItemIndex(-1)
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:GridClear(form.grid_photo)
  end
  form.grid_photo.type_name = nil
  form.gbox_info.Visible = false
end
function show_qinggong_data(form, qinggong_id)
  local gui = nx_value("gui")
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  hide_qinggong_data(form)
  form.lbl_name.Text = gui.TextManager:GetText(nx_string(qinggong_id))
  form.mltbox_desc:AddHtmlText(nx_widestr(get_qinggong_desc(qinggong_id)), -1)
  form.pbar_gate.Maximum = nx_int(100)
  form.pbar_gate.Value = nx_int(0)
  form.lbl_gate_point.Visible = false
  form.btn_faculty.Enabled = false
  form.btn_faculty.wuxue_type = nil
  form.gbox_faculty.Visible = false
  form.lbl_faculty_back.Visible = true
  if wuxue_query:CheckLearn_QingGong(nx_string(qinggong_id)) then
    form.lbl_level.Text = gui.TextManager:GetText("ui_wuxue_level_max")
    form.mltbox_get_desc.Visible = false
  else
    form.lbl_level.Text = gui.TextManager:GetText("ui_wuxue_level_0")
    form.mltbox_get_desc.HtmlText = gui.TextManager:GetText(get_qg_get_desc(qinggong_id))
    form.mltbox_get_desc.Visible = true
  end
  local photo = GetQGPropByID(qinggong_id, "Photo")
  set_grid_data(form.grid_photo)
  form.grid_photo:AddItem(0, nx_string(photo), 0, 1, -1)
  form.grid_photo.type_name = qinggong_id
  form.gbox_info.Visible = true
end
function hide_qgskill_data(form)
  form.lbl_name.Text = nx_widestr("")
  form.btn_faculty.item_name = nil
  form.mltbox_get_desc.Visible = false
  form.lbl_level.Text = nx_widestr("")
  form.grid_photo:Clear()
  form.grid_photo:SetSelectItemIndex(-1)
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:GridClear(form.grid_photo)
  end
  form.gbox_info.Visible = false
end
function show_qgskill_data(form, qgskill_id)
  local gui = nx_value("gui")
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  hide_qgskill_data(form)
  form.lbl_name.Text = gui.TextManager:GetText(nx_string(qgskill_id))
  form.btn_active.IsActive = check_qgskill_is_avtive(nx_string(qgskill_id))
  form.btn_active.item_name = nx_string(qgskill_id)
  if form.btn_active.IsActive then
    form.btn_active.Text = nx_widestr(gui.TextManager:GetText(nx_string("ui_qinggong_active_yes")))
  else
    form.btn_active.Text = nx_widestr(gui.TextManager:GetText(nx_string("ui_qinggong_active_no")))
  end
  local qgskill = wuxue_query:GetLearnID_QGSkill(qgskill_id)
  show_faculty_level(form, qgskill, qgskill_id, WUXUE_QGSKILL)
  if nx_is_valid(qgskill) then
    form.btn_faculty_on.item_name = nx_string(qgskill_id)
    form.btn_faculty_on.Enabled = form.btn_faculty.Enabled
    form.btn_faculty_on.Visible = check_wuxue_is_faculty(qgskill_id)
    set_grid_data(form.grid_photo, qgskill, VIEWPORT_QGSKILL)
  else
    form.btn_faculty_on.Enabled = false
    set_grid_data(form.grid_photo)
  end
  form.gbox_info.Visible = true
end
function show_qg_action(form)
  local gui = nx_value("gui")
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return 0
  end
  if not nx_find_custom(sel_node, "type_name") then
    return 0
  end
  show_item_action(form, sel_node.type_name, WUXUE_SHOW_QINGGONG)
end
function get_qinggong_consume_desc(qinggong_id)
  local gui = nx_value("gui")
  local desc = ""
  desc = nx_widestr(gui.TextManager:GetText("desc_" .. qinggong_id))
  local consume = GetQGPropByID(qinggong_id, "Consume")
  if nx_number(consume) > 0 then
    desc = desc .. nx_widestr("<br>") .. nx_widestr(gui.TextManager:GetFormatText("desc_qinggong_consume", nx_int(consume)))
  end
  return desc
end
function get_qinggong_desc(qinggong_id)
  local gui = nx_value("gui")
  local desc = nx_widestr("")
  desc = nx_widestr(gui.TextManager:GetText("desc_" .. qinggong_id))
  local consume = GetQGPropByID(qinggong_id, "Consume")
  if nx_number(consume) > 0 then
    desc = desc .. nx_widestr("<br>") .. nx_widestr(gui.TextManager:GetFormatText("desc_qinggong_consume", nx_int(consume)))
  end
  local text = get_qg_eff_desc(qinggong_id)
  if not nx_ws_equal(text, nx_widestr("")) then
    desc = desc .. nx_widestr("<br>") .. nx_widestr(text)
  end
  desc = desc .. nx_widestr("<br>") .. nx_widestr(gui.TextManager:GetText("desc_wenhua_" .. qinggong_id))
  return desc
end
function get_qg_eff_desc(qgid)
  local gui = nx_value("gui")
  local type = GetQGPropByID(qgid, "Type")
  if type == nil or nx_int(type) <= nx_int(QINGGONG_TYPE_INVALID) or nx_int(type) >= nx_int(QINGGONG_TYPE_MAX) then
    return nx_widestr("")
  end
  local info_1 = nx_widestr("")
  local info_2 = nx_widestr("")
  if nx_int(type) == nx_int(QINGGONG_TYPE_BASE) then
    if GetPerCentum("RunSpeed", "RunSpeedAdd") ~= nil then
      info_1 = gui.TextManager:GetText("ui_qinggong_runspeed")
      info_1 = info_1 .. nx_widestr(GetPerCentum("RunSpeed", "RunSpeedAdd"))
    end
    if GetPerCentum2("JumpSpeed", "JumpSpeedAdd") ~= nil then
      info_2 = gui.TextManager:GetText("ui_qinggong_jumpspeed")
      info_2 = info_2 .. nx_widestr(GetPerCentum2("JumpSpeed", "JumpSpeedAdd"))
    end
  elseif nx_int(type) == nx_int(QINGGONG_TYPE_WATER_TA) then
    if GetPerCentum("DriftSpeed", "DriftSpeedAdd") ~= nil then
      info_1 = gui.TextManager:GetText("ui_qinggong_driftspeed")
      info_1 = info_1 .. nx_widestr(GetPerCentum("DriftSpeed", "DriftSpeedAdd"))
    end
  elseif nx_int(type) == nx_int(QINGGONG_TYPE_WATER_DIAN) then
    if GetPerCentum("DriftJumpSpeed", "DriftJumpSpeedAdd") ~= nil then
      info_1 = gui.TextManager:GetText("ui_qinggong_driftjumpspeed")
      info_1 = info_1 .. nx_widestr(GetPerCentum("DriftJumpSpeed", "DriftJumpSpeedAdd"))
    end
  elseif nx_int(type) == nx_int(QINGGONG_TYPE_JUMP_JUMP) then
    if GetPerCentum("SndJumpSpeed", "SndJumpSpeedAdd") ~= nil then
      info_1 = gui.TextManager:GetText("ui_qinggong_sndjumpspeed")
      info_1 = info_1 .. nx_widestr(GetPerCentum("SndJumpSpeed", "SndJumpSpeedAdd"))
    end
  elseif nx_int(type) == nx_int(QINGGONG_TYPE_JUMP_THREE) then
    if GetPerCentum("ThdJumpSpeed", "ThdJumpSpeedAdd") ~= nil then
      info_1 = gui.TextManager:GetText("ui_qinggong_thdjumpspeed")
      info_1 = info_1 .. nx_widestr(GetPerCentum("ThdJumpSpeed", "ThdJumpSpeedAdd"))
    end
  elseif nx_int(type) == nx_int(QINGGONG_TYPE_FLY_RUSH) then
    if GetPerCentum("AirRushSpeed", "AirRushSpeedAdd") ~= nil then
      info_1 = gui.TextManager:GetText("ui_qinggong_airrushspeedadd")
      info_1 = info_1 .. nx_widestr(GetPerCentum("AirRushSpeed", "AirRushSpeedAdd"))
    end
    if GetPerCentum("AirRushDist", "AirRushDistAdd") ~= nil then
      info_2 = gui.TextManager:GetText("ui_qinggong_airrushdist")
      info_2 = info_2 .. nx_widestr(GetPerCentum("AirRushDist", "AirRushDistAdd"))
    end
  elseif nx_int(type) == nx_int(QINGGONG_TYPE_GROUND_RUSH) then
    if GetPerCentum("LandRushSpeed", "LandRushSpeedAdd") ~= nil then
      info_1 = gui.TextManager:GetText("ui_qinggong_landrushspeedadd")
      info_1 = info_1 .. nx_widestr(GetPerCentum("LandRushSpeed", "LandRushSpeedAdd"))
    end
    if GetPerCentum("LandRushDist", "LandRushDistAdd") ~= nil then
      info_2 = gui.TextManager:GetText("ui_qinggong_landrushdist")
      info_2 = info_2 .. nx_widestr(GetPerCentum("LandRushDist", "LandRushDistAdd"))
    end
  elseif nx_int(type) == nx_int(QINGGONG_TYPE_FAST) then
  elseif nx_int(type) == nx_int(QINGGONG_TYPE_LIGHT) then
    if GetPerCentum("Gravity", "GravityAdd") ~= nil then
      info_1 = gui.TextManager:GetText("ui_qinggong_gravity")
      info_1 = info_1 .. nx_widestr(GetPerCentum("Gravity", "GravityAdd"))
    end
  elseif nx_int(type) == nx_int(QINGGONG_TYPE_CLIMB_SIDE) then
  elseif nx_int(type) == nx_int(QINGGONG_TYPE_CLIMB_UP) then
    if GetPerCentum("ClimbSpeed", "ClimbSpeedAdd") ~= nil then
      info_1 = gui.TextManager:GetText("ui_qinggong_climbspeed")
      info_1 = info_1 .. nx_widestr(GetPerCentum("ClimbSpeed", "ClimbSpeedAdd"))
    end
  elseif nx_int(type) == nx_int(QINGGONG_TYPE_CLIMB_JUMP) then
  end
  if not nx_ws_equal(info_1, nx_widestr("")) and not nx_ws_equal(info_2, nx_widestr("")) then
    return info_1 .. nx_widestr("  ") .. info_2
  end
  if not nx_ws_equal(info_1, nx_widestr("")) then
    return info_1
  end
  if not nx_ws_equal(info_2, nx_widestr("")) then
    return info_2
  end
  return nx_widestr("")
end
function GetPerCentum(prop, propadd)
  local game_client = nx_value("game_client")
  local client_obj = game_client:GetPlayer()
  local base = 0
  local ppvalue = 0
  if client_obj:FindProp(prop) then
    base = client_obj:QueryProp(prop)
  end
  if client_obj:FindProp(propadd) then
    ppvalue = client_obj:QueryProp(propadd)
  end
  local per = ppvalue * 100 / base
  if nx_int(per) <= nx_int(0) then
    return ""
  end
  return nx_string(nx_int(per)) .. "%"
end
function GetPerCentum2(prop, propadd)
  local game_client = nx_value("game_client")
  local client_obj = game_client:GetPlayer()
  local base = 0
  local ppvalue = 0
  if client_obj:FindProp(prop) then
    base = client_obj:QueryProp(prop)
  end
  if client_obj:FindProp(propadd) then
    ppvalue = client_obj:QueryProp(propadd)
  end
  local per = ppvalue * 100 / (base - ppvalue)
  if nx_int(per) <= nx_int(0) then
    return ""
  end
  return nx_string(nx_int(per)) .. "%"
end
function GetQGPropByID(qinggongid, prop)
  local ini = nx_execute("util_functions", "get_ini", "share\\Skill\\QingGong\\QGDefine.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string(qinggongid))
  if sec_index < 0 then
    return ""
  end
  return ini:ReadString(sec_index, nx_string(prop), "")
end
function get_qg_get_desc(qinggongid)
  local ini = nx_call("util_functions", "get_ini", INI_FILE_QG_GETDESC)
  if not nx_is_valid(ini) then
    return ""
  end
  local index = ini:FindSectionIndex(nx_string(qinggongid))
  if 0 <= index then
    return ini:ReadString(index, "GetDesc", "")
  end
  return ""
end
function on_btn_active_click(self)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local qinggong = nx_value("qinggong")
  if nx_is_valid(qinggong) and qinggong:IsInQingGongState() then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_cant_active_qg_skill"))
    return
  end
  local sub_msg
  if self.IsActive then
    sub_msg = CLIENT_SUB_CLOSE
  else
    sub_msg = CLIENT_SUB_ACTIVE
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_QG_SKILL), nx_int(sub_msg), nx_string(self.item_name))
end
function get_qinggong_name_by_staticdata(qg_configid)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return ""
  end
  local qg_data_ini = nx_execute("util_functions", "get_ini", "share\\Skill\\QingGong\\QGSkillStatic.ini")
  if not nx_is_valid(qg_data_ini) then
    return ""
  end
  local qgskill = wuxue_query:GetLearnID_QGSkill(qg_configid)
  if not nx_is_valid(qgskill) then
    return ""
  end
  local staticdata = qgskill:QueryProp("StaticData")
  local sec_index = qg_data_ini:FindSectionIndex(nx_string(staticdata))
  if sec_index < 0 then
    return ""
  end
  local qinggong_name = qg_data_ini:ReadString(sec_index, "QingGongName", "")
  return qinggong_name
end
function on_btn_show_click(self)
  if not util_is_lockform_visible("form_stage_main\\form_help\\form_help_qinggong_video") then
    util_auto_show_hide_form_lock("form_stage_main\\form_help\\form_help_qinggong_video")
  end
end
