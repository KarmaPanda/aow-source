require("util_gui")
require("tips_data")
require("util_functions")
local CLIENT_CUSTOMMSG_SMAILL_GAME_MSG = 505
local SMALLGAME_MSG_OPEN_WHACK_EGG_END = 6
local SMALLGAME_MSG_PRIZE_WHACK_EGG = 7
local WHACK_EGG_MOLE_BTN_NUMBER = 9
local MOLE_BTN = "hole_"
local MOLE_ANI = "ani_"
local FUQI_EGG = 1
local JINLONG_EGG = 2
local FEICHUI_EGG = 3
local NORMAL_EGG = 4
local SPECIAL_COUNT = 2
local BTN_MOLE_IMAGE = {
  "gui\\animations\\smahing_egg\\egg1\\d8.png",
  "gui\\animations\\smahing_egg\\egg2\\d8.png",
  "gui\\animations\\smahing_egg\\egg3\\d8.png",
  "gui\\animations\\smahing_egg\\egg4\\d8.png"
}
local SINKER_IMAGE = "gui\\special\\life\\puzzle_quest\\smahing_egg\\hammer.png"
local SINKER_EFFECT = "whackegg_ani6"
local WHACK_EGG_EFFECT = {
  ["0"] = {
    "whackegg_ani1_out",
    "whackegg_ani2_out",
    "whackegg_ani3_out",
    "whackegg_ani4_out"
  },
  ["1"] = {
    "whackegg_ani1_in",
    "whackegg_ani2_in",
    "whackegg_ani3_in",
    "whackegg_ani4_in"
  },
  ["2"] = {
    "gui\\animations\\smahing_egg\\k1.png",
    "gui\\animations\\smahing_egg\\k2.png",
    "gui\\animations\\smahing_egg\\k3.png",
    "gui\\animations\\smahing_egg\\k4.png"
  },
  ["3"] = {
    "gui\\animations\\path_effect\\red.dds",
    "gui\\animations\\path_effect\\yellow.dds",
    "gui\\animations\\path_effect\\blue.dds",
    "whackegg_ani5"
  }
}
local SOUND_EFFECT = {
  start = "snd\\action\\minigame\\new\\6101_44.wav",
  win = "snd\\action\\minigame\\new\\6101_46.wav",
  lose = "snd\\action\\minigame\\new\\6101_45.wav",
  special = "snd\\action\\minigame\\zdyl\\7555_2.wav",
  normal = "snd\\action\\npc\\animal\\xjdw\\atkhit1_houzi.wav"
}
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  form.Fixed = true
  turn_to_full_screen(form)
  form.goal_fuqi = 0
  form.goal_jinlong = 0
  form.goal_feichui = 0
  form.special_num_1 = 0
  form.special_num_2 = 0
  form.special_num_3 = 0
  form.break_num_1 = 0
  form.break_num_2 = 0
  form.break_num_3 = 0
  form.game_time = 0
  form.pause_time = 0
  form.game_batch = 0
  form.batch_time = 0
  form.max_goal = 0
  form.end_success = false
  form.Cursor = SINKER_IMAGE
  init_mole(form)
  play_music("gem_egg_start")
end
function on_main_form_close(form)
  stop_music()
  on_game_over(form.end_success)
  nx_destroy(form)
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\puzzle_quest\\form_game_whackegg", true)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", form)
  timer:UnRegister(nx_current(), "on_end_time", form)
  timer:UnRegister(nx_current(), "on_end_smash", form)
  timer:UnRegister(nx_current(), "on_end_break_egg", form)
  form:Close()
end
function init_mole(form)
  if not nx_is_valid(form) then
    return
  end
  gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local groupbox_ctr = form.groupbox_10
  if not nx_is_valid(groupbox_ctr) then
    return
  end
  local btn_name = ""
  local groupbox_name = ""
  for i = nx_number(1), nx_number(WHACK_EGG_MOLE_BTN_NUMBER) do
    groupbox_name = "groupbox_" .. nx_string(i)
    local groupbox_mole = groupbox_ctr:Find(groupbox_name)
    if not nx_is_valid(groupbox_mole) then
      return
    end
    btn_name = MOLE_BTN .. nx_string(i)
    local btn_mole = groupbox_mole:Find(btn_name)
    if not nx_is_valid(btn_mole) then
      return
    end
    btn_mole.index = i
    btn_mole.NormalImage = ""
    btn_mole.data = -1
  end
  gui.GameHand:ClearHand()
  gui.GameHand:SetHand("sinker", SINKER_IMAGE, "", "", "", "")
