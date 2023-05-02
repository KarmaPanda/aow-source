require("utils")
require("util_gui")
require("const_define")
require("custom_sender")
require("form_stage_main\\form_fight\\form_fight_main")
local FORM_FIGHT_MAIN = "form_stage_main\\form_fight\\form_fight_main"
local FORM_ROLE_LEFT = "form_stage_main\\form_fight\\form_fight_role_left"
local FORM_ROLE_RIGHT = "form_stage_main\\form_fight\\form_fight_role_right"
local FORM_MAIN_PLAYER = "form_stage_main\\form_main\\form_main_player"
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function main_form_init(self)
  self.Fixed = true
  self.player = nil
  self.role_face = nx_null()
  self.scene = nil
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    self.scene = game_client:GetScene()
  end
  return 1
end
function on_main_form_open(self)
  self.no_need_motion_alpha = true
  self.name = ""
  self.origin = ""
  self.buff_grid.unhelpful_total = 0
  self.buff_grid.helpful_total = 0
  self.pbar_hp.tge_value = 0
  self.pbar_hp.sat_value = 0
  self.pbar_hp.cur_value = 0
  self.pbar_hp.cur_ratio = 0.01
  self.pbar_hp.end_time = 2000
  self.pbar_hp.cur_time = 0
  self.pbar_resume_hp.tge_value = 0
  self.pbar_resume_hp.sat_value = 0
  self.pbar_resume_hp.cur_value = 0
  self.pbar_resume_hp.cur_ratio = 0.01
  self.pbar_resume_hp.cur_stage = 0
  self.pbar_resume_hp.Visible = false
  self.pbar_resume_hp.obj = self.player
  self.pbar_resume_hp.prop = "HP"
  self.pbar_resume_hp.end_time = 2000
  self.pbar_resume_hp.cur_time = 0
  self.pbar_mp.tge_value = 0
  self.pbar_mp.sat_value = 0
  self.pbar_mp.cur_value = 0
  self.pbar_mp.cur_ratio = 0.01
  self.pbar_mp.end_time = 2000
  self.pbar_mp.cur_time = 0
  self.lbl_a_nq1.Visible = false
  self.lbl_a_nq2.Visible = false
  self.lbl_a_nq3.Visible = false
  self.lbl_a_nq4.Visible = false
  self.lbl_a_nq5.Visible = false
  self.pbar_qinggong.Visible = false
  for i = 1, 10 do
    local contral_name = "lbl_win_" .. nx_string(i)
    local contral = self.groupbox_win_count:Find(contral_name)
    if nx_is_valid(contral) then
      contral.Visible = false
    end
  end
  bind_player(self)
  refresh_name(self)
  local main_player = get_player()
  if not nx_is_valid(main_player) then
    return
  end
  local player_name = main_player:QueryProp("Name")
  if is_arena_player(player_name) then
    self.btn_camera.Visible = false
  else
    self.btn_camera.Visible = true
  end
  if nx_string(self.player) == nx_string(main_player) then
    self.pbar_qinggong.Visible = true
    local form_main_buff = nx_value("form_stage_main\\form_main\\form_main_buff")
    if nx_is_valid(form_main_buff) then
      form_main_buff.Top = 100
      form_main_buff.Left = 50
      form_main_buff.Visible = true
      self.buff_groupbox.Visible = false
    end
    local databinder = nx_value("data_binder")
    if nx_is_valid(databinder) then
      databinder:AddRolePropertyBind("HPHeartSpeed", "int", self, FORM_MAIN_PLAYER, "on_hp_heart_speed_changed")
      databinder:AddRolePropertyBind("HPHeartSpeedAdd", "int", self, FORM_MAIN_PLAYER, "on_hp_heart_speed_changed")
      databinder:AddRolePropertyBind("MPHeartSpeed", "int", self, FORM_MAIN_PLAYER, "on_mp_heart_speed_changed")
      databinder:AddRolePropertyBind("MPHeartSpeedAdd", "int", self, FORM_MAIN_PLAYER, "on_mp_heart_speed_changed")
      databinder:AddRolePropertyBind("Dead", "int", self, FORM_MAIN_PLAYER, "refresh_hp")
      databinder:AddRolePropertyBind("HP", "int", self, FORM_MAIN_PLAYER, "refresh_hp")
      databinder:AddRolePropertyBind("MaxHP", "int", self, FORM_MAIN_PLAYER, "refresh_total_hp")
      databinder:AddRolePropertyBind("MaxHPAdd", "int", self, FORM_MAIN_PLAYER, "refresh_total_hp")
      databinder:AddRolePropertyBind("MaxHPMul", "int", self, FORM_MAIN_PLAYER, "refresh_total_hp")
      databinder:AddRolePropertyBind("HitHP", "int", self, FORM_MAIN_PLAYER, "refresh_hit_hp_tge_value")
      databinder:AddRolePropertyBind("MP", "int", self, FORM_MAIN_PLAYER, "refresh_mp")
      databinder:AddRolePropertyBind("MaxMP", "int", self, FORM_MAIN_PLAYER, "refresh_total_mp")
      databinder:AddRolePropertyBind("MaxMPAdd", "int", self, FORM_MAIN_PLAYER, "refresh_total_mp")
      databinder:AddRolePropertyBind("MaxMPMul", "int", self, FORM_MAIN_PLAYER, "refresh_total_mp")
      databinder:AddRolePropertyBind("QingGongPoint", "int", self.pbar_qinggong, FORM_MAIN_PLAYER, "refresh_qing_gong_point")
      databinder:AddRolePropertyBind("MaxQingGongPoint", "int", self.pbar_qinggong, FORM_MAIN_PLAYER, "refresh_qing_gong_point")
      databinder:AddRolePropertyBind("MaxQingGongPointAdd", "int", self.pbar_qinggong, FORM_MAIN_PLAYER, "refresh_qing_gong_point")
      databinder:AddRolePropertyBind("SP", "int", self, FORM_MAIN_PLAYER, "refresh_sp")
      databinder:AddRolePropertyBind("MaxSP", "int", self, FORM_MAIN_PLAYER, "refresh_sp")
      databinder:AddRolePropertyBind("MaxSPAdd", "int", self, FORM_MAIN_PLAYER, "refresh_sp")
    end
    nx_callback(self.pbar_state_hp, "on_get_capture", "on_pbar_state_hp_get_capture")
    nx_callback(self.pbar_state_hp, "on_lost_capture", "on_pbar_state_hp_lost_capture")
    nx_callback(self.pbar_state_mp, "on_get_capture", "on_pbar_state_mp_get_capture")
    nx_callback(self.pbar_state_mp, "on_lost_capture", "on_pbar_state_mp_lost_capture")
  end
