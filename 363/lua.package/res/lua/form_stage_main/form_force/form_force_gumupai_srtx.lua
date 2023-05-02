require("util_gui")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_force\\form_force_gumupai_srtx"
local ZZXL_IMAGE_PATH = "gui\\special\\srtx\\zz_on.png"
function main_form_init(form)
end
function on_main_form_open(form)
  util_show_form("form_stage_main\\form_relationship", false)
  nx_execute("form_stage_main\\form_main\\form_main", "move_over")
  nx_execute("gui", "gui_close_allsystem_form", 2)
  local form_chat = util_get_form("form_stage_main\\form_main\\form_main_chat", false)
  if nx_is_valid(form_chat) then
    form_chat.Top = -580
  end
  local form_sysinfo = util_get_form("form_stage_main\\form_main\\form_main_sysinfo", false)
  if nx_is_valid(form_sysinfo) then
    form_sysinfo.Top = -380
  end
  local form_main = util_get_form("form_stage_main\\form_main\\form_main", false)
  if nx_is_valid(form_main) then
    form_main.groupbox_4.Visible = false
    form_main.groupbox_5.Visible = false
    form_main.groupbox_update.Visible = false
  end
  form.Visible = true
  change_form_size()
end
function on_main_form_close(form)
  nx_execute("form_stage_main\\form_small_game\\form_game_pick", "close_form")
  nx_execute("form_stage_main\\form_small_game\\form_game_bee", "close_form_force")
  nx_execute("form_stage_main\\form_small_game\\form_game_balance", "close_form")
  nx_execute("form_stage_main\\form_small_game\\form_game_question", "close_form")
  nx_destroy(form)
end
function on_main_form_shut(self)
  nx_execute("gui", "gui_open_closedsystem_form")
  local form_chat = util_get_form("form_stage_main\\form_main\\form_main_chat", false)
  if nx_is_valid(form_chat) then
    form_chat.Top = -681
  end
  local form_sysinfo = util_get_form("form_stage_main\\form_main\\form_main_sysinfo", false)
  if nx_is_valid(form_sysinfo) then
    form_sysinfo.Top = -407
  end
  local form_main = util_get_form("form_stage_main\\form_main\\form_main", false)
  if nx_is_valid(form_main) and nx_is_valid(form_main.groupbox_4) and nx_is_valid(form_main.groupbox_5) then
    form_main.groupbox_4.Visible = true
    form_main.groupbox_5.Visible = true
    if nx_is_valid(form_main.groupbox_update) then
      form_main.groupbox_update.Visible = true
    end
  end
  nx_execute("custom_sender", "custom_ancient_tomb_sender", 2)
end
function change_form_size()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = 0
  form.Top = 0
  form.Width = gui.Width
  form.Height = gui.Height
  form.lbl_back.Left = 0
  form.lbl_back.Top = 0
  form.lbl_back.Width = gui.Width
  form.lbl_back.Height = gui.Height
end
function on_btn_close_click(btn)
  local ret = showconfigdialog()
  if ret then
    close_form()
  end
end
function on_btn_ready_click(btn)
  nx_execute("custom_sender", "custom_ancient_tomb_sender", 3)
  btn.Visible = false
end
function open_form(turns_max)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  form.lbl_turns_max.Text = nx_widestr(turns_max)
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function showconfigdialog()
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "exit_gumupai_srtx")
  if not nx_is_valid(dialog) then
    return
  end
  dialog.ok_btn.Visible = true
  dialog.cancel_btn.Visible = true
  dialog:ShowModal()
  local text = nx_widestr(util_format_string("gmp_srtx_sys_009"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  local res = nx_wait_event(100000000, dialog, "exit_gumupai_srtx_confirm_return")
  if res == "cancel" then
    return false
  elseif res == "ok" then
    return true
  end
end
function refresh_turns_right(turns_right)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_turns_right.Text = nx_widestr(turns_right)
  form.lbl_time_game.Text = nx_widestr(0)
end
function refresh_time_turns(time_turns, turns_cur)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_turns_cur.Text = nx_widestr(turns_cur)
  form.lbl_time_turns.Text = nx_widestr(time_turns)
  form.lbl_6.BackImage = ZZXL_IMAGE_PATH
  if nx_int(time_turns) > nx_int(0) then
    local timer = nx_value(GAME_TIMER)
    timer:Register(1000, -1, nx_current(), "on_update_time_turns", form, -1, -1)
  end
end
function on_update_time_turns(form)
  form.lbl_time_turns.Text = nx_widestr(nx_int(form.lbl_time_turns.Text) - nx_int(1))
  if nx_int(form.lbl_time_turns.Text) == nx_int(0) then
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "on_update_time_turns", form)
  end
end
function refresh_time_game(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_time_game.Text = nx_widestr(arg[1])
  if nx_int(arg[1]) > nx_int(0) then
    local timer = nx_value(GAME_TIMER)
    timer:Register(1000, -1, nx_current(), "on_update_time_game", form, -1, -1)
  end
end
function on_update_time_game(form)
  if nx_int(form.lbl_time_game.Text) == nx_int(0) then
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "on_update_time_game", form)
    return
  end
  form.lbl_time_game.Text = nx_widestr(nx_int(form.lbl_time_game.Text) - nx_int(1))
end
