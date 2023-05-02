require("utils")
require("util_gui")
require("const_define")
require("custom_sender")
local control_inarena_close_table = {}
local FORM_FIGHT_MAIN = "form_stage_main\\form_fight\\form_fight_main"
local FORM_ROLE_LEFT = "form_stage_main\\form_fight\\form_fight_role_left"
local FORM_ROLE_RIGHT = "form_stage_main\\form_fight\\form_fight_role_right"
local FORM_FIGHT_ROLE = "form_stage_main\\form_fight\\form_fight_role"
local FORM_FIGHT_SETTING = "form_stage_main\\form_fight\\form_fight_setting"
local FORM_FIGHT_JOIN = "form_stage_main\\form_fight\\form_fight_join"
local FORM_FIGHT_INFO_COMMON = "form_stage_main\\form_fight\\form_fight_info_common"
local FORM_FIGHT_OVER = "form_stage_main\\form_fight\\form_fight_over"
local FORM_FIGHT_SELECT_SCENE = "form_stage_main\\form_fight\\form_fight_select_scene"
local FORM_MAIN_PLAYER = "form_stage_main\\form_main\\form_main_player"
local FORM_MAIN_MAP = "form_stage_main\\form_main\\form_main_map"
local FORM_MAIN_BUFF = "form_stage_main\\form_main\\form_main_buff"
local arena_form_table = {
  FORM_FIGHT_MAIN,
  FORM_FIGHT_SETTING,
  FORM_FIGHT_JOIN,
  FORM_FIGHT_INFO_COMMON,
  FORM_FIGHT_OVER,
  "form_stage_main\\form_main\\form_main_shortcut",
  "form_stage_main\\form_main\\form_main_sysinfo",
  "form_stage_main\\form_main\\form_main_chat"
}
local SERVER_SUB_CREATE_SUCCESS = 1
local SERVER_SUB_INIT_SUCCESS = 2
local SERVER_SUB_SHOW_JOIN = 3
local SERVER_SUB_SHOW_MAIN = 4
local SERVER_SUB_SHOW_OVER = 5
local SERVER_SUB_LEAVE_ARENA = 6
local SERVER_SUB_CHOOSE_FIELD = 7
local SERVER_SUB_SET_WUXUE = 11
local SERVER_SUB_CLOSE_WUXUE = 12
local SERVER_SUB_SHOW_COMMON_FORM = 99
function main_form_init(self)
  self.Fixed = true
  self.time = 60
  self.scene = nil
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    self.scene = game_client:GetScene()
  end
  return 1
end
function on_main_form_open(self)
  if not nx_find_custom(self, "scene") or not nx_is_valid(self.scene) then
    self:Close()
    return
  end
  hide_other_form()
  on_size_change()
  local form_right = util_get_form(FORM_ROLE_RIGHT, true, false)
  local form_left = util_get_form(FORM_ROLE_LEFT, true, false)
  if not nx_is_valid(form_left) or not nx_is_valid(form_right) then
    return
  end
  self.groupbox_left:Add(form_left)
  self.groupbox_right:Add(form_right)
  self.form_left = form_left
  self.form_right = form_right
  local main_player = get_player()
  if not nx_is_valid(main_player) then
    return
  end
  local player_name = main_player:QueryProp("Name")
  if is_arena_player(player_name) then
    self.groupbox_camera.Visible = false
  else
    self.groupbox_camera.Visible = true
    custom_gminfo(nx_widestr("setobj"))
    custom_gminfo(nx_widestr("hide"))
  end
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:Register(500, -1, nx_current(), "up_date_role_info", self, -1, -1)
    timer:Register(1000, -1, nx_current(), "up_date_time", self, -1, -1)
  end
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "up_data_role_info", self)
    timer:UnRegister(nx_current(), "up_date_time", self)
  end
  nx_destroy(self)
