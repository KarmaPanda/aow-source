require("util_functions")
require("custom_sender")
require("util_gui")
require("share\\client_custom_define")
require("utils")
require("form_stage_main\\form_tiguan\\form_tiguan_util")
require("define\\sysinfo_define")
require("tips_data")
local SUB_CUSTOMMSG_REQUEST_AUTHENTICATE_INFO = 94
local SUB_CUSTOMMSGMEMBER_AUTHENTICATE = 95
local SUB_CUSTOMMSG_CAPTAIN_AUTHENTICATE = 96
local SUB_CUSTOMMSG_REQUEST_AUTH_LIST = 97
local SUB_CUSTOMMSG_GUILD_BIND_YY_SET = 98
local SUB_CUSTOMMSG_GUILD_BIND_YY_QUERY = 99
local achieve_lbl_back_pix1 = 47
local achieve_lbl_back_pix2 = 55
local achieve_rank_interval = 2
local achieve_quanfu_height = 40
local pho = "gui\\language\\ChineseS\\mainform\\guild_captain_auth_"
local AUTH_INI = "ini\\Guild\\guild_auth.ini"
function main_form_init(self)
  self.Fixed = true
  self.select_auth = 0
  self.select_sub_auth = 0
  self.pageno = 1
  self.page_next_ok = 1
  form.remain_time = 0
end
function on_main_form_open(self)
  self.select_auth = 0
  self.pageno = 1
  self.page_next_ok = 1
  self.active_value = 0
  self.contribute_value = 0
  self.power_level = 0
  self.remain_time = 0
  self.main_gamestep = 0
  self.sub_gamestep = 0
  self.last_cbtn = nil
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.groupscrollbox_7.Visible = true
  self.groupbox_member.Visible = true
  self.groupbox_auth.Visible = false
  self.groupbox_YY.Visible = false
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) or switch_manager:CheckSwitchEnable(158) then
  end
  self.yy_query_time = 0
  self.grid_auth:BeginUpdate()
  self.grid_auth:SetColTitle(0, nx_widestr(util_text("ui_guild_auth_1")))
  self.grid_auth:SetColTitle(1, nx_widestr(util_text("ui_guild_auth_2")))
  self.grid_auth:SetColTitle(2, nx_widestr(util_text("ui_guild_auth_3")))
  self.grid_auth:SetColTitle(3, nx_widestr(util_text("ui_guild_auth_4")))
  self.grid_auth:EndUpdate()
  request_captain_Auth_list()
  request_auth_list(1)
  self.guild_auth_ini = nx_execute("util_functions", "get_ini", AUTH_INI)
  if not nx_is_valid(self.guild_auth_ini) then
    return 0
  end
end
function on_main_form_close(form)
  nx_destroy(form)
  return
end
function on_rbtn_member_auth_checked_changed(rbtn)
  if rbtn.Checked ~= true then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form.groupscrollbox_7.Visible = true
  form.groupbox_auth.Visible = false
  form.groupbox_YY.Visible = false
  form.groupbox_member.Visible = true
end
function on_rbtn_auth_info_checked_changed(rbtn)
  if rbtn.Checked ~= true then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form.groupscrollbox_7.Visible = false
  form.groupbox_member.Visible = false
  form.groupbox_auth.Visible = true
  form.groupbox_YY.Visible = false
end
function request_captain_Auth_list()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_AUTHENTICATE_INFO))
end
function on_btn_last_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if form.pageno > 1 then
    request_auth_list(form.pageno - 1)
  end
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if 0 < form.page_next_ok then
    request_auth_list(form.pageno + 1)
  end
