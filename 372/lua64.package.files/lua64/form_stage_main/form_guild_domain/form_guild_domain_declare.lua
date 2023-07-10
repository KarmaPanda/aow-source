require("util_gui")
require("share\\client_custom_define")
require("util_functions")
require("define\\sysinfo_define")
require("share\\itemtype_define")
require("util_static_data")
local CLIENT_SUBMSG_REQUIRE_DECLARE_WAR = 1
local CLIENT_SUBMSG_DECLARE_COMPETE = 2
local CLIENT_SUBMSG_REQUEST_COMPETE_INFO = 25
local CLIENT_SUBMSG_REQUEST_COMPETE_RESULT = 26
local SUB_CUSTOMMSG_REQUEST_LEAGUE_GUILD = 38
local SUB_CUSTOMMSG_ADD_GUILD_ENEMY = 43
local DC_STAGE_NONE = 0
local DC_STAGE_FIRST_TURN = 1
local DC_STAGE_SECOND_TURN = 2
local DC_STAGE_THIRD_TURN = 3
local DC_STAGE_SELECT = 4
local self_domain_list = {}
local occupy_item_table = {
  "guild_occupy_tool_01",
  "guild_occupy_tool_02"
}
local ST_FUNCTION_NEW_GUILDWAR = 219
function main_form_init(form)
  form.Fixed = true
  form.life_time = 0
  form.declare_stage = 0
  form.is_selecting = 0
  form.IsInNewGuildWar = false
end
function on_main_form_open(form)
  form.textgrid_compete:SetColTitle(0, nx_widestr(util_text("ui_guildcompete_guild_name")))
  form.combobox_1.Text = nx_widestr(util_text("ui_qingxuanze"))
  form.combobox_1.DropListBox.SelectIndex = -1
  form.tool_index = -1
  for i = 1, table.getn(occupy_item_table) do
    form.combobox_1.DropListBox:AddString(nx_widestr(util_text(nx_string(occupy_item_table[i]))))
  end
  form.groupbox_domain_info.Visible = false
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form.IsInNewGuildWar = true
    form.groupbox_stage_0.Visible = false
    form.groupbox_domain_info.Visible = true
  else
    form.IsInNewGuildWar = false
  end
  return
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "update_time", form)
  end
  nx_destroy(form)
end
function on_btn_declare_compete_click(btn)
  local form = btn.ParentForm
  local stage = form.declare_stage
  if stage < DC_STAGE_FIRST_TURN or stage > DC_STAGE_THIRD_TURN then
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(util_text("guild_dc_not_in_compete"), 1, 0)
    end
    return
  end
  local form_guild_domain_map
  if nx_find_custom(form, "IsInNewGuildWar") and form.IsInNewGuildWar then
    form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_new_map")
  else
    form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_map")
  end
  if not nx_is_valid(form_guild_domain_map) then
    return
  end
  form_guild_domain_map.base_info.Visible = false
  hide_all_groupbox(form)
  form.groupbox_declare_compete.Visible = true
  form.fipt_guild_ding.Text = ""
  form.fipt_guild_liang.Text = ""
  form.fipt_guild_wen.Text = ""
  form.fipt_self_ding.Text = ""
  form.fipt_self_liang.Text = ""
  form.fipt_self_wen.Text = ""
  custom_request_info(CLIENT_SUBMSG_REQUEST_COMPETE_INFO)
end
function on_btn_look_compete_click(btn)
  local form_guild_domain_map
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_new_map")
  else
    form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_map")
  end
  if not nx_is_valid(form_guild_domain_map) then
    return
  end
  if not show_or_hide_declare_result(form_guild_domain_map) then
    return
  end
  local form = btn.ParentForm
  local stage = form.declare_stage
  if stage == DC_STAGE_NONE then
    custom_request_info(CLIENT_SUBMSG_REQUEST_COMPETE_RESULT)
  else
    custom_request_info(CLIENT_SUBMSG_REQUEST_COMPETE_INFO)
  end
