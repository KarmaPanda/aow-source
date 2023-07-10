require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_outland\\form_outland_play_single"
local FILE_INI = "ini\\form_outland\\play_single.ini"
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local outland_play_single = get_ini(FILE_INI, true)
  if not nx_is_valid(outland_play_single) then
    return
  end
  form.play_single_ini = outland_play_single
  local count = outland_play_single:GetSectionCount()
  local rbtn_group = form.groupbox_2
  if not nx_is_valid(rbtn_group) then
    return
  end
  local child_control_list = rbtn_group:GetChildControlList()
  for i, rbtn in ipairs(child_control_list) do
    if i <= count then
      rbtn.Visible = true
    else
      rbtn.Visible = false
    end
  end
  local lbl_group = form.groupbox_5
  if not nx_is_valid(lbl_group) then
    return
  end
  local lbl_list = lbl_group:GetChildControlList()
  for i, lbl in ipairs(lbl_list) do
    local index = nx_int(lbl.DataSource)
    local condition = outland_play_single:ReadString(index - 1, "condition", "")
    if i <= count and query_condition(condition) then
      lbl.Visible = true
    else
      lbl.Visible = false
    end
  end
  local lbl_title_group = form.groupbox_6
  if not nx_is_valid(lbl_title_group) then
    return
  end
  local lbl_title_list = lbl_title_group:GetChildControlList()
  for i, lbl in ipairs(lbl_title_list) do
    local index = nx_int(lbl.DataSource)
    local text_out = outland_play_single:ReadString(index - 1, "desc_text_out", "")
    lbl.Text = gui.TextManager:GetText(text_out)
    if count >= i then
      lbl.Visible = true
    else
      lbl.Visible = false
    end
  end
  form.task_id = 0
  form.task_name = ""
  form.rewards = ""
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local parent_form = nx_value("form_stage_main\\form_outland\\form_outland_play")
  if not nx_is_valid(parent_form) then
    return
  end
  local groupbox_main = parent_form.groupbox_main
  if not nx_is_valid(groupbox_main) then
    return
  end
  groupbox_main.Visible = true
  nx_destroy(form)
end
function open_form(index)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  local parent_form = nx_value("form_stage_main\\form_outland\\form_outland_play")
  if not nx_is_valid(parent_form) then
    return
  end
  local grpbox = parent_form.groupbox_subform
  if not nx_is_valid(grpbox) then
    return
  end
  parent_form.groupbox_main.Visible = false
  grpbox:DeleteAll()
  grpbox:Add(form)
  if 1 == index then
    form.rbtn_1.Checked = true
  elseif 2 == index then
    form.rbtn_2.Checked = true
  elseif 3 == index then
    form.rbtn_3.Checked = true
  elseif 4 == index then
    form.rbtn_4.Checked = true
  end
end
function on_btn_return_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function show_info(index)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not nx_find_custom(form, "play_single_ini") then
    return
  end
  local play_single_ini = form.play_single_ini
  if not nx_is_valid(play_single_ini) then
    return
  end
  local sec_index = play_single_ini:FindSectionIndex(nx_string(index))
  if nx_int(sec_index) < nx_int(0) then
    return
  end
  local name = play_single_ini:ReadString(sec_index, "name", "")
  local condition = play_single_ini:ReadString(sec_index, "condition", "")
  local pic = play_single_ini:ReadString(sec_index, "pic", "")
  local content = play_single_ini:ReadString(sec_index, "desc_content", "")
  local desc_reward_normal = play_single_ini:ReadString(sec_index, "desc_reward_normal", "")
  local reward_normal = play_single_ini:ReadString(sec_index, "reward_normal", "")
  local desc_reward_advanced = play_single_ini:ReadString(sec_index, "desc_reward_advanced", "")
  local reward_advanced = play_single_ini:ReadString(sec_index, "reward_advanced", "")
  local text_on = play_single_ini:ReadString(sec_index, "desc_text_on", "")
  form.task_id = play_single_ini:ReadInteger(sec_index, "task_id", 0)
  form.task_name = text_on
  if nx_int(form.task_id) > nx_int(0) then
    send_msg_get_taskinfo(2, form.task_id)
  end
  form.pic_1.Image = pic
  form.mltbox_1.HtmlText = gui.TextManager:GetText(content)
  if not query_condition(condition) then
    form.mltbox_2.HtmlText = gui.TextManager:GetText(desc_reward_normal)
    show_reward(reward_normal)
  else
    form.mltbox_2.HtmlText = gui.TextManager:GetText(desc_reward_advanced)
    show_reward(reward_advanced)
  end
