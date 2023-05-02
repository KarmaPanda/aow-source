require("util_functions")
require("form_stage_main\\form_task\\task_define")
function main_form_init(form)
  form.Fixed = true
  form.time_limit_list = nx_call("util_gui", "get_arraylist", "form_task_time_limit_task_time_limit")
  form.current_time = 0
  form.heartbeat_count = 1
  form.total_count = 0
  return 1
end
function on_main_form_open(form)
  reset_form_position(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("TaskTimeLimitRec", form, nx_current(), "on_time_limit_rec_change")
  end
  return 1
end
function on_main_form_close(form)
  form.time_limit_list:ClearChild()
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", form)
  nx_destroy(form.time_limit_list)
  nx_destroy(form)
end
function refresh_time_info(form, server_cur_time)
  form.current_time = server_cur_time
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_task\\form_task_time_limit", true)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", form)
  timer:Register(1, -1, nx_current(), "on_update_time", form, -1, -1)
  return 1
end
function on_update_time(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  if form.heartbeat_count == 1 then
    local timer = nx_value("timer_game")
    timer:UnRegister(nx_current(), "on_update_time", form)
    timer:Register(1000, -1, nx_current(), "on_update_time", form, -1, -1)
    form.heartbeat_count = 2
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local show_text = ""
  local cur_taskid = 0
  local cur_end_time = 0
  local cur_max_time = 0
  local cur_time_type = 1
  for i = 1, form.total_count do
    local time_limit_rec = form.time_limit_list:GetChild(nx_string(i))
    cur_taskid = time_limit_rec.id
    cur_time_type = time_limit_rec.type
    cur_end_time = time_limit_rec.end_time
    cur_max_time = cur_end_time - form.current_time
    local task_row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(cur_taskid))
    local tasktitleid = ""
    if 0 <= task_row then
      tasktitleid = client_player:QueryRecord("Task_Accepted", task_row, accept_rec_title)
    end
    local task_title = gui.TextManager:GetText(tasktitleid)
    local convoy_type = ""
    if cur_time_type == 1 then
      convoy_type = gui.TextManager:GetText("ui_shijianxianzhi")
    elseif cur_time_type == 2 then
      convoy_type = gui.TextManager:GetText("ui_yuandibaohu")
    elseif cur_time_type == 3 then
      convoy_type = gui.TextManager:GetText("ui_overprize")
    end
    show_text = nx_widestr(show_text) .. nx_widestr(" ") .. nx_widestr(convoy_type) .. nx_widestr("<a href=\"" .. "TASK_TITLE,") .. nx_widestr(cur_taskid) .. nx_widestr(">") .. nx_widestr(task_title) .. nx_widestr("</a>") .. nx_widestr(": ")
    local format_time = ""
    if 86400 <= cur_max_time then
      local day = nx_int(cur_max_time / 86400) + 1
      format_time = nx_string(day) .. nx_string(util_text("ui_day"))
    elseif 3600 <= cur_max_time then
      local hour = nx_int(cur_max_time / 3600)
      local min = nx_int(math.mod(cur_max_time, 3600) / 60)
      local sec = nx_int(math.mod(math.mod(cur_max_time, 3600), 60))
      format_time = string.format("%02d:%02d:%02d", nx_number(hour), nx_number(min), nx_number(sec))
    elseif 60 <= cur_max_time then
      local min = nx_int(cur_max_time / 60)
      local sec = nx_int(math.mod(cur_max_time, 60))
      format_time = string.format("%02d:%02d", nx_number(min), nx_number(sec))
    else
      local sec = nx_int(cur_max_time)
      format_time = string.format("00:%02d", nx_number(sec))
    end
    show_text = show_text .. nx_widestr(format_time) .. nx_widestr("<br>")
  end
  form.mltbox_task:Clear()
  local index = form.mltbox_task:AddHtmlText(nx_widestr(show_text), -1)
  form.mltbox_task:SetHtmlItemSelectable(nx_int(index), false)
  form.current_time = form.current_time + 1
  set_position(form)
end
function set_position(form)
  local height = form.mltbox_task:GetContentHeight()
  form.Height = height + 10
  form.mltbox_task.Height = height + 10
  reset_form_position(form)
end
function after_time_limit_rec_change(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    form:Close()
    return 0
  end
  local row_num = client_player:GetRecordRows("TaskTimeLimitRec")
  if row_num <= 0 then
    form:Close()
    return
  end
  form.total_count = row_num
  for i = 0, row_num - 1 do
    local task_id = client_player:QueryRecord("TaskTimeLimitRec", i, task_time_limit_id)
    local time_type = client_player:QueryRecord("TaskTimeLimitRec", i, task_time_limit_type)
    local end_time = client_player:QueryRecord("TaskTimeLimitRec", i, task_time_limit_end_time)
    local time_limit_rec = form.time_limit_list:CreateChild(nx_string(i + 1))
    time_limit_rec.id = task_id
    time_limit_rec.type = time_type
    time_limit_rec.end_time = end_time
  end
  return 0
end
function on_time_limit_rec_change(form, recordname, optype, row, clomn)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    if nx_is_valid(form) then
      form:Close()
    end
    return 0
  end
  after_time_limit_rec_change(form)
  return 0
end
function check_time(server_cur_time)
  local form = nx_value("form_stage_main\\form_task\\form_task_time_limit")
  if not nx_is_valid(form) then
    return
  end
  form.current_time = server_cur_time
end
function reset_form_position(form)
  local gui = nx_value("gui")
  form.AbsLeft = gui.Width * 8.9 / 10 - form.Width
  form.AbsTop = gui.Height * 29 / 100 - form.Height
end
