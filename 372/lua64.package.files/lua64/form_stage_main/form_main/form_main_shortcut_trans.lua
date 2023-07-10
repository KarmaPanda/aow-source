require("share\\client_custom_define")
require("tips_func_skill")
require("player_state\\state_const")
local icon_table = {
  [1] = {
    icon_lbl = "icon\\jiaotong\\jt_xiamache01.png",
    icon_btn = "icon\\jiaotong\\jt_xiamache02.png",
    icon_skill_bg = "gui\\language\\ChineseS\\icon_trans_2.png"
  },
  [2] = {
    icon_lbl = "icon\\jiaotong\\jt_xiachuan01.png",
    icon_btn = "icon\\jiaotong\\jt_xiachuan02.png",
    icon_skill_bg = "gui\\language\\ChineseS\\icon_trans_3.png"
  }
}
local TRANS_ON = 1
local TRANS_OFF = 2
local INTERVAL_DISTANCE = 2
local SUB_CUSTOMMSG_TRANS_OFF = 3
function main_form_init(self)
  self.Fixed = true
  return 1
end
function on_main_form_open(self)
  start_timer(self)
  set_bottom_form_visible(false)
  refush_move_pos(self)
  refresh_ride_shotcut_pos()
  updata_control_pos(TRANS_ON)
end
function refush_move_pos(self)
  self.init_down_top = self.groupbox_1.Top
  self.init_up_top = self.groupbox_2.Top
  self.groupbox_1.Top = self.groupbox_1.Top - self.groupbox_1.Height
  self.groupbox_2.Top = self.groupbox_2.Top + self.groupbox_2.Height
  self.init_hide_down_top = self.groupbox_1.Top
  self.init_hide_up_top = self.groupbox_2.Top
end
function open_form(self)
  local form_relationship = nx_value("form_stage_main\\form_relationship")
  if nx_is_valid(form_relationship) then
    form_relationship:Close()
    set_bottom_form_visible(false)
  end
  local gui = nx_value("gui")
  local form_sysinfo = nx_value("form_stage_main\\form_main\\form_main_sysinfo")
  if nx_is_valid(gui) and nx_is_valid(form_sysinfo) then
    gui.Desktop:ToFront(form_sysinfo)
  end
  local form_chat_btn_right = nx_value("form_stage_main\\form_chat_system\\form_chat_light")
  if nx_is_valid(form_chat_btn_right) then
    gui.Desktop:ToFront(form_chat_btn_right)
  end
end
function on_main_form_close(form)
  updata_control_pos(TRANS_OFF)
end
function close_form(self)
  local form = self.ParentForm
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_main\\form_main_shortcut_trans", nx_null())
  set_bottom_form_visible(true)
  local form_chat_btn_right = nx_value("form_stage_main\\form_chat_system\\form_chat_light")
  if nx_is_valid(form_chat_btn_right) then
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      gui.Desktop:ToFront(form_chat_btn_right)
    end
  end
  nx_execute("form_stage_main\\form_main\\form_main_team", "update_team_panel")
end
function refresh_ride_shotcut_pos()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_trans")
  if not nx_is_valid(form) then
    return
  end
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(shortcut_grid) then
    return
  end
  form.Width = gui.Width
  form.Height = gui.Height
  form.groupbox_1.Width = form.Width
  form.groupbox_2.Width = form.Width
  form.zaiju_back_1.Width = form.Width
  form.zaiju_back.Width = form.Width
end
function start_timer(form)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(5000, 1, nx_current(), "on_timer_end", form, -1, -1)
    form.imagegrid_1.Visible = false
  end
end
function on_timer_end(form)
  if not nx_is_valid(form) then
    return
  end
  form.imagegrid_1.Visible = true
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_timer_end", form)
  end
end
function on_rightclick_grid(self, index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CREATE_WORLD_TRANS_TOOL), nx_int(SUB_CUSTOMMSG_TRANS_OFF))
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_trans")
  if not nx_is_valid(form) then
    return
  end
  on_main_form_close(form)
end
function on_select_changed(self, index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CREATE_WORLD_TRANS_TOOL), nx_int(SUB_CUSTOMMSG_TRANS_OFF))
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_trans")
  if not nx_is_valid(form) then
    return
  end
  on_main_form_close(form)
end
function on_mousein_grid(grid, index)
  local form = grid.ParentForm
  local str = ""
  if form.TransToolType == 1 then
    str = util_format_string("ui_jt_xiamache")
  else
    str = util_format_string("ui_jt_xiachuan")
  end
  nx_execute("tips_game", "show_text_tip", str, grid.AbsLeft, grid.AbsTop, 32, form)
