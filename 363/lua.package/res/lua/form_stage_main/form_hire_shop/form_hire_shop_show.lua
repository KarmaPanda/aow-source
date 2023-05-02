require("share\\view_define")
require("define\\gamehand_type")
require("share\\client_custom_define")
require("form_stage_main\\form_hire_shop\\form_hire_shop_price")
require("util_gui")
local SUBMSG_BUY_ITEM = 5
local SUBMSG_CLINET_GOODS_LIST = 11
local VIEWPORT_HIRESHOP = 24
local CAPITAL_TYPE_SILVER_CARD = 2
local SUBMSG_CLINET_EXPAND_CELLS = 8
local goods_table = {}
function main_form_init(form)
  form.Fixed = false
  form.npcid = nil
  form.pageno = 1
  form.max_page = 2
  form.remain_time = 0
  form.owner = ""
  form.is_online = 0
  form.target = ""
  form.ExpandCells = 0
  form.MaxCells = 0
  form.CostSilver = 0
  form.CurMaxCapacity = 0
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  form.target = game_client:GetSceneObj(nx_string(form.npcid))
  if not (nx_is_valid(gui) and nx_is_valid(game_client)) or not nx_is_valid(client_player) then
    return
  end
  local owner_name = ""
  if nx_is_valid(form.target) then
    owner_name = form.target:QueryProp("ShopOwner")
    get_max_capacity(form)
  else
    owner_name = form.owner
    refresh_page(form, form.CurMaxCapacity)
  end
  local player_name = client_player:QueryProp("Name")
  if owner_name == player_name then
    form.btn_chat.Visible = false
  else
    form.btn_chat.Visible = true
  end
  if nx_int(form.is_online) == nx_int(0) then
    form.btn_chat.Enabled = false
  else
    form.btn_chat.Enabled = true
  end
  local grid = form.icg_goods
  local count = grid.RowNum * grid.ClomnNum
  for i = 1, count do
    grid:SetBindIndex(nx_int(i - 1), nx_int(i))
  end
  grid.typeid = VIEWPORT_HIRESHOP
  grid.canselect = true
  grid.candestroy = false
  grid.cansplit = false
  grid.canlock = false
  grid.canarrange = false
  load_ini(form)
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_HIRESHOP, grid, "form_stage_main\\form_hire_shop\\form_hire_shop_show", "on_goods_view_oper")
  form.lbl_number.Text = nx_widestr(nx_string(form.pageno) .. "/" .. nx_string(form.max_page))
  is_visibled(form)
  local remain = get_format_time_text(form.remain_time)
  form.lbl_time.Text = nx_widestr(remain)
  init_timer(form.remain_time, form.npcid)
  if nx_is_valid(form) and form.npcid ~= nil then
    req_goods_list(form.npcid)
  end
  return 1
end
function on_main_form_close(form)
  goods_table = {}
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  local game_client = nx_value("game_client")
  local obj = game_client:GetSceneObj(nx_string(form.npcid))
  if nx_is_valid(obj) and nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", obj)
  end
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_hire_shop\\form_hire_shop_show", nx_null())
end
function load_ini(form)
  if not nx_is_valid(form) then
    return
  end
  local expand_ini = nx_execute("util_functions", "get_ini", "share\\Trade\\HireShopExpand.ini")
  if not nx_is_valid(expand_ini) then
    return false
  end
  local sec_index = expand_ini:FindSectionIndex("Expand")
  if sec_index < 0 then
    return
  end
  form.ExpandCells = expand_ini:ReadInteger(sec_index, "ExpandCells", 0)
  form.MaxCells = expand_ini:ReadInteger(sec_index, "MaxCells", 0)
  form.CostSilver = expand_ini:ReadInteger(sec_index, "CostSilver", 0)
end
function on_goods_view_oper(grid, op_type, view_ident, index)
  if not nx_is_valid(grid) then
    return false
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return false
  end
  local form = grid.ParentForm
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return false
  end
  if op_type == "createview" then
    do_wait_to_refresh_grid(form)
  elseif op_type == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif op_type == "additem" then
    do_wait_to_refresh_grid(form)
  elseif op_type == "delitem" then
    GoodsGrid:ViewDeleteItem(grid, index)
    goods_grid_delete_item(grid, index)
  elseif op_type == "updateitem" then
    GoodsGrid:ViewUpdateItem(grid, index)
  end
  return true
