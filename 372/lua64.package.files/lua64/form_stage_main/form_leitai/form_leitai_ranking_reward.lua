require("util_gui")
require("share\\view_define")
local LEITI_ITEM_RANKING_REWARD_INFO_REC = "leiti_item_ranking_reward_info_rec"
local LEITI_RANKING_REWARD_ITEM_TYPE = 3
local ITEM_NUM_MAX = 3
local MONTH_MAX = 12
local LEITI_ITEM_RANGING_INFO_REC = "leiti_item_ranging_info_rec"
local control_left = 0
local control_top = 2
local control_width = 105
local control_height = 21
local MONTH_INFO = {
  [1] = "january",
  [2] = "february",
  [3] = "march",
  [4] = "april",
  [5] = "may",
  [6] = "june",
  [7] = "july",
  [8] = "august",
  [9] = "september",
  [10] = "october",
  [11] = "november",
  [12] = "december"
}
function main_form_init(self)
  return 1
end
function on_main_form_open(self)
  local form = self.ParentForm
  self.select_grid = nil
  self.target_npc = nil
  self.select_month = nil
  local game_timer = nx_value("timer_game")
  if game_timer then
    game_timer:Register(1000, -1, nx_current(), "on_leitai_ranking_reward_change", form, -1, -1)
  end
  on_leitai_ranking_reward_change(self)
  auto_show_month(self)
end
function on_leitai_ranking_reward_change(self, month)
  local form = self.ParentForm
  local leitai_reward_manager = nx_value("leitai_reward_manager")
  if not nx_is_valid(leitai_reward_manager) then
    return
  end
  local leitai_reward_form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_leitai\\form_leitai_reward", true)
  if not nx_is_valid(leitai_reward_form.select_target_npc) then
    return
  end
  form.target_npc = leitai_reward_form.select_target_npc
  local ranging_reward_item_list = leitai_reward_manager:GetRewardItemInfo(LEITI_RANKING_REWARD_ITEM_TYPE)
  local rows = nx_int(0)
  if ranging_reward_item_list ~= nil then
    rows = table.getn(ranging_reward_item_list) / 2
  end
  clear_leitai_ranging_reward(self)
  local list_index = 0
  for index = 0, rows - 1 do
    list_index = index * 2 + 1
    local item_index = ranging_reward_item_list[list_index]
    local item_id = ranging_reward_item_list[list_index + 1]
    local ranging_reward_item_info = leitai_reward_manager:GetRangingRewardItemInfo(nx_int(item_index))
    local item_num = nx_int(ranging_reward_item_info[2])
    local item_ranging = nx_string(ranging_reward_item_info[3])
    local item_date = nx_string(ranging_reward_item_info[4])
    if form.select_month == nil or nx_number(form.select_month) < nx_number(0) or nx_number(form.select_month) > MONTH_MAX then
      local Time = os.date("*t", os.time())
      form.select_month = nx_number(Time.month)
      local month_control = form:Find("rbtn_month_" .. nx_string(form.select_month))
      if not nx_is_valid(month_control) then
        break
      end
      month_control.Checked = true
    end
    if check_ranging_item_date(self, item_date, form.select_month) then
      update_ranging_item_show_info(self, item_ranging, item_index, item_id, item_num, item_date)
    end
  end