end
function request_auth_list(pageno)
  local from = (nx_int(pageno) - 1) * 10
  local to = pageno * 10
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_AUTH_LIST), nx_int(from), nx_int(to))
end
function on_recv_auth_list(from, to, rowcount, ...)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_authentication")
  if not nx_is_valid(form) then
    return 0
  end
  local guild_manager = nx_value("GuildManager")
  if not nx_is_valid(guild_manager) then
    return
  end
  local size = table.getn(arg)
  if size <= 0 or size % 5 ~= 0 then
    return 0
  end
  if from < 0 or from == to then
    form.page_next_ok = 0
    return 0
  end
  form.page_next_ok = 1
  form.pageno = from / 10 + 1
  local nowpage = nx_string(form.pageno)
  local maxpage = "/" .. nx_string(math.ceil(rowcount / 10))
  form.lbl_pageno.Text = nx_widestr(nowpage .. maxpage)
  local gui = nx_value("gui")
  local rows = size / 5
  if 10 < rows then
    rows = 10
  end
  local control_length = 0
  if nx_int(form.grid_auth:GetColWidth(4)) >= nx_int(form.grid_auth.RowHeight) then
    control_length = nx_int(form.grid_auth.RowHeight) - 2
  else
    control_length = nx_int(form.grid_auth:GetColWidth(4)) - 2
  end
  form.grid_auth:BeginUpdate()
  form.grid_auth:ClearRow()
  for i = 1, rows do
    local row = form.grid_auth:InsertRow(-1)
    local base = (i - 1) * 5
    local player_name = arg[base + 1]
    local pos_name = arg[base + 2]
    local captain_auth = arg[base + 3]
    local member_auth = arg[base + 4]
    local member_sub_auth = arg[base + 5]
    local auth = guild_manager:GetMaxCaptainAuth(captain_auth)
    if auth == "" then
      auth = "0_0"
    end
    local label = gui:Create("Label")
    if nx_is_valid(label) then
      label.Width = control_length
      label.Height = control_length
      label.BackImage = pho .. nx_string(auth) .. ".png"
      label.HintText = nx_widestr(util_text("ui_guild_captain_auth_" .. nx_string(auth)))
      label.DrawMode = "FitWindow"
      label.Text = nx_widestr("")
      label.Align = "Center"
      label.NoFrame = true
      label.Solid = false
      label.AutoSize = true
      label.Transparent = false
      form.grid_auth:SetGridControl(row, 2, label)
    end
    form.grid_auth:SetGridText(row, 0, nx_widestr(player_name))
    form.grid_auth:SetGridText(row, 1, nx_widestr(util_text("ui_guild_pos_level" .. nx_string(pos_name) .. "_name")))
    local ui_name = "ui_guild_auth_4_" .. nx_string(member_auth) .. "_" .. nx_string(member_sub_auth)
    form.grid_auth:SetGridText(row, 3, nx_widestr(util_text(ui_name)))
  end
  form.grid_auth:EndUpdate()
end
function recv_auth_data(...)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_authentication")
  if not nx_is_valid(form) then
    return
  end
  local size = table.getn(arg)
  form.main_gamestep = arg[1]
  form.sub_gamestep = arg[2]
  form.active_value = arg[3]
  form.contribute_value = arg[4]
  form.power_level = arg[5]
  local remain_time = arg[6]
  local auth_info = arg[7]
  local key = nx_string(form.main_gamestep) .. "_" .. nx_string(form.sub_gamestep)
  form.lbl_step.Text = gui.TextManager:GetText("ui_guild_auth_4_" .. nx_string(key))
  show_game_step_auth_info(form, auth_info)
  if remain_time <= 0 then
    form.lbl_time.Text = nx_widestr("00:00:00")
  else
    local GuildManager = nx_value("GuildManager")
    if nx_is_valid(GuildManager) then
      GuildManager:RegisterPrizeTimer(remain_time)
    end
  end
