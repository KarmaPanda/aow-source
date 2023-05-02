require("util_gui")
require("util_static_data")
require("role_composite")
require("share\\static_data_type")
require("util_functions")
local FORM_PATH = "form_stage_main\\form_attire\\form_attire_origin"
function open_form()
  local form = nx_value(FORM_PATH)
  if nx_is_valid(form) then
    form:Close()
  end
  form = nx_execute("util_gui", "util_get_form", FORM_PATH, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
local PAGE_COUNT = 8
function on_main_form_init(self)
  self.Fixed = true
  self.cur_page = 0
  self.max_page = 1
  self.main_type = 0
  self.sub_type = ""
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return
  end
  attire_manager:LoadsfRes()
  form.rbtn_school.Checked = true
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_rbtn_school_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.main_type = rbtn.TabIndex
    form.cur_page = 0
    form.sub_type = ""
    set_drop_box(form)
    show_suit_info(form)
  end
end
function set_copy_ent_info(form, source, target_ent)
  local source_ent = nx_custom(form, source)
  if not nx_is_valid(source_ent) then
    return
  end
  local prop_list = nx_property_list(source_ent)
  for i, prop in ipairs(prop_list) do
    if "Name" ~= prop then
      nx_set_property(target_ent, prop, nx_property(source_ent, prop))
    end
  end
end
function create_groupbox(form, index, config_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if config_id == nil or config_id == "" then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return
  end
  local gui = nx_value("gui")
  local groupbox = gui:Create("GroupBox")
  set_copy_ent_info(form, "groupbox_sub", groupbox)
  groupbox.Name = form.groupbox_sub.Name .. nx_string(index)
  local child_ctrls = form.groupbox_sub:GetChildControlList()
  for i, ctrl in ipairs(child_ctrls) do
    local ctrl_obj = gui:Create(nx_name(ctrl))
    set_copy_ent_info(form, ctrl.Name, ctrl_obj)
    ctrl_obj.Name = ctrl.Name .. nx_string(index)
    groupbox:Add(ctrl_obj)
  end
  local lbl_name = groupbox:Find("lbl_name" .. nx_string(index))
  lbl_name.Text = util_text(nx_string(config_id))
  local photo = query_arrire_item_photo(nx_string(config_id), "Photo")
  local control_name = "imagegrid_8" .. nx_string(index)
  local imagegrid = groupbox:Find(control_name)
  imagegrid.tips_config = config_id
  imagegrid.item_type = item_type
  imagegrid:AddItem(0, photo, util_text(nx_string(config_id)), 1, -1)
  nx_bind_script(imagegrid, nx_current())
  nx_callback(imagegrid, "on_mousein_grid", "on_mousein_grid")
  nx_callback(imagegrid, "on_mouseout_grid", "on_mouseout_grid")
  nx_callback(imagegrid, "on_select_changed", "on_imagegrid_select_changed")
  local conditionid = ItemQuery:GetItemPropByConfigID(nx_string(config_id), "ConditionID")
  local have_no_active = false
  local conditon_manager = nx_value("ConditionManager")
  if nx_is_valid(conditon_manager) then
    have_no_active = conditon_manager:CanSatisfyCondition(client_player, client_player, nx_int(conditionid))
  end
  local lbl_have = groupbox:Find("lbl_1" .. nx_string(index))
  if have_no_active then
    lbl_have.HtmlText = util_text("ui_attire_origin_2")
  else
    lbl_have.HtmlText = util_text("ui_attire_origin_1")
  end
  local mltbox = groupbox:Find("mltbox_1" .. nx_string(index))
  if conditionid == "" or conditionid == nil then
    mltbox.HtmlText = util_text("desc_condition_" .. nx_string(config_id))
    lbl_have.HtmlText = nx_widestr("")
  else
    mltbox.HtmlText = util_text("desc_condition_" .. nx_string(conditionid))
  end
  groupbox.item_index = index
  groupbox.config_id = config_id
  return groupbox
end
function on_combobox_1_selected(combo)
  local form = combo.ParentForm
  local list = combo.DropListBox
  local sel_index = list.SelectIndex
  if sel_index < 0 then
    return
  end
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return
  end
  local table_school = attire_manager:GetSchoolsByType(form.main_type)
  local school = table_school[sel_index + 1]
  if school ~= nil then
    form.sub_type = school
    form.cur_page = 0
    show_suit_info(form)
  end
end
function set_drop_box(form)
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return
  end
  local list = form.combobox_1.DropListBox
  list:ClearString()
  local table_school = attire_manager:GetSchoolsByType(form.main_type)
  local count = table.getn(table_school)
  for i = 1, count do
    list:AddString(util_text(nx_string(table_school[i])))
  end
  form.combobox_1.DroppedDown = false
end
function on_mousein_grid(grid, index)
  local ConfigID = nx_custom(grid, "tips_config")
  nx_execute("tips_game", "show_tips_by_config", ConfigID, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_select_changed(grid)
  local config_id = nx_custom(grid, "tips_config")
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  local form = grid.ParentForm
  local need_sex = item_query:GetItemPropByConfigID(config_id, "NeedSex")
  local player_sex = get_player_sex()
  local use_equip = false
  if nx_int(need_sex) == nx_int(2) or nx_int(player_sex) == nx_int(need_sex) then
    use_equip = true
  end
  if use_equip == false then
    return
  end
  nx_execute("form_stage_main\\form_attire\\form_attire_main", "player_link_sf", config_id, form.main_type)
end
function get_player_sex()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nil
  end
  return client_player:QueryProp("Sex")
end
function on_rbtn_type_all_checked_changed(rbtn)
end
function on_rbtn_type_haved_checked_changed(rbtn)
end
function show_suit_info(form)
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return
  end
  form.groupbox_1:DeleteAll()
  local begin = form.cur_page * PAGE_COUNT
  local size = PAGE_COUNT
  local table_count = 0
  local item_list = {}
  if form.sub_type == "" then
    table_count = attire_manager:GetTypeSchoolSuitCount(form.main_type)
  else
    table_count = attire_manager:GetSchoolSuitCount(form.sub_type)
  end
  if table_count - begin < PAGE_COUNT then
    size = table_count - begin
  end
  set_max_page(table_count)
  local bAll = false
  if form.sub_type == "" then
    item_list = attire_manager:GetSomeSuitByType(form.main_type, begin, size)
    bAll = true
  else
    item_list = attire_manager:GetSchoolSuit(form.sub_type)
  end
  local index = 0
  for i = 1, size do
    if bAll then
      index = i
    else
      index = begin + i
    end
    local config_id = item_list[index]
    local groupbox = create_groupbox(form, i, config_id)
    if nx_is_valid(groupbox) then
      groupbox.Left = (i - 1) % 2 * groupbox.Width
      groupbox.Top = nx_int((i - 1) / 2) * (groupbox.Height - 8)
      form.groupbox_1:Add(groupbox)
    end
  end
  form.lbl_page.Text = nx_widestr(nx_string(form.cur_page + 1) .. "/" .. nx_string(form.max_page))
end
function get_show_start(table_school, start)
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return nil, nil
  end
  local index = 0
  for i, v in ipairs(table_school) do
    if start <= index then
      return i, index - start
    end
    index = index + attire_manager:GetSchoolSuitCount(v)
  end
  return nil, nil
end
function set_max_page(num)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return 0
  end
  form.max_page = math.ceil(num / PAGE_COUNT)
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.max_page > 0 and 0 < form.cur_page then
    form.cur_page = form.cur_page - 1
    show_suit_info(form)
  end
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.max_page > 0 and form.cur_page < form.max_page - 1 then
    form.cur_page = form.cur_page + 1
    show_suit_info(form)
  end
end
function query_arrire_item_photo(id, prop, sex)
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return ""
  end
  local row = nx_int(item_query:GetItemPropByConfigID(id, "ArtPack"))
  local item_type = item_query:GetItemPropByConfigID(id, "ItemType")
  if sex == nil then
    sex = 0
    local game_client = nx_value("game_client")
    local client_palyer = game_client:GetPlayer()
    if nx_is_valid(client_palyer) then
      sex = client_palyer:QueryProp("Sex")
    end
  end
  if "Photo" == prop and 0 ~= sex then
    prop = "FemalePhoto"
    local result = item_static_query(row, prop, STATIC_DATA_ITEM_ART)
    if "" == result then
      prop = "Photo"
    end
  end
  return item_static_query(row, prop, STATIC_DATA_ITEM_ART)
end
function query_arrire_item_modle(id, prop, sex)
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return ""
  end
  local row = nx_int(item_query:GetItemPropByConfigID(id, "ArtPack"))
  if sex == nil then
    sex = 0
    local game_client = nx_value("game_client")
    local client_palyer = game_client:GetPlayer()
    if nx_is_valid(client_palyer) then
      sex = client_palyer:QueryProp("Sex")
    end
  end
  if "MaleModel" == prop and 0 ~= sex then
    prop = "FemaleModel"
    local result = item_static_query(row, prop, STATIC_DATA_ITEM_ART)
    if "" == result then
      prop = "MaleModel"
    end
  end
  return item_static_query(row, prop, STATIC_DATA_ITEM_ART)
end
function on_btn_all_click(btn)
  local form = btn.ParentForm
  form.cur_page = 0
  form.sub_type = ""
  form.combobox_1.Text = nx_widestr("")
  show_suit_info(form)
end
function on_btn_1_click(btn)
  nx_execute("form_stage_main\\form_attire\\form_attire_main", "player_unlink_sf")
end
