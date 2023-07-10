require("util_gui")
require("share\\client_custom_define")
require("util_functions")
require("define\\sysinfo_define")
local CLIENT_CUSTOMMSG_GUILD_WAR = 8
local CLIENT_SUBMSG_CHOOSE_DOMAIN_LEVEL = 35
local ST_FUNCTION_GUILDWAR_HIGHT_LOW = 251
function main_form_init(form)
  form.Fixed = true
  form.domain_level = 0
  form.cur_domain_level = 0
end
function on_main_form_open(form)
  return
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
  nx_destroy(form)
end
function on_rbtn_choose_1_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not rbtn.Checked then
    return
  end
  form.domain_level = 1
end
function on_rbtn_choose_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not rbtn.Checked then
    return
  end
  form.domain_level = 2
end
function on_rbtn_choose_3_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not rbtn.Checked then
    return
  end
  form.domain_level = 3
end
function on_btn_choose_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "domain_level") then
    on_main_form_close(form)
    return
  end
  if nx_int(form.domain_level) == nx_int(0) then
    return
  end
  local gui = nx_value("gui")
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILDWAR_HIGHT_LOW) and nx_int(form.domain_level) > nx_int(form.cur_domain_level) then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if nx_is_valid(dialog) then
      local text = gui.TextManager:GetText("ui_guild_war_minyuan_tips3")
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
      dialog:ShowModal()
      local res = nx_wait_event(100000000, dialog, "confirm_return")
      if res ~= "ok" then
        return false
      end
    end
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_CHOOSE_DOMAIN_LEVEL), nx_int(form.domain_level))
  on_main_form_close(form)
end
function SetDomainLevel(domain_level)
  if type_index == nil then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guild_domain\\form_guild_domain_map", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.domain_level = domain_level
end
