require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("gui")
local form_name = "form_stage_main\\form_life\\form_fishing_op"
local flag = false
local refresh_error_first = true
function form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local databinder = nx_value("data_binder")
  if databinder then
    databinder:AddRolePropertyBind("FishingValue", "float", form.pbar_fishing, form_name, "refresh_fishing")
    databinder:AddRolePropertyBind("FishingState", "int", form.btn_fishing, form_name, "refresh_fishingstate")
    databinder:AddRolePropertyBind("ErrorTimes", "int", form, form_name, "refresh_error")
  end
  nx_execute("gui", "gui_close_allsystem_form")
  init_form(form)
  refresh_form(form)
  form.Visible = true
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if databinder then
    databinder:DelRolePropertyBind("FishingValue", form.pbar_fishing)
    databinder:DelRolePropertyBind("FishingState", form.btn_fishing)
    databinder:DelRolePropertyBind("ErrorTimes", form)
  end
  nx_execute("gui", "gui_open_closedsystem_form")
  form.Visible = false
  nx_destroy(form)
end
function open_form()
  local form = nx_execute("util_gui", "util_get_form", form_name, true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
end
function init_form(form)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_fishing.Visible = false
end
function refresh_form(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Width
  form.Height = gui.Height
  form.groupbox_back.Left = 0
  form.groupbox_back.Top = 0
  form.groupbox_back.Width = gui.Width
  form.groupbox_back.Height = gui.Height
  form.groupbox_fishing.AbsLeft = (gui.Width - form.groupbox_fishing.Width) / 2
  form.groupbox_fishing.AbsTop = (gui.Height - form.groupbox_fishing.Height) / 2 + gui.Height / 15
end
function change_form_size()
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  refresh_form(form)
end
function refresh_fishing(progress_bar, prop_name, prop_type, prop_value)
  if not nx_is_valid(progress_bar) then
    return
  end
  local form = progress_bar.ParentForm
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local fishing_value = nx_number(client_player:QueryProp("FishingValue"))
  if progress_bar.Visible then
    local offset = (progress_bar.EndDelta - progress_bar.BeginDelta) * fishing_value / 100 + progress_bar.BeginDelta - 180
    local r = progress_bar.Width / 2 - 26
    local pi = math.pi
    local fish_left = progress_bar.Left + progress_bar.Width / 2 - r * math.cos(offset / 180 * pi)
    local fish_top = progress_bar.Top + progress_bar.Height / 2 - r * math.sin(offset / 180 * pi)
    form.lbl_fish.Left = fish_left - form.lbl_fish.Width / 2
    form.lbl_fish.Top = fish_top - form.lbl_fish.Height / 2
    progress_bar.Value = fishing_value
  end
end
function refresh_fishingstate(self)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local scene = nx_value("game_scene")
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_player = game_client:GetPlayer()
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not nx_is_valid(visual_player) then
    return
  end
  local role = visual_player:GetLinkObject("actor_role")
  local terrain = scene.terrain
  local x = visual_player.PositionX
  local y = visual_player.PositionY
  local z = visual_player.PositionZ
  local fishing_state = nx_number(client_player:QueryProp("FishingState"))
  if fishing_state == 0 then
    on_end_game()
    flag = false
  elseif fishing_state == 1 then
    on_wait_fish(form)
  elseif fishing_state == 2 then
    on_pull_fish(form)
  elseif fishing_state == 3 then
    on_free_fish(form)
  end
end
function on_btn_fishing_right_click(self)
  nx_execute("custom_sender", "custom_op_fishing")
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  local action_module = nx_value("action_module")
  if nx_is_valid(action_module) then
    action_module:DoAction(visual_player, "interact268")
  end
end
function refresh_error(form)
  local form = nx_value(form_name)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local light_on = "gui\\mainform\\smallgame\\life_on.png"
  local light_down = "gui\\mainform\\smallgame\\life_down.png"
  local error_times = nx_number(client_player:QueryProp("ErrorTimes"))
  if 5 <= error_times then
    form.lbl_1.BackImage = light_on
    form.lbl_2.BackImage = light_on
    form.lbl_3.BackImage = light_on
    form.lbl_4.BackImage = light_on
    form.lbl_5.BackImage = light_on
    if refresh_error_first then
      refresh_error_first = false
    end
  elseif error_times == 4 then
    form.lbl_1.BackImage = light_on
    form.lbl_2.BackImage = light_on
    form.lbl_3.BackImage = light_on
    form.lbl_4.BackImage = light_on
    form.lbl_5.BackImage = light_down
    if refresh_error_first then
      form.lbl_5.Visible = false
      refresh_error_first = false
    end
  elseif error_times == 3 then
    form.lbl_1.BackImage = light_on
    form.lbl_2.BackImage = light_on
    form.lbl_3.BackImage = light_on
    form.lbl_4.BackImage = light_down
    form.lbl_5.BackImage = light_down
    if refresh_error_first then
      form.lbl_4.Visible = false
      form.lbl_5.Visible = false
      refresh_error_first = false
    end
  elseif error_times == 2 then
    form.lbl_1.BackImage = light_on
    form.lbl_2.BackImage = light_on
    form.lbl_3.BackImage = light_down
    form.lbl_4.BackImage = light_down
    form.lbl_5.BackImage = light_down
    if refresh_error_first then
      form.lbl_3.Visible = false
      form.lbl_4.Visible = false
      form.lbl_5.Visible = false
      refresh_error_first = false
    end
  elseif error_times == 1 then
    form.lbl_1.BackImage = light_on
    form.lbl_2.BackImage = light_down
    form.lbl_3.BackImage = light_down
    form.lbl_4.BackImage = light_down
    form.lbl_5.BackImage = light_down
    if refresh_error_first then
      form.lbl_2.Visible = false
      form.lbl_3.Visible = false
      form.lbl_4.Visible = false
      form.lbl_5.Visible = false
      refresh_error_first = false
    end
  end
end
function FishingProcess(client_scene_obj, visual_scene_obj, cur_logic, old_logic)
  if not nx_is_valid(client_scene_obj) or not nx_is_valid(visual_scene_obj) then
    return
  end
  if nx_int(cur_logic) == nx_int(LS_FISHING) and nx_int(old_logic) ~= nx_int(LS_FISHING) then
    emit_player_input(visual_scene_obj, PLAYER_INPUT_LOGIC, LOGIC_BEGIN_FISHING)
  elseif nx_int(cur_logic) ~= nx_int(LS_FISHING) and nx_int(old_logic) == nx_int(LS_FISHING) then
    emit_player_input(visual_scene_obj, PLAYER_INPUT_LOGIC, LOGIC_END_FISHING)
    nx_execute("game_effect", "remove_effect", "", visual_obj, visual_obj)
  end
end
function end_fishing()
  nx_execute("custom_sender", "custom_begin_fishing", 1)
end
function get_select_target(role)
  local target = nx_null()
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_client) and nx_is_valid(game_visual) and not nx_find_value("form_action_blend") then
    local client_ident = game_visual:QueryRoleClientIdent(role)
    if client_ident == "" then
      return nx_null()
    end
    local self_client_obj = game_client:GetSceneObj(client_ident)
    if not nx_is_valid(self_client_obj) then
      return nx_null()
    end
    if not self_client_obj:FindProp("LastObject") then
      return nx_null()
    end
    local select_target_ident = nx_string(self_client_obj:QueryProp("LastObject"))
    target = game_visual:GetSceneObj(nx_string(select_target_ident))
  else
    target = nx_value("target_player")
  end
  return target
end
function start_fishing()
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(client_player) or not nx_is_valid(visual_player) then
    return
  end
  local role = game_visual:GetSceneObj(client_player.Ident)
  if not nx_is_valid(role) then
    return
  end
  if nx_find_custom(role, "state") and role.state ~= "static" then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("12214"))
    return
  end
  local target = get_select_target(visual_player)
  if not nx_is_valid(target) then
    return
  end
  local scene_obj = nx_value("scene_obj")
  if not nx_is_valid(scene_obj) then
    return
  end
  scene_obj:SceneObjAdjustAngle(visual_player, target.PositionX, target.PositionZ)
  local send_move = nx_value("send_move")
  if not nx_is_valid(send_move) then
    return
  end
  send_move:SendStopAt(0, visual_player.PositionX, visual_player.PositionY, visual_player.PositionZ, visual_player.face_angle)
  nx_execute("custom_sender", "custom_begin_fishing", 0)
