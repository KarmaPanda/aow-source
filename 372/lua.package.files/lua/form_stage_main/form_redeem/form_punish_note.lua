require("util_gui")
require("util_functions")
local PunishKillRec = "PunishKillRec"
local PunishBeKillRec = "PunishBeKillRec"
function main_form_init(form)
  form.Fixed = true
  return
end
function on_main_form_open(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("CharacterDebt", "int", form, nx_current(), "on_CharacterDebt_change")
    databinder:AddRolePropertyBind("CharacterHatred", "int", form, nx_current(), "on_CharacterHatred_change")
  end
  show_punish_info(form)
end
function on_main_form_close(form)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:DelRolePropertyBind("CharacterDebt", form)
    data_binder:DelRolePropertyBind("CharacterHatred", form)
  end
  nx_destroy(form)
end
function show_punish_info(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  form.mltbox_kill:Clear()
  form.mltbox_bekill:Clear()
  if client_player:FindRecord(PunishKillRec) then
    local rows = client_player:GetRecordRows(PunishKillRec)
    for i = rows - 1, 0, -1 do
      local date = nx_string(client_player:QueryRecord(PunishKillRec, i, 0))
      local other_name = nx_widestr(client_player:QueryRecord(PunishKillRec, i, 1))
      local sence = nx_string(client_player:QueryRecord(PunishKillRec, i, 2))
      local drop_type = nx_int(client_player:QueryRecord(PunishKillRec, i, 3))
      local item_config = nx_string(client_player:QueryRecord(PunishKillRec, i, 4))
      local item_color = nx_int(client_player:QueryRecord(PunishKillRec, i, 5))
      local faculty = nx_int(client_player:QueryRecord(PunishKillRec, i, 6))
      local color_text = nx_widestr(util_text("ui_market_color_level_" .. nx_string(item_color)))
      if drop_type == nx_int(0) then
        local info = gui.TextManager:GetFormatText("ui_sns_pk_diary_eqp_01", date, sence, other_name, item_config, color_text)
        form.mltbox_kill:AddHtmlText(nx_widestr(info), nx_int(-1))
      elseif drop_type == nx_int(1) then
        local info = gui.TextManager:GetFormatText("ui_sns_pk_diary_fac_01", date, sence, other_name, faculty)
        form.mltbox_kill:AddHtmlText(nx_widestr(info), nx_int(-1))
      end
    end
  end
  if client_player:FindRecord(PunishBeKillRec) then
    local rows = client_player:GetRecordRows(PunishBeKillRec)
    for i = rows - 1, 0, -1 do
      local date = nx_string(client_player:QueryRecord(PunishBeKillRec, i, 0))
      local other_name = nx_widestr(client_player:QueryRecord(PunishBeKillRec, i, 1))
      local sence = nx_string(client_player:QueryRecord(PunishBeKillRec, i, 2))
      local drop_type = nx_int(client_player:QueryRecord(PunishBeKillRec, i, 3))
      local item_config = nx_string(client_player:QueryRecord(PunishBeKillRec, i, 4))
      local item_color = nx_int(client_player:QueryRecord(PunishBeKillRec, i, 5))
      local faculty = nx_int(client_player:QueryRecord(PunishBeKillRec, i, 6))
      local color_text = nx_widestr(util_text("ui_market_color_level_" .. nx_string(item_color)))
      if drop_type == nx_int(0) then
        local info = gui.TextManager:GetFormatText("ui_sns_pk_diary_eqp_02", date, sence, other_name, item_config, color_text)
        form.mltbox_bekill:AddHtmlText(nx_widestr(info), nx_int(-1))
      elseif drop_type == nx_int(1) then
        local info = gui.TextManager:GetFormatText("ui_sns_pk_diary_fac_02", date, sence, other_name, faculty)
        form.mltbox_bekill:AddHtmlText(nx_widestr(info), nx_int(-1))
      end
    end
  end
end
function on_CharacterDebt_change(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local cur_debt = client_player:QueryProp("CharacterDebt")
  form.lbl_debt.Text = nx_widestr(cur_debt)
end
function on_CharacterHatred_change(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local cur_hatred = client_player:QueryProp("CharacterHatred")
  form.lbl_hatred.Text = nx_widestr(cur_hatred)
end
