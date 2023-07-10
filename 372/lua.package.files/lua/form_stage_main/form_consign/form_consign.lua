require("util_functions")
require("util_gui")
require("custom_sender")
require("share\\client_custom_define")
require("share\\capital_define")
local g_form_name = "form_stage_main\\form_consign\\form_consign"
CSM_PUBLISH = 1
CSM_BUY = 2
CSM_UNSELL = 3
CSM_QUERY = 4
local g_page_items = 8
function auto_show_hide_form_consign()
  util_auto_show_hide_form("form_stage_main\\form_consign\\form_consign")
  local form = nx_value("form_stage_main\\form_consign\\form_consign")
  nx_execute("util_gui", "ui_show_attached_form", form)
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function main_form_init(self)
  self.Fixed = false
  local consign_info = nx_value("ConsignSale")
  if not nx_is_valid(consign_info) then
    consign_info = nx_create("ConsignSale")
    nx_set_value("ConsignSale", consign_info)
  end
  if nx_is_valid(consign_info) then
    consign_info.PageItemCount = g_page_items
  end
  return 1
end
function on_main_form_open(form)
  send_server_msg(CSM_QUERY, 0)
  local consign_info = nx_value("ConsignSale")
  if not nx_is_valid(consign_info) then
    consign_info = nx_create("ConsignSale")
    nx_set_value("ConsignSale", consign_info)
  end
  if nx_is_valid(consign_info) then
    consign_info.PageItemCount = g_page_items
  end
  set_max_page()
  set_consign_show_type(form, 0)
  form.Fixed = false
  form.rbtn_consign.Checked = true
  local databinder = nx_value("data_binder")
  databinder:AddRolePropertyBind("CapitalType0", "int", form, g_form_name, "on_point_changed")
  databinder:AddRolePropertyBind("CapitalType2", "int", form, g_form_name, "on_card_changed")
  local grid = form.tg_history
  grid:SetColTitle(0, util_format_string("ui_consign_menu_19"))
  grid:SetColTitle(1, util_format_string("ui_consign_menu_18"))
  grid:SetColTitle(2, util_format_string("ui_consign_menu_21"))
  grid:SetColTitle(3, util_format_string("ui_consign_menu_23"))
  init_buy_grid(form.tg_buy)
  form.btn_buy.Enabled = false
  return 1
end
function on_main_form_close(form)
  local mgr = nx_value("ConsignSale")
  if nx_is_valid(mgr) then
    mgr:ClearInfoList()
  end
  ui_destroy_attached_form(form)
  nx_destroy(form)
end
function on_func_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    local g_group = {
      rbtn_consign = form.gb_consign,
      rbtn_buy = form.gb_buy,
      rbtn_history = form.gb_history
    }
    for id, group in pairs(g_group) do
      if id == rbtn.Name then
        group.Visible = true
      else
        group.Visible = false
      end
    end
    if rbtn.Name == "rbtn_buy" then
      send_server_msg(CSM_QUERY, -1)
      set_consign_show_type(rbtn.ParentForm, 0)
    elseif rbtn.Name == "rbtn_history" then
      refresh_history_info(form.tg_history)
    end
  end
end
function on_close_click(self)
  util_show_form(g_form_name, false)
  return 1
end
function send_server_msg(type, ...)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CONSIGN_BASE), nx_int(type), unpack(arg))
  end
end
function on_server_msg(type, ...)
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  local mgr = nx_value("ConsignSale")
  if not nx_is_valid(mgr) then
    mgr = nx_create("ConsignSale")
    nx_set_value("ConsignSale", mgr)
  end
  if not nx_is_valid(mgr) then
    return
  end
  type = nx_number(arg[1])
  if type == CSM_QUERY then
    local update_uid = nx_string(arg[2])
    local puid = arg[3]
    local str = arg[4]
    nx_log("query_consign_info:")
    nx_log(nx_string(str))
    mgr:UpdateAllInfo(update_uid, puid, nx_int(0), nx_string(str))
    refresh_buy_info()
  end
end
function on_point_changed(form)
  local mgr = nx_value("CapitalModule")
  local info = nx_widestr("0")
  if nx_is_valid(mgr) then
    info = mgr:FormatCapital(CAPITAL_TYPE_GOLDEN, mgr:GetCapital(CAPITAL_TYPE_GOLDEN))
  end
  form.mb_current_gold_consign.HtmlText = info
  form.mb_current_gold_buy.HtmlText = info
end
function on_card_changed(form)
  local mgr = nx_value("CapitalModule")
  local info = nx_widestr("0")
  if nx_is_valid(mgr) then
    info = mgr:FormatCapital(CAPITAL_TYPE_SILVER_CARD, mgr:GetCapital(CAPITAL_TYPE_SILVER_CARD))
  end
  form.mb_current_silver_buy.HtmlText = info
  form.mb_current_silver_consign.HtmlText = info
