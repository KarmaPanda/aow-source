require("util_functions")
require("util_gui")
require("share\\view_define")
require("share\\client_custom_define")
require("form_stage_main\\form_origin\\kapai_define")
require("form_stage_main\\switch\\switch_define")
local main_row_num = 0
local main_kapai_num = 0
local kapai_para = {}
function main_form_init(form)
  form.Fixed = false
  main_row_num = 0
  main_kapai_num = 0
  return 1
end
function on_main_form_open(form)
  if not is_open_degree_kapai() then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("19596"), 2)
    end
    form:Close()
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  init_tab_form(form)
  nx_execute("custom_sender", "custom_kapai_msg", OPEN_FORM)
  local rbtn = form.rbtn_type_1
  rbtn.Checked = true
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("rec_kapai_daily_max", form, nx_current(), "on_rec_change")
    databinder:AddRolePropertyBind("PrestigeExp", "int", form, nx_current(), "on_update_PrestigeExp")
  end
  nx_execute("util_gui", "ui_show_attached_form", form)
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_main_form_close(form)
  ui_destroy_attached_form(form)
  local prize_form = nx_value("form_stage_main\\form_origin\\form_kapai_drop")
  if nx_is_valid(prize_form) then
    prize_form:Close()
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("rec_kapai_daily_max", form)
  end
  nx_destroy(form)
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function init_tab_form(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local kapai_manager = nx_value("Kapai")
  local type_table = kapai_manager:GetAllKapaiType()
  table.sort(type_table)
  form.rbtn_type_1.Text = nx_widestr("   ") .. nx_widestr(gui.TextManager:GetText("type_prestige_" .. nx_string(type_table[1])))
  form.rbtn_type_1.HintText = gui.TextManager:GetText("tips_prestige_type1")
  local icon = gui:Create("Label")
  icon.Width = 23
  icon.Height = 22
  icon.Top = form.rbtn_type_1.Top + 10
  icon.Left = form.rbtn_type_1.Left + 10
  icon.BackImage = "gui\\language\\ChineseS\\prestige\\btn_type1_out.png"
  form.groupbox_tab:Add(icon)
  local len = table.getn(type_table)
  for i = 2, len do
    local id = type_table[i]
    local clone = clone_radiobutton(form.rbtn_type_1)
    clone.Name = "rbtn_type_" .. nx_string(id)
    clone.Text = nx_widestr("   ") .. gui.TextManager:GetText("type_prestige_" .. nx_string(id))
    clone.Left = form.rbtn_type_1.Left + (form.rbtn_type_1.Width + 20) * (i - 1)
    clone.HintText = gui.TextManager:GetText("tips_prestige_type" .. nx_string(id))
    local icon
    if nx_find_custom(clone, "icon") then
      icon = clone.icon
      icon.Left = clone.Left + 10
      icon.Top = clone.Top + 10
      icon.BackImage = "gui\\language\\ChineseS\\prestige\\btn_type" .. nx_string(id) .. "_out.png"
    end
    nx_bind_script(clone, nx_current())
    nx_callback(clone, "on_checked_changed", "on_rbtn_type_checked_changed")
    form.groupbox_tab:Add(clone)
    if nx_is_valid(icon) then
      form.groupbox_tab:Add(icon)
    end
  end
  set_jianghu_yueli(form)
end
function init_kapai_main(form)
  clear_kapai_main()
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.mltbox_prestigeexp.HtmlText = nx_widestr("0")
  if client_player:FindProp("PrestigeExp") then
    form.mltbox_prestigeexp.HtmlText = nx_widestr(client_player:QueryProp("PrestigeExp"))
  end
  if not client_player:FindRecord("Origin_Kapai") then
    return
  end
  local ini = get_ini("share\\Karma\\prestige.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:GetSectionCount()
  for i = 0, sec_count - 1 do
    local kapai_id = ini:GetSectionByIndex(i)
    local type_id = ini:ReadInteger(i, "Type", 0)
    if 0 <= client_player:FindRecordRow("Origin_Kapai", KAPAI_REC_ID, nx_int(kapai_id)) and nx_int(form.kapai_type) == nx_int(type_id) then
      local clone = clone_groupbox_kapai(nx_int(kapai_id), nx_number(type_id))
      fresh_groupbox_kapai(clone, nx_int(kapai_id))
      add_to_main(clone)
    end
  end
  if main_row_num == 1 and form.kapai_type < 5 then
    add_background_to_main(main_row_num)
  end
  form.kapai_main.IsEditMode = false
end
function add_to_main(kapai)
  if not nx_is_valid(kapai) then
    return
  end
  local form = nx_value("form_stage_main\\form_origin\\form_kapai")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local main_width = form.kapai_main.Width - form.kapai_main.ScrollSize
  local max_col_num = math.floor(main_width / kapai.Width)
  local total_space = main_width % kapai.Width
  local unit_space = math.floor(total_space / (max_col_num + 1))
  local row = math.floor(main_kapai_num / max_col_num)
  local col = main_kapai_num % max_col_num
  kapai.Left = col * (kapai.Width + unit_space) + unit_space
  kapai.Top = row * kapai.Height
  if col == 0 then
    add_background_to_main(main_row_num)
    main_row_num = main_row_num + 1
  end
  main_kapai_num = main_kapai_num + 1
  form.kapai_main:Add(kapai)
end
function clone_groupbox_kapai(id, type)
  local form = nx_value("form_stage_main\\form_origin\\form_kapai")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local kapai_manager = nx_value("Kapai")
  local type = nx_number(type)
  local src = form:Find("groupbox_kapai_" .. nx_string(type))
  if not nx_is_valid(src) then
    return
  end
  local clone = clone_groupbox(src)
  clone.Name = "groupbox_kapai" .. nx_string(id)
  clone.Visable = true
  clone.id = id
  local temp
  temp = gui:Create("Label")
  temp.Name = "lbl_yuan"
  temp.BackImage = "yuan"
  temp.Visible = false
  clone:Add(temp)
  local temp
  temp = clone_button(src:Find("btn_kapai_" .. nx_string(type)))
  temp.Name = "btn_kapai"
  clone:Add(temp)
  nx_bind_script(temp, nx_current())
  nx_callback(temp, "on_click", "on_btn_kapai_click")
  nx_callback(temp, "on_get_capture", "on_btn_kapai_get_capture")
  nx_callback(temp, "on_lost_capture", "on_btn_kapai_lost_capture")
  local yuan = clone:Find("lbl_yuan")
  local btn = clone:Find("btn_kapai")
  if nx_is_valid(yuan) and nx_is_valid(btn) then
    yuan.Left = btn.Left - 20
    yuan.Top = btn.Top - 20
    yuan.Width = btn.Width + 40
    yuan.Height = btn.Height
  end
  local temp
  temp = clone_label(src:Find("lbl_time_" .. nx_string(type)))
  temp.Name = "lbl_time"
  clone:Add(temp)
  temp = nil
  temp = clone_multitextbox(src:Find("mltbox_state_" .. nx_string(type)))
  temp.Name = "mltbox_state"
  clone:Add(temp)
  local temp
  temp = gui:Create("Label")
  temp.Name = "lbl_kuang"
  temp.Visible = false
  local state = clone:Find("mltbox_state")
  if nx_is_valid(state) then
    temp.Left = state.Left
    temp.Top = state.Top
    temp.Width = state.Width
    temp.Height = state.Height
  end
  clone:Add(temp)
  return clone
end
function add_background_to_main(row)
  local form = nx_value("form_stage_main\\form_origin\\form_kapai")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local back_kapai = form.lbl_back_kapai
  local background_height = form.groupbox_template.Height
  if form.kapai_type == 5 then
    back_kapai = form.lbl_back_kapai_5
    background_height = form.groupbox_template_5.Height
  end
  local top = row * background_height
  local clone = clone_label(back_kapai)
  clone.Left = 0
  clone.Top = top + back_kapai.Top
  form.kapai_main:Add(clone)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) or not form.Visible then
    return
  end
  on_main_form_close(form)
end
function on_btn_kapai_click(btn)
  local parent = btn.Parent
  nx_execute("custom_sender", "custom_kapai_msg", CLICK_KAPAI, parent.id)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_kapai_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_kapai_get_capture(btn)
  local parent = btn.Parent
  local gui = nx_value("gui")
  local text = ""
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local row = client_player:FindRecordRow("Origin_Kapai", KAPAI_REC_ID, nx_int(parent.id))
  if row < 0 then
    return
  end
  local valid_list = client_player:QueryRecord("Origin_Kapai", row, KAPAI_REC_VALID_LIST)
  if nx_string(valid_list) == nx_string("") then
    text = gui.TextManager:GetText("ui_prestige_nosub")
    local mouse_x, mouse_z = gui:GetCursorPosition()
    nx_execute("tips_game", "show_text_tip", nx_widestr(text), mouse_x, mouse_z)
    return
  end
  local state = client_player:QueryRecord("Origin_Kapai", row, KAPAI_REC_STATE)
  local sub_id = client_player:QueryRecord("Origin_Kapai", row, KAPAI_REC_SUB_ID)
  if state == KAPAI_STATE_OPENING then
    text = gui.TextManager:GetText("ui_prestige_on_open")
    text = nx_widestr(text) .. nx_widestr(gui.TextManager:GetText("sub_prestige_" .. nx_string(sub_id)))
  elseif state == KAPAI_STATE_DONE then
    text = gui.TextManager:GetText("ui_prestige_on_got")
    text = nx_widestr(text) .. nx_widestr(gui.TextManager:GetText("sub_prestige_" .. nx_string(sub_id)))
  elseif state == KAPAI_STATE_CAN_OPEN then
    text = gui.TextManager:GetText("ui_prestige_on_cansee")
  elseif state == KAPAI_STATE_CLOSING then
    local kapai_manager = nx_value("Kapai")
    local condition_manager = nx_value("ConditionManager")
    text = gui.TextManager:GetText("ui_prestige_on_cantsee")
    con_list = kapai_manager:GetConditionList(parent.id)
    for i, val in pairs(con_list) do
      local condition_decs = gui.TextManager:GetText(condition_manager:GetConditionDesc(nx_int(val)))
      text = nx_widestr(text) .. nx_widestr("<br>") .. nx_widestr(condition_decs)
    end
  elseif state == KAPAI_STATE_COOLDOWN then
    text = gui.TextManager:GetText("ui_prestige_on_cold")
  end
  local mouse_x, mouse_z = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), mouse_x, mouse_z)
