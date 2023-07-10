require("util_gui")
require("util_functions")
require("custom_sender")
require("form_stage_main\\form_battlefield_wulin\\wudao_util")
local wuxue_pre_line = 6
local left = 8
local top = 8
local width_m = 8
local height_m = 8
local weapon_max = 10
local wuxue_color = {
  [1] = "255,163,202,68",
  [2] = "255,233,192,80",
  [3] = "255,153,153,153",
  [4] = "255,152,160,205",
  [5] = "255,186,151,114",
  [6] = "255,0,0,255"
}
local lbl_ban_mod_left = -25
local ARRAY_NAME = "COMMON_ARRAY_BANPICK"
local INI_PATH = "share\\War\\WuDaoWar\\wudao_war_wuxue.ini"
local FORM_NAME = "form_stage_main\\form_battlefield_wulin\\form_wulin_banpick"
local WuDaoSubStep_None = 0
local WuDaoSubStep_WaitEnter = 1
local WuDaoSubStep_Ban = 2
local WuDaoSubStep_Pick = 3
local WuDaoSubStep_Preview = 4
local WuDaoSubStep_Adjust = 5
local WuDaoSubStep_Ready = 6
local WuDaoTeamNo_1 = 1
local WuDaoTeamNo_2 = 2
local WuDaoFightPlayerState_OK = 1
local PTYPE_0 = 0
local PTYPE_1 = 1
local PTYPE_2 = 2
function update_info_test()
  update_info(2, 30000, "\213\189\182\211A", "\213\189\182\211B", "", "1", "4,5", "1,\208\236\231\243\211\240@a,1,13;0,\203\190\205\189\208\249\182\254,1,21,22;0,\205\230\188\210C@abc,1,31,32;0,\205\230\188\210D,1,41,42;0,\205\230\188\210E,1,;0,\205\230\188\210F,1,61,62;", "1,\205\230\188\210A@c,1,16;0,\205\230\188\210B,1,;0,\205\230\188\210C,1,43;0,\205\230\188\210D@agg,1,41,0;0,\205\230\188\210E,1,51,52;0,\205\230\188\210F,1,;")
end
function update_ban_test()
  update_ban("\208\236\231\243\211\240", 1, 3, 7)
end
function update_player_test()
  update_player(1, 2, "0,\180\243\184\231\184\231,1,31,37")
end
function update_stage_test()
  update_stage(3, 300000)
end
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.AbsLeft = (gui.Width - self.Width) / 2
    self.AbsTop = (gui.Height - self.Height) / 2
  end
  load_ini(self)
  init_combobox_weapon(self)
  self.stage = WuDaoSubStep_None
  self.ptype = PTYPE_0
  self.sl_wuxue = nil
  self.sl_color = 0
  self.sl_weapon = 0
  self.t1_leader = nil
  self.t2_leader = nil
  self.lbl_p1_ban1_x.Visible = false
  self.lbl_p1_ban2_x.Visible = false
  self.lbl_p1_ban3_x.Visible = false
  self.lbl_p2_ban1_x.Visible = false
  self.lbl_p2_ban2_x.Visible = false
  self.lbl_p2_ban3_x.Visible = false
  self.ani_p1_1.Visible = false
  self.ani_p1_2.Visible = false
  self.ani_p1_3.Visible = false
  self.ani_p2_1.Visible = false
  self.ani_p2_2.Visible = false
  self.ani_p2_3.Visible = false
  custom_wudao(113)
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_update_lbl_time", self, -1, -1)
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_lbl_time", self)
  end
  nx_destroy(self)
