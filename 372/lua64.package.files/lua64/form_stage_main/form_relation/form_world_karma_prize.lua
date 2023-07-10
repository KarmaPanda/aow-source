require("util_gui")
require("util_functions")
require("custom_sender")
local offset_left = -5
local offset_top = -8
local world_offset_top = 38
local world_offset_left = 5
local text_name = {
  "desc_jianghu_delaykarma1",
  "desc_jianghu_delaykarma2",
  "desc_jianghu_money",
  "desc_jianghu_item",
  "desc_jianghu_buff"
}
function main_form_init(form)
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    local control_list = form.groupbox_prize:GetChildControlList()
    for i = 1, table.getn(control_list) do
      if nx_find_custom(control_list[i], "list_prize") and nx_is_valid(control_list[i].list_prize) then
        control_list[i].list_prize:Close()
      end
      if nx_find_custom(control_list[i], "single_prize") and nx_is_valid(control_list[i].single_prize) then
        control_list[i].single_prize:Close()
      end
    end
    nx_destroy(form)
  end
end
function hide_form(scene_id)
  local form = nx_value("form_stage_main\\form_relation\\form_world_karma_prize" .. nx_string(scene_id))
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn1_get_capture(button)
  local form = button.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.groupbox_scene_relation:ToFront(button)
  if not nx_find_custom(button, "scene_id") then
    return
  end
  local x = button.Left + button.Width
  local y = button.Top + button.Height
  local npc_position = nx_string(button.npc_position_x) .. nx_string(",") .. nx_string(button.npc_position_z)
  nx_execute("tips_game", "ShowLeftPhoto3DTips", x, y, button.Name, button.scene_id, false, npc_position)
end
function on_btn1_lost_capture(button)
  nx_execute("tips_game", "hide_tip")
end
function on_btn1_right_click(btn)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local x = btn.Left - 105
  local y = btn.Top + btn.Height
  show_npc_menu(btn, x, y)
end
function show_npc_relation(...)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form_base = nx_value("form_stage_main\\form_relation\\form_relation_world")
  if not nx_is_valid(form_base) then
    return
  end
  local scene_id = arg[1]
  local isupdate = arg[2]
  local configid = arg[3]
  local relation_karma = nx_number(arg[4])
  local relation = nx_number(arg[5])
  local position_x = nx_number(arg[8])
  local position_z = nx_number(arg[9])
  local button = form_base.groupbox_scene_relation:Find(configid)
  if not nx_is_valid(button) then
    button = gui:Create("Button")
    button.Name = configid
    button.AutoSize = true
    button.DrawMode = "FitWindow"
    button.scene_id = scene_id
    button.npc_position_x = position_x
    button.npc_position_z = position_z
    nx_bind_script(button, nx_current())
    nx_callback(button, "on_get_capture", "on_btn1_get_capture")
    nx_callback(button, "on_lost_capture", "on_btn1_lost_capture")
    nx_callback(button, "on_right_click", "on_btn1_right_click")
    nx_callback(button, "on_click", "on_btn1_click")
  end
  if not nx_is_valid(button) then
    return
  end
  if not isupdate then
    button.Left = nx_number(arg[6]) - button.Width / 2
    button.Top = nx_number(arg[7]) - button.Height / 2
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\sns\\msg_config.ini")
  if nx_is_valid(ini) then
    local sec_index = ini:FindSectionIndex("KarmaPoint")
    if sec_index < 0 then
      sec_index = "0"
    end
    local GroupMsgData = ini:GetItemValueList(sec_index, nx_string("r"))
    for i = 1, nx_number(table.getn(GroupMsgData)) do
      local stepData = util_split_string(GroupMsgData[i], ",")
      if nx_number(stepData[1]) <= nx_number(relation_karma) and nx_number(relation_karma) <= nx_number(stepData[2]) then
        button.NormalImage = "gui\\special\\sns_new\\point\\" .. nx_string(stepData[4]) .. "_out.png"
        button.FocusImage = "gui\\special\\sns_new\\point\\" .. nx_string(stepData[4]) .. "_on.png"
        button.PushImage = "gui\\special\\sns_new\\point\\" .. nx_string(stepData[4]) .. "_down.png"
        button.relation_karma_text = nx_string(stepData[3])
      end
    end
  end
  if relation == 0 then
    button.relation_text = "ui_haoyou_01"
  elseif relation == 1 then
    button.relation_text = "ui_zhiyou_01"
  elseif relation == 2 then
    button.relation_text = "ui_guanzhu_01"
  else
    button.relation_text = ""
  end
  button.Left = nx_number(arg[6]) - button.Width / 2
  button.Top = nx_number(arg[7]) - button.Height / 2
  form_base.groupbox_scene_relation:Add(button)
  nx_execute("form_stage_main\\form_relation\\form_relation_world", "hide_all_city_button")
