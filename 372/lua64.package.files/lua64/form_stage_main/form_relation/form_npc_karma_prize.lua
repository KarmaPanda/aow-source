require("util_gui")
require("util_functions")
require("custom_sender")
local KARMA_PRIZE_TYPE_ADD = 10
local KARMA_PRIZE_TYPE_DEC = -10
local KARMA_PRIZE_TYPE_MONEY_BIND = 1
local KARMA_PRIZE_TYPE_MONEY = 2
local KARMA_PRIZE_TYPE_ITEM = 3
local KARMA_PRIZE_TYPE_BUFFER = 4
function main_form_init(form)
  form.Fixed = true
  return 1
end
function on_main_form_open(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("rec_npc_relation", form, "form_stage_main\\form_relation\\form_npc_karma_prize", "on_npc_relation_change")
    databinder:AddTableBind("rec_npc_relation_delay", form, "form_stage_main\\form_relation\\form_npc_karma_prize", "on_npc_relation_change")
  end
  local timer = nx_value("timer_game")
  timer:Register(10000, -1, nx_current(), "update_time", form, -1, -1)
  form.Visible = true
  return 1
end
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
  local prize_confirm = nx_value("form_common\\form_karma_prize_confirm")
  if nx_is_valid(prize_confirm) then
    prize_confirm:Close()
  end
  return 1
end
function hide_form()
  local form = nx_value("form_stage_main\\form_relation\\form_npc_karma_prize")
  if nx_is_valid(form) then
    form.Visible = false
    nx_destroy(form)
  end
  local form_ex = nx_value("form_stage_main\\form_relation\\form_npc_karma_prize_ex")
  if nx_is_valid(form_ex) then
    form_ex.Visible = false
    nx_destroy(form_ex)
  end
  local prize_confirm = nx_value("form_common\\form_karma_prize_confirm")
  if nx_is_valid(prize_confirm) then
    prize_confirm:Close()
  end
  return 1
end
function show_form(form_base, configid)
  if nx_string(configid) == "" then
    return
  end
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_npc_karma_prize_ex", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.target_npc_id = nx_string(configid)
  form.btn_karma_add.Enabled = false
  form.btn_karma_dec.Enabled = false
  form.btn_prize_gold.Enabled = false
  form.btn_prize_item.Enabled = false
  form.btn_prize_buffer.Enabled = false
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local condition_manager = nx_value("ConditionManager")
  if nx_is_valid(condition_manager) then
    if condition_manager:CanSatisfyCondition(player, player, nx_int(26536)) then
      form.btn_present.Enabled = true
    else
      form.btn_present.Enabled = false
    end
  end
  form.btn_karma_add.HintText = nx_widestr("")
  form.btn_karma_dec.HintText = nx_widestr("")
  form.btn_prize_gold.HintText = nx_widestr("")
  form.btn_prize_item.HintText = nx_widestr("")
  form.btn_prize_buffer.HintText = nx_widestr("")
  form.lbl_add_timeout.Text = nx_widestr("")
  form.lbl_dec_timeout.Text = nx_widestr("")
  form.lbl_gold_timeout.Text = nx_widestr("")
  form.lbl_item_timeout.Text = nx_widestr("")
  form.lbl_buffer_timeout.Text = nx_widestr("")
  form.lbl_add_timeout.prize_timeout = nx_double(0)
  form.lbl_dec_timeout.prize_timeout = nx_double(0)
  form.lbl_gold_timeout.prize_timeout = nx_double(0)
  form.lbl_item_timeout.prize_timeout = nx_double(0)
  form.lbl_buffer_timeout.prize_timeout = nx_double(0)
  local table_out = karmamgr:GetNpcPrize(nx_string(configid))
  local num = table.getn(table_out) / 3
  local add_value = 0
  local dec_value = 0
  local gold_value = 0
  local str_add_uid = ""
  local str_dec_uid = ""
  local str_gold_uid = ""
  local timeout_add = nx_double(0)
  local timeout_dec = nx_double(0)
  local timeout_gold = nx_double(0)
  for i = 1, num * 3, 3 do
    local value = table_out[i]
    local timeout = table_out[i + 1]
    local type = table_out[i + 2]
    if nx_string(type) == "Gold" then
      gold_value = nx_int64(value)
      str_gold_uid = nx_string(configid)
      timeout_gold = nx_double(timeout)
    else
      if nx_int64(value) > nx_int64(0) then
        add_value = nx_int64(add_value) + nx_int64(value)
        str_add_uid = nx_string(str_add_uid) .. nx_string(type) .. ","
        if nx_double(timeout) > nx_double(timeout_add) then
          timeout_add = nx_double(timeout)
        end
      end
      if nx_int64(value) < nx_int64(0) then
        dec_value = nx_int64(dec_value) + nx_int64(value)
        str_dec_uid = nx_string(str_dec_uid) .. nx_string(type) .. ","
        if nx_double(timeout) > nx_double(timeout_dec) then
          timeout_dec = nx_double(timeout)
        end
      end
    end
  end
  if nx_double(timeout_add) > nx_double(0) then
    form.lbl_add_timeout.prize_timeout = nx_double(timeout_add)
    form.btn_karma_add.Enabled = true
    form.btn_karma_add.HintText = nx_widestr(util_text("desc_sns_delaykarma1"))
    form.btn_karma_add.prize_npc_id = nx_string(configid)
    form.btn_karma_add.prize_value = nx_int64(add_value)
    form.btn_karma_add.prize_uid = nx_string(str_add_uid)
  end
  if nx_double(timeout_dec) > nx_double(0) then
    form.lbl_dec_timeout.prize_timeout = nx_double(timeout_dec)
    form.btn_karma_dec.Enabled = true
    form.btn_karma_dec.HintText = nx_widestr(util_text("desc_sns_delaykarma2"))
    form.btn_karma_dec.prize_npc_id = nx_string(configid)
    form.btn_karma_dec.prize_value = nx_int64(dec_value)
    form.btn_karma_dec.prize_uid = nx_string(str_dec_uid)
  end
  if nx_double(timeout_gold) > nx_double(0) then
    local table_out_prize = karmamgr:GetKarmaPrizeInfo(nx_int(gold_value))
    local num = table.getn(table_out_prize)
    if nx_number(num) == nx_number(4) then
      local type = nx_int(table_out_prize[1])
      local id = nx_string(table_out_prize[2])
      local amount = nx_int(table_out_prize[3])
      local text = nx_string(table_out_prize[4])
      if nx_number(type) == nx_number(1) or nx_number(type) == nx_number(2) then
        form.lbl_gold_timeout.prize_timeout = nx_double(timeout_gold)
        form.btn_prize_gold.Enabled = true
        form.btn_prize_gold.HintText = nx_widestr(util_text("desc_sns_delaymoney"))
        form.btn_prize_gold.prize_npc_id = nx_string(str_gold_uid)
        form.btn_prize_gold.prize_value = nx_int64(gold_value)
        form.btn_prize_gold.prize_type = type
        form.btn_prize_gold.prize_id = id
        form.btn_prize_gold.prize_amount = amount
        form.btn_prize_gold.prize_text = text
      elseif nx_number(type) == nx_number(3) then
        form.lbl_item_timeout.prize_timeout = nx_double(timeout_gold)
        form.btn_prize_item.Enabled = true
        form.btn_prize_item.HintText = nx_widestr(util_text("desc_sns_delayitem"))
        form.btn_prize_item.prize_npc_id = nx_string(str_gold_uid)
        form.btn_prize_item.prize_value = nx_int64(gold_value)
        form.btn_prize_item.prize_type = type
        form.btn_prize_item.prize_id = id
        form.btn_prize_item.prize_amount = amount
        form.btn_prize_item.prize_text = text
      elseif nx_number(type) == nx_number(4) then
        form.lbl_buffer_timeout.prize_timeout = nx_double(timeout_gold)
        form.btn_prize_buffer.Enabled = true
        form.btn_prize_buffer.HintText = nx_widestr(util_text("desc_sns_delaybuff"))
        form.btn_prize_buffer.prize_npc_id = nx_string(str_gold_uid)
        form.btn_prize_buffer.prize_value = nx_int64(gold_value)
        form.btn_prize_buffer.prize_type = type
        form.btn_prize_buffer.prize_id = id
        form.btn_prize_buffer.prize_amount = amount
        form.btn_prize_buffer.prize_text = text
      end
    end
  end
  update_time(form)
  form_base:Add(form)
  change_form_size(form)
end
function on_btn_karma_add_click(btn)
  local gui = nx_value("gui")
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  gui.TextManager:Format_SetIDName("ui_sns_npcvalue001")
  gui.TextManager:Format_AddParam(nx_string(btn.prize_npc_id))
  gui.TextManager:Format_AddParam(nx_int64(btn.prize_value * karmamgr:GetGoodCoefficient()))
  gui.TextManager:Format_AddParam(nx_int64(500))
  local text = gui.TextManager:Format_GetText()
  local time_out_text = btn.ParentForm.lbl_add_timeout.Text
  local form_prize = nx_execute("util_gui", "util_get_form", "form_common\\form_karma_prize_confirm", true, false)
  local table_uid_list = util_split_string(nx_string(btn.prize_uid), ",")
  local num = table.getn(table_uid_list)
  local real_num = 0
  for i = 1, num do
    local uid_len = nx_string(string.len(table_uid_list[i]))
    if nx_number(uid_len) == nx_number(32) then
      real_num = real_num + 1
    end
  end
  nx_execute("form_common\\form_karma_prize_confirm", "show_karma_prize_confirm", form_prize, KARMA_PRIZE_TYPE_ADD, time_out_text, text, real_num)
  form_prize:ShowModal()
  local res = nx_wait_event(100000000, form_prize, "karma_prize_confirm_return")
  if res ~= "ok" then
    return
  end
  if nx_number(num) <= nx_number(0) then
    return
  end
  for i = 1, num do
    local uid_len = nx_string(string.len(table_uid_list[i]))
    if nx_number(uid_len) == nx_number(32) then
      nx_execute("custom_sender", "apply_add_npc_relation", nx_int(3), nx_string(table_uid_list[i]), nx_int(0), nx_string(btn.prize_npc_id))
    end
  end
end
function on_btn_karma_dec_click(btn)
  local gui = nx_value("gui")
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  gui.TextManager:Format_SetIDName("ui_sns_npcvalue002")
  gui.TextManager:Format_AddParam(nx_string(btn.prize_npc_id))
  gui.TextManager:Format_AddParam(nx_int64(math.abs(btn.prize_value) * karmamgr:GetBadCoefficient()))
  gui.TextManager:Format_AddParam(nx_int64(500))
  local text = gui.TextManager:Format_GetText()
  local time_out_text = btn.ParentForm.lbl_dec_timeout.Text
  local form_prize = nx_execute("util_gui", "util_get_form", "form_common\\form_karma_prize_confirm", true, false)
  local table_uid_list = util_split_string(nx_string(btn.prize_uid), ",")
  local num = table.getn(table_uid_list)
  local real_num = 0
  for i = 1, num do
    local uid_len = nx_string(string.len(table_uid_list[i]))
    if nx_number(uid_len) == nx_number(32) then
      real_num = real_num + 1
    end
  end
  nx_execute("form_common\\form_karma_prize_confirm", "show_karma_prize_confirm", form_prize, KARMA_PRIZE_TYPE_DEC, time_out_text, text, real_num)
  form_prize:ShowModal()
  local res = nx_wait_event(100000000, form_prize, "karma_prize_confirm_return")
  if res ~= "ok" then
    return
  end
  if nx_number(num) <= nx_number(0) then
    return
  end
  for i = 1, num do
    local uid_len = nx_string(string.len(table_uid_list[i]))
    if nx_number(uid_len) == nx_number(32) then
      nx_execute("custom_sender", "apply_add_npc_relation", nx_int(4), nx_string(table_uid_list[i]), nx_int(0), nx_string(btn.prize_npc_id))
    end
  end
end
function on_btn_prize_gold_click(btn)
  if not (nx_find_custom(btn, "prize_text") and nx_find_custom(btn, "prize_id") and nx_find_custom(btn, "prize_amount")) or not nx_find_custom(btn, "prize_type") then
    return
  end
  local prize_type = btn.prize_type
  if nx_number(prize_type) < nx_number(KARMA_PRIZE_TYPE_MONEY_BIND) or nx_number(prize_type) > nx_number(KARMA_PRIZE_TYPE_BUFFER) then
    return
  end
  local form_text = btn.prize_text
  local text_para_2 = false
  local text_para_3 = false
  local bHasText = false
  if nx_string(form_text) == "" then
    bHasText = true
  end
  local time_out_text = btn.ParentForm.lbl_gold_timeout.Text
  if nx_number(prize_type) == nx_number(KARMA_PRIZE_TYPE_MONEY_BIND) then
    if bHasText then
      form_text = "ui_geinisuiyin"
    end
    text_para_3 = true
  elseif nx_number(prize_type) == nx_number(KARMA_PRIZE_TYPE_MONEY) then
    if bHasText then
      form_text = "ui_geiniguanyin"
    end
    text_para_3 = true
  elseif nx_number(prize_type) == nx_number(KARMA_PRIZE_TYPE_ITEM) then
    if bHasText then
      form_text = "ui_geinidaojv"
    end
    text_para_2 = true
    text_para_3 = true
    time_out_text = btn.ParentForm.lbl_item_timeout.Text
  elseif nx_number(prize_type) == nx_number(KARMA_PRIZE_TYPE_BUFFER) then
    if bHasText then
      form_text = "ui_geinizengyi"
    end
    text_para_2 = true
    time_out_text = btn.ParentForm.lbl_buffer_timeout.Text
  end
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName(nx_string(form_text))
  gui.TextManager:Format_AddParam(nx_string(btn.prize_npc_id))
  if text_para_2 then
    gui.TextManager:Format_AddParam(nx_string(btn.prize_id))
  end
  if text_para_3 then
    gui.TextManager:Format_AddParam(nx_int64(btn.prize_amount))
  end
  local text = gui.TextManager:Format_GetText()
  local form_prize = nx_execute("util_gui", "util_get_form", "form_common\\form_karma_prize_confirm", true, false)
  nx_execute("form_common\\form_karma_prize_confirm", "show_karma_prize_confirm", form_prize, prize_type, time_out_text, text, btn.prize_id, btn.prize_amount)
  form_prize:ShowModal()
  local res = nx_wait_event(100000000, form_prize, "karma_prize_confirm_return")
  if res ~= "ok" then
    return
  end
  if nx_find_custom(btn, "prize_npc_id") and nx_string(btn.prize_npc_id) ~= "" then
    nx_execute("custom_sender", "apply_add_npc_relation", nx_int(5), nx_string(btn.prize_npc_id), nx_int(0))
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_npc_relation_change(self, recordname, optype, row, clomn)
  local timer = nx_value("timer_game")
  timer:Register(500, 1, nx_current(), "update_prize", self, -1, -1)
  if optype == "add" then
  end
  if optype == "update" then
  end
  if optype == "del" then
  end
  if optype == "clear" then
  end
  return 1
end
function update_prize()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_npc_karma_prize_ex", true, false)
  if not nx_is_valid(form) then
    return
  end
  if not form.Visible then
    return
  end
  if not nx_find_custom(form, "target_npc_id") then
    return
  end
  local npc_id = form.target_npc_id
  if nx_string(npc_id) == "" then
    return
  end
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  local table_out = karmamgr:GetNpcPrize(nx_string(npc_id))
  local num = table.getn(table_out) / 3
  refersh_npc_news(npc_id, num)
  if nx_number(num) < nx_number(1) then
    form.btn_karma_add.Enabled = false
    form.btn_karma_dec.Enabled = false
    form.btn_prize_gold.Enabled = false
    form.btn_prize_item.Enabled = false
    form.btn_prize_buffer.Enabled = false
    form.lbl_add_timeout.Text = nx_widestr("")
    form.lbl_dec_timeout.Text = nx_widestr("")
    form.lbl_gold_timeout.Text = nx_widestr("")
    form.lbl_item_timeout.Text = nx_widestr("")
    form.lbl_buffer_timeout.Text = nx_widestr("")
    return
  end
  local add_value = 0
  local dec_value = 0
  local gold_value = 0
  local str_add_uid = ""
  local str_dec_uid = ""
  local str_gold_uid = ""
  local timeout_add = nx_double(0)
  local timeout_dec = nx_double(0)
  local timeout_gold = nx_double(0)
  for i = 1, num * 3, 3 do
    local value = table_out[i]
    local timeout = table_out[i + 1]
    local type = table_out[i + 2]
    if nx_string(type) == "Gold" then
      gold_value = nx_int64(value)
      str_gold_uid = nx_string(npc_id)
      timeout_gold = nx_double(timeout)
    else
      if nx_int64(value) > nx_int64(0) then
        add_value = nx_int64(add_value) + nx_int64(value)
        str_add_uid = nx_string(str_add_uid) .. nx_string(type) .. ","
        if nx_double(timeout) > nx_double(timeout_add) then
          timeout_add = nx_double(timeout)
        end
      end
      if nx_int64(value) < nx_int64(0) then
        dec_value = nx_int64(dec_value) + nx_int64(value)
        str_dec_uid = nx_string(str_dec_uid) .. nx_string(type) .. ","
        if nx_double(timeout) > nx_double(timeout_dec) then
          timeout_dec = nx_double(timeout)
        end
      end
    end
  end
  if nx_double(timeout_add) > nx_double(0) then
    form.lbl_add_timeout.prize_timeout = nx_double(timeout_add)
    form.btn_karma_add.Enabled = true
    form.btn_karma_add.HintText = nx_widestr(util_text("desc_sns_delaykarma1"))
    form.btn_karma_add.prize_npc_id = nx_string(npc_id)
    form.btn_karma_add.prize_value = nx_int64(add_value)
    form.btn_karma_add.prize_uid = nx_string(str_add_uid)
  else
    form.lbl_add_timeout.prize_timeout = nx_double(0)
    form.btn_karma_add.Enabled = false
    form.lbl_add_timeout.Text = nx_widestr("")
  end
  if nx_double(timeout_dec) > nx_double(0) then
    form.lbl_dec_timeout.prize_timeout = nx_double(timeout_dec)
    form.btn_karma_dec.Enabled = true
    form.btn_karma_dec.HintText = nx_widestr(util_text("desc_sns_delaykarma2"))
    form.btn_karma_dec.prize_npc_id = nx_string(npc_id)
    form.btn_karma_dec.prize_value = nx_int64(dec_value)
    form.btn_karma_dec.prize_uid = nx_string(str_dec_uid)
  else
    form.lbl_dec_timeout.prize_timeout = nx_double(0)
    form.btn_karma_dec.Enabled = false
    form.lbl_dec_timeout.Text = nx_widestr("")
  end
  if nx_double(timeout_gold) > nx_double(0) then
    local table_out_prize = karmamgr:GetKarmaPrizeInfo(nx_int(gold_value))
    local num = table.getn(table_out_prize)
    if nx_number(num) == nx_number(4) then
      local type = nx_int(table_out_prize[1])
      local id = nx_string(table_out_prize[2])
      local amount = nx_int(table_out_prize[3])
      local text = nx_string(table_out_prize[4])
      if nx_number(type) == nx_number(1) or nx_number(type) == nx_number(2) then
        form.lbl_gold_timeout.prize_timeout = nx_double(timeout_gold)
        form.btn_prize_gold.Enabled = true
        form.btn_prize_gold.HintText = nx_widestr(util_text("desc_sns_delaymoney"))
        form.btn_prize_gold.prize_npc_id = nx_string(str_gold_uid)
        form.btn_prize_gold.prize_value = nx_int64(gold_value)
        form.btn_prize_gold.prize_type = type
        form.btn_prize_gold.prize_id = id
        form.btn_prize_gold.prize_amount = amount
        form.btn_prize_gold.prize_text = text
      elseif nx_number(type) == nx_number(3) then
        form.lbl_item_timeout.prize_timeout = nx_double(timeout_gold)
        form.btn_prize_item.Enabled = true
        form.btn_prize_item.HintText = nx_widestr(util_text("desc_sns_delayitem"))
        form.btn_prize_item.prize_npc_id = nx_string(str_gold_uid)
        form.btn_prize_item.prize_value = nx_int64(gold_value)
        form.btn_prize_item.prize_type = type
        form.btn_prize_item.prize_id = id
        form.btn_prize_item.prize_amount = amount
        form.btn_prize_item.prize_text = text
      elseif nx_number(type) == nx_number(4) then
        form.lbl_buffer_timeout.prize_timeout = nx_double(timeout_gold)
        form.btn_prize_buffer.Enabled = true
        form.btn_prize_buffer.HintText = nx_widestr(util_text("desc_sns_delaybuff"))
        form.lbl_buffer_timeout.Text = nx_widestr(format_time(timeout_gold))
        form.btn_prize_buffer.prize_npc_id = nx_string(str_gold_uid)
        form.btn_prize_buffer.prize_value = nx_int64(gold_value)
        form.btn_prize_buffer.prize_type = type
        form.btn_prize_buffer.prize_id = id
        form.btn_prize_buffer.prize_amount = amount
        form.btn_prize_buffer.prize_text = text
      end
    end
  else
    form.lbl_gold_timeout.prize_timeout = nx_double(0)
    form.btn_prize_gold.Enabled = false
    form.lbl_gold_timeout.Text = nx_widestr("")
    form.lbl_item_timeout.prize_timeout = nx_double(0)
    form.btn_prize_item.Enabled = false
    form.lbl_item_timeout.Text = nx_widestr("")
    form.lbl_buffer_timeout.prize_timeout = nx_double(0)
    form.btn_prize_buffer.Enabled = false
    form.lbl_buffer_timeout.Text = nx_widestr("")
    nx_execute("custom_sender", "apply_add_npc_relation", nx_int(8), nx_string(npc_id), nx_int(0))
  end
  update_time(form)
end
function update_time(form)
  local npc_id = form.target_npc_id
  if nx_string(npc_id) == "" then
    return
  end
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  local table_out = karmamgr:GetNpcPrize(nx_string(npc_id))
  local num = table.getn(table_out) / 3
  if nx_number(num) < nx_number(1) then
    return
  end
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  if nx_find_custom(form.lbl_add_timeout, "prize_timeout") and nx_double(form.lbl_add_timeout.prize_timeout) > nx_double(cur_date_time) then
    form.lbl_add_timeout.Text = nx_widestr(format_time(nx_double(form.lbl_add_timeout.prize_timeout) - nx_double(cur_date_time)))
    update_prize_confirm(KARMA_PRIZE_TYPE_ADD, form.lbl_add_timeout.Text)
  else
    form.lbl_add_timeout.Text = nx_widestr("")
    form.btn_karma_add.Enabled = false
    update_prize_confirm(KARMA_PRIZE_TYPE_ADD, "")
  end
  if nx_find_custom(form.lbl_dec_timeout, "prize_timeout") and nx_double(form.lbl_dec_timeout.prize_timeout) > nx_double(cur_date_time) then
    form.lbl_dec_timeout.Text = nx_widestr(format_time(nx_double(form.lbl_dec_timeout.prize_timeout) - nx_double(cur_date_time)))
    update_prize_confirm(KARMA_PRIZE_TYPE_DEC, form.lbl_dec_timeout.Text)
  else
    form.lbl_dec_timeout.Text = nx_widestr("")
    form.btn_karma_dec.Enabled = false
    update_prize_confirm(KARMA_PRIZE_TYPE_DEC, "")
  end
  if nx_find_custom(form.lbl_gold_timeout, "prize_timeout") and nx_double(form.lbl_gold_timeout.prize_timeout) > nx_double(cur_date_time) then
    form.lbl_gold_timeout.Text = nx_widestr(format_time(nx_double(form.lbl_gold_timeout.prize_timeout) - nx_double(cur_date_time)))
    update_prize_confirm(KARMA_PRIZE_TYPE_MONEY, form.lbl_gold_timeout.Text)
  else
    local old_time = form.lbl_gold_timeout.Text
    form.lbl_gold_timeout.Text = nx_widestr("")
    form.btn_prize_gold.Enabled = false
    update_prize_confirm(KARMA_PRIZE_TYPE_MONEY, "")
    if nx_string(old_time) ~= "" then
      nx_execute("custom_sender", "apply_add_npc_relation", nx_int(8), nx_string(npc_id), nx_int(0))
    end
  end
  if nx_find_custom(form.lbl_item_timeout, "prize_timeout") and nx_double(form.lbl_item_timeout.prize_timeout) > nx_double(cur_date_time) then
    form.lbl_item_timeout.Text = nx_widestr(format_time(nx_double(form.lbl_item_timeout.prize_timeout) - nx_double(cur_date_time)))
    update_prize_confirm(KARMA_PRIZE_TYPE_ITEM, form.lbl_item_timeout.Text)
  else
    local old_time = form.lbl_item_timeout.Text
    form.lbl_item_timeout.Text = nx_widestr("")
    form.btn_prize_item.Enabled = false
    update_prize_confirm(KARMA_PRIZE_TYPE_ITEM, "")
    if nx_string(old_time) ~= "" then
      nx_execute("custom_sender", "apply_add_npc_relation", nx_int(8), nx_string(npc_id), nx_int(0))
    end
  end
  if nx_find_custom(form.lbl_buffer_timeout, "prize_timeout") and nx_double(form.lbl_buffer_timeout.prize_timeout) > nx_double(cur_date_time) then
    form.lbl_buffer_timeout.Text = nx_widestr(format_time(nx_double(form.lbl_buffer_timeout.prize_timeout) - nx_double(cur_date_time)))
    update_prize_confirm(KARMA_PRIZE_TYPE_BUFFER, form.lbl_buffer_timeout.Text)
  else
    local old_time = form.lbl_buffer_timeout.Text
    form.lbl_buffer_timeout.Text = nx_widestr("")
    form.btn_prize_buffer.Enabled = false
    update_prize_confirm(KARMA_PRIZE_TYPE_BUFFER, "")
    if nx_string(old_time) ~= "" then
      nx_execute("custom_sender", "apply_add_npc_relation", nx_int(8), nx_string(npc_id), nx_int(0))
    end
  end
end
function update_prize_confirm(current_prize_type, time_out_text)
  nx_execute("form_common\\form_karma_prize_confirm", "update_time", current_prize_type, time_out_text)
end
function format_time(date)
  local str_dt = nx_function("format_date_time", nx_double(date))
  local table_dt = util_split_string(str_dt, ";")
  if table.getn(table_dt) ~= 2 then
    return ""
  end
  local format_time = format_time_text(table_dt[2])
  return format_time
end
function format_time_text(text)
  local len = string.len(text)
  if nx_number(len) ~= 8 then
    return text
  end
  local format_time = string.sub(nx_string(text), 1, 5)
  if nx_string(format_time) == "00:00" then
    format_time = "00:01"
  end
  return format_time
end
function refersh_npc_news(npc_id, num)
  local form_shili = nx_value("form_stage_main\\form_relation\\form_relation_shili")
  local form_fujin = nx_value("form_stage_main\\form_relation\\form_relation_fujin")
  local form_renmai = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  local gb_npc = nx_null()
  if nx_is_valid(form_shili) then
    form_shili.lbl_news.Visible = false
    form_shili.lbl_news_num.Visible = false
    gb_npc = form_shili.groupbox_npc:Find(nx_string(npc_id))
  end
  if nx_is_valid(gb_npc) then
    local gb_npc_info = gb_npc:Find("gb_npc_info" .. npc_id)
    if nx_is_valid(gb_npc_info) then
      local lbl_npc_news_num = gb_npc_info:Find("lbl_news_num_" .. npc_id)
      if nx_is_valid(lbl_npc_news_num) then
        if num == 0 then
          lbl_npc_news_num.Visible = false
        else
          lbl_npc_news_num.Visible = true
          lbl_npc_news_num.Text = nx_widestr("" .. nx_string(num))
        end
      end
    end
  end
  if nx_is_valid(form_renmai) or nx_is_valid(form_fujin) then
    local form_friend_list = nx_value("form_stage_main\\form_relation\\form_friend_list")
    if nx_is_valid(form_friend_list) then
      local gb_player = form_friend_list.player_list:Find("gb_player_" .. npc_id)
      if nx_is_valid(gb_player) then
        local lbl_npc_news_num = gb_player:Find("lbl_news_num_" .. npc_id)
        if nx_is_valid(lbl_npc_news_num) then
          if num == 0 then
            lbl_npc_news_num.Visible = false
          else
            lbl_npc_news_num.Visible = true
            lbl_npc_news_num.Text = nx_widestr("" .. nx_string(num))
          end
        end
      end
    end
  end
end
function change_form_size(form)
  local form_base = form.Parent
  if nx_is_valid(form_base) then
    form.Left = form_base.Left
    form.Top = form_base.Top
    form.Width = form_base.Width
    form.Height = form_base.Height
  end
end
function on_btn_npc_info_click(btn)
  if not nx_find_custom(btn.ParentForm, "target_npc_id") then
    return
  end
  local npc_id = btn.ParentForm.target_npc_id
  nx_execute("form_stage_main\\form_relation\\form_npc_info", "show_npc_info", npc_id)
end
function on_btn_present_click(btn)
  if not nx_find_custom(btn.ParentForm, "target_npc_id") then
    return
  end
  local npc_id = btn.ParentForm.target_npc_id
  if npc_id == "" then
    return
  end
  local scene_id = nx_execute("form_stage_main\\form_relation\\form_npc_info", "get_scene_id", npc_id)
  if nx_number(scene_id) == nx_number(-1) then
    return
  end
  local form = nx_value("form_stage_main\\form_present_to_npc")
  if nx_is_valid(form) then
    nx_destroy(form)
  end
  form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_present_to_npc", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.npc_id = npc_id
  form.scene_id = scene_id
  form.type = 2
  form:Show()
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
end
