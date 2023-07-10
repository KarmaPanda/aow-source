require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
col_item_config = 1
col_item_count = 2
col_subtype = 3
col_count = 3
grid_count = 5
server_custom_msg_open = 0
server_custom_msg_close = 1
local FORM = "form_stage_main\\form_home\\form_home_farm"
local CLIENT_CUSTOMMSG_HOME_FARM = 263
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2 + (gui.Height - form.Height) / 4
  form.npc_type = 0
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function on_server(sub_msg, ...)
  if nx_int(sub_msg) == nx_int(server_custom_msg_open) then
    local home_farm = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_home\\form_home_farm", true, false)
    home_farm:Show()
    local form = nx_value(FORM)
    if not nx_is_valid(form) then
      return
    end
    clear_imagegrid(form)
    form.npc_type = nx_int(arg[1])
    table.remove(arg, 1)
    refresh_form(form, unpack(arg))
  elseif nx_int(sub_msg) == nx_int(server_custom_msg_close) then
    local form = nx_value(FORM)
    if not nx_is_valid(form) then
      return
    end
    form:Close()
  end
end
function clear_imagegrid(form)
  for i = 1, grid_count do
    local child_name = string.format("%s_%s", nx_string("groupbox"), nx_string(i))
    local box = form:Find(child_name)
    if nx_is_valid(box) then
      child_name = string.format("%s_%s", nx_string("imagegrid"), nx_string(i))
      local imagegrid = box:Find(child_name)
      if nx_is_valid(imagegrid) then
        imagegrid:Clear()
      end
      child_name = string.format("%s_%s", nx_string("btn"), nx_string(i))
      local btn = box:Find(child_name)
      if nx_is_valid(btn) then
        util_remove_custom(btn, "subtype")
      end
    end
  end
end
function refresh_form(form, ...)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local size = nx_number(table.getn(arg)) / nx_number(col_count)
  for i = 1, size do
    local config = nx_string(arg[(i - 1) * col_count + col_item_config])
    local count = nx_int(arg[(i - 1) * col_count + col_item_count])
    local subtype = nx_int(arg[(i - 1) * col_count + col_subtype])
    local child_name = string.format("%s_%s", nx_string("groupbox"), nx_string(i))
    local box = form:Find(child_name)
    if nx_is_valid(box) then
      child_name = string.format("%s_%s", nx_string("imagegrid"), nx_string(i))
      local imagegrid = box:Find(child_name)
      if nx_is_valid(imagegrid) then
        local photo = ItemQuery:GetItemPropByConfigID(config, "Photo")
        imagegrid:AddItem(0, photo, nx_widestr(config), count, 0)
      end
      child_name = string.format("%s_%s", nx_string("btn"), nx_string(i))
      local btn = box:Find(child_name)
      if nx_is_valid(btn) then
        btn.subtype = subtype
      end
    end
  end
end
function on_imagegrid_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_mouseout_grid(grid, index)
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
function on_btn_click(btn)
  if not nx_find_custom(btn, "subtype") then
    return
  end
  local form = btn.ParentForm
  nx_execute("custom_sender", "custom_send_home_farm", nx_int(CLIENT_CUSTOMMSG_HOME_FARM), nx_int(0), nx_int(form.npc_type), nx_int(btn.subtype))
end
