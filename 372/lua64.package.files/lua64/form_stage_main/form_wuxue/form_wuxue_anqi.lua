require("form_stage_main\\form_wuxue\\form_wuxue_util")
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
    databinder:AddViewBind(VIEWPORT_EQUIP, form, nx_current(), "on_equip_view_operat")
    databinder:AddViewBind(VIEWPORT_SHOUFA, form, nx_current(), "on_shoufa_view_operat")
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
  show_faculty_info(self, "item_name", WUXUE_ANQI)
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
  end
  show_item_data(form)
  show_aq_action(form)
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
function on_shoufa_view_operat(form, optype, view_ident, index)
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
  local type_name = get_type_by_wuxue_id(item_name, WUXUE_ANQI)
  if type_name == "" then
    return 0
  end
  form.type_name = type_name
  form.item_name = item_name
  show_type_data(form)
  set_radio_btns()
  switch_sub_page(WUXUE_ANQI)
end
function on_equip_view_operat(form, optype, view_ident, index)
  if nx_is_valid(form) and not form.is_open then
    return 0
  end
  if nx_string(optype) == "updateitem" then
    local timer = nx_value("timer_game")
    timer:Register(CALLBACK_WAIT_TIME, 1, nx_current(), "show_item_data", form, -1, -1)
  else
    show_item_data(form)
  end
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
  local sel_type_node
  form.tree_types:BeginUpdate()
  local type_tab = wuxue_query:GetMainNames(WUXUE_ANQI)
  for i = 1, table.getn(type_tab) do
    local type_name = type_tab[i]
    if check_anqi_is_learn(type_name) then
      local type_text = gui.TextManager:GetText(type_name)
      local type_node = root:CreateNode(nx_widestr(type_text))
      type_node.type_name = type_name
      set_node_prop(type_node, 1)
      if nx_find_custom(form, "type_name") and nx_string(form.type_name) == nx_string(type_name) then
        sel_type_node = type_node
      end
    end
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_SHOUFA))
  if nx_is_valid(view) then
    local anqi_list = view:GetViewObjList()
    form.lbl_aqcount.Text = nx_widestr(table.getn(anqi_list))
  end
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
  local show_count = 1
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
  hide_item_data(form)
  local item_tab = wuxue_query:GetItemNames(WUXUE_ANQI, sel_node.type_name)
  for i = 1, table.getn(item_tab) do
    local item_name = item_tab[i]
    local item = wuxue_query:GetLearnID_ShouFa(nx_string(item_name))
    if nx_is_valid(item) then
      local gbox_item = form.gpsb_items:Find("gbox_item_" .. show_count)
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
      grid_photo.item_name = nx_string(item_name)
      btn_select.item_name = nx_string(item_name)
      lbl_name.Text = nx_widestr(gui.TextManager:GetFormatText(nx_string(item_name)))
      set_grid_data(grid_photo, item, VIEWPORT_SHOUFA)
      show_wuxue_level(lbl_level, item, WUXUE_ANQI)
      lbl_ani.Visible = check_shoufa_is_active(nx_string(item_name))
      if nx_find_custom(form, "item_name") and nx_string(form.item_name) == nx_string(item_name) then
        sel_item_index = show_count
      end
      gbox_item.Visible = true
      show_count = show_count + 1
    end
  end
  form.gpsb_items:ResetChildrenYPos()
  if 1 < show_count then
    select_one_item(form, sel_item_index)
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
  if not nx_find_custom(btn_select, "item_name") then
    return 0
  end
  show_shoufa_data(form, btn_select.item_name)
  form.mltbox_desc.HtmlText = gui.TextManager:GetFormatText("desc_sf_" .. btn_select.item_name)
end
function hide_shoufa_data(form)
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
function show_shoufa_data(form, shoufa_id)
  local gui = nx_value("gui")
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  hide_shoufa_data(form)
  form.lbl_name.Text = gui.TextManager:GetText(nx_string(shoufa_id))
  form.mltbox_desc:AddHtmlText(gui.TextManager:GetFormatText("desc_sf_" .. shoufa_id), -1)
  local shoufa = wuxue_query:GetLearnID_ShouFa(shoufa_id)
  show_faculty_level(form, shoufa, shoufa_id, WUXUE_ANQI)
  if nx_is_valid(shoufa) then
    form.btn_faculty_on.item_name = nx_string(shoufa_id)
    form.btn_faculty_on.Enabled = form.btn_faculty.Enabled
    form.btn_faculty_on.Visible = check_wuxue_is_faculty(form.btn_faculty_on.item_name)
  else
    form.btn_faculty_on.Enabled = false
  end
  set_grid_data(form.grid_photo, shoufa, VIEWPORT_SHOUFA)
  form.gbox_info.Visible = true
end
function show_aq_action(form)
  local gui = nx_value("gui")
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return 0
  end
  if not nx_find_custom(sel_node, "type_name") then
    return 0
  end
  show_item_action(form, sel_node.type_name, WUXUE_SHOW_ANQI)
end
