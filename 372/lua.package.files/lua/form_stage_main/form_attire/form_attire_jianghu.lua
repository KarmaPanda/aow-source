require("util_gui")
require("util_static_data")
require("role_composite")
require("share\\static_data_type")
require("util_functions")
require("share\\view_define")
local ITEMTYPE_MOUNT = 200
local ITEMTYPE_PET_ANIMAL = 222
local ITEMTYPE_HUANPIHEAD = 601
local ITEMTYPE_HUANPICLOTH = 602
local ITEMTYPE_HUANPIPANTS = 603
local ITEMTYPE_HUANPISHOES = 604
local FORM_PATH = "form_stage_main\\form_attire\\form_attire_jianghu"
local SHOW_TYPE_PLAYER = 1
local SHOW_TYPE_MOUNT_PET = 2
local ITEMTYPE_EQUIP_HAT = 140
local ITEMTYPE_EQUIP_CLOTH = 141
local ITEMTYPE_EQUIP_PANTS = 142
local ITEMTYPE_EQUIP_SHOES = 143
local FACE_IMAGE_ON = "gui\\language\\ChineseS\\create\\creat_new\\srxm_down_3.png"
local FACE_IMAGE_DOWN = "gui\\language\\ChineseS\\create\\creat_new\\srxm_on_3.png"
local FACE_IMAGE_OUT = "gui\\language\\ChineseS\\create\\creat_new\\srxm_out_3.png"
local NOR_IMAGE_ON = "gui\\special\\attire\\attire_btn\\btn_save_3_on.png"
local NOR_IMAGE_DOWN = "gui\\special\\attire\\attire_btn\\btn_save_3_down.png"
local NOR_IMAGE_OUT = "gui\\special\\attire\\attire_btn\\btn_save_3_out.png"
local SHOW_EQUIP_TYPE = {
  "140",
  "141",
  "142",
  "143"
}
local SHOW_DRAW_TYPE = {
  "hat",
  "cloth",
  "pants",
  "shoes"
}
local FORM_FACE = "form_stage_create\\form_create_on"
local FORM_SAVE = "form_stage_main\\form_attire\\form_attire_save"
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
local SUB_FORM = {
  "form_stage_main\\form_attire\\form_attire_jianghu_suit",
  "form_stage_main\\form_attire\\form_attire_jianghu_item",
  "form_stage_main\\form_attire\\form_attire_jianghu_pet_mount",
  "form_stage_create\\form_create_on"
}
function on_main_form_init(self)
  self.Fixed = true
  self.show_model_type = SHOW_TYPE_PLAYER
end
function on_main_form_open(form)
  form.rbtn_taozhuang.Checked = true
  form.groupbox_bag.Visible = false
  init_show_equip(form)
end
function refresh_form_change()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form.rbtn_taozhuang.Checked = true
    form.groupbox_bag.Visible = false
    init_show_equip(form)
  end
end
function open_sub_form_by_tab_index(index)
  local form = nx_value(nx_current())
  hide_sub_form_all()
  local form_path = SUB_FORM[index]
  if form_path == "" or form_path == nil then
    return nil
  end
  local sub_form = nx_value(form_path)
  if nx_is_valid(sub_form) then
    sub_form.Visible = true
    sub_form:Show()
  else
    local create_sub_form = nx_execute("util_gui", "util_get_form", form_path, true, false)
    local is_load = form.groupbox_content:Add(create_sub_form)
    if is_load == true then
      create_sub_form.Left = 1
      create_sub_form.Top = 0
      sub_form = create_sub_form
    end
  end
  return sub_form
end
function hide_sub_form_all()
  local count = table.getn(SUB_FORM)
  for i = 1, count do
    local sub_form = nx_value(SUB_FORM[i])
    if nx_is_valid(sub_form) then
      sub_form.Visible = false
    end
  end
