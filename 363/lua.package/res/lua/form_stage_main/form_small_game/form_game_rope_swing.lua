require("const_define")
require("util_functions")
require("util_gui")
require("role_composite")
local process_stage = 1
local display_interval = 10
local display_flag = false
local ACTID_STAND = 1
local ACTID_LAYDOWN = 2
local ACTID_TURNOVER = 3
local ACTID_CLIMB = 4
local ACTID_DROP = 5
local ACTID_FREEZE = 10
local ACTID_TINY_SWING = 11
local ACTID_NORMAL_SWING = 12
local ACTID_INFORMAL_SWING = 13
local role_actions = {
  [ACTID_CLIMB] = "interact498",
  [ACTID_DROP] = "interact502",
  [ACTID_STAND] = "interact499",
  [ACTID_LAYDOWN] = "interact500",
  [ACTID_TURNOVER] = "interact501"
}
local rope_actions = {
  [ACTID_FREEZE] = "rope_001",
  [ACTID_TINY_SWING] = "rope_003",
  [ACTID_NORMAL_SWING] = "rope_004",
  [ACTID_INFORMAL_SWING] = "rope_005"
}
local get_role_face = function(actor2)
  local actor_role = actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    return nil
  end
  local actor_role_face = actor_role:GetLinkObject("actor_role_face")
  if not nx_is_valid(actor_role_face) then
    return nil
  end
  return actor_role_face
end
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  refresh_form_pos(self)
  on_reset_ball(self)
  nx_execute("gui", "gui_close_allsystem_form")
  self.pbar_time.Visible = true
  self.btn_skill.Visible = false
  self.lbl_skill_desc.Visible = false
  self.groupbox_sbg.Visible = false
end
function refresh_form_pos(form)
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Width
  form.Height = gui.Height
  form.groupbox_back.AbsLeft = 0
  form.groupbox_back.AbsTop = 0
  form.groupbox_back.Width = gui.Width
  form.groupbox_back.Height = gui.Height
  form.groupbox_main.AbsLeft = (gui.Width - form.groupbox_main.Width) / 2
  form.groupbox_main.AbsTop = (gui.Height - form.groupbox_main.Height) / 2
  form.groupbox_word.BackImage = "gui/mainform/smallgame/RopeSwingGame/bg1.png"
  form.groupbox_word.Left = (form.groupbox_main.Width - form.groupbox_word.Width) / 2 - 15
  form.groupbox_word.Top = (form.groupbox_main.Height - form.groupbox_word.Height) / 2
  form.pbar_time.Left = form.groupbox_word.Left + form.groupbox_word.Width + 20
  form.pbar_time.Top = form.groupbox_word.Top + form.groupbox_word.Height - form.pbar_time.Height
  form.scenebox_action.Height = 0.8 * form.groupbox_word.Height - form.groupbox_sbg.Height
  form.scenebox_action.Width = form.groupbox_word.Width / 2
  form.scenebox_action.Top = 0.1 * form.groupbox_word.Height
  form.scenebox_action.Left = (form.groupbox_word.Width - form.scenebox_action.Width) / 2
  form.groupbox_sbg.Left = (form.groupbox_main.Width - form.groupbox_sbg.Width) / 2 - 15
  form.groupbox_sbg.Top = form.groupbox_word.Top + form.scenebox_action.Top + form.scenebox_action.Height + 20
  form.lbl_ball.Left = form.groupbox_sbg.Width / 2 - form.lbl_ball.Width / 2
  form.btn_start.Left = (form.groupbox_main.Width - form.btn_start.Width) / 2 - 15
  form.btn_start.Top = form.groupbox_word.Top + form.groupbox_word.Height - 2 * form.btn_start.Height
  form.btn_close.Left = form.groupbox_main.AbsLeft + form.groupbox_main.Width + 3
  form.btn_close.Top = form.groupbox_main.AbsTop + 6
  form.btn_help.Left = form.btn_close.Left
  form.btn_help.Top = form.btn_close.Top + form.btn_close.Height + 5
  form.btn_skill.Left = form.groupbox_sbg.Left + form.groupbox_sbg.Width + 20
  form.btn_skill.Top = form.groupbox_sbg.Top
  form.lbl_skill_desc.Left = form.btn_skill.Left
  form.lbl_skill_desc.Top = form.btn_skill.Top + form.btn_skill.Height
  return
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_small_game\\form_game_rope_swing")
  if not nx_is_valid(form) then
    return
  end
  refresh_form_pos(form)
