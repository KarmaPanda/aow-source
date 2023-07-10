require("util_gui")
require("util_functions")
require("tips_data")
local FORM_NAME = "form_stage_main\\form_world_auction\\form_world_auction"
local ARRAY_NAME_ITEM = "COMMON_ARRAY_WA_ITEM"
local REC_WA_ATTATION = "WorldAuctionAttationRec"
local color = {
  [1] = {
    "255,201,88,81",
    "ui_auction_1"
  },
  [2] = {
    "255,152,160,205",
    "ui_auction_2"
  },
  [3] = {
    "255,186,151,114",
    "ui_auction_3"
  },
  [4] = {
    "255,153,153,153",
    "ui_auction_4"
  },
  [5] = {
    "255,233,192,80",
    "ui_auction_5"
  },
  [6] = {
    "255,163,202,68",
    "ui_auction_6"
  }
}
local fore_color_you = "255,10,255,0"
local fore_color_other = "255,255,255,255"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  load_ini(self)
  self.sl_type = 1
  self.sl_auction = ""
  self.sl_histroy = ""
  self.show_boss_info = 1
  local databinder = nx_value("data_binder")
  databinder:AddTableBind(REC_WA_ATTATION, self, FORM_NAME, "on_rec_wa_attation_change")
  databinder:AddRolePropertyBind("CapitalType2", "int", self, FORM_NAME, "on_captial2_changed")
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_update_time", self, -1, -1)
  nx_execute("custom_sender", "custom_world_auction", 0, 0)
