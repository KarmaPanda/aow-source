require("form_stage_main\\switch\\url_define")
require("util_functions")
require("util_gui")
function open_charge_url()
  local AOWSteamClient = nx_value("AOWSteamClient")
  if nx_is_valid(AOWSteamClient) then
    util_show_form("haiwai_pt", true)
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local version_type = switch_manager:GetVersionType()
  if nx_int(version_type) == nx_int(3) then
    nx_execute("custom_sender", "custom_open_huaren_charge", URL_TYPE_ONLINE_IMPREST)
  else
    local operators = get_operators_name()
    local url_type = URL_TYPE_ONLINE_IMPREST
    if operators == OPERATORS_TYPE_WONIU then
      switch_manager:OpenUrl(URL_TYPE_ONLINE_IMPREST)
    elseif operators == OPERATORS_TYPE_SNDA then
      switch_manager:OpenUrl(URL_TYPE_SNDA_ONLINE_IMPREST)
    else
      nx_execute("custom_sender", "custom_open_huaren_charge", URL_TYPE_HUAREN_ONLINE_IMPREST)
    end
  end
end