end
function on_update_lbl_time(form)
  local cur_time = nx_number(form.lbl_time.Text)
  if 0 < cur_time then
    form.lbl_time.Text = nx_widestr(cur_time - 1)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if form.stage == WuDaoSubStep_Ready then
    close_form()
  end
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
end
function reopen_form()
  local form = util_get_form(FORM_NAME, false, false)
  if nx_is_valid(form) then
    close_form()
  end
  form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_ban_click(btn)
  local form = btn.ParentForm
  if form.stage ~= WuDaoSubStep_Ban then
    return
  end
  if form.ptype == PTYPE_0 then
    return
  end
  if form.sl_wuxue == nil then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_wudao_war_banpick_001"))
    return
  end
  if form.sl_wuxue.Visible == false then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_wudao_war_banpick_001"))
    return
  end
  if form.sl_wuxue.Enabled == false then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_wudao_war_banpick_001"))
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local player_name = client_player:QueryProp("Name")
  local t_leader, lbl_p_ban3
  if form.ptype == PTYPE_1 then
    t_leader = form.t1_leader
    lbl_p_ban3 = form.lbl_p1_ban3
  elseif form.ptype == PTYPE_2 then
    t_leader = form.t2_leader
    lbl_p_ban3 = form.lbl_p2_ban3
  else
    return
  end
  if t_leader == nil or lbl_p_ban3 == nil then
    return
  end
  if nx_widestr(t_leader) ~= nx_widestr(player_name) then
    return
  end
  if nx_find_custom(lbl_p_ban3, "is_ban") and lbl_p_ban3.is_ban then
    return
  end
  local index = form.sl_wuxue.index
  custom_wudao(108, nx_int(index))
end
function on_btn_select_click(btn)
  local form = btn.ParentForm
  if form.stage ~= WuDaoSubStep_Pick then
    return
  end
  if form.ptype == PTYPE_0 then
    return
  end
  if form.sl_wuxue == nil then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_wudao_war_banpick_002"))
    return
  end
  if form.sl_wuxue.Visible == false then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_wudao_war_banpick_002"))
    return
  end
  if form.sl_wuxue.Enabled == false then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_wudao_war_banpick_002"))
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local player_name = client_player:QueryProp("Name")
  local gsb, str_lbl_pick2
  if form.ptype == PTYPE_1 then
    gsb = form.gsb_p1
    str_lbl_pick2 = "lbl_p1_pick2_"
  elseif form.ptype == PTYPE_2 then
    gsb = form.gsb_p2
    str_lbl_pick2 = "lbl_p2_pick2_"
  end
  if gsb == nil or str_lbl_pick2 == nil then
    return
  end
  local gb = get_gb_by_name(gsb, player_name)
  if gb == nil then
    return
  end
  local lbl_pick2 = gb:Find(nx_string(str_lbl_pick2) .. nx_string(gb.index))
  if nx_find_custom(lbl_pick2, "is_pick") and lbl_pick2.is_pick then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_wudao_war_banpick_003"))
    return
  end
  local index = form.sl_wuxue.index
  custom_wudao(109, nx_int(index))
end
function on_rbtn_color_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    local color = nx_number(rbtn.DataSource)
    form.sl_color = color
    do_sift(form)
  end
end
function on_combobox_weapon_selected(combo)
  local form = combo.ParentForm
  form.sl_weapon = nx_number(combo.DropListBox.SelectIndex)
  do_sift(form)
