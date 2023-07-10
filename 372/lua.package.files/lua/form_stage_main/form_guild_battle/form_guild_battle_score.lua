require("util_gui")
require("custom_sender")
local FORM_INFO = "form_stage_main\\form_guild_battle\\form_guild_battle_score"
function on_main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 4
  form.sucess_font = nx_string(form.lbl_sucess.ForeColor)
  form.sucess_img = nx_widestr(form.lbl_sucess.BackImage)
  form.failed_font = nx_string(form.lbl_failed.ForeColor)
  form.failed_img = nx_widestr(form.lbl_failed.BackImage)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(5000, -1, FORM_INFO, "refresh_ui", form, -1, -1)
  end
end
function on_main_form_close(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_string(FORM_INFO), "refresh_ui", form)
  end
  nx_destroy(form)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_btn_exit_click(btn)
  custom_cw_back()
end
function refresh_ui(form)
  if nx_is_valid(form) then
    custom_request_guildbl()
  end
end
function open_balance_info_form()
  local form = util_get_form(FORM_INFO, false)
  if not nx_is_valid(form) then
    form = util_get_form(FORM_INFO, true)
    form:Show()
    form.Visible = true
    custom_request_guildbl()
  else
    form:Close()
  end
end
function refresh_balance1(...)
  local gui = nx_value("gui")
  local form = nx_value(nx_string(FORM_INFO))
  if not nx_is_valid(form) then
    return
  end
  local valid_camp1 = nx_number(arg[1])
  local sucess_camp1 = nx_int(arg[2])
  local gui = nx_value("gui")
  local start_num = 3
  local single_info_count = 7
  local gui = nx_value("gui")
  local max_score1 = 0
  local max_good1 = 0
  form.textgrid_1:BeginUpdate()
  form.textgrid_1:SetColTitle(0, nx_widestr(util_text("ui_guild_battle_count_01")))
  form.textgrid_1:SetColTitle(1, nx_widestr(util_text("ui_guild_battle_count_02")))
  form.textgrid_1:SetColTitle(2, nx_widestr(util_text("ui_guild_battle_count_03")))
  form.textgrid_1:SetColTitle(3, nx_widestr(util_text("ui_guild_battle_count_04")))
  form.textgrid_1:SetColTitle(4, nx_widestr(util_text("ui_guild_battle_count_05")))
  form.textgrid_1:SetColTitle(5, nx_widestr(util_text("ui_guild_battle_count_07")))
  form.textgrid_1:ClearRow()
  for i = 1, valid_camp1 do
    local index = start_num + (i - 1) * single_info_count
    local row = form.textgrid_1:InsertRow(-1)
    local name = nx_widestr(arg[index])
    local kill = nx_int(arg[index + 1])
    local injured = nx_int(arg[index + 2])
    local dead = nx_int(arg[index + 3])
    local damage = nx_int64(arg[index + 4])
    local score = nx_int(arg[index + 5])
    form.textgrid_1:SetGridText(row, 0, nx_widestr(name))
    form.textgrid_1:SetGridText(row, 1, nx_widestr(kill))
    form.textgrid_1:SetGridText(row, 2, nx_widestr(injured))
    form.textgrid_1:SetGridText(row, 3, nx_widestr(dead))
    form.textgrid_1:SetGridText(row, 4, nx_widestr(damage))
    form.textgrid_1:SetGridText(row, 5, nx_widestr(score))
    if nx_int(score) > nx_int(max_score1) then
      max_good1 = i
      max_score1 = score
    end
  end
  form.textgrid_1:EndUpdate()
  local start_numex = start_num + valid_camp1 * single_info_count
  local valid_camp2 = nx_number(arg[start_numex])
  local sucess_camp2 = nx_int(arg[start_numex + 1])
  local start_num2 = start_numex + 1
  form.textgrid_2:BeginUpdate()
  form.textgrid_2:SetColTitle(0, nx_widestr(util_text("ui_guild_battle_count_01")))
  form.textgrid_2:SetColTitle(1, nx_widestr(util_text("ui_guild_battle_count_02")))
  form.textgrid_2:SetColTitle(2, nx_widestr(util_text("ui_guild_battle_count_03")))
  form.textgrid_2:SetColTitle(3, nx_widestr(util_text("ui_guild_battle_count_04")))
  form.textgrid_2:SetColTitle(4, nx_widestr(util_text("ui_guild_battle_count_05")))
  form.textgrid_2:SetColTitle(5, nx_widestr(util_text("ui_guild_battle_count_07")))
  form.textgrid_2:ClearRow()
  local max_score2 = 0
  local max_good2 = 0
  for i = 1, valid_camp2 do
    local index = start_num2 + (i - 1) * single_info_count
    local row = form.textgrid_2:InsertRow(-1)
    local name = nx_widestr(arg[index + 1])
    local kill = nx_int(arg[index + 2])
    local injured = nx_int(arg[index + 3])
    local dead = nx_int(arg[index + 4])
    local damage = nx_int64(arg[index + 5])
    local score = nx_int(arg[index + 6])
    form.textgrid_2:SetGridText(row, 0, nx_widestr(name))
    form.textgrid_2:SetGridText(row, 1, nx_widestr(kill))
    form.textgrid_2:SetGridText(row, 2, nx_widestr(injured))
    form.textgrid_2:SetGridText(row, 3, nx_widestr(dead))
    form.textgrid_2:SetGridText(row, 4, nx_widestr(damage))
    form.textgrid_2:SetGridText(row, 5, nx_widestr(score))
    if nx_int(score) > nx_int(max_score2) then
      max_good2 = i
      max_score2 = score
    end
  end
  form.textgrid_2:EndUpdate()
  if nx_int(1) == nx_int(sucess_camp1) then
    form.lbl_sucess.Visible = true
    form.lbl_sucess.ForeColor = form.failed_font
    form.lbl_sucess.BackImage = nx_string(form.failed_img)
  elseif nx_int(2) == nx_int(sucess_camp1) then
    form.lbl_sucess.Visible = true
    form.lbl_sucess.ForeColor = form.sucess_font
    form.lbl_sucess.BackImage = nx_string(form.sucess_img)
  elseif nx_int(0) == nx_int(sucess_camp1) then
    form.lbl_sucess.Visible = false
  end
  if nx_int(2) == nx_int(sucess_camp2) then
    form.lbl_failed.Visible = true
    form.lbl_failed.ForeColor = nx_string(form.sucess_font)
    form.lbl_failed.BackImage = nx_string(form.sucess_img)
  elseif nx_int(2) == nx_int(sucess_camp2) then
    form.lbl_failed.Visible = true
    form.lbl_failed.ForeColor = nx_string(form.failed_font)
    form.lbl_failed.BackImage = nx_string(form.failed_img)
  elseif nx_int(0) == nx_int(sucess_camp2) then
    form.lbl_failed.Visible = false
  end
  if nx_int(max_good1) > nx_int(0) then
    form.lbl_good1.Top = form.textgrid_1.Top + form.textgrid_1.RowHeight * max_good1
  else
    form.lbl_good1.Visible = false
  end
  if nx_int(max_good2) > nx_int(0) then
    form.lbl_good2.Top = form.textgrid_2.Top + form.textgrid_2.RowHeight * max_good2
  else
    form.lbl_good2.Visible = false
  end
