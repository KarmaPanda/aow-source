require("define\\move_define")
require("util_functions")
require("share\\logicstate_define")
require("player_state\\state_input")
require("player_state\\logic_const")
require("define\\team_rec_define")
curse_text_id = {
  chaolu = "ui_custom_chaolu",
  tanzou = "ui_custom_tanzou",
  qitao = "ui_custom_qitao",
  suangua = "ui_custom_suangua",
  zhongzhi = "ui_custom_zhongzhi",
  shouge = "ui_custom_shouge"
}
ERR_ANGLE = -99
function create_balloon(target_ident, text, font_name, color, left_offset, top_offset, x_scale, y_scale)
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(target_ident)
  if not nx_is_valid(visual_scene_obj) then
    return nx_null()
  end
  local gui = nx_value("gui")
  local balls = nx_value("balls")
  local label = gui:Create("Label")
  label.Font = font_name
  label.Width = 128
  label.Align = "Center"
  local ball = balls:AddBalloon(label, visual_scene_obj, 0)
  ball.Name = "custom_effect:create_balloon:" .. nx_string(visual_scene_obj)
  ball.BindY = visual_scene_obj.height
  ball.NearDistance = 0
  ball.FarDistance = 200
  ball.Control.model = visual_scene_obj
  ball.MustVisible = true
  ball.Control.Text = text
  ball.Control.ForeColor = "255," .. color
  ball.OffsetLeft = left_offset
  ball.OffsetTop = top_offset
  local times = 0
  local speed = 300
  if up_speed ~= nil then
    speed = up_speed
  end
  local rand_pos = 3 - math.random(5)
  local alpha = 255
  while true do
    local sep = nx_pause(0)
    times = times + sep
    if not nx_is_valid(ball) then
      return
    end
    if x_scale ~= nil then
      if times < 0.3 then
        ball.OffsetLeft = ball.OffsetLeft + nx_float((x_scale + rand_pos) * times / 0.7)
      else
        ball.OffsetLeft = ball.OffsetLeft + nx_float((x_scale + rand_pos) * (1 - times) / 0.7)
      end
    end
    if y_scale ~= nil then
      if times < 0.2 then
        ball.OffsetTop = ball.OffsetTop - nx_float((y_scale + rand_pos) * times / 0.8)
      else
        ball.OffsetTop = ball.OffsetTop - nx_float((y_scale + rand_pos) * (1 - times) / 0.8)
      end
    end
    if 0.5 < times then
      alpha = math.floor(alpha - sep * 255)
      if alpha < 0 then
        alpha = 0
        break
      end
      ball.Control.ForeColor = nx_string(nx_int(alpha)) .. "," .. color
    end
  end
  delete_balloon(ball)
end
function delete_balloon(ball)
  if not nx_is_valid(ball) then
    return
  end
  local gui = nx_value("gui")
  local balls = nx_value("balls")
  if nx_is_valid(gui) and nx_is_valid(ball) and nx_is_valid(ball.Control) then
    gui:Delete(ball.Control)
  end
  if nx_is_valid(balls) and nx_is_valid(ball) then
    balls:DeleteBalloon(ball)
  end
end
function custom_effect_dechp(target_ident, hp, attacker_ident, bva)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local text = nx_widestr("-" .. nx_string(hp))
  if bva then
    local gui = nx_value("gui")
    local info = gui.TextManager:GetText("ui_bva_damage")
    text = nx_widestr(nx_string(info) .. nx_string(text))
  end
  local color = "220,220,56"
  if target_ident == game_client.PlayerIdent then
    color = "255,0,0"
    if bva then
      nx_execute("SuspendManager", "show_balloon", "self_Bva", text, target_ident)
    else
      nx_execute("SuspendManager", "show_balloon", "self_damage_hp", text, target_ident)
    end
  elseif bva then
    nx_execute("SuspendManager", "show_balloon", "other_Bva", text, target_ident)
  else
    nx_execute("SuspendManager", "show_balloon", "other_damage_hp", text, target_ident)
  end
  local client_attacker = game_client:GetSceneObj(attacker_ident)
  if not nx_is_valid(client_attacker) then
    return
  end
  local visual_select = nx_null()
  if client_attacker:FindProp("LastObject") then
    local last_obj = nx_string(client_attacker:QueryProp("LastObject"))
    visual_select = game_visual:GetSceneObj(last_obj)
  end
  local visual_attacker = game_visual:GetSceneObj(attacker_ident)
  local visual_target = game_visual:GetSceneObj(target_ident)
  nx_execute("skill_effect", "play_hurt_sound", visual_attacker, visual_target, bva)
end
function custom_miss(target_ident, hits)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if target_ident == game_client.PlayerIdent then
    nx_execute("SuspendManager", "show_balloon", "self_Miss", "", target_ident)
  else
    nx_execute("SuspendManager", "show_balloon", "other_Miss", "", target_ident)
  end
end
function custom_effect_hits(target_ident, hits)
  local gui = nx_value("gui")
  local info = gui.TextManager:GetText("ui_fight_hit")
  local text = nx_widestr(nx_string(info) .. "+" .. nx_string(hits))
  local color = "234,141,28"
  local bAttack_Hit = nx_execute("form_stage_main\\form_system\\form_system_Fight_info_Setting", "get_info_is_visible", "Attack_Hits")
  if bAttack_Hit then
    nx_execute("SuspendManager", "show_balloon", "self_Hits", nx_string(hits), target_ident)
  end
end
function custom_effect_addhp(target_ident, hp)
  local text = nx_widestr("+" .. nx_string(hp))
  local color = "20,220,20"
  nx_execute("SuspendManager", "show_balloon", "self_AddHP", text, target_ident)
end
function custom_effect_addmp(target_ident, mp)
  local text = nx_widestr("+" .. nx_string(mp))
  local color = "20,20,220"
  nx_execute("SuspendManager", "show_balloon", "self_AddMP", text, target_ident)
end
function custom_effect_decmp(target_ident, mp)
  do return end
  local text = nx_widestr("-" .. nx_string(mp))
  nx_execute("SuspendManager", "show_balloon", "self_AddMP", text, target_ident)
end
function custom_effect_addexp(target_ident, exp)
  local text = nx_widestr("+" .. nx_string(exp))
  local color = "220,0,220"
  nx_execute(nx_current(), "create_balloon", target_ident, text, "FIGHT24_O", color, -0, -0, -0, 4)
end
function custom_effect_show_skill_name(target_ident, string_id, color)
  local string_id = util_text(nx_string(string_id))
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(target_ident)
  nx_execute("head_game", "ShowNpcSkillNameOnHead", visual_scene_obj, string_id)
end
function is_using_taolu()
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    local client_player = game_client:GetPlayer()
    if nx_is_valid(client_player) then
      local cur_taolu = client_player:QueryProp("CurSkillTaolu")
      if string.len(cur_taolu) > 1 and cur_taolu ~= "NOSET" then
        return true
      end
    end
  end
  return false
end
function custom_begin_curse(ticks, curse_text, cursetype)
  if curse_text == "skill_pause" then
    nx_execute("form_stage_main\\form_main\\form_main_fightvs_alone_ex", "star_fight_progress", ticks)
    return
  end
  if is_using_taolu() then
    nx_execute("form_stage_main\\form_main\\form_main_fightvs_alone", "star_taolu_progress", ticks)
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  if player_client:FindProp("LogicState") then
    local logic_state = player_client:QueryProp("LogicState")
    if nx_int(logic_state) == nx_int(LS_SITCROSS) then
      return
    end
  end
  local gui = nx_value("gui")
  local text
  if curse_text ~= nil then
    local strlst = util_split_string(curse_text, ",")
    local textid = curse_text_id[strlst[1]]
    if textid ~= nil then
      if table.getn(strlst) == 1 then
        text = gui.TextManager:GetFormatText(textid)
      elseif table.getn(strlst) == 2 then
        text = gui.TextManager:GetFormatText(textid, strlst[2])
      end
    end
    if gui.TextManager:IsIDName(curse_text) then
      text = gui.TextManager:GetText(curse_text)
    end
  end
  if text ~= nil then
    local item_query = nx_value("ItemQuery")
    if nx_is_valid(item_query) then
      local value = item_query:GetItemPropByConfigID(nx_string(curse_text), "GatherType")
      if value ~= "2" then
        text = nil
      end
    end
  end
  nx_execute("form_stage_main\\form_main\\form_main_curseloading", "delete_self")
  nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_main\\form_main_curseloading")
  nx_execute("form_stage_main\\form_main\\form_main_curseloading", "do_load_loop", ticks, cursetype, text)
  nx_execute("form_stage_main\\form_main\\form_main_curseloading", "set_flow_id", nx_string(curse_text))
