require("util_gui")
require("const_define")
require("define\\object_type_define")
require("util_functions")
require("custom_sender")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\npc_type_define")
require("util_static_data")
require("scenario_npc_manager")
require("tips_game")
local TEAM_REC = "team_rec"
local skill_name = "ui_skill001"
local captain_ico = "gui\\mainform\\icon_captain_player.png"
local allot_ico = "gui\\mainform\\icon_allocatee_player.png"
local skill_photo = "icon\\skill\\wx_sl0903.png"
local back_image = {
  "gui\\mainform\\target\\bg_target.png",
  "gui\\mainform\\target\\bg_target.png",
  "gui\\mainform\\target\\bg_target.png",
  "gui\\mainform\\target\\bg_target.png",
  "gui\\mainform\\target\\bg_target.png"
}
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
local function get_method_arg(ent, method_list)
  local nifo_list = nx_method(ent, method_list)
  log("method_list bagin")
  for _, info in pairs(nifo_list) do
    log("info = " .. nx_string(info))
  end
  log("method_list end")
end
local function get_method(ent)
  if not nx_is_valid(ent) then
    log("no \163\186need entity")
    return 1
  end
  local method_list = nx_method_list(ent)
  log("method_list bagin")
  for _, method in ipairs(method_list) do
    log("method = " .. method)
  end
  log("method_list end")
end
function main_form_init(self)
  self.Fixed = true
  self.bind = false
  self.b_first = true
  self.name_pos = 0
  self.str_font = ""
  self.selectobjname = nil
  self.selectobjtype = nil
  self.cantopen = false
  self.role_actor2 = nx_null()
  nx_execute("form_stage_main\\form_main\\form_main_buff", "create_buffer_time_rec", "TARGET_BUFF_TIME_REC")
  return 1
end
function main_form_open(form)
  local gui = nx_value("gui")
  if form.b_first then
    form.name_pos = form.lbl_name.AbsTop
    form.str_font = form.lbl_name.Font
    form.b_first = false
  end
  form.buff_grid.unhelpful_total = 0
  form.buff_grid.helpful_total = 0
  form.prog_hp.tge_value = 0
  form.prog_hp.sat_value = 0
  form.prog_hp.cur_value = 0
  form.prog_hp.cur_ratio = 0.01
  form.prog_hp.resume_hp = form.prog_resume_hp
  form.prog_hp.end_time = 2000
  form.prog_hp.cur_time = 0
  form.prog_mp.tge_value = 0
  form.prog_mp.sat_value = 0
  form.prog_mp.cur_value = 0
  form.prog_mp.cur_ratio = 0.01
  form.prog_mp.end_time = 2000
  form.prog_mp.cur_time = 0
  form.pbar_hp.tge_value = 0
  form.pbar_hp.sat_value = 0
  form.pbar_hp.cur_value = 0
  form.pbar_hp.cur_ratio = 0.01
  form.pbar_hp.resume_hp = form.pbar_resume_hp
  form.pbar_hp.end_time = 2000
  form.pbar_hp.cur_time = 0
  form.prog_resume_hp.tge_value = 0
  form.prog_resume_hp.sat_value = 0
  form.prog_resume_hp.cur_value = 0
  form.prog_resume_hp.cur_ratio = 0.005
  form.prog_resume_hp.cur_stage = 1
  form.prog_resume_hp.end_time = 2000
  form.prog_resume_hp.cur_time = 0
  form.prog_resume_hp.Visible = false
  form.prog_resume_hp.obj = nil
  form.prog_resume_hp.prop = "HPRatio"
  form.pbar_resume_hp.tge_value = 0
  form.pbar_resume_hp.sat_value = 0
  form.pbar_resume_hp.cur_value = 0
  form.pbar_resume_hp.cur_ratio = 0.005
  form.pbar_resume_hp.cur_stage = 1
  form.pbar_resume_hp.Visible = false
  form.pbar_resume_hp.obj = nil
  form.pbar_resume_hp.end_time = 2000
  form.pbar_resume_hp.cur_time = 0
  form.pbar_resume_hp.prop = "HitHPRatio"
  form.groupbox_skill.Visible = false
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) and not form.bind then
    databinder:AddRolePropertyBind("LastObject", "object", form, nx_current(), "on_selectobj_changed")
    databinder:AddSelObjPropertyBind("TeamCaptain", "widestr", form, nx_current(), "on_selobj_captain_changed")
    databinder:AddSelObjPropertyBind("HPRatio", "int", form.prog_hp, nx_current(), "refresh_hpradio_sel")
    databinder:AddSelObjPropertyBind("HitHPRatio", "int", form.prog_resume_hp, nx_current(), "refresh_hit_hp_tge_value_sel")
    databinder:AddSelObjPropertyBind("MPRatio", "int", form.prog_mp, nx_current(), "refresh_mpradio_sel")
    databinder:AddSelObjPropertyBind("LastObject", "object", form, nx_current(), "refresh_auto_select_object")
    databinder:AddSelObjPropertyBind("School", "string", form, nx_current(), "refresh_school")
    databinder:AddSelObjPropertyBind("PKValue", "int", form, nx_current(), "refresh_color")
    databinder:AddSelTargetObjPropertyBind("HPRatio", "int", form.pbar_hp, nx_current(), "refresh_hpradio_tar")
    databinder:AddSelTargetObjPropertyBind("HitHPRatio", "int", form.pbar_resume_hp, nx_current(), "refresh_hit_hp_tge_value_tar")
    form.bind = true
  end
  local timer = nx_value("timer_game")
  local asynor = nx_value("common_execute")
  asynor:AddExecute("ExecuteBuffersCyc", form, nx_float(0.015))
  asynor:AddExecute("HPResume", form, nx_float(0), form.prog_hp, form.prog_mp, form.prog_resume_hp)
  asynor:AddExecute("HPResume", form.groupbox_select, nx_float(0), form.pbar_hp, nil, form.pbar_resume_hp)
end
function on_main_form_shut(form)
  if nx_find_custom(form, "role_actor2") and nx_is_valid(form.role_actor2) then
    clear_form_model(form, form.role_actor2)
  end
end
function main_form_close(self)
  local old_sel_vis_object = nx_null()
  if nx_find_value(GAME_SELECT_OBJECT) then
    local old_sel_client_object = nx_value(GAME_SELECT_OBJECT)
    local game_visual = nx_value("game_visual")
    if nx_is_valid(old_sel_client_object) and nx_is_valid(game_visual) then
      old_sel_vis_object = game_visual:GetSceneObj(old_sel_client_object.Ident)
    end
  end
  local asynor = nx_value("common_execute")
  asynor:RemoveExecute("ExecuteBuffersCyc", self)
  asynor:RemoveExecute("HPResume", self)
  asynor:RemoveExecute("HPResume", self.groupbox_select)
  remove_select_effect(old_sel_vis_object)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelSelObjPropertyBind("LastObject", self)
    databinder:DelSelObjPropertyBind("HPRatio", self.prog_hp)
    databinder:DelSelObjPropertyBind("MaxHPMul", self)
    databinder:DelSelObjPropertyBind("MaxHP", self)
    databinder:DelSelObjPropertyBind("HP", self.prog_hp)
    databinder:DelSelObjPropertyBind("MPRatio", self.prog_mp)
    databinder:DelSelObjPropertyBind("School", self)
    databinder:DelSelObjPropertyBind("PKValue", self)
    databinder:DelSelObjPropertyBind("TeamCaptain", self)
  end
  nx_execute("form_stage_main\\form_main\\form_main_buff", "clear_buffer_time_rec", "TARGET_BUFF_TIME_REC")
  self.buff_grid.unhelpful_total = 0
  self.buff_grid.helpful_total = 0
