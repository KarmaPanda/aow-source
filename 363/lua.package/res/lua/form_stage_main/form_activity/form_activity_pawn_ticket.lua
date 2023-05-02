require("util_gui")
require("util_functions")
local CLIENT_CUSTOMMSG_ACTIVITY_MANAGE = 182
local CLIENT_SUBMSG_REQUEST_CONTRIBUTE_LIST = 17
local CLIENT_SUBMSG_REQUEST_CONTRIBUTE = 18
local FORM_NAME = "form_stage_main\\form_activity\\form_activity_pawn_ticket"
function on_main_form_init(form)
  if not nx_is_valid(form) then
    return
  end
  form.Fixed = false
  form.contribute_type = 0
  form.prop_id = ""
  return 1
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  clear_grid(form)
  send_info_list(form)
  form.grid_info:SetColTitle(0, nx_widestr(util_text("ui_activity_rank")))
  form.grid_info:SetColTitle(1, nx_widestr(util_text("ui_activity_name")))
  form.grid_info:SetColTitle(2, nx_widestr(util_text("ui_activity_count")))
  form.grid_sta:SetColTitle(0, nx_widestr(util_text("ui_activity_rank")))
  form.grid_sta:SetColTitle(1, nx_widestr(util_text("ui_activity_name")))
  form.grid_sta:SetColTitle(2, nx_widestr(util_text("ui_activity_sum")))
  form.mltbox_1:AddHtmlText(gui.TextManager:GetFormatText("contribute_activity_info_" .. nx_string(form.contribute_type)), -1)
  form.ini_pawn = get_ini("share\\Activity\\pawn_ticket.ini", true)
  return
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function on_main_form_close(form)
  nx_destroy(form)
  return
end
function get_contribute_list(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local count = #arg
  if count < 4 then
    return
  end
  local day_count = nx_int(arg[2])
  if nx_int(day_count) <= nx_int(0) then
    day_count = nx_int(0)
  end
  form.lbl_18.Text = nx_widestr(day_count)
  form.lbl_4.Text = nx_widestr(arg[3])
  form.prop_id = nx_string(arg[4])
  show_prop_image(form)
  local grid_count = count - 4
  local playerInfoSize = 2
  if grid_count < playerInfoSize or math.mod(grid_count, playerInfoSize) ~= 0 then
    return
  end
  for i = 1, grid_count / playerInfoSize do
    local row = form.grid_info:InsertRow(-1)
    form.grid_info:SetGridText(row, 0, nx_widestr(i))
    form.grid_info:SetGridText(row, 1, nx_widestr(arg[i * playerInfoSize + 3]))
    form.grid_info:SetGridText(row, 2, nx_widestr(arg[i * playerInfoSize + 4]))
  end
end
function get_contribute_sta_list(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local playerInfoSize = 2
  local count = #arg - 1
  if playerInfoSize > count or math.mod(count, playerInfoSize) ~= 0 then
    return
  end
  local grid = form.grid_sta
  grid:BeginUpdate()
  grid:ClearRow()
  for i = 1, count / playerInfoSize do
    local row = form.grid_sta:InsertRow(-1)
    grid:SetGridText(row, 0, nx_widestr(i))
    grid:SetGridText(row, 1, nx_widestr(arg[i * playerInfoSize]))
    grid:SetGridText(row, 2, nx_widestr(arg[i * playerInfoSize + 1]))
  end
  grid:EndUpdate()
end
function send_info_list(form)
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_MANAGE), nx_int(CLIENT_SUBMSG_REQUEST_CONTRIBUTE_LIST), nx_int(form.contribute_type))
end
function send_contribute(number)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_MANAGE), nx_int(CLIENT_SUBMSG_REQUEST_CONTRIBUTE), nx_int(form.contribute_type), nx_int(number))
end
function clear_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.grid_info
  grid:BeginUpdate()
  grid:ClearRow()
  grid:EndUpdate()
  form.grid_sta:BeginUpdate()
  form.grid_sta:ClearRow()
  form.grid_sta:EndUpdate()
end
function on_btn_contribute_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local number = form.number_text.Text
  if nx_number(number) <= nx_number(0) then
    return
  end
  if not nx_find_custom(form, "ini_pawn") then
    return
  end
  local ini_pawn = form.ini_pawn
  if not nx_is_valid(ini_pawn) then
    return
  end
  local section = ini_pawn:FindSectionIndex("1026")
  if section < 0 then
    return
  end
  local max_count = ini_pawn:ReadInteger(section, "nMaxContributeCount", 0)
  if nx_number(number) > nx_number(max_count) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("1000218"), 2)
    end
    return
  end
  if not show_confirm_info("1000217", nx_string(form.prop_id), nx_int(number)) then
    return
  end
  send_contribute(number)
  form:Close()
end
function on_imagegrid_prop_mousein_grid(grid, index)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  showitemtips(grid, nx_string(form.prop_id))
end
function on_imagegrid_prop_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function showitemtips(grid, item_config)
  if nx_string(item_config) == nx_string("") or nx_string(item_config) == nx_string("nil") then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
  if nx_string(bExist) == nx_string("true") then
    local photo = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Photo"))
    local prop_array = {}
    prop_array.ConfigID = nx_string(item_config)
    prop_array.is_static = true
    if not nx_is_valid(grid.Data) then
      grid.Data = nx_create("ArrayList")
    end
    grid.Data:ClearChild()
    for prop, value in pairs(prop_array) do
      nx_set_custom(grid.Data, prop, value)
    end
    nx_execute("tips_game", "show_goods_tip", grid.Data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
    return
  end
end
function show_prop_image(form)
  if not nx_is_valid(form) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  local photo = ItemQuery:GetItemPropByConfigID(nx_string(form.prop_id), nx_string("Photo"))
  if photo == "" then
    return
  end
  form.imagegrid_prop:AddItem(nx_int(0), nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
end
function show_confirm_info(tip, ...)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if nx_is_valid(dialog) then
    dialog.mltbox_info.HtmlText = nx_widestr(format_info(tip, unpack(arg)))
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res ~= "ok" then
      return false
    end
  end
  return true
end
function format_info(strid, ...)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return strid
  end
  gui.TextManager:Format_SetIDName(strid)
  for i, v in ipairs(arg) do
    gui.TextManager:Format_AddParam(v)
  end
  return gui.TextManager:Format_GetText()
end
