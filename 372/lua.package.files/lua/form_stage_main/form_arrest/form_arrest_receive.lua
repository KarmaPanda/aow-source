require("util_gui")
require("custom_sender")
require("share\\client_custom_define")
require("form_stage_main\\form_arrest\\form_arrest_define")
local sort_type = 0
local unit_money = 1
local prison_div = 1
local max_prison = 1
function on_main_form_init(form)
  form.Fixed = false
  form.uid = ""
  form.page_index = 1
  form.grid_index = 0
  form.rows = 0
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.groupbox_list.Visible = true
  form.groupbox_detail.Visible = false
  form.btn_next.Visible = true
  form.btn_front.Visible = false
  form.btn_ok.Visible = false
  form.lbl_scene_title.Visible = false
  form.lbl_scene.Visible = false
  nx_execute("form_stage_main\\form_arrest\\form_arrest_define", "get_arrest_ini")
  unit_money, prison_div, max_prison = nx_execute("form_stage_main\\form_arrest\\form_arrest_define", "get_arrest_receive_need_info")
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function show_all_arrest_info(...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_arrest\\form_arrest_receive", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_list.Visible = true
  form.groupbox_detail.Visible = false
  form.rows = arg[3]
  if form.rows < 1 then
    return
  end
  form.textgrid_list:ClearRow()
  form.textgrid_list:SetColWidth(4, 1)
  local gui = nx_value("gui")
  for i = 0, form.rows - 1 do
    form.textgrid_list:InsertRow(-1)
    form.textgrid_list:SetGridText(i, 0, nx_widestr(arg[5 + i * 5]))
    local mltbox = gui:Create("MultiTextBox")
    mltbox.Height = 30
    mltbox.Width = 109
    mltbox.Transparent = true
    mltbox.HAlign = "Center"
    mltbox.VAlign = "Center"
    mltbox.LineTextAlign = "Center"
    mltbox.NoFrame = true
    local danger_level = "<font face=\"font_sns_list\" color=\"#c8b464\">" .. util_text("ui_cf_danger_lvl") .. ":" .. "</font>" .. get_danger_level_icon(arg[6 + i * 5])
    mltbox:AddHtmlText(nx_widestr(danger_level), i)
    form.textgrid_list:SetGridControl(i, 1, mltbox)
    local money = arg[7 + i * 5]
    local money_info = money_info(money)
    form.textgrid_list:SetGridText(i, 2, nx_widestr(money_info))
    local time_format = format_time(arg[8 + i * 5])
    form.textgrid_list:SetGridText(i, 3, nx_widestr(time_format))
    form.textgrid_list:SetGridText(i, 4, nx_widestr(arg[4 + i * 5]))
  end
  form.grid_index = arg[2]
  form.lbl_grid_page.Text = nx_widestr(form.grid_index)
  form.uid = arg[4]
  if arg[4] == nil then
    form.uid = ""
  end
  form.page_index = 1
  util_show_form("form_stage_main\\form_arrest\\form_arrest_receive", true)
end
function show_detailed_info(...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_arrest\\form_arrest_receive", true, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.uid = arg[3]
  local target_charater = nx_execute("form_stage_main\\form_arrest\\form_arrest_add_money", "get_enemy_character", arg[6])
  form.lbl_character.Text = nx_widestr(util_text(target_charater))
  local obj_power_level = nx_execute("form_stage_main\\form_arrest\\form_arrest_add_money", "target_power_level", arg[7])
  if obj_power_level ~= "" then
    local power_level = gui.TextManager:GetText(obj_power_level)
    form.lbl_power.Text = nx_widestr(power_level)
  end
  if arg[8] == 0 then
    form.lbl_scene.Text = nx_widestr("")
  else
    local scene = nx_execute("form_stage_main\\form_task\\form_task_main", "get_scene_name", nx_string(arg[9]))
    form.lbl_scene.Text = nx_widestr(util_text("tvt_" .. nx_string(scene)))
  end
  local time_format = format_time(arg[13])
  form.lbl_time.Text = nx_widestr(time_format)
  form.lbl_name.Text = nx_widestr(arg[4])
  form.lbl_on_line.Text = nx_widestr(util_text(on_line(arg[8])))
  form.redit_reason_desc.Text = nx_widestr(arg[11])
  local money_info = money_info(arg[12])
  form.lbl_money.Text = nx_widestr(money_info)
  form.lbl_num.Text = nx_widestr(nx_string(arg[17]) .. util_text("ui_ren"))
  local lock_time = nx_int(arg[12] / unit_money * prison_div)
  if nx_int(lock_time) > nx_int(max_prison) then
    lock_time = nx_int(max_prison)
  end
  form.lbl_lock_time.Text = nx_widestr(nx_string(nx_int(lock_time / 60)) .. util_text("ui_fengzhong"))
  form.lbl_times.Text = nx_widestr(nx_string(nx_int(arg[12] / unit_money)) .. util_text("ui_ci"))
  local danger_icon = get_danger_icon(arg[5])
  form.lbl_danger_icon.BackImage = danger_icon
  return
end
function on_textgrid_list_select_row(grid, row)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.uid = nx_string(grid:GetGridText(row, 4))
  return
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local page = {
    form.groupbox_list,
    form.groupbox_detail
  }
  if form.page_index > 1 then
    return
  end
  if form.page_index == 1 then
    if form.uid == "" then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_QUERY_ARREST), nx_int(arrest_detail_accept), nx_string(form.uid))
  end
  page[form.page_index].Visible = false
  page[form.page_index + 1].Visible = true
  form.page_index = form.page_index + 1
  form.btn_next.Visible = false
  form.btn_front.Visible = true
  form.btn_ok.Visible = true
  return