end
function on_gui_size_change()
  local form = nx_value("form_stage_main\\form_main\\form_main_select")
  if not nx_is_valid(form) then
    return
  end
end
function del_sel_tar_prop(form)
  local databinder = nx_value("data_binder")
  databinder:DelSelTargetObjPropertyBind("HPRatio", form.pbar_hp)
  databinder:DelSelTargetObjPropertyBind("HitCurHPRatio", form.pbar_resume_hp)
  databinder:DelSelTargetObjPropertyBind("HitHPRatio", form.pbar_resume_hp)
end
function get_client_obj_type(client_scene_obj)
  if not nx_is_valid(client_scene_obj) then
    return -1
  end
  local obj_type = nx_number(client_scene_obj:QueryProp("Type"))
  return obj_type
end
function on_selobj_captain_changed(form)
  local game_client = nx_value("game_client")
  local game_role = game_client:GetPlayer()
  if not nx_is_valid(game_role) then
    return
  end
  local select_target_ident = game_role:QueryProp("LastObject")
  local select_target = game_client:GetSceneObj(nx_string(select_target_ident))
  if not nx_is_valid(select_target) then
    return
  end
  local roletype = select_target:QueryProp("Type")
  local captainname = select_target:QueryProp("TeamCaptain")
  local rolename = select_target:QueryProp("Name")
  if TYPE_PLAYER == roletype then
    if nx_string(captainname) == nx_string(rolename) then
      form.lbl_captain.BackImage = captain_ico
    else
      form.lbl_captain.BackImage = ""
    end
  else
    form.lbl_captain.BackImage = ""
  end
end
function on_selobj_allot_changed(form)
  local game_client = nx_value("game_client")
  local game_role = game_client:GetPlayer()
  if not nx_is_valid(game_role) then
    return
  end
  local select_target_ident = game_role:QueryProp("LastObject")
  local select_target = game_client:GetSceneObj(nx_string(select_target_ident))
  if not nx_is_valid(select_target) then
    return
  end
  local roletype = select_target:QueryProp("Type")
  local playername = nx_string(select_target:QueryProp("Name"))
  local rowcount = select_target:GetRecordRows(TEAM_REC)
  if nx_int(rowcount) <= nx_int(0) then
    form.lbl_allot.BackImage = ""
    return
  end
  if TYPE_PLAYER == roletype then
    for i = 0, rowcount - 1 do
      local name = select_target:QueryRecord(TEAM_REC, i, 0)
      if nx_string(playername) == nx_string(name) then
        local playerwork = select_target:QueryRecord(TEAM_REC, i, 11)
        if nx_int(playerwork) == nx_int(1) then
          form.lbl_allot.BackImage = allot_ico
          break
        end
        form.lbl_allot.BackImage = ""
        break
      end
    end
  else
    form.lbl_allot.BackImage = ""
  end
end
function remove_select_effect(target)
  local game_select_decal = nx_value("GameSelectDecal")
  if nx_is_valid(game_select_decal) then
    game_select_decal:ChangeTarget(nx_null())
  end
end
function set_select_effect(target)
  if nx_is_valid(target) then
    local game_select_decal = nx_value("GameSelectDecal")
    if nx_is_valid(game_select_decal) then
      game_select_decal:ChangeTarget(target)
    end
  end
end
function on_selectobj_changed(self, propname, proptype, propvalue)
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local databinder = nx_value("data_binder")
  on_selobj_captain_changed(self)
  on_selobj_allot_changed(self)
  local old_sel_vis_object = nx_null()
  if nx_find_value(GAME_SELECT_OBJECT) then
    local old_sel_client_object = nx_value(GAME_SELECT_OBJECT)
    if nx_is_valid(old_sel_client_object) then
      old_sel_vis_object = game_visual:GetSceneObj(old_sel_client_object.Ident)
    end
  end
  remove_select_effect(old_sel_vis_object)
  local visual_scene_obj = nx_null()
  self.buff_grid.unhelpful_total = 0
  self.buff_grid.helpful_total = 0
  local select_object = game_client:GetSceneObj(nx_string(propvalue))
  set_target_model(nx_string(propvalue), game_client, game_visual)
  if not nx_is_valid(select_object) then
    self.Visible = false
    nx_set_value(GAME_SELECT_OBJECT, nx_null())
    nx_set_value("select_obj_ident", "")
    nx_set_value("select_object", nx_null())
  else
    self.cantopen = false
    nx_set_value(GAME_SELECT_OBJECT, select_object)
    nx_set_value("select_obj_ident", select_object.Ident)
    nx_set_value("select_object", nx_string(propvalue))
    visual_scene_obj = game_visual:GetSceneObj(select_object.Ident)
    local databinder = nx_value("data_binder")
    databinder:RefreshSelBind()
    local objtype = select_object:QueryProp("Type")
    local npc_type = select_object:QueryProp("NpcType")
    if objtype == TYPE_NPC and is_check_npc_type(npc_type) then
      self.Visible = false
    else
      show_selectobj_form(select_object)
    end
  end
  if nx_is_valid(old_sel_vis_object) then
    local head_game = nx_value("HeadGame")
    if nx_is_valid(head_game) then
      head_game:RefreshAll(old_sel_vis_object)
    end
  end
  if nx_is_valid(visual_scene_obj) then
    local head_game = nx_value("HeadGame")
    if nx_is_valid(head_game) then
      head_game:RefreshAll(visual_scene_obj)
    end
  end
  nx_execute("menu_game", "menu_close_click")
  local client_player = game_client:GetPlayer()
  if nx_id_equal(client_player, select_object) then
    return 0
  end
  set_select_effect(visual_scene_obj)
  return 1
end
function set_target_model(ident, game_client, game_visual)
  local select_client_obj = game_client:GetSceneObj(nx_string(ident))
  local target_model
  if nx_is_valid(select_client_obj) then
    local type = select_client_obj:QueryProp("Type")
    target_model = game_visual:GetSceneObj(nx_string(ident))
    if type == 2 and nx_is_valid(target_model) then
      target_model = target_model:GetLinkObject("actor_role")
    end
  end
  if target_model == nil or not nx_is_valid(target_model) then
    target_model = nil
  end
  nx_set_value("target_model", target_model)
