require("share\\view_define")
require("utils")
require("util_gui")
require("define\\gamehand_type")
require("util_functions")
local ORDER_NEED_ITEM_TYPE_COUNT = 3
local HOME_ORDER_STATE_ORDER = 0
local HOME_ORDER_STATE_BACK = 1
local HOME_ORDER_STATE_AWARD = 2
local CLIENT_SUB_ORDER_REFRESH = 61
local CLIENT_SUB_ORDER_SEND = 62
local CLIENT_SUB_ORDER_BACK = 63
local CLIENT_SUB_ORDER_GET_AWARK = 64
local CLIENT_SUB_HOME_SPECIAL_ORDER = 72
local tab_order_item = {}
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.order_time = 0
  form.groupbox_order.Visible = false
  form.groupbox_award.Visible = false
  form.groupbox_back.Visible = false
  init_home_order(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function close_form(form)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_order_time", form)
  end
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  close_form(form)
end
function init_home_order(form)
  if not nx_is_valid(form) then
    return
  end
  local groupbox_order = form.groupbox_order_need
  if not nx_is_valid(groupbox_order) then
    return
  end
  for i = 1, ORDER_NEED_ITEM_TYPE_COUNT do
    local ImgCtlGrid = groupbox_order:Find("order_need_" .. nx_string(i))
    if nx_is_valid(ImgCtlGrid) then
      ImgCtlGrid.BackImage = ""
      ImgCtlGrid:Clear()
    end
    ImgCtlGrid = groupbox_order:Find("order_afford_" .. nx_string(i))
    if nx_is_valid(ImgCtlGrid) then
      ImgCtlGrid.BackImage = ""
      ImgCtlGrid.itemid = nil
      ImgCtlGrid.count = nil
      ImgCtlGrid.send = 0
      ImgCtlGrid:Clear()
    end
  end
  local groupbox_award = form.groupbox_award
  if not nx_is_valid(groupbox_award) then
    return
  end
  for i = 1, ORDER_NEED_ITEM_TYPE_COUNT do
    local ImgGrid = groupbox_award:Find("imagegrid_award_" .. nx_string(i))
    if nx_is_valid(ImgGrid) then
      ImgGrid.BackImage = ""
      ImgGrid:Clear()
    end
  end
  tab_order_item = {}
  form.btn_refresh.Visible = true
  form.btn_refresh.Enabled = true
  form.mltbox_refresh.Visible = false
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_HOME_SPECIAL_ORDER)
end
function open_form(...)
  if table.getn(arg) < 1 then
    return
  end
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  end
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  local order_state = arg[1]
  if order_state == HOME_ORDER_STATE_ORDER then
    form.groupbox_order.Visible = true
    init_home_order(form)
    fresh_order(form, unpack(arg))
  elseif order_state == HOME_ORDER_STATE_BACK then
    form.groupbox_back.Visible = true
    fresh_order_back(form, unpack(arg))
  elseif order_state == HOME_ORDER_STATE_AWARD then
    form.groupbox_award.Visible = true
    fresh_order_award(form, unpack(arg))
  end
