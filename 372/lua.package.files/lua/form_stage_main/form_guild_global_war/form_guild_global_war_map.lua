require("util_gui")
require("define\\team_rec_define")
require("define\\map_lable_define")
require("form_stage_main\\switch\\switch_define")
local FORM_NAME = "form_stage_main\\form_guild_global_war\\form_guild_global_war_map"
local FORM_BUY = "form_stage_main\\form_guild_global_war\\form_guild_global_war_buy"
local FORM_WORD = "form_stage_main\\form_guild_global_war\\form_guild_global_war_word"
local image = {
  flag = "gui\\guild\\guildwar_new\\guildwar_flag_",
  side_flag = "gui\\guild\\guildwar_new\\ceqi_",
  relive = "gui\\guild\\guildwar_new\\yingdi_"
}
local flag_map_x = 428
local flag_map_y = 235
local zoom = 1.6
local origin_x = 0
local origin_z = 0
local orient_o = 0
function open_or_hide()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  else
    form = util_get_form(FORM_NAME, true)
    form:Show()
    form.Visible = true
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  local game_timer = nx_value("timer_game")
  game_timer:Register(1000, -1, nx_current(), "on_role_pos_changed", self, -1, -1)
  nx_execute("custom_sender", "custom_guildglobalwar", nx_int(101))
  nx_execute("custom_sender", "custom_guildglobalwar", nx_int(5))
  self.rbtn_3.Checked = true
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_GLOBAL_WAR_WORD) then
    self.btn_word.Visible = false
  end
  self.flag_buy = 0
  self.flag_num = 0
  self.camp_num = 0
  load_info_ini(self)
end
function on_main_form_close(self)
  ui_destroy_attached_form(self)
  local team_manager = nx_value("team_manager")
  if nx_is_valid(team_manager) then
    team_manager:DelBinder(nx_current(), "on_team_sub_rec_update", self)
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_role_pos_changed", self)
  end
  nx_destroy(self)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_rbtn_1_checked_changed(rbtn)
  if rbtn.Checked then
    nx_execute("form_stage_main\\form_map\\form_map_scene", "auto_show_hide_map_scene")
    open_or_hide()
  end
end
function on_rbtn_2_checked_changed(rbtn)
  if rbtn.Checked then
    nx_execute("form_stage_main\\form_guild_global_war\\form_guild_global_war_domain", "open_form_for_browse")
    open_or_hide()
  end
end
function on_rbtn_3_checked_changed(rbtn)
end
function on_btn_buy_click(btn)
  nx_execute(FORM_BUY, "open_form")
  local form = btn.ParentForm
  if nx_is_valid(form) then
    refresh_buy_flag(form.flag_buy, form.flag_num, form.camp_num)
  end
end
function on_btn_word_click(btn)
  nx_execute(FORM_WORD, "open_form")
end
function GetRotateAngle(x1, y1, x2, y2)
  local epsilon = 1.0E-6
  local angle
  local dist1 = math.sqrt(x1 * x1 + y1 * y1)
  local dist2 = math.sqrt(x2 * x2 + y2 * y2)
  if dist1 == 0 then
    dist1 = 1.0E-6
  end
  if dist2 == 0 then
    dist2 = 1.0E-6
  end
  x1 = x1 / dist1
  y1 = y1 / dist1
  x2 = x2 / dist2
  y2 = y2 / dist2
  local dot = x1 * x2 + y1 * y2
  if epsilon >= math.abs(dot - 1) then
    angle = 0
  elseif epsilon >= math.abs(dot + 1) then
    angle = math.pi
  else
    angle = math.acos(dot)
    local cross = x1 * y2 - x2 * y1
    if 0 < cross then
      angle = 2 * math.pi - angle
    end
  end
  return angle
end
function TransPosToMap(world_x, world_z)
  local x1 = world_x - origin_x
  local y1 = world_z - origin_z
  local x2 = math.sin(orient_o)
  local y2 = math.cos(orient_o)
  local dist = math.sqrt(x1 * x1 + y1 * y1)
  local dest_o = GetRotateAngle(x1, y1, x2, y2)
  local map_x = flag_map_x + math.sin(dest_o) * dist * zoom
  local map_y = flag_map_y + math.cos(dest_o) * dist * zoom
  return map_x, map_y
end
function on_role_pos_changed(form)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  local map_x, map_y = TransPosToMap(visual_player.PositionX, visual_player.PositionZ)
  form.lbl_self.Left = map_x - form.lbl_self.Width / 2
  form.lbl_self.Top = map_y - form.lbl_self.Height / 2
  form.lbl_self.AngleZ = orient_o - visual_player.AngleY + math.pi
  if not form.lbl_self.Visible then
    form.lbl_self.Visible = true
  end
  form:ToFront(form.lbl_self)
