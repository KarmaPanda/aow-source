require("util_functions")
QUESTION_CUSMSG_REQUEST = 0
QUESTION_CUSMSG_ACCEPT = 1
QUESTION_CUSMSG_CHOOSE = 2
QUESTION_CUSMSG_SKILL = 3
QUESTION_BACKMSG_REQUEST = 0
QUESTION_BACKMSG_ACCEPT = 1
QUESTION_BACKMSG_CHOOSE = 2
QUESTION_BACKMSG_SKILL = 3
QUESTION_BACKMSG_RANK = 4
QUESTION_BACKMSG_START = 5
QUESTION_BACKMSG_ASK = 6
QUESTION_BACKMSG_DIFF = 7
QUESTION_BACKMSG_END = 8
QUESTION_STATUS_END = 0
QUESTION_STATUS_PERPARE = 1
QUESTION_STATUS_START = 2
QUESTION_STATUS_DIFF = 3
local FORM_NAME = "form_stage_main\\form_activity\\form_activity_answer_join"
function open_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_dbomall\\form_dbomall", "add_sub_form", form)
  nx_execute("custom_sender", "custom_question", nx_int(QUESTION_CUSMSG_REQUEST))
  form.Visible = true
  form:Show()
end
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local join = is_join_question()
  if nx_int(join) == nx_int(0) then
    form.btn_join.Enabled = false
  end
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_join_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_dbomall = nx_value("form_stage_main\\form_dbomall\\form_dbomall")
  if nx_is_valid(form_dbomall) then
    form_dbomall:Close()
  end
  nx_execute("custom_sender", "custom_question", nx_int(QUESTION_CUSMSG_ACCEPT))
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function question_server_msg(submsg, ...)
  if nx_int(QUESTION_BACKMSG_REQUEST) == nx_int(submsg) then
    local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
    if not nx_is_valid(form) then
      return
    end
    local state = nx_int(arg[1])
    if nx_int(QUESTION_STATUS_PERPARE) == nx_int(state) then
    else
      form.btn_join.Enabled = false
    end
    local time_text = nx_widestr(arg[2])
    form.lbl_time.Text = time_text
  end
end
function is_join_question()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local joinquestion = client_player:QueryProp("JoinQuestion")
  return nx_int(joinquestion)
end
