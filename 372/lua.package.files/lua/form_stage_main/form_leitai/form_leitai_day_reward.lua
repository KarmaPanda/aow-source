require("util_gui")
require("const_define")
require("share\\view_define")
require("form_stage_main\\form_charge_shop\\charge_shop_define")
require("share\\itemtype_define")
require("form_stage_main\\form_leitai\\form_leitai_reward")
local LEITI_ITEM_DAY_REWARD_INFO_REC = "leiti_item_day_reward_info_rec"
local LEITI_DAY_REWARD_ITEM_TYPE = 1
local SHOW_ITEM_MAX = 4
local LEITAI_REWARD_ITEM_REC = "LeitaiRewardItemRec"
function set_leitai_qiecuo_num(self, qiecuo_num)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if nx_int(qiecuo_num) <= nx_int(-1) then
    qiecuo_num = 0
  end
  form.player_qiecuo_count = nx_int(qiecuo_num)
  local text = gui.TextManager:GetFormatText("ui_qiecuo_count", nx_int(qiecuo_num))
  form.lbl_leitai_num.Text = nx_widestr(text)
end
function main_form_init(self)
  self.cur_page = 1
  self.page_max = 0
  self.select_grid = nil
  self.player_qiecuo_count = 0
  return 1
end
function on_main_form_open(self)
  nx_execute("custom_sender", "custom_send_leitai_qiecuo_num")
  on_leitai_day_reward_change(self)
  local game_timer = nx_value("timer_game")
  game_timer:Register(500, -1, nx_current(), "on_leitai_day_reward_change", self, -1, -1)
end
function on_leitai_day_reward_change(self)
  local leitai_reward_manager = nx_value("leitai_reward_manager")
  if not nx_is_valid(leitai_reward_manager) then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_leitai\\form_leitai_reward", true)
  local day_reward_item_list = leitai_reward_manager:GetRewardItemInfo(LEITI_DAY_REWARD_ITEM_TYPE)
  local rows = nx_int(0)
  if day_reward_item_list ~= nil then
    rows = table.getn(day_reward_item_list) / 2
  end
  clear_leitai_day_reward(self)
  self.page_max = nx_execute("form_stage_main\\form_leitai\\form_leitai_reward", "get_max_page_num", self, rows, SHOW_ITEM_MAX)
  local control_index = 0
  local begin_index = (self.cur_page - 1) * SHOW_ITEM_MAX
  show_page(self)
  local list_index = 0
  for index = nx_number(begin_index), rows - 1 do
    if nx_int(control_index) < nx_int(SHOW_ITEM_MAX) then
      list_index = index * 2 + 1
      local item_index = day_reward_item_list[list_index]
      local item_id = day_reward_item_list[list_index + 1]
      control_index = control_index + 1
      local day_reward_item_info = leitai_reward_manager:GetRangingRewardItemInfo(nx_int(item_index))
      local item_num = day_reward_item_info[2]
      local leitai_num = day_reward_item_info[3]
      local item_leitai_level = day_reward_item_info[4]
      init_leitai_day_reward(self, control_index, item_id, item_num, item_index, leitai_num, item_leitai_level)
    else
      return
    end
  end
end
function get_max_page_num(self, data_rows)
  local max_page_num = nx_float(data_rows / SHOW_ITEM_MAX)
  if nx_float(max_page_num) > nx_int(max_page_num) then
    max_page_num = nx_int(max_page_num) + 1
  elseif nx_float(max_page_num) == nx_int(max_page_num) then
  end
  return max_page_num
end
function clear_leitai_day_reward(self)
  local from = self.ParentForm
  for i = 1, SHOW_ITEM_MAX do
    local group_control = from:Find("groupbox_day_" .. i)
    local imagecontrol = group_control:Find("ImageControlGrid" .. i)
    if nx_is_valid(imagecontrol) then
      imagecontrol:Clear()
    end
    local item_title_control = group_control:Find("lbl_item_title_" .. i)
    item_title_control.Text = nx_widestr("")
    local leitai_num_control = group_control:Find("lbl_leitai_num_" .. i)
    leitai_num_control.Text = nx_widestr("")
    local leitai_state_control = group_control:Find("lbl_state_" .. i)
    leitai_state_control.Text = nx_widestr("")
  end
