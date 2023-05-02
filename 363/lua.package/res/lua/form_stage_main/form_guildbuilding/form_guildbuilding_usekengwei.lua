require("scene")
require("util_gui")
require("game_object")
require("custom_sender")
require("util_functions")
require("role_composite")
require("util_static_data")
require("share\\view_define")
require("define\\sysinfo_define")
require("share\\client_custom_define")
require("form_stage_main\\form_guild\\form_guild_util")
PROP_COUNT = 11
TYPE_INDEX = 1
FACULTY_ACTION_INDEX = 2
COST_SILVER_INDEX = 3
COST_CONTRIBUTION_INDEX = 4
REPAIRE_COST_INDEX = 5
FACULTY_TIME_INDEX = 6
KICK_CONTRIBUTION_INDEX = 7
NEXT_LVL_ATTR_BAG_INDEX = 8
OPEN_START_TIME_INDEX = 9
OPEN_LAST_TIME_INDEX = 10
COST_SILVER_TYPE_INDEX = 11
local SILVER_TYPE_SUIYIN = 1
local SILVER_TYPE_RMB = 2
local FACULTY_TYPE = 5
local FACULTY_TYPE2 = 8
local REPLACE_CATEGORY_A = 123456
local REPLACE_CATEGORY_B = 654321
local KENGWEI_ADD_LIMIT = 0.05
local FORM_NAME = "form_stage_main\\form_guildbuilding\\form_guildbuilding_usekengwei"
local FACULTY_TYPE_TABLE = {
  sh_kg = 5,
  sh_lh = 6,
  sh_nf = 7,
  sh_qf = 8,
  sh_yf = 9,
  sh_cf = 10,
  sh_cs = 11,
  sh_ds = 12,
  sh_jq = 13,
  sh_tj = 14,
  sh_ys = 15,
  sh_qs = 16,
  sh_qis = 17,
  sh_ss = 18,
  sh_hs = 19,
  sh_gs = 20,
  sh_qg = 21
}
local FACULTY_SCROLL_TABLE = {
  JuanZhou01 = "sh_kg",
  JuanZhou02 = "sh_tj",
  JuanZhou03 = "sh_yf",
  JuanZhou04 = "sh_qf",
  JuanZhou05 = "sh_nf",
  JuanZhou06 = "sh_lh",
  JuanZhou07 = "sh_cf",
  JuanZhou08 = "sh_jq",
  JuanZhou09 = "sh_ys",
  JuanZhou10 = "sh_ds",
  JuanZhou11 = "sh_cs",
  JuanZhou12 = "sh_qs",
  JuanZhou13 = "sh_hs",
  JuanZhou14 = "sh_qg",
  JuanZhou15 = "sh_ss",
  JuanZhou16 = "sh_qis",
  JuanZhou17 = "sh_gs",
  ["5"] = "sh_kg",
  ["6"] = "sh_lh",
  ["7"] = "sh_nf",
  ["8"] = "sh_qf",
  ["9"] = "sh_yf",
  ["10"] = "sh_cf",
  ["11"] = "sh_cs",
  ["12"] = "sh_ds",
  ["13"] = "sh_jq",
  ["14"] = "sh_tj",
  ["15"] = "sh_ys",
  ["16"] = "sh_qs",
  ["17s"] = "sh_qis",
  ["18"] = "sh_ss",
  ["19"] = "sh_hs",
  ["20"] = "sh_gs",
  ["21"] = "sh_qg"
}
function main_form_init(form)
  form.Fixed = false
  form.npc_id = nil
  form.time = 0
  form.type = 0
  form.type_array = nx_create("ArrayList", nx_current())
  form.sex = 0
  form.cloth = ""
  form.hat = ""
  form.pants = ""
  form.shoes = ""
  form.face = ""
  form.weapon = ""
  form.clotheffect = ""
  form.hateffect = ""
  form.pantseffect = ""
  form.shoeseffect = ""
  form.weaponeffect = ""
  form.visual_obj = ""
  form.role_actor2 = nx_null()
  return 1