end
function on_fipt_changed(fipt)
  local form = fipt.ParentForm
  local text = nx_string(fipt.Text)
  if string.find(text, "%D") then
    text = string.gsub(text, "%D", "")
    fipt.Text = nx_widestr(text)
  end
  local guild_silver = (nx_int(form.fipt_guild_ding.Text) * 1000 + nx_int(form.fipt_guild_liang.Text)) * 1000 + nx_int(form.fipt_guild_wen.Text)
  local self_silver = (nx_int(form.fipt_self_ding.Text) * 1000 + nx_int(form.fipt_self_liang.Text)) * 1000 + nx_int(form.fipt_self_wen.Text)
  local total_Silver = guild_silver + self_silver
  local gui = nx_value("gui")
  form.lbl_total_money.Text = nx_widestr(gui.TextManager:GetFormatText("ui_gc_money", nx_int64(total_Silver)))
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local guild_silver = (nx_int(form.fipt_guild_ding.Text) * 1000 + nx_int(form.fipt_guild_liang.Text)) * 1000 + nx_int(form.fipt_guild_wen.Text)
  local self_silver = (nx_int(form.fipt_self_ding.Text) * 1000 + nx_int(form.fipt_self_liang.Text)) * 1000 + nx_int(form.fipt_self_wen.Text)
  local total_Silver = guild_silver + self_silver
  if total_Silver <= 0 then
    return false
  end
  custom_request_info(CLIENT_SUBMSG_DECLARE_COMPETE, guild_silver, self_silver)
  form.fipt_guild_ding.Text = ""
  form.fipt_guild_liang.Text = ""
  form.fipt_guild_wen.Text = ""
  form.fipt_self_ding.Text = ""
  form.fipt_self_liang.Text = ""
  form.fipt_self_wen.Text = ""
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  local form_guild_domain_map
  if nx_find_custom(form, "IsInNewGuildWar") and form.IsInNewGuildWar then
    form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_new_map")
  else
    form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_map")
  end
  if not nx_is_valid(form_guild_domain_map) then
    return
  end
  hide_all_groupbox(form)
  form_guild_domain_map.base_info.Visible = true
  if nx_find_custom(form, "IsInNewGuildWar") and form.IsInNewGuildWar then
    form.groupbox_domain_info.Visible = true
  else
    form.groupbox_stage_0.Visible = true
  end
end
function on_btn_declare_click(btn)
  local gui = nx_value("gui")
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local form_guild_domain_map
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_new_map")
  else
    form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_map")
  end
  if not nx_is_valid(form_guild_domain_map) then
    return
  end
  local form = btn.ParentForm
  local domain_id = nx_int(form_guild_domain_map.cur_domain_id)
  local list_box = form.combobox_self_domain.DropListBox
  local self_domain_id = 0
  local domain_counts = list_box.ItemCount
  if 0 < domain_counts then
    local sel_row = list_box.SelectIndex
    if sel_row < 0 then
      local show_text = gui.TextManager:GetText("guild_dc_not_choice_self_domain")
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(show_text, CENTERINFO_PERSONAL_NO)
      end
      return false
    elseif sel_row < #self_domain_list then
      self_domain_id = nx_int(self_domain_list[sel_row + 1])
    end
  end
  custom_request_info(CLIENT_SUBMSG_REQUIRE_DECLARE_WAR, nx_int(1), nx_int(domain_id), nx_int(self_domain_id), nx_int(form.tool_index))
end
function on_btn_league_click(btn)
  local form_guild_domain_info = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_info")
  if not nx_is_valid(form_guild_domain_info) then
    return
  end
  local guild_name = form_guild_domain_info.lbl_info_owner_name.Text
  local index_begin, index_end = string.find(nx_string(guild_name), "%(")
  if index_end ~= nil then
    guild_name = string.sub(nx_string(guild_name), 1, index_end - 1)
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_LEAGUE_GUILD), nx_widestr(guild_name))
end
function on_btn_enemy_click(btn)
  local form_guild_domain_info = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_info")
  if not nx_is_valid(form_guild_domain_info) then
    return
  end
  local guild_name = form_guild_domain_info.lbl_info_owner_name.Text
  local index_begin, index_end = string.find(nx_string(guild_name), "%(")
  if index_end ~= nil then
    guild_name = string.sub(nx_string(guild_name), 1, index_end - 1)
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_ADD_GUILD_ENEMY), nx_widestr(guild_name))
end
function on_combobox_1_selected(self)
  local form = self.ParentForm
  form.tool_index = self.DropListBox.SelectIndex + 1
