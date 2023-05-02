require("util_gui")
local LEITI_ITEM_INTEGRAL_REWARD_INFO_REC = "leiti_item_integral_reward_info_rec"
local LEITI_INTEGRAL_REWARD_ITEM_TYPE = 2
local SHOW_INTEGRAL_ITEM_MAX = 2
local LEITAI_REWARD_NUM_MAX = 20
function main_form_init(self)
  self.select_grid = nil
  self.cur_page = 1
  self.page_max = 0
  self.exchange_type = 1
  return 1
end
function on_main_form_open(self)
  nx_execute("custom_sender", "custom_send_leitai_integral_num")
  nx_execute("custom_sender", "custom_send_leitai_integral_info")
  self.rbtn_free_obtain.Checked = true
  local game_timer = nx_value("timer_game")
  game_timer:Register(1000, -1, nx_current(), "on_leitai_integral_reward_change", self, -1, -1)
end
function on_leitai_integral_reward_change(self)
  local leitai_reward_manager = nx_value("leitai_reward_manager")
  if not nx_is_valid(leitai_reward_manager) then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_leitai\\form_leitai_reward", true)
  local integral_reward_item_list = leitai_reward_manager:GetRewardItemInfo(LEITI_INTEGRAL_REWARD_ITEM_TYPE)
  local rows = nx_int(0)
  if integral_reward_item_list ~= nil then
    rows = table.getn(integral_reward_item_list) / 2
  end
  clear_leitai_integral_reward(self)
  local control_index = 0
  local begin_index = (self.cur_page - 1) * SHOW_INTEGRAL_ITEM_MAX
  self.page_max = nx_execute("form_stage_main\\form_leitai\\form_leitai_reward", "get_max_page_num", self, rows, SHOW_INTEGRAL_ITEM_MAX)
  show_page(self)
  local list_index = 0
  for index = nx_number(begin_index), rows - 1 do
    if nx_int(control_index) < nx_int(SHOW_INTEGRAL_ITEM_MAX) then
      list_index = index * 2 + 1
      local item_index = integral_reward_item_list[list_index]
      local item_id = integral_reward_item_list[list_index + 1]
      control_index = control_index + 1
      local integral_reward_item_info = leitai_reward_manager:GetRangingRewardItemInfo(nx_int(item_index))
      local item_num = nx_int(integral_reward_item_info[2])
      local leitai_integral = 0
      local money_limit = 0
      if nx_int(self.exchange_type) == nx_int(1) then
        leitai_integral = nx_int(integral_reward_item_info[3])
        money_limit = nx_int(0)
      elseif nx_int(self.exchange_type) == nx_int(2) then
        leitai_integral = nx_int(integral_reward_item_info[5])
        money_limit = nx_int(integral_reward_item_info[4])
      end
      init_leitai_integral_reward(self, control_index, item_id, item_num, item_index, leitai_integral, money_limit)
    else
      return
    end
  end
end
function clear_leitai_integral_reward(self)
  local from = self.ParentForm
  for i = 1, SHOW_INTEGRAL_ITEM_MAX do
    local group_root_control = from:Find("groupbox_1")
    local group_control = group_root_control:Find("groupbox_item_" .. i)
    local imagecontrol = group_control:Find("ImageControlGrid" .. i)
    if nx_is_valid(imagecontrol) then
      imagecontrol:Clear()
    end
    local item_title_control = group_control:Find("lbl_item_title_" .. i)
    item_title_control.Text = nx_widestr("")
    local integral_control = group_control:Find("lbl_integral_" .. i)
    integral_control.Text = nx_widestr("")
    local integral_control = group_control:Find("lbl_money_" .. i)
    integral_control.Text = nx_widestr("")
  end
end
function init_leitai_integral_reward(self, control_index, item_id, item_num, item_index, leitai_integral, money_limit)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return 0
  end
  local group_root_control = form:Find("groupbox_1")
  local group_control = group_root_control:Find("groupbox_item_" .. nx_string(control_index))
  local imagecontrol = group_control:Find("ImageControlGrid" .. control_index)
  local photo = ItemQuery:GetItemPropByConfigID(nx_string(item_id), "Photo")
  local item_name = gui.TextManager:GetText(nx_string(item_id))
  local item_title_control = group_control:Find("lbl_item_title_" .. control_index)
  item_title_control.Text = nx_widestr(item_name)
  local leitai_integral_control = group_control:Find("lbl_integral_" .. control_index)
  local leitai_integral_limit_text = gui.TextManager:GetFormatText("ui_leitai_integral_num", leitai_integral)
  leitai_integral_control.Text = nx_widestr(leitai_integral_limit_text)
  local leitai_money_icon = group_control:Find("lbl_money_icon_" .. control_index)
  if nx_int(money_limit) > nx_int(0) then
    leitai_money_icon.Visible = true
    local leitai_money_control = group_control:Find("lbl_money_" .. control_index)
    local text = gui.TextManager:GetFormatText("ui_ge")
    leitai_money_control.Text = nx_widestr(money_limit) .. nx_widestr(text)
  else
    leitai_money_icon.Visible = false
  end
  imagecontrol:AddItem(nx_int(0), nx_string(photo), nx_widestr(item_id), nx_int(item_num), nx_int(item_index))
end
function on_btn_begin_page_click(btn)
  local form = btn.ParentForm
  if nx_int(form.cur_page) > nx_int(1) then
    form.cur_page = form.cur_page - 1
    on_leitai_integral_reward_change(form)
  end
  show_page(form)
end
function on_btn_next_page_click(btn)
  local form = btn.ParentForm
  if nx_number(form.cur_page) < nx_number(form.page_max) then
    form.cur_page = form.cur_page + 1
    on_leitai_integral_reward_change(form)
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
function on_rbtn_obtain_checked_changed(btn)
  local form = btn.ParentForm
  local data_source = 0
  if btn.Checked then
    if form.exchange_type ~= btn.DataSource then
      on_leitai_integral_reward_change(form)
    end
    form.exchange_type = btn.DataSource
  end
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
function set_leitai_reward_num(self, reward_num)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local remain_reward_num = 0
  if nx_int(reward_num) <= nx_int(-1) then
    reward_num = 0
  end
  remain_reward_num = nx_int(LEITAI_REWARD_NUM_MAX) - nx_int(reward_num)
  local text = gui.TextManager:GetFormatText("ui_leitai_remain_reward_num", nx_int(remain_reward_num))
  form.lbl_reward_num.Text = nx_widestr(text)
end
function set_leitai_integral_info(self, integral_info)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if nx_int(integral_info) <= nx_int(-1) then
    integral_info = 0
  end
  local text = gui.TextManager:GetFormatText("ui_leitai_integral_num", nx_int(integral_info))
  form.lbl_integral.Text = nx_widestr(text)
end
