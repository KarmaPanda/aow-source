require("util_gui")
require("custom_sender")
require("share\\client_custom_define")
require("form_stage_main\\form_arrest\\form_arrest_define")
local grid_uid = {
  "",
  "",
  "",
  "",
  ""
}
local sort_type = 0
local unit_money = 1
local prison_div = 1
local max_prison = 1
local be_wanted_rate = 1
function on_main_form_init(form)
  form.Fixed = false
  form.rows = 0
  form.uid = ""
  form.name = nx_widestr("")
  form.money = 0
  form.time = 0
  form.danger_level = 1
  form.police_num = 0
  form.kill_times = 0
  form.character = 0
  form.power_level = 0
  form.danger_level = 1
  form.grid_index = 1
  form.page_index = 1
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.btn_page_next.Enabled = true
  form.btn_publish.Enabled = false
  form.btn_page_front.Enabled = false
  nx_execute("form_stage_main\\form_arrest\\form_arrest_define", "get_arrest_ini")
  unit_money, prison_div, max_prison, be_wanted_rate = nx_execute("form_stage_main\\form_arrest\\form_arrest_define", "get_arrest_add_need_info")
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return
end
function show_all_arrest_info(...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_arrest\\form_arrest_add_money", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_select.Visible = true
  form.groupbox_info.Visible = false
  form.groupbox_add_money.Visible = false
  form.groupbox_confirm.Visible = false
  form.rows = arg[3]
  if form.rows < 1 then
    return
  end
  form.textgrid_criminal:ClearRow()
  local gui = nx_value("gui")
  local param_num = 5
  for i = 0, form.rows - 1 do
    grid_uid[i + 1] = nx_string(arg[4 + i * 5])
    form.textgrid_criminal:InsertRow(-1)
    form.textgrid_criminal:SetGridText(i, 0, nx_widestr(arg[5 + i * 5]))
    local mltbox = gui:Create("MultiTextBox")
    mltbox.Height = 30
    mltbox.Width = 109
    mltbox.Transparent = true
    mltbox.HAlign = "Center"
    mltbox.VAlign = "Center"
    mltbox.LineTextAlign = "Center"
    mltbox.NoFrame = true
    local danger_level = nx_widestr("<font face=\"font_sns_list\" color=\"#c8b464\">") .. nx_widestr(util_text("ui_cf_danger_lvl")) .. nx_widestr(":</font>") .. nx_widestr(get_danger_level_icon(arg[6 + i * 5]))
    mltbox:AddHtmlText(nx_widestr(danger_level), i)
    form.textgrid_criminal:SetGridControl(i, 1, mltbox)
    local money = arg[7 + i * 5]
    local format_money = money_info(money)
    form.textgrid_criminal:SetGridText(i, 2, nx_widestr(format_money))
    local time_format = format_time(arg[8 + i * 5])
    form.textgrid_criminal:SetGridText(i, 3, nx_widestr(time_format))
  end
  form.grid_index = arg[2]
  form.lbl_page.Text = nx_widestr(form.grid_index)
  form.uid = grid_uid[1]
  form.page_index = 1
  util_show_form("form_stage_main\\form_arrest\\form_arrest_add_money", true)
end
function show_detailed_info(...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_arrest\\form_arrest_add_money", true, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.uid = arg[3]
  form.name = arg[4]
  form.danger_level = arg[5]
  form.character = arg[6]
  form.power_level = arg[7]
  form.money = arg[12]
  form.time = arg[13]
  form.kill_times = arg[16]
  form.police_num = arg[17]
  local obj_power_level = target_power_level(form.power_level)
  if obj_power_level ~= "" then
    local power_level = gui.TextManager:GetText(obj_power_level)
    form.lbl_power.Text = nx_widestr(power_level)
  end
  local time_format = format_time(form.time)
  form.lbl_time.Text = nx_widestr(time_format)
  local target_charater = get_enemy_character(form.character)
  form.lbl_name.Text = form.name
  form.lbl_character.Text = nx_widestr(util_text(target_charater))
  local money_info = money_info(form.money)
  form.lbl_money.Text = nx_widestr(money_info)
  local lock_time = nx_int(form.money / unit_money * prison_div)
  if nx_int(lock_time) > nx_int(max_prison) then
    lock_time = nx_int(max_prison)
  end
  form.lbl_lock_time.Text = nx_widestr(nx_int(lock_time / 60)) .. nx_widestr(util_text("ui_fengzhong"))
  form.lbl_num.Text = nx_widestr(form.police_num) .. nx_widestr(util_text("ui_ren"))
  form.lbl_times.Text = nx_widestr(nx_int(form.money * be_wanted_rate / unit_money)) .. nx_widestr(util_text("ui_ci"))
  form.redit_reason_desc.Text = nx_widestr(arg[11])
  local danger_icon = get_danger_icon(arg[5])
  form.lbl_danger_icon.BackImage = danger_icon
  return
end
function on_btn_sort_danger_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  sort_type = 0
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_QUERY_BY_SORT), nx_int(1), nx_int(5), nx_int(arrest_tocustom_show_reward), nx_int(0))
  return