end
function get_start_action()
  return "interact046"
end
function get_state_action()
  return "interact047"
end
function get_finish_action(role)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(role) then
    return
  end
  local client_ident = game_visual:QueryRoleClientIdent(role)
  if client_ident == "" then
    return
  end
  local client_obj = game_client:GetSceneObj(client_ident)
  if not nx_is_valid(client_obj) then
    return
  end
  local result = client_obj:QueryProp("FishingRusult")
  if result == 1 then
    client_obj.modx = "ini\\npc\\cj_101026a.ini"
    client_obj.fishweight = 1
    if client_obj:FindProp("FishModID") then
      client_obj.modx = client_obj:QueryProp("FishModID")
    end
    if client_obj:FindProp("FishWeight") then
      client_obj.fishweight = client_obj:QueryProp("FishWeight")
    end
    return "interact048"
  end
  return ""
end
function get_yu_piao()
  return "obj\\item\\npcitem\\npcitem429\\npcitem429.xmod"
end
function is_in_fishing()
  local form = nx_value("form_stage_main\\form_life\\form_fishing_op")
  if not nx_is_valid(form) then
    return false
  end
  return true
end
function on_end_game()
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  refresh_error_first = true
  form.groupbox_fishing.Visible = false
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local result = nx_number(client_player:QueryProp("FishingRusult"))
  if result == 1 then
    local timer = nx_value(GAME_TIMER)
    timer:Register(4000, 1, nx_current(), "auto_close_form", form, -1, -1)
  else
    auto_close_form(form)
  end