end
function clear_mole_ani(ani)
  local form = util_get_form("form_stage_main\\puzzle_quest\\form_game_whackegg", false)
  if not nx_is_valid(form) then
    return
  end
  local groupbox_ctr = form.groupbox_10
  if not nx_is_valid(groupbox_ctr) then
    return
  end
  local btn_name = ""
  local ani_name = ""
  local groupbox_name = ""
  for i = nx_number(1), nx_number(WHACK_EGG_MOLE_BTN_NUMBER) do
    groupbox_name = "groupbox_" .. nx_string(i)
    local groupbox_mole = groupbox_ctr:Find(groupbox_name)
    if not nx_is_valid(groupbox_mole) then
      return
    end
    btn_name = MOLE_BTN .. nx_string(i)
    local btn_mole = groupbox_mole:Find(btn_name)
    if not nx_is_valid(btn_mole) then
      return
    end
    ani_name = MOLE_ANI .. nx_string(i)
    local ani_mole = groupbox_mole:Find(ani_name)
    if not nx_is_valid(ani_mole) then
      return
    end
    if btn_mole.data < 0 then
      on_animation_end(ani_mole)
      btn_mole.NormalImage = ""
    end
  end
end
function on_size_change()
  local form = nx_value("form_stage_main\\puzzle_quest\\form_game_whackegg")
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
function on_update_time(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.game_time = form.game_time - form.batch_time
  form.pbar_2.Value = form.game_time
  form.lbl_6.Text = gui.TextManager:GetFormatText("ui_whack_egg_time", nx_int(form.game_time))
  if form.game_time <= 0 then
    form.game_time = 0
    form.end_success = false
    close_form()
    return
  end
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  timer:UnRegister("form_stage_main\\puzzle_quest\\form_game_whackegg", "on_end_time", form)
  init_mole(form)
  on_update_egg(form)
  return
end
function on_end_time(form, state, btn)
  if state == 1 then
    on_pause_egg(form)
  elseif state == 2 then
    on_updown_egg(form)
  end
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  timer:UnRegister("form_stage_main\\puzzle_quest\\form_game_whackegg", "on_end_time", form)
  return
end
function on_end_break_egg(form, index)
  if not nx_is_valid(form) then
    return
  end
  local groupbox_ctr = form.groupbox_10
  if not nx_is_valid(groupbox_ctr) then
    return
  end
  local groupbox_name = "groupbox_" .. nx_string(index)
  local groupbox_mole = groupbox_ctr:Find(groupbox_name)
  if not nx_is_valid(groupbox_mole) then
    return
  end
  btn_name = MOLE_BTN .. nx_string(index)
  local btn = groupbox_mole:Find(btn_name)
  if not nx_is_valid(btn) then
    return
  end
  if btn.data < 0 then
    btn.NormalImage = ""
  end
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  timer:UnRegister("form_stage_main\\puzzle_quest\\form_game_whackegg", "on_end_break_egg", form)
end
function on_update_egg(form)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  timer:Register(200 + form.pause_time, -1, nx_current(), "on_end_time", form, 2, -1)
  local hole1 = math.random(nx_number(1), nx_number(WHACK_EGG_MOLE_BTN_NUMBER))
  local hole2 = math.random(nx_number(1), nx_number(WHACK_EGG_MOLE_BTN_NUMBER - 1))
  if hole1 <= hole2 then
    hole2 = hole2 + 1
  end
  local rand1 = get_egg_type(form)
  local rand2 = get_egg_type(form)
  local groupbox_ctr = form.groupbox_10
  if not nx_is_valid(groupbox_ctr) then
    return
  end
  local groupbox_name = ""
  local btn_name = ""
  local ani_name = ""
  for i = nx_number(1), nx_number(WHACK_EGG_MOLE_BTN_NUMBER) do
    groupbox_name = "groupbox_" .. nx_string(i)
    local groupbox_mole = groupbox_ctr:Find(groupbox_name)
    if not nx_is_valid(groupbox_mole) then
      return
    end
    btn_name = MOLE_BTN .. nx_string(i)
    local btn_mole = groupbox_mole:Find(btn_name)
    if not nx_is_valid(btn_mole) then
      return
    end
    ani_name = MOLE_ANI .. nx_string(i)
    local ani_mole = groupbox_mole:Find(ani_name)
    if not nx_is_valid(ani_mole) then
      return
    end
    btn_mole.index = i
    if i == hole1 then
      btn_mole.data = rand1
    elseif i == hole2 then
      btn_mole.data = rand2
    else
      btn_mole.data = 4
    end
    play_animation(get_animation(btn_mole.data, 0), ani_mole)
  end
end
function get_egg_type(form)
  if not nx_is_valid(form) then
    return
  end
  local egg_table = {}
  local index = 1
  if form.special_num_1 < form.max_goal then
    egg_table[index] = FUQI_EGG
    index = index + 1
  end
  if form.special_num_2 < form.max_goal then
    egg_table[index] = JINLONG_EGG
    index = index + 1
  end
  if form.special_num_3 < form.max_goal then
    egg_table[index] = FEICHUI_EGG
    index = index + 1
  end
  if table.getn(egg_table) <= 0 then
    egg_table[1] = FUQI_EGG
    egg_table[2] = JINLONG_EGG
    egg_table[3] = FEICHUI_EGG
  end
  local rand = math.random(nx_number(1), nx_number(table.getn(egg_table)))
  if rand == FUQI_EGG then
    form.special_num_1 = form.special_num_1 + 1
  elseif rand == JINLONG_EGG then
    form.special_num_2 = form.special_num_2 + 1
  elseif rand == FEICHUI_EGG then
    form.special_num_3 = form.special_num_3 + 1
  end
  return egg_table[rand]
end
function on_pause_egg(form)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  timer:Register(form.pause_time, -1, nx_current(), "on_end_time", form, 2, -1)
  local groupbox_ctr = form.groupbox_10
  if not nx_is_valid(groupbox_ctr) then
    return
  end
  local groupbox_name = ""
  local btn_name = ""
  for i = nx_number(1), nx_number(WHACK_EGG_MOLE_BTN_NUMBER) do
    groupbox_name = "groupbox_" .. nx_string(i)
    local groupbox_mole = groupbox_ctr:Find(groupbox_name)
    if not nx_is_valid(groupbox_mole) then
      return
    end
    btn_name = MOLE_BTN .. nx_string(i)
    local btn_mole = groupbox_mole:Find(btn_name)
    if not nx_is_valid(btn_mole) then
      return
    end
    if btn_mole.data > 0 then
      btn_mole.NormalImage = BTN_MOLE_IMAGE[btn_mole.data]
    end
  end
end
function on_updown_egg(form)
  if not nx_is_valid(form) then
    return
  end
  local groupbox_ctr = form.groupbox_10
  if not nx_is_valid(groupbox_ctr) then
    return
  end
  local ani_end
  local groupbox_name = ""
  local btn_name = ""
  local ani_name = ""
  for i = nx_number(1), nx_number(WHACK_EGG_MOLE_BTN_NUMBER) do
    groupbox_name = "groupbox_" .. nx_string(i)
    local groupbox_mole = groupbox_ctr:Find(groupbox_name)
    if not nx_is_valid(groupbox_mole) then
      return
    end
    btn_name = MOLE_BTN .. nx_string(i)
    local btn_mole = groupbox_mole:Find(btn_name)
    if not nx_is_valid(btn_mole) then
      return
    end
    if btn_mole.data > 0 then
      ani_name = MOLE_ANI .. nx_string(i)
      local ani_mole = groupbox_mole:Find(ani_name)
      if not nx_is_valid(ani_mole) then
        return
      end
      btn_mole.NormalImage = ""
      play_animation(get_animation(btn_mole.data, 1), ani_mole)
      btn_mole.data = -1
      ani_end = ani_mole
    end
  end
  if nx_is_valid(ani_end) then
    nx_callback(ani_end, "on_animation_end", "clear_mole_ani")
  end
end
function on_btn_game_start(btn)
  if not nx_is_valid(btn) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  btn.Enabled = false
  timer:Register(form.batch_time * 1000, -1, nx_current(), "on_update_time", form, -1, -1)
  on_update_egg(form)
  play_sound("start")
end
function on_btn_quit_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.end_success = false
  close_form()
end
function on_btn_hole_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  on_form_click(form)
  if btn.data < 0 then
    return
  end
  local groupbox_ctr = form.groupbox_10
  if not nx_is_valid(groupbox_ctr) then
    return
  end
  local groupbox_name = "groupbox_" .. nx_string(btn.index)
  local groupbox_mole = groupbox_ctr:Find(groupbox_name)
  if not nx_is_valid(groupbox_mole) then
    return
  end
  local ani_name = MOLE_ANI .. nx_string(btn.index)
  local ani_mole = groupbox_mole:Find(ani_name)
  if not nx_is_valid(ani_mole) then
    return
  end
  local data = btn.data
  btn.data = -1
  on_animation_end(ani_mole)
  btn.NormalImage = WHACK_EGG_EFFECT["2"][nx_number(data)]
  timer:Register(200, -1, nx_current(), "on_end_break_egg", form, btn.index, -1)
  if data < NORMAL_EGG then
    play_sound("special")
    create_goal_path_effect(form, btn, data)
  else
    play_sound("normal")
  end
  on_update_goal(form, data)
end
function on_update_goal(form, data)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local max_goal = 0
  local cur_goal = 0
  if data == FUQI_EGG then
    form.break_num_1 = form.break_num_1 + 1
    max_goal = form.goal_fuqi
    cur_goal = form.break_num_1
  elseif data == JINLONG_EGG then
    form.break_num_2 = form.break_num_2 + 1
    max_goal = form.goal_jinlong
    cur_goal = form.break_num_2
  elseif data == FEICHUI_EGG then
    form.break_num_3 = form.break_num_3 + 1
    max_goal = form.goal_feichui
    cur_goal = form.break_num_3
  elseif data == NORMAL_EGG then
    form.game_time = form.game_time - 1
    form.pbar_2.Value = form.game_time
    form.lbl_6.Text = gui.TextManager:GetFormatText("ui_whack_egg_time", nx_int(form.game_time))
    play_animation(get_animation(data, 3), form.ani_10)
    if 0 >= form.game_time then
      local timer = nx_value("timer_game")
      if not nx_is_valid(timer) then
        return
      end
      timer:UnRegister("form_stage_main\\puzzle_quest\\form_game_whackegg", "on_update_time", form)
      form.end_success = false
      close_form()
    end
    return
  end
  local lbl_name = "lbl_" .. nx_string(data)
  local lbl_goal = form:Find(lbl_name)
  if not nx_is_valid(lbl_goal) then
    return
  end
  if max_goal < cur_goal then
    cur_goal = max_goal
  end
  lbl_goal.Text = nx_widestr(cur_goal) .. nx_widestr("/") .. nx_widestr(max_goal)
  if form.break_num_1 >= form.goal_fuqi and form.break_num_2 >= form.goal_jinlong and form.break_num_3 >= form.goal_feichui then
    form.end_success = true
    close_form()
  end
end
function on_form_click(form)
  if not nx_is_valid(form) then
    return
  end
  gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.GameHand:ClearHand()
  gui.GameHand:SetHand("show", "Trans", "", "", "", "")
  local mouse_x, mouse_z = gui:GetCursorPosition()
  local x, z = gui:GetCursorPosition()
  form.ani_11.AbsLeft = x - 25
  form.ani_11.AbsTop = z - 40
  form.ani_11.AnimationImage = SINKER_EFFECT
  form.ani_11.Visible = true
  form.ani_11.Loop = false
  form.ani_11.PlayMode = 0
  nx_callback(form.ani_11, "on_animation_end", "on_end_smash")
end
function on_end_smash(self)
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
  gui.GameHand:SetHand("sinker", SINKER_IMAGE, "", "", "", "")
end
function on_start(...)
  local size = table.getn(arg)
  if nx_int(size) < nx_int(6) then
    return
  end
  local form = util_get_form("form_stage_main\\puzzle_quest\\form_game_whackegg", true, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Visible = true
  form:Show()
  form.game_time = arg[1]
  form.pause_time = arg[2]
  form.game_batch = arg[3]
  form.goal_fuqi = arg[4]
  form.goal_jinlong = arg[5]
  form.goal_feichui = arg[6]
  form.max_goal = 2 * form.game_batch / 3
  form.batch_time = form.game_time / form.game_batch
  form.lbl_1.Text = nx_widestr(0) .. nx_widestr("/") .. nx_widestr(form.goal_fuqi)
  form.lbl_2.Text = nx_widestr(0) .. nx_widestr("/") .. nx_widestr(form.goal_jinlong)
  form.lbl_3.Text = nx_widestr(0) .. nx_widestr("/") .. nx_widestr(form.goal_feichui)
  form.pbar_2.Maximum = form.game_time
  form.pbar_2.Minimum = 0
  form.pbar_2.Value = form.game_time
  form.lbl_6.Text = gui.TextManager:GetFormatText("ui_whack_egg_time", nx_int(form.game_time))
end
function on_stop(...)
  local form = util_get_form("form_stage_main\\puzzle_quest\\form_game_whackegg", false)
  if not nx_is_valid(form) then
    return
  end
  form.end_success = false
  form:Close()
end
function on_cancel(...)
  local form = util_get_form("form_stage_main\\puzzle_quest\\form_game_whackegg", false)
  if not nx_is_valid(form) then
    return
  end
  form.end_success = false
  close_form()
end
function on_game_over(state)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if state then
    create_img_ani("win", gui.Desktop.Width / 2 - 868, gui.Desktop.Height / 5)
    play_sound("win")
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SMAILL_GAME_MSG), nx_int(SMALLGAME_MSG_PRIZE_WHACK_EGG))
  else
    create_img_ani("lose", gui.Desktop.Width / 2 - 868, gui.Desktop.Height / 5)
    play_sound("lose")
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SMAILL_GAME_MSG), nx_int(SMALLGAME_MSG_OPEN_WHACK_EGG_END))
  gui.GameHand:ClearHand()
