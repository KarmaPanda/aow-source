require("util_functions")
require("util_gui")
local DAILY_LP_REC = "DailyLPRec"
local LP_TYPE_NOT_DEFINE = 0
local LP_TYPE_KILL_MONSTER = 1
local LP_TYPE_KILL_BOSS = 2
local LP_TYPE_TIGUAN = 3
local LP_TYPE_CLONE_SCENE = 4
local LP_TYPE_TASK = 5
local LP_TYPE_GATHER = 6
local LP_TYPE_COMPOSE = 7
local LP_TYPE_PLAYER_QIECUO = 8
local LP_TYPE_MAX = 9
local TIME_TYPE_DAILY = 1
local TIME_TYPE_WEEK = 2
local TIME_TYPE_MONTH = 3
local page_row_count = 10
local week_days = {
  "daily_sun",
  "daily_mon",
  "daily_tue",
  "daily_wen",
  "daily_thu",
  "daily_fri",
  "daily_sat"
}
function log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function open_form()
  util_auto_show_hide_form(nx_current())
end
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  init_describe_info()
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.lbl_name.Text = gui.TextManager:GetText("ui_daily")
  form.lbl_mouse_in.Visible = false
  form.last_select_index = -1
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind(DAILY_LP_REC, form, nx_current(), "on_record_changed")
  end
  refresh_table_contont(form)
  nx_execute("util_gui", "ui_show_attached_form", form)
  return 1
end
function on_main_form_close(form)
  ui_destroy_attached_form(form)
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_daily_live_point", nx_null())
  return 1
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
  return 1
end
function on_record_changed(form, recordname, optype, row, clomn)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindRecord(DAILY_LP_REC) then
    return 0
  end
  refresh_table_contont(form)
  if optype == "add" then
    return 0
  end
  if optype == "update" then
    return 0
  end
  if optype == "del" then
    return 0
  end
  if optype == "clear" then
    return 0
  end
  return 0
end
function clear_all_pbar(form)
  for i = 1, page_row_count do
    local control = form.gb_pbar:Find("pbar_" .. nx_string(i))
    if nx_is_valid(control) then
      control.Visible = false
    end
  end
end
function set_pbar_value(form, index, value, maximum)
  local control = form.gb_pbar:Find("pbar_" .. nx_string(index))
  if nx_is_valid(control) then
    control.Visible = true
    control.Maximum = maximum
    control.Value = value
  end
