require("util_gui")
require("util_functions")
require("custom_sender")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\view_define")
local IsFormShowed
function open_form()
  if not util_is_form_visible("form_stage_main\\form_offline\\form_offline") then
    nx_execute("form_stage_main\\form_offline\\form_offline", "open_form_offline")
    local form = nx_value("form_stage_main\\form_offline\\form_offline")
    form_to_front(form)
  else
    nx_execute("form_stage_main\\form_offline\\form_offline", "hide_window")
  end
end
function open_offline_daily_form()
  open_form()
end
function form_to_front(form)
  if not nx_is_valid(form) then
    return
  end
  if not form.Visible then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.Desktop:ToFront(form)
end
function main_form_init(form)
  form.SubFormDaily = false
  form.SubFormLog = false
  form.SubFormTrainingOption = false
  form.SubFormStall = false
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  update_form_pos(form)
  form.Visible = true
  return 1
end
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
  return 1
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  ui_destroy_attached_form(form)
  form:Close()
end
function update_form_pos(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function open_form_offline()
  IsFormShowed = false
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ASK_OPEN_DAILY))
  end
  local sock = nx_value("game_sock")
  if not nx_is_valid(sock) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "show_confirm_exit", sock)
  timer:Register(2000, 1, nx_current(), "show_confirm_exit", sock, -1, -1)
end
function show_window(date, type, job_id1, job_id2, job_id3, job_id4, job_id5, idCnt, sceneID, jobSuff, isNewRole, stage)
  local form_confirm = nx_value("exit_game_form_confirm")
  if nx_is_valid(form_confirm) and form_confirm.Visible then
    nx_execute("form_common\\form_confirm", "cancel_btn_click", form_confirm)
  end
  if date == 0 then
    nx_execute("main", "confirm_exit_game")
    IsFormShowed = true
    return
  end
  if type ~= 0 then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\form_offline", true, false)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(isNewRole) <= nx_int(0) and nx_int(idCnt) == nx_int(0) then
    return
  end
  IsFormShowed = true
  form.Date = date
  form.ShowType = type
  local flag_daily_show = false
  local flag_log_show = false
  local flag_training_show = false
  local flag_stall_show = false
  local flag_sub_offline = false
  local sub_form_daily = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\sub_form_offline_daily", true, false)
  local sub_form_log = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\sub_form_offline_log", true, false)
  local sub_form_training = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\sub_form_offline_training_option", true, false)
  local sub_form_stall = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\sub_form_offline_stall", true, false)
  local sub_form_offline = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\sub_form_offline", true, false)
  if not (nx_is_valid(sub_form_daily) and nx_is_valid(sub_form_log) and nx_is_valid(sub_form_training) and nx_is_valid(sub_form_stall)) or not nx_is_valid(sub_form_offline) then
    return
  end
  if not nx_find_custom(form, "sub_form_daily") then
    if not form:Add(sub_form_daily) then
      return
    end
    form.sub_form_daily = sub_form_daily
  end
  if not nx_find_custom(form, "sub_form_log") then
    if not form:Add(sub_form_log) then
      return
    end
    form.sub_form_log = sub_form_log
  end
  if not nx_find_custom(form, "sub_form_training") then
    if not form:Add(sub_form_training) then
      return
    end
    form.sub_form_training = sub_form_training
  end
  if not nx_find_custom(form, "sub_form_stall") then
    if not form:Add(sub_form_stall) then
      return
    end
    form.sub_form_stall = sub_form_stall
  end
  if not nx_find_custom(form, "sub_form_offline") then
    if not form:Add(sub_form_offline) then
      return
    end
    form.sub_form_offline = sub_form_offline
  else
    form.sub_form_offline = sub_form_offline
  end
  flag_sub_offline_show = nx_execute("form_stage_main\\form_offline\\sub_form_offline", "init_form", sub_form_offline, date, type, job_id1, job_id2, job_id3, job_id4, job_id5, idCnt, sceneID, jobSuff, isNewRole, stage)
  flag_daily_show = nx_execute("form_stage_main\\form_offline\\sub_form_offline_daily", "init_form", sub_form_daily, date, type)
  flag_log_show = nx_execute("form_stage_main\\form_offline\\sub_form_offline_log", "init_log", sub_form_log, date, type)
  if nx_number(type) == 0 then
    flag_training_show = true
    flag_stall_show = true
  end
  if not flag_daily_show and not flag_log_show and not flag_training_show and not flag_stall_show then
    return
  end
  form.show_page1 = flag_daily_show
  form.show_page2 = flag_log_show
  form.show_page3 = flag_training_show
  form.show_page4 = flag_stall_show
  form.show_page5 = flag_sub_offline_show
  hide_sub_form(form)
  init_main_form(form, flag_daily_show)
  nx_execute("util_gui", "ui_show_attached_form", form)
  local ret = nx_execute("form_stage_main\\form_small_game\\form_game_songjing", "is_in_minigame_song_jing")
  if ret then
    return form:ShowModal()
  else
    return form:Show()
  end
end
function hide_window()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\form_offline", true, false)
  return form:Close()
end
function hide_sub_form(form)
  form.sub_form_daily.Visible = false
  form.sub_form_log.Visible = false
  form.sub_form_training.Visible = false
  form.sub_form_stall.Visible = false
  form.sub_form_offline.Visible = false
