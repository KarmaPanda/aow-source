require("util_gui")
require("role_composite")
require("util_static_data")
require("define\\sysinfo_define")
require("tips_data")
require("util_functions")
local SKILL_FILL_PATH = "share\\Skill\\skill_new.ini"
local image_lable = "\\gui\\special\\card\\"
local inmage_path = "gui\\language\\ChineseS\\card\\"
local FORM_CARD = "form_stage_main\\form_attire\\form_attire_card"
local CARD_FILL_PATH = "share\\Rule\\card.ini"
local CARD_FILL_STATIC_INFO_PATH = "share\\Item\\ItemArtStatic.ini"
local CARD_IS_COLLECTED = "gui\\special\\attire\\attire_back\\fwz_ysj.png"
local CARD_NO_COLLECTED = "gui\\special\\attire\\attire_back\\fwz_wsj.png"
local CARD_NO_HEADICON = "gui\\special\\attire\\attire_back\\nophoto.png"
local CARD_MAIN_TYPE_WEAPON = 1
local CARD_MAIN_TYPE_EQUIP = 2
local CARD_MAIN_TYPE_HORSE = 3
local CARD_MAIN_TYPE_OTHENR = 4
local CARD_MAIN_TYPE_DECORATE = 5
local ITEMTYPE_WEAPON_BLADE = 101
local ITEMTYPE_WEAPON_SWORD = 102
local ITEMTYPE_WEAPON_THORN = 103
local ITEMTYPE_WEAPON_SBLADE = 104
local ITEMTYPE_WEAPON_SSWORD = 105
local ITEMTYPE_WEAPON_STHORN = 106
local ITEMTYPE_WEAPON_STUFF = 107
local ITEMTYPE_WEAPON_COSH = 108
local ITEMTYPE_WEAPON_BOW = 127
local EQUIP_SUB_TYPE_SUIT = 1
local EQUIP_SUB_TYPE_CLOTH = 2
local EQUIP_SUB_TYPE_HAT = 3
local EQUIP_SUB_TYPE_SHOSE = 4
local DECORATE_ARM = 1
local DECORATE_WAIST = 2
local DECORATE_BACK = 3
local DECORATE_SUB_TYPE_PIFENG = 4
local DECORATE_SUB_TYPE_FACE = 5
local PAGE_COUNT = 6
local CARD_MAX_COUNT = 1000
local max_info_count = 13
local max_head_skill = 10
local WEAPON_TYPE_MAX = 9
local TREASURE_TYPE_MAX = 5
local ZAXIANG_TYPE_MAX = 8
local card_info_table = {}
local card_head_skill = {}
local card_id_table = {}
local TEXT_SEE_SELF = "ui_shuzhuangge_yulan01"
local TEXT_SEE_OTHER = "ui_shuzhuangge_yulan02"
function main_form_init(form)
  reset_card_choice(form)
  form.sex = get_player_sex()
  form.main_type = 2
  form.cloth_card = 0
  form.role_type = 0
  form.select_head = nil
end
function on_main_form_open(form)
  refresh_combobox(form)
  get_statistic_card_number(form)
  choose_card(from)
  get_uesd_card_list(form)
  data_bind_prop(form)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  util_show_form("form_stage_main\\form_card\\form_card_replace", false)
  del_data_bind_prop(form)
  nx_destroy(form)
