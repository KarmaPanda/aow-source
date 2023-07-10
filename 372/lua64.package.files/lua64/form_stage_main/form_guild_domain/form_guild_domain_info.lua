require("util_gui")
local ST_FUNCTION_NEW_GUILDWAR = 219
local ONE_DAY = 86400
local ONE_HOUR = 3600
local ONE_MIN = 60
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_domain_info.Visible = true
  form.groupbox_new_guild_war_info.Visible = false
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form.IsInNewGuildWar = true
    form.groupbox_domain_info.Visible = false
    form.groupbox_new_guild_war_info.Visible = true
  else
    form.IsInNewGuildWar = false
  end
  return
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function updata_domain_info(...)
  if #arg < 11 then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local form
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_new_map")
  else
    form = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_map")
  end
  if not (nx_is_valid(form) and nx_find_custom(form, "base_info") and nx_is_valid(form.base_info) and nx_find_custom(form, "guild_relation")) or not nx_is_valid(form.guild_relation) then
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
  local gui = nx_value("gui")
  form.base_info.lbl_info_level.Text = nx_widestr(guild_level)
  form.base_info.lbl_info_mun.Text = nx_widestr(guild_member_num)
  if nx_find_custom(form, "IsInNewGuildWar") and form.IsInNewGuildWar then
    new_guild_war_update_domain_info(form, unpack(arg))
    return
  else
    form.base_info.lbl_info_size.Text = nx_widestr(util_text("ui_dipan_scale_" .. nx_string(field_num)))
    form.base_info.lbl_info_build_degree.Text = nx_widestr(build_level)
    form.base_info.lbl_info_own_degree.Text = nx_widestr(occ_value)
  end
  if nx_int(guild_relation) ~= nx_int(1) and nx_ws_length(nx_widestr(owner_guild_name)) > 0 then
    owner_guild_name = nx_widestr(owner_guild_name) .. nx_widestr("(") .. nx_widestr(util_text("ui_dm_relation_" .. nx_string(guild_relation))) .. nx_widestr(")")
  end
  form.base_info.lbl_info_owner_name.Text = nx_widestr(owner_guild_name)
  form.base_info.lbl_target_position.Text = nx_widestr(util_text("ui_dipanweizhi_" .. nx_string(form.cur_domain_id)))
  if nx_find_custom(form, "IsInNewGuildWar") and not form.IsInNewGuildWar then
    local logo_info = util_split_string(guild_logo, "#")
    if table.getn(logo_info) == 3 then
      if logo_info[1] == "" and logo_info[2] == "" and logo_info[3] == "0,255,255,255" then
        form.base_info.pic_logo.Image = "gui\\guild\\formback\\bg_logo.png"
      else
        form.base_info.pic_frame.Image = "gui\\guild\\frame\\" .. logo_info[1]
        form.base_info.pic_logo.Image = "gui\\guild\\logo\\" .. logo_info[2]
        form.base_info.groupbox_logo.BackColor = logo_info[3]
      end
    else
      form.base_info.pic_frame.Image = ""
      form.base_info.pic_logo.Image = "gui\\guild\\formback\\bg_logo.png"
      form.base_info.groupbox_logo.BackColor = "0,255,255,255"
    end
  end
