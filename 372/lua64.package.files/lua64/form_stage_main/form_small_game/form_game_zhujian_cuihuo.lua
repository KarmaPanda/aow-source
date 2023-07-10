require("const_define")
require("util_functions")
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  nx_execute("gui", "gui_close_allsystem_form")
  self.Visible = true
  refresh_form_pos(self)
  set_allow_control(false)
  if nx_is_valid(self.ani_djs) then
    self.ani_djs.Visible = false
    self.ani_djs:Stop()
  end
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
  form.groupbox_controller.AbsLeft = form.groupbox_progress.AbsLeft + form.groupbox_progress.Width / 3
  form.groupbox_controller.AbsTop = form.groupbox_progress.AbsTop
  form.groupbox_roll.AbsLeft = form.groupbox_controller.AbsLeft
  form.groupbox_roll.AbsTop = form.groupbox_controller.AbsTop - form.groupbox_roll.Height
  form.lbl_bucket_bk.AbsLeft = form.groupbox_roll.AbsLeft - form.groupbox_roll.Width / 4
  form.lbl_bucket_bk.AbsTop = form.groupbox_roll.AbsTop - form.lbl_bucket_bk.Height
  form.lbl_bucket_water.AbsLeft = form.lbl_bucket_bk.AbsLeft + form.lbl_bucket_bk.Width / 6.5
  form.lbl_bucket_water.AbsTop = form.lbl_bucket_bk.AbsTop + form.lbl_bucket_bk.Height / 5
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
    on_main_form_close(form)
  end
end
function game_key_down(gui, key, shift, ctrl)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_zhujian_cuihuo")
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
  local form = nx_value("form_stage_main\\form_small_game\\form_game_zhujian_cuihuo")
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
  local form = nx_value("form_stage_main\\form_small_game\\form_game_zhujian_cuihuo")
  if not nx_is_valid(form) then
    return
  end
  if 1 < res then
    auto_close_form(form)
    return
  end
  form.groupbox_guide.Visible = false
  form.groupbox_progress.Visible = false
  form.lbl_bucket_bk.Visible = false
  form.lbl_bucket_water.Visible = false
  form.groupbox_roll.Visible = false
  form.groupbox_controller.Visible = false
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
  timer:Register(2500, 1, "form_stage_main\\form_small_game\\form_game_zhujian_cuihuo", "auto_close_form", form, -1, -1)
end
function auto_close_form(self)
  local form = self
  if form == nil or not nx_is_valid(form) then
    form = nx_value("form_stage_main\\form_small_game\\form_game_zhujian_cuihuo")
  end
  if nx_is_valid(form) then
    set_allow_control(true)
    nx_execute("gui", "gui_open_closedsystem_form")
    do_action("stand")
    nx_destroy(form)
    nx_set_value("form_stage_main\\form_small_game\\form_game_zhujian_cuihuo", nx_null())
  end
end
function on_btn_left_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  local zhujian = nx_value("ShijiaEastZhujianGame")
  if not nx_is_valid(zhujian) then
    return
  end
  zhujian:OnClickLeft()
end
function on_btn_right_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  local zhujian = nx_value("ShijiaEastZhujianGame")
  if not nx_is_valid(zhujian) then
    return
  end
  zhujian:OnClickRight()
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
function create_path_effect()
  local form = nx_value("form_stage_main\\form_small_game\\form_game_zhujian_cuihuo")
  if not nx_is_valid(form) then
    return
  end
  local ani_path_pos_list = {}
  ani_path_pos_list[1] = {left = 0, top = 0}
  ani_path_pos_list[1].left = math.random(form.AbsLeft + form.lbl_bucket_water.Left, form.AbsLeft + form.lbl_bucket_water.Left + form.lbl_bucket_water.Width)
  ani_path_pos_list[1].top = form.AbsTop + form.lbl_bucket_water.Top
  ani_path_pos_list[3] = {left = 0, top = 0}
  ani_path_pos_list[3].left = form.AbsLeft + form.groupbox_progress.Left + form.pbar_sword.Left + form.pbar_sword.Width / 2
  ani_path_pos_list[3].top = form.AbsTop + form.groupbox_progress.Top + form.pbar_sword.Top
  ani_path_pos_list[2] = {left = 0, top = 0}
  ani_path_pos_list[2].left = math.random(math.min(ani_path_pos_list[1].left, ani_path_pos_list[3].left), math.max(ani_path_pos_list[1].left, ani_path_pos_list[3].left))
  ani_path_pos_list[2].top = math.random(math.min(ani_path_pos_list[1].top, ani_path_pos_list[3].top), math.max(ani_path_pos_list[1].top, ani_path_pos_list[3].top))
  local gui = nx_value("gui")
  local ani_path = gui:Create("AnimationPath")
  form:Add(ani_path)
  ani_path.AnimationImage = "gui\\animations\\path_effect\\star.dds"
  ani_path.SmoothPath = true
  ani_path.Loop = false
  ani_path.ClosePath = false
  ani_path.Color = "255,40,230,255"
  ani_path.CreateMinInterval = 5
  ani_path.CreateMaxInterval = 10
  ani_path.RotateSpeed = 2
  ani_path.BeginAlpha = 1
  ani_path.AlphaChangeSpeed = 1
  ani_path.BeginScale = 0.17
  ani_path.ScaleSpeed = 0
  ani_path.MaxTime = 1000
  ani_path.MaxWave = 0.05
  ani_path:ClearPathPoints()
  for i = 1, table.getn(ani_path_pos_list) do
    local ani_path_pos = ani_path_pos_list[i]
    ani_path:AddPathPoint(ani_path_pos.left, ani_path_pos.top)
  end
  ani_path:AddPathPointFinish()
  nx_bind_script(ani_path, nx_current())
  nx_callback(ani_path, "on_animation_end", "on_ani_path_end")
  ani_path:Play()
end
function on_ani_path_end(self)
  if not nx_is_valid(self) then
    return
  end
  self.Visible = false
  local gui = nx_value("gui")
  gui:Delete(self)
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
    do_action("interact585b")
    play_sound("sound_zhujian_ch_game", "snd\\action\\minigame\\zhujian\\dfsj_zj_ch.wav")
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
