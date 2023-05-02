require("share\\view_define")
require("define\\object_type_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("const_define")
require("util_functions")
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function main_form_init(form)
  form.Fixed = true
  return 1
end
function on_main_form_open(form)
  form.lbl_lpoint.Text = nx_widestr("")
  form.lbl_rpoint.Text = nx_widestr("")
  form.lbl_right_photo.BackImage = ""
  form.lbl_right_name.Text = nx_widestr("")
  form.lbl_left_photo.BackImage = ""
  form.lbl_left_name.Text = nx_widestr("")
  form.btn_close.Visible = false
  form.step_flag = 0
  form.groupbox_left.Visible = false
  form.groupbox_right.Visible = false
end
function on_main_form_close(form)
  nx_destroy(form)
end
function close_form()
  local form_roll = nx_value("form_stage_main\\form_small_game\\form_rollgame")
  if nx_is_valid(form_roll) then
    form_roll:Close()
  end
end
function on_btn_close_click(btn)
  close_form()
end
function on_btn_start_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  btn.Enabled = false
  local RollGame = nx_value("RollGame")
  RollGame:SendStartMsg()
end
function start_roll(lpoint, rpoint)
  local form = nx_value("form_stage_main\\form_small_game\\form_rollgame")
  if nx_is_valid(form) then
    form.lpoint = lpoint
    form.rpoint = rpoint
    form.lbl_result_photo.BackImage = "gui\\mainform\\newgui\\renw-on.png"
    form.step_flag = 0
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "on_update_time", form)
    timer:Register(1000, -1, nx_current(), "on_update_time", form, -1, -1)
  end
end
function end_roll(form)
  if not nx_is_valid(form) then
    return
  end
  stop_timer(form)
  local RollGame = nx_value("RollGame")
  RollGame:SendGameResult(1)
  form.btn_close.Visible = true
  form.step_flag = 0
end
function on_update_time(form)
  form.step_flag = form.step_flag + 1
  if form.step_flag == 2 then
    form.lbl_result_photo.BackImage = ""
    form.ani_result.AnimationImage = "clone_award_3_21"
    form.ani_result.PlayMode = 0
    form.ani_result.Loop = false
  elseif form.step_flag == 9 then
    form.ani_result.AnimationImage = ""
    form.lbl_result_photo.BackImage = "gui\\mainform\\newgui\\baoguo-on.png"
    form.lbl_lpoint.Text = nx_widestr(form.lpoint)
    show_talking_text(form, "left", "ui_manytestlines")
  elseif form.step_flag == 11 then
    show_talking_text(form, "left", "123456789")
    form.lbl_result_photo.BackImage = ""
    form.ani_result.AnimationImage = "clone_award_3_22"
    form.ani_result.PlayMode = 0
    form.ani_result.Loop = false
  elseif form.step_flag == 18 then
    form.ani_result.AnimationImage = ""
    form.lbl_result_photo.BackImage = "gui\\mainform\\newgui\\hulu-on.png"
    form.lbl_rpoint.Text = nx_widestr(form.rpoint)
    show_talking_text(form, "right", "ui_manytestlines")
    end_roll(form)
  end
end
function stop_timer(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_time", form)
end
function show_roll_info(obj_id)
  local form = nx_value("form_stage_main\\form_small_game\\form_rollgame")
  if not nx_is_valid(form) then
    local RollGame = nx_value("RollGame")
    RollGame:SendGameResult(0)
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local select_object = game_client:GetSceneObj(nx_string(obj_id))
  if not nx_is_valid(select_object) then
    local RollGame = nx_value("RollGame")
    RollGame:SendGameResult(0)
    return
  end
  local photo = ""
  local name = ""
  if client_player:FindProp("Photo") then
    photo = client_player:QueryProp("Photo")
  end
  if client_player:FindProp("Name") then
    name = client_player:QueryProp("Name")
  end
  form.lbl_right_photo.BackImage = photo
  form.lbl_right_name.Text = nx_widestr(name)
  if select_object:FindProp("Photo") then
    photo = select_object:QueryProp("Photo")
  end
  local target_type = select_object:QueryProp("Type")
  if TYPE_PLAYER == target_type then
    name = select_object:QueryProp("Name")
  else
    local config_id = select_object:QueryProp("ConfigID")
    local gui = nx_value("gui")
    name = gui.TextManager:GetText(config_id)
  end
  if select_object:FindProp("Name") then
    name = select_object:QueryProp("Name")
    nx_msgbox(nx_string(name))
  end
  form.lbl_left_photo.BackImage = photo
  form.lbl_left_name.Text = nx_widestr(name)
end
function show_talking_text(form, name, textid)
  local group_control_name = "groupbox_" .. nx_string(name)
  local talk_control_name = "mltbox_" .. nx_string(name)
  local group_control = form:Find(group_control_name)
  if not nx_is_valid(group_control) then
    return
  end
  local talk_control = group_control:Find(talk_control_name)
  if not nx_is_valid(talk_control) then
    return
  end
  group_control.BlendAlpha = 255
  group_control.Visible = true
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText(nx_string(textid))
  talk_control.HtmlText = nx_widestr(text)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "timer_disappear_callback", group_control)
  timer:Register(500, -1, nx_current(), "timer_disappear_callback", group_control, -1, -1)
end
function timer_disappear_callback(control)
  local blend = control.BlendAlpha
  blend = blend - 30
  if blend <= 0 then
    blend = 0
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "timer_disappear_callback", control)
  end
  control.BlendAlpha = blend
end
