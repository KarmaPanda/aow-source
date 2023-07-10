require("utils")
require("util_gui")
require("share\\chat_define")
local ChatStr = {
  "ui_smp_info_01",
  "ui_smp_info_02",
  "ui_smp_info_03",
  "ui_smp_info_04",
  "ui_smp_info_05",
  "ui_smp_info_06"
}
local Image = {
  "gui\\special\\recount\\icon_1.png",
  "gui\\special\\recount\\icon_2.png",
  "gui\\special\\recount\\icon_3.png",
  "gui\\special\\recount\\icon_4.png",
  "gui\\special\\recount\\icon_5.png",
  "gui\\special\\recount\\icon_6.png"
}
function open_form()
  local form = nx_value("form_clone_damage_statistics")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_clone_damage_statistics", true, false)
    nx_set_value("form_clone_damage_statistics", form)
  end
  DamageStatistics = nx_value("damage_statistics")
  if not nx_is_valid(DamageStatistics) then
    return
  end
  if form.Visible == false then
    local open = DamageStatistics:IsOpen()
    if open == false then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("100101"))
      return
    end
    form.Left = DamageStatistics.Left
    form.Top = DamageStatistics.Top
    form:Show()
    form.Visible = true
  else
    DamageStatistics.Left = form.Left
    DamageStatistics.Top = form.Top
    form.Visible = false
    form:Close()
  end
end
function form_damage_statistics_init(self)
  nx_set_value("form_clone_damage_statistics", form_damage_statistics)
  self.Visible = false
end
function from_clone_damage_statistics_open(self)
  local DamageStatistics = nx_value("damage_statistics")
  if not nx_is_valid(DamageStatistics) then
    return
  end
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 1.05
  self.Top = (gui.Height - self.Height) / 1.6
  local Open = DamageStatistics:IsOpen()
  if not Open then
    return
  end
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:Register(1000, -1, nx_current(), "up_date_time", self, -1, -1)
  end
  FORM = self
  self.btn_show_all.Visible = true
  self.btn_Hiden.Visible = false
  self.Width = 390
  self.Height = 25
  self.lbl_7.BackImage = Image[1]
  self.lbl_7_7.Text = nx_widestr(nx_string(0))
  self.lbl_8.BackImage = Image[2]
  self.lbl_8_8.Text = nx_widestr(nx_string(0))
  self.Fixed = false
  local form_button = nx_value("form_clone_damage_statistics_buttons")
  if not nx_is_valid(form_button) then
    form_button = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_clone_damage_statistics_buttons", true, false)
    nx_set_value("form_clone_damage_statistics_buttons", form_button)
  end
  local form_channels = nx_value("form_clone_damage_statistics_channels")
  if not nx_is_valid(form_channels) then
    form_channels = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_clone_damage_statistics_channels", true, false)
    nx_set_value("form_clone_damage_statistics_channels", form_channels)
  end
  local form_set = nx_value("form_clone_damage_statistics_set")
  if not nx_is_valid(form_set) then
    form_set = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_clone_damage_statistics_set", true, false)
    nx_set_value("form_clone_damage_statistics_set", form_set)
  end
end
function from_clone_damage_statistics_close(self)
  DamageStatistics = nx_value("damage_statistics")
  if nx_is_valid(DamageStatistics) then
    DamageStatistics.Left = self.Left
    DamageStatistics.Top = self.Top
  end
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "up_date_time", self)
  end
  local form_button = nx_value("form_clone_damage_statistics_buttons")
  if nx_is_valid(form_button) then
    nx_destroy(form_button)
  end
  local form_channel = nx_value("form_clone_damage_statistics_channels")
  if nx_is_valid(form_channel) then
    nx_destroy(form_channel)
  end
  local form_set = nx_value("form_clone_damage_statistics_set")
  if nx_is_valid(form_set) then
    nx_destroy(form_set)
  end
  nx_destroy(self)
