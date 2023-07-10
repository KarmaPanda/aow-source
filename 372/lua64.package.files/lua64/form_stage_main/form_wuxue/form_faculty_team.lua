require("util_gui")
require("util_functions")
require("share\\view_define")
local SUB_CLIENT_BEGIN = 3
local SUB_CLIENT_EXIT = 4
local SUB_SERVER_READY = 1
local SUB_SERVER_PREPAR = 2
local SUB_SERVER_PLAYING = 3
local SUB_SERVER_SHOW = 4
local SUB_SERVER_OVER = 5
local SUB_SERVER_PLAYER_READY = 11
local SUB_SERVER_PLAYER_PLAY = 12
local SUB_SERVER_PLAYER_OVER = 13
local SUB_SERVER_PLAY_OPEN = 20
local SUB_SERVER_PLAY_CLOSE = 21
local SUB_SERVER_PLAY_JOIN = 30
local SUB_SERVER_PLAY_LEAVE = 31
local SUB_SERVER_RESULT_SUCCESS = 40
local SUB_SERVER_RESULT_FAILED = 41
local SUB_SERVER_CONVERT_FACULTY = 50
local TEAM_FACULTY_TYPE_NORMAL = 0
local TEAM_FACULTY_TYPE_DONGFANG = 1
local TEAM_FACULTY_TYPE_JIUGONG = 3
local FORM_MEMBER = "form_stage_main\\form_wuxue\\form_team_faculty_member"
local FORM_SETTING = "form_stage_main\\form_wuxue\\form_team_faculty_setting"
local FORM_DANCE = "form_stage_main\\form_wuxue\\form_team_faculty_dance"
local FORM_STAT = "form_stage_main\\form_wuxue\\form_team_faculty_stat"
local FORM_CONVERT = "form_stage_main\\form_wuxue\\form_convert_faculty"
local FORM_EXT_FACULTY = "form_stage_main\\form_wuxue\\form_ext_faculty"
function on_msg(sub_cmd, ...)
  if sub_cmd == nil then
    return false
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_READY) then
    util_show_form(FORM_MEMBER, true)
    local form_member = util_get_form(FORM_MEMBER, false)
    if not nx_is_valid(form_member) then
      return
    end
    local timer = nx_value(GAME_TIMER)
    send_to_chat_channel(form_member)
    timer:Register(20000, -1, nx_current(), "send_to_chat_channel", form_member, -1, -1)
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_PLAY_JOIN) then
    util_show_form(FORM_MEMBER, true)
    local sx = nx_number(arg[1])
    local sz = nx_number(arg[2])
    local so = nx_number(arg[3])
    create_point_effect(sx, sz, so)
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_PREPAR) then
    util_show_form(FORM_SETTING, false)
    local form_member = util_get_form(FORM_MEMBER, false)
    if not nx_is_valid(form_member) then
      return
    end
    form_member.btn_begin.Visible = false
    form_member.groupbox_score.Visible = true
    nx_execute(FORM_MEMBER, "hide_head_info", form_member)
    create_begin_animation()
    delete_point_effect()
    local scene = nx_value("game_scene")
    local game_control = scene.game_control
    if nx_is_valid(game_control) then
      game_control:ResetControlKey()
    end
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_PLAYER_READY) then
    local game_client = nx_value("game_client")
    local view = game_client:GetView(nx_string(VIEWPORT_TEAM_FACULTY))
    if not nx_is_valid(view) then
      return
    end
    local player_count = view:GetRecordRows("team_faculty_rec")
    if nx_int(player_count) > nx_int(1) then
      nx_function("ext_flash_window")
    end
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_PLAY_OPEN) then
    local form_dance = util_get_form(FORM_DANCE, true)
    if not nx_is_valid(form_dance) then
      return
    end
    if arg[1] == nil or arg[2] == nil then
      return
    end
    form_dance.time = nx_int(arg[1])
    form_dance.key_str = nx_string(arg[2])
    if 3 <= table.getn(arg) then
      form_dance.back_image_type = nx_int(arg[3])
    end
    form_dance.Visible = true
    form_dance:Show()
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_PLAYING) then
    local form_member = util_get_form(FORM_MEMBER, false)
    if not nx_is_valid(form_member) then
      return
    end
    nx_execute(FORM_MEMBER, "begin_show_time", form_member, nx_int(arg[1]))
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_PLAY_CLOSE) then
    util_show_form(FORM_DANCE, false)
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_PLAY_LEAVE) then
    util_show_form(FORM_DANCE, false)
    util_show_form(FORM_SETTING, false)
    util_show_form(FORM_MEMBER, false)
    util_show_form(FORM_CONVERT, false, 0)
    util_show_form(FORM_CONVERT, false, 1)
    util_show_form(FORM_EXT_FACULTY, false)
    delete_point_effect()
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_OVER) then
    create_end_animation()
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_RESULT_SUCCESS) then
    local game_client = nx_value("game_client")
    local view = game_client:GetView(nx_string(VIEWPORT_TEAM_FACULTY))
    if not nx_is_valid(view) then
      return
    end
    if nx_int(view:QueryProp("PlayType")) ~= nx_int(TEAM_FACULTY_TYPE_DONGFANG) then
      start_success_move()
      create_animation("train_team_success")
    end
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_RESULT_FAILED) then
    create_animation("train_team_failure")
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_CONVERT_FACULTY) then
    local cur_convert_id = nx_int(0)
    if table.getn(arg) >= 6 then
      cur_convert_id = nx_int(arg[6])
    end
    local form_convert = nx_value(FORM_CONVERT .. nx_string(cur_convert_id))
    if nx_is_valid(form_convert) then
      form_convert:Close()
    end
    form_convert = util_get_form(FORM_CONVERT, true, false, cur_convert_id)
    if not nx_is_valid(form_convert) then
      return
    end
    if nx_int(cur_convert_id) == nx_int(1) then
      local form_old_convert = nx_value(FORM_CONVERT .. nx_string(0))
      if nx_is_valid(form_old_convert) then
        form_old_convert.Top = form_old_convert.Top - 100
      end
    end
    form_convert.wuxue_name = nx_string(arg[1])
    form_convert.cur_level = nx_int(arg[2])
    form_convert.cur_fill = nx_int(arg[3])
    form_convert.convert_value = nx_int(arg[4])
    form_convert.total_fill = nx_int(arg[5])
    form_convert.Visible = true
    form_convert:Show()
  end
