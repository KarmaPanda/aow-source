require("util_functions")
require("custom_sender")
require("util_gui")
require("share\\static_data_type")
require("share\\itemtype_define")
require("define\\tip_define")
require("util_static_data")
require("tips_data")
require("util_functions")
require("form_stage_main\\switch\\switch_define")
require("form_stage_main\\form_tvt\\define")
local CLIENT_CUSTOMMSG_GUILD_GLOBAL_WAR = 803
local CLIENT_MSG_GGW_DOMAIN_MAP_INFO = 0
local CLIENT_MSG_GGW_GUILD_ACHIEVEMNT_RANK = 3
local CLIENT_MSG_GGW_PLAYER_ACHIEVEMNT_RANK = 4
local CLIENT_MSG_GGW_DOMAIN_TRANS = 6
local FORM_MAIN = "form_stage_main\\form_relation\\form_relation_guild\\form_cross_station_war_map"
local FORM_BUY = "form_stage_main\\form_guild_global_war\\form_guild_global_war_buy"
local FORM_TRANS = "form_stage_main\\form_guild_global_war\\form_guild_global_war_trans"
local FLAG_DEFAULT = "gui\\guild\\guildwar_new\\guildwar_flag_0.png"
local FLAG_NIL = "gui\\guild\\guildwar_new\\guildwar_flag_3.png"
local FLAG_BUILDING = "gui\\guild\\guildwar_new\\guildwar_flag_1.png"
local FLAG_BUILDED = "gui\\guild\\guildwar_new\\guildwar_flag_2.png"
local GGW_FLAG_STATE_DEFAULT = 0
local GGW_FLAG_STATE_NULL = 1
local GGW_FLAG_STATE_BUILDING = 2
local GGW_FLAG_STATE_BUILDED = 3
local GGW_STEP_NULL = 0
local GGW_STEP_PREPARATIVE = 1
local GGW_STEP_FIGHT = 2
local GGW_STEP_CALCULATE = 3
local tab_guild_domain_link = {}
local tab_domain_color = {
  [101] = "255,178,0,255",
  [201] = "255,128,128,128",
  [302] = "255,0,148,255",
  [402] = "255,214,127,255",
  [503] = "255,127,146,255",
  [602] = "255,255,233,127",
  [703] = "255,127,201,255",
  [801] = "255,255,216,0",
  [902] = "255,255,178,127",
  [1001] = "255,255,127,237",
  [1101] = "255,128,128,128",
  [1203] = "255,128,128,128",
  [1301] = "255,255,0,110",
  [1404] = "255,255,127,127",
  [1602] = "255,128,128,128",
  [1703] = "255,255,106,0"
}
local tab_domain_link = {
  [101] = {902, 1001},
  [302] = {1404, 801},
  [402] = {602, 503},
  [503] = {
    402,
    602,
    1301
  },
  [602] = {
    1301,
    402,
    503
  },
  [703] = {1404, 801},
  [801] = {
    1404,
    703,
    302,
    1301,
    1703
  },
  [902] = {
    1703,
    101,
    1001
  },
  [1001] = {
    101,
    902,
    1703
  },
  [1301] = {
    503,
    602,
    801,
    1703
  },
  [1404] = {
    302,
    703,
    801
  },
  [1703] = {
    1001,
    902,
    801,
    1301
  }
}
local tab_main_domain_id = {
  101,
  402,
  1404
}
local tab_domain_award = {}
local tab_achievement_award = {}
local tab_used = {}
function on_main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.step = 0
  self.flag_buy = 0
  self.flag_num = 0
  self.camp_num = 0
  self.domain_select = 0
  self.switch_cd = 0
  tab_used = {}
  init_form(self)
  nx_execute("custom_sender", "custom_guildglobalwar", CLIENT_MSG_GGW_DOMAIN_MAP_INFO)
  self.lbl_trans_cd.Text = nx_widestr(util_text("ui_guild_glo_trans_shp_007"))
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  tab_guild_domain_link = {}
  tab_domain_award = {}
  tab_achievement_award = {}
  tab_used = {}
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_switch_cd", form)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_player_rank_click(btn)
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_cross_station_war_h", "open_form", 1)
end
function on_btn_guild_rank_click(btn)
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_cross_station_war_h", "open_form", 2)
end
function close_form()
  local form = nx_value(FORM_MAIN)
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_form()
  local form = util_get_form(FORM_MAIN)
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", FORM_MAIN, true, false)
  end
  if not nx_is_valid(form) then
    return
  end
  form:Show()