end
function on_main_form_close(form)
  local count = table.getn(SUB_FORM)
  for i = 1, count do
    local sub_form = nx_value(SUB_FORM[i])
    if nx_is_valid(sub_form) then
      sub_form:Close()
    end
  end
  local form_face = nx_value(FORM_FACE)
  if nx_is_valid(form_face) then
    form_face:Close()
  end
  local form_save = nx_value(FORM_SAVE)
  if nx_is_valid(form_save) then
    form_save:Close()
  end
  nx_destroy(form)
end
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local attire_type = rbtn.DataSource
  if rbtn.Checked then
    refresh_form_by_type(attire_type)
    on_set_back_img(attire_type)
    local tab_index = rbtn.TabIndex
    if attire_type == "suit" then
      local sub_form = open_sub_form_by_tab_index(tab_index)
      if sub_form == nil then
        return
      end
      sub_form.cur_page = 0
      refresh_create_player_or_npc(SHOW_TYPE_PLAYER)
      nx_execute("form_stage_main\\form_attire\\form_attire_jianghu_suit", "show_suit_info", sub_form)
      nx_execute("form_stage_main\\form_attire\\form_attire_main", "set_camera_direct", 2)
    elseif attire_type == "hat" or attire_type == "cloth" or attire_type == "pants" or attire_type == "shoes" then
      local sub_form = open_sub_form_by_tab_index(tab_index)
      if sub_form == nil then
        return
      end
      sub_form.show_type = attire_type
      sub_form.cur_page = 0
      refresh_create_player_or_npc(SHOW_TYPE_PLAYER)
      nx_execute("form_stage_main\\form_attire\\form_attire_jianghu_item", "show_attire_item_info", sub_form)
      nx_execute("form_stage_main\\form_attire\\form_attire_main", "set_camera_direct", 2)
    elseif attire_type == "pet" or attire_type == "mount" then
      local sub_form = open_sub_form_by_tab_index(tab_index)
      if sub_form == nil then
        return
      end
      nx_execute("form_stage_main\\form_attire\\form_attire_jianghu_pet_mount", "show_shuzhuangtai_pet_mount", attire_type)
    elseif attire_type == "face" then
      on_rbtn_face_checked(rbtn)
    end
  end
end
function refresh_create_player_or_npc(show_type)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local old_show_type = form.show_model_type
  if nx_int(show_type) == nx_int(SHOW_TYPE_PLAYER) and nx_int(old_show_type) ~= nx_int(show_type) then
    reset_attire_change()
  end
  form.show_model_type = show_type
end
function refresh_form_by_type(attire_type)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form.btn_2.NormalImage = NOR_IMAGE_OUT
  form.btn_2.FocusImage = NOR_IMAGE_ON
  form.btn_2.PushImage = NOR_IMAGE_DOWN
  if attire_type == "pet" or attire_type == "mount" then
    form.groupbox_1.Visible = false
    if attire_type == "pet" then
      form.groupbox_pet.Visible = true
    else
      form.groupbox_pet.Visible = false
    end
  elseif attire_type == "face" then
    form.groupbox_1.Visible = true
    form.groupbox_pre.Visible = false
    form.imagegrid_equip.Visible = false
    form.groupbox_bag.Visible = false
    form.groupbox_pet.Visible = false
    form.groupbox_btn.Visible = true
    form.btn_reset.Visible = false
    form.lbl_3.Visible = false
    form.lbl_4.Visible = false
    form.btn_2.NormalImage = FACE_IMAGE_OUT
    form.btn_2.FocusImage = FACE_IMAGE_ON
    form.btn_2.PushImage = FACE_IMAGE_DOWN
  else
    form.groupbox_1.Visible = true
    form.groupbox_btn.Visible = true
    form.groupbox_pre.Visible = true
    form.imagegrid_equip.Visible = true
    form.groupbox_pet.Visible = false
    form.btn_reset.Visible = true
    form.lbl_3.Visible = true
    form.lbl_4.Visible = true
  end