end
function on_btn_front_click(btn)
  local form = btn.ParentForm
  local page = {
    form.groupbox_list,
    form.groupbox_detail
  }
  if form.page_index < 2 then
    return
  end
  page[form.page_index].Visible = false
  page[form.page_index - 1].Visible = true
  form.page_index = form.page_index - 1
  form.btn_next.Visible = true
  form.btn_front.Visible = false
  form.btn_ok.Visible = false
  return
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  if form.uid == "" then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_ACCEPT_ARREST), nx_string(form.uid))
  form:Close()
  return
end
function on_btn_danger_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  sort_type = 0
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_QUERY_BY_SORT), nx_int(1), nx_int(5), nx_int(arrest_tocustom_show_accept), nx_int(0))
  return
end
function on_btn_money_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  sort_type = 1
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_QUERY_BY_SORT), nx_int(1), nx_int(5), nx_int(arrest_tocustom_show_accept), nx_int(1))
  return
end
function on_btn_time_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  sort_type = 2
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_QUERY_BY_SORT), nx_int(1), nx_int(5), nx_int(arrest_tocustom_show_accept), nx_int(2))
  return
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if form.grid_index < 2 then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_QUERY_BY_SORT), nx_int(form.grid_index - 1), nx_int(5), nx_int(arrest_tocustom_show_accept), sort_type)
  return
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_QUERY_BY_SORT), nx_int(form.grid_index + 1), nx_int(5), nx_int(arrest_tocustom_show_accept), sort_type)
  return
end
function on_btn_first_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_QUERY_BY_SORT), nx_int(1), nx_int(5), nx_int(arrest_tocustom_show_accept), sort_type)
  return
end
function on_btn_last_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_QUERY_BY_SORT), nx_int(-1), nx_int(5), nx_int(arrest_tocustom_show_accept), sort_type)
  return
end
function on_btn_search_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if form.ipt_name.Text == nx_widestr("") then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_SEARCH_ARREST), nx_widestr(form.ipt_name.Text), nx_int(arrest_tocustom_show_accept))
  return
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  return
end
function format_time(time_value)
  if time_value < 0 then
    return nx_string(0) .. util_text("ui_minute")
  end
  local minute = time_value / 60
  local hour = minute / 60
  minute = minute % 60
  local day = nx_int(hour / 24)
  hour = hour % 24
  return nx_string(day) .. util_text("ui_day") .. nx_string(nx_int(hour)) .. util_text("ui_hour") .. nx_string(nx_int(minute)) .. util_text("ui_minute")
end
function get_danger_level_icon(danger_level)
  if danger_level == 1 then
    return "<img src=\"gui\\language\\ChineseS\\tvt\\tongji\\level_1.png\" data=\"\" />"
  elseif danger_level == 2 then
    return "<img src=\"gui\\language\\ChineseS\\tvt\\tongji\\level_2.png\" data=\"\" />"
  elseif danger_level == 3 then
    return "<img src=\"gui\\language\\ChineseS\\tvt\\tongji\\level_3.png\" data=\"\" />"
  elseif danger_level == 4 then
    return "<img src=\"gui\\language\\ChineseS\\tvt\\tongji\\level_4.png\" data=\"\" />"
  end
  return ""
end
function on_line(state)
  if state == 0 then
    return "ui_li"
  elseif state == 1 then
    return "ui_guild_online"
  end
  return ""
end
function get_danger_icon(danger_level)
  if danger_level == 1 then
    return "gui\\language\\ChineseS\\tvt\\tongji\\level2_1.png"
  elseif danger_level == 2 then
    return "gui\\language\\ChineseS\\tvt\\tongji\\level2_2.png"
  elseif danger_level == 3 then
    return "gui\\language\\ChineseS\\tvt\\tongji\\level2_3.png"
  elseif danger_level == 4 then
    return "gui\\language\\ChineseS\\tvt\\tongji\\level2_4.png"
  end
  return ""
end