end
function refresh_combobox(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.combobox_list.OnlySelect = true
  form.combobox_list.Visible = false
  form.combobox_list.DropListBox:ClearString()
  local combox_max = 0
  local main_type = form.main_type
  if nx_int(main_type) == nx_int(1) then
    combox_max = WEAPON_TYPE_MAX
  elseif nx_int(main_type) == nx_int(5) then
    combox_max = TREASURE_TYPE_MAX
  elseif nx_int(main_type) == nx_int(4) then
    combox_max = ZAXIANG_TYPE_MAX
  end
  if nx_int(combox_max) > nx_int(0) then
    form.combobox_list.DropListBox:AddString(gui.TextManager:GetText("ui_card_state_0"))
    for i = 1, combox_max do
      local sub_name = gui.TextManager:GetFormatText("ui_card_" .. nx_string(main_type) .. "_" .. nx_string(i))
      form.combobox_list.DropListBox:AddString(nx_widestr(sub_name))
      form.combobox_list.DropListBox.SelectIndex = 0
    end
    form.combobox_list.Text = nx_widestr(gui.TextManager:GetText("ui_card_state_0"))
    form.combobox_list.Visible = true
  end
end
function reset_card_choice(form)
  form.main_type = 0
  form.sub_type = 0
  form.status = 0
  form.level = 0
  form.author = 0
  form.book = 0
  form.pageno = 1
  form.maxpageno = 1000
  form.refresh_time = 0
  form.save_time = 0
end
function get_statistic_card_number(form)
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local statistic_table = collect_card_manager:StatisticCardNumber()
  local length = table.getn(statistic_table)
  if length < 8 then
    return
  end
  local all_level_1 = statistic_table[1]
  local all_level_2 = statistic_table[2]
  local all_level_3 = statistic_table[3]
  local all_level_4 = statistic_table[4]
  local get_level_1 = statistic_table[5]
  local get_level_2 = statistic_table[6]
  local get_level_3 = statistic_table[7]
  local get_level_4 = statistic_table[8]
  local sum_all = all_level_2 + all_level_3 + all_level_4
  local sum_get = get_level_2 + get_level_3 + get_level_4
  form.lbl_sum.Text = nx_widestr(sum_get) .. nx_widestr("/") .. nx_widestr(sum_all)
  if sum_all ~= 0 then
    local ratio = sum_get / sum_all
    form.lbl_ratio.Text = nx_widestr(nx_decimals(ratio * 100, 2)) .. nx_widestr("%")
  else
    form.lbl_ratio.Text = nx_widestr("0%")
  end
  form.lbl_level_one.Text = nx_widestr(get_level_1)
  form.lbl_level_two.Text = nx_widestr(get_level_2) .. nx_widestr("/") .. nx_widestr(all_level_2)
  form.lbl_level_three.Text = nx_widestr(get_level_3) .. nx_widestr("/") .. nx_widestr(all_level_3)
  form.lbl_level_four.Text = nx_widestr(get_level_4) .. nx_widestr("/") .. nx_widestr(all_level_4)
  form.pbar_1.Value = sum_get
  form.pbar_1.Maximum = sum_all
end
function get_all_query_param()
  local form = nx_value(FORM_CARD)
  if not nx_is_valid(form) then
    return
  end
  return form.main_type, form.sub_type, form.status, form.level, form.author, form.book
end
function choose_card(form)
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local form = nx_value(FORM_CARD)
  if not nx_is_valid(form) then
    return
  end
  local main_type, sub_type, status, level, author, book = get_all_query_param()
  card_id_table = {}
  card_id_table = collect_card_manager:OnChooseCard(nx_int(main_type), nx_int(sub_type), nx_int(status), nx_int(level), nx_int(author), nx_int(book))
  refresh_card(card_id_table, form, form.pageno)
end
function refresh_card(card_id_table, form, pageno)
  if not nx_is_valid(form) then
    return
  end
  local skillini = nx_execute("util_functions", "get_ini", SKILL_FILL_PATH)
  if not nx_is_valid(skillini) then
    return
  end
  form.groupbox_1:DeleteAll()
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local begin_pos = (pageno - 1) * PAGE_COUNT + 1
  local end_pos = pageno * PAGE_COUNT
  local card_num = table.getn(card_id_table)
  if card_num == 0 then
    form.lbl_page.Text = nx_widestr("0") .. nx_widestr("/") .. nx_widestr("0")
    return
  end
  local records = card_num / 3
  if end_pos > records then
    end_pos = records
  end
  if records % PAGE_COUNT == 0 then
    form.maxpageno = nx_int(records / PAGE_COUNT)
  else
    form.maxpageno = nx_int(records / PAGE_COUNT) + 1
  end
  local index = 1
  for i = begin_pos, end_pos do
    local base = (i - 1) * 3
    local card_id = card_id_table[1 + base]
    local get_state = card_id_table[2 + base]
    local open_flag = card_id_table[3 + base]
    card_info_table = {}
    card_info_table = collect_card_manager:GetCardInfo(card_id)
    if table.getn(card_info_table) < max_info_count then
      return
    end
    card_head_skill = {}
    card_head_skill = collect_card_manager:GetCardHeadIcon(card_id)
    if table.getn(card_head_skill) < max_head_skill then
      return
    end
    local main_type = card_info_table[2]
    local level = card_info_table[5]
    local author = card_info_table[6]
    local book = card_info_table[7]
    local config_id = card_info_table[8]
    local condition = card_info_table[9]
    local female_model = card_info_table[10]
    local male_model = card_info_table[11]
    local flag = card_info_table[12]
    local sub_type = card_info_table[13]
    local female_head_prop = card_head_skill[1]
    local female_head_model = card_head_skill[2]
    local female_head_icon = card_head_skill[3]
    local male_head_prop = card_head_skill[4]
    local male_head_model = card_head_skill[5]
    local male_head_icon = card_head_skill[6]
    local female_card_skill = card_head_skill[7]
    local male_card_skill = card_head_skill[8]
    local female_card_action = card_head_skill[9]
    local male_card_action = card_head_skill[10]
    local is_active = collect_card_manager:IsGetCard(nx_int(card_id))
    local head_icon = female_head_icon
    local card_skill = female_card_skill
    local card_action = female_card_action
    if form.sex == 0 then
      head_icon = male_head_icon
      card_skill = male_card_skill
      card_action = male_card_action
    end
    if nx_int(flag) > nx_int(0) then
      local new_box
      if main_type == CARD_MAIN_TYPE_WEAPON then
        new_box = create_weapon_box(form, skillini, index, card_id, level, card_skill, card_action, main_type, sub_type, is_active)
      elseif main_type == CARD_MAIN_TYPE_EQUIP then
        new_box = create_cloth_box(form, skillini, index, card_id, level, head_icon, card_skill, card_action, main_type, sub_type, is_active)
      elseif main_type == CARD_MAIN_TYPE_HORSE then
        new_box = create_horse_box(form, index, card_id, level, main_type, sub_type, is_active)
      elseif main_type == CARD_MAIN_TYPE_DECORATE then
        new_box = create_treasure_box(form, index, card_id, level, main_type, sub_type, is_active)
      else
        new_box = create_zaxiang_box(form, index, card_id, level, main_type, sub_type, is_active)
      end
      if new_box ~= nil then
        new_box.Left = (index - 1) % 2 * (new_box.Width + 6) + 10
        new_box.Top = nx_int((index - 1) / 2) * (new_box.Height + 3) + 6
        form.groupbox_1:Add(new_box)
        index = index + 1
      end
    end
  end
  form.lbl_page.Text = nx_widestr(form.pageno) .. nx_widestr("/") .. nx_widestr(form.maxpageno)
end
function create_groupbox(form, index, temp_name)
  local source_ent = nx_custom(form, temp_name)
  if not nx_is_valid(source_ent) then
    return nil
  end
  local gui = nx_value("gui")
  local groupbox = gui:Create("GroupBox")
  set_copy_ent_info(form, temp_name, groupbox)
  local child_ctrls = source_ent:GetChildControlList()
  for i, ctrl in ipairs(child_ctrls) do
    local ctrl_obj = gui:Create(nx_name(ctrl))
    if nx_is_valid(ctrl_obj) then
      set_copy_ent_info(form, ctrl.Name, ctrl_obj)
      ctrl_obj.Name = ctrl.Name .. nx_string(index)
      if nx_string(nx_name(ctrl)) == "MultiTextBox" then
        copy_scrollbar(ctrl_obj, ctrl)
      end
      groupbox:Add(ctrl_obj)
    end
  end
  return groupbox
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
function add_card_skill(grid, skillini, skill_id)
  if not nx_is_valid(skillini) or not nx_is_valid(grid) then
    return
  end
  if skillini:FindSection(nx_string(skill_id)) then
    local sec_index = skillini:FindSectionIndex(nx_string(skill_id))
    if 0 <= sec_index then
      local static_data = skillini:ReadInteger(sec_index, "StaticData", 0)
      local name = skillini:GetSectionByIndex(sec_index)
      local photo = skill_static_query(static_data, "Photo")
      local cooltype = skill_static_query(static_data, "CoolDownCategory")
      local coolteam = skill_static_query(static_data, "CoolDownTeam")
      grid:AddItem(0, nx_string(photo), nx_widestr(name), nx_int(0), 0)
    end
  end
end
function on_rbtn_level_click(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  local main_type = form.main_type
  local sub_type = form.sub_type
  reset_card_choice(form)
  form.main_type = main_type
  form.sub_type = sub_type
  form.level = rbtn.TabIndex
  choose_card(form)
end
function on_rbtn_option_click(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  reset_card_choice(form)
  form.main_type = rbtn.TabIndex
  choose_card(form)
  refresh_combobox(form)
  reset_level_option(form)
  if nx_int(form.role_type) == nx_int(1) and (nx_int(form.main_type) == nx_int(1) or nx_int(form.main_type) == nx_int(2) or nx_int(form.main_type) == nx_int(5)) then
    form.role_type = 0
    get_uesd_card_list(form)
    nx_execute("form_stage_main\\form_attire\\form_attire_main", "reset_fwz", true)
    ctr_sex_btn(true)
    nx_execute("form_stage_main\\form_attire\\form_attire_main", "create_fwz_player")
  end
  form.btn_huanse.Visible = false
  if nx_int(form.main_type) == nx_int(2) then
    form.btn_huanse.Visible = true
  end
  form.btn_save.Visible = true
  if nx_int(form.main_type) == nx_int(4) then
    form.btn_save.Visible = false
  end
end
function on_rbtn_get_click(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  local main_type = form.main_type
  local sub_type = form.sub_type
  reset_card_choice(form)
  form.main_type = main_type
  form.sub_type = sub_type
  form.status = rbtn.TabIndex
  choose_card(form)
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  local page = form.pageno
  page = page - 1
  if 0 < page then
    form.pageno = page
  end
  choose_card(form)
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  local page = form.pageno
  page = page + 1
  if page <= form.maxpageno then
    form.pageno = page
  end
  choose_card(form)
end
function on_btn_huanse_click(btn)
  util_show_form("form_stage_main\\form_card\\form_card_replace", false)
  util_show_form("form_stage_main\\form_card\\form_card_replace", true)
end
function on_grid_head_click(grid, index)
  local form = grid.ParentForm
  if nx_is_valid(form.select_head) and not nx_id_equal(form.select_head, grid) then
    form.select_head:SetSelectItemIndex(-1)
  end
  form.select_head = grid
  local parent_grid = grid.Parent
  if not nx_find_custom(parent_grid, "card_id") then
    return
  end
  local card_id = parent_grid.card_id
  if nx_int(card_id) <= nx_int(0) or nx_int(card_id) > nx_int(CARD_MAX_COUNT) then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local cloth_card = form.cloth_card
  if nx_int(cloth_card) > nx_int(0) then
    card_info_table = {}
    card_info_table = collect_card_manager:GetCardInfo(cloth_card)
    if table.getn(card_info_table) < max_info_count then
      return
    end
    local female_model = card_info_table[10]
    local male_model = card_info_table[11]
    local player_model = female_model
    if form.sex == 0 then
      player_model = male_model
    end
    if string.find(player_model, nx_string("Hat")) then
      return
    end
  end
  card_head_skill = {}
  card_head_skill = collect_card_manager:GetCardHeadIcon(card_id)
  if table.getn(card_head_skill) < max_head_skill then
    return
  end
  local female_head_prop = card_head_skill[1]
  local female_head_model = card_head_skill[2]
  local female_head_icon = card_head_skill[3]
  local male_head_prop = card_head_skill[4]
  local male_head_model = card_head_skill[5]
  local male_head_icon = card_head_skill[6]
  local female_card_skill = card_head_skill[7]
  local male_card_skill = card_head_skill[8]
  local head_model = female_head_model
  if form.sex == 0 then
    head_model = male_head_model
  end
  if head_model == "" then
    return
  end
  nx_execute("form_stage_main\\form_attire\\form_attire_main", "player_link_equip", "hat", head_model)
end
function on_grid_card_click(grid, index)
  local form = grid.ParentForm
  local new_time = nx_function("ext_get_tickcount")
  if new_time - form.refresh_time < 1000 then
    return
  end
  form.refresh_time = new_time
  local parent_grid = grid.Parent
  if not nx_find_custom(parent_grid, "card_id") then
    return
  end
  local card_id = parent_grid.card_id
  if nx_int(card_id) <= nx_int(0) or nx_int(card_id) > nx_int(CARD_MAX_COUNT) then
    local gui = nx_value("gui")
    local info = gui.TextManager:GetText("90205")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  card_info_table = {}
  card_info_table = collect_card_manager:GetCardInfo(card_id)
  local length = table.getn(card_info_table)
  if length < max_info_count then
    return
  end
  local card_id = card_info_table[1]
  local main_type = card_info_table[2]
  local level = card_info_table[5]
  local author = card_info_table[6]
  local book = card_info_table[7]
  local config_id = card_info_table[8]
  local condition = card_info_table[9]
  local female_model = card_info_table[10]
  local male_model = card_info_table[11]
  local flag = card_info_table[12]
  local sub_type = card_info_table[13]
  if main_type == CARD_MAIN_TYPE_WEAPON then
    local main_form = nx_value("form_stage_main\\form_attire\\form_attire_main")
    if nx_is_valid(main_form) then
      main_form.is_equip_fwz_weapon = true
    end
    nx_execute("form_stage_main\\form_attire\\form_attire_main", "player_link_equip", "weapon", config_id, false, nx_string(card_id))
  elseif main_type == CARD_MAIN_TYPE_EQUIP then
    form.cloth_card = card_id
    nx_execute("form_stage_main\\form_attire\\form_attire_main", "player_link_fwz", card_id)
  elseif main_type == CARD_MAIN_TYPE_HORSE then
    form.cloth_card = 0
    form.role_type = 1
    local mount_model = female_model
    if form.sex == 0 then
      mount_model = male_model
    end
    local mount_lst = util_split_string(mount_model, ":")
    if table.getn(mount_lst) == 2 then
      nx_execute("form_stage_main\\form_attire\\form_attire_main", "reset_fwz", false)
      ctr_sex_btn(false)
      nx_execute("form_stage_main\\form_attire\\form_attire_main", "create_npc_model_by_path", mount_lst[2], 2)
    end
  elseif main_type == CARD_MAIN_TYPE_DECORATE then
    local dec_model = female_model
    if form.sex == 0 then
      dec_model = male_model
    end
    if nx_int(sub_type) == nx_int(DECORATE_SUB_TYPE_FACE) then
      nx_execute("form_stage_main\\form_attire\\form_attire_main", "add_face_effect", card_id)
    elseif nx_int(sub_type) == nx_int(DECORATE_SUB_TYPE_PIFENG) or nx_int(sub_type) == nx_int(DECORATE_WAIST) then
      form.cloth_card = card_id
      nx_execute("form_stage_main\\form_attire\\form_attire_main", "player_fwz_link_sp", card_id)
    else
      nx_execute("form_stage_main\\form_attire\\form_attire_main", "LinkCardDecorate", dec_model, nx_int(sub_type))
    end
  end
  grid_card_add(form, card_id)
end
function get_player_sex()
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return 0
  end
  return player:QueryProp("Sex")
end
function on_btn_reback_click(btn)
  local form = btn.ParentForm
  local sex = get_player_sex()
  local main_form = nx_value("form_stage_main\\form_attire\\form_attire_main")
  if nx_is_valid(main_form) then
    main_form.is_equip_fwz_weapon = false
  end
  if form.sex == sex then
    nx_execute("form_stage_main\\form_attire\\form_attire_main", "create_fwz_player")
  else
    nx_execute("form_stage_main\\form_attire\\form_attire_main", "refresh_fwz_other")
  end
  get_uesd_card_list(btn.ParentForm)
end
function on_grid_card_rightclick_grid(grid, index)
  if grid:IsEmpty(nx_int(index)) then
    return
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.role_type) == nx_int(0) then
    if nx_int(index) >= nx_int(0) and nx_int(index) <= nx_int(8) then
      local main_form = nx_value("form_stage_main\\form_attire\\form_attire_main")
      if nx_is_valid(main_form) then
        main_form.is_equip_fwz_weapon = false
      end
      nx_execute("form_stage_main\\form_attire\\form_attire_main", "player_unlink_fwz", "weapon")
    elseif nx_int(index) == nx_int(9) then
      nx_execute("form_stage_main\\form_attire\\form_attire_main", "player_unlink_fwz", "cloth")
    elseif nx_int(index) == nx_int(11) then
      nx_execute("form_stage_main\\form_attire\\form_attire_main", "LinkCardDecorate", "", 1)
    elseif nx_int(index) == nx_int(12) then
      nx_execute("form_stage_main\\form_attire\\form_attire_main", "player_unlink_fwz", "waist")
    elseif nx_int(index) == nx_int(13) then
      nx_execute("form_stage_main\\form_attire\\form_attire_main", "LinkCardDecorate", "", 3)
    elseif nx_int(index) == nx_int(14) then
      nx_execute("form_stage_main\\form_attire\\form_attire_main", "player_unlink_fwz", "cloak")
    elseif nx_int(index) == nx_int(15) then
      nx_execute("form_stage_main\\form_attire\\form_attire_main", "add_face_effect", 0)
    end
  end
  grid:CoverItem(index, false)
  grid:DelItem(index)
end
function on_grid_card_select_changed(self, index)
end
function on_grid_card_mousein_grid(self, index)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local card_id = self:GetItemName(nx_int(index))
  if nx_ws_length(nx_widestr(card_id)) <= 0 then
    nx_execute("tips_game", "show_text_tip", gui.TextManager:GetText("tips_card_equip_pos_" .. nx_string(index)), self:GetMouseInItemLeft(), self:GetMouseInItemTop(), 0, form)
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return 0
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  if nx_is_valid(item) then
    local config_id = get_ini_prop(CARD_FILL_PATH, card_id, "ConfigID", "0")
    local card_name = get_ini_prop(CARD_FILL_PATH, card_id, "Name", "0")
    local item_type = get_ini_prop(CARD_FILL_PATH, card_id, "ItemType", "0")
    local item_photo = get_ini_prop(CARD_FILL_STATIC_INFO_PATH, card_id, "Photo", "0")
    item.ConfigID = nx_string(card_id)
    item.ItemType = nx_int(89)
    local str_id = "card_item_" .. nx_string(card_id)
    item.card_name = gui.TextManager:GetText(str_id)
    item.card_Item_type = nx_int(item_type)
    item.card_photo = nx_string("gui\\special\\card\\" .. nx_string(card_id) .. ".png")
    item.is_card = true
    nx_execute("tips_game", "show_goods_tip", item, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), 40, 40, self.ParentForm)
  end
end
function on_grid_card_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function get_uesd_card_list(form)
  form.grid_card:Clear()
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local usedcard_list = collect_card_manager:GetUsedCardList()
  if usedcard_list == nil then
    return
  end
  local count = table.getn(usedcard_list)
  local grid = form.grid_card
  for i = 1, count do
    local card_id = usedcard_list[i]
    local info_table = collect_card_manager:GetCardInfo(card_id)
    local length = table.getn(info_table)
    if length < max_info_count then
      return
    end
    local main_type = info_table[2]
    local sub_type = info_table[3]
    local item_type = info_table[4]
    local photo = image_lable .. nx_string(card_id) .. ".png"
    if card_id ~= nil then
      if main_type == CARD_MAIN_TYPE_WEAPON then
        if item_type == ITEMTYPE_WEAPON_BLADE then
          grid:AddItem(0, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(0, card_id)
        elseif item_type == ITEMTYPE_WEAPON_SWORD then
          grid:AddItem(1, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(1, card_id)
        elseif item_type == ITEMTYPE_WEAPON_THORN then
          grid:AddItem(2, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(2, card_id)
        elseif item_type == ITEMTYPE_WEAPON_SBLADE then
          grid:AddItem(3, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(3, card_id)
        elseif item_type == ITEMTYPE_WEAPON_SSWORD then
          grid:AddItem(4, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(4, card_id)
        elseif item_type == ITEMTYPE_WEAPON_STHORN then
          grid:AddItem(5, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(5, card_id)
        elseif item_type == ITEMTYPE_WEAPON_STUFF then
          grid:AddItem(6, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(6, card_id)
        elseif item_type == ITEMTYPE_WEAPON_COSH then
          grid:AddItem(7, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(7, card_id)
        elseif item_type == ITEMTYPE_WEAPON_BOW then
          grid:AddItem(8, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(8, card_id)
        end
      elseif main_type == CARD_MAIN_TYPE_EQUIP then
        local body_type = collect_card_manager:query_card_body_type(card_id)
        if nx_number(body_type) == nx_number(0) then
          grid:AddItem(9, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(9, card_id)
        end
      elseif main_type == CARD_MAIN_TYPE_HORSE then
        grid:AddItem(10, photo, nx_widestr(card_id), nx_int(1), 0)
        grid:SetBindIndex(10, card_id)
      elseif main_type == CARD_MAIN_TYPE_DECORATE then
        if sub_type == DECORATE_ARM then
          grid:AddItem(11, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(11, card_id)
        elseif sub_type == DECORATE_WAIST then
          grid:AddItem(12, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(12, card_id)
        elseif sub_type == DECORATE_BACK then
          grid:AddItem(13, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(13, card_id)
        elseif sub_type == DECORATE_SUB_TYPE_PIFENG then
          grid:AddItem(14, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(14, card_id)
        elseif sub_type == DECORATE_SUB_TYPE_FACE then
          grid:AddItem(15, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(15, card_id)
        end
      end
    end
  end
end
function on_grid_skill_mousein(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local skill_id = grid:GetItemName(index)
  if nx_string(skill_id) == nx_string("") then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  if nx_is_valid(item) then
    item.is_static = true
    item.ConfigID = nx_string(skill_id)
    item.ItemType = get_ini_prop(SKILL_FILL_PATH, skill_id, "ItemType", "0")
    item.Level = 1
    item.static_skill_level = 1
    nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 40, 40, grid.ParentForm)
  end
end
function on_grid_skill_mouseout(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_grid_skill_select_changed(grid, index)
  local form = grid.ParentForm
  if grid:IsEmpty(index) then
    return
  end
  local skill_id = grid:GetItemName(index)
  if nx_string(skill_id) == nx_string("") then
    return
  end
  local skill_actin = grid.card_play_action
  if nx_string(skill_actin) == nx_string("") then
    return
  end
end
function data_bind_prop(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("CardRec", form, nx_current(), "on_table_operat")
  end
end
function del_data_bind_prop(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("CardRec", form)
  end
end
function on_table_operat(form, tablename, ttype, line, col)
  local form = nx_value(FORM_CARD)
  if not nx_is_valid(form) then
    return
  end
  choose_card(form)
end
function grid_card_add(form, card_id)
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local usedcard_list = collect_card_manager:GetUsedCardList()
  if usedcard_list == nil then
    return
  end
  local count = table.getn(usedcard_list)
  local grid = form.grid_card
  local is_active = collect_card_manager:IsGetCard(nx_int(card_id))
  local info_table = collect_card_manager:GetCardInfo(nx_int(card_id))
  local length = table.getn(info_table)
  if length < max_info_count then
    return
  end
  local main_type = info_table[2]
  local sub_type = info_table[3]
  local item_type = info_table[4]
  local photo = image_lable .. nx_string(card_id) .. ".png"
  local type_number = -1
  if card_id ~= nil then
    if main_type == CARD_MAIN_TYPE_WEAPON then
      if item_type == ITEMTYPE_WEAPON_BLADE then
        grid:DelItem(0)
        grid:AddItem(0, photo, nx_widestr(card_id), nx_int(1), 0)
        grid:SetBindIndex(0, card_id)
        type_number = 0
      elseif item_type == ITEMTYPE_WEAPON_SWORD then
        grid:DelItem(1)
        grid:AddItem(1, photo, nx_widestr(card_id), nx_int(1), 0)
        grid:SetBindIndex(1, card_id)
        type_number = 1
      elseif item_type == ITEMTYPE_WEAPON_THORN then
        grid:DelItem(2)
        grid:AddItem(2, photo, nx_widestr(card_id), nx_int(1), 0)
        grid:SetBindIndex(2, card_id)
        type_number = 2
      elseif item_type == ITEMTYPE_WEAPON_SBLADE then
        grid:DelItem(3)
        grid:AddItem(3, photo, nx_widestr(card_id), nx_int(1), 0)
        grid:SetBindIndex(3, card_id)
        type_number = 3
      elseif item_type == ITEMTYPE_WEAPON_SSWORD then
        grid:DelItem(4)
        grid:AddItem(4, photo, nx_widestr(card_id), nx_int(1), 0)
        grid:SetBindIndex(4, card_id)
        type_number = 4
      elseif item_type == ITEMTYPE_WEAPON_STHORN then
        grid:DelItem(5)
        grid:AddItem(5, photo, nx_widestr(card_id), nx_int(1), 0)
        grid:SetBindIndex(5, card_id)
        type_number = 5
      elseif item_type == ITEMTYPE_WEAPON_STUFF then
        grid:DelItem(6)
        grid:AddItem(6, photo, nx_widestr(card_id), nx_int(1), 0)
        grid:SetBindIndex(6, card_id)
        type_number = 6
      elseif item_type == ITEMTYPE_WEAPON_COSH then
        grid:DelItem(7)
        grid:AddItem(7, photo, nx_widestr(card_id), nx_int(1), 0)
        grid:SetBindIndex(7, card_id)
        type_number = 7
      elseif item_type == ITEMTYPE_WEAPON_BOW then
        grid:DelItem(8)
        grid:AddItem(8, photo, nx_widestr(card_id), nx_int(1), 0)
        grid:SetBindIndex(8, card_id)
        type_number = 8
      end
    elseif main_type == CARD_MAIN_TYPE_EQUIP then
      local body_type = collect_card_manager:query_card_body_type(card_id)
      if nx_number(body_type) == nx_number(0) then
        grid:DelItem(9)
        grid:AddItem(9, photo, nx_widestr(card_id), nx_int(1), 0)
        grid:SetBindIndex(9, card_id)
        type_number = 9
      end
    elseif main_type == CARD_MAIN_TYPE_HORSE then
      grid:DelItem(10)
      grid:AddItem(10, photo, nx_widestr(card_id), nx_int(1), 0)
      grid:SetBindIndex(10, card_id)
      type_number = 10
    elseif main_type == CARD_MAIN_TYPE_DECORATE then
      if sub_type == DECORATE_ARM then
        grid:DelItem(11)
        grid:AddItem(11, photo, nx_widestr(card_id), nx_int(1), 0)
        grid:SetBindIndex(11, card_id)
        type_number = 11
      elseif sub_type == DECORATE_WAIST then
        grid:DelItem(12)
        grid:AddItem(12, photo, nx_widestr(card_id), nx_int(1), 0)
        grid:SetBindIndex(12, card_id)
        type_number = 12
      elseif sub_type == DECORATE_BACK then
        grid:DelItem(13)
        grid:AddItem(13, photo, nx_widestr(card_id), nx_int(1), 0)
        grid:SetBindIndex(13, card_id)
        type_number = 13
      elseif sub_type == DECORATE_SUB_TYPE_PIFENG then
        grid:AddItem(14, photo, nx_widestr(card_id), nx_int(1), 0)
        grid:SetBindIndex(14, card_id)
        type_number = 14
      elseif sub_type == DECORATE_SUB_TYPE_FACE then
        grid:AddItem(15, photo, nx_widestr(card_id), nx_int(1), 0)
        grid:SetBindIndex(15, card_id)
        type_number = 15
      end
    end
    grid:CoverItem(nx_int(type_number), false)
    if is_active == false and nx_int(type_number) ~= nx_int(-1) then
      grid:CoverItem(nx_int(type_number), true)
      grid:SetItemCoverImage(nx_int(type_number), "gui\\special\\attire\\attire_back\\k03.png")
    end
  end
end
function check_need_save(form)
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return 0
  end
  if nx_int(form.sex) ~= nx_int(get_player_sex()) then
    return 0
  end
  local usedcard_list = collect_card_manager:GetUsedCardList()
  if usedcard_list == nil then
    return 0
  end
  local count = table.getn(usedcard_list)
  local grid = form.grid_card
  local max_num = grid.ClomnNum - 1
  local use_num = 0
  for index = 0, max_num do
    if not grid:IsEmpty(nx_int(index)) then
      local use_id = grid:GetBindIndex(nx_int(index))
      if nx_int(use_id) > nx_int(0) then
        use_num = use_num + 1
      end
    end
  end
  local find = 0
  for i = 1, count do
    local card_id = usedcard_list[i]
    if card_id ~= nil then
      find = 0
      for index = 0, max_num do
        if not grid:IsEmpty(nx_int(index)) then
          local use_id = grid:GetBindIndex(nx_int(index))
          if nx_int(use_id) == nx_int(card_id) then
            find = 1
          end
        end
      end
      if nx_int(find) == nx_int(0) then
        return 1
      end
    end
  end
  if nx_int(count) ~= nx_int(use_num) then
    return 1
  end
  return 0
end
function on_btn_save_click(btn)
  local form = btn.ParentForm
  local new_time = nx_function("ext_get_tickcount")
  if new_time - form.save_time < 1500 then
    return
  end
  form.save_time = new_time
  local check = check_need_save(form)
  if nx_int(check) == nx_int(0) then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local usedcard_list = collect_card_manager:GetUsedCardList()
  if usedcard_list == nil then
    return
  end
  local count = table.getn(usedcard_list)
  local grid = form.grid_card
  local max_num = grid.ClomnNum - 1
  for i = 1, count do
    local card_id = usedcard_list[i]
    if card_id ~= nil then
      local find = 0
      for index = 0, max_num do
        if not grid:IsEmpty(nx_int(index)) then
          local use_id = grid:GetBindIndex(nx_int(index))
          if nx_int(use_id) == nx_int(card_id) then
            find = 1
          end
        end
      end
      if nx_int(find) == nx_int(0) then
        local card_info = collect_card_manager:GetCardInfo(card_id)
        if table.getn(card_info) < max_info_count then
          return
        end
        local main_type = card_info[2]
        local body_type = collect_card_manager:query_card_body_type(card_id)
        if nx_number(main_type) == nx_number(CARD_MAIN_TYPE_EQUIP) and nx_number(body_type) > nx_number(0) then
        else
          collect_card_manager:OnCancelCrad(nx_int(card_id))
        end
      end
    end
  end
  for i = 0, max_num do
    if not grid:IsEmpty(nx_int(i)) then
      local select_id = grid:GetBindIndex(nx_int(i))
      if nx_int(select_id) > nx_int(0) then
        collect_card_manager:OnUseCrad(nx_int(select_id))
      end
    end
  end
end
function on_combobox_list_selected(self)
  local form = self.ParentForm
  form.sub_type = nx_int(self.DropListBox.SelectIndex)
  form.pageno = 1
  choose_card(from)
end
function create_cloth_box(form, skillini, index, card_id, level, head_icon, card_skill, card_action, main_type, sub_type, is_active)
  local new_box = create_groupbox(form, index, "groupbox_model_cloth")
  if nx_is_valid(new_box) then
    set_copy_ent_info(form, "groupbox_model_cloth", new_box)
    new_box.card_id = card_id
    local photo = nx_resource_path() .. inmage_path .. nx_string(card_id) .. ".png"
    local grid_back = new_box:Find("imagegrid_cloth_back" .. nx_string(index))
    if nx_is_valid(grid_back) then
      grid_back:AddItem(0, photo, "", 1, -1)
      nx_bind_script(grid_back, nx_current())
      nx_callback(grid_back, "on_right_click", "on_grid_card_click")
      nx_callback(grid_back, "on_select_changed", "on_grid_card_click")
    end
    local lbl_is_collect = new_box:Find("lbl_cloth_collect" .. nx_string(index))
    if nx_is_valid(lbl_is_collect) then
      if is_active == false then
        lbl_is_collect.BackImage = CARD_NO_COLLECTED
      else
        lbl_is_collect.BackImage = CARD_IS_COLLECTED
      end
    end
    local lbl_down = new_box:Find("btn_xiexia_cloth" .. nx_string(index))
    if nx_is_valid(lbl_down) then
      lbl_down.Visible = false
      if is_active == true then
        lbl_down.Visible = true
        nx_bind_script(lbl_down, nx_current())
        nx_callback(lbl_down, "on_click", "on_btn_card_down_click")
      end
    end
    local lbl_cloth_name = new_box:Find("lbl_cloth_name" .. nx_string(index))
    if nx_is_valid(lbl_cloth_name) then
      local item_config = get_ini_prop(CARD_FILL_PATH, card_id, "ConfigID", "0")
      local card_name = util_text("card_item_" .. nx_string(card_id))
      lbl_cloth_name.Text = card_name
    end
    local gui = nx_value("gui")
    local lbl_cloth_level = new_box:Find("lbl_cloth_level" .. nx_string(index))
    if nx_is_valid(lbl_cloth_level) then
      lbl_cloth_level.Text = nx_widestr(gui.TextManager:GetText("ui_card_level_" .. nx_string(level)))
    end
    local lbl_cloth_type = new_box:Find("lbl_cloth_type" .. nx_string(index))
    if nx_is_valid(lbl_cloth_type) then
      local type_name = gui.TextManager:GetFormatText("ui_card_" .. nx_string(main_type) .. "_" .. nx_string(sub_type))
      lbl_cloth_type.Text = nx_widestr(type_name)
    end
    local grid_head = new_box:Find("imagegrid_head" .. nx_string(index))
    if nx_is_valid(grid_head) then
      if head_icon == "" then
        head_icon = CARD_NO_HEADICON
      end
      grid_head:AddItem(0, head_icon, "", 1, -1)
      nx_bind_script(grid_head, nx_current())
      nx_callback(grid_head, "on_right_click", "on_grid_head_click")
      nx_callback(grid_head, "on_select_changed", "on_grid_head_click")
    end
    local cloth_skill_desc = new_box:Find("lbl_cloth_skill_desc" .. nx_string(index))
    local cloth_no_skill_desc = new_box:Find("lbl_nocloth_skill" .. nx_string(index))
    local skill_grid_1 = new_box:Find("skill_grid_1" .. nx_string(index))
    local skill_grid_2 = new_box:Find("skill_grid_2" .. nx_string(index))
    if nx_is_valid(skill_grid_1) then
      skill_grid_1.Visible = false
    end
    if nx_is_valid(skill_grid_2) then
      skill_grid_2.Visible = false
    end
    if nx_is_valid(cloth_skill_desc) then
      cloth_skill_desc.Visible = false
    end
    if nx_is_valid(cloth_no_skill_desc) then
      cloth_no_skill_desc.Visible = false
    end
    if card_skill ~= "" then
      local skill_tmp_lst = util_split_string(card_skill, ",")
      local action_tmp_lst = util_split_string(card_action, ",")
      local action_count = table.getn(action_tmp_lst)
      for i = 1, table.getn(skill_tmp_lst) do
        local skill_grid = new_box:Find("skill_grid_" .. nx_string(i) .. nx_string(index))
        if nx_is_valid(skill_grid) then
          skill_grid.Visible = true
          add_card_skill(skill_grid, skillini, skill_tmp_lst[i])
          nx_bind_script(skill_grid, nx_current())
          nx_callback(skill_grid, "on_mousein_grid", "on_grid_skill_mousein")
          nx_callback(skill_grid, "on_mouseout_grid", "on_grid_skill_mouseout")
          nx_callback(skill_grid, "on_select_changed", "on_grid_skill_select_changed")
          skill_grid.card_play_action = ""
          if i <= action_count then
            skill_grid.card_play_action = action_tmp_lst[i]
          end
        end
      end
      if nx_is_valid(cloth_skill_desc) then
        cloth_skill_desc.Visible = true
      end
    elseif nx_is_valid(cloth_no_skill_desc) then
      cloth_no_skill_desc.Visible = true
    end
    return new_box
  end
  return nil
end
function create_weapon_box(form, skillini, index, card_id, level, card_skill, card_action, main_type, sub_type, is_active)
  local new_box = create_groupbox(form, index, "groupbox_model_weapon")
  if nx_is_valid(new_box) then
    set_copy_ent_info(form, "groupbox_model_weapon", new_box)
    new_box.card_id = card_id
    local photo = nx_resource_path() .. inmage_path .. nx_string(card_id) .. ".png"
    local grid_back = new_box:Find("imagegrid_wepon_back" .. nx_string(index))
    if nx_is_valid(grid_back) then
      grid_back:AddItem(0, photo, "", 1, -1)
      nx_bind_script(grid_back, nx_current())
      nx_callback(grid_back, "on_right_click", "on_grid_card_click")
      nx_callback(grid_back, "on_select_changed", "on_grid_card_click")
    end
    local lbl_is_collect = new_box:Find("lbl_weapon_collect" .. nx_string(index))
    if nx_is_valid(lbl_is_collect) then
      if is_active == false then
        lbl_is_collect.BackImage = CARD_NO_COLLECTED
      else
        lbl_is_collect.BackImage = CARD_IS_COLLECTED
      end
    end
    local lbl_down = new_box:Find("btn_xiexia_weapon" .. nx_string(index))
    if nx_is_valid(lbl_down) then
      lbl_down.Visible = false
      if is_active == true then
        lbl_down.Visible = true
        nx_bind_script(lbl_down, nx_current())
        nx_callback(lbl_down, "on_click", "on_btn_card_down_click")
      end
    end
    local lbl_weapon_name = new_box:Find("lbl_weapon_name" .. nx_string(index))
    if nx_is_valid(lbl_weapon_name) then
      local item_config = get_ini_prop(CARD_FILL_PATH, card_id, "ConfigID", "0")
      local card_name = util_text("card_item_" .. nx_string(card_id))
      lbl_weapon_name.Text = card_name
    end
    local gui = nx_value("gui")
    local lbl_weapon_level = new_box:Find("lbl_weapon_level" .. nx_string(index))
    if nx_is_valid(lbl_weapon_level) then
      lbl_weapon_level.Text = nx_widestr(gui.TextManager:GetText("ui_card_level_" .. nx_string(level)))
    end
    local lbl_weapon_type = new_box:Find("lbl_weapon_type" .. nx_string(index))
    if nx_is_valid(lbl_weapon_type) then
      local type_name = gui.TextManager:GetFormatText("ui_card_" .. nx_string(main_type) .. "_" .. nx_string(sub_type))
      lbl_weapon_type.Text = nx_widestr(type_name)
    end
    local skill_grid_1 = new_box:Find("weapon_skill_1" .. nx_string(index))
    local skill_grid_2 = new_box:Find("weapon_skill_2" .. nx_string(index))
    if nx_is_valid(skill_grid_1) then
      skill_grid_1.Visible = false
    end
    if nx_is_valid(skill_grid_2) then
      skill_grid_2.Visible = false
    end
    if card_skill == "" then
      local weapon_skill_desc = new_box:Find("lbl_weapon_skill_desc" .. nx_string(index))
      if nx_is_valid(weapon_skill_desc) then
        weapon_skill_desc.Text = nx_widestr(gui.TextManager:GetFormatText("ui_attire_card_tips"))
      end
    else
      local skill_tmp_lst = util_split_string(card_skill, ",")
      local action_tmp_lst = util_split_string(card_action, ",")
      local action_count = table.getn(action_tmp_lst)
      for i = 1, table.getn(skill_tmp_lst) do
        local skill_grid = new_box:Find("weapon_skill_" .. nx_string(i) .. nx_string(index))
        if nx_is_valid(skill_grid) then
          skill_grid.Visible = true
          add_card_skill(skill_grid, skillini, skill_tmp_lst[i])
          nx_bind_script(skill_grid, nx_current())
          nx_callback(skill_grid, "on_mousein_grid", "on_grid_skill_mousein")
          nx_callback(skill_grid, "on_mouseout_grid", "on_grid_skill_mouseout")
          nx_callback(skill_grid, "on_select_changed", "on_grid_skill_select_changed")
          skill_grid.card_play_action = ""
          if i <= action_count then
            skill_grid.card_play_action = action_tmp_lst[i]
          end
        end
      end
    end
    local mltbox_weapon = new_box:Find("mltbox_weapon" .. nx_string(index))
    if nx_is_valid(mltbox_weapon) then
      mltbox_weapon:AddHtmlText(gui.TextManager:GetText("ui_card_desc_" .. nx_string(card_id)), nx_int(-1))
    end
    return new_box
  end
  return nil
end
function create_horse_box(form, index, card_id, level, main_type, sub_type, is_active)
  local new_box = create_groupbox(form, index, "groupbox_model_horse")
  if nx_is_valid(new_box) then
    set_copy_ent_info(form, "groupbox_model_horse", new_box)
    new_box.card_id = card_id
    local photo = nx_resource_path() .. inmage_path .. nx_string(card_id) .. ".png"
    local grid_back = new_box:Find("imagegrid_horse_back" .. nx_string(index))
    if nx_is_valid(grid_back) then
      grid_back:AddItem(0, photo, "", 1, -1)
      nx_bind_script(grid_back, nx_current())
      nx_callback(grid_back, "on_right_click", "on_grid_card_click")
      nx_callback(grid_back, "on_select_changed", "on_grid_card_click")
    end
    local lbl_is_collect = new_box:Find("lbl_horse_collect" .. nx_string(index))
    if nx_is_valid(lbl_is_collect) then
      if is_active == false then
        lbl_is_collect.BackImage = CARD_NO_COLLECTED
      else
        lbl_is_collect.BackImage = CARD_IS_COLLECTED
      end
    end
    local lbl_down = new_box:Find("btn_xiexia_horse" .. nx_string(index))
    if nx_is_valid(lbl_down) then
      lbl_down.Visible = false
      if is_active == true then
        lbl_down.Visible = true
        nx_bind_script(lbl_down, nx_current())
        nx_callback(lbl_down, "on_click", "on_btn_card_down_click")
      end
    end
    local lbl_horse_name = new_box:Find("lbl_horse_name" .. nx_string(index))
    if nx_is_valid(lbl_horse_name) then
      local item_config = get_ini_prop(CARD_FILL_PATH, card_id, "ConfigID", "0")
      local card_name = util_text("card_item_" .. nx_string(card_id))
      lbl_horse_name.Text = card_name
    end
    local gui = nx_value("gui")
    local lbl_horse_level = new_box:Find("lbl_horse_level" .. nx_string(index))
    if nx_is_valid(lbl_horse_level) then
      lbl_horse_level.Text = nx_widestr(gui.TextManager:GetText("ui_card_level_" .. nx_string(level)))
    end
    local lbl_horse_type = new_box:Find("lbl_horse_type" .. nx_string(index))
    if nx_is_valid(lbl_horse_type) then
      local type_name = gui.TextManager:GetFormatText("ui_card_" .. nx_string(main_type) .. "_" .. nx_string(sub_type))
      lbl_horse_type.Text = nx_widestr(type_name)
    end
    local mltbox_horse = new_box:Find("mltbox_horse" .. nx_string(index))
    if nx_is_valid(mltbox_horse) then
      mltbox_horse:AddHtmlText(gui.TextManager:GetText("ui_card_desc_" .. nx_string(card_id)), nx_int(-1))
    end
    return new_box
  end
  return nil
end
function create_treasure_box(form, index, card_id, level, main_type, sub_type, is_active)
  local new_box = create_groupbox(form, index, "groupbox_model_treasure")
  if nx_is_valid(new_box) then
    set_copy_ent_info(form, "groupbox_model_treasure", new_box)
    new_box.card_id = card_id
    local photo = nx_resource_path() .. inmage_path .. nx_string(card_id) .. ".png"
    local grid_back = new_box:Find("imagegrid_treasure_back" .. nx_string(index))
    if nx_is_valid(grid_back) then
      grid_back:AddItem(0, photo, "", 1, -1)
      nx_bind_script(grid_back, nx_current())
      nx_callback(grid_back, "on_right_click", "on_grid_card_click")
      nx_callback(grid_back, "on_select_changed", "on_grid_card_click")
    end
    local lbl_is_collect = new_box:Find("lbl_treasure_collect" .. nx_string(index))
    if nx_is_valid(lbl_is_collect) then
      if is_active == false then
        lbl_is_collect.BackImage = CARD_NO_COLLECTED
      else
        lbl_is_collect.BackImage = CARD_IS_COLLECTED
      end
    end
    local lbl_down = new_box:Find("btn_xiexia_treasure" .. nx_string(index))
    if nx_is_valid(lbl_down) then
      lbl_down.Visible = false
      if is_active == true then
        lbl_down.Visible = true
        nx_bind_script(lbl_down, nx_current())
        nx_callback(lbl_down, "on_click", "on_btn_card_down_click")
      end
    end
    local lbl_treasure_name = new_box:Find("lbl_treasure_name" .. nx_string(index))
    if nx_is_valid(lbl_treasure_name) then
      local item_config = get_ini_prop(CARD_FILL_PATH, card_id, "ConfigID", "0")
      local card_name = util_text("card_item_" .. nx_string(card_id))
      lbl_treasure_name.Text = card_name
    end
    local gui = nx_value("gui")
    local lbl_treasure_level = new_box:Find("lbl_treasure_level" .. nx_string(index))
    if nx_is_valid(lbl_treasure_level) then
      lbl_treasure_level.Text = nx_widestr(gui.TextManager:GetText("ui_card_level_" .. nx_string(level)))
    end
    local lbl_treasure_type = new_box:Find("lbl_treasure_type" .. nx_string(index))
    if nx_is_valid(lbl_treasure_type) then
      local type_name = gui.TextManager:GetFormatText("ui_card_" .. nx_string(main_type) .. "_" .. nx_string(sub_type))
      lbl_treasure_type.Text = nx_widestr(type_name)
    end
    local mltbox_treasure = new_box:Find("mltbox_treasure" .. nx_string(index))
    if nx_is_valid(mltbox_treasure) then
      mltbox_treasure:AddHtmlText(gui.TextManager:GetText("ui_card_desc_" .. nx_string(card_id)), nx_int(-1))
    end
    return new_box
  end
  return nil
end
function create_zaxiang_box(form, index, card_id, level, main_type, sub_type, is_active)
  local new_box = create_groupbox(form, index, "groupbox_model_zaxiang")
  if nx_is_valid(new_box) then
    set_copy_ent_info(form, "groupbox_model_zaxiang", new_box)
    new_box.card_id = card_id
    local photo = nx_resource_path() .. inmage_path .. nx_string(card_id) .. ".png"
    local grid_back = new_box:Find("imagegrid_zaxiang_back" .. nx_string(index))
    if nx_is_valid(grid_back) then
      grid_back:AddItem(0, photo, "", 1, -1)
      nx_bind_script(grid_back, nx_current())
      nx_callback(grid_back, "on_right_click", "on_grid_card_click")
      nx_callback(grid_back, "on_select_changed", "on_grid_card_click")
    end
    local lbl_is_collect = new_box:Find("lbl_zaxiang_collect" .. nx_string(index))
    if nx_is_valid(lbl_is_collect) then
      if is_active == false then
        lbl_is_collect.BackImage = CARD_NO_COLLECTED
      else
        lbl_is_collect.BackImage = CARD_IS_COLLECTED
      end
    end
    local lbl_down = new_box:Find("btn_xiexia_zaxiang" .. nx_string(index))
    if nx_is_valid(lbl_down) then
      lbl_down.Visible = false
      if is_active == true then
        lbl_down.Visible = true
        nx_bind_script(lbl_down, nx_current())
        nx_callback(lbl_down, "on_click", "on_btn_card_down_click")
      end
    end
    local lbl_zaxiang_name = new_box:Find("lbl_zaxiang_name" .. nx_string(index))
    if nx_is_valid(lbl_zaxiang_name) then
      local item_config = get_ini_prop(CARD_FILL_PATH, card_id, "ConfigID", "0")
      local card_name = util_text("card_item_" .. nx_string(card_id))
      lbl_zaxiang_name.Text = card_name
    end
    local gui = nx_value("gui")
    local lbl_zaxiang_level = new_box:Find("lbl_zaxiang_level" .. nx_string(index))
    if nx_is_valid(lbl_zaxiang_level) then
      lbl_zaxiang_level.Text = nx_widestr(gui.TextManager:GetText("ui_card_level_" .. nx_string(level)))
    end
    local lbl_zaxiang_type = new_box:Find("lbl_zaxiang_type" .. nx_string(index))
    if nx_is_valid(lbl_zaxiang_type) then
      local type_name = gui.TextManager:GetFormatText("ui_card_" .. nx_string(main_type) .. "_" .. nx_string(sub_type))
      lbl_zaxiang_type.Text = nx_widestr(type_name)
    end
    local mltbox_zaxiang = new_box:Find("mltbox_zaxiang" .. nx_string(index))
    if nx_is_valid(mltbox_zaxiang) then
      mltbox_zaxiang:AddHtmlText(gui.TextManager:GetText("ui_card_desc_" .. nx_string(card_id)), nx_int(-1))
    end
    return new_box
  end
  return nil
end
function reset_level_option(form)
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_js.Visible = true
  form.rbtn_js.Checked = false
  form.rbtn_cs.Visible = true
  form.rbtn_cs.Checked = false
  form.rbtn_zc.Visible = true
  form.rbtn_zc.Checked = false
  form.rbtn_had.Visible = true
  form.rbtn_had.Checked = false
  form.rbtn_all.Visible = true
  form.rbtn_all.Checked = true
  if nx_int(form.main_type) == nx_int(4) then
    form.rbtn_js.Visible = false
    form.rbtn_cs.Visible = false
    form.rbtn_zc.Visible = false
  end
end
function copy_scrollbar(richedit, tpl_richedit)
  if nx_is_valid(richedit.VScrollBar) and nx_is_valid(tpl_richedit.VScrollBar) then
    local vscrollbar = richedit.VScrollBar
    local tpl_vscrollbar = tpl_richedit.VScrollBar
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
end
function on_btn_card_down_click(btn)
  local form = btn.ParentForm
  local parent_grid = btn.Parent
  if not nx_find_custom(parent_grid, "card_id") then
    return
  end
  local card_id = parent_grid.card_id
  if nx_int(card_id) == nx_int(0) then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local bsucess = collect_card_manager:OnRebackCrad(nx_int(card_id))
  if bsucess == true then
  end
end
function on_btn_sex_click(btn)
  local main_form = nx_value("form_stage_main\\form_attire\\form_attire_main")
  if nx_is_valid(main_form) then
    main_form.is_equip_fwz_weapon = false
  end
  local res = nx_execute("form_stage_main\\form_attire\\form_attire_main", "on_btn_model_fwz_click")
  if res == true then
    local form = btn.ParentForm
    local form_main = nx_value("form_stage_main\\form_attire\\form_attire_main")
    if nx_is_valid(form_main) and nx_find_custom(form_main, "see_other") then
      local gui = nx_value("gui")
      if form_main.see_other == true then
        form.sex = get_sex_other()
        form.btn_sex.Text = gui.TextManager:GetText(TEXT_SEE_SELF)
      else
        form.sex = get_player_sex()
        form.btn_sex.Text = gui.TextManager:GetText(TEXT_SEE_OTHER)
      end
    end
    choose_card(form)
    get_uesd_card_list(form)
  end
end
function get_sex_other()
  local sex = get_player_sex()
  if sex == 1 then
    return 0
  end
  return 1
end
function ctr_sex_btn(show)
  local form = nx_value("form_stage_main\\form_attire\\form_attire_card")
  if nx_is_valid(form) then
    form.btn_sex.Visible = show
    local gui = nx_value("gui")
    form.btn_sex.Text = gui.TextManager:GetText(TEXT_SEE_OTHER)
    form.sex = get_player_sex()
    if show then
      choose_card(form)
      get_uesd_card_list(form)
    end
  end
end