end
function show_selectobj_form(client_scene_obj)
  local game_client = nx_value("game_client")
  local form_main_select = nx_value("form_stage_main\\form_main\\form_main_select")
  local gui = nx_value("gui")
  if not nx_is_valid(form_main_select) then
    return 0
  end
  if not nx_is_valid(client_scene_obj) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(nx_string(client_scene_obj.Ident))
  form_main_select.lbl_photo.Visible = false
  form_main_select.groupbox_select.Visible = false
  form_main_select.lbl_back.BackImage = back_image[1]
  if not nx_is_valid(client_scene_obj) then
    return 0
  end
  local photo = ""
  if client_scene_obj:FindProp("Photo") then
    photo = client_scene_obj:QueryProp("Photo")
  end
  local _visible = nx_string(photo) ~= nx_string("")
  form_main_select.lbl_photo.BackImage = photo
  local npc_info_ini = nx_execute("util_functions", "get_ini", "ini\\ClientNpcInfo\\Client_Npc_Info.ini")
  if not nx_is_valid(npc_info_ini) then
    return 0
  end
  local auto_select_object_value = client_scene_obj:QueryProp("LastObject")
  local objtype = client_scene_obj:QueryProp("Type")
  form_main_select.groupbox_select.Visible = false
  refresh_auto_select_object(form_main_select, "LastObject", "object", auto_select_object_value)
  form_main_select.selectobjtype = objtype
  local targetname = ""
  form_main_select.prog_resume_hp.obj = client_scene_obj
  local client_kind_npc = 0
  if objtype == TYPE_PLAYER then
    local color = nx_execute("head_game", "get_player_name_color", client_scene_obj)
    form_main_select.lbl_name.ForeColor = color_hex_d(color)
    form_main_select.lbl_back.Visible = true
    targetname = client_scene_obj:QueryProp("Name")
    if nx_is_valid(visual_scene_obj) and nx_find_custom(visual_scene_obj, "other_role") and nx_is_valid(visual_scene_obj.other_role) then
      local other_role = visual_scene_obj.other_role
      targetname = other_role:QueryProp("Name")
      if other_role:FindProp("Photo") then
        photo = other_role:QueryProp("Photo")
        form_main_select.lbl_photo.BackImage = photo
      end
    end
    form_main_select.selectobjname = targetname
    main_origin = client_scene_obj:QueryProp("ShowOrigin")
    form_main_select.lbl_back.BackImage = back_image[1]
    local client_player = game_client:GetPlayer()
    if nx_id_equal(client_player, client_scene_obj) then
      form_main_select.btn_offline.Visible = false
      form_main_select.btn_info.Visible = false
      form_main_select.btn_copy.Visible = false
      form_main_select.btn_miliao.Visible = false
      form_main_select.btn_chakan.Visible = false
      form_main_select.btn_jiaohu.Visible = false
    else
      form_main_select.btn_offline.Visible = false
      form_main_select.btn_info.Visible = false
      form_main_select.btn_copy.Visible = false
      form_main_select.btn_miliao.Visible = false
      form_main_select.btn_chakan.Visible = false
      form_main_select.btn_jiaohu.Visible = false
    end
    form_main_select.prog_hp.ProgressImage = "gui\\mainform\\target\\pbr_target_hp.png"
  elseif objtype == TYPE_NPC then
    local game_client = nx_value("game_client")
    local client_self = game_client:GetPlayer()
    local fight = nx_value("fight")
    local can_attack = fight:CanAttackNpc(client_self, client_scene_obj)
    if can_attack then
      if client_scene_obj:QueryProp("NotPositive") == 0 then
        form_main_select.lbl_name.ForeColor = "255,233,103,103"
      end
      if client_scene_obj:QueryProp("NotPositive") == 1 then
        form_main_select.lbl_name.ForeColor = "255,235,208,118"
      end
    else
      form_main_select.lbl_name.ForeColor = "255,166,226,105"
    end
    local nameid = client_scene_obj:QueryProp("ConfigID")
    if client_scene_obj:FindProp("CKindID") then
      client_kind_npc = client_scene_obj:QueryProp("CKindID")
    end
    if tonumber(client_kind_npc) == 0 then
      form_main_select.lbl_name.Visible = true
      form_main_select.lbl_back.Visible = true
      form_main_select.lbl_photo.Visible = false
      form_main_select.buff_groupbox.Visible = true
      form_main_select.btn_jiaohu.Visible = false
      form_main_select.btn_miliao.Visible = false
      form_main_select.btn_chakan.Visible = false
      if client_scene_obj:FindProp("BossLevel") then
        local BossLevel = client_scene_obj:QueryProp("BossLevel")
        if nx_int(BossLevel) == nx_int(1) then
          form_main_select.lbl_back.BackImage = back_image[2]
        elseif nx_int(BossLevel) == nx_int(2) then
          form_main_select.lbl_back.BackImage = back_image[3]
        elseif nx_int(BossLevel) == nx_int(3) then
          form_main_select.lbl_back.BackImage = back_image[4]
        elseif nx_int(BossLevel) == nx_int(4) then
          form_main_select.lbl_back.BackImage = back_image[5]
        end
      end
      local npc_type = client_scene_obj:QueryProp("NpcType")
      local b_has_IDCard = false
      if client_scene_obj:FindProp("IDCard") then
        b_has_IDCard = true
      else
        b_has_IDCard = false
      end
      if b_has_IDCard then
        local info_str = client_scene_obj:QueryProp("IDCard")
        local info_lst = util_split_string(info_str, ",")
        local text_call = info_lst[5]
        local fname = info_lst[1]
        local sname = info_lst[2]
        local name = ""
        if fname == "null" and sname == "null" then
          name = nx_string(gui.TextManager:GetText(nx_string(nameid)))
        else
          name = nx_string(gui.TextManager:GetText(nx_string(fname))) .. nx_string(gui.TextManager:GetText(nx_string(sname)))
        end
        local origin_text = gui.TextManager:GetText(nameid .. "_1")
        if nx_string(origin_text) == nx_string(nameid .. "_1") then
          origin_text = ""
        else
        end
        local tmp_text_call = gui.TextManager:GetText(nx_string(text_call))
        if text_call == "null" or text_call == "" or nx_string(tmp_text_call) == nx_string(text_call) then
          if nx_string(origin_text) == nx_string("") then
            targetname = nx_widestr(name)
          else
            targetname = nx_widestr(nx_string(origin_text) .. nx_string("-") .. nx_string(name))
          end
        elseif nx_string(origin_text) == nx_string("") then
          targetname = nx_widestr(nx_string(tmp_text_call) .. name)
        else
          targetname = nx_widestr(nx_string(origin_text) .. nx_string("-") .. nx_string(tmp_text_call) .. nx_string(name))
        end
        targetname = nx_widestr(nx_string(name))
      else
        local origin_text = gui.TextManager:GetText(nameid .. "_1")
        if nx_string(origin_text) == nx_string(nameid .. "_1") then
          origin_text = ""
        else
        end
        local call_text = ""
        if client_scene_obj:FindProp("Call") then
          local tmp_text_call = nx_string(client_scene_obj:QueryProp("Call"))
          call_text = gui.TextManager:GetText(nx_string(tmp_text_call))
          if tmp_text_call == nx_string("") or nx_string(text_call) == nx_string(tmp_text_call) then
            call_text = ""
          else
          end
        else
          call_text = ""
        end
        if nx_string(origin_text) ~= nx_string("") then
          targetname = nx_string(origin_text) .. "-"
        end
        if nx_string(call_text) ~= nx_string("") then
          targetname = targetname .. nx_string(call_text)
        end
        targetname = nx_widestr(nx_string(targetname) .. nx_string(gui.TextManager:GetText(nameid)))
      end
      local school = ""
      if client_scene_obj:FindProp("School") then
        school = client_scene_obj:QueryProp("School")
        school = gui.TextManager:GetText(school)
      end
    elseif tonumber(client_kind_npc) == 1 then
      form_main_select.lbl_name.Visible = true
      form_main_select.lbl_back.Visible = true
      form_main_select.lbl_photo.Visible = false
      form_main_select.buff_groupbox.Visible = true
      form_main_select.btn_jiaohu.Visible = true
      form_main_select.btn_miliao.Visible = false
      form_main_select.btn_chakan.Visible = false
      targetname = gui.TextManager:GetText(nameid)
    elseif tonumber(client_kind_npc) == 2 or tonumber(client_kind_npc) == 7 or tonumber(client_kind_npc) == 8 or tonumber(client_kind_npc) == 9 or tonumber(client_kind_npc) == 10 then
      form_main_select.lbl_name.Visible = true
      form_main_select.lbl_back.Visible = false
      form_main_select.lbl_photo.Visible = false
      form_main_select.buff_groupbox.Visible = false
      form_main_select.btn_jiaohu.Visible = true
      form_main_select.btn_miliao.Visible = false
      form_main_select.btn_chakan.Visible = false
      targetname = gui.TextManager:GetText(nameid)
    elseif tonumber(client_kind_npc) == 3 then
      form_main_select.lbl_name.Visible = true
      form_main_select.lbl_back.Visible = false
      form_main_select.lbl_photo.Visible = false
      form_main_select.buff_groupbox.Visible = false
      form_main_select.btn_jiaohu.Visible = false
      form_main_select.btn_miliao.Visible = false
      form_main_select.btn_chakan.Visible = false
      targetname = gui.TextManager:GetText(nameid)
    elseif tonumber(client_kind_npc) == 4 then
      form_main_select.lbl_name.Visible = true
      form_main_select.lbl_back.Visible = false
      form_main_select.lbl_photo.Visible = false
      form_main_select.buff_groupbox.Visible = false
      form_main_select.btn_jiaohu.Visible = false
      form_main_select.btn_miliao.Visible = false
      form_main_select.btn_chakan.Visible = false
      targetname = gui.TextManager:GetText(nameid)
      local ItemQuery = nx_value("ItemQuery")
      local bExist = ItemQuery:FindItemByConfigID(nx_string(nameid))
      if nx_is_valid(ItemQuery) and bExist then
        local Script = ItemQuery:GetItemPropByConfigID(nx_string(nameid), nx_string("script"))
        if nx_string(Script) == nx_string("InteractiveNpc") then
          form_main_select.lbl_back.Visible = true
        end
      end
    elseif tonumber(client_kind_npc) == 5 then
      form_main_select.lbl_name.Visible = true
      form_main_select.lbl_back.Visible = false
      form_main_select.lbl_photo.Visible = false
      form_main_select.buff_groupbox.Visible = false
      form_main_select.btn_jiaohu.Visible = true
      form_main_select.btn_miliao.Visible = false
      form_main_select.btn_chakan.Visible = false
      targetname = gui.TextManager:GetText(nameid)
    elseif tonumber(client_kind_npc) == 6 then
      form_main_select.lbl_name.Visible = true
      form_main_select.lbl_back.Visible = true
      form_main_select.lbl_photo.Visible = false
      form_main_select.buff_groupbox.Visible = false
      form_main_select.btn_jiaohu.Visible = false
      form_main_select.btn_miliao.Visible = false
      form_main_select.btn_chakan.Visible = false
      targetname = gui.TextManager:GetText(nameid)
    end
    if client_scene_obj:FindProp("HPRatio") then
      form_main_select.prog_hp.Value = client_scene_obj:QueryProp("HPRatio")
    else
      form_main_select.prog_hp.Value = 100
    end
    if client_scene_obj:FindProp("MPRatio") then
      form_main_select.prog_mp.Value = client_scene_obj:QueryProp("MPRatio")
    else
      form_main_select.prog_mp.Value = 0
    end
    form_main_select.prog_hp.tge_value = form_main_select.prog_hp.Value
    form_main_select.prog_hp.sat_value = form_main_select.prog_hp.Value
    form_main_select.prog_hp.cur_value = form_main_select.prog_hp.Value
    form_main_select.prog_mp.tge_value = form_main_select.prog_mp.Value
    form_main_select.prog_mp.sat_value = form_main_select.prog_mp.Value
    form_main_select.prog_mp.cur_value = form_main_select.prog_mp.Value
    if 0 ~= nx_number(form_main_select.prog_mp.Value) then
      form_main_select.lbl_back.BackImage = "gui\\mainform\\target\\bg_target.png"
    else
      form_main_select.lbl_back.BackImage = "gui\\mainform\\target\\bg_target_2.png"
    end
    form_main_select.prog_hp.tge_value = form_main_select.prog_hp.Value
    form_main_select.prog_hp.sat_value = form_main_select.prog_hp.Value
    form_main_select.prog_hp.cur_value = form_main_select.prog_hp.Value
    if can_attack then
      form_main_select.prog_hp.ProgressImage = "gui\\mainform\\target\\pbr_target_hp.png"
    else
      form_main_select.prog_hp.ProgressImage = "gui\\mainform\\target\\pbr_target_friend.png"
    end
    form_main_select.btn_offline.Visible = false
    form_main_select.btn_info.Visible = false
    form_main_select.btn_copy.Visible = false
    form_main_select.btn_miliao.Visible = false
    form_main_select.btn_chakan.Visible = false
    form_main_select.btn_jiaohu.Visible = false
    local npc_type = nx_number(client_scene_obj:QueryProp("NpcType"))
    if npc_type == NpcType201 and nx_string(client_scene_obj:QueryProp("Owner")) ~= "0" then
      targetname = nx_widestr(nx_string(targetname) .. "(" .. nx_string(client_scene_obj:QueryProp("Owner")) .. ")")
    end
  end
  form_main_select.lbl_back.Visible = true
  form_main_select.lbl_photo.Visible = false
  form_main_select.lbl_name.Text = targetname
  form_main_select.Visible = true
  local w = form_main_select.lbl_name.TextWidth
  if objtype == TYPE_PLAYER then
    local sel_obj = nx_value(GAME_SELECT_OBJECT)
    if nx_is_valid(sel_obj) then
      local shcool_id = sel_obj:QueryProp("School")
      form_main_select.lbl_menpai.Visible = true
      form_main_select.lbl_menpai.Text = nx_widestr(get_school_name(nx_string(shcool_id)))
      local w_t = form_main_select.lbl_menpai.TextWidth
      form_main_select.lbl_menpai.Left = form_main_select.Width + form_main_select.lbl_name.Left - w + w_t - 2 * form_main_select.lbl_name.TextOffsetX - 15
    else
      form_main_select.lbl_menpai.Visible = false
    end
  elseif objtype == TYPE_NPC then
    form_main_select.lbl_menpai.Visible = false
  end
  on_refresh_face(form_main_select, client_scene_obj)
  update_button_pos(form_main_select, client_scene_obj)
  cur_select_obj = client_scene_obj
  local photo = get_scene_obj_strength_photo(client_scene_obj)
  if tonumber(client_kind_npc) == 4 then
    form_main_select.lbl_level.BackImage = ""
  else
    form_main_select.lbl_level.BackImage = photo
  end
  local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
  if bMovie and form_main_select.Visible then
    form_main_select.Visible = false
    nx_execute("form_stage_main\\form_movie_new", "add_hide_control", form_main_select)
  end
  if client_scene_obj:FindProp("LogicState") and client_scene_obj:QueryProp("LogicState") == 106 then
    refresh_hpradio_sel(form_main_select.prog_hp, "HPRatio", "int", 100)
  elseif client_scene_obj:FindProp("HPRatio") then
    refresh_hpradio_sel(form_main_select.prog_hp, "HPRatio", "int", client_scene_obj:QueryProp("HPRatio"))
  end
  if client_scene_obj:FindProp("HitHPRatio") then
    refresh_hit_hp_tge_value_sel(form_main_select.prog_resume_hp, "HitHPRatio", "int", client_scene_obj:QueryProp("HitHPRatio"))
  end
