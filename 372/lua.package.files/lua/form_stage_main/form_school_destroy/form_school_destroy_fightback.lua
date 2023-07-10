require("util_gui")
require("util_functions")
require("util_static_data")
local FILE_FIGHTBACK = "form_stage_main\\form_school_destroy\\form_school_destroy_fightback"
local INI_FIGHTBACK = "ini\\school_destroy\\form_school_destroy_fightback.ini"
function open_form()
  local form = util_get_form(FILE_FIGHTBACK, true, false)
  if not nx_is_valid(form) then
    return nx_null()
  end
  nx_execute("custom_sender", "custom_school_counter_attack_data", 4)
  return form
end
function on_fightback_server_msg(...)
  local form = nx_value(FILE_FIGHTBACK)
  if nx_is_valid(form) then
    form.i_fightback_state = nx_number(arg[1])
    form.i_fightback_val = nx_int(arg[2])
    form.i_finish_countdown = nx_int64(arg[3])
    if nx_number(form.i_finish_countdown) > 0 then
      form.b_can_join_scene = true
    else
      form.b_can_join_scene = false
    end
    form.i_reward_countdown = nx_int64(arg[4])
    refresh_fightback_countdown()
    refresh_menpai_highlight(form)
    refresh_fightback_state_highlight(form)
  end
end
function main_form_init(form)
  form.Fixed = true
  form.rbtn_default_2 = nil
  form.rbtn_default_3 = nil
  form.rbtn_default_4 = nil
  form.rbtn_default_5 = nil
  form.i_fightback_val = nx_int(0)
  form.i_finish_countdown = nx_int64(0)
  form.i_reward_countdown = nx_int64(0)
  form.i_fightback_state = nx_int(0)
  form.b_can_join_scene = false
  form.rbtn_cur_school = nil
end
function on_main_form_open(form)
  local ini_fightback = get_ini(INI_FIGHTBACK, true)
  if not nx_is_valid(ini_fightback) then
    return
  end
  form.ini_fightback = ini_fightback
  form.sec_count = ini_fightback:GetSectionCount()
  local SchoolExtinct = nx_value("SchoolExtinct")
  if not nx_is_valid(SchoolExtinct) then
    return
  end
  form.str_school_id = SchoolExtinct:GetExtinctSchool()
  init_info_tree(form)
  set_default_form(form)
  refresh_fightback_state_highlight(form)
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_update_fightback_timedown", form)
      timer:UnRegister(nx_current(), "on_update_reward_timedown", form)
    end
    nx_destroy(form)
  end
