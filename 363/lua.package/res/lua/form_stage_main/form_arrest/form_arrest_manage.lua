require("util_gui")
require("custom_sender")
require("share\\client_custom_define")
require("form_stage_main\\form_arrest\\form_arrest_define")
local unit_money = 1
local prison_div = 1
local max_prison = 1
local police_time = ""
function main_form_init(form)
  form.Fixed = false
  form.uid = ""
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.rbtn_publish.Checked = true
  form.groupbox_receive.Visible = false
  form.groupbox_me.Visible = false
  form.btn_resume.Visible = false
  form.btn_back.Visible = false
  form.btn_give_up.Visible = false
  form.groupbox_publish.Visible = true
  form.lbl_scene_title.Visible = false
  form.lbl_scene_do.Visible = false
  form.lbl_scene_do_receive_title.Visible = false
  form.lbl_scene_do_receive.Visible = false
  nx_execute("form_stage_main\\form_arrest\\form_arrest_define", "get_arrest_ini")
  unit_money, prison_div, max_prison = nx_execute("form_stage_main\\form_arrest\\form_arrest_define", "get_arrest_manage_need_info")
  show_arrest_list(form, 1)
  police_time = show_police_period()
  if police_time == "" then
    form.lbl_police_period_title.Visible = false
  else
    form.lbl_police_period_title.Visible = true
  end
  form.lbl_police_period.Text = nx_widestr(police_time)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function on_rbtn_page_click(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_publish.Visible = false
  form.groupbox_receive.Visible = false
  form.groupbox_me.Visible = false
  form.btn_resume.Visible = false
  form.btn_back.Visible = false
  form.btn_give_up.Visible = false
  if rbtn.TabIndex == 1 then
    form.groupbox_publish.Visible = true
    show_arrest_list(form, 1)
  elseif rbtn.TabIndex == 2 then
    form.groupbox_receive.Visible = true
    show_arrest_list(form, 2)
  elseif rbtn.TabIndex == 3 then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_QUERY_ARREST), nx_int(arrest_detail_wanted_manger))
  end
  return