end
function clear_grid(grid, row_min, row_max)
  local cols = grid.ColCount
  if row_min == nil or row_min < 0 then
    row_min = 0
  end
  if row_max == nil or row_max >= grid.RowCount then
    row_max = grid.RowCount
  end
  local empty = nx_widestr("")
  for i = row_min, row_max do
    for j = 0, cols do
      grid:SetGridText(i, j, empty)
    end
  end
end
function show_tips(pos, strid, ...)
  local tipmgr = nx_value("SystemCenterInfo")
  if not nx_is_valid(tipmgr) then
    return
  end
  local tipinfo = util_format_string(strid, unpack(arg))
  tipmgr:ShowSystemCenterInfo(tipinfo, pos)
end
function on_btn_fill_click(btn)
  local url = nx_string(util_format_string("ui_online_url"))
  nx_function("ext_open_url", url)
end
function on_btn_consign_click(btn)
  local form = btn.ParentForm
  local point = nx_number(form.ipt_consign_point.Text)
  local price = nx_number(form.ipt_consign_price.Text)
  if point < 10 or 1000 < point then
    show_tips(2, "consign_tip_13", 10, 1000)
    return
  end
  if 20 < price or price < 10 then
    show_tips(2, "consign_tip_14", 10, 1000)
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if nx_is_valid(dialog) then
    dialog.mltbox_info.HtmlText = util_format_string("consign_confirm", point, point * price * 1000)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res ~= "ok" then
      return
    end
  end
  send_server_msg(CSM_PUBLISH, point, price * 1000)
end
function on_price_changed(ipt)
  local form = ipt.ParentForm
  local item = form.ipt_consign_point
  local point = nx_number(item.Text)
  if point < 10 then
    point = 10
  end
  if 1000 < point then
    point = 1000
  end
  item.Text = nx_widestr(nx_int(point))
  item = form.ipt_consign_price
  local price = nx_number(item.Text)
  if price < 10 then
    price = 10
  end
  if 20 < price then
    price = 20
  end
  item.Text = nx_widestr(nx_int(price))
  local silver = point * price * 1000
  local mgr = nx_value("CapitalModule")
  local info = nx_widestr("0")
  if nx_is_valid(mgr) then
    info = mgr:FormatCapital(CAPITAL_TYPE_SILVER_CARD, nx_int64(silver))
  end
  form.ipt_total_price.Text = info
end
local g_button_info = {
  [0] = {
    type = "point",
    text = "ui_consign_menu_19",
    name = "Button",
    bgon = "down_on.png",
    bgout = "down_out.png",
    bgdown = "down_down.png"
  },
  [1] = {
    type = "price",
    text = "ui_consign_menu_18",
    name = "Button",
    bgon = "down_on.png",
    bgout = "down_out.png",
    bgdown = "down_down.png"
  },
  [2] = {
    type = "totalprice",
    text = "ui_consign_menu_21",
    name = "Button",
    bgon = "down_on.png",
    bgout = "down_out.png",
    bgdown = "down_down.png"
  },
  [3] = {
    type = "time",
    text = "ui_consign_menu_20",
    name = "Button",
    bgon = "down_on.png",
    bgout = "down_out.png",
    bgdown = "down_down.png"
  }
}
local g_button_info_desc = {
  [0] = {
    type = "point",
    text = "ui_consign_menu_19",
    name = "Button",
    bgon = "up_on.png",
    bgout = "up_out.png",
    bgdown = "up_down.png"
  },
  [1] = {
    type = "price",
    text = "ui_consign_menu_18",
    name = "Button",
    bgon = "up_on.png",
    bgout = "up_out.png",
    bgdown = "up_down.png"
  },
  [2] = {
    type = "totalprice",
    text = "ui_consign_menu_21",
    name = "Button",
    bgon = "up_on.png",
    bgout = "up_out.png",
    bgdown = "up_down.png"
  },
  [3] = {
    type = "time",
    text = "ui_consign_menu_20",
    name = "Button",
    bgon = "up_on.png",
    bgout = "up_out.png",
    bgdown = "up_down.png"
  }
}
local g_gui_path = "gui\\special\\consign\\"
function on_btn_myconsign_click(btn)
  local mgr = nx_value("ConsignSale")
  if not nx_is_valid(mgr) then
    return
  end
  local form = btn.ParentForm
  mgr.CurrentInfoPage = 0
  local flag = nx_custom(btn, "consign_type")
  set_consign_show_type(form, 1 - flag)
  form.btn_fresh.Visible = flag ~= 0
  local grid = btn.ParentForm.tg_buy
  grid:ClearSelect()
  if flag == 0 then
    local my_infos = mgr:GetMyInfoList()
    clear_grid(grid, 1)
    set_max_page(table.getn(my_infos))
    local row = 1
    for _, index in pairs(my_infos) do
      local infos = mgr:GetInfoByIndex(index)
      set_buy_info(grid, row, infos)
      row = row + 1
    end
  else
    refresh_buy_info()
  end
  on_select_buyinfo_row(grid, grid.RowSelectIndex)