end
function init_info_tree(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "ini_fightback") then
    return
  end
  local ini_fightback = form.ini_fightback
  if not nx_is_valid(ini_fightback) then
    return
  end
  local gsbox_play = form.groupscrollbox_play
  local gsbox_fback = form.groupscrollbox_fightback
  local gsbox_gift = form.groupscrollbox_gift
  local gsbox_pchange = form.groupscrollbox_play_change
  local sec_count = form.sec_count
  local text_id, node_type, parent_gsbox = "", 0
  gsbox_play.Visible = true
  gsbox_fback.Visible = true
  gsbox_gift.Visible = true
  gsbox_pchange.Visible = true
  gsbox_play.IsEditMode = true
  gsbox_play:DeleteAll()
  gsbox_fback.IsEditMode = true
  gsbox_fback:DeleteAll()
  gsbox_gift.IsEditMode = true
  gsbox_gift:DeleteAll()
  gsbox_pchange.IsEditMode = true
  gsbox_pchange:DeleteAll()
  for i = 1, sec_count do
    node_type = ini_fightback:ReadInteger(i - 1, "SubFormIndex", 0)
    if node_type == 2 then
      parent_gsbox = gsbox_play
    elseif node_type == 3 then
      parent_gsbox = gsbox_fback
    elseif node_type == 4 then
      parent_gsbox = gsbox_gift
    elseif node_type == 5 then
      parent_gsbox = gsbox_pchange
    else
      parent_gsbox = nil
    end
    text_id = ini_fightback:GetSectionByIndex(i - 1)
    if text_id == "" then
      return
    end
    local rbtn = clone_control("RadioButton", "rbtn_root_" .. nx_string(i), form.rbtn_template, parent_gsbox)
    if nx_is_valid(rbtn) then
      if form.rbtn_default_2 == nil and node_type == 2 then
        form.rbtn_default_2 = rbtn
      elseif form.rbtn_default_3 == nil and node_type == 3 then
        form.rbtn_default_3 = rbtn
      elseif form.rbtn_default_4 == nil and node_type == 4 then
        form.rbtn_default_4 = rbtn
      elseif form.rbtn_default_5 == nil and node_type == 5 then
        form.rbtn_default_5 = rbtn
      end
      rbtn.Text = util_text(text_id)
      rbtn.TabIndex = i
      rbtn.Visible = true
      nx_bind_script(rbtn, nx_current())
      nx_callback(rbtn, "on_checked_changed", "on_rbtn_root_checked_changed")
      if node_type == 3 and text_id == "ui_school_destroy_" .. nx_string(form.str_school_id) then
        form.rbtn_cur_school = rbtn
      end
    end
  end
  gsbox_play.IsEditMode = false
  gsbox_play:ResetChildrenYPos()
  gsbox_fback.IsEditMode = false
  gsbox_fback:ResetChildrenYPos()
  gsbox_gift.IsEditMode = false
  gsbox_gift:ResetChildrenYPos()
  gsbox_pchange.IsEditMode = false
  gsbox_pchange:ResetChildrenYPos()
  local lbl = clone_control("Label", "lbl_flash", form.lbl_template, form.groupbox_stage)
  if nx_is_valid(lbl) then
    lbl.Visible = false
  end
end
function on_rbtn_root_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local select_index = nx_number(rbtn.TabIndex)
  local desc = get_fightback_ini_prop(form, select_index - 1, "Desc")
  local reward_id = get_fightback_ini_prop(form, select_index - 1, "RewardTextID")
  local grid
  local node_type = nx_number(get_fightback_ini_prop(form, select_index - 1, "SubFormIndex"))
  if node_type == 2 then
    form.mltbox_play_desc.HtmlText = util_text(desc)
    form.mltbox_play_reward.HtmlText = util_text(reward_id)
    grid = form.imagegrid_item
    form.pic_1.Image = get_fightback_ini_prop(form, select_index - 1, "ImagePath")
  elseif node_type == 3 then
    if nx_is_valid(form.rbtn_default_3) then
      form.rbtn_default_3.Checked = false
      form.rbtn_default_3 = rbtn
    end
    form.mltbox_stage_info.HtmlText = util_text(desc)
    return
  elseif node_type == 4 then
    form.mltbox_gift_desc.HtmlText = util_text(desc)
    form.mltbox_gift_reward.HtmlText = util_text(reward_id)
    grid = form.imagegrid_reward
  elseif node_type == 5 then
    form.mltbox_play_change_desc.HtmlText = util_text(desc)
    form.mltbox_play_change_reward.HtmlText = util_text(reward_id)
    grid = form.imagegrid_play_change
  else
    return
  end
  grid:Clear()
  local items, item_list, grid_index, photo = "", "", 0, ""
  items = get_fightback_ini_prop(form, select_index - 1, "RewardItemID")
  if items == "" then
    return
  end
  item_list = util_split_string(items, ",")
  if 0 >= table.getn(item_list) then
    return
  end
  for _, item_id in ipairs(item_list) do
    photo = item_query_ArtPack_by_id(item_id, "Photo")
    grid:AddItem(grid_index, photo, nx_widestr(item_id), 1, -1)
    grid:CoverItem(grid_index, true)
    grid_index = grid_index + 1
  end
