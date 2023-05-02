require("util_gui")
require("utils")
require("util_functions")
require("custom_sender")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("form_stage_main\\form_offline\\offline_define")
require("define\\sysinfo_define")
local totalAddition = 0
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  update_form_pos(form)
  form.Visible = true
  dataBind(form)
  refresh_form(form)
  return 1
end
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_close2_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function update_form_pos(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function show_window()
  local game_client = nx_value("game_client")
  local game_role = game_client:GetPlayer()
  if not nx_is_valid(game_role) then
    return
  end
  local gui = nx_value("gui")
  local info = ""
  if game_role:FindProp("LogicState") then
    local role_logic_state = game_role:QueryProp("LogicState")
    if nx_int(role_logic_state) == nx_int(LS_OFFLINE_TOGATHER) then
      info = gui.TextManager:GetFormatText("40053")
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(info, 2)
      end
      local form_logic = nx_value("form_main_sysinfo")
      if nx_is_valid(form_logic) then
        form_logic:AddSystemInfo(info, SYSTYPE_SYSTEM, 0)
      end
      return
    end
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\form_offline_together_training", true, false)
  if init_form(form) then
    form:Show()
  end
end
function init_form(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local target = nx_value("game_select_obj")
  if not nx_is_valid(target) then
    return false
  end
  form.mltbox_together_training:Clear()
  local text = get_together_convert_ratio_text(form, client_player, target)
  if nx_widestr(text) == nx_widestr("") then
    return false
  end
  form.mltbox_together_training:AddHtmlText(nx_widestr(text), nx_int(-1))
  showTotalAddition(form)
  return true
end
function on_btn_proc_click(btn)
  local form = btn.ParentForm
  local target = nx_value("game_select_obj")
  if nx_is_valid(target) then
    local targetname = target:QueryProp("Name")
    local game_visual = nx_value("game_visual")
    if nx_is_valid(game_visual) then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_TRUSTEE_INTERACT), nx_widestr(targetname))
    end
  end
  form:Close()
end
function get_together_convert_ratio_text(form, client_player, target)
  local base_value = get_base_speed(client_player, target)
  if nx_number(base_value) <= 0 then
    return ""
  end
  local level_modify = get_level_modify(client_player, target)
  if nx_number(level_modify) <= 0 then
    return ""
  end
  local school_modify = get_school_modify(client_player, target)
  local guild_modify = get_guild_modify(client_player, target)
  local friend_modify = get_friend_modify(client_player, target)
  totalAddition = nx_number(base_value) + nx_number(level_modify) + nx_number(school_modify) + nx_number(guild_modify) + nx_number(friend_modify)
  local text = nx_widestr(util_text("ui_offline_add_base")) .. nx_widestr("<s>+") .. nx_widestr(base_value) .. nx_widestr("%") .. nx_widestr("<br>")
  text = text .. nx_widestr(util_text("ui_offline_add_level")) .. nx_widestr("<s>+") .. nx_widestr(level_modify) .. nx_widestr("%") .. nx_widestr("<br>")
  text = text .. nx_widestr(util_text("ui_offline_add_friend")) .. nx_widestr("<s>+") .. nx_widestr(friend_modify) .. nx_widestr("%") .. nx_widestr("<br>")
  text = text .. nx_widestr(util_text("ui_offline_add_school")) .. nx_widestr("<s>+") .. nx_widestr(school_modify) .. nx_widestr("%") .. nx_widestr("<br>")
  text = text .. nx_widestr(util_text("ui_offline_add_faction")) .. nx_widestr("<s>+") .. nx_widestr(guild_modify) .. nx_widestr("%") .. nx_widestr("<br>")
  text = text .. nx_widestr("<br>")
  return text
end
function showTotalAddition(form)
  form.lbl_totalAddition.Text = nx_widestr("+") .. nx_widestr(totalAddition) .. nx_widestr("%")