end
function goods_grid_delete_item(grid, grid_index)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  grid:CoverItem(grid_index - 1, false)
end
function do_wait_to_refresh_grid(form)
  if nx_running(nx_current(), "wait_to_refresh_grid", form) then
    nx_kill(nx_current(), "wait_to_refresh_grid", form)
  end
  nx_execute(nx_current(), "wait_to_refresh_grid", form)
end
function wait_to_refresh_grid(form)
  nx_pause(0.1)
  if not nx_is_valid(form) then
    return false
  end
  refresh_grid(form)
end
function get_max_capacity(form)
  local game_client = nx_value("game_client")
  local ident = nx_string(form.npcid)
  local npc = game_client:GetSceneObj(ident)
  if not nx_is_valid(npc) then
    return false
  end
  form.CurMaxCapacity = npc:QueryProp("MaxCapacity")
  refresh_page(form, form.CurMaxCapacity)
end
function refresh_page(form, max_capacity)
  if not nx_is_valid(form) then
    return
  end
  form.CurMaxCapacity = max_capacity
  if form.CurMaxCapacity >= form.MaxCells then
    form.btn_KuoRong.Enabled = false
  else
    form.btn_KuoRong.Enabled = true
  end
  local count = nx_int(form.icg_goods.RowNum * form.icg_goods.ClomnNum)
  local page = nx_int(form.CurMaxCapacity / count)
  if nx_int(page) > nx_int(1) then
    form.max_page = page
    form.lbl_number.Text = nx_widestr(nx_string(form.pageno) .. "/" .. nx_string(form.max_page))
  end
end
function on_icg_goods_mousein_grid(grid, index)
  local form = grid.ParentForm
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local item_data = GoodsGrid:GetItemData(grid, index)
  if nx_is_valid(item_data) then
    nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
  else
    nx_execute("tips_game", "hide_tip", grid.ParentForm)
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_HIRESHOP_ADDITEM))
  if nx_is_valid(view) then
    local bind_index = grid:GetBindIndex(index)
    local viewobj = view:GetViewObj(nx_string(bind_index))
    nx_execute("form_stage_main\\form_life\\form_job_main_new", "chang_life_skill_photo", viewobj)
  end
  if grid:IsEmpty(index) then
    return false
  end
  local item_data = grid.Data:GetChild(nx_string(index))
  if not nx_is_valid(item_data) then
    return false
  end
  nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft() + 32, grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_icg_goods_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_grid_goods_select_changed(grid, index)
end
function player_buy_item(grid, npc_id, index)
  local form = grid.ParentForm
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_HIRESHOP))
  if not nx_is_valid(view) then
    return false
  end
  local item_obj = view:GetViewObj(nx_string(index + 1))
  if not nx_is_valid(item_obj) then
    return false
  end
  local amount = item_obj:QueryProp("Amount")
  local item_nameid = item_obj:QueryProp("ConfigID")
  local price = item_obj:QueryProp("StallPrice1")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_shop\\form_trade_buy", true, false)
  dialog.Left = (gui.Desktop.Width - dialog.Width) / 2
  dialog.Top = (gui.Desktop.Height - dialog.Height) / 2
  nx_execute("form_stage_main\\form_shop\\form_trade_buy", "init_buy_form", dialog, CAPITAL_TYPE_SILVER_CARD, price, amount)
  dialog:ShowModal()
  local res, count, paymodel = nx_wait_event(100000000, dialog, "form_retail_return")
  if nx_int(count) > nx_int(amount) then
    return false
  end
  if res == "ok" then
    if nx_int(form.pageno) > nx_int(1) then
      index = index - (form.pageno - 1) * 10
    end
    local view_index = grid:GetBindIndex(index)
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return false
    end
    local silver = price * count
    local rate = 1000
    local ding = nx_int(silver / (rate * rate))
    local liang = nx_int((silver - ding * rate * rate) / rate)
    local wen = nx_int(silver - ding * rate * rate - liang * rate)
    if nx_int(silver) <= nx_int(0) then
      return false
    end
    local item_name = ""
    local tips_manager = nx_value("tips_manager")
    if nx_is_valid(tips_manager) then
      item_name = tips_manager:GetItemBaseName(item_obj)
    end
    if item_name == "" then
      item_name = gui.TextManager:GetText(item_nameid)
    end
    if not show_confirm_info("ui_shop_buy_confirm", item_name, nx_int(count), ding, liang, wen) then
      return false
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HIRE_SHOP), nx_int(SUBMSG_BUY_ITEM), nx_int(view_index), npc_id, count, nx_int64(price))
  end
  return true