end
function init_page(form)
  form.btn_offline_daily.Visible = form.show_page1
  form.btn_offline_log.Visible = form.show_page2
  form.btn_offline_training.Visible = form.show_page3
  form.btn_offline_stall.Visible = form.show_page4
  local base_left = 19
  local home_page = 0
  if form.btn_offline_daily.Visible then
    form.btn_offline_daily.Left = base_left
    base_left = 107
    home_page = 1
  end
  if form.btn_offline_log.Visible then
    form.btn_offline_log.Left = base_left
    base_left = base_left + 88
  end
  if form.btn_offline_training.Visible then
    form.btn_offline_training.Left = base_left
    base_left = base_left + 88
    if 0 >= nx_number(home_page) then
      home_page = 3
    end
  end
  if form.btn_offline_stall.Visible then
    form.btn_offline_stall.Left = base_left
  end
  if nx_number(home_page) == 1 then
    on_btn_offline_daily_click(form.btn_offline_daily)
  elseif nx_number(home_page) == 3 then
    on_btn_offline_training_click(form.btn_offline_training)
  end
end
function on_btn_offline_daily_click(btn)
  local form = btn.ParentForm
  hide_sub_form(form)
  if not form.SubFormDaily and nx_is_valid(form.sub_form_daily) then
    form.sub_form_daily.Visible = false
    form.sub_form_daily.Fixed = true
    form.sub_form_daily.Left = 10
    form.SubFormDaily = true
  end
  form.sub_form_daily.Visible = true
  form:ToFront(form.sub_form_daily)
end
function on_btn_offline_log_click(btn)
  local form = btn.ParentForm
  hide_sub_form(form)
  if not form.SubFormLog and nx_is_valid(form.sub_form_log) then
    form.sub_form_log.Visible = false
    form.sub_form_log.Fixed = true
    form.sub_form_log.Left = 10
    form.SubFormLog = true
  end
  form.sub_form_log.Visible = true
  form:ToFront(form.sub_form_log)
end
function on_btn_offline_training_click(btn)
  local form = btn.ParentForm
  hide_sub_form(form)
  if not form.SubFormTrainingOption and nx_is_valid(form.sub_form_daily) then
    form.sub_form_training.Visible = false
    form.sub_form_training.Fixed = true
    form.sub_form_training.Left = 10
    form.SubFormTrainingOption = true
  end
  form.sub_form_training.Visible = true
  form:ToFront(form.sub_form_training)
end
function on_btn_offline_stall_click(btn)
  local form = btn.ParentForm
  hide_sub_form(form)
  if not form.SubFormStall and nx_is_valid(form.sub_form_stall) then
    form.sub_form_stall.Visible = false
    form.sub_form_stall.Fixed = true
    form.sub_form_stall.Left = 10
    form.SubFormStall = true
  end
  form.sub_form_stall.Visible = true
  form:ToFront(form.sub_form_stall)
end
function init_main_form(form, flag_daily_show)
  form.sub_form_offline.Visible = true
  form.sub_form_offline.btn_log.Visible = flag_daily_show
  form.sub_form_daily.Top = 40
  form.sub_form_log.Top = 40
  form.sub_form_training.Top = 40
  form.sub_form_stall.Top = 40
  form.sub_form_offline.Top = 40
  form.sub_form_offline.btn_log.Visible = form.show_page2
  form.sub_form_offline.btn_daily.Visible = false
  form.sub_form_offline.btn_log.Visible = false
  form:ToFront(form.sub_form_offline)
end
function show_log()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\form_offline", true, false)
  hide_sub_form(form)
  if not form.SubFormLog and nx_is_valid(form.sub_form_log) then
    form.sub_form_log.Visible = false
    form.sub_form_log.Fixed = true
    form.sub_form_log.Left = 0
    form.SubFormLog = true
  end
  form.sub_form_log.Visible = true
  form:ToFront(form.sub_form_log)
end
function show_daily()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\form_offline", true, false)
  hide_sub_form(form)
  if not form.SubFormDaily and nx_is_valid(form.sub_form_daily) then
    form.sub_form_daily.Visible = false
    form.sub_form_daily.Fixed = true
    form.sub_form_daily.Left = 0
    form.SubFormDaily = true
  end
  form.sub_form_daily.Visible = true
  form:ToFront(form.sub_form_daily)
end
function show_training()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\form_offline", true, false)
  hide_sub_form(form)
  if not form.SubFormTrainingOption and nx_is_valid(form.sub_form_daily) then
    form.sub_form_training.Visible = false
    form.sub_form_training.Fixed = true
    form.sub_form_training.Left = 0
    form.SubFormTrainingOption = true
  end
  form.sub_form_training.Visible = true
  form:ToFront(form.sub_form_training)
end
function show_main()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\form_offline", true, false)
  form.sub_form_offline.Visible = true
  form.sub_form_daily.Visible = false
  form.sub_form_log.Visible = false
  form.sub_form_training.Visible = false
  form.sub_form_stall.Visible = false
end
function show_confirm_exit(sock)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "show_confirm_exit", sock)
  if IsFormShowed ~= true then
    local form_confirm = nx_value("exit_game_form_confirm")
    if nx_is_valid(form_confirm) then
      if form_confirm.Visible then
        return
      else
        form_confirm.Visible = true
      end
    else
      nx_execute("main", "confirm_exit_game")
    end
  end
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