end
function show_form(...)
  local form_base = nx_value("form_stage_main\\form_relation\\form_relation_world")
  if not nx_is_valid(form_base) then
    return
  end
  local isupdate = arg[1]
  local isworld = arg[2]
  local scene_id = arg[3]
  local form = nx_value("form_stage_main\\form_relation\\form_world_karma_prize" .. nx_string(scene_id))
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_world_karma_prize", true, false, scene_id)
  end
  if not nx_is_valid(form) then
    return
  end
  form.scene_id = scene_id
  form.groupbox_prize.scene_id = scene_id
  if not isupdate then
    form.Left = nx_number(arg[4]) - form.Width / 2
    if isworld then
      form.Top = nx_number(arg[5]) - form.Height / 2 - world_offset_top
      form.Left = form.Left + world_offset_left
    else
      form.Top = nx_number(arg[5]) - form.Height / 2
    end
    return
  end
  local lbl_memory_data = form:Find("lbl_memory_data")
  if not nx_is_valid(lbl_memory_data) then
    local gui = nx_value("gui")
    lbl_memory_data = gui:Create("Label")
    lbl_memory_data.Left = 0
    lbl_memory_data.Top = 0
    lbl_memory_data.Width = 10
    lbl_memory_data.Height = 10
    lbl_memory_data.Visible = false
    form:Add(lbl_memory_data)
    form.lbl_memory_data = lbl_memory_data
    nx_function("ext_clear_custom_list", form.lbl_memory_data)
  else
    nx_function("ext_clear_custom_list", form.lbl_memory_data)
  end
  form.btn_prize_10.Visible = false
  form.btn_prize_10.count = 0
  form.btn_prize_0.Visible = false
  form.btn_prize_0.count = 0
  form.btn_prize_1_2.Visible = false
  form.btn_prize_1_2.count = 0
  form.btn_prize_3.Visible = false
  form.btn_prize_3.count = 0
  form.btn_prize_4.Visible = false
  form.btn_prize_4.count = 0
  form.lbl_prize_10.Visible = false
  form.lbl_prize_0.Visible = false
  form.lbl_prize_1_2.Visible = false
  form.lbl_prize_3.Visible = false
  form.lbl_prize_4.Visible = false
  local show_type_count = 0
  if not nx_find_custom(form, "lbl_memory_data") or not nx_is_valid(form.lbl_memory_data) then
    return
  end
  form.lbl_memory_data.prize_count_10 = 0
  form.lbl_memory_data.prize_npcid_10 = ""
  form.lbl_memory_data.prize_count_0 = 0
  form.lbl_memory_data.prize_npcid_0 = ""
  form.lbl_memory_data.prize_count_1 = 0
  form.lbl_memory_data.prize_npcid_1 = ""
  form.lbl_memory_data.prize_count_2 = 0
  form.lbl_memory_data.prize_npcid_2 = ""
  form.lbl_memory_data.prize_count_3 = 0
  form.lbl_memory_data.prize_npcid_3 = ""
  form.lbl_memory_data.prize_count_4 = 0
  form.lbl_memory_data.prize_npcid_4 = ""
  for i = 6, table.getn(arg), 3 do
    nx_set_custom(form.lbl_memory_data, "prize_count_" .. nx_string(arg[i]), nx_number(arg[i + 1]))
    nx_set_custom(form.lbl_memory_data, "prize_npcid_" .. nx_string(arg[i]), nx_string(arg[i + 2]))
  end
  if nx_find_custom(form.lbl_memory_data, "prize_count_0") then
    if isworld then
      form.lbl_prize_0.Text = nx_widestr(form.lbl_memory_data.prize_count_0)
    else
      local timeout_gold_text, text, str_dec_uid = get_prize_dec_info(scene_id)
      local num = 0
      local real_num = 0
      local table_uid_list = util_split_string(nx_string(str_dec_uid), ",")
      num = table.getn(table_uid_list)
      for i = 1, num do
        local uid_len = nx_string(string.len(table_uid_list[i]))
        if nx_number(uid_len) == nx_number(32) then
          real_num = real_num + 1
        end
      end
      if 1 < nx_number(real_num) then
        form.lbl_prize_0.Text = nx_widestr(real_num)
      else
        form.lbl_prize_0.Text = nx_widestr(form.lbl_memory_data.prize_count_0)
      end
    end
    form.btn_prize_0.count = nx_number(form.lbl_memory_data.prize_count_0)
    form.btn_prize_0.configid_list = nx_string(form.lbl_memory_data.prize_npcid_0)
    if 0 < form.lbl_memory_data.prize_count_0 then
      form.btn_prize_0.Left = show_type_count * form.btn_prize_0.Width
      form.btn_prize_0.Top = 0
      form.btn_prize_0.Visible = true
      form.lbl_prize_0.Left = form.btn_prize_0.Left + form.btn_prize_0.Width - form.lbl_prize_0.Width + offset_left
      form.lbl_prize_0.Top = form.btn_prize_0.Top + form.btn_prize_0.Height - form.lbl_prize_0.Height + offset_top
      form.lbl_prize_0.Visible = true
      show_type_count = show_type_count + 1
    end
  end
  if nx_find_custom(form.lbl_memory_data, "prize_count_10") then
    if isworld then
      form.lbl_prize_10.Text = nx_widestr(form.lbl_memory_data.prize_count_10)
    else
      local timeout_gold_text, text, str_dec_uid = get_prize_add_info(scene_id)
      local num = 0
      local real_num = 0
      local table_uid_list = util_split_string(nx_string(str_dec_uid), ",")
      num = table.getn(table_uid_list)
      for i = 1, num do
        local uid_len = nx_string(string.len(table_uid_list[i]))
        if nx_number(uid_len) == nx_number(32) then
          real_num = real_num + 1
        end
      end
      if 1 < nx_number(real_num) then
        form.lbl_prize_10.Text = nx_widestr(real_num)
      else
        form.lbl_prize_10.Text = nx_widestr(form.lbl_memory_data.prize_count_10)
      end
    end
    form.btn_prize_10.count = nx_number(form.lbl_memory_data.prize_count_10)
    form.btn_prize_10.configid_list = nx_string(form.lbl_memory_data.prize_npcid_10)
    if 0 < form.lbl_memory_data.prize_count_10 then
      form.btn_prize_10.Left = show_type_count * form.btn_prize_10.Width
      form.btn_prize_10.Top = 0
      form.btn_prize_10.Visible = true
      form.lbl_prize_10.Left = form.btn_prize_10.Left + form.btn_prize_10.Width - form.lbl_prize_10.Width + offset_left
      form.lbl_prize_10.Top = form.btn_prize_10.Top + form.btn_prize_10.Height - form.lbl_prize_10.Height + offset_top
      form.lbl_prize_10.Visible = true
      show_type_count = show_type_count + 1
    end
  end
  local prize_type_num = {
    0,
    0,
    0,
    0
  }
  for i = 1, 4 do
    if nx_find_custom(form.lbl_memory_data, "prize_count_" .. nx_string(i)) then
      prize_type_num[i] = nx_number(nx_custom(form.lbl_memory_data, "prize_count_" .. nx_string(i)))
    end
    if i ~= 1 and i ~= 2 then
      local control_btn = form.groupbox_prize:Find("btn_prize_" .. nx_string(i))
      local control_lbl = form.groupbox_prize:Find("lbl_prize_" .. nx_string(i))
      if nx_is_valid(control_btn) and nx_is_valid(control_lbl) then
        control_btn.count = prize_type_num[i]
        control_btn.configid_list = nx_string(nx_custom(form.lbl_memory_data, "prize_npcid_" .. nx_string(i)))
        control_lbl.Text = nx_widestr(prize_type_num[i])
        if 0 < prize_type_num[i] then
          control_btn.Left = show_type_count * control_btn.Width
          control_btn.Top = 0
          control_btn.Visible = true
          control_lbl.Left = control_btn.Left + control_btn.Width - control_lbl.Width + offset_left
          control_lbl.Top = control_btn.Top + control_btn.Height - control_lbl.Height + offset_top
          control_lbl.Visible = true
          show_type_count = show_type_count + 1
        end
      end
    end
  end
  if prize_type_num[1] + prize_type_num[2] > 0 then
    form.lbl_prize_1_2.Text = nx_widestr(prize_type_num[1] + prize_type_num[2])
    form.btn_prize_1_2.count = nx_number(prize_type_num[1] + prize_type_num[2])
    local prize_npcid_1 = ""
    if nx_find_custom(form.lbl_memory_data, "prize_npcid_1") then
      prize_npcid_1 = form.lbl_memory_data.prize_npcid_1
    end
    local prize_npcid_2 = ""
    if nx_find_custom(form.lbl_memory_data, "prize_npcid_2") then
      prize_npcid_2 = form.lbl_memory_data.prize_npcid_2
    end
    form.btn_prize_1_2.configid_list = nx_string(prize_npcid_1) .. nx_string(prize_npcid_2)
    form.btn_prize_1_2.Left = show_type_count * form.btn_prize_1_2.Width
    form.btn_prize_1_2.Top = 0
    form.btn_prize_1_2.Visible = true
    form.lbl_prize_1_2.Left = form.btn_prize_1_2.Left + form.btn_prize_1_2.Width - form.lbl_prize_1_2.Width + offset_left
    form.lbl_prize_1_2.Top = form.btn_prize_1_2.Top + form.btn_prize_1_2.Height - form.lbl_prize_1_2.Height + offset_top
    form.lbl_prize_1_2.Visible = true
    show_type_count = show_type_count + 1
  else
    form.lbl_prize_1_2.Text = nx_widestr(prize_type_num[1] + prize_type_num[2])
    form.btn_prize_1_2.count = nx_number(prize_type_num[1] + prize_type_num[2])
  end
  form.Width = show_type_count * form.btn_prize_1_2.Width
  form.Left = nx_number(arg[4]) - form.Width / 2
  if isworld then
    form.Top = nx_number(arg[5]) - form.Height / 2 - world_offset_top
    form.Left = form.Left + world_offset_left
  else
    form.Top = nx_number(arg[5]) - form.Height / 2
  end
  if isworld then
    form_base.groupbox_world:Add(form)
  else
    form_base.groupbox_scene:Add(form)
  end
  form.Visible = true
  form:Show()
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  local timer = nx_value("timer_game")
  timer:Register(10000, -1, nx_current(), "update_prize", form, -1, -1)
  update_prize(form)
  nx_execute("form_stage_main\\form_relation\\form_relation_world", "hide_all_city_button")
