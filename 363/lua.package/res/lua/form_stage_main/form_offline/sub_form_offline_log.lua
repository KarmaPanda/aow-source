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
function show_window(form, date, type)
  if init_log(form, date, type) then
    return true
  end
  return false
end
function update_controls(form)
  form.groupscrollbox_log.IsEditMode = true
  local height_date = form.mltbox_date:GetContentHeight()
  form.mltbox_date.Height = height_date
  form.mltbox_date.ViewRect = "0,0,70," .. nx_string(height_date)
  local height_log = form.mltbox_log:GetContentHeight()
  form.mltbox_log.Height = height_log
  form.mltbox_log.ViewRect = "0,0,350," .. nx_string(height_log)
  form.groupscrollbox_log.IsEditMode = false
  form.groupscrollbox_log.HasVScroll = true
  form.groupscrollbox_log.VScrollBar.Value = 0
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
  return -1
end
function format_desc_text(text, name, para)
end
function on_mltbox_log_right_click_hyperlink(mltbox, linkitem, linkdata)
  local form = mltbox.ParentForm
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "offline_log_name", "offline_log_name")
  nx_execute("menu_game", "menu_recompose", menu_game)
  form.TargetName = nx_widestr(linkdata)
  local x, y = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, x, y)
end
function format_date_text(text)
  local len = string.len(text)
  if nx_number(len) ~= 11 then
    return text
  end
  text = string.sub(nx_string(text), 6, 11)
  local hasMonth = string.find(nx_string(text), "M")
  if hasMonth ~= nil then
    text = string.gsub(nx_string(text), "M", nx_string(util_text("ui_g_month")))
  end
  local hasDay = string.find(nx_string(text), "D")
  if hasDay ~= nil then
    text = string.gsub(nx_string(text), "D", nx_string(util_text("ui_g_day")))
  end
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
function init_log(form, date, type)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local offmgr = nx_value("OffLineJobManager")
  if not nx_is_valid(offmgr) then
    return false
  end
  if not client_player:FindRecord("OffLineInteract_Log") then
    return false
  end
  local rows = client_player:GetRecordRows("OffLineInteract_Log")
  if nx_number(rows) <= 0 then
    return false
  end
  form.mltbox_date.Visible = false
  form.mltbox_log.Visible = false
  form.mltbox_date:Clear()
  form.mltbox_log:Clear()
  form.btn_quit.Visible = false
  form.btn_setfree.Visible = false
  local total_day = 0
  for i = rows - 1, 0, -1 do
    local dt = client_player:QueryRecord("OffLineInteract_Log", i, REC_INTERACT_LOG_DATE)
    local id = client_player:QueryRecord("OffLineInteract_Log", i, REC_INTERACT_LOG_ID)
    local text = client_player:QueryRecord("OffLineInteract_Log", i, REC_INTERACT_LOG_TEXT_ID)
    local name = client_player:QueryRecord("OffLineInteract_Log", i, REC_INTERACT_LOG_NAME)
    local para = client_player:QueryRecord("OffLineInteract_Log", i, REC_INTERACT_LOG_PARA_LIST)
    local str_dt = nx_function("format_date_time", nx_double(dt))
    local table_dt = util_split_string(str_dt, ";")
    if table.getn(table_dt) == 2 then
      local format_date = format_date_text(table_dt[1])
      local format_time = format_time_text(table_dt[2])
      local format_desc = format_desc_text(util_text(text), name, para)
      local height_desc = form.mltbox_log:GetContentHeight()
      local height_time = form.mltbox_date:GetContentHeight()
      if nx_number(height_desc) ~= nx_number(height_time) then
        local sub_height = nx_number(height_desc) - nx_number(height_time)
        local line_height = form.mltbox_log.LineHeight
        local fill_row = nx_int(nx_number(sub_height) / nx_number(line_height))
        if nx_number(fill_row) > 0 then
          for i = 1, nx_number(fill_row) do
            form.mltbox_date:AddHtmlText(nx_widestr("<s>"), nx_int(-1))
          end
        end
      end
      form.mltbox_date:AddHtmlText(nx_widestr(format_date .. " " .. format_time), nx_int(-1))
      form.mltbox_log:AddHtmlText(nx_widestr(format_desc), nx_int(-1))
      total_day = total_day + 1
      if nx_number(total_day) > 30 then
        break
      end
    end
  end
  if nx_number(type) == 0 then
    form.btn_quit.Visible = true
  end
  if client_player:FindProp("IsAbducted") and nx_number(client_player:QueryProp("IsAbducted")) > nx_number(0) then
    form.btn_setfree.Visible = true
  end
  local left_base = 382
  if form.btn_quit.Visible then
    left_base = left_base - 90
  end
  if form.btn_setfree.Visible then
  end
  if nx_number(total_day) > 0 then
    form.mltbox_date.Visible = true
    form.mltbox_log.Visible = true
    update_controls(form)
    return true
  end
  return false
end
function on_btn_setfree_click(btn)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local money = nx_execute("form_stage_main\\form_offline\\offline_util", "get_setfree_money_by_level", client_player)
  local text_money = nx_execute("util_functions", "trans_capital_string", nx_int64(money))
  gui.TextManager:Format_SetIDName(nx_string("desc_can_set_free_self"))
  gui.TextManager:Format_AddParam(nx_string(text_money))
  local text = gui.TextManager:Format_GetText()
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_offline_setfree", nx_int(0))
    close_form_offline()
  end
end
function close_form_offline()
  local form_offline = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\form_offline", true, false)
  nx_execute("form_stage_main\\form_offline\\form_offline", "on_btn_close_click", form_offline.btn_close)
end
function on_btn_return_click(btn)
  nx_execute("form_stage_main\\form_offline\\form_offline", "show_main")
end
