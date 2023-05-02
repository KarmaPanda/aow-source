require("util_functions")
require("custom_sender")
require("util_gui")
require("share\\static_data_type")
require("share\\itemtype_define")
require("define\\tip_define")
require("util_static_data")
require("tips_data")
require("util_functions")
local CLIENT_CUSTOMMSG_GUILD_CROSS_WAR = 776
local CTS_GCW_QUERY_FIGHT_RESULT = 3
local CTS_GCW_QUERY_PAGE_FIGHT_RESULT = 4
local CTS_GCW_DEL_FIGHT_MEMBER = 5
local CTS_GCW_GUILD_CROSS_WAR_EXIT = 6
local CTS_GCW_CHANGE_LEADER = 7
local STC_GCW_SEND_FIGHT_RESULT = 1
local STC_GCW_QUERY_FIGHT_INFO = 2
IS_SELF_GUILD = 1
IS_OTHER_GUILD = 2
local CROSS_GUILDWAR_ATTACK_FORCE_ID = 1651
local CROSS_GUILDWAR_DEFEND_FORCE_ID = 1652
local FIGHT_RESULT_INFO_COLS = 5
local temp_delete_table = {}
function open_form()
  custom_cross_guild_war(CTS_GCW_QUERY_FIGHT_RESULT)
end
function close_form()
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_list")
  if nx_is_valid(form) then
    form:Close()
  end
end
function main_form_init(self)
  self.Fixed = false
  self.pageno = 1
  self.pageno_count = 0
  self.pageno2 = 1
  self.pageno2_count = 0
  self.self_side = 0
  self.other_side = 0
  self.check_btn = 0
  self.attk_leader_uid = ""
  self.def_leader_uid = ""
  refresh_leader_uid(self)
  loadresource(self)
  self.choose_leader = ""
end
function on_main_form_open(form)
  form.lbl_failed.Visible = false
  form.lbl_win.Visible = false
  form.check_btn = 0
  form.lbl_loading_1.Visible = false
  form.lbl_loading_2.Visible = false
end
function on_main_form_close(form)
  form:Close()
  nx_destroy(form)
end
function on_btn_last_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local pageno = form.pageno - 1
  if nx_int(pageno) < nx_int(0) or nx_int(pageno) > nx_int(form.pageno_count) then
    return
  end
  custom_cross_guild_war(CTS_GCW_QUERY_PAGE_FIGHT_RESULT, nx_int(form.self_side), pageno)
  show_wait_form(form)
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local pageno = form.pageno + 1
  if nx_int(pageno) < nx_int(0) or nx_int(pageno) > nx_int(form.pageno_count) then
    return
  end
  custom_cross_guild_war(CTS_GCW_QUERY_PAGE_FIGHT_RESULT, nx_int(form.self_side), nx_int(pageno))
  show_wait_form(form)
end
function on_btn_last2_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local pageno = form.pageno2 - 1
  if nx_int(pageno) < nx_int(0) or nx_int(pageno) > nx_int(form.pageno2_count) then
    return
  end
  custom_cross_guild_war(CTS_GCW_QUERY_PAGE_FIGHT_RESULT, nx_int(form.other_side), pageno)
  show_wait_form(form)
