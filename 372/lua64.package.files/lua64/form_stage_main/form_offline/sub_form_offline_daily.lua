require("util_gui")
require("util_functions")
require("custom_sender")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("form_stage_main\\form_offline\\offline_define")
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  form.Visible = true
  return 1
end
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
  return 1
end
function on_btn_quit_click(btn)
  nx_execute("main", "wait_exit_game")
end
function show_window(date)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\form_offline_job_daily", true, false)
  if init_form(form, date) then
    return true
  end
  return false
end
function on_btn_get_prize_click(btn)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_GET_DAILY_PRIZE))
  end
end
function init_form(form, date, show_type)
  local gui = nx_value("gui")
  local offmgr = nx_value("OffLineJobManager")
  if not nx_is_valid(offmgr) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if not client_player:FindRecord("OffLineJob_Log") then
    return false
  end
  form.mltbox_daily_desc:Clear()
  form.groupbox_prize.Visible = false
  form.lbl_line.Visible = false
  form.btn_get_prize.Visible = false
  form.btn_quit.Visible = false
  local log_row = get_job_row(date)
  if nx_number(log_row) < 0 then
    return false
  end
  local off_id = client_player:QueryRecord("OffLineJob_Log", log_row, REC_LOG_ID)
  local area = offmgr:GetOffLineJobProp(off_id, "WorkArea")
  local str_date = nx_function("format_date_time", nx_double(date))
  local table_dt = util_split_string(str_date, ";")
  if table.getn(table_dt) ~= 2 then
    return false
  end
  local format_date = format_date_text(table_dt[1])
  form.lbl_work.Text = nx_widestr(format_date) .. nx_widestr(" ") .. nx_widestr(util_text(area)) .. nx_widestr(" ") .. nx_widestr(util_text(off_id))
  local type, name = get_convert_type(client_player, date)
  if nx_number(type) == 5 then
    local desc_change_scene = client_player:QueryRecord("OffLineJob_Log", log_row, REC_LOG_DESC_CHANGE_SCENE)
    if nx_string(desc_change_scene) ~= "" then
      form.mltbox_daily_desc:AddHtmlText(nx_widestr("  ") .. nx_widestr(util_text(desc_change_scene)), -1)
    end
  end
  if nx_number(type) == 3 then
    gui.TextManager:Format_SetIDName("event_covert_desc_sale_2")
    gui.TextManager:Format_AddParam(nx_string(name))
    local desc_full = nx_string(gui.TextManager:Format_GetText())
    form.mltbox_daily_desc:AddHtmlText(nx_widestr("  ") .. nx_widestr(desc_full), -1)
  elseif nx_number(type) == 4 then
    gui.TextManager:Format_SetIDName("event_covert_desc_buy_2")
    gui.TextManager:Format_AddParam(nx_string(name))
    local desc_full = nx_string(gui.TextManager:Format_GetText())
    form.mltbox_daily_desc:AddHtmlText(nx_widestr("  ") .. nx_widestr(desc_full), -1)
  end
  if nx_number(type) > 0 then
    local desc_change_job = client_player:QueryRecord("OffLineJob_Log", log_row, REC_LOG_DESC_CHANGE)
    if nx_string(desc_change_job) ~= "" then
      form.mltbox_daily_desc:AddHtmlText(nx_widestr("  ") .. nx_widestr(util_text(desc_change_job)), -1)
    end
  end
  local desc_daily = client_player:QueryRecord("OffLineJob_Log", log_row, REC_LOG_DESC_DESC_DAILY)
  if nx_string(desc_daily) ~= "" then
    form.mltbox_daily_desc:AddHtmlText(nx_widestr("  ") .. nx_widestr(util_text(desc_daily)), -1)
  end
  local prize_info_daily = ""
  local row = client_player:FindRecordRow("OffLineJob_Log", REC_LOG_DAILY_PRIZE_DATE, nx_double(date), 0)
  if 0 <= row then
    prize_info_daily = client_player:QueryRecord("OffLineJob_Log", row, REC_LOG_DAILY_PRIZE)
  end
  if nx_string(prize_info_daily) ~= "" and nx_number(prize_info_daily) ~= 0 then
    form.lbl_num_money.Text = nx_execute("util_functions", "trans_capital_string", nx_int64(prize_info_daily))
    form.groupbox_prize.Visible = true
    form.lbl_line.Visible = true
    form.btn_get_prize.Visible = true
  end
  if nx_number(show_type) == 0 then
    form.btn_quit.Visible = true
  end
  local left_base = 382
  if form.btn_quit.Visible then
    left_base = left_base - 90
  end
  if form.btn_get_prize.Visible then
  end
  return true
