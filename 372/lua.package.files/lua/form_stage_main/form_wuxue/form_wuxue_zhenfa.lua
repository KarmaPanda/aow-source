require("form_stage_main\\form_wuxue\\form_wuxue_util")
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function main_form_init(form)
  form.Fixed = true
  form.sel_item_index = -1
  return 1
end
function main_form_open(form)
  hide_item_data(form)
  form.lbl_ani_photo.Visible = false
  form.btn_faculty_on.Visible = false
  form.is_open = false
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_SKILL, form, nx_current(), "on_view_skill_operat")
    databinder:AddViewBind(VIEWPORT_ZHENFA, form, nx_current(), "on_view_zhenfa_operat")
    databinder:AddRolePropertyBind("FacultyName", "string", form, nx_current(), "prop_callback_facultyname")
    databinder:AddRolePropertyBind("FacultyStyle", "int", form, nx_current(), "prop_callback_facultystyle")
  end
  form.is_open = true
  show_type_data(form)
  return 1
end
function main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form)
    databinder:DelRolePropertyBind("FacultyName", form)
    databinder:DelRolePropertyBind("FacultyStyle", form)
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
  if not nx_find_custom(self, "wuxue_type") then
    return 0
  end
  show_faculty_info(self, "item_name", self.wuxue_type)
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
  if not set_node_select(self, cur_node, pre_node) then
    return 0
  end
  if nx_find_custom(form, "type_name") and nx_find_custom(cur_node, "type_name") and form.type_name ~= cur_node.type_name then
    form.lbl_ani_photo.Visible = false
    form.type_name = ""
    form.item_name = ""
  end
  show_item_data(form)
end
function on_tree_types_left_click(self, node)
  local form = self.ParentForm
  if not nx_id_equal(self.SelectNode, node) then
    return 0
  end
end
function on_grid_photo_select_changed(grid, index)
  select_one_item(grid.ParentForm, grid.DataSource)
  local view_index = grid:GetBindIndex(index)
  if view_index < 0 then
    return 0
  end
  local goodsgrid = nx_value("GoodsGrid")
  if not nx_is_valid(goodsgrid) then
    return
  end
  goodsgrid:ViewGridOnSelectItem(grid, -1)
  grid:SetSelectItemIndex(-1)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_grid_photo_drag_enter(grid, index)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    local game_hand = gui.GameHand
    game_hand.IsDragged = false
    game_hand.IsDropped = false
  end
end
function on_grid_photo_drag_move(grid, index)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    local game_hand = gui.GameHand
    if not game_hand.IsDragged then
      game_hand.IsDragged = true
      local goodsgrid = nx_value("GoodsGrid")
      if not nx_is_valid(goodsgrid) then
        return
      end
      goodsgrid:ViewGridOnSelectItem(grid, -1)
    end
  end
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
  if not nx_find_custom(self, "wuxue_type") then
    return 0
  end
  local bSuccess = nx_execute("faculty", "set_faculty_wuxue", self.item_name)
  if bSuccess == true then
    auto_show_hide_wuxue()
  end
end
function on_view_zhenfa_operat(form, optype, view_ident, index)
  if nx_is_valid(form) and not form.is_open then
    return 0
  end
  if nx_string(optype) == "updateitem" then
    local timer = nx_value("timer_game")
    timer:Register(CALLBACK_WAIT_TIME, 1, nx_current(), "show_type_data", form, -1, -1)
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
  form.item_name = ""
  show_type_data(form)
  set_radio_btns()
  switch_sub_page(WUXUE_ZHENFA)