end
function on_main_form_close(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind(REC_WA_ATTATION, self)
    databinder:DelRolePropertyBind("CapitalType2", self)
  end
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", self)
  end
  nx_execute("custom_sender", "custom_world_auction", 6, 0)
  nx_destroy(self)
end
function on_main_form_shut(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function open_or_close()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    form = util_get_form(FORM_NAME, true)
    form:Show()
    form.Visible = true
    return
  end
  form:Close()
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_update_time(form)
  local old_count = form.gsb_auction:GetChildControlCount()
  for i = 0, form.gsb_auction:GetChildControlCount() do
    local gb = form.gsb_auction:GetChildControlByIndex(i)
    if nx_is_valid(gb) then
      local lbl_time = gb:Find("lbl_1_time_" .. nx_string(gb.auction_uid))
      local end_time = lbl_time.end_time
      local time = nx_number(get_remain_time(end_time))
      if 0 < time then
        time = time - 1
        lbl_time.Text = get_time_text(time)
        if time == 0 then
          nx_execute("custom_sender", "custom_world_auction", 0)
          return
        end
      else
        local cbtn = gb:Find("cbtn_1_bg_" .. nx_string(gb.auction_uid))
        if cbtn.Checked then
          set_sl_auction(form, "")
        end
        form.gsb_auction.IsEditMode = true
        form.gsb_auction:Remove(gb)
        form.gsb_auction.IsEditMode = false
        form.gsb_auction:ResetChildrenYPos()
      end
    end
  end
  local count = form.gsb_auction:GetChildControlCount()
  if old_count ~= 0 and count == 0 then
    form.gb_1_help1.Visible = true
    form.gb_1_help2.Visible = true
  elseif old_count == 0 and count ~= 0 then
    form.gb_1_help1.Visible = true
    form.gb_1_help2.Visible = true
  end
end
function on_rbtn_1_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.gb_1.Visible = true
    form.gb_2.Visible = false
    form.sl_type = 1
    show_info(form)
    select_first(form)
  end
end
function on_rbtn_2_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.gb_1.Visible = true
    form.gb_2.Visible = false
    form.sl_type = 2
    show_info(form)
    select_first(form)
  end
end
function select_first(form)
  form.gb_1_help1.Visible = false
  form.gb_1_help2.Visible = false
  form.gb_info_1.Visible = true
  for i = 0, form.gsb_auction:GetChildControlCount() do
    local gb = form.gsb_auction:GetChildControlByIndex(i)
    if nx_is_valid(gb) and gb.Visible then
      local cbtn = gb:Find("cbtn_1_bg_" .. nx_string(gb.auction_uid))
      cbtn.Checked = true
      break
    end
  end
  if form.gsb_auction:GetChildControlCount() == 0 then
    form.gb_1_help1.Visible = true
    form.gb_1_help2.Visible = true
    form.gb_info_1.Visible = false
  end
end
function select_first_histroy(form)
  form.gb_2_help1.Visible = false
  form.gb_2_help2.Visible = false
  form.gb_info_2.Visible = true
  if form.gsb_histroy:GetChildControlCount() <= 0 then
    form.gb_2_help1.Visible = true
    form.gb_2_help2.Visible = true
    form.gb_info_2.Visible = false
    return
  end
  local gb = form.gsb_histroy:GetChildControlByIndex(0)
  if nx_is_valid(gb) then
    local cbtn = gb:Find("cbtn_2_bg_" .. nx_string(gb.auction_uid))
    cbtn.Checked = true
  end
end
function on_rbtn_3_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.gb_1.Visible = false
    form.gb_2.Visible = true
    nx_execute("custom_sender", "custom_world_auction", 2)
  end
end
function on_ipt_changed(ipt)
  local form = ipt.ParentForm
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local capital1 = client_player:QueryProp("CapitalType2")
  local ding = nx_number(form.ipt_1_ding.Text)
  local liang = nx_number(form.ipt_1_liang.Text)
  local wen = nx_number(form.ipt_1_wen.Text)
  local cur_price = ding * 1000000 + liang * 1000 + wen
  if cur_price < form.gb_info_1.price_min or cur_price > nx_number(capital1) then
    form.btn_compete.Enabled = false
  else
    form.btn_compete.Enabled = true
  end
end
function on_btn_see_boss_click(btn)
  local form = btn.ParentForm
  if nx_int(form.show_boss_info) == nx_int(0) then
    return
  else
    nx_execute("form_stage_main\\form_world_auction\\form_world_auction_see_boss", "open_or_close")
  end
end
function on_btn_compete_click(btn)
  local form = btn.ParentForm
  local ding = nx_int(form.ipt_1_ding.Text)
  local liang = nx_int(form.ipt_1_liang.Text)
  local wen = nx_int(form.ipt_1_wen.Text)
  local cur_price = ding * 1000000 + liang * 1000 + wen
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local dialog_text = "world_auction_compete_confirm"
  if 200000 <= cur_price and cur_price > form.gb_info_1.price_min * 8 then
    dialog_text = "world_auction_compete_confirm_2"
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText(dialog_text, nx_int(cur_price), nx_widestr(form.lbl_info_1_name.Text), nx_int(form.lbl_info_1_amount.Text))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local sl_auction = form.sl_auction
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_world_auction", 3, sl_auction, cur_price)
  end
end
function on_btn_price_up_click(btn)
  local form = btn.ParentForm
  local ding = nx_int(form.ipt_1_ding.Text)
  local liang = nx_int(form.ipt_1_liang.Text)
  local wen = nx_int(form.ipt_1_wen.Text)
  local cur_price = ding * 1000000 + liang * 1000 + wen
  cur_price = cur_price + nx_number(btn.DataSource)
  if cur_price < form.gb_info_1.price_min then
    cur_price = form.gb_info_1.price_min
  end
  set_ipt_money(form, cur_price)
end
function on_btn_price_down_click(btn)
  local form = btn.ParentForm
  local ding = nx_int(form.ipt_1_ding.Text)
  local liang = nx_int(form.ipt_1_liang.Text)
  local wen = nx_int(form.ipt_1_wen.Text)
  local cur_price = ding * 1000000 + liang * 1000 + wen
  cur_price = cur_price + nx_number(btn.DataSource)
  if cur_price < form.gb_info_1.price_min then
    cur_price = form.gb_info_1.price_min
  end
  set_ipt_money(form, cur_price)
end
function on_cbtn_1_bg_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if cbtn.Checked then
    if nx_string(form.sl_auction) == nx_string(cbtn.auction_uid) then
      return
    end
    local old_sl_auction = form.sl_auction
    set_sl_auction(form, nx_string(cbtn.auction_uid))
    if nx_string(old_sl_auction) ~= nx_string("") then
      local gb = form.gsb_auction:Find("gb_1_" .. nx_string(old_sl_auction))
      if nx_is_valid(gb) then
        local cbtn_old = gb:Find("cbtn_1_bg_" .. nx_string(old_sl_auction))
        if nx_is_valid(cbtn_old) then
          cbtn_old.Checked = false
        end
      end
    end
  elseif nx_string(form.sl_auction) == nx_string(cbtn.auction_uid) then
    cbtn.Checked = true
  end
end
function on_cbtn_2_bg_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if cbtn.Checked then
    if nx_string(form.sl_histroy) == nx_string(cbtn.auction_uid) then
      return
    end
    local old_sl_histroy = form.sl_histroy
    set_sl_histroy(form, nx_string(cbtn.auction_uid))
    if nx_string(old_sl_histroy) ~= nx_string("") then
      local gb = form.gsb_histroy:Find("gb_2_" .. nx_string(old_sl_histroy))
      if nx_is_valid(gb) then
        local cbtn_old = gb:Find("cbtn_2_bg_" .. nx_string(old_sl_histroy))
        if nx_is_valid(cbtn_old) then
          cbtn_old.Checked = false
        end
      end
    end
  elseif nx_string(form.sl_histroy) == nx_string(cbtn.auction_uid) then
    cbtn.Checked = true
  end
end
function on_cbtn_1_attation_click(cbtn)
  if cbtn.Checked then
    nx_execute("custom_sender", "custom_world_auction", 4, cbtn.auction_uid)
  else
    nx_execute("custom_sender", "custom_world_auction", 5, cbtn.auction_uid)
    show_info(cbtn.ParentForm)
  end
end
function on_ig_mousein_grid(grid, index)
  if not nx_find_custom(grid, "config") then
    return
  end
  local config = grid.config
  local count = grid.count
  local bind = grid.bind
  local prop_array = {}
  prop_array.ConfigID = nx_string(config)
  prop_array.Amount = nx_int(count)
  prop_array.BindStatus = nx_int(bind)
  if not nx_is_valid(grid.Data) then
    grid.Data = nx_create("ArrayList")
  end
  grid.Data:ClearChild()
  for prop, value in pairs(prop_array) do
    nx_set_custom(grid.Data, prop, value)
  end
  nx_execute("tips_game", "show_goods_tip", grid.Data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_ig_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function update_auction_single(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local drop_type = nx_int(arg[1])
  local auction_uid = nx_string(arg[2])
  local item_config = nx_string(arg[3])
  local item_amount = nx_int(arg[4])
  local bind = nx_int(arg[5])
  local price = nx_int(arg[6])
  local competer_name = nx_widestr(arg[7])
  local end_time = nx_double(arg[8])
  if drop_type >= nx_int(100) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local self_name = client_player:QueryProp("Name")
  local now = get_sys_time()
  local gb = form.gsb_auction:Find("gb_1_" .. auction_uid)
  if nx_is_valid(gb) then
    if end_time <= now then
      local cbtn = gb:Find("cbtn_1_bg_" .. nx_string(auction_uid))
      if cbtn.Checked then
        set_sl_auction(form, "")
      end
      form.gsb_auction.IsEditMode = true
      form.gsb_auction:Remove(gb)
      form.gsb_auction.IsEditMode = false
      form.gsb_auction:ResetChildrenYPos()
    else
      local lbl_competer = gb:Find("lbl_1_competer_" .. nx_string(auction_uid))
      local lbl_price = gb:Find("lbl_1_price_" .. nx_string(auction_uid))
      local lbl_time = gb:Find("lbl_1_time_" .. nx_string(auction_uid))
      lbl_competer.Text = nx_widestr(competer_name)
      if nx_widestr(competer_name) == nx_widestr(self_name) then
        lbl_competer.ForeColor = fore_color_you
      else
        lbl_competer.ForeColor = fore_color_other
      end
      lbl_price.HtmlText = get_money_text(price)
      lbl_price.price = price
      local cbtn = gb:Find("cbtn_1_bg_" .. nx_string(auction_uid))
      if cbtn.Checked then
        set_sl_auction(form, nx_string(cbtn.auction_uid))
      end
    end
  else
    form.gsb_auction.IsEditMode = true
    gsp_auction_add(form, auction_uid, item_config, item_amount, bind, price, competer_name, end_time)
    form.gsb_auction.IsEditMode = false
    form.gsb_auction:ResetChildrenYPos()
  end
end
function update_auction(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local see_type = nx_number(arg[3])
  if see_type ~= 0 then
    return
  end
  form.show_boss_info = 1
  local info_list = util_split_wstring(arg[1], ";")
  form.show_boss_info = nx_int(1) - nx_int(arg[2])
  form.gsb_auction.IsEditMode = true
  form.gsb_auction:DeleteAll()
  for i = 1, table.getn(info_list) do
    local info = util_split_wstring(info_list[i], ",")
    if table.getn(info) >= 7 then
      local auction_uid = nx_string(info[1])
      local item_config = nx_string(info[2])
      local item_amount = nx_int(info[3])
      local bind = nx_int(info[4])
      local price = nx_int(info[5])
      local competer_name = nx_widestr(info[6])
      local end_time = nx_double(info[7])
      gsp_auction_add(form, auction_uid, item_config, item_amount, bind, price, competer_name, end_time)
    end
  end
  form.gsb_auction.IsEditMode = false
  form.gsb_auction:ResetChildrenYPos()
  form.rbtn_1.Checked = true
end
function update_histroy(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local see_type = nx_number(arg[2])
  if see_type ~= 0 then
    return
  end
  local info_list = util_split_wstring(arg[1], ";")
  form.gsb_histroy.IsEditMode = true
  form.gsb_histroy:DeleteAll()
  for i = 1, table.getn(info_list) do
    local info = util_split_wstring(info_list[i], ",")
    if table.getn(info) >= 7 then
      local auction_uid = nx_string(info[1])
      local item_config = nx_string(info[2])
      local item_amount = nx_int(info[3])
      local bind = nx_int(info[4])
      local price = nx_int(info[5])
      local buyer_name = nx_widestr(info[6])
      local time = nx_double(info[7])
      gsp_histroy_add(form, auction_uid, item_config, item_amount, bind, price, buyer_name, time)
    end
  end
  form.gsb_histroy.IsEditMode = false
  form.gsb_histroy:ResetChildrenYPos()
  select_first_histroy(form)
end
function get_price_add(item_config)
  local common_array = nx_value("common_array")
  local price_add = common_array:FindChild(ARRAY_NAME_ITEM, nx_string(item_config))
  if price_add == nil then
    price_add = common_array:FindChild(ARRAY_NAME_ITEM, "price_add")
  end
  return nx_number(price_add)
end
function load_ini(form)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\WorldAuction\\WorldAuction.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("item")
  if sec_index < 0 then
    return
  end
  common_array:RemoveArray(ARRAY_NAME_ITEM)
  common_array:AddArray(ARRAY_NAME_ITEM, form, 600, true)
  local count = ini:GetSectionItemCount(sec_index)
  for i = 0, count do
    local str = ini:GetSectionItemValue(sec_index, i)
    local item_s = util_split_string(str, ",")
    if table.getn(item_s) == 3 then
      common_array:AddChild(ARRAY_NAME_ITEM, nx_string(item_s[1]), nx_int(item_s[3]))
    end
  end
  sec_index = ini:FindSectionIndex("property")
  if sec_index < 0 then
    return
  end
  local price_add = ini:ReadInteger(sec_index, "price_add", "")
  common_array:AddChild(ARRAY_NAME_ITEM, "price_add", nx_int(price_add))
end
function set_sl_auction(form, auction_uid)
  form.sl_auction = nx_string(auction_uid)
  if form.sl_auction == "" then
    form.gb_info_2.Visible = false
  else
    form.gb_info_2.Visible = true
    local gb = form.gsb_auction:Find("gb_1_" .. form.sl_auction)
    if nx_is_valid(gb) then
      local ig = gb:Find("ig_1_item_" .. nx_string(auction_uid))
      local lbl_price = gb:Find("lbl_1_price_" .. nx_string(auction_uid))
      local lbl_competer = gb:Find("lbl_1_competer_" .. nx_string(auction_uid))
      local item_config = ig.config
      local item_amount = ig.count
      local bind = ig.bind
      local color_level = nx_number(get_prop_in_ItemQuery(item_config, nx_string("ColorLevel")))
      local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", item_config, "Photo")
      form.ig_info_1:AddItem(0, nx_string(photo), nx_widestr(item_config), nx_int(item_amount), 0)
      form.ig_info_1.config = item_config
      form.ig_info_1.count = item_amount
      form.ig_info_1.bind = bind
      form.lbl_info_1_name.Text = util_text(item_config)
      form.lbl_info_1_name.ForeColor = color[color_level][1]
      form.lbl_info_1_amount.Text = nx_widestr(item_amount)
      form.mltbox_info_1_price.HtmlText = lbl_price.HtmlText
      local price_min = lbl_price.price
      price_min = price_min + get_price_add(item_config)
      form.gb_info_1.price_min = price_min
      form.gb_info_1.price_add = get_price_add(item_config)
      set_ipt_money(form, 0)
      set_ipt_money(form, lbl_price.price)
    end
  end
end
function set_sl_histroy(form, auction_uid)
  form.sl_histroy = nx_string(auction_uid)
  if form.sl_histroy == "" then
    form.gb_info_2.Visible = false
  else
    form.gb_info_2.Visible = true
    local gb = form.gsb_histroy:Find("gb_2_" .. form.sl_histroy)
    if nx_is_valid(gb) then
      local ig = gb:Find("ig_2_item_" .. nx_string(auction_uid))
      local lbl_price = gb:Find("lbl_2_price_" .. nx_string(auction_uid))
      local lbl_buyer = gb:Find("lbl_2_buyer_" .. nx_string(auction_uid))
      local lbl_time = gb:Find("lbl_2_time_" .. nx_string(auction_uid))
      local item_config = ig.config
      local item_amount = ig.count
      local bind = ig.bind
      local color_level = nx_number(get_prop_in_ItemQuery(item_config, nx_string("ColorLevel")))
      local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", item_config, "Photo")
      form.ig_info_2:AddItem(0, nx_string(photo), nx_widestr(item_config), nx_int(item_amount), 0)
      form.ig_info_2.config = item_config
      form.ig_info_2.count = item_amount
      form.ig_info_2.bind = bind
      form.lbl_info_2_name.Text = util_text(item_config)
      form.lbl_info_2_name.ForeColor = color[color_level][1]
      form.lbl_info_2_amount.Text = nx_widestr(item_amount)
      form.lbl_info_2_buyer.Text = nx_widestr(lbl_buyer.Text)
      form.mltbox_info_2_price.HtmlText = lbl_price.HtmlText
      form.lbl_info_2_time.Text = lbl_time.Text
      if form.lbl_info_2_buyer.Text == nx_widestr(util_text("world_auction_none")) then
        form.lbl_liupai.Visible = true
      else
        form.lbl_liupai.Visible = false
      end
    end
  end
end
function set_ipt_money(form, price)
  local ding = math.floor(nx_number(price) / 1000000)
  local liang = math.floor(nx_number(price) % 1000000 / 1000)
  local wen = math.floor(nx_number(price) % 1000)
  form.ipt_1_ding.Text = nx_widestr(ding)
  form.ipt_1_liang.Text = nx_widestr(liang)
  form.ipt_1_wen.Text = nx_widestr(wen)
end
function show_info(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local attation_nums = 0
  form.gsb_auction.IsEditMode = true
  local show_nums = form.gsb_auction:GetChildControlCount()
  for i = 0, form.gsb_auction:GetChildControlCount() do
    local gb = form.gsb_auction:GetChildControlByIndex(i)
    if nx_is_valid(gb) then
      local auction_uid = gb.auction_uid
      gb.Visible = true
      local cbtn = gb:Find("cbtn_1_bg_" .. nx_string(auction_uid))
      local cbtn_attation = gb:Find("cbtn_1_attation_" .. nx_string(auction_uid))
      local row = client_player:FindRecordRow(REC_WA_ATTATION, 0, nx_string(auction_uid))
      if nx_int(row) < nx_int(0) then
        cbtn_attation.Checked = false
        if form.sl_type == 2 then
          gb.Visible = false
          show_nums = show_nums - 1
          if form.sl_auction == gb.auction_uid then
            set_sl_auction(form, "")
            cbtn.Checked = false
            select_first(form)
          end
        end
      else
        cbtn_attation.Checked = true
        attation_nums = attation_nums + 1
      end
    end
  end
  form.gsb_auction:ResetChildrenYPos()
  form.gsb_auction.IsEditMode = false
  if attation_nums <= 0 then
    form.rbtn_2.Enabled = false
    if form.rbtn_2.Checked then
      form.rbtn_1.Checked = true
    end
  else
    form.rbtn_2.Enabled = true
  end
end
function gsp_auction_add(form, auction_uid, item_config, item_amount, bind, price, competer, end_time)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local self_name = client_player:QueryProp("Name")
  local gb = create_ctrl("GroupBox", "gb_1_" .. nx_string(auction_uid), form.gb_mod_1, form.gsb_auction)
  if nx_is_valid(gb) then
    gb.auction_uid = nx_string(auction_uid)
    local cbtn = create_ctrl("CheckButton", "cbtn_1_bg_" .. nx_string(auction_uid), form.cbtn_1_bg, gb)
    cbtn.auction_uid = nx_string(auction_uid)
    nx_bind_script(cbtn, nx_current())
    nx_callback(cbtn, "on_checked_changed", "on_cbtn_1_bg_checked_changed")
    local ig = create_ctrl("ImageGrid", "ig_1_item_" .. nx_string(auction_uid), form.ig_1_item, gb)
    ig.config = item_config
    ig.count = item_amount
    ig.bind = bind
    nx_bind_script(ig, nx_current())
    nx_callback(ig, "on_mousein_grid", "on_ig_mousein_grid")
    nx_callback(ig, "on_mouseout_grid", "on_ig_mouseout_grid")
    local lbl_bind = create_ctrl("Label", "lbl_1_bind_" .. nx_string(auction_uid), form.lbl_1_bind, gb)
    if nx_int(bind) == nx_int(bind) then
      lbl_bind.Visible = true
    else
      lbl_bind.Visible = false
    end
    local cbtn_attation = create_ctrl("CheckButton", "cbtn_1_attation_" .. nx_string(auction_uid), form.cbtn_1_attation, gb)
    cbtn_attation.auction_uid = nx_string(auction_uid)
    cbtn_attation.ClickEvent = true
    nx_bind_script(cbtn_attation, nx_current())
    nx_callback(cbtn_attation, "on_click", "on_cbtn_1_attation_click")
    local lbl_name = create_ctrl("Label", "lbl_1_name_" .. nx_string(auction_uid), form.lbl_1_name, gb)
    local lbl_competer = create_ctrl("Label", "lbl_1_competer_" .. nx_string(auction_uid), form.lbl_1_competer, gb)
    local lbl_price = create_ctrl("MultiTextBox", "lbl_1_price_" .. nx_string(auction_uid), form.lbl_1_price, gb)
    local lbl_time = create_ctrl("Label", "lbl_1_time_" .. nx_string(auction_uid), form.lbl_1_time, gb)
    local mltbox_price = create_ctrl("MultiTextBox", "mltbox_1_price_" .. nx_string(auction_uid), form.mltbox_1_price, gb)
    create_ctrl("Label", "lbl_1_playername_" .. nx_string(auction_uid), form.lbl_1_playername, gb)
    local color_level = nx_number(get_prop_in_ItemQuery(item_config, nx_string("ColorLevel")))
    local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", item_config, "Photo")
    ig:AddItem(0, nx_string(photo), nx_widestr(item_config), nx_int(count), 0)
    lbl_name.Text = util_text(item_config)
    lbl_name.ForeColor = color[color_level][1]
    lbl_competer.Text = nx_widestr(competer)
    if nx_widestr(competer) == nx_widestr(self_name) then
      lbl_competer.ForeColor = fore_color_you
    else
      lbl_competer.ForeColor = fore_color_other
    end
    lbl_price.HtmlText = nx_widestr(get_money_text(price))
    lbl_price.price = price
    lbl_time.Text = get_time_text(get_remain_time(end_time))
    lbl_time.end_time = end_time
    if nx_widestr(competer) == nx_widestr("") then
      lbl_competer.Text = nx_widestr(util_text("world_auction_none"))
    end
  end
end
function gsp_histroy_add(form, auction_uid, item_config, item_amount, bind, price, buyer, time)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local self_name = client_player:QueryProp("Name")
  local gb = create_ctrl("GroupBox", "gb_2_" .. nx_string(auction_uid), form.gb_mod_2, form.gsb_histroy)
  if nx_is_valid(gb) then
    gb.auction_uid = nx_string(auction_uid)
    local cbtn = create_ctrl("CheckButton", "cbtn_2_bg_" .. nx_string(auction_uid), form.cbtn_2_bg, gb)
    cbtn.auction_uid = nx_string(auction_uid)
    nx_bind_script(cbtn, nx_current())
    nx_callback(cbtn, "on_checked_changed", "on_cbtn_2_bg_checked_changed")
    local ig = create_ctrl("ImageGrid", "ig_2_item_" .. nx_string(auction_uid), form.ig_2_item, gb)
    ig.config = item_config
    ig.count = item_amount
    ig.bind = bind
    nx_bind_script(ig, nx_current())
    nx_callback(ig, "on_mousein_grid", "on_ig_mousein_grid")
    nx_callback(ig, "on_mouseout_grid", "on_ig_mouseout_grid")
    local lbl_bind = create_ctrl("Label", "lbl_2_bind_" .. nx_string(auction_uid), form.lbl_2_bind, gb)
    if nx_int(bind) == nx_int(1) then
      lbl_bind.Visible = true
    else
      lbl_bind.Visible = false
    end
    local lbl_name = create_ctrl("Label", "lbl_2_name_" .. nx_string(auction_uid), form.lbl_2_name, gb)
    local lbl_buyer = create_ctrl("Label", "lbl_2_buyer_" .. nx_string(auction_uid), form.lbl_2_buyer, gb)
    local lbl_price = create_ctrl("MultiTextBox", "lbl_2_price_" .. nx_string(auction_uid), form.lbl_2_price, gb)
    local lbl_time = create_ctrl("Label", "lbl_2_time_" .. nx_string(auction_uid), form.lbl_2_time, gb)
    local mltbox_price = create_ctrl("MultiTextBox", "mltbox_2_price_" .. nx_string(auction_uid), form.mltbox_2_price, gb)
    create_ctrl("Label", "lbl_2_playername_" .. nx_string(auction_uid), form.lbl_2_playername, gb)
    local color_level = nx_number(get_prop_in_ItemQuery(item_config, nx_string("ColorLevel")))
    local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", item_config, "Photo")
    ig:AddItem(0, nx_string(photo), nx_widestr(item_config), nx_int(count), 0)
    lbl_name.Text = util_text(item_config)
    lbl_name.ForeColor = color[color_level][1]
    lbl_buyer.Text = nx_widestr(buyer)
    if nx_widestr(buyer) == nx_widestr(self_name) then
      lbl_buyer.ForeColor = fore_color_you
    else
      lbl_buyer.ForeColor = fore_color_other
    end
    lbl_price.HtmlText = nx_widestr(get_money_text(price))
    lbl_time.Text = nx_widestr(decode_time(time))
    if nx_widestr(buyer) == nx_widestr("") then
      lbl_buyer.Text = nx_widestr(util_text("world_auction_none"))
      lbl_price.HtmlText = nx_widestr(util_text("world_auction_price_none"))
    end
  end
end
function decode_time(d_time)
  local year, month, day, hour, min, sec = nx_function("ext_decode_date", d_time)
  local min_str = ""
  if nx_number(min) < 10 then
    min_str = "0" .. nx_string(min)
  else
    min_str = nx_string(min)
  end
  local sec_str = ""
  if nx_number(sec) < 10 then
    sec_str = "0" .. nx_string(sec)
  else
    sec_str = nx_string(sec)
  end
  return nx_string(month) .. "/" .. nx_string(day) .. " " .. nx_string(hour) .. ":" .. min_str
end
function get_money_text(price)
  local ding = math.floor(nx_number(price) / 1000000)
  local liang = math.floor(nx_number(price) % 1000000 / 1000)
  local wen = math.floor(nx_number(price) % 1000)
  local gui = nx_value("gui")
  local htmlTextYinKa = nx_widestr("")
  if 0 < ding then
    local text = gui.TextManager:GetText("ui_ding")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(ding) .. nx_widestr(htmlText)
  end
  if 0 < liang then
    local text = gui.TextManager:GetText("ui_liang")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(" ") .. nx_widestr(liang) .. nx_widestr(htmlText)
  end
  if 0 < wen then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(" ") .. nx_widestr(wen) .. nx_widestr(htmlText)
  end
  if nx_number(price) == 0 then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinKa = htmlTextYinKa .. nx_widestr("0") .. nx_widestr(htmlText)
  end
  return htmlTextYinKa
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
function get_remain_time(end_time)
  local now = get_sys_time()
  return nx_int((end_time - now) * 24 * 3600)
end
function on_rec_wa_attation_change(form, recordname, optype, row, clomn)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not client_player:FindRecord(recordname) then
    return 0
  end
  if optype == "add" or optype == "update" or optype == "del" or optype == "clear" then
    show_info(form)
  end
end
function on_captial2_changed(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local capital1 = client_player:QueryProp("CapitalType2")
  local ding1 = math.floor(capital1 / 1000000)
  local liang1 = math.floor(capital1 % 1000000 / 1000)
  local wen1 = math.floor(capital1 % 1000)
  local gui = nx_value("gui")
  local htmlTextYinKa = nx_widestr("")
  if 0 < ding1 then
    local text = gui.TextManager:GetText("ui_ding")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(ding1) .. nx_widestr(htmlText)
  end
  if 0 < liang1 then
    local text = gui.TextManager:GetText("ui_liang")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(" ") .. nx_widestr(liang1) .. nx_widestr(htmlText)
  end
  if 0 < wen1 then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(" ") .. nx_widestr(wen1) .. nx_widestr(htmlText)
  end
  if capital1 == 0 then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinKa = htmlTextYinKa .. nx_widestr("0") .. nx_widestr(htmlText)
  end
  form.mltbox_1.HtmlText = util_text("ui_auction_price_own") .. htmlTextYinKa
end
function get_sys_time()
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  return nx_double(msg_delay:GetServerDateTime())
end
function a(info)
  nx_msgbox(nx_string(info))
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  ctrl.Name = name
  return ctrl
end