end
function on_icg_goods_rightclick_grid(grid, index)
  local form = grid.ParentForm
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local npc = game_client:GetSceneObj(nx_string(form.npcid))
  local owner_name = ""
  if nx_is_valid(npc) then
    owner_name = npc:QueryProp("ShopOwner")
  else
    owner_name = form.owner
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local client_player = game_client:GetPlayer()
  local player_name = client_player:QueryProp("Name")
  if owner_name == player_name then
    local view_index = grid:GetBindIndex(index)
    local item_data = GoodsGrid:GetItemData(grid, index)
    if not nx_is_valid(item_data) then
      return
    end
    local text = gui.TextManager:GetText("ui_shangpu_suretooff")
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return false
      end
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HIRE_SHOP), nx_int(SUBMSG_BUY_ITEM), nx_int(view_index), form.npcid, 0, 0)
    end
  else
    if nx_int(form.pageno) > nx_int(1) then
      index = index + (form.pageno - 1) * 10
    end
    player_buy_item(grid, form.npcid, index)
  end
end
function format_money(money)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_money2")
  gui.TextManager:Format_AddParam(money)
  local ret = gui.TextManager:Format_GetText()
  return ret
end
function on_btn_pageup_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.pageno <= 1 then
    return
  end
  form.pageno = form.pageno - 1
  refresh_grid(form)
  form.lbl_number.Text = nx_widestr(form.pageno .. "/" .. nx_string(form.max_page))
end
function on_btn_pagedown_click(btn)
  local form = btn.ParentForm
  if nx_int(form.pageno) < nx_int(form.max_page) then
    form.pageno = form.pageno + 1
    refresh_grid(form)
  end
  form.lbl_number.Text = nx_widestr(form.pageno .. "/" .. nx_string(form.max_page))
end
function on_btn_KuoRong_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if form.CurMaxCapacity >= form.MaxCells then
    nx_execute("form_stage_main\\form_main\\form_main_sysinfo", "add_system_info", nx_widestr(util_text("37022")), 1)
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = gui.TextManager:GetFormatText("37024", nx_widestr(format_money(form.CostSilver)), nx_int(form.ExpandCells))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    if not nx_is_valid(form) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HIRE_SHOP), nx_int(SUBMSG_CLINET_EXPAND_CELLS), form.npcid)
  end
end
function is_visibled(form)
  local game_client = nx_value("game_client")
  local ident = nx_string(form.npcid)
  local npc = game_client:GetSceneObj(ident)
  local owner_name = ""
  if nx_is_valid(npc) then
    owner_name = npc:QueryProp("ShopOwner")
  else
    owner_name = form.owner
  end
  local client_player = game_client:GetPlayer()
  local player_name = client_player:QueryProp("Name")
  if owner_name ~= player_name then
    form.lbl_time.Visible = false
    form.lbl_21.Visible = false
    form.btn_KuoRong.Visible = false
  else
    form.lbl_time.Visible = true
    form.lbl_21.Visible = true
    form.btn_KuoRong.Visible = true
  end
  form.lbl_owner.Text = nx_widestr(owner_name)
