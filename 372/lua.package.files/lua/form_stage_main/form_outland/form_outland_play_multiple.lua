require("util_gui")
require("util_functions")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_outland\\form_outland_play_multiple"
local FILE_INI = "ini\\form_outland\\play_multiple.ini"
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local outland_play_multiple = get_ini(FILE_INI, true)
  if not nx_is_valid(outland_play_multiple) then
    return
  end
  form.play_multiple_ini = outland_play_multiple
  local count = outland_play_multiple:GetSectionCount()
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
  local lbl_title_group = form.groupbox_6
  if not nx_is_valid(lbl_title_group) then
    return
  end
  local lbl_title_list = lbl_title_group:GetChildControlList()
  for i, lbl in ipairs(lbl_title_list) do
    local index = nx_int(lbl.DataSource)
    local text_out = outland_play_multiple:ReadString(index - 1, "desc_text_out", "")
    lbl.Text = gui.TextManager:GetText(text_out)
    if i <= count then
      lbl.Visible = true
    else
      lbl.Visible = false
    end
  end
  form.rewards = ""
  form.camp_a_score_today = 0
  form.camp_a_socre_week = 0
  form.camp_b_score_today = 0
  form.camp_b_socre_week = 0
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
  if not nx_find_custom(form, "play_multiple_ini") then
    return
  end
  local play_multiple_ini = form.play_multiple_ini
  if not nx_is_valid(play_multiple_ini) then
    return
  end
  local sec_index = play_multiple_ini:FindSectionIndex(nx_string(index))
  if nx_int(sec_index) < nx_int(0) then
    return
  end
  local name = play_multiple_ini:ReadString(sec_index, "name", "")
  local pic = play_multiple_ini:ReadString(sec_index, "pic", "")
  local content = play_multiple_ini:ReadString(sec_index, "desc_content", "")
  local desc_reward_normal = play_multiple_ini:ReadString(sec_index, "desc_reward_normal", "")
  local reward_normal = play_multiple_ini:ReadString(sec_index, "reward_normal", "")
  form.pic_1.Image = pic
  form.mltbox_1.HtmlText = gui.TextManager:GetText(content)
  form.mltbox_2.HtmlText = gui.TextManager:GetText(desc_reward_normal)
  show_reward(reward_normal)
  query_war_msg()
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
function on_rbtn_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "play_multiple_ini") then
    return
  end
  local play_multiple_ini = form.play_multiple_ini
  if not nx_is_valid(play_multiple_ini) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local btn_index = nx_int(btn.DataSource)
  local text_on = play_multiple_ini:ReadString(btn_index - 1, "desc_text_on", "")
  btn.Text = gui.TextManager:GetText(text_on)
end
function on_rbtn_lost_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
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
    if not nx_find_custom(form, "play_multiple_ini") then
      return
    end
    local play_multiple_ini = form.play_multiple_ini
    if not nx_is_valid(play_multiple_ini) then
      return
    end
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    local text_on = play_multiple_ini:ReadString(btn_index - 1, "desc_text_on", "")
    btn.Text = gui.TextManager:GetText(text_on)
  else
    btn.Text = ""
  end
end
function update_war_info(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local camp_a_score = arg[1]
  local camp_a_kill = arg[2]
  local camp_a_win = arg[3]
  local camp_a_goods = arg[4]
  local camp_b_score = arg[5]
  local camp_b_kill = arg[6]
  local camp_b_win = arg[7]
  local camp_b_goods = arg[8]
  local camp_a_score_today = arg[9]
  local camp_a_socre_week = arg[10]
  local camp_b_score_today = arg[11]
  local camp_b_socre_week = arg[12]
  if camp_a_score == nil or camp_b_score == nil or camp_a_kill == nil or camp_b_kill == nil or camp_a_win == nil or camp_b_win == nil or camp_a_goods == nil or camp_b_goods == nil or camp_a_score_today == nil or camp_a_socre_week == nil or camp_b_score_today == nil or camp_b_socre_week == nil then
    return
  end
  form.lbl_10.Text = nx_widestr(camp_a_score)
  form.lbl_18.Text = nx_widestr(camp_b_score)
  form.lbl_12.Text = nx_widestr(camp_a_kill)
  form.lbl_22.Text = nx_widestr(camp_b_kill)
  form.lbl_14.Text = nx_widestr(camp_a_win)
  form.lbl_23.Text = nx_widestr(camp_b_win)
  form.lbl_16.Text = nx_widestr(camp_a_goods)
  form.lbl_24.Text = nx_widestr(camp_b_goods)
  form.camp_a_score_today = camp_a_score_today
  form.camp_a_socre_week = camp_a_socre_week
  form.camp_b_score_today = camp_b_score_today
  form.camp_b_socre_week = camp_b_socre_week
end
function on_btn_score_detail_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local mouse_x, mouse_z = gui:GetCursorPosition()
  if "camp_a_score" == btn.DataSource then
    local tips = nx_widestr(gui.TextManager:GetFormatText("ui_outland_war_score_tips_0", nx_int(form.camp_a_score_today), nx_int(form.camp_a_socre_week)))
    nx_execute("tips_game", "show_text_tip", tips, mouse_x, mouse_z)
  elseif "camp_b_score" == btn.DataSource then
    local tips = nx_widestr(gui.TextManager:GetFormatText("ui_outland_war_score_tips_0", nx_int(form.camp_b_score_today), nx_int(form.camp_b_socre_week)))
    nx_execute("tips_game", "show_text_tip", tips, mouse_x, mouse_z)
  end
end
function on_btn_score_detail_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
function query_war_msg()
  nx_execute("custom_sender", "custom_outland_war", 2)
end