end
function refresh_school(form, prop_name, prop_type, prop_value)
  local gui = nx_value("gui")
  form.lbl_menpai.Text = nx_widestr(get_school_name(nx_string(prop_value)))
end
function refresh_color(form, prop_name, prop_type, prop_value)
  local sel_obj = nx_value(GAME_SELECT_OBJECT)
  if nx_is_valid(sel_obj) then
    local color = nx_execute("head_game", "get_player_name_color", sel_obj)
    form.lbl_name.ForeColor = color_hex_d(color)
  end
end
function update_button_pos(form, client_scene_obj)
  if not nx_is_valid(client_scene_obj) then
    return
  end
  form.btn_flag.Visible = false
  local obj_type = client_scene_obj:QueryProp("Type")
  if obj_type == TYPE_PLAYER then
    local abs_top = form.btn_flag.AbsTop
    local abs_left = form.btn_flag.AbsLeft
    form.btn_miliao.AbsLeft = form.btn_flag.AbsLeft
    form.btn_miliao.AbsTop = abs_top
    form.btn_offline.AbsLeft = form.btn_flag.AbsLeft
    form.btn_offline.AbsTop = abs_top
    abs_left = abs_left - form.btn_chakan.Width
    form.btn_chakan.AbsLeft = abs_left
    form.btn_chakan.AbsTop = abs_top
    abs_left = abs_left - form.btn_jiaohu.Width
    form.btn_jiaohu.AbsLeft = abs_left
    form.btn_jiaohu.AbsTop = abs_top
  elseif obj_type == TYPE_NPC then
    local abs_top = form.btn_flag.AbsTop
    local abs_left = form.btn_flag.AbsLeft
    form.btn_info.AbsLeft = form.btn_flag.AbsLeft
    form.btn_info.AbsTop = abs_top
    abs_left = abs_left - form.btn_copy.Width
    form.btn_copy.AbsLeft = abs_left
    form.btn_copy.AbsTop = abs_top
  end
