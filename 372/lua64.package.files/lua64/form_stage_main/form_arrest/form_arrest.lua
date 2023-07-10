require("util_gui")
require("custom_sender")
require("form_stage_main\\form_arrest\\form_arrest_define")
function deal_arrest_message(...)
  local type = arg[1]
  if nx_int(type) == nx_int(arrest_tocustom_show_apply) then
    util_show_form("form_stage_main\\form_arrest\\form_arrest_apply", true)
  elseif nx_int(type) == nx_int(arrest_tocustom_show_pulish) then
    util_show_form("form_stage_main\\form_arrest\\form_publish_arrest", true)
  elseif nx_int(type) == nx_int(arrest_tocustom_show_accept) then
    nx_execute("form_stage_main\\form_arrest\\form_arrest_receive", "show_all_arrest_info", unpack(arg))
  elseif nx_int(type) == nx_int(arrest_tocustom_show_reward) then
    nx_execute("form_stage_main\\form_arrest\\form_arrest_add_money", "show_all_arrest_info", unpack(arg))
  elseif nx_int(type) == nx_int(arrest_tocustom_show_query) then
    nx_execute("form_stage_main\\form_arrest\\form_arrest_all", "show_all_arrest_info", unpack(arg))
  elseif nx_int(type) == nx_int(arrest_tocustom_show_detail) then
    local sub_type = arg[2]
    if nx_int(sub_type) == nx_int(arrest_detail_add_reward) then
      nx_execute("form_stage_main\\form_arrest\\form_arrest_add_money", "show_detailed_info", unpack(arg))
    elseif nx_int(sub_type) == nx_int(arrest_detail_accept) then
      nx_execute("form_stage_main\\form_arrest\\form_arrest_receive", "show_detailed_info", unpack(arg))
    elseif nx_int(sub_type) == nx_int(arrest_detail_publish_manger) then
      nx_execute("form_stage_main\\form_arrest\\form_arrest_manage", "show_detailed_info_publish", unpack(arg))
    elseif nx_int(sub_type) == nx_int(arrest_detail_accept_manger) then
      nx_execute("form_stage_main\\form_arrest\\form_arrest_manage", "show_detailed_info_receive", unpack(arg))
    elseif nx_int(sub_type) == nx_int(arrest_detail_wanted_manger) then
      nx_execute("form_stage_main\\form_arrest\\form_arrest_manage", "show_detailed_info_me", unpack(arg))
    elseif nx_int(sub_type) == nx_int(arrest_detail_all) then
      nx_execute("form_stage_main\\form_arrest\\form_arrest_all", "show_detailed_info", unpack(arg))
    end
  elseif nx_int(type) == nx_int(arrest_tocustom_show_visit) then
    visit_prisoner(arg[2])
  elseif nx_int(type) == nx_int(arrest_tocustom_show_pulish_confirm) then
    show_arrest_confirm(arrest_tocustom_show_pulish_confirm, arg[2])
  elseif nx_int(type) == nx_int(arrest_tocustom_show_reward_confirm) then
    show_arrest_confirm(arrest_tocustom_show_reward_confirm, arg[2])
  end
end
function accuse_wanted(name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), ARREST_CUSTOMMSG_ARREST_ACCUSE, nx_widestr(name))
  return
end
function visit_prisoner(prisoner_name)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_visit_prisoner")
  gui.TextManager:Format_AddParam(prisoner_name)
  local text = gui.TextManager:Format_GetText()
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), ARREST_CUSTOMMSG_ARREST_VISIT)
end
function show_arrest_confirm(flag, name)
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_arrest\\form_arrest_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  if flag == arrest_tocustom_show_pulish_confirm then
    local text = gui.TextManager:GetFormatText("ui_haibu_chouren_bg", nx_widestr(name))
    nx_execute("form_stage_main\\form_arrest\\form_arrest_confirm", "show_common_text", dialog, text, flag)
  elseif flag == arrest_tocustom_show_reward_confirm then
    local text = gui.TextManager:GetFormatText("ui_haibu_chouren_sj", nx_widestr(name))
    nx_execute("form_stage_main\\form_arrest\\form_arrest_confirm", "show_common_text", dialog, text, flag)
  end
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "arrest_confirm_return")
  if "ok_publish" == res then
    nx_execute("form_stage_main\\form_arrest\\form_publish_arrest", "on_add_publish", name)
  elseif "ok_add_money" == res then
    nx_execute("form_stage_main\\form_arrest\\form_arrest_add_money", "add_money", name)
  end
end