end
function on_main_form_open(form)
  local temp_form = nx_value(nx_string(FORM_NAME))
  if not nx_is_valid(temp_form) then
    nx_set_value(nx_string(FORM_NAME), form)
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  refresh_form(form)
  local player = get_client_player()
  if nx_is_valid(player) then
    form.sex = player:QueryProp("Sex")
    form.cloth = player:QueryProp("Cloth")
    form.hat = player:QueryProp("Hat")
    form.pants = player:QueryProp("Pants")
    form.shoes = player:QueryProp("Shoes")
    form.face = player:QueryProp("Face")
    form.weapon = player:QueryProp("Weapon")
    form.clotheffect = player:QueryProp("ClothEffect")
    form.hateffect = player:QueryProp("HateEffect")
    form.pantseffect = player:QueryProp("PantsEffect")
    form.shoeseffect = player:QueryProp("ShoesEffect")
    form.weaponeffect = player:QueryProp("WeaponEffect")
    local game_visual = nx_value("game_visual")
    local client_visual = game_visual:GetSceneObj(player.Ident)
    form.visual_obj = client_visual
    if not nx_is_valid(form.scenebox_role.Scene) then
      util_addscene_to_scenebox(form.scenebox_role)
    end
    show_role_model(form)
  end
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, 4 do
    local scene_box = form:Find("scenebox_" .. i + 1)
    if nx_is_valid(scene_box) then
      if nx_find_custom(scene_box, "master_actor2") and nx_is_valid(scene_box.master_actor2) then
        scene_box.Scene:Delete(scene_box.master_actor2)
      end
      nx_execute("scene", "delete_scene", scene_box.Scene)
    end
  end
  if nx_find_custom(form, "role_actor2") and nx_is_valid(form.role_actor2) then
    form.scenebox_role.Scene:Delete(form.role_actor2)
  end
  nx_execute("scene", "delete_scene", form.scenebox_role.Scene)
  local databinder = nx_value("data_binder")
  databinder:DelViewBind(form)
  form.type_array:ClearChild()
  nx_destroy(form)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(1016), nx_int(123), nx_int(VIEWPORT_GUILD_TEACHER_BOX))
  custom_guild_del_viewport(VIEWPORT_JUANZHOU)
end
function on_btn_faculty_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  if check_can_faculty(form, form.time, form.type) == false then
    return false
  end
  local CLIENT_SUBMSG_USE_KENGWEI = 3
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_USE_KENGWEI), form.npc_id, nx_int(form.combobox_buff.DropListBox.SelectIndex))
  form:Close()
  return true
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
  return 1
end
function on_combobox_buff_selected(combobox)
  local form = combobox.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local cur_index = combobox.DropListBox.SelectIndex + 1
  local cur_buff_name = get_faculty_buff_name_by_index(cur_index)
  if string.len(cur_buff_name) <= 0 then
    return
  end
  form.mltbox_desc.HtmlText = nx_widestr(gui.TextManager:GetText("ui_" .. nx_string(cur_buff_name)))
end
function refresh_form(form)
  if not nx_is_valid(form) then
    return
  end
  show_preview(form)
  refresh_text(form)
