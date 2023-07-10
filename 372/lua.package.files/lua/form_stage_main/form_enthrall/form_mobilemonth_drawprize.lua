require("util_functions")
require("util_gui")
require("share\\client_custom_define")
SERVER_SUB_DRAW_PRIZE_OPEN = 3
SERVER_SUB_DRAW_PRIZE_INDEX = 4
MAX_ITEM_COUNT = 14
local FORM_DRAW = "form_stage_main\\form_enthrall\\form_mobilemonth_drawprize"
local index_table = {
  [1] = {4},
  [2] = {11},
  [3] = {0, 7},
  [4] = {
    2,
    9,
    12
  },
  [5] = {
    3,
    6,
    10
  },
  [6] = {
    1,
    5,
    8,
    13
  }
}
function main_form_init(self)
  self.Fixed = false
  self.Visible = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  self.groupbox_1.select_index = 0
  self.groupbox_1.cur_loop = 0
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_server_msg(sub_msg, ...)
  if nx_int(sub_msg) == nx_int(SERVER_SUB_DRAW_PRIZE_OPEN) then
    util_show_form(FORM_DRAW, true)
    local form = nx_value(FORM_DRAW)
    if not nx_is_valid(form) then
      return
    end
    local ItemQuery = nx_value("ItemQuery")
    if not nx_is_valid(ItemQuery) then
      return
    end
    form.imagegrid_1:Clear()
    local photo = ItemQuery:GetItemPropByConfigID(nx_string("box_power_redeem_fc"), "Photo")
    form.imagegrid_1:AddItem(0, photo, nx_widestr("box_power_redeem_fc"), 1, 0)
  elseif nx_int(sub_msg) == nx_int(SERVER_SUB_DRAW_PRIZE_INDEX) then
    local form = nx_value(FORM_DRAW)
    if not nx_is_valid(form) then
      return
    end
    on_play_effect(form, nx_int(arg[1]))
  end
end
function on_play_effect(form, index)
  if not nx_is_valid(form) then
    return
  end
  index = index + 1
  if nx_int(index) <= nx_int(0) or nx_int(index) > nx_int(table.getn(index_table)) then
    return
  end
  local str_index = index_table[index]
  local random_index = math.random(table.getn(str_index))
  local common_execute = nx_value("common_execute")
  if not nx_is_valid(common_execute) then
    return
  end
  if common_execute:FindExecute("MobileMonthDrawIndexMove", form.groupbox_1) then
    return
  end
  common_execute:AddExecute("MobileMonthDrawIndexMove", form.groupbox_1, nx_float(0.08), nx_int(1), nx_int(MAX_ITEM_COUNT), nx_int(str_index[random_index]), "")
end
function on_play_effect_2(result)
  local form = nx_value(FORM_DRAW)
  if not nx_is_valid(form) then
    return
  end
  local common_execute = nx_value("common_execute")
  if not nx_is_valid(common_execute) then
    return
  end
  if common_execute:FindExecute("MobileMonthDrawSlowdownMove", form.groupbox_1) then
    return
  end
  common_execute:AddExecute("MobileMonthDrawSlowdownMove", form.groupbox_1, nx_float(0.3), nx_int(result))
end
function refresh_box(index)
  local form = nx_value(FORM_DRAW)
  if not nx_is_valid(form) then
    return
  end
  local child_name = string.format("%s_%s", nx_string("rbtn"), nx_string(index))
  local item_box = form.groupbox_1:Find(child_name)
  if nx_is_valid(item_box) then
    item_box.Checked = true
  end
end
function on_btn_draw_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MOBILE_COMFIRM), 4)
end
function on_imagegrid_1_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_1_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function show_prize_tips(grid, index)
  local prize_id = grid:GetItemName(nx_int(index))
  local prize_type = grid:GetItemMark(nx_int(index))
  local prize_count = grid:GetItemNumber(nx_int(index))
  if nx_string(prize_id) == "" or nx_number(prize_count) <= 0 then
    return
  end
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  if nx_number(prize_type) == 1 then
    local tip_text = nx_widestr(util_text(nx_string(prize_id)) .. ":" .. nx_string(prize_count))
    nx_execute("tips_game", "show_text_tip", tip_text, x, y)
  elseif nx_number(prize_type) == 2 then
    local tip_text = nx_widestr(prize_id)
    nx_execute("tips_game", "show_text_tip", tip_text, x, y)
  elseif nx_number(prize_type) == 0 then
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
end
