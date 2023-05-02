require("util_gui")
require("util_functions")
require("tips_data")
require("tips_game")
require("util_static_data")
local BOSS_DETAILED = "form_stage_main\\form_world_boss_detailed"
local BOSS_INI_PATH = "ini\\world_boss_info.ini"
local BOSS_SELECT_PNG = "gui\\special\\tiguan\\duihua_2.png"
local MAX_BOSS_COUNT = 4
local MAX_UNCOMMON_COUNT = 10
local MAX_COMMON_COUNT = 5
function on_main_form_init(form)
  form.Fixed = false
end
function load_set_info()
  local ini = get_ini(BOSS_INI_PATH)
  if not nx_is_valid(ini) then
    return
  end
  local set_info_list = get_global_arraylist("set_info_list")
  if not nx_is_valid(set_info_list) then
    return
  end
  set_info_list:ClearChild()
  local index = ini:FindSectionIndex("rbtn_set")
  if index < 0 then
    return
  end
  local rbtn_set = set_info_list:CreateChild("rbtn_set")
  local rbtn_set_count = ini:GetSectionItemCount(index)
  for i = 1, rbtn_set_count do
    local prop = ini:GetSectionItemKey(index, i - 1)
    local value = ini:GetSectionItemValue(index, i - 1)
    nx_set_custom(rbtn_set, prop, value)
  end
end
function on_main_form_open(form)
  load_set_info()
  change_form_size(form)
  refresh_main_rbtn(form)