end
function get_school_name(school_id)
  local gui = nx_value("gui")
  local school_name = ""
  if school_id == "school_shaolin" then
    school_name = gui.TextManager:GetText("ui_neigong_category_sl")
  elseif school_id == "school_wudang" then
    school_name = gui.TextManager:GetText("ui_neigong_category_wd")
  elseif school_id == "school_emei" then
    school_name = gui.TextManager:GetText("ui_neigong_category_em")
  elseif school_id == "school_junzitang" then
    school_name = gui.TextManager:GetText("ui_neigong_category_jz")
  elseif school_id == "school_jinyiwei" then
    school_name = gui.TextManager:GetText("ui_neigong_category_jy")
  elseif school_id == "school_jilegu" then
    school_name = gui.TextManager:GetText("ui_neigong_category_jl")
  elseif school_id == "school_gaibang" then
    school_name = gui.TextManager:GetText("ui_neigong_category_gb")
  elseif school_id == "school_tangmen" then
    school_name = gui.TextManager:GetText("ui_neigong_category_tm")
  elseif school_id == "school_mingjiao" then
    school_name = gui.TextManager:GetText("ui_neigong_category_mj")
  elseif school_id == "school_tianshan" then
    school_name = gui.TextManager:GetText("ui_neigong_category_ts")
  else
    school_name = gui.TextManager:GetText("ui_task_school_null")
  end
  return nx_string(school_name)
end
function on_look_selectobj_prop(self)
  local selectobj = nx_value(GAME_SELECT_OBJECT)
  if not nx_is_valid(selectobj) then
    return 0
  end
  local target_type = selectobj:QueryProp("Type")
  if target_type == TYPE_PLAYER then
    local name = selectobj:QueryProp("Name")
    nx_execute("form_stage_main\\form_role_chakan", "get_player_info", name)
  end
  return 1
end
function on_show_selectobj_menu(self, x, y)
  local form = self.ParentForm
  local lbl = form.lbl_photo
  local gui = nx_value("gui")
  local target = nx_value("game_select_obj")
  if not nx_is_valid(target) then
    return
  end
  nx_execute("custom_sender", "custom_select_player_menu", target.Ident)
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "selectobj", "selectobj")
  nx_execute("menu_game", "menu_recompose", menu_game)
  local curx, cury = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, curx + 25, cury)
end
function refresh_hpradio_tar(progress_bar, prop_name, prop_type, prop_value)
  local sel_obj = nx_value(GAME_SELECT_OBJECT)
  if not nx_is_valid(sel_obj) then
    return
  end
  local tar_obj_id = sel_obj:QueryProp("LastObject")
  local game_client = nx_value("game_client")
  local tar_obj = game_client:GetSceneObj(nx_string(tar_obj_id))
  if nx_is_valid(tar_obj) then
    refresh_hpradio(progress_bar, prop_name, prop_type, prop_value, tar_obj)
  end
end
function refresh_hpradio_sel(progress_bar, prop_name, prop_type, prop_value)
  local sel_obj = nx_value(GAME_SELECT_OBJECT)
  if nx_is_valid(sel_obj) then
    refresh_hpradio(progress_bar, prop_name, prop_type, prop_value, sel_obj)
  end
end
function refresh_hpradio(progress_bar, prop_name, prop_type, prop_value, obj)
  if not nx_is_valid(obj) then
    return
  end
  progress_bar.tge_value = prop_value
  progress_bar.sat_value = progress_bar.cur_value
  progress_bar.cur_time = 0
end
function refresh_hit_hp_tge_value_sel(progress_bar, prop_name, prop_type, prop_value)
  local sel_obj = nx_value(GAME_SELECT_OBJECT)
  if nx_is_valid(sel_obj) then
    refresh_hit_hp_tge_value(progress_bar, prop_name, prop_type, prop_value, sel_obj)
  end
end
function refresh_hit_hp_tge_value_tar(progress_bar, prop_name, prop_type, prop_value)
  local sel_obj = nx_value(GAME_SELECT_OBJECT)
  if not nx_is_valid(sel_obj) then
    return
  end
  local tar_obj_id = sel_obj:QueryProp("LastObject")
  local game_client = nx_value("game_client")
  local tar_obj = game_client:GetSceneObj(nx_string(tar_obj_id))
  if nx_is_valid(tar_obj) and tar_obj:QueryProp("Type") == TYPE_PLAYER then
    progress_bar.Visible = true
    refresh_hpradio(progress_bar, prop_name, prop_type, prop_value, tar_obj)
  end
end
function refresh_hit_hp_tge_value(progress_bar, prop_name, prop_type, prop_value, obj)
  local sat_value = prop_value
  if 0 == progress_bar.cur_stage then
    progress_bar.sat_value = sat_value
    progress_bar.cur_value = sat_value
  elseif 2 == progress_bar.cur_stage then
    progress_bar.sat_value = prop_value
    progress_bar.cur_value = prop_value
  end
  progress_bar.cur_stage = 1
  progress_bar.tge_value = prop_value
  progress_bar.cur_time = 0
  progress_bar.Visible = true
end
function refresh_hit_hp_cur_value_sel(progress_bar, prop_name, prop_type, prop_value)
  local sel_obj = nx_value(GAME_SELECT_OBJECT)
  if nx_is_valid(sel_obj) then
    refresh_hit_hp_cur_value(progress_bar, prop_name, prop_type, prop_value, sel_obj)
  end
end
function refresh_hit_hp_cur_value_tar(progress_bar, prop_name, prop_type, prop_value)
  local sel_obj = nx_value(GAME_SELECT_OBJECT)
  if not nx_is_valid(sel_obj) then
    return
  end
  local tar_obj_id = sel_obj:QueryProp("LastObject")
  local game_client = nx_value("game_client")
  local tar_obj = game_client:GetSceneObj(nx_string(tar_obj_id))
  if nx_is_valid(tar_obj) then
    refresh_hit_hp_cur_value(progress_bar, prop_name, prop_type, prop_value, tar_obj)
  end
end
function refresh_hit_hp_cur_value(progress_bar, prop_name, prop_type, prop_value, obj)
  local tge_value = obj:QueryProp("HitHPRatio")
  if obj:QueryProp("Type") ~= TYPE_PLAYER then
    return
  end
  if 0 == progress_bar.cur_stage then
    progress_bar.sat_value = prop_value
    progress_bar.cur_value = prop_value
  elseif 2 == progress_bar.cur_stage then
    progress_bar.sat_value = prop_value
    progress_bar.cur_value = prop_value
  end
  progress_bar.cur_stage = 1
  progress_bar.Visible = true
  if 0 == tge_value then
    progress_bar.tge_value = tge_value
  end
  progress_bar.cur_time = 0