end
function refresh_table_contont(form)
  local gui = nx_value("gui")
  local dailylp_manager = nx_value("DailyLPManager")
  if not nx_is_valid(dailylp_manager) then
    return 0
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindRecord(DAILY_LP_REC) then
    return 0
  end
  clear_all_pbar(form)
  form.textgrid_unit:ClearRow()
  form.textgrid_unit.HeaderRowHeight = 31
  local rows = client_player:GetRecordRows(DAILY_LP_REC)
  for i = 1, rows do
    local unit_type = client_player:QueryRecord(DAILY_LP_REC, i - 1, 0)
    local unit_id = client_player:QueryRecord(DAILY_LP_REC, i - 1, 1)
    if unit_type > LP_TYPE_NOT_DEFINE and unit_type < LP_TYPE_MAX and unit_type ~= 2 and unit_type ~= 8 and 0 < unit_id then
      local desc = "daily_lp_type_desc_" .. nx_string(unit_type)
      local desc_text = gui.TextManager:GetText(desc)
      local prize_count = nx_int(dailylp_manager:GetPrizeValue(unit_id) / 1000)
      local time_str = ""
      local time_paras = dailylp_manager:GetTimeParas(unit_type)
      local time_table = os.date("*t", os.time())
      if time_paras ~= nil then
        time_type = time_paras[1]
        if time_type == TIME_TYPE_DAILY then
          local hour = time_paras[2]
          local min = 0
          time_str = nx_widestr(time_str) .. nx_widestr(hour) .. nx_widestr(":00")
        elseif time_type == TIME_TYPE_WEEK then
          local week_day = time_paras[2]
          time_str = nx_widestr(time_str) .. nx_widestr(util_text(week_days[week_day]))
        elseif time_type == TIME_TYPE_MONTH then
          local month = time_table.month
          local day = time_paras[2]
          local hour = time_paras[3]
          if time_table.day == day then
            if time_table.hour * 3600 + time_table.min * 60 + time_table.sec > hour * 3600 then
              month = month + 1
            end
          elseif day < time_table.day then
            month = month + 1
          end
          gui.TextManager:Format_SetIDName("daily_date")
          gui.TextManager:Format_AddParam(nx_widestr(month))
          gui.TextManager:Format_AddParam(nx_widestr(day))
          local text = gui.TextManager:Format_GetText()
          time_str = nx_widestr(time_str) .. nx_widestr(text)
        end
      end
      local row = form.textgrid_unit:InsertRow(-1)
      form.textgrid_unit:SetGridText(row, 0, nx_widestr(" ") .. nx_widestr(desc_text))
      form.textgrid_unit:SetColAlign(0, "left")
      form.textgrid_unit:SetGridText(row, 1, nx_widestr(prize_count))
      form.textgrid_unit:SetGridText(row, 2, nx_widestr(time_str))
      form.textgrid_unit:SetRowTitle(row, nx_widestr(unit_id))
      local value = client_player:QueryRecord(DAILY_LP_REC, i - 1, 2)
      local max_value = client_player:QueryRecord(DAILY_LP_REC, i - 1, 3)
      set_pbar_value(form, row + 1, value, max_value)
    end
  end
