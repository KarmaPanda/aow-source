require("util_gui")
require("share\\client_custom_define")
local FORM_NAME = "form_stage_main\\form_skyhill\\form_sanhill_invite"
local CLOSE_SEC = 60
function on_main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 5
  form.clone_id = 0
  form.clone_lvl = 0
  form.game_id = 0
  form.player_name = nx_widestr("")
end
function on_main_form_close(form)
  if nx_running(nx_current(), "delay_close") then
    nx_kill(nx_current(), "delay_close")
  end
  nx_destroy(form)
end
function open_form(...)
  local form = util_get_form(FORM_NAME, true)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.clone_id = arg[1]
  form.clone_lvl = arg[2]
  form.game_id = arg[3]
  form.player_name = arg[4]
  local text = nx_widestr(gui.TextManager:GetFormatText("sanhill_invite_info", nx_widestr(form.player_name), nx_int(form.clone_lvl)))
  form.mltbox_1:Clear()
  form.mltbox_1:AddHtmlText(text, -1)
  form.remain_sec = CLOSE_SEC
  if nx_running(nx_current(), "delay_close") then
    nx_kill(nx_current(), "delay_close")
  end
  nx_execute(nx_current(), "delay_close", form)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_sanhill_msg", 10, nx_int(form.clone_id), nx_int(form.clone_lvl), nx_int(form.game_id), nx_widestr(form.player_name))
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function delay_close(form)
  while nx_is_valid(form) do
    if not nx_find_custom(form, "remain_sec") then
      form.remain_sec = CLOSE_SEC
    end
    form.remain_sec = form.remain_sec - 1
    if form.remain_sec < 0 then
      form:Close()
      return
    end
    form.lbl_3.Text = nx_widestr(form.remain_sec)
    nx_pause(1)
  end
end
