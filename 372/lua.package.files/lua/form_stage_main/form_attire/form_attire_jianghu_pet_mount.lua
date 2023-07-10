require("util_gui")
require("util_static_data")
require("role_composite")
require("share\\static_data_type")
require("util_functions")
require("share\\view_define")
local FORM_PATH = "form_stage_main\\form_attire\\form_attire_jianghu_pet_mount"
local CARD_IS_COLLECTED = "gui\\special\\attire\\attire_back\\fwz_ysj.png"
local CARD_NO_COLLECTED = "gui\\special\\attire\\attire_back\\fwz_wsj.png"
local table_inis = {
  pet = "ini\\ui\\attire\\attire_pet.ini",
  mount = "ini\\ui\\attire\\attire_horsse.ini"
}
function form_open(form)
  data_bind_prop(form)
end
function on_main_form_init(self)
  self.horse_current_page = nx_int(1)
  self.pet_current_page = nx_int(1)
  self.pet_or_mount_page = nx_string("")
  self.is_items_select = nx_int(0)
  self.itemnpc_type = 1
  self.save_time = 0
end
function on_main_form_close(form)
  del_data_bind_prop(form)
  nx_destroy(form)
end
function show_shuzhuangtai_pet_mount(str_type)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local pack = {}
  local gui = nx_value("gui")
  form.groupbox_1:DeleteAll()
  form.is_items_select = nx_int(0)
  form.pet_or_mount_page = nx_string(str_type)
  if nx_ws_equal(nx_widestr(str_type), nx_widestr("pet")) then
    if form.rbtn_1.Checked then
      form.rbtn_9.Checked = true
    end
    pack = get_shuzhuangtai_config_list(nx_string(str_type))
    for i = 1 + 10 * (form.pet_current_page - 1), 10 * form.pet_current_page do
      if pack[i] ~= nil then
        page_index = i - 10 * (form.pet_current_page - 1)
        local formulacontrol = copy_formula_btns(form, form.groupbox_model_pet, page_index, pack[i])
        form.groupbox_1:Add(formulacontrol)
      end
    end
    local total_page_count = math.floor((table.getn(pack) - 1) / 10) + 1
    if nx_int(total_page_count) == nx_int(0) then
      form.pet_current_page = "0"
    end
    local page_text = nx_string(form.pet_current_page .. "/" .. total_page_count)
    form.lbl_12.Text = nx_widestr(page_text)
    form.rbtn_9.Text = gui.TextManager:GetFormatText("attire_sable_type")
    form.rbtn_1.Visible = false
    form.rbtn_10.Visible = true
  elseif nx_ws_equal(nx_widestr(str_type), nx_widestr("mount")) then
    if form.rbtn_10.Checked then
      form.rbtn_9.Checked = true
    end
    pack = get_shuzhuangtai_config_list(nx_string(str_type))
    for i = 1 + 10 * (form.horse_current_page - 1), 10 * form.horse_current_page do
      if pack[i] ~= "" and pack[i] ~= nil then
        page_index = i - 10 * (form.horse_current_page - 1)
        local formulacontrol = copy_formula_btns(form, form.groupbox_model_pet, page_index, pack[i])
        form.groupbox_1:Add(formulacontrol)
      end
    end
    local total_page_count = math.floor((table.getn(pack) - 1) / 10) + 1
    if nx_int(total_page_count) == nx_int(0) then
      form.horse_current_page = "0"
    end
    local page_text = nx_string(form.horse_current_page .. "/" .. total_page_count)
    form.lbl_12.Text = nx_widestr(page_text)
    form.rbtn_9.Text = gui.TextManager:GetFormatText("attire_mount_type")
    form.rbtn_1.Visible = true
    form.rbtn_10.Visible = false
  end