end
function get_item_state_info(self, item_date, ranging)
  local form = self.ParentForm
  local game_client = nx_value("game_client")
  if not nx_is_valid(form.target_npc) then
    return false, "? ? ?"
  end
  local view = game_client:GetView(nx_string(VIEWPORT_RANGING_ITEM_BOX))
  if not nx_is_valid(view) then
    return false, "? ? ?"
  end
  if not view:FindRecord(LEITI_ITEM_RANGING_INFO_REC) then
    return false, "? ? ?"
  end
  local rows = view:GetRecordRows(LEITI_ITEM_RANGING_INFO_REC)
  if nx_number(rows) < nx_number(1) then
    return false, "? ? ?"
  end
  local table_data = util_split_string(item_date, ",")
  if table.getn(table_data) ~= 2 then
    return false, "? ? ?"
  end
  local item_year = nx_number(table_data[1])
  local item_month = nx_number(table_data[2]) + nx_number(1)
  if nx_number(item_month) > nx_number(MONTH_MAX) then
    item_month = item_month - MONTH_MAX
    item_year = item_year + 1
  end
  for i = 0, rows - 1 do
    local ranging_date = view:QueryRecord(LEITI_ITEM_RANGING_INFO_REC, i, 0)
    local ranging_num = view:QueryRecord(LEITI_ITEM_RANGING_INFO_REC, i, 1)
    local player_name = view:QueryRecord(LEITI_ITEM_RANGING_INFO_REC, i, 2)
    local is_obtain = view:QueryRecord(LEITI_ITEM_RANGING_INFO_REC, i, 3)
    local year, month = nx_function("ext_decode_date", nx_double(ranging_date))
    if nx_number(year) == nx_number(item_year) and nx_number(month) == nx_number(item_month) and nx_number(ranging_num) == nx_number(ranging) then
      if nx_number(is_obtain) == nx_number(0) then
        return false, player_name
      else
        return true, player_name
      end
    end
  end
  return false, "? ? ?"
end
function update_ranging_item_show_info(self, control_index, item_index, item_id, item_num, item_date)
  local form = self.ParentForm
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return ""
  end
  local group_control = form:Find("groupbox_" .. control_index)
  local imagecontrol = group_control:Find("ImageControlGrid" .. control_index)
  if not nx_is_valid(imagecontrol) then
    return
  end
  local photo = ItemQuery:GetItemPropByConfigID(nx_string(item_id), "Photo")
  local item_name = gui.TextManager:GetText(nx_string(item_id))
  local item_name_control = group_control:Find("lbl_item_name_" .. control_index)
  if not nx_is_valid(item_name_control) then
    return
  end
  item_name_control.Text = nx_widestr(item_name)
  local state, player_name = get_item_state_info(self, item_date, control_index)
  local player_name_control = group_control:Find("lbl_player_name_" .. control_index)
  if not nx_is_valid(player_name_control) then
    return
  end
  local obtain_player = gui.TextManager:GetText("ui_lingjiangren")
  obtain_player = nx_widestr(obtain_player) .. nx_widestr(player_name)
  player_name_control.Text = nx_widestr(obtain_player)
  local state_control = group_control:Find("lbl_state_" .. control_index)
  if not nx_is_valid(state_control) then
    return
  end
  local is_obtain_info = gui.TextManager:GetText("ui_leitai_item_state2")
  if state then
    is_obtain_info = gui.TextManager:GetText("ui_leitai_item_state1")
  end
  is_obtain_info = gui.TextManager:GetFormatText("ui_leitai_item_state", nx_widestr(is_obtain_info))
  state_control.Text = nx_widestr(is_obtain_info)
  imagecontrol:AddItem(nx_int(0), nx_string(photo), nx_widestr(item_id), nx_int(item_num), nx_int(item_index))
end
function clear_leitai_ranging_reward(self)
  local form = self.ParentForm
  for i = 1, ITEM_NUM_MAX do
    local group_control = form:Find("groupbox_" .. i)
    local imagecontrol = group_control:Find("ImageControlGrid" .. i)
    if nx_is_valid(imagecontrol) then
      imagecontrol:Clear()
    end
    local item_name_control = group_control:Find("lbl_item_name_" .. i)
    item_name_control.Text = nx_widestr("")
    local palyer_name_control = group_control:Find("lbl_player_name_" .. i)
    palyer_name_control.Text = nx_widestr("")
    local state_control = group_control:Find("lbl_state_" .. i)
    state_control.Text = nx_widestr("")
  end
