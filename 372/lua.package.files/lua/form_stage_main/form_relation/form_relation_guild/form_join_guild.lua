require("custom_sender")
require("util_gui")
function main_form_init(self)
  self.Fixed = false
  self.guild_list = nx_create("ArrayList", nx_current())
  self.respond_list = nx_create("ArrayList", nx_current())
  self.guild_pageno = 1
  self.respond_pageno = 1
  self.page_next_ok = 1
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.lbl_respond.Visible = false
  form.rbtn_1.Checked = true
  form.guild_list:ClearChild()
  clear_ui_info(form)
  request_guild_info(form.guild_pageno)
  return 1
end
function on_main_form_close(form)
  form.guild_list:ClearChild()
  form.respond_list:ClearChild()
  nx_destroy(form)
end
function is_in_guild()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if client_player:FindProp("GuildName") then
    local guild_name = client_player:QueryProp("GuildName")
    if nx_widestr(guild_name) ~= nx_widestr("") then
      return true
    end
  end
  return false
end
function request_guild_info(pageno)
  local from = (pageno - 1) * 10
  local to = pageno * 10
  custom_request_guild_info(from, to)
end
function request_respond_info(pageno)
  local from = (pageno - 1) * 10
  local to = pageno * 10
  custom_request_guild_respond_list(from, to)
end
function load_respond_info(from, to, ...)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_join_guild")
  if not nx_is_valid(form) then
    return
  end
  if from < 0 then
    form.page_next_ok = 0
    return
  end
  form.page_next_ok = 1
  local size = table.getn(arg)
  if size <= 0 or size % 5 ~= 0 then
    return
  end
  clear_ui_info(form)
  form.respond_pageno = from / 10 + 1
  local rows = size / 5
  if 10 < rows then
    rows = 10
  end
  form.respond_list:ClearChild()
  for i = 1, rows do
    local rec_obj = form.respond_list:CreateChild(nx_string(i))
    idx_base = (i - 1) * 5
    rec_obj.guild_name = arg[idx_base + 1]
    rec_obj.level = arg[idx_base + 2]
    rec_obj.captain = arg[idx_base + 3]
    rec_obj.num = arg[idx_base + 4]
    rec_obj.purpose = arg[idx_base + 5]
    rec_obj.ability = ""
    rec_obj.school = ""
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local guild_name = client_player:QueryProp("GuildName")
  form.textgrid_1:BeginUpdate()
  form.textgrid_1:ClearRow()
  form.lbl_respond.Visible = false
  for i = 1, rows do
    local row = form.textgrid_1:InsertRow(-1)
    local rec_obj = form.respond_list:GetChild(nx_string(i))
    form.textgrid_1:SetGridText(row, 0, nx_widestr(rec_obj.guild_name))
    if nx_string(guild_name) == nx_string(rec_obj.guild_name) then
      form.lbl_respond.Visible = true
      form.lbl_respond.Left = 33
      form.lbl_respond.Top = 80 + row * 29
    end
  end
  form.textgrid_1:EndUpdate()
  form.textgrid_1:SelectRow(0)
  update_selected_guild_info(form, 0)
end
function load_guild_info(from, to, ...)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_join_guild")
  if not nx_is_valid(form) then
    return
  end
  if from < 0 then
    form.page_next_ok = 0
    return
  end
  form.page_next_ok = 1
  form.lbl_respond.Visible = false
  local size = table.getn(arg)
  if size <= 0 or size % 7 ~= 0 then
    return
  end
  clear_ui_info(form)
  form.guild_pageno = from / 10 + 1
  local rows = size / 7
  if 10 < rows then
    rows = 10
  end
  form.guild_list:ClearChild()
  for i = 1, rows do
    local rec_obj = form.guild_list:CreateChild(nx_string(i))
    idx_base = (i - 1) * 7
    rec_obj.guild_name = arg[idx_base + 1]
    rec_obj.level = arg[idx_base + 2]
    rec_obj.captain = arg[idx_base + 3]
    rec_obj.num = arg[idx_base + 4]
    rec_obj.purpose = arg[idx_base + 5]
    rec_obj.ability = arg[idx_base + 6]
    rec_obj.school = arg[idx_base + 7]
  end
  form.textgrid_1:BeginUpdate()
  form.textgrid_1:ClearRow()
  for i = 1, rows do
    local row = form.textgrid_1:InsertRow(-1)
    local rec_obj = form.guild_list:GetChild(nx_string(i))
    form.textgrid_1:SetGridText(row, 0, nx_widestr(rec_obj.guild_name))
  end
  form.textgrid_1:EndUpdate()
  form.textgrid_1:SelectRow(0)
  update_selected_guild_info(form, 0)