end
function on_receive(...)
  local form = nx_value(FORM_MAIN)
  if not nx_is_valid(form) then
    return
  end
  if #arg < 3 then
    return
  end
  form.step = nx_int(arg[1])
  if nx_int(form.step) == nx_int(GGW_STEP_NULL) then
  else
    form.groupbox_2.Visible = true
  end
  local domain_info = nx_string(arg[2])
  show_domain_info(form, domain_info)
  check_link(form)
  refresh_domain_color(form)
  form.switch_cd = nx_int(arg[3])
  form.btn_trans.Enabled = true
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) and nx_int(form.switch_cd) > nx_int(0) then
    timer:UnRegister(nx_current(), "on_update_switch_cd", form)
    timer:Register(1000, -1, nx_current(), "on_update_switch_cd", form, -1, -1)
    form.btn_trans.Enabled = false
    on_update_switch_cd(form)
  end
end
function on_war_receive(...)
  local form = nx_value(FORM_MAIN)
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
  form.lbl_flag.Text = flag_num
  form.lbl_camp.Text = camp_num
  refresh_buy_flag(form.flag_buy, form.flag_num, form.camp_num)
end
function open_form_for_browse()
  local form = nx_value(FORM_MAIN)
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_auto_show_hide_form", FORM_MAIN)
  end
end
function on_rbtn_scene_map_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  nx_execute("form_stage_main\\form_map\\form_map_scene", "auto_show_hide_map_scene")
  rbtn.ParentForm:Close()
end
function on_rbtn_school_map_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  nx_execute("form_stage_main\\form_school_domain\\form_school_domain_map", "open_form_for_browse")
  rbtn.ParentForm:Close()
end
function on_rbtn_global_war_map_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_cross_station_war_small_map", "open_or_hide")
  rbtn.ParentForm:Close()
end
function show_domain_info(form, domain_info)
  if not nx_is_valid(form) then
    return
  end
  local domain_tab = util_split_string(domain_info, ",")
  for i = 1, table.getn(domain_tab) - 1, 3 do
    local domain_id = nx_number(domain_tab[i])
    local doamin_state = nx_number(domain_tab[i + 1])
    local guild_name = nx_widestr(domain_tab[i + 2])
    local lbl_back_name = "lbl_back_" .. nx_string(domain_id)
    local lbl_back = form.groupbox_domain:Find(lbl_back_name)
    if nx_is_valid(lbl_back) then
      if doamin_state == GGW_FLAG_STATE_NULL then
        lbl_back.BackImage = FLAG_NIL
      elseif doamin_state == GGW_FLAG_STATE_BUILDING then
        lbl_back.BackImage = FLAG_BUILDING
      elseif doamin_state == GGW_FLAG_STATE_BUILDED then
        lbl_back.BackImage = FLAG_BUILDED
      else
        lbl_back.BackImage = FLAG_DEFAULT
      end
    end
    if doamin_state == GGW_FLAG_STATE_BUILDED and nx_string(guild_name) ~= nx_string("") then
      if not is_table_have(tab_guild_domain_link, "guild_name", guild_name) then
        local tab = {}
        tab.guild_name = nx_string(guild_name)
        tab.color = ""
        tab.link = {main = 0, sub = 0}
        tab.domain = {}
        table.insert(tab_guild_domain_link, tab)
      end
      local index = nx_number(get_table_index(tab_guild_domain_link, "guild_name", guild_name))
      if 0 < index then
        table.insert(tab_guild_domain_link[index].domain, domain_id)
        if is_main_domain(domain_id) then
          local color = tab_guild_domain_link[index].color
          if color == nil or nx_string(color) == nx_string("") then
            tab_guild_domain_link[index].color = tab_domain_color[domain_id]
          end
        end
      end
    end
    local btn_area = get_btn_area(form, domain_id)
    if nx_is_valid(btn_area) then
      btn_area.guild_name = guild_name
      btn_area.doamin_state = doamin_state
    end
    local lbl_guildname = "lbl_guildname_" .. nx_string(domain_id)
    local lbl_guild = form.groupbox_guildname:Find(lbl_guildname)
    if nx_is_valid(lbl_guild) then
      lbl_guild.Text = nx_widestr(util_text("ui_golbal_war_shp_013"))
      if doamin_state ~= GGW_FLAG_STATE_NULL and doamin_state ~= GGW_FLAG_STATE_DEFAULT and guild_name ~= "" then
        lbl_guild.Text = nx_widestr(guild_name)
      end
    end
  end