end
function custom_end_curse(msg)
  if msg == "skill_pause" then
    nx_execute("form_stage_main\\form_main\\form_main_fightvs_alone_ex", "stop_fight_progress", msg)
    return
  elseif msg == "skill_whack" then
    local fight = nx_value("fight")
    if nx_is_valid(fight) then
      fight:StopUseSkill()
    end
  end
  nx_execute("form_stage_main\\form_main\\form_main_curseloading", "delete_self")
  if msg == "skill_break" then
    nx_execute("form_stage_main\\form_main\\form_main_fightvs_alone", "stop_taolu_progress", msg)
  end
end
function is_cursing(id)
  local form = nx_value("form_stage_main\\form_main\\form_main_curseloading")
  if nx_is_valid(form) then
    if id ~= nil and id ~= form.flow_id then
      return false
    end
    return true
  end
  return false
end
function custom_hitdown(src_ident, target_ident, failed, lock_time, down_action, up_action, loop_action, angle)
  if down_action == nil then
    down_action = ""
  end
  if up_action == nil then
    up_action = ""
  end
  if loop_action == nil then
    loop_action = ""
  end
  if angle == nil then
    angle = nx_number(ERR_ANGLE) - 1
  end
  local game_visual = nx_value("game_visual")
  local visual_target = game_visual:GetSceneObj(target_ident)
  if not nx_is_valid(visual_target) then
    return
  end
  emit_player_input(visual_target, PLAYER_INPUT_LOGIC, LOGIC_LOCK)
  local hitdown_time = lock_time / 1000 - 0.5
  if nx_number(angle) > nx_number(ERR_ANGLE) then
    visual_target:SetAngle(0, nx_float(angle), 0)
  end
  local skill_effect = nx_value("skill_effect")
  if nx_is_valid(skill_effect) then
    skill_effect:PlayHitDown(visual_target, hitdown_time, down_action, up_action, loop_action)
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    if nx_number(lock_time) > 1.0E-7 then
      timer:UnRegister(nx_current(), "on_hitdown_finish", visual_target)
      timer:Register(lock_time, 1, nx_current(), "on_hitdown_finish", visual_target, -1, -1)
    else
      on_hitdown_finish(visual_target)
    end
  end
end
function on_hitdown_finish(visual_target)
  if not nx_is_valid(visual_target) then
    return
  end
  emit_player_input(visual_target, PLAYER_INPUT_LOGIC, LOGIC_UNLOCK)
end
function custom_hitbreak(src_ident, target_ident, failed, lock_time, hurt_action, angle, def_hurt_action)
  if hurt_action == nil then
    hurt_action = "hurt_f_1_s"
  end
  if def_hurt_action == nil then
    def_hurt_action = "hurt_f"
  end
  if angle == nil then
    angle = nx_number(ERR_ANGLE) - 1
  end
  local game_visual = nx_value("game_visual")
  local vis_src = game_visual:GetSceneObj(src_ident)
  local visual_target = game_visual:GetSceneObj(target_ident)
  if not nx_is_valid(visual_target) then
    return
  end
  emit_player_input(visual_target, PLAYER_INPUT_LOGIC, LOGIC_LOCK)
  if nx_number(angle) > nx_number(ERR_ANGLE) then
    visual_target:SetAngle(0, nx_float(angle), 0)
  end
  local skill_effect = nx_value("skill_effect")
  if nx_is_valid(skill_effect) then
    skill_effect:PlayHitBreak(vis_src, visual_target, hurt_action, def_hurt_action)
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    if 1.0E-7 < lock_time then
      timer:UnRegister(nx_current(), "on_hitbreak_finish", visual_target)
      timer:Register(lock_time, 1, nx_current(), "on_hitbreak_finish", visual_target, -1, -1)
    else
      on_hitbreak_finish(visual_target)
    end
  end
end
function on_hitbreak_finish(visual_target)
  if not nx_is_valid(visual_target) then
    return
  end
  local game_visual = nx_value("game_visual")
  if game_visual:QueryRoleDead(visual_target) then
    local action_module = nx_value("action_module")
    action_module:ChangeState(visual_target, "diedownloop")
    action_module:DoAction(visual_target, "diedown")
  end
  emit_player_input(visual_target, PLAYER_INPUT_LOGIC, LOGIC_UNLOCK)
end
function custom_effect_born(target_ident)
  local game_visual = nx_value("game_visual")
  local visual_target = game_visual:GetSceneObj(target_ident)
  if not nx_is_valid(visual_target) then
    return
  end
  local effect_model = nx_execute("game_effect", "create_effect", "born", visual_target, visual_target)
end
function custom_effect_levelup(target_ident)
  local game_visual = nx_value("game_visual")
  local visual_target = game_visual:GetSceneObj(target_ident)
  if not nx_is_valid(visual_target) then
    return
  end
  local effect_model = nx_execute("game_effect", "create_effect", "levelup", visual_target, visual_target)
end
function custom_effect_recv_letter(target_ident)
  local game_visual = nx_value("game_visual")
  local visual_target = game_visual:GetSceneObj(target_ident)
  if not nx_is_valid(visual_target) then
    return
  end
end
function custom_effect_send_letter(target_ident)
  local game_visual = nx_value("game_visual")
  local visual_target = game_visual:GetSceneObj(target_ident)
  if not nx_is_valid(visual_target) then
    return
  end
  local effect_model = nx_execute("game_effect", "create_effect", "sendletter", visual_target, visual_target)
end
function change_task_npc_effect_type(npc, effecttype)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local model = game_visual:GetSceneObj(nx_string(npc))
  if model == nil or not nx_is_valid(model) then
    return
  end
  local effectm_model_name = "caiji01"
  if nx_int(effecttype) == nx_int(0) then
    if nx_find_custom(model, "particle") and nx_is_valid(model.particle) then
      nx_execute("game_effect", "delete_eff_model", model.scene, model.particle)
    end
  elseif nx_int(effecttype) == nx_int(1) and (not nx_find_custom(model, "particle") or not nx_is_valid(model.particle)) then
    local effect_model = nx_execute("game_effect", "create_linktopoint_effect_by_target", effectm_model_name, -1, model, "Model::E_target01", 0, 0, 0, 0, 0, 0, 1, 1, 1)
    model.particle = effect_model
  end