end
function show_arrest_list(form, index)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.groupbox_publish.Visible = false
  form.groupbox_receive.Visible = false
  form.groupbox_me.Visible = false
  local need_type = 0
  if index == 1 then
    form.groupbox_publish.Visible = true
    form.textgrid_doing_publish.Visible = true
    form.groupbox_doing_desc.Visible = false
    grid = form.textgrid_doing_publish
    need_type = 0
  elseif index == 2 then
    form.groupbox_receive.Visible = true
    form.textgrid_doing_receive.Visible = true
    form.groupbox_doing_desc_receive.Visible = false
    grid = form.textgrid_doing_receive
    need_type = 1
  end
  local rows = client_player:GetRecordRows("Arrest_Warrant_Rec")
  if rows < 0 then
    return
  end
  grid:ClearRow()
  grid:SetColAlign(0, "Center")
  grid:SetColWidth(4, 1)
  grid:SetColWidth(0, 100)
  grid:SetColWidth(1, 156)
  local j = 0
  for i = 0, rows - 1 do
    local arrest_uid = client_player:QueryRecord("Arrest_Warrant_Rec", i, 0)
    local arrest_type = client_player:QueryRecord("Arrest_Warrant_Rec", i, 1)
    local arrest_pub_name = client_player:QueryRecord("Arrest_Warrant_Rec", i, 2)
    local arrest_name = client_player:QueryRecord("Arrest_Warrant_Rec", i, 3)
    local arrest_danger_level = client_player:QueryRecord("Arrest_Warrant_Rec", i, 4)
    local arest_money = client_player:QueryRecord("Arrest_Warrant_Rec", i, 5)
    local arrest_is_valid = client_player:QueryRecord("Arrest_Warrant_Rec", i, 6)
    if arrest_type == need_type then
      grid:InsertRow(-1)
      local mltbox_name = gui:Create("MultiTextBox")
      mltbox_name.Height = 52
      mltbox_name.Width = 100
      mltbox_name.Transparent = true
      mltbox_name.ViewRect = "0,10,100,52"
      mltbox_name.HAlign = "Center"
      mltbox_name.VAlign = "Center"
      mltbox_name.LineTextAlign = "Center"
      mltbox_name.NoFrame = true
      local name = nx_widestr("<font face=\"font_text\" color=\"#80654a\">") .. nx_widestr(arrest_name) .. nx_widestr("</font>")
      mltbox_name:AddHtmlText(nx_widestr(name), i)
      grid:SetGridControl(j, 0, mltbox_name)
      local mltbox_money = gui:Create("MultiTextBox")
      mltbox_money.Height = 52
      mltbox_money.Width = 156
      mltbox_money.ViewRect = "0,10,156,52"
      mltbox_money.Transparent = true
      mltbox_money.HAlign = "Center"
      mltbox_money.VAlign = "Center"
      mltbox_money.LineTextAlign = "Center"
      mltbox_money.NoFrame = true
      local money_format = money_info(arest_money)
      local money = nx_widestr("<font face=\"font_text\" color=\"#80654a\">") .. nx_widestr(util_text("ui_xuanshang")) .. nx_widestr(":</font>") .. nx_widestr("<font face=\"font_text\" color=\"#4c3d2c\">") .. nx_widestr(money_format) .. nx_widestr("</font>")
      mltbox_money:AddHtmlText(nx_widestr(money), i)
      grid:SetGridControl(j, 1, mltbox_money)
      local mltbox_state = gui:Create("MultiTextBox")
      mltbox_state.Height = 52
      mltbox_state.Width = 128
      mltbox_state.ViewRect = "0,10,128,52"
      mltbox_state.Transparent = true
      mltbox_state.HAlign = "Center"
      mltbox_state.VAlign = "Center"
      mltbox_state.LineTextAlign = "Center"
      mltbox_state.NoFrame = true
      local state = ""
      if arrest_is_valid == 0 then
        state = "ui_waitingforvalid"
      elseif arrest_is_valid == 1 then
        state = "ui_doing"
      end
      state = nx_widestr("<font face=\"font_text\" color=\"#80654a\">") .. nx_widestr(util_text("ui_status")) .. nx_widestr(":</font>") .. nx_widestr("<font face=\"font_text\" color=\"#4c3d2c\">") .. nx_widestr(util_text(state)) .. nx_widestr("</font>")
      mltbox_state:AddHtmlText(nx_widestr(state), i)
      grid:SetGridControl(j, 2, mltbox_state)
      local mltbox_danger = gui:Create("MultiTextBox")
      mltbox_danger.Height = 52
      mltbox_danger.Width = 128
      mltbox_danger.ViewRect = "0,10,128,52"
      mltbox_danger.Transparent = true
      mltbox_danger.HAlign = "Center"
      mltbox_danger.VAlign = "Center"
      mltbox_danger.LineTextAlign = "Center"
      mltbox_danger.NoFrame = true
      local danger_level = nx_widestr("<font face=\"font_sns_list\" color=\"#80654a\">") .. nx_widestr(util_text("ui_cf_danger_lvl")) .. nx_widestr(":</font>") .. nx_widestr(get_danger_level_icon(arrest_danger_level))
      mltbox_danger:AddHtmlText(nx_widestr(danger_level), i)
      grid:SetGridControl(j, 3, mltbox_danger)
      grid:SetGridText(j, 4, nx_widestr(arrest_uid))
      j = j + 1
    end
  end
  if 0 < j then
    grid.Visible = true
  else
    grid.Visible = false
  end
  return
end
function on_textgrid_doing_publish_select_row(grid)
  return
