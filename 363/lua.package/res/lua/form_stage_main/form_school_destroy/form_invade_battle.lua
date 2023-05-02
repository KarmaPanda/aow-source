require("util_gui")
require("util_functions")
require("util_static_data")
local FORM_NAME = "form_stage_main\\form_school_destroy\\form_invade_battle"
local school_table = {
  [5] = "ui_jinyiwei",
  [6] = "ui_gaibang",
  [7] = "ui_junzitang",
  [8] = "ui_jilegu",
  [9] = "ui_tangmen",
  [10] = "ui_emei",
  [11] = "ui_wudang",
  [12] = "ui_shaolin"
}
local school_desc = {
  [5] = "ui_school_destory_test1",
  [6] = "ui_school_destory_test2",
  [7] = "ui_school_destory_test3",
  [8] = "ui_school_destory_test4",
  [9] = "ui_school_destory_test5",
  [10] = "ui_school_destory_test6",
  [11] = "ui_school_destory_test7",
  [12] = "ui_school_destory_test8"
}
local defence_desc = {
  "ui_school_destroy_fight_1",
  "ui_school_destroy_fight_2",
  "ui_school_destroy_fight_3",
  "ui_school_destroy_fight_4",
  "ui_school_destroy_fight_5"
}
local MAX_FREQUENCE = 1
function main_form_init(form)
  form.Fixed = true
  form.last_time = -1
  form.current_id = -1
  form.first_id = -1
  form.school_id = -1
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  form.refresh_time = 0
  show_invade_info(form)
  form.rbtn_break.Enabled = false
  form.btn_reward.Enabled = false
  form.btn_enter.Enabled = false
  form.lbl_3.Visible = false
  form.lbl_4.Visible = false
  nx_execute("custom_sender", "custom_protect_school_step")
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "update_time", form)
  end
  nx_destroy(form)