end
function clear_kapai_main()
  local form = nx_value("form_stage_main\\form_origin\\form_kapai")
  if not nx_is_valid(form) then
    return
  end
  form.kapai_main:DeleteAll()
  main_kapai_num = 0
  main_row_num = 0
end
function on_rbtn_type_checked_changed(btn)
  if btn.Checked then
    local type_id = get_rbtn_name_id(btn.Name)
    if nx_int(type_id) == 0 then
      return
    end
    local form = btn.ParentForm
    form.kapai_type = nx_int(type_id)
    init_kapai_main(form)
    show_main_form()
    local sub_form = nx_value("form_stage_main\\form_origin\\form_sub_kapai")
    if nx_is_valid(sub_form) then
      nx_execute("form_stage_main\\form_origin\\form_sub_kapai", "on_main_form_close", sub_form)
    end
    update_kapai_number(form)
  end
end
function fresh_groupbox_kapai(clone, kapai_id)
  if not nx_is_valid(clone) then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local kapai_manager = nx_value("Kapai")
  local row = client_player:FindRecordRow("Origin_Kapai", KAPAI_REC_ID, nx_int(kapai_id))
  if row < 0 then
    return
  end
  local sub_id = client_player:QueryRecord("Origin_Kapai", row, KAPAI_REC_SUB_ID)
  local state = client_player:QueryRecord("Origin_Kapai", row, KAPAI_REC_STATE)
  clone:Find("mltbox_state").HtmlText = gui.TextManager:GetText(state_name[state])
  if nx_number(state) == nx_number(2) then
    clone:Find("lbl_yuan").Visible = true
    clone:Find("lbl_kuang").Visible = true
  else
    clone:Find("lbl_yuan").Visible = false
    clone:Find("lbl_kuang").Visible = false
  end
  if state == KAPAI_STATE_OPENING or state == KAPAI_STATE_DONE then
    clone:Find("btn_kapai").NormalImage = kapai_manager:GetKapaiIcon(kapai_id)
  else
    clone:Find("btn_kapai").NormalImage = kapai_manager:GetKapaiOffIcon(kapai_id)
  end
  if state == KAPAI_STATE_DONE or state == KAPAI_STATE_COOLDOWN then
    local msg_delay = nx_value("MessageDelay")
    if not nx_is_valid(msg_delay) then
      return
    end
    local cur_date_time = msg_delay:GetServerDateTime()
    local time_label = clone:Find("lbl_time")
    local deadline = client_player:QueryRecord("Origin_Kapai", row, KAPAI_REC_DEADLINE)
    if nx_double(cur_date_time) < nx_double(deadline) then
      time_label.Text = nx_widestr(format_time(nx_double(deadline) - nx_double(cur_date_time)))
    elseif nx_double(deadline) < nx_double(1) then
      time_label.Text = nx_widestr("")
    else
      time_label.Text = nx_widestr("00:01")
      nx_execute("custom_sender", "custom_kapai_msg", TIME_OUT, kapai_id)
    end
  else
    local time_label = clone:Find("lbl_time")
    time_label.Text = nx_widestr("")
  end
