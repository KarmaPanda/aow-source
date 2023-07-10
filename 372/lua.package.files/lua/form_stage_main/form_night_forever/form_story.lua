require("util_gui")
require("tips_data")
require("custom_sender")
require("util_functions")
require("util_static_data")
require("share\\itemtype_define")
require("share\\client_custom_define")
local FORM_STORY = "form_stage_main\\form_night_forever\\form_story"
local FORM_MAIN = "form_stage_main\\form_night_forever\\form_night_forever"
local STROY_GROUPBOX = "groupbox_story"
local STROY_STATUS_PRE = "lbl_status_"
local STROY_RBTN_PRE = "rbtn_accept_"
local STROY_DESC_PRE = "lbl_desc_"
local STROY_MLTBOX_PRE = "mltbox_story_"
local index_accepted_status_img = 1
local index_completed_status_img = 2
local index_unknow_status_img = 3
local index_unlock_status_img = 4
local index_unlock_btn_normal_img = 5
local index_unlock_btn_focus_img = 6
local index_unlock_btn_push_img = 7
local index_accepted_btn_normal_img = 8
local index_accepted_btn_focus_img = 9
local index_accepted_btn_push_img = 10
local index_completed_btn_normal_img = 11
local index_completed_btn_focus_img = 12
local index_completed_btn_push_img = 13
local index_unknow_btn_img = 14
local index_unknow_desc_img = 15
local index_normal_desc_img = 16
local index_unlock_ani = 17
local index_story_text = 18
local index_pre_task = 19
local index_cur_task = 20
local index_cur_last_task = 21
local data_count = 21
local BTN_STATUS_UNKNOW = 0
local BTN_STATUS_COMPLETED = 1
local BTN_STATUS_ACCEPTED = 2
local BTN_STATUS_UNLOCK = 3
local TASK_CHANGED_NONE = 0
local TASK_CHANGED_ACCEPT = 1
local TASK_CHANGED_COMPLETE = 2
local TASK_CHANGED_GIVEUP = 3
local index_story = 2
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  init_form_data(form)
  add_data_bind(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  del_data_bind(form)
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function init_form_data(form)
  init_story(form)
  refresh_story(form)
  refresh_character(form)
end
function set_form_size(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function change_form_size()
  local form = nx_value(FORM_STORY)
  if not nx_is_valid(form) then
    return
  end
  set_form_size(form)
end
function refresh_story(form)
  local mgr = nx_value("TaskManager")
  if not nx_is_valid(mgr) then
    return
  end
  local list = mgr:GetYongyeTaskCtrlIndexList()
  local count = table.getn(list)
  for i = 1, count do
    local index = list[i]
    refresh_node(form, index)
  end
end
function refresh_node(form, index)
  local mgr = nx_value("TaskManager")
  if not nx_is_valid(mgr) then
    return
  end
  local data = mgr:GetYongyeTaskData(index)
  local count = table.getn(data)
  if count ~= data_count then
    return
  end
  local groupbox_story = form:Find(STROY_GROUPBOX)
  if not nx_is_valid(groupbox_story) then
    return
  end
  local lbl_status = groupbox_story:Find(STROY_STATUS_PRE .. nx_string(index))
  if not nx_is_valid(lbl_status) then
    return
  end
  local rbtn_accept = groupbox_story:Find(STROY_RBTN_PRE .. nx_string(index))
  if not nx_is_valid(rbtn_accept) then
    return
  end
  local lbl_desc = groupbox_story:Find(STROY_DESC_PRE .. nx_string(index))
  if not nx_is_valid(lbl_desc) then
    return
  end
  local cur_task = data[index_cur_task]
  local cur_task_status = mgr:GetTaskStatus(cur_task)
  local cur_last_task = data[index_cur_last_task]
  local cur_last_task_status = mgr:GetTaskStatus(cur_last_task)
  if cur_last_task_status == 3 then
    lbl_status.BackImage = data[index_completed_status_img]
    rbtn_accept.NormalImage = data[index_completed_btn_normal_img]
    rbtn_accept.FocusImage = data[index_completed_btn_focus_img]
    rbtn_accept.CheckedImage = data[index_completed_btn_push_img]
    lbl_desc.BackImage = data[index_normal_desc_img]
    rbtn_accept.status = BTN_STATUS_COMPLETED
    rbtn_accept.Enabled = true
    if nx_int(index) == nx_int(9) then
      rbtn_accept.HintText = nx_widestr(util_text("ui_eternalnight_task_story09_tips"))
    end
  elseif 0 <= cur_task_status and cur_task_status <= 3 then
    lbl_status.BackImage = data[index_accepted_status_img]
    rbtn_accept.NormalImage = data[index_accepted_btn_normal_img]
    rbtn_accept.FocusImage = data[index_accepted_btn_focus_img]
    rbtn_accept.CheckedImage = data[index_accepted_btn_push_img]
    lbl_desc.BackImage = data[index_normal_desc_img]
    rbtn_accept.status = BTN_STATUS_ACCEPTED
    rbtn_accept.Enabled = true
  else
    local pre_task = data[index_pre_task]
    local pre_task_status = mgr:GetTaskStatus(pre_task)
    if pre_task_status == 3 or pre_task == -1 then
      lbl_status.BackImage = data[index_unlock_status_img]
      rbtn_accept.NormalImage = data[index_unlock_btn_normal_img]
      rbtn_accept.FocusImage = data[index_unlock_btn_focus_img]
      rbtn_accept.CheckedImage = data[index_unlock_btn_push_img]
      rbtn_accept.status = BTN_STATUS_UNLOCK
      rbtn_accept.Enabled = true
    else
      lbl_status.BackImage = data[index_unknow_status_img]
      rbtn_accept.NormalImage = data[index_unknow_btn_img]
      rbtn_accept.FocusImage = data[index_unknow_btn_img]
      rbtn_accept.CheckedImage = data[index_unknow_btn_img]
      rbtn_accept.status = BTN_STATUS_UNKNOW
      rbtn_accept.Enabled = false
    end
    lbl_desc.BackImage = data[index_unknow_desc_img]
  end
end
function init_story(form)
  local mgr = nx_value("TaskManager")
  if not nx_is_valid(mgr) then
    return
  end
  local list = mgr:GetYongyeTaskCtrlIndexList()
  local count = table.getn(list)
  for i = 1, count do
    local index = list[i]
    local groupbox_story = form:Find(STROY_GROUPBOX)
    if not nx_is_valid(groupbox_story) then
      return
    end
    local rbtn_accept = groupbox_story:Find(STROY_RBTN_PRE .. nx_string(index))
    if not nx_is_valid(rbtn_accept) then
      return
    end
    rbtn_accept.DataSource = nx_string(index)
    rbtn_accept.status = BTN_STATUS_UNKNOW
    rbtn_accept.Enabled = true
    nx_bind_script(rbtn_accept, nx_current())
    nx_callback(rbtn_accept, "on_checked_changed", "on_rbtn_checked_changed")
    local mltbox_story = groupbox_story:Find(STROY_MLTBOX_PRE .. nx_string(index))
    if nx_is_valid(mltbox_story) then
      mltbox_story.Visible = false
    end
  end
  form.ani_unlock.Visible = false
end
function on_rbtn_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local mgr = nx_value("TaskManager")
  if not nx_is_valid(mgr) then
    return
  end
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  local index = nx_int(rbtn.DataSource)
  local data = mgr:GetYongyeTaskData(index)
  local count = table.getn(data)
  if count ~= data_count then
    return
  end
  if not nx_find_custom(rbtn, "status") then
    return
  end
  local status = nx_int(rbtn.status)
  if status == nx_int(BTN_STATUS_UNKNOW) then
    return
  elseif status == nx_int(BTN_STATUS_UNLOCK) then
    timer:UnRegister(nx_current(), "clear_select", form)
    timer:Register(1000, 1, nx_current(), "clear_select", form, -1, -1)
    if not show_confirm("ui_eternalnight_taskopen") then
      return
    end
    local cur_task = data[index_cur_task]
    send_task_msg(16, cur_task)
  elseif status == nx_int(BTN_STATUS_COMPLETED) or status == nx_int(BTN_STATUS_ACCEPTED) then
    hide_all_story(form)
    show_story(form, index)
  end
end
function on_server_msg(...)
  local form_main = util_get_form(FORM_MAIN, false)
  if not nx_is_valid(form_main) then
    return
  end
  local form = nx_execute(FORM_MAIN, "get_nf_sub_form", FORM_STORY)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(table.getn(arg)) < nx_int(3) then
    return
  end
  local change_type = nx_int(arg[1])
  local task_id = nx_int(arg[2])
  local index = nx_int(arg[3])
  local mgr = nx_value("TaskManager")
  if not nx_is_valid(mgr) then
    return
  end
  local data = mgr:GetYongyeTaskData(index)
  local count = table.getn(data)
  if count ~= data_count then
    return
  end
  if nx_int(change_type) == nx_int(TASK_CHANGED_ACCEPT) then
    form.ani_unlock.Visible = true
    form.ani_unlock.AnimationImage = data[index_unlock_ani]
    form.ani_unlock.Loop = false
    form.ani_unlock.PlayMode = 2
    form.ani_unlock:Play()
  end
  refresh_story(form)
end
function on_ani_unlock_animation_end(ani)
  if not nx_is_valid(ani) then
    return
  end
  ani.Visible = false
end
function open_form(...)
  nx_execute(FORM_MAIN, "open_nf_sub_form", index_story)
  local form = nx_execute(FORM_MAIN, "get_nf_sub_form", FORM_STORY)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(table.getn(arg)) < nx_int(1) then
    return
  end
  local ani = nx_string(arg[1])
  if ani == "" then
    return
  end
  local ani_ctrl = form:Find("ani_unlock")
  if not nx_is_valid(ani_ctrl) then
    return
  end
  ani_ctrl.Visible = true
  ani_ctrl.AnimationImage = ani
  ani_ctrl.Loop = false
  ani_ctrl.PlayMode = 2
  ani_ctrl:Play()
end
function hide_all_story(form)
  local mgr = nx_value("TaskManager")
  if not nx_is_valid(mgr) then
    return
  end
  local list = mgr:GetYongyeTaskCtrlIndexList()
  local count = table.getn(list)
  for i = 1, count do
    local index = list[i]
    local groupbox_story = form:Find(STROY_GROUPBOX)
    if not nx_is_valid(groupbox_story) then
      return
    end
    local mltbox_story = groupbox_story:Find(STROY_MLTBOX_PRE .. nx_string(index))
    if not nx_is_valid(mltbox_story) then
      return
    end
    mltbox_story.Visible = false
  end
end
function show_story(form, index)
  local groupbox_story = form:Find(STROY_GROUPBOX)
  if not nx_is_valid(groupbox_story) then
    return
  end
  local mltbox_story = groupbox_story:Find(STROY_MLTBOX_PRE .. nx_string(index))
  if not nx_is_valid(mltbox_story) then
    return
  end
  mltbox_story.Visible = true
end
function refresh_character(form)
  form.lbl_character.BackImage = ""
  local mgr = nx_value("TaskManager")
  if not nx_is_valid(mgr) then
    return
  end
  local info = mgr:GetYongyeCharacterPic()
  local count = table.getn(info)
  if nx_int(count) ~= nx_int(2) then
    return
  end
  local pic = info[1]
  local tips = info[2]
  if nx_string(pic) == nx_string("") then
    return
  end
  form.lbl_character.BackImage = nx_string(pic)
  form.lbl_character.DataSource = nx_string(tips)
end
function on_lbl_character_get_capture(lbl)
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local text_id = nx_string(lbl.DataSource)
  if nx_string(text_id) == "" then
    return
  end
  local x, y = gui:GetCursorPosition()
  local tips = nx_widestr(util_text(text_id))
  nx_execute("tips_game", "show_text_tip", tips, x, y, 0, form)
end
function on_lbl_character_lost_capture(lbl)
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function add_data_bind(form)
  local data_binder = nx_value("data_binder")
  if not nx_is_valid(data_binder) then
    return
  end
  data_binder:AddRolePropertyBind("YongyeCharacter1", "int", form, nx_current(), "refresh_character")
  data_binder:AddRolePropertyBind("YongyeCharacter2", "int", form, nx_current(), "refresh_character")
  data_binder:AddRolePropertyBind("YongyeCharacter3", "int", form, nx_current(), "refresh_character")
end
function del_data_bind(form)
  local data_binder = nx_value("data_binder")
  if not nx_is_valid(data_binder) then
    return
  end
  data_binder:DelRolePropertyBind("YongyeCharacter1", form)
  data_binder:DelRolePropertyBind("YongyeCharacter2", form)
  data_binder:DelRolePropertyBind("YongyeCharacter3", form)
end
function show_confirm(text_id)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return true
  end
  dialog.mltbox_info:Clear()
  dialog.mltbox_info.HtmlText = nx_widestr(util_text(text_id))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return false
  end
  return true
end
function clear_select(form)
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_1.Checked = true
end