end
function refresh_text(form)
  local gui = nx_value("gui")
  if not nx_is_valid(form) or not nx_is_valid(gui) then
    return
  end
  form.type = nx_int(get_npc_faculty_info(form, TYPE_INDEX))
  form.lbl_kengwei_title.Text = nx_widestr(gui.TextManager:GetText("ui_guildbuilding_name_1_" .. nx_string(form.type)))
  form.time = nx_int(get_npc_faculty_info(form, FACULTY_TIME_INDEX))
  form.lbl_faculty_time.Text = nx_widestr(form.time) .. nx_widestr(gui.TextManager:GetText("ui_fengzhong"))
  form.lbl_cost_contribution.Text = nx_widestr(get_npc_faculty_info(form, COST_CONTRIBUTION_INDEX))
  local cost_sliver = get_npc_faculty_info(form, COST_SILVER_INDEX) / 1000
  local cost_silver_type = get_npc_faculty_info(form, COST_SILVER_TYPE_INDEX)
  if nx_int(cost_silver_type) == nx_int(SILVER_TYPE_SUIYIN) then
    form.mlt_cost_sliver.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_suiyin", nx_int(cost_sliver)))
  else
    form.mlt_cost_sliver.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_zhengyin", nx_int(cost_sliver)))
  end
  local start_time = get_npc_faculty_info(form, OPEN_START_TIME_INDEX)
  local last_time = get_npc_faculty_info(form, OPEN_LAST_TIME_INDEX)
  local end_time = start_time + last_time
  if nx_int(start_time) >= nx_int(end_time) then
    last_time = 0
  end
  if nx_int(end_time) > nx_int(24) then
    end_time = 24
  end
  if nx_int(last_time) <= nx_int(0) or nx_int(start_time) >= nx_int(24) then
    form.btn_faculty.Enabled = false
    form.lbl_open_range.Text = nx_widestr(gui.TextManager:GetText("ui_close"))
  elseif nx_int(start_time) == nx_int(0) and nx_int(last_time) == nx_int(24) then
    form.lbl_open_range.Text = nx_widestr(gui.TextManager:GetText("ui_week_day"))
  else
    form.lbl_open_range.Text = nx_widestr(gui.TextManager:GetFormatText("ui_time_from_to", nx_int(start_time), nx_int(end_time)))
  end
  local buff_table = get_npc_faculty_buff(form)
  form.combobox_buff.Text = nx_widestr(util_text("ui_qingxuanze"))
  form.combobox_buff.DropListBox.SelectIndex = -1
  for j = 1, table.getn(buff_table) do
    form.combobox_buff.DropListBox:AddString(nx_widestr(util_text(nx_string(buff_table[j]))))
  end
end
function show_preview(form)
  local build_npc = get_guild_build_npc(form)
  if not nx_is_valid(build_npc) then
    return
  end
  local sub_type = build_npc:QueryProp("SubType")
  if nx_int(sub_type) >= nx_int(1) and nx_int(sub_type) <= nx_int(5) then
    local img = "gui\\guild\\preview\\xiuliang_preview_" .. nx_string(sub_type) .. ".png"
    form.lbl_preview.BackImage = nx_string(img)
  end
end
function get_npc_faculty_info(form, index)
  if not nx_is_valid(form) then
    return 0
  end
  if nx_int(index) <= nx_int(0) or nx_int(index) > nx_int(PROP_COUNT) then
    return 0
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local gb_manager = nx_value("GuildbuildingManager")
  if not nx_is_valid(gb_manager) then
    return 0
  end
  local ident = nx_string(form.npc_id)
  local npc = game_client:GetSceneObj(ident)
  if not nx_is_valid(npc) then
    return 0
  end
  local package_id = npc:QueryProp("AttributeBag")
  local package_infos = gb_manager:GetKengWeiNpcPackageInfo(package_id)
  if package_infos == nil then
    return 0
  end
  if table.getn(package_infos) ~= PROP_COUNT then
    return 0
  end
  return package_infos[index]
end
function get_npc_faculty_buff(form)
  if not nx_is_valid(form) then
    return 0
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local gb_manager = nx_value("GuildbuildingManager")
  if not nx_is_valid(gb_manager) then
    return 0
  end
  local ident = nx_string(form.npc_id)
  local npc = game_client:GetSceneObj(ident)
  if not nx_is_valid(npc) then
    return 0
  end
  local package_id = npc:QueryProp("AttributeBag")
  local buff_list = gb_manager:GetKengWeiNpcBuffInfo(package_id)
  if buff_list == nil then
    return 0
  end
  return buff_list
end
function get_faculty_buff_name_by_index(index)
  local form = nx_value(FORM_NAME)
  local buff_list = get_npc_faculty_buff(form)
  if index > table.getn(buff_list) or index <= 0 then
    return ""
  end
  return buff_list[index]
