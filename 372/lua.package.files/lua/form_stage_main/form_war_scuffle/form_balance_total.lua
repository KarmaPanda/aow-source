require("util_gui")
require("util_functions")
require("form_stage_main\\switch\\switch_define")
require("define\\sysinfo_define")
require("share\\client_custom_define")
local FORM_PATH = "form_stage_main\\form_war_scuffle\\form_balance_total"
local FORM_LV = "form_stage_main\\form_war_scuffle\\form_balance_level"
local balance_total_file = "share\\War\\PingHeng\\pingheng.ini"
local WuDaoYanWuClientMsg_Apply = 1
local WuDaoYanWuClientMsg_Quit = 2
local WuDaoYanWuClientMsg_AttendInfo = 3
local CLIENT_SUB_BG_REQ_WAR_INFO = 0
local bg = "balance_grow_bg_"
local ST_FUNCTION_WUDAO_YANWU = 904
local left_image = {
  "gui\\special\\war_balance\\tip222.png",
  "gui\\special\\war_balance\\tip333.png",
  "gui\\special\\war_balance\\tip111.png"
}
local gbox_image = {
  "gui\\special\\war_balance\\kuang_2.png",
  "gui\\special\\war_balance\\kuang_3.png",
  "gui\\special\\war_balance\\kuang_1.png"
}
function open_form()
  local form = util_get_form(FORM_PATH, true, false)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
end
function main_form_init(self)
  self.Fixed = false
  self.Count = 0
  self.WeekDay = -1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.AbsLeft = (gui.Width - self.Width) / 2
    self.AbsTop = (gui.Height - self.Height) / 2
  end
  self.WeekDay = get_week_day_current()
  auto_select_week_day_rbtn(self)
  init_form(self)
  nx_execute("custom_sender", "custom_wudao_yanwu", nx_int(WuDaoYanWuClientMsg_AttendInfo))
  request_balance_info()
end
function request_balance_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_GROW), nx_int(CLIENT_SUB_BG_REQ_WAR_INFO))
end
function rec_balance_info(...)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_wd_join.Text = nx_widestr(nx_string(arg[1]))
  form.lbl_wd_win.Text = nx_widestr(nx_string(arg[2]))
  form.lbl_wd_kill.Text = nx_widestr(nx_string(arg[3]))
  form.lbl_qf_join.Text = nx_widestr(nx_string(arg[4]))
  form.lbl_qf_win.Text = nx_widestr(nx_string(arg[5]))
  form.lbl_qf_kill.Text = nx_widestr(nx_string(arg[6]))
  form.lbl_xy_join.Text = nx_widestr(nx_string(arg[7]))
  form.lbl_xy_win.Text = nx_widestr(nx_string(arg[8]))
  form.lbl_xy_kill.Text = nx_widestr(nx_string(arg[9]))
  form.lbl_my_join.Text = nx_widestr(nx_string(arg[10]))
  form.lbl_my_win.Text = nx_widestr(nx_string(arg[11]))
  form.lbl_my_kill.Text = nx_widestr(nx_string(arg[12]))
  form.lbl_kof_join.Text = nx_widestr(nx_string(arg[17]))
  form.lbl_kof_win.Text = nx_widestr(nx_string(arg[18]))
  form.lbl_kof_kill.Text = nx_widestr(nx_string(arg[19]))
  form.lbl_blance_lv.Text = nx_widestr(nx_string(arg[13]))
  form.pbar_balance_grow.Maximum = nx_int(arg[15])
  form.pbar_balance_grow.Value = nx_int(arg[14])
  local dang = nx_number(arg[16])
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local value = client_player:QueryProp("BalanceGroupCurLv")
  form.btn_lv_detail.FocusImage = "gui\\special\\balance_grow\\balance_grow_" .. nx_string(dang) .. nx_string(".png")
  form.btn_lv_detail.NormalImage = "gui\\special\\balance_grow\\balance_grow_" .. nx_string(dang) .. nx_string(".png")
  form.btn_lv_detail.PushImage = "gui\\special\\balance_grow\\balance_grow_" .. nx_string(dang) .. nx_string(".png")
  form.pbar_balance_grow.HintText = util_text(nx_string(form.pbar_balance_grow.Value) .. nx_string("/") .. nx_string(form.pbar_balance_grow.Maximum))