end
function custom_request_info(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(sub_msg), unpack(arg))
end
function init_declare_info(...)
  if #arg < 2 then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local form_guild_domain_map
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_new_map")
  else
    form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_map")
  end
  local form = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_declare")
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_declare_new")
  end
  if not nx_is_valid(form_guild_domain_map) or not nx_is_valid(form) then
    return
  end
  local compete_stage = arg[1]
  local domain_count = arg[2]
  form.declare_stage = compete_stage
  form.lbl_compete_stage_text.Text = nx_widestr(util_text("ui_gc_title_" .. nx_string(compete_stage)))
  self_domain_list = {}
  if 0 < domain_count and #arg > domain_count + 1 then
    form.combobox_self_domain.DropListBox:ClearString()
    form.combobox_self_domain.DropListBox.SelectIndex = -1
    form.combobox_self_domain.Text = nx_widestr(util_text("ui_guild_domain_select"))
    for i = 1, domain_count do
      form.combobox_self_domain.DropListBox:AddString(nx_widestr(util_text("ui_dipan_" .. nx_string(arg[i + 2]))))
      table.insert(self_domain_list, arg[i + 2])
    end
  end
  local begin_index = domain_count + 2
  local cols = 6
  if nx_find_custom(form, "IsInNewGuildWar") and form.IsInNewGuildWar then
    cols = 14
  end
  local count = (#arg - begin_index) / cols
  local default_domain_id
  for j = 0, count - 1 do
    local domain_id = arg[begin_index + j * cols + 1]
    local domain_stage = arg[begin_index + j * cols + 2]
    local colour_id = arg[begin_index + j * cols + 3]
    local guild_name = arg[begin_index + j * cols + 4]
    local field_num = arg[begin_index + j * cols + 5]
    local score_flag = arg[begin_index + j * cols + 6]
    local real_colour = get_real_colour(colour_id, nil, "255")
    local control_lbl_name = "lbl_back_" .. nx_string(domain_id)
    local control_btn_name = "btn_domain_" .. nx_string(domain_id)
    local control_show_name = "lbl_domain_" .. nx_string(domain_id)
    local control_lbl = form_guild_domain_map.groupbox_domain:Find(control_lbl_name)
    local control_btn = form_guild_domain_map.groupbox_domain:Find(control_btn_name)
    local control_show = form_guild_domain_map.groupbox_show_name:Find(control_show_name)
    if nx_is_valid(control_lbl) and nx_is_valid(control_btn) and nx_is_valid(control_show) then
      control_btn.DataSource = nx_string(domain_stage)
      local img_index = domain_stage
      if nx_int(domain_stage) == nx_int(4) or nx_int(domain_stage) == nx_int(5) then
        img_index = 3
      end
      if nx_int(img_index) == nx_int(1) then
        control_btn.NormalImage = "gc_icon_1_out"
        control_btn.FocusImage = "gc_icon_1_on"
      elseif nx_int(img_index) == nx_int(2) and nx_int(score_flag) > nx_int(0) then
        control_btn.NormalImage = "guildwar_score_out"
        control_btn.FocusImage = "guildwar_score_on"
      else
        control_btn.NormalImage = "gui\\guild\\guild_jingbiao\\gc_icon_" .. nx_string(img_index) .. "_out.png"
        control_btn.FocusImage = "gui\\guild\\guild_jingbiao\\gc_icon_" .. nx_string(img_index) .. "_on.png"
      end
      control_btn.PushImage = "gui\\guild\\guild_jingbiao\\gc_icon_" .. nx_string(img_index) .. "_down.png"
      control_lbl.BlendColor = real_colour
      control_btn.colour_id = colour_id
      control_btn.domain_id = domain_id
      control_show.domain_id = domain_id
      control_show.guild_name = guild_name
      control_btn.HintText = nx_widestr(util_format_string("ui_dipan_tips", "ui_scene_" .. string.sub(nx_string(domain_id), 1, -3), "ui_dipan_" .. nx_string(domain_id), nx_widestr(guild_name), "ui_dipan_scale_" .. nx_string(field_num)))
      if nx_find_custom(form, "IsInNewGuildWar") and form.IsInNewGuildWar and arg[begin_index + j * cols + 7] == 1 then
        control_btn.Visible = true
        control_show.Visible = true
        control_btn.GuildName = guild_name
        control_btn.DomainType = arg[begin_index + j * cols + 8]
        if default_domain_id == nil then
          default_domain_id = 1404
          form_guild_domain_map.cur_domain_id = default_domain_id
        end
        local tianwei = arg[begin_index + j * cols + 9]
        local qifu = arg[begin_index + j * cols + 10]
        local domainlevel = arg[begin_index + j * cols + 11]
        local domain_occupy_time = arg[begin_index + j * cols + 12]
        local get_weapon_player = arg[begin_index + j * cols + 13]
        local weapon_index = arg[begin_index + j * cols + 14]
        if nx_string(tianwei) == nx_string("") then
          tianwei = 0
        end
        local NormalImage = "gui\\guild\\newguildwar\\domain_" .. nx_string(domainlevel) .. "_" .. nx_string(tianwei) .. "_out.png"
        local FocusImage = "gui\\guild\\newguildwar\\domain_" .. nx_string(domainlevel) .. "_" .. nx_string(tianwei) .. "_on.png"
        local PushImage = "gui\\guild\\newguildwar\\domain_" .. nx_string(domainlevel) .. "_" .. nx_string(tianwei) .. "_down.png"
        control_btn.NormalImage = NormalImage
        control_btn.FocusImage = FocusImage
        control_btn.PushImage = PushImage
        local control_lbl_zhanling_name = "lbl_zhanling_" .. nx_string(domain_id)
        local control_lbl_zhanling = form_guild_domain_map.groupbox_1:Find(control_lbl_zhanling_name)
        if nx_is_valid(control_lbl_zhanling) and nx_widestr(guild_name) ~= nx_widestr("") then
          control_lbl_zhanling.Visible = true
          control_lbl_zhanling.BackImage = "gui\\guild\\newguildwar\\domain_zhanling.png"
          local week = 0
          week = math.floor(domain_occupy_time / 7)
          local control_lbl_zhanling_time_name = "lbl_time_" .. nx_string(domain_id)
          local control_lbl_zhanling_time = form_guild_domain_map.groupbox_show_time:Find(control_lbl_zhanling_time_name)
          if nx_is_valid(control_lbl_zhanling_time) then
            if week == 0 then
              control_lbl_zhanling_time.Text = nx_widestr(util_text("ui_guild_occupytime_1"))
            else
              control_lbl_zhanling_time.Text = nx_widestr(util_format_string("ui_guild_occupytime_2", nx_int(week)))
            end
            control_lbl_zhanling_time.Visible = true
          end
        end
        local control_lbl_qifu_name = "lbl_qifu_" .. nx_string(domain_id)
        local control_lbl_qifu = form_guild_domain_map.groupbox_1:Find(control_lbl_qifu_name)
        if nx_is_valid(control_lbl_qifu) and nx_string(qifu) ~= nx_string("") then
          control_lbl_qifu.Visible = true
          control_lbl_qifu.BackImage = "gui\\guild\\newguildwar\\domain_qifu.png"
        end
        local control_lbl_declared_name = "lbl_atk_" .. nx_string(domain_id)
        local control_lbl_declared = form_guild_domain_map.groupbox_2:Find(control_lbl_declared_name)
        if nx_is_valid(control_lbl_declared) then
          control_lbl_declared.BackImage = "newguildwar_atk_" .. domain_stage
          control_lbl_declared.Visible = true
        end
        if nx_widestr(get_weapon_player) ~= nx_widestr("") and nx_int(weapon_index) >= nx_int(0) then
          local control_lbl_shengbing_value_name = "lbl_shengbing_value_" .. nx_string(domain_id)
          local control_lbl_shengbing_value = form_guild_domain_map.groupbox_5:Find(control_lbl_shengbing_value_name)
          if nx_is_valid(control_lbl_shengbing_value) then
            control_lbl_shengbing_value.Text = nx_widestr(get_weapon_player)
            control_lbl_shengbing_value.ShengBingFlag = 1
          end
        end
      end
    end
    if form_guild_domain_map.cur_domain_id == domain_id then
      form_guild_domain_map.cur_domain_stage = domain_stage
    end
  end
  if nx_find_custom(form, "IsInNewGuildWar") and form.IsInNewGuildWar then
    nx_execute("form_stage_main\\form_guild_domain\\form_guild_domain_map", "custom_request_domian", form_guild_domain_map.cur_domain_id)
  end
  refresh_area_colour(form_guild_domain_map)
  updata_domain_info()
  nx_execute("form_stage_main\\form_guild_domain\\form_guild_domain_map", "updata_guild_name_text", form_guild_domain_map)
  if compete_stage < DC_STAGE_FIRST_TURN or compete_stage > DC_STAGE_THIRD_TURN then
    form.btn_declare_compete.Enabled = false
  else
    form.btn_declare_compete.Enabled = true
  end
  if (compete_stage == DC_STAGE_SELECT or form.btn_declare_compete.Enabled) and form.btn_declare_compete.Visible then
    form.lbl_flash.Visible = true
  else
    form.lbl_flash.Visible = false
  end
  if compete_stage == DC_STAGE_SELECT then
    custom_request_info(CLIENT_SUBMSG_REQUEST_COMPETE_INFO)
  end
end
function open_declare_form(time)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local form_guild_domain_map
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_new_map")
  else
    form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_map")
  end
  if nx_is_valid(form_guild_domain_map) then
    form_guild_domain_map:Close()
  end
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form_guild_domain_map = util_show_form("form_stage_main\\form_guild_domain\\form_guild_domain_new_map", true)
  else
    form_guild_domain_map = util_show_form("form_stage_main\\form_guild_domain\\form_guild_domain_map", true)
  end
  local form = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_declare")
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_declare_new")
  end
  if not nx_is_valid(form_guild_domain_map) or not nx_is_valid(form) then
    return
  end
  form_guild_domain_map.Visible = true
  form_guild_domain_map.rbtn_2.Checked = true
  hide_all_groupbox(form)
  form_guild_domain_map.base_info.Visible = true
  form.groupbox_declare.Visible = true
  form.is_selecting = 1
  show_timer(time, DC_STAGE_SELECT)
end
function close_declare_form()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local form_guild_domain_map
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_new_map")
  else
    form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_map")
  end
  local form = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_declare")
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_declare_new")
  end
  if not nx_is_valid(form_guild_domain_map) or not nx_is_valid(form) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "update_time", form)
  end
  nx_execute("form_stage_main\\form_guild_domain\\form_guild_domain_map", "hide_all_sub_page", form_guild_domain_map)
  form_guild_domain_map.base_info.Visible = true
  form_guild_domain_map.guild_declare.Visible = true
  custom_request_info(CLIENT_SUBMSG_REQUEST_COMPETE_INFO)