end
function refresh_mpradio_sel(progress_bar, prop_name, prop_type, prop_value)
  local sel_obj = nx_value(GAME_SELECT_OBJECT)
  if nx_is_valid(sel_obj) then
    refresh_mpradio(progress_bar, prop_name, prop_type, prop_value, sel_obj)
  end
end
function refresh_mpradio_tar(progress_bar, prop_name, prop_type, prop_value)
  local sel_obj = nx_value(GAME_SELECT_OBJECT)
  if not nx_is_valid(sel_obj) then
    return
  end
  local tar_obj_id = sel_obj:QueryProp("LastObject")
  local game_client = nx_value("game_client")
  local tar_obj = game_client:GetSceneObj(nx_string(tar_obj_id))
  if nx_is_valid(tar_obj) then
    refresh_mpradio(progress_bar, prop_name, prop_type, prop_value, tar_obj)
  end
end
function refresh_mpradio(progress_bar, prop_name, prop_type, prop_value, obj)
  if not nx_is_valid(obj) then
    return
  end
  local game_client = nx_value("game_client")
  progress_bar.tge_value = prop_value
  progress_bar.sat_value = progress_bar.cur_value
  progress_bar.cur_time = 0
end
function refresh_auto_select_object(form, prop_name, prop_type, prop_value)
  local game_client = nx_value("game_client")
  local sel_sel_obj = game_client:GetSceneObj(nx_string(prop_value))
  local sel_obj = nx_value(GAME_SELECT_OBJECT)
  if not (nx_is_valid(sel_obj) and nx_is_valid(sel_sel_obj)) or TYPE_PLAYER ~= sel_sel_obj:QueryProp("Type") then
    form.groupbox_select.Visible = false
    return
  end
  form.groupbox_select.Visible = true
  local prog_max_hp = 100
  local prog_max_mp = 100
  local prog_hp = sel_sel_obj:QueryProp("HPRatio")
  local prog_mp = sel_sel_obj:QueryProp("MPRatio")
  local client_player = game_client:GetPlayer()
  form.lbl_name_ex.Text = nx_widestr(sel_sel_obj:QueryProp("Name"))
  local school = sel_sel_obj:QueryProp("School")
  form.lbl_school.Text = nx_widestr(get_school_name(school))
  local photo = sel_sel_obj:QueryProp("Photo")
  form.pbar_hp.Value = prog_hp
  form.pbar_hp.Maximum = prog_max_hp
  form.pbar_hp.tge_value = form.pbar_hp.Value
  form.pbar_hp.sat_value = form.pbar_hp.cur_value
  form.pbar_resume_hp.obj = sel_sel_obj
end
function refresh_main_origin(self, prop_name, prop_type, prop_value)
  local form_main_select = nx_value("form_stage_main\\form_main\\form_main_select")
  if form_main_select.selectobjtype == TYPE_NPC then
    self.Text = nx_widestr("")
  elseif form_main_select.selectobjtype == TYPE_PLAYER then
    if prop_value == 0 or prop_value == "" then
      self.Text = nx_widestr("")
    else
      local gui = nx_value("gui")
      self.Text = gui.TextManager:GetText("ui_" .. nx_string(prop_value))
    end
  end
end
function on_groupbox_select_left_double_click(grid)
  local sel_obj = nx_value(GAME_SELECT_OBJECT)
  if not nx_is_valid(sel_obj) then
    return
  end
  local tar_obj_id = sel_obj:QueryProp("LastObject")
  local game_client = nx_value("game_client")
  local tar_obj = game_client:GetSceneObj(nx_string(tar_obj_id))
  nx_execute("custom_sender", "custom_select", tar_obj.Ident)
end
function on_select_photo_box_click(target_face)
  local game_visual = nx_value("game_visual")
  local select_obj_ident = nx_value("select_obj_ident")
  local visual_scene_object = game_visual:GetSceneObj(select_obj_ident)
  if nx_is_valid(visual_scene_object) then
    nx_execute("shortcut_game", "mouse_use_item", visual_scene_object, "left")
  end
end
function del_buff_icon(grid, index)
  grid:DelItem(nx_int(index))
end
function get_buff_level(buff_id, sender_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local SelectObj = nx_value(GAME_SELECT_OBJECT)
  if not nx_is_valid(SelectObj) then
    return
  end
  local result = nx_function("get_buffer_info", SelectObj, buff_id, sender_id)
  if result == nil or table.getn(result) < 3 then
    return
  end
  return result[1]
end
function on_imagegrid_buffer_mousein_grid(grid, index)
  local buff_info = nx_string(grid:GetItemName(index))
  if buff_info == "" or buff_info == nil then
    return 1
  end
  local info_lst = util_split_string(buff_info, ",")
  if table.getn(info_lst) < 2 then
    return 1
  end
  local buff_id = info_lst[1]
  local sender_id = info_lst[2]
  if buff_id == "" or buff_id == nil then
    return 1
  end
  if sender_id == nil then
    return 1
  end
  local level = get_buff_level(buff_id, sender_id)
  local str_index = "desc_" .. nx_string(buff_id) .. "_0"
  if level ~= nil and nx_int(level) > nx_int(0) then
    str_index = "desc_" .. nx_string(buff_id) .. "_" .. nx_string(level)
  end
  local gui = nx_value("gui")
  nx_execute("tips_game", "show_text_tip", gui.TextManager:GetText(str_index), grid:GetMouseInItemLeft() + 5, grid:GetMouseInItemTop() + 5, 0, grid.ParentForm)
  return 1
end
function on_imagegrid_buffer_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_jiaohu_click(btn)
  local menu_game = nx_value("menu_game")
  local gui = nx_value("gui")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
    menu_game.Visible = false
  end
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(menu_game) then
    if nx_find_custom(menu_game, "type") then
      local type = menu_game.type
      if type ~= "selectobj" and menu_game.Visible then
        menu_game.Visible = false
      end
    end
    menu_game.need_visible = not menu_game.Visible
  end
  timer:UnRegister("form_stage_main\\form_main\\form_main_select", "on_menu_visible_change", btn)
  timer:Register(10, 1, "form_stage_main\\form_main\\form_main_select", "on_menu_visible_change", btn, -1, -1)
end
function on_btn_chakan_click(btn)
  on_look_selectobj_prop()
end
function on_btn_miliao_click(btn)
  local form_main_select = nx_value("form_stage_main\\form_main\\form_main_select")
  local form = nx_value("form_stage_main\\form_main\\form_main_chat")
  local gui = nx_value("gui")
  form.chat_channel_btn.Text = gui.TextManager:GetText("ui_chat_channel_3")
  form.chat_edit.chat_type = 3
  gui.Focused = form.chat_edit
  local name = form_main_select.selectobjname
  form.chat_edit.Text = nx_widestr("")
  form.chat_edit:Append(nx_widestr(name), -1)
  form.chat_edit:Append(nx_widestr(" "), -1)
  nx_execute("form_stage_main\\form_main\\form_main_chat", "show_chat")
end
function on_btn_info_click(btn)
  on_look_selectobj_prop()
end
function on_btn_copy_click(btn)
  local sel_obj = nx_value(GAME_SELECT_OBJECT)
  if not nx_is_valid(sel_obj) then
    return
  end
  local name
  local target_type = sel_obj:QueryProp("Type")
  if TYPE_PLAYER == target_type then
    name = sel_obj:QueryProp("Name")
  else
    local config_id = sel_obj:QueryProp("ConfigID")
    local gui = nx_value("gui")
    name = gui.TextManager:GetText(config_id)
  end
  nx_function("ext_copy_wstr", nx_widestr(name))
end
function on_menu_visible_change(btn, need_visible)
  local form = nx_value("form_stage_main\\form_main\\form_main_select")
  if not nx_is_valid(form) then
    return
  end
  local menu_game = nx_value("menu_game")
  local gui = nx_value("gui")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  menu_game.Visible = menu_game.need_visible
  if menu_game.Visible then
    on_show_selectobj_menu(form.btn_jiaohu)
  end
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_main\\form_main_select")
  if not nx_is_valid(form) then
    return
  end
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    return
  end
  if not menu_game.Visible then
    return
  end
  if not nx_find_custom(menu_game, "type") then
    return
  end
  local type = menu_game.type
  if type == "selectobj" then
    menu_game.AbsLeft = form.btn_jiaohu.AbsLeft + form.btn_jiaohu.Width
    menu_game.AbsTop = form.btn_jiaohu.AbsTop + form.btn_jiaohu.Height
  end
end
function select_target_byName(playername)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_client) then
    return
  end
  if not nx_is_valid(game_visual) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local obj_list = client_scene:GetSceneObjList()
  for i = 1, table.maxn(obj_list) do
    local client_scene_obj = obj_list[i]
    local visual_scene_obj = game_visual:GetSceneObj(client_scene_obj.Ident)
    local type = client_scene_obj:QueryProp("Type")
    if type == TYPE_PLAYER then
      local Name = client_scene_obj:QueryProp("Name")
      if nx_string(playername) == nx_string(Name) then
        local fight = nx_value("fight")
        fight:SelectTarget(visual_scene_obj)
      end
    end
  end