end
function refresh_balance2(...)
  local gui = nx_value("gui")
  local form = nx_value(nx_string(FORM_INFO))
  if not nx_is_valid(form) then
    return
  end
  local num = table.getn(arg)
  local valid_camp1 = nx_number(arg[1])
  local sucess_camp1 = nx_int(arg[2])
  local gui = nx_value("gui")
  local start_num = 3
  local single_info_count = 7
  form.textgrid_1:BeginUpdate()
  form.textgrid_1:SetColTitle(0, nx_widestr(util_text("ui_guild_battle_count_01")))
  form.textgrid_1:SetColTitle(1, nx_widestr(util_text("ui_guild_battle_count_02")))
  form.textgrid_1:SetColTitle(2, nx_widestr(util_text("ui_guild_battle_count_03")))
  form.textgrid_1:SetColTitle(3, nx_widestr(util_text("ui_guild_battle_count_04")))
  form.textgrid_1:SetColTitle(4, nx_widestr(util_text("ui_guild_battle_count_05")))
  form.textgrid_1:SetColTitle(5, nx_widestr(util_text("ui_guild_battle_count_06")))
  form.textgrid_1:SetColTitle(6, nx_widestr(util_text("ui_guild_battle_count_07")))
  form.textgrid_1:ClearRow()
  local max_score1 = 0
  local max_good1 = 0
  for i = 1, valid_camp1 do
    local index = start_num + (i - 1) * single_info_count
    local row = form.textgrid_1:InsertRow(-1)
    local name = nx_widestr(arg[index])
    local kill = nx_int(arg[index + 1])
    local injured = nx_int(arg[index + 2])
    local dead = nx_int(arg[index + 3])
    local damage = nx_int64(arg[index + 4])
    local score = nx_int(arg[index + 5])
    local destroynum = nx_int(arg[index + 6])
    form.textgrid_1:SetGridText(row, 0, nx_widestr(name))
    form.textgrid_1:SetGridText(row, 1, nx_widestr(kill))
    form.textgrid_1:SetGridText(row, 2, nx_widestr(injured))
    form.textgrid_1:SetGridText(row, 3, nx_widestr(dead))
    form.textgrid_1:SetGridText(row, 4, nx_widestr(damage))
    form.textgrid_1:SetGridText(row, 5, nx_widestr(destroynum))
    form.textgrid_1:SetGridText(row, 6, nx_widestr(score))
    if nx_int(score) > nx_int(max_score1) then
      max_good1 = i
      max_score1 = score
    end
  end
  form.textgrid_1:EndUpdate()
  local start_numex = start_num + valid_camp1 * single_info_count
  local valid_camp2 = nx_number(arg[start_numex])
  local sucess_camp2 = nx_int(arg[start_numex + 1])
  local start_num2 = start_numex + 1
  form.textgrid_2:BeginUpdate()
  form.textgrid_2:SetColTitle(0, nx_widestr(util_text("ui_guild_battle_count_01")))
  form.textgrid_2:SetColTitle(1, nx_widestr(util_text("ui_guild_battle_count_02")))
  form.textgrid_2:SetColTitle(2, nx_widestr(util_text("ui_guild_battle_count_03")))
  form.textgrid_2:SetColTitle(3, nx_widestr(util_text("ui_guild_battle_count_04")))
  form.textgrid_2:SetColTitle(4, nx_widestr(util_text("ui_guild_battle_count_05")))
  form.textgrid_2:SetColTitle(5, nx_widestr(util_text("ui_guild_battle_count_06")))
  form.textgrid_2:SetColTitle(6, nx_widestr(util_text("ui_guild_battle_count_07")))
  form.textgrid_2:ClearRow()
  local max_score2 = 0
  local max_good2 = 0
  for i = 1, valid_camp2 do
    local index = start_num2 + (i - 1) * single_info_count
    local row = form.textgrid_2:InsertRow(-1)
    local name = nx_widestr(arg[index + 1])
    local kill = nx_int(arg[index + 2])
    local injured = nx_int(arg[index + 3])
    local dead = nx_int(arg[index + 4])
    local damage = nx_int64(arg[index + 5])
    local score = nx_int(arg[index + 6])
    local destroynum = nx_int(arg[index + 7])
    form.textgrid_2:SetGridText(row, 0, nx_widestr(name))
    form.textgrid_2:SetGridText(row, 1, nx_widestr(kill))
    form.textgrid_2:SetGridText(row, 2, nx_widestr(injured))
    form.textgrid_2:SetGridText(row, 3, nx_widestr(dead))
    form.textgrid_2:SetGridText(row, 4, nx_widestr(damage))
    form.textgrid_2:SetGridText(row, 5, nx_widestr(destroynum))
    form.textgrid_2:SetGridText(row, 6, nx_widestr(score))
    if nx_int(score) > nx_int(max_score2) then
      max_good2 = i
      max_score2 = score
    end
  end
  form.textgrid_2:EndUpdate()
  if nx_int(1) == nx_int(sucess_camp1) then
    form.lbl_sucess.Visible = true
    form.lbl_sucess.ForeColor = form.failed_font
    form.lbl_sucess.BackImage = nx_string(form.failed_img)
  elseif nx_int(2) == nx_int(sucess_camp1) then
    form.lbl_sucess.Visible = true
    form.lbl_sucess.ForeColor = form.sucess_font
    form.lbl_sucess.BackImage = nx_string(form.sucess_img)
  elseif nx_int(0) == nx_int(sucess_camp1) then
    form.lbl_sucess.Visible = false
  end
  if nx_int(2) == nx_int(sucess_camp2) then
    form.lbl_failed.Visible = true
    form.lbl_failed.ForeColor = nx_string(form.sucess_font)
    form.lbl_failed.BackImage = nx_string(form.sucess_img)
  elseif nx_int(2) == nx_int(sucess_camp2) then
    form.lbl_failed.Visible = true
    form.lbl_failed.ForeColor = nx_string(form.failed_font)
    form.lbl_failed.BackImage = nx_string(form.failed_img)
  elseif nx_int(0) == nx_int(sucess_camp2) then
    form.lbl_failed.Visible = false
  end
  if nx_int(max_good1) > nx_int(0) then
    form.lbl_good1.Top = form.textgrid_1.Top + form.textgrid_1.RowHeight * max_good1
  else
    form.lbl_good1.Visible = false
  end
  if nx_int(max_good2) > nx_int(0) then
    form.lbl_good2.Top = form.textgrid_2.Top + form.textgrid_2.RowHeight * max_good2
  else
    form.lbl_good2.Visible = false
  end