end
function refresh_domain_color(form, domain_id, guild_name)
  if not nx_is_valid(form) then
    return
  end
  local btn_area = get_btn_area(form, domain_id)
  if not nx_is_valid(btn_area) then
    return
  end
  local color = tab_guild_domain_link[nx_string(guild_name)].color
  if color == nil then
    color = tab_domain_color[domain_id]
    tab_guild_domain_link[nx_string(guild_name)].color = color
  end
  if color == nil then
    return
  end
  btn_area.BlendColor = color
  btn_area.FocusBlendColor = color
  btn_area.PushBlendColor = color
  btn_area.DisableBlendColor = color
  local area_id = string.sub(nx_string(btn_area.Name), 10, -1)
  if btn_area.BlendColor == "255,255,255,255" then
    btn_area.NormalImage = "gui\\guild\\guild_new_jingbiao\\area_" .. nx_string(area_id) .. "_out.png"
    btn_area.FocusImage = "gui\\guild\\guild_new_jingbiao\\area_" .. nx_string(area_id) .. "_on.png"
  else
    btn_area.NormalImage = "gui\\guild\\guild_new_jingbiao\\area_" .. nx_string(area_id) .. "_white_out.png"
    btn_area.FocusImage = "gui\\guild\\guild_new_jingbiao\\area_" .. nx_string(area_id) .. "_white_on.png"
  end
end
function refresh_domain_color(form)
  if not nx_is_valid(form) then
    return
  end
  local area_list = form.groupbox_area:GetChildControlList()
  for i = 1, #area_list do
    local control = area_list[i]
    if nx_is_valid(control) and nx_find_custom(control, "doamin_state") and nx_int(control.doamin_state) == nx_int(GGW_FLAG_STATE_BUILDED) and nx_find_custom(control, "guild_name") and nx_string(control.guild_name) ~= nx_string("") then
      local index = nx_number(get_table_index(tab_guild_domain_link, "guild_name", control.guild_name))
      if 0 < index then
        local color = tab_guild_domain_link[index].color
        if color == nil or nx_string(color) == nx_string("") then
          color = tab_domain_color[nx_number(control.DataSource)]
          tab_guild_domain_link[index].color = color
        end
        control.BlendColor = color
        control.FocusBlendColor = color
        control.PushBlendColor = color
        control.DisableBlendColor = color
        local area_id = string.sub(nx_string(control.Name), 10, -1)
        if control.BlendColor == "255,255,255,255" then
          control.NormalImage = "gui\\guild\\guild_new_jingbiao\\area_" .. nx_string(area_id) .. "_out.png"
          control.FocusImage = "gui\\guild\\guild_new_jingbiao\\area_" .. nx_string(area_id) .. "_on.png"
        else
          control.NormalImage = "gui\\guild\\guild_new_jingbiao\\area_" .. nx_string(area_id) .. "_white_out.png"
          control.FocusImage = "gui\\guild\\guild_new_jingbiao\\area_" .. nx_string(area_id) .. "_white_on.png"
        end
      end
    end
  end