end
function updata_domain_info(...)
  local form = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_declare")
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_declare_new")
  end
  if not nx_is_valid(form) then
    return
  end
  local form_guild_domain_map
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_new_map")
    form.IsInNewGuildWar = true
  else
    form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_map")
  end
  if not nx_is_valid(form) or not nx_is_valid(form_guild_domain_map) then
    return
  end
  if form_guild_domain_map.need_change_form > 0 then
    hide_all_groupbox(form)
    form_guild_domain_map.base_info.Visible = true
    if form.declare_stage == DC_STAGE_SELECT and 0 < form.is_selecting then
      form.groupbox_declare.Visible = true
    elseif nx_find_custom(form, "IsInNewGuildWar") and form.IsInNewGuildWar then
      form.groupbox_domain_info.Visible = true
    else
      form.groupbox_stage_0.Visible = true
    end
  end
  local gui = nx_value("gui")
  form.lbl_domain_name.Text = nx_widestr(util_text("ui_dipan_" .. nx_string(form_guild_domain_map.cur_domain_id)))
  form.lbl_domain_stage.Text = nx_widestr(util_text("ui_dm_stage_" .. nx_string(form_guild_domain_map.cur_domain_stage)))
  form.lbl_declare_domain.Text = nx_widestr(util_text("ui_dipan_" .. nx_string(form_guild_domain_map.cur_domain_id)))
  form.lbl_targer_stage.Text = nx_widestr(util_text("ui_dm_stage_" .. nx_string(form_guild_domain_map.cur_domain_stage)))
  if #arg < 10 then
    return
  end
  local text = ""
  if nx_int(form_guild_domain_map.cur_domain_stage) == nx_int(1) then
    text = gui.TextManager:GetFormatText("ui_dm_declare_guild", nx_widestr(arg[9]))
  elseif (nx_int(form_guild_domain_map.cur_domain_stage) == nx_int(3) or nx_int(form_guild_domain_map.cur_domain_stage) == nx_int(4) or nx_int(form_guild_domain_map.cur_domain_stage) == nx_int(5)) and nx_int(arg[10]) > nx_int(0) then
    local cool_down_time = nx_int(arg[10] / 3600)
    text = gui.TextManager:GetFormatText("ui_dm_cool_down_time", nx_int(cool_down_time))
  end
  form.lbl_stage_info.Text = nx_widestr(text)
  form.lbl_declare_stage_info.Text = nx_widestr(text)
  if form.declare_stage < DC_STAGE_FIRST_TURN or form.declare_stage > DC_STAGE_THIRD_TURN then
    form.btn_declare_compete.Enabled = false
  else
    form.btn_declare_compete.Enabled = true
  end
  if (compete_stage == DC_STAGE_SELECT or form.btn_declare_compete.Enabled) and form.btn_declare_compete.Visible then
    form.lbl_flash.Visible = true
  else
    form.lbl_flash.Visible = false
  end
  if nx_find_custom(form, "IsInNewGuildWar") and form.IsInNewGuildWar then
    form.cur_domain_id = form_guild_domain_map.cur_domain_id
    new_guild_war_update_declare_info(form, unpack(arg))
  end