end
function change_form_size(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function refresh_main_rbtn(form)
  local ini = get_ini(BOSS_INI_PATH)
  if not nx_is_valid(ini) then
    return
  end
  local groupbox = form.groupbox_rbtn
  groupbox:DeleteAll()
  load_main_rbtn(groupbox, ini, "root")
end
function load_main_rbtn(groupbox, ini, section)
  local index = ini:FindSectionIndex(section)
  if index < 0 then
    return
  end
  local rbtn_list = ini:GetItemValueList(index, "node")
  local rbtn_count = table.getn(rbtn_list)
  for i = 1, rbtn_count do
    local rbtn_remark = rbtn_list[i]
    local rbtn_text = "ui_" .. rbtn_remark
    local rbtn = groupbox:Find("rbtn_" .. rbtn_remark)
    if not nx_is_valid(rbtn) then
      rbtn = create_main_rbtn(groupbox, rbtn_remark)
      if nx_is_valid(rbtn) then
        rbtn.Left = rbtn.Width * (i - 1)
        rbtn.Text = util_text(rbtn_text)
        set_rbtn_info(ini, rbtn_remark, rbtn)
      end
    end
  end
  local child_list = groupbox:GetChildControlList()
  local child_count = table.getn(child_list)
  if child_count <= 0 then
    return
  end
  local rbtn_home = child_list[1]
  if not nx_is_valid(rbtn_home) then
    return
  end
  rbtn_home.Checked = true
end
function create_main_rbtn(groupbox, remark)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local rbtn = gui:Create("RadioButton")
  rbtn.Name = "rbtn_" .. remark
  set_node_prop(rbtn, "rbtn_set")
  nx_bind_script(rbtn, nx_current())
  nx_callback(rbtn, "on_checked_changed", "on_rbtn_checked_changed")
  groupbox:Add(rbtn)
  local child_list = groupbox:GetChildControlList()
  local child_count = table.getn(child_list)
  rbtn.Left = rbtn.Width * child_count
  return rbtn
end
function set_node_prop(node, props)
  local set_info_list = get_global_arraylist("set_info_list")
  if not nx_is_valid(set_info_list) then
    return
  end
  local set_info = set_info_list:GetChild(props)
  local custom_list = nx_custom_list(set_info)
  local custom_count = table.getn(custom_list)
  for i = 1, custom_count do
    local prop = custom_list[i]
    local value = nx_property(node, prop)
    local value_type = nx_type(value)
    value = nx_custom(set_info, prop)
    if "number" == value_type then
      nx_set_property(node, prop, nx_number(value))
    elseif "string" == value_type then
      nx_set_property(node, prop, value)
    elseif "boolean" == value_type then
      nx_set_property(node, prop, nx_boolean(value))
    end
  end
end
function set_rbtn_info(ini, props, rbtn)
  local index = ini:FindSectionIndex(props)
  if index < 0 then
    return
  end
  local node_list = ini:GetItemValueList(index, "node")
  local node_count = table.getn(node_list)
  local data_source = ""
  for i = 1, node_count do
    local node_remark = node_list[i]
    set_node_info(ini, node_remark)
    if i < node_count then
      data_source = data_source .. node_remark .. ","
    else
      data_source = data_source .. node_remark
    end
  end
  rbtn.DataSource = data_source
  rbtn.page_no = 0
end
function set_node_info(ini, props)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return
  end
  local set_info_list = get_global_arraylist("set_info_list")
  if not nx_is_valid(set_info_list) then
    return
  end
  local index = ini:FindSectionIndex(props)
  if index < 0 then
    return
  end
  local node_set = set_info_list:CreateChild(props)
  local node_set_count = ini:GetSectionItemCount(index)
  for i = 1, node_set_count do
    local prop = ini:GetSectionItemKey(index, i - 1)
    local value = ini:GetSectionItemValue(index, i - 1)
    if "uncommon" == prop or "common" == prop then
      local item_list = util_split_string(value, ",")
      local item_count = table.getn(item_list)
      local filter_value = ""
      for j = 1, item_count do
        local item_info = item_list[j]
        local item_info_list = util_split_string(item_info, "/")
        local item_info_list_count = table.getn(item_info_list)
        local item_id = ""
        local item_condition_id = 0
        if 2 <= item_info_list_count then
          item_id = item_info_list[1]
          item_condition_id = nx_number(item_info_list[2])
        elseif 0 < item_info_list_count then
          item_id = item_info_list[1]
        end
        local is_add = false
        if "" ~= item_id then
          if 0 < item_condition_id then
            if condition_manager:CanSatisfyCondition(client_player, client_player, item_condition_id) then
              is_add = true
            end
          elseif 0 == item_condition_id then
            is_add = true
          end
        end
        if is_add then
          if "" == filter_value then
            filter_value = item_id
          else
            filter_value = filter_value .. "," .. item_id
          end
        end
      end
      value = filter_value
    end
    nx_set_custom(node_set, prop, value)
  end
end
function get_node_prop(remark, prop)
  local set_info_list = get_global_arraylist("set_info_list")
  if not nx_is_valid(set_info_list) then
    return
  end
  local set_info = set_info_list:GetChild(remark)
  local custom_list = nx_custom_list(set_info)
  local custom_count = table.getn(custom_list)
  for i = 1, custom_count do
    local custom_prop = custom_list[i]
    if prop == custom_prop then
      local custom_value = nx_custom(set_info, custom_prop)
      return custom_value
    end
  end
end
function on_main_form_close(form)
  local detailed_form = util_get_form(BOSS_DETAILED, false)
  if not nx_is_valid(detailed_form) then
    local set_info_list = get_global_arraylist("set_info_list")
    if nx_is_valid(set_info_list) then
      nx_destroy(set_info_list)
    end
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  local data_source = nx_string(rbtn.DataSource)
  local node_list = util_split_string(data_source, ",")
  local node_count = table.getn(node_list)
  if node_count <= 0 then
    form.lbl_page.Text = nx_widestr("0/0")
    return
  end
  local node_page = nx_number(nx_int(node_count / MAX_BOSS_COUNT))
  local node_mod = node_count % MAX_BOSS_COUNT
  if 0 < node_mod then
    node_page = node_page + 1
  end
  local page_no = rbtn.page_no
  if page_no <= 0 then
    page_no = 1
  elseif node_page < page_no then
    page_no = node_page
  end
  rbtn.page_no = page_no
  form.lbl_page.Text = nx_widestr(page_no) .. nx_widestr("/") .. nx_widestr(node_page)
  form.lbl_page.DataSource = rbtn.Name
  for i = 1, MAX_BOSS_COUNT do
    local groupbox_image = form.groupbox_image:Find("groupbox_image_" .. nx_string(i))
    if nx_is_valid(groupbox_image) then
      groupbox_image.Visible = false
      groupbox_image.BackImage = ""
      local index = (page_no - 1) * MAX_BOSS_COUNT + i
      if node_count >= index then
        local lbl_image = groupbox_image:Find("lbl_image_" .. nx_string(i))
        local cbtn_image = groupbox_image:Find("cbtn_image_" .. nx_string(i))
        if nx_is_valid(lbl_image) and nx_is_valid(cbtn_image) then
          local remark = node_list[index]
          local image = get_node_prop(remark, "image1")
          lbl_image.BackImage = image
          cbtn_image.DataSource = remark
          groupbox_image.Visible = true
        end
      end
    end
  end
end
function on_btn_left_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local rbtn_name = nx_string(form.lbl_page.DataSource)
  local rbtn = form.groupbox_rbtn:Find(rbtn_name)
  if not nx_is_valid(rbtn) then
    return
  end
  local data_source = nx_string(btn.DataSource)
  if "0" == data_source then
    rbtn.page_no = rbtn.page_no - 1
  elseif "1" == data_source then
    rbtn.page_no = rbtn.page_no + 1
  end
  on_rbtn_checked_changed(rbtn)
end
function on_cbtn_image_checked_changed(cbtn)
  local remark = nx_string(cbtn.DataSource)
  if nil == remark or "" == remark then
    return
  end
  local detailed_form = util_get_form(BOSS_DETAILED, true)
  if not nx_is_valid(detailed_form) then
    return
  end
  get_node_info(detailed_form, remark)
  util_show_form(BOSS_DETAILED, true)
end
function on_cbtn_image_get_capture(cbtn)
  cbtn.Parent.BackImage = BOSS_SELECT_PNG
end
function on_cbtn_image_lost_capture(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local groupbox = form.groupbox_image
  for i = 1, MAX_BOSS_COUNT do
    local groupbox_image = groupbox:Find("groupbox_image_" .. nx_string(i))
    if nx_is_valid(groupbox_image) then
      groupbox_image.BackImage = ""
    end
  end
end
function get_node_info(form, remark)
  local set_info_list = get_global_arraylist("set_info_list")
  if not nx_is_valid(set_info_list) then
    return
  end
  local set_info = set_info_list:GetChild(remark)
  local custom_list = nx_custom_list(set_info)
  local custom_count = table.getn(custom_list)
  for i = 1, custom_count do
    local prop = custom_list[i]
    if "image2" == prop then
      local value = nx_custom(set_info, "image2")
      form.lbl_image.BackImage = value
    elseif "rule1" == prop then
      local value = nx_custom(set_info, "rule1")
      form.mltbox_1:Clear()
      form.mltbox_1:AddHtmlText(util_text(value), -1)
    elseif "rule2" == prop then
      local value = nx_custom(set_info, "rule2")
      form.mltbox_2:Clear()
      form.mltbox_2:AddHtmlText(util_text(value), -1)
    elseif "uncommon" == prop then
      local uncommon = nx_custom(set_info, "uncommon")
      local item_list = util_split_string(uncommon, ",")
      local item_count = table.getn(item_list)
      local lbl_page = form.lbl_uncommon_page
      if item_count <= 0 then
        lbl_page.Text = nx_widestr("0/0")
        return
      end
      local item_page = nx_number(nx_int(item_count / MAX_UNCOMMON_COUNT))
      local item_mod = item_count % MAX_UNCOMMON_COUNT
      if 0 < item_mod then
        item_page = item_page + 1
      end
      local page_no = 1
      lbl_page.page_no = page_no
      lbl_page.Text = nx_widestr(page_no) .. nx_widestr("/") .. nx_widestr(item_page)
      local image_grid = form.imagegrid_uncommon
      image_grid:Clear()
      for i = 1, MAX_UNCOMMON_COUNT do
        local index = (page_no - 1) * MAX_UNCOMMON_COUNT + i
        if item_count >= index then
          local item_id = item_list[index]
          local item_photo = get_item_info(item_id, "Photo")
          image_grid:AddItem(i - 1, item_photo, "", 1, -1)
        end
      end
    elseif "common" == prop then
      local common = nx_custom(set_info, "common")
      local item_list = util_split_string(common, ",")
      local item_count = table.getn(item_list)
      local lbl_page = form.lbl_common_page
      if item_count <= 0 then
        lbl_page.Text = nx_widestr("0/0")
        return
      end
      local item_page = nx_number(nx_int(item_count / MAX_COMMON_COUNT))
      local item_mod = item_count % MAX_COMMON_COUNT
      if 0 < item_mod then
        item_page = item_page + 1
      end
      local page_no = 1
      lbl_page.page_no = page_no
      lbl_page.Text = nx_widestr(page_no) .. nx_widestr("/") .. nx_widestr(item_page)
      local image_grid = form.imagegrid_common
      image_grid:Clear()
      for i = 1, MAX_COMMON_COUNT do
        local index = (page_no - 1) * MAX_COMMON_COUNT + i
        if item_count >= index then
          local item_id = item_list[index]
          local item_photo = get_item_info(item_id, "Photo")
          image_grid:AddItem(i - 1, item_photo, "", 1, -1)
        end
      end
    end
  end
  form.DataSource = remark
end
function get_node_info_item(form, remark, prop)
  local set_info_list = get_global_arraylist("set_info_list")
  if not nx_is_valid(set_info_list) then
    return
  end
  local set_info = set_info_list:GetChild(remark)
  if nx_find_custom(set_info, prop) then
    local value = nx_custom(set_info, prop)
    local item_list = util_split_string(value, ",")
    local item_count = table.getn(item_list)
    local lbl_page = nx_null()
    local MAX_ITEM_COUNT = 0
    if "uncommon" == prop then
      lbl_page = form.lbl_uncommon_page
      MAX_ITEM_COUNT = MAX_UNCOMMON_COUNT
    elseif "common" == prop then
      lbl_page = form.lbl_common_page
      MAX_ITEM_COUNT = MAX_COMMON_COUNT
    end
    if not nx_is_valid(lbl_page) then
      return
    end
    if item_count <= 0 then
      lbl_page.Text = nx_widestr("0/0")
      return
    end
    local item_page = nx_number(nx_int(item_count / MAX_ITEM_COUNT))
    local item_mod = item_count % MAX_ITEM_COUNT
    if 0 < item_mod then
      item_page = item_page + 1
    end
    if not nx_find_custom(lbl_page, "page_no") then
      return
    end
    local page_no = lbl_page.page_no
    if page_no <= 0 then
      page_no = 1
    elseif item_page < page_no then
      page_no = item_page
    end
    lbl_page.page_no = page_no
    lbl_page.Text = nx_widestr(page_no) .. nx_widestr("/") .. nx_widestr(item_page)
    local image_grid = nx_null()
    if "uncommon" == prop then
      image_grid = form.imagegrid_uncommon
    elseif "common" == prop then
      image_grid = form.imagegrid_common
    end
    if not nx_is_valid(image_grid) then
      return
    end
    image_grid:Clear()
    for i = 1, MAX_ITEM_COUNT do
      local index = (page_no - 1) * MAX_ITEM_COUNT + i
      if item_count >= index then
        local item_id = item_list[index]
        local item_photo = get_item_info(item_id, "Photo")
        image_grid:AddItem(i - 1, item_photo, "", 1, -1)
      end
    end
  end
end
function get_item_id(form, remark, prop, index)
  local set_info_list = get_global_arraylist("set_info_list")
  if not nx_is_valid(set_info_list) then
    return
  end
  local set_info = set_info_list:GetChild(remark)
  if nx_find_custom(set_info, prop) then
    local value = nx_custom(set_info, prop)
    local item_list = util_split_string(value, ",")
    local item_count = table.getn(item_list)
    local lbl_page = nx_null()
    local MAX_ITEM_COUNT = 0
    if "uncommon" == prop then
      lbl_page = form.lbl_uncommon_page
      MAX_ITEM_COUNT = MAX_UNCOMMON_COUNT
    elseif "common" == prop then
      lbl_page = form.lbl_common_page
      MAX_ITEM_COUNT = MAX_COMMON_COUNT
    end
    if not nx_is_valid(lbl_page) then
      return ""
    end
    if item_count <= 0 then
      return ""
    end
    local item_page = nx_number(nx_int(item_count / MAX_ITEM_COUNT))
    local item_mod = item_count % MAX_ITEM_COUNT
    if 0 < item_mod then
      item_page = item_page + 1
    end
    if not nx_find_custom(lbl_page, "page_no") then
      return ""
    end
    local page_no = lbl_page.page_no
    if page_no <= 0 then
      page_no = 1
    elseif item_page < page_no then
      page_no = item_page
    end
    local list_index = (page_no - 1) * MAX_ITEM_COUNT + index + 1
    if item_count >= list_index then
      local item_id = item_list[list_index]
      return item_id
    end
  end
  return ""
end
function get_item_info(item_id, prop)
  return item_query_ArtPack_by_id(item_id, prop)
end
function open_form()
  util_auto_show_hide_form(nx_current())
end
