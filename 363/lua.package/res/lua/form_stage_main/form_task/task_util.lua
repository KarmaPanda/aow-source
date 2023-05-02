require("util_gui")
require("util_functions")
require("form_stage_main\\form_task\\task_define")
local accept_rec = "Task_Accepted"
local task_rec = "Task_Record"
local type_collect, type_hunter, type_usetool, type_mult_interact = 2, 1, 7, 3
g_prize = {}
local g_drop_photo = "icon\\prop\\prop026.png"
local g_drop_desc = ""
function is_show_task_proc(task_type, min, max)
  if task_type == type_collect or task_type == type_hunter or task_type == type_usetool or task_type == type_mult_interact or 1 < max then
    return true
  end
  return false
end
function get_task_complete_state(task_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local row = client_player:FindRecordRow(accept_rec, 0, nx_int(task_id), 0)
  if row < 0 then
    return 0
  end
  local title_text = client_player:QueryRecord(accept_rec, row, 5)
  local flag = client_player:QueryRecord(accept_rec, row, 6)
  local split_flag_finished = string.find(title_text, "%(@0%)")
  local split_flag_failed = string.find(title_text, "%(@1%)")
  if nil ~= split_flag_finished and flag == 0 then
    return 1
  end
  if nil ~= split_flag_failed and flag == 1 then
    return 2
  end
  return 0
end
function get_task_proc(task_id)
  local str = nx_string("")
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return str
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return str
  end
  local show_row = client_player:FindRecordRow(task_rec, 0, nx_int(task_id), 0)
  if show_row < 0 then
    return str
  else
    local rows = client_player:GetRecordRows(task_rec)
    for row = 0, rows - 1 do
      local find_taskid = client_player:QueryRecord(task_rec, row, task_rec_id)
      local state_flag = get_task_complete_state(task_id)
      if nx_number(task_id) == nx_number(find_taskid) then
        local task_done_num = client_player:QueryRecord(task_rec, row, task_rec_curnum)
        local task_need_num = client_player:QueryRecord(task_rec, row, task_rec_maxnum)
        local task_obj_name = client_player:QueryRecord(task_rec, row, task_rec_trackinfo)
        local task_obj_show = gui.TextManager:GetText(task_obj_name)
        local task_type = client_player:QueryRecord(task_rec, row, task_rec_subtype)
        if is_show_task_proc(task_type, task_done_num, task_need_num) then
          if state_flag == 2 then
            str = nx_widestr(str) .. nx_widestr(task_obj_show) .. nx_widestr(" : ") .. nx_widestr(task_done_num) .. nx_widestr(" / ") .. nx_widestr(task_need_num) .. nx_widestr(util_text("ui_SpaceFailed")) .. nx_widestr("<br>")
          elseif task_done_num == task_need_num and state_flag == 1 then
            str = nx_widestr(str) .. nx_widestr(task_obj_show) .. nx_widestr(" : ") .. nx_widestr(task_done_num) .. nx_widestr(" / ") .. nx_widestr(task_need_num) .. nx_widestr(util_text("ui_SpaceFinished")) .. nx_widestr("<br>")
          else
            str = str .. nx_string(task_obj_show) .. " : " .. nx_string(task_done_num) .. " / " .. nx_string(task_need_num) .. "<br>"
          end
        elseif state_flag == 2 then
          str = nx_widestr(str) .. nx_widestr(task_obj_show) .. nx_widestr(util_text("ui_SpaceFailed")) .. nx_widestr("<br>")
        elseif task_done_num == task_need_num and state_flag == 1 then
          str = nx_widestr(str) .. nx_widestr(task_obj_show) .. nx_widestr(util_text("ui_SpaceFinished")) .. nx_widestr("<br>")
        else
          str = str .. nx_string(task_obj_show) .. "<br>"
        end
      end
    end
  end
  return str
end
function get_task_type(id)
  local line, tp = 0, 0
  return line, tp
end
function show_talk_form(npc)
  local gui = nx_value("gui")
  local form_talk = nx_value("form_stage_main\\form_talk")
  if nx_is_valid(form_talk) then
    nx_execute("form_stage_main\\form_talk", "clear_data")
    nx_execute("form_stage_main\\form_talk", "clear_control")
  else
    form_talk = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_talk", true)
  end
  form_talk.talk_list:Clear()
  form_talk.taskid = task_id
  form_talk.npcid = nx_string(npc)
  local game_client = nx_value("game_client")
  if not nx_is_valid(form_talk) then
    return
  end
  local client_scene_obj = game_client:GetSceneObj(nx_string(npc))
  if nx_is_valid(client_scene_obj) then
    local string_id = client_scene_obj:QueryProp("ConfigID")
    local npc_name = gui.TextManager:GetText(nx_string(string_id))
    form_talk.name_label.Text = npc_name
    local photo_head = tostring(client_scene_obj:QueryProp("Photo"))
    if photo_head ~= "" then
      local str_const = "_large."
      local str_lst = nx_function("ext_split_string", nx_string(photo_head), ".")
      if table.getn(str_lst) >= 2 then
        local str_temp = str_lst[1]
        form_talk.lhbodynpc.BackImage = str_lst[1] .. str_const .. str_lst[2]
      end
    end
  end
  if not form_talk.Visible then
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_talk", true)
  end
  return form_talk
end
function get_title_task_context(context_id)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  local name = player_client:QueryProp("Name")
  local sex = player_client:QueryProp("Sex")
  if tonumber(sex) == 1 then
    sex = ""
  else
    sex = ""
  end
  gui.TextManager:Format_SetIDName(nx_string(context_id))
  gui.TextManager:Format_AddParam(name)
  return gui.TextManager:Format_GetText()
end