end
function on_main_form_shut(form)
  if nx_is_valid(form.role_face) then
    local world = nx_value("world")
    world:Delete(form.role_face)
  end
end
function on_main_form_close(self)
  local main_player = get_player()
  if not nx_is_valid(main_player) then
    return
  end
  if nx_string(self.player) == nx_string(main_player) then
    local databinder = nx_value("data_binder")
    if nx_is_valid(databinder) then
      databinder:DelRolePropertyBind("HPHeartSpeed", self)
      databinder:DelRolePropertyBind("HPHeartSpeedAdd", self)
      databinder:DelRolePropertyBind("MPHeartSpeed", self)
      databinder:DelRolePropertyBind("MPHeartSpeedAdd", self)
      databinder:DelRolePropertyBind("Dead", self)
      databinder:DelRolePropertyBind("HP", self)
      databinder:DelRolePropertyBind("MaxHP", self)
      databinder:DelRolePropertyBind("MaxHPAdd", self)
      databinder:DelRolePropertyBind("MaxHPMul", self)
      databinder:DelRolePropertyBind("HitHP", self)
      databinder:DelRolePropertyBind("MP", self)
      databinder:DelRolePropertyBind("MaxMP", self)
      databinder:DelRolePropertyBind("MaxMPAdd", self)
      databinder:DelRolePropertyBind("MaxMPMul", self)
      databinder:DelRolePropertyBind("QingGongPoint", self.pbar_qinggong)
      databinder:DelRolePropertyBind("MaxQingGongPoint", self.pbar_qinggong)
      databinder:DelRolePropertyBind("MaxQingGongPointAdd", self.pbar_qinggong)
      databinder:DelRolePropertyBind("SP", self)
      databinder:DelRolePropertyBind("MaxSP", self)
      databinder:DelRolePropertyBind("MaxSPAdd", self)
    end
  end
  local asynor = nx_value("common_execute")
  if nx_is_valid(asynor) then
    asynor:RemoveExecute("ExecuteBuffersCyc", self)
    asynor:RemoveExecute("HPResume", self)
  end
  if nx_is_valid(self.role_face) and nx_is_valid(self.scenebox_role.Scene) then
    self.scenebox_role.Scene:Delete(self.role_face)
  end
  self.buff_grid.unhelpful_total = 0
  self.buff_grid.helpful_total = 0