end
function on_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function set_bottom_form_visible(vis)
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) and form_talk.Visible then
    form_talk.Visible = false
    form_talk:Close()
  end
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if nx_is_valid(shortcut_grid) then
    shortcut_grid.Visible = vis
    shortcut_grid.old_visible = vis
  end
  form_visible("form_stage_main\\form_main\\form_main_player", vis)
  form_visible("form_stage_main\\form_main\\form_main_select", vis)
  form_visible("form_stage_main\\form_main\\form_text_trace", vis)
  form_visible("form_stage_main\\form_task\\form_task_trace", vis)
  form_visible("form_stage_main\\form_main\\form_main_buff", vis)
  form_visible("form_stage_main\\form_main\\form_main_map", vis)
  if vis == false then
    form_visible("form_stage_main\\form_card\\form_card_skill", vis)
  else
    nx_execute("form_stage_main\\form_card\\form_card_skill", "show_form_cardskill")
  end
  local dialog = nx_value("form_stage_main\\form_main\\form_main_chat")
  if nx_is_valid(dialog) then
    nx_execute("form_stage_main\\form_main\\form_laba_info", "set_all_trumpet_form_visible", vis)
  end
  local main_dialog = nx_value("form_stage_main\\form_main\\form_main")
  if nx_is_valid(main_dialog) then
    main_dialog.groupbox_5.Visible = vis
  end
end
function form_visible(dialog_path, vis)
  local dialog = nx_value(dialog_path)
  if nx_is_valid(dialog) then
    dialog.Visible = vis
  end
end
function visiable_form_control(dialog_path, vis)
  local dialog = nx_value(dialog_path)
  if nx_is_valid(dialog) then
    dialog.Visible = vis
  end
end
function show_off_trans_form(trans_tool_type)
  trans_tool_type = trans_tool_type + 1
  if nx_int(trans_tool_type) <= nx_int(0) or nx_int(trans_tool_type) > nx_int(table.getn(icon_table)) then
    return
  end
  local form_load = nx_value("form_common\\form_loading")
  while nx_is_valid(form_load) do
    nx_pause(1)
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main_shortcut_trans", true, false)
  if nx_is_valid(dialog) then
    local sub_table = icon_table[trans_tool_type]
    dialog.TransToolType = trans_tool_type
    dialog.roundbox_1.BackImage = sub_table.icon_lbl
    dialog.lbl_skill_bg.BackImage = sub_table.icon_skill_bg
    dialog.imagegrid_1:AddItem(nx_int(0), nx_string(sub_table.icon_btn), nx_widestr("riding_dismount"), nx_int(0), 1)
    dialog:Show()
  end
end
function on_quick_click()
  local game_visual = nx_value("game_visual")
  local visual_player = nx_null()
  if nx_is_valid(game_visual) then
    visual_player = game_visual:GetPlayer()
  end
  if not nx_is_valid(visual_player) then
    return false
  end
end
function updata_control_pos(state_type)
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_trans")
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) or not nx_is_valid(form) then
    return
  end
  form.state_type = state_type
  timer:UnRegister(nx_current(), "updata_pos", form)
  timer:Register(20, -1, nx_current(), "updata_pos", form, -1, -1)
end
function updata_pos(self)
  local form = self.ParentForm
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  local state_type = form.state_type
  if state_type == TRANS_ON then
    if updata_control_show(form) then
      timer:UnRegister(nx_current(), "updata_pos", form)
    end
    open_form(form)
  elseif state_type == TRANS_OFF then
    if updata_control_hide(form) then
      timer:UnRegister(nx_current(), "updata_pos", form)
    end
    close_form(form)
  end
end
function updata_control_show(self)
  local form = self.ParentForm
  local show_end = true
  if form.groupbox_1.Top < form.init_down_top then
    form.groupbox_1.Top = form.groupbox_1.Top + INTERVAL_DISTANCE
    show_end = false
  end
  if form.groupbox_2.Top > form.init_up_top then
    form.groupbox_2.Top = form.groupbox_2.Top - INTERVAL_DISTANCE
    show_end = false
  end
  return show_end
end
function updata_control_hide(self)
  local form = self.ParentForm
  local show_end = true
  if form.groupbox_1.Top > form.init_hide_down_top then
    form.groupbox_1.Top = form.groupbox_1.Top - INTERVAL_DISTANCE
    show_end = false
  end
  if form.groupbox_2.Top < form.init_hide_up_top then
    form.groupbox_2.Top = form.groupbox_2.Top + INTERVAL_DISTANCE
    show_end = false
  end
  return show_end
end
