require("utils")
require("util_functions")
require("share\\capital_define")
require("form_stage_main\\form_dbomall\\dbomall_define")
local FORM_DBOMALL = "form_stage_main\\form_dbomall\\form_dbomall"
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  nx_execute("custom_sender", "custom_dbomall_request", DMC_SUBMSG_FIRSTPAY_DATAINFO)
  nx_execute(FORM_DBOMALL, "show_loading")
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:AddRolePropertyBind("CapitalType0", "int", form, nx_current(), "on_gold_changed")
  end
end
function on_main_form_close(form)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:DelRolePropertyBind("CapitalType0", form)
  end
  nx_destroy(form)
end
function on_imagegrid_mousein_grid(grid, index)
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
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_gain_click(btn)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local first_pay = client_player:QueryProp("DboMallFirstPay")
  if nx_int(first_pay) == nx_int(0) then
    nx_execute("custom_sender", "custom_dbomall_request", DMC_SUBMSG_FIRSTPAY_REWARD)
  else
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("96080"))
  end
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
function on_recv_firstpay_datainfo(...)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_dbomall\\form_dbofirst")
  if not nx_is_valid(form) then
    return
  end
  if table.getn(arg) < 6 then
    return
  end
  local gain_str = nx_string(arg[1])
  local gift_str = nx_string(arg[2])
  local oldprice = nx_int(arg[3])
  local curprice = nx_int(arg[4])
  local begin_time = nx_string(arg[5])
  local end_time = nx_string(arg[6])
  local gain = util_split_string(gain_str, ",")
  if table.getn(gain) == 2 then
    local config_id = nx_string(gain[1])
    local count = nx_int(gain[2])
    local photo = get_photo(config_id)
    form.imagegrid_gain:AddItem(0, photo, "", count, -1)
    form.imagegrid_gain.config_id = config_id
  end
  form.imagegrid_gift1.Visible = false
  form.imagegrid_gift2.Visible = false
  form.imagegrid_gift3.Visible = false
  local gift_table = util_split_string(gift_str, ";")
  local gift_count = table.getn(gift_table)
  for i = 1, gift_count do
    local gift_str = nx_string(gift_table[i])
    local gift = util_split_string(gift_str, ",")
    if table.getn(gift) == 2 then
      local config_id = nx_string(gift[1])
      local count = nx_int(gift[2])
      if i <= 3 and nx_find_custom(form, "imagegrid_gift" .. i) then
        local imagegrid = nx_custom(form, "imagegrid_gift" .. i)
        if nx_is_valid(imagegrid) then
          local photo = get_photo(config_id)
          imagegrid:AddItem(0, photo, "", count, -1)
          imagegrid.Visible = true
          imagegrid.config_id = config_id
        end
      end
    end
  end
  form.lbl_oldprice.Text = gui.TextManager:GetFormatText("ui_dobmall_old_price", nx_int(oldprice))
  form.lbl_curprice.Text = gui.TextManager:GetFormatText("ui_dobmall_new_price", nx_int(curprice))
  form.lbl_limit_1.Visible = false
  if nx_string(begin_time) ~= nx_string("") and nx_string(end_time) ~= nx_string("") then
    local y1, m1, d1 = 0, 0, 0
    local y2, m2, d2 = 0, 0, 0
    local date1 = util_split_string(begin_time, " ")
    if table.getn(date1) == 2 then
      local str = nx_string(date1[1])
      local tbl = util_split_string(str, "-")
      if table.getn(tbl) == 3 then
        y1 = nx_int(tbl[1])
        m1 = nx_int(tbl[2])
        d1 = nx_int(tbl[3])
      end
    end
    local date2 = util_split_string(end_time, " ")
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
      form.lbl_limit_1.Text = gui.TextManager:GetFormatText("ui_dbomall_data", y1, m1, d1, y2, m2, d2)
      form.lbl_limit_1.Visible = true
    end
  end
  nx_execute(FORM_DBOMALL, "hide_loading")
end