end
function on_main_form_shut(form)
  show_other_form()
  local form_fight_over = nx_value(FORM_FIGHT_OVER)
  if nx_is_valid(form_fight_over) then
    form_fight_over:Close()
  end
  local form_main_buff = nx_value(FORM_MAIN_BUFF)
  if nx_is_valid(form_main_buff) then
    local gui = nx_value("gui")
    form_main_buff.Top = 0
    form_main_buff.Left = gui.Width - form_main_buff.Width - 200
  end
end
function on_size_change()
  local form = nx_value(FORM_FIGHT_MAIN)
  local gui = nx_value("gui")
  if nx_is_valid(form) and nx_is_valid(gui) then
    form.AbsTop = 0
    form.AbsLeft = 0
    form.Width = gui.Desktop.Width
    form.Height = gui.Desktop.Height
  end
end
function on_btn_camera_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(FORM_FIGHT_MAIN, "goto_target_position", form)
  end
  goto_target_position(form)
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  local role = nx_value("role")
  if nx_is_valid(role) then
    game_control.Target = role
    game_control.TargetMode = 0
  end
end
function goto_target_position(form)
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  local Target = game_control.Target
  if not nx_is_valid(Target) then
    return
  end
  local DestX, DestZ = find_walk_enable_point(Target.PositionX, Target.PositionZ)
  if DestX == nil or DestZ == nil then
    return
  end
  local info = "goto " .. nx_string(DestX) .. " " .. nx_string(DestZ)
  custom_gminfo(nx_widestr(info))
end
function on_btn_show_self_click(btn)
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  scene.player_show = true
  nx_execute("console", "show_player")
  show_or_hide_head_info(1)
end
function on_btn_hide_self_click(btn)
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  scene.player_show = false
  nx_execute("console", "hide_player")
  show_or_hide_head_info(0)
end
function show_or_hide_head_info(is_show)
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return
  end
  util_set_property_key(game_config_info, "showself_name", nx_int(is_show))
  util_set_property_key(game_config_info, "showself_titleid", nx_int(is_show))
  util_set_property_key(game_config_info, "showself_guild", nx_int(is_show))
  util_set_property_key(game_config_info, "showself_guildid", nx_int(is_show))
  util_set_property_key(game_config_info, "showhead_hp", nx_int(is_show))
  util_set_property_key(game_config_info, "showself_qg", nx_int(is_show))
  nx_execute("game_config", "save_game_config", game_config_info, "systeminfo.ini", "Config")
  local main_player = get_player()
  local head_game = nx_value("HeadGame")
  local game_visual = nx_value("game_visual")
  if not (nx_is_valid(main_player) and nx_is_valid(head_game)) or not nx_is_valid(game_visual) then
    return
  end
  local visual_obj = game_visual:GetSceneObj(main_player.Ident)
  if not nx_is_valid(visual_obj) then
    return
  end
  head_game:RefreshHeadConfig()
  head_game:RefreshAll(visual_obj)
end
function on_btn_game_over_click(btn)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if nx_is_valid(dialog) then
    local gui = nx_value("gui")
    dialog.mltbox_info:Clear()
    dialog.mltbox_info.HtmlText = nx_widestr(gui.TextManager:GetText("ui_arena_game_over_confirm"))
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "cancel" then
      return
    end
  end
  custom_arena_game_over()
