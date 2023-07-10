require("util_functions")
require("util_gui")
require("define\\tip_define")
require("util_static_data")
require("tips_data")
local FORM_TIPS = "form_stage_main\\form_guild_global_war\\form_guild_global_war_tips"
local STRIVE_STATE_IDLE = 0
local STRIVE_STATE_BUILD = 1
local STRIVE_STATE_OCCUPY = 2
local STRIVE_STATE_DEAD = 3
local STRIVE_STATE_PEACE = 4
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function close_form()
  local form = nx_value(FORM_TIPS)
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_form()
  local form = util_get_form(FORM_TIPS)
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", FORM_TIPS, true, false)
  end
  if not nx_is_valid(form) then
    return
  end
  form:Show()
end
function refresh_war_tips(flag_state, flag_guild, side_num, relive_info)
  local client = nx_value("game_client")
  local client_role = client:GetPlayer()
  if not nx_is_valid(client_role) then
    return
  end
  local guild_name = client_role:QueryProp("GuildName")
  if nx_widestr(guild_name) == nx_widestr("") then
    return
  end
  local form = util_show_form(nx_current(), true)
  if not nx_is_valid(form) then
    return
  end
  local tab_relive_info = util_split_string(nx_string(relive_info), ",")
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
  local tips = ""
  if nx_widestr(guild_name) == nx_widestr(flag_guild) then
    if nx_number(flag_state) == STRIVE_STATE_OCCUPY then
      tips = "ui_global_war_shp_081"
    elseif nx_number(flag_state) == STRIVE_STATE_BUILD then
      tips = "ui_global_war_shp_085"
    end
  elseif 0 < nx_number(side_num) then
    tips = "ui_global_war_shp_082"
  elseif nx_number(flag_state) == STRIVE_STATE_OCCUPY or nx_number(flag_state) == STRIVE_STATE_IDLE then
    tips = "ui_global_war_shp_083"
  elseif nx_number(flag_state) == STRIVE_STATE_DEAD then
    tips = "ui_global_war_shp_084"
  elseif nx_number(flag_state) == STRIVE_STATE_BUILD then
    tips = "ui_global_war_shp_086"
  end
  form.lbl_flag.Text = nx_widestr(util_text(nx_string(tips)))
  tips = ""
  if nx_widestr(guild_name) ~= nx_widestr(flag_guild) and nx_widestr(guild_name) ~= nx_widestr(relive_guild_1) and nx_widestr(guild_name) ~= nx_widestr(relive_guild_2) then
    tips = util_text(nx_string("ui_global_war_shp_087"))
  end
  form.lbl_camp.Text = nx_widestr(tips)
end