end
function play_sound(sound)
  local filename = SOUND_EFFECT[sound]
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not gui:FindSound(filename) then
    gui:AddSound(filename, nx_resource_path() .. filename)
  end
  gui:PlayingSound(filename)
end
function play_music(sound_name)
  local role = nx_value("role")
  if not nx_is_valid(role) then
    return
  end
  local scene = role.scene
  if not nx_is_valid(scene) then
    return
  end
  nx_execute("util_functions", "play_music", scene, "scene", sound_name)
end
function stop_music()
  local role = nx_value("role")
  if not nx_is_valid(role) then
    return
  end
  local scene = role.scene
  if not nx_is_valid(scene) then
    return
  end
  local sound_man = scene.sound_man
  if not nx_is_valid(sound_man) then
    return
  end
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local scene_music = client_scene:QueryProp("Resource")
  if sound_man.cur_music_name == scene_music then
    return
  end
  nx_execute("util_functions", "play_scene_random_music", scene, "scene", scene_music)
end
function get_animation(data, state)
  local ani = ""
  if data >= FUQI_EGG and data <= NORMAL_EGG and 0 <= state and state <= 3 then
    ani = WHACK_EGG_EFFECT[nx_string(state)][nx_number(data)]
  end
  return ani
end
function play_animation(ani, self)
  if not nx_is_valid(self) then
    return
  end
  self.AnimationImage = ani
  self.Visible = true
  self.Loop = false
  self.PlayMode = 0