end
function dataBind(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("Faculty", "int", form, nx_current(), "prop_callback_refresh")
    databinder:AddRolePropertyBind("LiveGroove_1", "int", form, nx_current(), "prop_callback_refresh")
    databinder:AddRolePropertyBind("LiveGroove_2", "int", form, nx_current(), "prop_callback_refresh")
    databinder:AddRolePropertyBind("LiveGroove_3", "int", form, nx_current(), "prop_callback_refresh")
    databinder:AddRolePropertyBind("LiveGroove_4", "int", form, nx_current(), "prop_callback_refresh")
    databinder:AddRolePropertyBind("LiveGroove_5", "int", form, nx_current(), "prop_callback_refresh")
  end
end
function prop_callback_refresh(form, PropName, PropType, Value)
  if not nx_is_valid(form) then
    return 1
  end
  refresh_form(form)
  return 1
end
function refresh_form(form)
  if not nx_is_valid(form) then
    return 1
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local faculty = player:QueryProp("Faculty")
  local liveGroove = player:QueryProp("LiveGroove_1") + player:QueryProp("LiveGroove_2") + player:QueryProp("LiveGroove_3") + player:QueryProp("LiveGroove_4") + player:QueryProp("LiveGroove_5")
  form.pbar_faculty.Maximum = 2100000000
  form.pbar_faculty.Value = faculty
  form.pbar_liveGroove.Maximum = 999
  form.pbar_liveGroove.Value = liveGroove / 1000
end
function get_base_speed(client_player, target)
  if not target:FindProp("OffFacultyConvertBase") then
    return 0
  end
  return target:QueryProp("OffFacultyConvertBase")
end
function get_level_modify(client_player, target)
  local self_level, target_level
  if not client_player:FindProp("PowerLevel") or not target:FindProp("PowerLevel") then
    self_level = 0
    target_level = 0
  else
    self_level = client_player:QueryProp("PowerLevel")
    target_level = target:QueryProp("PowerLevel")
  end
  local sub_level = nx_int(math.abs(nx_number(self_level) - nx_number(target_level)) / 10)
  if nx_number(sub_level) == 0 then
    return 70
  elseif nx_number(sub_level) == 1 then
    return 60
  elseif nx_number(sub_level) == 2 then
    return 50
  elseif nx_number(sub_level) == 3 then
    return 40
  elseif nx_number(sub_level) == 4 then
    return 30
  elseif nx_number(sub_level) == 5 then
    return 20
  elseif nx_number(sub_level) == 6 then
    return 10
  end
  return 0
end
function get_school_modify(client_player, target)
  local self_school = ""
  if client_player:FindProp("School") then
    self_school = client_player:QueryProp("School")
  end
  local target_school = ""
  if target:FindProp("School") then
    target_school = target:QueryProp("School")
  end
  if nx_string(self_school) == "" and nx_string(target_school) == "" then
    return 0
  end
  if nx_string(self_school) == nx_string(target_school) then
    return 10
  end
  return 0
end
function get_guild_modify(client_player, target)
  local self_guild = ""
  if client_player:FindProp("GuildName") then
    self_guild = client_player:QueryProp("GuildName")
  end
  local target_guild = ""
  if target:FindProp("GuildName") then
    target_guild = target:QueryProp("GuildName")
  end
  if nx_string(self_guild) == "" and nx_string(target_guild) == "" then
    return 0
  end
  if nx_string(self_guild) == nx_string(target_guild) then
    return 10
  end
  return 0
end
function get_friend_modify(client_player, target)
  local target_name = ""
  if target:FindProp("Name") then
    target_name = target:QueryProp("Name")
  end
  if is_friend(target_name) then
    return 10
  end
  return 0
end
function is_friend(name)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not client_player:FindRecord("friend_rec") then
    return false
  end
  local rownum = client_player:FindRecordRow("friend_rec", 0, nx_widestr(name), 0)
  if 0 <= rownum then
    return true
  end
  return false
end
function get_end_text(type)
  if nx_number(type) == TRAINING_TOGETHER_END_FACULTY then
    return util_text("ui_off_full_faculty")
  elseif nx_number(type) == TRAINING_TOGETHER_END_ACT then
    return util_text("ui_off_no_ene")
  elseif nx_number(type) == TRAINING_TOGETHER_END_MONEY then
    return util_text("ui_off_no_money")
  elseif nx_number(type) == TRAINING_TOGETHER_END_OFFLINE then
    return util_text("ui_off_stop1")
  elseif nx_number(type) == TRAINING_TOGETHER_END_PLAYER then
    return util_text("ui_off_stop2")
  end
  return util_text("ui_off_unknown_reasons")
end