end
function get_shuzhuangtai_config_list(str_type)
  local pack = {}
  form = nx_value(FORM_PATH)
  if form.rbtn_9.Checked or form.rbtn_1.Checked then
    local ini = nx_execute("util_functions", "get_ini", nx_string(table_inis[nx_string(str_type)]))
    if not nx_is_valid(ini) then
      return {}
    end
    if str_type == "pet" then
      local section_index = ini:FindSectionIndex("pet")
      if section_index < 0 then
        return {}
      end
      local item_count = ini:GetSectionItemCount(section_index)
      for i = 0, item_count do
        local item = ini:GetSectionItemValue(section_index, i)
        local tmp_lst = util_split_string(item, ",")
        table.insert(pack, tmp_lst[1])
      end
    else
      local section_count = ini:GetSectionCount()
      for j = 0, section_count - 1 do
        local item_count = ini:GetSectionItemCount(j)
        for i = 0, item_count do
          local item = ini:GetSectionItemValue(j, i)
          local tmp_lst = util_split_string(item, ",")
          if nx_int(form.itemnpc_type) == nx_int(0) then
            table.insert(pack, tmp_lst[1])
          elseif nx_int(form.itemnpc_type) == nx_int(tmp_lst[2]) then
            table.insert(pack, tmp_lst[1])
          end
        end
      end
    end
  elseif form.rbtn_10.Checked then
    if nx_ws_equal(nx_widestr(str_type), nx_widestr("pet")) then
      pack = get_my_sable_list()
    elseif nx_ws_equal(nx_widestr(str_type), nx_widestr("mount")) then
    end
  end
  return pack
end
function copy_formula_btns(form, btn_info, index, config)
  local gui = nx_value("gui")
  local ItemsQuery = nx_value("ItemQuery")
  if not nx_is_valid(form) then
    return false
  end
  if not nx_is_valid(gui) then
    return false
  end
  if not nx_is_valid(btn_info) then
    return false
  end
  local control = gui.Designer:Clone(btn_info)
  if not nx_is_valid(control) then
    return false
  end
  control.DesignMode = false
  local child_list = btn_info:GetChildControlList()
  if table.getn(child_list) == nx_int(0) then
    return false
  end
  local script = ItemsQuery:GetItemPropByConfigID(config, "script")
  local item_type = ItemsQuery:GetItemPropByConfigID(config, "ItemType")
  for _, copy_child in pairs(child_list) do
    if not nx_is_valid(copy_child) then
      return false
    end
    local child = gui.Designer:Clone(copy_child)
    child.DesignMode = false
    if nx_string(child.Name) == "imagegrid_2" then
      child.Name = "pet_info_imagegrid_" .. nx_string(index)
      local photo = ""
      if nx_string(script) == nx_string("Mount") then
        photo = item_query_ArtPack_by_id_Ex(nx_string(config), "Photo")
      elseif nx_string(script) == nx_string("Sable") then
        photo = item_query_ArtPack_by_id(nx_string(config), "Photo")
      end
      child:AddItem(0, photo, util_text(config), 1, -1)
      child.photo = photo
      child.config = config
      child.item_type = item_type
      nx_bind_script(child, nx_current())
      nx_callback(child, "on_mousein_grid", "img_grid_mousein_grid")
      nx_callback(child, "on_mouseout_grid", "img_grid_mouseout_grid")
      nx_callback(child, "on_select_changed", "on_main_shortcut_lmouse_click")
      if nx_int(form.is_items_select) == nx_int(0) then
        nx_execute("form_stage_main\\form_attire\\form_attire_jianghu", "use_arrire_item", config, item_type, photo)
        form.is_items_select = 1
      end
    elseif nx_string(child.Name) == "lbl_name" then
      child.Name = "pet_info_lbl_name_" .. nx_string(index)
      szMountName = gui.TextManager:GetFormatText(config)
      child.Text = util_text(nx_string(szMountName))
    elseif nx_string(child.Name) == "lbl_type" then
      child.Name = "pet_info_lbl_describe_" .. nx_string(index)
      if nx_string(script) == nx_string("Mount") then
        local mount_type = ItemsQuery:GetItemPropByConfigID(config, "MountType")
        local txt_name = "attire_type_mount"
        if nx_int(mount_type) == nx_int(5) then
          txt_name = "attire_type_zaiju"
        end
        child.Text = gui.TextManager:GetFormatText(nx_string(txt_name))
      elseif nx_string(script) == nx_string("Sable") then
        local sable_type = ItemsQuery:GetItemPropByConfigID(config, "SableType")
        local txt_name = "attire_type_sable"
        if nx_int(sable_type) > nx_int(0) then
          txt_name = "attire_type_new_sable"
        end
        child.Text = gui.TextManager:GetFormatText(nx_string(txt_name))
      end
    elseif nx_string(child.Name) == "lbl_11" then
      if nx_ws_equal(nx_widestr(form.pet_or_mount_page), nx_widestr("mount")) then
        child.Visible = false
      elseif nx_ws_equal(nx_widestr(form.pet_or_mount_page), nx_widestr("pet")) then
        if check_is_sable_had(config) then
          child.BackImage = CARD_IS_COLLECTED
        else
          child.BackImage = CARD_NO_COLLECTED
        end
      end
      child.Name = "pet_info_lbl_is_had_" .. nx_string(index)
    elseif nx_string(child.Name) == "btn_huoqu_1" then
      child.Name = "pet_info_btn_get_method_" .. nx_string(index)
    elseif nx_string(child.Name) == "imagegrid_8" then
      child.Name = "pet_info_imagegrid_skill_1_" .. nx_string(index)
      gui:Delete(child)
    elseif nx_string(child.Name) == "imagegrid_9" then
      child.Name = "pet_info_imagegrid_skill_2_" .. nx_string(index)
      gui:Delete(child)
    elseif nx_string(child.Name) == "imagegrid_10" then
      child.Name = "pet_info_imagegrid_skill_3_" .. nx_string(index)
      gui:Delete(child)
    elseif nx_string(child.Name) == "imagegrid_11" then
      child.Name = "pet_info_imagegrid_skill_4_" .. nx_string(index)
      gui:Delete(child)
    end
    control:Add(child)
  end
  control.Name = "groupbox_model_pet_" .. nx_string(index)
  control.Left = math.floor((index - 1) % 2) * control.Width
  control.Top = math.floor((index - 1) / 2) * (control.Height - 8)
  return control