end
function on_textgrid_unit_vscroll_changed(self)
  local form = nx_value(nx_current())
  clear_all_pbar(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local rows = client_player:GetRecordRows(DAILY_LP_REC)
  for i = self.VScrollBar.Value, self.VScrollBar.Value + page_row_count do
    if i >= rows then
      return
    end
    local value = client_player:QueryRecord(DAILY_LP_REC, i, 2)
    local max_value = client_player:QueryRecord(DAILY_LP_REC, i, 3)
    set_pbar_value(form, i - self.VScrollBar.Value + 1, value, max_value)
  end
end
function on_textgrid_unit_mousein_row_changed(grid, row)
  local gui = nx_value("gui")
  local dailylp_manager = nx_value("DailyLPManager")
  if not dailylp_manager then
    return 0
  end
  local unit_id = nx_int(grid:GetRowTitle(row))
  local form = grid.ParentForm
  log(nx_string(row))
  if row ~= -1 then
    form.lbl_mouse_in.Visible = true
    form.lbl_mouse_in.Left = form.textgrid_unit.Left
    form.lbl_mouse_in.Top = form.textgrid_unit.Top + form.textgrid_unit.HeaderRowHeight + row * form.textgrid_unit.RowHeight
  else
    form.lbl_mouse_in.Visible = false
  end
  if 0 <= grid.RowSelectIndex then
    return
  end
  form.lbl_2.Text = nx_widestr(grid:GetGridText(row, 0))
  local mltbox = form.mltbox_info
  mltbox:Clear()
  local desc = dailylp_manager:GetUnitDesc(unit_id)
  if nx_number(unit_id) ~= 0 then
    local text = nx_widestr(util_text("ui_daily_desc")) .. nx_widestr(":") .. nx_widestr("<br>") .. nx_widestr(util_text(desc))
    mltbox:AddHtmlText(text, -1)
    mltbox:AddHtmlText(nx_widestr("<br>"), -1)
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    if not client_player:FindRecord(DAILY_LP_REC) then
      return 0
    end
    local unit_type = client_player:QueryRecord(DAILY_LP_REC, row, 0)
    local str_desc_list = dailylp_manager:GetRecommentSceneList(unit_id)
    local count = table.getn(str_desc_list)
    if 0 < count then
      local html = nx_widestr("")
      for i = 1, count do
        html = nx_widestr(util_text(str_desc_list[i])) .. nx_widestr(" ") .. nx_widestr(html)
      end
      html = nx_widestr(util_text("ui_daily_advice")) .. nx_widestr(":") .. nx_widestr("<br>") .. nx_widestr(html)
    end
  end
  if row == -1 then
    init_describe_info()
  end
end
function on_textgrid_unit_select_grid(grid)
  local row = grid.RowSelectIndex
  if row < 0 then
    return
  end
  local form = grid.ParentForm
  if row ~= form.last_select_index then
    form.last_select_index = row
  end
  form.lbl_mouse_in.Visible = false
  form.lbl_2.Text = nx_widestr(grid:GetGridText(row, 0))
  local mltbox = form.mltbox_info
  mltbox:Clear()
  local unit_id = nx_int(grid:GetRowTitle(row))
  local dailylp_manager = nx_value("DailyLPManager")
  if not nx_is_valid(dailylp_manager) then
    return 0
  end
  create_select_list_icon(form, row)
  local desc = dailylp_manager:GetUnitDesc(unit_id)
  mltbox:AddHtmlText(nx_widestr(util_text("ui_daily_desc")) .. nx_widestr(":") .. nx_widestr("<br>") .. nx_widestr(util_text(desc)), -1)
  mltbox:AddHtmlText(nx_widestr("<br>"), -1)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not client_player:FindRecord(DAILY_LP_REC) then
    return 0
  end
  local unit_type = client_player:QueryRecord(DAILY_LP_REC, row, 0)
  local str_desc_list = dailylp_manager:GetRecommentSceneList(unit_id)
  local count = table.getn(str_desc_list)
  if 0 < count then
    local html = nx_widestr("")
    for i = 1, count do
      html = nx_widestr(util_text(str_desc_list[i])) .. nx_widestr(" ") .. nx_widestr(html)
    end
    html = nx_widestr(util_text("ui_daily_advice")) .. nx_widestr(":") .. nx_widestr("<br>") .. nx_widestr(html)
  end
end
function create_select_list_icon(form, row)
  local get_lable = form:Find("lbl_seclect_list")
  if not nx_is_valid(get_lable) then
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    local label = gui:Create("Label")
    label.Text = nx_widestr("")
    label.Name = "lbl_seclect_list"
    label.BackImage = "gui\\special\\sns\\icon_talk_right.png"
    label.Visible = true
    label.Width = 13
    label.Height = 18
    label.Left = form.lbl_bg_list.Left + form.lbl_bg_list.Width
    label.Top = form.textgrid_unit.Top + form.textgrid_unit.HeaderRowHeight + row * form.textgrid_unit.RowHeight + 5
    form:Add(label)
  else
    get_lable.Left = form.lbl_bg_list.Left + form.lbl_bg_list.Width
    get_lable.Top = form.textgrid_unit.Top + form.textgrid_unit.HeaderRowHeight + row * form.textgrid_unit.RowHeight + 5
    get_lable.Visible = true
  end
end
function init_describe_info()
  local form = nx_value(nx_current())
  form.lbl_2.Text = nx_widestr(util_text("daily_title"))
  local mltbox = form.mltbox_info
  mltbox:Clear()
  mltbox:AddHtmlText(nx_widestr(util_text("ui_daily_desc")) .. nx_widestr(":") .. nx_widestr("<br>") .. nx_widestr(util_text("daily_intro")), -1)
  mltbox:AddHtmlText(nx_widestr("<br>"), -1)
end
function on_textgrid_unit_right_click(grid)
  local row = grid.RowSelectIndex
  if row == -1 then
    return
  end
  local form = grid.ParentForm
  grid:ClearSelect()
  form.last_select_index = -1
  form.lbl_mouse_in.Visible = false
  local get_lable = form:Find("lbl_seclect_list")
  if nx_is_valid(get_lable) then
    get_lable.Visible = false
  end
  init_describe_info()
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