end
function get_btn_area(form, domain_id)
  if not nx_is_valid(form) then
    return
  end
  local area_list = form.groupbox_area:GetChildControlList()
  for i = 1, #area_list do
    local control = area_list[i]
    if nx_is_valid(control) and nx_int(control.DataSource) == nx_int(domain_id) then
      return control
    end
  end
  return
end
function on_btn_buy_click(btn)
  nx_execute(FORM_BUY, "open_form")
  local form = btn.ParentForm
  if nx_is_valid(form) then
    refresh_buy_flag(form.flag_buy, form.flag_num, form.camp_num)
  end
end
function refresh_buy_flag(flag_buy, flag_num, camp_num)
  local form_buy = nx_value(FORM_BUY)
  if not nx_is_valid(form_buy) then
    return
  end
  form_buy.lbl_flag_buy.Text = nx_widestr(flag_num)
  form_buy.lbl_camp_num.Text = nx_widestr(camp_num)
end
function on_btn_refresh_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  init_form(form)
  nx_execute("custom_sender", "custom_guildglobalwar", CLIENT_MSG_GGW_DOMAIN_MAP_INFO)
end
function on_btn_area_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  form.domain_select = nx_number(btn.DataSource)
  if nx_int(btn.DataSource) <= nx_int(0) then
    form.lbl_trans_scene.Text = nx_widestr(util_text("ui_guild_glo_trans_shp_006"))
  else
    form.lbl_trans_scene.Text = nx_widestr(util_text("ui_scene_" .. nx_string(get_scene_id_by_domain(btn.DataSource))))
  end
end
function on_btn_trans_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) and form.domain_select > 0 and nx_int(form.switch_cd) <= nx_int(0) then
    nx_execute("custom_sender", "custom_guildglobalwar", CLIENT_MSG_GGW_DOMAIN_TRANS, form.domain_select)
  end
end
function on_btn_trans_preview_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    nx_execute(FORM_TRANS, "open_form", form.domain_select)
  end
end
function on_update_switch_cd(form, param1, param2)
  form.switch_cd = nx_number(form.switch_cd) - 1
  if form.switch_cd < 0 then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_update_switch_cd", form)
      form.lbl_trans_cd.Text = nx_widestr(util_text("ui_guild_glo_trans_shp_007"))
      form.btn_trans.Enabled = true
    end
  else
    form.lbl_trans_cd.Text = get_format_time_text(form.switch_cd)
  end
end
function get_format_time_text(count_time)
  if nx_int(count_time) <= nx_int(0) then
    return nx_widestr(util_text("ui_guild_glo_trans_shp_007"))
  end
  local hour = nx_int(count_time / 3600)
  local min = nx_int(math.mod(count_time, 3600) / 60)
  local sec = nx_int(math.mod(math.mod(count_time, 3600), 60))
  local format_time = nx_widestr("")
  if hour > nx_int(0) then
    if hour < nx_int(10) then
      format_time = format_time .. nx_widestr(0)
    end
    format_time = format_time .. nx_widestr(hour) .. nx_widestr(":")
  end
  if min >= nx_int(0) then
    if min < nx_int(10) then
      format_time = format_time .. nx_widestr(0)
    end
    format_time = format_time .. nx_widestr(min) .. nx_widestr(":")
  end
  if sec >= nx_int(0) then
    if sec < nx_int(10) then
      format_time = format_time .. nx_widestr(0)
    end
    format_time = format_time .. nx_widestr(sec)
  end
  return format_time