end
function hide_form()
  local helper_form = nx_value("helper_form")
  if helper_form then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local view = game_client:GetView(nx_string(VIEWPORT_TEAM_FACULTY))
  if not nx_is_valid(view) then
    return
  end
  local type = view:QueryProp("PlayType")
  local rule_type = client_player:QueryProp("DongFangRuleType")
  if nx_int(type) == nx_int(TEAM_FACULTY_TYPE_DONGFANG) and nx_int(rule_type) ~= nx_int(1) then
    return
  end
  local gui = nx_value("gui")
  local ask_dialog = util_get_form("form_common\\form_confirm", true, false)
  ask_dialog.Left = (gui.Width - ask_dialog.Width) / 2
  ask_dialog.Top = (gui.Height - ask_dialog.Height) / 2
  local text = nx_widestr(util_text("ui_diamond2_wantquit"))
  if nx_int(type) == nx_int(TEAM_FACULTY_TYPE_DONGFANG) then
    text = nx_widestr(util_text("ui_want_quit_dongfang_show"))
  end
  nx_execute("form_common\\form_confirm", "show_common_text", ask_dialog, text)
  ask_dialog:ShowModal()
  local res = nx_wait_event(100000000, ask_dialog, "confirm_return")
  if res == "ok" then
    util_show_form(FORM_DANCE, false)
    util_show_form(FORM_SETTING, false)
    util_show_form(FORM_MEMBER, false)
    util_show_form(FORM_CONVERT, false, 0)
    util_show_form(FORM_CONVERT, false, 1)
    nx_execute("custom_sender", "custom_team_faculty", SUB_CLIENT_EXIT)
  elseif res == "cancel" then
  end
end
function create_animation(ani_name)
  local gui = nx_value("gui")
  local animation = gui:Create("Animation")
  animation.AnimationImage = ani_name
  gui.Desktop:Add(animation)
  animation.AutoSize = true
  animation.Loop = false
  nx_bind_script(animation, nx_current())
  nx_callback(animation, "on_animation_end", "dance_animation_end")
  animation:Play()
end
function create_begin_animation()
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TEAM_FACULTY))
  if not nx_is_valid(view) then
    return
  end
  local type = view:QueryProp("PlayType")
  if nx_int(type) == nx_int(TEAM_FACULTY_TYPE_DONGFANG) then
    return
  end
  local cur_turn = view:QueryProp("CurTurn")
  if nx_int(cur_turn) == nx_int(0) then
    local gui = nx_value("gui")
    local animation = gui:Create("Animation")
    animation.AnimationImage = "train_team_start"
    gui.Desktop:Add(animation)
    animation.Left = (gui.Width - 500) / 2
    animation.Top = gui.Height / 6
    animation.Loop = false
    nx_bind_script(animation, nx_current())
    nx_callback(animation, "on_animation_end", "dance_animation_end")
    animation:Play()
    local form_member = util_get_form(FORM_MEMBER, false)
    if not nx_is_valid(form_member) then
      return
    end
    nx_execute(FORM_MEMBER, "on_btn_hide_click", form_member.btn_hide)
  end