end
function get_pi(degree)
  return math.pi * degree / 180
end
function exe_refresh_role_face(form)
  if not nx_is_valid(form) or nx_is_valid(form.role_face) then
    return
  end
  if not nx_is_valid(form.scenebox_role.Scene) then
    util_addscene_to_scenebox(form.scenebox_role)
    form.scenebox_role.Scene.RoundScene = true
  end
  local scene = form.scenebox_role.Scene
  local client_player = form.player
  if not nx_is_valid(client_player) then
    return
  end
  local sex = client_player:QueryProp("Sex")
  local dr = sex == 0 and 0.55 or 0.5
  local dx = sex == 0 and 0.01 or 0
  local dh = sex == 0 and 1.67 or 1.58
  local role_actor2 = nx_execute("role_composite", "create_actor2", scene, "create_scene_obj_composite")
  nx_execute("role_composite", "create_scene_obj_composite_with_actor2", scene, role_actor2, client_player, false, "main_player")
  form.role_face = role_actor2
  local time_count = 0
  if not nx_is_valid(role_actor2) then
    return
  end
  while not role_actor2.LoadFinish do
    time_count = time_count + nx_pause(0.1)
  end
  if not nx_is_valid(form) then
    return
  end
  if not nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_role, role_actor2) and nx_is_valid(form.role_face) then
    local world = nx_value("world")
    world:Delete(form.role_face)
  end
  if not nx_is_valid(role_actor2) then
    return 1
  end
  local actor_role = role_actor2:GetLinkObject("actor_role")
  time_count = 0
  if not nx_is_valid(actor_role) then
    while not nx_is_valid(actor_role) and time_count < 2 do
      actor_role = role_actor2:GetLinkObject("actor_role")
      time_count = time_count + nx_pause(0.1)
    end
  end
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(actor_role) then
    return 1
  end
  while not actor_role.LoadFinish do
    time_count = time_count + nx_pause(0.1)
  end
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(actor_role) then
    actor_role:BlendAction("logoin_stand_2", true, true)
  end
  local camera = form.scenebox_role.Scene.camera
  if nx_is_valid(camera) then
    camera:SetPosition(-dr * math.sin(get_pi(15)) + dx, dh, -dr * math.cos(get_pi(15)))
    camera:SetAngle(0, get_pi(15), 0)
  end
end
function on_btn_camera_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local target_object = form.player
  if not nx_is_valid(target_object) then
    return
  end
  local vis_target = game_visual:GetSceneObj(nx_string(target_object.Ident))
  if nx_is_valid(vis_target) then
    game_control.Target = vis_target
    game_control.TargetMode = 1
    nx_execute(FORM_FIGHT_MAIN, "on_btn_hide_self_click", nil)
  end