end
function is_main_domain(domain_id)
  if nx_int(domain_id) <= nx_int(0) then
    return false
  end
  for i = 0, table.getn(tab_main_domain_id) do
    if nx_int(domain_id) == nx_int(tab_main_domain_id[i]) then
      return true
    end
  end
  return false
end
function refresh_player_trace(...)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if #arg < 15 then
    return
  end
  local tab_relive_info = util_split_string(nx_string(arg[4]), ",")
  local relive_state_1 = 0
  local relive_guild_1 = nx_widestr("")
  local relive_state_2 = 0
  local relive_guild_2 = nx_widestr("")
  if 4 <= #tab_relive_info then
    relive_state_1 = tab_relive_info[1]
    relive_guild_1 = nx_widestr(tab_relive_info[2])
    relive_state_2 = tab_relive_info[3]
    relive_guild_2 = nx_widestr(tab_relive_info[4])
  end
  local desc = nx_widestr(util_text("ui_golbal_war_shp_022"))
  desc = desc .. nx_widestr("<br>") .. nx_widestr(util_text("ui_golbal_war_shp_018")) .. nx_widestr(util_text("ui_global_war_state_" .. nx_string(arg[1]))) .. nx_widestr(" ") .. nx_widestr("<font color=\"#FFCC00\">") .. nx_widestr(arg[2]) .. nx_widestr("</font>")
  desc = desc .. nx_widestr("<br>") .. nx_widestr(util_text("ui_golbal_war_shp_019")) .. nx_widestr(arg[3])
  desc = desc .. nx_widestr("<br>") .. nx_widestr(util_text("ui_golbal_war_shp_020")) .. nx_widestr(util_text("ui_global_war_state_" .. nx_string(relive_state_1)) .. nx_widestr(" ") .. nx_widestr("<font color=\"#FFCC00\">") .. nx_widestr(relive_guild_1)) .. nx_widestr("</font>")
  desc = desc .. nx_widestr("<br>") .. nx_widestr(util_text("ui_golbal_war_shp_021")) .. nx_widestr(util_text("ui_global_war_state_" .. nx_string(relive_state_2)) .. nx_widestr(" ") .. nx_widestr("<font color=\"#FFCC00\">") .. nx_widestr(relive_guild_2)) .. nx_widestr("</font>")
  desc = desc .. nx_widestr("<br>")
  desc = desc .. nx_widestr("<br>") .. nx_widestr(util_text("ui_golbal_war_shp_023"))
  desc = desc .. nx_widestr("<br>") .. gui.TextManager:GetFormatText("ui_newguildwar3_001", nx_int(arg[9]), nx_int(arg[8]))
  desc = desc .. nx_widestr("<br>") .. gui.TextManager:GetFormatText("ui_newguildwar3_002", nx_int(arg[11]), nx_int(arg[10]))
  desc = desc .. nx_widestr("<br>") .. gui.TextManager:GetFormatText("ui_newguildwar3_004", nx_int(arg[13]), nx_int(arg[12]))
  desc = desc .. nx_widestr("<br>") .. gui.TextManager:GetFormatText("ui_newguildwar3_003", nx_int(arg[15]), nx_int(arg[14]))
  nx_execute("form_stage_main\\form_single_notice", "NotifyText", nx_int(111), desc)
  nx_execute(FORM_TIPS, "refresh_war_tips", arg[1], arg[2], arg[3], arg[4])