end
function on_textgrid_publish_double_click_grid(grid, row, col)
  local form = grid.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.textgrid_doing_publish.Visible = false
  form.groupbox_doing_desc.Visible = true
  local uid = grid:GetGridText(row, 4)
  local row_rec = client_player:FindRecordRow("Arrest_Warrant_Rec", 0, nx_string(uid), 0)
  local is_valid = client_player:QueryRecord("Arrest_Warrant_Rec", row_rec, 6)
  form.uid = nx_string(uid)
  if nx_int(is_valid) == nx_int(0) then
    form.btn_resume.Visible = true
  end
  form.btn_back.Visible = true
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_QUERY_ARREST), nx_int(arrest_detail_publish_manger), nx_string(uid))
  return
end
function on_textgrid_receive_double_click_grid(grid, row, col)
  local form = grid.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  form.textgrid_doing_receive.Visible = false
  form.groupbox_doing_desc_receive.Visible = true
  local uid = grid:GetGridText(row, 4)
  form.btn_back.Visible = true
  form.btn_give_up.Visible = true
  form.uid = nx_string(uid)
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_QUERY_ARREST), nx_int(arrest_detail_accept_manger), nx_string(uid))
end
function on_btn_resume_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if form.uid ~= "" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_RECOVER_ARREST), form.uid)
  end
  form:Close()
  return
end
function on_btn_give_up_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if form.uid ~= "" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_GIVEUP_ARREST), form.uid)
  end
  form:Close()
  return
