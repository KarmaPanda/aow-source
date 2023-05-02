require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("const_define")
require("util_functions")
require("util_gui")
require("tips_data")
require("define\\request_type")
server_sub_custommsg_question_info = 1
server_sub_custommsg_close_form = 2
CLIENT_CUSMSG_CHOOSE = 1
local FORM = "form_stage_main\\form_check_afk_question"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  form.left_time = 30
  form.result = 0
  form.right_answer = 0
  form.is_answer = 0
  form.lbl_right.Visible = false
  form.lbl_wrong.Visible = false
  form.lbl_time.Text = nx_widestr(form.left_time)
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:Register(1000, -1, nx_current(), "update_left_time", form, -1, -1)
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function update_left_time(form)
  form.left_time = form.left_time - 1
  form.lbl_time.Text = nx_widestr(form.left_time)
  if nx_int(form.left_time) <= nx_int(0) then
    local game_timer = nx_value("timer_game")
    if nx_is_valid(game_timer) then
      game_timer:UnRegister(nx_current(), "update_left_time", form)
    end
    form:Close()
  end
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.is_answer == 1 then
    return
  end
  form.is_answer = 1
  nx_execute("custom_sender", "custom_check_afk_question", nx_int(CLIENT_CUSMSG_CHOOSE), nx_int(form.result))
  update_result(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_rbtn_1_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not btn.Checked then
    return
  end
  form.result = 1
end
function on_rbtn_2_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not btn.Checked then
    return
  end
  form.result = 2
end
function on_rbtn_3_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not btn.Checked then
    return
  end
  form.result = 3
end
function update_result(form)
  form.lbl_right.Visible = false
  form.lbl_wrong.Visible = falses
  if form.result == form.right_answer then
    form.lbl_right.Visible = true
  else
    form.lbl_wrong.Visible = true
  end
end
function on_server_msg(submsg, ...)
  if nx_int(server_sub_custommsg_question_info) == nx_int(submsg) then
    local form = nx_execute("util_gui", "util_get_form", FORM, true, false)
    if nx_is_valid(form) then
      form:Close()
    end
    local form = nx_execute("util_gui", "util_get_form", FORM, true, false)
    form:Show()
    if not nx_is_valid(form) then
      return
    end
    form.right_answer = arg[1]
    table.remove(arg, 1)
    show_form(form, unpack(arg))
  elseif nx_int(server_sub_custommsg_close_form) == nx_int(submsg) then
    local form = nx_value(FORM)
    if not nx_is_valid(form) then
      return
    end
    form:Close()
  end
end
function show_form(form, ...)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local MainText = nx_string(arg[1])
  local AnswerText1 = nx_string(arg[2])
  local AnswerText2 = nx_string(arg[3])
  local AnswerText3 = nx_string(arg[4])
  form.mltbox_questions.HtmlText = nx_widestr(gui.TextManager:GetText(MainText))
  form.lbl_answer1.Text = nx_widestr(gui.TextManager:GetText(AnswerText1))
  form.lbl_answer2.Text = nx_widestr(gui.TextManager:GetText(AnswerText2))
  form.lbl_answer3.Text = nx_widestr(gui.TextManager:GetText(AnswerText3))
end