end
function on_btn_right_click(btn)
  form = btn.ParentForm
  local gui = nx_value("gui")
  local pack = {}
  local cur_page = 1
  pack = get_shuzhuangtai_config_list(form.pet_or_mount_page)
  if nx_ws_equal(nx_widestr(form.pet_or_mount_page), nx_widestr("mount")) then
    cur_page = nx_int(form.horse_current_page)
  elseif nx_ws_equal(nx_widestr(form.pet_or_mount_page), nx_widestr("pet")) then
    cur_page = nx_int(form.pet_current_page)
  end
  local max_page = math.floor((table.getn(pack) - 1) / 10) + 1
  if nx_number(cur_page) < nx_number(max_page) then
    cur_page = cur_page + 1
    form.groupbox_1:DeleteAll()
    for i = 1 + 10 * (cur_page - 1), 10 * cur_page do
      if pack[i] ~= "" and pack[i] ~= nil then
        index = i - 10 * (cur_page - 1)
        local formulacontrol = copy_formula_btns(form, form.groupbox_model_pet, index, pack[i])
        form.groupbox_1:Add(formulacontrol)
      end
    end
    if nx_ws_equal(nx_widestr(form.pet_or_mount_page), nx_widestr("mount")) then
      form.horse_current_page = cur_page
    elseif nx_ws_equal(nx_widestr(form.pet_or_mount_page), nx_widestr("pet")) then
      form.pet_current_page = cur_page
    end
    local page_text = nx_string(cur_page .. "/" .. max_page)
    form.lbl_12.Text = nx_widestr(page_text)
  end
end
function on_btn_left_click(btn)
  form = btn.ParentForm
  local gui = nx_value("gui")
  local pack = {}
  local cur_page = 1
  pack = get_shuzhuangtai_config_list(form.pet_or_mount_page)
  if nx_ws_equal(nx_widestr(form.pet_or_mount_page), nx_widestr("mount")) then
    cur_page = nx_int(form.horse_current_page)
  elseif nx_ws_equal(nx_widestr(form.pet_or_mount_page), nx_widestr("pet")) then
    cur_page = nx_int(form.pet_current_page)
  end
  local max_page = math.floor((table.getn(pack) - 1) / 10) + 1
  if 1 < nx_number(cur_page) then
    cur_page = nx_int(cur_page) - 1
    form.groupbox_1:DeleteAll()
    for i = 1 + 10 * (cur_page - 1), 10 * cur_page do
      if pack[i] ~= "" and pack[i] ~= nil then
        index = i - 10 * (cur_page - 1)
        local formulacontrol = copy_formula_btns(form, form.groupbox_model_pet, index, pack[i])
        form.groupbox_1:Add(formulacontrol)
      end
    end
    if nx_ws_equal(nx_widestr(form.pet_or_mount_page), nx_widestr("mount")) then
      form.horse_current_page = cur_page
    elseif nx_ws_equal(nx_widestr(form.pet_or_mount_page), nx_widestr("pet")) then
      form.pet_current_page = cur_page
    end
    local page_text = nx_string(cur_page .. "/" .. max_page)
    form.lbl_12.Text = nx_widestr(page_text)
  end