end
function init_timer(time, ident)
  local timer = nx_value("timer_game")
  temp_time = time
  local game_client = nx_value("game_client")
  local npc = game_client:GetSceneObj(nx_string(ident))
  if not nx_is_valid(npc) then
    return false
  end
  while true do
    local ptime = nx_pause(0)
    if not nx_is_valid(game_client) then
      return false
    end
    local obj = game_client:GetSceneObj(nx_string(ident))
    if nx_is_valid(obj) then
      timer:UnRegister(nx_current(), "on_update_time", obj)
      timer:Register(1000, -1, nx_current(), "on_update_time", obj, -1, -1)
      temp_time = temp_time - nx_int(ptime)
      break
    end
  end
end
function on_update_time(obj)
  temp_time = temp_time - 1
  local form = nx_value("form_stage_main\\form_hire_shop\\form_hire_shop_show")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_hire_shop\\form_hire_shop_show", true, false)
    nx_set_value("form_stage_main\\form_hire_shop\\form_hire_shop_show", form)
  end
  local remain = get_format_time_text(temp_time)
  form.lbl_time.Text = nx_widestr(remain)
  if temp_time <= 0 then
    stop_timer(obj)
  end
end
function stop_timer(obj)
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  timer:UnRegister(nx_current(), "on_update_time", obj)
end
function get_format_time_text(time)
  local format_time = ""
  if nx_number(time) >= 3600 then
    local hour = nx_int(time / 3600)
    local min = nx_int(math.mod(time, 3600) / 60)
    local sec = nx_int(math.mod(math.mod(time, 3600), 60))
    format_time = string.format("%02d:%02d:%02d", nx_number(hour), nx_number(min), nx_number(sec))
  elseif nx_number(time) >= 60 then
    local min = nx_int(time / 60)
    local sec = nx_int(math.mod(time, 60))
    format_time = string.format("%02d:%02d", nx_number(min), nx_number(sec))
  else
    local sec = nx_int(time)
    format_time = string.format("00:%02d", nx_number(sec))
  end
  return nx_string(format_time)
end
function refresh_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.icg_goods
  grid:Clear()
  local count = grid.RowNum * grid.ClomnNum
  local base = nx_int((form.pageno - 1) * count)
  for i = 1, count do
    grid:SetBindIndex(nx_int(i - 1), nx_int(i) + base)
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:ViewRefreshGrid(grid)
  end
  show_goods_price(form)
end
function show_goods_price(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  local pre_price_text = gui.TextManager:GetText("ui_hire_shop_price")
  local max_rows = table.getn(goods_table)
  local count = form.icg_goods.RowNum * form.icg_goods.ClomnNum
  local maxpos = form.pageno * 10
  local minpos = (form.pageno - 1) * 10
  for j = 1, 10 do
    form.icg_goods:CoverItem(j - 1, false)
  end
  for i = 1, max_rows do
    local pos = goods_table[i][1]
    local silver = goods_table[i][2]
    local price = pre_price_text .. nx_widestr(": ") .. format_money(silver)
    if maxpos >= pos and minpos < pos then
      local grid_index = -1
      if pos % 10 == 0 then
        grid_index = 9
      else
        grid_index = pos % 10 - 1
      end
      form.icg_goods:SetItemAddInfo(grid_index, 1, nx_widestr(price))
      form.icg_goods:ShowItemAddInfo(grid_index, 1, true)
      if 1000000 <= silver then
        form.icg_goods:CoverItem(grid_index, true)
      end
    end
  end
end
function req_goods_list(npcid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HIRE_SHOP), nx_int(SUBMSG_CLINET_GOODS_LIST), npcid)
end
function on_recv_goods_list(rowcount, ...)
  local form = nx_value("form_stage_main\\form_hire_shop\\form_hire_shop_show")
  if not nx_is_valid(form) then
    return 0
  end
  if rowcount == 0 then
    return
  end
  local size = table.getn(arg)
  if size < 0 or size % 2 ~= 0 then
    return 0
  end
  local rows = size / 2
  goods_table = {}
  for i = 1, rows do
    local base = (i - 1) * 2
    local pos = arg[base + 1]
    local silver = arg[base + 2]
    table.insert(goods_table, {pos, silver})
  end
  refresh_grid(form)
end
function on_btn_chat_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_widestr(form.owner) == nx_widestr("") then
    return
  end
  nx_execute("custom_sender", "custom_request_chat", nx_widestr(form.owner))
end
