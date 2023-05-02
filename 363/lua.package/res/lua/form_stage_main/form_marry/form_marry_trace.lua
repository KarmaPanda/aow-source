require("form_stage_main\\form_marry\\form_marry_util")
local TVT_TYPE_MARRY = 32
function main_form_init(form)
  form.Fixed = false
  form.leave_time = 0
  form.flag = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 1
  end
  form.grid_flow:SetColAlign(0, "center")
  form.AbsLeft = gui.Width - form.Width - 20
  form.AbsTop = (gui.Height - form.Height) / 2
  nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "add_form", 1, TVT_TYPE_MARRY)
  return 1
end
function on_main_form_close(form)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "refresh_leave_time", form)
  nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "del_form", 1, TVT_TYPE_MARRY)
  nx_destroy(form)
end
function on_btn_colse_click(self)
  local form = self.ParentForm
  nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "check_cbtn_state", 1, TVT_TYPE_MARRY)
  form.Visible = false
end
function format_time(sec)
  local time = os.time({
    year = os.date("%Y"),
    month = os.date("%m"),
    day = os.date("%d"),
    hour = 0,
    sec = 0,
    min = 0
  })
  return os.date("%H:%M:%S", nx_number(time) + nx_number(sec))
end
function refresh_leave_time(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  if not nx_is_valid(form) then
    return 0
  end
  if not nx_find_custom(form, "leave_time") or not nx_find_custom(form, "flag") then
    return 0
  end
  form.leave_time = form.leave_time - 1
  if 0 >= form.leave_time then
    local timer = nx_value("timer_game")
    timer:UnRegister(nx_current(), "refresh_leave_time", form)
    form.lbl_leave_time.HtmlText = util_text("ui_marry_flow_finish")
    return 0
  end
  if form.flag == 1 then
    form.lbl_leave_time.HtmlText = gui.TextManager:GetFormatText("ui_marry_flow_leave_time", format_time(form.leave_time))
  else
    form.lbl_leave_time.HtmlText = gui.TextManager:GetFormatText("ui_marry_wait_leave_time", format_time(form.leave_time))
  end
  return 0
end
function show_data(rite, step, time, flag)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local form = util_get_form(FORM_MARRY_TRACE, false)
  local is_show = not nx_is_valid(form)
  if 0 > nx_number(step) then
    if nx_is_valid(form) then
      form:Close()
    end
    return 0
  end
  if not nx_is_valid(form) then
    form = util_get_form(FORM_MARRY_TRACE, true)
  end
  if not nx_is_valid(form) then
    return 0
  end
  local marry_rite_ini = nx_execute("util_functions", "get_ini", INI_FILE_MARRY_RITE)
  if not nx_is_valid(marry_rite_ini) then
    return 0
  end
  local index = marry_rite_ini:FindSectionIndex(nx_string(rite))
  if 0 > nx_number(index) then
    return 0
  end
  local flow_name = marry_rite_ini:ReadString(index, "RiteFlowNamePrefix", "")
  local flow_desc = marry_rite_ini:ReadString(index, "RiteFlowDescPrefix", "")
  local flow = marry_rite_ini:ReadString(index, "RiteFlow", "")
  form.grid_flow:ClearRow()
  local flow_tab = util_split_string(nx_string(flow), ",")
  for i = 1, table.getn(flow_tab) do
    if nx_number(flow_tab[i]) == 1 then
      local row = form.grid_flow:InsertRow(-1)
      form.grid_flow:SetGridText(row, 0, util_text(flow_name .. nx_string(i)))
      if i == nx_number(step) then
        form.grid_flow:SelectRow(row)
      end
    end
  end
  form.mltbox_info.HtmlText = util_text(flow_desc .. nx_string(step))
  form.leave_time = nx_number(time)
  form.flag = nx_number(flag)
  if form.flag == 1 then
    form.lbl_leave_time.HtmlText = gui.TextManager:GetFormatText("ui_marry_flow_leave_time", format_time(form.leave_time))
  else
    form.lbl_leave_time.HtmlText = gui.TextManager:GetFormatText("ui_marry_wait_leave_time", format_time(form.leave_time))
  end
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "refresh_leave_time", form)
  timer:Register(1000, -1, nx_current(), "refresh_leave_time", form, -1, -1)
  if is_show == true then
    util_show_form(FORM_MARRY_TRACE, true)
  end
end