end
function update_prize(form)
  if not nx_is_valid(form) then
    return
  end
  local single_prize_form = nx_value("form_common\\form_karma_prize_confirm" .. nx_string(form.scene_id))
  if not nx_is_valid(single_prize_form) then
    single_prize_form = nx_value("form_stage_main\\form_relation\\form_world_karma_prize_list" .. nx_string(form.scene_id))
  end
  if nx_is_valid(single_prize_form) and nx_find_custom(single_prize_form, "specialType") then
    if nx_string(single_prize_form.specialType) == "add" then
      on_btn_karma_add_click(form.btn_prize_10)
    elseif nx_string(single_prize_form.specialType) == "dec" then
      on_btn_karma_dec_click(form.btn_prize_0)
    elseif nx_string(single_prize_form.specialType) == "1" or nx_string(single_prize_form.specialType) == "2" then
      on_btn_prize_gold_click(form.btn_prize_1_2)
    elseif nx_string(single_prize_form.specialType) == "3" then
      on_btn_prize_gold_click(form.btn_prize_3)
    elseif nx_string(single_prize_form.specialType) == "4" then
      on_btn_prize_gold_click(form.btn_prize_4)
    end
  end
end
function get_prize_add_info(configid)
  local gui = nx_value("gui")
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  local table_out = karmamgr:GetNpcPrize(nx_string(configid))
  local num = table.getn(table_out) / 3
  if nx_number(num) < nx_number(1) then
    return
  end
  local add_value = 0
  local timeout_gold = nx_double(0)
  local timeout_add = nx_double(0)
  local str_add_uid = ""
  for i = 1, num * 3, 3 do
    local value = table_out[i]
    local timeout = table_out[i + 1]
    local type = table_out[i + 2]
    if nx_string(type) ~= "Gold" and nx_int64(value) > nx_int64(0) then
      add_value = nx_int64(add_value) + nx_int64(value)
      str_add_uid = nx_string(str_add_uid) .. nx_string(type) .. ","
      if nx_double(timeout) > nx_double(timeout_add) then
        timeout_add = nx_double(timeout)
      end
    end
  end
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  local time_out_text = nx_widestr(format_time(nx_double(timeout_add) - nx_double(cur_date_time)))
  if nx_double(timeout_add) <= nx_double(cur_date_time) then
    time_out_text = ""
  end
  gui.TextManager:Format_SetIDName("ui_sns_npcvalue001")
  gui.TextManager:Format_AddParam(nx_string(configid))
  gui.TextManager:Format_AddParam(nx_int64(add_value * karmamgr:GetGoodCoefficient()))
  gui.TextManager:Format_AddParam(nx_int64(500))
  local text = gui.TextManager:Format_GetText()
  return time_out_text, text, str_add_uid