end
function create_end_animation()
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TEAM_FACULTY))
  if not nx_is_valid(view) then
    return
  end
  local type = view:QueryProp("PlayType")
  if nx_int(type) == nx_int(TEAM_FACULTY_TYPE_DONGFANG) then
    return
  end
  local cur_turn = view:QueryProp("CurTurn")
  local total_turn = view:QueryProp("TotalTurn")
  if total_turn <= cur_turn + 1 then
    util_show_form(FORM_STAT, true)
    local gui = nx_value("gui")
    local animation = gui:Create("Animation")
    animation.AnimationImage = "train_team_complete"
    gui.Desktop:Add(animation)
    animation.Left = (gui.Width - 500) / 2
    animation.Top = gui.Height / 6
    animation.Loop = false
    nx_bind_script(animation, nx_current())
    nx_callback(animation, "on_animation_end", "dance_animation_end")
    animation:Play()
  end
end
function dance_animation_end(self)
  if not nx_is_valid(self) then
    return
  end
  self.Visible = false
  local gui = nx_value("gui")
  if nx_is_valid(self) then
    gui:Delete(self)
  end
end
function start_success_move()
  local game_visual = nx_value("game_visual")
  local player = game_visual:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local scene = player.scene
  if not nx_is_valid(scene) then
    return false
  end
  local game_effect = scene.game_effect
  if not nx_is_valid(game_effect) then
    return false
  end
  game_effect:SetGlobalEffect(0, player, 3, "", 0)
end
eff_table = {}
function create_point_effect(sx, sz, so)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TEAM_FACULTY))
  if not nx_is_valid(view) then
    return
  end
  local taolu = view:QueryProp("TaoLuID")
  if taolu == "" or taolu == nil then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Faculty\\faculty_team_pos.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(taolu))
  if sec_index < 0 then
    return
  end
  local point_list = ini:GetItemValueList(nx_number(sec_index), nx_string("r"))
  for i = 1, table.getn(point_list) do
    local point_info = util_split_string(point_list[i], ",")
    if table.getn(point_info) < 2 then
      return
    end
    local offset_x = nx_number(point_info[1])
    local offset_z = nx_number(point_info[2])
    local dist = math.sqrt(offset_x * offset_x + offset_z * offset_z)
    if 100 < dist then
      return
    end
    local real_orient = math_get_angle(offset_z, offset_x, dist)
    local dest_orient = nip_radianII(so + real_orient)
    local result_x = sx + math.sin(dest_orient) * dist
    local result_z = sz + math.cos(dest_orient) * dist
    local result_y = scene.terrain:GetPosiY(result_x, result_z)
    local eff = nx_execute("game_effect", "create_eff_model_in_mainscene", scene, "light_hold_51", result_x, result_y, result_z)
    if nx_is_valid(eff) then
      table.insert(eff_table, eff)
    end
  end
end
function delete_point_effect()
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  if not nx_find_custom(scene, "terrain") then
    return
  end
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return
  end
  for i = 1, table.getn(eff_table) do
    local eff = eff_table[i]
    if nx_is_valid(eff) then
      terrain:RemoveVisual(eff)
      scene:Delete(eff)
    end
  end
  eff_table = {}
end
function send_to_chat_channel(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TEAM_FACULTY))
  if not nx_is_valid(view) then
    return
  end
  local state = view:QueryProp("CurState")
  if nx_int(state) ~= nx_int(1) then
    return
  end
  local type = view:QueryProp("PlayType")
  if nx_int(type) == nx_int(TEAM_FACULTY_TYPE_DONGFANG) or nx_int(type) == nx_int(TEAM_FACULTY_TYPE_JIUGONG) then
    return
  end
  local turn = view:QueryProp("TotalTurn")
  local name = view:QueryProp("TaoLuID")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local state = client_player:QueryProp("TeamFacultyState")
  if nx_int(state) ~= nx_int(1) then
    return
  end
  local player_name = client_player:QueryProp("Name")
  local data = nx_widestr("teamfaculty,") .. nx_widestr(player_name)
  local gui = nx_value("gui")
  local player_name = client_player:QueryProp("Name")
  local info = gui.TextManager:GetFormatText(nx_string("ui_team_faculty_channel"), nx_string(name), nx_string(turn), nx_string(data))
  nx_execute("custom_sender", "custom_chat", nx_int(1), nx_widestr(info))
end