end
function on_set_back_img(attire_type)
  if attire_type == "pet" then
    nx_execute("form_stage_main\\form_attire\\form_attire_main", "set_form_main_backimg", 3)
  elseif attire_type == "mount" then
    nx_execute("form_stage_main\\form_attire\\form_attire_main", "set_form_main_backimg", 2)
  else
    nx_execute("form_stage_main\\form_attire\\form_attire_main", "set_form_main_backimg", 1)
  end
end
function use_arrire_item(config_id, item_type, photo, model)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return false
  end
  if nx_int(item_type) == nx_int(ITEMTYPE_HUANPIHEAD) then
    form.imagegrid_draw_item:AddItem(0, photo, nx_widestr(config_id), 1, -1)
    if not attire_manager:AttireItemActive(config_id) then
      form.imagegrid_draw_item:CoverItem(0, true)
      form.imagegrid_draw_item:SetItemCoverImage(0, "gui\\special\\attire\\attire_back\\k03.png")
    else
      form.imagegrid_draw_item:CoverItem(0, false)
    end
    nx_execute("form_stage_main\\form_attire\\form_attire_main", "player_link_equip", "hat", model)
  elseif nx_int(item_type) == nx_int(ITEMTYPE_HUANPICLOTH) then
    form.imagegrid_draw_item:AddItem(1, photo, nx_widestr(config_id), 1, -1)
    if not attire_manager:AttireItemActive(config_id) then
      form.imagegrid_draw_item:CoverItem(1, true)
      form.imagegrid_draw_item:SetItemCoverImage(1, "gui\\special\\attire\\attire_back\\k03.png")
    else
      form.imagegrid_draw_item:CoverItem(1, false)
    end
    play_action_by_sex()
    nx_execute("form_stage_main\\form_attire\\form_attire_main", "player_link_equip", "cloth", model)
  elseif nx_int(item_type) == nx_int(ITEMTYPE_HUANPIPANTS) then
    form.imagegrid_draw_item:AddItem(2, photo, nx_widestr(config_id), 1, -1)
    if not attire_manager:AttireItemActive(config_id) then
      form.imagegrid_draw_item:CoverItem(2, true)
      form.imagegrid_draw_item:SetItemCoverImage(2, "gui\\special\\attire\\attire_back\\k03.png")
    else
      form.imagegrid_draw_item:CoverItem(2, false)
    end
    nx_execute("form_stage_main\\form_attire\\form_attire_main", "player_link_equip", "pants", model)
  elseif nx_int(item_type) == nx_int(ITEMTYPE_HUANPISHOES) then
    form.imagegrid_draw_item:AddItem(3, photo, nx_widestr(config_id), 1, -1)
    if not attire_manager:AttireItemActive(config_id) then
      form.imagegrid_draw_item:CoverItem(3, true)
      form.imagegrid_draw_item:SetItemCoverImage(3, "gui\\special\\attire\\attire_back\\k03.png")
    else
      form.imagegrid_draw_item:CoverItem(3, false)
    end
    nx_execute("form_stage_main\\form_attire\\form_attire_main", "player_link_equip", "shoes", model)
  elseif nx_int(item_type) == nx_int(ITEMTYPE_MOUNT) then
    refresh_create_player_or_npc(SHOW_TYPE_MOUNT_PET)
    nx_execute("form_stage_main\\form_attire\\form_attire_main", "create_scene_box_npc", config_id, 2)
  elseif nx_int(item_type) == nx_int(ITEMTYPE_PET_ANIMAL) then
    refresh_create_player_or_npc(SHOW_TYPE_MOUNT_PET)
    nx_execute("form_stage_main\\form_attire\\form_attire_main", "create_scene_box_npc", config_id, 3)
    refresh_attire_pet_skill(form, config_id)
  end
