require("util_gui")
local CHARACTER_LEVEL_RENZAI = 1
local CHARACTER_LEVEL_FENGYU = 2
local CHARACTER_LEVEL_REXUE = 3
function main_form_init(form)
  form.Fixed = true
  form.character_step = CHARACTER_LEVEL_RENZAI
  form.cur_player_step = CHARACTER_LEVEL_RENZAI
  return 1
end
function on_main_form_open(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("CharacterFlag", "int", form, nx_current(), "on_character_change")
    databinder:AddRolePropertyBind("CharacterValue", "int", form, nx_current(), "on_character_change")
    databinder:AddTableBind("rec_friend", form, nx_current(), "relation_rec_changed")
    databinder:AddTableBind("rec_buddy", form, nx_current(), "relation_rec_changed")
    databinder:AddTableBind("rec_enemy", form, nx_current(), "relation_rec_changed")
    databinder:AddTableBind("rec_blood", form, nx_current(), "relation_rec_changed")
  end
  return 1
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function show_step_photo(form)
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local character_flag = player:QueryProp("CharacterFlag")
  local character_value = player:QueryProp("CharacterValue")
  local step = get_character_step(character_flag, character_value)
  form.character_step = step
  form.cur_player_step = step
  local btn
  for i = 1, 3 do
    btn = form.groupbox_1:Find("btn_" .. i)
    if nx_is_valid(btn) then
      btn.NormalImage = "gui\\special\\sns_new\\sns_pk\\btn_part" .. i .. "_hui_out.png"
      btn.FocusImage = "gui\\special\\sns_new\\sns_pk\\btn_part" .. i .. "_hui_on.png"
      btn.PushImage = "gui\\special\\sns_new\\sns_pk\\btn_part" .. i .. "_hui_down.png"
    end
  end
  btn = form.groupbox_1:Find("btn_" .. nx_string(step))
  if nx_is_valid(btn) then
    btn.NormalImage = "gui\\special\\sns_new\\sns_pk\\btn_part" .. nx_string(step) .. "_out.png"
    btn.FocusImage = "gui\\special\\sns_new\\sns_pk\\btn_part" .. nx_string(step) .. "_on.png"
    btn.PushImage = "gui\\special\\sns_new\\sns_pk\\btn_part" .. nx_string(step) .. "_down.png"
  end
end
function show_character_info(form)
  local step = form.character_step
  form.lbl_cur_step.Visible = false
  if nx_number(step) == nx_number(form.cur_player_step) then
    form.lbl_cur_step.Visible = true
  end
  local lbl
  for i = 1, 3 do
    lbl = form.groupbox_1:Find("lbl_select_" .. i)
    if nx_is_valid(lbl) then
      lbl.Visible = false
    end
  end
  lbl = form.groupbox_1:Find("lbl_select_" .. nx_string(step))
  if nx_is_valid(lbl) then
    lbl.Visible = true
  end
  form.lbl_title.Text = util_text("ui_sns_pk_part_0" .. nx_string(step))
  form.lbl_title_ex.Text = util_text("ui_sns_pk_part0" .. nx_string(step))
  form.mltbox_rule.HtmlText = util_text("ui_sns_pk_rule0" .. nx_string(step))
  form.mltbox_event.HtmlText = util_text("ui_sns_pk_action0" .. nx_string(step))
  form.mltbox_act.HtmlText = util_text("ui_sns_pk_action_0" .. nx_string(step))
  form.lbl_condition.Text = util_text("ui_sns_pk_part_condition_0" .. nx_string(step))
  local friend_num = get_players_num("rec_friend", step)
  form.btn_friend.Text = util_text("ui_haoyou_01") .. nx_widestr("(") .. nx_widestr(friend_num) .. nx_widestr(")")
  form.btn_friend.Enabled = nx_int(friend_num) > nx_int(0)
  local buddy_num = get_players_num("rec_buddy", step)
  form.btn_buddy.Text = util_text("ui_zhiyou_01") .. nx_widestr("(") .. nx_widestr(buddy_num) .. nx_widestr(")")
  form.btn_buddy.Enabled = nx_int(buddy_num) > nx_int(0)
  local enemy_num = get_players_num("rec_enemy", step)
  form.btn_enemy.Text = util_text("ui_chouren_01") .. nx_widestr("(") .. nx_widestr(enemy_num) .. nx_widestr(")")
  form.btn_enemy.Enabled = nx_int(enemy_num) > nx_int(0)
  local blood_num = get_players_num("rec_blood", step)
  form.btn_blood.Text = util_text("ui_xuechou_01") .. nx_widestr("(") .. nx_widestr(blood_num) .. nx_widestr(")")
  form.btn_blood.Enabled = nx_int(blood_num) > nx_int(0)
end
function get_players_num(rec_name, step)
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return 0
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return 0
  end
  if not player:FindRecord(rec_name) then
    return 0
  end
  local REC_FRIEND_CHARACTER_TITLE = 13
  local REC_FRIEND_CHARACTER_VALUE = 14
  local num = 0
  local rows = player:GetRecordRows(rec_name)
  for i = 0, rows - 1 do
    local character_flag = player:QueryRecord(rec_name, i, REC_FRIEND_CHARACTER_TITLE)
    local character_value = player:QueryRecord(rec_name, i, REC_FRIEND_CHARACTER_VALUE)
    local player_step = get_character_step(character_flag, character_value)
    if nx_number(step) == nx_number(player_step) then
      num = num + 1
    end
  end
  return num
end
function get_character_step(character_flag, character_value)
  if nx_number(character_flag) == nx_number(0) then
    return CHARACTER_LEVEL_RENZAI
  end
  local character_step = CHARACTER_LEVEL_RENZAI
  local character_level = get_character_level(character_value)
  if nx_number(character_level) <= nx_number(2) then
    character_step = CHARACTER_LEVEL_RENZAI
  elseif nx_number(character_level) >= nx_number(3) and nx_number(character_level) <= nx_number(6) then
    character_step = CHARACTER_LEVEL_FENGYU
  elseif nx_number(character_level) >= nx_number(7) and nx_number(character_level) <= nx_number(10) then
    character_step = CHARACTER_LEVEL_REXUE
  end
  return character_step
end
function get_character_level(character_value)
  local character_level = 0
  if nx_number(character_value) <= nx_number(199) then
    character_level = 0
  elseif nx_number(character_value) >= nx_number(200) and nx_number(character_value) <= nx_number(449) then
    character_level = 1
  elseif nx_number(character_value) >= nx_number(450) and nx_number(character_value) <= nx_number(899) then
    character_level = 2
  elseif nx_number(character_value) >= nx_number(900) and nx_number(character_value) <= nx_number(1799) then
    character_level = 3
  elseif nx_number(character_value) >= nx_number(1800) and nx_number(character_value) <= nx_number(3599) then
    character_level = 4
  elseif nx_number(character_value) >= nx_number(3600) and nx_number(character_value) <= nx_number(7199) then
    character_level = 5
  elseif nx_number(character_value) >= nx_number(7200) and nx_number(character_value) <= nx_number(9999) then
    character_level = 6
  elseif nx_number(character_value) >= nx_number(10000) and nx_number(character_value) <= nx_number(19999) then
    character_level = 7
  elseif nx_number(character_value) >= nx_number(20000) and nx_number(character_value) <= nx_number(29999) then
    character_level = 8
  elseif nx_number(character_value) >= nx_number(30000) and nx_number(character_value) <= nx_number(39999) then
    character_level = 9
  elseif nx_number(character_value) >= nx_number(40000) and nx_number(character_value) <= nx_number(50000) then
    character_level = 10
  end
  return character_level
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  form.character_step = CHARACTER_LEVEL_RENZAI
  show_character_info(form)
end
function on_btn_2_click(btn)
  local form = btn.ParentForm
  form.character_step = CHARACTER_LEVEL_FENGYU
  show_character_info(form)
end
function on_btn_3_click(btn)
  local form = btn.ParentForm
  form.character_step = CHARACTER_LEVEL_REXUE
  show_character_info(form)
end
function on_character_change(form)
  if not nx_is_valid(form) then
    return
  end
  show_step_photo(form)
  show_character_info(form)
end
function relation_rec_changed(form, recordname, optype, row, clomn)
  if not nx_is_valid(form) then
    return
  end
  if nx_string(recordname) == nx_string("rec_friend") then
    local friend_num = get_players_num("rec_friend", form.character_step)
    form.btn_friend.Text = util_text("ui_haoyou_01") .. nx_widestr("(") .. nx_widestr(friend_num) .. nx_widestr(")")
    form.btn_friend.Enabled = nx_int(friend_num) > nx_int(0)
  elseif nx_string(recordname) == nx_string("rec_buddy") then
    local buddy_num = get_players_num("rec_buddy", form.character_step)
    form.btn_buddy.Text = util_text("ui_zhiyou_01") .. nx_widestr("(") .. nx_widestr(buddy_num) .. nx_widestr(")")
    form.btn_buddy.Enabled = nx_int(buddy_num) > nx_int(0)
  elseif nx_string(recordname) == nx_string("rec_enemy") then
    local enemy_num = get_players_num("rec_enemy", form.character_step)
    form.btn_enemy.Text = util_text("ui_chouren_01") .. nx_widestr("(") .. nx_widestr(enemy_num) .. nx_widestr(")")
    form.btn_enemy.Enabled = nx_int(enemy_num) > nx_int(0)
  elseif nx_string(recordname) == nx_string("rec_blood") then
    local blood_num = get_players_num("rec_blood", form.character_step)
    form.btn_blood.Text = util_text("ui_xuechou_01") .. nx_widestr("(") .. nx_widestr(blood_num) .. nx_widestr(")")
    form.btn_blood.Enabled = nx_int(blood_num) > nx_int(0)
  end
end
function on_btn_friend_click(btn)
  nx_execute("form_stage_main\\form_chat_system\\form_chat_panel", "extend_sub_group", "friend")
end
function on_btn_buddy_click(btn)
  nx_execute("form_stage_main\\form_chat_system\\form_chat_panel", "extend_sub_group", "buddy")
end
function on_btn_enemy_click(btn)
  nx_execute("form_stage_main\\form_chat_system\\form_chat_panel", "extend_sub_group", "enemy")
end
function on_btn_blood_click(btn)
  nx_execute("form_stage_main\\form_chat_system\\form_chat_panel", "extend_sub_group", "blood")
end
