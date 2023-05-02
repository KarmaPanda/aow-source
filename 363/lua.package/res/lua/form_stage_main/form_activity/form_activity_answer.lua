require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("const_define")
require("util_functions")
require("util_gui")
require("tips_data")
require("define\\request_type")
QUESTION_CUSMSG_REQUEST = 0
QUESTION_CUSMSG_ACCEPT = 1
QUESTION_CUSMSG_CHOOSE = 2
QUESTION_CUSMSG_SKILL = 3
QUESTION_BACKMSG_REQUEST = 0
QUESTION_BACKMSG_ACCEPT = 1
QUESTION_BACKMSG_CHOOSE = 2
QUESTION_BACKMSG_SKILL = 3
QUESTION_BACKMSG_RANK = 4
QUESTION_BACKMSG_START = 5
QUESTION_BACKMSG_ASK = 6
QUESTION_BACKMSG_DIFF = 7
QUESTION_BACKMSG_END = 8
QUESTION_BACKMSG_START_ACCEPT = 9
QUESTION_STATUS_END = 0
QUESTION_STATUS_PERPARE = 1
QUESTION_STATUS_START = 2
QUESTION_STATUS_DIFF = 3
TimeDown_ReadQuestion = 1
TimeDown_AskQuestion = 2
local g_ask_seq = {
  1,
  2,
  3,
  4
}
local g_reward_item = {}
function main_form_init(form)
  form.Fixed = false
  form.question_count = 0
  form.timer_span = 1000
  form.ans_type = 0
  form.timer_down = 0
  form.ask_time = 0
  form.ask_seq_type = 0
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  form.result = 0
  form.lbl_right.Visible = false
  form.lbl_wrong.Visible = false
  form.lbl_delay.Visible = false
  form.ani_right.Visible = false
  form.ani_wrong.Visible = false
  form.groupbox_box.Visible = false
  form.btn_arm_phb.Visible = false
  form.btn_arm_reward.Visible = false
  form.btn_arm_right.Visible = false
  form.textgrid_1:ClearRow()
  init_grid(form.textgrid_1)
  form.lbl_point.Text = nx_widestr(nx_string(0))
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(0) == nx_int(form.ask_seq_type) then
    nx_execute("custom_sender", "custom_question", nx_int(QUESTION_CUSMSG_CHOOSE), nx_int(form.result))
  else
    nx_execute("custom_sender", "custom_question", nx_int(QUESTION_CUSMSG_CHOOSE), nx_int(g_ask_seq[form.result]))
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_rbtn_1_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not btn.Checked then
    return
  end
  form.result = 1
end
function on_rbtn_2_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not btn.Checked then
    return
  end
  form.result = 2
end
function on_rbtn_3_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not btn.Checked then
    return
  end
  form.result = 3
end
function on_rbtn_4_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not btn.Checked then
    return
  end
  form.result = 4