end
function reset_attire_change()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form.imagegrid_draw_item:Clear()
  form.groupbox_bag.Visible = false
  init_show_equip(form)
  nx_execute("form_stage_main\\form_attire\\form_attire_main", "create_jh_player")
end
function on_btn_reset_click(btn)
  reset_attire_change()
end
function on_imagegrid_rightclick_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.imagegrid_draw_item:IsEmpty(index) then
    return
  end
  form.imagegrid_draw_item:DelItem(index)
  form.imagegrid_draw_item:CoverItem(index, false)
  local link_pos = SHOW_DRAW_TYPE[index + 1]
  nx_execute("form_stage_main\\form_attire\\form_attire_main", "player_unlink_equip", link_pos)
end
function on_rbtn_face_checked(rbtn)
  if rbtn.Checked ~= true then
    return
  end
  hide_sub_form_all()
  nx_execute("form_stage_main\\form_attire\\form_attire_main", "create_jh_player")
  local form_main = nx_value("form_stage_main\\form_attire\\form_attire_main")
  if not nx_is_valid(form_main) then
    return
  end
  if not nx_find_custom(form_main, "role_model") then
    return
  end
  if not nx_is_valid(form_main.role_model) then
    return
  end
  if not nx_find_custom(form_main.role_model, "model_type") then
    return
  end
  local model_type = form_main.role_model.model_type
  if nx_int(model_type) ~= nx_int(1) then
    return
  end
  nx_execute("form_stage_main\\form_attire\\form_attire_main", "set_camera_direct", 1)
  local form = rbtn.ParentForm
  local form_face = nx_value(FORM_FACE)
  if nx_is_valid(form_face) then
    nx_execute(FORM_FACE, "reset_face", form_face, form_main.role_model)
    return
  end
  form_face = nx_execute("util_gui", "util_get_form", FORM_FACE, true, false)
  if not nx_is_valid(form_face) then
    return
  end
  form_face.role_actor2 = form_main.role_model
  form_face.Left = 0
  form_face.Top = 0
  form.groupbox_content:Add(form_face)
  form_face.Visible = true
end
function refresh_show_model()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
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
function refresh_show_equip(type)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_palyer = game_client:GetPlayer()
  if not nx_is_valid(client_palyer) then
    return
  end
  local player_sex = client_palyer:QueryProp("Sex")
  local equip_view = game_client:GetView(nx_string(VIEWPORT_EQUIP_TOOL))
  if not nx_is_valid(equip_view) then
    return nil
  end
  form.imagegrid_bag:Clear()
  local find_type = ITEMTYPE_EQUIP_HAT + type
  local count = equip_view:GetViewObjCount()
  local grid_index = 0
  for i = 1, count do
    local obj = equip_view:GetViewObjByIndex(i - 1)
    local config_id = obj:QueryProp("ConfigID")
    local item_type = obj:QueryProp("ItemType")
    local needsex = obj:QueryProp("NeedSex")
    local bCanUse = true
    if nx_int(needsex) <= nx_int(1) and nx_int(needsex) ~= nx_int(player_sex) then
      bCanUse = false
    end
    if bCanUse and nx_string(config_id) ~= nx_string("") and nx_int(find_type) == nx_int(item_type) then
      local photo = nx_execute("util_static_data", "queryprop_by_object", obj, "Photo")
      local uid = obj:QueryProp("UniqueID")
      local info = nx_string(config_id) .. "," .. nx_string(uid)
      form.imagegrid_bag:AddItem(grid_index, photo, nx_widestr(info), 1, -1)
      nx_set_custom(form.imagegrid_bag, "bag_" .. nx_string(grid_index), obj)
      grid_index = grid_index + 1
    end
  end
end
function on_imagegrid_bag_mousein_grid(grid, index)
  local info = grid:GetItemName(index)
  if nx_string(info) == nx_string("") then
    return
  end
  local custom_name = "bag_" .. index
  if nx_find_custom(grid, custom_name) then
    local obj = nx_custom(grid, custom_name)
    if nx_is_valid(obj) then
      nx_execute("tips_game", "show_goods_tip", obj, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm, false)
    end
  end