end
function new_guild_war_update_domain_info(form_guild_domain_map, ...)
  if not (nx_is_valid(form_guild_domain_map) and nx_find_custom(form_guild_domain_map, "cur_domain_id")) or table.getn(arg) < 21 then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
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
  local remain_guild_punish_data = arg[23]
  local guild_war_punish_number = arg[24]
  local text_domain_name = nx_widestr(util_text("ui_dipan_" .. nx_string(form_guild_domain_map.cur_domain_id)))
  local text_domain_position = nx_widestr(util_text("ui_dipanweizhi_" .. nx_string(form_guild_domain_map.cur_domain_id)))
  local text_domain_level = nx_widestr(util_text("ui_dp_level_" .. nx_string(domain_level)))
  local text_domain_type = nx_widestr(util_text("ui_dp_type_" .. nx_string(domain_type)))
  local text_domain_fight_member = gui.TextManager:GetFormatText("ui_dp_fight_number", nx_int(max_attack_members), nx_int(max_defend_members))
  local text_domain_size = nx_widestr(util_text("ui_dipan_scale_" .. nx_string(field_num)))
  if nx_int(guild_relation) ~= nx_int(1) and nx_ws_length(nx_widestr(owner_guild_name)) > 0 then
    owner_guild_name = nx_widestr(owner_guild_name) .. nx_widestr("(") .. nx_widestr(util_text("ui_dm_relation_" .. nx_string(guild_relation))) .. nx_widestr(")")
  end
  local text_owner_guild_name = nx_widestr(owner_guild_name)
  local text_guild_captain = nx_widestr(guild_captain)
  local text_guild_level = nx_widestr(guild_level)
  local text_guild_population = nx_widestr(guild_member_num)
  if nx_int(remain_guild_punish_data) >= nx_int(ONE_DAY) then
    local punish_day = nx_int(remain_guild_punish_data / nx_int(ONE_DAY))
    local text_punish_time = gui.TextManager:GetFormatText("ui_guild_war_minyuan_tips2_day", nx_widestr(punish_day))
    form_guild_domain_map.base_info.lbl_guild_time.Text = nx_widestr(text_punish_time)
  elseif nx_int(remain_guild_punish_data) >= nx_int(ONE_HOUR) then
    local punish_hour = nx_int(remain_guild_punish_data / nx_int(ONE_HOUR))
    local text_punish_time = gui.TextManager:GetFormatText("ui_guild_war_minyuan_tips2_hour", nx_widestr(punish_hour))
    form_guild_domain_map.base_info.lbl_guild_time.Text = nx_widestr(text_punish_time)
  elseif nx_int(remain_guild_punish_data) >= nx_int(ONE_MIN) then
    local punish_min = nx_int(remain_guild_punish_data / nx_int(ONE_MIN))
    local text_punish_time = gui.TextManager:GetFormatText("ui_guild_war_minyuan_tips2_min", nx_widestr(punish_min))
    form_guild_domain_map.base_info.lbl_guild_time.Text = nx_widestr(text_punish_time)
  elseif nx_int(guild_war_punish_number) >= nx_int(2) then
    local text_punish_time = gui.TextManager:GetFormatText("ui_guild_war_minyuan_cishu_2")
    form_guild_domain_map.base_info.lbl_guild_time.Text = nx_widestr(text_punish_time)
  elseif nx_int(guild_war_punish_number) >= nx_int(1) then
    local text_punish_time = gui.TextManager:GetFormatText("ui_guild_war_minyuan_cishu_1")
    form_guild_domain_map.base_info.lbl_guild_time.Text = nx_widestr(text_punish_time)
  else
    local text_punish_time = gui.TextManager:GetFormatText("ui_guild_war_minyuan_cishu_0")
    form_guild_domain_map.base_info.lbl_guild_time.Text = nx_widestr(text_punish_time)
  end
  form_guild_domain_map.lbl_dipan_value.Text = text_domain_name
  form_guild_domain_map.lbl_position_value.Text = text_domain_position
  form_guild_domain_map.lbl_level_value.Text = text_domain_level
  form_guild_domain_map.lbl_type_value.Text = text_domain_type
  form_guild_domain_map.lbl_fight_member_value.Text = text_domain_fight_member
  form_guild_domain_map.lbl_dipan_size_value.Text = text_domain_size
  form_guild_domain_map.lbl_dipan_guild_value.Text = text_owner_guild_name
  form_guild_domain_map.lbl_guild_leader_value.Text = text_guild_captain
  form_guild_domain_map.lbl_guild_level_value.Text = text_guild_level
  form_guild_domain_map.lbl_guild_population_value.Text = text_guild_population
  local text_domain_tianwei_name, text_domain_tianwei_desc
  if nx_string(tianwei) == nx_string("") then
    text_domain_tianwei_name = nx_widestr(util_text("ui_guildTianWeiName_0"))
    text_domain_tianwei_desc = nx_widestr(util_text("ui_guildTianWeiDes_0"))
  else
    text_domain_tianwei_name = nx_widestr(util_text("ui_guildTianWeiName_" .. nx_string(tianwei)))
    text_domain_tianwei_desc = nx_widestr(util_text("ui_guildTianWeiDes_" .. nx_string(tianwei)))
  end
  local text_domain_qifu_name, text_domain_qifu_desc
  if nx_string(qifu) == nx_string("") then
    text_domain_qifu_name = nx_widestr(util_text("ui_guildQiFuName_0"))
    text_domain_qifu_desc = nx_widestr(util_text("ui_guildQiFuDes_0"))
  else
    text_domain_qifu_name = nx_widestr(util_text("ui_guildQiFuName_" .. nx_string(qifu)))
    text_domain_qifu_desc = nx_widestr(util_text("ui_guildQiFuDes_" .. nx_string(qifu)))
  end
  form_guild_domain_map.base_info.lbl_tianwei.Text = text_domain_tianwei_name
  form_guild_domain_map.base_info.mltbox_tianwei_desc:Clear()
  form_guild_domain_map.base_info.mltbox_tianwei_desc:AddHtmlText(text_domain_tianwei_desc, -1)
  form_guild_domain_map.base_info.lbl_qifu.Text = text_domain_qifu_name
  form_guild_domain_map.base_info.mltbox_qifu_desc:Clear()
  form_guild_domain_map.base_info.mltbox_qifu_desc:AddHtmlText(text_domain_qifu_desc, -1)
  local text_domain_stage = nx_widestr(util_text("ui_dm_stage_" .. nx_string(form_guild_domain_map.cur_domain_stage)))
  form_guild_domain_map.base_info.lbl_dipan_state_value.Font = "font_text"
  form_guild_domain_map.base_info.lbl_dipan_state_value.Text = text_domain_stage
  local guild_name = arg[2]
  if nx_int(form_guild_domain_map.cur_domain_stage) == nx_int(1) and nx_widestr(guild_name) ~= nx_widestr("") and nx_widestr(enemy_name) ~= nx_widestr("") then
    text_domain_stage = gui.TextManager:GetFormatText("ui_dm_stage_atk", nx_widestr(guild_name), nx_widestr(enemy_name))
    form_guild_domain_map.base_info.lbl_dipan_state_value.Font = "font_sns_event"
    form_guild_domain_map.base_info.lbl_dipan_state_value.Text = text_domain_stage
  end
  form_guild_domain_map.base_info.lbl_prosperous_value.Text = nx_widestr(domain_prosperous_value)
end
