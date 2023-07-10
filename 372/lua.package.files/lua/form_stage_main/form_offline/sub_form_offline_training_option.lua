require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("form_stage_main\\form_offline\\offline_define")
local cost_slow = 10
local cost_normal = 25
local cost_fast = 40
local percent_slow = 10
local percent_normal = 30
local percent_fast = 50
local costPerHour = 40
local timeTotal = 4
function main_form_init(form)
  form.Fixed = true
  return 1
end
function on_main_form_open(form)
  init_form(form)
  form.Visible = true
  getOffLineExerciseInfo()
  form.lbl_property.Text = nx_widestr(getPlayerGoldCnt())
  setCostAndTime(40, 4)
  updateTrainingTotalCost(form)
  form.lbl_money.Visible = false
  return 1
end
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_quit_click(btn)
  nx_execute("main", "wait_exit_game")
end
function on_btn_start_training_click(btn)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog.info_label.Text = nx_widestr(util_text("ui_start_training_desc"))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  local form = btn.ParentForm
  if nx_number(timeTotal) > 0 and nx_number(costPerHour) > 0 then
    start_offline_trustee(nx_int(timeTotal), nx_int(costPerHour))
  end
end
function show_window()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\sub_form_offline_training_option", true, false)
  form:Show()
end
function init_form(form)
end
function on_ipt_time_changed(edit)
  local cur_val = edit.Text
  if nx_string(cur_val) == "0" or nx_string(cur_val) == "1" or nx_string(cur_val) == "2" or nx_string(cur_val) == "3" or nx_string(cur_val) == "4" then
    local form = edit.ParentForm
    update_option(form)
  else
    edit.Text = nx_widestr("0")
  end
end
function on_rbtn_speed_checked_changed(rbtn)
  local form = rbtn.ParentForm
  update_option(form)
end
function update_option(form)
  if form.rbtn_fast.Checked then
    costPerHour = cost_fast
  elseif form.rbtn_normal.Checked then
    costPerHour = cost_normal
  elseif form.rbtn_slow.Checked then
    costPerHour = cost_slow
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  updateTrainingTotalCost(form)
end
function on_rbtn_time_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if form.rbtn_1hour.Checked then
    timeTotal = 1
  elseif form.rbtn_2hour.Checked then
    timeTotal = 2
  elseif form.rbtn_3hour.Checked then
    timeTotal = 3
  elseif form.rbtn_4hour.Checked then
    timeTotal = 4
  end
  updateTrainingTotalCost(form)
end
function updateTrainingTotalCost(form)
  form.lbl_money.Text = nx_widestr(nx_number(costPerHour) * nx_number(timeTotal))
  if nx_int(form.lbl_money.Text) > nx_int(form.lbl_property.Text) then
    form.lbl_money.ForeColor = "255,255,0,0"
  else
    form.lbl_money.ForeColor = "255,147,123,99"
  end
end
function getOffLineExerciseInfo()
  local offMgr = nx_value("OffLineJobManager")
  if nx_is_valid(offMgr) then
    cost_slow = nx_int(offMgr:GetOffLinePracticeProp("ConvertWorthSlow"))
    cost_normal = nx_int(offMgr:GetOffLinePracticeProp("ConvertWorthNormal"))
    cost_fast = nx_int(offMgr:GetOffLinePracticeProp("ConvertWorthFast"))
    percent_slow = nx_int(offMgr:GetOffLinePracticeProp("ConvertRatioSlow"))
    percent_normal = nx_int(offMgr:GetOffLinePracticeProp("ConvertRatioNormal"))
    percent_fast = nx_int(offMgr:GetOffLinePracticeProp("ConvertRatioFast"))
  end
end
function getPlayerGoldCnt()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local goldCnt = nx_number(client_player:QueryProp("CapitalType0"))
  return goldCnt
end
function setCostAndTime(cost, time)
  costPerHour = cost
  timeTotal = time
end
function start_offline_trustee(time, speed)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_START_OFFLINE_TRUSTEE), nx_int(time), nx_int(speed))
end
function on_btn_return_click(btn)
  nx_execute("form_stage_main\\form_offline\\form_offline", "show_main")
end