end
function get_rbtn_name_id(name)
  local str_list = util_split_string(name, "_")
  local num = table.maxn(str_list)
  return nx_int(str_list[num])
end
function show_main_form()
  local form = nx_value("form_stage_main\\form_origin\\form_kapai")
  if not nx_is_valid(form) then
    return
  end
  form.kapai_main.Visible = true
  local timer = nx_value("timer_game")
  timer:Register(1000, -1, nx_current(), "refresh", form, -1, -1)
  refresh(form)
end
function hide_main_form()
  local form = nx_value("form_stage_main\\form_origin\\form_kapai")
  if not nx_is_valid(form) then
    return
  end
  form.kapai_main.Visible = false
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "refresh", form)
end
function on_server_msg(...)
  local gui = nx_value("gui")
  local type = arg[1]
  local kapai_manager = nx_value("Kapai")
  if type == CLICK_KAPAI then
    local sub_id = arg[3]
    if sub_id == nil then
      return
    end
    local form = nx_value("form_stage_main\\form_origin\\form_kapai")
    if not nx_is_valid(form) then
      return
    end
    nx_execute("form_stage_main\\form_origin\\form_sub_kapai", "set_sub_kapai_info", arg[2], arg[3], arg[4], arg[5], arg[6])
    local condition_val = {}
    for i = 7, table.maxn(arg) do
      table.insert(condition_val, arg[i])
    end
    nx_execute("form_stage_main\\form_origin\\form_sub_kapai", "set_condition_val", unpack(condition_val))
    if not lock_loading_syn() then
      return
    end
    local form_sub = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_origin\\form_sub_kapai", true, false)
    if not nx_is_valid(form_sub) then
      release_loading_syn()
      return
    end
    hide_main_form()
    local is_load = form:Add(form_sub)
    if is_load == true then
      form_sub.Left = form.kapai_main.Left
      form_sub.Top = form.kapai_main.Top - 1
    end
    form_sub.Visible = true
    release_loading_syn()
  elseif type == GET_PRESTIGE then
    local sub_form = nx_value("form_stage_main\\form_origin\\form_sub_kapai")
    if not nx_is_valid(sub_form) then
      return
    end
    local arg_cnt = table.getn(arg)
    if nx_int(arg_cnt) == nx_int(2) then
      nx_execute("form_stage_main\\form_origin\\form_sub_kapai", "set_sub_deadline", arg[2])
    end
    sub_form.btn_get_prestige.Enabled = false
    sub_form.btn_get_reward.Enabled = true
    sub_form.btn_close_kapai.Enabled = false
    sub_form.mltbox_state.HtmlText = gui.TextManager:GetText("ui_prestige_got")
    nx_execute("form_stage_main\\form_origin\\form_sub_kapai", "update_time", sub_form)
  elseif type == GET_PRIZE then
    local sub_form = nx_value("form_stage_main\\form_origin\\form_sub_kapai")
    if not nx_is_valid(sub_form) then
      return
    end
    if arg[4] == 0 then
      sub_form.btn_get_reward.Enabled = false
    end
    nx_execute("form_stage_main\\form_origin\\form_sub_kapai", "update_reward_list", sub_form)
  elseif type == CLOSE_KAPAI then
    local form = nx_value("form_stage_main\\form_origin\\form_kapai")
    if not nx_is_valid(form) then
      return
    end
    show_main_form()
    local sub_form = nx_value("form_stage_main\\form_origin\\form_sub_kapai")
    if not nx_is_valid(sub_form) then
      return
    end
    nx_execute("form_stage_main\\form_origin\\form_sub_kapai", "on_main_form_close", sub_form)
  elseif type == TIME_OUT then
    local form = nx_value("form_stage_main\\form_origin\\form_kapai")
    if not nx_is_valid(form) then
      return
    end
    refresh(form)
  elseif type == TOTAL_NUM then
    nx_execute("form_stage_main\\form_origin\\form_sub_kapai", "set_sub_cur", arg[2])
    local sub_form = nx_value("form_stage_main\\form_origin\\form_sub_kapai")
    if not nx_is_valid(sub_form) then
      return
    end
    nx_execute("form_stage_main\\form_origin\\form_sub_kapai", "update_time", sub_form)
  elseif type == CHECK_CONDITION then
    nx_execute("form_stage_main\\form_relation\\form_world_city_kapai_trace", "refreash_trace_condition", unpack(arg))
  end
