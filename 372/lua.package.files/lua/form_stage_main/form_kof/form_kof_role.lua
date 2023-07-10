require("utils")
require("util_gui")
require("const_define")
require("custom_sender")
require("form_stage_main\\form_huashan\\huashan_function")
require("form_stage_main\\form_kof\\kof_util")
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function main_form_init(self)
  self.Fixed = true
  self.role_face = nx_null()
  self.playername = nx_widestr("")
  self.player = nx_null()
  self.notes_space = 0
  return 1
end
function on_main_form_open(self)
  self.no_need_motion_alpha = true
  self.name = ""
  self.sub_stage = 0
  self.pbar_hp.lasthp = 0
  self.pbar_mp.lastmp = 0
  self.notes_space = 0
  self.canshowsprite = true
  self.groupbox_win_count.wintimes = nx_int(0)
  self.buff_grid.unhelpful_total = 0
  self.buff_grid.helpful_total = 0
  self.buff_grid.refresh_grid_height = 35
  self.lbl_a_nq1.Visible = false
  self.lbl_a_nq2.Visible = false
  self.lbl_a_nq3.Visible = false
  self.lbl_a_nq4.Visible = false
  self.lbl_a_nq5.Visible = false
  self.pbar_qinggong.Visible = false
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
  local asynor = nx_value("common_execute")
  if nx_is_valid(asynor) then
    asynor:RemoveExecute("ExecuteBuffersCyc", self)
  end
  if nx_is_valid(self.role_face) and nx_is_valid(self.scenebox_role.Scene) then
    self.scenebox_role.Scene:Delete(self.role_face)
  end
  self.buff_grid.unhelpful_total = 0
  self.buff_grid.helpful_total = 0
end
function remove_buff_cyc(form)
  local asynor = nx_value("common_execute")
  asynor:RemoveExecute("ExecuteBuffersCyc", form)
end
function add_buff_cyc(form)
  local asynor = nx_value("common_execute")
  asynor:RemoveExecute("ExecuteBuffersCyc", form)
  asynor:AddExecute("ExecuteBuffersCyc", form, nx_float(0.015), form.player, form.Name)
end
function bind_player(form)
  if nx_widestr("") == form.playername then
    return
  end
  if form.player ~= nil and nx_is_valid(form.player) and nx_widestr(form.playername) == nx_widestr(form.player:QueryProp("Name")) then
    return
  end
  local scene = get_scene()
  if not nx_is_valid(scene) then
    return
  end
  local table_client_obj = scene:GetSceneObjList()
  for i = 1, #table_client_obj do
    local client_obj = table_client_obj[i]
    if client_obj:FindProp("Name") then
      local name = client_obj:QueryProp("Name")
      local obj_type = client_obj:QueryProp("Type")
      if nx_int(obj_type) == nx_int(2) and nx_string(name) == nx_string(form.playername) then
        form.player = client_obj
      end
    end
  end
  if not nx_is_valid(form.player) then
    return
  end
  exe_refresh_role_face(form)
  local asynor = nx_value("common_execute")
  asynor:RemoveExecute("ExecuteBuffersCyc", form)
  asynor:AddExecute("ExecuteBuffersCyc", form, nx_float(0.015), form.player, form.Name)
end
function refresh_name(form)
  if not nx_is_valid(form.player) then
    if 0 == form.notes_space then
    end
    form.notes_space = form.notes_space + 1
    if 10 == form.notes_space then
      form.notes_space = 0
    end
    bind_player(form)
    return
  end
  form.mltbox_name:Clear()
  form.name = form.player:QueryProp("Name")
  form.mltbox_name:AddHtmlText(nx_widestr(form.name), -1)
  local schoolid = nx_string(form.player:QueryProp("School"))
  if "" ~= nx_string(schoolid) and string.len(schoolid) > 6 then
    form.lbl_school.Text = util_text(schoolid)
  end
end
function refresh_form(form, view)
  if not nx_is_valid(form) or not nx_is_valid(view) then
    return
  end
  local player_name = view:QueryProp("KofPlayer")
  form.playername = player_name
  bind_player(form)
  refresh_name(form)
  local DamageAll = view:QueryProp("KofDamageAll")
  local DamageMax = view:QueryProp("KofDamageMax")
  local FightDodge = view:QueryProp("KofDodge")
  local FightVa = view:QueryProp("KofVa")
  local FightBreakParry = view:QueryProp("KofBreakParry")
  local FightParry = view:QueryProp("KofParry")
  local FightLastTime = view:QueryProp("KofLastTime")
  local DamagePerSec = 0
  local HP = view:QueryProp("KofHP")
  local MaxHP = view:QueryProp("KofMaxHP")
  local MP = view:QueryProp("KofMP")
  local MaxMP = view:QueryProp("KofMaxMP")
  local sec_FightLastTime = FightLastTime
  if 0 < sec_FightLastTime then
    DamagePerSec = DamageAll / sec_FightLastTime
  end
  form.lbl_stat_val_1.Text = nx_widestr(DamageAll)
  form.lbl_stat_val_2.Text = nx_widestr(DamageMax)
  form.lbl_stat_val_3.Text = nx_widestr(nx_int(DamagePerSec))
  form.lbl_stat_val_4.Text = nx_widestr(FightParry)
  form.lbl_stat_val_5.Text = nx_widestr(FightDodge)
  form.lbl_stat_val_6.Text = nx_widestr(FightVa)
  form.lbl_stat_val_7.Text = nx_widestr(FightBreakParry)
  refresh_hp(form, nx_number(HP), nx_number(MaxHP))
  refresh_mp(form, nx_number(MP), nx_number(MaxMP))
  refresh_sp(form)