end
function on_btn_leave_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local dialog = util_get_form("form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  dialog.mltbox_info:Clear()
  dialog.mltbox_info.HtmlText = nx_widestr(gui.TextManager:GetText("ui_arena_leave_confirm"))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    if "" == form.huashan_path then
      nx_execute("custom_sender", "custom_arena_leave")
    else
      form:Close()
    end
  end
end
function get_player()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  return client_player
end
function get_scene()
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  return client_scene
end
function is_arena_player(player_name)
  local scene = get_scene()
  if not nx_is_valid(scene) then
    return false
  end
  if player_name == scene:QueryProp("PlayerA") then
    return true
  elseif player_name == scene:QueryProp("PlayerB") then
    return true
  end
  return false
end
function is_arena_scene()
  local scene = get_scene()
  if not nx_is_valid(scene) then
    return false
  end
  if scene:FindProp("ArenaState") then
    return true
  end
  return false
end
function on_msg(sub_cmd, ...)
  if SERVER_SUB_CHOOSE_FIELD == sub_cmd then
    nx_execute("util_gui", "util_auto_show_hide_form", FORM_FIGHT_SELECT_SCENE)
  elseif SERVER_SUB_CREATE_SUCCESS == sub_cmd then
    if #arg < 1 then
      return
    end
    nx_execute(FORM_FIGHT_SETTING, "open_form_by_param", nx_int(arg[1]))
  elseif SERVER_SUB_INIT_SUCCESS == sub_cmd then
  elseif SERVER_SUB_SHOW_JOIN == sub_cmd then
    nx_execute(FORM_FIGHT_JOIN, "open_form_by_custom", unpack(arg))
  elseif SERVER_SUB_SHOW_MAIN == sub_cmd then
    local stage_main_flag = nx_value("stage_main")
    local loading_flag = nx_value("loading")
    local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
    while loading_flag or nx_string(stage_main_flag) ~= nx_string("success") or bMovie do
      nx_pause(1)
      stage_main_flag = nx_value("stage_main")
      loading_flag = nx_value("loading")
      bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
    end
    local form = nx_execute("util_gui", "util_show_form", FORM_FIGHT_MAIN, true)
  elseif SERVER_SUB_SHOW_COMMON_FORM == sub_cmd then
    nx_execute(FORM_FIGHT_INFO_COMMON, "open_form_by_custom", unpack(arg))
  elseif SERVER_SUB_SHOW_OVER == sub_cmd then
    if #arg < 3 then
      return
    end
    local form_over = nx_execute("util_gui", "util_show_form", FORM_FIGHT_OVER, true)
    if nx_is_valid(form_over) then
      form_over.lbl_winner.Text = nx_widestr(arg[1])
      form_over.lbl_score_a.Text = nx_widestr(arg[2])
      form_over.lbl_score_b.Text = nx_widestr(arg[3])
    end
  elseif SERVER_SUB_LEAVE_ARENA == sub_cmd then
    local form = nx_value(FORM_FIGHT_MAIN)
    if nx_is_valid(form) then
      form:Close()
    end
  elseif SERVER_SUB_SET_WUXUE == sub_cmd then
    util_show_form("form_stage_main\\form_wuxue\\form_wuxue_simulator", true)
  elseif SERVER_SUB_CLOSE_WUXUE == sub_cmd then
    util_show_form("form_stage_main\\form_wuxue\\form_wuxue_simulator", false)
  end
end
function up_date_role_info(form)
  up_date_singl_role_info(form.form_left)
  up_date_singl_role_info(form.form_right)
end
function up_date_singl_role_info(form)
  nx_execute(FORM_FIGHT_ROLE, "refresh_name", form)
  nx_execute(FORM_FIGHT_ROLE, "refresh_skill", form)
  local form_player = form.player
  if not nx_is_valid(form_player) then
    return
  end
  local main_player = get_player()
  if not nx_is_valid(main_player) then
    return
  end
  if nx_string(form_player) ~= nx_string(main_player) then
    nx_execute(FORM_FIGHT_ROLE, "refresh_hp", form)
    nx_execute(FORM_FIGHT_ROLE, "refresh_sp", form)
    nx_execute(FORM_FIGHT_ROLE, "refresh_hit_hp_tge_value", form)
    nx_execute(FORM_FIGHT_ROLE, "refresh_mp", form)
  end
  nx_execute(FORM_FIGHT_ROLE, "resize_buff_groupbox", form)
end
function up_date_time(form)
  local scene = form.scene
  if not nx_is_valid(scene) then
    return
  end
  local cur_time = scene:QueryProp("TimeTick")
  if cur_time < 0 then
    local timer = nx_value(GAME_TIMER)
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "up_date_time", form)
    end
    return
  end
  form.lbl_time.Text = nx_widestr(cur_time)
  update_round_info(form)
  update_arena_status(form)