end
function updata_declare_compete_result(...)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local form = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_declare")
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_declare_new")
  end
  local form_guild_domain_map
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_new_map")
  else
    form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_map")
  end
  if not nx_is_valid(form_guild_domain_map) or not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.textgrid_compete:ClearRow()
  local stage = arg[1]
  local is_selecting = arg[2]
  local select_index = arg[3]
  local money = arg[4]
  form.declare_stage = stage
  if form.is_selecting ~= is_selecting then
    form.is_selecting = is_selecting
    form_guild_domain_map.need_change_form = 1
    updata_domain_info()
  end
  form.lbl_compete_stage_text.Text = nx_widestr(util_text("ui_gc_title_" .. nx_string(stage)))
  form.lbl_money.Text = nx_widestr(gui.TextManager:GetFormatText("ui_gc_money", nx_int64(money)))
  if stage < DC_STAGE_FIRST_TURN or stage > DC_STAGE_THIRD_TURN then
    form.btn_declare_compete.Enabled = false
  else
    form.btn_declare_compete.Enabled = true
  end
  if (compete_stage == DC_STAGE_SELECT or form.btn_declare_compete.Enabled) and form.btn_declare_compete.Visible then
    form.lbl_flash.Visible = true
  else
    form.lbl_flash.Visible = false
  end
  nx_execute("form_stage_main\\form_guild_domain\\form_guild_look_compete", "open_form_by_server_data", unpack(arg))
end
function show_timer(time, stage)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local form = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_declare")
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_declare_new")
  end
  if not nx_is_valid(form) then
    return
  end
  form.declare_stage = stage
  if stage ~= DC_STAGE_SELECT then
    form.is_selecting = 0
  end
  local temp_stage = stage + form.is_selecting
  if temp_stage == DC_STAGE_SELECT then
    form.lbl_compete_time.Visible = false
  else
    form.lbl_compete_time.Visible = true
  end
  form.lbl_compete_stage_text.Text = nx_widestr(util_text("ui_gc_title_" .. nx_string(temp_stage)))
  local gui = nx_value("gui")
  local timer = nx_value(GAME_TIMER)
  if not nx_is_valid(timer) then
    return
  end
  if stage == DC_STAGE_NONE then
    local begin_hour = nx_int(time / 60)
    local begin_minute = nx_int(time % 60)
    form.lbl_compete_time.Text = nx_widestr(gui.TextManager:GetFormatText("ui_dm_declare_time", begin_hour, begin_minute))
    return
  elseif stage > DC_STAGE_THIRD_TURN then
    form.lbl_compete_time.Text = ""
  end
  if 0 < time then
    form.life_time = time
    timer:UnRegister(nx_current(), "update_time", form)
    timer:Register(1000, -1, nx_current(), "update_time", form, -1, -1)
    update_time(form)
  end