end
function init_form(form)
  if not nx_is_valid(form) then
    return
  end
  tab_guild_domain_link = {}
  local area_list = form.groupbox_area:GetChildControlList()
  for i = 1, #area_list do
    local control = area_list[i]
    if nx_is_valid(control) then
      local color = tab_domain_color[nx_number(control.DataSource)]
      control.BlendColor = "255,255,255,255"
      control.FocusBlendColor = color
      control.PushBlendColor = color
      control.DisableBlendColor = color
      local area_id = string.sub(nx_string(control.Name), 10, -1)
      control.NormalImage = "gui\\guild\\guild_new_jingbiao\\area_" .. nx_string(area_id) .. "_out.png"
      control.FocusImage = "gui\\guild\\guild_new_jingbiao\\area_" .. nx_string(area_id) .. "_on.png"
    end
  end
  local name_list = form.groupbox_guildname:GetChildControlList()
  for i = 1, #name_list do
    local control = name_list[i]
    if nx_is_valid(control) then
      control.Text = nx_widestr(util_text("ui_golbal_war_shp_013"))
    end
  end
  form.groupbox_2.Visible = false
  form.lbl_trans_scene.Text = nx_widestr(util_text("ui_guild_glo_trans_shp_006"))
  form.domain_select = 0
end
function check_link(form)
  if not nx_is_valid(form) then
    return
  end
  tab_used = {}
  for i = 1, table.getn(tab_guild_domain_link) do
    local tab_domain = tab_guild_domain_link[i].domain
    local main, sub = get_link_main_sub(form, tab_domain)
    tab_guild_domain_link[i].link.main = nx_int(main)
    tab_guild_domain_link[i].link.sub = nx_int(sub)
  end
  tab_used = {}
end
function get_link_main_sub(form, tab)
  local m_main = 0
  local m_sub = 0
  local main = 0
  local sub = 0
  for i = 1, table.getn(tab) do
    local domain = tab[i]
    if not is_table_have(tab_used, "", domain) then
      main = 0
      sub = 0
      table.insert(tab_used, domain)
      if is_main_domain(domain) then
        main = main + 1
      else
        sub = sub + 1
      end
      local main_s, sub_s = get_link_domain(form, domain, tab)
      main = main + main_s
      sub = sub + sub_s
      if m_main < main then
        m_main = main
        m_sub = sub
      elseif main == m_main and sub > m_sub then
        m_sub = sub
      end
    end
  end
  return m_main, m_sub
end
function get_link_domain(form, domain, tab)
  if not nx_is_valid(form) then
    return 0, 0
  end
  local main = 0
  local sub = 0
  for i = 1, table.getn(tab) do
    local domain_id = tab[i]
    if not is_table_have(tab_used, "", domain_id) and is_link(domain, domain_id) then
      table.insert(tab_used, domain_id)
      if is_main_domain(domain_id) then
        main = main + 1
      else
        sub = sub + 1
      end
      local main_s, sub_s = get_link_domain(form, domain_id, tab)
      main = main + main_s
      sub = sub + sub_s
    end
  end
  return main, sub
end
function is_link(domai_id1, domain_id2)
  local tab = tab_domain_link[nx_number(domai_id1)]
  if tab == nil then
    return false
  end
  for i = 0, table.getn(tab) do
    if nx_int(tab[i]) == nx_int(domain_id2) then
      return true
    end
  end
  return false
end
function is_table_have(tab, prop, value)
  for i = 1, table.getn(tab) do
    if nx_string(prop) ~= nx_string("") then
      if nx_string(tab[i][prop]) == nx_string(value) then
        return true
      end
    elseif nx_string(tab[i]) == nx_string(value) then
      return true
    end
  end
  return false
end
function get_table_index(tab, prop, value)
  for i = 1, table.getn(tab) do
    if nx_string(prop) ~= nx_string("") then
      if nx_string(tab[i][prop]) == nx_string(value) then
        return i
      end
    elseif nx_string(tab[i]) == nx_string(value) then
      return i
    end
  end
  return 0
end
function get_scene_id_by_domain(domain_id)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuildGlobalWar\\domain_info.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local index = ini:FindSectionIndex(nx_string(domain_id))
  if 0 <= index then
    return ini:ReadInteger(index, "scene_id", 0)
  end
  return 0
end
function a(info)
  nx_msgbox(nx_string(info))
end