end
function check_can_faculty(form, time, type)
  if not nx_is_valid(form) then
    return false
  end
  if nx_int(time) <= nx_int(0) then
    return false
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local player_contri = client_player:QueryProp("GuildContribute")
  local player_silver = client_player:QueryProp("CapitalType1")
  local need_gongxian = get_npc_faculty_info(form, COST_CONTRIBUTION_INDEX)
  local need_yinzi = get_npc_faculty_info(form, COST_SILVER_INDEX)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_int(player_contri) < nx_int(need_gongxian) then
    local info = gui.TextManager:GetText("19226")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
    return false
  end
  if nx_int(player_silver) < nx_int(need_yinzi) then
    local info = gui.TextManager:GetText("19227")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
    return false
  end
  local cur_faculty_buff_list = get_npc_faculty_buff(form)
  local buffer_list = nx_function("get_buffer_list", client_player)
  local buffer_count = table.getn(buffer_list) / 2
  for i = 1, buffer_count do
    local buffer_id = buffer_list[i * 2 - 1]
    local buff_source = buffer_list[i * 2]
    local REPLACE_CATEGORY = buff_static_query(nx_string(buffer_id), "ReplaceCategory")
    for j = 1, table.getn(cur_faculty_buff_list) do
      local cur_faculty_buff_name = cur_faculty_buff_list[j]
      local cur_faculty_replace_category = buff_static_query(nx_string(cur_faculty_buff_name), "ReplaceCategory")
      if nx_int(cur_faculty_replace_category) == nx_int(REPLACE_CATEGORY) then
        local confirm_dlg = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false, "kengwei_faculty")
        if not nx_is_valid(confirm_dlg) then
          return false
        end
        local text = nx_widestr(gui.TextManager:GetFormatText("ui_None"))
        if nx_int(REPLACE_CATEGORY_A) == nx_int(REPLACE_CATEGORY) then
          text = nx_widestr(gui.TextManager:GetFormatText("ui_kengwei_faculty_conflict_1"))
        elseif nx_int(REPLACE_CATEGORY_B) == nx_int(REPLACE_CATEGORY) then
          text = nx_widestr(gui.TextManager:GetFormatText("ui_kengwei_faculty_conflict_2"))
        end
        nx_execute("form_common\\form_confirm", "show_common_text", confirm_dlg, nx_widestr(text))
        confirm_dlg:ShowModal()
        local res = nx_wait_event(100000000, confirm_dlg, "confirm_return")
        if nx_string(res) == nx_string("ok") then
          return true
        else
          return false
        end
      end
    end
  end
  return true
end
function get_guild_build_npc(form)
  if not nx_is_valid(form) then
    return nil
  end
  local ident = nx_string(form.npc_id)
  local game_client = nx_value("game_client")
  local npc = game_client:GetSceneObj(ident)
  if not nx_is_valid(npc) then
    return nil
  end
  local build_id = nx_string(npc:QueryProp("BelongGuildBuilding"))
  local build_npc = game_client:GetSceneObj(build_id)
  if not nx_is_valid(build_npc) then
    return nil
  end
  return build_npc
end
function check_life_faculty(build_npc)
  if not nx_is_valid(build_npc) then
    return
  end
  local sub_type = build_npc:QueryProp("SubType")
  if nx_int(sub_type) == nx_int(FACULTY_TYPE) or nx_int(sub_type) == nx_int(FACULTY_TYPE2) then
    return true
  end
  return false
end
function find_life_job(job_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if 0 <= client_player:FindRecordRow("job_rec", 0, job_id, 0) then
    return true
  else
    return false
  end
end
function on_self_view_operat(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_JUANZHOU))
  local scroll_count = view:GetRecordRows("JuanZhouRec")
  form.lbl_lifejob.Visible = true
  form.type_array:ClearChild()
  for i = 0, scroll_count - 1 do
    local scroll_id = view:QueryRecord("JuanZhouRec", i, 0)
    local life_name = guild_util_get_text("ui_" .. nx_string(scroll_id))
  end
end
function get_role_face(role_actor2)
  local actor_role = role_actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    return nil
  end
  local actor2_face = actor_role:GetLinkObject("actor_role_face")
  return actor2_face
end
function doPossAction(actor2, aciton)
  local action_module = nx_value("action_module")
  if nx_is_valid(action_module) and nx_is_valid(actor2) then
    actor2.cur_action = aciton
    local isExists = action_module:ActionExists(actor2, nx_string(aciton))
    if isExists then
      local is_in_list = action_module:ActionBlended(actor2, nx_string(aciton))
      if not is_in_list then
        action_module:BlendAction(actor2, nx_string(aciton), true, true)
      end
    end
  end
