require("const_define")
require("util_functions")
local HAMMER_IMAGE = "gui\\language\\ChineseS\\dfsj_zhujian\\dfsj_chuizi.png"
local HAMMER_EFFECT = "dfsj_zjcj_dhcz01"
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  nx_execute("gui", "gui_close_allsystem_form")
  self.Visible = true
  self.groupbox_guide.Visible = true
  self.groupbox_progress.Visible = true
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    gui.GameHand:SetHand("hammer", HAMMER_IMAGE, "", "", "", "")
  end
  self.ani_1.Visible = false
  refresh_form_pos(self)
  if nx_is_valid(self.ani_djs) then
    self.ani_djs.Visible = false
    self.ani_djs:Stop()
  end
  set_allow_control(false)
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
  form.groupbox_progress.AbsLeft = gui.Width * 0.05
  form.groupbox_progress.AbsTop = gui.Height - form.groupbox_progress.Height - gui.Height / 100
  form.groupbox_guide.AbsLeft = gui.Width - form.groupbox_guide.Width - gui.Height / 100
  form.groupbox_guide.AbsTop = (gui.Height - form.groupbox_guide.Height) / 2.5
  form.ani_djs.AbsLeft = form.Width / 2
  form.ani_djs.AbsTop = form.Height / 3
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_small_game\\form_game_zhujian_qiaoda")
  if nx_is_valid(form) then
    form.Visible = false
  end
  local ShijiaEastZhujianGame = nx_value("ShijiaEastZhujianGame")
  if nx_is_valid(ShijiaEastZhujianGame) then
    ShijiaEastZhujianGame:SendError()
  end
end
function on_main_form_close(self)
  local ShijiaEastZhujianGame = nx_value("ShijiaEastZhujianGame")
  if nx_is_valid(ShijiaEastZhujianGame) then
    ShijiaEastZhujianGame:SendError()
  end
end
function on_btn_close_click(btn)
  local ShijiaEastZhujianGame = nx_value("ShijiaEastZhujianGame")
  if nx_is_valid(ShijiaEastZhujianGame) then
    ShijiaEastZhujianGame:SendError()
  end
end
function on_btn_start_click(btn)
  if not nx_is_valid(btn.ParentForm) then
    return
  end
  start_count_down(btn.ParentForm)
  btn.Enabled = false
end
function cancel_game()
  local ShijiaEastZhujianGame = nx_value("ShijiaEastZhujianGame")
  if nx_is_valid(ShijiaEastZhujianGame) then
    ShijiaEastZhujianGame:SendError()
  end
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
    local ShijiaEastZhujianGame = nx_value("ShijiaEastZhujianGame")
    if nx_is_valid(ShijiaEastZhujianGame) then
      ShijiaEastZhujianGame:SendError()
    end
  end
end
function game_key_down(gui, key, shift, ctrl)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_zhujian_qiaoda")
  if not nx_is_valid(form) then
    return
  end
  if key == "Esc" then
    show_close_dialog(form)
  end
end
function set_allow_control(allow)
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  game_control.AllowControl = allow
end
function play_sound(flag, filename)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not gui:FindSound(nx_string(flag)) then
    gui:AddSound(nx_string(flag), nx_resource_path() .. nx_string(filename))
  end
  gui:PlayingSound(nx_string(flag))
end
function set_light_btn(type)
end
function on_size_change()
  local form = nx_value("form_stage_main\\form_small_game\\form_game_zhujian_qiaoda")
  if nx_is_valid(form) then
    turn_to_full_screen(form)
  end
end
function turn_to_full_screen(self)
  local form = self
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Desktop.Width
  form.Height = gui.Desktop.Height
end
function on_game_end(res)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_zhujian_qiaoda")
  if not nx_is_valid(form) then
    return
  end
  if 1 < res then
    auto_close_form(form)
    return
  end
  form.groupbox_guide.Visible = false
  form.groupbox_progress.Visible = false
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
  timer:Register(2500, 1, "form_stage_main\\form_small_game\\form_game_zhujian_qiaoda", "auto_close_form", form, -1, -1)
end
function auto_close_form(self)
  local form = self
  if form == nil or not nx_is_valid(form) then
    form = nx_value("form_stage_main\\form_small_game\\form_game_zhujian_qiaoda")
  end
  if nx_is_valid(form) then
    nx_execute("gui", "gui_open_closedsystem_form")
    do_action("stand")
    local gui = nx_value("gui")
    if nx_is_valid(form) then
      gui.GameHand:ClearHand()
    end
    set_allow_control(true)
    nx_destroy(form)
    nx_set_value("form_stage_main\\form_small_game\\form_game_zhujian_qiaoda", nx_null())
  end
end
function on_btn_case_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  local zhujian = nx_value("ShijiaEastZhujianGame")
  if not nx_is_valid(zhujian) then
    return
  end
  on_hammer_start()
  zhujian:OnAnswer4Lua(nx_int(btn.DataSource))
end
function on_btn_guide_click(btn)
  if not nx_is_valid(btn.ParentForm) then
    return
  end
  local guide = btn.ParentForm.groupbox_guide
  if not nx_is_valid(guide) then
    return
  end
  if guide.Visible == true then
    guide.Visible = false
  else
    guide.Visible = true
  end
end
function on_hammer_start()
  local form = nx_value("form_stage_main\\form_small_game\\form_game_zhujian_qiaoda")
  if not nx_is_valid(form) then
    return
  end
  gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.GameHand:ClearHand()
  gui.GameHand:SetHand("show", "Trans", "", "", "", "")
  local mouse_x, mouse_y = gui:GetCursorPosition()
  form.ani_1.AbsLeft = mouse_x - form.AbsLeft
  form.ani_1.AbsTop = mouse_y - form.AbsTop
  form.ani_1.AnimationImage = HAMMER_EFFECT
  form.ani_1.Visible = true
  form.ani_1.Loop = false
  form.ani_1.PlayMode = 0
  nx_callback(form.ani_1, "on_animation_end", "on_hammer_end")
end
function on_hammer_end(self)
  if not nx_is_valid(self) then
    return
  end
  gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  self.AnimationImage = ""
  self.Visible = false
  gui.GameHand:ClearHand()
  gui.GameHand:SetHand("hammer", HAMMER_IMAGE, "", "", "", "")
  local ShijiaEastZhujianGame = nx_value("ShijiaEastZhujianGame")
  if nx_is_valid(ShijiaEastZhujianGame) then
    ShijiaEastZhujianGame:EffectOver()
  end
end
function start_count_down(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.ani_djs) then
    return
  end
  form.ani_djs.Visible = true
  form.ani_djs.AnimationImage = nx_string("dfsj_zjcj_dhcz02")
  form.ani_djs.Loop = false
  form.ani_djs.PlayMode = 2
  form.ani_djs:Play()
  nx_bind_script(form.ani_djs, nx_current())
  nx_callback(form.ani_djs, "on_animation_end", "on_ani_end")
end
function on_ani_end(self)
  local ShijiaEastZhujianGame = nx_value("ShijiaEastZhujianGame")
  if nx_is_valid(ShijiaEastZhujianGame) then
    ShijiaEastZhujianGame:DoStart()
    do_action("interact585a")
    play_sound("sound_zhujian_qd_game", "snd\\action\\minigame\\zhujian\\dfsj_zj_dt.wav")
  end
end
function do_action(action_name)
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  local action_module = nx_value("action_module")
  if nx_is_valid(action_module) then
    action_module:ChangeState(visual_player, action_name, true)
  end
end