end
function show_game_step_auth_info(form, auth_info)
  local auth_ini = form.guild_auth_ini
  if not nx_is_valid(auth_ini) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local guild_manager = nx_value("GuildManager")
  if not nx_is_valid(guild_manager) then
    return
  end
  form.groupbox_member.IsEditMode = true
  form.groupbox_member:DeleteAll()
  local section_count = auth_ini:GetSectionCount()
  for i = 1, section_count do
    local key_game_step = auth_ini:GetSectionByIndex(i - 1)
    local str_lst = util_split_string(key_game_step, "_")
    local desc_title = auth_ini:ReadString(i - 1, "desc_title", "")
    local pho1 = auth_ini:ReadString(i - 1, "pho1", "")
    local tips1 = auth_ini:ReadString(i - 1, "tips1", "")
    local pho2 = auth_ini:ReadString(i - 1, "pho2", "")
    local tips2 = auth_ini:ReadString(i - 1, "tips2", "")
    local pho3 = auth_ini:ReadString(i - 1, "pho3", "")
    local tips3 = auth_ini:ReadString(i - 1, "tips3", "")
    local pho4 = auth_ini:ReadString(i - 1, "pho4", "")
    local tips4 = auth_ini:ReadString(i - 1, "tips4", "")
    local pho5 = auth_ini:ReadString(i - 1, "pho5", "")
    local tips5 = auth_ini:ReadString(i - 1, "tips5", "")
    local pho6 = auth_ini:ReadString(i - 1, "pho6", "")
    local tips6 = auth_ini:ReadString(i - 1, "tips6", "")
    local groupbox_one = create_ctrl("GroupBox", "groupbox_reward_info_0" .. nx_string(reward_level), form.groupbox_reward, form.groupbox_member)
    if nx_is_valid(groupbox_one) then
      local cbtn_auth_select = create_ctrl("CheckButton", "cbtn_reward_info_0", form.cbtn_auth_select, groupbox_one)
      cbtn_auth_select.reward_id = i
      cbtn_auth_select.select_auth = nx_int(str_lst[1])
      cbtn_auth_select.select_sub_auth = nx_int(str_lst[2])
      nx_bind_script(cbtn_auth_select, nx_current())
      nx_callback(cbtn_auth_select, "on_checked_changed", "on_cbtn_auth_checked_changed")
      groupbox_one.Height = cbtn_auth_select.Height + achieve_rank_interval
      local lbl_auth_name1 = create_ctrl("Label", "lbl_auth_name1", form.lbl_auth_name1, groupbox_one)
      lbl_auth_name1.Text = gui.TextManager:GetText("ui_guild_auth_4_" .. nx_string(i))
      local lbl_reward_back = create_ctrl("Label", "lbl_reward_back_" .. nx_string(i), form.lbl_reward_back, groupbox_one)
      lbl_reward_back.Top = achieve_lbl_back_pix2
      lbl_reward_back.Height = lbl_reward_back.Height + achieve_quanfu_height
      local lbl_condition1 = create_ctrl("Label", "lbl_condition1", form.lbl_condition1, groupbox_one)
      lbl_condition1.Text = gui.TextManager:GetText("ui_guild_auth_1_" .. nx_string(i))
      local lbl_active_desc = create_ctrl("Label", "lbl_active_desc", form.lbl_active_desc, groupbox_one)
      lbl_active_desc.Text = gui.TextManager:GetText("ui_guild_sinature_1_1")
      local lbl_contribute_desc = create_ctrl("Label", "lbl_contribute_desc", form.lbl_contribute_desc, groupbox_one)
      lbl_contribute_desc.Text = gui.TextManager:GetText("ui_guild_sinature_1_2")
      local lbl_power_desc = create_ctrl("Label", "lbl_power_desc", form.lbl_power_desc, groupbox_one)
      lbl_power_desc.Text = gui.TextManager:GetText("ui_guild_sinature_1_3")
      local lbl_active = create_ctrl("Label", "lbl_active", form.lbl_active, groupbox_one)
      local lbl_contribute = create_ctrl("Label", "lbl_contribute", form.lbl_contribute, groupbox_one)
      local lbl_power = create_ctrl("Label", "lbl_power", form.lbl_power, groupbox_one)
      lbl_active.Text = nx_widestr("")
      lbl_contribute.Text = nx_widestr("")
      lbl_power.Text = nx_widestr("")
      local lbl_prize1 = create_ctrl("Label", "lbl_prize1", form.lbl_prize1, groupbox_one)
      lbl_prize1.Text = gui.TextManager:GetText("ui_guild_sinature_award")
      local lbl_image1 = create_ctrl("Label", "lbl_image1", form.lbl_image1, groupbox_one)
      lbl_image1.HintText = nx_widestr(util_text(tips1))
      lbl_image1.BackImage = pho1
      local lbl_image2 = create_ctrl("Label", "lbl_image2", form.lbl_image2, groupbox_one)
      lbl_image2.HintText = nx_widestr(util_text(tips2))
      lbl_image2.BackImage = pho2
      local lbl_image5 = create_ctrl("Label", "lbl_image5", form.lbl_image5, groupbox_one)
      lbl_image5.HintText = nx_widestr(util_text(tips5))
      lbl_image5.BackImage = pho5
      local btn_take_1 = create_ctrl("Button", "btn_take_1", form.btn_take_1, groupbox_one)
      nx_bind_script(btn_take_1, nx_current())
      nx_callback(btn_take_1, "on_click", "on_btn_member_auth_click")
      local lbl_condition2 = create_ctrl("Label", "lbl_condition2", form.lbl_condition2, groupbox_one)
      lbl_condition2.Text = gui.TextManager:GetText("ui_guild_auth_2_" .. nx_string(i))
      local lbl_number_desc = create_ctrl("Label", "lbl_number_desc", form.lbl_number_desc, groupbox_one)
      lbl_number_desc.Text = gui.TextManager:GetText("ui_guild_sinature_0_2")
      local lbl_number = create_ctrl("Label", "lbl_number", form.lbl_number, groupbox_one)
      local lbl_captain_active_desc = create_ctrl("Label", "lbl_active_desc2", form.lbl_active_desc2, groupbox_one)
      lbl_active_desc.Text = gui.TextManager:GetText("ui_guild_sinature_1_1")
      local lbl_captain_contribute_desc = create_ctrl("Label", "lbl_contribute_desc2", form.lbl_contribute_desc2, groupbox_one)
      lbl_contribute_desc.Text = gui.TextManager:GetText("ui_guild_sinature_1_2")
      local lbl_captain_active = create_ctrl("Label", "lbl_active2", form.lbl_active2, groupbox_one)
      local lbl_captain_contribute = create_ctrl("Label", "lbl_contribute2", form.lbl_contribute2, groupbox_one)
      lbl_captain_active.Text = nx_widestr("")
      lbl_captain_contribute.Text = nx_widestr("")
      local lbl_prize2 = create_ctrl("Label", "lbl_prize2", form.lbl_prize2, groupbox_one)
      lbl_prize2.Text = gui.TextManager:GetText("ui_guild_sinature_award")
      local lbl_image3 = create_ctrl("Label", "lbl_image3", form.lbl_image3, groupbox_one)
      lbl_image3.HintText = nx_widestr(util_text(tips3))
      lbl_image3.BackImage = pho3
      local lbl_image4 = create_ctrl("Label", "lbl_image4", form.lbl_image4, groupbox_one)
      lbl_image4.HintText = nx_widestr(util_text(tips4))
      lbl_image4.BackImage = pho4
      local lbl_image6 = create_ctrl("Label", "lbl_image6", form.lbl_image6, groupbox_one)
      lbl_image6.HintText = nx_widestr(util_text(tips6))
      lbl_image6.BackImage = pho6
      local btn_take_2 = create_ctrl("Button", "btn_take_2", form.btn_take_2, groupbox_one)
      nx_bind_script(btn_take_2, nx_current())
      nx_callback(btn_take_2, "on_click", "on_btn_acptain_auth_click")
      set_info(form, i, key_game_step, auth_info, desc_title, lbl_active, lbl_contribute, lbl_power, btn_take_1, lbl_number, btn_take_2, lbl_captain_active, lbl_captain_contribute)
    end
  end
  form.groupbox_member.IsEditMode = false
  form.groupbox_member:ResetChildrenYPos()