end
function init_leitai_day_reward(self, control_index, item_id, item_num, item_index, leitai_num, item_leitai_level)
  local from = self.ParentForm
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local group_control = from:Find("groupbox_day_" .. control_index)
  local imagecontrol = group_control:Find("ImageControlGrid" .. control_index)
  local photo = ItemQuery:GetItemPropByConfigID(nx_string(item_id), "Photo")
  local item_name = gui.TextManager:GetText(nx_string(item_id))
  local item_title_control = group_control:Find("lbl_item_title_" .. control_index)
  item_title_control.Text = nx_widestr(item_name)
  local leitai_num_control = group_control:Find("lbl_leitai_num_" .. control_index)
  local leitai_num_limit_text = gui.TextManager:GetFormatText("ui_qiecuo_count", nx_int(leitai_num))
  leitai_num_control.Text = nx_widestr(leitai_num_limit_text)
  local leitai_state_control = group_control:Find("lbl_state_" .. control_index)
  local state = check_day_reward_item_state(from, item_index, leitai_num, item_leitai_level)
  local leitai_state_limit_text = gui.TextManager:GetFormatText("ui_leitai_item_state", nx_widestr(state))
  leitai_state_control.Text = nx_widestr(leitai_state_limit_text)
  imagecontrol:AddItem(nx_int(0), nx_string(photo), nx_widestr(item_id), nx_int(item_num), nx_int(item_index))
end
function check_day_reward_item_state(self, item_index, item_leitai_num, item_leitai_level)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_widestr("")
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nx_widestr("")
  end
  local state_text = nx_widestr("")
  if not client_player:FindRecord(LEITAI_REWARD_ITEM_REC) then
    state_text = gui.TextManager:GetText("ui_leitai_item_state2")
    return nx_widestr(state_text)
  end
  local rows = client_player:GetRecordRows(LEITAI_REWARD_ITEM_REC)
  local col = client_player:GetRecordCols(LEITAI_REWARD_ITEM_REC)
  for index = 0, rows - 1 do
    local leitai_level = client_player:QueryRecord(LEITAI_REWARD_ITEM_REC, index, 0)
    local leitai_item_index = client_player:QueryRecord(LEITAI_REWARD_ITEM_REC, index, 1)
    if nx_number(leitai_level) == nx_number(item_leitai_level) then
      if nx_int(item_index) == nx_int(leitai_item_index) then
        state_text = gui.TextManager:GetText("ui_leitai_item_state1")
      else
        state_text = gui.TextManager:GetText("ui_leitai_item_state3")
      end
      return nx_widestr(state_text)
    end
  end
  if nx_number(form.player_qiecuo_count) < nx_number(item_leitai_num) then
    state_text = gui.TextManager:GetText("ui_leitai_item_state3")
    return nx_widestr(state_text)
  end
  state_text = gui.TextManager:GetText("ui_leitai_item_state2")
  return nx_widestr(state_text)
end
function on_btn_begin_page_click(btn)
  local form = btn.ParentForm
  if nx_int(form.cur_page) > nx_int(1) then
    form.cur_page = form.cur_page - 1
    on_leitai_day_reward_change(form)
  end
  show_page(form)
end
function on_btn_next_page_click(btn)
  local form = btn.ParentForm
  if nx_number(form.cur_page) < nx_number(form.page_max) then
    form.cur_page = form.cur_page + 1
    on_leitai_day_reward_change(form)
  end
  show_page(form)
end
function show_page(self)
  local form = self.ParentForm
  local page_info = nx_string(form.cur_page) .. " / " .. nx_string(form.page_max)
  form.lbl_page_num.Text = nx_widestr(page_info)
end
function on_ImageControlGrid_select_changed(grid, index)
  local form = grid.ParentForm
  if nx_is_valid(form.select_grid) then
    local item_name = form.select_grid:GetItemName(index)
    local click_item_name = grid:GetItemName(index)
    if click_item_name ~= item_name then
      form.select_grid:SetSelectItemIndex(nx_int(-1))
    end
  end
  form.select_grid = grid
end
function on_ImageControlGrid1_mousein_grid(grid, index)
  nx_execute("form_stage_main\\form_leitai\\form_leitai_reward", "show_reward_item_tips", grid, index)
end
function on_ImageControlGrid1_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
