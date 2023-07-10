require("util_gui")
require("custom_sender")
function main_form_init(form)
  form.Fixed = false
  form.guild_pageno = 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.guild_list = get_global_arraylist(nx_current() .. "guild_list")
  if nx_is_valid(form.guild_list) then
    form.guild_list:ClearChild()
  end
  clear_ui_info(form)
  custom_request_fire_guild_info()
end
function on_main_form_close(form)
  if nx_is_valid(form.guild_list) then
    form.guild_list:ClearChild()
    nx_destroy(form.guild_list)
  end
  nx_destroy(form)
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if form.page_next_ok > 0 then
    request_fire_guild_info(form.guild_pageno + 1)
  end
end
function on_btn_last_click(btn)
  local form = btn.ParentForm
  if form.guild_pageno > 1 then
    request_fire_guild_info(form.guild_pageno - 1)
  end
  return 1
end
function on_btn_join_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local rec_obj = nx_null()
  local index = form.textgrid_1.RowSelectIndex
  rec_obj = form.guild_list:GetChild(nx_string(index + 1))
  if not nx_is_valid(rec_obj) then
    return
  end
  local guild_name = rec_obj.guild_name
  local domain_id = tonumber(string.sub(rec_obj.dipan, string.len("ui_dipan_") + 1, -1))
  custom_request_fire_guild_task(guild_name, domain_id)
  form:Close()
end
function on_select_guild(self, index)
  local form = nx_value("form_stage_main\\form_guild_fire\\form_guild_fire")
  if not nx_is_valid(form) then
    return
  end
  update_selected_guild_info(form, index)
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
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
function load_fire_guild_info(...)
  local form = nx_value("form_stage_main\\form_guild_fire\\form_guild_fire")
  if not nx_is_valid(form) then
    return
  end
  local size = table.getn(arg)
  if size <= 0 or size % 6 ~= 0 then
    return
  end
  clear_ui_info(form)
  local rows = size / 6
  form.guild_list:ClearChild()
  for i = 1, rows do
    local rec_obj = form.guild_list:CreateChild(nx_string(i))
    idx_base = (i - 1) * 6
    rec_obj.guild_name = arg[idx_base + 1]
    rec_obj.level = arg[idx_base + 2]
    rec_obj.captain = arg[idx_base + 3]
    rec_obj.num = arg[idx_base + 4]
    rec_obj.dipan = "ui_dipan_" .. arg[idx_base + 5]
    rec_obj.dipanmaoshu = "ui_dipanmiaoshu_" .. arg[idx_base + 5]
    rec_obj.purpose = arg[idx_base + 6]
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
  rec_obj = form.guild_list:GetChild(nx_string(index + 1))
  if not nx_is_valid(rec_obj) then
    return
  end
  form.lbl_3.Text = nx_widestr(rec_obj.guild_name)
  form.lbl_8.Text = nx_widestr(rec_obj.level)
  form.lbl_9.Text = nx_widestr(rec_obj.captain)
  form.lbl_10.Text = nx_widestr(rec_obj.num)
  form.lbl_14.Text = nx_widestr(util_text(rec_obj.dipan))
  form.lbl_15.Text = nx_widestr(util_text(rec_obj.dipanmaoshu))
  form.redit_1.Text = nx_widestr(rec_obj.purpose)
end
function clear_ui_info(form)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_3.Text = nx_widestr("")
  form.lbl_8.Text = nx_widestr("")
  form.lbl_9.Text = nx_widestr("")
  form.lbl_10.Text = nx_widestr("")
  form.lbl_14.Text = nx_widestr("")
  form.lbl_15.Text = nx_widestr("")
  form.redit_1.Text = nx_widestr("")
  form.textgrid_1:ClearRow()
end
