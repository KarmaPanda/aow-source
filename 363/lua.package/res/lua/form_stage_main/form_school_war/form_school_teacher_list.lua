require("util_gui")
require("util_functions")
require("define\\request_type")
require("define\\sysinfo_define")
require("form_stage_main\\form_school_war\\form_school_teacher_pupil_func")
local teacher_list
local last_request_time = 0
local REQUEST_INTERVAL_TIME = 5
local ID_NAME = 1
local ID_POWERLEVEL = 2
local ID_PUPILCOUNT = 3
local ID_CHUSHICOUNT = 4
local ID_TEACHERLEVEL = 5
local ID_COMMENT = 6
local ID_SHITU_TYPE = 7
local ID_SHITU_SEX = 8
local NGMAP_STR_TO_NUM = {}
local NGMAP_NUM_TO_STR = {}
function open_form()
  nx_execute("form_stage_main\\form_school_war\\form_school_msg_info", "open_school_form_and_show_sub_page", 7)
end
function refresh_form(form)
  form.btn_unregiste.Visible = false
  if is_in_teacher_list() then
    form.btn_unregiste.Visible = true
  end
  refresh_grid_list(form)
  local school_tprule_desc1 = util_text(school_tprule_desc[1])
  form.mltbox_1:Clear()
  form.mltbox_1:AddHtmlText(nx_widestr(school_tprule_desc1), nx_int(-1))
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  local school_id = client_player:QueryProp("School")
  form.mltbox_2:Clear()
  form.mltbox_3:Clear()
  if school_id ~= nil and school_id ~= 0 and nx_string(school_id) ~= "" then
    local school_tprule_desc2 = util_text(school_tprule_desc[2][school_id])
    form.mltbox_2:AddHtmlText(nx_widestr(school_tprule_desc2), nx_int(-1))
    local school_tprule_desc3 = util_text(school_tprule_desc[3])
    form.mltbox_3:AddHtmlText(nx_widestr(school_tprule_desc3), nx_int(-1))
  end
end
function refresh_grid_list(form)
  local grid = form.textgrid_list
  grid:BeginUpdate()
  grid:ClearRow()
  grid:ClearSelect()
  if teacher_list == nil or teacher_list == nx_widestr("") then
    grid:EndUpdate()
    return
  end
  local rows, cols, row
  local teacher_jm = form.cbtn_teacher_jm.Checked
  local teacher_2 = form.cbtn_teacher_2nei.Checked
  local teacher_3 = form.cbtn_teacher_3nei.Checked
  rows = util_split_wstring(teacher_list, ";")
  for i = 1, table.getn(rows) - 1 do
    row = rows[i]
    cols = util_split_wstring(row, ",")
    local continue = false
    if nx_int(2) == nx_int(cols[ID_SHITU_TYPE]) then
      if teacher_jm == false then
        continue = true
      end
    elseif teacher_2 == false and nx_number(cols[ID_TEACHERLEVEL]) == 2 then
      continue = true
    elseif teacher_3 == false and nx_number(cols[ID_TEACHERLEVEL]) == 3 then
      continue = true
    end
    if not continue then
      insert_row(grid, cols)
    end
  end
  grid:SortRowsByInt(3, true)
  grid:EndUpdate()
end
function insert_row(grid, clos)
  local row = grid.RowCount
  grid:InsertRow(row)
  local power_name = Get_PowerLevel_Name(nx_int(clos[ID_POWERLEVEL]))
  grid:SetGridText(row, 0, nx_widestr(clos[ID_NAME]))
  grid:SetGridText(row, 1, nx_widestr(power_name))
  local teacher_level = nx_number(clos[ID_TEACHERLEVEL])
  local shitu_type = nx_int(clos[ID_SHITU_TYPE])
  local sex = nx_int(clos[ID_SHITU_SEX])
  if nx_int(2) == nx_int(shitu_type) then
    grid:SetGridText(row, 2, nx_widestr(util_text("ui_shitu_jingmai_sx_" .. nx_string(sex))))
  else
    grid:SetGridText(row, 2, nx_widestr(util_text("ui_shitu_teacher_0" .. nx_string(teacher_level) .. "_" .. nx_string(sex))))
  end
  grid:SetGridText(row, 3, nx_widestr(clos[ID_CHUSHICOUNT]))
  grid:SetGridText(row, 4, nx_widestr(clos[ID_COMMENT]))
end
function is_in_teacher_list()
  if teacher_list == nil or teacher_list == nx_widestr("") then
    return false
  end
  local player = get_player()
  local name = player:QueryProp("Name")
  local rows, cols, row
  rows = util_split_wstring(teacher_list, ";")
  for i = 1, table.getn(rows) - 1 do
    row = rows[i]
    cols = util_split_wstring(row, ",")
    if nx_string(cols[ID_NAME]) == nx_string(name) then
      return true
    end
  end
  return false
end
function request_teacher_list()
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  local school_id = client_player:QueryProp("School")
  if school_id == nil or school_id == 0 or nx_string(school_id) == "" then
    local text = util_format_string("shitu_58")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, CENTERINFO_PERSONAL_NO)
    end
    return
  end
  local now_time = nx_function("ext_get_tickcount") / 1000
  if nx_number(last_request_time) == 0 or nx_number(now_time - last_request_time) >= nx_number(REQUEST_INTERVAL_TIME) then
    last_request_time = now_time
    nx_execute("custom_sender", "custom_teacher_pupil", 3)
  else
    open_form()
  end
end
function on_main_form_init(form)
  local gui = nx_value("gui")
  local str_2nei = nx_string(gui.TextManager:GetText(nx_string("ui_shitu_erneishixiong")))
  local str_3nei = nx_string(gui.TextManager:GetText(nx_string("ui_shitu_sanneishixiong")))
  NGMAP_STR_TO_NUM[str_2nei] = 2
  NGMAP_STR_TO_NUM[str_3nei] = 3
  NGMAP_NUM_TO_STR[2] = str_2nei
  NGMAP_NUM_TO_STR[3] = str_3nei
end
function on_main_form_open(self)
  self.btn_speak.Enabled = false
  self.btn_request.Enabled = false
  refresh_form(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_request_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid_list
  if grid.RowSelectIndex == -1 then
    return
  end
  local name = grid:GetGridText(grid.RowSelectIndex, 0)
  local teacher_level_string = grid:GetGridText(grid.RowSelectIndex, 2)
  local teacher_level_number = NGMAP_STR_TO_NUM[nx_string(teacher_level_string)]
  nx_execute("form_stage_main\\form_school_war\\form_school_teacher_request", "custom_request_teacher_pupil", 1, nx_widestr(name))
end
function on_btn_speak_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid_list
  if grid.RowSelectIndex == -1 then
    return
  end
  local name = grid:GetGridText(grid.RowSelectIndex, 0)
  nx_execute("custom_sender", "custom_request_chat", nx_widestr(name))
end
function on_btn_unregiste_click(btn)
  local player = get_player()
  local name = player:QueryProp("Name")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog:ShowModal()
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(nx_widestr(util_text("ui_shitu_tishi")), -1)
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_teacher_pupil", 2, nx_widestr(name))
  end
end
function on_cbtn_teacher_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  refresh_grid_list(form)
end
function on_textgrid_list_select_grid(grid)
  local form = grid.ParentForm
  if nx_is_valid(form) then
    form.btn_speak.Enabled = true
    form.btn_request.Enabled = true
  end
end
function on_server_msg(...)
  open_form()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  teacher_list = nx_widestr(arg[1])
  refresh_form(form)
end