end
function set_consign_show_type(form, flag)
  local g_consign_type = {
    [0] = {
      "ui_my_consign",
      "ui_buy_consign"
    },
    [1] = {
      "ui_all_consign",
      "ui_cancel_consign"
    }
  }
  local cfg = g_consign_type[flag]
  if cfg == nil then
    return
  end
  form.btn_myconsign.Text = util_format_string(cfg[1])
  form.btn_buy.Text = util_format_string(cfg[2])
  nx_set_custom(form.btn_myconsign, "consign_type", flag)
  nx_set_custom(form.btn_buy, "consign_type", flag)
  form.btn_fresh.Visible = flag == 0
  local grid = form.tg_buy
  local cols = grid.ColCount
  local rows = grid.RowCount
  if 0 < rows then
    for i = 0, cols - 1 do
      local item = grid:GetGridControl(0, i)
      if nx_is_valid(item) then
        item.Enabled = flag == 0
      end
    end
  end
end
function on_btn_fresh_click(btn)
  local mgr = nx_value("ConsignSale")
  if not nx_is_valid(mgr) then
    return
  end
  local slice = mgr.UpdateInfoSlice
  if nx_number(slice) < 5 then
    return
  end
  send_server_msg(CSM_QUERY, -1)
  set_consign_show_type(btn.ParentForm, 0)
end
function on_btn_buy_click(btn)
  local form = btn.ParentForm
  local grid = form.tg_buy
  local index = grid.RowSelectIndex
  if index < 0 then
    show_tips(2, "consign_tip_37")
    return
  end
  local key = nx_string(grid:GetGridText(index, 4))
  local g_sub_cmd = {
    [0] = {
      cmd = CSM_BUY,
      tip = "consign_tip_60"
    },
    [1] = {
      cmd = CSM_UNSELL,
      tip = "consign_tip_61"
    }
  }
  local cfg = g_sub_cmd[nx_custom(btn, "consign_type")]
  if cfg == nil then
    return
  end
  local point = grid:GetGridText(index, 0)
  local price = grid:GetGridText(index, 2)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if nx_is_valid(dialog) then
    dialog.mltbox_info.HtmlText = util_format_string(cfg.tip, point, price)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res ~= "ok" then
      return
    end
  end
  send_server_msg(cfg.cmd, key)
end
function on_select_buyinfo_row(grid, row)
  local item = grid.ParentForm.btn_buy
  local mgr = nx_value("ConsignSale")
  if not nx_is_valid(mgr) then
    return
  end
  local uid = nx_string(grid:GetGridText(row, 4))
  local infos = mgr:GetInfoByUid(uid)
  item.Enabled = table.getn(infos) > 0
end
function on_buynfo_sort_click(btn)
  local mgr = nx_value("ConsignSale")
  if not nx_is_valid(mgr) then
    return
  end
  local desc = nx_custom(btn, "desc_type")
  local configs
  if desc == 1 then
    configs = g_button_info
    nx_set_custom(btn, "desc_type", 0)
  else
    configs = g_button_info_desc
    nx_set_custom(btn, "desc_type", 1)
  end
  local col_index = nx_custom(btn, "col_index")
  local sort_type = nx_custom(btn, "sort_type")
  local cfg = configs[col_index]
  if cfg == nil then
    return
  end
  btn.NormalImage = g_gui_path .. cfg.bgout
  btn.FocusImage = g_gui_path .. cfg.bgon
  mgr:OrderInfo(sort_type, desc == 0)
  refresh_buy_info()
end
function init_buy_grid(grid)
  local mgr = nx_value("ConsignSale")
  if not nx_is_valid(mgr) then
    return
  end
  grid.RowCount = mgr.PageItemCount + 1
  local gui = nx_value("gui")
  for col, cfg in pairs(g_button_info) do
    local ctrl = gui:Create(cfg.name)
    ctrl.DrawMode = "ExpandH"
    nx_bind_script(ctrl, nx_current())
    nx_callback(ctrl, "on_click", "on_buynfo_sort_click")
    ctrl.NormalImage = g_gui_path .. cfg.bgout
    ctrl.FocusImage = g_gui_path .. cfg.bgon
    ctrl.Text = util_format_string(cfg.text)
    ctrl.ForeColor = "255,197,184,159"
    grid:SetGridControl(0, col, ctrl)
    nx_set_custom(ctrl, "desc_type", 0)
    nx_set_custom(ctrl, "col_index", col)
    nx_set_custom(ctrl, "sort_type", cfg.type)
  end