end
function refresh(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local row = client_player:GetRecordRows("Origin_Kapai")
  for i = 0, row - 1 do
    local type_id = client_player:QueryRecord("Origin_Kapai", i, KAPAI_REC_TYPE)
    if nx_int(type_id) == nx_int(form.kapai_type) then
      local kapai_id = client_player:QueryRecord("Origin_Kapai", i, KAPAI_REC_ID)
      local main = form:Find("kapai_main")
      local kapai = form.kapai_main:Find("groupbox_kapai" .. nx_string(kapai_id))
      fresh_groupbox_kapai(kapai, nx_int(kapai_id))
    end
  end
end
function init_kapai_para(id)
  local form = nx_value("form_stage_main\\form_origin\\form_kapai")
  if not nx_is_valid(form) then
    return
  end
  local src = form.groupbox_template:Find("groupbox_kapai_" .. nx_string(id))
  if not nx_is_valid(src) then
    return
  end
  kapai_para[id] = {}
  kapai_para[id].groupbox_kapai = {}
  kapai_para[id].groupbox_kapai.Width = src.Width
  kapai_para[id].groupbox_kapai.Height = src.Height
  local temp = src:Find("lbl_time_" .. nx_string(id))
  if not nx_is_valid(temp) then
    return
  end
  kapai_para[id].lbl_time = {}
  kapai_para[id].lbl_time.Width = temp.Width
  kapai_para[id].lbl_time.Height = temp.Height
  kapai_para[id].lbl_time.Left = temp.Left
  kapai_para[id].lbl_time.Top = temp.Top
  local temp = src:Find("btn_kapai_" .. nx_string(id))
  if not nx_is_valid(temp) then
    return
  end
  kapai_para[id].btn_kapai = {}
  kapai_para[id].btn_kapai.Width = temp.Width
  kapai_para[id].btn_kapai.Height = temp.Height
  kapai_para[id].btn_kapai.Left = temp.Left
  kapai_para[id].btn_kapai.Top = temp.Top
  local temp = src:Find("mltbox_state_" .. nx_string(id))
  if not nx_is_valid(temp) then
    return
  end
  kapai_para[id].mltbox_state = {}
  kapai_para[id].mltbox_state.Width = temp.Width
  kapai_para[id].mltbox_state.Height = temp.Height
  kapai_para[id].mltbox_state.Left = temp.Left
  kapai_para[id].mltbox_state.Top = temp.Top
end
function lock_loading_syn()
  local form = nx_value("form_stage_main\\form_origin\\form_kapai")
  if not nx_is_valid(form) then
    return false
  end
  form.form_loading_syn = true
  return true
end
function release_loading_syn()
  local form = nx_value("form_stage_main\\form_origin\\form_kapai")
  if not nx_is_valid(form) then
    return false
  end
  form.form_loading_syn = nil
  return true
end
function on_btn_yueli_click(btn)
  nx_execute("form_stage_main\\form_role_info\\form_role_info", "auto_show_hide_role_info")
  local form_info = nx_value("form_stage_main\\form_role_info\\form_role_info")
  if nx_is_valid(form_info) then
    form_info.rbtn_2.Checked = true
    nx_execute("form_stage_main\\form_role_info\\form_role_info", "on_rbtn_info_click", form_info.rbtn_2)
  end
end
function set_jianghu_yueli(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local karma_exp = client_player:QueryRecord("KarmaExpRec", 0, 0)
  if nx_number(karma_exp) <= nx_number(0) then
    form.mlt_yueli.Visible = false
    return
  end
  local txt = ""
  local gui = nx_value("gui")
  if nx_number(karma_exp) >= nx_number(0) and nx_number(karma_exp) <= nx_number(1799) then
    txt = gui.TextManager:GetText("KarmaExp_1")
  elseif nx_number(karma_exp) >= nx_number(1800) and nx_number(karma_exp) <= nx_number(10799) then
    txt = gui.TextManager:GetText("KarmaExp_2")
  elseif nx_number(karma_exp) >= nx_number(10800) and nx_number(karma_exp) <= nx_number(36719) then
    txt = gui.TextManager:GetText("KarmaExp_3")
  elseif nx_number(karma_exp) >= nx_number(36720) and nx_number(karma_exp) <= nx_number(88559) then
    txt = gui.TextManager:GetText("KarmaExp_4")
  elseif nx_number(karma_exp) >= nx_number(88560) and nx_number(karma_exp) <= nx_number(174959) then
    txt = gui.TextManager:GetText("KarmaExp_5")
  elseif nx_number(karma_exp) >= nx_number(174960) and nx_number(karma_exp) <= nx_number(329399) then
    txt = gui.TextManager:GetText("KarmaExp_6")
  elseif nx_number(karma_exp) >= nx_number(329400) and nx_number(karma_exp) <= nx_number(588599) then
    txt = gui.TextManager:GetText("KarmaExp_7")
  elseif nx_number(karma_exp) >= nx_number(588600) and nx_number(karma_exp) <= nx_number(1020599) then
    txt = gui.TextManager:GetText("KarmaExp_8")
  elseif nx_number(karma_exp) >= nx_number(1020600) then
    txt = gui.TextManager:GetText("KarmaExp_9")
  end
  form.mlt_yueli.HtmlText = txt
end
function on_btn_prize_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) or not nx_find_custom(form, "kapai_type") then
    return
  end
  local prize_form = nx_value("form_stage_main\\form_origin\\form_kapai_drop")
  if nx_is_valid(prize_form) then
    prize_form:Close()
  else
    nx_execute("form_stage_main\\form_origin\\form_kapai_drop", "open_form", form.kapai_type)
  end
end
function on_rec_change(form, recordname, optype, row, col)
  if not nx_is_valid(form) or not nx_find_custom(form, "kapai_type") then
    return
  end
  if nx_string(optype) ~= nx_string("add") and nx_string(optype) ~= nx_string("update") then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "update_kapai_number", form)
    timer:Register(500, 1, nx_current(), "update_kapai_number", form, -1, -1)
  end
