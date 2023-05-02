require("util_gui")
require("util_static_data")
require("role_composite")
require("share\\static_data_type")
require("util_functions")
local FORM_PATH = "form_stage_main\\form_attire\\form_attire_jianghu_suit"
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
local BLEND_COLLECT_REC = "blend_collect_rec"
function on_main_form_init(self)
  self.Fixed = true
  self.cur_page = 0
  self.max_page = 1
  self.select_grid = nil
end
function on_main_form_open(form)
  form.rbtn_type_all.Checked = true
  add_data_bind(form)
  show_suit_info(form)
end
function on_main_form_close(form)
  del_data_bind(form)
  nx_destroy(form)
end
function add_data_bind(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind(BLEND_COLLECT_REC, form, nx_current(), "on_table_rec_changed")
  end
end
function del_data_bind(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind(BLEND_COLLECT_REC, form)
  end
end
function on_table_rec_changed(form, rec_name, opt_type, row, col)
  if nx_int(col) == nx_int(BLENDCOLLECT_REC_COL_USEDNUM) or nx_int(col) == nx_int(BLENDCOLLECT_REC_COL_ACTIVE) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "show_suit_info", form)
    timer:Register(500, 1, nx_current(), "show_suit_info", form, -1, -1)
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
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return false
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
  lbl_name.Text = util_text(config_id)
  local item_list = attire_manager:GetAttireSuitItemConfigID(config_id)
  local rows = table.getn(item_list)
  if rows < 4 then
    return
  end
  local have_no_active = false
  for i = 0, rows - 1 do
    local ItemsQuery = nx_value("ItemQuery")
    local suit_sub_congfig = item_list[i + 1]
    local photo = query_arrire_item_photo(nx_string(suit_sub_congfig), "Photo")
    local item_type = ItemsQuery:GetItemPropByConfigID(nx_string(suit_sub_congfig), nx_string("ItemType"))
    local control_name = "imagegrid_" .. nx_string(i + 1) .. nx_string(index)
    local imagegrid = groupbox:Find(control_name)
    imagegrid.tips_config = suit_sub_congfig
    imagegrid.photo = photo
    imagegrid.item_type = item_type
    imagegrid:AddItem(0, photo, util_text(suit_sub_congfig), 1, -1)
    if not attire_manager:AttireItemActive(suit_sub_congfig) then
      imagegrid:ChangeItemImageToBW(0, true)
      have_no_active = true
    end
    nx_bind_script(imagegrid, nx_current())
    nx_callback(imagegrid, "on_mousein_grid", "on_mousein_grid")
    nx_callback(imagegrid, "on_mouseout_grid", "on_mouseout_grid")
    nx_callback(imagegrid, "on_select_changed", "on_imagegrid_select_changed")
  end
  local lbl_name = groupbox:Find("lbl_have" .. nx_string(index))
  if have_no_active then
    lbl_name.HtmlText = util_text("ui_attire_lack")
  else
    lbl_name.HtmlText = util_text("ui_attire_full")
  end
  groupbox.item_index = index
  groupbox.config_id = config_id
  return groupbox
end
function on_mousein_grid(grid, index)
  local ConfigID = nx_custom(grid, "tips_config")
  if nx_string(ConfigID) == nx_string("") then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", ConfigID, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_select_changed(grid)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local config_id = nx_custom(grid, "tips_config")
  local photo = nx_custom(grid, "photo")
  local item_type = nx_custom(grid, "item_type")
  local modle_path = query_arrire_item_modle(config_id, "MaleModel")
  if form.select_grid ~= nil then
    form.select_grid:SetSelectItemIndex(-1)
    form.select_grid = nil
  end
  nx_execute("form_stage_main\\form_attire\\form_attire_jianghu", "use_arrire_item", config_id, item_type, photo, modle_path)
  if grid:GetSelectItemIndex() then
    form.select_grid = grid
  end
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
  if form.select_grid ~= nil then
    form.select_grid:SetSelectItemIndex(-1)
    form.select_grid = nil
  end
  form.groupscrollbox_1:DeleteAll()
  local item_list = attire_manager:GetAttireItemConfigList("suit")
  local begin = form.cur_page * PAGE_COUNT
  local size = PAGE_COUNT
  local table_count = table.getn(item_list)
  if table_count - begin < PAGE_COUNT then
    size = table_count - begin
  end
  set_max_page(table_count)
  for i = 1, size do
    local index = begin + i
    local config_id = item_list[begin + i]
    local groupbox = create_groupbox(form, i, config_id)
    if nx_is_valid(groupbox) then
      groupbox.Left = (i - 1) % 2 * groupbox.Width
      groupbox.Top = nx_int((i - 1) / 2) * (groupbox.Height - 8)
      form.groupscrollbox_1:Add(groupbox)
    end
  end
  form.lbl_page.Text = nx_widestr(nx_string(form.cur_page + 1) .. "/" .. nx_string(form.max_page))
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