end
function on_btn_next2_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local pageno = form.pageno2 + 1
  if nx_int(pageno) < nx_int(0) or nx_int(pageno) > nx_int(form.pageno2_count) then
    return
  end
  custom_cross_guild_war(CTS_GCW_QUERY_PAGE_FIGHT_RESULT, nx_int(form.other_side), nx_int(pageno))
  show_wait_form(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_ref_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_cross_guild_war(CTS_GCW_QUERY_FIGHT_RESULT, nx_int(form.self_side), nx_int(form.pageno), nx_int(form.other_side), nx_int(form.pageno2))
  show_wait_form(form)
end
function on_server_msg(submsg, ...)
  if nx_int(STC_GCW_SEND_FIGHT_RESULT) == nx_int(submsg) then
    on_recv_fightresult(unpack(arg))
  elseif nx_int(STC_GCW_QUERY_FIGHT_INFO) == nx_int(submsg) then
    on_recv_fight_info(unpack(arg))
  end
end
function on_recv_fightresult(win_side, wf_level, ...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guild_war\\form_guild_war_list", true, true)
  if not nx_is_valid(form) then
    return 0
  end
  refresh_fight_info(unpack(arg))
  local guild_name = get_guild()
  if nx_widestr(arg[2]) == nx_widestr(guild_name) then
    if nx_int(form.self_side) == nx_int(win_side) then
      form.lbl_failed.Visible = false
      form.lbl_win.Visible = true
      form.lbl_win.BackImage = "guildwar_win_kuafu0" .. nx_string(wf_level)
    else
      form.lbl_failed.Visible = true
      form.lbl_win.Visible = false
      form.lbl_failed.BackImage = "guildwar_lose_kuafu0" .. nx_string(wf_level)
    end
  end
end
function on_recv_fight_info(...)
  refresh_fight_info(unpack(arg))
end
function refresh_fight_info(side, guild, page_count, pageno, ...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guild_war\\form_guild_war_list", true, true)
  if not nx_is_valid(form) then
    return 0
  end
  loadresource(form)
  local count = table.getn(arg) / FIGHT_RESULT_INFO_COLS
  local base_row = (pageno - 1) * form.per_page_count
  local self_guild = get_guild()
  form.check_btn = 0
  if nx_widestr(self_guild) == nx_widestr(guild) then
    form.pageno = pageno
    form.grid_my:BeginUpdate()
    form.grid_my:ClearRow()
    if nx_int(page_count) <= nx_int(0) then
      form.lbl_pageno.Text = nx_widestr(nx_int(0)) .. nx_widestr("/") .. nx_widestr(nx_int(page_count))
    else
      form.lbl_pageno.Text = nx_widestr(nx_int(pageno)) .. nx_widestr("/") .. nx_widestr(nx_int(page_count))
    end
    form.pageno_count = nx_int(page_count)
    form.lbl_self_guild.Text = nx_widestr(guild)
    form.self_side = side
    form.check_btn = 1
    for i = 1, count do
      local base = (i - 1) * FIGHT_RESULT_INFO_COLS
      local uid = nx_string(arg[base + 1])
      local name = nx_widestr(arg[base + 2])
      local kill_count = nx_int(arg[base + 3])
      local bekill_count = nx_int(arg[base + 4])
      local score = nx_int(arg[base + 5])
      if is_leader(form, side, uid) then
        form.lbl_self_leader.Text = nx_widestr(name)
      end
      local rank = base_row + i
      insert_data(form, form.grid_my, rank, uid, name, kill_count, bekill_count, score)
    end
    form.grid_my:EndUpdate()
  else
    if nx_int(page_count) <= nx_int(0) then
      form.lbl_pageno2.Text = nx_widestr(nx_int(0)) .. nx_widestr("/") .. nx_widestr(nx_int(page_count))
    else
      form.lbl_pageno2.Text = nx_widestr(nx_int(pageno)) .. nx_widestr("/") .. nx_widestr(nx_int(page_count))
    end
    form.pageno2_count = nx_int(page_count)
    form.lbl_other_guild.Text = nx_widestr(guild)
    form.other_side = side
    form.pageno2 = pageno
    form.grid_other:BeginUpdate()
    form.grid_other:ClearRow()
    for i = 1, count do
      local base = (i - 1) * FIGHT_RESULT_INFO_COLS
      local uid = nx_string(arg[base + 1])
      local name = nx_widestr(arg[base + 2])
      local kill_count = nx_int(arg[base + 3])
      local bekill_count = nx_int(arg[base + 4])
      local score = nx_int(arg[base + 5])
      if is_leader(form, side, uid) then
        form.lbl_other_leader.Text = nx_widestr(name)
      end
      local rank = base_row + i
      insert_data(form, form.grid_other, rank, uid, name, kill_count, bekill_count, score)
    end
    form.grid_other:EndUpdate()
  end
  form.Visible = true
  form:Show()
end
function insert_data(form, grid, rank, uid, playrname, kill_count, bekill_count, score)
  local row = grid:InsertRow(-1)
  if nx_int(row) < nx_int(0) then
    return
  end
  local base_cols = 0
  if 0 < form.check_btn then
    local ctbtn_name = "cbtn" .. nx_string(row)
    create_cbtn(form, grid, row, uid, ctbtn_name, "on_cbtn_checked_changed")
    base_cols = 1
  end
  grid:SetGridText(row, base_cols + 0, nx_widestr(rank))
  grid:SetGridText(row, base_cols + 1, nx_widestr(playrname))
  grid:SetGridText(row, base_cols + 2, nx_widestr(kill_count))
  grid:SetGridText(row, base_cols + 3, nx_widestr(bekill_count))
  grid:SetGridText(row, base_cols + 4, nx_widestr(score))
end
function create_cbtn(form, grid, row, uid, ctbtn_name, call_back_name)
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  local cbtn = form:Find(ctbtn_name)
  if not nx_is_valid(cbtn) then
    cbtn = gui:Create("CheckButton")
    cbtn.BoxSize = form.cbtn_base.BoxSize
    cbtn.NormalImage = form.cbtn_base.NormalImage
    cbtn.FocusImage = form.cbtn_base.FocusImage
    cbtn.CheckedImage = form.cbtn_base.CheckedImage
    cbtn.DisableImage = form.cbtn_base.DisableImage
    cbtn.NormalColor = form.cbtn_base.NormalColor
    cbtn.FocusColor = form.cbtn_base.FocusColor
    cbtn.PushColor = form.cbtn_base.PushColor
    cbtn.DisableColor = form.cbtn_base.DisableColor
    cbtn.Left = form.cbtn_base.Left
    cbtn.Top = form.cbtn_base.Top
    cbtn.Width = form.cbtn_base.Width
    cbtn.Height = form.cbtn_base.Height
    cbtn.BackColor = form.cbtn_base.BackColor
    cbtn.ShadowColor = form.cbtn_base.ShadowColor
    cbtn.AutoSize = form.cbtn_base.AutoSize
    nx_bind_script(cbtn, nx_current())
    nx_callback(cbtn, "on_checked_changed", call_back_name)
  end
  if not nx_is_valid(cbtn) then
    return
  end
  cbtn.uid = uid
  cbtn.Name = ctbtn_name
  grid:SetGridControl(row, 0, cbtn)
end
function on_cbtn_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local uid = cbtn.uid
  local length = table.getn(temp_delete_table)
  if cbtn.Checked then
    form.choose_leader = uid
    for i = 1, length do
      if nx_string(uid) == nx_string(temp_delete_table[i]) then
        return
      end
    end
    table.insert(temp_delete_table, uid)
  else
    form.choose_leader = ""
    for i = 1, length do
      if nx_string(uid) == nx_string(temp_delete_table[i]) then
        table.remove(temp_delete_table, i)
        return
      end
    end
  end
end
function on_btn_del_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local length = table.getn(temp_delete_table)
  if length == 0 then
    return
  end
  custom_cross_guild_war(nx_int(CTS_GCW_DEL_FIGHT_MEMBER), unpack(temp_delete_table))
  temp_delete_table = {}
end
function get_guild()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local guild_name = client_player:QueryProp("TempGuildName")
  return guild_name
end
function on_btn_war_exit_click(btn)
  if not show_confirm_info("ui_kuafu_item_xuanfukuang_02") then
    return
  end
  custom_cross_guild_war(CTS_GCW_GUILD_CROSS_WAR_EXIT)
end
function show_confirm_info(tip)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if nx_is_valid(dialog) then
    dialog:ShowModal()
    local text = nx_widestr(util_text(tip))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res ~= "ok" then
      return false
    end
  end
  return true
end
function on_btn_leader_click(btn)
  local form = btn.ParentForm
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  local gui = nx_value("gui")
  local uid = form.choose_leader
  if uid == "" then
    local info = gui.TextManager:GetText("1000373")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_CROSS_WAR), nx_int(CTS_GCW_CHANGE_LEADER), nx_string(uid))
end
function refresh_leader_uid(form)
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return ""
  end
  form.attk_leader_uid = client_scene:QueryProp("AttackerLeaderUID")
  form.def_leader_uid = client_scene:QueryProp("DefenderLeaderUID")
end
function is_leader(form, side, uid)
  if nx_int(CROSS_GUILDWAR_ATTACK_FORCE_ID) == nx_int(side) then
    if nx_string(uid) == nx_string(form.attk_leader_uid) then
      return true
    end
  elseif nx_string(uid) == nx_string(form.def_leader_uid) then
    return true
  end
  return false
end
function loadresource(form)
  form.per_page_count = 10
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuildWarCross.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("property")
  if nx_int(sec_index) < nx_int(0) then
    return
  end
  form.per_page_count = ini:ReadInteger(sec_index, "max_count_per_page", 10)
end
function show_wait_form(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    form.btn_last_page.Enabled = false
    form.btn_next_page.Enabled = false
    form.btn_last2_page.Enabled = false
    form.btn_next2_page.Enabled = false
    form.btn_ref.Enabled = false
    form.btn_del.Enabled = false
    form.btn_leader.Enabled = false
    form.btn_war_exit.Enabled = false
    form.lbl_loading_1.Visible = true
    form.lbl_loading_2.Visible = true
    timer:Register(3000, 1, nx_current(), "set_btn_enabled", form, -1, -1)
  end
end
function set_btn_enabled(form)
  if not nx_is_valid(form) then
    return 0
  end
  form.btn_last_page.Enabled = true
  form.btn_next_page.Enabled = true
  form.btn_last2_page.Enabled = true
  form.btn_next2_page.Enabled = true
  form.btn_ref.Enabled = true
  form.btn_del.Enabled = true
  form.btn_del.Enabled = true
  form.btn_leader.Enabled = true
  form.btn_war_exit.Enabled = true
  form.lbl_loading_1.Visible = false
  form.lbl_loading_2.Visible = false
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "set_btn_enabled", form)
  end
end
