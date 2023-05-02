require("util_gui")
require("tips_game")
require("tips_data")
require("util_functions")
require("role_composite")
require("util_static_data")
local FORM_BODY = "form_stage_main\\form_attire\\form_attire_body"
local FORM_MAIN = "form_stage_main\\form_attire\\form_attire_main"
local FORM_ORIGIN = "form_stage_main\\form_attire\\form_attire_origin"
local FORM_CARD = "form_stage_main\\form_attire\\form_attire_card"
local FORM_DESC = "form_stage_main\\form_attire\\form_attire_body_desc"
local CARD_FILE_PATH = "share\\Rule\\card.ini"
local SKILL_FILE_PATH = "share\\Skill\\skill_new.ini"
local BODY_TYPE_WOMAN_JUV = 3
local BODY_TYPE_MAN_JUV = 4
local BODY_TYPE_WOMAN_MAJ = 5
local BODY_TYPE_MAN_MAJ = 6
local MAIN_TYPE_ORIGIN = 1
local MAIN_TYPE_JIANGHU = 2
local MAIN_TYPE_CARD = 3
local CARD_TYPE_MIN = 0
local CARD_TYPE_WEAPON = 1
local CARD_TYPE_CLOTH = 2
local CARD_TYPE_MOUNT = 3
local CARD_TYPE_OTHER = 4
local CARD_TYPE_DECORATE = 5
local CARD_TYPE_MAX = 6
local COUNT_ORIGIN_PER_PAGE = 6
local COUNT_CARD_PER_PAGE = 4
local MODEL_INFO_COUNT = 2
local ORIGIN_TEMPLATE = "gb_origin_sub"
local CARD_CLOTH_TEMPLATE = "gb_card_cloth"
local CARD_WEAPON_TEMPLATE = "gb_card_weapon"
local CARD_MOUNT_TEMPLATE = "gb_card_mount"
local CARD_DECORATE_TEMPLATE = "gb_card_decorate"
local TEXT_ACTIVE = "ui_attire_origin_2"
local TEXT_NOT_ACTIVE = "ui_attire_origin_1"
local TEXT_ALL = "ui_card_state_0"
local SEX_MALE = 0
local SEX_FEMALE = 1
local SEX_NOT_LIMIT = 2
local CARD_INFO_COUNT = 13
local CARD_INFO_LEVEL = 5
local CARD_INFO_MAIN_TYPE = 2
local CARD_INFO_SUB_TYPE = 3
local CARD_INFO_ITEM_TYPE = 4
local CARD_INFO_CONFIG_ID = 8
local CARD_INFO_FEMALE_MODEL = 10
local CARD_INFO_MALE_MODEL = 11
local CARD_HEAD_INFO_COUNT = 10
local FEMALE_HEAD_MODEL = 2
local FEMALE_HEAD_ICON = 3
local MALE_HEAD_MODEL = 5
local MALE_HEAD_ICON = 6
local FEMALE_HEAD_SKILL = 7
local MALE_HEAD_SKILL = 8
local FEMALE_HEAD_ACTION = 9
local MALE_HEAD_ACTION = 10
local WEAPON_SUB_TYPE_COUNT = 9
local DECORATE_SUB_TYPE_COUNT = 5
local OTHER_SUB_TYPE_COUNT = 8
local ITEMTYPE_WEAPON_MIN = 100
local ITEMTYPE_WEAPON_BLADE = 101
local ITEMTYPE_WEAPON_SWORD = 102
local ITEMTYPE_WEAPON_THORN = 103
local ITEMTYPE_WEAPON_SBLADE = 104
local ITEMTYPE_WEAPON_SSWORD = 105
local ITEMTYPE_WEAPON_STHORN = 106
local ITEMTYPE_WEAPON_STUFF = 107
local ITEMTYPE_WEAPON_COSH = 108
local ITEMTYPE_WEAPON_BOW = 127
local weapon_grid = {
  [ITEMTYPE_WEAPON_BLADE] = 0,
  [ITEMTYPE_WEAPON_SWORD] = 1,
  [ITEMTYPE_WEAPON_THORN] = 2,
  [ITEMTYPE_WEAPON_SBLADE] = 3,
  [ITEMTYPE_WEAPON_SSWORD] = 4,
  [ITEMTYPE_WEAPON_STHORN] = 5,
  [ITEMTYPE_WEAPON_STUFF] = 6,
  [ITEMTYPE_WEAPON_COSH] = 7,
  [ITEMTYPE_WEAPON_BOW] = 8
}
local DECORATE_TYPE_MIN = 0
local DECORATE_TYPE_ARM = 1
local DECORATE_TYPE_WAIST = 2
local DECORATE_TYPE_BACK = 3
local DECORATE_TYPE_CLOAK = 4
local DECORATE_TYPE_FACE = 5
local DECORATE_TYPE_MAX = 6
local IMAGE_CARD_GET = "gui\\special\\attire\\attire_back\\fwz_ysj.png"
local IMAGE_CARD_NO_GET = "gui\\special\\attire\\attire_back\\fwz_wsj.png"
local IMAGE_HEAD_ICON = "gui\\special\\attire\\attire_back\\nophoto.png"
local IMAGE_CARD_PATH = "gui\\language\\ChineseS\\card\\"
local IMAGE_SMALL_CARD_PATH = "\\gui\\special\\card\\"
local IMAGE_LOCK = "gui\\special\\attire\\attire_back\\k03.png"
local REC_CARD = "CardRec"
function main_form_init(form)
  form.Fixed = true
  return 1
end
function on_main_form_open(form)
  set_form_size(form)
  init_form_data(form)
  add_data_bind(form)
  return 1
end
function on_main_form_close(form)
  del_data_bind(form)
  nx_destroy(form)
  return 1
end
function set_form_size(form)
end
function init_form_data(form)
  form.rbtn_card_yujie.Enabled = false
  form.rbtn_card_zhuanghan.Enabled = false
  form.rbtn_jianghu.Enabled = false
  form.rbtn_decorate.Enabled = false
  init_body_type(form)
  init_origin_data(form)
  init_card_data(form)
  init_card_page(form)
end
function on_rbtn_body_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  local body_type = rbtn.TabIndex
  form.body_type = body_type
  nx_execute(FORM_MAIN, "create_body_player", body_type)
  if not nx_find_custom(form, "main_type") then
    return
  end
  if nx_number(form.main_type) == nx_number(MAIN_TYPE_ORIGIN) then
    set_origin(form)
  elseif nx_number(form.main_type) == nx_number(MAIN_TYPE_CARD) then
    set_card(form)
  end
end
function on_rbtn_origin_main_type_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local main_type = rbtn.TabIndex
  if nx_number(main_type) <= nx_number(0) then
    return
  end
  set_origin_drop_list(form, main_type)
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return
  end
  local body_type = get_body_type(form)
  local count = attire_manager:get_body_origin_main_count(main_type, body_type)
  set_type_page(form, count)
  show_origin_list(form)
end
function set_origin_drop_list(form, main_type)
  local list_box = form.combobox_origin.DropListBox
  list_box:ClearString()
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return
  end
  local list = attire_manager:get_body_origin_main_list(main_type)
  local count = table.getn(list)
  for i = 1, count do
    list_box:AddString(util_text(nx_string(list[i])))
  end
  form.combobox_origin.DroppedDown = false
  form.combobox_origin.main_type = main_type
  form.combobox_origin.sub_type = ""
  form.combobox_origin.Text = nx_widestr("")
end
function init_body_type(form)
  local sex = get_player_prop("Sex")
  if nx_int(sex) == nx_int(1) then
    form.rbtn_luoli.Checked = true
    form.body_type = BODY_TYPE_WOMAN_JUV
  else
    form.rbtn_zhengtai.Checked = true
    form.body_type = BODY_TYPE_MAN_JUV
  end
end
function init_origin_drop_list(form)
  local main_type = form.combobox_origin.main_type
  set_origin_drop_list(form, main_type)
