require("util_gui")
require("util_static_data")
require("share\\static_data_type")
require("role_composite")
function on_main_form_init(self)
  self.Fixed = true
  return 1
end
function on_main_form_open(self)
  local form_logic = nx_value("form_shijia_detail")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  form_logic = nx_create("form_shijia_detail")
  if nx_is_valid(form_logic) then
    nx_set_value("form_shijia_detail", form_logic)
  end
  nx_execute(nx_current(), "show_player", self)
  self.rbtn_player_dongfang.Checked = true
end
function on_main_form_close(self)
  local form_logic = nx_value("form_shijia_detail")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  nx_kill(nx_current(), "show_player")
  nx_kill(nx_current(), "show_npc_by_config_id")
  nx_destroy(self)
end
function on_rbtn_npc_checked_changed(self)
  if not self.Checked then
    return
  end
  local form = self.ParentForm
  local shijia_id = self.DataSource
  form.groupbox_player_detail.Visible = false
  form.groupbox_npc_detail.Visible = true
  local form_logic = nx_value("form_shijia_detail")
  if nx_is_valid(form_logic) then
    form_logic:UpdateNpcList(form, shijia_id)
  end
end
function on_rbtn_player_checked_changed(self)
  if not self.Checked then
    return
  end
  local form = self.ParentForm
  local shijia_id = self.DataSource
  form.sel_player_shijia = shijia_id
  local form_logic = nx_value("form_shijia_detail")
  if nx_is_valid(form_logic) then
    form_logic:UpdateWuXue(form, shijia_id)
    on_imagegrid_cloth_select_changed(form.imagegrid_cloth, 0)
    form.imagegrid_cloth:SetSelectItemIndex(0)
    on_imagegrid_taolu_select_changed(form.imagegrid_taolu, 0)
    form.imagegrid_taolu:SetSelectItemIndex(0)
  end
  form.groupbox_player_detail.Visible = true
  form.groupbox_npc_detail.Visible = false
end
function on_rbtn_npc_item_checked_changed(self)
  if not self.Checked then
    return
  end
  local form = self.ParentForm
  local npc_id = self.npc_id
  nx_execute(nx_current(), "show_npc_by_config_id", form, npc_id)
  local form_logic = nx_value("form_shijia_detail")
  if nx_is_valid(form_logic) then
    local text_id = form_logic:GetNpcDesc(npc_id)
    local text = util_text(text_id)
    local mltbox = form.mltbox_npc
    mltbox:Clear()
    mltbox:AddHtmlText(text, -1)
  end