end
function refresh_skill_new(form, player, skill_id)
  if not nx_is_valid(form.player) then
    return
  end
  if form.player.Ident ~= player.Ident then
    return
  end
  if string.len(skill_id) < 3 then
    return
  end
  if form.canshowsprite then
  end
  form.mltbox_skill:AddHtmlText(nx_widestr(format_info(skill_id)), -1)
end
function refresh_skill(form)
  if not nx_is_valid(form.player) then
    return
  end
  local skill_id = nx_string(form.player:QueryProp("CurSkillID"))
  if string.len(skill_id) < 3 then
    return
  end
  if form.canshowsprite then
  end
  form.mltbox_skill:AddHtmlText(nx_widestr(format_info(skill_id)), -1)
end
function refresh_hp(form, HP, MaxHP)
  if MaxHP < HP then
    return
  end
  local progress_bar = form.pbar_hp
  progress_bar.Maximum = MaxHP
  progress_bar.Minimun = 0
  progress_bar.Value = HP
  local player = form.player
  if nx_is_valid(player) then
    form.pbar_resume_hp.Value = form.player:QueryProp("HitHPRatio")
  end
  local value = HP - progress_bar.lasthp
  if value == 0 then
    return
  elseif 0 < value then
    self_SpriteManager(form, "self_AddHP", nx_string(value))
  else
    self_SpriteManager(form, "self_Damage", nx_string(value))
  end
  progress_bar.lasthp = HP
end
function refresh_mp(form, MP, MaxMP)
  local progress_bar = form.pbar_mp
  progress_bar.Maximum = MaxMP
  progress_bar.Minimun = 0
  progress_bar.Value = MP
  local value = MP - progress_bar.lastmp
  if value == 0 then
    return
  elseif 0 < value then
    self_SpriteManager(form, "self_AddMP", nx_string(value))
  else
    self_SpriteManager(form, "self_AddMP", nx_string(value))
  end
  progress_bar.lastmp = MP
end
function refresh_sp(form)
  if not nx_is_valid(form.player) then
    return
  end
  local sp = nx_number(form.player:QueryProp("SP"))
  local gui = nx_value("gui")
  local text = nx_string(gui.TextManager:GetText("ui_nuqi")) .. ":" .. nx_string(sp)
  form.pbar_sp.HintText = nx_widestr(text)
  if 100 < sp then
    sp = 100
  end
  form.pbar_sp.Value = sp
  show_nuqi(sp, 100, form)
end
function set_win_num(form, fightmsg)
  if "" == fightmsg then
    return
  end
  local msgs = util_split_string(fightmsg, ";")
  if table.maxn(msgs) < 3 then
    return
  end
  local count = nx_number(msgs[3])
  if count <= 0 or 10 < count then
    return
  end
  local winnum = nx_int(msgs[2])
  if winnum == form.groupbox_win_count.wintimes then
    return
  end
  form.groupbox_win_count.wintimes = winnum
  for i = 1, count do
    local y = nx_number(winnum) % 10
    local contral_name = "lbl_win_" .. nx_string(i)
    local contral = form.groupbox_win_count:Find(contral_name)
    if nx_is_valid(contral) then
      contral.Visible = true
      if y ~= 0 then
        contral.BackImage = "gui\\special\\huashan\\bg_visit_lighton.png"
      else
        contral.BackImage = "gui\\special\\huashan\\bg_visit_lightout.png"
      end
    end
    winnum = nx_int(winnum / 10)
  end
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
  return gui.TextManager:Format_GetText()
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
function on_btn_view_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.sub_stage == KOF_ROUND_STAGE_END then
    return
  end
  if not nx_is_valid(form.player) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_player = game_visual:GetSceneObj(form.player.Ident)
  local client_player = game_visual:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local game_control = client_player.scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  game_control.Target = visual_player
  game_control.TargetMode = 1
end
function on_btn_statistical_min_max_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_statistical.Visible = not form.groupbox_statistical.Visible
end
function on_btn_buff_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.buff_groupbox.Visible = not form.buff_groupbox.Visible
end
function on_btn_sprite_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.canshowsprite = not form.canshowsprite
end
function on_btn_skill_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_skill.Visible = not form.groupbox_skill.Visible
end
function on_btn_role_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.player) then
    return
  end
  nx_execute("form_stage_main\\form_role_chakan", "get_player_info", form.playername)
end
function get_pi(degree)
  return math.pi * degree / 180
end
function exe_refresh_role_face(form)
  if nx_is_valid(form.role_face) then
    local world = nx_value("world")
    world:Delete(form.role_face)
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
function a(b)
  nx_msgbox(nx_string(b))
end