end
function set_info(form, i, key_game_step, auth_info, desc_title, lbl_active, lbl_contribute, lbl_power, btn_take_1, lbl_number, btn_take_2, lbl_captain_active, lbl_captain_contribute)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local guild_manager = nx_value("GuildManager")
  if not nx_is_valid(guild_manager) then
    return
  end
  local member_info = {}
  member_info = guild_manager:GetMemberAuthInfo(nx_string(key_game_step))
  local LevelTitle = client_player:QueryProp("LevelTitle")
  local lengh = table.getn(member_info)
  if lengh == 3 then
    lbl_active.Text = nx_widestr(form.active_value) .. nx_widestr("/") .. nx_widestr(member_info[1])
    lbl_contribute.Text = nx_widestr(form.contribute_value) .. nx_widestr("/") .. nx_widestr(member_info[2])
    lbl_power.Text = nx_widestr(util_text("desc_" .. LevelTitle)) .. nx_widestr("/") .. nx_widestr(util_text(desc_title))
    set_lbl_color(lbl_active, form.active_value, member_info[1])
    set_lbl_color(lbl_contribute, form.contribute_value, member_info[2])
    set_lbl_color(lbl_power, form.power_level, member_info[3])
  end
  local member_auth_step = client_player:QueryProp("GuildMemberAuthStep")
  local member_sub_auth_step = client_player:QueryProp("GuildMemberAuthSubStep")
  local str_lst = util_split_string(key_game_step, "_")
  if str_lst == nil then
    return
  end
  if table.getn(str_lst) ~= 2 then
    return
  end
  btn_take_1.Text = nx_widestr(util_text("ui_guild_auth_take_prize_1"))
  btn_take_1.Enabled = false
  if nx_int(member_auth_step) < nx_int(str_lst[1]) or nx_int(member_auth_step) == nx_int(str_lst[1]) and nx_int(member_sub_auth_step) < nx_int(str_lst[2]) then
    btn_take_1.Text = nx_widestr(util_text("ui_guild_auth_take_prize_2"))
    btn_take_1.Enabled = true
  end
  local info = {}
  info = guild_manager:GetCaptainAuthInfo(auth_info, nx_int(str_lst[1]), nx_int(str_lst[2]))
  lengh = table.getn(info)
  if nx_int(5) <= nx_int(lengh) then
    lbl_number.Text = nx_widestr(info[1]) .. nx_widestr("/") .. nx_widestr(info[2])
    set_lbl_color(lbl_number, info[1], info[2])
    local is_auth = info[3]
    lbl_captain_active.Text = nx_widestr(form.active_value) .. nx_widestr("/") .. nx_widestr(info[4])
    lbl_captain_contribute.Text = nx_widestr(form.contribute_value) .. nx_widestr("/") .. nx_widestr(info[5])
    set_lbl_color(lbl_captain_active, form.active_value, info[4])
    set_lbl_color(lbl_captain_contribute, form.contribute_value, info[5])
    if nx_int(client_player:QueryProp("IsGuildCaptain")) ~= nx_int(2) then
      btn_take_2.Text = nx_widestr(util_text("ui_guild_auth_take_prize_2"))
      btn_take_2.Enabled = false
    elseif nx_int(is_auth) == nx_int(1) then
      btn_take_2.Text = nx_widestr(util_text("ui_guild_auth_take_prize_1"))
      btn_take_2.Enabled = false
    else
      btn_take_2.Text = nx_widestr(util_text("ui_guild_auth_take_prize_2"))
      btn_take_2.Enabled = true
    end
    set_btn_is_open(form, key_game_step, btn_take_1, btn_take_2)
  end
