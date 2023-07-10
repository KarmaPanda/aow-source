require("utils")
require("util_functions")
require("share\\capital_define")
require("form_stage_main\\form_dbomall\\dbomall_define")
local FORM_DBOMALL = "form_stage_main\\form_dbomall\\form_dbomall"
function main_form_init(form)
  form.Fixed = true
  form.nCurPage = 1
  form.nItemCount = 0
  form.nPerItemNum = 3
  form.nPageNum = 0
end
function on_main_form_open(form)
  nx_execute("custom_sender", "custom_dbomall_request", DMC_SUBMSG_TOTAL_DATAINFO)
  nx_execute(FORM_DBOMALL, "show_loading")
  HideChargeItemCtrls(form)
  form.lbl_no_content.Visible = false
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:AddRolePropertyBind("CapitalType0", "int", form, nx_current(), "on_gold_changed")
  end
end
function on_main_form_close(form)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:DelTableBind("DboMallTotalPayRec", form)
    data_binder:DelRolePropertyBind("CapitalType0", form)
  end
  nx_destroy(form)
end
function on_btn_prev_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.nCurPage) <= nx_int(1) then
    form.nCurPage = 1
  else
    form.nCurPage = form.nCurPage - 1
  end
  SwitchToPage(form, form.nCurPage)
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.nCurPage) >= nx_int(form.nPageNum) then
    form.nCurPage = form.nPageNum
  else
    form.nCurPage = form.nCurPage + 1
  end
  SwitchToPage(form, form.nCurPage)
end
function on_grid_mousein_grid(grid)
  local form = grid.ParentForm
  if not nx_find_custom(grid, "config_id") then
    return
  end
  local config_id = grid.config_id
  if nx_string(config_id) == nx_string("") then
    return
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = config_id
  item.ItemType = ItemQuery:GetItemPropByConfigID(nx_string(configid), "ItemType")
  item.BindStatus = ItemQuery:GetItemPropByConfigID(nx_string(configid), "BindStatus")
  nx_execute("tips_game", "show_goods_tip", item, x, y, 0, 0, form)
end
function on_grid_mouseout_grid(grid)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_gain_click(btn)
  local gbx = btn.Parent
  if not nx_is_valid(gbx) then
    return
  end
  if not (nx_find_custom(gbx, "charge_id") and nx_find_custom(gbx, "config_id")) or not nx_find_custom(gbx, "sale_desc") then
    return
  end
  local config_id = gbx.config_id
  local charge_id = gbx.charge_id
  local sale_desc = gbx.sale_desc
  if nx_string(config_id) == nx_string("") or nx_int(charge_id) <= nx_int(0) or nx_string(sale_desc) == nx_string("") then
    return
  end
  nx_execute("custom_sender", "custom_dbomall_request", DMC_SUBMSG_TOTAL_GAINITEM, nx_int(charge_id), nx_string(config_id), nx_string(sale_desc))
end
function on_gold_changed(form)
  local manager = nx_value("CapitalModule")
  if not nx_is_valid(manager) then
    return
  end
  local point = manager:GetCapital(CAPITAL_TYPE_GOLDEN)
  local txt = manager:GetFormatCapitalHtml(CAPITAL_TYPE_GOLDEN, point)
  form.mltbox_silver.HtmlText = txt
end
function on_recv_total_datainfo(...)
  local form = nx_value("form_stage_main\\form_dbomall\\form_dbototal")
  if not nx_is_valid(form) then
    return
  end
  local dbomall_manager = nx_value("dbomall_manager")
  if not nx_is_valid(dbomall_manager) then
    return
  end
  dbomall_manager:ClearChargeItems()
  for i = 1, table.getn(arg) do
    dbomall_manager:AddChargeItem(nx_string(arg[i]))
  end
  form.nCurPage = 1
  form.nItemCount = dbomall_manager:GetChargeItemCount()
  form.nPageNum = nx_int((form.nItemCount + form.nPerItemNum - 1) / form.nPerItemNum)
  dbomall_manager:SetPerItemNum(form.nPerItemNum)
  SwitchToPage(form, form.nCurPage)
  nx_execute(FORM_DBOMALL, "hide_loading")
  form.lbl_no_content.Visible = IsAllHide(form)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:AddTableBind("DboMallTotalPayRec", form, nx_current(), "on_totalpayrec_change")
  end