end
function show_npc_by_config_id(form, npc_id)
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  local resource = item_query:GetItemPropByConfigID(npc_id, "Resource")
  if nil == resource then
    nx_msgbox("Can not find Resource by Npc ConfigID!")
    return
  end
  local npc_file = "ini\\" .. resource .. ".ini"
  nx_execute("util_gui", "ui_ClearModel", form.scenebox_npc)
  if not nx_is_valid(form.scenebox_npc.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_npc)
  end
  local scene = form.scenebox_npc.Scene
  local actor = nx_execute("role_composite", "create_actor2", scene)
  if not nx_is_valid(actor) then
    return
  end
  load_from_ini(actor, npc_file)
  if not nx_is_valid(actor) then
    return
  end
  local action = nx_value("action_module")
  if nx_is_valid(action) then
    action:BlendAction(actor, "ty_stand", true, false)
  end
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_npc, actor)
end
function show_player(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local client_obj = game_client:GetSceneObj(client_player.Ident)
  if not nx_is_valid(client_obj) then
    return
  end
  local scenebox = form.scenebox_player
  nx_execute("util_gui", "ui_ClearModel", scenebox)
  if not nx_is_valid(scenebox.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", scenebox)
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local actor = role_composite:CreateSceneObject(scenebox.Scene, client_obj, false, false)
  if not nx_is_valid(actor) then
    return
  end
  while not actor.LoadFinish do
    nx_pause(0.1)
  end
  local face = get_role_face(actor)
  while not nx_is_valid(face) do
    nx_pause(0.1)
    face = get_role_face(actor)
  end
  if not nx_is_valid(face) then
    return false
  end
  while not face.LoadFinish do
    nx_pause(0.1)
  end
  nx_execute("util_gui", "util_add_model_to_scenebox", scenebox, actor)
end
function get_player_sex()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return 0
  end
  return player:QueryProp("Sex")
end
function change_player_cloth(form, cloth)
  if nil == cloth or "" == cloth then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return
  end
  local scenebox = form.scenebox_player
  local scene = scenebox.Scene
  if not nx_is_valid(scene) then
    return
  end
  if not nx_find_custom(scene, "model") then
    return
  end
  local actor = scene.model
  if not nx_is_valid(actor) then
    return
  end
  local model_name = "MaleModel"
  local sex = get_player_sex()
  if 1 == sex then
    model_name = "FemaleModel"
  end
  actor.AsyncLoad = false
  local nArtPack = item_query_ArtPack_by_id(cloth, "ArtPack", sex)
  local model = data_query:Query(STATIC_DATA_ITEM_ART, nx_int(nArtPack), model_name)
  local part = {
    "headdress",
    "mask",
    "scarf",
    "shoulders",
    "pendant1",
    "pendant2",
    "cloth",
    "shoes",
    "pants",
    "hat",
    "cloth_h"
  }
  for _, v in pairs(part) do
    role_composite:UnLinkSkin(actor, v)
  end
  role_composite:UnLinkWeapon(actor)
  role_composite:LinkSkin(actor, "Hat", " ", false)
  local ArtPack = {
    ArtPack = "Cloth",
    HatArtPack = "Hat",
    PlantsArtPack = "Pants",
    ShoesArtPack = "Shoes"
  }
  for id, prop in pairs(ArtPack) do
    local art_id = nx_number(item_query:GetItemPropByConfigID(cloth, id))
    if art_id < 0 then
      nx_execute("role_composite", "unlink_skin", actor, prop)
      nx_execute("role_composite", "unlink_skin", actor, string.lower(prop))
    elseif 0 < art_id then
      local model = data_query:Query(STATIC_DATA_ITEM_ART, nx_int(art_id), model_name)
      if "Cloth" == prop or "cloth" == prop then
        role_composite:LinkClothSkin(actor, model)
        role_composite:LinkSkin(actor, "cloth_h", model .. "_h.xmod", false)
      else
        role_composite:LinkSkin(actor, prop, model .. ".xmod", false)
      end
    end
  end
  actor.AsyncLoad = true
end
function on_imagegrid_taolu_select_changed(grid, index)
  local form = grid.ParentForm
  local form_logic = nx_value("form_shijia_detail")
  if not nx_is_valid(form_logic) then
    return
  end
  local shijia_id = form.sel_player_shijia
  local taolu_id = form_logic:GetTaoLuID(shijia_id, index)
  show_skill(form, taolu_id)
  form.lbl_79.Text = util_text(taolu_id)
end
function show_skill(form, taolu_id)
  local form_logic = nx_value("form_shijia_detail")
  if not nx_is_valid(form_logic) then
    return
  end
  local grid = form.imagegrid_skill
  local skill = form_logic:GetTaoLuSkill(taolu_id)
  local skill_list = util_split_string(skill, ",")
  grid:Clear()
  local grid_index = 0
  for _, id in ipairs(skill_list) do
    local photo = nx_execute("util_static_data", "skill_static_query_by_id", id, "Photo")
    grid:AddItem(grid_index, photo, nx_widestr(id), 1, -1)
    grid_index = grid_index + 1
  end
  show_taolu_info(form, taolu_id)
end
function show_taolu_info(form, taolu_id)
  local form_logic = nx_value("form_shijia_detail")
  if not nx_is_valid(form_logic) then
    return
  end
  local taolu_attack = form_logic:GetTaoLuAttack(taolu_id)
  local taolu_defend = form_logic:GetTaoLuDefend(taolu_id)
  local taolu_recover = form_logic:GetTaoLuRecover(taolu_id)
  local taolu_operate = form_logic:GetTaoLuOperate(taolu_id)
  local taolu_site = form_logic:GetTaoLuSite(taolu_id)
  set_star(form.groupbox_attack, taolu_attack)
  set_star(form.groupbox_defend, taolu_defend)
  set_star(form.groupbox_recover, taolu_recover)
  set_star(form.groupbox_operate, taolu_operate)
  form.mltbox_site:Clear()
  form.mltbox_site:AddHtmlText(util_text(taolu_site), -1)
end
function set_star(groupbox, num)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  groupbox:DeleteAll()
  local count = num / 2
  for i = 1, count do
    local lbl_star = gui:Create("Label")
    groupbox:Add(lbl_star)
    lbl_star.Left = (i - 1) * 20
    lbl_star.Top = 0
    lbl_star.AutoSize = true
    lbl_star.BackImage = "gui\\special\\helper\\school_introduction\\star_2.png"
    lbl_star.AutoSize = false
  end
  local remainder = num % 2
  if 1 == remainder then
    local lbl_star = gui:Create("Label")
    groupbox:Add(lbl_star)
    lbl_star.Left = count * 20 - 10
    lbl_star.Top = 0
    lbl_star.AutoSize = true
    lbl_star.BackImage = "gui\\special\\helper\\school_introduction\\star_1.png"
    lbl_star.AutoSize = false
  end
end
function on_imagegrid_cloth_select_changed(grid, index)
  local form = grid.ParentForm
  local cloth_id = nx_string(grid:GetItemAddText(index, 0))
  change_player_cloth(form, cloth_id)
end
function on_imagegrid_cloth_mousein_grid(grid, index)
  local cloth = nx_string(grid:GetItemAddText(index, 0))
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = cloth
  item.ItemType = ITEMTYPE_ORIGIN_SUIT
  item.is_static = true
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_imagegrid_cloth_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_neigong_select_changed(self, index)
end
function on_imagegrid_neigong_mousein_grid(grid, index)
  local faculty_query = nx_value("faculty_query")
  if not nx_is_valid(faculty_query) then
    return
  end
  local neigong = nx_string(grid:GetItemAddText(index, 0))
  local staticdata = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\NeiGong\\neigong.ini", neigong, "StaticData", "")
  local min_varpropno = nx_execute("util_static_data", "neigong_static_query", staticdata, "MinVarPropNo")
  local bufferlevel = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\NeiGong\\neigong_varprop.ini", nx_string(min_varpropno + 35), "BufferLevel")
  local level = 36
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = neigong
  item.ItemType = ITEMTYPE_NEIGONG
  item.StaticData = nx_number(staticdata)
  item.Level = level
  item.BufferLevel = bufferlevel
  item.is_static = true
  item.WuXing = faculty_query:GetWuXing(neigong)
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager.InShortcut = true
  end
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_imagegrid_neigong_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_skill_select_changed(grid, index)
  local form = grid.ParentForm
  local skill_id = nx_string(grid:GetItemAddText(index, 0))
  show_skill_action(form, skill_id)
end
function on_imagegrid_skill_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local skill = nx_string(grid:GetItemAddText(index, 0))
  local staticdata = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\skill_new.ini", skill, "StaticData", "")
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = skill
  item.ItemType = ITEMTYPE_ZHAOSHI
  item.StaticData = nx_number(staticdata)
  item.Level = 1
  item.is_static = true
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_imagegrid_skill_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip")
end
function get_role_face(actor)
  if not nx_is_valid(actor) then
    return nil
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return nil
  end
  local face = game_visual:QueryActFace(actor)
  if not nx_is_valid(face) then
    local actor_role = actor:GetLinkObject("actor_role")
    if not nx_is_valid(actor_role) then
      return nil
    end
    face = actor_role:GetLinkObject("actor_role_face")
  end
  return face
end
function show_skill_action(form, skill_id)
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  local scenebox = form.scenebox_player
  local scene = scenebox.Scene
  if not nx_is_valid(scene) then
    return
  end
  local actor = scene.model
  if not nx_is_valid(actor) then
    return
  end
  local skill_effect = nx_value("skill_effect")
  if not nx_is_valid(skill_effect) then
    return
  end
  skill_effect:EndShowZhaoshi(actor, "")
  action:ActionInit(actor)
  action:ClearAction(actor)
  action:ClearState(actor)
  action:BlendAction(actor, "stand", true, true)
  skill_effect:BeginShowZhaoshi(actor, skill_id)
  add_weapon(actor, skill_id)
end
function add_weapon(actor, skill_name)
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return false
  end
  if not nx_is_valid(actor) then
    return false
  end
  role_composite:UnLinkWeapon(actor)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  if nx_find_custom(actor, "wuxue_book_set") then
    actor.wuxue_book_set = nil
  else
    nx_set_custom(actor, "wuxue_book_set", "")
  end
  local taolu = nx_execute("util_static_data", "skill_static_query_by_id", skill_name, "TaoLu")
  local g_weapon_ini = nx_execute("util_functions", "get_ini", "ini\\ui\\wuxue\\skill_weapon.ini")
  if not nx_is_valid(g_weapon_ini) then
    return false
  end
  local sec_index = g_weapon_ini:FindSectionIndex("weapon_name")
  if sec_index < 0 then
    return false
  end
  local weapon_name = g_weapon_ini:ReadString(sec_index, nx_string(taolu), "")
  local LimitIndex = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\skill_new.ini", skill_name, "UseLimit", "")
  if LimitIndex == nil or nx_int(LimitIndex) == nx_int(0) then
    return false
  end
  local skill_query = nx_value("SkillQuery")
  if not nx_is_valid(skill_query) then
    return false
  end
  local ItemType = skill_query:GetSkillWeaponType(nx_int(LimitIndex))
  if ItemType == nil or nx_int(ItemType) == nx_int(0) then
    return false
  end
  game_visual:SetRoleWeaponName(actor, nx_string(weapon_name))
  local set_index = nx_int(ItemType) - 100
  if nx_int(set_index) >= nx_int(1) or nx_int(set_index) <= nx_int(8) then
    local action_set = nx_string(set_index) .. "h"
    nx_set_custom(actor, "wuxue_book_set", action_set)
  end
  role_composite:UseWeapon(actor, game_visual:QueryRoleWeaponName(actor), 2, nx_int(ItemType))
  if nx_int(ItemType) == nx_int(116) then
    role_composite:LinkWeapon(actor, "ShotWeapon", "main_model::H_weaponR_01", "ini\\npc\\hw_fz001")
    local actor_role = game_visual:QueryActRole(actor)
    local shot_weapon = actor_role:GetLinkObject("ShotWeapon")
    shot_weapon.Visible = false
  end
  game_visual:SetRoleLogicState(actor, 1)
  return true
end
function show_npc(form)
  nx_execute("util_gui", "ui_ClearModel", form.scenebox_npc)
  if not nx_is_valid(form.scenebox_npc.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_npc)
  end
  local scene = form.scenebox_npc.Scene
  local actor_root = scene:Create("Actor")
  if not nx_is_valid(actor_root) then
    return nx_null()
  end
  local async_load = false
  actor_root.AsyncLoad = async_load
  local action_file = "obj\\mount\\ride_haigui_0101\\action.ini"
  if not actor_root:SetActionEx(action_file, "gui_swim_walk", "", async_load) then
    scene:Delete(actor_root)
    return nx_null()
  end
  local mount_xmod = "obj\\mount\\horse_action\\mount.xmod"
  local horse_xmod = "obj\\mount\\ride_horse_0402\\ride_horse_0402.xmod"
  local bridge_xmod = "obj\\mount\\ride_horse_0402\\ride_horse_0402_02.xmod"
  local mount_xmod = "obj\\mount\\haigui_action\\gui.xmod"
  local horse_xmod = "obj\\mount\\ride_haigui_0101\\Tpose.xmod"
  local bridge_xmod = "obj\\mount\\ride_haigui_0101\\Tpose_02.xmod"
  local role_composite = nx_value("role_composite")
  role_composite:LinkSkin(actor_root, "mount", mount_xmod, true)
  role_composite:LinkSkin(actor_root, "horse", horse_xmod, true)
  role_composite:LinkSkin(actor_root, "bridge", bridge_xmod, true)
  while not actor_root.LoadFinish do
    nx_pause(0)
  end
  local actor_role = scene:Create("Actor")
  if not nx_is_valid(actor_role) then
    return nx_null()
  end
  actor_role.AsyncLoad = async_load
  local sex = get_player_sex()
  local action_file = ""
  if sex == 0 then
    action_file = "obj\\char\\b_action\\action_simple.ini"
  else
    action_file = "obj\\char\\g_action\\action_simple.ini"
  end
  if not actor_role:SetActionEx(action_file, "gui_swim_walk", "", async_load) then
    scene:Delete(actor_role)
    scene:Delete(actor_root)
    return nx_null()
  end
  actor_role.Callee = nx_create("ActionEventHandler")
  local main_model = ""
  if sex == 0 then
    main_model = "obj\\char\\b_model_simple\\tpose.xmod"
  else
    main_model = "obj\\char\\g_model_simple\\tpose.xmod"
  end
  if not actor_role:AddSkin("main_model", main_model) then
    scene:Delete(actor_root)
    scene:Delete(actor_role)
    return nx_null()
  end
  while not actor_role.LoadFinish do
    nx_pause(0)
  end
  actor_root:LinkToPoint("actor_role", "mount::Point01", actor_role)
  local game_visual = nx_value("game_visual")
  game_visual:CreateRoleUserData(actor_root)
  game_visual:SetActRole(actor_root, actor_role)
  local actor_face = scene:Create("Actor")
  if not nx_is_valid(actor_face) then
    return nx_null()
  end
  local file_name = ""
  if sex == 0 then
    file_name = "obj\\char\\b_face\\face_5\\composite.ini"
  else
    file_name = "obj\\char\\g_face\\face_5\\composite.ini"
  end
  if not actor_face:CreateFromIni(file_name) then
    scene:Delete(actor_face)
    return nx_null()
  end
  if nx_is_valid(actor_face) then
    actor_role:LinkToPoint("actor_face", "mount::Point01", actor_face)
    actor_role:AddChildAction(actor_face)
    actor_face:AddParentAction(actor_role)
  end
  if not nx_is_valid(actor_root) then
    scene:Delete(actor_role)
    scene:Delete(actor_face)
    return nx_null()
  end
  if nx_is_valid(role_composite) then
    local cloth_xmod = "obj\\char\\b_jianghu010\\b_cloth010.xmod"
    local hat_xmod = "obj\\char\\b_jianghu010\\b_helmet010.xmod"
    local pants_xmod = "obj\\char\\b_jianghu010\\b_pants010.xmod"
    local shoes_xmod = "obj\\char\\b_jianghu010\\b_shoes010.xmod"
    role_composite:LinkSkin(actor_role, "cloth", cloth_xmod, true)
    role_composite:LinkSkin(actor_role, "hat", hat_xmod, true)
    role_composite:LinkSkin(actor_role, "pants", pants_xmod, true)
    role_composite:LinkSkin(actor_role, "shoes", shoes_xmod, true)
    actor_root:SetScale(0.6, 0.6, 0.6)
  end
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_npc, actor_root)
end