end
function set_btn_is_open(form, key_game_step, btn_take_1, btn_take_2)
  local str_lst = util_split_string(key_game_step, "_")
  if nx_int(form.main_gamestep) < nx_int(str_lst[1]) then
    btn_take_1.Text = nx_widestr(util_text("ui_guild_auth_take_prize_3"))
    btn_take_1.Enabled = false
    btn_take_2.Text = nx_widestr(util_text("ui_guild_auth_take_prize_3"))
    btn_take_2.Enabled = false
  end
  if nx_int(form.main_gamestep) == nx_int(str_lst[1]) and nx_int(form.sub_gamestep) < nx_int(str_lst[2]) then
    btn_take_1.Text = nx_widestr(util_text("ui_guild_auth_take_prize_3"))
    btn_take_1.Enabled = false
    btn_take_2.Text = nx_widestr(util_text("ui_guild_auth_take_prize_3"))
    btn_take_2.Enabled = false
  end
end
function set_lbl_color(lbl, value1, value2)
  if nx_int(value1) >= nx_int(value2) then
    lbl.ForeColor = "255,40,130,40"
  else
    lbl.ForeColor = "255,255,0,0"
  end
end
function on_cbtn_auth_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if nx_is_valid(form.last_cbtn) and nx_string(form.last_cbtn) ~= nx_string(cbtn) then
    form.last_cbtn.Checked = false
  end
  local gbox = cbtn.Parent
  if not nx_is_valid(gbox) then
    return 0
  end
  local lbl_reward_back = gbox:Find("lbl_reward_back_" .. nx_string(cbtn.reward_id))
  form.select_auth = cbtn.select_auth
  form.select_sub_auth = cbtn.select_sub_auth
  if cbtn.Checked then
    gbox.Height = form.lbl_reward_back.Height + cbtn.Height + achieve_rank_interval + achieve_quanfu_height
    lbl_reward_back.Top = achieve_lbl_back_pix1
    lbl_reward_back.Height = lbl_reward_back.Height
    form.last_cbtn = cbtn
  else
    gbox.Height = cbtn.Height + achieve_rank_interval
    lbl_reward_back.Top = achieve_lbl_back_pix2
    form.last_cbtn = nil
  end
  form.groupbox_member:ResetChildrenYPos()
