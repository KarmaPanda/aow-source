require("util_gui")
require("util_functions")
require("custom_sender")
require("form_stage_main\\form_tvt\\define")
local FORM_NAME = "form_stage_main\\form_skyhill\\form_sanhill_success"
local max_level = 30
function open_form(...)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  form.use_time = arg[1]
  form.cur_level = arg[2]
  form.is_master = arg[3]
  table.remove(arg, 1)
  table.remove(arg, 1)
  table.remove(arg, 1)
  time_label(form.use_time)
  local count = nx_number(table.getn(arg))
  for i = 1, count do
    local config = nx_string(arg[i])
    local photo = ItemQuery:GetItemPropByConfigID(config, "Photo")
    form.imagegrid_reward:AddItem(i - 1, photo, nx_widestr(config), 1, 0)
  end
  if nx_int(form.cur_level) == nx_int(max_level) or nx_int(form.is_master) == nx_int(0) then
    form.btn_1.Visible = false
  else
    form.btn_1.Visible = true
  end
end
function time_label(total)
  local form = util_get_form(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.minute = total / 60
  form.time_1 = nx_int(form.minute) / 10
  form.time_2 = math.fmod(nx_number(form.minute), 10)
  form.second = nx_number(total) % 60
  form.time_3 = nx_int(form.second) / 10
  form.time_4 = math.fmod(nx_number(form.second), 10)
  local time_value = 0
  for i = 1, 4 do
    if i == 1 then
      time_value = nx_int(form.time_1)
    elseif i == 2 then
      time_value = nx_int(form.time_2)
    elseif i == 3 then
      time_value = nx_int(form.time_3)
    elseif i == 4 then
      time_value = nx_int(form.time_4)
    end
    time_get = "lbl_time_" .. nx_string(i)
    local time_gain = form.groupbox_1:Find(time_get)
    if not nx_is_valid(time_gain) then
      return
    end
    for j = 0, 9 do
      if time_value == nx_int(j) then
        time_gain.BackImage = "gui\\clone_new\\form_clone_award\\" .. nx_string(nx_int(j)) .. ".png"
      end
    end
  end
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  nx_execute("custom_sender", "custom_sanhill_msg", 7)
end
function on_btn_out_click(btn)
  nx_execute("custom_sender", "custom_sanhill_msg", 5)
end
function close_form()
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    form:Close()
  end
end
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Width = gui.Width
    form.Height = gui.Height
    form.groupbox_1.Width = gui.Width
    form.groupbox_1.Height = gui.Height
    form.Left = 0
    form.Top = 0
  end
  change_form_size(true)
  form.lbl_light.Visible = true
  form.groupbox_comment.Visible = false
  form.imagegrid_reward.Visible = false
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    common_execute:AddExecute("HighLight", form, nx_float(0.01), form.lbl_light, form.groupbox_comment, nx_float(0.5), nx_float(1.5), nx_current(), nx_string("execute_end"))
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_imagegrid_reward_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_reward_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function show_prize_tips(grid, index)
  local prize_id = grid:GetItemName(nx_int(index))
  local prize_count = grid:GetItemNumber(nx_int(index))
  if nx_string(prize_id) == "" or nx_number(prize_count) <= 0 then
    return
  end
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  local itemmap = nx_value("ItemQuery")
  if not nx_is_valid(itemmap) then
    return
  end
  local table_prop_name = {}
  local table_prop_value = {}
  table_prop_name = itemmap:GetItemPropNameArrayByConfigID(nx_string(prize_id))
  if 0 >= table.getn(table_prop_name) then
    return
  end
  table_prop_value.ConfigID = nx_string(prize_id)
  for count = 1, table.getn(table_prop_name) do
    local prop_name = table_prop_name[count]
    local prop_value = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string(prop_name))
    table_prop_value[prop_name] = prop_value
  end
  local staticdatamgr = nx_value("data_query_manager")
  if nx_is_valid(staticdatamgr) then
    local index = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string("ArtPack"))
    local photo = staticdatamgr:Query(nx_int(11), nx_int(index), nx_string("Photo"))
    if nx_string(photo) ~= "" and photo ~= nil then
      table_prop_value.Photo = photo
    end
  end
  if nx_is_valid(grid.Data) then
    nx_destroy(grid.Data)
  end
  grid.Data = nx_create("ArrayList", "task_grid_data")
  grid.Data:ClearChild()
  for prop, value in pairs(table_prop_value) do
    nx_set_custom(grid.Data, prop, value)
  end
  nx_set_custom(grid.Data, "is_static", true)
  nx_execute("tips_game", "show_goods_tip", grid.Data, x, y, 32, 32)
  grid.Data:ClearChild()
end
function change_form_size(isfrist)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local self = nx_value(nx_current())
  if not nx_is_valid(self) then
    return
  end
  self.Left = 0
  self.Top = 0
  self.Width = gui.Width
  self.Height = gui.Height
  self.groupbox_back.Left = 0
  self.groupbox_back.Top = 0
  self.groupbox_back.Width = gui.Width
  self.groupbox_back.Height = gui.Height
  self.groupbox_comment.Left = gui.Width / 2 - gui.Width / 14
  self.groupbox_comment.Top = (self.Height - self.groupbox_comment.Height) / 3
  self.lbl_light.Left = gui.Width / 2 - gui.Width / 14
  self.lbl_light.Top = (self.Height - self.lbl_light.Height) / 3
end
function execute_end()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form.imagegrid_reward.Visible = true
end
