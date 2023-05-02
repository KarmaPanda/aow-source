require("util_gui")
require("util_functions")
require("define\\laba_define")
local SHOW_NUM = 100
local COL_COUNT = 10
local COL_WIDTHS = "60,80,80,80,50,60,100,130,95,80"
local FORCE_ERROR = 0
local SELF_DEFENSE = 1
local SELF_ATTACK = 2
local TYPE_PLAYER = 2
local SERVER_SUBMSG_STAT_SELF = 10
local SERVER_SUBMSG_STAT_NEW_VER = 11
local SERVER_SUBMSG_STAT_RIGHT_VER = 12
local SERVER_SUBMSG_STAT_ERROR_VER = 13
local SERVER_SUBMSG_STAT_END = 14
local CLIENT_SUBMSG_STAT_SELF = 10
local CLIENT_SUBMSG_STAT_NEW = 11
local CLIENT_SUBMSG_STAT_CHECK = 12
local CLIENT_CUSTOMMSG_GUILD_WAR = 8
local FORM_NAME = "form_stage_main\\form_guild_war\\form_guild_war_order"
local head_name = {
  ["2"] = {
    "ui_guildwar_order_mingci",
    "ui_guildwar_order_xingming",
    "ui_guildwar_order_bangpai",
    "ui_guildwar_order_shadi",
    "ui_guildwar_order_siwang",
    "ui_guildwar_order_qiangduoyahuan",
    "ui_guildwar_order_cuihuijiguan",
    "ui_guildwar_order_fenshaojianzhu",
    "ui_guildwar_order_special",
    "ui_guildwar_order_rongyuzhi"
  },
  ["1"] = {
    "ui_guildwar_order_mingci",
    "ui_guildwar_order_xingming",
    "ui_guildwar_order_bangpai",
    "ui_guildwar_order_shadi",
    "ui_guildwar_order_siwang",
    "ui_guildwar_order_jiejiuyahuan",
    "ui_guildwar_order_xiufujiguan",
    "ui_guildwar_order_pumiedahuo",
    "ui_guildwar_order_special",
    "ui_guildwar_order_rongyuzhi"
  }
}
function out_open()
  if is_in_war() then
    util_auto_show_hide_form(FORM_NAME)
  end
  return
end
function main_form_init(self)
  self.side = 0
  self.rank_rows = 0
  self.rank_string = ""
  self.win_side = 0
  local cache = nx_value("Cache_Guild_War_Order")
  if not nx_is_valid(cache) then
    local cache_list = get_global_arraylist("Cache_Guild_War_Order")
    init_rank_cache(cache_list)
  end
  self.Fixed = false
end
function on_main_form_open(self)
  if not nx_is_valid(self) then
    return
  end
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.rbtn_attack.Checked = true
  hide_effect(self)
  if is_in_war() then
    send_query_rank(CLIENT_SUBMSG_STAT_SELF, 0, 0)
  end
  return 1
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
  return
end
function on_btn_close_click(self)
  local form = self.Parent
  form:Close()
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_time_refresh", form)
end
function on_rbtn_checked_changed(self)
  local form = self.Parent
  if self.Checked then
    request_query(form, self.DataSource)
  end
end
function refresh_form(form, side)
  if not nx_is_valid(form) then
    return
  end
  form.textgrid_order:BeginUpdate()
  form.textgrid_order:ClearRow()
  form.textgrid_order.ColCount = COL_COUNT
  form.textgrid_order.ColWidths = COL_WIDTHS
  local gui = nx_value("gui")
  for i = 1, COL_COUNT do
    local temp_text = nx_widestr(gui.TextManager:GetText(head_name[nx_string(side)][i]))
    form.textgrid_order:SetColTitle(i - 1, nx_widestr(temp_text))
  end
  local string_table = util_split_string(nx_string(form.rank_string), ",")
  local begin_index = 1
  for row = 0, SHOW_NUM - 1 do
    if begin_index + COL_COUNT > table.getn(string_table) then
      break
    end
    form.textgrid_order:InsertRow(-1)
    for index = 0, COL_COUNT - 1 do
      form.textgrid_order:SetGridText(row, index, nx_widestr(string_table[begin_index]))
      begin_index = begin_index + 1
    end
  end
  form.textgrid_order:SortRowsByInt(0, false)
  form.textgrid_order:EndUpdate()
  form.rbtn_attack.Enabled = true
  form.rbtn_defend.Enabled = true
  set_ui_me(form, side)
  local defense_text = nx_widestr(gui.TextManager:GetText("ui_guildwar_order_fangshoufang"))
  local attack_test = nx_widestr(gui.TextManager:GetText("ui_guildwar_order_jingongfang"))
  local win_test = nx_widestr(gui.TextManager:GetText("ui_guildwar_order_huosheng"))
  local defense_win = nx_widestr(defense_text) .. nx_widestr(win_test)
  local attack_win = nx_widestr(attack_test) .. nx_widestr(win_test)
  if nx_int(form.win_side) == nx_int(SELF_DEFENSE) then
    form.lbl_wininfo.Text = nx_widestr(defense_win)
  elseif nx_int(form.win_side) == nx_int(SELF_ATTACK) then
    form.lbl_wininfo.Text = nx_widestr(attack_win)
  end