end
function on_btn_member_auth_click(btn)
  local form = btn.ParentForm
  if nx_int(form.select_auth) == nx_int(0) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("19884"), 2)
    end
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSGMEMBER_AUTHENTICATE), nx_int(form.select_auth), nx_int(form.select_sub_auth))
end
function on_btn_acptain_auth_click(btn)
  local form = btn.ParentForm
  if nx_int(form.select_auth) == nx_int(0) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("19884"), 2)
    end
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_CAPTAIN_AUTHENTICATE), nx_int(form.select_auth), nx_int(form.select_sub_auth))
end
function on_rbtn_yy_auth_checked_changed(rbtn)
  if rbtn.Checked ~= true then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) or not switch_manager:CheckSwitchEnable(158) then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("19895")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return
  end
  guild_is_bind(0)
end
function guild_is_bind(type)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local guild_name = client_player:QueryProp("GuildName")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_BIND_YY_QUERY), nx_int(type), guild_name)
end
function show_bind_yy_info(...)
  if table.getn(arg) < 2 then
    return
  end
  local gui = nx_value("gui")
  local type = arg[1]
  if type == 0 then
    local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_authentication")
    if not nx_is_valid(form) then
      return
    end
    if arg[2] == 1 then
      form.groupscrollbox_7.Visible = false
      form.groupbox_auth.Visible = false
      form.groupbox_member.Visible = false
      form.groupbox_YY.Visible = true
      form.groupbox_4.Visible = false
      form.groupbox_3.Visible = true
      form.lbl_guild_name.Text = arg[3]
      form.lbl_ID.Text = nx_widestr(arg[4])
      local desc = nx_widestr(arg[5])
      if desc == nx_widestr("") then
        desc = gui.TextManager:GetFormatText("ui_guild_YY_desc")
      end
      form.mltbox_desc:Clear()
      form.mltbox_desc:AddHtmlText(desc, -1)
    elseif arg[2] == 0 then
      form.groupscrollbox_7.Visible = false
      form.groupbox_auth.Visible = false
      form.groupbox_member.Visible = false
      form.groupbox_YY.Visible = true
      form.groupbox_4.Visible = true
      form.groupbox_3.Visible = false
    end
  elseif type == 1 then
    if arg[2] == 1 then
      nx_function("ext_guild_bind_yy", nx_int(3), arg[3], arg[4])
    else
      local game_client = nx_value("game_client")
      if not nx_is_valid(game_client) then
        return
      end
      local client_player = game_client:GetPlayer()
      if not nx_is_valid(client_player) then
        return
      end
      local text = nx_widestr("")
      local my_guild_name = client_player:QueryProp("GuildName")
      if my_guild_name == guild_name then
        text = gui.TextManager:GetFormatText("19889")
      else
        text = gui.TextManager:GetFormatText("19898")
      end
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(text, 2)
      end
    end
  elseif type == 2 then
    nx_execute("form_stage_main\\form_main\\form_main_player", "show_yy_btn", arg[2])
  elseif type == 3 then
    local form_select = nx_value("form_stage_main\\form_main\\form_main_select")
    if nx_is_valid(form_select) then
      if arg[2] == 1 then
        form_select.btn_YY.Visible = true
      else
        form_select.btn_YY.Visible = false
      end
      local game_client = nx_value("game_client")
      if not nx_is_valid(game_client) then
        return
      end
      local client_player = game_client:GetPlayer()
      if not nx_is_valid(client_player) then
        return
      end
      local select_target_ident = client_player:QueryProp("LastObject")
      local select_target = game_client:GetSceneObj(nx_string(select_target_ident))
      if not nx_is_valid(select_target) then
        return
      end
      select_target.guild_is_bind_yy = arg[2]
    end
  end