end
function get_convert_type(client_player, date)
  local offmgr = nx_value("OffLineJobManager")
  if not nx_is_valid(offmgr) then
    return -1
  end
  local log_row = get_job_row(date)
  if nx_number(log_row) < 0 then
    return -1
  end
  local IsFirstJob = false
  if 0 < nx_number(get_job_row(date - 1)) then
    IsFirstJob = true
  end
  local IsFirstDay = false
  local begin_date = client_player:QueryRecord("OffLineJob_Log", log_row, REC_LOG_DATE_START)
  if nx_number(begin_date) == nx_number(date) then
    IsFirstDay = true
  end
  local off_id = client_player:QueryRecord("OffLineJob_Log", log_row, REC_LOG_ID)
  local scene_id = offmgr:GetOffLineJobProp(off_id, "SceneID")
  local freedom = offmgr:GetOffLineJobProp(off_id, "IsFreedom")
  local convert_date = client_player:QueryRecord("OffLineJob_Log", log_row, REC_LOG_TASK_COVERT_DATE)
  local convert_name = client_player:QueryRecord("OffLineJob_Log", log_row, REC_LOG_TASK_CONVERT_PLAYER)
  if nx_number(convert_date) == nx_number(date) then
    if nx_number(freedom) == 0 then
      return 1, convert_name
    elseif nx_number(freedom) == 1 then
      return 2, convert_name
    end
  end
  if not IsFirstJob and IsFirstDay then
    local convert_date = client_player:QueryRecord("OffLineJob_Log", log_row - 1, REC_LOG_TASK_COVERT_DATE)
    local convert_name = client_player:QueryRecord("OffLineJob_Log", log_row - 1, REC_LOG_TASK_CONVERT_PLAYER)
    if nx_number(convert_date) == nx_number(date - 1) then
      if nx_number(freedom) == 0 then
        return 4, convert_name
      elseif nx_number(freedom) == 1 then
        return 3, convert_name
      end
    end
    local off_id = client_player:QueryRecord("OffLineJob_Log", log_row - 1, REC_LOG_ID)
    local last_scene_id = offmgr:GetOffLineJobProp(off_id, "SceneID")
    if nx_number(scene_id) ~= nx_number(last_scene_id) then
      return 5
    end
  end
  if IsFirstDay then
    return 0
  end
  return -1
end
function get_job_row(date)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return -1
  end
  if not client_player:FindRecord("OffLineJob_Log") then
    return -1
  end
  local rows = client_player:GetRecordRows("OffLineJob_Log")
  if 0 < rows then
    for i = 0, rows - 1 do
      local begin_date = client_player:QueryRecord("OffLineJob_Log", i, REC_LOG_DATE_START)
      local end_date = client_player:QueryRecord("OffLineJob_Log", i, REC_LOG_DATE_END)
      if nx_number(date) >= nx_number(begin_date) and nx_number(date) <= nx_number(end_date) then
        return i
      end
    end
  end
  if nx_number(rows) == nx_number(1) then
    return 0
  end
  return -1
end
function set_offlinejob_effect(visual_scene_obj)
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_ident = game_visual:QueryRoleClientIdent(visual_scene_obj)
  local client_scene_obj = game_client:GetSceneObj(client_ident)
  if not nx_is_valid(client_scene_obj) then
    return
  end
  if client_scene_obj:FindProp("AIEffect") and client_scene_obj:FindProp("LogicState") then
    local cur_effect = client_scene_obj:QueryProp("AIEffect")
    local logic_state = client_scene_obj:QueryProp("LogicState")
    if string.len(cur_effect) > 0 and nx_number(logic_state) == 106 then
      nx_execute("scene_obj_prop", "auto_show_hide_effect", client_scene_obj, cur_effect, true)
      visual_scene_obj.effect_name = cur_effect
    end
  end
end
function format_desc_text(text, name, para)
  local hasName = string.find(nx_string(text), "{@name}")
  if hasName ~= nil then
    text = string.gsub(nx_string(text), "{@name}", nx_string(name))
  end
  local table_para = util_split_string(para, ";")
  local para_num = table.getn(table_para)
  if 0 < para_num then
    for i = 1, para_num do
      local keyword = "{@para" .. nx_string(i) .. "}"
      local hasName = string.find(nx_string(text), nx_string(keyword))
      if hasName ~= nil then
        text = string.gsub(nx_string(text), nx_string(keyword), nx_string(util_text(table_para[i])))
      end
    end
  end
  return text
end
function format_date_text(text)
  local len = string.len(text)
  if nx_number(len) ~= 11 then
    return text
  end
  text = string.sub(nx_string(text), 6, 11)
  local month = string.sub(nx_string(text), 1, 2)
  local day = string.sub(nx_string(text), 4, 5)
  text = nx_widestr(month) .. nx_widestr(util_text("ui_g_month")) .. nx_widestr(day) .. nx_widestr(util_text("ui_g_day"))
  return text
end
function format_time_text(text)
  local len = string.len(text)
  if nx_number(len) ~= 8 then
    return text
  end
  local format_time = string.sub(nx_string(text), 1, 5)
  return format_time
end
function on_btn_return_click(btn)
  nx_execute("form_stage_main\\form_offline\\form_offline", "show_main")
end