end
function on_combobox_origin_selected(combo)
  local form = combo.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return
  end
  local main_type = combo.main_type
  local list = attire_manager:get_body_origin_main_list(main_type)
  local count = table.getn(list)
  local list_box = combo.DropListBox
  local select_index = list_box.SelectIndex
  if count < select_index + 1 then
    return
  end
  local sub_type = list[select_index + 1]
  form.combobox_origin.sub_type = sub_type
  local body_type = get_body_type(form)
  local total_count = attire_manager:get_body_origin_sub_count(sub_type, body_type)
  set_type_page(form, total_count)
  show_origin_list(form)
end
function init_origin_page(form)
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return
  end
  local main_type = form.combobox_origin.main_type
  local body_type = get_body_type(form)
  local count = attire_manager:get_body_origin_main_count(main_type, body_type)
  set_type_page(form, count)
end
function get_origin_list(form)
  local main_type = form.combobox_origin.main_type
  local sub_type = form.combobox_origin.sub_type
  local cur_page = form.gb_origin_page.cur_page
  local begin_pos = (cur_page - 1) * COUNT_ORIGIN_PER_PAGE + 1
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return nil
  end
  local body_type = get_body_type(form)
  local list = attire_manager:get_body_origin_list(main_type, sub_type, begin_pos, COUNT_ORIGIN_PER_PAGE, body_type)
  return list
end
function show_origin_list(form)
  form.gb_origin_list:DeleteAll()
  local list = get_origin_list(form)
  local count = table.getn(list)
  count = math.min(count, COUNT_ORIGIN_PER_PAGE)
  count = math.max(count, 0)
  for i = 1, count do
    show_origin_item(form, list[i], i)
  end
  local origin_page = form.gb_origin_page
  form.lbl_origin_page.Text = nx_widestr(origin_page.cur_page) .. nx_widestr("/") .. nx_widestr(origin_page.total_page)
end
function on_btn_origin_pre_page_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local origin_page = form.gb_origin_page
  local cur_page = origin_page.cur_page
  local total_page = origin_page.total_page
  cur_page = cur_page - 1
  if nx_int(cur_page) < nx_int(1) then
    cur_page = 1
    return
  end
  origin_page.cur_page = cur_page
  show_origin_list(form)
end
function on_btn_origin_next_page_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local origin_page = form.gb_origin_page
  local cur_page = origin_page.cur_page
  local total_page = origin_page.total_page
  cur_page = cur_page + 1
  if nx_int(cur_page) > nx_int(total_page) then
    cur_page = total_page
    return
  end
  origin_page.cur_page = cur_page
  show_origin_list(form)
end
function on_btn_origin_all_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return nil
  end
  local body_type = get_body_type(form)
  local count = attire_manager:get_body_origin_main_count(form.combobox_origin.main_type, body_type)
  set_type_page(form, count)
  form.combobox_origin.sub_type = ""
  form.combobox_origin.Text = nx_widestr("")
  show_origin_list(form)
end
function show_origin_item(form, id, index)
  local item = create_item_groupbox(form, id, ORIGIN_TEMPLATE)
  if not nx_is_valid(item) then
    return
  end
  local lbl_name = item:Find("lbl_origin_name" .. nx_string(id))
  if not nx_is_valid(lbl_name) then
    return
  end
  lbl_name.Text = util_text(nx_string(id))
  local sex = get_cur_sex(form)
  local photo = get_item_prop(nx_string(id), "Photo", sex)
  local grid_name = "imagegrid_origin" .. nx_string(id)
  local grid = item:Find(grid_name)
  if not nx_is_valid(grid) then
    return
  end
  grid.item_id = id
  grid:AddItem(0, photo, util_text(nx_string(id)), 1, -1)
  nx_bind_script(grid, nx_current())
  nx_callback(grid, "on_mousein_grid", "on_mousein_origin_grid")
  nx_callback(grid, "on_mouseout_grid", "on_mouseout_origin_grid")
  nx_callback(grid, "on_select_changed", "on_origin_grid_select_changed")
  local lbl_origin = item:Find("lbl_origin" .. nx_string(id))
  if not nx_is_valid(lbl_origin) then
    return
  end
  local satisfy, condition_id = can_satisfy_condition(id)
  if satisfy then
    lbl_origin.HtmlText = util_text(TEXT_ACTIVE)
  else
    lbl_origin.HtmlText = util_text(TEXT_NOT_ACTIVE)
  end
  local mltbox = item:Find("mltbox_origin" .. nx_string(id))
  if not nx_is_valid(mltbox) then
    return
  end
  if condition_id == "" or condition_id == nil then
    mltbox.HtmlText = util_text("desc_condition_" .. nx_string(id))
    lbl_origin.HtmlText = nx_widestr("")
  else
    mltbox.HtmlText = util_text("desc_condition_" .. nx_string(condition_id))
  end
  item.Left = (index - 1) % 2 * item.Width
  item.Top = nx_int((index - 1) / 2) * (item.Height - 8)
  form.gb_origin_list:Add(item)
end
function create_item_groupbox(form, id, template)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nil
  end
  local source = nx_custom(form, template)
  if not nx_is_valid(source) then
    return nil
  end
  local group_box = gui:Create("GroupBox")
  if not nx_is_valid(group_box) then
    return nil
  end
  group_box.Name = source.Name .. nx_string(id)
  copy_ctrl_prop(form, source, group_box)
  local child_list = source:GetChildControlList()
  for i, child in ipairs(child_list) do
    local ctrl = gui:Create(nx_name(child))
    copy_ctrl_prop(form, child, ctrl)
    ctrl.Name = child.Name .. nx_string(id)
    if nx_string(nx_name(ctrl)) == "MultiTextBox" then
      create_scrollbar(ctrl, child)
    end
    group_box:Add(ctrl)
  end
  return group_box
end
function copy_ctrl_prop(form, source, dest)
  if not nx_is_valid(source) or not nx_is_valid(dest) then
    return
  end
  local prop_list = nx_property_list(source)
  for i, prop in ipairs(prop_list) do
    if nx_string(prop) ~= nx_string("Name") then
      nx_set_property(dest, prop, nx_property(source, prop))
    end
  end
end
function get_item_prop(id, prop, sex)
  return nx_execute(FORM_ORIGIN, "query_arrire_item_photo", id, prop, sex)
