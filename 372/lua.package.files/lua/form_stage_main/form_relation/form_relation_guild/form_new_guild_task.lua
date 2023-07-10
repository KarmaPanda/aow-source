require("util_functions")
require("util_gui")
require("form_stage_main\\form_task\\form_task_main")
require("form_stage_main\\form_task\\task_define")
require("form_stage_main\\form_agree_war\\form_agree_war_main")
local FORM_PATH = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_task"
local CLIENT_MSG_OPEN_GUILD_PRAY = 1
local CLIENT_MSG_ACCEPT_LUCK_TASK = 3
local CLIENT_MSG_SUBMIT_LUCK_TASK = 4
local DATA_COL_NUM = 4
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(form)
  nx_execute("custom_sender", "custom_guild_luck_pray", nx_int(CLIENT_MSG_OPEN_GUILD_PRAY))
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function show_guild_luck_task(...)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  if table.getn(arg) < 1 then
    return
  end
  local table_task_info = util_split_string(nx_string(arg[1]), ";")
  local count = table.getn(table_task_info)
  if count <= 0 or (count - 1) % 9 ~= 0 then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local TaskManager = nx_value("TaskManager")
  if not nx_is_valid(TaskManager) then
    return
  end
  form.groupscrollbox_task.IsEditMode = true
  form.groupscrollbox_task:DeleteAll()
  for i = 1, count - 1, 9 do
    local task_id = table_task_info[i]
    local luck_value = table_task_info[i + 1]
    local task_scene = table_task_info[i + 2]
    local state = table_task_info[i + 3]
    local cur_pr = table_task_info[i + 4]
    local max_pr = table_task_info[i + 5]
    local title = table_task_info[i + 6]
    local context = table_task_info[i + 7]
    local prize = table_task_info[i + 8]
    local groupbox_one = create_ctrl("GroupBox", "groupbox_reward_" .. nx_string(task_id), form.groupbox_reward, form.groupscrollbox_task)
    if nx_is_valid(groupbox_one) then
      local cbtn_task_select = create_ctrl("CheckButton", "cbtn_task_select_" .. nx_string(task_id), form.cbtn_task_select, groupbox_one)
      if not nx_is_valid(cbtn_task_select) then
        return
      end
      nx_bind_script(cbtn_task_select, nx_current())
      nx_callback(cbtn_task_select, "on_checked_changed", "on_cbtn_task_checked_changed")
      groupbox_one.Height = cbtn_task_select.Height + 2
      local btn_task_get = create_ctrl("Button", "btn_task_get_" .. nx_string(task_id), form.btn_task_get, groupbox_one)
      if not nx_is_valid(btn_task_get) then
        return
      end
      btn_task_get.task_id = task_id
      btn_task_get.task_state = state
      btn_task_get.task_scene = task_scene
      nx_bind_script(btn_task_get, nx_current())
      nx_callback(btn_task_get, "on_click", "on_btn_task_get_click")
      local lbl_task_name = create_ctrl("Label", "lbl_task_name_" .. nx_string(task_id), form.lbl_task_name, groupbox_one)
      if not nx_is_valid(lbl_task_name) then
        return
      end
      local lbl_task_pr = create_ctrl("Label", "lbl_task_pr_" .. nx_string(task_id), form.lbl_task_pr, groupbox_one)
      if not nx_is_valid(lbl_task_pr) then
        return
      end
      local lbl_task_desc = create_ctrl("Label", "lbl_task_desc_" .. nx_string(task_id), form.lbl_task_desc, groupbox_one)
      if not nx_is_valid(lbl_task_desc) then
        return
      end
      local lbl_task_luck = create_ctrl("Label", "lbl_task_luck_" .. nx_string(task_id), form.lbl_task_luck, groupbox_one)
      if not nx_is_valid(lbl_task_luck) then
        return
      end
      local lbl_task_luck_value = create_ctrl("Label", "lbl_task_luck_value_" .. nx_string(task_id), form.lbl_task_luck_value, groupbox_one)
      if not nx_is_valid(lbl_task_luck_value) then
        return
      end
      local imagegrid_task = create_ctrl("ImageGrid", "imagegrid_task_" .. nx_string(task_id), form.imagegrid_task, groupbox_one)
      if not nx_is_valid(imagegrid_task) then
        return
      end
      imagegrid_task:Clear()
      nx_bind_script(imagegrid_task, nx_current())
      nx_callback(imagegrid_task, "on_mousein_grid", "on_imagegrid_task_mousein_grid")
      nx_callback(imagegrid_task, "on_mouseout_grid", "on_imagegrid_task_mouseout_grid")
      local mltbox_desc = create_ctrl("MultiTextBox", "mltbox_desc_" .. nx_string(task_id), form.mltbox_desc, groupbox_one)
      if not nx_is_valid(mltbox_desc) then
        return
      end
      state_task_btn(btn_task_get, state)
      show_tesk_reward(imagegrid_task, prize)
      lbl_task_name.Text = gui.TextManager:GetText(title)
      lbl_task_pr.Text = nx_widestr(nx_string(cur_pr) .. "/" .. nx_string(max_pr))
      mltbox_desc.HtmlText = gui.TextManager:GetText(context)
      lbl_task_luck_value.Text = nx_widestr(luck_value)
    end
  end
  form.groupscrollbox_task.IsEditMode = false
  form.groupscrollbox_task:ResetChildrenYPos()