end
function on_btn_karma_add_click(btn)
  if not nx_find_custom(btn, "count") then
    return
  end
  if btn.count == 0 then
    if nx_find_custom(btn, "single_prize") and nx_is_valid(btn.single_prize) then
      btn.single_prize:Close()
      return
    end
    if nx_find_custom(btn, "list_prize") and nx_is_valid(btn.list_prize) then
      btn.list_prize:Close()
      return
    end
    return
  end
  local list = util_split_string(btn.configid_list, ",")
  local configid_list = {}
  for i = 1, table.getn(list) do
    if list[i] ~= "" then
      configid_list[table.getn(configid_list) + 1] = list[i]
    end
  end
  if nx_number(btn.count) == 1 and (not nx_find_custom(btn, "list_prize") or not nx_is_valid(btn.list_prize)) then
    if table.getn(configid_list) ~= 1 then
      return
    end
    local time_out_text, text, str_add_uid = get_prize_add_info(configid_list[1])
    local form_prize = nx_value("form_common\\form_karma_prize_confirm" .. nx_string(btn.Parent.scene_id))
    if nx_is_valid(form_prize) then
      if time_out_text == "" then
        form_prize:Close()
        btn.Parent.Parent:Close()
      else
        nx_execute("form_common\\form_karma_prize_confirm", "update_time", 10, time_out_text, false)
      end
      return
    elseif time_out_text == "" then
      btn.Parent.Parent:Close()
      return
    end
    local table_uid_list = util_split_string(nx_string(str_add_uid), ",")
    local num = table.getn(table_uid_list)
    form_prize = nx_execute("util_gui", "util_get_form", "form_common\\form_karma_prize_confirm", true, false, nx_string(btn.Parent.scene_id))
    local real_num = 0
    for i = 1, num do
      local uid_len = nx_string(string.len(table_uid_list[i]))
      if nx_number(uid_len) == nx_number(32) then
        real_num = real_num + 1
      end
    end
    nx_execute("form_common\\form_karma_prize_confirm", "show_karma_prize_confirm", form_prize, 10, time_out_text, text, real_num)
    form_prize.configid = configid_list[1]
    form_prize.specialType = "add"
    btn.single_prize = form_prize
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
        nx_execute("custom_sender", "apply_add_npc_relation", nx_int(3), nx_string(table_uid_list[i]), nx_int(0), nx_string(configid_list[1]))
      end
    end
  else
    if nx_number(btn.count) ~= table.getn(configid_list) then
      return
    end
    local prize_list = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_world_karma_prize_list", true, false, nx_string(btn.Parent.scene_id))
    if not nx_is_valid(prize_list) then
      return
    end
    prize_list.configid_list = ""
    for i = 1, table.getn(configid_list) do
      local timeout_gold_text, text, str_add_uid = get_prize_add_info(configid_list[i])
      nx_execute("form_stage_main\\form_relation\\form_world_karma_prize_list", "addItem", prize_list, configid_list[i], 3, 10, timeout_gold_text, text, str_add_uid)
      if not nx_is_valid(prize_list) then
        return
      end
      prize_list.configid_list = prize_list.configid_list .. nx_string(configid_list[i]) .. ","
    end
    nx_execute("form_stage_main\\form_relation\\form_world_karma_prize_list", "clearItem", prize_list)
    prize_list.specialType = "add"
    btn.list_prize = prize_list
    prize_list:Show()
  end