end
function on_totalpayrec_change(form, tablename, ttype, line, col)
  if not nx_is_valid(form) then
    return
  end
  local dbomall_manager = nx_value("dbomall_manager")
  if not nx_is_valid(dbomall_manager) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local rows = client_player:GetRecordRows("DboMallTotalPayRec")
  if nx_int(rows) > nx_int(0) then
    for i = 0, rows - 1 do
      local charge_id = client_player:QueryRecord("DboMallTotalPayRec", i, 0)
      dbomall_manager:DelChargeItem(charge_id)
    end
    form.nItemCount = dbomall_manager:GetChargeItemCount()
    form.nPageNum = nx_int((form.nItemCount + form.nPerItemNum - 1) / form.nPerItemNum)
    SwitchToPage(form, form.nCurPage)
  end
  form.lbl_no_content.Visible = IsAllHide(form)
end
function SwitchToPage(form, page)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(page) < nx_int(1) or nx_int(page) > nx_int(form.nPageNum) then
    HideAll(form)
    return
  end
  local dbomall_manager = nx_value("dbomall_manager")
  if not nx_is_valid(dbomall_manager) then
    return
  end
  local item_table = dbomall_manager:GetChargeItemList(page)
  if table.getn(item_table) <= 0 then
    HideAll(form)
    return
  end
  HideChargeItemCtrls(form)
  local arg_num = 14
  local item_count = table.getn(item_table) / arg_num
  for i = 0, item_count - 1 do
    local charge_item = {}
    for j = i * arg_num + 1, i * arg_num + arg_num do
      table.insert(charge_item, item_table[j])
    end
    SetChargeItemInfo(form, i + 1, unpack(charge_item))
  end
  form.lbl_page.Text = nx_widestr(page .. "/" .. form.nPageNum)
end
function HideChargeItemCtrls(form)
  for i = 1, form.nPerItemNum do
    if nx_find_custom(form, "gbx_item_" .. i) then
      local gbx = nx_custom(form, "gbx_item_" .. i)
      if nx_is_valid(gbx) then
        gbx.Visible = false
      end
    end
  end
end
function HideAll(form)
  HideChargeItemCtrls(form)
  form.btn_prev.Enabled = false
  form.btn_next.Enabled = false
  form.lbl_page.Text = nx_widestr("0/0")
end
function IsAllHide(form)
  for i = 1, form.nPerItemNum do
    if nx_find_custom(form, "gbx_item_" .. i) then
      local gbx = nx_custom(form, "gbx_item_" .. i)
      if nx_is_valid(gbx) and gbx.Visible then
        return false
      end
    end
  end
  return true