end
function refresh_buy_info()
  local mgr = nx_value("ConsignSale")
  if not nx_is_valid(mgr) then
    return
  end
  local capitalmgr = nx_value("CapitalModule")
  if not nx_is_valid(capitalmgr) then
    return
  end
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  set_max_page()
  local page = mgr.CurrentInfoPage
  local max_index = mgr.InfoCount - 1
  local begin_index = page * mgr.PageItemCount
  local end_index = begin_index + mgr.PageItemCount
  if max_index < end_index then
    end_index = max_index
  end
  local selfuid = mgr.PlayerUid
  local show_count = end_index - begin_index + 1
  local grid = form.tg_buy
  clear_grid(grid, 1)
  local row = 1
  for i = begin_index, end_index do
    local infos = mgr:GetInfoByIndex(nx_int(i))
    set_buy_info(grid, row, infos)
    row = row + 1
  end
end
function set_buy_info(grid, row, infos)
  local capitalmgr = nx_value("CapitalModule")
  if not nx_is_valid(capitalmgr) then
    return
  end
  grid:SetGridText(row, nx_int(0), capitalmgr:FormatCapital(0, nx_int64(infos[1])))
  grid:SetGridText(row, nx_int(1), capitalmgr:FormatCapital(2, nx_int64(infos[2])))
  grid:SetGridText(row, nx_int(2), capitalmgr:FormatCapital(2, nx_int64(infos[2] * infos[1])))
  local day = nx_int(infos[3] / 86400)
  local h = nx_int(math.mod(infos[3], 86400) / 3600)
  local m = nx_int(math.mod(infos[3], 3600) / 60)
  grid:SetGridText(row, nx_int(3), util_format_string("consign_tip_time", day, h, m))
  grid:SetGridText(row, 4, nx_widestr(infos[5]))
end
function set_max_page(item_count)
  local mgr = nx_value("ConsignSale")
  if not nx_is_valid(mgr) then
    return
  end
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  local page = mgr.CurrentInfoPage
  if page < 0 then
    page = 0
    mgr.CurrentInfoPage = 0
  end
  if item_count == nil then
    item_count = mgr.InfoCount
  end
  local max_page = math.ceil(nx_number(item_count) / nx_number(mgr.PageItemCount))
  if max_page < 1 then
    max_page = 1
  end
  if page >= max_page then
    mgr.CurrentInfoPage = max_page - 1
    page = max_page - 1
  end
  form.btn_left.Enabled = 0 < page
  form.btn_right.Enabled = max_page > page + 1
  form.lbl_consign_info_page.Text = util_format_string("ui_consign_menu_26", mgr.CurrentInfoPage + 1, max_page)
end
function on_page_left(btn)
  local mgr = nx_value("ConsignSale")
  if not nx_is_valid(mgr) then
    return
  end
  mgr.CurrentInfoPage = mgr.CurrentInfoPage - 1
  set_max_page()
  refresh_buy_info()
end
function on_page_right(btn)
  local mgr = nx_value("ConsignSale")
  if not nx_is_valid(mgr) then
    return
  end
  mgr.CurrentInfoPage = mgr.CurrentInfoPage + 1
  set_max_page()
  refresh_buy_info()
end
function refresh_history_info(grid)
  grid.RowCount = rows
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local capitalmgr = nx_value("CapitalModule")
  if not nx_is_valid(capitalmgr) then
    return
  end
  local rows = player:GetRecordRows("consign_history")
  grid.RowCount = rows
  local row = 0
  for i = 0, rows - 1 do
    local infos = util_split_string(player:QueryRecord("consign_history", i, 0), ",")
    local point = nx_int(infos[5])
    local price = nx_int(infos[6])
    local totalprice = point * price
    grid:SetGridText(row, 0, capitalmgr:FormatCapital(0, point))
    grid:SetGridText(row, 1, capitalmgr:FormatCapital(2, price))
    grid:SetGridText(row, 2, capitalmgr:FormatCapital(2, totalprice))
    local t = os.date("*t", nx_number(infos[4]))
    grid:SetGridText(row, 3, util_format_string("consign_history_1", t.year, t.month, t.day, t.hour, t.min))
    row = row + 1
  end
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