end
function on_view_skill_operat(form, optype, view_ident, index)
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
  local type_name = get_type_by_wuxue_id(item_name, WUXUE_ZHENFA)
  if type_name == "" then
    return 0
  end
  form.type_name = type_name
  form.item_name = item_name
  show_type_data(form)
  set_radio_btns()
  switch_sub_page(WUXUE_ZHENFA)
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
function show_type_data(form)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return 0
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local root = form.tree_types:CreateRootNode("")
  local learned_zf_count = 0
  local sel_type_node
  form.tree_types:BeginUpdate()
  local type_tab = wuxue_query:GetMainNames(WUXUE_ZHENFA)
  for i = 1, table.getn(type_tab) do
    local type_name = type_tab[i]
    local sub_type_tab = wuxue_query:GetSubNames(WUXUE_ZHENFA, type_name)
    for j = 1, table.getn(sub_type_tab) do
      local sub_type_name = sub_type_tab[j]
      local sub_type = wuxue_query:GetLearnID_ZhenFa(sub_type_name)
      local type_text = gui.TextManager:GetText(type_name)
      local type_node = root:FindNode(nx_widestr(type_text))
      if not nx_is_valid(type_node) then
        type_node = root:CreateNode(nx_widestr(type_text))
        set_node_prop(type_node, 1)
      end
      local sub_type_text = gui.TextManager:GetText(sub_type_name)
      local sub_type_node = type_node:CreateNode(nx_widestr(sub_type_text))
      if nx_is_valid(sub_type_node) then
        sub_type_node.type_name = sub_type_name
        set_node_prop(sub_type_node, 2)
      end
      if nx_is_valid(sub_type) then
        type_node.ShowCoverImage = false
        sub_type_node.ShowCoverImage = false
        sub_type_node.ForeColor = "255,101,80,63"
        learned_zf_count = learned_zf_count + 1
      else
        sub_type_node.ShowCoverImage = true
        sub_type_node.ForeColor = "255,123,114,106"
      end
      if nx_find_custom(form, "type_name") and nx_string(form.type_name) == nx_string(sub_type_name) then
        sel_type_node = sub_type_node
      end
    end
  end
  form.lbl_zfcount.Text = nx_widestr(learned_zf_count)
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
  form.mltbox_desc.HtmlText = nx_widestr("")
end
function show_item_data(form)
  local gui = nx_value("gui")
  local sel_item_index = 1
  if nx_int(form.sel_item_index) > nx_int(0) then
    sel_item_index = form.sel_item_index
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
  local zhenfa_id = sel_node.type_name
  hide_item_data(form)
  local item_tab = wuxue_query:GetItemNames(WUXUE_ZHENFA, zhenfa_id)
  for i = 1, table.getn(item_tab) + 1 do
    local item_name = item_tab[i - 1]
    local gbox_item = form.gpsb_items:Find("gbox_item_" .. i)
    if not nx_is_valid(gbox_item) then
      break
    end
    local grid_photo = gbox_item:Find("grid_photo_" .. i)
    local lbl_name = gbox_item:Find("lbl_name_" .. i)
    local lbl_level = gbox_item:Find("lbl_level_" .. i)
    local btn_select = gbox_item:Find("btn_select_" .. i)
    if not (nx_is_valid(grid_photo) and nx_is_valid(lbl_name) and nx_is_valid(lbl_level)) or not nx_is_valid(btn_select) then
      break
    end
    if i == 1 then
      item_name = zhenfa_id
    end
    local item = nx_null()
    if i == 1 then
      item = wuxue_query:GetLearnID_ZhenFa(item_name)
    else
      item = wuxue_query:GetLearnID_Skill(item_name)
    end
    btn_select.item_name = item_name
    lbl_name.Text = gui.TextManager:GetFormatText(item_name)
    if nx_is_valid(item) then
      if i == 1 then
        set_grid_data(grid_photo, item, VIEWPORT_ZHENFA)
        show_wuxue_level(lbl_level, item, WUXUE_ZHENFA)
        btn_select.wuxue_type = WUXUE_ZHENFA
      else
        set_grid_data(grid_photo, item, VIEWPORT_SKILL)
        show_wuxue_level(lbl_level, item, WUXUE_SKILL)
        btn_select.wuxue_type = WUXUE_SKILL
      end
      if nx_find_custom(form, "item_name") and nx_string(form.item_name) == nx_string(item_name) then
        sel_item_index = i
      end
    else
      set_grid_data(grid_photo, item, VIEWPORT_SKILL)
      show_wuxue_level(lbl_level, item, WUXUE_SKILL)
      btn_select.wuxue_type = WUXUE_SKILL
    end
    gbox_item.Visible = true
  end
  form.gpsb_items:ResetChildrenYPos()
  if 0 < sel_item_index then
    select_one_item(form, sel_item_index)
  end
  form.lbl_skill_back_1.Visible = false
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
  if not nx_find_custom(btn_select, "item_name") then
    return 0
  end
  if not nx_find_custom(btn_select, "wuxue_type") then
    return 0
  end
  if btn_select.wuxue_type == WUXUE_ZHENFA then
    show_zhenfa_data(form)
  elseif btn_select.wuxue_type == WUXUE_SKILL then
    show_skill_data(form, btn_select.item_name)
  end