end
function get_prize_dec_info(configid)
  local gui = nx_value("gui")
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  local table_out = karmamgr:GetNpcPrize(nx_string(configid))
  local num = table.getn(table_out) / 3
  if nx_number(num) < nx_number(1) then
    return
  end
  local dec_value = 0
  local timeout_gold = nx_double(0)
  local timeout_dec = nx_double(0)
  local str_dec_uid = ""
  for i = 1, num * 3, 3 do
    local value = table_out[i]
    local timeout = table_out[i + 1]
    local type = table_out[i + 2]
    if nx_string(type) ~= "Gold" and nx_int64(value) < nx_int64(0) then
      dec_value = nx_int64(dec_value) + nx_int64(value)
      str_dec_uid = nx_string(str_dec_uid) .. nx_string(type) .. ","
      if nx_double(timeout) > nx_double(timeout_dec) then
        timeout_dec = nx_double(timeout)
      end
    end
  end
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  local time_out_text = nx_widestr(format_time(nx_double(timeout_dec) - nx_double(cur_date_time)))
  if nx_double(timeout_dec) <= nx_double(cur_date_time) then
    time_out_text = ""
  end
  gui.TextManager:Format_SetIDName("ui_sns_npcvalue002")
  gui.TextManager:Format_AddParam(nx_string(configid))
  gui.TextManager:Format_AddParam(nx_int64(math.abs(dec_value) * karmamgr:GetBadCoefficient()))
  gui.TextManager:Format_AddParam(nx_int64(500))
  local text = gui.TextManager:Format_GetText()
  return time_out_text, text, str_dec_uid