end
function hide_all_groupbox(form)
  form.groupbox_stage_0.Visible = false
  form.groupbox_declare_compete.Visible = false
  form.groupbox_look_compete.Visible = false
  form.groupbox_declare.Visible = false
  form.groupbox_domain_info.Visible = false
end
function update_time(form)
  if not nx_is_valid(form) then
    return
  end
  form.life_time = form.life_time - 1
  if nx_int(form.life_time) < nx_int(-2) then
    local timer = nx_value(GAME_TIMER)
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "update_time", form)
    end
    custom_request_info(CLIENT_SUBMSG_REQUEST_COMPETE_INFO)
  elseif nx_int(form.life_time) < nx_int(0) then
  else
    local gui = nx_value("gui")
    form.lbl_compete_time.Text = nx_widestr(gui.TextManager:GetFormatText("ui_gc_timer", nx_int(form.life_time)))
  end
end
function show_or_hide_declare_result(form)
  if form.groupbox_result.Visible then
    form.groupbox_result.Visible = false
    form.Width = form.Width - form.groupbox_result.Width
  else
    form.Width = form.Width + form.groupbox_result.Width
    form.groupbox_result.Visible = true
  end
  return form.groupbox_result.Visible
end
function get_real_colour(colour_id, colour_stage, alpha)
  local ini = nx_execute("util_functions", "get_ini", "share\\Guild\\GuildDomain\\guild_domain_colour.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local section_index = ini:FindSectionIndex(nx_string(colour_id))
  if section_index < 0 then
    return ""
  end
  if colour_stage == nil then
    colour_stage = "NormalColor"
  end
  local colour = ini:ReadString(section_index, nx_string(colour_stage), "255,255,255,255")
  if alpha ~= nil then
    local rgb_index, _ = string.find(nx_string(colour), ",")
    colour = nx_string(alpha) .. string.sub(nx_string(colour), rgb_index, -1)
  end
  return colour
end
function refresh_area_colour(form)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    return
  end
  local area_list = form.groupbox_area:GetChildControlList()
  for i = 1, #area_list do
    local control = area_list[i]
    if nx_is_valid(control) then
      local area_id = string.sub(nx_string(control.Name), 10, -1)
      local NormalColor, FocusColor = is_area_unite(form, area_id)
      control.BlendColor = NormalColor
      control.FocusBlendColor = FocusColor
      control.PushBlendColor = NormalColor
      control.DisableBlendColor = NormalColor
      if control.BlendColor == "255,255,255,255" then
        control.NormalImage = "gui\\guild\\guild_jingbiao\\area_" .. nx_string(area_id) .. "_out.png"
        control.FocusImage = "gui\\guild\\guild_jingbiao\\area_" .. nx_string(area_id) .. "_on.png"
      else
        control.NormalImage = "gui\\guild\\guild_jingbiao\\area_" .. nx_string(area_id) .. "_white_out.png"
        control.FocusImage = "gui\\guild\\guild_jingbiao\\area_" .. nx_string(area_id) .. "_white_on.png"
      end
    end
  end
end
function is_area_unite(form, area_id)
  local unite_colour = 0
  local domain_pre = "btn_domain_" .. nx_string(area_id) .. "0"
  for i = 1, 4 do
    local domain_control_name = domain_pre .. nx_string(i)
    local domain_control = form.groupbox_domain:Find(domain_control_name)
    if nx_is_valid(domain_control) and nx_find_custom(domain_control, "colour_id") then
      if 0 == unite_colour and 0 < domain_control.colour_id then
        unite_colour = domain_control.colour_id
      elseif 0 ~= unite_colour and unite_colour == domain_control.colour_id then
        return get_real_colour(unite_colour), get_real_colour(unite_colour, "FocusColor")
      end
    end
  end
  return "255,255,255,255", "255,255,255,255"
end
function new_guild_war_update_declare_info(form, ...)
  if not (nx_is_valid(form) and nx_find_custom(form, "cur_domain_id")) or table.getn(arg) < 21 then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_new_map")
  if not nx_is_valid(form_guild_domain_map) then
    return
  end
  local owner_guild_name = arg[2]
  local guild_level = arg[3]
  local guild_member_num = arg[4]
  local occ_value = arg[5]
  local field_num = arg[6]
  local build_level = arg[7]
  local enemy_name = arg[9]
  local cool_down_time = arg[10]
  local guild_relation = arg[11]
  local guild_logo = arg[12]
  local domain_level = arg[13]
  local max_attack_members = arg[14]
  local max_defend_members = arg[15]
  local domain_type = arg[16]
  local tianwei = arg[17]
  local qifu = arg[18]
  local shouyi = arg[19]
  local domain_prosperous_value = arg[20]
  local guild_captain = arg[21]
  local jiuyinzhi_level = arg[22]
  local text_domain_name = nx_widestr(util_text("ui_dipan_" .. nx_string(form.cur_domain_id)))
  form.lbl_domain.Text = text_domain_name
  if nx_int(guild_relation) ~= nx_int(1) and nx_ws_length(nx_widestr(owner_guild_name)) > 0 then
    owner_guild_name = nx_widestr(owner_guild_name) .. nx_widestr("(") .. nx_widestr(util_text("ui_dm_relation_" .. nx_string(guild_relation))) .. nx_widestr(")")
  end
  local text_owner_guild_name = nx_widestr(owner_guild_name)
  form.lbl_guild_value.Text = text_owner_guild_name
  local text_guild_captain = nx_widestr(guild_captain)
  form.lbl_guild_captain_value.Text = text_guild_captain
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuildDomainExtraInfo.ini")
  if not nx_is_valid(ini) then
    return
  end
  local section_index = ini:FindSectionIndex(nx_string(form.cur_domain_id))
  if section_index < 0 then
    return
  end
  clear_all_weapon_imagegrid(form)
  local weapons = ini:ReadString(section_index, nx_string("WeaponAward"), "")
  local all_weapon = util_split_string(weapons, ",")
  local limit = 4
  if limit > table.getn(all_weapon) then
    limit = table.getn(all_weapon)
  end
  for i = 1, limit do
    local control_name = "imagegrid_weapon_" .. nx_string(i)
    local imagegrid = form.groupbox_domain_info:Find(control_name)
    if nx_is_valid(imagegrid) then
      local config_id = all_weapon[i]
      local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "Photo")
      imagegrid.DrawGridBack = "gui\\common\\imagegrid\\icon_item.png"
      imagegrid:AddItem(0, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
      imagegrid.config_id = config_id
      imagegrid.Visible = true
    end
  end
  if form.cur_domain_id == 1404 and limit < 4 then
    local control_name = "imagegrid_weapon_" .. nx_string(limit + 1)
    local imagegrid = form.groupbox_domain_info:Find(control_name)
    if nx_is_valid(imagegrid) then
      local config_id = "mount_guild_hg"
      local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "Photo")
      imagegrid:AddItem(0, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
      imagegrid.config_id = config_id
      imagegrid.DrawGridBack = "gui\\common\\imagegrid\\icon_item.png"
      imagegrid.Visible = true
    end
  end
  form.jiuyinzhi_level = nx_int(jiuyinzhi_level)
  form.rbtn_captain_award.Checked = true
  update_guild_captain_awards_info(form)
  form.lbl_36.Text = util_text("ui_newguild_w_23")
  local control_lbl_shengbing_value_name = "lbl_shengbing_value_" .. nx_string(form.cur_domain_id)
  local control_lbl_shengbing_value = form_guild_domain_map.groupbox_5:Find(control_lbl_shengbing_value_name)
  if nx_is_valid(control_lbl_shengbing_value) and nx_find_custom(control_lbl_shengbing_value, "ShengBingFlag") and 1 == control_lbl_shengbing_value.ShengBingFlag then
    form.lbl_36.Text = control_lbl_shengbing_value.Text
  end
  return
end
function clear_all_weapon_imagegrid(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, 4 do
    local control_name = "imagegrid_weapon_" .. nx_string(i)
    local imagegrid = form.groupbox_domain_info:Find(control_name)
    if nx_is_valid(imagegrid) then
      imagegrid:Clear()
      imagegrid.DrawGridBack = "gui\\guild\\newguildwar\\domain_icon_item.png"
      if nx_find_custom(imagegrid, "config_id") then
        imagegrid.config_id = nil
      end
    end
  end
  return
end
function clear_all_award_imagegrid(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, 10 do
    local control_name = "imagegrid_award_" .. nx_string(i)
    local imagegrid = form.groupbox_domain_info:Find(control_name)
    if nx_is_valid(imagegrid) then
      imagegrid:Clear()
      imagegrid.DrawGridBack = "gui\\guild\\newguildwar\\domain_icon_item.png"
      if nx_find_custom(imagegrid, "config_id") then
        imagegrid.config_id = nil
      end
      imagegrid.Visible = false
    end
  end
  return
end
function on_imagegrid_mousein_grid(grid, index)
  if not nx_find_custom(grid, "config_id") or grid.config_id == nil then
    return
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local item_type = ItemQuery:GetItemPropByConfigID(nx_string(grid.config_id), "ItemType")
  nx_execute("tips_game", "show_tips_common", grid.config_id, item_type, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), form)
  return
end
function on_imagegrid_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
  return
end
function update_guild_captain_awards_info(form)
  if not (nx_is_valid(form) and nx_find_custom(form, "cur_domain_id") and nx_find_custom(form, "jiuyinzhi_level")) or nx_int(form.jiuyinzhi_level) < nx_int(1) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuildDomainAwardDetail.ini")
  if not nx_is_valid(ini) then
    return
  end
  local section_index = ini:FindSectionIndex(nx_string(form.cur_domain_id))
  if section_index < 0 then
    return
  end
  clear_all_award_imagegrid(form)
  local key_captain_award_name = "CaptainAward_" .. nx_string(form.jiuyinzhi_level)
  local guild_captain_awards = ini:ReadString(section_index, nx_string(key_captain_award_name), "")
  local all_captain_awards = util_split_string(guild_captain_awards, ",")
  for i = table.getn(all_captain_awards), 1, -1 do
    if all_captain_awards[i] == nx_string("") then
      all_captain_awards[i] = nil
    else
      break
    end
  end
  local limit = 10
  if limit > table.getn(all_captain_awards) then
    limit = table.getn(all_captain_awards)
  end
  for i = 1, limit do
    local control_name = "imagegrid_award_" .. nx_string(i)
    local imagegrid = form.groupbox_domain_info:Find(control_name)
    if nx_is_valid(imagegrid) then
      local config_id = all_captain_awards[i]
      local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "Photo")
      imagegrid.DrawGridBack = "gui\\common\\imagegrid\\icon_item.png"
      imagegrid:AddItem(0, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
      imagegrid.config_id = config_id
      imagegrid.Visible = true
    end
  end
  return
end
function update_guild_normal_awards_info(form)
  if not (nx_is_valid(form) and nx_find_custom(form, "cur_domain_id") and nx_find_custom(form, "jiuyinzhi_level")) or nx_int(form.jiuyinzhi_level) < nx_int(1) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuildDomainAwardDetail.ini")
  if not nx_is_valid(ini) then
    return
  end
  local section_index = ini:FindSectionIndex(nx_string(form.cur_domain_id))
  if section_index < 0 then
    return
  end
  clear_all_award_imagegrid(form)
  local key_normal_award_name = "NormalAward_" .. nx_string(form.jiuyinzhi_level)
  local guild_normal_awards = ini:ReadString(section_index, nx_string(key_normal_award_name), "")
  local all_normal_awards = util_split_string(guild_normal_awards, ",")
  for i = table.getn(all_normal_awards), 1, -1 do
    if all_normal_awards[i] == nx_string("") then
      all_normal_awards[i] = nil
    else
      break
    end
  end
  local limit = 10
  if limit > table.getn(all_normal_awards) then
    limit = table.getn(all_normal_awards)
  end
  for i = 1, limit do
    local control_name = "imagegrid_award_" .. nx_string(i)
    local imagegrid = form.groupbox_domain_info:Find(control_name)
    if nx_is_valid(imagegrid) then
      local config_id = all_normal_awards[i]
      local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "Photo")
      imagegrid.DrawGridBack = "gui\\common\\imagegrid\\icon_item.png"
      imagegrid:AddItem(0, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
      imagegrid.config_id = config_id
      imagegrid.Visible = true
    end
  end
  return
end
function update_guild_lower_awards_info(form)
  if not (nx_is_valid(form) and nx_find_custom(form, "cur_domain_id") and nx_find_custom(form, "jiuyinzhi_level")) or nx_int(form.jiuyinzhi_level) < nx_int(1) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuildDomainAwardDetail.ini")
  if not nx_is_valid(ini) then
    return
  end
  local section_index = ini:FindSectionIndex(nx_string(form.cur_domain_id))
  if section_index < 0 then
    return
  end
  clear_all_award_imagegrid(form)
  local key_Lower_award_name = "LowerAward_" .. nx_string(form.jiuyinzhi_level)
  local guild_Lower_awards = ini:ReadString(section_index, nx_string(key_Lower_award_name), "")
  local all_Lower_awards = util_split_string(guild_Lower_awards, ",")
  for i = table.getn(all_Lower_awards), 1, -1 do
    if all_Lower_awards[i] == nx_string("") then
      all_Lower_awards[i] = nil
    else
      break
    end
  end
  local limit = 10
  if limit > table.getn(all_Lower_awards) then
    limit = table.getn(all_Lower_awards)
  end
  for i = 1, limit do
    local control_name = "imagegrid_award_" .. nx_string(i)
    local imagegrid = form.groupbox_domain_info:Find(control_name)
    if nx_is_valid(imagegrid) then
      local config_id = all_Lower_awards[i]
      local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "Photo")
      imagegrid.DrawGridBack = "gui\\common\\imagegrid\\icon_item.png"
      imagegrid:AddItem(0, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
      imagegrid.config_id = config_id
      imagegrid.Visible = true
    end
  end
  return
end
function on_rbtn_award_checked_changed(rbtn)
  if not nx_is_valid(rbtn) then
    return
  end
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(rbtn.DataSource) == nx_int(1) then
    update_guild_captain_awards_info(form)
  elseif nx_int(rbtn.DataSource) == nx_int(2) then
    update_guild_normal_awards_info(form)
  elseif nx_int(rbtn.DataSource) == nx_int(3) then
    update_guild_lower_awards_info(form)
  end
  return
end
function get_weapon_config_id(domain_id, weapon_index)
  if nx_int(domain_id) < nx_int(0) or nx_int(weapon_index) < nx_int(0) then
    return ""
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuildDomainExtraInfo.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local section_index = ini:FindSectionIndex(nx_string(domain_id))
  if section_index < 0 then
    return ""
  end
  local weapons = ini:ReadString(section_index, nx_string("WeaponAward"), "")
  local all_weapon_list = util_split_string(weapons, ",")
  if weapon_index + 1 > table.getn(all_weapon_list) then
    return ""
  else
    return all_weapon_list[weapon_index + 1]
  end
end