end
function on_mousein_origin_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  local item = get_tips_ArrayList()
  if not nx_is_valid(item) then
    return
  end
  local id = nx_string(grid.item_id)
  item.ConfigID = id
  item.ItemType = item_query:GetItemPropByConfigID(id, "ItemType")
  item.Level = item_query:GetItemPropByConfigID(id, "Level")
  item.SellPrice1 = item_query:GetItemPropByConfigID(id, "sellPrice1")
  item.is_static = true
  item.IsLookOther = true
  item.other_sex = get_cur_sex(form)
  item.ignore_sex_color = true
  show_goods_tip(item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_mouseout_origin_grid(grid, index)
  hide_tip(form)
end
function on_origin_grid_select_changed(grid)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  local id = grid.item_id
  local player_sex = get_cur_sex(form)
  local need_sex = item_query:GetItemPropByConfigID(id, "NeedSex")
  if nx_int(need_sex) == nx_int(SEX_NOT_LIMIT) or nx_int(need_sex) == nx_int(player_sex) then
    nx_execute(FORM_MAIN, "player_link_body_origin", id)
  end
end
function can_satisfy_condition(id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local Item_query = nx_value("ItemQuery")
  if not nx_is_valid(Item_query) then
    return
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return
  end
  local condition_id = Item_query:GetItemPropByConfigID(nx_string(id), "ConditionID")
  local satisfy = condition_manager:CanSatisfyCondition(client_player, client_player, nx_int(condition_id))
  return satisfy, condition_id
end
function set_type_page(form, count)
  form.gb_origin_page.cur_page = 1
  local total_page = 1
  if count % COUNT_ORIGIN_PER_PAGE == 0 then
    total_page = nx_int(count / COUNT_ORIGIN_PER_PAGE)
  else
    total_page = nx_int(count / COUNT_ORIGIN_PER_PAGE) + 1
  end
  form.gb_origin_page.total_page = total_page
end
function get_player_prop(prop)
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return ""
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return ""
  end
  if not player:FindProp(nx_string(prop)) then
    return ""
  end
  return player:QueryProp(nx_string(prop))
end
function on_rbtn_main_type_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = rbtn.TabIndex
  if nx_int(index) == nx_int(MAIN_TYPE_ORIGIN) then
    set_origin(form)
  elseif nx_int(index) == nx_int(MAIN_TYPE_JIANGHU) then
    set_jianghu(form)
  elseif nx_int(index) == nx_int(MAIN_TYPE_CARD) then
    set_card(form)
  end
end
function show_type_groupbox(form, index)
  local group_box = {
    form.groupbox_origin,
    form.groupbox_jianghu,
    form.groupbox_card
  }
  local count = table.getn(group_box)
  if nx_int(index) < nx_int(0) or nx_int(index) > nx_int(count) then
    return
  end
  for i = 1, nx_number(count) do
    group_box[i].Visible = false
  end
  group_box[index].Visible = true
  form.main_type = index
end
function set_origin(form)
  init_origin_data(form)
  init_origin_drop_list(form)
  init_origin_page(form)
  show_origin_list(form)
  show_type_groupbox(form, MAIN_TYPE_ORIGIN)
  init_model(form)
  init_card_gb(form, false)
end
function set_jianghu(form)
  show_type_groupbox(form, MAIN_TYPE_JIANGHU)
  init_model(form)
  init_card_gb(form, false)
end
function set_card(form)
  init_card_data(form)
  init_card_level_drop_list(form)
  init_card_sub_type_drop_list(form)
  init_card_page(form)
  show_card_list(form)
  show_type_groupbox(form, MAIN_TYPE_CARD)
  init_card_equip_grid(form)
  init_card_statistic(form)
  init_card_model(form)
  init_card_gb(form, true)
end
function init_origin_data(form)
  form.combobox_origin.main_type = 1
  form.rbtn_school.Checked = true
end
function init_card_gb(form, show)
  form.groupbox_getinfo.Visible = show
  form.groupbox_1.Visible = show
end
function init_card_model(form)
  local form_main = nx_value(FORM_MAIN)
  if not nx_is_valid(form_main) then
    return
  end
  nx_execute(FORM_MAIN, "init_player_fwz_model", form_main)
end
function init_model(form)
  refresh_model(form, CARD_TYPE_CLOTH)
  local form_main = nx_value(FORM_MAIN)
  if not nx_is_valid(form_main) then
    return
  end
  nx_execute(FORM_MAIN, "player_unlink_fwz", "weapon")
  nx_execute(FORM_MAIN, "player_unlink_fwz", "cloth")
  nx_execute(FORM_MAIN, "player_unlink_fwz", "waist")
  nx_execute(FORM_MAIN, "player_unlink_fwz", "cloak")
end
function on_rbtn_card_main_type_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local main_type = rbtn.TabIndex
  if nx_number(main_type) <= nx_number(CARD_TYPE_MIN) or nx_number(main_type) >= nx_number(CARD_TYPE_MAX) then
    return
  end
  refresh_model(form, main_type)
  set_card_data(form)
  form.groupbox_card.main_type = main_type
  init_card_page(form)
  show_card_list(form)
  init_card_level_drop_list(form)
  init_card_sub_type_drop_list(form)
  init_card_equip_grid(form)
end
function init_card_level_drop_list(form)
  local list_box = form.cb_card_level_list.DropListBox
  list_box:ClearString()
  local status_count = 1
  for i = 0, status_count do
    list_box:AddString(util_text("ui_card_state_" .. nx_string(i)))
  end
  local level_count = 3
  for i = 1, level_count do
    list_box:AddString(util_text("ui_card_level_" .. nx_string(i)))
  end
  list_box.SelectIndex = 0
  form.cb_card_level_list.DroppedDown = false
  form.cb_card_level_list.Text = util_text(TEXT_ALL)
end
function init_card_sub_type_drop_list(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local cb = form.cb_card_sub_type_list
  if not nx_is_valid(cb) then
    return
  end
  cb.OnlySelect = true
  cb.Visible = false
  cb.DropListBox:ClearString()
  local main_type = form.groupbox_card.main_type
  if nx_number(main_type) <= nx_number(CARD_TYPE_MIN) or nx_number(main_type) >= nx_number(CARD_TYPE_MAX) then
    return
  end
  local list_count = 0
  if nx_number(main_type) == nx_number(CARD_TYPE_WEAPON) then
    list_count = WEAPON_SUB_TYPE_COUNT
  elseif nx_number(main_type) == nx_number(CARD_TYPE_DECORATE) then
    list_count = DECORATE_SUB_TYPE_COUNT
  elseif nx_number(main_type) == nx_number(CARD_TYPE_OTHER) then
    list_count = OTHER_SUB_TYPE_COUNT
  end
  if nx_number(list_count) > nx_number(0) then
    cb.DropListBox:AddString(gui.TextManager:GetText("ui_card_state_0"))
    for i = 1, list_count do
      local text = gui.TextManager:GetFormatText("ui_card_" .. nx_string(main_type) .. "_" .. nx_string(i))
      cb.DropListBox:AddString(nx_widestr(text))
      cb.DropListBox.SelectIndex = 0
    end
    cb.Text = nx_widestr(gui.TextManager:GetText("ui_card_state_0"))
    cb.Visible = true
  end
end
function on_cb_card_level_list_selected(combo)
  local form = combo.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local list_box = combo.DropListBox
  local select_index = list_box.SelectIndex
  if nx_number(select_index) < nx_number(2) then
    form.groupbox_card.status = select_index
    form.groupbox_card.level = 0
  else
    form.groupbox_card.status = 0
    form.groupbox_card.level = select_index - 1
  end
  init_card_page(form)
  show_card_list(form)
end
function on_cb_card_sub_type_list_selected(combo)
  local form = combo.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local list_box = combo.DropListBox
  local select_index = list_box.SelectIndex
  form.groupbox_card.sub_type = nx_int(select_index)
  init_card_page(form)
  show_card_list(form)
end
function init_card_data(form)
  set_card_data(form)
end
function set_card_data(form)
  local gb = form.groupbox_card
  if not nx_is_valid(gb) then
    return
  end
  gb.card_id = 0
  gb.main_type = CARD_TYPE_CLOTH
  gb.sub_type = 0
  gb.status = 0
  gb.level = 0
  gb.author = 0
  gb.book = 0
  form.rbtn_cloth.Checked = true
end
function show_card_list(form)
  form.gb_card_list:DeleteAll()
  local list = get_card_list(form)
  local count = table.getn(list)
  count = math.min(count, COUNT_CARD_PER_PAGE)
  count = math.max(count, 0)
  for i = 1, count do
    show_card_item(form, list[i], i)
  end
  local gb_card = form.groupbox_card
  form.lbl_card_page.Text = nx_widestr(gb_card.cur_page) .. nx_widestr("/") .. nx_widestr(gb_card.total_page)
end
function get_all_query_args(form)
  local gb = form.groupbox_card
  if not nx_is_valid(gb) then
    return
  end
  return gb.main_type, gb.sub_type, gb.status, gb.level, gb.author, gb.book
end
function set_card_page(form, count)
  if nx_number(count) > nx_number(0) then
    form.groupbox_card.cur_page = 1
  else
    form.groupbox_card.cur_page = 0
  end
  local total_page = 1
  if count % COUNT_CARD_PER_PAGE == 0 then
    total_page = nx_int(count / COUNT_CARD_PER_PAGE)
  else
    total_page = nx_int(count / COUNT_CARD_PER_PAGE) + 1
  end
  form.groupbox_card.total_page = total_page
end
function init_card_page(form)
  form.groupbox_card.cur_page = 1
  form.groupbox_card.total_page = 1
  local main_type, sub_type, status, level, author, book = get_all_query_args(form)
  local body_type = form.body_type
  local card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(card_manager) then
    return
  end
  local data = card_manager:query_body_card_count(main_type, sub_type, status, level, author, book, body_type)
  if nx_number(table.getn(data)) < nx_number(1) then
    return
  end
  local count = data[1]
  set_card_page(form, count)
end
function get_card_list(form)
  local cur_page = form.groupbox_card.cur_page
  local begin_pos = (cur_page - 1) * COUNT_CARD_PER_PAGE + 1
  local card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(card_manager) then
    return
  end
  local main_type, sub_type, status, level, author, book = get_all_query_args(form)
  local body_type = form.body_type
  local list = card_manager:query_body_card(main_type, sub_type, status, level, author, book, begin_pos, COUNT_CARD_PER_PAGE, body_type)
  return list
end
function show_card_item(form, id, index)
  local main_type = form.groupbox_card.main_type
  if nx_number(main_type) <= nx_number(CARD_TYPE_MIN) or nx_number(main_type) >= nx_number(CARD_TYPE_MAX) then
    return
  end
  if main_type == CARD_TYPE_CLOTH then
    show_card_cloth_item(form, id, index)
  elseif main_type == CARD_TYPE_WEAPON then
    show_card_weapon_item(form, id, index)
  elseif main_type == CARD_TYPE_MOUNT then
    show_card_mount_item(form, id, index)
  elseif main_type == CARD_TYPE_DECORATE then
    show_card_decorate_item(form, id, index)
  end
end
function show_card_cloth_item(form, id, index)
  local item = create_item_groupbox(form, id, CARD_CLOTH_TEMPLATE)
  if not nx_is_valid(item) then
    return
  end
  local lbl_name = item:Find("lbl_cloth_name" .. nx_string(id))
  if not nx_is_valid(lbl_name) then
    return
  end
  local card_name = util_text("card_item_" .. nx_string(id))
  lbl_name.Text = card_name
  local card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(card_manager) then
    return
  end
  local card_info = card_manager:GetCardInfo(id)
  local count = table.getn(card_info)
  if nx_int(count) < nx_int(CARD_INFO_COUNT) then
    return
  end
  local level = card_info[CARD_INFO_LEVEL]
  local lbl_level = item:Find("lbl_cloth_level" .. nx_string(id))
  if not nx_is_valid(lbl_level) then
    return
  end
  lbl_level.Text = util_text("ui_card_level_" .. nx_string(level))
  local main_type = card_info[CARD_INFO_MAIN_TYPE]
  local sub_type = card_info[CARD_INFO_SUB_TYPE]
  local lbl_type = item:Find("lbl_cloth_type" .. nx_string(id))
  if nx_is_valid(lbl_type) then
    local type_name = util_text("ui_card_" .. nx_string(main_type) .. "_" .. nx_string(sub_type))
    lbl_type.Text = type_name
  end
  local lbl_is_get = item:Find("lbl_cloth_collect" .. nx_string(id))
  if not nx_is_valid(lbl_is_get) then
    return
  end
  local is_get = card_manager:IsGetCard(id)
  if is_get == true then
    lbl_is_get.BackImage = IMAGE_CARD_GET
  else
    lbl_is_get.BackImage = IMAGE_CARD_NO_GET
  end
  local btn = item:Find("btn_take_off_cloth" .. nx_string(id))
  if not nx_is_valid(btn) then
    return
  end
  btn.card_id = id
  btn.Visible = false
  if is_get == true then
    btn.Visible = true
    nx_bind_script(btn, nx_current())
    nx_callback(btn, "on_click", "on_btn_back_card_click")
  end
  local grid_head = item:Find("imagegrid_head" .. nx_string(id))
  if not nx_is_valid(grid_head) then
    return
  end
  local card_head_skill = card_manager:GetCardHeadIcon(id)
  local count = table.getn(card_head_skill)
  if nx_int(count) < nx_int(CARD_HEAD_INFO_COUNT) then
    return
  end
  local female_head_icon = card_head_skill[FEMALE_HEAD_ICON]
  local male_head_icon = card_head_skill[MALE_HEAD_ICON]
  local head_icon = ""
  local body_type = form.body_type
  local sex = get_cur_sex(form)
  if nx_number(sex) == nx_number(SEX_FEMALE) then
    head_icon = female_head_icon
  else
    head_icon = male_head_icon
  end
  if head_icon == "" then
    head_icon = IMAGE_HEAD_ICON
  end
  grid_head.card_id = id
  grid_head:AddItem(0, head_icon, "", 1, -1)
  nx_bind_script(grid_head, nx_current())
  nx_callback(grid_head, "on_right_click", "on_grid_head_click")
  nx_callback(grid_head, "on_select_changed", "on_grid_head_click")
  local cloth_skill_desc = item:Find("lbl_cloth_skill_desc" .. nx_string(id))
  local cloth_no_skill_desc = item:Find("lbl_nocloth_skill" .. nx_string(id))
  local skill_grid_1 = item:Find("cloth_skill_1" .. nx_string(id))
  local skill_grid_2 = item:Find("cloth_skill_2" .. nx_string(id))
  if not (nx_is_valid(cloth_skill_desc) and nx_is_valid(cloth_no_skill_desc) and nx_is_valid(skill_grid_1)) or not nx_is_valid(skill_grid_2) then
    return
  end
  cloth_skill_desc.Visible = false
  cloth_no_skill_desc.Visible = false
  skill_grid_1.Visible = false
  skill_grid_2.Visible = false
  local female_skill = card_head_skill[FEMALE_HEAD_SKILL]
  local male_skill = card_head_skill[MALE_HEAD_SKILL]
  local female_action = card_head_skill[FEMALE_HEAD_SKILL]
  local male_action = card_head_skill[MALE_HEAD_SKILL]
  local skill = ""
  local action = ""
  if nx_number(sex) == nx_number(SEX_FEMALE) then
    skill = female_skill
    action = female_action
  else
    skill = male_skill
    action = male_action
  end
  local skill_cfg = get_ini(SKILL_FILE_PATH)
  if not nx_is_valid(skill_cfg) then
    return
  end
  if nx_string(skill) ~= nx_string("") then
    local skill_list = util_split_string(skill, ",")
    local action_list = util_split_string(action, ",")
    local action_count = table.getn(action_list)
    for i = 1, table.getn(skill_list) do
      local skill_grid = item:Find("cloth_skill_" .. nx_string(i) .. nx_string(id))
      if nx_is_valid(skill_grid) then
        skill_grid.Visible = true
        nx_execute(FORM_CARD, "add_card_skill", skill_grid, skill_cfg, skill_list[i])
        nx_bind_script(skill_grid, nx_current())
        nx_callback(skill_grid, "on_mousein_grid", "on_grid_skill_mousein")
        nx_callback(skill_grid, "on_mouseout_grid", "on_grid_skill_mouseout")
        skill_grid.card_action = ""
        if nx_number(i) <= nx_number(action_count) then
          skill_grid.card_action = action_list[i]
        end
      end
    end
    cloth_skill_desc.Visible = true
  else
    cloth_no_skill_desc.Visible = true
  end
  local photo = nx_resource_path() .. IMAGE_CARD_PATH .. nx_string(id) .. ".png"
  local grid = item:Find("imagegrid_cloth_back" .. nx_string(id))
  if not nx_is_valid(grid) then
    return
  end
  grid.card_id = id
  grid:AddItem(0, photo, "", 1, -1)
  nx_bind_script(grid, nx_current())
  nx_callback(grid, "on_right_click", "on_grid_card_click")
  nx_callback(grid, "on_select_changed", "on_grid_card_click")
  item.Left = (index - 1) % 2 * item.Width
  item.Top = nx_int((index - 1) / 2) * (item.Height - 8)
  form.gb_card_list:Add(item)
end
function on_btn_back_card_click(btn)
  local card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(card_manager) then
    return
  end
  card_manager:OnRebackCrad(nx_int(btn.card_id))
end
function on_grid_head_click(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(grid, "select_grid") and not nx_id_equal(form.select_grid, grid) then
    form.select_grid:SetSelectItemIndex(-1)
  end
  form.select_grid = grid
  if not nx_find_custom(grid, "card_id") then
    return
  end
  local id = grid.card_id
  local card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(card_manager) then
    return
  end
  local card_id = form.groupbox_card.card_id
  if nx_int(card_id) > nx_int(0) then
    local card_info = card_manager:GetCardInfo(card_id)
    if table.getn(card_info) < CARD_INFO_COUNT then
      return
    end
    local female_model = card_info[CARD_INFO_FEMALE_MODEL]
    local male_model = card_info[CARD_INFO_MALE_MODEL]
    local sex = get_cur_sex(form)
    local player_model = female_model
    if nx_number(sex) == nx_number(SEX_MALE) then
      player_model = male_model
    end
    if string.find(player_model, nx_string("Hat")) then
      return
    end
  end
  local card_head_skill = card_manager:GetCardHeadIcon(id)
  local count = table.getn(card_head_skill)
  if nx_int(count) < nx_int(CARD_HEAD_INFO_COUNT) then
    return
  end
  local female_head_model = card_head_skill[FEMALE_HEAD_MODEL]
  local male_head_model = card_head_skill[MALE_HEAD_MODEL]
  local sex = get_cur_sex(form)
  local head_model = ""
  if nx_number(sex) == nx_number(SEX_FEMALE) then
    head_model = female_head_model
  else
    head_model = male_head_model
  end
  if nx_string(head_model) == nx_string("") then
    return
  end
  nx_execute(FORM_MAIN, "player_link_equip", "hat", head_model)
end
function get_cur_sex(form)
  local body_type = form.body_type
  if nx_number(body_type) == nx_number(BODY_TYPE_WOMAN_JUV) or nx_number(body_type) == nx_number(BODY_TYPE_WOMAN_MAJ) then
    return SEX_FEMALE
  else
    return SEX_MALE
  end
end
function get_body_type(form)
  if not nx_is_valid(form) then
    return nx_number(-1)
  end
  if not nx_find_custom(form, "body_type") then
    return nx_number(-1)
  end
  return nx_number(form.body_type)
end
function on_grid_skill_mousein(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local skill_id = grid:GetItemName(index)
  if nx_string(skill_id) == nx_string("") then
    return
  end
  local item = get_tips_ArrayList()
  if nx_is_valid(item) then
    item.is_static = true
    item.ConfigID = nx_string(skill_id)
    item.ItemType = get_ini_prop(SKILL_FILE_PATH, skill_id, "ItemType", "0")
    item.Level = 1
    item.static_skill_level = 1
    show_goods_tip(item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 40, 40, grid.ParentForm)
  end
end
function on_grid_skill_mouseout(grid, index)
  hide_tip(grid.ParentForm)
end
function on_grid_card_click(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "tick_count") then
    local tick_count = nx_function("ext_get_tickcount")
    if nx_number(tick_count) - nx_number(form.tick_count) < nx_number(1000) then
      return
    end
  end
  form.tick_count = tick_count
  local id = grid.card_id
  form.groupbox_card.card_id = id
  local card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(card_manager) then
    return
  end
  local card_info = card_manager:GetCardInfo(id)
  local count = table.getn(card_info)
  if nx_int(count) < nx_int(CARD_INFO_COUNT) then
    return
  end
  local female_model = card_info[CARD_INFO_FEMALE_MODEL]
  local male_model = card_info[CARD_INFO_MALE_MODEL]
  local main_type = form.groupbox_card.main_type
  if nx_number(main_type) <= nx_number(CARD_TYPE_MIN) or nx_number(main_type) >= nx_number(CARD_TYPE_MAX) then
    return
  end
  local model = ""
  local sex = get_cur_sex(form)
  if nx_number(sex) == nx_number(SEX_FEMALE) then
    model = female_model
  else
    model = male_model
  end
  if main_type == CARD_TYPE_CLOTH then
    nx_execute(FORM_MAIN, "player_link_body_card", id)
  elseif main_type == CARD_TYPE_WEAPON then
    local config_id = card_info[CARD_INFO_CONFIG_ID]
    nx_execute(FORM_MAIN, "player_link_equip", "weapon", config_id, false, nx_string(id))
  elseif main_type == CARD_TYPE_MOUNT then
    local mount_info = util_split_string(model, ":")
    local count = table.getn(mount_info)
    if nx_number(count) ~= nx_number(MODEL_INFO_COUNT) then
      return
    end
    nx_execute(FORM_MAIN, "create_npc_model_by_path", mount_info[2], 2)
  elseif main_type == CARD_TYPE_DECORATE then
    local sub_type = card_info[CARD_INFO_SUB_TYPE]
    if nx_number(sub_type) <= nx_number(DECORATE_TYPE_MIN) or nx_number(sub_type) >= nx_number(DECORATE_TYPE_MAX) then
      return
    end
    if nx_int(sub_type) == nx_int(DECORATE_TYPE_FACE) then
      nx_execute(FORM_MAIN, "add_face_effect", id)
    elseif nx_int(sub_type) == nx_int(DECORATE_TYPE_WAIST) or nx_int(sub_type) == nx_int(DECORATE_TYPE_CLOAK) then
      nx_execute(FORM_MAIN, "player_fwz_link_sp", id)
    else
      nx_execute(FORM_MAIN, "LinkCardDecorate", model, nx_int(sub_type))
    end
  end
  add_card_equip_grid(form, id)
end
function on_btn_card_pre_page_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local card_page = form.groupbox_card
  local cur_page = card_page.cur_page
  local total_page = card_page.total_page
  cur_page = cur_page - 1
  if nx_int(cur_page) < nx_int(1) then
    cur_page = 1
    return
  end
  card_page.cur_page = cur_page
  show_card_list(form)
end
function on_btn_card_next_page_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local card_page = form.groupbox_card
  local cur_page = card_page.cur_page
  local total_page = card_page.total_page
  cur_page = cur_page + 1
  if nx_int(cur_page) > nx_int(total_page) then
    cur_page = total_page
    return
  end
  card_page.cur_page = cur_page
  show_card_list(form)
end
function show_card_weapon_item(form, id, index)
  local item = create_item_groupbox(form, id, CARD_WEAPON_TEMPLATE)
  if not nx_is_valid(item) then
    return
  end
  local lbl_name = item:Find("lbl_weapon_name" .. nx_string(id))
  if not nx_is_valid(lbl_name) then
    return
  end
  local card_name = util_text("card_item_" .. nx_string(id))
  lbl_name.Text = card_name
  local card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(card_manager) then
    return
  end
  local card_info = card_manager:GetCardInfo(id)
  local count = table.getn(card_info)
  if nx_int(count) < nx_int(CARD_INFO_COUNT) then
    return
  end
  local level = card_info[CARD_INFO_LEVEL]
  local lbl_level = item:Find("lbl_weapon_level" .. nx_string(id))
  if not nx_is_valid(lbl_level) then
    return
  end
  lbl_level.Text = util_text("ui_card_level_" .. nx_string(level))
  local main_type = card_info[CARD_INFO_MAIN_TYPE]
  local sub_type = card_info[CARD_INFO_SUB_TYPE]
  local lbl_type = item:Find("lbl_weapon_type" .. nx_string(id))
  if nx_is_valid(lbl_type) then
    local type_name = util_text("ui_card_" .. nx_string(main_type) .. "_" .. nx_string(sub_type))
    lbl_type.Text = type_name
  end
  local lbl_is_get = item:Find("lbl_weapon_collect" .. nx_string(id))
  if not nx_is_valid(lbl_is_get) then
    return
  end
  local is_get = card_manager:IsGetCard(id)
  if is_get == true then
    lbl_is_get.BackImage = IMAGE_CARD_GET
  else
    lbl_is_get.BackImage = IMAGE_CARD_NO_GET
  end
  local btn = item:Find("btn_take_off_weapon" .. nx_string(id))
  if not nx_is_valid(btn) then
    return
  end
  btn.card_id = id
  btn.Visible = false
  if is_get == true then
    btn.Visible = true
    nx_bind_script(btn, nx_current())
    nx_callback(btn, "on_click", "on_btn_back_card_click")
  end
  local weapon_skill_desc = item:Find("lbl_weapon_skill_desc" .. nx_string(id))
  local mltbox_weapon_desc = item:Find("mltbox_weapon" .. nx_string(id))
  local skill_grid_1 = item:Find("weapon_skill_1" .. nx_string(id))
  local skill_grid_2 = item:Find("weapon_skill_2" .. nx_string(id))
  if not (nx_is_valid(weapon_skill_desc) and nx_is_valid(mltbox_weapon_desc) and nx_is_valid(skill_grid_1)) or not nx_is_valid(skill_grid_2) then
    return
  end
  skill_grid_1.Visible = false
  skill_grid_2.Visible = false
  local card_head_skill = card_manager:GetCardHeadIcon(id)
  local count = table.getn(card_head_skill)
  if nx_int(count) < nx_int(CARD_HEAD_INFO_COUNT) then
    return
  end
  local female_skill = card_head_skill[FEMALE_HEAD_SKILL]
  local male_skill = card_head_skill[MALE_HEAD_SKILL]
  local female_action = card_head_skill[FEMALE_HEAD_SKILL]
  local male_action = card_head_skill[MALE_HEAD_SKILL]
  local skill = ""
  local action = ""
  if nx_number(sex) == nx_number(SEX_FEMALE) then
    skill = female_skill
    action = female_action
  else
    skill = male_skill
    action = male_action
  end
  local skill_cfg = get_ini(SKILL_FILE_PATH)
  if not nx_is_valid(skill_cfg) then
    return
  end
  if nx_string(skill) ~= nx_string("") then
    local skill_list = util_split_string(skill, ",")
    local action_list = util_split_string(action, ",")
    local action_count = table.getn(action_list)
    for i = 1, table.getn(skill_list) do
      local skill_grid = item:Find("weapon_skill_" .. nx_string(i) .. nx_string(id))
      if nx_is_valid(skill_grid) then
        skill_grid.Visible = true
        nx_execute(FORM_CARD, "add_card_skill", skill_grid, skill_cfg, skill_list[i])
        nx_bind_script(skill_grid, nx_current())
        nx_callback(skill_grid, "on_mousein_grid", "on_grid_skill_mousein")
        nx_callback(skill_grid, "on_mouseout_grid", "on_grid_skill_mouseout")
        skill_grid.card_action = ""
        if nx_number(i) <= nx_number(action_count) then
          skill_grid.card_action = action_list[i]
        end
      end
    end
    mltbox_weapon_desc:AddHtmlText(util_text("ui_card_desc_" .. nx_string(id)), -1)
  else
    weapon_skill_desc.Text = util_text("ui_attire_card_tips")
  end
  local photo = nx_resource_path() .. IMAGE_CARD_PATH .. nx_string(id) .. ".png"
  local grid = item:Find("imagegrid_wepon_back" .. nx_string(id))
  if not nx_is_valid(grid) then
    return
  end
  grid.card_id = id
  grid:AddItem(0, photo, "", 1, -1)
  nx_bind_script(grid, nx_current())
  nx_callback(grid, "on_right_click", "on_grid_card_click")
  nx_callback(grid, "on_select_changed", "on_grid_card_click")
  item.Left = (index - 1) % 2 * item.Width
  item.Top = nx_int((index - 1) / 2) * (item.Height - 8)
  form.gb_card_list:Add(item)
end
function show_card_mount_item(form, id, index)
  local item = create_item_groupbox(form, id, CARD_MOUNT_TEMPLATE)
  if not nx_is_valid(item) then
    return
  end
  local lbl_name = item:Find("lbl_horse_name" .. nx_string(id))
  if not nx_is_valid(lbl_name) then
    return
  end
  local card_name = util_text("card_item_" .. nx_string(id))
  lbl_name.Text = card_name
  local card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(card_manager) then
    return
  end
  local card_info = card_manager:GetCardInfo(id)
  local count = table.getn(card_info)
  if nx_int(count) < nx_int(CARD_INFO_COUNT) then
    return
  end
  local level = card_info[CARD_INFO_LEVEL]
  local lbl_level = item:Find("lbl_horse_level" .. nx_string(id))
  if not nx_is_valid(lbl_level) then
    return
  end
  lbl_level.Text = util_text("ui_card_level_" .. nx_string(level))
  local main_type = card_info[CARD_INFO_MAIN_TYPE]
  local sub_type = card_info[CARD_INFO_SUB_TYPE]
  local lbl_type = item:Find("lbl_horse_type" .. nx_string(id))
  if nx_is_valid(lbl_type) then
    local type_name = util_text("ui_card_" .. nx_string(main_type) .. "_" .. nx_string(sub_type))
    lbl_type.Text = type_name
  end
  local lbl_is_get = item:Find("lbl_horse_collect" .. nx_string(id))
  if not nx_is_valid(lbl_is_get) then
    return
  end
  local is_get = card_manager:IsGetCard(id)
  if is_get == true then
    lbl_is_get.BackImage = IMAGE_CARD_GET
  else
    lbl_is_get.BackImage = IMAGE_CARD_NO_GET
  end
  local btn = item:Find("btn_take_off_mount" .. nx_string(id))
  if not nx_is_valid(btn) then
    return
  end
  btn.card_id = id
  btn.Visible = false
  if is_get == true then
    btn.Visible = true
    nx_bind_script(btn, nx_current())
    nx_callback(btn, "on_click", "on_btn_back_card_click")
  end
  local mltbox_desc = item:Find("mltbox_horse" .. nx_string(id))
  if not nx_is_valid(mltbox_desc) then
    return
  end
  mltbox_desc:AddHtmlText(util_text("ui_card_desc_" .. nx_string(id)), nx_int(-1))
  local photo = nx_resource_path() .. IMAGE_CARD_PATH .. nx_string(id) .. ".png"
  local grid = item:Find("imagegrid_horse_back" .. nx_string(id))
  if not nx_is_valid(grid) then
    return
  end
  grid.card_id = id
  grid:AddItem(0, photo, "", 1, -1)
  nx_bind_script(grid, nx_current())
  nx_callback(grid, "on_right_click", "on_grid_card_click")
  nx_callback(grid, "on_select_changed", "on_grid_card_click")
  item.Left = (index - 1) % 2 * item.Width
  item.Top = nx_int((index - 1) / 2) * (item.Height - 8)
  form.gb_card_list:Add(item)
end
function refresh_model(form, main_type)
  local gb = form.groupbox_card
  if not nx_is_valid(gb) then
    return
  end
  if nx_number(gb.main_type) == nx_number(main_type) then
    return
  end
  if not is_mount_show(form) then
    return
  end
  nx_execute(FORM_MAIN, "create_body_player", form.body_type)
  if nx_number(form.main_type) == nx_number(MAIN_TYPE_CARD) then
    init_card_model(form)
  end
end
function show_card_decorate_item(form, id, index)
  local item = create_item_groupbox(form, id, CARD_DECORATE_TEMPLATE)
  if not nx_is_valid(item) then
    return
  end
  local lbl_name = item:Find("lbl_decorate_name" .. nx_string(id))
  if not nx_is_valid(lbl_name) then
    return
  end
  local card_name = util_text("card_item_" .. nx_string(id))
  lbl_name.Text = card_name
  local card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(card_manager) then
    return
  end
  local card_info = card_manager:GetCardInfo(id)
  local count = table.getn(card_info)
  if nx_int(count) < nx_int(CARD_INFO_COUNT) then
    return
  end
  local level = card_info[CARD_INFO_LEVEL]
  local lbl_level = item:Find("lbl_decorate_level" .. nx_string(id))
  if not nx_is_valid(lbl_level) then
    return
  end
  lbl_level.Text = util_text("lbl_decorate_level" .. nx_string(level))
  local main_type = card_info[CARD_INFO_MAIN_TYPE]
  local sub_type = card_info[CARD_INFO_SUB_TYPE]
  local lbl_type = item:Find("lbl_decorate_type" .. nx_string(id))
  if nx_is_valid(lbl_type) then
    local type_name = util_text("ui_card_" .. nx_string(main_type) .. "_" .. nx_string(sub_type))
    lbl_type.Text = type_name
  end
  local lbl_is_get = item:Find("lbl_decorate_collect" .. nx_string(id))
  if not nx_is_valid(lbl_is_get) then
    return
  end
  local is_get = card_manager:IsGetCard(id)
  if is_get == true then
    lbl_is_get.BackImage = IMAGE_CARD_GET
  else
    lbl_is_get.BackImage = IMAGE_CARD_NO_GET
  end
  local btn = item:Find("btn_take_off_decorate" .. nx_string(id))
  if not nx_is_valid(btn) then
    return
  end
  btn.card_id = id
  btn.Visible = false
  if is_get == true then
    btn.Visible = true
    nx_bind_script(btn, nx_current())
    nx_callback(btn, "on_click", "on_btn_back_card_click")
  end
  local mltbox_desc = item:Find("mltbox_decorate" .. nx_string(id))
  if not nx_is_valid(mltbox_desc) then
    return
  end
  mltbox_desc:AddHtmlText(util_text("ui_card_desc_" .. nx_string(card_id)), nx_int(-1))
  local photo = nx_resource_path() .. IMAGE_CARD_PATH .. nx_string(id) .. ".png"
  local grid = item:Find("imagegrid_decorate_back" .. nx_string(id))
  if not nx_is_valid(grid) then
    return
  end
  grid.card_id = id
  grid:AddItem(0, photo, "", 1, -1)
  nx_bind_script(grid, nx_current())
  nx_callback(grid, "on_right_click", "on_grid_card_click")
  nx_callback(grid, "on_select_changed", "on_grid_card_click")
  item.Left = (index - 1) % 2 * item.Width
  item.Top = nx_int((index - 1) / 2) * (item.Height - 8)
  form.gb_card_list:Add(item)
end
function on_btn_return_original_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute(FORM_MAIN, "create_body_player", form.body_type)
  init_card_equip_grid(form)
end
function add_card_equip_grid(form, id)
  local card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(card_manager) then
    return
  end
  local grid = form.grid_card_equip
  local is_get = card_manager:IsGetCard(nx_int(id))
  local card_info = card_manager:GetCardInfo(nx_int(id))
  local count = table.getn(card_info)
  if nx_int(count) < nx_int(CARD_INFO_COUNT) then
    return
  end
  local main_type = card_info[CARD_INFO_MAIN_TYPE]
  if nx_number(main_type) <= nx_number(CARD_TYPE_MIN) or nx_number(main_type) >= nx_number(CARD_TYPE_MAX) then
    return
  end
  local sub_type = card_info[CARD_INFO_SUB_TYPE]
  local item_type = card_info[CARD_INFO_ITEM_TYPE]
  local photo = IMAGE_SMALL_CARD_PATH .. nx_string(id) .. ".png"
  local type_grid = {
    [CARD_TYPE_CLOTH] = 9,
    [CARD_TYPE_MOUNT] = 10
  }
  local index = -1
  if nx_number(main_type) == nx_number(CARD_TYPE_CLOTH) or nx_number(main_type) == nx_number(CARD_TYPE_MOUNT) then
    index = type_grid[main_type]
    grid:DelItem(index)
    grid:AddItem(index, photo, nx_widestr(id), nx_int(1), 0)
    grid:SetBindIndex(index, id)
  elseif nx_number(main_type) == nx_number(CARD_TYPE_WEAPON) then
    if weapon_grid[item_type] == nil then
      return
    end
    index = weapon_grid[item_type]
    grid:DelItem(index)
    grid:AddItem(index, photo, nx_widestr(id), nx_int(1), 0)
    grid:SetBindIndex(index, id)
  elseif nx_number(main_type) == nx_number(CARD_TYPE_DECORATE) then
    local decorate_grid = {
      [DECORATE_TYPE_ARM] = 11,
      [DECORATE_TYPE_WAIST] = 12,
      [DECORATE_TYPE_BACK] = 13,
      [DECORATE_TYPE_CLOAK] = 14,
      [DECORATE_TYPE_FACE] = 15
    }
    index = decorate_grid[sub_type]
    grid:DelItem(index)
    grid:AddItem(index, photo, nx_widestr(id), nx_int(1), 0)
    grid:SetBindIndex(index, id)
  end
  grid:CoverItem(nx_int(index), false)
  if not is_get and nx_number(index) > nx_number(0) then
    grid:CoverItem(nx_number(index), true)
    grid:SetItemCoverImage(nx_number(index), IMAGE_LOCK)
  end
end
function init_card_equip_grid(form)
  local grid = form.grid_card_equip
  grid:Clear()
  local card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(card_manager) then
    return
  end
  local card_list = card_manager:GetUsedCardList()
  local count = table.getn(card_list)
  if nx_number(count) <= nx_number(0) then
    return
  end
  local type_grid = {
    [CARD_TYPE_CLOTH] = 9,
    [CARD_TYPE_MOUNT] = 10
  }
  for i = 1, count do
    local id = card_list[i]
    local card_info = card_manager:GetCardInfo(nx_number(id))
    local count = table.getn(card_info)
    if nx_int(count) < nx_int(CARD_INFO_COUNT) then
      return
    end
    local main_type = card_info[CARD_INFO_MAIN_TYPE]
    if nx_number(main_type) <= nx_number(CARD_TYPE_MIN) or nx_number(main_type) >= nx_number(CARD_TYPE_MAX) then
      return
    end
    local sub_type = card_info[CARD_INFO_SUB_TYPE]
    local item_type = card_info[CARD_INFO_ITEM_TYPE]
    local photo = IMAGE_SMALL_CARD_PATH .. nx_string(id) .. ".png"
    local index = -1
    if nx_number(main_type) == nx_number(CARD_TYPE_CLOTH) then
      local cloth_id = card_manager:query_cur_body_cloth(form.body_type)
      if nx_number(cloth_id) == nx_number(id) then
        index = type_grid[main_type]
        grid:DelItem(index)
        grid:AddItem(index, photo, nx_widestr(id), nx_int(1), 0)
        grid:SetBindIndex(index, id)
      end
    elseif nx_number(main_type) == nx_number(CARD_TYPE_MOUNT) then
      index = type_grid[main_type]
      grid:DelItem(index)
      grid:AddItem(index, photo, nx_widestr(id), nx_int(1), 0)
      grid:SetBindIndex(index, id)
    elseif nx_number(main_type) == nx_number(CARD_TYPE_WEAPON) then
      if weapon_grid[item_type] == nil then
        return
      end
      index = weapon_grid[item_type]
      grid:DelItem(index)
      grid:AddItem(index, photo, nx_widestr(id), nx_int(1), 0)
      grid:SetBindIndex(index, id)
    elseif nx_number(main_type) == nx_number(CARD_TYPE_DECORATE) then
      local decorate_grid = {
        [DECORATE_TYPE_ARM] = 11,
        [DECORATE_TYPE_WAIST] = 12,
        [DECORATE_TYPE_BACK] = 13,
        [DECORATE_TYPE_CLOAK] = 14,
        [DECORATE_TYPE_FACE] = 15
      }
      index = decorate_grid[sub_type]
      grid:DelItem(index)
      grid:AddItem(index, photo, nx_widestr(id), nx_int(1), 0)
      grid:SetBindIndex(index, id)
    end
  end
end
function on_grid_card_equip_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local id = grid:GetItemName(nx_int(index))
  if nx_string(id) == nx_string("") then
    local text = util_text("tips_card_equip_pos_" .. nx_string(index))
    show_text_tip(text, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 0, form)
    return
  end
  local card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(card_manager) then
    return
  end
  local card_info = card_manager:GetCardInfo(nx_int(id))
  local count = table.getn(card_info)
  if nx_int(count) < nx_int(CARD_INFO_COUNT) then
    return
  end
  local item_type = card_info[CARD_INFO_ITEM_TYPE]
  local item = get_tips_ArrayList()
  if not nx_is_valid(item) then
    return
  end
  item.ConfigID = nx_string(id)
  item.ItemType = nx_number(89)
  item.card_name = util_text("card_item_" .. nx_string(id))
  item.card_Item_type = nx_number(item_type)
  item.card_photo = nx_string("gui\\special\\card\\" .. nx_string(id) .. ".png")
  item.is_card = true
  show_goods_tip(item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 40, 40, form)
end
function on_grid_card_equip_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  hide_tip(form)
end
function on_grid_card_equip_rightclick_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  grid:CoverItem(index, false)
  grid:DelItem(index)
  if is_mount_show(form) then
    return
  end
  if nx_int(index) >= nx_int(0) and nx_int(index) <= nx_int(8) then
    nx_execute(FORM_MAIN, "player_unlink_fwz", "weapon")
  elseif nx_int(index) == nx_int(9) then
    nx_execute(FORM_MAIN, "player_unlink_fwz", "cloth")
  elseif nx_int(index) == nx_int(11) then
    nx_execute(FORM_MAIN, "LinkCardDecorate", "", 1)
  elseif nx_int(index) == nx_int(12) then
    nx_execute(FORM_MAIN, "player_unlink_fwz", "waist")
  elseif nx_int(index) == nx_int(13) then
    nx_execute(FORM_MAIN, "LinkCardDecorate", "", 3)
  elseif nx_int(index) == nx_int(14) then
    nx_execute(FORM_MAIN, "player_unlink_fwz", "cloak")
  elseif nx_int(index) == nx_int(15) then
    nx_execute(FORM_MAIN, "add_face_effect", 0)
  end
end
function is_equip_card(form, id)
  local grid = form.grid_card_equip
  if not nx_is_valid(grid) then
    return false
  end
  local grid_count = grid.ClomnNum - 1
  if nx_number(grid_count) <= nx_number(0) then
    return false
  end
  for index = 0, grid_count do
    if not grid:IsEmpty(nx_number(index)) then
      local card_id = grid:GetBindIndex(nx_number(index))
      if nx_number(card_id) == nx_number(id) then
        return true
      end
    end
  end
  return false
end
function equip_card(form)
  local card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(card_manager) then
    return
  end
  local grid = form.grid_card_equip
  if not nx_is_valid(grid) then
    return
  end
  local grid_count = grid.ClomnNum - 1
  if nx_number(grid_count) <= nx_number(0) then
    return
  end
  for index = 0, grid_count do
    if not grid:IsEmpty(nx_number(index)) then
      local id = grid:GetBindIndex(nx_number(index))
      card_manager:OnUseCrad(nx_number(id))
    end
  end
  return
end
function is_mount_show(form)
  local gb = form.groupbox_card
  if not nx_is_valid(gb) then
    return
  end
  local id = gb.card_id
  local card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(card_manager) then
    return
  end
  local card_info = card_manager:GetCardInfo(id)
  local count = table.getn(card_info)
  if nx_int(count) < nx_int(CARD_INFO_COUNT) then
    return
  end
  local main_type = card_info[CARD_INFO_MAIN_TYPE]
  if nx_number(main_type) ~= nx_number(CARD_TYPE_MOUNT) then
    return false
  end
  return true
end
function init_card_statistic(form)
  nx_execute(FORM_CARD, "get_statistic_card_number", form)
end
function on_btn_save_card_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(card_manager) then
    return
  end
  local list = card_manager:GetUsedCardList()
  local count = table.getn(list)
  if nx_number(count) > nx_number(0) then
    for i = 1, count do
      local id = nx_number(list[i])
      if not is_equip_card(form, id) then
        local card_info = card_manager:GetCardInfo(id)
        local count = table.getn(card_info)
        if nx_int(count) < nx_int(CARD_INFO_COUNT) then
          return
        end
        local main_type = card_info[CARD_INFO_MAIN_TYPE]
        local body_type = card_manager:query_card_body_type(id)
        if nx_number(main_type) == nx_number(CARD_TYPE_CLOTH) and nx_number(body_type) <= nx_number(0) then
        else
          card_manager:OnCancelCrad(id)
        end
      end
    end
  end
  equip_card(form)
end
function add_data_bind(form)
  local data_binder = nx_value("data_binder")
  if not nx_is_valid(data_binder) then
    return
  end
  data_binder:AddTableBind(REC_CARD, form, nx_current(), "on_card_rec_change")
end
function del_data_bind(form)
  local data_binder = nx_value("data_binder")
  if not nx_is_valid(data_binder) then
    return
  end
  data_binder:DelTableBind(REC_CARD, form)
end
function on_card_rec_change(bind_id, rec_name, op_type, row, col)
  if not nx_is_valid(bind_id) then
    return
  end
  show_card_list(bind_id)
end
function on_btn_open_origin_body_dec(btn)
  util_auto_show_hide_form(FORM_DESC)
end
function create_scrollbar(ctrl, template)
  local vscrollbar = ctrl.VScrollBar
  local tpl_vscrollbar = template.VScrollBar
  if not nx_is_valid(vscrollbar) or not nx_is_valid(tpl_vscrollbar) then
    return
  end
  vscrollbar.BackColor = tpl_vscrollbar.BackColor
  vscrollbar.ButtonSize = tpl_vscrollbar.ButtonSize
  vscrollbar.FullBarBack = tpl_vscrollbar.FullBarBack
  vscrollbar.ShadowColor = tpl_vscrollbar.ShadowColor
  vscrollbar.BackImage = tpl_vscrollbar.BackImage
  vscrollbar.NoFrame = tpl_vscrollbar.NoFrame
  vscrollbar.DrawMode = tpl_vscrollbar.DrawMode
  vscrollbar.DecButton.NormalImage = tpl_vscrollbar.DecButton.NormalImage
  vscrollbar.DecButton.FocusImage = tpl_vscrollbar.DecButton.FocusImage
  vscrollbar.DecButton.PushImage = tpl_vscrollbar.DecButton.PushImage
  vscrollbar.DecButton.Width = tpl_vscrollbar.DecButton.Width
  vscrollbar.DecButton.Height = tpl_vscrollbar.DecButton.Height
  vscrollbar.DecButton.DrawMode = tpl_vscrollbar.DecButton.DrawMode
  vscrollbar.IncButton.NormalImage = tpl_vscrollbar.IncButton.NormalImage
  vscrollbar.IncButton.FocusImage = tpl_vscrollbar.IncButton.FocusImage
  vscrollbar.IncButton.PushImage = tpl_vscrollbar.IncButton.PushImage
  vscrollbar.IncButton.Width = tpl_vscrollbar.IncButton.Width
  vscrollbar.IncButton.Height = tpl_vscrollbar.IncButton.Height
  vscrollbar.IncButton.DrawMode = tpl_vscrollbar.IncButton.DrawMode
  vscrollbar.TrackButton.NormalImage = tpl_vscrollbar.TrackButton.NormalImage
  vscrollbar.TrackButton.FocusImage = tpl_vscrollbar.TrackButton.FocusImage
  vscrollbar.TrackButton.PushImage = tpl_vscrollbar.TrackButton.PushImage
  vscrollbar.TrackButton.Width = tpl_vscrollbar.TrackButton.Width
  vscrollbar.TrackButton.Height = tpl_vscrollbar.TrackButton.Height
  vscrollbar.TrackButton.Enabled = tpl_vscrollbar.TrackButton.Enabled
  vscrollbar.TrackButton.DrawMode = tpl_vscrollbar.TrackButton.DrawMode
end
function show_page(index)
  local form = util_show_form(FORM_BODY, true)
  if not nx_is_valid(form) then
    return
  end
  local page_info = {
    [MAIN_TYPE_ORIGIN] = {
      rbtn = form.rbtn_origin,
      func = "set_origin"
    },
    [MAIN_TYPE_JIANGHU] = {
      rbtn = form.rbtn_jianghu,
      func = "set_jianghu"
    },
    [MAIN_TYPE_CARD] = {
      rbtn = form.rbtn_card,
      func = "set_card"
    }
  }
  if page_info[index] == nil then
    return
  end
  local info = page_info[index]
  info.rbtn.Checked = true
  nx_execute(FORM_BODY, info.func, form)
end