end
function hide_zhenfa_data(form)
  form.lbl_name.Text = nx_widestr("")
  form.btn_faculty.item_name = nil
  form.btn_faculty_on.item_name = nil
  form.lbl_level.Text = nx_widestr("")
  form.mltbox_desc:Clear()
  form.grid_photo:Clear()
  form.grid_photo:SetSelectItemIndex(-1)
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:GridClear(form.grid_photo)
  end
  form.gbox_info.Visible = false
end
function show_zhenfa_data(form)
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
  local zhenfa_id = sel_node.type_name
  hide_zhenfa_data(form)
  form.lbl_name.Text = gui.TextManager:GetText(nx_string(zhenfa_id))
  form.mltbox_desc:AddHtmlText(gui.TextManager:GetText("desc_" .. zhenfa_id), -1)
  local zhenfa = wuxue_query:GetLearnID_ZhenFa(zhenfa_id)
  show_faculty_level(form, zhenfa, zhenfa_id, WUXUE_ZHENFA)
  if nx_is_valid(zhenfa) then
    form.btn_faculty_on.item_name = nx_string(zhenfa_id)
    form.btn_faculty_on.Enabled = form.btn_faculty.Enabled
    form.btn_faculty_on.Visible = check_wuxue_is_faculty(form.btn_faculty_on.item_name)
    set_grid_data(form.grid_photo, zhenfa, VIEWPORT_ZHENFA)
    show_item_action(form, zhenfa_id, WUXUE_SHOW_ZHENFA)
    add_zhenfa_weapon(form, zhenfa_id)
    form.mltbox_get_desc.Visible = false
  else
    form.btn_faculty_on.Enabled = false
    form.mltbox_get_desc.HtmlText = gui.TextManager:GetText(get_zf_get_desc(zhenfa_id))
    form.mltbox_get_desc.Visible = true
    set_grid_data(form.grid_photo)
  end
  form.gbox_info.Visible = true
end
function hide_skill_data(form)
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
  form.gbox_info.Visible = false
end
function show_skill_data(form, skill_id)
  local gui = nx_value("gui")
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  hide_skill_data(form)
  form.lbl_name.Text = gui.TextManager:GetText(nx_string(skill_id))
  form.mltbox_desc:AddHtmlText(nx_widestr(gui.TextManager:GetText("desc_" .. skill_id)), -1)
  local skill = wuxue_query:GetLearnID_Skill(skill_id)
  show_faculty_level(form, skill, skill_id, WUXUE_SKILL)
  if nx_is_valid(skill) then
    set_grid_data(form.grid_photo, skill, VIEWPORT_SKILL)
    show_item_action(form, skill_id, WUXUE_SHOW_SKILL, true)
    add_weapon(form, skill_id)
    form.mltbox_get_desc.Visible = false
  else
    set_grid_data(form.grid_photo)
    form.mltbox_get_desc.HtmlText = gui.TextManager:GetText(get_zf_get_desc(skill_id))
    form.mltbox_get_desc.Visible = true
  end
  form.gbox_info.Visible = true
end
function get_zf_get_desc(zhenfa_id)
  local ini = nx_call("util_functions", "get_ini", INI_FILE_ZF_GETDESC, true)
  if not nx_is_valid(ini) then
    return ""
  end
  local index = ini:FindSectionIndex(nx_string(zhenfa_id))
  if 0 <= index then
    return ini:ReadString(index, "GetDesc", "")
  end
  return ""
end