end
function hide_other_form()
  local gui = nx_value("gui")
  local childlist = gui.Desktop:GetChildControlList()
  for i = table.maxn(childlist), 1, -1 do
    local control = childlist[i]
    if nx_is_valid(control) and control.Visible and not is_need_show_form(control) then
      control.Visible = false
      table.insert(control_inarena_close_table, control)
    end
  end
  local main_player = get_player()
  if not nx_is_valid(main_player) then
    return
  end
  if not is_arena_player(main_player:QueryProp("Name")) then
    local form_main_shortcut = nx_value("form_stage_main\\form_main\\form_main_shortcut")
    if nx_is_valid(form_main_shortcut) and form_main_shortcut.Visible then
      form_main_shortcut.Visible = false
      table.insert(control_inarena_close_table, form_main_shortcut)
    end
    local form_main_sysinfo = nx_value("form_stage_main\\form_main\\form_main_sysinfo")
    if nx_is_valid(form_main_sysinfo) and form_main_sysinfo.Visible then
      form_main_sysinfo.Visible = false
      table.insert(control_inarena_close_table, form_main_sysinfo)
    end
  end
end
function show_other_form()
  local gui = nx_value("gui")
  for i = table.maxn(control_inarena_close_table), 1, -1 do
    local control = control_inarena_close_table[i]
    if nx_is_valid(control) then
      control.Visible = true
    end
  end
  control_inarena_close_table = {}
end
function is_need_show_form(form)
  if not nx_is_valid(form) then
    return false
  end
  local script = nx_script_name(form)
  for i, para in pairs(arena_form_table) do
    if script == para then
      return true
    end
  end
  return false
end
function update_round_info(form)
  local scene = form.scene
  if not nx_is_valid(scene) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local cur_round = scene:QueryProp("CurRound")
  local total_round = scene:QueryProp("TotalRound")
  if cur_round > total_round then
    cur_round = "n"
  end
  form.lbl_text.Text = nx_widestr(gui.TextManager:GetText("ui_arena_round_" .. nx_string(cur_round)))
  update_win_count_info(form.form_left)
  update_win_count_info(form.form_right)
end
function update_win_count_info(form)
  local scene = form.scene
  if not nx_is_valid(scene) then
    return
  end
  local cur_player = form.player
  if not nx_is_valid(cur_player) then
    return
  end
  local win_count = 0
  local player_name = cur_player:QueryProp("Name")
  if player_name == scene:QueryProp("PlayerA") then
    win_count = scene:QueryProp("AWinCount")
  elseif player_name == scene:QueryProp("PlayerB") then
    win_count = scene:QueryProp("BWinCount")
  end
  for i = 1, win_count do
    local lbl_name = "lbl_win_" .. nx_string(i)
    local lbl_win = form.groupbox_win_count:Find(lbl_name)
    if nx_is_valid(lbl_win) then
      lbl_win.Visible = true
    end
  end
end
function update_arena_status(form)
  local scene = form.scene
  if not nx_is_valid(scene) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local arena_state = scene:QueryProp("ArenaState")
  form.lbl_status.Text = nx_widestr(gui.TextManager:GetText("ui_arena_status_" .. nx_string(arena_state)))
end
function find_walk_enable_point(x, z)
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return
  end
  for i = 1, 20 do
    if terrain:GetWalkEnable(x, z) then
      return x, z
    end
    if 600 < x then
      x = x - 1
    else
      x = x + 1
    end
    if 600 < z then
      z = z - 1
    else
      z = z + 1
    end
  end
  return nil, nil
end