end
function custom_effect_interactive(target_ident, effect_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_target = game_visual:GetSceneObj(target_ident)
  if not nx_is_valid(visual_target) then
    return
  end
  visual_target.Visible = false
  local effect_model = nx_execute("game_effect", "create_effect", nx_string(effect_name), visual_target, visual_target)
end
function custom_effect_spring(target_ident, effect_name)
  local game_visual = nx_value("game_visual")
  local visual_target = game_visual:GetSceneObj(target_ident)
  if not nx_is_valid(visual_target) then
    return
  end
  while not visual_target.LoadFinish do
    nx_pause(0)
  end
  local effect_model = nx_execute("game_effect", "create_effect", effect_name, visual_target, visual_target)
end
function custom_effect_compose(target_ident, effect_name)
  local game_visual = nx_value("game_visual")
  local visual_target = game_visual:GetSceneObj(target_ident)
  if not nx_is_valid(visual_target) then
    return
  end
  local effect_model = nx_execute("game_effect", "create_effect", effect_name, visual_target, visual_target)
end
function custom_effect_get_origin(target_ident)
  local game_visual = nx_value("game_visual")
  local visual_target = game_visual:GetSceneObj(target_ident)
  if not nx_is_valid(visual_target) then
    return
  end
  local effect_model = nx_execute("game_effect", "create_effect", "levelup", visual_target, visual_target)
end
function get_role_model(visual_target)
  local actor2_target = visual_target
  if nx_is_valid(actor2_target) then
    local actor2_role = actor2_target:GetLinkObject("actor_role")
    if nx_is_valid(actor2_role) then
      return actor2_role
    end
  end
  return actor2_target
end
function custom_effect_offline_ai(target_ident, effect_name, be_open)
  local game_visual = nx_value("game_visual")
  local visual_target = game_visual:GetSceneObj(target_ident)
  if not nx_is_valid(visual_target) then
    return 0
  end
  local actor2 = get_role_model(visual_target)
  if nx_int(be_open) > nx_int(0) then
    local effect_model = nx_execute("game_effect", "create_effect", nx_string(effect_name), actor2, actor2)
  else
    nx_execute("game_effect", "remove_effect", nx_string(effect_name), actor2, actor2)
  end
  return 1
end
function show_ball_tl(target_ident, zhaoshi_id, color)
  local gui = nx_value("gui")
  local taolu = nx_execute("util_static_data", "skill_static_query_by_id", zhaoshi_id, "TaoLu")
  if taolu == nil or taolu == "" then
    return
  end
  local text = gui.TextManager:GetText(taolu)
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(target_ident)
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  local balls = nx_value("balls")
  local ball
  local taolu_ball = nx_value("taolu_ball")
  if nx_is_valid(taolu_ball) then
    set_ball_text_alpha(taolu_ball, 250, color)
    taolu_ball.Control.Text = text
    return
  else
    local label = gui:Create("Label")
    label.Font = "FIGHT48_O"
    label.Width = nx_ws_length(text) * 24
    nx_set_value("taolu_boll_lable", label)
    ball = balls:AddBalloon(label, visual_scene_obj, 0)
    ball.Name = "custom_effect:show_ball_tl:" .. nx_string(visual_scene_obj)
    nx_set_value("taolu_ball", ball)
    ball.BindY = visual_scene_obj.height * 2.1
    ball.NearDistance = 0
    ball.FarDistance = 200
    ball.Control.model = visual_scene_obj
    ball.MustVisible = true
    ball.Control.ForeColor = "255," .. color
    ball.OffsetLeft = 60
    ball.OffsetTop = -1
    ball.Control.Text = text
  end
  local times = 0
  while true do
    local sep = nx_pause(0)
    times = times + sep
    if not nx_is_valid(ball) then
      return
    end
    local alpha = get_ball_text_alpha(ball)
    alpha = math.floor(alpha - sep / 6 * 255)
    if alpha <= 0 then
      break
    end
    set_ball_text_alpha(ball, alpha)
  end
  nx_set_value("taolu_ball", nil)
  delete_balloon(ball)
end
function show_ball_zhaoshi(target_ident, zhaoshi_id, color)
  local gui = nx_value("gui")
  if zhaoshi_id == nil or zhaoshi_id == "" then
    return
  end
  local text = gui.TextManager:GetText(zhaoshi_id)
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(target_ident)
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  local balls = nx_value("balls")
  local ball
  local zhaoshi_ball = nx_value("zhaoshi_ball")
  nx_execute("SuspendManager", "show_balloon", "skill_name", "", target_ident, nx_string(text))
end
function get_ball_text_alpha(ball)
  if not nx_is_valid(ball) then
    return
  end
  local forecolor = ball.Control.ForeColor
  local lst = util_split_string(forecolor, ",")
  return lst[1]
end
function set_ball_text_alpha(ball, alpha, color)
  if not nx_is_valid(ball) then
    return
  end
  if color == nil or color == "" then
    local forecolor = ball.Control.ForeColor
    local lst = util_split_string(forecolor, ",")
    ball.Control.ForeColor = nx_string(nx_int(alpha)) .. "," .. lst[2] .. "," .. lst[3] .. "," .. lst[4]
  else
    ball.Control.ForeColor = nx_string(nx_int(alpha)) .. "," .. color
  end
end
function create_va_dmg_balloon(target_ident, text, font_name, color, left_offset, top_offset, x_scale, y_scale, range)
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(target_ident)
  if not nx_is_valid(visual_scene_obj) then
    return nx_null()
  end
  local gui = nx_value("gui")
  local balls = nx_value("balls")
  local label = gui:Create("Label")
  label.Font = font_name
  label.Width = 128
  label.Align = "Center"
  local ball = balls:AddBalloon(label, visual_scene_obj, 0)
  ball.Name = "create_va_dmg_balloon:" .. nx_string(visual_scene_obj)
  ball.BindY = visual_scene_obj.height
  ball.NearDistance = 0
  ball.FarDistance = 200
  ball.Control.model = visual_scene_obj
  ball.MustVisible = true
  ball.Control.Text = text
  ball.Control.ForeColor = "255," .. color
  ball.OffsetLeft = left_offset
  ball.OffsetTop = top_offset
  local times = 0
  local speed = 300
  if up_speed ~= nil then
    speed = up_speed
  end
  local alpha = 255
  while true do
    local sep = nx_pause(0)
    times = times + sep
    local rand_pos = range / 2 - math.random(range)
    if not nx_is_valid(ball) then
      return
    end
    if x_scale ~= nil then
      ball.OffsetLeft = left_offset + rand_pos
    end
    if y_scale ~= nil then
      ball.OffsetTop = ball.OffsetTop + rand_pos * 0.7 - y_scale * times / 1
    end
    if 0.5 < times then
      alpha = math.floor(alpha - sep * 255)
      if alpha < 0 then
        alpha = 0
        break
      end
      ball.Control.ForeColor = nx_string(nx_int(alpha)) .. "," .. color
    end
  end
  delete_balloon(ball)
end
function show_fighting_state(text, ticks, color)
  if not text or not ticks then
    return
  end
  local gui = nx_value("gui")
  local label = nx_null()
  if nx_find_value("Fighting_Label") then
    label = nx_value("Fighting_Label")
  end
  if not nx_is_valid(label) then
    label = gui:Create("Label")
    if not nx_is_valid(label) then
      return
    end
    label.Height = 30
    label.Width = 150
    label.Align = "Center"
    label.Font = "FZHKJT30"
    local form = gui.Desktop
    label.Top = form.Height * 0.32
    label.Left = (form.Width - label.Width) / 2
    form:Add(label)
    nx_set_value("Fighting_Label", label)
  end
  label.Text = text
  color = color or "239,218,29"
  label.ForeColor = "255," .. color
  local times = 0
  local alpha = 255
  while true do
    local sep = nx_pause(0.1)
    times = times + sep
    if not nx_is_valid(label) then
      nx_remove_value("Fighting_Label")
      return
    end
    if ticks < times then
      alpha = math.floor(alpha - sep * 255)
      if alpha < 0 then
        alpha = 0
        break
      end
      label.ForeColor = nx_string(nx_int(alpha)) .. "," .. color
    end
  end
  label.Visible = false
end
function set_simple_decal_mask(scene)
  local terrain = scene.terrain
  terrain:SetTraceMask("Ground", false)
  terrain:SetTraceMask("Role", true)
  terrain:SetTraceMask("Model", true)
  terrain:SetTraceMask("Particle", true)
  terrain:SetTraceMask("Light", true)
  terrain:SetTraceMask("Sound", true)
  terrain:SetTraceMask("Trigger", true)
  terrain:SetTraceMask("Helper", true)
  terrain:SetTraceMask("EffectModel", true)
  terrain:SetTraceMask("Through", true)
end
function bak_mask(scene)
  local terrain = scene.terrain
  local g_mask = terrain:GetTraceMask("Ground")
  local r_mask = terrain:GetTraceMask("Role")
  local m_mask = terrain:GetTraceMask("Model")
  local p_mask = terrain:GetTraceMask("Particle")
  local l_mask = terrain:GetTraceMask("Light")
  local s_mask = terrain:GetTraceMask("Sound")
  local tri_mask = terrain:GetTraceMask("Trigger")
  local h_mask = terrain:GetTraceMask("Helper")
  local e_mask = terrain:GetTraceMask("EffectModel")
  local th_mask = terrain:GetTraceMask("Through")
  return g_mask, r_mask, m_mask, p_mask, l_mask, s_mask, tri_mask, h_mask, e_mask, th_mask
end
function restore_mask(scene, g_mask, r_mask, m_mask, p_mask, l_mask, s_mask, tri_mask, h_mask, e_mask, th_mask)
  local terrain = scene.terrain
  terrain:SetTraceMask("Ground", g_mask)
  terrain:SetTraceMask("Role", r_mask)
  terrain:SetTraceMask("Model", m_mask)
  terrain:SetTraceMask("Particle", p_mask)
  terrain:SetTraceMask("Light", l_mask)
  terrain:SetTraceMask("Sound", s_mask)
  terrain:SetTraceMask("Trigger", tri_mask)
  terrain:SetTraceMask("Helper", h_mask)
  terrain:SetTraceMask("EffectModel", e_mask)
  terrain:SetTraceMask("Through", th_mask)
end
function custom_effect_common_range(client_ident, x, y, z, radius, res, disp)
  if disp == 0 then
    local old_decal = nx_value("common_range")
    if nx_is_valid(old_decal) then
      local alph = 255
      while nx_is_valid(old_decal) do
        alph = alph - 6
        old_decal.Color = nx_string(alph) .. ", 255, 255, 255"
        if nx_number(alph) <= nx_number(0) then
          break
        end
        nx_pause(0)
      end
      local scene = nx_value("game_scene")
      local terrain = scene.terrain
      terrain:RemoveVisual(old_decal)
      scene:Delete(old_decal)
      nx_set_value("common_range", nx_null())
    end
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetSceneObj(client_ident)
  if not nx_is_valid(client_player) then
    return
  end
  if nx_is_valid(nx_value("common_range")) then
    return
  end
  local world = nx_value("world")
  local scene = nx_value("game_scene")
  local g_mask, r_mask, m_mask, p_mask, l_mask, s_mask, tri_mask, h_mask, e_mask, th_mask = bak_mask(scene)
  set_simple_decal_mask(scene)
  local decal = scene:Create("SimpleDecal")
  nx_set_value("common_range", decal)
  decal.AsyncLoad = false
  decal.DiffuseMap = res
  decal:Load()
  decal.Color = "255, 255, 255, 255"
  decal.DisplayBias = 3.0E-4
  decal.EnableAlphaBlend = true
  decal.Visible = true
  local terrain = scene.terrain
  terrain:AddVisual("", decal)
  terrain:RelocateVisual(decal, x, y + 0.1, z)
  if not decal:BuildByOrthoLH(terrain, x, y + 0.1, z, x, y, z, radius * 2, radius * 2, 0.1, 2, 0, false, true) then
  end
  restore_mask(scene, g_mask, r_mask, m_mask, p_mask, l_mask, s_mask, tri_mask, h_mask, e_mask, th_mask)
end
function custom_effect_show_jhboss_range(client_ident, x, y, z, radius, disp)
  if disp == 0 then
    old_decal = nx_value("challenge_range")
    if nx_is_valid(old_decal) then
      local alph = 255
      while nx_is_valid(old_decal) do
        alph = alph - 6
        old_decal.Color = nx_string(alph) .. ", 255, 255, 255"
        if nx_number(alph) <= nx_number(0) then
          break
        end
        nx_pause(0)
      end
      local scene = nx_value("game_scene")
      local terrain = scene.terrain
      terrain:RemoveVisual(old_decal)
      scene:Delete(old_decal)
      nx_set_value("challenge_range", nx_null())
    end
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetSceneObj(client_ident)
  if not nx_is_valid(client_player) then
    return
  end
  if nx_is_valid(nx_value("challenge_range")) then
    return
  end
  local world = nx_value("world")
  local scene = nx_value("game_scene")
  local g_mask, r_mask, m_mask, p_mask, l_mask, s_mask, tri_mask, h_mask, e_mask, th_mask = bak_mask(scene)
  set_simple_decal_mask(scene)
  local decal = scene:Create("SimpleDecal")
  nx_set_value("challenge_range", decal)
  decal.AsyncLoad = false
  decal.DiffuseMap = "map\\tex\\particles\\pattern033.dds"
  decal:Load()
  decal.Color = "255, 255, 255, 255"
  decal.DisplayBias = 3.0E-4
  decal.EnableAlphaBlend = true
  decal.Visible = true
  local terrain = scene.terrain
  terrain:AddVisual("", decal)
  terrain:RelocateVisual(decal, x, y + 0.1, z)
  if not decal:BuildByOrthoLH(terrain, x, y + 0.1, z, x, y, z, radius * 2, radius * 2, 0.1, 2, 0, false, true) then
  end
  restore_mask(scene, g_mask, r_mask, m_mask, p_mask, l_mask, s_mask, tri_mask, h_mask, e_mask, th_mask)
end
function custom_effect_xunbao_flash(client_ident, x, y, z, radius, disp)
  local scene = nx_value("game_scene")
  local eff = nx_execute("game_effect", "create_eff_model_in_mainscene", scene, "light_circ_11a", x, y, z)
  if nx_is_valid(eff) then
    eff.LifeTime = 5
  end
end
function custom_effect_show_challenge_range(client_ident, x, y, z, radius, disp)
  if disp == 0 then
    old_decal = nx_value("challenge_range")
    if nx_is_valid(old_decal) then
      local alph = 255
      while nx_is_valid(old_decal) do
        alph = alph - 6
        old_decal.Color = nx_string(alph) .. ", 255, 255, 255"
        if nx_number(alph) <= nx_number(0) then
          break
        end
        nx_pause(0)
      end
      local scene = nx_value("game_scene")
      local terrain = scene.terrain
      terrain:RemoveVisual(old_decal)
      scene:Delete(old_decal)
      nx_set_value("challenge_range", nx_null())
    end
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetSceneObj(client_ident)
  if not nx_is_valid(client_player) then
    return
  end
  local fight = nx_value("fight")
  if not fight:IsChallenge(client_player) then
    nx_pause(2)
  end
  if nx_is_valid(nx_value("challenge_range")) then
    return
  end
  local world = nx_value("world")
  local scene = nx_value("game_scene")
  local g_mask, r_mask, m_mask, p_mask, l_mask, s_mask, tri_mask, h_mask, e_mask, th_mask = bak_mask(scene)
  set_simple_decal_mask(scene)
  local decal = scene:Create("SimpleDecal")
  nx_set_value("challenge_range", decal)
  decal.AsyncLoad = false
  decal.DiffuseMap = "map\\tex\\particles\\pattern033.dds"
  decal:Load()
  decal.Color = "255, 255, 255, 255"
  decal.DisplayBias = 3.0E-4
  decal.EnableAlphaBlend = true
  decal.Visible = true
  local terrain = scene.terrain
  terrain:AddVisual("", decal)
  terrain:RelocateVisual(decal, x, y + 0.1, z)
  if not decal:BuildByOrthoLH(terrain, x, y + 0.1, z, x, y, z, radius * 2, radius * 2, 0.1, 2, 0, false, true) then
  end
  restore_mask(scene, g_mask, r_mask, m_mask, p_mask, l_mask, s_mask, tri_mask, h_mask, e_mask, th_mask)
  local fight = nx_value("fight")
  while true do
    nx_pause(0)
    if not nx_is_valid(decal) then
      break
    end
    if not nx_is_valid(client_player) then
      break
    end
    if not fight:IsChallenge(client_player) then
      break
    end
  end
  local alph = 255
  while nx_is_valid(decal) do
    alph = alph - 6
    decal.Color = nx_string(alph) .. ", 255, 255, 255"
    if nx_number(alph) <= nx_number(0) then
      break
    end
    nx_pause(0)
  end
  if nx_is_valid(decal) then
    terrain:RemoveVisual(decal)
    scene:Delete(decal)
  end
end
function custom_effect_show_leitai_range(target_ident, resource, disp)
  local game_visual = nx_value("game_visual")
  local visual_target = game_visual:GetSceneObj(nx_string(target_ident))
  for i = 1, 5 do
    if not nx_is_valid(visual_target) then
      if i == 5 or disp == 0 then
        return
      end
      nx_pause(1)
      visual_target = game_visual:GetSceneObj(nx_string(target_ident))
    else
      break
    end
  end
  if disp == 0 then
    nx_execute("game_effect", "remove_effect", resource, visual_target, visual_target)
    return
  end
  nx_execute("game_effect", "create_effect", resource, visual_target, visual_target)
end
array_data = {}
function custom_challenge_effect_show(client_ident, x, y, z, radius, type, srcuid, src_ident)
  local effect_list = {
    [1] = {
      name = "item_duelflag01",
      loop = false
    },
    [2] = {
      name = "item_duelflag02",
      loop = true
    },
    [3] = {
      name = "item_duelflag04",
      loop = false,
      remove = "item_duelflag02"
    },
    [4] = {
      name = "item_duelflag03",
      loop = false,
      remove = "item_duelflag02"
    },
    [5] = {
      name = "item_duelflag05",
      loop = true
    },
    [7] = {
      name = "item_duelflag06",
      loop = false,
      remove = "item_duelflag05"
    }
  }
  local game_client = nx_value("game_client")
  local client_player = game_client:GetSceneObj(client_ident)
  local src_player = game_client:GetSceneObj(nx_string(src_ident))
  local challenge_x = 0
  local challenge_y = 0
  local challenge_z = 0
  if not nx_is_valid(client_player) then
    return
  end
  if not nx_is_valid(src_player) then
    return
  end
  if type == 5 then
    nx_pause(2.2)
  end
  if nx_running(nx_current(), "custom_challenge_effect_show") and effect_list[type].remove then
    local effect_data = array_data
    local remove_effect = effect_list[type].remove
    if 0 < table.getn(array_data) then
      for i, effect in pairs(array_data) do
        if nx_is_valid(effect) and nx_find_custom(effect, "srcuid") then
          local src_uid = nx_custom(effect, "srcuid")
          if nx_string(src_uid) == nx_string(srcuid) and nx_is_valid(effect) then
            if type == 5 then
              challenge_x = nx_custom(effect, "challenge_x")
              challenge_y = nx_custom(effect, "challenge_y")
              challenge_z = nx_custom(effect, "challenge_z")
            end
            table.remove(array_data, i)
            if 1 <= i then
              i = i - 1
            end
            local effect_number = nx_value("challenge_effect_number") - 1
            if effect_number < 0 then
              effect_number = 0
            end
            nx_set_value("challenge_effect_number", effect_number)
            local scene = nx_value("game_scene")
            local terrain = scene.terrain
            terrain:RemoveVisual(effect)
            scene:Delete(effect)
          end
        end
      end
    end
  end
  local world = nx_value("world")
  local scene = nx_value("game_scene")
  if nx_int(type) == nx_int(5) then
  end
  local effect_model = scene:Create("EffectModel")
  effect_model:CreateFromIni("ini\\effect\\model.ini", effect_list[type].name, false)
  effect_model.name = effect_list[type].name
  effect_model.challenge_x = x
  effect_model.challenge_y = y
  effect_model.challenge_z = z
  effect_model.srcuid = srcuid
  effect_model.Loop = effect_list[type].loop
  table.insert(array_data, effect_model)
  if not nx_is_valid(nx_value("challenge_effect_number")) then
    nx_set_value("challenge_effect_number", 0)
  end
  local effect_number = nx_value("challenge_effect_number") + 1
  nx_set_value("challenge_effect_number", effect_number)
  local terrain = scene.terrain
  if nx_is_valid(effect_model) then
    terrain:AddVisual("", effect_model)
    if type ~= 7 then
      terrain:RelocateVisual(effect_model, x, y, z)
    else
      terrain:RelocateVisual(effect_model, challenge_x, challenge_y, challenge_z)
    end
  end
  while true do
    nx_pause(2.33)
    if not nx_is_valid(client_player) then
      break
    end
    if not nx_is_valid(src_player) then
      break
    end
    if not effect_list[type].loop then
      break
    end
  end
  if nx_is_valid(effect_model) then
    for i, effect in pairs(array_data) do
      if nx_id_equal(effect, effect_model) then
        table.remove(array_data, i)
        break
      end
    end
    local effect_number = nx_value("challenge_effect_number") - 1
    if effect_number < 0 then
      effect_number = 0
    end
    nx_set_value("challenge_effect_number", effect_number)
    terrain:RemoveVisual(effect_model)
    scene:Delete(effect_model)
  end
  if nx_int(type) == nx_int(7) then
  end
end
function custom_effect_add_challenge_terrain(client_ident, x, y, z, radius)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetSceneObj(client_ident)
  if not nx_is_valid(client_player) then
    return
  end
  local fight = nx_value("fight")
  if not fight:IsChallenge(client_player) then
    nx_pause(2)
  end
  local world = nx_value("world")
  local scene = nx_value("game_scene")
  if nx_find_custom(scene, "challenge_terrain") and nx_is_valid(nx_custom(scene, "challenge_terrain")) then
    return
  end
  local g_mask, r_mask, m_mask, p_mask, l_mask, s_mask, tri_mask, h_mask, e_mask, th_mask = bak_mask(scene)
  set_simple_decal_mask(scene)
  local decal = scene:Create("SimpleDecal")
  decal.AsyncLoad = false
  decal.DiffuseMap = "map\\tex\\particles\\pattern041.dds"
  decal:Load()
  decal.Color = "255, 255, 255, 255"
  decal.DisplayBias = 3.0E-4
  decal.EnableAlphaBlend = true
  decal.Visible = true
  nx_set_custom(scene, "challenge_terrain", decal)
  local terrain = scene.terrain
  terrain:AddVisual("", decal)
  terrain:RelocateVisual(decal, x, y + 0.01, z)
  if not decal:BuildByOrthoLH(terrain, x, y + 0.01, z, x, y, z, radius * 2, radius * 2, 0.1, 2, 0, false, true) then
  end
  restore_mask(scene, g_mask, r_mask, m_mask, p_mask, l_mask, s_mask, tri_mask, h_mask, e_mask, th_mask)
end
function custom_effect_del_challenge_terrain(client_ident, x, y, z, radius)
  local scene = nx_value("game_scene")
  local terrain = scene.terrain
  if not nx_find_custom(scene, "challenge_terrain") then
    return
  end
  local decal = nx_custom(scene, "challenge_terrain")
  if not nx_is_valid(decal) then
    return
  end
  local alph = 255
  while nx_is_valid(decal) do
    alph = alph - 6
    decal.Color = nx_string(alph) .. ", 255, 255, 255"
    if nx_number(alph) <= nx_number(0) then
      break
    end
    nx_pause(0)
  end
  if nx_is_valid(decal) then
    terrain:RemoveVisual(decal)
    scene:Delete(decal)
    nx_set_custom(scene, "challenge_terrain", nx_null())
  end
end
function custom_effect_show_masses_fight_range(client_ident, x, y, z, radius, disp)
  if disp == 0 then
    old_decal = nx_value("challenge_range")
    if nx_is_valid(old_decal) then
      local alph = 255
      while nx_is_valid(old_decal) do
        alph = alph - 6
        old_decal.Color = nx_string(alph) .. ", 255, 255, 255"
        if nx_number(alph) <= nx_number(0) then
          break
        end
        nx_pause(0)
      end
      local scene = nx_value("game_scene")
      local terrain = scene.terrain
      terrain:RemoveVisual(old_decal)
      scene:Delete(old_decal)
      nx_set_value("challenge_range", nx_null())
    end
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetSceneObj(client_ident)
  if not nx_is_valid(client_player) then
    return
  end
  if nx_is_valid(nx_value("challenge_range")) then
    return
  end
  local world = nx_value("world")
  local scene = nx_value("game_scene")
  local g_mask, r_mask, m_mask, p_mask, l_mask, s_mask, tri_mask, h_mask, e_mask, th_mask = bak_mask(scene)
  set_simple_decal_mask(scene)
  local decal = scene:Create("SimpleDecal")
  nx_set_value("challenge_range", decal)
  decal.AsyncLoad = false
  decal.DiffuseMap = "map\\tex\\particles\\pattern033.dds"
  decal:Load()
  decal.Color = "255, 255, 255, 255"
  decal.DisplayBias = 3.0E-4
  decal.EnableAlphaBlend = true
  decal.Visible = true
  local terrain = scene.terrain
  terrain:AddVisual("", decal)
  terrain:RelocateVisual(decal, x, y + 0.1, z)
  if not decal:BuildByOrthoLH(terrain, x, y + 0.1, z, x, y, z, radius * 2, radius * 2, 0.1, 2, 0, false, true) then
  end
  restore_mask(scene, g_mask, r_mask, m_mask, p_mask, l_mask, s_mask, tri_mask, h_mask, e_mask, th_mask)
end
function custom_effect_show_compare(target, self_skill_id, target_skill_id, self_effect_type, target_effect_type, result)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    local role = game_visual:GetSceneObj(nx_string(game_visual.PlayerIdent))
    if nx_is_valid(role) then
      role.last_skill_id = self_skill_id
    end
  end
  nx_execute("form_stage_main\\form_main\\form_main_fightvs", "begin_compare_zhaoshi", target, self_skill_id, target_skill_id, self_effect_type, target_effect_type, result)
  local fight = nx_value("fight")
  fight:StopCheckCurSkill()
end
function custom_effect_fire(target_ident)
  local game_visual = nx_value("game_visual")
  local visual_target = game_visual:GetSceneObj(target_ident)
  if not nx_is_valid(visual_target) then
    return
  end
  local effect_model = nx_execute("game_effect", "create_effect", "E_atk26_head", visual_target, visual_target)
end
function custom_effect_once(target_ident, effectname)
  local game_visual = nx_value("game_visual")
  local visual_target = game_visual:GetSceneObj(target_ident)
  if not nx_is_valid(visual_target) then
    return
  end
  local effect_model = nx_execute("game_effect", "create_effect", effectname, visual_target, visual_target)
end
function custom_destory_effect_once(target_ident, effectname)
  local game_visual = nx_value("game_visual")
  local visual_target = game_visual:GetSceneObj(target_ident)
  if not nx_is_valid(visual_target) then
    return
  end
  local effect_model = nx_execute("game_effect", "remove_effect", effectname, visual_target, visual_target)
end
function custom_alpha_effect_once(target_ident, effectname, num)
  local game_visual = nx_value("game_visual")
  local visual_target = game_visual:GetSceneObj(target_ident)
  if not nx_is_valid(visual_target) then
    return
  end
  local effect_model = nx_execute("game_effect", "alpha_effect", effectname, visual_target, visual_target, num)
end
function custom_escape_effect(target_ident, effect_name, open)
  local game_visual = nx_value("game_visual")
  local visual_target = game_visual:GetSceneObj(target_ident)
  if not nx_is_valid(visual_target) then
    return
  end
  if nx_int(open) <= nx_int(0) then
    nx_execute("game_effect", "remove_effect", nx_string(effect_name), visual_target, visual_target)
  else
    nx_execute("game_effect", "create_effect", nx_string(effect_name), visual_target, visual_target, "")
  end
end
function custom_fight_guid_task_create_cycle(x, y, z, r)
  local game_client = nx_value("game_client")
  local world = nx_value("world")
  local scene = nx_value("game_scene")
  if nx_find_custom(scene, "fight_guid_cycle") and nx_is_valid(nx_custom(scene, "fight_guid_cycle")) then
    return
  end
  local g_mask, r_mask, m_mask, p_mask, l_mask, s_mask, tri_mask, h_mask, e_mask, th_mask = bak_mask(scene)
  set_simple_decal_mask(scene)
  local decal = scene:Create("SimpleDecal")
  decal.AsyncLoad = false
  decal.DiffuseMap = "map\\tex\\pattern037.dds"
  decal:Load()
  decal.Color = "255, 255, 255, 0"
  decal.DisplayBias = 3.0E-4
  decal.EnableAlphaBlend = true
  decal.Visible = true
  nx_set_custom(scene, "fight_guid_cycle", decal)
  local terrain = scene.terrain
  terrain:AddVisual("", decal)
  terrain:RelocateVisual(decal, x, y + 0.01, z)
  if not decal:BuildByOrthoLH(terrain, x, y + 0.01, z, x, y, z, r * 2, r * 2, 0.1, 2, 0, false, true) then
  end
  restore_mask(scene, g_mask, r_mask, m_mask, p_mask, l_mask, s_mask, tri_mask, h_mask, e_mask, th_mask)
end
function custom_fight_guid_task_clear_cycle(x, y, z, r)
  local scene = nx_value("game_scene")
  local terrain = scene.terrain
  if not nx_find_custom(scene, "fight_guid_cycle") then
    return
  end
  local decal = nx_custom(scene, "fight_guid_cycle")
  if not nx_is_valid(decal) then
    return
  end
  local alph = 255
  while nx_is_valid(decal) do
    alph = alph - 6
    decal.Color = nx_string(alph) .. ", 255, 255, 255"
    if nx_number(alph) <= nx_number(0) then
      break
    end
    nx_pause(0)
  end
  if nx_is_valid(decal) then
    terrain:RemoveVisual(decal)
    scene:Delete(decal)
    nx_set_custom(scene, "fight_guid_cycle", nx_null())
  end
end
function gather_effect(npc, effect_type, slice, effect_name, effect_pos, x, y, z)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local model = game_visual:GetSceneObj(nx_string(npc))
  if model == nil or not nx_is_valid(model) then
    return
  end
  if effect_name == nil or nx_string(effect_name) == nx_string("") then
    effect_name = "caiji01"
  end
  if nx_int(effect_type) == nx_int(0) then
    if nx_find_custom(model, "particle") and nx_is_valid(model.particle) then
      nx_execute("game_effect", "delete_eff_model", model.scene, model.particle)
    end
  elseif nx_int(effect_type) == nx_int(1) then
    if nx_find_custom(model, "particle") and nx_is_valid(model.particle) then
      nx_execute("game_effect", "delete_eff_model", model.scene, model.particle)
    end
    if slice == nil or nx_int(slice) < nx_int(0) then
      slice = -1
    end
    local pos_x = 0
    local pos_y = 0
    local pos_z = 0
    if x ~= nil then
      pos_x = nx_float(x)
    end
    if y ~= nil then
      pos_y = nx_float(y)
    end
    if z ~= nil then
      pos_z = nx_float(z)
    end
    if effect_pos == nil or nx_string(effect_pos) == nx_string("") then
      effect_pos = "Model::E_target01"
    end
    local effect_model = nx_execute("game_effect", "create_linktopoint_effect_by_target", effect_name, slice, model, effect_pos, pos_x, pos_y, pos_z, 0, 0, 0, 1, 1, 1)
    model.particle = effect_model
  end
end
function custom_do_skill_stage_effect(ident, stage, effect_id)
  local game_visual = nx_value("game_visual")
  local visual_target = game_visual:GetSceneObj(ident)
  if not nx_is_valid(visual_target) then
    return false
  end
  local b_del = false
  if stage == "end_prepare" or stage == "end_lead" then
    b_del = true
  end
  if b_del then
    nx_execute("game_effect", "remove_effect", effect_id, visual_target, visual_target)
  else
    nx_execute("game_effect", "create_effect", effect_id, visual_target, visual_target)
  end
  return true
end
function play_music(flag, music_name)
  local role = nx_value("role")
  if not nx_is_valid(role) then
    return
  end
  local scene = role.scene
  if not nx_is_valid(scene) then
    return
  end
  local scene_music_play_manager = nx_value("scene_music_play_manager")
  if not nx_is_valid(scene_music_play_manager) then
    return
  end
  local cur_music_name = scene_music_play_manager:GetGameMusicName()
  if flag == 1 then
    if music_name == "fight" then
      music_name = music_name .. nx_string(math.random(1, 3))
    end
    if cur_music_name == music_name then
      return
    end
    nx_execute("util_functions", "play_music", scene, "scene", music_name, 0, 4)
  elseif flag == 0 then
    local game_client = nx_value("game_client")
    local client_scene = game_client:GetScene()
    if not nx_is_valid(client_scene) then
      return
    end
    local scene_music = client_scene:QueryProp("Resource")
    local sceneid = client_scene:QueryProp("ConfigID")
    if string.find(sceneid, "war") ~= nil then
      local i, j = string.find(sceneid, "ini\\scene\\")
      scene_music = string.sub(sceneid, j + 1)
    end
    if cur_music_name == scene_music then
      return
    end
    local b_wait_last = false
    if music_name == "fight" then
      b_wait_last = true
    end
    nx_execute("util_functions", "play_scene_random_music", scene, "scene", scene_music, 0, 4, false, -1, b_wait_last)
  end
end
function custom_effect_add_zhenfamap(client_scene_obj, zhenfa_map)
  if not nx_is_valid(client_scene_obj) then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_target = game_visual:GetSceneObj(client_scene_obj.Ident)
  if not nx_is_valid(visual_target) then
    return
  end
  local array_name = nx_string(client_scene_obj) .. "ZHENYAN_EFFECT"
  if nx_find_value(array_name) then
    return
  end
  local array_list = nx_create("ArrayList", array_name)
  if not nx_is_valid(array_list) then
    return
  end
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    common_execute:AddExecute("ZhenFaMapEffect", client_scene_obj, 2)
  end
  nx_set_value(array_name, array_list)
  local terrain = scene.terrain
  local zhenyan_effect = "battleform_effect_1a"
  local zhenyan_color = ""
  local ini = nx_execute("util_functions", "get_ini", "share\\Skill\\zhenfa_map.ini")
  if nx_is_valid(ini) then
    local sec_index = ini:FindSectionIndex(nx_string(zhenfa_map))
    if sec_index < 0 then
      return
    end
    local map_effect = ini:ReadString(sec_index, "map_effect", "")
    local map_radius = ini:ReadString(sec_index, "map_radius", "")
    local map_effect1 = ini:ReadString(sec_index, "map_effect1", "")
    zhenyan_effect = ini:ReadString(sec_index, "zhenyan_effect", "")
    zhenyan_color = ini:ReadString(sec_index, "zhenyan_color", "")
    if map_effect ~= "" then
      local x = visual_target.PositionX
      local z = visual_target.PositionZ
      if nx_find_custom(visual_target, "zhenfa_end_x") then
        x = visual_target.zhenfa_end_x
        z = visual_target.zhenfa_end_z
      end
      local y = terrain:GetPosiY(x, z)
      local rotate_angle = visual_target.AngleY
      local floor_index = game_visual:QueryRoleFloorIndex(visual_target)
      if terrain:GetFloorExists(x, z, floor_index) then
        y = terrain:GetFloorHeight(x, z, floor_index)
      end
      if 0 >= nx_number(map_radius) then
        map_radius = 5
      end
      local decal = nx_execute("game_effect", "create_ground_decal", "zhenfa_ground_decal", x, y, z, nx_number(map_radius), map_effect, true, rotate_angle)
      local eff = nx_null()
      if map_effect1 ~= "" then
        eff = nx_execute("game_effect", "create_eff_model_in_mainscene", scene, map_effect1, x, y, z)
      end
      if nx_is_valid(decal) then
        local child = array_list:CreateChild(nx_string(decal))
        child.decal_id = decal
      end
      if nx_is_valid(eff) then
        eff:SetAngle(0, rotate_angle + math.pi, 0)
        local child = array_list:CreateChild(nx_string(eff))
        child.eff_id = eff
      end
    end
  end
  if not client_scene_obj:FindProp("ZhenYanStr") then
    return
  end
  local zhenyan_str = client_scene_obj:QueryProp("ZhenYanStr")
  if zhenyan_str == 0 or zhenyan_str == "" then
    return
  end
  local zhenyan_list = util_split_string(zhenyan_str, "|")
  for i = 1, table.getn(zhenyan_list) do
    local pos_list = util_split_string(zhenyan_list[i], ",")
    if table.getn(pos_list) < 3 then
      break
    end
    local x = nx_number(pos_list[1])
    local z = nx_number(pos_list[2])
    local y = terrain:GetPosiY(x, z)
    local floor_index = game_visual:QueryRoleFloorIndex(visual_target)
    if terrain:GetFloorExists(x, z, floor_index) then
      y = terrain:GetFloorHeight(x, z, floor_index)
    end
    local eff = nx_execute("game_effect", "create_eff_model_in_mainscene", scene, zhenyan_effect, x, y + 0.2, z)
    if nx_is_valid(eff) then
      if zhenyan_color ~= "" then
        eff.Color = zhenyan_color
      end
      local child = array_list:CreateChild("ZhenYanRec" .. nx_string(i))
      child.eff_id = eff
      child.spring_flag = 0
    end
  end
end
function custom_effect_refresh_zhenfamap(client_scene_obj)
  if not nx_is_valid(client_scene_obj) then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local terrain = scene.terrain
  local zhenfamap_id = client_scene_obj:QueryProp("CurZhenFaMap")
  local spring_effect = ""
  local ini = nx_execute("util_functions", "get_ini", "share\\Skill\\zhenfa_map.ini")
  if nx_is_valid(ini) and ini:FindSection(nx_string(zhenfamap_id)) then
    spring_effect = ini:ReadString(nx_string(zhenfamap_id), "spring_effect", "")
  end
  if spring_effect == "" or not client_scene_obj:FindProp("ZhenYanStr") then
    return
  end
  local array_name = nx_string(client_scene_obj) .. "ZHENYAN_EFFECT"
  if not nx_find_value(array_name) then
    return
  end
  local array_list = nx_value(array_name)
  if not nx_is_valid(array_list) then
    return
  end
  local zhenyan_str = client_scene_obj:QueryProp("ZhenYanStr")
  if zhenyan_str == 0 or zhenyan_str == "" then
    return
  end
  local zhenyan_list = util_split_string(zhenyan_str, "|")
  for i = 1, table.getn(zhenyan_list) do
    local pos_list = util_split_string(zhenyan_list[i], ",")
    if table.getn(pos_list) < 3 then
      break
    end
    local flag = nx_number(pos_list[3])
    local zhenyan_eff = array_list:GetChild("ZhenYanRec" .. nx_string(i))
    if nx_is_valid(zhenyan_eff) and nx_find_custom(zhenyan_eff, "spring_flag") and nx_number(flag) ~= zhenyan_eff.spring_flag then
      if nx_number(flag) == 0 then
        if nx_find_custom(zhenyan_eff, "spring_eff") and nx_is_valid(zhenyan_eff.spring_eff) then
          nx_execute("game_effect", "delete_eff_model_in_mainscene", scene, zhenyan_eff.spring_eff)
          zhenyan_eff.spring_eff = nx_null()
          zhenyan_eff.spring_flag = 0
        end
      elseif nx_find_custom(zhenyan_eff, "eff_id") and nx_is_valid(zhenyan_eff.eff_id) then
        local x = zhenyan_eff.eff_id.PositionX
        local y = zhenyan_eff.eff_id.PositionY
        local z = zhenyan_eff.eff_id.PositionZ
        local eff = nx_execute("game_effect", "create_eff_model_in_mainscene", scene, spring_effect, x, y, z)
        if nx_is_valid(eff) then
          zhenyan_eff.spring_eff = eff
          zhenyan_eff.spring_flag = 1
        end
      end
    end
  end
end
function custom_effect_del_zhenfamap(client_scene_obj)
  local array_name = nx_string(client_scene_obj) .. "ZHENYAN_EFFECT"
  if not nx_find_value(array_name) then
    return
  end
  local array_list = nx_value(array_name)
  if not nx_is_valid(array_list) then
    return
  end
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    common_execute:RemoveExecute("ZhenFaMapEffect", client_scene_obj)
  end
  local child_list = array_list:GetChildList()
  local scene = nx_value("game_scene")
  if nx_is_valid(scene) then
    for i = 1, table.getn(child_list) do
      local child = child_list[i]
      if nx_find_custom(child, "eff_id") then
        if nx_find_custom(child, "spring_eff") and nx_is_valid(child.spring_eff) then
          nx_execute("game_effect", "delete_eff_model_in_mainscene", scene, child.spring_eff)
        end
        if nx_is_valid(child.eff_id) then
          nx_execute("game_effect", "delete_eff_model_in_mainscene", scene, child.eff_id)
        end
      elseif nx_find_custom(child, "decal_id") then
        local decal = child.decal_id
        if nx_is_valid(decal) then
          nx_execute("game_effect", "delete_ground_decal", decal)
        end
      end
    end
  end
  array_list:ClearChild()
  nx_destroy(array_list)
  nx_remove_value(array_name)
end
function custom_effect_add_zhenfa_effect(client_scene_obj, visual_target, zhenfa_effect, zhenfa_once_effect, effect_color, range_effect, scale, range_color)
  if not nx_is_valid(visual_target) or not nx_is_valid(client_scene_obj) then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local once_eff = nx_execute("game_effect", "create_linktopoint_effect_by_target", zhenfa_once_effect, 1, visual_target, "", 0, 0, 0, 0, 0, 0, 1, 1, 1)
  if nx_is_valid(once_eff) and effect_color ~= nil and effect_color ~= "" then
    once_eff.Color = effect_color
  end
  local eff = nx_execute("game_effect", "create_linktopoint_effect_by_target", zhenfa_effect, -1, visual_target, "", 0, 0, 0, 0, 0, 0, 1, 1, 1)
  if nx_is_valid(eff) then
    if effect_color ~= nil and effect_color ~= "" then
      eff.Color = effect_color
    end
    visual_target.zhenfa_effect = eff
  end
  if range_effect ~= nil and range_effect ~= "" then
    local eff = nx_execute("game_effect", "create_pos_follow_effect_by_target", range_effect, -1, visual_target, 0, 0, 0, 0, 0, 0, false)
    if nx_is_valid(eff) then
      eff:SetScale(nx_number(scale), 1, nx_number(scale))
      eff.TraceEnable = false
      eff.CullEnable = false
      if range_color ~= nil and range_color ~= "" then
        eff.Color = range_color
      end
      visual_target.zhenfa_range = eff
    end
  end
end
function custom_effect_del_zhenfa_effect(client_scene_obj, visual_target)
  if not nx_is_valid(visual_target) then
    return
  end
  if nx_find_value("ZHENFA_EFFECT") then
    local ZHENFA_EFFECT = nx_value("ZHENFA_EFFECT")
    if nx_is_valid(ZHENFA_EFFECT) then
      local child = ZHENFA_EFFECT:FindChild(nx_string(visual_target))
      if nx_is_valid(child) then
        ZHENFA_EFFECT:RemoveChild(nx_string(visual_target))
      end
    end
  end
  if nx_find_custom(visual_target, "zhenfa_effect") and nx_is_valid(visual_target.zhenfa_effect) then
    nx_execute("game_effect", "delete_eff_model", nx_value("game_scene"), visual_target.zhenfa_effect)
    visual_target.zhenfa_effect = nx_null()
  end
  if nx_find_custom(visual_target, "zhenfa_range") and nx_is_valid(visual_target.zhenfa_range) then
    nx_execute("game_effect", "delete_eff_model", nx_value("game_scene"), visual_target.zhenfa_range)
    visual_target.zhenfa_range = nx_null()
  end
end
function custom_effect_refresh_zhenfa_effect()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  nx_call("util_gui", "get_global_arraylist", "ZHENFA_EFFECT")
  local obj_list = client_scene:GetSceneObjList()
  for i = 1, table.maxn(obj_list) do
    local client_obj = obj_list[i]
    if client_obj:FindProp("Name") then
      local name = client_obj:QueryProp("Name")
      local row = client_player:FindRecordRow("team_rec", TEAM_REC_COL_NAME, nx_widestr(name))
      if 0 <= row then
        role_composite:RefreshZhenFaEffect(client_obj)
      end
    end
  end
end
function custom_effect_clear_zhenfa_effect()
  if nx_find_value("ZHENFA_EFFECT") then
    local ZHENFA_EFFECT = nx_call("util_gui", "get_global_arraylist", "ZHENFA_EFFECT", false)
    if nx_is_valid(ZHENFA_EFFECT) then
      local child_list = ZHENFA_EFFECT:GetChildList()
      for i = 1, table.getn(child_list) do
        local child = child_list[i]
        local visual_target = child.target
        if nx_is_valid(visual_target) then
          if nx_find_custom(visual_target, "zhenfa_effect") and nx_is_valid(visual_target.zhenfa_effect) then
            nx_execute("game_effect", "delete_eff_model", nx_value("game_scene"), visual_target.zhenfa_effect)
            visual_target.zhenfa_effect = nx_null()
          end
          if nx_find_custom(visual_target, "zhenfa_range") and nx_is_valid(visual_target.zhenfa_range) then
            nx_execute("game_effect", "delete_eff_model", nx_value("game_scene"), visual_target.zhenfa_range)
            visual_target.zhenfa_range = nx_null()
          end
        end
      end
      ZHENFA_EFFECT:ClearChild()
    end
  end
end
function custom_effect_zhenfa_line(client_scene_obj, line_type)
  if not nx_is_valid(client_scene_obj) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_target = game_visual:GetSceneObj(client_scene_obj.Ident)
  if not nx_is_valid(visual_target) then
    return
  end
  local zhenfa_id = client_scene_obj:QueryProp("BelongZhenFa")
  local effect_color = ""
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\wuxue\\zhenfa_effect.ini")
  if nx_is_valid(ini) then
    local sec_index = ini:FindSectionIndex(nx_string(zhenfa_id))
    if 0 <= sec_index then
      effect_color = ini:ReadString(sec_index, "ZhenFaFollowColor", "")
    end
  end
  if not nx_find_custom(visual_target, "zhenfa_effect") then
    return
  end
  if not nx_is_valid(visual_target.zhenfa_effect) then
    return
  end
  if nx_number(line_type) == 1 then
    visual_target.zhenfa_effect.Color = effect_color
  elseif nx_number(line_type) == 2 then
    local game_client = nx_value("game_client")
    if game_client:IsPlayer(client_scene_obj.Ident) then
      nx_execute("util_sound", "play_link_sound", "fight_formation_warning.wav", nx_value("role"), 0, 0, 0, 1, 5, 1, "snd\\action\\fight\\other\\")
    end
    visual_target.zhenfa_effect.Color = "255,255,0,0"
  end
end
function get_captain_visual(client_scene_obj)
  if not nx_is_valid(client_scene_obj) then
    return nx_null()
  end
  local team_id = client_scene_obj:QueryProp("TeamID")
  if team_id < 0 then
    return nx_null()
  end
  local leader_name = client_scene_obj:QueryProp("TeamCaptain")
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_client) or not nx_is_valid(game_visual) then
    return nx_null()
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return nx_null()
  end
  local obj_list = client_scene:GetSceneObjList()
  for i = 1, table.maxn(obj_list) do
    local client_obj = obj_list[i]
    if client_obj:FindProp("Name") then
      local name = client_obj:QueryProp("Name")
      if nx_string(name) == nx_string(leader_name) then
        return game_visual:GetSceneObj(client_obj.Ident)
      end
    end
  end
  return nx_null()