end
function SetChargeItemInfo(form, index, ...)
  local gui = nx_value("gui")
  if not nx_find_custom(form, "gbx_item_" .. index) then
    return
  end
  local gbx = nx_custom(form, "gbx_item_" .. index)
  if not nx_is_valid(gbx) then
    return
  end
  if table.getn(arg) ~= 14 then
    return
  end
  gbx.charge_id = nx_int(arg[1])
  gbx.config_id = nx_string(arg[2])
  gbx.beben_time = nx_string(arg[3])
  gbx.end_time = nx_string(arg[4])
  gbx.charge_order = nx_string(arg[5])
  gbx.game_order = nx_string(arg[6])
  gbx.src_price = nx_string(arg[7])
  gbx.exchange_price = nx_string(arg[8])
  gbx.money_type = nx_string(arg[9])
  gbx.sell_type = nx_string(arg[10])
  gbx.item_value = nx_string(arg[11])
  gbx.sale_desc = nx_string(arg[12])
  gbx.limint_count = nx_int(arg[13])
  gbx.account_limint_count = nx_int(arg[14])
  local extra_table = util_split_string(gbx.sale_desc, "|")
  if table.getn(extra_table) >= 4 then
    local price_value = nx_int(extra_table[4])
    local lbl_name = nx_custom(form, "lbl_name_" .. index)
    if nx_is_valid(lbl_name) then
      lbl_name.Text = gui.TextManager:GetFormatText("ui_dobmall_0003_title", nx_int(price_value))
    end
  end
  local grid = nx_custom(form, "grid_main_" .. index)
  if nx_is_valid(grid) then
    local photo = get_photo(gbx.config_id)
    grid:AddItem(0, photo, "", 1, -1)
    grid.config_id = gbx.config_id
  end
  local item_table = {}
  if table.getn(extra_table) >= 1 then
    local item_info = nx_string(extra_table[1])
    local info_table = util_split_string(item_info, ";")
    for i = 1, table.getn(info_table) do
      local info = info_table[i]
      local tbl = util_split_string(info, ":")
      if table.getn(tbl) == 2 then
        local item = {}
        item.config_id = nx_string(tbl[1])
        item.count = nx_number(tbl[2])
        table.insert(item_table, item)
      end
    end
  end
  local sub_grid_str = "grid_sub_" .. index .. "_"
  for i = 1, form.nPerItemNum do
    local sub_grid = nx_custom(form, sub_grid_str .. i)
    if nx_is_valid(sub_grid) then
      sub_grid.Visible = false
      if i <= table.getn(item_table) then
        local item = item_table[i]
        local photo = get_photo(item.config_id)
        sub_grid:AddItem(0, photo, "", item.count, -1)
        sub_grid.Visible = true
        sub_grid.config_id = item.config_id
      end
    end
  end
  local lbl_srcprice = nx_custom(form, "lbl_srcprice_" .. index)
  if nx_is_valid(lbl_srcprice) then
    lbl_srcprice.Text = gui.TextManager:GetFormatText("ui_dobmall_old_price", nx_int(gbx.src_price))
  end
  local lbl_curprice = nx_custom(form, "lbl_curprice_" .. index)
  if nx_is_valid(lbl_curprice) then
    lbl_curprice.Text = gui.TextManager:GetFormatText("ui_dobmall_new_price", nx_int(0))
  end
  local lbl_limit = nx_custom(form, "lbl_limit_" .. index)
  if nx_is_valid(lbl_limit) then
    lbl_limit.Visible = false
    if table.getn(extra_table) >= 2 then
      local info = nx_string(extra_table[2])
      local date_table = util_split_string(info, ";")
      if table.getn(date_table) == 2 then
        local y1, m1, d1 = 0, 0, 0
        local y2, m2, d2 = 0, 0, 0
        local str1 = nx_string(date_table[1])
        local date1 = util_split_string(str1, " ")
        if table.getn(date1) == 2 then
          local str = nx_string(date1[1])
          local tbl = util_split_string(str, "-")
          if table.getn(tbl) == 3 then
            y1 = nx_int(tbl[1])
            m1 = nx_int(tbl[2])
            d1 = nx_int(tbl[3])
          end
        end
        local str2 = nx_string(date_table[2])
        local date2 = util_split_string(str2, " ")
        if table.getn(date2) == 2 then
          local str = nx_string(date2[1])
          local tbl = util_split_string(str, "-")
          if table.getn(tbl) == 3 then
            y2 = nx_int(tbl[1])
            m2 = nx_int(tbl[2])
            d2 = nx_int(tbl[3])
          end
        end
        if nx_int(y1) ~= nx_int(0) and nx_int(m1) ~= nx_int(0) and nx_int(d1) ~= nx_int(0) and nx_int(y2) ~= nx_int(0) and nx_int(m2) ~= nx_int(0) and nx_int(d2) ~= nx_int(0) then
          lbl_limit.Text = gui.TextManager:GetFormatText("ui_dbomall_data", y1, m1, d1, y2, m2, d2)
          lbl_limit.Visible = true
        end
      end
    end
  end
  local lbl_rebate = nx_custom(form, "lbl_rebate_" .. index)
  if nx_is_valid(lbl_rebate) then
    lbl_rebate.Visible = false
    if table.getn(extra_table) >= 3 then
      local rebate = nx_number(extra_table[3])
      if rebate ~= nil then
        lbl_rebate.BackImage = REBATE_IMAGE[rebate]
        lbl_rebate.Visible = true
      end
    end
  end
  local lbl_salenum = nx_custom(form, "lbl_salenum_" .. index)
  if nx_is_valid(lbl_salenum) then
    lbl_salenum.Visible = false
    local text = nx_widestr("")
    if nx_int(gbx.limint_count) > nx_int(0) then
      text = nx_widestr(gui.TextManager:GetFormatText("ui_dbomall_limit_1", nx_int(gbx.limint_count)))
    end
    if nx_int(gbx.account_limint_count) > nx_int(0) then
      if nx_string(text) ~= nx_string("") then
        text = text .. nx_widestr(",")
      end
      text = text .. nx_widestr(gui.TextManager:GetFormatText("ui_dbomall_limit_2", nx_int(gbx.account_limint_count)))
    end
    if nx_string(text) ~= nx_string("") then
      lbl_salenum.Text = nx_widestr("(") .. text .. nx_widestr(")")
      lbl_salenum.Visible = true
    end
  end
  gbx.Visible = true
end