end
function bind_player(form)
  local scene = get_scene()
  if not nx_is_valid(scene) then
    return
  end
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  local player_name = client_player:QueryProp("Name")
  local player_nameA = scene:QueryProp("PlayerA")
  local player_nameB = scene:QueryProp("PlayerB")
  local target_name = ""
  if form.Name == FORM_ROLE_LEFT then
    if is_arena_player(player_name) then
      target_name = player_name
    else
      target_name = player_nameA
    end
  elseif form.Name == FORM_ROLE_RIGHT then
    if is_arena_player(player_name) then
      if player_name == player_nameA then
        target_name = player_nameB
      else
        target_name = player_nameA
      end
    else
      target_name = player_nameB
    end
  end
  local table_client_obj = scene:GetSceneObjList()
  for i = 1, #table_client_obj do
    local client_obj = table_client_obj[i]
    if client_obj:FindProp("Name") then
      local name = client_obj:QueryProp("Name")
      local obj_type = client_obj:QueryProp("Type")
      if nx_int(obj_type) == nx_int(2) and nx_string(name) == nx_string(target_name) then
        form.player = client_obj
      end
    end
  end
  exe_refresh_role_face(form)
  local asynor = nx_value("common_execute")
  asynor:RemoveExecute("ExecuteBuffersCyc", form)
  asynor:RemoveExecute("HPResume", form)
  asynor:AddExecute("ExecuteBuffersCyc", form, nx_float(0.015), form.player, form.Name)
  asynor:AddExecute("HPResume", form, nx_float(0), form.pbar_hp, form.pbar_mp, form.pbar_resume_hp, form.pbar_state_hp, form.pbar_state_mp)
end
function get_text_by_color(text, color)
  if nx_ws_length(nx_widestr(text)) < 1 then
    return ""
  end
  local _begin = "<font color=\"" .. nx_string(color) .. "\">"
  local _end = "</font>"
  text = nx_string(_begin) .. nx_string(text) .. nx_string(_end)
  return text
end
function refresh_name(form)
  local client_player = form.player
  if not nx_is_valid(client_player) then
    bind_player(form)
    return
  end
  form.name = nx_string(client_player:QueryProp("Name"))
  form.mltbox_name:Clear()
  local text1 = get_text_by_color(form.name, "#ffffff")
  form.mltbox_name:AddHtmlText(nx_widestr(text1), -1)
end
function refresh_skill(form)
  local client_player = form.player
  if not nx_is_valid(client_player) then
    bind_player(form)
    return
  end
  local skill_id = nx_string(client_player:QueryProp("CurSkillID"))
  if string.len(skill_id) > 1 then
    form.lbl_curskill.Text = nx_widestr(format_info(skill_id))
    form.lbl_curskill.Visible = true
  else
    form.lbl_curskill.Visible = false
  end
  refresh_hit_point(form)
end
function refresh_hit_point(form)
  local scene = form.scene
  if not nx_is_valid(scene) then
    return
  end
  local hit_point = 0
  local cur_player = form.player
  if not nx_is_valid(cur_player) then
    return
  end
  local player_name = cur_player:QueryProp("Name")
  if player_name == scene:QueryProp("PlayerA") then
    hit_point = scene:QueryProp("HitPointA")
  elseif player_name == scene:QueryProp("PlayerB") then
    hit_point = scene:QueryProp("HitPointB")
  end
  if hit_point == 0 then
    form.lbl_hit_point.Visible = false
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.lbl_hit_point.Text = gui.TextManager:GetFormatText("ui_arena_hitpoint", nx_int(hit_point))
  form.lbl_hit_point.Visible = true
end
function refresh_hp(form)
  local client_player = form.player
  if not nx_is_valid(client_player) then
    bind_player(form)
    return
  end
  local progress_bar = form.pbar_hp
  local hp = nx_number(client_player:QueryProp("HPRatio"))
  progress_bar.tge_value = hp
  progress_bar.sat_value = progress_bar.cur_value
  progress_bar.cur_time = 0