end
function state_task_btn(btn, state)
  if not nx_is_valid(btn) then
    return
  end
  if nx_number(state) == nx_number(0) then
    btn.Enabled = true
    btn.Text = util_text("ui_guild_task_btn_3")
  elseif nx_number(state) == nx_number(1) then
    btn.Enabled = true
    btn.Text = util_text("ui_guild_task_btn_1")
  elseif nx_number(state) == nx_number(3) then
    btn.Enabled = false
    btn.Text = util_text("ui_guild_task_btn_2")
  elseif nx_number(state) == nx_number(4) then
    btn.Enabled = false
    btn.Text = util_text("ui_guild_task_btn_4")
  else
    btn.Enabled = false
    btn.Text = util_text("ui_guild_task_btn_5")
  end
end
function show_tesk_reward(imagegrid_task, task_reward)
  if not nx_is_valid(imagegrid_task) then
    return
  end
  local table_prize_info = util_split_string(task_reward, ",")
  if nx_number(table.getn(table_prize_info)) <= nx_number(TASK_PRIZE_NUM) then
    return
  end
  local index = 0
  for i = 11, 18, 2 do
    if nx_string(table_prize_info[i]) ~= "0" then
      local id = table_prize_info[i]
      local num = table_prize_info[i + 1]
      local photo = get_icon(0, nx_string(id))
      local flag_add = imagegrid_task:AddItem(index, nx_string(photo), nx_widestr(id), nx_int(num), 0)
      if flag_add then
        index = index + 1
      end
    end
  end
end
function on_btn_task_get_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  if nx_number(btn.task_id) <= nx_number(0) then
    return
  end
  if nx_number(btn.task_state) == nx_number(0) then
    custom_guild_luck_pray(CLIENT_MSG_SUBMIT_LUCK_TASK, nx_int(btn.task_id))
  elseif nx_number(btn.task_state) == nx_number(1) then
    if nx_number(btn.task_scene) > nx_number(0) then
      local res = util_form_confirm("", util_format_string("ui_guildluck_chuansong"))
      if res == "ok" then
        custom_guild_luck_pray(CLIENT_MSG_ACCEPT_LUCK_TASK, nx_int(btn.task_id))
      end
    else
      custom_guild_luck_pray(CLIENT_MSG_ACCEPT_LUCK_TASK, nx_int(btn.task_id))
    end
  end
end
function on_cbtn_task_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gbox = cbtn.Parent
  if not nx_is_valid(gbox) then
    return
  end
  local lbl_task_desc = form.lbl_task_desc
  if cbtn.Checked then
    gbox.Height = form.lbl_task_desc.Height + cbtn.Height + 2 + 2
    lbl_task_desc.Top = 38
    lbl_task_desc.Height = lbl_task_desc.Height
  else
    gbox.Height = cbtn.Height + 2
    lbl_task_desc.Top = 46
  end
  form.groupscrollbox_task:ResetChildrenYPos()
end
function on_imagegrid_task_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_task_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