end
function fresh_order(form, ...)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local data_count = table.getn(arg)
  if data_count ~= 3 * ORDER_NEED_ITEM_TYPE_COUNT + 2 then
    return
  end
  local refresh_time = arg[2]
  if 0 < refresh_time then
    form.btn_refresh.Visible = false
    form.btn_refresh.Enabled = false
    form.mltbox_refresh.Visible = true
    form.order_time = refresh_time
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_update_order_time", form)
      timer:Register(1000, -1, nx_current(), "on_update_order_time", form, -1, -1)
      on_update_order_time(form)
    end
  end
  data_count = data_count - 2
  local groupbox_order = form.groupbox_order_need
  if not nx_is_valid(groupbox_order) then
    return
  end
  local index = 2
  for i = 1, ORDER_NEED_ITEM_TYPE_COUNT do
    index = index + 1
    local item_id = arg[index]
    index = index + 1
    local item_count = arg[index]
    index = index + 1
    local ImgCtlGrid = groupbox_order:Find("order_need_" .. nx_string(i))
    if nx_is_valid(ImgCtlGrid) then
      local bExist = ItemQuery:FindItemByConfigID(item_id)
      if bExist then
        local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
        ImgCtlGrid:AddItem(nx_int(0), photo, nx_widestr("<font color=\"#000000\">" .. nx_string(item_count) .. "</font>"), 0, -1)
        ImgCtlGrid:ChangeItemImageToBW(0, false)
        ImgCtlGrid:SetItemAddInfo(nx_int(0), nx_int(1), nx_widestr(item_id))
        ImgCtlGrid:SetItemAddInfo(nx_int(0), nx_int(2), nx_widestr(item_count))
        if tab_order_item[item_id] == nil then
          tab_order_item[item_id] = 0
        end
      end
    end
    ImgCtlGrid = groupbox_order:Find("order_afford_" .. nx_string(i))
    if nx_is_valid(ImgCtlGrid) then
      ImgCtlGrid.itemid = item_id
      ImgCtlGrid.count = item_count
    end
  end
end
function fresh_order_back(form, ...)
  if table.getn(arg) < 3 then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local back_time = arg[2]
  local back_time_limit = arg[3]
  if back_time <= 0 then
    form.mltbox_1.HtmlText = nx_widestr("")
    close_form(form)
    return
  end
  form.order_time = back_time
  if 0 <= back_time_limit then
    form.btn_back.Text = nx_widestr(gui.TextManager:GetFormatText("ui_homeorder_11", nx_int(back_time_limit)))
    if back_time_limit == 0 then
      form.btn_back.Enabled = false
    end
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_order_time", form)
    timer:Register(1000, -1, nx_current(), "on_update_order_time", form, -1, -1)
    on_update_order_time(form)
  end
end
function fresh_order_award(form, ...)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local data_count = table.getn(arg)
  data_count = data_count - 1
  if data_count > ORDER_NEED_ITEM_TYPE_COUNT or data_count < 1 then
    return
  end
  local grid = form.imagegrid_award
  if not nx_is_valid(grid) then
    return
  end
  local pos_num = data_count / 2
  local pos_step = math.floor(pos_num)
  local pos_x = grid.Width / 2 - pos_num * grid.GridWidth - pos_step
  local pos_y = (grid.Height - grid.GridHeight) / 2
  local grids_pos = ""
  for i = 1, data_count do
    grids_pos = grids_pos .. nx_string(pos_x + (i - 1) * (grid.GridWidth + 1)) .. "," .. nx_string(pos_y) .. ";"
  end
  grid.GridsPos = grids_pos
  local index = 2
  local photo = ""
  for i = 1, data_count do
    local item_id = arg[index]
    if item_id ~= nil and item_id ~= "" then
      local bExist = ItemQuery:FindItemByConfigID(item_id)
      if bExist then
        photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
        grid:AddItem(i - 1, photo, nx_widestr(item_id), 1, -1)
        index = index + 1
      end
    end
  end
