require("util_gui")
require("util_functions")
require("tips_data")
local FORM_NAME = "form_stage_main\\form_relation\\form_relation_guild\\form_cross_station_war_award"
local rec_award = {
  [1] = "box_20180508_kfzdbz001",
  [2] = "box_20180508_kfzdbz002",
  [3] = "box_20180508_kfzdbz003",
  [4] = "box_20180508_kfzdbz004",
  [5] = "box_20180508_kfzdbz005",
  [6] = "box_20180508_kfzdbz006",
  [7] = "box_20180508_kfzdbz006",
  [8] = "box_20180508_kfzdbz006",
  [9] = "box_20180508_kfzdbz006",
  [10] = "box_20180508_kfzdbz006"
}
function open_form()
  local form = util_get_form(FORM_NAME, true)
  form:Show()
  form.Visible = true
  nx_execute("custom_sender", "custom_corss_station_war", 2)
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_update_time", self, -1, -1)
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", self)
  end
  nx_destroy(self)
end
function on_update_time(form)
  if not nx_find_custom(form.lbl_end_time, "time") then
    return
  end
  local time = form.lbl_end_time.time
  if 0 < time then
    time = time - 1
  end
  show_end_time(form.lbl_end_time, time)
end
function on_btn_close_click(btn)
  close_form()
end
function on_btn_get_click(btn)
  nx_execute("custom_sender", "custom_corss_station_war", 3)
  close_form()
end
function on_imagegrid_1_mousein_grid(grid, index)
  if not nx_find_custom(grid, "config") then
    return
  end
  local config = grid.config
  local count = grid.count
  local prop_array = {}
  prop_array.ConfigID = nx_string(config)
  prop_array.Amount = nx_int(count)
  if not nx_is_valid(grid.Data) then
    grid.Data = nx_create("ArrayList")
  end
  grid.Data:ClearChild()
  for prop, value in pairs(prop_array) do
    nx_set_custom(grid.Data, prop, value)
  end
  nx_execute("tips_game", "show_goods_tip", grid.Data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_imagegrid_1_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function update_info(...)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  local no = arg[1]
  local end_time = arg[2]
  form.lbl_no.Text = nx_widestr(no)
  form.lbl_4.BackImage = nx_string("gui\\guild\\guildwar_new\\" .. nx_string(math.floor(nx_number(no) / 10)) .. ".png")
  form.lbl_5.BackImage = nx_string("gui\\guild\\guildwar_new\\" .. nx_string(math.floor(nx_number(no) % 10)) .. ".png")
  local time = nx_number(get_remain_time(end_time))
  show_end_time(form.lbl_end_time, time)
  local item_config = rec_award[nx_number(no)]
  local color_level = nx_number(get_prop_in_ItemQuery(item_config, nx_string("ColorLevel")))
  local photo = get_prop_in_ItemQuery(item_config, nx_string("Photo"))
  form.imagegrid_1:AddItem(0, nx_string(photo), nx_widestr(item_config), nx_int(item_amount), 0)
  form.imagegrid_1.config = item_config
  form.imagegrid_1.count = item_amount
end
function show_end_time(lbl_end_time, time)
  if 0 < time then
    lbl_end_time.time = time
    lbl_end_time.Text = get_time_text(time)
  else
    lbl_end_time.Text = nx_widestr(util_text("ui_cross_station_war_001"))
  end
end
function get_remain_time(end_time)
  local now = get_sys_time()
  return nx_int((end_time - now) * 24 * 3600)
end
function get_sys_time()
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  return nx_double(msg_delay:GetServerDateTime())
end
function get_time_text(time)
  local hour = math.floor(nx_number(time) / 3600)
  local minute = math.floor(nx_number(time) % 3600 / 60)
  local second = math.floor(nx_number(time) % 60)
  local text = nx_widestr("")
  local min_str = ""
  if nx_number(minute) < 10 then
    min_str = "0" .. nx_string(minute)
  else
    min_str = nx_string(minute)
  end
  local sec_str = ""
  if nx_number(second) < 10 then
    sec_str = "0" .. nx_string(second)
  else
    sec_str = nx_string(second)
  end
  if 0 < hour then
    text = text .. nx_widestr(hour) .. nx_widestr(":") .. nx_widestr(min_str) .. nx_widestr(":") .. nx_widestr(sec_str)
  else
    text = nx_widestr(min_str) .. nx_widestr(":") .. nx_widestr(sec_str)
  end
  return text
end
