require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_small_game\\form_game_tg_roll"
local chip_item = ""
local chip_list = {}
local png_touzi = {
  "gui\\special\\small_game_tg_roll\\point_1.png",
  "gui\\special\\small_game_tg_roll\\point_2.png",
  "gui\\special\\small_game_tg_roll\\point_3.png",
  "gui\\special\\small_game_tg_roll\\point_4.png",
  "gui\\special\\small_game_tg_roll\\point_5.png",
  "gui\\special\\small_game_tg_roll\\point_6.png"
}
local png_touzi_3d = {
  [1] = {
    "gui\\special\\small_game_tg_roll\\1.png",
    "gui\\special\\small_game_tg_roll\\2.png",
    "gui\\special\\small_game_tg_roll\\3.png",
    "gui\\special\\small_game_tg_roll\\4.png",
    "gui\\special\\small_game_tg_roll\\5.png",
    "gui\\special\\small_game_tg_roll\\6.png"
  },
  [2] = {
    "gui\\special\\small_game_tg_roll\\1.png",
    "gui\\special\\small_game_tg_roll\\2.png",
    "gui\\special\\small_game_tg_roll\\3.png",
    "gui\\special\\small_game_tg_roll\\4.png",
    "gui\\special\\small_game_tg_roll\\5.png",
    "gui\\special\\small_game_tg_roll\\6.png"
  },
  [3] = {
    "gui\\special\\small_game_tg_roll\\1.png",
    "gui\\special\\small_game_tg_roll\\2.png",
    "gui\\special\\small_game_tg_roll\\3.png",
    "gui\\special\\small_game_tg_roll\\4.png",
    "gui\\special\\small_game_tg_roll\\5.png",
    "gui\\special\\small_game_tg_roll\\6.png"
  }
}
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.Left = (gui.Width - self.Width) / 2
    self.Top = (gui.Height - self.Height) / 2
  end
  self.btn_player.Visible = false
  self.btn_player_again.Visible = false
  self.btn_cheat.Visible = false
  self.btn_sum_single.Visible = false
  self.ani_wan.Visible = false
  self.ani_single.Visible = false
  self.ani_lock = false
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_ani_play_delay", self)
  end
  nx_destroy(self)
  nx_execute("custom_sender", "custom_tg_roll_game", 9)
end
function start_game(diff)
  nx_execute("custom_sender", "custom_tg_roll_game", 0, nx_int(diff))
