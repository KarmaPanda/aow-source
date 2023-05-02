require("form_stage_main\\form_marry\\form_marry_util")
require("form_stage_main\\switch\\switch_define")
function main_form_init(form)
  form.Fixed = true
  form.cur_year = 0
  form.cur_month = 0
  form.cur_day = 0
  form.cur_hour = 0
  form.sel_year = 0
  form.sel_month = 0
  form.sel_day = 0
  form.sel_time = 0
  form.sel_rite = 1
  form.begin_time = 0
  form.opt_type = 0
  form.wedding_list = nx_null()
  form.invaliddate_list = nx_null()
  form.time_count = 0
  local marry_time_ini = nx_execute("util_functions", "get_ini", INI_FILE_MARRY_TIME)
  if nx_is_valid(marry_time_ini) then
    form.time_count = marry_time_ini:GetSectionCount()
  end
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  local form_chat = nx_value("form_stage_main\\form_main\\form_main_chat")
  if nx_is_valid(form_chat) then
    gui.Desktop:ToFront(form_chat)
  end
  form.grid_title:ClearSelect()
  form.grid_title:ClearRow()
  form.grid_title:InsertRow(-1)
  for i = 0, 6 do
    form.grid_title:SetGridText(0, i, util_text("ui_confirmdate_grid_title_" .. nx_string(i)))
    form.grid_title:SetColAlign(i, "center")
  end
  if not nx_is_valid(form.wedding_list) then
    form.wedding_list = get_global_arraylist("marry_wedding_list")
  end
  if not nx_is_valid(form.invaliddate_list) then
    form.invaliddate_list = get_global_arraylist("marry_invaliddate_list")
  end
  form.cur_year = os.date("%Y")
  form.cur_month = os.date("%m")
  form.cur_day = os.date("%d")
  form.cur_hour = os.date("%H")
  local msgdelay = nx_value("MessageDelay")
  if nx_is_valid(msgdelay) then
    local server_time = msgdelay:GetServerDateTime()
    if 0 < nx_number(server_time) then
      local y, m, d, h = nx_function("ext_decode_date", server_time)
      form.cur_year = nx_number(y)
      form.cur_month = nx_number(m)
      form.cur_day = nx_number(d)
      form.cur_hour = nx_number(h)
    end
  end
  form.cbox_year.DropListBox:ClearString()
  form.cbox_year.DropListBox:AddString(nx_widestr(form.cur_year))
  form.cbox_year.DropListBox:AddString(nx_widestr(nx_number(form.cur_year) + 1))
  form.cbox_year.Text = nx_widestr(form.cur_year)
  on_cbox_year_selected(form.cbox_year)
  form.gbox_date.Visible = true
  form.gbox_rite.Visible = false
  set_form_all_screen(form)
  return 1
end
function on_main_form_close(form)
  if nx_is_valid(form.wedding_list) then
    nx_destroy(form.wedding_list)
    form.wedding_list = nx_null()
  end
  if nx_is_valid(form.invaliddate_list) then
    nx_destroy(form.invaliddate_list)
    form.invaliddate_list = nx_null()
  end
  local form_details = nx_value(FORM_MARRY_DETAILS)
  if nx_is_valid(form_details) then
    form_details:Close()
  end
  ui_ClearModel(form.sbox_player_1)
  ui_ClearModel(form.sbox_player_2)
  nx_destroy(form)
end
function on_btn_colse_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_cbox_year_selected(self)
  local form = self.ParentForm
  form.sel_year = nx_number(form.cbox_year.Text)
  if form.sel_year == nx_number(form.cur_year) then
    form.sel_month = nx_number(form.cur_month)
  else
    form.sel_month = nx_number(1)
  end
  select_month_btn(form, form.sel_month)
