require("util_gui")
require("const_define")
local LEITI_REWARD_ITEM_INFO_REC = "leiti_item_reward_info_rec"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  init_common_data(self)
  local dayrewardpage = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_leitai\\form_leitai_day_reward", true, false)
  local is_load = self.groupbox_1:Add(dayrewardpage)
  if is_load == true then
    self.dayrewardpage = dayrewardpage
    self.dayrewardpage.Left = 1
    self.dayrewardpage.Top = 0
  end
  local integralrewardpage = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_leitai\\form_leitai_integral_reward", true, false)
  local is_load = self.groupbox_1:Add(integralrewardpage)
  if is_load == true then
    self.integralrewardpage = integralrewardpage
    self.integralrewardpage.Left = 1
    self.integralrewardpage.Top = 0
  end
  local rankingrewardpage = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_leitai\\form_leitai_ranking_reward", true, false)
  local is_load = self.groupbox_1:Add(rankingrewardpage)
  if is_load == true then
    self.rankingrewardpage = rankingrewardpage
    self.rankingrewardpage.Left = 1
    self.rankingrewardpage.Top = 0
  end
  self.dayrewardpage.Visible = true
  self.integralrewardpage.Visible = false
  self.rankingrewardpage.Visible = false
end
function on_main_form_shut(self)
  local form = self.ParentForm
  if nx_is_valid(form.dayrewardpage) then
    nx_destroy(form.dayrewardpage)
  end
  if nx_is_valid(form.integralrewardpage) then
    nx_destroy(form.integralrewardpage)
  end
  if nx_is_valid(form.rankingrewardpage) then
    nx_destroy(form.rankingrewardpage)
  end
end
function init_common_data(self)
  local form = self.ParentForm
  form.rbtn_day.Checked = true
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  form.select_target_npc = game_client:GetSceneObj(nx_string(form.select_npc_id))
end
function on_main_form_close(self)
  nx_destroy(self)
  nx_set_value(nx_current(), nx_null())
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_enter_reward_click(btn)
  local form = btn.ParentForm
  local leitai_reward_manager = nx_value("leitai_reward_manager")
  if not nx_is_valid(leitai_reward_manager) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local cur_show_page_form = form.dayrewardpage
  if form.dayrewardpage.Visible then
    cur_show_page_form = form.dayrewardpage
  elseif form.integralrewardpage.Visible then
    cur_show_page_form = form.integralrewardpage
  elseif form.rankingrewardpage.Visible then
    cur_show_page_form = form.rankingrewardpage
  end
  local item_index = nx_int(-1)
  local item_id = nx_widestr("")
  local item_num = nx_int(0)
  local integral_type = nx_int(0)
  local notice_title_text = ""
  if form.dayrewardpage.Visible or form.rankingrewardpage.Visible then
    if cur_show_page_form.select_grid ~= nil then
      item_index = cur_show_page_form.select_grid:GetItemMark(0)
    end
  elseif form.integralrewardpage.Visible then
    if cur_show_page_form.select_grid ~= nil then
      item_index = cur_show_page_form.select_grid:GetItemMark(0)
    end
    integral_type = cur_show_page_form.exchange_type
  else
    return
  end
  local item_id = leitai_reward_manager:GetItemConfigID(nx_int(item_index))
  local item_name = gui.TextManager:GetText(nx_string(item_id))
  notice_title_text = gui.TextManager:GetFormatText("ui_leitai_item_Reward_enter", nx_widestr(item_name))
  if nx_int(integral_type) == nx_int(2) then
    local need_gold = leitai_reward_manager:GetItemNeedGold(nx_int(item_index))
    notice_title_text = gui.TextManager:GetFormatText("ui_leitai_integral_money_enter", nx_int(need_gold), nx_widestr(item_name))
  end
  if nx_int(item_index) > nx_int(-1) then
    show_confirm_box(form, nx_widestr(notice_title_text), nx_int(item_index), nx_int(integral_type))
  end
end
function enter_obtain_item(self)
end
function on_rbtn_day_click(self)
  local form = self.Parent
  form.dayrewardpage.Visible = true
  form.integralrewardpage.Visible = false
  form.rankingrewardpage.Visible = false
end
function on_rbtn_grade_num_click(self)
  local form = self.Parent
  form.dayrewardpage.Visible = false
  form.integralrewardpage.Visible = true
  form.rankingrewardpage.Visible = false
end
function on_rbtn_ranking_click(self)
  local form = self.Parent
  form.dayrewardpage.Visible = false
  form.integralrewardpage.Visible = false
  form.rankingrewardpage.Visible = true
end
function get_max_page_num(self, data_rows, page_have_item_num)
  local max_page_num = 1
  if data_rows == 0 then
    return max_page_num
  end
  max_page_num = nx_float(data_rows / page_have_item_num)
  if nx_float(max_page_num) > nx_int(max_page_num) then
    max_page_num = nx_int(max_page_num) + 1
  elseif nx_float(max_page_num) == nx_int(max_page_num) then
  end
  return max_page_num
end
function show_reward_item_tips(grid, index)
  local config_id = grid:GetItemName(nx_int(index))
  if nx_string(config_id) == nx_string("") then
    return
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return 0
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  if nx_is_valid(item) then
    item.ConfigID = nx_string(config_id)
    item.ItemType = ItemQuery:GetItemPropByConfigID(nx_string(item.ConfigID), "ItemType")
    nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 40, 40, grid.ParentForm)
  end
end
function show_confirm_box(self, title, item_index, integral_type)
  local form = self.ParentForm
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if nx_is_valid(dialog) then
    dialog.mltbox_info.HtmlText = nx_widestr(title)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res ~= "ok" then
      return
    end
  end
  if not check_item_index(item_index) then
    return
  end
  nx_execute("custom_sender", "custom_send_leitai_reward_info", item_index, integral_type, form.select_npc_id)
  nx_execute("form_stage_main\\form_leitai\\form_leitai_day_reward", "on_leitai_day_reward_change", form.dayrewardpage)
end
function check_item_index(item_index)
  local leitai_reward_manager = nx_value("leitai_reward_manager")
  if not nx_is_valid(leitai_reward_manager) then
    return
  end
  if leitai_reward_manager:CheckRewardItemIndex(item_index) then
    return true
  end
  return false
end
function on_btn_leitai_ranging_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_rank\\form_rank_main")
  local rang_form = nx_value("form_stage_main\\form_rank\\form_rank_main")
  if nx_is_valid(rang_form) then
    nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", rang_form, "rank_1_lt")
  end
end