end
function on_main_form_close(self)
  process_stage = 1
  nx_execute("gui", "gui_open_closedsystem_form")
  nx_destroy(self)
  nx_set_value("form_stage_main\\form_small_game\\form_game_rope_swing", nx_null())
end
function on_btn_close_click(btn)
  show_close_dialog(btn.ParentForm)
end
function cancel_game()
  local form = nx_value("form_stage_main\\form_small_game\\form_game_rope_swing")
  if nx_is_valid(form) then
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister("form_stage_main\\form_small_game\\form_game_rope_swing", "on_update_ball", form)
    form:Close()
  end
end
function set_help_text(text)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_rope_swing")
  if not nx_is_valid(form) then
    return
  end
  form.helptext = nx_string(text)
end
function set_stage_time(secs)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_rope_swing")
  if not nx_is_valid(form) then
    return
  end
  form.pbar_time.Minimum = 0
  form.pbar_time.Maximum = secs * 10
  return
end
function show_close_dialog(form)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(util_text("ui_smallgametc"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    if not nx_is_valid(form) then
      return
    end
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister("form_stage_main\\form_small_game\\form_game_rope_swing", "on_update_ball", form)
    form:Close()
    local RopeSwingGame = nx_value("RopeSwingGame")
    RopeSwingGame:SendError()
  end
end
function on_reset_ball(form)
  form.lbl_ball.Left = form.groupbox_sbg.Width / 2 - form.lbl_ball.Width / 2
end
function set_backimage(image)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_rope_swing")
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_main.AutoSize = true
  form.groupbox_main.BackImage = "gui/mainform/smallgame/RopeSwingGame/bg.png"
  refresh_form_pos(form)
  return
end
function set_btn_pos(close_btn_pos, help_btn_pos, start_btn_pos)
  do return end
  local form = nx_value("form_stage_main\\form_small_game\\form_game_rope_swing")
  if not nx_is_valid(form) then
    return
  end
  if nx_string(close_btn_pos) ~= "" then
    local table_close = util_split_string(close_btn_pos, ",")
    if table.getn(table_close) == 2 then
      form.btn_close.Left = nx_number(table_close[1])
      form.btn_close.Top = nx_number(table_close[2])
    end
  end
  if nx_string(help_btn_pos) ~= "" then
    local table_help = util_split_string(help_btn_pos, ",")
    if table.getn(table_help) == 2 then
      form.btn_help.Left = nx_number(table_help[1])
      form.btn_help.Top = nx_number(table_help[2])
    end
  end
  if nx_string(start_btn_pos) ~= "" then
    local table_start = util_split_string(start_btn_pos, ",")
    if table.getn(table_start) == 2 then
      form.btn_start.Left = nx_number(table_start[1])
      form.btn_start.Top = nx_number(table_start[2])
    end
  end
end
function on_btn_left_click(btn)
  local RopeSwingGame = nx_value("RopeSwingGame")
  if RopeSwingGame == nil or not nx_is_valid(RopeSwingGame) then
    return
  end
  RopeSwingGame:LeftDown()
end
function on_btn_right_click(btn)
  local RopeSwingGame = nx_value("RopeSwingGame")
  if RopeSwingGame == nil or not nx_is_valid(RopeSwingGame) then
    return
  end
  RopeSwingGame:RightDown()
end
function on_game_end(res)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_rope_swing")
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister("form_stage_main\\form_small_game\\form_game_rope_swing", "on_update_ball", form)
  form.groupbox_main.Visible = false
  local gui = nx_value("gui")
  local Label = gui:Create("Label")
  Label.AutoSize = true
  Label.Name = "lab_res"
  local victory = "gui\\language\\ChineseS\\minigame\\victory.png"
  local lost = "gui\\language\\ChineseS\\minigame\\lost.png"
  if res == 1 then
    Label.BackImage = victory
    Label.AbsTop = (gui.Height - Label.Height) / 2 - Label.Height - 40
  else
    Label.BackImage = lost
    Label.AbsTop = (gui.Height - Label.Height) / 2
  end
  Label.AbsLeft = (form.Width - Label.Width) / 2
  form:Add(Label)
  local timer = nx_value(GAME_TIMER)
  timer:Register(2500, 1, "form_stage_main\\form_small_game\\form_game_rope_swing", "auto_close_form", form, -1, -1)
end
function auto_close_form(form)
  if nx_is_valid(form) then
    form:Close()
  end
end
function game_key_down(gui, key, shift, ctrl)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_rope_swing")
  if not nx_is_valid(form) then
    return
  end
  if shift or ctrl then
    return
  end
  if key == "A" or key == "Left" then
    on_btn_left_click(form.btn_left)
    return
  end
  if key == "D" or key == "Right" then
    on_btn_right_click(form.btn_right)
    return
  end
end
function on_tbar_1_value_changed(self)
  local groupbox = self.ParentForm.groupbox_back
  if self.Value >= 0 and self.Value <= 100 then
    groupbox.BlendAlpha = 255 * self.Value / 100
  end
end
function on_btn_help_click(self)
  local form = self.ParentForm
  local groupbox = form.groupbox_main
  local groupboxhelp = groupbox:Find("groupbox_help")
  if not nx_is_valid(groupboxhelp) then
    local gui = nx_value("gui")
    groupboxhelp = gui:Create("GroupBox")
    groupboxhelp.AutoSize = true
    groupboxhelp.Name = "groupbox_help"
    groupboxhelp.BackImage = "gui\\language\\ChineseS\\minigame\\gamehelp.png"
    groupboxhelp.AbsLeft = (groupbox.Width - groupboxhelp.Width) / 2
    groupboxhelp.AbsTop = (groupbox.Height - groupboxhelp.Height) / 2
    local button = gui:Create("Button")
    local closebutton = form.groupbox_back:Find("btn_close")
    button.AutoSize = true
    button.NormalImage = closebutton.NormalImage
    button.FocusImage = closebutton.FocusImage
    button.PushImage = closebutton.PushImage
    button.AbsLeft = groupboxhelp.Width - button.Width - 30
    button.AbsTop = 30
    nx_bind_script(button, nx_current())
    nx_callback(button, "on_click", "on_close_helpbox")
    local multitextbox = gui:Create("MultiTextBox")
    multitextbox.AutoSize = true
    multitextbox.AbsLeft = 40
    multitextbox.AbsTop = button.AbsTop + button.Height + 30
    multitextbox.Width = groupboxhelp.Width - 80
    multitextbox.Height = groupboxhelp.Height - 70 - button.Height
    multitextbox.MouseInBarColor = "0,0,0,0"
    multitextbox.ViewRect = nx_string("0,0," .. nx_string(multitextbox.Width) .. "," .. nx_string(multitextbox.Height))
    multitextbox.BackColor = "0,0,0,0"
    multitextbox.LineColor = "0,0,0,0"
    multitextbox.SelectBarColor = "0,0,0,0"
    multitextbox.TextColor = "255,0,0,0"
    multitextbox.HtmlText = nx_widestr(gui.TextManager:GetText(form.helptext))
    groupboxhelp:Add(multitextbox)
    groupboxhelp:Add(button)
    groupbox:Add(groupboxhelp)
  else
    groupboxhelp.Visible = true
  end
end
function on_close_helpbox(self)
  groupbox = self.Parent
  groupbox.Visible = false
end
function on_alpha_changed(delta)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_rope_swing")
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_back.BlendAlpha = form.groupbox_back.BlendAlpha - delta
end
function interval_operate(form)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister("form_stage_main\\form_small_game\\form_game_rope_swing", "on_update_ball", form)
  on_reset_ball(form)
  form.pbar_time.Value = 0
  form.groupbox_sbg.Visible = true
  if process_stage == 1 then
    if display_flag then
      display_flag = false
      display_action(form, ACTID_STAND, ACTID_TINY_SWING)
    end
    form.btn_skill.NormalImage = "icon\\skill\\gmp_yswc_01_out.png"
    form.btn_skill.FocusImage = "icon\\skill\\gmp_yswc_01_on.png"
    form.btn_skill.PushImage = "icon\\skill\\gmp_yswc_01_down.png"
    form.lbl_skill_desc.Text = nx_widestr("\213\190\193\162")
  elseif process_stage == 2 then
    form.btn_skill.NormalImage = "icon\\skill\\gmp_yswc_02_out.png"
    form.btn_skill.FocusImage = "icon\\skill\\gmp_yswc_02_on.png"
    form.btn_skill.PushImage = "icon\\skill\\gmp_yswc_02_down.png"
    form.lbl_skill_desc.Text = nx_widestr("\204\201\207\194")
  elseif process_stage == 3 then
    form.btn_skill.NormalImage = "icon\\skill\\gmp_yswc_03_out.png"
    form.btn_skill.FocusImage = "icon\\skill\\gmp_yswc_03_on.png"
    form.btn_skill.PushImage = "icon\\skill\\gmp_yswc_03_down.png"
    form.lbl_skill_desc.Text = nx_widestr("\183\173\201\237")
  else
    local RopeSwingGame = nx_value("RopeSwingGame")
    if not nx_is_valid(RopeSwingGame) then
      return
    end
    RopeSwingGame:UpDateGame(process_stage)
  end
  form.btn_skill.Visible = true
  form.lbl_skill_desc.Visible = true
  return
end
function on_update_ball(form, param1, param2)
  local RopeSwingGame = nx_value("RopeSwingGame")
  if RopeSwingGame == nil or not nx_is_valid(RopeSwingGame) then
    return
  end
  local ret = RopeSwingGame:UpDateGame(param1)
  if ret == false then
    form.pbar_time.Value = 0
    handle_failure(form)
    return
  end
  if param1 ~= -1 then
    local pBar = form.pbar_time
    pBar.Value = pBar.Value + 1
    if pBar.Value == pBar.Maximum then
      pBar.Value = 0
      display_action(form, process_stage, ACTID_NORMAL_SWING)
      process_stage = process_stage + 1
      interval_operate(form)
    end
  end
  return
end
function update_game(current_pos, current_pro)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_rope_swing")
  if not nx_is_valid(form) then
    return
  end
  if current_pos <= -100 or 100 <= current_pos then
    return
  end
  local nDeltaLeft = form.groupbox_sbg.Width / 2 - form.lbl_ball.Width / 2
  local pos = nDeltaLeft * current_pos / 100
  form.lbl_ball.Left = nDeltaLeft + pos
  offset = math.abs(current_pos)
  if nx_is_valid(form.Actor2) then
    form.Actor2.Speed = nx_number(math.abs(current_pos) / 30 + 1)
  end
  return
end
function display_action(form, role_action_id, rope_action_id)
  if not nx_is_valid(form.scenebox_action.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_action)
  end
  if not nx_is_valid(form.scenebox_action.Scene) then
    return
  end
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return nil
  end
  if not nx_find_custom(form, "Actor2") or not nx_is_valid(form.Actor2) then
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    form.Actor2 = create_scene_object_composite(form.scenebox_action.Scene, client_player, false)
    if not nx_is_valid(form.Actor2) then
      return nil
    end
    nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_action, form.Actor2)
    form.Actor2:SetAngle(0, math.pi * -90 / 180, 0)
    local fScale = 1
    if client_player:FindProp("BodyScale") then
      fScale = client_player:QueryProp("BodyScale")
    end
    local camera = form.scenebox_action.Scene.camera
    if nx_is_valid(camera) then
      camera:SetAngle(math.pi * 8 / 180, 0, 0)
      camera:SetPosition(camera.PositionX, camera.PositionY + 1.9 * fScale, camera.PositionZ - 0.8)
    end
    action:ActionInit(form.Actor2)
  end
  local role_action_id = role_action_id or ACTID_STAND
  local rope_action_id = rope_action_id or ACTID_NORMAL_SWING
  local actor_rope = form.Actor2
  local actor_role = form.Actor2:GetLinkObject("actor_role")
  action:ClearAction(form.Actor2)
  action:ClearState(form.Actor2)
  form.Actor2.Speed = nx_number(1)
  local isRopeActLoop = true
  local isRoleActLoop = true
  if rope_action_id == ACTID_INFORMAL_SWING or rope_action_id == ACTID_FREEZE then
    isRopeActLoop = false
  end
  if role_action_id == ACTID_CLIMB or role_action_id == ACTID_DROP then
    isRoleActLoop = false
  end
  action:BlendAction(actor_rope, rope_actions[rope_action_id], isRopeActLoop, true)
  action:BlendAction(actor_role, role_actions[role_action_id], isRoleActLoop, true)
  return
end
function handle_failure(form)
  process_stage = 1
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister("form_stage_main\\form_small_game\\form_game_rope_swing", "on_update_ball", form)
  form.groupbox_sbg.Visible = false
  display_flag = true
  display_action(form, ACTID_DROP, ACTID_INFORMAL_SWING)
  timer:Register(3600, 1, "form_stage_main\\form_small_game\\form_game_rope_swing", "display_action", form, ACTID_CLIMB, ACTID_FREEZE)
  timer:Register(6600, 1, "form_stage_main\\form_small_game\\form_game_rope_swing", "interval_operate", form, -1, -1)
  return
end
function on_btn_start_click(btn)
  local form = btn.ParentForm
  on_reset_ball(form)
  local RopeSwingGame = nx_value("RopeSwingGame")
  if not nx_is_valid(RopeSwingGame) then
    return
  end
  RopeSwingGame:InitGame()
  RopeSwingGame:SetIsInGame(true)
  display_flag = true
  form.btn_start.Visible = false
  display_action(form, ACTID_CLIMB, ACTID_FREEZE, true)
  local timer = nx_value(GAME_TIMER)
  timer:Register(3600, 1, "form_stage_main\\form_small_game\\form_game_rope_swing", "interval_operate", form, -1, -1)
  return
end
function on_btn_skill_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister("form_stage_main\\form_small_game\\form_game_rope_swing", "on_update_ball", form)
  local RopeSwingGame = nx_value("RopeSwingGame")
  if not nx_is_valid(RopeSwingGame) then
    return
  end
  RopeSwingGame:InitGame()
  if process_stage == 1 then
    display_action(form, ACTID_STAND, ACTID_NORMAL_SWING)
  elseif process_stage == 2 then
    display_action(form, ACTID_LAYDOWN, ACTID_NORMAL_SWING)
  elseif process_stage == 3 then
    display_action(form, ACTID_TURNOVER, ACTID_NORMAL_SWING)
  end
  timer:Register(100, -1, "form_stage_main\\form_small_game\\form_game_rope_swing", "on_update_ball", form, process_stage, -1)
  form.btn_skill.Visible = false
  form.lbl_skill_desc.Visible = false
  return
end
function create_scene_object_composite(scene, client_scene_obj, include_mount, debug_info)
  if not nx_is_valid(scene) then
    scene = nx_value("game_scene")
    if not nx_is_valid(scene) then
      return nx_null()
    end
  end
  if not nx_is_valid(client_scene_obj) then
    return nx_null()
  end
  local actor2 = nx_null()
  local sex = client_scene_obj:QueryProp("Sex")
  local game_client = nx_value("game_client")
  if game_client:IsPlayer(client_scene_obj.Ident) then
    actor2 = create_rope_and_role_composite(scene, true, sex, client_scene_obj)
  else
    actor2 = create_rope_and_role_composite(scene, true, sex, client_scene_obj)
  end
  if not nx_is_valid(actor2) then
    return nx_null()
  end
  actor2.client_ident = nx_string(client_scene_obj.Ident)
  create_appearance(actor2, client_scene_obj)
  register_action_event(actor2, client_scene_obj)
  return actor2
end
function create_rope_and_role_composite(scene, async_load, sex, client_scene_obj)
  if not nx_is_valid(client_scene_obj) then
    return
  end
  local actor_rope = create_actor2(scene, "create_rope_and_role_composite")
  if not nx_is_valid(actor_rope) then
    return nx_null()
  end
  actor_rope.AsyncLoad = async_load
  local rope_action_file = "obj\\item\\npcitem\\npcitem838\\action.ini"
  local rope_main_model = "obj\\item\\npcitem\\npcitem838\\Tpose.xmod"
  actor_rope.default_action = rope_actions[ACTID_NORMAL_SWING]
  if not actor_rope:SetActionEx(rope_action_file, actor_rope.default_action, "", false) then
    scene:Delete(actor2)
    scene:Delete(actor_rope)
    return nx_null()
  end
  if not actor_rope:AddSkin("main_model", rope_main_model) then
    scene:Delete(actor2)
    scene:Delete(actor_rope)
    return nx_null()
  end
  while not actor_rope.LoadFinish do
    nx_pause(0)
  end
  local body_type = 0
  if client_scene_obj:FindProp("BodyType") then
    body_type = client_scene_obj:QueryProp("BodyType")
  end
  if body_type == nil or body_type <= 2 then
    create_role_composite_with_actor2(scene, actor_rope, false, sex, role_actions[ACTID_STAND])
  else
    create_role_composite_with_actor2_body(scene, actor_rope, false, sex, role_actions[ACTID_STAND], body_type)
  end
  while not actor_rope.LoadFinish do
    nx_pause(0)
  end
  return actor_rope
end
function create_appearance(actor2, client_scene_obj)
  local skin_info = {
    [1] = {link_name = "face", prop = "Face"},
    [2] = {link_name = "impress", prop = "Impress"},
    [3] = {link_name = "mask", prop = "Mask"},
    [4] = {link_name = "hat", prop = "Hat"},
    [5] = {link_name = "cloth", prop = "Cloth"},
    [6] = {link_name = "pants", prop = "Pants"},
    [7] = {link_name = "shoes", prop = "Shoes"},
    [8] = {link_name = "mantle", prop = "Mantle"}
  }
  local role_composite = nx_value("role_composite")
  for i, info in pairs(skin_info) do
    if nx_is_valid(client_scene_obj) and client_scene_obj:FindProp(info.prop) then
      if info.link_name == "face" then
        local body_face = 0
        if client_scene_obj:FindProp("BodyFace") then
          body_face = client_scene_obj:QueryProp("BodyFace")
        end
        if nx_is_valid(role_composite) then
          if 0 < body_face then
            role_composite:LinkFaceSkin(actor2, client_scene_obj:QueryProp("Sex"), body_face, false)
          else
            local role_face = get_role_face(actor2)
            if not nx_is_valid(role_face) then
            end
            role_composite:SetPlayerFaceDetial(get_role_face(actor2), nx_string(client_scene_obj:QueryProp(info.prop)), client_scene_obj:QueryProp("Sex"), nx_null())
          end
        end
      elseif client_scene_obj:QueryProp("ShowEquipType") == 1 and info.link_name == "hat" then
        if client_scene_obj:QueryProp(info.prop) == nx_string("") then
          link_role_skin(actor2, info.link_name, nx_string(client_scene_obj:QueryProp("Cloth")) .. "_h.xmod")
        else
          link_role_skin(actor2, info.link_name, nx_string(client_scene_obj:QueryProp(info.prop)) .. ".xmod")
        end
      else
        link_role_skin(actor2, info.link_name, nx_string(client_scene_obj:QueryProp(info.prop)) .. ".xmod")
      end
    end
  end
  return
end
function link_role_skin(actor2, link_name, model_name, root)
  if not nx_is_valid(actor2) then
    return false
  end
  if link_name == nil or string.len(link_name) == 0 then
    return false
  end
  local actor_role = nx_null()
  if root == nil or not root then
    actor_role = actor2:GetLinkObject("actor_role")
  end
  if not nx_is_valid(actor_role) then
    actor_role = actor2
  end
  actor_role:DeleteSkin(link_name)
  if model_name == nil or string.len(model_name) == 0 then
    return false
  end
  local actor_role_face = actor2:GetLinkObject("actor_role_face")
  if nx_string(link_name) == nx_string("face") and nx_is_valid(actor_role_face) then
  elseif not actor_role:AddSkin(link_name, model_name) then
    return false
  end
  while not actor_role.LoadFinish do
    nx_pause(0.1)
    if not nx_is_valid(actor_role) then
      return false
    end
  end
  return true
end
function register_action_event(actor2, client_scene_obj)
  local actor_role = actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    actor_role = actor2
  end
  if nx_is_valid(actor_role.Callee) then
    actor_role.Callee.ident = client_scene_obj.Ident
    nx_bind_script(actor_role.Callee, "action_callee", "action_callee_init")
  end
end