end
function on_rbtn_month_checked_changed(self)
  local form = self.ParentForm
  if self.Checked == false then
    return 0
  end
  form.sel_month = nx_number(self.DataSource)
  if form.sel_year == nx_number(form.cur_year) then
    if form.sel_month == nx_number(form.cur_month) then
      form.sel_day = nx_number(form.cur_day)
    else
      form.sel_day = nx_number(1)
    end
  else
    form.sel_day = nx_number(1)
  end
  show_calendar(form, form.sel_year, form.sel_month)
end
function on_cbtn_one_date_checked_changed(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local form = self.ParentForm
  if not nx_find_custom(self, "day") then
    return 0
  end
  if self.Checked == false then
    if nx_number(self.day) == nx_number(form.sel_day) then
      self.Enabled = false
      self.Checked = true
      self.Enabled = true
    end
    return 0
  end
  form.sel_day = nx_number(self.day)
  select_day_cbtn(form, form.sel_day)
  form.lbl_sel_date.Text = gui.TextManager:GetFormatText("ui_confirmdate_sel_date", nx_int(form.sel_year), nx_int(form.sel_month), nx_int(form.sel_day))
  show_time_list(form, form.sel_year, form.sel_month, form.sel_day)
end
function on_btn_time_confirm_click(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  if not nx_find_custom(self, "time") or not nx_find_custom(self, "begin_time") then
    return 0
  end
  form.sel_time = nx_number(self.time)
  form.begin_time = nx_number(self.begin_time)
  if not check_time_is_valid(form, form.sel_year, form.sel_month, form.sel_day, form.begin_time) then
    return 0
  end
  if form.opt_type == MARRY_CONFIRMDATE_TYPE_RESET then
    local rite_name = get_rite_name(get_player_prop("WeddingRite"))
    local info = gui.TextManager:GetFormatText("ui_marry_rite_info1", nx_int(form.sel_year), nx_int(form.sel_month), nx_int(form.sel_day), rite_name)
    local res = show_confirm(info)
    if res == "cancel" then
      return 0
    end
    custom_marry(CLIENT_MSG_SUB_MARRY_CONFIRM_DATE, form.sel_year, form.sel_month, form.sel_day, form.sel_time, form.sel_rite, 1)
    return 0
  end
  if form.opt_type == MARRY_CONFIRMDATE_TYPE_LOOK then
    return 0
  end
  show_rite_list(form)
  form.gbox_date.Visible = false
  form.gbox_rite.Visible = true
end
function on_btn_time_sel_click(self)
  local form = self.ParentForm
  if not nx_find_custom(self, "woman_info") or not nx_find_custom(self, "man_info") then
    return 0
  end
  if nx_widestr(self.woman_info) == nx_widestr("") or nx_widestr(self.man_info) == nx_widestr("") then
    return 0
  end
  nx_execute("form_stage_main\\form_marry\\form_marry_util", "create_role_model_by_role_info", form.sbox_player_1, self.woman_info, 0, 1, -3.5, 0)
  nx_execute("form_stage_main\\form_marry\\form_marry_util", "create_role_model_by_role_info", form.sbox_player_2, self.man_info, 0, 1, -3.5, 0)
end
function on_btn_detail_click(self)
  local form = self.ParentForm
  if not nx_find_custom(self, "rite") then
    return 0
  end
  nx_execute(FORM_MARRY_DETAILS, "show_data", self.rite)
end
function on_btn_buy_click(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return false
  end
  if not (nx_find_custom(self, "rite") and nx_find_custom(self, "rbtn_price_1")) or not nx_find_custom(self, "rbtn_price_2") then
    return 0
  end
  local money_type = 0
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_MARRY_USE_BIND_CARD) then
    if not nx_is_valid(self.rbtn_price_1) or not nx_is_valid(self.rbtn_price_2) then
      return 0
    end
    if self.rbtn_price_1.Checked then
      money_type = 1
    end
    if self.rbtn_price_2.Checked then
      money_type = 2
    end
  else
    money_type = 1
  end
  if money_type == 0 then
    show_confirm(util_text("ui_select_money_type"))
    return 0
  end
  local info = ""
  if money_type == 1 then
    info = gui.TextManager:GetFormatText("ui_marry_rite_info", self.rite_noney_1, self.rite_name, nx_int(form.sel_year), nx_int(form.sel_month), nx_int(form.sel_day))
  elseif money_type == 2 then
    info = gui.TextManager:GetFormatText("ui_marry_rite_info", self.rite_noney_2, self.rite_name, nx_int(form.sel_year), nx_int(form.sel_month), nx_int(form.sel_day))
  end
  local res = show_confirm(info)
  if res == "cancel" then
    return 0
  end
  form.sel_rite = self.rite
  custom_marry(CLIENT_MSG_SUB_MARRY_CONFIRM_DATE, nx_int(form.sel_year), nx_int(form.sel_month), nx_int(form.sel_day), nx_int(form.sel_time), nx_int(form.sel_rite), nx_int(money_type))
end
function check_time_is_valid(form, year, month, day, time)
  local now_time = os.time({
    year = form.cur_year,
    month = form.cur_month,
    day = form.cur_day,
    hour = form.cur_hour
  })
  local sel_time = os.time({
    year = year,
    month = month,
    day = day,
    hour = time / 60
  })
  if now_time >= sel_time then
    return false
  end
  if 604800 < sel_time - now_time then
    return false
  end
  return true
end
function select_month_btn(form, month)
  for i = 1, 12 do
    local rbtn_month = form.gbox_date:Find("rbtn_month_" .. nx_string(i))
    if nx_is_valid(rbtn_month) and nx_number(rbtn_month.DataSource) == nx_number(month) then
      rbtn_month.Checked = true
      break
    end
  end
end
function select_day_cbtn(form, day)
  for i = 0, form.grid_calendar.RowCount do
    for j = 0, form.grid_calendar.ColCount do
      local gbox = form.grid_calendar:GetGridControl(i, j)
      if nx_is_valid(gbox) and nx_find_custom(gbox, "cbtn") and nx_is_valid(gbox.cbtn) then
        local cbtn = gbox.cbtn
        if nx_find_custom(cbtn, "day") then
          if nx_number(cbtn.day) ~= nx_number(day) then
            cbtn.Enabled = false
            cbtn.Checked = false
            cbtn.Enabled = true
          else
            cbtn.Enabled = false
            cbtn.Checked = true
            cbtn.Enabled = true
          end
        end
      end
    end
  end
end
function get_wedding_count(form, year, month, day)
  if not nx_is_valid(form.wedding_list) then
    return 0
  end
  local name = nx_string(year) .. "." .. nx_string(month) .. "." .. nx_string(day)
  local child = form.wedding_list:GetChild(name)
  if not nx_is_valid(child) then
    return 0
  end
  return child:GetChildCount()
end
function get_time_select_child(form, time)
  if not nx_is_valid(form.wedding_list) then
    return nx_null()
  end
  local name = nx_string(form.sel_year) .. "." .. nx_string(form.sel_month) .. "." .. nx_string(form.sel_day)
  local child = form.wedding_list:GetChild(name)
  if not nx_is_valid(child) then
    return nx_null()
  end
  return child:GetChild(nx_string(time))
end
function show_calendar(form, sel_year, sel_month)
  if not nx_is_valid(form.wedding_list) then
    return 0
  end
  local date_tab = os.date("*t", os.time({
    year = sel_year,
    month = sel_month,
    day = 1
  }))
  form.grid_calendar:ClearSelect()
  form.grid_calendar:ClearRow()
  local row = -1
  local col = date_tab.wday - 1
  local cur_day = 1
  while true do
    local temp_tab = os.date("*t", os.time({
      year = sel_year,
      month = sel_month,
      day = cur_day
    }))
    if nx_int(temp_tab.month) ~= nx_int(sel_month) then
      for i = col, 6 do
        local gbox_one_date = create_ctrl_ex("GroupBox", "gbox_invalid_date_" .. nx_string(i), form.gbox_one_date)
        local cbtn_one_date = create_ctrl_ex("CheckButton", "cbtn_invalid_date_" .. nx_string(i), form.cbtn_one_date, gbox_one_date)
        cbtn_one_date.Enabled = false
        form.grid_calendar:SetGridControl(row, i, gbox_one_date)
      end
      break
    end
    if row == -1 then
      row = form.grid_calendar:InsertRow(-1)
      for i = 0, col - 1 do
        local gbox_one_date = create_ctrl_ex("GroupBox", "gbox_invalid_date_" .. nx_string(i), form.gbox_one_date)
        local cbtn_one_date = create_ctrl_ex("CheckButton", "cbtn_invalid_date_" .. nx_string(i), form.cbtn_one_date, gbox_one_date)
        cbtn_one_date.Enabled = false
        form.grid_calendar:SetGridControl(row, i, gbox_one_date)
      end
    end
    local gbox_one_date = create_ctrl_ex("GroupBox", "gbox_one_date_" .. nx_string(cur_day), form.gbox_one_date)
    local cbtn_one_date = create_ctrl_ex("CheckButton", "cbtn_one_date_" .. nx_string(cur_day), form.cbtn_one_date, gbox_one_date)
    local lbl_date_line = create_ctrl_ex("Label", "lbl_date_line_" .. nx_string(cur_day), form.lbl_date_line, gbox_one_date)
    local lbl_date_desc = create_ctrl_ex("Label", "lbl_date_desc_" .. nx_string(cur_day), form.lbl_date_desc, gbox_one_date)
    if not (nx_is_valid(gbox_one_date) and nx_is_valid(cbtn_one_date) and nx_is_valid(lbl_date_line)) or not nx_is_valid(lbl_date_desc) then
      break
    end
    cbtn_one_date.NormalImage = "gui\\special\\marry\\date\\" .. nx_string(cur_day) .. "_out.png"
    cbtn_one_date.FocusImage = "gui\\special\\marry\\date\\" .. nx_string(cur_day) .. "_on.png"
    cbtn_one_date.CheckedImage = "gui\\special\\marry\\date\\" .. nx_string(cur_day) .. "_down.png"
    local count = get_wedding_count(form, sel_year, sel_month, cur_day)
    if nx_number(count) >= nx_number(form.time_count) then
      lbl_date_line.BackImage = "gui\\special\\marry\\date\\" .. "pbr_2.png"
      lbl_date_desc.BackImage = "gui\\special\\marry\\date\\" .. "yym.png"
    elseif 0 < nx_number(count) then
      lbl_date_line.BackImage = "gui\\special\\marry\\date\\" .. "pbr_1.png"
      lbl_date_desc.BackImage = "gui\\special\\marry\\date\\" .. "yyy.png"
    end
    gbox_one_date.cbtn = cbtn_one_date
    cbtn_one_date.day = cur_day
    nx_bind_script(cbtn_one_date, nx_current())
    nx_callback(cbtn_one_date, "on_checked_changed", "on_cbtn_one_date_checked_changed")
    form.grid_calendar:SetGridControl(row, col, gbox_one_date)
    if nx_number(cur_day) == nx_number(form.sel_day) then
      cbtn_one_date.Checked = true
    end
    cur_day = cur_day + 1
    col = col + 1
    if 7 <= col then
      row = -1
      col = 0
    end
  end
end
function show_time_list(form, sel_year, sel_month, sel_day)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  ui_ClearModel(form.sbox_player_1)
  ui_ClearModel(form.sbox_player_2)
  local marry_time_ini = nx_execute("util_functions", "get_ini", INI_FILE_MARRY_TIME)
  if not nx_is_valid(marry_time_ini) then
    return 0
  end
  local have_model = false
  form.gscrbox_time:DeleteAll()
  local sec_count = marry_time_ini:GetSectionCount()
  for i = 0, sec_count - 1 do
    local section = marry_time_ini:GetSectionByIndex(i)
    local begin_time = marry_time_ini:ReadString(i, "BeginTime", "")
    local end_time = marry_time_ini:ReadString(i, "EndTime", "")
    local time_desc = marry_time_ini:ReadString(i, "Desc", "")
    local gbox_time = create_ctrl_ex("GroupBox", "gbox_time_" .. nx_string(i), form.gbox_time, form.gscrbox_time)
    local btn_sel = create_ctrl_ex("Button", "btn_sel_" .. nx_string(i), form.btn_time_sel, gbox_time)
    local lbl_time = create_ctrl_ex("Label", "lbl_time_" .. nx_string(i), form.lbl_time_desc, gbox_time)
    local btn_time = create_ctrl_ex("Button", "btn_time_" .. nx_string(i), form.btn_time_confirm, gbox_time)
    local lbl_rite = create_ctrl_ex("Label", "lbl_rite_" .. nx_string(i), form.lbl_rite, gbox_time)
    if not (nx_is_valid(gbox_time) and nx_is_valid(lbl_time) and nx_is_valid(btn_time) and nx_is_valid(btn_sel)) or not nx_is_valid(lbl_rite) then
      break
    end
    btn_time.time = nx_number(section)
    btn_time.begin_time = nx_number(begin_time)
    local sub_child = get_time_select_child(form, nx_number(section))
    if nx_is_valid(sub_child) then
      local player_name = gui.TextManager:GetFormatText("ui_confirmdate_player_name", sub_child.man_name, sub_child.woman_name)
      lbl_time.Text = gui.TextManager:GetFormatText(time_desc, format_time(form, begin_time), format_time(form, end_time), player_name)
      btn_time.Visible = false
      if have_model == false then
        have_model = true
        nx_execute("form_stage_main\\form_marry\\form_marry_util", "create_role_model_by_role_info", form.sbox_player_1, sub_child.woman_info, 0, 1, -3.5, 0)
        nx_execute("form_stage_main\\form_marry\\form_marry_util", "create_role_model_by_role_info", form.sbox_player_2, sub_child.man_info, 0, 1, -3.5, 0)
      end
      btn_sel.woman_info = sub_child.woman_info
      btn_sel.man_info = sub_child.man_info
      lbl_rite.Visible = true
      lbl_rite.BackImage = "gui\\special\\marry\\date\\tc" .. nx_string(sub_child.rite) .. ".png"
    else
      local add_info_id = "ui_confirmdate_unknown"
      if check_is_invalid_date(form, begin_time, end_time) then
        add_info_id = "ui_confirmdate_unsuited"
        btn_time.Visible = false
      end
      lbl_time.Text = gui.TextManager:GetFormatText(time_desc, format_time(form, begin_time), format_time(form, end_time), add_info_id)
      btn_sel.woman_info = nx_widestr("")
      btn_sel.man_info = nx_widestr("")
      lbl_rite.Visible = false
    end
    if not check_time_is_valid(form, sel_year, sel_month, sel_day, begin_time) then
      btn_time.Visible = false
    end
    if form.opt_type == MARRY_CONFIRMDATE_TYPE_LOOK then
      btn_time.Visible = false
    end
    nx_bind_script(btn_time, nx_current())
    nx_callback(btn_time, "on_click", "on_btn_time_confirm_click")
    nx_bind_script(btn_sel, nx_current())
    nx_callback(btn_sel, "on_click", "on_btn_time_sel_click")
  end
  form.gscrbox_time:ResetChildrenYPos()
end
function show_rite_list(form)
  local marry_rite_ini = nx_execute("util_functions", "get_ini", INI_FILE_MARRY_RITE)
  if not nx_is_valid(marry_rite_ini) then
    return 0
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return false
  end
  form.gscrbox_rite:DeleteAll()
  local sec_count = marry_rite_ini:GetSectionCount()
  for i = 0, sec_count - 1 do
    local section = marry_rite_ini:GetSectionByIndex(i)
    local price = marry_rite_ini:ReadString(i, "RitePrice", "")
    local photo = marry_rite_ini:ReadString(i, "RitePhoto", "")
    local name = marry_rite_ini:ReadString(i, "RiteName", "")
    local desc = marry_rite_ini:ReadString(i, "RiteDesc", "")
    local gbox_rite = create_ctrl_ex("GroupBox", "gbox_rite_" .. nx_string(i), form.gbox_one_rite, form.gscrbox_rite)
    local lbl_photo = create_ctrl_ex("Label", "lbl_photo_" .. nx_string(i), form.lbl_rite_photo, gbox_rite)
    local lbl_name = create_ctrl_ex("Label", "lbl_name_" .. nx_string(i), form.lbl_rite_name, gbox_rite)
    local mbox_desc = create_ctrl_ex("MultiTextBox", "mbox_desc_" .. nx_string(i), form.mbox_rite_desc, gbox_rite)
    local lbl_price_desc = create_ctrl_ex("Label", "lbl_price_desc_" .. nx_string(i), form.lbl_rite_price_desc, gbox_rite)
    local rbtn_price_1 = create_ctrl_ex("RadioButton", "rbtn_price_1_" .. nx_string(i), form.rbtn_rite_price_1, gbox_rite)
    local rbtn_price_2 = create_ctrl_ex("RadioButton", "rbtn_price_2_" .. nx_string(i), form.rbtn_rite_price_2, gbox_rite)
    local mbox_price_1 = create_ctrl_ex("MultiTextBox", "mbox_price_1_" .. nx_string(i), form.mbox_rite_price_1, gbox_rite)
    local mbox_price_2 = create_ctrl_ex("MultiTextBox", "mbox_price_2_" .. nx_string(i), form.mbox_rite_price_2, gbox_rite)
    local btn_detail = create_ctrl_ex("Button", "btn_detail_" .. nx_string(i), form.btn_detail, gbox_rite)
    local btn_buy = create_ctrl_ex("Button", "btn_buy_" .. nx_string(i), form.btn_buy, gbox_rite)
    if not (nx_is_valid(gbox_rite) and nx_is_valid(lbl_photo) and nx_is_valid(lbl_name) and nx_is_valid(mbox_desc) and nx_is_valid(lbl_price_desc) and nx_is_valid(rbtn_price_1) and nx_is_valid(rbtn_price_2) and nx_is_valid(mbox_price_1) and nx_is_valid(mbox_price_2) and nx_is_valid(btn_detail)) or not nx_is_valid(btn_buy) then
      break
    end
    local money_html_1 = get_format_capital_html(2, nx_int64(price))
    local money_html_2 = get_format_capital_html(4, nx_int64(price))
    lbl_photo.BackImage = photo
    lbl_name.Text = util_text(name)
    mbox_desc.HtmlText = util_text(desc)
    lbl_price_desc.Text = util_text("ui_huafei")
    mbox_price_1.HtmlText = money_html_1
    mbox_price_2.HtmlText = money_html_2
    if not switch_manager:CheckSwitchEnable(ST_FUNCTION_MARRY_USE_BIND_CARD) then
      mbox_price_2.Visible = false
      rbtn_price_1.Visible = false
      rbtn_price_2.Visible = false
    end
    btn_buy.rbtn_price_1 = rbtn_price_1
    btn_buy.rbtn_price_2 = rbtn_price_2
    btn_detail.rite = nx_int(section)
    btn_buy.rite = nx_int(section)
    btn_buy.rite_noney_1 = money_html_1
    btn_buy.rite_noney_2 = money_html_2
    btn_buy.rite_name = lbl_name.Text
    nx_bind_script(btn_detail, nx_current())
    nx_callback(btn_detail, "on_click", "on_btn_detail_click")
    nx_bind_script(btn_buy, nx_current())
    nx_callback(btn_buy, "on_click", "on_btn_buy_click")
  end
  form.gscrbox_rite:ResetChildrenYPos()
end
function get_rite_name(rite)
  local marry_rite_ini = nx_execute("util_functions", "get_ini", INI_FILE_MARRY_RITE)
  if not nx_is_valid(marry_rite_ini) then
    return ""
  end
  local index = marry_rite_ini:FindSectionIndex(nx_string(rite))
  if index < 0 then
    return ""
  end
  return marry_rite_ini:ReadString(index, "RiteName", "")
end
function check_is_invalid_date(form, begin_time, end_time)
  if not nx_is_valid(form.invaliddate_list) then
    return false
  end
  local sel_date = nx_string(form.sel_year) .. "." .. nx_string(form.sel_month) .. "." .. nx_string(form.sel_day)
  local child_tab = form.invaliddate_list:GetChildList()
  for i = 1, table.getn(child_tab) do
    local child = child_tab[i]
    if nx_is_valid(child) and nx_string(child.date) == sel_date then
      if nx_number(begin_time) >= nx_number(child.begin_time) and nx_number(begin_time) < nx_number(child.end_time) then
        return true
      end
      if nx_number(end_time) > nx_number(child.begin_time) and nx_number(end_time) <= nx_number(child.end_time) then
        return true
      end
    end
  end
  return false
end
function format_time(form, minute)
  local time = os.time({
    year = form.cur_year,
    month = form.cur_month,
    day = form.cur_day,
    hour = 0,
    sec = 0,
    min = 0
  })
  return os.date("%H:%M", nx_number(time) + nx_number(minute) * 60)
end
function show_data(type, data, ...)
  local form = util_get_form(FORM_MARRY_CONFIRMDATE, true)
  if not nx_is_valid(form) then
    return 0
  end
  if not nx_is_valid(form.wedding_list) then
    form.wedding_list = get_global_arraylist("marry_wedding_list")
  end
  if not nx_is_valid(form.wedding_list) then
    return 0
  end
  if not nx_is_valid(form.invaliddate_list) then
    form.invaliddate_list = get_global_arraylist("marry_invaliddate_list")
  end
  if not nx_is_valid(form.invaliddate_list) then
    return 0
  end
  for i = 1, table.getn(arg) / 3 do
    local y, m, d = nx_function("ext_decode_date", nx_double(arg[i * 3 - 2]))
    local begin_time = nx_number(arg[i * 3 - 1])
    local end_time = nx_number(arg[i * 3])
    local child = form.invaliddate_list:CreateChild(nx_string(i))
    if nx_is_valid(child) then
      child.date = nx_string(y) .. "." .. nx_string(m) .. "." .. nx_string(d)
      child.begin_time = begin_time
      child.end_time = end_time
    end
  end
  form.opt_type = nx_number(type)
  local data_tab = nx_function("ext_split_wstring_ex", data, nx_widestr("#$%"))
  for i = 1, table.getn(data_tab) / 7 do
    local man_name = nx_widestr(data_tab[(i - 1) * 7 + 1])
    local woman_name = nx_widestr(data_tab[(i - 1) * 7 + 2])
    local man_info = nx_widestr(data_tab[(i - 1) * 7 + 3])
    local woman_info = nx_widestr(data_tab[(i - 1) * 7 + 4])
    local date = nx_number(data_tab[(i - 1) * 7 + 5])
    local time = nx_number(data_tab[(i - 1) * 7 + 6])
    local rite = nx_number(data_tab[(i - 1) * 7 + 7])
    local y, m, d = nx_function("ext_decode_date", date)
    local name = nx_string(y) .. "." .. nx_string(m) .. "." .. nx_string(d)
    local child = form.wedding_list:GetChild(name)
    if not nx_is_valid(child) then
      child = form.wedding_list:CreateChild(name)
    end
    local sub_child = child:GetChild(nx_string(time))
    if not nx_is_valid(sub_child) then
      sub_child = child:CreateChild(nx_string(time))
    end
    if nx_is_valid(sub_child) then
      sub_child.man_name = man_name
      sub_child.woman_name = woman_name
      sub_child.man_info = man_info
      sub_child.woman_info = woman_info
      sub_child.rite = rite
    end
  end
  util_show_form(FORM_MARRY_CONFIRMDATE, true)
end