end
function update_selected_guild_info(form, index)
  local rec_obj = nx_null()
  if form.rbtn_1.Checked then
    rec_obj = form.guild_list:GetChild(nx_string(index + 1))
  else
    rec_obj = form.respond_list:GetChild(nx_string(index + 1))
  end
  if not nx_is_valid(rec_obj) then
    return
  end
  form.lbl_3.Text = nx_widestr(rec_obj.guild_name)
  form.lbl_8.Text = nx_widestr(rec_obj.level)
  form.lbl_9.Text = nx_widestr(rec_obj.captain)
  form.lbl_10.Text = nx_widestr(rec_obj.num)
  form.lbl_24.Text = nx_widestr(util_text("desc_title00" .. nx_string(rec_obj.ability)))
  form.redit_1.Text = nx_widestr(rec_obj.purpose)
  local school_table = util_split_string(nx_string(rec_obj.school), ",")
  local school_count = table.getn(school_table)
  form.textgrid_school:ClearRow()
  if nx_int(school_count) > nx_int(0) then
    form.textgrid_school:BeginUpdate()
    for row = 0, school_count - 2 do
      form.textgrid_school:InsertRow(-1)
      form.textgrid_school:SetGridText(row, 0, nx_widestr(util_text("ui_" .. nx_string(school_table[row + 1]))))
    end
    form.textgrid_school:EndUpdate()
  end
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if form.rbtn_1.Checked and form.page_next_ok > 0 then
    request_guild_info(form.guild_pageno + 1)
    return 1
  end
  if form.rbtn_2.Checked and form.page_next_ok > 0 then
    request_respond_info(form.respond_pageno + 1)
    return 1
  end
end
function on_btn_last_click(btn)
  local form = btn.ParentForm
  if form.rbtn_1.Checked and form.guild_pageno > 1 then
    request_guild_info(form.guild_pageno - 1)
    return 1
  end
  if form.rbtn_2.Checked and 1 < form.respond_pageno then
    request_respond_info(form.respond_pageno - 1)
    return 1
  end
  return 1
end
function on_btn_join_click(btn)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_join_guild")
  if not nx_is_valid(form) then
    return
  end
  guild_name = form.textgrid_1:GetGridText(form.textgrid_1.RowSelectIndex, 0)
  if form.rbtn_1.Checked then
    custom_request_join_guild(guild_name)
    form:Close()
  else
    custom_request_respond_guild(0, guild_name)
    nx_pause(0)
    request_guild_info(form.guild_pageno)
    form.rbtn_1.Checked = true
  end
end
function on_select_guild(self, index)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_join_guild")
  if not nx_is_valid(form) then
    return
  end
  update_selected_guild_info(form, index)
  return 1
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if form.rbtn_1.Checked then
    form:Close()
  else
    custom_request_respond_guild(1, "")
  end
end
function on_rbtn_1_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.lbl_7.Text = nx_widestr(util_text("ui_guild_mem_count"))
  form.btn_join.Text = nx_widestr(util_text("ui_guild_request_join"))
  form.btn_cancel.Text = nx_widestr(util_text("ui_cancel"))
  form.guild_list:ClearChild()
  clear_ui_info(form)
  request_guild_info(form.guild_pageno)
end
function on_rbtn_2_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.lbl_7.Text = nx_widestr(util_text("ui_guild_responded"))
  form.btn_join.Text = nx_widestr(util_text("ui_guild_respond"))
  form.btn_cancel.Text = nx_widestr(util_text("ui_guild_cancel_respond"))
  form.respond_list:ClearChild()
  clear_ui_info(form)
  request_respond_info(form.respond_pageno)
end
function clear_ui_info(form)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_3.Text = nx_widestr("")
  form.lbl_8.Text = nx_widestr("")
  form.lbl_9.Text = nx_widestr("")
  form.lbl_10.Text = nx_widestr("")
  form.lbl_24.Text = nx_widestr("")
  form.redit_1.Text = nx_widestr("")
  form.textgrid_1:ClearRow()
  form.textgrid_school:ClearRow()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_search_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_relation_guild\\form_search_guild", true)
  if not nx_is_valid(form) then
    return 0
  end
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_relation\\form_relation_guild\\form_search_guild", true)
end