end
function on_btn_karma_dec_click(btn)
  if not nx_find_custom(btn, "count") then
    return
  end
  if btn.count == 0 then
    if nx_find_custom(btn, "single_prize") and nx_is_valid(btn.single_prize) then
      btn.single_prize:Close()
      return
    end
    if nx_find_custom(btn, "list_prize") and nx_is_valid(btn.list_prize) then
      btn.list_prize:Close()
      return
    end
    return
  end
  if not nx_find_custom(btn, "configid_list") then
    return
  end
  local list = util_split_string(btn.configid_list, ",")
  local configid_list = {}
  for i = 1, table.getn(list) do
    if list[i] ~= "" then
      configid_list[table.getn(configid_list) + 1] = list[i]
    end
  end
  if nx_number(btn.count) == 1 and (not nx_find_custom(btn, "list_prize") or not nx_is_valid(btn.list_prize)) then
    if table.getn(configid_list) ~= 1 then
      return
    end
    local time_out_text, text, str_dec_uid = get_prize_dec_info(configid_list[1])
    local form_prize = nx_value("form_common\\form_karma_prize_confirm" .. nx_string(btn.Parent.scene_id))
    if nx_is_valid(form_prize) then
      if time_out_text == "" then
        form_prize:Close()
        btn.Parent.Parent:Close()
      else
        nx_execute("form_common\\form_karma_prize_confirm", "update_time", -10, time_out_text, false)
      end
      return
    elseif time_out_text == "" then
      btn.Parent.Parent:Close()
      return
    end
    form_prize = nx_execute("util_gui", "util_get_form", "form_common\\form_karma_prize_confirm", true, false, nx_string(btn.Parent.scene_id))
    local table_uid_list = util_split_string(nx_string(str_dec_uid), ",")
    local num = table.getn(table_uid_list)
    local real_num = 0
    for i = 1, num do
      local uid_len = nx_string(string.len(table_uid_list[i]))
      if nx_number(uid_len) == nx_number(32) then
        real_num = real_num + 1
      end
    end
    nx_execute("form_common\\form_karma_prize_confirm", "show_karma_prize_confirm", form_prize, -10, time_out_text, text, real_num)
    form_prize.configid = configid_list[1]
    form_prize.specialType = "dec"
    btn.single_prize = form_prize
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
        nx_execute("custom_sender", "apply_add_npc_relation", nx_int(4), nx_string(table_uid_list[i]), nx_int(0), nx_string(configid_list[1]))
      end
    end
  else
    if nx_number(btn.count) ~= table.getn(configid_list) then
      return
    end
    local prize_list = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_world_karma_prize_list", true, false, nx_string(btn.Parent.scene_id))
    if not nx_is_valid(prize_list) then
      return
    end
    prize_list.configid_list = ""
    for i = 1, table.getn(configid_list) do
      local timeout_gold_text, text, str_dec_uid = get_prize_dec_info(configid_list[i])
      nx_execute("form_stage_main\\form_relation\\form_world_karma_prize_list", "addItem", prize_list, configid_list[i], 4, -10, timeout_gold_text, text, str_dec_uid)
      if not nx_is_valid(prize_list) then
        return
      end
      prize_list.configid_list = prize_list.configid_list .. nx_string(configid_list[i]) .. ","
    end
    nx_execute("form_stage_main\\form_relation\\form_world_karma_prize_list", "clearItem", prize_list)
    prize_list.specialType = "dec"
    btn.list_prize = prize_list
    prize_list:Show()
  end
end
function get_prize_gold_info(configid)
  local gui = nx_value("gui")
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  local table_out = karmamgr:GetNpcPrize(nx_string(configid))
  local num = table.getn(table_out) / 3
  if nx_number(num) < nx_number(1) then
    return
  end
  local gold_value = 0
  local timeout_gold = nx_double(0)
  for i = 1, num * 3, 3 do
    local value = table_out[i]
    local timeout = table_out[i + 1]
    local type = table_out[i + 2]
    if nx_string(type) == "Gold" then
      gold_value = nx_int64(value)
      timeout_gold = nx_double(timeout)
    end
  end
  local table_out_prize = karmamgr:GetKarmaPrizeInfo(nx_int(gold_value))
  local num = table.getn(table_out_prize)
  local prize_type = 0
  local prize_id = ""
  local prize_amount = 0
  local prize_text = ""
  if nx_number(num) == nx_number(4) then
    prize_type = nx_int(table_out_prize[1])
    prize_id = nx_string(table_out_prize[2])
    prize_amount = nx_int(table_out_prize[3])
    prize_text = nx_string(table_out_prize[4])
  end
  if nx_number(prize_type) < nx_number(1) or nx_number(prize_type) > nx_number(4) then
    return
  end
  local form_text = prize_text
  local text_para_2 = false
  local text_para_3 = false
  local bHasText = false
  if nx_string(form_text) == "" then
    bHasText = true
  end
  if nx_number(prize_type) == nx_number(1) then
    if bHasText then
      form_text = "ui_geinisuiyin"
    end
    text_para_3 = true
  elseif nx_number(prize_type) == nx_number(2) then
    if bHasText then
      form_text = "ui_geiniguanyin"
    end
    text_para_3 = true
  elseif nx_number(prize_type) == nx_number(3) then
    if bHasText then
      form_text = "ui_geinidaojv"
    end
    text_para_2 = true
    text_para_3 = true
  elseif nx_number(prize_type) == nx_number(4) then
    if bHasText then
      form_text = "ui_geinizengyi"
    end
    text_para_2 = true
  end
  gui.TextManager:Format_SetIDName(nx_string(form_text))
  gui.TextManager:Format_AddParam(nx_string(configid))
  if text_para_2 then
    gui.TextManager:Format_AddParam(nx_string(prize_id))
  end
  if text_para_3 then
    gui.TextManager:Format_AddParam(nx_int64(prize_amount))
  end
  local text = gui.TextManager:Format_GetText()
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  local timeout_gold_text = nx_widestr(format_time(nx_double(timeout_gold) - nx_double(cur_date_time)))
  if nx_double(timeout_gold) <= nx_double(cur_date_time) then
    timeout_gold_text = ""
  end
  return prize_type, timeout_gold_text, text, prize_id, prize_amount