end
function on_btn_sort_reward_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  sort_type = 1
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_QUERY_BY_SORT), nx_int(1), nx_int(5), nx_int(arrest_tocustom_show_reward), nx_int(1))
  return
end
function on_btn_sort_validTime_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  sort_type = 2
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_QUERY_BY_SORT), nx_int(1), nx_int(5), nx_int(arrest_tocustom_show_reward), nx_int(2))
  return
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_QUERY_BY_SORT), nx_int(form.grid_index + 1), nx_int(5), nx_int(arrest_tocustom_show_reward), sort_type)
  return
end
function on_btn_front_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  if form.grid_index < 2 then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_QUERY_BY_SORT), nx_int(form.grid_index - 1), nx_int(5), nx_int(arrest_tocustom_show_reward), sort_type)
  return
end
function on_btn_last_page_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_QUERY_BY_SORT), nx_int(-1), nx_int(5), nx_int(arrest_tocustom_show_reward), sort_type)
  return
end
function on_btn_first_page_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_QUERY_BY_SORT), nx_int(1), nx_int(5), nx_int(arrest_tocustom_show_reward), sort_type)
  return
end
function on_btn_search_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  if form.ipt_name.Text == nx_widestr("") then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_SEARCH_ARREST), nx_widestr(form.ipt_name.Text), nx_int(arrest_tocustom_show_reward))
  return
end
function add_money(name)
  if nx_ws_length(nx_widestr(name)) <= 0 then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_SEARCH_ARREST), nx_widestr(name), nx_int(arrest_tocustom_show_reward))