end
function open_form()
  local form = util_get_form(FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return nx_null()
  end
  return form
end
function show_invade_info(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local invade_ini = get_ini("ini\\school_destroy\\school_invade.ini")
  if not nx_is_valid(invade_ini) then
    return
  end
  local invade_count = invade_ini:GetSectionCount()
  form.first_id = invade_ini:GetSectionByIndex(0)
  form.groupscrollbox_invade:DeleteAll()
  for i = 1, invade_count do
    local rbtn = gui:Create("RadioButton")
    if not nx_is_valid(rbtn) then
      return
    end
    local invade_id = invade_ini:GetSectionByIndex(i - 1)
    local invade_rule = invade_ini:ReadString(i - 1, "Rule", "")
    local invade_desc = invade_ini:ReadString(i - 1, "Desc", "")
    local invade_reward = invade_ini:ReadString(i - 1, "RewardItemID", "")
    rbtn.invade_id = invade_id
    rbtn.Name = "rbtn_" .. nx_string(invade_id)
    rbtn.invade_rule = invade_rule
    rbtn.invade_desc = invade_desc
    rbtn.invade_reward = invade_reward
    rbtn.Text = util_text("ui_school_destory_" .. i)
    rbtn.NormalImage = "gui\\special\\school_destroy\\list1_out.png"
    rbtn.FocusImage = "gui\\special\\school_destroy\\list1_on.png"
    rbtn.PushImage = "gui\\special\\school_destroy\\list1_down.png"
    rbtn.DrawMode = "ExpandH"
    rbtn.NormalColor = "255,197,184,159"
    rbtn.FocusColor = "255,255,255,255"
    rbtn.PushColor = "255,255,255,255"
    rbtn.Height = 47
    rbtn.Width = 328
    rbtn.Left = 0
    rbtn.Top = 47 * (i - 1)
    rbtn.Font = "font_text"
    nx_bind_script(rbtn, nx_current())
    nx_callback(rbtn, "on_checked_changed", "on_rbtn_select_checked_changed")
    form.groupscrollbox_invade:Add(rbtn)
  end
end
function show_step_info(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local destroy_ini = get_ini("ini\\school_destroy\\school_destroy.ini")
  if not nx_is_valid(destroy_ini) then
    return
  end
  local destroy_reward = destroy_ini:ReadString(0, "RewardItemID", "")
  local grid = form.imagegrid_2
  grid:Clear()
  local gift_lst = util_split_string(destroy_reward, ",")
  if 0 >= table.getn(gift_lst) then
    return
  end
  local index = 0
  local photo = ""
  for _, item_id in ipairs(gift_lst) do
    photo = item_query_ArtPack_by_id(item_id, "Photo")
    grid:AddItem(index, photo, nx_widestr(item_id), 1, -1)
    grid:CoverItem(index, true)
    index = index + 1
  end
  local argnum = table.getn(arg)
  if argnum < 2 then
    return
  end
  local step = nx_number(arg[2])
  if step < 0 then
    return
  end
  local SchoolExtinct = nx_value("SchoolExtinct")
  if not nx_is_valid(SchoolExtinct) then
    return nx_null()
  end
  local ExtinctedStep = SchoolExtinct:GetCurrentDeitalStage()
  local ExtinctedSchoolID = SchoolExtinct:GetExtinctSchool()
  if ExtinctedSchoolID ~= "" then
    form.rbtn_break.Enabled = true
    form.lbl_3.Visible = false
    form.lbl_4.Visible = false
  elseif ExtinctedStep == 0 then
    form.rbtn_break.Enabled = false
    form.lbl_3.Visible = true
    form.lbl_4.Visible = false
  elseif ExtinctedStep == 1 then
    form.rbtn_break.Enabled = true
    form.lbl_3.Visible = false
    form.lbl_4.Visible = false
  elseif ExtinctedStep == 2 then
    form.rbtn_break.Enabled = true
    form.lbl_3.Visible = false
    form.lbl_4.Visible = true
  elseif step == 0 then
    form.rbtn_break.Enabled = false
    form.lbl_3.Visible = true
    form.lbl_4.Visible = false
  else
    form.rbtn_break.Enabled = true
    form.lbl_3.Visible = false
    form.lbl_4.Visible = true
  end
  local score = nx_number(arg[1])
  form.lbl_score.Text = nx_widestr(score)
  local is_ready = nx_number(arg[3])
  if is_ready == 0 and 0 < score and step == 2 then
    form.btn_reward.Enabled = true
  else
    form.btn_reward.Enabled = false
  end
  form.groupscrollbox_break:DeleteAll()
  for i = 1, (argnum - 3) / 2 do
    local rbtn = gui:Create("RadioButton")
    if not nx_is_valid(rbtn) then
      return
    end
    local school_id = arg[2 * (i + 1)]
    if school_id < 5 or 12 < school_id then
      return
    end
    local school_text = gui.TextManager:GetText(school_table[school_id])
    local school_desc = gui.TextManager:GetText(school_desc[school_id])
    rbtn.school_id = school_id
    rbtn.school_desc = school_desc
    local school_step = nx_number(arg[(i + 1) * 2 + 1])
    if school_step < 0 or 4 < school_step then
      school_step = 0
    end
    local defence_text = gui.TextManager:GetText(defence_desc[school_step + 1])
    rbtn.Text = nx_widestr(school_text .. nx_widestr("(") .. defence_text .. nx_widestr(")"))
    rbtn.Name = "rbtn_break_" .. nx_string(i)
    rbtn.NormalImage = "gui\\special\\school_destroy\\list2_out.png"
    rbtn.FocusImage = "gui\\special\\school_destroy\\list2_on.png"
    rbtn.PushImage = "gui\\special\\school_destroy\\list2_down.png"
    rbtn.DrawMode = "ExpandH"
    rbtn.NormalColor = "255,197,184,159"
    rbtn.FocusColor = "255,255,255,255"
    rbtn.PushColor = "255,255,255,255"
    rbtn.Height = 34
    rbtn.Width = 322
    rbtn.Left = 0
    rbtn.Top = 34 * (i - 1)
    rbtn.Font = "font_text"
    rbtn.school_step = school_step
    nx_bind_script(rbtn, nx_current())
    nx_callback(rbtn, "on_checked_changed", "on_rbtn_break_select_checked_changed")
    form.groupscrollbox_break:Add(rbtn)
  end
  local rbtn_first = form.groupscrollbox_break:Find("rbtn_break_1")
  if nx_is_valid(rbtn_first) then
    rbtn_first.Checked = true
  else
    return
  end
end
function on_btn_reward_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_protect_school_reward")
  form.btn_reward.Enabled = false
  nx_execute("custom_sender", "custom_protect_school_step")
end
function on_btn_rank_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_rank\\form_rank_main")
  local rang_form = nx_value("form_stage_main\\form_rank\\form_rank_main")
  if not nx_is_valid(rang_form) then
    return
  end
  nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", rang_form, "rank_mmzw_defense")
end
function on_rbtn_break_select_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.gb_desc.Visible = true
  form.school_id = nx_number(rbtn.school_id)
  local school_step = rbtn.school_step
  if school_step == 1 or school_step == 2 then
    form.btn_enter.Enabled = true
  else
    form.btn_enter.Enabled = false
  end
  form.mltbox_desc:Clear()
  form.mltbox_desc.HtmlText = rbtn.school_desc
  nx_execute("custom_sender", "custom_protect_school_time", rbtn.school_id)
end
function show_leavetime_info(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  local last_time = arg[2]
  if nx_number(last_time) > 0 then
    form.last_time = last_time
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "update_time", form)
      timer:Register(1000, -1, nx_current(), "update_time", form, -1, -1)
      update_time(form)
    end
  else
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "update_time", form)
    end
    form.lbl_time.Text = nx_widestr(0) .. nx_widestr(util_text("ui_hour")) .. nx_widestr(0) .. nx_widestr(util_text("ui_minute")) .. nx_widestr(0) .. nx_widestr(util_text("ui_second"))
  end
end
function update_time(form)
  if not nx_is_valid(form) then
    return
  end
  form.last_time = form.last_time - 1
  local minute = form.last_time / 60
  local hour = minute / 60
  minute = nx_int(minute % 60)
  hour = nx_int(hour % 24)
  local second = form.last_time - minute * 60 - hour * 60 * 60
  local timer = nx_value(GAME_TIMER)
  if not nx_is_valid(timer) then
    return
  end
  if nx_int(form.last_time) < nx_int(1) then
    form.lbl_time.Text = nx_widestr(0) .. nx_widestr(util_text("ui_hour")) .. nx_widestr(0) .. nx_widestr(util_text("ui_minute")) .. nx_widestr(0) .. nx_widestr(util_text("ui_second"))
    timer:UnRegister(nx_current(), "update_time", form)
  else
    timer:Register(1000, -1, nx_current(), "update_time", form, -1, -1)
    form.lbl_time.Text = nx_widestr(nx_int(hour)) .. nx_widestr(util_text("ui_hour")) .. nx_widestr(nx_int(minute)) .. nx_widestr(util_text("ui_minute")) .. nx_widestr(nx_int(second)) .. nx_widestr(util_text("ui_second"))
  end
end
function on_rbtn_select_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  update_selected_info(form, rbtn.invade_id)
end
function update_selected_info(form, invade_id)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ItemsQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemsQuery) then
    return
  end
  local rbtn = form.groupscrollbox_invade:Find("rbtn_" .. nx_string(invade_id))
  if not nx_is_valid(rbtn) then
    return
  end
  form.current_id = rbtn.invade_id
  form.mltbox_3:Clear()
  form.mltbox_4:Clear()
  form.mltbox_3.HtmlText = gui.TextManager:GetFormatText(rbtn.invade_rule)
  form.mltbox_4.HtmlText = gui.TextManager:GetFormatText(rbtn.invade_desc)
  local gift_id = rbtn.invade_reward
  local grid = form.imagegrid_1
  grid:Clear()
  local str_lst = util_split_string(gift_id, ",")
  if table.getn(str_lst) <= 0 then
    return
  end
  local index = 0
  local photo = ""
  for _, item_id in ipairs(str_lst) do
    photo = item_query_ArtPack_by_id(item_id, "Photo")
    grid:AddItem(index, photo, nx_widestr(item_id), 1, -1)
    grid:CoverItem(index, true)
    index = index + 1
  end
end
function on_imagegrid_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local x, y = gui:GetCursorPosition()
  local item_id = grid:GetItemName(index)
  if item_id == nx_widestr("") then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", item_id, x, y, form)
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_rbtn_rule_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    form.groupbox_invade.Visible = false
    form.groupbox_break.Visible = false
    form.groupbox_rule.Visible = true
  end
end
function on_rbtn_invade_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    form.groupbox_invade.Visible = true
    form.groupbox_break.Visible = false
    form.groupbox_rule.Visible = false
    update_selected_info(form, form.first_id)
  end
end
function on_rbtn_break_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    form.groupbox_invade.Visible = false
    form.groupbox_break.Visible = true
    form.groupbox_rule.Visible = false
  end
  nx_execute("custom_sender", "custom_protect_school_step")
end
function on_btn_enter_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local school_id = form.school_id
  nx_execute("custom_sender", "custom_protect_school_enter", school_id)
end
function on_btn_refresh_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "refresh_time") then
    return
  end
  local old_time = form.refresh_time
  local new_time = os.time()
  if new_time - old_time <= MAX_FREQUENCE then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("sns_new_05"), 2)
    end
    return
  end
  form.refresh_time = new_time
  nx_execute("custom_sender", "custom_protect_school_step")
end