end
function custom_neigpk_effect(ident, name)
  local game_visual = nx_value("game_visual")
  local visual_target = game_visual:GetSceneObj(ident)
  if not nx_is_valid(visual_target) then
    return
  end
  nx_execute("game_effect", "create_effect", name, visual_target, visual_target)
end
function check_spy_effect(obj, effect_name, bAdd)
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local obj = game_client:GetSceneObj(nx_string(obj))
  if not nx_is_valid(obj) then
    return
  end
  local visual_target = game_visual:GetSceneObj(nx_string(obj.Ident))
  if visual_target == nil or not nx_is_valid(visual_target) then
    return
  end
  if not nx_find_custom(visual_target, effect_name) then
    nx_set_custom(visual_target, effect_name, 0)
  end
  local bFind = 0 < nx_custom(visual_target, effect_name)
  if bAdd and not bFind then
    nx_execute("game_effect", "create_effect", effect_name, visual_target, visual_target)
    nx_set_custom(visual_target, effect_name, 1)
  elseif bFind and not bAdd then
    nx_execute("game_effect", "remove_effect", effect_name, visual_target, visual_target)
    nx_set_custom(visual_target, effect_name, 0)
  end
end
function create_zhenfa_decal(target_ident, zhenfa_map_id, x, y, z, o, lifetime)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene_obj = game_client:GetSceneObj(nx_string(target_ident))
  if not nx_is_valid(client_scene_obj) then
    return
  end
  local array_list
  local array_name = nx_string(client_scene_obj) .. "ZHENFA_SKILL_DECAL"
  if not nx_find_value(array_name) then
    array_list = nx_create("ArrayList", array_name)
    if not nx_is_valid(array_list) then
      return
    end
    nx_set_value(array_name, array_list)
  else
    array_list = nx_value(array_name)
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return
  end
  local zhenyan_effect = "battleform_effect_1a"
  local zhenyan_color = ""
  local ini = nx_execute("util_functions", "get_ini", "share\\Skill\\zhenfa_map.ini")
  if nx_is_valid(ini) then
    local sec_index = ini:FindSectionIndex(nx_string(zhenfa_map_id))
    if sec_index < 0 then
      return
    end
    local map_effect = ini:ReadString(sec_index, "map_effect", "")
    local map_radius = ini:ReadString(sec_index, "map_radius", "")
    if map_effect ~= "" then
      if 0 >= nx_number(map_radius) then
        map_radius = 5
      end
      local decal = nx_execute("game_effect", "create_ground_decal", "zhenfa_ground_decal", x, y, z, nx_number(map_radius), map_effect, true, o)
      if nx_is_valid(decal) then
        local child = array_list:CreateChild(nx_string(decal))
        child.decal_id = decal
        child.life_time = nx_int(lifetime)
        local common_execute = nx_value("common_execute")
        if nx_is_valid(common_execute) then
          common_execute:AddExecute("ZhenFaSkillDecal", client_scene_obj, 1, nx_string(decal))
        end
      end
    end
  end
end
