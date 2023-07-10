require("util_gui")
require("share\\client_custom_define")
local FORM_NAME = "form_stage_main\\form_royal_treasure_invite"
local CLOSE_SEC = 60
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 5
end
function on_main_form_close(form)
  nx_destroy(form)
end
function open_form(player_name)
  local form = util_get_form(FORM_NAME, true)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local text = nx_widestr(gui.TextManager:GetFormatText("tips_rtm_100", nx_widestr(player_name)))
  form.mltbox_1:Clear()
  form.mltbox_1:AddHtmlText(text, -1)
  form.remain_sec = CLOSE_SEC
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "delay_close", form)
  timer:Register(1000, -1, nx_current(), "delay_close", form, -1, -1)
  form:Show()
  form.Visible = true
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ROYAL_TREASURE), nx_int(2), nx_int(0))
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ROYAL_TREASURE), nx_int(2), nx_int(1))
  form:Close()
end
function delay_close(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "remain_sec") then
    form.remain_sec = CLOSE_SEC
  end
  form.remain_sec = form.remain_sec - 1
  if form.remain_sec < 0 then
    local timer = nx_value("timer_game")
    timer:UnRegister(nx_current(), "delay_close", form)
    form:Close()
    return
  end
  form.lbl_3.Text = nx_widestr(form.remain_sec)
end