end
function request_query(form, side)
  if not nx_is_valid(form) then
    return
  end
  if side == nil or nx_int(side) == nx_int(0) then
    return
  end
  form.rbtn_attack.Enabled = false
  form.rbtn_defend.Enabled = false
  local rank_obj = get_cache(side)
  if not nx_is_valid(rank_obj) then
    return
  end
  if is_in_war() == false then
    if rank_obj.rank_string ~= "null" then
      on_use_cache(form, side)
      local timer = nx_value(GAME_TIMER)
      timer:Register(500, 1, nx_current(), "on_time_refresh", form, nx_int(side), -1)
    end
    return
  end
  if rank_obj.rank_string ~= "null" then
    send_query_rank(CLIENT_SUBMSG_STAT_CHECK, side, rank_obj.publish_time)
  else
    send_query_rank(CLIENT_SUBMSG_STAT_NEW, side, 0)
  end
end
function send_query_rank(sub_cmd, side, publish_time)
  if sub_cmd == nil or side == nil then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  if nx_int(sub_cmd) == nx_int(CLIENT_SUBMSG_STAT_SELF) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(sub_cmd))
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(sub_cmd), nx_int(side), nx_int64(publish_time))
end
function receive_data(sub_cmd, ...)
  if table.getn(arg) < 1 then
    return
  end
  local form = util_get_form(FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(sub_cmd) == nx_int(SERVER_SUBMSG_STAT_END) then
    nx_pause(math.random(8) - 1)
    form_main = util_get_form(FORM_NAME, true, false)
    if not nx_is_valid(form_main) then
      return
    end
    form_main.win_side = arg[2]
    form_main.rbtn_attack.Checked = false
    form_main.rbtn_defend.Checked = false
    form_main.Visible = true
    form_main:Show()
    effect_after_war_over(form_main.win_side)
    return
  end
  if nx_int(sub_cmd) == nx_int(SERVER_SUBMSG_STAT_SELF) then
    local self_info = arg[1]
    local string_table = util_split_string(nx_string(self_info), ",")
    if table.getn(string_table) < COL_COUNT then
      return
    end
    form.lbl_me_order.Text = nx_widestr(string_table[1])
    form.lbl_me_name.Text = nx_widestr(string_table[2])
    form.lbl_me_guild.Text = nx_widestr(string_table[3])
    form.lbl_me_kill.Text = nx_widestr(string_table[4])
    form.lbl_me_bekill.Text = nx_widestr(string_table[5])
    form.lbl_me_rob.Text = nx_widestr(string_table[6])
    form.lbl_me_destroy.Text = nx_widestr(string_table[7])
    form.lbl_me_burn.Text = nx_widestr(string_table[8])
    form.lbl_special.Text = nx_widestr(string_table[9])
    form.lbl_me_honor.Text = nx_widestr(string_table[10])
    return
  end
  local side = arg[1]
  if side == nil or nx_int(side) == nx_int(0) then
    return
  end
  if nx_int(sub_cmd) == nx_int(SERVER_SUBMSG_STAT_ERROR_VER) then
    on_clear_cache(side)
    send_query_rank(CLIENT_SUBMSG_STAT_NEW, side, 0)
    return
  end
  if nx_int(sub_cmd) == nx_int(SERVER_SUBMSG_STAT_RIGHT_VER) then
    on_use_cache(form, side)
    local timer = nx_value(GAME_TIMER)
    timer:Register(500, 1, nx_current(), "on_time_refresh", form, side, -1)
    return
  end
  if nx_int(sub_cmd) == nx_int(SERVER_SUBMSG_STAT_NEW_VER) then
    local publish_time = arg[2]
    local rank_rows = arg[3]
    local rank_string = arg[4]
    on_set_cache(form, side, rank_rows, publish_time, rank_string)
    on_use_cache(form, side)
    local timer = nx_value(GAME_TIMER)
    timer:Register(500, 1, nx_current(), "on_time_refresh", form, side, -1)
    return
  end
  return true
end
function on_time_refresh(form, side)
  if not nx_is_valid(form) then
    return
  end
  refresh_form(form, side)
end
function init_rank_cache(cache_list)
  if not nx_is_valid(cache_list) then
    return
  end
  cache_list:ClearChild()
  child = cache_list:CreateChild(nx_string(SELF_DEFENSE))
  if nx_is_valid(child) then
    child.total_rows = 0
    child.publish_time = -1
    child.rank_string = "null"
  end
  child = cache_list:CreateChild(nx_string(SELF_ATTACK))
  if nx_is_valid(child) then
    child.total_rows = 0
    child.publish_time = -1
    child.rank_string = "null"
  end
end
function on_clear_cache(side)
  local rank_obj = get_cache(side)
  if not nx_is_valid(rank_obj) then
    return
  end
  rank_obj.total_rows = 0
  rank_obj.publish_time = -1
  rank_obj.rank_string = "null"
  return
end
function get_cache(side)
  local cache = nx_value("Cache_Guild_War_Order")
  if not nx_is_valid(cache) then
    return
  end
  local obj = cache:GetChild(nx_string(side))
  if not nx_is_valid(obj) then
    return
  end
  return obj
end
function on_use_cache(form, side)
  local rank_obj = get_cache(side)
  if not nx_is_valid(rank_obj) then
    return
  end
  form.side = side
  form.rank_rows = rank_obj.total_rows
  form.rank_string = rank_obj.rank_string
  return
end
function on_set_cache(form, side, rank_rows, publish_time, rank_string)
  local rank_obj = get_cache(side)
  if nx_is_valid(rank_obj) then
    rank_obj.total_rows = rank_rows
    rank_obj.publish_time = publish_time
    rank_obj.rank_string = rank_string
  end
  return
end
function get_self_side()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return FORCE_ERROR
  end
  local force = client_player:QueryProp("GuildWarSide")
  return force
end
function get_self_domainid()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return FORCE_ERROR
  end
  local force = client_player:QueryProp("GuildWarDomainID")
  return force
end
function set_ui_me(form, side)
  local self_side = get_self_side()
  local same = false
  if nx_int(self_side) == nx_int(side) then
    same = true
  end
  form.lbl_me_order.Visible = same
  form.lbl_me_name.Visible = same
  form.lbl_me_guild.Visible = same
  form.lbl_me_kill.Visible = same
  form.lbl_me_bekill.Visible = same
  form.lbl_me_rob.Visible = same
  form.lbl_me_destroy.Visible = same
  form.lbl_me_burn.Visible = same
  form.lbl_special.Visible = same
  form.lbl_me_honor.Visible = same
end
function is_in_war()
  local self_side = get_self_side()
  local self_domainid = get_self_domainid()
  if (nx_int(self_side) == nx_int(SELF_DEFENSE) or nx_int(self_side) == nx_int(SELF_ATTACK)) and nx_int(self_domainid) > nx_int(0) then
    return true
  end
  return false
end
function effect_after_war_over(win_side)
  local self_side = get_self_side()
  hide_war_obj()
  start_timer(nx_int(self_side) == nx_int(win_side))
end
function hide_war_obj()
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local game_scene = game_client:GetScene()
  local client_obj_lst = game_scene:GetSceneObjList()
  for i, client_obj in pairs(client_obj_lst) do
    local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
    if nx_is_valid(visual_obj) and nx_is_valid(client_obj) then
      local obj_type = get_client_obj_type(client_obj)
      if not client_obj:FindProp("MainType") and nx_int(obj_type) ~= nx_int(TYPE_PLAYER) then
        local sceneobj = nx_value("scene_obj")
        sceneobj:RemoveObject(nx_string(client_obj.Ident))
      end
    end
  end
end
function get_client_obj_type(client_scene_obj)
  if not nx_is_valid(client_scene_obj) then
    return -1
  end
  return nx_int(client_scene_obj:QueryProp("Type"))
end
function start_timer(isWinner)
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_order")
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(3000, 1, nx_current(), "hide_effect", form, -1, -1)
    show_effect(form, isWinner)
  end
end
function show_effect(form, isWinner)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_win_text.Visible = isWinner
  form.lbl_lose_text.Visible = isWinner == false
end
function hide_effect(form)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_win_text.Visible = false
  form.lbl_lose_text.Visible = false
end
function send_guild_war_winner_speaker(...)
  local gui = nx_value("gui")
  local winner_guild = nx_widestr(arg[1])
  local loser_guild = nx_widestr(arg[2])
  local domain_str = nx_string(arg[3])
  nx_execute("form_stage_main\\form_main\\form_laba_info", "send_laba_immediate", gui.TextManager:GetText("ui_xiaolaba_special_tishi_1"), gui.TextManager:GetFormatText("ui_xiaolaba_special_title_1", nx_widestr(winner_guild), nx_widestr(loser_guild), nx_string(domain_str)), 7, CONFIRM_GUILD_WAR_WIN)
end