end
function on_wait_fish(form)
  local gui = nx_value("gui")
  form.groupbox_light.Visible = false
  form.lbl_1.Visible = true
  form.lbl_2.Visible = true
  form.lbl_3.Visible = true
  form.lbl_4.Visible = true
  form.lbl_5.Visible = true
  form.btn_fishing.Visible = false
  form.lbl_fish.Visible = false
  form.pbar_fishing.Visible = false
  form.lbl_result.Visible = false
  form.pbar_fishing.Value = 0
  local text = gui.TextManager:GetFormatText("ui_waitingfish")
  form.lbl_fishing_tip.Text = text
end
function on_pull_fish(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_player = game_client:GetPlayer()
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not nx_is_valid(visual_player) then
    return
  end
  local x = visual_player.PositionX
  local y = visual_player.PositionY
  local z = visual_player.PositionZ
  form.groupbox_fishing.Visible = true
  form.groupbox_light.Visible = true
  form.pbar_fishing.Visible = true
  form.btn_fishing.Visible = true
  form.lbl_fish.Visible = true
  refresh_fishing(form.pbar_fishing)
  form.btn_fishing.NormalImage = "fishing_mouse1"
  form.btn_fishing.FocusImage = "fishing_mouse3"
  form.btn_fishing.PushImage = "fishing_mouse2"
  form.lbl_fish.BackImage = "gui\\mainform\\smallgame\\Fishing_fish.png"
  local text = gui.TextManager:GetFormatText("ui_pullfish")
  form.lbl_fishing_tip.Text = text
  if not flag then
    local filename = "snd\\action\\minigame\\fishing\\fishing03.wav"
    play_sound(filename)
    flag = true
  end
end
function on_free_fish(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_player = game_client:GetPlayer()
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not nx_is_valid(visual_player) then
    return
  end
  local x = visual_player.PositionX
  local y = visual_player.PositionY
  local z = visual_player.PositionZ
  form.groupbox_fishing.Visible = true
  form.groupbox_back.Visible = true
  form.groupbox_light.Visible = true
  form.pbar_fishing.Visible = true
  form.btn_fishing.Visible = true
  form.lbl_fish.Visible = true
  form.btn_fishing.NormalImage = "gui\\mainform\\smallgame\\Fishing-free-outon.png"
  form.btn_fishing.FocusImage = "gui\\mainform\\smallgame\\Fishing-free-outon.png"
  form.btn_fishing.PushImage = "gui\\mainform\\smallgame\\Fishing-free-down.png"
  form.lbl_fish.BackImage = "fishing_mouse4"
  local text = gui.TextManager:GetFormatText("ui_pushrope")
  form.lbl_fishing_tip.Text = text
  local filename = "snd\\action\\minigame\\fishing\\fishing04.wav"
  play_sound(filename)
end
function showResult(form, res)
  local form = nx_value("form_stage_main\\form_life\\form_fishing_op")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local victory = "gui\\mainform\\smallgame\\victory.png"
  local lost = "gui\\language\\ChineseS\\minigame\\lost.png"
  form.lbl_result.Visible = true
  if res == 1 then
    form.lbl_result.BackImage = victory
    form.lbl_result.AbsTop = form.groupbox_fishing.AbsTop - form.lbl_result.Height + 20
    local timer = nx_value(GAME_TIMER)
    timer:Register(4000, 1, nx_current(), "auto_close_form", form, -1, -1)
  else
    form.lbl_result.BackImage = lost
    form.lbl_result.AbsTop = (gui.Height - form.lbl_result.Height) / 2
    auto_close_form(form)
  end
  form.lbl_result.AbsLeft = (form.Width - form.lbl_result.Width) / 2
end
function auto_close_form(form)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_alpha_changed(delta)
  local form = nx_value("form_stage_main\\form_life\\form_fishing_op")
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_back.BlendAlpha = form.groupbox_back.BlendAlpha - delta
end
function GetFormIsVisable()
  local form = nx_value("form_stage_main\\form_life\\form_fishing_op")
  if not nx_is_valid(form) then
    return false
  end
  return true
end
function play_sound(filename)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not gui:FindSound("sound_qingame") then
    gui:AddSound("sound_qingame", nx_resource_path() .. filename)
  end
  gui:PlayingSound("sound_qingame")
end