end
function on_ImageControlGrid_select_changed(grid, index)
  local form = grid.ParentForm
  if nx_is_valid(form.select_grid) then
    form.select_grid:SetSelectItemIndex(nx_int(-1))
  end
  form.select_grid = grid
end
function on_ImageControlGrid_mousein_grid(grid, index)
  nx_execute("form_stage_main\\form_leitai\\form_leitai_reward", "show_reward_item_tips", grid, index)
end
function on_ImageControlGrid_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_rbtn_month_checked_changed(btn)
  local form = btn.ParentForm
  local select_month = -1
  if btn.Checked then
    select_month = nx_int(btn.DataSource)
    if nx_int(select_month) >= nx_int(1) and nx_int(select_month) <= nx_int(12) then
      form.select_month = select_month
      on_leitai_ranking_reward_change(form, select_month)
    end
  end
end
function check_ranging_item_date(self, item_date, select_month)
  local Time = os.date("*t", os.time())
  local year = nx_number(Time.year)
  local month = nx_number(Time.month)
  if nx_number(select_month) > nx_number(month) then
    year = year - 1
  end
  local table_data = util_split_string(item_date, ",")
  local item_year = table_data[1]
  local item_month = table_data[2]
  if nx_int(item_year) == nx_int(year) and nx_int(item_month) == nx_int(select_month) then
    return true
  end
  return false
end
function update_month_info(self, year, month)
  local form = self.ParentForm
  local leitai_reward_manager = nx_value("leitai_reward_manager")
  if not nx_is_valid(leitai_reward_manager) then
    return
  end
  local ranging_reward_item_list = leitai_reward_manager:GetRewardItemInfo(LEITI_RANKING_REWARD_ITEM_TYPE)
  local rows = nx_int(0)
  if ranging_reward_item_list ~= nil then
    rows = table.getn(ranging_reward_item_list) / 2
  end
  local list_index = 0
  for index = 0, rows - 1 do
    list_index = index * 2 + 1
    local item_index = ranging_reward_item_list[list_index]
    local item_id = ranging_reward_item_list[list_index + 1]
    local ranging_reward_item_info = leitai_reward_manager:GetRangingRewardItemInfo(nx_int(item_index))
    local item_date = nx_string(ranging_reward_item_info[4])
    local table_data = util_split_string(item_date, ",")
    local item_year = table_data[1]
    local item_month = table_data[2]
    local all_month = (year - item_year) * MONTH_MAX + (month - item_month)
    if nx_number(all_month) >= nx_number(0) and nx_number(all_month) < MONTH_MAX then
      auto_activate_show_control(self, item_month)
    end
  end
end
function auto_activate_show_control(self, activate_month)
  local form = self.ParentForm
  local month_control = form:Find("rbtn_month_" .. nx_string(activate_month))
  if not nx_is_valid(month_control) then
    return
  end
  month_control.Enabled = true
  month_control.ForeColor = "255,255,255,255"
end
function auto_show_month(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return ""
  end
  for index = 1, MONTH_MAX do
    local month_control = form:Find("rbtn_month_" .. index)
    if month_control == nil then
      break
    end
    month_control.Enabled = false
    month_control.ForeColor = "255,50,50,50"
  end
  local Time = os.date("*t", os.time())
  local cur_year = nx_number(Time.year)
  local cur_month = nx_number(Time.month)
  for index = 1, MONTH_MAX do
    if nx_number(cur_month) < nx_number(1) then
      cur_month = cur_month + MONTH_MAX
      cur_year = nx_number(Time.year) - 1
    end
    local month_control = form:Find("rbtn_month_" .. nx_string(cur_month))
    if not nx_is_valid(month_control) then
      break
    end
    month_control.Left = 0
    month_control.Top = control_height * (index - 1) + control_top
    local month_info = gui.TextManager:GetFormatText(nx_string(MONTH_INFO[cur_month]))
    month_control.Text = nx_widestr(month_info)
    update_month_info(self, cur_year, cur_month)
    cur_month = cur_month - 1
  end
end