end
function on_btn_lv_detail_click(btn)
  nx_execute(FORM_LV, "open_form")
end
function on_main_form_close(self)
  if nx_is_valid(self) then
    nx_destroy(self)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_6.Left >= 0 then
    return
  end
  local t_x = form.groupbox_6.Left + form.groupbox_5.Width
  local t_y = form.groupbox_6.Top
  local common_execute = nx_value("common_execute")
  if common_execute:FindExecute("ControlMove", form.groupbox_6) then
    return
  end
  common_execute:AddExecute("ControlMove", form.groupbox_6, nx_float(0), nx_float(t_x), nx_float(t_y), nx_float(0.3), "")
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if -form.groupbox_6.Left >= form.groupbox_6.Width - form.groupbox_5.Width then
    return
  end
  local t_x = form.groupbox_6.Left - form.groupbox_5.Width
  local t_y = form.groupbox_6.Top
  local common_execute = nx_value("common_execute")
  if common_execute:FindExecute("ControlMove", form.groupbox_6) then
    return
  end
  common_execute:AddExecute("ControlMove", form.groupbox_6, nx_float(0), nx_float(t_x), nx_float(t_y), nx_float(0.3), "")
end
function on_rbtn_week_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  updata_flag_gbox_time(form, rbtn.DataSource)
end
function on_btn_detail_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_string(btn.DataSource) == "" then
    return
  end
  nx_execute(nx_string(btn.DataSource), "open_form")
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  ctrl.Name = name
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  return ctrl
end
function init_form(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", balance_total_file)
  if not nx_is_valid(ini) then
    return
  end
  local total_sec = ini:GetSectionCount()
  form.Count = total_sec
  local parent_gbox = form.groupbox_6
  if not nx_is_valid(parent_gbox) then
    return
  end
  parent_gbox:DeleteAll()
  local open_num = 0
  for i = 1, total_sec do
    local sec_count = ini:FindSectionIndex(nx_string(i))
    if 0 <= sec_count then
      local switch = ini:ReadInteger(sec_count, "switch", -1)
      if balance_switch_check(switch) then
        local gbox = create_ctrl("GroupBox", "gbox_balance_activity_" .. nx_string(i), form.groupbox_2, parent_gbox)
        if nx_is_valid(gbox) then
          gbox.sec_index = sec_count
          local lbl_back = create_ctrl("Label", "lbl_back_" .. nx_string(i), form.lbl_back, gbox)
          lbl_back.play_no = nx_int(i)
          local lbl_back1 = create_ctrl("Label", "lbl_back1_" .. nx_string(i), form.lbl_bg_1, gbox)
          local lbl_back2 = create_ctrl("Label", "lbl_back2_" .. nx_string(i), form.lbl_bg_2, gbox)
          local lbl_image = create_ctrl("Label", "lbl_image_" .. nx_string(i), form.lbl_image, gbox)
          lbl_image.BackImage = ini:ReadString(sec_count, "activity_image", "")
          local lbl_activity_name = create_ctrl("Label", "lbl_activity_name_" .. nx_string(i), form.lbl_activity_name, gbox)
          lbl_activity_name.Text = nx_widestr(util_text(ini:ReadString(sec_count, "activity_name", "")))
          local lbl_type = create_ctrl("Label", "lbl_type_" .. nx_string(i), form.lbl_type, gbox)
          local lbl_scale = create_ctrl("Label", "lbl_scale_" .. nx_string(i), form.lbl_scale, gbox)
          local lbl_time = create_ctrl("Label", "lbl_time_" .. nx_string(i), form.lbl_time, gbox)
          local lbl_limite = create_ctrl("Label", "lbl_limite_" .. nx_string(i), form.lbl_limite, gbox)
          local lbl_type_value = create_ctrl("Label", "lbl_type_value_" .. nx_string(i), form.lbl_type_value, gbox)
          lbl_type_value.Text = nx_widestr(util_text(ini:ReadString(sec_count, "type", "")))
          local lbl_scale_value = create_ctrl("Label", "lbl_scale_value_" .. nx_string(i), form.lbl_scale_value, gbox)
          lbl_scale_value.Text = nx_widestr(util_text(ini:ReadString(sec_count, "scale", "")))
          local lbl_time_value = create_ctrl("Label", "lbl_time_value_" .. nx_string(i), form.lbl_time_value, gbox)
          set_left_up_image(gbox, lbl_time_value, lbl_back, form.WeekDay)
          local lbl_limite_value = create_ctrl("Label", "lbl_limite_value_" .. nx_string(i), form.lbl_limite_value, gbox)
          lbl_limite_value.Text = nx_widestr(util_text(ini:ReadString(sec_count, "limite", "")))
          local btn_detail = create_ctrl("Button", "btn_detail_" .. nx_string(i), form.btn_detail, gbox)
          if nx_is_valid(btn_detail) then
            btn_detail.DataSource = ini:ReadString(sec_count, "form", "")
            nx_bind_script(btn_detail, nx_current())
            nx_callback(btn_detail, "on_click", "on_btn_detail_click")
          end
          gbox.Left = open_num * form.groupbox_2.Width
          gbox.Top = 0
          parent_gbox.Width = (nx_int(open_num / 3) + 1) * form.groupbox_5.Width
          open_num = open_num + 1
        end
      end
    end
  end
end
function get_week_day_current()
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return -1
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  local cur_year, cur_month, cur_day, cur_hour, cur_mins, cur_sec = nx_function("ext_decode_date", cur_date_time)
  local week = nx_function("ext_get_day_of_week", cur_year, cur_month, cur_day)
  if week == 0 then
    week = 7
  end
  return week
end
function auto_select_week_day_rbtn(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.WeekDay) < nx_int(0) or nx_int(form.WeekDay) > nx_int(7) then
    return
  end
  local rbtn_name = "rbtn_" .. nx_string(form.WeekDay)
  local lbl_name = "lbl_" .. nx_string(form.WeekDay)
  local lbl = form.groupbox_1:Find(lbl_name)
  local rbtn = form.groupbox_1:Find(rbtn_name)
  if nx_is_valid(rbtn) and nx_is_valid(lbl) then
    rbtn.Checked = true
    lbl.BackImage = "gui\\special\\war_balance\\on.png"
  end
end
function balance_switch_check(switch_index)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return false
  end
  if not switch_manager:CheckSwitchEnable(switch_index) then
    return false
  end
  return true
end
function balance_time_check(open_time)
  local time_list = util_split_string(open_time, "-")
  if nx_int(#time_list) ~= nx_int(2) then
    return false
  end
  local begin_time_list = util_split_string(time_list[1], ":")
  local end_time_list = util_split_string(time_list[2], ":")
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return false
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  local cur_year, cur_month, cur_day, cur_hour, cur_mins, cur_sec = nx_function("ext_decode_date", cur_date_time)
  local begin_time = nx_int(begin_time_list[1]) * 60 + nx_int(begin_time_list[2])
  local end_time = nx_int(end_time_list[1]) * 60 + nx_int(end_time_list[2])
  local current_time = cur_hour * 60 + cur_mins
  if begin_time <= current_time and end_time > current_time then
    return true
  else
    return false
  end
end
function set_left_up_image(gbox, lbl_time, lbl_back, week_index)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(gbox) then
    return
  end
  if not nx_is_valid(lbl_time) then
    return
  end
  if not nx_is_valid(lbl_back) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", balance_total_file)
  if not nx_is_valid(ini) then
    return
  end
  if not nx_find_custom(gbox, "sec_index") then
    return
  end
  local open_time_list = ini:GetItemValueList(gbox.sec_index, "open_time")
  for i = 1, #open_time_list do
    local open_weekday_list = util_split_string(open_time_list[i], ",")
    if nx_int(open_weekday_list[1]) == nx_int(week_index) then
      if balance_time_check(open_weekday_list[2]) then
        gbox.sort_index = 1
        lbl_back.BackImage = "gui\\special\\war_balance\\balance_war_" .. nx_string(lbl_back.play_no) .. "_" .. nx_string(3) .. ".png"
        lbl_time.Text = nx_widestr(open_weekday_list[2])
        return
      else
        gbox.sort_index = 2
        lbl_back.BackImage = "gui\\special\\war_balance\\balance_war_" .. nx_string(lbl_back.play_no) .. "_" .. nx_string(2) .. ".png"
        lbl_time.Text = nx_widestr(open_weekday_list[2])
        return
      end
    end
  end
  gbox.sort_index = 3
  lbl_back.BackImage = "gui\\special\\war_balance\\balance_war_" .. nx_string(lbl_back.play_no) .. "_" .. nx_string(1) .. ".png"
  lbl_time.Text = nx_widestr(util_text("ui_luandou_shp_bal_016"))
end
function updata_flag_gbox_time(form, week_index)
  if not nx_is_valid(form) then
    return
  end
  local parent_gbox = form.groupbox_6
  if not nx_is_valid(parent_gbox) then
    return
  end
  for i = 1, form.Count do
    local gbox_name = "gbox_balance_activity_" .. nx_string(i)
    local gbox = parent_gbox:Find(gbox_name)
    if nx_is_valid(gbox) then
      local lbl_time_name = "lbl_time_value_" .. nx_string(i)
      local lbl_back_name = "lbl_back_" .. nx_string(i)
      local lbl_time = gbox:Find(lbl_time_name)
      local lbl_back = gbox:Find(lbl_back_name)
      if nx_is_valid(lbl_time) and nx_is_valid(lbl_back) then
        set_left_up_image(gbox, lbl_time, lbl_back, week_index)
      end
    end
  end
end
function close_form()
  local form = nx_value(FORM_PATH)
  if nx_is_valid(form) then
    form:Close()
  end
end
function balance_activity_sort()
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local parent_gbox = form.groupbox_6
  if not nx_is_valid(parent_gbox) then
    return
  end
  local temp_player_data = {}
  for i = 1, form.Count do
    local gbox_name = "gbox_balance_activity_" .. nx_string(i)
    local gbox = parent_gbox:Find(gbox_name)
    if nx_is_valid(gbox) and nx_find_custom(gbox, "sort_index") then
      table.insert(temp_player_data, {
        gbox,
        nx_int(gbox.sort_index)
      })
    end
  end
  table.sort(temp_player_data, function(a, b)
    if a[2] ~= b[2] then
      return a[2] < b[2]
    end
  end)
  for i = 1, #temp_player_data do
    temp_player_data[i][1].Left = (i - 1) * form.groupbox_2.Width
  end
end
function on_btn_yanwu_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_WUDAO_YANWU) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      local info = util_text("sys_school_convert_01")
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    return
  end
  nx_execute("custom_sender", "custom_wudao_yanwu", nx_int(WuDaoYanWuClientMsg_Apply))
end
function on_btn_quit_click()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = util_format_string("sys_activity_918_05")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_wudao_yanwu", nx_int(WuDaoYanWuClientMsg_Quit))
  else
  end
end
function rec_wudao_yanwu_attend_info(...)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(#arg) < nx_int(2) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.TextManager:Format_SetIDName("ui_testskill_button_tips")
  gui.TextManager:Format_AddParam(nx_int(arg[1]))
  gui.TextManager:Format_AddParam(nx_int(arg[2]))
  form.btn_yanwu.HintText = gui.TextManager:Format_GetText()
end
function on_btn_quit_horse_race_click()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = util_format_string("sys_activity_918_05")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_horse_race", nx_int(2))
  else
  end
end
function a(info)
  nx_msgbox(nx_string(info))
end