end
function get_scene_obj_strength_photo(client_scene_obj)
  if not nx_is_valid(client_scene_obj) then
    return ""
  end
  if not client_scene_obj:FindProp("Level") and not client_scene_obj:FindProp("PowerLevel") then
    return ""
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if nx_id_equal(client_player, client_scene_obj) then
    return ""
  end
  local self_level = client_player:QueryProp("PowerLevel")
  local obj_level
  local obj_type = client_scene_obj:QueryProp("Type")
  if obj_type == TYPE_PLAYER then
    obj_level = client_scene_obj:QueryProp("PowerLevel")
  elseif obj_type == TYPE_NPC then
    obj_level = client_scene_obj:QueryProp("Level")
  end
  if nil == obj_level then
    return ""
  end
  local diff_level = obj_level - self_level
  if diff_level < -10 then
    return "gui\\special\\monster\\Lv_1.png"
  elseif -10 <= diff_level and diff_level <= 5 then
    return "gui\\special\\monster\\Lv_2.png"
  elseif 6 <= diff_level and diff_level <= 15 then
    return "gui\\special\\monster\\Lv_3.png"
  elseif 16 <= diff_level and diff_level <= 20 then
    return "gui\\special\\monster\\Lv_4.png"
  elseif 20 < diff_level then
    return "gui\\special\\monster\\Lv_5.png"
  end
  return ""
end
function get_scene_obj_strength_photo_special(client_scene_obj)
  if not nx_is_valid(client_scene_obj) then
    return ""
  end
  if not client_scene_obj:FindProp("Level") and not client_scene_obj:FindProp("PowerLevel") then
    return ""
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if nx_id_equal(client_player, client_scene_obj) then
    return ""
  end
  local self_level = client_player:QueryProp("PowerLevel")
  local obj_level
  local obj_type = client_scene_obj:QueryProp("Type")
  if obj_type == TYPE_PLAYER then
    obj_level = client_scene_obj:QueryProp("PowerLevel")
  elseif obj_type == TYPE_NPC then
    obj_level = client_scene_obj:QueryProp("Level")
  end
  if nil == obj_level then
    return ""
  end
  local diff_level = obj_level - self_level
  if diff_level < -10 then
    return "gui\\special\\monster\\mlv_1.png"
  elseif -10 <= diff_level and diff_level <= 5 then
    return "gui\\special\\monster\\mlv_2.png"
  elseif 6 <= diff_level and diff_level <= 15 then
    return "gui\\special\\monster\\mlv_3.png"
  elseif 16 <= diff_level and diff_level <= 20 then
    return "gui\\special\\monster\\mlv_4.png"
  elseif 20 < diff_level then
    return "gui\\special\\monster\\mlv_5.png"
  end
  return ""
end
function color_hex_d(color)
  local r = string.sub(color, 2, 3)
  local g = string.sub(color, 4, 5)
  local b = string.sub(color, 6, 7)
  return "\"255," .. string.format("%d", tonumber(r, 16)) .. "," .. string.format("%d", tonumber(g, 16)) .. "," .. string.format("%d", tonumber(b, 16)) .. "\""
end
function on_lbl_level_get_capture(lbl)
  if lbl.BackImage == "" then
    return
  end
  local gui = nx_value("gui")
  local textinfo = gui.TextManager:GetText("ui_select_lever")
  local x, y = gui:GetCursorPosition()
  x = x - 32
  show_text_tip(nx_widestr(textinfo), x, y, 100, lbl)
end
function on_lbl_level_lost_capture(lbl)
  if lbl.BackImage == "" then
    return
  end
  hide_tip(lbl)
end
function on_refresh_face(form, client_player)
  if not nx_is_valid(form.scenebox_1.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_1)
    form.scenebox_1.Scene.RoundScene = true
  end
  local scene = form.scenebox_1.Scene
  local select_type = client_player:QueryProp("Type")
  if nx_find_custom(form, "role_actor2") and nx_is_valid(form.role_actor2) then
    clear_form_model(form, form.role_actor2)
  end
  if nx_running(nx_current(), "on_refresh_npc_face") then
    nx_kill(nx_current(), "on_refresh_npc_face")
  end
  if nx_running(nx_current(), "on_refresh_role_face") then
    nx_kill(nx_current(), "on_refresh_role_face")
  end
  if select_type == TYPE_PLAYER then
    nx_execute(nx_current(), "on_refresh_role_face", form, scene, client_player, form.role_actor2)
  else
    nx_execute(nx_current(), "on_refresh_npc_face", form, scene, client_player, form.role_actor2)
  end
end
function get_pi(degree)
  return math.pi * degree / 180