end
function refresh_hit_hp_tge_value(form)
  local client_player = form.player
  if not nx_is_valid(client_player) then
    bind_player(form)
    return
  end
  local sat_value = client_player:QueryProp("HitHPRatio")
  local progress_bar = form.pbar_resume_hp
  if 0 == progress_bar.cur_stage then
    progress_bar.sat_value = sat_value
    progress_bar.cur_value = sat_value
  elseif 2 == progress_bar.cur_stage then
    progress_bar.sat_value = sat_value
    progress_bar.cur_value = sat_value
  end
  progress_bar.Visible = true
  progress_bar.cur_stage = 1
  progress_bar.tge_value = sat_value
  progress_bar.cur_time = 0
end
function refresh_mp(form)
  local client_player = form.player
  if not nx_is_valid(client_player) then
    bind_player(form)
    return
  end
  local progress_bar = form.pbar_mp
  progress_bar.tge_value = nx_number(client_player:QueryProp("MPRatio"))
  progress_bar.sat_value = progress_bar.cur_value
  progress_bar.cur_value = progress_bar.Value
  progress_bar.cur_time = 0
end
function format_info(strid, ...)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName(strid)
  for i, para in pairs(arg) do
    local type = nx_type(para)
    if type == "number" then
      gui.TextManager:Format_AddParam(nx_int(para))
    elseif type == "string" then
      gui.TextManager:Format_AddParam(gui.TextManager:GetText(para))
    else
      gui.TextManager:Format_AddParam(para)
    end
  end
  local text = gui.TextManager:Format_GetText()
  text = string.gsub(nx_string(text), "%b()", "")
  local CH_begin, CH_end = string.find(nx_string(text), "\163\168")
  if CH_begin ~= nil then
    text = string.sub(nx_string(text), 1, CH_begin - 1)
  end
  return text
end
function refresh_sp(form)
  local player = form.player
  if not nx_is_valid(player) then
    return
  end
  local sp = nx_number(player:QueryProp("SP"))
  local gui = nx_value("gui")
  local text = nx_string(gui.TextManager:GetText("ui_nuqi")) .. ":" .. nx_string(sp)
  form.pbar_sp.HintText = nx_widestr(text)
  if 100 < sp then
    sp = 100
  end
  form.pbar_sp.Value = sp
  show_nuqi(sp, 100, form)
end
function show_nuqi(value, total, form)
  value = nx_number(value)
  local num = nx_int(value / total * 5)
  local close_image = "gui\\mainform\\role\\bg_nu_off.png"
  local open_image = "gui\\mainform\\role\\bg_nu_on.png"
  local lbl
  local name = ""
  num = nx_number(num)
  if num < 1 then
    num = 0
  end
  if 5 < num then
    num = 5
  end
  if 0 < num then
    for i = 1, num do
      name = "lbl_nq" .. nx_string(i)
      lbl = nx_custom(form, name)
      if nx_is_valid(lbl) then
        lbl.BackImage = open_image
      end
      name = "lbl_a_nq" .. nx_string(i)
      lbl = nx_custom(form, name)
      if nx_is_valid(lbl) then
        lbl.Visible = true
      end
    end
  end
  if num < 5 then
    for i = num + 1, 5 do
      name = "lbl_nq" .. nx_string(i)
      lbl = nx_custom(form, name)
      if nx_is_valid(lbl) then
        lbl.BackImage = close_image
      end
      name = "lbl_a_nq" .. nx_string(i)
      lbl = nx_custom(form, name)
      if nx_is_valid(lbl) then
        lbl.Visible = false
      end
    end
  end
  form.pbar_sp.Maximum = total