end
function on_btn_delete_bind_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local new_time = os.time()
  if nx_find_custom(btn.ParentForm, "yy_query_time") and new_time - btn.ParentForm.yy_query_time <= 3 then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("19892")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return
  end
  btn.ParentForm.yy_query_time = new_time
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) or not switch_manager:CheckSwitchEnable(158) then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("19895")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
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
  if client_player:QueryProp("IsGuildCaptain") ~= 2 then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("19887")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return
  end
  local guild_name = form.lbl_guild_name.Text
  local sid = form.lbl_ID.Text
  nx_function("ext_guild_bind_yy", nx_int(2), guild_name, nx_string(sid))
end
function on_btn_send_post_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local new_time = os.time()
  if nx_find_custom(btn.ParentForm, "yy_query_time") and new_time - btn.ParentForm.yy_query_time <= 3 then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("19892")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return
  end
  btn.ParentForm.yy_query_time = new_time
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) or not switch_manager:CheckSwitchEnable(158) then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("19895")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return
  end
  local code = nx_string(form.ipt_code.Text)
  if code == "" then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("19893")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
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
  if client_player:QueryProp("IsGuildCaptain") ~= 2 then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("19887")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return
  end
  local guild_name = client_player:QueryProp("GuildName")
  nx_function("ext_guild_bind_yy", nx_int(1), guild_name, code)
end
function send_bind_info_to_yy(...)
  nx_function("ext_guild_bind_yy", unpack(arg))
end
function save_yy_info(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  if nx_int(arg[1]) == nx_int(1) then
    local game_config = nx_value("game_config")
    if not nx_is_valid(game_config) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_BIND_YY_SET), nx_int(arg[1]), arg[2], arg[3], game_config.server_name)
    local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_authentication")
    if not nx_is_valid(form) then
      return
    end
    form.groupbox_4.Visible = false
    form.groupbox_3.Visible = true
    form.lbl_guild_name.Text = arg[2]
    form.lbl_ID.Text = nx_widestr(arg[3])
    local gui = nx_value("gui")
    local desc = gui.TextManager:GetFormatText("ui_guild_YY_desc")
    form.mltbox_desc:Clear()
    form.mltbox_desc:AddHtmlText(desc, -1)
    local form_player = nx_value("form_stage_main\\form_main\\form_main_player")
    if nx_is_valid(form_player) then
      form_player.btn_YY.Enabled = true
    end
  elseif nx_int(arg[1]) == nx_int(2) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_BIND_YY_SET), nx_int(arg[1]), arg[2])
    local form_player = nx_value("form_stage_main\\form_main\\form_main_player")
    if nx_is_valid(form_player) then
      form_player.btn_YY.Enabled = false
    end
  elseif nx_int(arg[1]) == nx_int(3) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_BIND_YY_SET), nx_int(arg[1]), arg[2], nx_widestr(arg[3]), nx_widestr(arg[4]))
  end
end
