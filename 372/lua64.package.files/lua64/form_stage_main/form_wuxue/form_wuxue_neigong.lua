require("form_stage_main\\form_wuxue\\form_wuxue_util")
require("form_stage_main\\switch\\switch_define")
local FACULTY_NULL = 0
local FACULTY_ONE = 1
local FACULTY_TWO = 2
local SETFACULTYSALE_INI = "share\\Faculty\\SetFacultySale.ini"
local FACULTYSALE_INI = "share\\Faculty\\FacultySale.ini"
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function main_form_init(form)
  form.Fixed = true
  form.sel_item_index = -1
  form.showsplv = 0
  return 1
end
function main_form_open(form)
  local gui = nx_value("gui")
  hide_neigong_data(form)
  hide_jinfa_data(form)
  hide_neigong_jf(form)
  show_jinfa_ani(form, 0)
  form.btn_faculty_on.Visible = false
  form.btn_flash.Visible = false
  form.lbl_ani_photo.Visible = false
  form.is_open = false
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind(TABLE_NAME_JINFA, form, nx_current(), "on_jinfa_rec_refresh")
    databinder:AddViewBind(VIEWPORT_NEIGONG, form, nx_current(), "on_neigong_view_operat")
    databinder:AddRolePropertyBind("CurNeiGong", "string", form, nx_current(), "prop_callback_curneigong")
    databinder:AddRolePropertyBind("FacultyName", "string", form, nx_current(), "prop_callback_facultyname")
    databinder:AddRolePropertyBind("FacultyStyle", "int", form, nx_current(), "prop_callback_facultystyle")
  end
  form.is_open = true
  show_type_data(form)
  set_jinfa_visible(form, false)
  return 1
end
function main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form)
    databinder:DelTableBind(TABLE_NAME_JINFA, form)
    databinder:DelRolePropertyBind("CurNeiGong", form)
    databinder:DelRolePropertyBind("FacultyName", form)
    databinder:DelRolePropertyBind("FacultyStyle", form)
  end
  local jinfa_all = nx_value("jinfa_all")
  if nx_is_valid(jinfa_all) then
    nx_destroy(jinfa_all)
  end
  nx_destroy(form)