end
function on_btn_send_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local groupbox_order = form.groupbox_order_need
  if not nx_is_valid(groupbox_order) then
    return
  end
  if not groupbox_order.Visible then
    return
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  local can_send = 0
  local string_send = ""
  for i = 1, ORDER_NEED_ITEM_TYPE_COUNT do
    local ImgCtlGrid = groupbox_order:Find("order_afford_" .. nx_string(i))
    if nx_is_valid(ImgCtlGrid) then
      string_send = string_send .. nx_string(ImgCtlGrid.send) .. ","
      local item_id = nx_string(ImgCtlGrid:GetItemAddText(0, 1))
      if ImgCtlGrid.itemid == item_id then
        if 0 >= ImgCtlGrid.send then
          local SystemCenterInfo = nx_value("SystemCenterInfo")
          if nx_is_valid(SystemCenterInfo) then
            SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_home_order_tips_4"), 2)
          end
          return
        end
        if nx_int(goods_grid:GetItemCount(item_id)) < nx_int(ImgCtlGrid:GetItemAddText(0, 2)) then
          clear_afford_item(form)
          return
        end
      end
      if 0 < ImgCtlGrid.send then
        can_send = can_send + 1
      end
    end
  end
  if can_send <= 0 then
    return
  end
  if can_send < ORDER_NEED_ITEM_TYPE_COUNT then
    local info = util_format_string("ui_home_order_tips_6")
    local res = util_form_confirm("", info)
    if res ~= "ok" then
      return
    end
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_ORDER_SEND, nx_string(string_send))
  close_form(form)
end
function on_btn_refresh_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local groupbox_order = form.groupbox_order
  if not nx_is_valid(groupbox_order) then
    return
  end
  if not groupbox_order.Visible then
    return
  end
  if not form.btn_refresh.Enabled then
    return
  end
  local info = util_format_string("ui_home_order_tips_3")
  local res = util_form_confirm("", info)
  if res == "ok" then
    nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_ORDER_REFRESH)
  end
end
function on_btn_back_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.groupbox_back.Visible then
    return
  end
  local info = util_format_string("ui_home_order_tips_2", get_order_back_cost(form))
  local res = util_form_confirm("", info)
  if res == "ok" then
    nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_ORDER_BACK)
    close_form(form)
  end
end
function on_btn_award_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.groupbox_award.Visible then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_ORDER_GET_AWARK)
  close_form(form)
end
function on_imagegrid_award_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local x, y = gui:GetCursorPosition()
  local item_id = grid:GetItemName(index)
  if item_id == nx_widestr("") then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", item_id, x, y, form)
end
function on_imagegrid_award_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_update_order_time(form, param1, param2)
  form.order_time = nx_number(form.order_time) - 1
  if form.order_time < 0 then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_update_order_time", form)
      if form.groupbox_back.Visible then
        close_form(form)
      elseif form.groupbox_order.Visible then
        form.btn_refresh.Visible = true
        form.btn_refresh.Enabled = true
        form.mltbox_refresh.Visible = false
      end
    end
  elseif form.groupbox_back.Visible then
    form.mltbox_1.HtmlText = get_format_time_text(form.order_time, "ui_home_order_tips_1")
  elseif form.groupbox_order.Visible then
    form.mltbox_refresh.HtmlText = get_format_time_text(form.order_time, "ui_home_order_tips_5")
  end
end
function get_format_time_text(count_time, ui_text_tip)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local hour = nx_int(count_time / 3600)
  local min = nx_int(math.mod(count_time, 3600) / 60)
  local sec = nx_int(math.mod(math.mod(count_time, 3600), 60))
  local format_time = nx_widestr(gui.TextManager:GetFormatText(ui_text_tip, nx_int(hour), nx_int(min), nx_int(sec)))
  return format_time