end
function on_rbtn_subform_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.TabIndex == 1 then
    form.groupbox_desc.Visible = true
    form.groupbox_play.Visible = false
    form.groupbox_stage.Visible = false
    form.groupbox_gift.Visible = false
    form.groupbox_play_change.Visible = false
  elseif rbtn.TabIndex == 2 then
    form.groupbox_desc.Visible = false
    form.groupbox_play.Visible = true
    form.groupbox_stage.Visible = false
    form.groupbox_gift.Visible = false
    form.groupbox_play_change.Visible = false
  elseif rbtn.TabIndex == 3 then
    form.groupbox_desc.Visible = false
    form.groupbox_play.Visible = false
    form.groupbox_stage.Visible = true
    form.groupbox_gift.Visible = false
    form.groupbox_play_change.Visible = false
    if nx_find_custom(form, "b_can_join_scene") then
      form.btn_enter_scene.Enabled = form.b_can_join_scene
    else
      form.btn_enter_scene.Enabled = false
    end
  elseif rbtn.TabIndex == 4 then
    form.groupbox_desc.Visible = false
    form.groupbox_play.Visible = false
    form.groupbox_stage.Visible = false
    form.groupbox_gift.Visible = true
    form.groupbox_play_change.Visible = false
  elseif rbtn.TabIndex == 5 then
    form.groupbox_desc.Visible = false
    form.groupbox_play.Visible = false
    form.groupbox_stage.Visible = false
    form.groupbox_gift.Visible = false
    form.groupbox_play_change.Visible = true
  end
end
function on_imagegrid_reward_mousein_grid(grid, index)
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
function on_imagegrid_reward_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_btn_enter_scene_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "b_can_join_scene") then
    return
  end
  if form.b_can_join_scene then
    nx_execute("custom_sender", "custom_school_counter_attack_data", 3)
  else
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("19917"), 2)
    end
  end
end
function get_fightback_ini_prop(form, index, prop)
  if not nx_is_valid(form) then
    return ""
  end
  if not nx_find_custom(form, "ini_fightback") then
    return ""
  end
  local ini_fightback = form.ini_fightback
  if not nx_is_valid(ini_fightback) then
    return ""
  end
  local sec_count = nx_number(form.sec_count)
  local select_index = nx_number(index)
  if 0 <= select_index and sec_count > select_index then
    return ini_fightback:ReadString(select_index, nx_string(prop), "")
  end
  return ""
end
function set_default_form(form)
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_rules.Checked = true
  if nx_find_custom(form, "rbtn_default_2") and nx_is_valid(form.rbtn_default_2) then
    form.rbtn_default_2.Checked = true
  end
  if nx_find_custom(form, "rbtn_default_3") and nx_is_valid(form.rbtn_default_3) then
    form.rbtn_default_3.Checked = true
  end
  if nx_find_custom(form, "rbtn_default_4") and nx_is_valid(form.rbtn_default_4) then
    form.rbtn_default_4.Checked = true
  end
  if nx_find_custom(form, "rbtn_default_5") and nx_is_valid(form.rbtn_default_5) then
    form.rbtn_default_5.Checked = true
  end
end
function clone_control(ctrl_type, name, refer_ctrl, parent_ctrl)
  if not (nx_is_valid(refer_ctrl) and nx_is_valid(parent_ctrl)) or ctrl_type == "" or name == "" then
    return nx_null()
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  local cloned_ctrl = gui:Create(ctrl_type)
  if not nx_is_valid(cloned_ctrl) then
    return nx_null()
  end
  local prop_list = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_list) do
    nx_set_property(cloned_ctrl, prop_list[i], nx_property(refer_ctrl, prop_list[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, cloned_ctrl)
  cloned_ctrl.Name = name
  parent_ctrl:Add(cloned_ctrl)
  return cloned_ctrl
end
function refresh_fightback_countdown()
  local form = nx_value(FILE_FIGHTBACK)
  if nx_is_valid(form) then
    form.lbl_fightback.Text = nx_widestr(form.i_fightback_val)
    start_countdown(form, form.i_finish_countdown, "on_update_fightback_timedown")
    start_countdown(form, form.i_reward_countdown, "on_update_reward_timedown")
  end
end
function start_countdown(form, last_time, callback_func)
  if not nx_is_valid(form) then
    return
  end
  if nx_number(last_time) <= 0 then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), nx_string(callback_func), form)
    timer:Register(1000, -1, nx_current(), nx_string(callback_func), form, -1, -1)
  end