end
function on_animation_end(self)
  if not nx_is_valid(self) then
    return
  end
  self.Visible = false
  self.AnimationImage = ""
end
function create_img_ani(sect, start_x, start_z)
  local SpriteManager = nx_value("SpriteManager")
  if not nx_is_valid(SpriteManager) then
    return
  end
  SpriteManager:ShowBallFormScreenPos(sect, "", start_x, start_z, "")
end
function create_goal_path_effect(form, hole_btn, data)
  local ani_param = {}
  ani_param.AnimationImage = get_animation(data, 3)
  ani_param.SmoothPath = true
  ani_param.Loop = false
  ani_param.ClosePath = false
  ani_param.CreateMinInterval = 5
  ani_param.CreateMaxInterval = 10
  ani_param.RotateSpeed = 3
  ani_param.BeginAlpha = 0.8
  ani_param.AlphaChangeSpeed = 0.3
  ani_param.BeginScale = 0.27
  ani_param.ScaleSpeed = 0
  ani_param.MaxTime = 1000
  ani_param.MaxWave = 0.05
  local ani_path_pos_list = {}
  ani_path_pos_list[1] = {left = 0, top = 0}
  ani_path_pos_list[1].left = hole_btn.AbsLeft + hole_btn.Width / 2
  ani_path_pos_list[1].top = hole_btn.AbsTop + hole_btn.Height / 2
  local control_name = "lbl_goal_" .. nx_string(data)
  local control_goal = form:Find(control_name)
  if not nx_is_valid(control_goal) then
    return
  end
  ani_path_pos_list[3] = {left = 0, top = 0}
  ani_path_pos_list[3].left = control_goal.AbsLeft + control_goal.Width / 2
  ani_path_pos_list[3].top = control_goal.AbsTop + control_goal.Height / 2
  ani_path_pos_list[2] = {left = 0, top = 0}
  if ani_path_pos_list[3] == nil then
    return
  end
  ani_path_pos_list[2].left = math.random(math.min(ani_path_pos_list[1].left, ani_path_pos_list[3].left), math.max(ani_path_pos_list[1].left, ani_path_pos_list[3].left))
  ani_path_pos_list[2].top = math.random(math.min(ani_path_pos_list[1].top, ani_path_pos_list[3].top), math.max(ani_path_pos_list[1].top, ani_path_pos_list[3].top))
  return create_path_ani(form, ani_path_pos_list, ani_param)