end
function show_reward(reward_list)
  local form = nx_value(FORM_NAME)
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
  form.rewards = reward_list
  local rewards = util_split_string(reward_list, ";")
  local photo = ""
  local grid = form.imagegrid_1
  grid:Clear()
  for i = 1, table.getn(rewards) do
    local ConfigID = rewards[i]
    photo = ItemsQuery:GetItemPropByConfigID(ConfigID, "Photo")
    grid:AddItem(i - 1, photo, util_text(ConfigID), 1, -1)
    nx_bind_script(grid, nx_current())
    nx_callback(grid, "on_mousein_grid", "on_imagegrid_mousein_grid")
    nx_callback(grid, "on_mouseout_grid", "on_imagegrid_mouseout_grid")
  end
end
function on_imagegrid_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if 3 < index then
    return
  end
  if not nx_find_custom(form, "rewards") then
    return
  end
  if form.rewards == "" then
    return
  end
  local rewards = util_split_string(form.rewards, ";")
  local ConfigID = rewards[index + 1]
  if nil ~= ConfigID then
    nx_execute("tips_game", "show_tips_by_config", ConfigID, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
  end
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function query_condition(condition)
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return false
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  if condition_manager:CanSatisfyCondition(player, player, nx_int(condition)) then
    return true
  end
  return false
end
function on_rbtn_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "play_single_ini") then
    return
  end
  local play_single_ini = form.play_single_ini
  if not nx_is_valid(play_single_ini) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local btn_index = nx_int(btn.DataSource)
  local text_on = play_single_ini:ReadString(btn_index - 1, "desc_text_on", "")
  btn.Text = gui.TextManager:GetText(text_on)
end
function on_rbtn_lost_capture(btn)
  if btn.Checked == false then
    btn.Text = ""
  end
end
function on_rbtn_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if true == btn.Checked then
    local btn_index = nx_int(btn.DataSource)
    show_info(btn_index)
    local lbl_title_group = form.groupbox_6
    if not nx_is_valid(lbl_title_group) then
      return
    end
    local lbl_title_list = lbl_title_group:GetChildControlList()
    for i, lbl in ipairs(lbl_title_list) do
      if btn_index == nx_int(lbl.DataSource) then
        lbl.ForeColor = "255,255,204,0"
      else
        lbl.ForeColor = "255,255,255,255"
      end
    end
    if not nx_find_custom(form, "play_single_ini") then
      return
    end
    local play_single_ini = form.play_single_ini
    if not nx_is_valid(play_single_ini) then
      return
    end
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    local text_on = play_single_ini:ReadString(btn_index - 1, "desc_text_on", "")
    btn.Text = gui.TextManager:GetText(text_on)
  else
    btn.Text = ""
  end
end
function show_task_price(_price)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local price = nx_int(_price)
  if nx_int(price) < nx_int(0) then
    form.lbl_ding.Text = ""
    form.lbl_liang.Text = ""
    form.lbl_wen.Text = ""
    return
  end
  local price_ding = nx_int64(price / 1000000)
  local temp = nx_int64(price - price_ding * 1000000)
  local price_liang = nx_int64(temp / 1000)
  local price_wen = nx_int64(temp - price_liang * 1000)
  form.lbl_ding.Text = nx_widestr(price_ding)
  form.lbl_liang.Text = nx_widestr(price_liang)
  form.lbl_wen.Text = nx_widestr(price_wen)
end
function on_btn_task_finish_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if nx_int(form.task_id) <= nx_int(0) then
    return
  end
  local task_name = util_text(form.task_name)
  local text = nx_widestr(gui.TextManager:GetFormatText("ui_outland_single_ok_tips", nx_int(form.lbl_ding.Text), nx_int(form.lbl_liang.Text), nx_int(form.lbl_wen.Text), nx_widestr(task_name)))
  if not ShowTipDialog(nx_widestr(text)) then
    return
  end
  if nx_is_valid(form) then
    nx_execute("custom_sender", "send_task_msg", nx_int(12), nx_int(form.task_id))
  end
end
function on_msg_received(msg_type, ...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local sub_type = arg[1]
  local task_id = arg[2]
  local current_times = arg[3]
  local max_times = arg[4]
  local money = arg[5]
  if msg_type == "round_task_msg" and nx_int(sub_type) == nx_int(2) then
    if current_times >= max_times then
      form.btn_task_finish.Enabled = false
      form.btn_task_finish.Text = gui.TextManager:GetText("ui_taskfinish")
    else
      form.btn_task_finish.Enabled = true
      form.btn_task_finish.Text = gui.TextManager:GetText("ui_onekeyfinish")
    end
    show_task_price(money)
  end
end
function send_msg_get_taskinfo(sub_type, task_id)
  if nx_int(task_id) <= nx_int(0) then
    return
  end
  nx_execute("custom_sender", "custom_send_query_round_task", nx_int(sub_type), nx_int(task_id))
end