end
function update_info(...)
  local form = util_get_form(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local stage = arg[1]
  local left_time = arg[2]
  local t1_name = arg[3]
  local t2_name = arg[4]
  local wuxue_str = arg[5]
  local t1_ban = arg[6]
  local t2_ban = arg[7]
  local p1_str = arg[8]
  local p2_str = arg[9]
  form.stage = nx_number(stage)
  form.lbl_t1_name.Text = nx_widestr(t1_name)
  form.lbl_t2_name.Text = nx_widestr(t2_name)
  set_wuxue(form, wuxue_str)
  set_ban_wuxue(form.gb_ban1, "lbl_p1_ban", t1_ban)
  set_ban_wuxue(form.gb_ban2, "lbl_p2_ban", t2_ban)
  set_player_info(form, WuDaoTeamNo_1, p1_str)
  set_player_info(form, WuDaoTeamNo_2, p2_str)
  update_stage(stage, left_time)
end
function update_ban(...)
  local form = util_get_form(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local leader = arg[1]
  local team_no = arg[2]
  local ban_no = arg[3]
  local ban_index = arg[4]
  if nx_number(ban_index) <= 0 then
    return
  end
  local gb, lbl_str
  if WuDaoTeamNo_1 == nx_number(team_no) then
    gb = form.gb_ban1
    lbl_str = "lbl_p1_ban"
  elseif WuDaoTeamNo_2 == nx_number(team_no) then
    gb = form.gb_ban2
    lbl_str = "lbl_p2_ban"
  else
    return
  end
  local lbl = gb:Find(nx_string(lbl_str) .. nx_string(ban_no))
  local lbl_x = gb:Find(nx_string(lbl_str) .. nx_string(ban_no) .. "_x")
  if nx_is_valid(lbl) and nx_is_valid(lbl_x) then
    local config = common_array:FindChild(get_array_name(ban_index), "wuxue")
    lbl.Text = nx_widestr(util_text(config))
    lbl.is_ban = true
    lbl.ban_index = nx_number(ban_index)
    lbl_x.Visible = true
    set_ban_rbtn_wuxue_single(form, team_no, ban_index)
  end
  set_ban_ani(form)
end
function update_player(...)
  local form = util_get_form(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local team_no = arg[1]
  local index = arg[2]
  local info = arg[3]
  local info_list = util_split_string(nx_string(info), ",")
  if table.getn(info_list) < 4 then
    return
  end
  local pos = nx_number(info_list[1])
  local name_more = info_list[2]
  local state = nx_number(info_list[3])
  local pick1 = nx_number(info_list[4])
  local pick2 = 0
  if table.getn(info_list) >= 5 then
    pick2 = nx_number(info_list[5])
  end
  local name_more_list = util_split_string(name_more, "@")
  local name = name_more_list[1]
  local server = ""
  if 2 <= table.getn(name_more_list) then
    server = name_more_list[2]
  end
  local gsb, gb_str, p_name_str, p_server_str, p_pick1_str, p_pick2_str, p_pos_str, p_state_str
  if WuDaoTeamNo_1 == nx_number(team_no) then
    gsb = form.gsb_p1
    gb_str = "gb_p1_"
    p_name_str = "lbl_p1_name_"
    p_server_str = "lbl_p1_server_"
    p_pick1_str = "lbl_p1_pick1_"
    p_pick2_str = "lbl_p1_pick2_"
    p_pos_str = "lbl_p1_leader_"
    p_state_str = "lbl_p1_leave_"
  elseif WuDaoTeamNo_2 == nx_number(team_no) then
    gsb = form.gsb_p2
    gb_str = "gb_p2_"
    p_name_str = "lbl_p2_name_"
    p_server_str = "lbl_p2_server_"
    p_pick1_str = "lbl_p2_pick1_"
    p_pick2_str = "lbl_p2_pick2_"
    p_pos_str = "lbl_p2_leader_"
    p_state_str = "lbl_p2_leave_"
  else
    return
  end
  local gb = gsb:Find(nx_string(gb_str) .. nx_string(index))
  local lbl_name = gb:Find(nx_string(p_name_str) .. nx_string(index))
  local lbl_server = gb:Find(nx_string(p_server_str) .. nx_string(index))
  local lbl_pick1 = gb:Find(nx_string(p_pick1_str) .. nx_string(index))
  local lbl_pick2 = gb:Find(nx_string(p_pick2_str) .. nx_string(index))
  local lbl_pos = gb:Find(nx_string(p_pos_str) .. nx_string(index))
  local lbl_state = gb:Find(nx_string(p_state_str) .. nx_string(index))
  lbl_name.Text = nx_widestr(name)
  lbl_server.Text = nx_widestr(server)
  if pos == 1 then
    lbl_pos.Visible = true
    if WuDaoTeamNo_1 == nx_number(team_no) then
      form.t1_leader = nx_widestr(name_more)
    elseif WuDaoTeamNo_2 == nx_number(team_no) then
      form.t2_leader = nx_widestr(name_more)
    end
  else
    lbl_pos.Visible = false
  end
  if state == WuDaoFightPlayerState_OK then
    lbl_state.Visible = false
  else
    lbl_state.Visible = true
  end
  if pick1 ~= 0 then
    lbl_pick1.Text = util_text(common_array:FindChild(get_array_name(pick1), "wuxue"))
    lbl_pick1.is_pick = true
    lbl_pick1.pick_index = pick1
    lbl_pick1.ForeColor = wuxue_color[common_array:FindChild(get_array_name(pick1), "color")]
    set_ban_rbtn_wuxue_single(form, nx_number(team_no), pick1)
  end
  if pick2 ~= 0 then
    lbl_pick2.Text = util_text(common_array:FindChild(get_array_name(pick2), "wuxue"))
    lbl_pick2.is_pick = true
    lbl_pick2.pick_index = pick2
    lbl_pick2.ForeColor = wuxue_color[common_array:FindChild(get_array_name(pick2), "color")]
    set_ban_rbtn_wuxue_single(form, nx_number(team_no), pick2)
  end
  set_banpick_btn(form)
end
function update_stage(...)
  local form = util_get_form(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local stage = arg[1]
  local left_time = arg[2]
  form.stage = nx_number(stage)
  form.lbl_time.Text = nx_widestr(math.floor(nx_number(left_time) / 1000))
  set_ban_ani(form)
  set_banpick_btn(form)
  set_ban_rbtn_wuxue(form)
  set_stage_lbl(form)
end
function set_stage_lbl(form)
  form.mltbox_1.Visible = false
  form.mltbox_2.Visible = false
  form.mltbox_3.Visible = false
  if WuDaoSubStep_Ban == form.stage then
    form.mltbox_1.Visible = true
  elseif WuDaoSubStep_Pick == form.stage then
    form.mltbox_2.Visible = true
  else
    form.mltbox_3.Visible = true
  end
end
function set_banpick_btn(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local player_name = client_player:QueryProp("Name")
  form.btn_ban.Visible = false
  form.btn_select.Visible = false
  local t_leader
  if form.ptype == PTYPE_1 then
    t_leader = form.t1_leader
  elseif form.ptype == PTYPE_2 then
    t_leader = form.t2_leader
  else
    return
  end
  if form.stage == WuDaoSubStep_Ban then
    if t_leader == nil then
      return
    end
    if nx_widestr(t_leader) == nx_widestr(player_name) then
      form.btn_ban.Visible = true
      return
    end
  elseif form.stage == WuDaoSubStep_Pick then
    form.btn_select.Visible = true
  end
end
function set_player_info(form, team_no, p_str)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local player_name = client_player:QueryProp("Name")
  local gsb, gb_str, p_bg_str, p_name_str, p_server_str, p_pick1_str, p_pick2_str, p_pos_str, p_state_str, gb_mod, lbl_bg_mod, lbl_name_mod, lbl_server_mod, lbl_pick1_mod, lbl_pick2_mod, lbl_pos_mod, lbl_state_mod
  if WuDaoTeamNo_1 == team_no then
    gsb = form.gsb_p1
    gb_str = "gb_p1_"
    p_bg_str = "lbl_p1_bg"
    p_name_str = "lbl_p1_name_"
    p_server_str = "lbl_p1_server_"
    p_pick1_str = "lbl_p1_pick1_"
    p_pick2_str = "lbl_p1_pick2_"
    p_pos_str = "lbl_p1_leader_"
    p_state_str = "lbl_p1_leave_"
    gb_mod = form.gb_p1_mod
    lbl_bg_mod = form.lbl_p1_bg
    lbl_name_mod = form.lbl_p1_name
    lbl_server_mod = form.lbl_p1_server
    lbl_pick1_mod = form.lbl_p1_pick1
    lbl_pick2_mod = form.lbl_p1_pick2
    lbl_pos_mod = form.lbl_p1_leader
    lbl_state_mod = form.lbl_p1_leave
  elseif WuDaoTeamNo_2 == team_no then
    gsb = form.gsb_p2
    gb_str = "gb_p2_"
    p_bg_str = "lbl_p2_bg"
    p_name_str = "lbl_p2_name_"
    p_server_str = "lbl_p2_server_"
    p_pick1_str = "lbl_p2_pick1_"
    p_pick2_str = "lbl_p2_pick2_"
    p_pos_str = "lbl_p2_leader_"
    p_state_str = "lbl_p2_leave_"
    gb_mod = form.gb_p2_mod
    lbl_bg_mod = form.lbl_p2_bg
    lbl_name_mod = form.lbl_p2_name
    lbl_server_mod = form.lbl_p2_server
    lbl_pick1_mod = form.lbl_p2_pick1
    lbl_pick2_mod = form.lbl_p2_pick2
    lbl_pos_mod = form.lbl_p2_leader
    lbl_state_mod = form.lbl_p2_leave
  else
    return
  end
  local p_list = util_split_string(nx_string(p_str), ";")
  if table.getn(p_list) == 0 then
    return
  end
  gsb.IsEditMode = true
  gsb:DeleteAll()
  for i = 1, table.getn(p_list) do
    local p_info = util_split_string(p_list[i], ",")
    if table.getn(p_info) >= 4 then
      local pos = nx_number(p_info[1])
      local name_more = p_info[2]
      local state = nx_number(p_info[3])
      local pick1 = nx_number(p_info[4])
      local pick2 = 0
      if table.getn(p_info) >= 5 then
        pick2 = nx_number(p_info[5])
      end
      if nx_widestr(player_name) == nx_widestr(name_more) then
        form.ptype = team_no
      end
      local name_more_list = util_split_string(nx_string(name_more), "@")
      local name = name_more_list[1]
      local server = ""
      if table.getn(name_more_list) >= 2 then
        server = name_more_list[2]
      end
      local gb = create_ctrl("GroupBox", nx_string(gb_str) .. nx_string(i), gb_mod, gsb)
      gb.Left = 0
      gb.index = nx_number(i)
      gb.pname = nx_widestr(name_more)
      local lbl_bg = create_ctrl("Label", nx_string(p_bg_str) .. nx_string(i), lbl_bg_mod, gb)
      local lbl_name = create_ctrl("Label", nx_string(p_name_str) .. nx_string(i), lbl_name_mod, gb)
      local lbl_server = create_ctrl("Label", nx_string(p_server_str) .. nx_string(i), lbl_server_mod, gb)
      local lbl_pick1 = create_ctrl("Label", nx_string(p_pick1_str) .. nx_string(i), lbl_pick1_mod, gb)
      local lbl_pick2 = create_ctrl("Label", nx_string(p_pick2_str) .. nx_string(i), lbl_pick2_mod, gb)
      local lbl_pos = create_ctrl("Label", nx_string(p_pos_str) .. nx_string(i), lbl_pos_mod, gb)
      local lbl_state = create_ctrl("Label", nx_string(p_state_str) .. nx_string(i), lbl_state_mod, gb)
      lbl_name.Text = nx_widestr(name)
      lbl_server.Text = nx_widestr(server)
      if pos == 1 then
        lbl_pos.Visible = true
        if WuDaoTeamNo_1 == team_no then
          form.t1_leader = nx_widestr(name_more)
        elseif WuDaoTeamNo_2 == team_no then
          form.t2_leader = nx_widestr(name_more)
        end
      else
        lbl_pos.Visible = false
      end
      if state == WuDaoFightPlayerState_OK then
        lbl_state.Visible = false
      else
        lbl_state.Visible = true
      end
      if pick1 ~= 0 then
        lbl_pick1.Text = util_text(common_array:FindChild(get_array_name(pick1), "wuxue"))
        lbl_pick1.is_pick = true
        lbl_pick1.pick_index = pick1
        lbl_pick1.ForeColor = wuxue_color[common_array:FindChild(get_array_name(pick1), "color")]
      end
      if pick2 ~= 0 then
        lbl_pick2.Text = util_text(common_array:FindChild(get_array_name(pick2), "wuxue"))
        lbl_pick2.is_pick = true
        lbl_pick2.pick_index = pick2
        lbl_pick2.ForeColor = wuxue_color[common_array:FindChild(get_array_name(pick2), "color")]
      end
    end
  end
  gsb.IsEditMode = false
  gsb:ResetChildrenYPos()
end
function set_ban_wuxue(gb, lbl_str, ban)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local ban_list = util_split_string(ban, ",")
  if table.getn(ban_list) == 0 then
    return
  end
  for i = 1, table.getn(ban_list) do
    local lbl = gb:Find(nx_string(lbl_str) .. nx_string(i))
    local lbl_x = gb:Find(nx_string(lbl_str) .. nx_string(i) .. "_x")
    if nx_is_valid(lbl) and nx_is_valid(lbl_x) then
      local config = common_array:FindChild(get_array_name(ban_list[i]), "wuxue")
      if config ~= nil then
        lbl.Text = nx_widestr(util_text(config))
        lbl.is_ban = true
        lbl.ban_index = nx_number(ban_list[i])
        lbl_x.Visible = true
      end
    end
  end
  set_ban_ani(gb.ParentForm)
end
function set_ban_ani(form)
  form.ani_p1_1.Visible = false
  form.ani_p1_2.Visible = false
  form.ani_p1_3.Visible = false
  form.ani_p2_1.Visible = false
  form.ani_p2_2.Visible = false
  form.ani_p2_3.Visible = false
  if form.stage ~= WuDaoSubStep_Ban then
    return
  end
  local ani1 = find_ani(form.gb_ban1, "lbl_p1_ban", "ani_p1_")
  if nx_is_valid(ani1) then
    ani1.Visible = true
    ani1:Play()
  end
  local ani2 = find_ani(form.gb_ban2, "lbl_p2_ban", "ani_p2_")
  if nx_is_valid(ani2) then
    ani2.Visible = true
    ani2:Play()
  end
end
function find_ani(gb_ban, lbl_p_ban_str, ani_ban_str)
  for i = 1, 3 do
    local lbl_p_ban = gb_ban:Find(lbl_p_ban_str .. nx_string(i))
    if nx_is_valid(lbl_p_ban) and not nx_find_custom(lbl_p_ban, "is_ban") then
      local ani = gb_ban:Find(ani_ban_str .. nx_string(i))
      return ani
    end
  end
  return nil
end
function set_ban_rbtn_wuxue(form)
  if form.ptype == PTYPE_0 then
    return
  end
  local lbl_p_ban1, lbl_p_ban2, lbl_p_ban3, lbl_o_ban1, lbl_o_ban2, lbl_o_ban3, gsb_p, lbl_p_pick1_str, lbl_p_pick2_str
  if form.ptype == PTYPE_1 then
    lbl_p_ban1 = form.lbl_p1_ban1
    lbl_p_ban2 = form.lbl_p1_ban2
    lbl_p_ban3 = form.lbl_p1_ban3
    lbl_o_ban1 = form.lbl_p2_ban1
    lbl_o_ban2 = form.lbl_p2_ban2
    lbl_o_ban3 = form.lbl_p2_ban3
    gsb_p = form.gsb_p1
    lbl_p_pick1_str = "lbl_p1_pick1_"
    lbl_p_pick2_str = "lbl_p1_pick2_"
  elseif form.ptype == PTYPE_2 then
    lbl_p_ban1 = form.lbl_p2_ban1
    lbl_p_ban2 = form.lbl_p2_ban2
    lbl_p_ban3 = form.lbl_p2_ban3
    lbl_o_ban1 = form.lbl_p1_ban1
    lbl_o_ban2 = form.lbl_p1_ban2
    lbl_o_ban3 = form.lbl_p1_ban3
    gsb_p = form.gsb_p2
    lbl_p_pick1_str = "lbl_p2_pick1_"
    lbl_p_pick2_str = "lbl_p2_pick2_"
  end
  if form.stage == WuDaoSubStep_Ban then
    if nx_find_custom(lbl_p_ban1, "ban_index") then
      set_ban_rbtn_wuxue_single(form, form.ptype, lbl_p_ban1.ban_index)
    end
    if nx_find_custom(lbl_p_ban2, "ban_index") then
      set_ban_rbtn_wuxue_single(form, form.ptype, lbl_p_ban2.ban_index)
    end
    if nx_find_custom(lbl_p_ban3, "ban_index") then
      set_ban_rbtn_wuxue_single(form, form.ptype, lbl_p_ban3.ban_index)
    end
  else
    if nx_find_custom(lbl_p_ban1, "ban_index") then
      cancel_ban_rbtn_wuxue_single(form, lbl_p_ban1.ban_index)
    end
    if nx_find_custom(lbl_p_ban2, "ban_index") then
      cancel_ban_rbtn_wuxue_single(form, lbl_p_ban2.ban_index)
    end
    if nx_find_custom(lbl_p_ban3, "ban_index") then
      cancel_ban_rbtn_wuxue_single(form, lbl_p_ban3.ban_index)
    end
    if nx_find_custom(lbl_o_ban1, "ban_index") then
      set_ban_rbtn_wuxue_single(form, form.ptype, lbl_o_ban1.ban_index, true)
    end
    if nx_find_custom(lbl_o_ban2, "ban_index") then
      set_ban_rbtn_wuxue_single(form, form.ptype, lbl_o_ban2.ban_index, true)
    end
    if nx_find_custom(lbl_o_ban3, "ban_index") then
      set_ban_rbtn_wuxue_single(form, form.ptype, lbl_o_ban3.ban_index, true)
    end
    local gb_p_list = gsb_p:GetChildControlList()
    for i = 1, table.getn(gb_p_list) do
      local gb = gb_p_list[i]
      if nx_is_valid(gb) then
        local lbl_p_pick1 = gb:Find(nx_string(lbl_p_pick1_str) .. nx_string(i))
        local lbl_p_pick2 = gb:Find(nx_string(lbl_p_pick2_str) .. nx_string(i))
        if nx_is_valid(lbl_p_pick1) and nx_find_custom(lbl_p_pick1, "pick_index") then
          set_ban_rbtn_wuxue_single(form, form.ptype, lbl_p_pick1.pick_index)
        end
        if nx_is_valid(lbl_p_pick2) and nx_find_custom(lbl_p_pick2, "pick_index") then
          set_ban_rbtn_wuxue_single(form, form.ptype, lbl_p_pick2.pick_index)
        end
      end
    end
  end
end
function set_ban_rbtn_wuxue_single(form, ptype, index, b_ban)
  if form.ptype ~= ptype then
    return
  end
  local rbtn = form.gsb_wuxue:Find("rbtn_wuxue_" .. nx_string(index))
  if not nx_is_valid(rbtn) then
    return
  end
  rbtn.Enabled = false
  if b_ban ~= nill and b_ban then
    form.gsb_wuxue.IsEditMode = true
    local lbl = create_ctrl("Label", "lbl_ban_" .. nx_string(index), form.lbl_ban_mod, form.gsb_wuxue)
    if nx_is_valid(lbl) then
      lbl.Left = rbtn.Left + lbl_ban_mod_left
      lbl.Top = rbtn.Top
      lbl.is_lbl = true
      lbl.Visible = rbtn.Visible
      lbl.index = rbtn.index
      lbl.config = rbtn.config
      lbl.color = rbtn.color
      lbl.weapon = rbtn.weapon
    end
    form.gsb_wuxue.IsEditMode = false
  end
end
function cancel_ban_rbtn_wuxue_single(form, index)
  local rbtn = form.gsb_wuxue:Find("rbtn_wuxue_" .. nx_string(index))
  if not nx_is_valid(rbtn) then
    return
  end
  rbtn.Enabled = true
end
function set_wuxue(form, wuxue_str)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local wuxue_list = util_split_string(wuxue_str, ",")
  if table.getn(wuxue_list) == 0 then
    return
  end
  form.gsb_wuxue.IsEditMode = true
  form.gsb_wuxue:DeleteAll()
  for i = 1, table.getn(wuxue_list) do
    local index = nx_number(wuxue_list[i])
    if index ~= 0 then
      local config = common_array:FindChild(get_array_name(index), "wuxue")
      local color = common_array:FindChild(get_array_name(index), "color")
      local weapon = common_array:FindChild(get_array_name(index), "weapon")
      local rbtn = create_ctrl("RadioButton", "rbtn_wuxue_" .. nx_string(index), form.rbtn_wuxue_mod, form.gsb_wuxue)
      nx_bind_script(rbtn, nx_current())
      nx_callback(rbtn, "on_checked_changed", "on_rbtn_wuxue_checked_changed")
      rbtn.index = index
      rbtn.config = config
      rbtn.color = color
      rbtn.weapon = weapon
      rbtn.Text = nx_widestr(util_text(config))
      rbtn.ForeColor = wuxue_color[color]
      rbtn.Left = left + math.fmod(i - 1, wuxue_pre_line) * (rbtn.Width + width_m)
      rbtn.Top = top + math.floor((i - 1) / wuxue_pre_line) * (rbtn.Height + height_m)
    end
  end
  form.gsb_wuxue.IsEditMode = false
end
function on_rbtn_wuxue_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.sl_wuxue = rbtn
  end
end
function do_sift(form)
  local rbtn_list = form.gsb_wuxue:GetChildControlList()
  for i = 1, table.getn(rbtn_list) do
    local rbtn = rbtn_list[i]
    if (form.sl_color == 0 or form.sl_color == nx_number(rbtn.color)) and (form.sl_weapon == 0 or form.sl_weapon == nx_number(rbtn.weapon)) then
      rbtn.Visible = true
    else
      rbtn.Visible = false
    end
  end
  refresh_gsb_wuxue(form)
end
function refresh_gsb_wuxue(form)
  local rbtn_list = form.gsb_wuxue:GetChildControlList()
  form.gsb_wuxue.IsEditMode = true
  local vis_count = 0
  for i = 1, table.getn(rbtn_list) do
    local ctrl = rbtn_list[i]
    if ctrl.Visible then
      vis_count = vis_count + 1
      if nx_find_custom(ctrl, "is_lbl") and ctrl.is_lbl then
        local rbtn = form.gsb_wuxue:Find("rbtn_wuxue_" .. ctrl.index)
        if nx_is_valid(rbtn) then
          ctrl.Left = rbtn.Left + lbl_ban_mod_left
          ctrl.Top = rbtn.Top
        end
      else
        ctrl.Left = left + math.fmod(vis_count - 1, wuxue_pre_line) * (ctrl.Width + width_m)
        ctrl.Top = top + math.floor((vis_count - 1) / wuxue_pre_line) * (ctrl.Height + height_m)
      end
    end
  end
  form.gsb_wuxue.IsEditMode = false
end
function get_gb_by_name(gsb, name)
  local gb_list = gsb:GetChildControlList()
  for i = 1, table.getn(gb_list) do
    local gb = gb_list[i]
    if nx_find_custom(gb, "pname") and nx_widestr(gb.pname) == name then
      return gb
    end
  end
  return nil
end
function init_combobox_weapon(form)
  form.combobox_weapon.DropListBox:ClearString()
  for i = 0, weapon_max do
    local text = "ui_wulin_banpick_weapon_" .. nx_string(i)
    form.combobox_weapon.DropListBox:AddString(nx_widestr(util_text(text)))
  end
  form.combobox_weapon.DropListBox.SelectIndex = 0
  form.combobox_weapon.Text = nx_widestr(form.combobox_weapon.DropListBox:GetString(0))
  form.sl_weapon = 0
end
function load_ini(form)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", INI_PATH)
  if not nx_is_valid(ini) then
    return
  end
  local section_count = ini:GetSectionCount()
  if section_count <= 0 then
    return
  end
  for i = nx_number(0), nx_number(section_count - 1) do
    local section = nx_number(ini:GetSectionByIndex(i))
    local array_name = get_array_name(section)
    common_array:RemoveArray(array_name)
    common_array:AddArray(array_name, form, 600, true)
    local wuxue = ini:ReadString(i, "wuxue", "")
    local color = ini:ReadInteger(i, "color", 0)
    local weapon = ini:ReadInteger(i, "weapon", 0)
    common_array:AddChild(array_name, "wuxue", nx_string(wuxue))
    common_array:AddChild(array_name, "color", nx_int(color))
    common_array:AddChild(array_name, "weapon", nx_int(weapon))
  end
end
function get_array_name(index)
  return ARRAY_NAME .. nx_string(index)
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
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
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  ctrl.Name = name
  return ctrl
end
function a(info)
  nx_msgbox(nx_string(info))
end