end
function on_btn_prize_gold_click(btn)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  if not nx_find_custom(btn, "count") then
    return
  end
  if btn.count == 0 then
    if nx_find_custom(btn, "single_prize") and nx_is_valid(btn.single_prize) then
      btn.single_prize:Close()
      return
    end
    if nx_find_custom(btn, "list_prize") and nx_is_valid(btn.list_prize) then
      btn.list_prize:Close()
      return
    end
    return
  end
  if not nx_find_custom(btn, "configid_list") then
    return
  end
  local list = util_split_string(btn.configid_list, ",")
  local configid_list = {}
  for i = 1, table.getn(list) do
    if list[i] ~= "" then
      configid_list[table.getn(configid_list) + 1] = list[i]
    end
  end
  if nx_number(btn.count) == 1 and (not nx_find_custom(btn, "list_prize") or not nx_is_valid(btn.list_prize)) then
    if table.getn(configid_list) ~= 1 then
      return
    end
    local prize_type, timeout_gold_text, text, prize_id, prize_amount = get_prize_gold_info(configid_list[1])
    local form_prize = nx_value("form_common\\form_karma_prize_confirm" .. nx_string(btn.Parent.scene_id))
    if nx_is_valid(form_prize) then
      if time_out_text == "" then
        form_prize:Close()
        btn.Parent.Parent:Close()
      else
        nx_execute("form_common\\form_karma_prize_confirm", "update_time", prize_type, timeout_gold_text, false)
      end
      return
    elseif time_out_text == "" then
      btn.Parent.Parent:Close()
      return
    end
    form_prize = nx_execute("util_gui", "util_get_form", "form_common\\form_karma_prize_confirm", true, false, nx_string(btn.Parent.scene_id))
    nx_execute("form_common\\form_karma_prize_confirm", "show_karma_prize_confirm", form_prize, prize_type, timeout_gold_text, text, prize_id, prize_amount)
    form_prize.specialType = nx_string(prize_type)
    form_prize.configid = configid_list[1]
    btn.single_prize = form_prize
    form_prize:ShowModal()
    local res = nx_wait_event(100000000, form_prize, "karma_prize_confirm_return")
    if res ~= "ok" then
      return
    end
    if nx_string(configid_list[1]) ~= "" then
      nx_execute("custom_sender", "apply_add_npc_relation", nx_int(5), nx_string(configid_list[1]), nx_int(0))
    end
  else
    if nx_number(btn.count) ~= table.getn(configid_list) then
      return
    end
    local prize_list = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_world_karma_prize_list", true, false, nx_string(btn.Parent.scene_id))
    if not nx_is_valid(prize_list) then
      return
    end
    prize_list.configid_list = ""
    for i = 1, table.getn(configid_list) do
      local prize_type, timeout_gold_text, text, prize_id, prize_amount = get_prize_gold_info(configid_list[i])
      nx_execute("form_stage_main\\form_relation\\form_world_karma_prize_list", "addItem", prize_list, configid_list[i], 5, prize_type, timeout_gold_text, text, prize_id, prize_amount)
      if not nx_is_valid(prize_list) then
        return
      end
      prize_list.specialType = nx_string(prize_type)
      prize_list.configid_list = prize_list.configid_list .. nx_string(configid_list[i]) .. ","
    end
    nx_execute("form_stage_main\\form_relation\\form_world_karma_prize_list", "clearItem", prize_list)
    btn.list_prize = prize_list
    prize_list:Show()
  end
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
function on_btn_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_get_capture(btn)
  local form_groupbox = btn.Parent.Parent.Parent
  local form = btn.Parent.Parent
  if nx_is_valid(form_groupbox) and nx_is_valid(form) then
    form_groupbox:ToFront(form)
  end
  if not nx_find_custom(btn, "configid_list") then
    return
  end
  local list = util_split_string(btn.configid_list, ",")
  local configid_list = {}
  for i = 1, table.getn(list) do
    local is_find = false
    for j = 1, table.getn(configid_list) do
      if nx_string(configid_list[j]) == nx_string(list[i]) then
        is_find = true
      end
    end
    if list[i] ~= "" and not is_find then
      configid_list[table.getn(configid_list) + 1] = list[i]
    end
  end
  local gui = nx_value("gui")
  local name_list = ""
  for i = 1, table.getn(configid_list) do
    if i ~= table.getn(configid_list) then
      name_list = name_list .. nx_string(gui.TextManager:GetText(configid_list[i])) .. nx_string(gui.TextManager:GetText("desc_sns_and"))
    else
      name_list = name_list .. nx_string(gui.TextManager:GetText(configid_list[i]))
    end
  end
  if name_list == "" then
    return
  end
  gui.TextManager:Format_SetIDName(text_name[nx_number(btn.DataSource)])
  gui.TextManager:Format_AddParam(nx_string(name_list))
  local text = gui.TextManager:Format_GetText()
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), btn.AbsLeft, btn.AbsTop, 160, btn.ParentForm)
end
function on_btn1_click(btn)
  local gui = nx_value("gui")
  local ItemQuery = nx_value("ItemQuery")
  local karmamgr = nx_value("Karma")
  if not (nx_is_valid(gui) and nx_is_valid(ItemQuery)) or not nx_is_valid(karmamgr) then
    return
  end
  if not nx_find_custom(btn, "scene_id") then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  local npc_id = btn.Name
  local scene_id = btn.scene_id
  local photo, name, origin, character_str, relation, scene_str, pos_str, shili_str, yinxiang
  photo = ItemQuery:GetItemPropByConfigID(nx_string(npc_id), nx_string("Photo"))
  if nx_string(photo) == nx_string("") then
    photo = "gui\\special\\sns_new\\sns_head\\common_head.png"
  end
  name = nx_string(npc_id)
  origin = npc_id .. "_1"
  if gui.TextManager:IsIDName(nx_string(origin)) then
    origin = nx_widestr(util_text(nx_string(origin)))
  else
    origin = nx_widestr(util_text(nx_string("ui_karma_none")))
  end
  local Flag = ItemQuery:GetItemPropByConfigID(nx_string(npc_id), nx_string("Character"))
  if nx_number(Flag) == nx_number(1) then
    character_str = nx_widestr(util_text("ui_xiashi"))
  elseif nx_number(Flag) == nx_number(2) then
    character_str = nx_widestr(util_text("ui_eren"))
  elseif nx_number(Flag) == nx_number(3) then
    character_str = nx_widestr(util_text("ui_xie"))
  elseif nx_number(Flag) == nx_number(4) then
    character_str = nx_widestr(util_text("ui_kuang"))
  else
    character_str = nx_widestr(util_text(nx_string("ui_sns_npcinfo_noinfo1")))
  end
  local relation_type = nx_execute("form_stage_main\\form_relation\\form_relation_shili\\form_group_karma", "get_npc_relation", npc_id)
  if relation_type == 0 then
    relation = nx_widestr(util_text(nx_string("ui_haoyou_01")))
  elseif relation_type == 1 then
    relation = nx_widestr(util_text(nx_string("ui_zhiyou_01")))
  elseif relation_type == 2 then
    relation = nx_widestr(util_text(nx_string("ui_guanzhu_01")))
  else
    relation = nx_widestr(util_text(nx_string("ui_sns_npcinfo_noinfo2")))
  end
  local shili_id = karmamgr:GetGroupKarma(nx_string(npc_id))
  if nx_string(shili_id) ~= "" then
    shili_str = nx_widestr(util_text("group_karma_" .. nx_string(shili_id)))
  else
    shili_str = nx_widestr(util_text("ui_sns_npcinfo_noinfo2"))
  end
  scene_str = "ui_scene_" .. nx_string(scene_id)
  if util_text(nx_string(scene_str)) ~= nx_string(scene_str) then
    scene_str = nx_widestr(util_text(nx_string(scene_str)))
  else
    scene_str = nx_widestr(util_text(nx_string("ui_sns_npcinfo_noinfo1")))
  end
  pos_str = nx_widestr(nx_int(btn.npc_position_x)) .. nx_widestr(",") .. nx_widestr(nx_int(btn.npc_position_z))
  local rnr_rows = player:GetRecordRows("rec_npc_relation")
  yinxiang = nx_widestr(gui.TextManager:GetText("ui_karma_rela4"))
  for i = 0, rnr_rows - 1 do
    if nx_string(npc_id) == nx_string(player:QueryRecord("rec_npc_relation", i, 0)) then
      local karma = player:QueryRecord("rec_npc_relation", i, 2)
      yinxiang = nx_execute("form_stage_main\\form_relation\\form_relation_shili\\form_group_karma", "get_karma_name", karma, false)
      break
    end
  end
  local is_prize_npc = true
  local is_avenge_npc = nx_execute("form_stage_main\\form_relation\\form_avenge_search", "is_avenge_npc", nx_string(npc_id))
  local is_baowu_npc = nx_execute("form_stage_main\\form_relation\\form_enchou_npc_list", "is_zhibao_npc", nx_string(npc_id))
  nx_execute("form_stage_main\\form_relation\\form_world_city_npc_info", "show_npc_desc", photo, name, origin, character_str, relation, scene_str, pos_str, shili_str, yinxiang, is_prize_npc, is_avenge_npc, is_baowu_npc)
  local x = btn.Left - 105
  local y = btn.Top + btn.Height
  show_npc_menu(btn, x, y)
end
function show_npc_menu(btn, x, y)
  if not nx_find_custom(btn, "scene_id") then
    return
  end
  nx_execute("form_stage_main\\form_relation\\form_sns_menu", "LoadMenuItem", btn.Name, btn.scene_id, x, y)
end