end
function get_buff_level(player, buff_id, sender_id)
  if not nx_is_valid(player) then
    return
  end
  local result = nx_function("get_buffer_info", player, buff_id, sender_id)
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
  local player = grid.ParentForm.player
  if not nx_is_valid(player) then
    return 1
  end
  local level = get_buff_level(player, buff_id, sender_id)
  local str_index = "desc_" .. nx_string(buff_id) .. "_0"
  if level ~= nil and nx_int(level) > nx_int(0) then
    str_index = "desc_" .. nx_string(buff_id) .. "_" .. nx_string(level)
  elseif level == nil then
    return 1
  end
  local gui = nx_value("gui")
  nx_execute("tips_game", "show_text_tip", gui.TextManager:GetText(str_index), grid:GetMouseInItemLeft() + 5, grid:GetMouseInItemTop() + 5, 0, grid.ParentForm)
  return 1
end
function on_imagegrid_buffer_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_buff_grid_doubleclick_grid(grid, index)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 1
  end
  local player_name = client_player:QueryProp("Name")
  local form_player = grid.ParentForm.player
  if not nx_is_valid(form_player) then
    return 1
  end
  if player_name ~= form_player:QueryProp("Name") then
    return 1
  end
  local buff_info = nx_string(grid:GetItemName(index))
  if buff_info == "" or buff_info == nil then
    return 1
  end
  local info_lst = util_split_string(buff_info, ",")
  if table.getn(info_lst) < 2 then
    return 1
  end
  local buff_id = info_lst[1]
  if buff_id == "" or buff_id == nil then
    return 1
  end
  nx_execute("custom_sender", "custom_remove_buffer", buff_id)
end
function resize_buff_groupbox(form)
  local unhelpful_total = form.buff_grid.unhelpful_total
  local helpful_total = form.buff_grid.helpful_total
  local row_num = form.buff_grid.RowNum
  local clomn_num = form.buff_grid.ClomnNum
  local grid_rows = 0
  local grid_clo = 0
  if 0 < unhelpful_total and unhelpful_total <= clomn_num then
    grid_rows = 1
    grid_clo = unhelpful_total
  elseif unhelpful_total > clomn_num and unhelpful_total <= 2 * clomn_num then
    grid_rows = 2
    grid_clo = clomn_num
  elseif unhelpful_total > 2 * clomn_num then
    grid_rows = 3
    grid_clo = clomn_num
  end
  if 0 < helpful_total and helpful_total <= clomn_num then
    grid_rows = grid_rows + 1
    if helpful_total > grid_clo then
      grid_clo = helpful_total
    end
  elseif helpful_total > clomn_num and helpful_total <= 2 * clomn_num then
    grid_rows = grid_rows + 2
    grid_clo = clomn_num
  elseif helpful_total > 2 * clomn_num then
    grid_rows = grid_rows + 3
    grid_clo = clomn_num
  end
  if row_num < grid_rows then
    grid_rows = row_num
  end
  form.buff_groupbox.Height = grid_rows * 35
  form.buff_groupbox.Width = grid_clo * 35
  if form.Name == FORM_ROLE_RIGHT then
    form.buff_groupbox.Top = form.groupbox_win_count.Top + form.groupbox_win_count.Height
    form.buff_groupbox.Left = form.groupbox_win_count.Left + form.groupbox_win_count.Width - form.buff_groupbox.Width
  end
end
function on_pbar_state_hp_get_capture(progres)
  nx_execute("form_stage_main\\form_main\\form_main_player", "show_state_tips", progres, "HP", "ui_g_hp", "ui_state_hp")
end
function on_pbar_state_hp_lost_capture(progres)
  nx_execute("tips_game", "hide_tip")
end
function on_pbar_state_mp_get_capture(progres)
  nx_execute("form_stage_main\\form_main\\form_main_player", "show_state_tips", progres, "MP", "ui_g_mp", "ui_state_mp")
end
function on_pbar_state_mp_lost_capture(progres)
  nx_execute("tips_game", "hide_tip")
end