end
function get_my_sable_list()
  local pack = {}
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return pack
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return pack
  end
  if not client_player:FindRecord("sable_rec") then
    return pack
  end
  local nRows = client_player:GetRecordRows("sable_rec")
  for i = 0, nRows - 1 do
    local config_id = client_player:QueryRecord("sable_rec", i, 3)
    table.insert(pack, config_id)
  end
  return pack
end
function check_is_sable_had(config)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindRecord("sable_rec") then
    return
  end
  local nRows = client_player:GetRecordRows("sable_rec")
  for i = 0, nRows - 1 do
    local config_id = client_player:QueryRecord("sable_rec", i, 3)
    if nx_ws_equal(nx_widestr(config), nx_widestr(config_id)) then
      return true
    end
  end
  return false
end
function check_is_mount_had(config)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindRecord("sable_rec") then
    return
  end
  local nRows = client_player:GetRecordRows("sable_rec")
  for i = 0, nRows - 1 do
    local config_id = client_player:QueryRecord("sable_rec", i, 3)
    if nx_ws_equal(nx_widestr(config), nx_widestr(config_id)) then
      return true
    end
  end
  return false
end
function show_shuzhuangtai_change_all_click(btn)
  form = nx_value(FORM_PATH)
  form.horse_current_page = nx_int("1")
  form.pet_current_page = nx_int("1")
  if btn.Checked then
    nx_pause(0.2)
    form.itemnpc_type = btn.TabIndex
    show_shuzhuangtai_pet_mount(form.pet_or_mount_page)
  end
end
function show_shuzhuangtai_change_had_click(btn)
  form = nx_value(FORM_PATH)
  form.horse_current_page = nx_int("1")
  form.pet_current_page = nx_int("1")
  if btn.Checked then
    nx_pause(0.2)
    show_shuzhuangtai_pet_mount(form.pet_or_mount_page)
  end
end
function on_main_shortcut_lmouse_click(btn)
  form = nx_value(FORM_PATH)
  local new_time = nx_function("ext_get_tickcount")
  if new_time - form.save_time < 1500 then
    return
  end
  form.save_time = new_time
  nx_execute("form_stage_main\\form_attire\\form_attire_jianghu", "use_arrire_item", btn.config, btn.item_type, btn.photo)
end
function img_grid_mouseout_grid(grid)
  nx_execute("tips_game", "hide_tip")
end
function img_grid_mousein_grid(grid)
  local config_id = grid.config
  nx_execute("tips_game", "show_tips_by_config", config_id, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function data_bind_prop(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("sable_rec", form, nx_current(), "on_table_operat")
  end
end
function del_data_bind_prop(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("sable_rec", form)
  end
end
function on_table_operat(form, tablename, ttype, line, col)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  if not nx_ws_equal(nx_widestr(form.pet_or_mount_page), nx_widestr("pet")) then
    return
  end
  refresh_grid(form)
end
function refresh_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local pack = {}
  pack = get_shuzhuangtai_config_list(form.pet_or_mount_page)
  cur_page = nx_int(form.pet_current_page)
  if nx_int(cur_page) <= nx_int(0) and nx_int(table.getn(pack)) > nx_int(0) then
    cur_page = 1
  end
  form.groupbox_1:DeleteAll()
  local max_page = math.floor((table.getn(pack) - 1) / 10) + 1
  if nx_number(cur_page) <= nx_number(max_page) then
    for i = 1 + 10 * (cur_page - 1), 10 * cur_page do
      if pack[i] ~= "" and pack[i] ~= nil then
        index = i - 10 * (cur_page - 1)
        local formulacontrol = copy_formula_btns(form, form.groupbox_model_pet, index, pack[i])
        form.groupbox_1:Add(formulacontrol)
      end
    end
    local page_text = nx_string(nx_string(cur_page) .. "/" .. nx_string(max_page))
    form.lbl_12.Text = nx_widestr(page_text)
  end
end