end
function show_detailed_info_publish(...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_arrest\\form_arrest_manage", true, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local target_charater = nx_execute("form_stage_main\\form_arrest\\form_arrest_add_money", "get_enemy_character", arg[6])
  form.lbl_character_do.Text = nx_widestr(util_text(target_charater))
  local obj_power_level = nx_execute("form_stage_main\\form_arrest\\form_arrest_add_money", "target_power_level", arg[7])
  if obj_power_level ~= "" then
    local power_level = gui.TextManager:GetText(obj_power_level)
    form.lbl_power_do.Text = nx_widestr(power_level)
  end
  if arg[8] == 0 then
    form.lbl_scene_do.Text = nx_widestr("")
  else
    local scene = nx_execute("form_stage_main\\form_task\\form_task_main", "get_scene_name", nx_string(arg[9]))
    form.lbl_scene_do.Text = nx_widestr(util_text("tvt_" .. nx_string(scene)))
  end
  local time_format = format_time(arg[13])
  form.lbl_time_leave.Text = nx_widestr(time_format)
  local del_time_format = format_time(arg[14])
  form.lbl_del_time.Text = nx_widestr(del_time_format)
  form.lbl_name_do.Text = nx_widestr(arg[4])
  form.lbl_online_do.Text = nx_widestr(util_text(on_line(arg[8])))
  form.redit_desc_do.Text = nx_widestr(arg[11])
  local format_money = money_info(arg[12])
  form.lbl_money_do.Text = nx_widestr(format_money)
  form.lbl_num_do.Text = nx_widestr(arg[17]) .. nx_widestr(util_text("ui_ren"))
  local lock_time = nx_int(arg[12] / unit_money * prison_div)
  if nx_int(lock_time) > nx_int(max_prison) then
    lock_time = nx_int(max_prison)
  end
  form.lbl_prison_time_do.Text = nx_widestr(nx_int(lock_time / 60)) .. nx_widestr(util_text("ui_fengzhong"))
  form.lbl_catch_do.Text = nx_widestr(arg[16]) .. nx_widestr(util_text("ui_ci"))
  form.lbl_del_time.Visible = false
  form.lbl_del_time_title.Visible = false
  form.lbl_time_leave.Visible = false
  form.lbl_time_leave_title.Visible = false
  local state = arg[15]
  if nx_int(state) == nx_int(0) then
    form.lbl_del_time.Visible = true
    form.lbl_del_time_title.Visible = true
  elseif nx_int(state) == nx_int(1) then
    form.lbl_time_leave.Visible = true
    form.lbl_time_leave_title.Visible = true
  end
  local report_scene, coordinate = format_coordinate(arg[10])
  if coordinate == "" then
    coordinate = util_text("ui_wu")
  end
  if report_scene == "" then
    report_scene = util_text("ui_wu")
  end
  form.lbl_coordinate_do.Text = nx_widestr(coordinate)
  form.lbl_report_scene_do.Text = nx_widestr(report_scene)
  local danger_icon = get_danger_icon(arg[5])
  form.lbl_danger_icon_publish.BackImage = danger_icon
  return
end
function show_detailed_info_receive(...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_arrest\\form_arrest_manage", true, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local target_charater = nx_execute("form_stage_main\\form_arrest\\form_arrest_add_money", "get_enemy_character", arg[6])
  form.lbl_character_do_receive.Text = nx_widestr(util_text(target_charater))
  local obj_power_level = nx_execute("form_stage_main\\form_arrest\\form_arrest_add_money", "target_power_level", arg[7])
  if obj_power_level ~= "" then
    local power_level = gui.TextManager:GetText(obj_power_level)
    form.lbl_power_do_receive.Text = nx_widestr(power_level)
  end
  if arg[8] == 0 then
    form.lbl_scene_do_receive.Text = nx_widestr("")
  else
    local scene = nx_execute("form_stage_main\\form_task\\form_task_main", "get_scene_name", nx_string(arg[9]))
    form.lbl_scene_do_receive.Text = nx_widestr(util_text("tvt_" .. nx_string(scene)))
  end
  local time_format = format_time(arg[13])
  form.lbl_time_leave_receive.Text = nx_widestr(time_format)
  local del_time_format = format_time(arg[14])
  form.lbl_del_time_receive.Text = nx_widestr(del_time_format)
  form.lbl_name_do_receive.Text = nx_widestr(arg[4])
  form.lbl_online_do_receive.Text = nx_widestr(util_text(on_line(arg[8])))
  form.redit_desc_do_receive.Text = nx_widestr(arg[11])
  local format_money = money_info(arg[12])
  form.lbl_money_do_receive.Text = nx_widestr(format_money)
  form.lbl_num_do_receive.Text = nx_widestr(arg[17]) .. nx_widestr(util_text("ui_ren"))
  local lock_time = nx_int(arg[12] / unit_money * prison_div)
  if nx_int(lock_time) > nx_int(max_prison) then
    lock_time = nx_int(max_prison)
  end
  form.lbl_prison_time_do_receive.Text = nx_widestr(nx_int(lock_time / 60)) .. nx_widestr(util_text("ui_fengzhong"))
  form.lbl_catch_do_receive.Text = nx_widestr(arg[16]) .. nx_widestr(util_text("ui_ci"))
  form.lbl_del_time_receive.Visible = false
  form.lbl_del_time_receive_title.Visible = false
  form.lbl_time_leave_receive.Visible = false
  form.lbl_time_leave_receive_title.Visible = false
  local state = arg[15]
  if nx_int(state) == nx_int(0) then
    form.lbl_del_time_receive.Visible = true
    form.lbl_del_time_receive_title.Visible = true
  elseif nx_int(state) == nx_int(1) then
    form.lbl_time_leave_receive.Visible = true
    form.lbl_time_leave_receive_title.Visible = true
  end
  local report_scene, coordinate = format_coordinate(arg[10])
  if coordinate == "" then
    coordinate = util_text("ui_wu")
  end
  if report_scene == "" then
    report_scene = util_text("ui_wu")
  end
  form.lbl_coordinate_do_receive.Text = nx_widestr(coordinate)
  form.lbl_scene_report_receive.Text = nx_widestr(report_scene)
  local danger_icon = get_danger_icon(arg[5])
  form.lbl_danger_icon_receive.BackImage = danger_icon
  return
end
function show_detailed_info_me(...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_arrest\\form_arrest_manage", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_me.Visible = true
  local time_format = format_time(arg[13])
  form.lbl_me_time.Text = nx_widestr(time_format)
  local del_time_format = format_time(arg[14])
  form.lbl_me_del_time.Text = nx_widestr(del_time_format)
  form.redit_me_desc.Text = nx_widestr(arg[11])
  local format_money = money_info(arg[12])
  form.lbl_me_money.Text = nx_widestr(format_money)
  form.lbl_me_police_num.Text = nx_widestr(arg[17]) .. nx_widestr(util_text("ui_ren"))
  local lock_time = nx_int(arg[12] / unit_money * prison_div)
  if nx_int(lock_time) > nx_int(max_prison) then
    lock_time = nx_int(max_prison)
  end
  form.lbl_me_prison_time.Text = nx_widestr(nx_int(lock_time / 60)) .. nx_widestr(util_text("ui_fengzhong"))
  form.lbl_me_catch_times.Text = nx_widestr(arg[16]) .. nx_widestr(util_text("ui_ci"))
  form.lbl_me_time.Visible = false
  form.lbl_me_time_title.Visible = false
  form.lbl_me_del_time.Visible = false
  form.lbl_me_del_time_title.Visible = false
  form.lbl_del_back.Visible = false
  form.lbl_state.Text = nx_widestr(arg[15])
  if arg[15] == 0 then
    form.lbl_state.Text = nx_widestr(util_text("ui_waitingforvalid"))
    form.lbl_me_del_time.Visible = true
    form.lbl_me_del_time_title.Visible = true
    form.lbl_del_back.Visible = true
  elseif arg[15] == 1 then
    form.lbl_state.Text = nx_widestr(util_text("ui_doing"))
    form.lbl_me_time.Visible = true
    form.lbl_me_time_title.Visible = true
  end
  return
end
function on_btn_back_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.rbtn_publish.Checked == true then
    form.groupbox_publish.Visible = true
    form.groupbox_receive.Visible = false
    form.groupbox_me.Visible = false
    show_arrest_list(form, 1)
  elseif form.rbtn_receive.Checked == true then
    form.groupbox_publish.Visible = false
    form.groupbox_receive.Visible = true
    form.groupbox_me.Visible = false
    form.groupbox_me.Visible = false
    show_arrest_list(form, 2)
    form.btn_give_up.Visible = false
  end
  btn.Visible = false
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
function format_coordinate(coordinate_value)
  local coordinate = util_split_string(coordinate_value, ";")
  if table.getn(coordinate) ~= 4 then
    return "", ""
  end
  local scene_id = nx_execute("form_stage_main\\form_task\\form_task_main", "get_scene_name", nx_string(coordinate[1]))
  local scene = get_scene_name(scene_id)
  local minute = nx_int(coordinate[4] / 60)
  return scene, nx_widestr(coordinate[2]) .. nx_widestr(",") .. nx_widestr(coordinate[3]) .. nx_widestr("(") .. nx_widestr(minute) .. nx_widestr(util_text("ui_sns_minute")) .. nx_widestr(")")
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
function on_line(state)
  if state == 0 then
    return "ui_li"
  elseif state == 1 then
    return "ui_guild_online"
  end
  return ""
end
function get_scene_name(scene_id)
  local gui = nx_value("gui")
  return gui.TextManager:GetText(nx_string("ini\\scene\\scene_" .. nx_string(scene_id)))
end
function show_police_period()
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  local police_time = player:QueryProp("PoliceTime")
  if nx_string(police_time) == nx_string(0) then
    return ""
  end
  local year = os.date("%Y", police_time)
  local month = os.date("%m", police_time)
  local day = os.date("%d", police_time)
  local time_police = os.date("%X", police_time)
  return nx_string(year) .. "-" .. nx_string(month) .. "-" .. nx_string(day) .. " " .. nx_string(time_police)
end