end
function on_btn_show_all_click(btn)
  local form = btn.ParentForm
  form.Width = 390
  form.Height = 180
  form.btn_Hiden.Visible = true
  btn.Visible = false
end
function on_btn_Hiden_click(btn)
  local form = btn.ParentForm
  form.Width = 390
  form.Height = 25
  form.btn_show_all.Visible = true
  btn.Visible = false
end
function from_clone_damage_statistics_active()
  local form_button = nx_value("form_stage_main\\form_clone_damage_statistics_buttons")
  if nx_is_valid(form_button) then
    form_button:Close()
  end
  local form_channel = nx_value("form_stage_main\\form_clone_damage_statistics_channels")
  if nx_is_valid(form_channel) then
    form_channel:Close()
  end
  local form_set = nx_value("form_stage_main\\form_clone_damage_statistics_set")
  if nx_is_valid(form_set) then
    form_set:Close()
  end
end
function up_date_time(form)
  local DamageStatistics = nx_value("damage_statistics")
  if not nx_is_valid(DamageStatistics) then
    form:Close()
    return
  end
  local Open = DamageStatistics:IsOpen()
  if not Open then
    form:Close()
    return
  end
  local arg = DamageStatistics:GetPlayerDamage()
  local length = table.getn(arg)
  if length < 7 then
    return
  end
  form.lbl_1_1.Text = nx_widestr(arg[1])
  form.lbl_2_2.Text = nx_widestr(arg[2])
  form.lbl_3_3.Text = nx_widestr(arg[3])
  form.lbl_4_4.Text = nx_widestr(arg[4])
  form.lbl_5_5.Text = nx_widestr(arg[5]) .. nx_widestr("    ") .. nx_widestr(arg[6]) .. nx_widestr("%")
  form.lbl_6_6.Text = nx_widestr(arg[7])
  local form_set = nx_value("form_clone_damage_statistics_set")
  if not nx_is_valid(form_set) then
    return
  end
  update_top_items(form_set, form)
end
function on_btn_show_panel_click(btn)
  local form_buttons = nx_value("form_clone_damage_statistics_buttons")
  if not nx_is_valid(form_buttons) then
    return
  end
  form_buttons.Visible = true
  form_buttons:Show()
end
function update_top_items(form_set, form)
  local top_item_num = 0
  local top_item_list = {}
  for var = 1, 6 do
    local control_name = "cbtn_" .. nx_string(var)
    local check_button = form_set.groupbox_1:Find(control_name)
    if nx_is_valid(check_button) and check_button.Checked == true then
      top_item_num = top_item_num + 1
      top_item_list[top_item_num] = var
    end
  end
  form.lbl_7.BackImage = ""
  form.lbl_7_7.Text = nx_widestr("")
  form.lbl_7.DataSource = nx_widestr("")
  form.lbl_8.BackImage = ""
  form.lbl_8_8.Text = nx_widestr("")
  form.lbl_8.DataSource = nx_widestr("")
  local num = table.getn(top_item_list)
  for v = 1, num do
    local name = "lbl_" .. nx_string(top_item_list[v])
    local lbl_name = form.groupbox_1:Find(name)
    if nx_is_valid(lbl_name) then
      local top_name = "lbl_" .. nx_string(6 + v)
      local top_lbl = form.groupbox_1:Find(top_name)
      if nx_is_valid(top_lbl) then
        top_lbl.BackImage = Image[top_item_list[v]]
        top_lbl.DataSource = ChatStr[top_item_list[v]]
      end
    end
    local value = "lbl_" .. nx_string(top_item_list[v]) .. "_" .. nx_string(top_item_list[v])
    local lbl_value = form.groupbox_1:Find(value)
    if nx_is_valid(lbl_value) then
      local top_value = "lbl_" .. nx_string(6 + v) .. "_" .. nx_string(6 + v)
      local top_lbl_value = form.groupbox_1:Find(top_value)
      if nx_is_valid(top_lbl_value) then
        top_lbl_value.Text = lbl_value.Text
      end
    end
  end
end