end
function on_imagegrid_bag_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_draw_item_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local config_id = grid:GetItemName(index)
  local pos = SHOW_DRAW_TYPE[index + 1]
  local gui = nx_value("gui")
  if nx_string(config_id) == nx_string("") then
    nx_execute("tips_game", "show_text_tip", gui.TextManager:GetText("ui_attire_tuzhi_" .. nx_string(pos)), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 0, form)
    return
  end
  nx_execute("tips_game", "show_tips_by_config", nx_string(config_id), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_imagegrid_draw_item_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_equip_select_changed(grid, index)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_bag.Visible = true
  refresh_show_equip(index)
end
function on_imagegrid_bag_select_changed(grid, index)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return ""
  end
  form.groupbox_bag.Visible = false
  local info = grid:GetItemName(index)
  if nx_string(info) == nx_string("") then
    return
  end
  local info_list = util_split_wstring(info, ",")
  local config_id = info_list[1]
  if nx_string(config_id) == nx_string("") then
    return
  end
  local item_type = item_query:GetItemPropByConfigID(nx_string(config_id), nx_string("ItemType"))
  local photo = grid:GetItemImage(index)
  local grid_index = nx_int(item_type - ITEMTYPE_EQUIP_HAT)
  form.imagegrid_equip:AddItem(grid_index, photo, nx_widestr(info), 1, -1)
  local custom_name = "bag_" .. index
  if nx_find_custom(grid, custom_name) then
    local obj = nx_custom(grid, custom_name)
    if nx_is_valid(obj) then
      nx_set_custom(form.imagegrid_equip, "equip_" .. nx_string(grid_index), obj)
    end
  end
end
function on_imagegrid_equip_rightclick_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.imagegrid_equip:IsEmpty(index) then
    return
  end
  form.imagegrid_equip:DelItem(index)
end
function on_btn_hide_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_bag.Visible = false
end
function init_show_equip(form)
  local game_client = nx_value("game_client")
  local equip_view = game_client:GetView(nx_string(VIEWPORT_EQUIP))
  if not nx_is_valid(equip_view) then
    return nil
  end
  form.imagegrid_equip:Clear()
  local count = equip_view:GetViewObjCount()
  for i = 1, count do
    local obj = equip_view:GetViewObjByIndex(i - 1)
    local config_id = obj:QueryProp("ConfigID")
    local item_type = obj:QueryProp("ItemType")
    if nx_string(config_id) ~= nx_string("") and not IsFashionOrSuit(obj) and is_show_equip_type(item_type) then
      local grid_index = nx_int(item_type - ITEMTYPE_EQUIP_HAT)
      local photo = nx_execute("util_static_data", "queryprop_by_object", obj, "Photo")
      local uid = obj:QueryProp("UniqueID")
      local info = nx_string(config_id) .. "," .. nx_string(uid)
      form.imagegrid_equip:AddItem(grid_index, photo, nx_widestr(info), 1, -1)
      nx_set_custom(form.imagegrid_equip, "equip_" .. nx_string(grid_index), obj)
    end
  end
end
function is_show_equip_type(item_type)
  local count = table.getn(SHOW_EQUIP_TYPE)
  for i = 1, count do
    local type = nx_int(SHOW_EQUIP_TYPE[i])
    if nx_int(type) == nx_int(item_type) then
      return true
    end
  end
  return false
end
function IsFashionOrSuit(item)
  if not nx_is_valid(item) then
    return false
  end
  if not item:FindProp("EquipType") then
    return false
  end
  local equip_type = item:QueryProp("EquipType")
  if nx_string(equip_type) == nx_string("Suit") or nx_string(equip_type) == nx_string("FashionHat") or nx_string(equip_type) == nx_string("FashionCoat") or nx_string(equip_type) == nx_string("FashionShoes") then
    return true
  end
  return false
end
function refresh_attire_pet_skill(form, config_id)
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  local skill_query = nx_value("SkillQuery")
  if not nx_is_valid(skill_query) then
    return
  end
  local pet_skill_info = item_query:GetItemPropByConfigID(nx_string(config_id), nx_string("SableSkillID"))
  local pet_skill_list = util_split_string(pet_skill_info, ",")
  form.imagegrid_pet:Clear()
  local skill_count = table.getn(pet_skill_list)
  for i = 1, skill_count do
    local skill_id = pet_skill_list[i]
    local photo = nx_execute("util_static_data", "skill_static_query_by_id", skill_id, "Photo")
    local grid_index = i - 1
    form.imagegrid_pet:AddItem(grid_index, photo, nx_widestr(skill_id), 1, -1)
  end
end
function on_imagegrid_pet_mousein_grid(grid, index)
  local config_id = grid:GetItemName(index)
  if nx_string(config_id) == nx_string("") then
    return
  end
  nx_execute("tips_game", "show_skill_tips", nx_string(config_id), 1000, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_imagegrid_pet_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_pet_select_changed(grid, index)
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return
  end
  local config_id = grid:GetItemName(index)
  if config_id == nil or config_id == "" then
    return
  end
  local action_name = attire_manager:GetAttirePetSkillAction(nx_string(config_id))
  if action_name == nil or action_name == "" then
    return
  end
  nx_execute("form_stage_main\\form_attire\\form_attire_main", "play_attire_skill_action", action_name)
end
function on_imagegrid_equip_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local info = grid:GetItemName(index)
  local pos = SHOW_DRAW_TYPE[index + 1]
  local gui = nx_value("gui")
  if nx_string(info) == nx_string("") then
    nx_execute("tips_game", "show_text_tip", gui.TextManager:GetText("ui_attire_equip_" .. nx_string(pos)), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 0, form)
    return
  end
  local custom_name = "equip_" .. index
  if nx_find_custom(grid, custom_name) then
    local obj = nx_custom(grid, custom_name)
    if nx_is_valid(obj) then
      nx_execute("tips_game", "show_goods_tip", obj, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, form, false)
    end
  end
end
function on_imagegrid_equip_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function play_action_by_sex()
  local sex = 0
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if nx_is_valid(client_player) then
    sex = client_player:QueryProp("Sex")
  end
  local action_name = "attire_boy_1"
  if 0 ~= sex then
    action_name = "attire_girl_1"
  end
  nx_execute("form_stage_main\\form_attire\\form_attire_main", "play_attire_skill_action", nx_string(action_name))
end
function on_btn_save_click(btn)
  local form_main = btn.ParentForm
  if form_main.rbtn_face.Checked then
    local form_create = nx_value("form_stage_create\\form_create_on")
    if nx_is_valid(form_create) and form_create.Visible then
      nx_execute("form_stage_create\\form_create_on", "on_btn_enter_frist_name_click", form_create.btn_enter_frist_name_3)
      return
    end
  end
  local form = btn.ParentForm
  local form_save = nx_value(FORM_SAVE)
  if not nx_is_valid(form_save) then
    form_save = util_get_form(FORM_SAVE, true, false)
    form_save.Visible = true
    form_save:Show()
  end
  nx_execute(FORM_SAVE, "refresh_grid_data", form, form_save)
end
function refresh_form_equip_grid()
  nx_pause(1)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_bag.Visible = false
  init_show_equip(form)
  form.imagegrid_bag:Clear()
  form.imagegrid_draw_item:Clear()
  local row = form.imagegrid_draw_item.RowNum
  local col = form.imagegrid_draw_item.ClomnNum
  local nCount = row * col
  for i = 0, nCount do
    form.imagegrid_draw_item:CoverItem(i, false)
  end
end
