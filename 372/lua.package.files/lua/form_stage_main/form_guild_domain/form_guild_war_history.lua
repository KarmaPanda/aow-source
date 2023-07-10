require("util_gui")
require("share\\client_custom_define")
require("share\\client_custom_define")
require("util_functions")
require("define\\sysinfo_define")
require("share\\itemtype_define")
require("util_static_data")
local FORM_GUILD_WAR_HISTORY = "form_stage_main\\form_guild_domain\\form_guild_war_history"
local PAGE_COUNT = 10
local ST_FUNCTION_NEW_GUILDWAR = 219
function main_form_init(form)
  form.Fixed = false
  form.page_index = 1
  form.max_index = 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.max_count = get_max_info()
  form.textgrid_war_history:SetColTitle(0, nx_widestr(util_text("ui_dr_col_name_2")))
  form.textgrid_war_history:SetColTitle(1, nx_widestr(util_text("ui_dr_col_name_0")))
  form.textgrid_war_history:SetColTitle(2, nx_widestr(util_text("ui_dr_col_name_1")))
  form.textgrid_war_history:SetColTitle(3, nx_widestr(util_text("ui_dr_col_name_4")))
  form.textgrid_war_history:SetColTitle(4, nx_widestr(util_text("ui_dr_col_name_5")))
  request_page_info(form, 1)
end
function on_main_form_close(form)
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function on_btn_pre_click(btn)
  local form = btn.ParentForm
  if form.page_index <= 1 then
    btn.Enabled = false
    return
  end
  form.btn_next.Enabled = true
  request_page_info(form, form.page_index - 1)
  if form.page_index == 1 then
    btn.Enabled = false
  end
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if form.page_index >= form.max_index then
    btn.Enabled = false
    return
  end
  form.btn_pre.Enabled = true
  request_page_info(form, form.page_index + 1)
  if form.page_index == form.max_index then
    btn.Enabled = false
  end
end
function on_textgrid_war_history_mousein_row_changed(grid, new_row, old_row)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    return
  end
  local form = grid.ParentForm
  if new_row < 0 then
    grid.HintText = ""
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local array_name = nx_string(form.Name)
  if not common_array:FindArray(array_name) then
    return
  end
  local reduce_occvalue = common_array:FindChild(array_name, nx_string(new_row))
  grid.HintText = nx_widestr(util_format_string("ui_guild_war_history_tips", nx_int(reduce_occvalue)))
end
function update_form_info(rows, ...)
  if math.mod(#arg, 6) ~= 0 then
    return
  end
  local form = nx_value(FORM_GUILD_WAR_HISTORY)
  if not nx_is_valid(form) then
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local array_name = nx_string(form.Name)
  if common_array:FindArray(array_name) then
    common_array:RemoveArray(array_name)
  end
  common_array:AddArray(array_name, form, 60, true)
  if nx_int(rows) > nx_int(form.max_count) then
    rows = form.max_count
  end
  form.max_index = math.ceil(rows / PAGE_COUNT)
  form.textgrid_war_history:ClearRow()
  local count = #arg / 6
  for i = 0, count - 1 do
    if (form.page_index - 1) * PAGE_COUNT + i >= form.max_count then
      break
    end
    local row = form.textgrid_war_history:InsertRow(-1)
    form.textgrid_war_history:SetGridText(row, 0, nx_widestr(arg[i * 6 + 2]))
    form.textgrid_war_history:SetGridText(row, 1, nx_widestr(arg[i * 6 + 3]))
    form.textgrid_war_history:SetGridText(row, 2, nx_widestr(util_text("ui_dipan_" .. nx_string(arg[i * 6 + 4]))))
    form.textgrid_war_history:SetGridText(row, 3, nx_widestr(arg[i * 6 + 5]))
    form.textgrid_war_history:SetGridText(row, 4, nx_widestr(arg[i * 6 + 1]))
    common_array:AddChild(array_name, nx_string(row), nx_widestr(arg[i * 6 + 6]))
  end
end
function request_page_info(form, page_index)
  if page_index <= 0 then
    return
  end
  form.page_index = page_index
  form.lbl_page.Text = nx_widestr(page_index) .. nx_widestr("/") .. nx_widestr(form.max_index)
  local from = (page_index - 1) * PAGE_COUNT + 1
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local CLIENT_SUBMSG_REQUEST_WAR_HISTORY = 27
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_REQUEST_WAR_HISTORY), nx_int(from), nx_int(from + PAGE_COUNT - 1))
end
function get_max_info()
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuildWar.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local section_index = ini:FindSectionIndex("history_count")
  if section_index < 0 then
    return 0
  end
  local max_info = ini:ReadInteger(section_index, "r", 0)
  return max_info
end