end
function on_grid_photo_mousein_grid(grid, index)
  local form = grid.ParentForm
  local gui = nx_value("gui")
  if not nx_find_custom(grid, "item_name") or grid.item_name == nil then
    if nx_number(grid.DataSource) ~= 0 then
      local tips_text = gui.TextManager:GetFormatText("ui_jinfa_level_need", nx_int(grid.DataSource))
      nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 140, grid.ParentForm)
    end
    return 0
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(grid.item_name), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 110, grid.ParentForm)
end
function on_grid_photo_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_grid_neigong_mousein_grid(grid, index)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return 0
  end
  local item_data = GoodsGrid:GetItemData(grid, index)
  if not nx_is_valid(item_data) then
    return 0
  end
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager.InShortcut = false
  end
  nx_execute("tips_game", "show_neigong_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_grid_neigong_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_faculty_get_capture(self)
  show_faculty_info(self, "item_name", WUXUE_NEIGONG)
end
function on_btn_faculty_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_tree_types_select_changed(self, cur_node, pre_node)
  local form = self.ParentForm
  if not set_node_select(self, cur_node, pre_node) then
    return 0
  end
  if nx_find_custom(form, "type_name") and nx_find_custom(cur_node, "type_name") and form.type_name ~= cur_node.type_name then
    form.lbl_ani_photo.Visible = false
    form.type_name = ""
  end
  show_neigong_data(self.ParentForm)
  show_neigong_jf(self.ParentForm)
end
function on_grid_photo_select_changed(grid, index)
  local gui = nx_value("gui")
  select_one_item(grid.ParentForm, grid.DataSource)
  grid:SetSelectItemIndex(-1)
  if not nx_find_custom(grid, "item_name") then
    return 0
  end
  if not nx_find_custom(grid, "item_splv") then
    return 0
  end
  if not gui.GameHand:IsEmpty() then
    if gui.GameHand.Type == GHT_JINFA and gui.GameHand.Para1 == grid.item_name and gui.GameHand.Para2 == grid.item_splv then
      gui.GameHand:ClearHand()
      show_jinfa_ani(grid.ParentForm, 0)
    end
  else
    local photo = grid:GetItemImage(index)
    gui.GameHand:SetHand(GHT_JINFA, photo, grid.item_name, grid.item_splv, "", "")
    show_jinfa_ani(grid.ParentForm, grid.item_splv)
  end
end
function on_grid_jinfa_select_changed(grid, index)
  local form = grid.ParentForm
  local gui = nx_value("gui")
  grid:SetSelectItemIndex(-1)
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return 0
  end
  if not nx_find_custom(sel_node, "type_name") then
    return 0
  end
  if gui.GameHand:IsEmpty() then
    return 0
  end
  if gui.GameHand.Type ~= GHT_JINFA then
    return 0
  end
  if nx_number(gui.GameHand.Para2) ~= nx_number(grid.DataSource) then
    return 0
  end
  nx_execute("custom_sender", "custom_wear_jinfa", WEAR_JINFA_PUTIN, sel_node.type_name, gui.GameHand.Para1)
  gui.GameHand:ClearHand()
  show_jinfa_ani(grid.ParentForm, 0)
end
function on_grid_neigong_select_changed(grid, index)
  local view_index = grid:GetBindIndex(index)
  if view_index < 0 then
    return 0
  end
  local goodsgrid = nx_value("GoodsGrid")
  if not nx_is_valid(goodsgrid) then
    return
  end
  goodsgrid:ViewGridOnSelectItem(grid, index)
  grid:SetSelectItemIndex(-1)
end
function on_grid_neigong_drag_enter(grid, index)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    local game_hand = gui.GameHand
    game_hand.IsDragged = false
    game_hand.IsDropped = false
  end
end
function on_grid_neigong_drag_move(grid, index)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    local game_hand = gui.GameHand
    if not game_hand.IsDragged then
      game_hand.IsDragged = true
      local goodsgrid = nx_value("GoodsGrid")
      if not nx_is_valid(goodsgrid) then
        return
      end
      goodsgrid:ViewGridOnSelectItem(grid, index)
    end
  end
end
function on_btn_select_click(self)
  select_one_item(self.ParentForm, self.DataSource)
end
function on_btn_zhuang_click(self)
  local form = self.ParentForm
  form.lbl_ani_photo.Visible = false
  form.type_name = ""
  if not nx_find_custom(self, "item_name") then
    return 0
  end
  nx_execute("custom_sender", "custom_use_neigong", nx_string(self.item_name))
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_faculty_click(self)
  if not nx_find_custom(self, "item_name") then
    return 0
  end
  local bSuccess = nx_execute("faculty", "set_faculty_wuxue", self.item_name)
  if bSuccess == true then
    auto_show_hide_wuxue()
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_flash_click(self)
  self.Visible = false
  if not nx_find_custom(self, "item_name") then
    return 0
  end
  local bSuccess = nx_execute("faculty", "set_faculty_wuxue", self.item_name)
  if bSuccess == true then
    auto_show_hide_wuxue()
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_rbtn_splv_checked_changed(self)
  local form = self.ParentForm
  if self.Checked then
    form.showsplv = nx_number(self.DataSource)
    show_jinfa_data(form)
  end
end
function on_btn_clearjf_click(self)
  local form = self.ParentForm
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return 0
  end
  if not nx_find_custom(sel_node, "type_name") then
    return 0
  end
  nx_execute("custom_sender", "custom_wear_jinfa", WEAR_JINFA_CLEAR, sel_node.type_name)
  form.showsplv = 0
  show_jinfa_data(form)
end
function on_neigong_view_operat(form, optype, view_ident, index)
  if nx_is_valid(form) and not form.is_open then
    return 0
  end
  if nx_string(optype) == "updateitem" then
    local timer = nx_value("timer_game")
    timer:Register(CALLBACK_WAIT_TIME, 1, nx_current(), "show_neigong_data", form, -1, -1)
    return 1
  end
  local item = get_view_object(view_ident, index)
  if not nx_is_valid(item) then
    return 0
  end
  local type_name = item:QueryProp("ConfigID")
  if type_name == "" then
    return 0
  end
  form.type_name = type_name
  show_type_data(form)
  set_radio_btns()
  switch_sub_page(WUXUE_NEIGONG)
end
function on_jinfa_rec_refresh(form, recordname, optype, row, clomn)
  if not nx_is_valid(form) then
    return 0
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not client_player:FindRecord(TABLE_NAME_JINFA) then
    return 0
  end
  local jinfaini = nx_execute("util_functions", "get_ini", INI_FILE_JF_SKILL)
  if not nx_is_valid(jinfaini) then
    return 0
  end
  local jinfa_all = nx_call("util_gui", "get_global_arraylist", "jinfa_all")
  jinfa_all:ClearChild()
  local rownum = client_player:GetRecordRows(TABLE_NAME_JINFA)
  for i = 0, rownum - 1 do
    local config_id = client_player:QueryRecord(TABLE_NAME_JINFA, i, 0)
    local index = jinfaini:FindSectionIndex(nx_string(config_id))
    if index < 0 then
      return 0
    end
    local type = jinfaini:ReadString(index, "Type", "")
    if nx_number(type) == JINGFA_TYPE_NUQI then
      local child = jinfa_all:CreateChild(nx_string(config_id))
      if nx_is_valid(child) then
        child.photo = jinfaini:ReadString(index, "Photo", "")
        child.splv = jinfaini:ReadString(index, "splevel", "")
      end
    end
  end
  show_jinfa_data(form)
  return 1
end
function prop_callback_curneigong(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
    return 0
  end
  if not form.is_open then
    return 0
  end
  nx_execute("util_sound", "play_link_sound", "fight_inpwr_swich.wav", nx_value("role"), 0, 0, 0, 1, 5, 1, "snd\\action\\fight\\other\\")
  if not nx_find_custom(form.btn_zhuang, "item_name") then
    return 0
  end
  form.btn_zhuang.Enabled = not check_is_curneigong(form.btn_zhuang.item_name)
end
function prop_callback_facultyname(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
    return 0
  end
  if not form.is_open then
    return 0
  end
  if not nx_find_custom(form.btn_faculty_on, "item_name") then
    return 0
  end
  form.btn_faculty_on.Visible = check_wuxue_is_faculty(form.btn_faculty_on.item_name)
end
function prop_callback_facultystyle(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
    return 0
  end
  if not form.is_open then
    return 0
  end
  if not nx_find_custom(form.btn_faculty_on, "item_name") then
    return 0
  end
  form.btn_faculty_on.Visible = check_wuxue_is_faculty(form.btn_faculty_on.item_name)
end
function on_mltbox_title_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local flag = switch_manager:CheckSwitchEnable(ST_FUNCTION_FACULTY_SALE)
  if not flag then
    return
  end
  local faculty_query = nx_value("faculty_query")
  if not nx_is_valid(faculty_query) then
    return
  end
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return 0
  end
  if not nx_find_custom(sel_node, "type_name") then
    return 0
  end
  if is_sale_wuxue(sel_node.type_name) == false then
    return
  end
  local tip_text = nx_widestr("")
  local value = faculty_query:GetFacultySale(nx_string(sel_node.type_name))
  local show_type = get_faculty_sale_value(value)
  if nx_int(show_type) == nx_int(FACULTY_ONE) then
    tip_text = nx_widestr(util_text("ui_tips_faculty_two"))
  elseif nx_int(show_type) == nx_int(FACULTY_TWO) then
    tip_text = nx_widestr(util_text("ui_tips_faculty_one"))
  else
    tip_text = nx_widestr(util_text("ui_tips_faculty_normal"))
  end
  nx_execute("tips_game", "show_text_tip", tip_text, self.AbsLeft, self.AbsTop)
end
function on_mltbox_title_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function on_pbar_power_cover_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local text = nx_widestr(gui.TextManager:GetFormatText("tips_ng_qlz_02", nx_widestr(form.pbar_power.Value), nx_widestr(form.pbar_power.Maximum)))
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), x, y)
end
function on_pbar_power_cover_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
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
  local learned_ng_count = 0
  local sel_type_node
  form.tree_types:BeginUpdate()
  local type_tab = wuxue_query:GetMainNames(WUXUE_NEIGONG)
  for i = 1, table.getn(type_tab) do
    local type_name = type_tab[i]
    local type_node
    local sub_type_tab = wuxue_query:GetItemNames(WUXUE_NEIGONG, type_name)
    for j = 1, table.getn(sub_type_tab) do
      local sub_type_name = sub_type_tab[j]
      local sub_type = wuxue_query:GetLearnID_NeiGong(sub_type_name)
      if nx_is_valid(sub_type) then
        if not nx_is_valid(type_node) then
          type_node = root:CreateNode(gui.TextManager:GetText(type_name))
          set_node_prop(type_node, 1)
        end
        local sub_type_node = type_node:CreateNode(gui.TextManager:GetText(sub_type_name))
        if nx_is_valid(sub_type_node) then
          sub_type_node.type_name = sub_type_name
          set_node_prop(sub_type_node, 2)
        end
        if nx_find_custom(form, "type_name") and nx_string(form.type_name) == nx_string(sub_type_name) then
          sel_type_node = sub_type_node
          form.lbl_ani_photo.Visible = true
        end
        learned_ng_count = learned_ng_count + 1
      end
    end
  end
  form.lbl_ngcount.Text = nx_widestr(learned_ng_count)
  if nx_is_valid(sel_type_node) then
    form.tree_types.SelectNode = sel_type_node
  else
    auto_select_first(form.tree_types)
  end
  root.Expand = true
  form.tree_types:EndUpdate()
end
function hide_jinfa_data(form)
  for i = 1, ITEM_BOX_COUNT do
    local gbox_item = form.gpsb_items:Find(nx_string("gbox_item_" .. i))
    if nx_is_valid(gbox_item) then
      gbox_item.Visible = false
    end
  end
  form.gpsb_items:ResetChildrenYPos()
  set_name_color(form, form.sel_item_index, false)
  form.sel_item_index = -1
  form.lbl_jinfa_back_1.Visible = true
  form.lbl_jinfa_back_2.Visible = true
end
function show_jinfa_data(form)
  local gui = nx_value("gui")
  hide_jinfa_data(form)
  local jinfa_all = nx_value("jinfa_all")
  if not nx_is_valid(jinfa_all) then
    return 0
  end
  local show_count = 1
  local item_tab = jinfa_all:GetChildList()
  for i = 1, table.getn(item_tab) do
    local item = item_tab[i]
    if nx_number(item.splv) == nx_number(form.showsplv) or nx_number(form.showsplv) == 0 then
      local gbox_item = form.gpsb_items:Find("gbox_item_" .. nx_string(show_count))
      if not nx_is_valid(gbox_item) then
        break
      end
      local lbl_name = gbox_item:Find("lbl_name_" .. nx_string(show_count))
      local lbl_level = gbox_item:Find("lbl_level_" .. nx_string(show_count))
      local grid_photo = gbox_item:Find("grid_photo_" .. nx_string(show_count))
      local btn_select = gbox_item:Find("btn_select_" .. nx_string(show_count))
      if not (nx_is_valid(lbl_name) and nx_is_valid(lbl_level) and nx_is_valid(grid_photo)) or not nx_is_valid(btn_select) then
        break
      end
      lbl_name.Text = nx_widestr(gui.TextManager:GetText(item.Name))
      lbl_level.Text = nx_widestr(gui.TextManager:GetText("ui_jinfa_level_" .. nx_string(item.splv)))
      grid_photo:AddItem(0, item.photo, "", 1, 1)
      grid_photo.item_name = nx_string(item.Name)
      grid_photo.item_splv = nx_string(item.splv)
      btn_select.item_name = nx_string(item.Name)
      gbox_item.Visible = true
      show_count = show_count + 1
    end
  end
  form.gpsb_items:ResetChildrenYPos()
  if 0 < table.getn(item_tab) then
    form.lbl_jinfa_back_1.Visible = false
    form.lbl_jinfa_back_2.Visible = false
    form.lbl_back_1.Visible = true
  else
    form.lbl_jinfa_back_1.Visible = true
    form.lbl_jinfa_back_2.Visible = true
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
end
function hide_neigong_data(form)
  form.lbl_name.Text = nx_widestr("")
  form.btn_faculty.item_name = nil
  form.btn_flash.item_name = nil
  form.btn_faculty_on.item_name = nil
  form.lbl_level.Text = nx_widestr("")
  form.mltbox_desc:Clear()
  form.btn_zhuang.item_name = nil
  form.grid_photo:Clear()
  form.grid_photo:SetSelectItemIndex(-1)
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:GridClear(form.grid_photo)
  end
  form.gbox_info.Visible = false
end
function show_neigong_data(form)
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
  hide_neigong_data(form)
  form.lbl_name.Text = gui.TextManager:GetText(nx_string(sel_node.type_name))
  form.mltbox_desc:AddHtmlText(nx_widestr(gui.TextManager:GetText("desc_" .. sel_node.type_name)), -1)
  local neigong = wuxue_query:GetLearnID_NeiGong(nx_string(sel_node.type_name))
  show_faculty_level(form, neigong, sel_node.type_name, WUXUE_NEIGONG)
  if nx_is_valid(neigong) then
    form.btn_flash.item_name = nx_string(sel_node.type_name)
    form.btn_flash.Enabled = form.btn_faculty.Enabled
    form.btn_faculty_on.item_name = nx_string(sel_node.type_name)
    form.btn_faculty_on.Enabled = form.btn_faculty.Enabled
    form.btn_faculty_on.Visible = check_wuxue_is_faculty(form.btn_faculty_on.item_name)
    form.btn_zhuang.item_name = nx_string(sel_node.type_name)
    form.btn_zhuang.Enabled = not check_is_curneigong(form.btn_zhuang.item_name)
    if not form.btn_zhuang.Enabled then
      form.lbl_ani_photo.Visible = false
    end
    set_grid_data(form.grid_photo, neigong, VIEWPORT_NEIGONG)
  else
    form.btn_flash.Enabled = false
    form.btn_faculty_on.Enabled = false
    form.btn_zhuang.Enabled = false
    set_grid_data(form.grid_photo)
  end
  form.gbox_info.Visible = true
  local faculty_query = nx_value("faculty_query")
  if not nx_is_valid(faculty_query) then
    return 0
  end
  local sale_value = faculty_query:GetFacultySale(nx_string(sel_node.type_name))
  show_sale_state(sale_value, form, nx_string(sel_node.type_name))
  show_super_power(form, neigong)
end
function hide_neigong_jf(form)
  for i = 1, NEIGONG_JINFA_COUNT do
    local grid_jinfa = form.gbox_jinfa:Find("grid_jinfa_" .. nx_string(i))
    if nx_is_valid(grid_jinfa) then
      grid_jinfa:Clear()
      grid_jinfa:SetSelectItemIndex(-1)
      grid_jinfa.item_name = nil
      grid_jinfa.item_splv = nil
    end
  end
  form.btn_clearjf.Enabled = false
end
function show_neigong_jf(form)
  if not nx_is_valid(form) then
    return 0
  end
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
  local neigong = wuxue_query:GetLearnID_NeiGong(nx_string(sel_node.type_name))
  if not nx_is_valid(neigong) then
    return 0
  end
  hide_neigong_jf(form)
  if not neigong:FindRecord(TABLE_NAME_NG_JINFA) then
    return 0
  end
  local jinfa_all = nx_value("jinfa_all")
  if not nx_is_valid(jinfa_all) then
    return 0
  end
  local rownum = neigong:GetRecordRows(TABLE_NAME_NG_JINFA)
  for i = 0, rownum - 1 do
    local config_id = neigong:QueryRecord(TABLE_NAME_NG_JINFA, i, 0)
    local item = jinfa_all:GetChild(nx_string(config_id))
    if nx_is_valid(item) then
      local grid_jinfa = form.gbox_jinfa:Find("grid_jinfa_" .. nx_string(item.splv))
      if nx_is_valid(grid_jinfa) then
        grid_jinfa:AddItem(0, item.photo, "", 1, 1)
        grid_jinfa.item_name = nx_string(item.Name)
        grid_jinfa.item_splv = nx_string(item.splv)
        form.btn_clearjf.Enabled = true
      end
    end
  end
end
function show_jinfa_ani(form, splv)
  local timer = nx_value("timer_game")
  if nx_number(splv) == 0 then
    timer:UnRegister(nx_current(), "show_jinfa_ani", form)
  else
    timer:Register(5000, 1, nx_current(), "show_jinfa_ani", form, 0, -1)
  end
  for i = 1, NEIGONG_JINFA_COUNT do
    local lbl_jinfa = form.gbox_jinfa:Find("lbl_jinfa_" .. nx_string(i))
    if nx_is_valid(lbl_jinfa) then
      if i == nx_number(splv) then
        lbl_jinfa.Visible = true
      else
        lbl_jinfa.Visible = false
      end
    end
  end
end
function refresh_ng_jinfa_rec()
  local form = nx_value(FORM_WUXUE_NEIGONG)
  if not nx_is_valid(form) then
    return 0
  end
  show_neigong_jf(form)
end
function set_jinfa_visible(form, is_visible)
  form.gbox_jinfa.Visible = is_visible
  form.lbl_jinfa.Visible = is_visible
  form.lbl_jinfa_1.Visible = is_visible
  form.lbl_jinfa_2.Visible = is_visible
  form.lbl_jinfa_3.Visible = is_visible
  form.lbl_jinfa_4.Visible = is_visible
  form.lbl_jinfa_5.Visible = is_visible
  form.grid_jinfa_1.Visible = is_visible
  form.grid_jinfa_2.Visible = is_visible
  form.grid_jinfa_3.Visible = is_visible
  form.grid_jinfa_5.Visible = is_visible
  form.lbl_nuqi_back.Visible = is_visible
  form.rbtn_splv_1.Visible = is_visible
  form.rbtn_splv_2.Visible = is_visible
  form.rbtn_splv_3.Visible = is_visible
  form.rbtn_splv_4.Visible = is_visible
  form.rbtn_splv_5.Visible = is_visible
  form.btn_clearjf.Visible = is_visible
end
function get_faculty_sale_value(value)
  if nx_int(value) == nx_int(FACULTY_NULL) then
    return 0
  end
  local ini = nx_execute("util_functions", "get_ini", nx_string(SETFACULTYSALE_INI))
  if not nx_is_valid(ini) then
    return 0
  end
  local index = ini:FindSectionIndex(nx_string(value))
  if index < 0 then
    return 0
  end
  local show_value = nx_int(FACULTY_NULL)
  for i = 0, index do
    local zk_value = ini:GetSectionItemKey(index, i)
    if nx_int(zk_value) == nx_int(value) then
      show_value = ini:GetSectionItemValue(index, i)
    end
  end
  return show_value
end
function is_sale_wuxue(wuxue_name)
  local ini = nx_execute("util_functions", "get_ini", nx_string(FACULTYSALE_INI))
  if not nx_is_valid(ini) then
    return 0
  end
  local index = ini:FindSectionIndex(nx_string(wuxue_name))
  if index < 0 then
    return false
  end
  return true
end
function show_sale_state(value, form, ng_name)
  form.pbar_gate.ProgressImage = "gui\\special\\wuxue\\pbar\\jdt.png"
  form.lbl_phase_title.Visible = false
  form.mltbox_title.Visible = true
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local flag = switch_manager:CheckSwitchEnable(ST_FUNCTION_FACULTY_SALE)
  if is_sale_wuxue(ng_name) == false or flag == false then
    form.mltbox_title.Visible = false
    form.lbl_phase_title.Visible = true
    form.lbl_phase_title.Text = nx_widestr(util_text("ui_phase_title"))
    return
  end
  local show_type = nx_int(get_faculty_sale_value(value))
  if nx_int(show_type) == nx_int(FACULTY_ONE) then
    form.mltbox_title.HtmlText = nx_widestr(util_text("ui_faculty_two"))
    form.pbar_gate.ProgressImage = "gui\\special\\wuxue\\pbar\\jdt2.png"
  elseif nx_int(show_type) == nx_int(FACULTY_TWO) then
    form.mltbox_title.HtmlText = nx_widestr(util_text("ui_faculty_one"))
    form.pbar_gate.ProgressImage = "gui\\special\\wuxue\\pbar\\jdt1.png"
  else
    form.mltbox_title.HtmlText = nx_widestr(util_text("ui_faculty_normal"))
  end
end
function show_super_power(form, wuxue)
  if not nx_is_valid(form) or not nx_is_valid(wuxue) then
    return
  end
  local max_power = wuxue:QueryProp("MaxPowerValue")
  if nx_int(max_power) > nx_int(0) then
    form.groupbox_power.Visible = true
    form.btn_faculty_on.Visible = false
    form.btn_flash.Visible = false
    form.btn_faculty.Visible = false
    local cur_power = wuxue:QueryProp("PowerValue")
    form.pbar_power.Maximum = nx_int(max_power)
    form.pbar_power.Value = nx_int(cur_power)
    if nx_int(cur_power) >= nx_int(max_power) then
      form.pbar_power_point.Visible = true
    else
      form.pbar_power_point.Visible = false
    end
  else
    form.groupbox_power.Visible = false
    form.btn_flash.Visible = true
    form.btn_faculty.Visible = true
  end
end
