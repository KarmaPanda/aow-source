require("util_functions")
require("share\\client_custom_define")
local CLIENT_SUBMSG_AWARD_GUILDWAR_RANK = 40
local TYPE_AWARD_WIN_RANK = 3
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  gui.Desktop:ToFront(form)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_award_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_AWARD_GUILDWAR_RANK))
end
function on_btn_award_desc_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_1.Visible = not form.groupbox_1.Visible
end
function on_btn_desc_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_1.Visible = false
end
function show_form(...)
  if arg == nil then
    return
  end
  local arg_num = table.getn(arg)
  if arg_num == nil then
    return
  end
  local self_date_num = 7
  if nx_int(arg_num) < nx_int(self_date_num) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuildDomainAwardExtra.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(nx_string(TYPE_AWARD_WIN_RANK))
  if index < 0 then
    return
  end
  local cycle = ini:ReadInteger(index, "Cycle", 3)
  local form = nx_execute("util_gui", "util_get_form", nx_current(), true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  local award_flag = nx_int(arg[1])
  local start_date = nx_double(arg[2])
  local self_rank_no = nx_int(arg[3])
  local self_guild_name = nx_widestr(arg[4])
  local self_win_cnt = nx_int(arg[5])
  local self_leader_name = nx_widestr(arg[6])
  local show_flag = nx_int(arg[7])
  if nx_int(self_rank_no) > nx_int(0) then
    form.lbl_self_no.Text = nx_widestr(self_rank_no)
    form.lbl_self_guild_name.Text = nx_widestr(self_guild_name)
    form.lbl_self_win_cnt.Text = nx_widestr(self_win_cnt)
    form.lbl_self_leader_name.Text = nx_widestr(self_leader_name)
  end
  form.btn_award.Enabled = false
  if nx_int(award_flag) == nx_int(1) then
    form.btn_award.Enabled = true
  end
  form.btn_award.Visible = false
  if nx_int(show_flag) == nx_int(1) then
    form.btn_award.Visible = true
  end
  local end_date = nx_double(start_date) + nx_double(cycle * 7 - 1)
  local b_year, b_month, b_day, b_hour, b_mins, b_sec = nx_function("ext_decode_date", nx_double(start_date))
  local e_year, e_month, e_day, e_hour, e_mins, e_sec = nx_function("ext_decode_date", nx_double(end_date))
  local date_text = util_format_string(nx_string("ui_guildnew_jiaozi_time"), nx_int(b_year), nx_int(b_month), nx_int(b_day), nx_int(e_year), nx_int(e_month), nx_int(e_day))
  form.lbl_date.Text = nx_widestr(date_text)
  form.textgrid_rank:BeginUpdate()
  form.textgrid_rank:ClearRow()
  form.textgrid_rank:SetColTitle(0, nx_widestr(util_text("ui_activity_rank")))
  form.textgrid_rank:SetColTitle(1, nx_widestr(util_text("guild_domain_fushi_bangpaiming")))
  form.textgrid_rank:SetColTitle(2, nx_widestr(util_text("guild_domain_fushi_jifen")))
  form.textgrid_rank:SetColTitle(3, nx_widestr(util_text("guild_domain_fushi_bangzhu")))
  local col_num = 3
  local item_num = math.floor((arg_num - self_date_num) / col_num)
  local base_index = self_date_num
  for i = 1, item_num do
    local guild_name = nx_widestr(arg[base_index + 1])
    local win_cnt = nx_int(arg[base_index + 2])
    local leader_name = nx_widestr(arg[base_index + 3])
    local row = form.textgrid_rank:InsertRow(-1)
    form.textgrid_rank:SetGridText(row, 0, nx_widestr(i))
    form.textgrid_rank:SetGridText(row, 1, nx_widestr(guild_name))
    form.textgrid_rank:SetGridText(row, 2, nx_widestr(win_cnt))
    form.textgrid_rank:SetGridText(row, 3, nx_widestr(leader_name))
    base_index = base_index + col_num
  end
  form.textgrid_rank:EndUpdate()
end