end
function on_ImageControlGrid_mousein_grid(grid, index)
  local item_config = grid:GetItemAddText(nx_int(index), nx_int(2))
  if nx_string(item_config) == nx_string("") or nx_string(item_config) == nx_string("nil") then
    return
  end
  local item_name, item_type
  local ItemQuery = nx_value("ItemQuery")
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(ItemQuery) or not nx_is_valid(IniManager) then
    return
  end
  local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
  if nx_string(bExist) == nx_string("true") then
    item_type = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("ItemType"))
    item_level = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Level"))
    local item_sellPrice1 = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("sellPrice1"))
    local photo = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Photo"))
    local prop_array = {}
    prop_array.ConfigID = nx_string(item_config)
    prop_array.ItemType = nx_int(item_type)
    prop_array.Level = nx_int(item_level)
    prop_array.SellPrice1 = nx_int(item_sellPrice1)
    prop_array.Photo = nx_string(photo)
    prop_array.is_static = true
    if not nx_is_valid(grid.Data) then
      grid.Data = nx_create("ArrayList")
    end
    grid.Data:ClearChild()
    for prop, value in pairs(prop_array) do
      nx_set_custom(grid.Data, prop, value)
    end
    nx_execute("tips_game", "show_goods_tip", grid.Data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
    return
  end
end
function on_ImageControlGrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function init_grid(self)
  self.ColCount = 2
  for i = 1, self.ColCount do
    self:SetColAlign(i - 1, "center")
  end
  self.HeaderColWidth = 30
  self.HeaderBackColor = "0,255,0,0"
  self.cur_editor_row = -1
  self.current_task_id = ""
  self.CanSelectRow = false
end
function question_server_msg(submsg, ...)
  if nx_int(QUESTION_BACKMSG_START_ACCEPT) == nx_int(submsg) then
    nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_item", REQUESTTYPE_ANSWER_QUESTION, "")
  end
  local join = is_join_question()
  if nx_int(join) < nx_int(0) then
    return
  end
  if nx_int(QUESTION_BACKMSG_ACCEPT) == nx_int(submsg) then
    local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
    if not nx_is_valid(form) then
      return
    end
    local count = table.getn(arg)
    local item_count = count / 2
    local item_list = nx_value("question_item_list")
    if not nx_is_valid(item_list) then
      item_list = nx_call("util_gui", "get_arraylist", "question_item_info")
      nx_set_value("question_item_list", item_list)
    end
    if not nx_is_valid(item_list) then
      return
    end
    item_list:ClearChild()
    for i = 1, item_count do
      local point = nx_int(arg[i * 2 - 1])
      local item_id = nx_string(arg[i * 2])
      local child = item_list:GetChild("index" .. nx_string(i))
      if not nx_is_valid(child) then
        child = item_list:CreateChild("index" .. nx_string(i))
        child.point = point
        child.item_id = item_id
      end
    end
  elseif nx_int(QUESTION_BACKMSG_START) == nx_int(submsg) then
    local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
    if not nx_is_valid(form) then
      return
    end
    if nx_int(QUESTION_STATUS_START) ~= nx_int(arg[1]) then
      return
    end
    local ans = {}
    local ask_seq = {
      1,
      2,
      3,
      4
    }
    ans[1] = nx_widestr(arg[3])
    ans[2] = nx_widestr(arg[4])
    ans[3] = nx_widestr(arg[5])
    ans[4] = nx_widestr(arg[6])
    local question = nx_widestr(arg[2])
    local readtime = nx_int(arg[7])
    local asktime = nx_int(arg[8])
    local wheel = nx_int(arg[9]) + 1
    local typetext = nx_widestr(arg[10])
    local point = nx_int(arg[11])
    local question_count = nx_int(arg[12]) + 1
    form.ask_seq_type = 0
    show_question(form, question, ans, ask_seq, readtime, asktime, wheel, typetext, point, question_count)
  elseif nx_int(QUESTION_BACKMSG_ASK) == nx_int(submsg) then
    local form = nx_execute("util_gui", "util_get_form", nx_current(), false, false)
    if not nx_is_valid(form) then
      return
    end
    form.btn_ok.Enabled = true
    form.ans_type = TimeDown_AskQuestion
    form.timer_down = form.ask_time
    question_timedown_started(form)
  elseif nx_int(QUESTION_BACKMSG_CHOOSE) == nx_int(submsg) then
    local form = nx_execute("util_gui", "util_get_form", nx_current(), false, false)
    if not nx_is_valid(form) then
      return
    end
    form.ani_right.Visible = false
    form.ani_wrong.Visible = false
    form.lbl_delay.Visible = false
    if nx_int(0) == nx_int(arg[1]) then
      form.ani_wrong.Visible = true
      form.ani_wrong.Loop = false
      form.ani_wrong.PlayMode = 2
      form.ani_wrong:Play()
    else
      form.ani_right.Visible = true
      form.ani_right.Loop = false
      form.ani_right.PlayMode = 2
      form.ani_right:Play()
      local point = nx_int(arg[2])
      form.lbl_point.Text = nx_widestr(nx_string(point))
      form.lbl_reward.Visible = true
    end
  elseif nx_int(QUESTION_BACKMSG_RANK) == nx_int(submsg) then
    local form = nx_execute("util_gui", "util_get_form", nx_current(), false, false)
    if not nx_is_valid(form) then
      return
    end
    local count = table.getn(arg)
    local rank_count = count / 2
    form.textgrid_1:ClearRow()
    for i = 1, rank_count do
      local name = nx_widestr(arg[i * 2 - 1])
      local point = nx_int(arg[i * 2])
      local row = form.textgrid_1:InsertRow(-1)
      form.textgrid_1:SetGridText(row, 0, nx_widestr(name))
      form.textgrid_1:SetGridText(row, 1, nx_widestr(nx_string(point)))
    end
  elseif nx_int(QUESTION_BACKMSG_END) == nx_int(submsg) then
    local form = nx_execute("util_gui", "util_get_form", nx_current(), false, false)
    if not nx_is_valid(form) then
      return
    end
    form:Close()
    local item_list = nx_value("question_item_list")
    if not nx_is_valid(item_list) then
      return
    end
    item_list:ClearChild()
    nx_destroy(item_list)
    nx_set_value("question_item_list", nx_null())
  elseif nx_int(QUESTION_BACKMSG_DIFF) == nx_int(submsg) then
    if nx_int(QUESTION_STATUS_DIFF) ~= nx_int(arg[1]) then
      return
    end
    local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
    if not nx_is_valid(form) then
      return
    end
    local ans = {}
    local ask_seq = {
      1,
      2,
      3,
      4
    }
    ans[1] = nx_widestr(arg[3])
    ans[2] = nx_widestr(arg[4])
    ans[3] = nx_widestr(arg[5])
    ans[4] = nx_widestr(arg[6])
    local question = nx_widestr(arg[2])
    local readtime = nx_int(arg[7])
    local asktime = nx_int(arg[8])
    local wheel = nx_int(arg[9]) + 1
    local typetext = nx_widestr(arg[10])
    local point = nx_int(arg[11])
    local question_count = nx_int(arg[12]) + 1
    local random1 = math.random(1, 3)
    local ask = ask_seq[4]
    ask_seq[4] = ask_seq[random1]
    ask_seq[random1] = ask
    local random2 = math.random(2, 4)
    ask = ask_seq[1]
    ask_seq[1] = ask_seq[random2]
    ask_seq[random2] = ask
    form.ask_seq_type = 1
    g_ask_seq = ask_seq
    show_question(form, question, ans, g_ask_seq, readtime, asktime, wheel, typetext, point, question_count)
  end
end
function on_update_timedown(form)
  local time = form.timer_down
  if nx_int(0) >= nx_int(time) then
    reset_question_timedown(form)
    return
  end
  form.lbl_time.Text = nx_widestr(get_format_time_text(form, time))
  form.timer_down = nx_int(time) - nx_int(1)
end
function question_timedown_started(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_timedown", form)
    timer:Register(nx_int(form.timer_span), -1, nx_current(), "on_update_timedown", form, -1, -1)
  end
end
function reset_question_timedown(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_timedown", form)
  end
  form.timer_down = 0
end
function get_format_time_text(form, time)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return ""
  end
  if nx_int(TimeDown_ReadQuestion) == nx_int(form.ans_type) then
    gui.TextManager:Format_SetIDName("ui_answer_time1")
  else
    gui.TextManager:Format_SetIDName("ui_answer_time2")
  end
  gui.TextManager:Format_AddParam(nx_int(time))
  text = gui.TextManager:Format_GetText()
  return text
end
function is_join_question()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return -1
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return -1
  end
  local joinquestion = client_player:QueryProp("JoinQuestion")
  return nx_int(joinquestion)
end
function show_question(form, question, ans, ans_seq, readtime, asktime, wheel, typetext, point, question_count)
  form.lbl_answer1.Text = nx_widestr(ans[ans_seq[1]])
  form.lbl_answer2.Text = nx_widestr(ans[ans_seq[2]])
  form.lbl_answer3.Text = nx_widestr(ans[ans_seq[3]])
  form.lbl_answer4.Text = nx_widestr(ans[ans_seq[4]])
  form.lbl_answer1.Checked = false
  form.lbl_answer2.Checked = false
  form.lbl_answer3.Checked = false
  form.lbl_answer4.Checked = false
  form.mltbox_questions.HtmlText = nx_widestr(question)
  form.question_count = question_count
  form.ans_type = TimeDown_ReadQuestion
  form.timer_down = readtime
  form.ask_time = asktime
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.TextManager:Format_SetIDName("ui_answer_head")
  gui.TextManager:Format_AddParam(nx_int(wheel))
  gui.TextManager:Format_AddParam(nx_int(question_count))
  gui.TextManager:Format_AddParam(typetext)
  local text = gui.TextManager:Format_GetText()
  form.lbl_title.Text = text
  gui.TextManager:Format_SetIDName("ui_answer_reward_point")
  gui.TextManager:Format_AddParam(nx_int(point))
  text = gui.TextManager:Format_GetText()
  form.lbl_reward.Text = text
  form.lbl_reward.Visible = false
  form.lbl_delay.Visible = false
  form.ani_right.Visible = false
  form.ani_wrong.Visible = false
  form.btn_ok.Enabled = false
  form.Visible = true
  show_item_info(form)
  form:Show()
  question_timedown_started(form)
end
function show_item(form, id, point, item_id)
  local lbl_tips, grid_item
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if nx_int(1) == nx_int(id) then
    lbl_tips = form.lbl_fir
    grid_item = form.ImageControlGrid1
    gui.TextManager:Format_SetIDName("ui_answer_reward_points_1")
  elseif nx_int(2) == nx_int(id) then
    lbl_tips = form.lbl_sec
    grid_item = form.ImageControlGrid2
    gui.TextManager:Format_SetIDName("ui_answer_reward_points_2")
  elseif nx_int(3) == nx_int(id) then
    lbl_tips = form.lbl_thi
    grid_item = form.ImageControlGrid3
    gui.TextManager:Format_SetIDName("ui_answer_reward_points_3")
  elseif nx_int(4) == nx_int(id) then
    lbl_tips = form.lbl_fou
    grid_item = form.ImageControlGrid4
    gui.TextManager:Format_SetIDName("ui_answer_reward_points_4")
  elseif nx_int(5) == nx_int(id) then
    lbl_tips = form.lbl_fif
    grid_item = form.ImageControlGrid5
    gui.TextManager:Format_SetIDName("ui_answer_reward_points_5")
  end
  gui.TextManager:Format_AddParam(nx_int(point))
  text = gui.TextManager:Format_GetText()
  if nx_is_valid(lbl_tips) then
    lbl_tips.Text = nx_widestr(text)
  end
  if nx_is_valid(grid_item) then
    set_item_info(grid_item, item_id)
  end
end
function set_item_info(ImageControlGrid, item_id)
  if not nx_is_valid(ImageControlGrid) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local bExist = ItemQuery:FindItemByConfigID(nx_string(item_id))
  if bExist then
    local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    ImageControlGrid:AddItem(nx_int(0), photo, text, 0, -1)
    ImageControlGrid:ChangeItemImageToBW(0, false)
    ImageControlGrid:SetItemAddInfo(nx_int(0), nx_int(2), nx_widestr(item_id))
  end
end
function show_item_info(form)
  local item_list = nx_value("question_item_list")
  if not nx_is_valid(item_list) then
    for i = 1, 5 do
      show_item(form, i, 0, "")
    end
    return
  end
  local child_count = item_list:GetChildCount()
  if nx_int(child_count) > nx_int(0) then
    for i = 1, child_count do
      local child = item_list:GetChildByIndex(i - 1)
      show_item(form, i, child.point, child.item_id)
    end
  else
    for i = 1, 5 do
      show_item(form, i, 0, "")
    end
  end
end
function on_btn_arm_left_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_box.Visible = true
  form.groupbox_phb.Visible = true
  form.groupbox_reward.Visible = false
  form.btn_arm_phb.Visible = true
  form.btn_arm_reward.Visible = true
  form.btn_arm_right.Visible = true
  form.btn_arm_left.Visible = false
end
function on_btn_arm_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_box.Visible = false
  form.groupbox_phb.Visible = false
  form.groupbox_reward.Visible = false
  form.btn_arm_phb.Visible = false
  form.btn_arm_reward.Visible = false
  form.btn_arm_right.Visible = false
  form.btn_arm_left.Visible = true
end
function on_btn_arm_phb_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_box.Visible = true
  form.groupbox_phb.Visible = true
  form.groupbox_reward.Visible = false
  form.btn_arm_phb.Visible = true
  form.btn_arm_reward.Visible = true
  form.btn_arm_right.Visible = true
  form.btn_arm_left.Visible = false
end
function on_btn_arm_reward_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_box.Visible = true
  form.groupbox_phb.Visible = false
  form.groupbox_reward.Visible = true
  form.btn_arm_phb.Visible = true
  form.btn_arm_reward.Visible = true
  form.btn_arm_right.Visible = true
  form.btn_arm_left.Visible = false
end