end
function update_kapai_number(form)
  if not nx_is_valid(form) or not nx_find_custom(form, "kapai_type") then
    return
  end
  local kapai_type = form.kapai_type
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local record_name = "rec_kapai_daily_max"
  local cur_num = 0
  local max_num = 0
  local row = client_player:FindRecordRow(record_name, 0, nx_number(kapai_type))
  if nx_number(row) < nx_number(0) then
    local ini = get_ini("share\\Karma\\kapai_prize_limit.ini")
    local sec_index = ini:FindSectionIndex(nx_string(kapai_type))
    if nx_number(sec_index) >= nx_number(0) then
      local item_index = ini:FindSectionItemIndex(sec_index, "DailyMax")
      if nx_number(item_index) >= nx_number(0) then
        max_num = ini:GetSectionItemValue(sec_index, item_index)
      end
    end
  else
    max_num = nx_number(client_player:QueryRecord(record_name, row, 2))
    local rec_date = nx_int(client_player:QueryRecord(record_name, row, 3))
    local now = 0
    local msg_delay = nx_value("MessageDelay")
    if nx_is_valid(msg_delay) then
      now = msg_delay:GetServerDateTime()
    end
    if nx_int(rec_date) < nx_int(now) then
      cur_num = 0
    else
      cur_num = nx_number(client_player:QueryRecord(record_name, row, 1))
    end
  end
  local txt = nx_string(cur_num) .. " / " .. nx_string(max_num)
  form.mltbox_num:Clear()
  if nx_number(cur_num) == nx_number(max_num) then
    form.mltbox_num.TextColor = "255,255,0,0"
  else
    form.mltbox_num.TextColor = "255,0,255,0"
  end
  form.mltbox_num:AddHtmlText(nx_widestr(txt), -1)
end
function on_update_PrestigeExp(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
    return
  end
  if nx_number(prop_value) >= nx_number(0) then
    form.mltbox_prestigeexp.HtmlText = nx_widestr(prop_value)
  end
end
function is_open_degree_kapai()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return false
  end
  return switch_manager:CheckSwitchEnable(ST_FUNCTION_KAPAI)
end