end
function on_update_fightback_timedown(form, param1, param2)
  form.i_finish_countdown = nx_number(form.i_finish_countdown) - 1
  if form.i_finish_countdown < 0 then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_update_fightback_timedown", form)
    end
  else
    form.lbl_countdown.Text = get_format_time_text(form.i_finish_countdown)
  end
end
function on_update_reward_timedown(form, param1, param2)
  form.i_reward_countdown = nx_number(form.i_reward_countdown) - 1
  if form.i_reward_countdown < 0 then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_update_reward_timedown", form)
    end
  else
    form.lbl_i_reward_countdown.Text = get_format_time_text(form.i_reward_countdown)
  end
end
function get_format_time_text(count_time)
  local format_time = nx_widestr("")
  if nx_number(count_time) >= 86400 then
    local day = nx_int(count_time / 86400)
    local hour = nx_int(math.mod(count_time, 86400) / 3600)
    local min = nx_int(math.mod(count_time, 3600) / 60)
    local sec = nx_int(math.mod(math.mod(count_time, 3600), 60))
    format_time = nx_widestr(day) .. util_text("ui_day") .. nx_widestr(string.format(" %02d:%02d:%02d", nx_number(hour), nx_number(min), nx_number(sec)))
  elseif nx_number(count_time) >= 3600 then
    local hour = nx_int(count_time / 3600)
    local min = nx_int(math.mod(count_time, 3600) / 60)
    local sec = nx_int(math.mod(math.mod(count_time, 3600), 60))
    format_time = nx_widestr(string.format("%02d:%02d:%02d", nx_number(hour), nx_number(min), nx_number(sec)))
  elseif nx_number(count_time) >= 60 then
    local min = nx_int(count_time / 60)
    local sec = nx_int(math.mod(count_time, 60))
    format_time = nx_widestr(string.format("00:%02d:%02d", nx_number(min), nx_number(sec)))
  else
    local sec = nx_int(count_time)
    format_time = nx_widestr(string.format("00:00:%02d", nx_number(sec)))
  end
  return format_time
end
function refresh_menpai_highlight(form)
  local rbtn = form.rbtn_cur_school
  if not nx_is_valid(rbtn) then
    return
  end
  local lbl = form.groupbox_stage:Find("lbl_flash")
  if not nx_is_valid(lbl) then
    return
  end
  local menpai_state = nx_number(form.i_fightback_state)
  if menpai_state == 1 then
    rbtn.Text = rbtn.Text .. util_text("ui_school_destory_df_in")
  elseif menpai_state == 2 then
    rbtn.Text = rbtn.Text .. util_text("ui_school_destory_df_lose")
  else
    return
  end
  lbl.Left = nx_int(rbtn.Left + (rbtn.Width - lbl.Width) / 2)
  lbl.Top = nx_int(rbtn.Top - (lbl.Height - rbtn.Height) / 2)
  lbl.Visible = true
end
function refresh_fightback_state_highlight(form)
  if not nx_is_valid(form) then
    return
  end
  local SchoolExtinct = nx_value("SchoolExtinct")
  if not nx_is_valid(SchoolExtinct) then
    return
  end
  local school_id = nx_string(SchoolExtinct:GetExtinctSchool())
  if school_id == "" then
    local rtime = nx_number(form.i_reward_countdown)
    local reward_state = nx_number(SchoolExtinct:GetCurrentDeitalStage())
    if reward_state == 1 and 0 < rtime then
      form.lbl_28.Visible = false
      form.lbl_29.Visible = false
      form.lbl_30.Visible = false
      form.lbl_31.Visible = true
    else
      form.lbl_28.Visible = false
      form.lbl_29.Visible = false
      form.lbl_30.Visible = false
      form.lbl_31.Visible = false
    end
  else
    local ftime = nx_number(form.i_finish_countdown)
    if 0 < ftime then
      form.lbl_28.Visible = false
      form.lbl_29.Visible = false
      form.lbl_30.Visible = true
      form.lbl_31.Visible = false
    else
      form.lbl_28.Visible = true
      form.lbl_29.Visible = true
      form.lbl_30.Visible = false
      form.lbl_31.Visible = false
    end
  end
end