end
function show_role_model(form)
  local world = nx_value("world")
  if not nx_is_valid(world) then
    return false
  end
  local scene = form.scenebox_role.Scene
  if not nx_is_valid(scene) then
    return false
  end
  local actor2 = create_role_composite(scene, true, form.sex)
  if not nx_is_valid(actor2) then
    return false
  end
  while not actor2.LoadFinish do
    nx_pause(0.1)
  end
  local face_actor2 = get_role_face(actor2)
  while not nx_is_valid(face_actor2) do
    nx_pause(0.1)
    face_actor2 = get_role_face(actor2)
  end
  while not face_actor2.LoadFinish do
    nx_pause(0.1)
  end
  if not nx_is_valid(form) then
    return false
  end
  local head_indo = {
    [1] = "hair",
    [2] = ""
  }
  local skin_info = {
    [1] = {link_name = "face", model_name = ""},
    [2] = {
      link_name = "hat",
      model_name = form.hat
    },
    [3] = {
      link_name = "cloth",
      model_name = form.cloth
    },
    [4] = {
      link_name = "pants",
      model_name = form.pants
    },
    [5] = {
      link_name = "shoes",
      model_name = form.shoes
    }
  }
  local effect_info = {
    [1] = {
      link_name = "HatEffect",
      model_name = form.hateffect
    },
    [2] = {
      link_name = "ClothEffect",
      model_name = form.clotheffect
    },
    [3] = {
      link_name = "PantsEffect",
      model_name = form.pantseffect
    },
    [4] = {
      link_name = "ShoesEffect",
      model_name = form.shoeseffect
    },
    [5] = {
      link_name = "WeaponEffect",
      model_name = form.weaponeffect
    }
  }
  for i, info in pairs(skin_info) do
    if string.len(nx_string(info.model_name)) > 0 then
      link_skin(actor2, info.link_name, info.model_name .. ".xmod")
    end
  end
  for i, info in pairs(effect_info) do
    if model_name ~= nil and model_name ~= null then
      link_effect(actor2, info.link_name, info.model_name)
    end
  end
  actor2:SetPosition(0, 0, 0)
  actor2:SetAngle(0, 0, 0)
  local actor_role = actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    scene:Delete(actor2)
    return false
  end
  form.role_actor2 = actor2
  local actor2_face = actor_role:GetLinkObject("actor_role_face")
  set_player_face_ex(actor2_face, form.face, form.sex, form.visual_obj)
  if nx_is_valid(form.scenebox_role.Scene) then
    util_add_model_to_scenebox(form.scenebox_role, actor2)
  end
  local aculty_action = get_npc_faculty_info(form, FACULTY_ACTION_INDEX)
  doPossAction(actor2, aculty_action)
  if nx_string(aculty_action) == nx_string("interact401") then
    scene.camera:SetPosition(0, 2.5, -3)
  end
  return true
end
function scenebox_showrole(scene_box, obj_id)
  local game_client = nx_value("game_client")
  local npc = game_client:GetSceneObj(nx_string(obj_id))
  if not nx_is_valid(npc) then
    return
  end
  local resource = npc:QueryProp("Resource")
  if not nx_is_valid(scene_box.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", scene_box)
  end
  local scene = scene_box.Scene
  if not nx_is_valid(scene) then
    return
  end
  local actor2 = nx_execute("role_composite", "create_actor2", scene)
  if not nx_is_valid(actor2) then
    scene:Delete(actor2)
    return
  end
  actor2.AsyncLoad = true
  actor2.scene = scene
  nx_execute("role_composite", "load_from_ini", actor2, "ini\\" .. nx_string(resource) .. ".ini")
  if not nx_is_valid(actor2) then
    scene:Delete(actor2)
    return
  end
  scene_box.master_actor2 = actor2
  nx_execute("util_gui", "util_add_model_to_scenebox", scene_box, actor2)
  local game_visual = nx_value("game_visual")
  game_visual:SetRoleStateOld(actor2, "")
  local visual_obj = game_visual:GetSceneObj(npc.Ident)
  game_visual:SetRoleWeaponMode(actor2, game_visual:QueryRoleWeaponMode(visual_obj))
  local visual_obj_type = game_visual:QueryRoleType(visual_obj)
  game_visual:SetRoleType(actor2, visual_obj_type)
  game_visual:SetRoleCreateFinish(actor2, true)
  local action_module = nx_value("action_module")
  action_module:ChangeState(actor2, "stand", true)
end
