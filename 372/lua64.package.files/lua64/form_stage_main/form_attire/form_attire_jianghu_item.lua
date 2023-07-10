require("util_gui")
require("util_static_data")
require("role_composite")
require("share\\static_data_type")
require("util_functions")
local BLENDCOLLECT_REC_COL_CONFIGID = 0
local BLENDCOLLECT_REC_COL_OWNNUM = 1
local BLENDCOLLECT_REC_COL_USEDNUM = 2
local BLENDCOLLECT_REC_COL_ACTIVE = 3
local BLENDCOLLECT_REC_COL_COUNT = 4
local FORM_PATH = "form_stage_main\\form_attire\\form_attire_jianghu_item"
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
local PAGE_COUNT = 10
local BLEND_COLLECT_REC = "blend_collect_rec"
local ATTIRE_TYPE_HAT = 1
local ATTIRE_TYPE_CLOTH = 2
local ATTIRE_TYPE_PLANTS = 3
local ATTIRE_TYPE_SHOES = 4
function on_main_form_init(self)
  self.Fixed = true
  self.cur_page = 0
  self.max_page = 1
  self.show_type = ""
  self.show_active = false
  self.select_grid = nil
end
function on_main_form_open(form)
  form.rbtn_type_all.Checked = true
  add_data_bind(form)
  show_attire_item_info(form)
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
  if nx_int(col) == nx_int(BLENDCOLLECT_REC_COL_ACTIVE) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "show_attire_item_info", form)
    timer:Register(500, 1, nx_current(), "show_attire_item_info", form, -1, -1)
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
  local ItemQuery = nx_value("ItemQuery")
  local photo = query_arrire_item_photo(nx_string(config_id), "Photo")
  local color_level = ItemQuery:GetItemPropByConfigID(nx_string(config_id), nx_string("ColorLevel"))
  local item_type = ItemQuery:GetItemPropByConfigID(nx_string(config_id), nx_string("ItemType"))
  local is_infinite = ItemQuery:GetItemPropByConfigID(nx_string(config_id), nx_string("InfiniteBlend"))
  local lbl_level_control = groupbox:Find("lbl_level" .. nx_string(index))
  local color_text = gui.TextManager:GetText("ui_market_color_level_" .. nx_string(color_level))
  lbl_level_control.Text = color_text
  local control_name = "imagegrid_1" .. nx_string(index)
  local imagegrid = groupbox:Find(control_name)
  imagegrid.tips_config = config_id
  imagegrid.photo = photo
  imagegrid.item_type = item_type
  local count = 1
  if nx_int(is_infinite) ~= nx_int(1) then
    count = GetItemAmount(config_id)
    if nx_int(count) <= nx_int(0) then
      count = 1
    end
  end
  imagegrid:AddItem(0, photo, util_text(config_id), count, -1)
  local lbl_name = groupbox:Find("lbl_have" .. nx_string(index))
  if not attire_manager:AttireItemActive(config_id) then
    imagegrid:ChangeItemImageToBW(0, true)
    lbl_name.HtmlText = util_text("ui_attire_nogather")
  else
    lbl_name.HtmlText = util_text("ui_attire_gather")
  end
  nx_bind_script(imagegrid, nx_current())
  nx_callback(imagegrid, "on_mousein_grid", "on_mousein_grid")
  nx_callback(imagegrid, "on_mouseout_grid", "on_mouseout_grid")
  nx_callback(imagegrid, "on_select_changed", "on_imagegrid_select_changed")
  local control_name = "imagegrid_equip_info" .. nx_string(index)
  local imagegrid_equip_info = groupbox:Find(control_name)
  imagegrid_equip_info.tips_config = get_equip_config_id(config_id)
  nx_bind_script(imagegrid_equip_info, nx_current())
  nx_callback(imagegrid_equip_info, "on_mousein_grid", "on_mousein_grid")
  nx_callback(imagegrid_equip_info, "on_mouseout_grid", "on_mouseout_grid")
  if not ItemQuery:FindItemByConfigID(imagegrid_equip_info.tips_config) then
    imagegrid_equip_info.Visible = false
  end
  groupbox.item_index = index
  groupbox.config_id = config_id
  return groupbox
end
function on_mousein_grid(grid, index)
  local config_id = nx_custom(grid, "tips_config")
  if nx_string(config_id) == nx_string("") then
    return
  end
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  if not item_query:FindItemByConfigID(config_id) then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", config_id, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_select_changed(grid, index)
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
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.show_active = false
  form.cur_page = 0
  show_attire_item_info(form)
end
function on_rbtn_active_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.show_active = true
  form.cur_page = 0
  show_attire_item_info(form)
end
function show_attire_item_info(form)
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return
  end
  if form.select_grid ~= nil then
    form.select_grid:SetSelectItemIndex(-1)
    form.select_grid = nil
  end
  form.groupscrollbox_1:DeleteAll()
  local item_list
  if form.show_active then
    item_list = attire_manager:GetActiveAttireItemConfigList(form.show_type)
  else
    item_list = attire_manager:GetAttireItemConfigList(form.show_type)
  end
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
  if 0 >= form.max_page then
    form.max_page = 1
  end
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.max_page > 0 and 0 < form.cur_page then
    form.cur_page = form.cur_page - 1
    show_attire_item_info(form)
  end
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.max_page > 0 and form.cur_page < form.max_page - 1 then
    form.cur_page = form.cur_page + 1
    show_attire_item_info(form)
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
function on_btn_use_click(btn)
  nx_execute("form_stage_main\\form_attire\\form_attire_copy", "open_form")
end
function get_equip_config_id(value)
  local game_client = nx_value("game_client")
  local client_palyer = game_client:GetPlayer()
  if nx_is_valid(client_palyer) then
    sex = client_palyer:QueryProp("Sex")
  end
  local find_string = "Tab_b_"
  if 0 ~= sex then
    find_string = "Tab_g_"
  end
  local split_pos = string.len(find_string)
  local equip_config_id = string.sub(value, split_pos + 1, string.len(value))
  return equip_config_id
end
function GetItemAmount(config_id)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return 1
  end
  local is_infinite = ItemQuery:GetItemPropByConfigID(nx_string(config_id), nx_string("InfiniteBlend"))
  if nx_int(is_infinite) == nx_int(1) then
    return 1
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 1
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 1
  end
  if not client_player:FindRecord(BLEND_COLLECT_REC) then
    return 1
  end
  local rows = client_player:GetRecordRows(BLEND_COLLECT_REC)
  for i = 0, rows - 1 do
    local configid = client_player:QueryRecord(BLEND_COLLECT_REC, i, BLENDCOLLECT_REC_COL_CONFIGID)
    local amount = client_player:QueryRecord(BLEND_COLLECT_REC, i, BLENDCOLLECT_REC_COL_OWNNUM)
    if nx_string(config_id) == nx_string(configid) then
      return amount
    end
  end
  return 1
end