end
function on_refresh_npc_face(form, scene, client_player, role_actor2)
  local npc_actor2 = nx_execute("role_composite", "create_scene_obj_composite", scene, client_player, true, "main_player")
  form.role_actor2 = npc_actor2
  if not nx_is_valid(npc_actor2) or not nx_is_valid(scene) then
    clear_form_model(form, role_actor2)
    return nx_null()
  end
  while nx_call("role_composite", "is_loading", 4, npc_actor2) do
    nx_pause(0)
  end
  local action_time_count = 0
  if not nx_is_valid(npc_actor2) then
    clear_form_model(form, role_actor2)
    return nx_null()
  end
  if npc_actor2:FindAction("ty_stand") ~= -1 then
    if npc_actor2:BlendAction("ty_stand", true, true) then
      while nx_is_valid(npc_actor2) and not (0 < npc_actor2:GetActionFrame("ty_stand")) and action_time_count < 0.2 do
        action_time_count = action_time_count + nx_pause(0.1)
      end
    end
  else
    if npc_actor2:FindAction("stand") ~= -1 and npc_actor2:BlendAction("stand", true, true) then
      while nx_is_valid(npc_actor2) and not (0 < npc_actor2:GetActionFrame("stand")) and action_time_count < 0.2 do
        action_time_count = action_time_count + nx_pause(0.1)
      end
    else
    end
  end
  if not nx_is_valid(npc_actor2) then
    clear_form_model(form, role_actor2)
    return nx_null()
  end
  clear_form_model(form, role_actor2)
  npc_actor2.Visible = false
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_1, npc_actor2)
  local time_count = 0
  form.role_actor2 = npc_actor2
  while time_count < 0.25 do
    time_count = time_count + nx_pause(0.1)
  end
  local r = 0.6
  local f_x, f_y, f_z = 0, 0, 0
  local is_angle = false
  if not nx_is_valid(npc_actor2) then
    clear_form_model(form, role_actor2)
    return nx_null()
  end
  if npc_actor2:NodeIsExist("BoneRUe05") then
    f_x, f_y, f_z = npc_actor2:GetNodePosition("BoneRUe05")
    is_angle = true
  end
  form.role_actor2 = npc_actor2
  if nx_find_custom(scene, "camera") and is_angle then
    local camera = scene.camera
    if nx_is_valid(camera) then
      camera:SetPosition(r * math.sin(get_pi(30)) + f_x, f_y, -1 * r * math.cos(get_pi(30)) + f_z)
      camera:SetAngle(0, get_pi(-30), 0)
      camera.Fov = 0.10416666666666667 * math.pi * 2
    end
  end
  npc_actor2.Visible = true
  local fov, far, near, target_dis, target_id = -1, -1, -1, -1, -1
  local c_p_x, c_p_y, c_p_z = -1, -1, -1
  local c_a_x, c_a_y, c_a_z = -1, -1, -1
  if nx_find_custom(scene, "camera") then
    local camera = scene.camera
    if nx_is_valid(camera) then
      local visual_list = npc_actor2:GetVisualList()
      for _, obj in ipairs(visual_list) do
        if "Skin" == nx_name(obj) then
          fov, far, near, target_dis, target_id = obj:GetCameraInfo("head_camera")
          c_p_x, c_p_y, c_p_z = obj:GetHelperPosition("", "head_camera")
          c_a_x, c_a_y, c_a_z = obj:GetHelperAngle("", "head_camera")
          if nil ~= c_p_x and nil ~= c_p_y and nil ~= c_p_z and nil ~= c_a_x and nil ~= c_a_y and nil ~= c_a_z and nx_find_custom(scene, "camera") then
            local camera = scene.camera
            if nx_is_valid(camera) then
              camera:SetPosition(-c_p_x, c_p_y, -c_p_z)
              camera:SetAngle(c_a_x, c_a_y, c_a_z)
              camera.Fov = fov
            end
          end
        end
      end
    end
  end
  return npc_actor2
end
function get_degree(i)
  return 180 * i / math.pi
end
function on_refresh_role_face(form, scene, client_player, actor2)
  local sex = client_player:QueryProp("Sex")
  if not nx_is_valid(scene) then
    clear_form_model(form, actor2)
    return nx_null()
  end
  local role_actor2 = nx_execute("role_composite", "create_actor2", scene)
  if not nx_is_valid(role_actor2) then
    return nx_null()
  end
  form.role_actor2 = role_actor2
  nx_execute("role_composite", "create_scene_obj_composite_with_actor2", scene, role_actor2, client_player, false, "main_player", true)
  if not nx_is_valid(role_actor2) then
    clear_form_model(form, actor2)
    return nx_null()
  end
  while nx_is_valid(role_actor2) and not role_actor2.LoadFinish do
    nx_pause(0.1)
  end
  if not nx_is_valid(role_actor2) then
    clear_form_model(form, actor2)
    return nx_null()
  end
  local actor_role = role_actor2:GetLinkObject("actor_role")
  local time_count = 0
  while nx_is_valid(role_actor2) and not nx_is_valid(actor_role) and time_count < 2 do
    actor_role = role_actor2:GetLinkObject("actor_role")
    time_count = time_count + nx_pause(0.1)
  end
  if not nx_is_valid(role_actor2) or not nx_is_valid(actor_role) then
    clear_form_model(form, actor2)
    return nx_null()
  end
  while nx_is_valid(role_actor2) and nx_is_valid(actor_role) and not actor_role.LoadFinish do
    time_count = time_count + nx_pause(0.1)
  end
  clear_form_model(form, actor2)
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_1, role_actor2)
  if sex == 0 then
    local action_module = nx_value("action_module")
    if nx_is_valid(action_module) then
      action_module:ChangeState(actor_role, "logoin_stand_2", true)
    end
  elseif sex == 1 then
    local action_module = nx_value("action_module")
    if nx_is_valid(action_module) then
      action_module:ChangeState(actor_role, "stand", true)
    end
  end
  local dr = sex == 0 and 0.55 or 0.5
  local dx = sex == 0 and 0.05 or 0
  local dh = sex == 0 and 1.67 or 1.58
  if nx_is_valid(actor_role) and nx_find_custom(scene, "camera") then
    local camera = scene.camera
    if nx_is_valid(camera) then
      camera:SetPosition(dr * math.sin(get_pi(30)) - dx, dh, -dr * math.cos(get_pi(30)))
      camera:SetAngle(0, get_pi(-30), 0)
    end
  end
  return role_actor2
end
function clear_form_model(form, role_actor2)
  if nx_is_valid(role_actor2) then
    form.scenebox_1.Scene:Delete(role_actor2)
  end
end
function is_check_npc_type(npc_type)
  if npc_type == 41 or npc_type == 42 or npc_type == 43 or npc_type == 44 or npc_type == 47 or npc_type == 68 or npc_type == 109 or npc_type == 138 or npc_type == 141 or npc_type == 142 or npc_type == 143 or npc_type == 144 or npc_type == 145 or npc_type == 146 or npc_type == 147 or npc_type == 148 or npc_type == 149 or npc_type == 150 or npc_type == 151 or npc_type == 152 or npc_type == 153 or npc_type == 161 or npc_type == 162 or npc_type == 163 or npc_type == 164 or npc_type == 167 or npc_type == 170 or npc_type == 171 or npc_type == 172 or npc_type == 173 or npc_type == 175 or npc_type == 176 or npc_type == 177 or npc_type == 180 or npc_type == 181 or npc_type == 77 then
    return true
  end
  return false
end
function show_select_skill(npc, time)
  local game_client = nx_value("game_client")
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local attacker_client = game_client:GetSceneObj(nx_string(npc))
  if not nx_is_valid(attacker_client) then
    return
  end
  local skill_id = attacker_client:QueryProp("CurSkillID")
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main_select", false, false)
  if not nx_is_valid(form) then
    return
  end
  local select_obj_ident = nx_value("select_obj_ident")
  if nx_string(npc) == nx_string(select_obj_ident) then
    local photo = nx_execute("util_static_data", "skill_static_query_by_id", skill_id, "Photo")
    if photo == "" or photo == nil then
      photo = skill_photo
    end
    form.imagegrid_curskill:AddItem(nx_int(0), photo, "", 0, -1)
    form.lbl_skillname.Text = nx_widestr(gui.TextManager:GetFormatText(skill_id))
    nx_execute(nx_current(), "show_skill_par", form, time)
  else
    form.groupbox_skill.Visible = false
  end
end
function show_skill_par(form, time)
  local space = nx_float(time / 30000)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_skill.Visible = true
  form.pbar_curskill.Minimum = 0
  form.pbar_curskill.Maxinum = 30
  form.pbar_curskill.Value = 0
  for i = 1, 30 do
    nx_pause(space)
    if not nx_is_valid(form.pbar_curskill) then
      return
    end
    form.pbar_curskill.Value = form.pbar_curskill.Value + 1
  end
  form.groupbox_skill.Visible = false
end
