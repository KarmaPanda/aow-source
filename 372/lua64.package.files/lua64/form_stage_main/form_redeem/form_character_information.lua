require("util_gui")
function main_form_init(form)
  form.Fixed = true
  return 1
end
function on_main_form_open(form)
  nx_execute("form_stage_main\\form_role_info\\form_rp_arm", "form_rp_arm_showrole", form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("Justice", "int", form, nx_current(), "on_character_change")
    databinder:AddRolePropertyBind("Evil", "int", form, nx_current(), "on_character_change")
    databinder:AddRolePropertyBind("FreeBase", "int", form, nx_current(), "on_character_change")
  end
  return 1
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function show_player_character_info(form)
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  nx_execute("form_stage_main\\form_relation\\form_relation_self", "show_self_shane_info", form)
  local character_flag = player:QueryProp("CharacterFlag")
  local character_value = player:QueryProp("CharacterValue")
  if nx_number(character_flag) == nx_number(0) then
    form.lbl_flag.BackImage = "gui\\special\\sns_new\\sns_pk\\level_chu.png"
  elseif nx_number(character_flag) == nx_number(1) then
    form.lbl_flag.BackImage = "gui\\special\\sns_new\\sns_pk\\level_xia.png"
  elseif nx_number(character_flag) == nx_number(2) then
    form.lbl_flag.BackImage = "gui\\special\\sns_new\\sns_pk\\level_e.png"
  elseif nx_number(character_flag) == nx_number(3) then
    form.lbl_flag.BackImage = "gui\\special\\sns_new\\sns_pk\\level_kuang.png"
  elseif nx_number(character_flag) == nx_number(4) then
    form.lbl_flag.BackImage = "gui\\special\\sns_new\\sns_pk\\level_xie.png"
  end
  local justice = player:QueryProp("Justice")
  local evil = player:QueryProp("Evil")
  local freebase = player:QueryProp("FreeBase")
  local debt = player:QueryProp("CharacterDebt")
  local hatred = player:QueryProp("CharacterHatred")
  form.lbl_2.Text = util_text("ui_sns_pk_mark_" .. nx_string(character_flag))
  form.lbl_charactervalue.Text = nx_widestr(character_value)
  form.lbl_justice.Text = nx_widestr(justice)
  form.lbl_evil.Text = nx_widestr(evil)
  form.lbl_freebase.Text = nx_widestr(freebase)
  form.lbl_debt.Text = nx_widestr(debt)
  form.lbl_hatred.Text = nx_widestr(hatred)
  local character_step = nx_execute("form_stage_main\\form_redeem\\form_character_zonglan", "get_character_step", character_flag, character_value)
  form.lbl_character_step.Text = util_text("ui_sns_pk_part_0" .. nx_string(character_step))
  local level = nx_execute("form_stage_main\\form_redeem\\form_character_zonglan", "get_character_level", character_value)
  form.lbl_level_select.Visible = true
  if nx_number(character_flag) == nx_number(0) then
    form.lbl_level.Text = util_text("ui_sns_churujianghu")
    form.lbl_level_select.Visible = false
  else
    form.lbl_level.Text = util_text("ui_character_" .. nx_string(character_flag) .. "_" .. nx_string(level))
  end
  form.lbl_sns_title.Text = form.lbl_level.Text
  form.lbl_level_select.Top = 401 - level * 24
  form.lbl_step_name.BackImage = "gui\\special\\sns_new\\sns_pk\\step_name_" .. nx_string(character_step) .. "_" .. nx_string(character_flag) .. ".png"
  local max_limit = get_max_limit_oneday(character_step)
  local justice_day, evil_day, freebase_day = get_character_add_today(player)
  form.lbl_justice_day.Text = nx_widestr(justice_day) .. nx_widestr("/") .. nx_widestr(max_limit)
  form.lbl_evil_day.Text = nx_widestr(evil_day) .. nx_widestr("/") .. nx_widestr(max_limit)
  form.lbl_freebase_day.Text = nx_widestr(freebase_day) .. nx_widestr("/") .. nx_widestr(max_limit)
end
function get_max_limit_oneday(character_step)
  local max_limit = 100
  if nx_number(character_step) == nx_number(1) then
    max_limit = 100
  elseif nx_number(character_step) == nx_number(2) then
    max_limit = 200
  elseif nx_number(character_step) == nx_number(3) then
    max_limit = 500
  end
  return max_limit
end
function get_character_add_today(player)
  local justice_day = 0
  local evil_day = 0
  local freebase_day = 0
  local today_date = 0
  local msg_delay = nx_value("MessageDelay")
  if nx_is_valid(msg_delay) then
    today_date = nx_int(msg_delay:GetServerDateTime())
  end
  if player:FindRecord("CharacterValueRec") then
    local justice_row = player:FindRecordRow("CharacterValueRec", 0, 0, 0)
    if today_date == nx_int(player:QueryRecord("CharacterValueRec", justice_row, 1)) then
      justice_day = player:QueryRecord("CharacterValueRec", justice_row, 2)
    end
    local evil_row = player:FindRecordRow("CharacterValueRec", 0, 1, 0)
    if today_date == nx_int(player:QueryRecord("CharacterValueRec", evil_row, 1)) then
      evil_day = player:QueryRecord("CharacterValueRec", evil_row, 2)
    end
    local freebase_row = player:FindRecordRow("CharacterValueRec", 0, 2, 0)
    if today_date == nx_int(player:QueryRecord("CharacterValueRec", freebase_row, 1)) then
      freebase_day = player:QueryRecord("CharacterValueRec", freebase_row, 2)
    end
  end
  return justice_day, evil_day, freebase_day
end
function on_character_change(form)
  if not nx_is_valid(form) then
    return
  end
  show_player_character_info(form)
end
function on_btn_pk_rule_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_redeem\\form_character_part_rule")
end