end
function on_order_need_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local item_config = grid:GetItemAddText(index, 1)
  if nx_string(item_config) == "" then
    return
  end
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_tips_by_config", item_config, x, y, form)
end
function on_order_need_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_order_afford_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  if not gui.GameHand:IsEmpty() and gui.GameHand.Type == GHT_VIEWITEM then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local src_pos = nx_int(gui.GameHand.Para2)
    local src_amount = nx_int(gui.GameHand.Para3)
    local game_client = nx_value("game_client")
    local view = game_client:GetView(nx_string(src_viewid))
    if not nx_is_valid(view) then
      return
    end
    local viewobj = view:GetViewObj(nx_string(src_pos))
    if not nx_is_valid(viewobj) then
      return
    end
    local config_id = viewobj:QueryProp("ConfigID")
    if grid.itemid ~= config_id then
      return
    end
    local count = goods_grid:GetItemCount(config_id) - tab_order_item[config_id]
    local item_count = nx_int(grid:GetItemAddText(0, 2))
    count = count + item_count
    if count < 0 then
      count = 0
    end
    local photo1 = nx_execute("util_static_data", "queryprop_by_object", viewobj, "Photo")
    local bExist = ItemQuery:FindItemByConfigID(config_id)
    if bExist then
      local photo = ItemQuery:GetItemPropByConfigID(config_id, "Photo")
      local afford_count = 0
      local num_text = ""
      if nx_number(count) >= nx_number(grid.count) then
        num_text = "<font color=\"#00ff00\">" .. nx_string(count) .. "/" .. nx_string(grid.count) .. "</font>"
        grid:ChangeItemImageToBW(nx_int(0), false)
        grid.send = 1
        afford_count = grid.count - item_count
      else
        num_text = "<font color=\"#ff0000\">" .. nx_string(count) .. "/" .. nx_string(grid.count) .. "</font>"
        grid:ChangeItemImageToBW(nx_int(0), true)
        afford_count = count - item_count
      end
      grid:AddItem(nx_int(0), photo, nx_widestr(util_text(num_text)), 0, -1)
      grid:SetItemAddInfo(nx_int(0), nx_int(1), nx_widestr(config_id))
      grid:SetItemAddInfo(nx_int(0), nx_int(2), nx_widestr(afford_count + item_count))
      tab_order_item[config_id] = tab_order_item[config_id] + afford_count
    end
    gui.GameHand:ClearHand()
  end
end
function on_order_afford_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local item_config = grid:GetItemAddText(index, 1)
  if nx_string(item_config) == "" then
    return
  end
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_tips_by_config", item_config, x, y, form)
end
function on_order_afford_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_order_afford_rightclick_grid(grid, index)
  if not nx_is_valid(grid) then
    return
  end
  local item_config = nx_string(grid:GetItemAddText(index, 1))
  if item_config == "" then
    return
  end
  local item_count = nx_int(grid:GetItemAddText(index, 2))
  if nx_number(item_count) > nx_number(0) and nx_number(tab_order_item[item_config]) >= nx_number(item_count) then
    tab_order_item[item_config] = tab_order_item[item_config] - item_count
  end
  grid.send = 0
  grid:Clear()
end
function get_order_back_cost(form)
  if not nx_is_valid(form) then
    return 0
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Home\\HomeOutDoorOrder.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local sec_count = ini:FindSectionIndex("config")
  if sec_count < 0 then
    return 0
  end
  return ini:ReadInteger(sec_count, "order_back_cost", 10000) / 1000
end
function clear_afford_item(form)
  if not nx_is_valid(form) then
    return
  end
  local groupbox_order = form.groupbox_order_need
  if not nx_is_valid(groupbox_order) then
    return
  end
  for i = 1, ORDER_NEED_ITEM_TYPE_COUNT do
    local ImgCtlGrid = groupbox_order:Find("order_afford_" .. nx_string(i))
    if nx_is_valid(ImgCtlGrid) then
      local item_config = nx_string(ImgCtlGrid:GetItemAddText(0, 1))
      if tab_order_item[item_config] ~= nil then
        tab_order_item[item_config] = 0
      end
      ImgCtlGrid.BackImage = ""
      ImgCtlGrid.send = 0
      ImgCtlGrid:Clear()
    end
  end
end
function rec_home_order_finish_time(...)
  local form = nx_value("form_stage_main\\form_home\\form_home_order")
  if not nx_is_valid(form) then
    return
  end
  if nx_int(#arg) ~= nx_int(2) then
    return
  end
  form.lbl_17.Text = nx_widestr(arg[1])
  form.lbl_19.Text = nx_widestr(arg[2])
end