end
function on_end_create_path(form)
end
function create_path_ani(form, ani_path_pos_list, ani_param)
  local gui = nx_value("gui")
  local ani_path = gui:Create("AnimationPath")
  ani_path.Name = ani_name
  form:Add(ani_path)
  ani_path.AnimationImage = ani_param.AnimationImage
  ani_path.SmoothPath = ani_param.SmoothPath
  ani_path.Loop = ani_param.Loop
  ani_path.ClosePath = ani_param.ClosePath
  ani_path.Color = ani_param.Color
  ani_path.CreateMinInterval = ani_param.CreateMinInterval
  ani_path.CreateMaxInterval = ani_param.CreateMaxInterval
  ani_path.RotateSpeed = ani_param.RotateSpeed
  ani_path.BeginAlpha = ani_param.BeginAlpha
  ani_path.AlphaChangeSpeed = ani_param.AlphaChangeSpeed
  ani_path.BeginScale = ani_param.BeginScale
  ani_path.ScaleSpeed = ani_param.ScaleSpeed
  ani_path.MaxTime = ani_param.MaxTime
  ani_path.MaxWave = ani_param.MaxWave
  ani_path:ClearPathPoints()
  for i = 1, table.getn(ani_path_pos_list) do
    local ani_path_pos = ani_path_pos_list[i]
    ani_path:AddPathPoint(ani_path_pos.left, ani_path_pos.top)
  end
  ani_path:AddPathPointFinish()
  nx_bind_script(ani_path, nx_current())
  nx_callback(ani_path, "on_animation_end", "on_ani_path_end")
  ani_path:Play()
  return ani_path
end
function on_ani_path_end(self)
  if not nx_is_valid(self) then
    return
  end
  self.Visible = false
  local gui = nx_value("gui")
  if nx_is_valid(self) then
    gui:Delete(self)
  end
end
function hide_form()
  local form = util_get_form("form_stage_main\\puzzle_quest\\form_game_whackegg", false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ask_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  ask_dialog.Left = form.Left + (form.Width - ask_dialog.Width) / 2
  ask_dialog.Top = form.Top + (form.Height - ask_dialog.Height) / 2
  local text = nx_widestr(gui.TextManager:GetText("ui_game_whackegg_exit1"))
  nx_execute("form_common\\form_confirm", "show_common_text", ask_dialog, text)
  ask_dialog:ShowModal()
  local res = nx_wait_event(100000000, ask_dialog, "confirm_return")
  if res == "ok" then
    close_form()
  end
end