end
function refresh_all_info(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_refresh_all_info", form)
    timer:Register(500, 1, nx_current(), "on_refresh_all_info", form, -1, -1)
  end
end
function on_refresh_all_info(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_refresh_all_info", form)
  end
  local team_manager = nx_value("team_manager")
  if not nx_is_valid(team_manager) then
    return
  end
  local gui = nx_value("gui")
  local designer = gui.Designer
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local self_name = client_player:QueryProp("Name")
  local control_num = 0
  local record_table = team_manager:GetAllData()
  local rows = #record_table / 7
  if rows <= 0 then
    return
  end
  for index = 0, rows - 1 do
    local name = record_table[7 * index + TEAM_SUB_REC_COL_NAME + 1]
    if name ~= self_name then
      local posX = record_table[7 * index + TEAM_SUB_REC_COL_X + 1]
      local posY = record_table[7 * index + TEAM_SUB_REC_COL_Z + 1]
      local map_x, map_y = TransPosToMap(posX, posY)
      local ctrl_name = "player_" .. nx_string(control_num)
      local ctrl = form.gb_team:Find(ctrl_name)
      if nx_is_valid(ctrl) then
        ctrl.Top = map_y - ctrl.Height / 2
        ctrl.Left = map_x - ctrl.Width / 2
      else
        local control = designer:Create("Label")
        control.Name = ctrl_name
        control.BackImage = "gui\\map\\npcicon\\npctype169.png"
        control.AutoSize = true
        control.HintText = nx_widestr(gui.TextManager:GetText("ui_guild_war_map_friend"))
        control.Top = map_y - control.Height / 2
        control.Left = map_x - control.Width / 2
        designer:AddMember(ctrl_name)
        form.gb_team:Add(control)
        form:ToFront(control)
      end
      control_num = control_num + 1
    end
  end
  local i = control_num
  local ctrl_name = "player_" .. nx_string(i)
  while designer:FindMember(ctrl_name) do
    form.gb_team:Remove(form.gb_team:Find(ctrl_name))
    i = i + 1
    ctrl_name = "player_" .. nx_string(i)
  end
  form:ToFront(form.gb_team)
end
function on_team_sub_rec_update(form, opttype, ...)
  local cols = table.concat(arg, ",")
  if string.find(cols, nx_string(TEAM_SUB_REC_COL_X)) or string.find(cols, nx_string(TEAM_SUB_REC_COL_Z)) or nx_string(opttype) == nx_string("clear") or nx_string(opttype) == nx_string("del") or nx_string(opttype) == nx_string("add") or nx_string(opttype) == nx_string("update") then
    refresh_all_info(form)
  end
end
function test()
  update_info(101, "0,\206\210,1076.505,1,1142,0.469,2,0,\210\187,2,2,2,2,0,\182\254,3,3,3,3,2,0,\200\253,4,4,4,4,0,\203\196,5,5,5,5")
end
function a(info)
  nx_msgbox(nx_string(info))
end
function update_info(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local domain_id = nx_int(arg[1])
  local info = nx_widestr(arg[2])
  local info_wstr = util_split_wstring(info, nx_widestr(","))
  local flag_state = nx_int(info_wstr[1])
  local flag_owner = nx_widestr(info_wstr[2])
  local flag_x = nx_float(info_wstr[3])
  local flag_y = nx_float(info_wstr[4])
  local flag_z = nx_float(info_wstr[5])
  local flag_o = nx_float(info_wstr[6])
  origin_x = nx_number(info_wstr[3])
  origin_z = nx_number(info_wstr[5])
  orient_o = nx_number(info_wstr[6])
  create_gb(form, "flag", flag_state, flag_owner, flag_x, flag_y, flag_z, flag_o, image.flag)
  if nx_int(flag_state) == nx_int(2) then
    form.lbl_relive_d_1_owner.Text = nx_widestr(flag_owner)
    form.lbl_relive_d_2_owner.Text = nx_widestr(flag_owner)
  end
  local side_flag_nums = nx_number(info_wstr[7])
  local arg_index = 7
  for i = 1, side_flag_nums do
    local side_flag_state = nx_int(info_wstr[arg_index + 1])
    local side_flag_owner = nx_widestr("")
    local side_flag_x = nx_float(info_wstr[arg_index + 2])
    local side_flag_y = nx_float(info_wstr[arg_index + 3])
    local side_flag_z = nx_float(info_wstr[arg_index + 4])
    local side_flag_o = nx_float(info_wstr[arg_index + 5])
    if nx_int(flag_state) == nx_int(2) then
      side_flag_owner = flag_owner
    end
    arg_index = arg_index + 5
    if side_flag_state == nx_int(0) then
      side_flag_state = 3
    else
      side_flag_state = flag_state
    end
    create_gb(form, "side_flag_" .. nx_string(i), side_flag_state, side_flag_owner, side_flag_x, side_flag_y, side_flag_z, side_flag_o, image.side_flag)
  end
  local relive_nums = nx_number(info_wstr[arg_index + 1])
  arg_index = arg_index + 1
  for i = 1, relive_nums do
    local relive_state = nx_int(info_wstr[arg_index + 1])
    local relive_owner = nx_widestr(info_wstr[arg_index + 2])
    local relive_x = nx_float(info_wstr[arg_index + 3])
    local relive_y = nx_float(info_wstr[arg_index + 4])
    local relive_z = nx_float(info_wstr[arg_index + 5])
    local relive_o = nx_float(info_wstr[arg_index + 6])
    arg_index = arg_index + 6
    create_gb(form, "relive_" .. nx_string(i), relive_state, relive_owner, relive_x, relive_y, relive_z, relive_o, image.relive)
  end
  on_role_pos_changed(form)
  local team_manager = nx_value("team_manager")
  if nx_is_valid(team_manager) then
    team_manager:AddBinder(nx_current(), "on_team_sub_rec_update", form)
  end
end
function update_domain_info(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  if #arg < 5 then
    return
  end
  local guild_achi = nx_string(arg[1])
  local player_achi = nx_string(arg[2])
  local flag = nx_widestr(arg[3])
  local flag_num = nx_widestr(arg[4])
  local camp_num = nx_widestr(arg[5])
  form.flag_buy = flag
  form.flag_num = flag_num
  form.camp_num = camp_num
  show_guild_achievement(form, guild_achi)
  show_player_achievement(form, player_achi)
  form.lbl_flag.Text = flag_num .. nx_widestr("/") .. flag
  form.lbl_camp.Text = camp_num
  refresh_buy_flag(form.flag_buy, form.flag_num, form.camp_num)
end
function show_guild_achievement(form, guild_achi)
  if not nx_is_valid(form) then
    return
  end
  local guild_achi_tab = util_split_string(guild_achi, ",")
  if table.getn(guild_achi_tab) < 4 then
    return
  end
  local flag_time_aim = nx_int(guild_achi_tab[1])
  local kills_aim = nx_int(guild_achi_tab[2])
  local flag_times_aim = nx_int(guild_achi_tab[3])
  local guarder_kills_aim = nx_int(guild_achi_tab[4])
  local flag_time = nx_int(0)
  local kills = nx_int(0)
  local flag_times = nx_int(0)
  local guarder_kills = nx_int(0)
  if table.getn(guild_achi_tab) >= 8 then
    flag_time = nx_int(guild_achi_tab[5])
    kills = nx_int(guild_achi_tab[6])
    flag_times = nx_int(guild_achi_tab[7])
    guarder_kills = nx_int(guild_achi_tab[8])
  end
  form.lbl_flag_time.Text = nx_widestr(flag_time) .. nx_widestr("/") .. nx_widestr(flag_time_aim)
  form.lbl_kills.Text = nx_widestr(kills) .. nx_widestr("/") .. nx_widestr(kills_aim)
  form.lbl_flag_times.Text = nx_widestr(flag_times) .. nx_widestr("/") .. nx_widestr(flag_times_aim)
  form.lbl_guarder_kills.Text = nx_widestr(guarder_kills) .. nx_widestr("/") .. nx_widestr(guarder_kills_aim)
  form.lbl_aw_5.Visible = false
  form.lbl_aw_6.Visible = false
  form.lbl_aw_7.Visible = false
  form.lbl_aw_8.Visible = false
  if flag_time_aim <= flag_time then
    form.lbl_aw_5.Visible = true
    if kills_aim <= kills then
      form.lbl_aw_6.Visible = true
    end
    if flag_times_aim <= flag_times then
      form.lbl_aw_7.Visible = true
    end
    if guarder_kills_aim <= guarder_kills then
      form.lbl_aw_8.Visible = true
    end
  end
end
function show_player_achievement(form, player_achi)
  if not nx_is_valid(form) then
    return
  end
  local player_achi_tab = util_split_string(player_achi, ",")
  if table.getn(player_achi_tab) < 4 then
    return
  end
  local kills_aim = nx_int(player_achi_tab[1])
  local player_demage_aim = nx_int(player_achi_tab[2])
  local flag_demage_aim = nx_int(player_achi_tab[3])
  local guarder_demage_aim = nx_int(player_achi_tab[4])
  local kills = nx_int(0)
  local player_demage = nx_int(0)
  local flag_demage = nx_int(0)
  local guarder_demage = nx_int(0)
  if table.getn(player_achi_tab) >= 8 then
    kills = nx_int(player_achi_tab[5])
    player_demage = nx_int(player_achi_tab[6])
    flag_demage = nx_int(player_achi_tab[7])
    guarder_demage = nx_int(player_achi_tab[8])
  end
  form.lbl_p_kills.Text = nx_widestr(kills) .. nx_widestr("/") .. nx_widestr(kills_aim)
  form.lbl_p_player_demage.Text = nx_widestr(player_demage) .. nx_widestr("/") .. nx_widestr(player_demage_aim)
  form.lbl_p_flag_demage.Text = nx_widestr(flag_demage) .. nx_widestr("/") .. nx_widestr(flag_demage_aim)
  form.lbl_p_guarder_demage.Text = nx_widestr(guarder_demage) .. nx_widestr("/") .. nx_widestr(guarder_demage_aim)
  form.lbl_aw_1.Visible = false
  form.lbl_aw_2.Visible = false
  form.lbl_aw_3.Visible = false
  form.lbl_aw_4.Visible = false
  if player_demage_aim <= player_demage then
    form.lbl_aw_2.Visible = true
    if kills_aim <= kills then
      form.lbl_aw_1.Visible = true
    end
    if flag_demage_aim <= flag_demage then
      form.lbl_aw_3.Visible = true
    end
    if guarder_demage_aim <= guarder_demage then
      form.lbl_aw_4.Visible = true
    end
  end
end
function create_gb(form, name, state, owner, x, y, z, o, image)
  local gb = form:Find(name)
  if not nx_is_valid(gb) then
    gb = create_ctrl("GroupBox", name, form.gb_mod, form)
    if nx_is_valid(gb) then
      local ctrl_pic = create_ctrl("Label", name .. "_p", form.lbl_p, gb)
      local ctrl_state = create_ctrl("Label", name .. "_s", form.lbl_s, gb)
      local ctrl_owner = create_ctrl("Label", name .. "_o", form.lbl_o, gb)
      gb.pic = ctrl_pic
      gb.state = ctrl_state
      gb.owner = ctrl_owner
    end
  end
  local lbl_pic = gb.pic
  local lbl_state = gb.state
  local lbl_owner = gb.owner
  lbl_pic.HintText = nx_widestr(util_text("ui_global_war_shp_" .. nx_string(name)))
  lbl_pic.BackImage = nx_string(image) .. nx_string(state) .. ".png"
  lbl_state.Text = nx_widestr(util_text("ui_guild_state_" .. nx_string(state)))
  lbl_owner.Text = nx_widestr(owner)
  local map_x, map_y = TransPosToMap(x, z)
  gb.Left = map_x - gb.Width / 2
  gb.Top = map_y - gb.Height / 2
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
function load_info_ini(form)
  if not nx_is_valid(form) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local file = "ini\\ui\\guild\\GuildGlobalWar.ini"
  local ini = nx_execute("util_functions", "get_ini", file)
  if nx_is_valid(ini) and ini:FindSection("achievement_award") then
    local groupbox_award = form.groupbox_award
    if not nx_is_valid(groupbox_award) then
      return
    end
    local section = nx_int(ini:FindSectionIndex("achievement_award"))
    local item_count = nx_number(ini:GetSectionItemCount(section))
    for i = 0, item_count - 1 do
      local key = nx_string(ini:GetSectionItemKey(section, i))
      local item = nx_string(ini:GetSectionItemValue(section, i))
      local grid_name = "imagegrid_aw_" .. key
      local grid = groupbox_award:Find(grid_name)
      if nx_is_valid(grid) then
        grid:Clear()
        local photo = ItemQuery:GetItemPropByConfigID(item, "Photo")
        grid:AddItem(0, photo, nx_widestr(item), 1, -1)
      end
    end
  end
end
function refresh_buy_flag(flag_buy, flag_num, camp_num)
  local form_buy = nx_value(FORM_BUY)
  if not nx_is_valid(form_buy) then
    return
  end
  form_buy.lbl_flag_buy.Text = nx_widestr(flag_num) .. nx_widestr("/") .. nx_widestr(flag_buy)
  form_buy.lbl_camp_num.Text = nx_widestr(camp_num)
end