end
function on_textgrid_criminal_select_row(grid, row)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.uid = grid_uid[row + 1]
  return
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(1), nx_string(form.uid))
end
function on_btn_page_next_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local page = {
    form.groupbox_select,
    form.groupbox_info,
    form.groupbox_add_money,
    form.groupbox_confirm
  }
  if form.page_index > 3 then
    return
  end
  if form.page_index == 1 then
    if form.uid == "" then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_QUERY_ARREST), nx_int(arrest_detail_add_reward), nx_string(form.uid))
  end
  form.btn_page_front.Enabled = true
  if form.page_index == 2 then
    local money_info = money_info(form.money)
    form.lbl_now_money.Text = nx_widestr(money_info)
  end
  if form.page_index == 3 then
    local add_money_info = format_money_info(nx_int(form.ipt_add_money_ding.Text), nx_int(form.ipt_add_money_liang.Text), nx_int(form.ipt_add_money_wen.Text))
    form.lbl_add_confirm.Text = nx_widestr(add_money_info)
    form.lbl_name_confirm.Text = form.name
    local target_charater = get_enemy_character(form.character)
    form.lbl_character_confirm.Text = nx_widestr(util_text(target_charater))
    local obj_power_level = target_power_level(form.power_level)
    if obj_power_level ~= "" then
      local power_level = gui.TextManager:GetText(obj_power_level)
      form.lbl_power_confirm.Text = nx_widestr(power_level)
    end
    local money_info = money_info(form.money)
    form.lbl_money_confirm.Text = nx_widestr(money_info)
    form.lbl_num_confirm.Text = nx_widestr(form.police_num) .. nx_widestr(util_text("ui_ren"))
    local time_format = format_time(form.time)
    form.lbl_time_confirm.Text = nx_widestr(time_format)
    local money_add_wen = nx_int(form.ipt_add_money_ding.Text) * 1000000 + nx_int(form.ipt_add_money_liang.Text) * 1000 + nx_int(form.ipt_add_money_wen.Text)
    local all_money = form.money + nx_int(money_add_wen)
    local lock_time = nx_int(all_money / unit_money * prison_div)
    if nx_int(lock_time) > nx_int(max_prison) then
      lock_time = nx_int(max_prison)
    end
    form.lbl_lock_time_confirm.Text = nx_widestr(nx_int(lock_time / 60)) .. nx_widestr(util_text("ui_fengzhong"))
    local catch_times = nx_int(all_money * be_wanted_rate / unit_money)
    form.lbl_times_confirm.Text = nx_widestr(catch_times) .. nx_widestr(util_text("ui_ci"))
    form.redit_reason_desc_confirm.Text = form.redit_reason_desc.Text
    form.btn_page_next.Enabled = false
    form.btn_publish.Enabled = true
    local danger_icon = get_danger_icon(form.danger_level)
    form.lbl_danger_icon_confirm.BackImage = danger_icon
  end
  page[form.page_index].Visible = false
  page[form.page_index + 1].Visible = true
  form.page_index = form.page_index + 1
  return
end
function on_btn_page_front_click(btn)
  local form = btn.ParentForm
  local page = {
    form.groupbox_select,
    form.groupbox_info,
    form.groupbox_add_money,
    form.groupbox_confirm
  }
  form.btn_publish.Enabled = false
  form.btn_page_next.Enabled = true
  if form.page_index < 2 then
    return
  end
  if form.page_index == 2 then
    form.btn_page_front.Enabled = false
  end
  page[form.page_index].Visible = false
  page[form.page_index - 1].Visible = true
  form.page_index = form.page_index - 1
  return
end
function on_btn_publish_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local money_ding = nx_int(form.ipt_add_money_ding.Text)
  local money_liang = nx_int(form.ipt_add_money_liang.Text)
  local money_wen = nx_int(form.ipt_add_money_wen.Text)
  local money = money_ding * 1000000 + money_liang * 1000 + money_wen
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_ADD_MONEY), nx_string(form.uid), nx_int(money))
  form:Close()
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
function get_enemy_character(CharacterFlag)
  local gui = nx_value("gui")
  if CharacterFlag == 0 then
    return "ui_putong"
  elseif CharacterFlag == 1 then
    return "ui_xiashi"
  elseif CharacterFlag == 2 then
    return "ui_eren"
  elseif CharacterFlag == 3 then
    return "ui_kuang"
  elseif CharacterFlag == 4 then
    return "ui_xie"
  end
  return ""
end
function target_power_level(target_power_level)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local self_power_level = client_player:QueryProp("PowerLevel")
  local diff_level = target_power_level - self_power_level
  if diff_level < -10 then
    return "tips_shili_1"
  elseif -10 <= diff_level and diff_level <= 5 then
    return "tips_shili_2"
  elseif 6 <= diff_level and diff_level <= 15 then
    return "tips_shili_3"
  elseif 16 <= diff_level and diff_level <= 20 then
    return "tips_shili_4"
  elseif 20 < diff_level then
    return "tips_shili_5"
  end
  return ""
end
function format_time(time_value)
  if time_value < 0 then
    return nx_widestr(0) .. nx_widestr(util_text("ui_minute"))
  end
  local minute = time_value / 60
  local hour = minute / 60
  minute = minute % 60
  local day = nx_int(hour / 24)
  hour = hour % 24
  return nx_widestr(day) .. nx_widestr(util_text("ui_day")) .. nx_widestr(nx_int(hour)) .. nx_widestr(util_text("ui_hour")) .. nx_widestr(nx_int(minute)) .. nx_widestr(util_text("ui_minute"))
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