end
function open_form(diff, sys_chip)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  form.lbl_sys_chip.Text = nx_widestr(sys_chip)
  form.diff = nx_int(diff)
  load_resource(form)
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function load_resource(form)
  local ini = get_ini("share\\Rule\\TGRollGame\\TGRoll.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local sec_index = ini:FindSectionIndex(nx_string("property"))
  if sec_index < 0 then
    return false
  end
  chip_item = ini:ReadString(sec_index, "item_chip", "")
  local chip_str = ini:ReadString(sec_index, "chip", "")
  chip_list = util_split_string(chip_str, ",")
end
function on_btn_close_click(btn)
  close_form()
end
function on_btn_start_click(btn)
  nx_execute("custom_sender", "custom_tg_roll_game", 0, nx_int(btn.ParentForm.diff))
end
function on_btn_start_single_click(btn)
  if btn.ParentForm.ani_lock then
    return
  end
  nx_execute("custom_sender", "custom_tg_roll_game", 1)
end
function on_btn_chip_click(btn)
  if btn.ParentForm.ani_lock then
    return
  end
  nx_execute("form_stage_main\\form_small_game\\form_game_tg_roll_chip", "open_form")
end
function on_btn_sys_click(btn)
  local form = btn.ParentForm
  if form.ani_lock then
    return
  end
  form.ani_wan.play_type = 3
  on_ani_play_delay(form)
end
function on_btn_sys_again_click(btn)
  local form = btn.ParentForm
  if form.ani_lock then
    return
  end
  form.ani_wan.play_type = 4
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_ani_play_delay", form, -1, -1)
end
function on_btn_player_click(btn)
  local form = btn.ParentForm
  if form.ani_lock then
    return
  end
  form.ani_wan.play_type = 5
  on_ani_play_delay(form)
end
function on_btn_player_again_click(btn)
  local form = btn.ParentForm
  if form.ani_lock then
    return
  end
  on_ani_play_delay(form)
  form.ani_wan.play_type = 6
end
function on_ani_wan_animation_start(ani)
  local form = ani.ParentForm
  form.groupbox_touzi.Visible = false
  form.ani_lock = true
end
function on_ani_wan_animation_end(ani)
  ani.Visible = false
  local form = ani.ParentForm
  form.groupbox_touzi.Visible = true
  if nx_int(ani.play_type) == nx_int(2) then
    nx_execute("custom_sender", "custom_tg_roll_game", nx_int(ani.play_type), nx_int(ani.chip_index))
  else
    nx_execute("custom_sender", "custom_tg_roll_game", nx_int(ani.play_type))
  end
  form.ani_lock = false
end
function on_ani_single_animation_start(ani)
  local form = ani.ParentForm
  local groupbox_touzi
  if nx_int(ani.index) == nx_int(1) then
    groupbox_touzi = form.groupbox_touzi1
  elseif nx_int(ani.index) == nx_int(2) then
    groupbox_touzi = form.groupbox_touzi2
  elseif nx_int(ani.index) == nx_int(3) then
    groupbox_touzi = form.groupbox_touzi3
  end
  groupbox_touzi.Visible = false
  ani.Left = groupbox_touzi.Left
  ani.Top = groupbox_touzi.Top
  form.ani_lock = true
end
function on_ani_single_animation_end(ani)
  ani.Visible = false
  local form = ani.ParentForm
  local groupbox_touzi
  if nx_int(ani.index) == nx_int(1) then
    groupbox_touzi = form.groupbox_touzi1
  elseif nx_int(ani.index) == nx_int(2) then
    groupbox_touzi = form.groupbox_touzi2
  elseif nx_int(ani.index) == nx_int(3) then
    groupbox_touzi = form.groupbox_touzi3
  end
  groupbox_touzi.Visible = true
  local form = ani.ParentForm
  nx_execute("custom_sender", "custom_tg_roll_game", 7, nx_int(ani.index))
  form.ani_lock = false
end
function on_btn_cheat_click(btn)
  if btn.ParentForm.ani_lock then
    return
  end
  nx_execute("form_stage_main\\form_small_game\\form_game_tg_roll_cheat", "open_form")
end
function on_btn_sum_single_click(btn)
  if btn.ParentForm.ani_lock then
    return
  end
  nx_execute("custom_sender", "custom_tg_roll_game", 8)
end
function on_ani_play_delay(form)
  form.ani_wan.Visible = true
  form.ani_wan.PlayMode = 2
  form.ani_wan:Play()
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_ani_play_delay", form)
end
function show_touzi(form, res1, res2, res3)
  form.lbl_touzi1.BackImage = png_touzi_3d[1][nx_number(res1)]
  form.lbl_touzi2.BackImage = png_touzi_3d[2][nx_number(res2)]
  form.lbl_touzi3.BackImage = png_touzi_3d[3][nx_number(res3)]
end
function on_start_single()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_player_chip.Text = nx_widestr("0")
end
function on_chip(chip_num)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_player_chip.Text = nx_widestr(chip_num)
end
function on_sys(res1, res2, res3, again_sign)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  form.btn_chip.Visible = false
  form.lbl_sys_res1.BackImage = png_touzi[nx_number(res1)]
  form.lbl_sys_res2.BackImage = png_touzi[nx_number(res2)]
  form.lbl_sys_res3.BackImage = png_touzi[nx_number(res3)]
  show_touzi(form, res1, res2, res3)
  if nx_int(again_sign) >= nx_int(1) then
    form.btn_sys_again.Enabled = true
    form.ani_wan.play_type = 4
    local timer = nx_value(GAME_TIMER)
    timer:Register(1000, -1, nx_current(), "on_ani_play_delay", form, -1, -1)
  else
    form.btn_sys_again.Enabled = false
    if form.btn_chip.Visible == false then
      form.btn_player.Visible = true
    end
  end
end
function on_sys_again(res1, res2, res3, again_sign)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_sys_res1.BackImage = png_touzi[nx_number(res1)]
  form.lbl_sys_res2.BackImage = png_touzi[nx_number(res2)]
  form.lbl_sys_res3.BackImage = png_touzi[nx_number(res3)]
  show_touzi(form, res1, res2, res3)
  if nx_int(again_sign) >= nx_int(1) then
    form.btn_sys_again.Enabled = true
    form.ani_wan.play_type = 4
    local timer = nx_value(GAME_TIMER)
    timer:Register(1000, -1, nx_current(), "on_ani_play_delay", form, -1, -1)
  else
    form.btn_sys_again.Enabled = false
    if form.btn_chip.Visible == false then
      form.btn_player.Visible = true
    end
  end
end
function on_player(res1, res2, res3, again_sign, cheat)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_player_res1.BackImage = png_touzi[nx_number(res1)]
  form.lbl_player_res2.BackImage = png_touzi[nx_number(res2)]
  form.lbl_player_res3.BackImage = png_touzi[nx_number(res3)]
  show_touzi(form, res1, res2, res3)
  form.btn_player.Visible = false
  if form.btn_chip.Visible == false then
    if nx_int(again_sign) >= nx_int(1) then
      form.btn_player_again.Visible = true
    else
      form.btn_player_again.Visible = false
    end
    if nx_int(cheat) > nx_int(0) then
      form.btn_cheat.Visible = true
    end
    form.btn_sum_single.Visible = true
  end
end
function on_player_again(res1, res2, res3, again_sign, cheat)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_player_res1.BackImage = png_touzi[nx_number(res1)]
  form.lbl_player_res2.BackImage = png_touzi[nx_number(res2)]
  form.lbl_player_res3.BackImage = png_touzi[nx_number(res3)]
  show_touzi(form, res1, res2, res3)
  if form.btn_chip.Visible == false then
    if nx_int(again_sign) >= nx_int(1) then
      form.btn_player_again.Visible = true
    else
      form.btn_player_again.Visible = false
    end
    if nx_int(cheat) > nx_int(0) then
      form.btn_cheat.Visible = true
    end
    form.btn_sum_single.Visible = true
  end
end
function on_cheat(cheat_index, res, cheat_nums)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(cheat_nums) <= nx_int(0) then
    form.btn_cheat.Visible = false
  end
  local lbl_cheat
  if nx_int(cheat_index) == nx_int(1) then
    lbl_cheat = form.lbl_player_res1
  elseif nx_int(cheat_index) == nx_int(2) then
    lbl_cheat = form.lbl_player_res2
  elseif nx_int(cheat_index) == nx_int(3) then
    lbl_cheat = form.lbl_player_res3
  end
  lbl_cheat.BackImage = png_touzi[nx_number(res)]
  local lbl_touzi
  if nx_int(cheat_index) == nx_int(1) then
    lbl_touzi = form.lbl_touzi1
  elseif nx_int(cheat_index) == nx_int(2) then
    lbl_touzi = form.lbl_touzi2
  elseif nx_int(cheat_index) == nx_int(3) then
    lbl_touzi = form.lbl_touzi3
  end
  lbl_touzi.BackImage = png_touzi_3d[nx_number(cheat_index)][nx_number(res)]
end
function on_sum_single(sys_chip)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_sys_chip.Text = nx_widestr(sys_chip)
  form.btn_chip.Visible = true
  form.btn_player.Visible = false
  form.btn_player_again.Visible = false
  form.btn_cheat.Visible = false
  form.btn_sum_single.Visible = false
  nx_execute("form_stage_main\\form_small_game\\form_game_tg_roll_cheat", "close_form")
end
function on_chip_ok(index)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  local chip_num = nx_number(chip_list[nx_number(index + 1)])
  local cur_num = get_item_num(nx_string(chip_item))
  if chip_num > cur_num then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("ui_tg_roll_004"))
    return
  end
  form.lbl_sys_res1.BackImage = ""
  form.lbl_sys_res2.BackImage = ""
  form.lbl_sys_res3.BackImage = ""
  form.lbl_player_res1.BackImage = ""
  form.lbl_player_res2.BackImage = ""
  form.lbl_player_res3.BackImage = ""
  form.lbl_touzi1.BackImage = ""
  form.lbl_touzi2.BackImage = ""
  form.lbl_touzi3.BackImage = ""
  form.lbl_player_chip.Text = nx_widestr(chip_num)
  form.ani_wan.play_type = 2
  form.ani_wan.chip_index = nx_int(index)
  on_ani_play_delay(form)
end
function on_cheat_ok(index)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  form.ani_single.index = nx_int(index)
  form.ani_single.Visible = true
  form.ani_single.PlayMode = 2
  form.ani_single:Play()
end
function get_item_num(config)
  local CLFRollGame = nx_value("CLFRollGame")
  if not nx_is_valid(CLFRollGame) then
    return 0
  end
  return CLFRollGame:GetItemNum(nx_string(config))
end