end
function refresh_power(...)
  local gui = nx_value("gui")
  local form = nx_value(nx_string(FORM_INFO))
  if not nx_is_valid(form) then
    return
  end
  local valid_camp1 = nx_number(arg[1])
  local sucess_camp1 = nx_int(arg[2])
  local gui = nx_value("gui")
  local start_num = 3
  local single_info_count = 7
  local gui = nx_value("gui")
  local max_score1 = 0
  local max_good1 = 0
  form.textgrid_1:BeginUpdate()
  form.textgrid_1:SetColTitle(0, nx_widestr(util_text("ui_guild_battle_count_01")))
  form.textgrid_1:SetColTitle(1, nx_widestr(util_text("ui_guild_battle_count_02")))
  form.textgrid_1:SetColTitle(2, nx_widestr(util_text("ui_guild_battle_count_03")))
  form.textgrid_1:SetColTitle(3, nx_widestr(util_text("ui_guild_battle_count_04")))
  form.textgrid_1:SetColTitle(4, nx_widestr(util_text("ui_guild_battle_count_05")))
  form.textgrid_1:SetColTitle(5, nx_widestr(util_text("ui_guild_battle_count_07")))
  form.textgrid_1:ClearRow()
  for i = 1, valid_camp1 do
    local index = start_num + (i - 1) * single_info_count
    local row = form.textgrid_1:InsertRow(-1)
    local name = nx_widestr(arg[index])
    local kill = nx_int(arg[index + 1])
    local injured = nx_int(arg[index + 2])
    local dead = nx_int(arg[index + 3])
    local damage = nx_int64(arg[index + 4])
    local score = nx_int(arg[index + 5])
    form.textgrid_1:SetGridText(row, 0, nx_widestr(name))
    form.textgrid_1:SetGridText(row, 1, nx_widestr(kill))
    form.textgrid_1:SetGridText(row, 2, nx_widestr(injured))
    form.textgrid_1:SetGridText(row, 3, nx_widestr(dead))
    form.textgrid_1:SetGridText(row, 4, nx_widestr(damage))
    form.textgrid_1:SetGridText(row, 5, nx_widestr(score))
    if nx_int(score) > nx_int(max_score1) then
      max_good1 = i
      max_score1 = score
    end
  end
  form.textgrid_1:EndUpdate()
  local start_numex = start_num + valid_camp1 * single_info_count
  local valid_camp2 = nx_number(arg[start_numex])
  local sucess_camp2 = nx_int(arg[start_numex + 1])
  local start_num2 = start_numex + 1
  form.textgrid_2:BeginUpdate()
  form.textgrid_2:SetColTitle(0, nx_widestr(util_text("ui_guild_battle_count_01")))
  form.textgrid_2:SetColTitle(1, nx_widestr(util_text("ui_guild_battle_count_02")))
  form.textgrid_2:SetColTitle(2, nx_widestr(util_text("ui_guild_battle_count_03")))
  form.textgrid_2:SetColTitle(3, nx_widestr(util_text("ui_guild_battle_count_04")))
  form.textgrid_2:SetColTitle(4, nx_widestr(util_text("ui_guild_battle_count_05")))
  form.textgrid_2:SetColTitle(5, nx_widestr(util_text("ui_guild_battle_count_07")))
  form.textgrid_2:ClearRow()
  local max_score2 = 0
  local max_good2 = 0
  for i = 1, valid_camp2 do
    local index = start_num2 + (i - 1) * single_info_count
    local row = form.textgrid_2:InsertRow(-1)
    local name = nx_widestr(arg[index + 1])
    local kill = nx_int(arg[index + 2])
    local injured = nx_int(arg[index + 3])
    local dead = nx_int(arg[index + 4])
    local damage = nx_int64(arg[index + 5])
    local score = nx_int(arg[index + 6])
    form.textgrid_2:SetGridText(row, 0, nx_widestr(name))
    form.textgrid_2:SetGridText(row, 1, nx_widestr(kill))
    form.textgrid_2:SetGridText(row, 2, nx_widestr(injured))
    form.textgrid_2:SetGridText(row, 3, nx_widestr(dead))
    form.textgrid_2:SetGridText(row, 4, nx_widestr(damage))
    form.textgrid_2:SetGridText(row, 5, nx_widestr(score))
    if nx_int(score) > nx_int(max_score2) then
      max_good2 = i
      max_score2 = score
    end
  end
  form.textgrid_2:EndUpdate()
  if nx_int(1) == nx_int(sucess_camp1) then
    form.lbl_sucess.Visible = true
    form.lbl_sucess.ForeColor = form.failed_font
    form.lbl_sucess.BackImage = nx_string(form.failed_img)
  elseif nx_int(2) == nx_int(sucess_camp1) then
    form.lbl_sucess.Visible = true
    form.lbl_sucess.ForeColor = form.sucess_font
    form.lbl_sucess.BackImage = nx_string(form.sucess_img)
  elseif nx_int(0) == nx_int(sucess_camp1) then
    form.lbl_sucess.Visible = false
  end
  if nx_int(2) == nx_int(sucess_camp2) then
    form.lbl_failed.Visible = true
    form.lbl_failed.ForeColor = nx_string(form.sucess_font)
    form.lbl_failed.BackImage = nx_string(form.sucess_img)
  elseif nx_int(2) == nx_int(sucess_camp2) then
    form.lbl_failed.Visible = true
    form.lbl_failed.ForeColor = nx_string(form.failed_font)
    form.lbl_failed.BackImage = nx_string(form.failed_img)
  elseif nx_int(0) == nx_int(sucess_camp2) then
    form.lbl_failed.Visible = false
  end
  if nx_int(max_good1) > nx_int(0) then
    form.lbl_good1.Top = form.textgrid_1.Top + form.textgrid_1.RowHeight * max_good1
  else
    form.lbl_good1.Visible = false
  end
  if nx_int(max_good2) > nx_int(0) then
    form.lbl_good2.Top = form.textgrid_2.Top + form.textgrid_2.RowHeight * max_good2
  else
    form.lbl_good2.Visible = false
  end
end
function close_form()
  local form = util_get_form(FORM_INFO, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_server_msg(war_type, ...)
  local form = util_get_form(FORM_INFO, false)
  if not nx_is_valid(form) then
    form = util_get_form(FORM_INFO, true)
    form:Show()
    form.Visible = true
  end
  if nx_int(war_type) == nx_int(101) then
    refresh_balance1(unpack(arg))
  elseif nx_int(war_type) == nx_int(102) then
    refresh_balance2(unpack(arg))
  else
    refresh_power(unpack(arg))
  end
end
