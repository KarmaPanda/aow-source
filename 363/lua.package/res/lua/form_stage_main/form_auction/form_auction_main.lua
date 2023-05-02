require("util_gui")
require("util_functions")
require("util_static_data")
require("tips_data")
require("custom_sender")
require("define\\gamehand_type")
require("share\\itemtype_define")
require("goods_grid")
require("share\\view_define")
require("form_stage_main\\switch\\switch_define")
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
local tax = {
  [0] = 25,
  [1] = 50,
  [2] = 75,
  [3] = 100
}
local AUCTION_SELL_TAX_MAX = 50
local AUCTION_SELL_TAX_MIN = 50
local AUCTION_SELL_TAX_DENOMINATOR = 10000
local AUCTION_COMPETE_RATE = 5
local AUCTION_CAPITAL2_NUMBER_MAX = 999999999
NODE_PROP = {
  first = {
    ForeColor = "255,255,255,255",
    NodeBackImage = "gui\\special\\market_new\\main_menu.png",
    NodeFocusImage = "gui\\special\\market_new\\main_menu.png",
    NodeSelectImage = "gui\\special\\market_new\\main_menu.png",
    ItemHeight = 27,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 1,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 20,
    TextOffsetY = 6,
    Font = "font_treeview"
  },
  second = {
    ForeColor = "255,255,249,194",
    NodeBackImage = "gui\\special\\market_new\\btn_2_out.png",
    NodeFocusImage = "gui\\special\\market_new\\btn_2_on.png",
    NodeSelectImage = "gui\\special\\market_new\\btn_2_down.png",
    ItemHeight = 22,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 0,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 25,
    TextOffsetY = 3,
    Font = "font_treeview"
  },
  third = {
    ForeColor = "255,255,255,255",
    NodeBackImage = "gui\\common\\treeview\\tree_2_out.png",
    NodeFocusImage = "gui\\common\\treeview\\tree_2_on.png",
    NodeSelectImage = "gui\\common\\treeview\\tree_2_on.png",
    ItemHeight = 20,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 0,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 38,
    TextOffsetY = 2,
    Font = "font_treeview"
  },
  fourth = {
    ForeColor = "255,182,177,171",
    NodeBackImage = "gui\\common\\treeview\\tree_3_out.png",
    NodeFocusImage = "gui\\common\\treeview\\tree_3_on.png",
    NodeSelectImage = "gui\\common\\treeview\\tree_3_on.png",
    ItemHeight = 20,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 0,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 50,
    TextOffsetY = 2,
    Font = "font_treeview"
  }
}
local CTS_SUB_AUCTION_GET_COMPETE_INFO = 0
local CTS_SUB_AUCTION_GET_SELLING_INFO = 1
local CTS_SUB_AUCTION_UP_ITEM = 2
local CTS_SUB_AUCTION_DOWN_ITEM = 3
local CTS_SUB_AUCTION_COMPETE = 4
local CTS_SUB_AUCTION_BUY = 5
local CTS_SUB_AUCTION_SEARCH = 6
local CTS_SUB_AUCTION_SELL_ADD = 7
local CTS_SUB_AUCTION_SELL_CANCEL = 8
local TOTAL_RECORD_COUNT = 30
local COLOR_LEVEL_SELECT_ALL = 0
local COLOR_LEVEL_COUNT = 6
local SEGMENT_SEARCH_CONFIG_MAX_AMOUNT = 100
local SEARCH_SORT_BY_PRICE = 0
local SEARCH_SORT_BY_TIME = 1
local SEARCH_SORT_BY_QUALITY = 2
local NUMS_PRE_PAGE = 30
local market_item_table = {}
local market_search_table = {}
local ItemSifter = {}
local sifter_tree_node_tab = {}
local MIN_SERACH_TEXT_LEN = 4
local MAX_SERACH_DATA_LEN = 2048
local LING_PNG = "<img src=\"gui\\common\\money\\liang.png\" valign=\"center\" only=\"line\" data=\"\" />"
local SEARCH_REFRESH_TAB = {
  item_type = 0,
  config = "",
  from = 1,
  to = NUMS_PRE_PAGE,
  desc = 0,
  sifter_config = "",
  sifter_treasure = "",
  sort_type = SEARCH_SORT_BY_PRICE
}
local FORM_NAME = "form_stage_main\\form_auction\\form_auction_main"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.lbl_waiting.Visible = false
  self.tree_sifter = ""
  self.item_type = 0
  self.config = ""
  self.desc = 0
  self.sort_type = SEARCH_SORT_BY_PRICE
  self.search_word = ""
  self.combo_search_2.Visible = false
  self.lbl_desc_up.Visible = true
  self.lbl_desc_down.Visible = false
  self.lbl_time_left_up.Visible = false
  self.lbl_time_left_down.Visible = false
  self.lbl_quality_up.Visible = false
  self.lbl_quality_down.Visible = false
  self.page = 1
  self.compete_page = 1
  self.sell_page = 1
  self.compete_count = 0
  self.sell_count = 0
  self.info_from = 1
  self.info_to = NUMS_PRE_PAGE
  self.sl_search = ""
  self.sl_compete = ""
  self.sl_sell = ""
  create_tree(self)
  init_search_info(self)
  init_combobox_color_index(self)
  init_combobox_time_index(self)
  init_combobox_group(self)
  self.rbtn_search.Checked = true
  self.cbtn_price.Checked = true
  self.ig_sell:SetBindIndex(nx_int(0), nx_int(1))
  self.ig_sell.typeid = VIEWPORT_AUCTION_SELL_BOX
  load_sifter_ini(self)
  self.groupbox_sifter.item_type = 0
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_AUCTION_SELL_BOX, self.ig_sell, FORM_NAME, "on_additem_view_oper")
  databinder:AddRolePropertyBind("CapitalType2", "int", self, FORM_NAME, "on_captial2_changed")
  load_ini(self)
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    if not switch_manager:CheckSwitchEnable(nx_int(ST_FUNCTION_AUCTION_COMPANY_OPERATE)) then
      self.cbtn_fuzzy_search.Visible = false
      self.lbl_fuzzy_search.Visible = false
    end
    if not switch_manager:CheckSwitchEnable(nx_int(ST_FUNCTION_AUCTION_COMPANY_OPERATE)) then
      self.btn_compete.Enabled = false
      self.btn_buy.Enabled = false
      self.btn_compete_2.Enabled = false
      self.btn_buy_2.Enabled = false
      self.btn_up.Enabled = false
    end
  end
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_main_form_close(self)
  ui_destroy_attached_form(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(self.ig_sell)
  end
  remove_sell_grid_item(self)
  save_ini(self)
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
function open_form()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    form = util_get_form(FORM_NAME, true)
    form:Show()
    form.Visible = true
    nx_execute("util_gui", "ui_show_attached_form", form)
    return
  end
  if not form.Visible then
    form:Show()
    form.Visible = true
  end
  nx_execute("util_gui", "ui_show_attached_form", form)
end
function open_form_and_search(item_name)
  open_form()
  local form = util_get_form(FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  form.ipt_search.Text = nx_widestr(item_name)
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_rbtn_search_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_search.Visible = true
    form.gb_compete.Visible = false
    form.gb_sell.Visible = false
    remove_sell_grid_item(form)
  end
  if form.combo_search_1.DroppedDown then
    form.combo_search_1.DroppedDown = false
  end
  if form.combo_search_2.DroppedDown then
    form.combo_search_2.DroppedDown = false
  end
end
function on_rbtn_compete_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_search.Visible = false
    form.gb_compete.Visible = true
    form.gb_sell.Visible = false
    form.compete_page = 1
    begin_wait(form)
    local from = 1 + NUMS_PRE_PAGE * (form.compete_page - 1)
    local to = NUMS_PRE_PAGE * form.compete_page
    custom_auction(CTS_SUB_AUCTION_GET_COMPETE_INFO, from, to)
    form.info_from = from
    form.info_to = to
    remove_sell_grid_item(form)
  end
  if form.combo_search_1.DroppedDown then
    form.combo_search_1.DroppedDown = false
  end
  if form.combo_search_2.DroppedDown then
    form.combo_search_2.DroppedDown = false
  end
end
function on_rbtn_sell_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_search.Visible = false
    form.gb_compete.Visible = false
    form.gb_sell.Visible = true
    form.sell_page = 1
    begin_wait(form)
    local from = 1 + NUMS_PRE_PAGE * (form.sell_page - 1)
    local to = NUMS_PRE_PAGE * form.sell_page
    custom_auction(CTS_SUB_AUCTION_GET_SELLING_INFO, from, to)
    form.info_from = from
    form.info_to = to
    remove_sell_grid_item(form)
  end
  if form.combo_search_1.DroppedDown then
    form.combo_search_1.DroppedDown = false
  end
  if form.combo_search_2.DroppedDown then
    form.combo_search_2.DroppedDown = false
  end
end
function create_tree(form)
  if not nx_is_valid(form) then
    return
  end
  local root = form.tree_ex1:CreateRootNode(nx_widestr("Root"))
  form.tree_ex1:BeginUpdate()
  local item_root = root:CreateNode(nx_widestr(util_text("ui_market_node")))
  set_node_prop(item_root, "first")
  form.item_root = item_root
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\market_prop.ini")
  if not nx_is_valid(ini) then
    return
  end
  local main_count = ini:GetSectionCount()
  for i = 0, main_count - 1 do
    local main_name = ini:GetSectionByIndex(i)
    local main_root = item_root:CreateNode(nx_widestr(util_text(main_name)))
    set_node_prop(main_root, "second")
    local sub_count = ini:GetSectionItemCount(i)
    for j = 0, sub_count - 1 do
      local sub_name = ini:GetSectionItemKey(i, j)
      local sub_info = ini:GetSectionItemValue(i, j)
      local sub_root = main_root:CreateNode(nx_widestr(util_text(sub_name)))
      local sub_list = util_split_string(sub_info, ",")
      sub_root.item_type = sub_list[1]
      if nx_int(table.getn(sub_list)) >= nx_int(2) then
        sub_root.select_color = sub_list[2]
      end
      set_node_prop(sub_root, "third")
      local ini_itemtype = nx_execute("util_functions", "get_ini", "share\\Rule\\market_itemtype.ini")
      if nx_is_valid(ini_itemtype) then
        local sec_index = ini_itemtype:FindSectionIndex(nx_string(sub_list[1]))
        if 0 <= sec_index then
          local count = ini_itemtype:GetSectionItemCount(sec_index)
          for k = 0, count - 1 do
            local ui = ini_itemtype:GetSectionItemKey(sec_index, k)
            local sifter_info = ini_itemtype:GetSectionItemValue(sec_index, k)
            local fourth_root = sub_root:CreateNode(nx_widestr(util_text(ui)))
            fourth_root.item_type = sub_root.item_type
            fourth_root.sifter_info = sifter_info
            set_node_prop(fourth_root, "fourth")
          end
        end
      end
    end
  end
  root.Expand = true
  item_root.Expand = true
  form.tree_ex1:EndUpdate()
end
function on_tree_ex1_left_click(tree, node)
  local form = tree.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_id_equal(form.item_root, node) then
    reset_tree_node(form)
  end
end
function on_tree_ex1_select_changed(self, cur_node)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.cbtn_fuzzy_search.Checked = false
  reset_page(form)
  clear_search(form)
  form.item_type = 0
  form.tree_sifter = ""
  form.config = ""
  if nx_find_custom(cur_node, "item_type") then
    begin_wait(form)
    form.item_type = cur_node.item_type
    show_sifter_treasure(form, form.item_type)
    if nx_find_custom(cur_node, "sifter_info") then
      form.tree_sifter = cur_node.sifter_info
    end
    send_search(form)
  end
end
function on_ipt_search_get_focus(ipt)
  local gui = nx_value("gui")
  gui.hyperfocused = ipt
  if nx_string(ipt.Text) == nx_string("") or ipt.Text == nil then
    local form = ipt.ParentForm
    if nx_is_valid(form) then
      show_search_item(form)
    end
  end
end
function on_ipt_search_changed(ipt)
  local form = ipt.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.search_word = nx_widestr("")
  local serach_text = ipt.Text
  if nx_string(serach_text) == nx_string("") then
    show_search_item(form)
    return
  end
  if nx_string(serach_text) == nx_string(util_text("ui_trade_search_key")) then
    return
  end
  if string.find(nx_string(serach_text), "%w") then
    return
  end
  local gui = nx_value("gui")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  form.combo_search_2.Visible = false
  form.combo_search_2.DroppedDown = false
  form.combo_search_1.Visible = true
  form.combo_search_1.DropListBox:ClearString()
  local search_table = ItemQuery:FindItemsByName(nx_widestr(serach_text))
  market_item_table = {}
  for i = 1, nx_number(table.getn(search_table)) do
    local item_config = search_table[i]
    local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
    if bExist == true then
      local IsMarketItem = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("IsMarketItem"))
      if nx_int(IsMarketItem) == nx_int(1) then
        local static_data = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("LogicPack"))
        local bind_type = item_static_query(nx_int(static_data), "BindType", STATIC_DATA_ITEM_LOGIC)
        local item_type = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("ItemType"))
        if nx_int(bind_type) ~= nx_int(1) and nx_number(item_type) ~= 146 and (nx_int(form.item_type) == nx_int(0) or nx_int(form.item_type) == nx_int(item_type)) and gui.TextManager:IsIDName(search_table[i]) then
          form.combo_search_1.DropListBox:AddString(nx_widestr(util_text(search_table[i])))
          table.insert(market_item_table, search_table[i])
        end
      end
    end
  end
  if form.cbtn_fuzzy_search.Checked then
    update_fuzzy_search_config_list(form)
  elseif not form.combo_search_1.DroppedDown then
    form.combo_search_1.DroppedDown = true
  end
end
function on_combo_color_selected(combo)
  send_search(combo.ParentForm)
end
function on_combo_search_selected(combo)
  local form = combo.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = combo.DropListBox.SelectIndex
  if index < table.getn(market_item_table) then
    form.config = market_item_table[index + 1]
  end
  form.ipt_search.Text = combo.Text
  form.search_word = nx_widestr(combo.Text)
  combo.Text = nx_widestr("")
end
function on_combo_search_2_selected(combo)
  local form = combo.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = combo.DropListBox.SelectIndex
  form.ipt_search.Text = combo.Text
  form.search_word = nx_widestr(combo.Text)
  combo.Text = nx_widestr("")
end
function record_search_item(form)
  local item_config = form.config
  if item_config == nil or nx_string(item_config) == "" then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  if not ItemQuery:FindItemByConfigID(nx_string(item_config)) then
    return
  end
  for i = 1, table.getn(market_search_table) do
    if nx_string(item_config) == nx_string(market_search_table[i]) then
      table.remove(market_search_table, i)
    end
  end
  local curRowCount = table.getn(market_search_table)
  if nx_int(curRowCount) >= nx_int(TOTAL_RECORD_COUNT) then
    table.remove(market_search_table, 1)
  end
  table.insert(market_search_table, nx_string(item_config))
end
function add_record_search_item(form)
  if not nx_is_valid(form) then
    return
  end
  local item_config = form.search_word
  if item_config == nil or nx_string(item_config) == "" then
    return
  end
  for i = table.getn(market_search_table), 1, -1 do
    if nx_string(item_config) == nx_string(market_search_table[i]) then
      table.remove(market_search_table, i)
    end
  end
  local curRowCount = table.getn(market_search_table)
  if nx_int(curRowCount) >= nx_int(TOTAL_RECORD_COUNT) then
    table.remove(market_search_table, 1)
  end
  table.insert(market_search_table, nx_string(item_config))
end
function show_search_item(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(table.getn(market_search_table)) <= nx_int(0) then
    return
  end
  form.combo_search_1.Visible = false
  form.combo_search_1.DroppedDown = false
  form.combo_search_2.Visible = true
  form.combo_search_2.DropListBox:ClearString()
  for i = table.getn(market_search_table), 1, -1 do
    form.combo_search_2.DropListBox:AddString(nx_widestr(util_text(market_search_table[i])))
  end
  if not form.combo_search_2.DroppedDown then
    form.combo_search_2.DroppedDown = true
  end
end
function on_btn_search_click(btn)
  local form = btn.ParentForm
  send_search(form)
end
function on_btn_reset_click(btn)
  local form = btn.ParentForm
  if nx_find_custom(form, "item_root") and nx_is_valid(form.item_root) then
    reset_tree_node(form)
  end
  form.item_type = 0
  form.config = ""
  init_search_info(form)
  if form.combo_search_1.DroppedDown then
    form.combo_search_1.DroppedDown = false
  end
  if form.combo_search_2.DroppedDown then
    form.combo_search_2.DroppedDown = false
  end
  form.combo_color.DropListBox.SelectIndex = COLOR_LEVEL_SELECT_ALL
  form.combo_color.Text = nx_widestr(form.combo_color.DropListBox:GetString(COLOR_LEVEL_SELECT_ALL))
  if form.combo_color.DroppedDown then
    form.combo_color.DroppedDown = false
  end
  form.cbtn_fuzzy_search.Checked = false
  form.cbtn_desc.Checked = false
  form.cbtn_quality.Checked = false
  form.cbtn_time_left.Checked = false
  form.cbtn_price.Checked = true
end
function on_btn_refresh_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(SEARCH_REFRESH_TAB.item_type) == nx_int(0) and nx_string(SEARCH_REFRESH_TAB.config) == nx_string("") then
    return
  end
  begin_wait(form)
  custom_auction(CTS_SUB_AUCTION_SEARCH, nx_int(SEARCH_REFRESH_TAB.item_type), nx_string(SEARCH_REFRESH_TAB.config), nx_int(SEARCH_REFRESH_TAB.from), nx_int(SEARCH_REFRESH_TAB.to), nx_int(SEARCH_REFRESH_TAB.desc), nx_string(SEARCH_REFRESH_TAB.sifter_config), nx_string(SEARCH_REFRESH_TAB.sifter_treasure), nx_int(SEARCH_REFRESH_TAB.sort_type))
end
function on_btn_page_up_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.page <= 1 then
    return
  end
  form.page = form.page - 1
  refresh_page_btn(form)
  begin_wait(form)
  send_search(form)
end
function on_btn_page_down_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "total_count") then
    return
  end
  if form.page >= math.floor(nx_number(form.total_count - 1) / NUMS_PRE_PAGE) + 1 then
    return
  end
  form.page = form.page + 1
  refresh_page_btn(form)
  begin_wait(form)
  send_search(form)
end
function refresh_page_btn(form)
  form.btn_page_up.Enabled = false
  form.btn_page_down.Enabled = false
  if nx_find_custom(form, "total_count") then
    if form.page > 1 then
      form.btn_page_up.Enabled = true
    end
    if form.page < math.floor(nx_number(form.total_count - 1) / NUMS_PRE_PAGE) + 1 then
      form.btn_page_down.Enabled = true
    end
  end
end
function on_btn_compete_click(btn)
  local form = btn.ParentForm
  local ding = nx_number(form.ipt_compete_ding.Text)
  local liang = nx_number(form.ipt_compete_liang.Text)
  local wen = nx_number(form.ipt_compete_wen.Text)
  local price = ding * 1000000 + liang * 1000 + wen
  local gb = form.gsb_search:Find("gb_search_" .. form.sl_search)
  if not nx_is_valid(gb) then
    return
  end
  local row = nx_int(gb.row)
  local lbl_name = gb:Find("lbl_1_name_" .. form.sl_search)
  local lbl_price_min = gb:Find("lbl_1_price_min_" .. form.sl_search)
  local lbl_price_max = gb:Find("lbl_1_price_max_" .. form.sl_search)
  local lbl_competitor = gb:Find("lbl_1_competitor_" .. form.sl_search)
  local lbl_seller = gb:Find("lbl_1_seller_" .. form.sl_search)
  local price_min = nx_number(lbl_price_min.price)
  local price_max = nx_number(lbl_price_max.price)
  local seller = nx_widestr(lbl_seller.Text)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local self_name = client_player:QueryProp("Name")
  if nx_widestr(self_name) == nx_widestr(seller) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_auction_022"))
    return
  end
  if nx_widestr(self_name) == nx_widestr(lbl_competitor.Text) or nx_widestr(util_text("auction_you")) == nx_widestr(lbl_competitor.Text) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_auction_023"))
    return
  end
  if nx_widestr(lbl_competitor.Text) ~= nx_widestr("") then
    price_min = math.floor((price_min * (100 + AUCTION_COMPETE_RATE) - 1) / 100) + 1
  end
  if price_max <= price_min then
    price_min = price_max
  end
  if price < price_min then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_auction_016"), AUCTION_COMPETE_RATE)
    return
  end
  if price >= price_max then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_auction_027"))
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText("auction_compete_confirm", nx_int(price), nx_widestr(lbl_name.Text), nx_int(gb.count))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    custom_auction(CTS_SUB_AUCTION_COMPETE, nx_string(form.sl_search), row, nx_int(price))
  end
end
function on_btn_buy_click(btn)
  local form = btn.ParentForm
  local gb = form.gsb_search:Find("gb_search_" .. form.sl_search)
  if not nx_is_valid(gb) then
    return
  end
  local row = nx_int(gb.row)
  local lbl_name = gb:Find("lbl_1_name_" .. form.sl_search)
  local lbl_price_max = gb:Find("lbl_1_price_max_" .. form.sl_search)
  local price = nx_number(lbl_price_max.price)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText("auction_buy_confirm", nx_int(price), nx_widestr(lbl_name.Text), nx_int(gb.count))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    custom_auction(CTS_SUB_AUCTION_BUY, nx_string(form.sl_search), row, nx_int(price))
  end
end
function on_btn_compete_2_click(btn)
  local form = btn.ParentForm
  local ding = nx_number(form.ipt_compete_ding_2.Text)
  local liang = nx_number(form.ipt_compete_liang_2.Text)
  local wen = nx_number(form.ipt_compete_wen_2.Text)
  local price = ding * 1000000 + liang * 1000 + wen
  local gb = form.gsb_compete:Find("gb_compete_" .. form.sl_compete)
  if not nx_is_valid(gb) then
    return
  end
  local row = nx_int(gb.row)
  local lbl_name = gb:Find("lbl_2_name_" .. form.sl_compete)
  local lbl_price_min = gb:Find("lbl_2_price_min_" .. form.sl_compete)
  local lbl_price_max = gb:Find("lbl_2_price_max_" .. form.sl_compete)
  local lbl_competitor = gb:Find("lbl_2_competitor_" .. form.sl_compete)
  local price_min = nx_number(lbl_price_min.price)
  local price_max = nx_number(lbl_price_max.price)
  if nx_widestr(util_text("auction_you")) == nx_widestr(lbl_competitor.Text) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_auction_023"))
    return
  end
  if nx_widestr(lbl_competitor.Text) ~= nx_widestr("") then
    price_min = math.floor((price_min * (100 + AUCTION_COMPETE_RATE) - 1) / 100) + 1
  end
  if price_max <= price_min then
    price_min = price_max
  end
  if price < price_min then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_auction_016"), AUCTION_COMPETE_RATE)
    return
  end
  if price >= price_max then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_auction_027"))
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText("auction_compete_confirm", nx_int(price), nx_widestr(lbl_name.Text), nx_int(gb.count))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    custom_auction(CTS_SUB_AUCTION_COMPETE, nx_string(form.sl_compete), row, nx_int(price))
  end
end
function on_btn_buy_2_click(btn)
  local form = btn.ParentForm
  local gb = form.gsb_compete:Find("gb_compete_" .. form.sl_compete)
  if not nx_is_valid(gb) then
    return
  end
  local row = nx_int(gb.row)
  local lbl_name = gb:Find("lbl_2_name_" .. form.sl_compete)
  local lbl_price_max = gb:Find("lbl_2_price_max_" .. form.sl_compete)
  local price = nx_number(lbl_price_max.price)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText("auction_buy_confirm", nx_int(price), nx_widestr(lbl_name.Text), nx_int(gb.count))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    custom_auction(CTS_SUB_AUCTION_BUY, nx_string(form.sl_compete), row, nx_int(price))
  end
end
function on_additem_view_oper(grid, op_type, view_ident, index)
  if not nx_is_valid(grid) then
    return false
  end
  local form = grid.ParentForm
  local game_client = nx_value("game_client")
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  if op_type == "createview" then
    goods_grid:GridClear(grid)
  elseif op_type == "deleteview" then
    goods_grid:GridClear(grid)
  elseif op_type == "additem" then
    goods_grid:ViewUpdateItem(grid, index)
  elseif op_type == "delitem" then
    goods_grid:GridDelItem(grid, index - 1)
    goods_grid:ViewDeleteItem(grid, index)
  elseif op_type == "updateitem" then
  end
  local item = game_client:GetViewObj(nx_string(view_ident), nx_string(index))
  if nx_is_valid(item) then
    goods_grid:GridClear(grid)
    local item_id = item:QueryProp("ConfigID")
    local item_count = nx_number(item:QueryProp("Amount"))
    local item_type = nx_number(item:QueryProp("ItemType"))
    local color_level = nx_number(item:QueryProp("ColorLevel"))
    local item_data = nx_create("ArrayList", nx_current())
    if not nx_is_valid(item_data) then
      return
    end
    local prop_table = {}
    local proplist = item:GetPropList()
    for i, prop in pairs(proplist) do
      prop_table[prop] = item:QueryProp(prop)
    end
    for prop, value in pairs(prop_table) do
      nx_set_custom(item_data, prop, value)
    end
    goods_grid:GridAddItem(grid, 0, item_data)
    local photo = ""
    if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
      local equip_type = get_prop_in_ItemQuery(item_id, "EquipType")
      local item_back_image = get_grid_treasure_back_image(equip_type, color_level)
      photo = item_query_ArtPack_by_id(item_id, "Photo")
      grid:AddItemEx(0, nx_string(photo), nx_widestr(item_id), nx_int(item_count), -1, nx_string(item_back_image))
    else
      photo = get_prop_in_ItemQuery(item_id, nx_string("Photo"))
      grid:AddItem(0, nx_string(photo), nx_widestr(item_id), nx_int(item_count), 0)
    end
    grid.config = item_id
    grid.count = item_count
    form.mltbox_sell_name.HtmlText = nx_widestr(tips_manager:GetEquipScoreName(item_id, item_data) .. util_text(item_id))
  else
    grid.config = ""
    grid.count = 0
    form.mltbox_sell_name.HtmlText = nx_widestr("")
  end
  reset_up_ipt(form)
  return true
end
function on_combobox_time_index_selected(combobox)
  local form = combobox.ParentForm
  local index = combobox.DropListBox.SelectIndex
  refresh_tax(form)
end
function refresh_tax(form)
  local index = form.combobox_time_index.DropListBox.SelectIndex
  local stack = nx_number(form.ipt_stack.Text)
  local num = nx_number(form.ipt_num.Text)
  local price_max = nx_number(form.ipt_buy_1.Text) * 1000000 + nx_number(form.ipt_buy_2.Text) * 1000 + nx_number(form.ipt_buy_3.Text)
  local price_group = form.combobox_group.DropListBox.SelectIndex
  if nx_number(price_group) == 1 then
    price_max = price_max * stack
  end
  local tax_value = nx_number(AUCTION_SELL_TAX_MAX)
  if tax[index] == nil then
    tax_value = nx_number(AUCTION_SELL_TAX_MAX)
  else
    tax_value = nx_number(tax[index]) * nx_number(price_max) * nx_number(num) / AUCTION_SELL_TAX_DENOMINATOR
  end
  if nx_number(tax_value) > nx_number(AUCTION_SELL_TAX_MAX) then
    tax_value = nx_number(AUCTION_SELL_TAX_MAX)
  elseif nx_number(tax_value) < nx_number(AUCTION_SELL_TAX_MIN) then
    tax_value = nx_number(AUCTION_SELL_TAX_MIN)
  end
  tax_value = nx_number(nx_int(tax_value))
  local ding = math.floor(tax_value / 1000000)
  local liang = math.floor(tax_value % 1000000 / 1000)
  local wen = math.floor(tax_value % 1000)
  form.lbl_tax_ding.Text = nx_widestr(ding)
  form.lbl_tax_liang.Text = nx_widestr(liang)
  form.lbl_tax_wen.Text = nx_widestr(wen)
  form.lbl_tax_ding.Visible = true
  form.lbl_tax_liang.Visible = true
  form.lbl_tax_wen.Visible = true
  form.lbl_sell_ding_tax.Visible = true
  form.lbl_sell_liang_tax.Visible = true
  form.lbl_sell_wen_tax.Visible = true
  if ding == 0 then
    form.lbl_tax_ding.Visible = false
    form.lbl_sell_ding_tax.Visible = false
  end
  if liang == 0 then
    form.lbl_tax_liang.Visible = false
    form.lbl_sell_liang_tax.Visible = false
  end
  if wen == 0 then
    form.lbl_tax_wen.Visible = false
    form.lbl_sell_wen_tax.Visible = false
  end
end
function on_btn_up_click(btn)
  local form = btn.ParentForm
  if form.ig_sell:IsEmpty(0) then
    return
  end
  local stack = nx_number(form.ipt_stack.Text)
  local num = nx_number(form.ipt_num.Text)
  local price_min = nx_number(form.ipt_compete_1.Text) * 1000000 + nx_number(form.ipt_compete_2.Text) * 1000 + nx_number(form.ipt_compete_3.Text)
  local price_max = nx_number(form.ipt_buy_1.Text) * 1000000 + nx_number(form.ipt_buy_2.Text) * 1000 + nx_number(form.ipt_buy_3.Text)
  local time_index = form.combobox_time_index.DropListBox.SelectIndex
  local price_group = form.combobox_group.DropListBox.SelectIndex
  if nx_number(price_group) == 1 then
    price_min = price_min * stack
    price_max = price_max * stack
  end
  if price_min <= 0 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_auction_021"))
    return
  end
  if price_max <= 0 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_auction_021"))
    return
  end
  if nx_number(price_max) > nx_number(AUCTION_CAPITAL2_NUMBER_MAX) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_auction_030"))
    return
  end
  if price_min > price_max then
    form.ipt_buy_1.ForeColor = "255,255,0,0"
    form.ipt_buy_2.ForeColor = "255,255,0,0"
    form.ipt_buy_3.ForeColor = "255,255,0,0"
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_auction_025"))
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  custom_auction(CTS_SUB_AUCTION_UP_ITEM, nx_int(stack), nx_int(num), nx_int(price_min), nx_int(price_max), nx_int(time_index))
end
function reset_up_ipt(form)
  form.ipt_stack.Text = nx_widestr("")
  form.ipt_num.Text = nx_widestr("")
  if not form.ig_sell:IsEmpty(0) then
    form.ipt_stack.Text = nx_widestr(form.ig_sell.count)
    form.ipt_num.Text = nx_widestr("1")
  end
  form.ipt_compete_1.Text = nx_widestr("")
  form.ipt_compete_2.Text = nx_widestr("")
  form.ipt_compete_3.Text = nx_widestr("")
  form.ipt_buy_1.Text = nx_widestr("")
  form.ipt_buy_2.Text = nx_widestr("")
  form.ipt_buy_3.Text = nx_widestr("")
  refresh_tax(form)
  form.lbl_tax_wen.Text = nx_widestr("")
  form.lbl_tax_liang.Text = nx_widestr("")
  form.lbl_tax_ding.Text = nx_widestr("")
end
function on_ig_sell_select_changed(grid, index)
  local gui = nx_value("gui")
  local selected_index = grid:GetSelectItemIndex()
  local dest_pos = selected_index + 1
  local dest_viewid = grid.typeid
  if gui.GameHand:IsEmpty() then
    return false
  end
  if not grid:IsEmpty(selected_index) then
    return false
  end
  if gui.GameHand.Type == GHT_VIEWITEM and nx_number(grid.typeid) > 0 then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local src_pos = nx_int(gui.GameHand.Para2)
    local game_client = nx_value("game_client")
    local view = game_client:GetView(nx_string(src_viewid))
    local viewobj = view:GetViewObj(nx_string(src_pos))
    if not nx_is_valid(viewobj) then
      return
    end
    local cant_exchange = 0
    if viewobj:FindProp("CantExchange") then
      cant_exchange = viewobj:QueryProp("CantExchange")
      if nx_int(cant_exchange) > nx_int(0) then
        nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7055"))
        return
      end
    end
    local lock_status = 0
    if viewobj:FindProp("LockStatus") then
      lock_status = viewobj:QueryProp("LockStatus")
      if nx_int(lock_status) > nx_int(0) then
        nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7054"))
        return
      end
    end
    local bind_status = 0
    if viewobj:FindProp("BindStatus") then
      bind_status = viewobj:QueryProp("BindStatus")
      if nx_int(bind_status) > nx_int(0) then
        nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_auction_011"))
        return
      end
    end
    if nx_number(src_viewid) ~= VIEWPORT_EQUIP_TOOL and nx_number(src_viewid) ~= VIEWPORT_TOOL and nx_number(src_viewid) ~= VIEWPORT_MATERIAL_TOOL and nx_number(src_viewid) ~= VIEWPORT_TASK_TOOL then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7055"))
      return
    end
    custom_auction(CTS_SUB_AUCTION_SELL_ADD, nx_int(src_viewid), nx_int(src_pos))
    gui.GameHand:ClearHand()
  end
end
function on_ig_sell_mousein_grid(grid, index)
  local form = grid.ParentForm
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local game_client = nx_value("game_client")
  local toolbox_view = game_client:GetView(nx_string(grid.typeid))
  if not nx_is_valid(toolbox_view) then
    return
  end
  local bind_index = grid:GetBindIndex(index)
  local viewobj = toolbox_view:GetViewObj(nx_string(bind_index))
  if not nx_is_valid(viewobj) then
    nx_execute("tips_game", "hide_tip", form)
    return
  end
  nx_execute("tips_game", "show_goods_tip", viewobj, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, form)
end
function on_ig_sell_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_ig_sell_rightclick_grid(grid, index)
  if grid:IsEmpty(index) then
    return false
  end
  custom_auction(CTS_SUB_AUCTION_SELL_CANCEL)
end
function on_btn_stack_max_click(btn)
  local form = btn.ParentForm
  if form.ig_sell:IsEmpty(0) then
    return
  end
  if nx_int(form.ipt_num.Text) < nx_int(1) then
    form.ipt_stack.Text = nx_widestr(form.ig_sell.count)
    form.ipt_num.Text = nx_widestr("1")
    refresh_tax(form)
  else
    form.ipt_stack.Text = nx_widestr(math.floor(form.ig_sell.count / nx_number(form.ipt_num.Text)))
  end
end
function on_btn_num_max_click(btn)
  local form = btn.ParentForm
  if form.ig_sell:IsEmpty(0) then
    return
  end
  if nx_int(form.ipt_stack.Text) < nx_int(1) then
    form.ipt_num.Text = nx_widestr(form.ig_sell.count)
    form.ipt_stack.Text = nx_widestr("1")
  else
    form.ipt_num.Text = nx_widestr(math.floor(form.ig_sell.count / nx_number(form.ipt_stack.Text)))
  end
  refresh_tax(form)
end
function init_combobox_color_index(form)
  form.combo_color.DropListBox:ClearString()
  for i = 0, COLOR_LEVEL_COUNT do
    local color_text = "ui_market_color_level_" .. nx_string(i)
    form.combo_color.DropListBox:AddString(nx_widestr(util_text(color_text)))
  end
  form.combo_color.DropListBox.SelectIndex = COLOR_LEVEL_SELECT_ALL
  form.combo_color.Text = nx_widestr(form.combo_color.DropListBox:GetString(COLOR_LEVEL_SELECT_ALL))
end
function init_combobox_time_index(form)
  form.combobox_time_index.DropListBox:ClearString()
  form.combobox_time_index.DropListBox:AddString(nx_widestr(util_text("ui_auction_time_1")))
  form.combobox_time_index.DropListBox:AddString(nx_widestr(util_text("ui_auction_time_2")))
  form.combobox_time_index.DropListBox:AddString(nx_widestr(util_text("ui_auction_time_3")))
  form.combobox_time_index.DropListBox:AddString(nx_widestr(util_text("ui_auction_time_4")))
  form.combobox_time_index.DropListBox.SelectIndex = 0
  form.combobox_time_index.InputEdit.Text = form.combobox_time_index.DropListBox:GetString(0)
  refresh_tax(form)
end
function init_combobox_group(form)
  form.combobox_group.DropListBox:ClearString()
  form.combobox_group.DropListBox:AddString(nx_widestr(util_text("ui_auction_sell_price_group")))
  form.combobox_group.DropListBox:AddString(nx_widestr(util_text("ui_auction_sell_price_single")))
  form.combobox_group.DropListBox.SelectIndex = 0
  form.combobox_group.InputEdit.Text = form.combobox_group.DropListBox:GetString(0)
end
function on_btn_sell_cancel_click(btn)
  local form = btn.ParentForm
  if nx_string(form.sl_sell) == nx_string("") then
    return
  end
  local gb = form.gsb_sell:Find("gb_sell_" .. nx_string(form.sl_sell))
  if not nx_is_valid(gb) then
    return
  end
  local lbl_competitor = gb:Find("lbl_3_competitor_" .. nx_string(form.sl_sell))
  if not nx_is_valid(lbl_competitor) then
    return
  end
  if nx_widestr(lbl_competitor.Text) ~= nx_widestr("") then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return
    end
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("ui_auction_sell_cancel_tip")
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
    dialog:ShowModal()
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res ~= "ok" then
      return
    end
  end
  custom_auction(CTS_SUB_AUCTION_DOWN_ITEM, nx_string(form.sl_sell))
end
function on_cbtn_desc_checked_changed(cbtn)
  local form = cbtn.ParentForm
  update_checkedbtn(form, cbtn.Name)
  if cbtn.Checked then
    form.desc = 1
    form.lbl_desc_down.Visible = true
  else
    form.desc = 0
    form.lbl_desc_up.Visible = true
  end
  form.sort_type = SEARCH_SORT_BY_PRICE
  send_search(form)
end
function on_cbtn_time_left_checked_changed(cbtn)
  local form = cbtn.ParentForm
  update_checkedbtn(form, cbtn.Name)
  if cbtn.Checked then
    form.desc = 1
    form.lbl_time_left_down.Visible = true
  else
    form.desc = 0
    form.lbl_time_left_up.Visible = true
  end
  form.sort_type = SEARCH_SORT_BY_TIME
  send_search(form)
end
function on_cbtn_quality_checked_changed(cbtn)
  local form = cbtn.ParentForm
  update_checkedbtn(form, cbtn.Name)
  if cbtn.Checked then
    form.desc = 1
    form.lbl_quality_down.Visible = true
  else
    form.desc = 0
    form.lbl_quality_up.Visible = true
  end
  form.sort_type = SEARCH_SORT_BY_QUALITY
  send_search(form)
end
function update_checkedbtn(form, btn_name)
  if not nx_is_valid(form) or "" == btn_name then
    return false
  end
  form.cbtn_desc.Enabled = false
  form.cbtn_time_left.Enabled = false
  form.cbtn_quality.Enabled = false
  form.lbl_desc_up.Visible = false
  form.lbl_desc_down.Visible = false
  form.lbl_time_left_up.Visible = false
  form.lbl_time_left_down.Visible = false
  form.lbl_quality_up.Visible = false
  form.lbl_quality_down.Visible = false
  if "cbtn_desc" == btn_name then
    form.cbtn_time_left.Checked = false
    form.cbtn_quality.Checked = false
  elseif "cbtn_time_left" == btn_name then
    form.cbtn_desc.Checked = false
    form.cbtn_quality.Checked = false
  elseif "cbtn_quality" == btn_name then
    form.cbtn_desc.Checked = false
    form.cbtn_time_left.Checked = false
  end
  form.cbtn_desc.Enabled = true
  form.cbtn_time_left.Enabled = true
  form.cbtn_quality.Enabled = true
  return true
end
function compete_ok(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local auction_uid = nx_string(arg[1])
  local price_compete = arg[2]
  local gb_search = form.gsb_search:Find("gb_search_" .. nx_string(auction_uid))
  if nx_is_valid(gb_search) then
    local lbl_price_min = gb_search:Find("lbl_1_price_min_" .. nx_string(auction_uid))
    if nx_is_valid(lbl_price_min) then
      lbl_price_min.HtmlText = get_captial_text(price_compete)
      lbl_price_min.price = price_compete
    end
    local lbl_competitor = gb_search:Find("lbl_1_competitor_" .. nx_string(auction_uid))
    if nx_is_valid(lbl_competitor) then
      lbl_competitor.Text = nx_widestr(util_text("auction_you"))
    end
  end
  local gb_compete = form.gsb_compete:Find("gb_compete_" .. nx_string(auction_uid))
  if nx_is_valid(gb_compete) then
    local lbl_price_min = gb_compete:Find("lbl_2_price_min_" .. nx_string(auction_uid))
    if nx_is_valid(lbl_price_min) then
      lbl_price_min.HtmlText = get_captial_text(price_compete)
      lbl_price_min.price = price_compete
    end
    local lbl_competitor = gb_compete:Find("lbl_2_competitor_" .. nx_string(auction_uid))
    if nx_is_valid(lbl_competitor) then
      lbl_competitor.Text = nx_widestr(util_text("auction_you"))
    end
    local lbl_state = gb_compete:Find("lbl_2_state_" .. nx_string(auction_uid))
    if nx_is_valid(lbl_state) then
      lbl_state.ForeColor = "255,0,255,0"
      lbl_state.Text = nx_widestr(util_text("ui_auction_state_1"))
    end
  end
end
function buy_ok(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local auction_uid = nx_string(arg[1])
  local gb_search = form.gsb_search:Find("gb_search_" .. nx_string(auction_uid))
  if nx_is_valid(gb_search) then
    form.gsb_search.IsEditMode = true
    form.gsb_search:Remove(gb_search)
    form.gsb_search.IsEditMode = false
    form.gsb_search:ResetChildrenYPos()
    if nx_string(form.sl_search) == auction_id then
      set_sl_search(form, "")
    end
  end
  local gb_compete = form.gsb_compete:Find("gb_compete_" .. nx_string(auction_uid))
  if nx_is_valid(gb_compete) then
    form.gsb_compete.IsEditMode = true
    form.gsb_compete:Remove(gb_compete)
    form.gsb_compete.IsEditMode = false
    form.gsb_compete:ResetChildrenYPos()
    if nx_string(form.sl_compete) == auction_id then
      set_sl_compete(form, "")
    end
    form.compete_count = form.compete_count - 1
    form.info_to = form.info_to - 1
    if form.info_from > form.info_to then
      form.info_from = form.info_to
    end
    form.lbl_compete_page.Text = nx_widestr(nx_string(form.info_from) .. "-" .. nx_string(form.info_to) .. "(" .. nx_string(form.compete_count) .. ")")
  end
end
function down_ok(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local auction_uid = nx_string(arg[1])
  local gb = form.gsb_sell:Find("gb_sell_" .. nx_string(auction_uid))
  if nx_is_valid(gb) then
    form.gsb_sell.IsEditMode = true
    form.gsb_sell:Remove(gb)
    form.gsb_sell.IsEditMode = false
    form.gsb_sell:ResetChildrenYPos()
    if nx_string(form.sl_sell) == auction_id then
      form.sl_sell = ""
    end
    form.sell_count = form.sell_count - 1
    form.info_to = form.info_to - 1
    if form.info_from > form.info_to then
      form.info_from = form.info_to
    end
    form.lbl_sell_page.Text = nx_widestr(nx_string(form.info_from) .. "-" .. nx_string(form.info_to) .. "(" .. nx_string(form.sell_count) .. ")")
  end
end
function delete_refresh_single(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local auction_uid = nx_string(arg[1])
  local gb = form.gsb_search:Find("gb_search_" .. auction_uid)
  if nx_is_valid(gb) then
    form.gsb_search.IsEditMode = true
    form.gsb_search:Remove(gb)
    form.gsb_search.IsEditMode = false
    form.gsb_search:ResetChildrenYPos()
    if nx_string(form.sl_search) == auction_uid then
      set_sl_search(form, "")
    end
  end
end
function update_refresh_single(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local auction_uid = nx_string(arg[1])
  local price_cur = nx_int(arg[2])
  local gb = form.gsb_search:Find("gb_search_" .. auction_uid)
  if nx_is_valid(gb) then
    local lbl_price_min = gb:Find("lbl_1_price_min_" .. auction_uid)
    if nx_is_valid(lbl_price_min) then
      local price = price_cur
      if not form.cbtn_price.Checked then
        price = nx_int(price / gb.count)
      end
      lbl_price_min.HtmlText = get_captial_text(price)
      lbl_price_min.price = price_cur
    end
  end
end
function update_refresh(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local self_name = client_player:QueryProp("Name")
  set_sl_search(form, "")
  form.config = nx_string(arg[2])
  form.from = nx_int(arg[3])
  form.to = nx_int(arg[4])
  form.desc = nx_int(arg[5])
  form.total_count = nx_int(arg[6])
  local count = nx_int(arg[7])
  if nx_int(count) == nx_int(0) then
    form.from = 0
  elseif nx_widestr(form.search_word) ~= nx_widestr("") then
    add_record_search_item(form)
  end
  form.search_word = nx_widestr("")
  if nx_int(form.to) > nx_int(form.total_count) then
    form.to = form.total_count
  end
  form.lbl_page_info.Text = nx_widestr(nx_string(form.from) .. "-" .. nx_string(form.to) .. "(" .. nx_string(form.total_count) .. ")")
  refresh_page_btn(form)
  form.gsb_search.IsEditMode = true
  form.gsb_search:DeleteAll()
  for i = 1, nx_number(count) do
    local row = arg[7 + (i - 1) * 10 + 1]
    local auction_uid = arg[7 + (i - 1) * 10 + 2]
    local config = arg[7 + (i - 1) * 10 + 3]
    local count = arg[7 + (i - 1) * 10 + 4]
    local prop = arg[7 + (i - 1) * 10 + 5]
    local time_left = arg[7 + (i - 1) * 10 + 6]
    local seller_name = arg[7 + (i - 1) * 10 + 7]
    local price_cur = arg[7 + (i - 1) * 10 + 8]
    local price_max = arg[7 + (i - 1) * 10 + 9]
    local competitor = arg[7 + (i - 1) * 10 + 10]
    local gb = create_ctrl("GroupBox", "gb_search_" .. nx_string(auction_uid), form.gb_mod_search, form.gsb_search)
    if nx_is_valid(gb) then
      gb.auction_uid = nx_string(auction_uid)
      gb.row = nx_int(row)
      gb.count = count
      local cbtn = create_ctrl("CheckButton", "cbtn_1_bg_" .. nx_string(auction_uid), form.cbtn_1_bg, gb)
      cbtn.auction_uid = nx_string(auction_uid)
      nx_bind_script(cbtn, nx_current())
      nx_callback(cbtn, "on_checked_changed", "on_cbtn_search_checked_changed")
      local ig = create_ctrl("ImageGrid", "ig_1_" .. nx_string(auction_uid), form.ig_1, gb)
      ig.config = config
      ig.count = count
      ig.prop = prop
      nx_bind_script(ig, nx_current())
      nx_callback(ig, "on_mousein_grid", "on_ig_mousein_grid")
      nx_callback(ig, "on_mouseout_grid", "on_ig_mouseout_grid")
      local lbl_name = create_ctrl("Label", "lbl_1_name_" .. nx_string(auction_uid), form.lbl_1_name, gb)
      local lbl_color = create_ctrl("Label", "lbl_1_color_" .. nx_string(auction_uid), form.lbl_1_color, gb)
      local lbl_time = create_ctrl("Label", "lbl_1_time_" .. nx_string(auction_uid), form.lbl_1_time, gb)
      local lbl_seller = create_ctrl("Label", "lbl_1_seller_" .. nx_string(auction_uid), form.lbl_1_seller, gb)
      local lbl_price_min = create_ctrl("MultiTextBox", "lbl_1_price_min_" .. nx_string(auction_uid), form.lbl_1_price_min, gb)
      local lbl_price_max = create_ctrl("MultiTextBox", "lbl_1_price_max_" .. nx_string(auction_uid), form.lbl_1_price_max, gb)
      local lbl_competitor = create_ctrl("Label", "lbl_1_competitor_" .. nx_string(auction_uid), form.lbl_1_competitor, gb)
      local search_pic_min = create_ctrl("MultiTextBox", "search_pic_min_" .. nx_string(auction_uid), form.mltbox_search_pic_min, gb)
      local search_pic_max = create_ctrl("MultiTextBox", "search_pic_max_" .. nx_string(auction_uid), form.mltbox_search_pic_max, gb)
      local item_type = nx_number(get_prop_in_ItemQuery(config, nx_string("ItemType")))
      local color_level = nx_number(get_item_colorlevel(config, prop))
      local photo = ""
      if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
        local equip_type = get_prop_in_ItemQuery(config, "EquipType")
        local item_back_image = get_grid_treasure_back_image(equip_type, color_level)
        photo = item_query_ArtPack_by_id(config, "Photo")
        ig:AddItemEx(0, nx_string(photo), nx_widestr(config), nx_int(count), -1, item_back_image)
      else
        photo = get_prop_in_ItemQuery(config, nx_string("Photo"))
        ig:AddItem(0, nx_string(photo), nx_widestr(config), nx_int(count), 0)
      end
      lbl_name.Text = nx_widestr(get_equip_score_name(config, count, prop) .. util_text(config))
      lbl_name.ForeColor = color[color_level][1]
      lbl_color.Text = nx_widestr(util_text(color[color_level][2]))
      lbl_color.ForeColor = color[color_level][1]
      local time_hour = nx_int(time_left / 3600)
      local time_text = nx_widestr(util_text("ui_auction_time_01"))
      if 0 < nx_number(time_hour) then
        time_text = nx_widestr(gui.TextManager:GetFormatText("ui_auction_time_02", nx_int(time_hour)))
      end
      lbl_time.Text = nx_widestr(time_text)
      lbl_seller.Text = nx_widestr(seller_name)
      local cur_price = price_cur
      local max_price = price_max
      if not form.cbtn_price.Checked then
        cur_price = nx_int(price_cur / count)
        max_price = nx_int(price_max / count)
      end
      lbl_price_min.HtmlText = get_captial_text(cur_price)
      lbl_price_min.price = price_cur
      lbl_price_max.HtmlText = get_captial_text(max_price)
      lbl_price_max.price = price_max
      if nx_widestr(competitor) == nx_widestr(self_name) then
        lbl_competitor.Text = nx_widestr(util_text("auction_you"))
      else
        lbl_competitor.Text = nx_widestr(competitor)
      end
      search_pic_min.price = price_cur
      nx_bind_script(search_pic_min, nx_current())
      nx_callback(search_pic_min, "on_get_capture", "on_price_min_get_capture")
      nx_callback(search_pic_min, "on_lost_capture", "on_price_min_lost_capture")
      search_pic_max.price = price_max
      nx_bind_script(search_pic_max, nx_current())
      nx_callback(search_pic_max, "on_get_capture", "on_price_max_get_capture")
      nx_callback(search_pic_max, "on_lost_capture", "on_price_max_lost_capture")
    end
  end
  form.gsb_search.IsEditMode = false
  form.gsb_search:ResetChildrenYPos()
  end_wait(form)
end
function update_compete(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local self_name = client_player:QueryProp("Name")
  form.sl_compete = ""
  end_wait(form)
  form.compete_count = arg[1]
  local count = arg[2]
  form.info_to = form.info_from + count - 1
  if form.info_from > form.info_to then
    form.info_from = form.info_to
  end
  form.lbl_compete_page.Text = nx_widestr(nx_string(form.info_from) .. "-" .. nx_string(form.info_to) .. "(" .. nx_string(form.compete_count) .. ")")
  set_page_btn(form.btn_compete_right, form.btn_compete_left, form.compete_page, form.compete_count)
  form.gsb_compete.IsEditMode = true
  form.gsb_compete:DeleteAll()
  for i = 1, count do
    local auction_uid = arg[2 + (i - 1) * 9 + 1]
    local row = arg[2 + (i - 1) * 9 + 2]
    local config = arg[2 + (i - 1) * 9 + 3]
    local count = arg[2 + (i - 1) * 9 + 4]
    local prop = arg[2 + (i - 1) * 9 + 5]
    local time_left = arg[2 + (i - 1) * 9 + 6]
    local price_buy = arg[2 + (i - 1) * 9 + 7]
    local price_max = arg[2 + (i - 1) * 9 + 8]
    local buyer = arg[2 + (i - 1) * 9 + 9]
    local gb = create_ctrl("GroupBox", "gb_compete_" .. nx_string(auction_uid), form.gb_mod_compete, form.gsb_compete)
    if nx_is_valid(gb) then
      gb.auction_uid = nx_string(auction_uid)
      gb.row = nx_int(row)
      gb.count = count
      local cbtn = create_ctrl("CheckButton", "cbtn_2_bg_" .. nx_string(auction_uid), form.cbtn_2_bg, gb)
      cbtn.auction_uid = nx_string(auction_uid)
      nx_bind_script(cbtn, nx_current())
      nx_callback(cbtn, "on_checked_changed", "on_cbtn_compete_checked_changed")
      local ig = create_ctrl("ImageGrid", "ig_2_" .. nx_string(auction_uid), form.ig_2, gb)
      ig.config = config
      ig.count = count
      ig.prop = prop
      nx_bind_script(ig, nx_current())
      nx_callback(ig, "on_mousein_grid", "on_ig_mousein_grid")
      nx_callback(ig, "on_mouseout_grid", "on_ig_mouseout_grid")
      local lbl_name = create_ctrl("Label", "lbl_2_name_" .. nx_string(auction_uid), form.lbl_2_name, gb)
      local lbl_color = create_ctrl("Label", "lbl_2_color_" .. nx_string(auction_uid), form.lbl_2_color, gb)
      local lbl_time = create_ctrl("Label", "lbl_2_time_" .. nx_string(auction_uid), form.lbl_2_time, gb)
      local lbl_state = create_ctrl("Label", "lbl_2_state_" .. nx_string(auction_uid), form.lbl_2_state, gb)
      local lbl_competitor = create_ctrl("Label", "lbl_2_competitor_" .. nx_string(auction_uid), form.lbl_2_competitor, gb)
      local lbl_price_min = create_ctrl("MultiTextBox", "lbl_2_price_min_" .. nx_string(auction_uid), form.lbl_2_price_min, gb)
      local lbl_price_max = create_ctrl("MultiTextBox", "lbl_2_price_max_" .. nx_string(auction_uid), form.lbl_2_price_max, gb)
      local compete_pic_min = create_ctrl("MultiTextBox", "compete_pic_min_" .. nx_string(auction_uid), form.mltbox_compete_pic_min, gb)
      local compete_pic_max = create_ctrl("MultiTextBox", "compete_pic_max_" .. nx_string(auction_uid), form.mltbox_compete_pic_max, gb)
      local item_type = nx_number(get_prop_in_ItemQuery(config, nx_string("ItemType")))
      local color_level = nx_number(get_item_colorlevel(config, prop))
      local photo = ""
      if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
        local equip_type = get_prop_in_ItemQuery(config, "EquipType")
        local item_back_image = get_grid_treasure_back_image(equip_type, color_level)
        photo = item_query_ArtPack_by_id(config, "Photo")
        ig:AddItemEx(0, nx_string(photo), nx_widestr(config), nx_int(count), -1, item_back_image)
      else
        photo = get_prop_in_ItemQuery(config, nx_string("Photo"))
        ig:AddItem(0, nx_string(photo), nx_widestr(config), nx_int(count), 0)
      end
      lbl_name.Text = nx_widestr(get_equip_score_name(config, count, prop) .. util_text(config))
      lbl_name.ForeColor = color[color_level][1]
      lbl_color.Text = nx_widestr(util_text(color[color_level][2]))
      lbl_color.ForeColor = color[color_level][1]
      local time_hour = nx_int(time_left / 3600)
      local time_text = nx_widestr(util_text("ui_auction_time_01"))
      if nx_number(time_hour) > 0 then
        time_text = nx_widestr(gui.TextManager:GetFormatText("ui_auction_time_02", nx_int(time_hour)))
      end
      lbl_time.Text = nx_widestr(time_text)
      lbl_price_min.HtmlText = get_captial_text(price_buy)
      lbl_price_min.price = price_buy
      lbl_price_max.HtmlText = get_captial_text(price_max)
      lbl_price_max.price = price_max
      if nx_widestr(buyer) == nx_widestr(self_name) then
        lbl_competitor.Text = nx_widestr(util_text("auction_you"))
        lbl_state.ForeColor = "255,0,255,0"
        lbl_state.Text = nx_widestr(util_text("ui_auction_state_1"))
      else
        lbl_competitor.Text = nx_widestr(buyer)
        lbl_state.ForeColor = "255,255,0,0"
        lbl_state.Text = nx_widestr(util_text("ui_auction_state_0"))
      end
      compete_pic_min.price = price_buy
      nx_bind_script(compete_pic_min, nx_current())
      nx_callback(compete_pic_min, "on_get_capture", "on_cur_price_get_capture")
      nx_callback(compete_pic_min, "on_lost_capture", "on_cur_price_lost_capture")
      compete_pic_max.price = price_max
      nx_bind_script(compete_pic_max, nx_current())
      nx_callback(compete_pic_max, "on_get_capture", "on_max_price_get_capture")
      nx_callback(compete_pic_max, "on_lost_capture", "on_max_price_lost_capture")
    end
  end
  form.gsb_compete.IsEditMode = false
  form.gsb_compete:ResetChildrenYPos()
  set_sl_compete(form, "")
end
function update_sell(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.sl_sell = ""
  end_wait(form)
  form.sell_count = arg[1]
  local count = arg[2]
  form.info_to = form.info_from + count - 1
  if form.info_from > form.info_to then
    form.info_from = form.info_to
  end
  form.lbl_sell_page.Text = nx_widestr(nx_string(form.info_from) .. "-" .. nx_string(form.info_to) .. "(" .. nx_string(form.sell_count) .. ")")
  set_page_btn(form.btn_sell_right, form.btn_sell_left, form.sell_page, form.sell_count)
  if nx_int(count) < nx_int(1) then
    return
  end
  form.gsb_sell.IsEditMode = true
  form.gsb_sell:DeleteAll()
  for i = 1, count do
    local auction_uid = arg[2 + (i - 1) * 9 + 1]
    local config = arg[2 + (i - 1) * 9 + 2]
    local count = arg[2 + (i - 1) * 9 + 3]
    local prop = arg[2 + (i - 1) * 9 + 4]
    local time_left = arg[2 + (i - 1) * 9 + 5]
    local price_min = arg[2 + (i - 1) * 9 + 6]
    local price_cur = arg[2 + (i - 1) * 9 + 7]
    local price_max = arg[2 + (i - 1) * 9 + 8]
    local buyer = arg[2 + (i - 1) * 9 + 9]
    local gb = create_ctrl("GroupBox", "gb_sell_" .. nx_string(auction_uid), form.gb_mod_sell, form.gsb_sell)
    if nx_is_valid(gb) then
      gb.auction_uid = nx_string(auction_uid)
      gb.row = nx_int(row)
      gb.count = count
      local cbtn = create_ctrl("CheckButton", "cbtn_3_bg_" .. nx_string(auction_uid), form.cbtn_3_bg, gb)
      cbtn.auction_uid = nx_string(auction_uid)
      nx_bind_script(cbtn, nx_current())
      nx_callback(cbtn, "on_checked_changed", "on_cbtn_sell_checked_changed")
      local ig = create_ctrl("ImageGrid", "ig_3_" .. nx_string(auction_uid), form.ig_3, gb)
      ig.config = config
      ig.count = count
      ig.prop = prop
      nx_bind_script(ig, nx_current())
      nx_callback(ig, "on_mousein_grid", "on_ig_mousein_grid")
      nx_callback(ig, "on_mouseout_grid", "on_ig_mouseout_grid")
      local lbl_name = create_ctrl("Label", "lbl_3_name_" .. nx_string(auction_uid), form.lbl_3_name, gb)
      local lbl_color = create_ctrl("Label", "lbl_3_color_" .. nx_string(auction_uid), form.lbl_3_color, gb)
      local lbl_time = create_ctrl("Label", "lbl_3_time_" .. nx_string(auction_uid), form.lbl_3_time, gb)
      local lbl_price_cur = create_ctrl("MultiTextBox", "lbl_3_price_cur_" .. nx_string(auction_uid), form.lbl_3_price_cur, gb)
      local lbl_price_min = create_ctrl("MultiTextBox", "lbl_3_price_min_" .. nx_string(auction_uid), form.lbl_3_price_min, gb)
      local lbl_price_max = create_ctrl("MultiTextBox", "lbl_3_price_max_" .. nx_string(auction_uid), form.lbl_3_price_max, gb)
      local lbl_competitor = create_ctrl("Label", "lbl_3_competitor_" .. nx_string(auction_uid), form.lbl_3_competitor, gb)
      local sell_pic_cur = create_ctrl("MultiTextBox", "sell_pic_cur_" .. nx_string(auction_uid), form.mltbox_sell_pic_cur, gb)
      local sell_pic_min = create_ctrl("MultiTextBox", "sell_pic_min_" .. nx_string(auction_uid), form.mltbox_sell_pic_min, gb)
      local sell_pic_max = create_ctrl("MultiTextBox", "sell_pic_max_" .. nx_string(auction_uid), form.mltbox_sell_pic_max, gb)
      local item_type = nx_number(get_prop_in_ItemQuery(config, nx_string("ItemType")))
      local color_level = nx_number(get_item_colorlevel(config, prop))
      local photo = ""
      if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
        local equip_type = get_prop_in_ItemQuery(config, "EquipType")
        local item_back_image = get_grid_treasure_back_image(equip_type, color_level)
        photo = item_query_ArtPack_by_id(config, "Photo")
        ig:AddItemEx(0, nx_string(photo), nx_widestr(config), nx_int(count), -1, item_back_image)
      else
        photo = get_prop_in_ItemQuery(config, nx_string("Photo"))
        ig:AddItem(0, nx_string(photo), nx_widestr(config), nx_int(count), 0)
      end
      lbl_name.Text = nx_widestr(get_equip_score_name(config, count, prop) .. util_text(config))
      lbl_name.ForeColor = color[color_level][1]
      lbl_color.Text = nx_widestr(util_text(color[color_level][2]))
      lbl_color.ForeColor = color[color_level][1]
      local time_hour = nx_int(time_left / 3600)
      local time_text = nx_widestr(util_text("ui_auction_time_01"))
      if nx_number(time_hour) > 0 then
        time_text = nx_widestr(gui.TextManager:GetFormatText("ui_auction_time_02", nx_int(time_hour)))
      end
      lbl_time.Text = nx_widestr(time_text)
      local price_cur_text = util_text("ui_auction_sell_wu")
      if nx_number(price_cur) > 0 then
        price_cur_text = get_captial_text(price_cur)
      end
      lbl_price_cur.HtmlText = nx_widestr(price_cur_text)
      lbl_price_cur.price = price_cur
      lbl_price_min.HtmlText = get_captial_text(price_min)
      lbl_price_min.price = price_min
      lbl_price_max.HtmlText = get_captial_text(price_max)
      lbl_price_max.price = price_max
      lbl_competitor.Text = nx_widestr(buyer)
      sell_pic_cur.price = price_cur
      nx_bind_script(sell_pic_cur, nx_current())
      nx_callback(sell_pic_cur, "on_get_capture", "on_cur_price_get_capture")
      nx_callback(sell_pic_cur, "on_lost_capture", "on_cur_price_lost_capture")
      sell_pic_min.price = price_min
      nx_bind_script(sell_pic_min, nx_current())
      nx_callback(sell_pic_min, "on_get_capture", "on_min_price_get_capture")
      nx_callback(sell_pic_min, "on_lost_capture", "on_min_price_lost_capture")
      sell_pic_max.price = price_max
      nx_bind_script(sell_pic_max, nx_current())
      nx_callback(sell_pic_max, "on_get_capture", "on_max_price_get_capture")
      nx_callback(sell_pic_max, "on_lost_capture", "on_max_price_lost_capture")
    end
  end
  form.gsb_sell.IsEditMode = false
  form.gsb_sell:ResetChildrenYPos()
  form.sl_sell = ""
end
function update_sell_single(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local auction_uid = arg[1]
  local config = arg[2]
  local count = arg[3]
  local prop = arg[4]
  local time_left = arg[5]
  local price_min = arg[6]
  local price_max = arg[7]
  form.gsb_sell.IsEditMode = true
  local gb = create_ctrl("GroupBox", "gb_sell_" .. nx_string(auction_uid), form.gb_mod_sell, form.gsb_sell)
  if nx_is_valid(gb) then
    gb.auction_uid = nx_string(auction_uid)
    gb.row = nx_int(row)
    gb.count = count
    local cbtn = create_ctrl("CheckButton", "cbtn_3_bg_" .. nx_string(auction_uid), form.cbtn_3_bg, gb)
    cbtn.auction_uid = nx_string(auction_uid)
    nx_bind_script(cbtn, nx_current())
    nx_callback(cbtn, "on_checked_changed", "on_cbtn_sell_checked_changed")
    local ig = create_ctrl("ImageGrid", "ig_3_" .. nx_string(auction_uid), form.ig_3, gb)
    ig.config = config
    ig.count = count
    ig.prop = prop
    nx_bind_script(ig, nx_current())
    nx_callback(ig, "on_mousein_grid", "on_ig_mousein_grid")
    nx_callback(ig, "on_mouseout_grid", "on_ig_mouseout_grid")
    local lbl_name = create_ctrl("Label", "lbl_3_name_" .. nx_string(auction_uid), form.lbl_3_name, gb)
    local lbl_color = create_ctrl("Label", "lbl_3_color_" .. nx_string(auction_uid), form.lbl_3_color, gb)
    local lbl_time = create_ctrl("Label", "lbl_3_time_" .. nx_string(auction_uid), form.lbl_3_time, gb)
    local lbl_competitor = create_ctrl("Label", "lbl_3_competitor_" .. nx_string(auction_uid), form.lbl_3_competitor, gb)
    local lbl_price_min = create_ctrl("MultiTextBox", "lbl_3_price_min_" .. nx_string(auction_uid), form.lbl_3_price_min, gb)
    local lbl_price_cur = create_ctrl("MultiTextBox", "lbl_3_price_cur_" .. nx_string(auction_uid), form.lbl_3_price_cur, gb)
    local lbl_price_max = create_ctrl("MultiTextBox", "lbl_3_price_max_" .. nx_string(auction_uid), form.lbl_3_price_max, gb)
    local sell_pic_cur = create_ctrl("MultiTextBox", "sell_pic_cur_" .. nx_string(auction_uid), form.mltbox_sell_pic_cur, gb)
    local sell_pic_min = create_ctrl("MultiTextBox", "sell_pic_min_" .. nx_string(auction_uid), form.mltbox_sell_pic_min, gb)
    local sell_pic_max = create_ctrl("MultiTextBox", "sell_pic_max_" .. nx_string(auction_uid), form.mltbox_sell_pic_max, gb)
    local item_type = nx_number(get_prop_in_ItemQuery(config, nx_string("ItemType")))
    local color_level = nx_number(get_item_colorlevel(config, prop))
    local photo = ""
    if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
      local equip_type = get_prop_in_ItemQuery(config, "EquipType")
      local item_back_image = get_grid_treasure_back_image(equip_type, color_level)
      photo = item_query_ArtPack_by_id(config, "Photo")
      ig:AddItemEx(0, nx_string(photo), nx_widestr(config), nx_int(count), -1, item_back_image)
    else
      photo = get_prop_in_ItemQuery(config, nx_string("Photo"))
      ig:AddItem(0, nx_string(photo), nx_widestr(config), nx_int(count), 0)
    end
    lbl_name.Text = nx_widestr(get_equip_score_name(config, count, prop) .. util_text(config))
    lbl_name.ForeColor = color[color_level][1]
    lbl_color.Text = nx_widestr(util_text(color[color_level][2]))
    lbl_color.ForeColor = color[color_level][1]
    local time_hour = nx_int(time_left / 3600)
    local time_text = nx_widestr(util_text("ui_auction_time_01"))
    if nx_number(time_hour) > 0 then
      time_text = nx_widestr(gui.TextManager:GetFormatText("ui_auction_time_02", nx_int(time_hour)))
    end
    lbl_time.Text = nx_widestr(time_text)
    lbl_price_cur.HtmlText = nx_widestr(util_text("ui_auction_sell_wu"))
    lbl_price_cur.price = 0
    lbl_price_min.HtmlText = get_captial_text(price_min)
    lbl_price_min.price = price_min
    lbl_price_max.HtmlText = get_captial_text(price_max)
    lbl_price_max.price = price_max
    lbl_competitor.Text = nx_widestr("")
    sell_pic_cur.price = 0
    nx_bind_script(sell_pic_cur, nx_current())
    nx_callback(sell_pic_cur, "on_get_capture", "on_cur_price_get_capture")
    nx_callback(sell_pic_cur, "on_lost_capture", "on_cur_price_lost_capture")
    sell_pic_min.price = price_min
    nx_bind_script(sell_pic_min, nx_current())
    nx_callback(sell_pic_min, "on_get_capture", "on_min_price_get_capture")
    nx_callback(sell_pic_min, "on_lost_capture", "on_min_price_lost_capture")
    sell_pic_max.price = price_max
    nx_bind_script(sell_pic_max, nx_current())
    nx_callback(sell_pic_max, "on_get_capture", "on_max_price_get_capture")
    nx_callback(sell_pic_max, "on_lost_capture", "on_max_price_lost_capture")
  end
  form.gsb_sell.IsEditMode = false
  form.gsb_sell:ResetChildrenYPos()
  form.sell_count = form.sell_count + 1
  form.info_to = form.info_to + 1
  form.info_from = form.sell_count - form.info_to + 1
  form.lbl_sell_page.Text = nx_widestr(nx_string(form.info_from) .. "-" .. nx_string(form.info_to) .. "(" .. nx_string(form.sell_count) .. ")")
end
function on_captial2_changed(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local capital1 = client_player:QueryProp("CapitalType2")
  local ding1 = math.floor(capital1 / 1000000)
  local liang1 = math.floor(capital1 % 1000000 / 1000)
  local wen1 = math.floor(capital1 % 1000)
  local CapitalModule = nx_value("CapitalModule")
  if not nx_is_valid(CapitalModule) then
    return
  end
  local add_color = capital1 > CapitalModule:GetMaxValue(2)
  local gui = nx_value("gui")
  local htmlTextYinKa = nx_widestr("")
  if 0 < ding1 then
    local text = gui.TextManager:GetText("ui_ding")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    if add_color then
      ding1 = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(nx_int(ding1)) .. nx_widestr("</font>")
    end
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(ding1) .. nx_widestr(htmlText)
  end
  if 0 < liang1 then
    local text = gui.TextManager:GetText("ui_liang")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    if add_color then
      liang1 = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(nx_int(liang1)) .. nx_widestr("</font>")
    end
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(" ") .. nx_widestr(liang1) .. nx_widestr(htmlText)
  end
  if 0 < wen1 then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    if add_color then
      wen1 = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(nx_int(wen1)) .. nx_widestr("</font>")
    end
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(" ") .. nx_widestr(wen1) .. nx_widestr(htmlText)
  end
  if capital1 == 0 then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinKa = htmlTextYinKa .. nx_widestr("0") .. nx_widestr(htmlText)
  end
  form.mltbox_yinka.HtmlText = util_text("ui_auction_price_own") .. htmlTextYinKa
end
function on_ig_mousein_grid(grid, index)
  local config = grid.config
  local count = grid.count
  local prop = grid.prop
  show_item_info(config, count, prop)
end
function on_ig_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_cbtn_search_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if cbtn.Checked then
    if nx_string(form.sl_search) == nx_string(cbtn.auction_uid) then
      return
    end
    if nx_string(form.sl_search) ~= nx_string("") then
      local gb = form.gsb_search:Find("gb_search_" .. nx_string(form.sl_search))
      if nx_is_valid(gb) then
        local cbtn_old = gb:Find("cbtn_1_bg_" .. nx_string(form.sl_search))
        if nx_is_valid(cbtn_old) then
          cbtn_old.Checked = false
        end
      end
    end
    set_sl_search(form, nx_string(cbtn.auction_uid))
  else
    set_sl_search(form, "")
  end
end
function on_cbtn_compete_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if cbtn.Checked then
    if nx_string(form.sl_compete) == nx_string(cbtn.auction_uid) then
      return
    end
    if nx_string(form.sl_compete) ~= nx_string("") then
      local gb = form.gsb_compete:Find("gb_compete_" .. nx_string(form.sl_compete))
      if nx_is_valid(gb) then
        local cbtn_old = gb:Find("cbtn_2_bg_" .. nx_string(form.sl_compete))
        if nx_is_valid(cbtn_old) then
          cbtn_old.Checked = false
        end
      end
    end
    set_sl_compete(form, nx_string(cbtn.auction_uid))
  else
    set_sl_compete(form, "")
  end
end
function on_cbtn_sell_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if cbtn.Checked then
    if nx_string(form.sl_sell) == nx_string(cbtn.auction_uid) then
      return
    end
    if nx_string(form.sl_sell) ~= nx_string("") then
      local gb = form.gsb_sell:Find("gb_sell_" .. nx_string(form.sl_sell))
      if nx_is_valid(gb) then
        local cbtn_old = gb:Find("cbtn_3_bg_" .. nx_string(form.sl_sell))
        if nx_is_valid(cbtn_old) then
          cbtn_old.Checked = false
        end
      end
    end
    form.sl_sell = cbtn.auction_uid
  else
    form.sl_sell = ""
  end
end
function get_item_colorlevel(config, prop)
  local xmldoc = nx_create("XmlDocument")
  if not xmldoc:ParseXmlData(nx_string(prop), 1) then
    nx_destroy(xmldoc)
    return 0
  end
  local xmlroot = xmldoc.RootElement
  local xmlelement = xmlroot:GetChildByIndex(0)
  if not nx_is_valid(xmlelement) then
    nx_destroy(xmldoc)
    return 0
  end
  for i = 0, xmlelement:GetAttrCount() - 1 do
    local name = xmlelement:GetAttrName(i)
    local value = xmlelement:GetAttrValue(i)
    if nx_string(name) == nx_string("ColorLevel") then
      nx_destroy(xmldoc)
      return value
    end
  end
  nx_destroy(xmldoc)
  return 0
end
function show_item_info(config, count, prop)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local xmldoc = nx_create("XmlDocument")
  if not xmldoc:ParseXmlData(nx_string(prop), 1) then
    nx_destroy(xmldoc)
    return
  end
  local xmlroot = xmldoc.RootElement
  local array_data = nx_call("util_gui", "get_arraylist", "form_auction_main:show_item_info")
  array_data:ClearChild()
  local xmlelement = xmlroot:GetChildByIndex(0)
  if not nx_is_valid(xmlelement) then
    nx_destroy(xmldoc)
    return
  end
  for i = 0, xmlelement:GetAttrCount() - 1 do
    local name = xmlelement:GetAttrName(i)
    local value = xmlelement:GetAttrValue(i)
    nx_set_custom(array_data, name, value)
  end
  nx_set_custom(array_data, "ConfigID", config)
  nx_set_custom(array_data, "Amount", count)
  local item_type = get_prop_in_ItemQuery(config, "ItemType")
  local phy_def = get_prop_in_ItemQuery(config, "PhyDef")
  local max_melee_damage = get_prop_in_ItemQuery(config, "MaxMeleeDamage")
  nx_set_custom(array_data, "ItemType", item_type)
  nx_set_custom(array_data, "PhyDef", phy_def)
  nx_set_custom(array_data, "MaxMeleeDamage", max_melee_damage)
  local xml_element_record = xmlroot:GetChildByIndex(1)
  if nx_is_valid(xml_element_record) then
    local record_num = xml_element_record:GetChildCount()
    local str_record_group = ""
    for i = 0, record_num - 1 do
      local child = xml_element_record:GetChildByIndex(i)
      local record_name = child:QueryAttr("name")
      local record_rows = child:QueryAttr("rows")
      local sz_child_info = nx_string(record_name) .. "," .. nx_string(record_rows)
      local record_prop_num = 0
      for index = 0, record_rows - 1 do
        local child_child = child:GetChildByIndex(index)
        record_prop_num = nx_int(record_prop_num) + (nx_int(child_child:GetAttrCount()) - 1)
      end
      sz_child_info = nx_string(sz_child_info) .. "," .. nx_string(record_prop_num / record_rows)
      for index = 0, record_rows - 1 do
        local child_child = child:GetChildByIndex(index)
        local record_prop_num = child_child:GetAttrCount()
        for record_index = 1, record_prop_num - 1 do
          local prop_name = child_child:GetAttrName(record_index)
          local prop_value = child_child:GetAttrValue(record_index)
          sz_child_info = nx_string(sz_child_info) .. "," .. nx_string(prop_value)
        end
      end
      if str_record_group == "" then
        str_record_group = nx_string(sz_child_info)
      else
        str_record_group = nx_string(str_record_group) .. "," .. nx_string(sz_child_info)
      end
    end
    if nx_int(record_num) > nx_int(0) then
      array_data.item_rec_data_info = str_record_group
    end
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_goods_tip", array_data, x + 32, y - 20, 32, 32, form)
  nx_destroy(array_data)
  nx_destroy(xmldoc)
end
function begin_wait(form)
  form.waiting = true
  form.lbl_waiting.Visible = true
  form.rbtn_search.Enabled = false
  form.rbtn_compete.Enabled = false
  form.rbtn_sell.Enabled = false
end
function end_wait(form)
  form.waiting = false
  form.lbl_waiting.Visible = false
  form.rbtn_search.Enabled = true
  form.rbtn_compete.Enabled = true
  form.rbtn_sell.Enabled = true
end
function is_wait(form)
  return form.waiting
end
function reset_page(form)
  form.page = 1
end
function clear_search(form)
  form.ipt_search.Text = nx_widestr("")
  if form.combo_search_1.DroppedDown then
    form.combo_search_1.DroppedDown = false
  end
  if form.combo_search_2.DroppedDown then
    form.combo_search_2.DroppedDown = false
  end
  form.combo_search_1.DropListBox:ClearString()
  form.config = nx_string("")
end
function send_search(form)
  if nx_int(form.item_type) == nx_int(0) and nx_string(form.config) == nx_string("") then
    return
  end
  form.from = 1 + NUMS_PRE_PAGE * (form.page - 1)
  form.to = NUMS_PRE_PAGE * form.page
  local sifter_config = get_sifter_config(form)
  local sifter_treasure = get_sifter_treasure_str(form)
  local sifter_tab = util_split_string(sifter_treasure)
  if table.getn(sifter_tab) > 10 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_auction_034"))
    return
  end
  begin_wait(form)
  custom_auction(CTS_SUB_AUCTION_SEARCH, nx_int(form.item_type), nx_string(form.config), nx_int(form.from), nx_int(form.to), nx_int(form.desc), nx_string(sifter_config), nx_string(sifter_treasure), nx_int(form.sort_type))
  SEARCH_REFRESH_TAB.item_type = form.item_type
  SEARCH_REFRESH_TAB.config = form.config
  SEARCH_REFRESH_TAB.from = form.from
  SEARCH_REFRESH_TAB.to = form.to
  SEARCH_REFRESH_TAB.desc = form.desc
  SEARCH_REFRESH_TAB.sifter_config = sifter_config
  SEARCH_REFRESH_TAB.sifter_treasure = sifter_treasure
  SEARCH_REFRESH_TAB.sort_type = form.sort_type
end
function get_sifter_config(form)
  local sifter_tab = util_split_string(nx_string(form.tree_sifter), ",")
  local sifter_count = (table.getn(sifter_tab) - 1) / 4
  if sifter_count < 0 then
    sifter_count = 0
  end
  local color_sifter = ""
  if form.combo_color.DropListBox.SelectIndex ~= COLOR_LEVEL_SELECT_ALL then
    sifter_count = sifter_count + 1
    color_sifter = "ColorLevel," .. "0," .. nx_string(form.combo_color.DropListBox.SelectIndex)
  end
  local sifter_config = nx_string(sifter_count) .. "," .. nx_string(form.tree_sifter) .. nx_string(color_sifter)
  return sifter_config
end
function set_sl_search(form, value)
  form.sl_search = nx_string(value)
  if form.sl_search == "" then
    form.ipt_compete_ding.Text = nx_widestr("")
    form.ipt_compete_liang.Text = nx_widestr("")
    form.ipt_compete_wen.Text = nx_widestr("")
  else
    local gb = form.gsb_search:Find("gb_search_" .. form.sl_search)
    if nx_is_valid(gb) then
      local lbl_price_min = gb:Find("lbl_1_price_min_" .. form.sl_search)
      local lbl_price_max = gb:Find("lbl_1_price_max_" .. form.sl_search)
      local lbl_competitor = gb:Find("lbl_1_competitor_" .. form.sl_search)
      local price_min = nx_number(lbl_price_min.price)
      local price_max = nx_number(lbl_price_max.price)
      if nx_widestr(lbl_competitor.Text) ~= nx_widestr("") then
        price_min = math.floor((price_min * (100 + AUCTION_COMPETE_RATE) - 1) / 100) + 1
      end
      if price_max <= price_min then
        price_min = price_max
      end
      local ding = math.floor(price_min / 1000000)
      local liang = math.floor(price_min % 1000000 / 1000)
      local wen = math.floor(price_min % 1000)
      form.ipt_compete_ding.Text = nx_widestr(ding)
      form.ipt_compete_liang.Text = nx_widestr(liang)
      form.ipt_compete_wen.Text = nx_widestr(wen)
    end
  end
end
function set_sl_compete(form, value)
  form.sl_compete = nx_string(value)
  if form.sl_compete == "" then
    form.ipt_compete_ding_2.Text = nx_widestr("")
    form.ipt_compete_liang_2.Text = nx_widestr("")
    form.ipt_compete_wen_2.Text = nx_widestr("")
  else
    local gb = form.gsb_compete:Find("gb_compete_" .. form.sl_compete)
    if nx_is_valid(gb) then
      local lbl_price_min = gb:Find("lbl_2_price_min_" .. form.sl_compete)
      local lbl_price_max = gb:Find("lbl_2_price_max_" .. form.sl_compete)
      local lbl_competitor = gb:Find("lbl_2_competitor_" .. form.sl_compete)
      local price_min = nx_number(lbl_price_min.price)
      local price_max = nx_number(lbl_price_max.price)
      if nx_widestr(lbl_competitor.Text) ~= nx_widestr("") then
        price_min = math.floor((price_min * (100 + AUCTION_COMPETE_RATE) - 1) / 100) + 1
      end
      if price_max <= price_min then
        price_min = price_max
      end
      local ding = math.floor(price_min / 1000000)
      local liang = math.floor(price_min % 1000000 / 1000)
      local wen = math.floor(price_min % 1000)
      form.ipt_compete_ding_2.Text = nx_widestr(ding)
      form.ipt_compete_liang_2.Text = nx_widestr(liang)
      form.ipt_compete_wen_2.Text = nx_widestr(wen)
    end
  end
end
function load_sifter_ini(form)
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\market_treasure.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:GetSectionCount()
  if sec_count <= 0 then
    return
  end
  local tab_sifter = {}
  local tab = {}
  for sec_index = 0, sec_count - 1 do
    tab_sifter = {}
    tab_node_type = {}
    local sec_name = nx_number(ini:GetSectionByIndex(sec_index))
    local item_count = nx_int(ini:GetSectionItemCount(sec_index))
    for item_index = 0, item_count - 1 do
      tab = {}
      local item_value = ini:GetSectionItemValue(sec_index, item_index)
      local tab_item_value = util_split_string(item_value, ";")
      if table.getn(tab_item_value) == 3 then
        tab.node_type = tab_item_value[1]
        tab.ui = tab_item_value[2]
        tab.sift = tab_item_value[3]
        table.insert(tab_sifter, tab)
        if find_table_index(tab_node_type, tab_item_value[1]) == 0 then
          table.insert(tab_node_type, tab_item_value[1])
        end
      end
    end
    table.insert(ItemSifter, sec_name, tab_sifter)
    table.insert(sifter_tree_node_tab, sec_name, tab_node_type)
  end
end
function find_table_index(table_find, table_value)
  if table.getn(table_find) <= 0 then
    return 0
  end
  for node_index = 1, table.getn(table_find) do
    if tab_node_type[node_index] == table_value then
      return node_index
    end
  end
  return 0
end
function show_sifter_treasure(form, item_type)
  if form.groupbox_sifter.item_type == item_type then
    return
  end
  form.sifter_select_num = 0
  form.groupbox_sifter.item_type = item_type
  local tab_node = sifter_tree_node_tab[nx_number(item_type)]
  local tab_sifter = ItemSifter[nx_number(item_type)]
  if tab_node == nil or table.getn(tab_node) == 0 or tab_sifter == nil or table.getn(tab_sifter) == 0 then
    if form.groupbox_sifter.Visible then
      form.groupbox_sifter.Visible = false
      form.Width = form.Width - form.groupbox_sifter.Width
    end
    return
  end
  if not form.groupbox_sifter.Visible then
    form.groupbox_sifter.Visible = true
    form.Width = form.Width + form.groupbox_sifter.Width
  end
  form.tree_ex_treasure:BeginUpdate()
  local sifter_root = form.tree_ex_treasure.RootNode
  if not nx_is_valid(sifter_root) then
    sifter_root = form.tree_ex_treasure:CreateRootNode(nx_widestr(""))
    sifter_root.select_type = 0
  else
    sifter_root:ClearNode()
  end
  for i = 1, table.getn(tab_node) do
    local node_type = tab_node[i]
    local name_node = nx_widestr(util_text("ui_sifter_node_" .. nx_string(node_type)))
    if not nx_ws_equal(name_node, nx_widestr("")) then
      local map_node = sifter_root:CreateNode(name_node)
      if nx_is_valid(map_node) then
        map_node.node_type = node_type
        map_node.select_type = 1
        map_node.DrawMode = "Tile"
        map_node.ExpandCloseOffsetX = 0
        map_node.ExpandCloseOffsetY = 6
        map_node.TextOffsetX = 0
        map_node.TextOffsetY = 3
        map_node.NodeOffsetY = 1
        map_node.Font = "font_treeview"
        map_node.ForeColor = "255,255,255,255"
        map_node.ShadowColor = "10,0,0,0"
        map_node.NodeBackImage = "gui\\common\\treeview\\tree_2_out.png"
        map_node.NodeFocusImage = "gui\\common\\treeview\\tree_2_on.png"
        map_node.NodeSelectImage = "gui\\common\\treeview\\tree_2_on.png"
        map_node.ItemHeight = 22
        map_node.Expand = false
        for j = 1, table.getn(tab_sifter) do
          if tab_sifter[j].node_type == node_type then
            local name_node2 = nx_widestr(util_text(tab_sifter[j].ui))
            if not nx_ws_equal(name_node2, nx_widestr("")) then
              local map_node2 = map_node:CreateNode(name_node2)
              map_node2.sifter = tab_sifter[j].sift
              map_node2.select = false
              map_node2.select_type = 2
              map_node2.DrawMode = "font_treeview"
              map_node2.ExpandCloseOffsetX = 0
              map_node2.ExpandCloseOffsetY = 0
              map_node2.TextOffsetX = 10
              map_node2.TextOffsetY = 2
              map_node2.NodeOffsetY = 1
              map_node2.Font = "font_main"
              map_node2.ForeColor = "255,182,177,171"
              map_node2.ShadowColor = "10,0,0,0"
              map_node2.NodeBackImage = "gui\\common\\treeview\\tree_3_out.png"
              map_node2.NodeFocusImage = "gui\\special\\maket\\shaixuan_on.png"
              map_node2.NodeSelectImage = "gui\\special\\maket\\shaixuan_on.png"
              map_node2.ItemHeight = 20
            end
          end
        end
      end
    end
  end
  sifter_root.Expand = true
  form.tree_ex_treasure:EndUpdate()
end
function on_tree_ex_treasure_select_double_click(tree, node)
  local form = tree.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if node.select_type == 2 then
    if node.select then
      node.select = false
      form.sifter_select_num = form.sifter_select_num - 1
      if form.sifter_select_num < 0 then
        form.sifter_select_num = 0
      end
      node.NodeBackImage = "gui\\common\\treeview\\tree_3_out.png"
      node.NodeFocusImage = "gui\\special\\maket\\shaixuan_on.png"
      node.NodeSelectImage = "gui\\special\\maket\\shaixuan_on.png"
    else
      node.select = true
      form.sifter_select_num = form.sifter_select_num + 1
      node.NodeBackImage = "gui\\special\\maket\\shaixuan_down.png"
      node.NodeFocusImage = "gui\\special\\maket\\shaixuan_down.png"
      node.NodeSelectImage = "gui\\special\\maket\\shaixuan_down.png"
    end
  else
    form.tree_ex_treasure:BeginUpdate()
    if node.Expand then
      node.Expand = false
    else
      node.Expand = true
    end
    form.tree_ex_treasure:EndUpdate()
  end
end
function on_tree_ex_treasure_left_click(tree, node)
  on_tree_ex_treasure_select_double_click(tree, node)
end
function get_sifter_treasure_str(form)
  if not form.groupbox_sifter.Visible then
    return ""
  end
  local sifter_nums = 0
  local sifter_str_sub = ""
  local tab_node = form.tree_ex_treasure:GetAllNodeList()
  for i = 1, table.getn(tab_node) do
    if nx_is_valid(tab_node[i]) and tab_node[i].select_type == 2 and tab_node[i].select then
      sifter_nums = sifter_nums + 1
      sifter_str_sub = sifter_str_sub .. nx_string(tab_node[i].sifter) .. ","
    end
  end
  local sifter_str = ""
  if 0 < sifter_nums then
    sifter_str = nx_string(sifter_nums) .. "," .. nx_string(sifter_str_sub)
  end
  return sifter_str
end
function on_btn_sifter_click(btn)
  local form = btn.ParentForm
  send_search(form)
end
function on_btn_sifter_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local tab_node = form.tree_ex_treasure:GetAllNodeList()
  for i = 1, table.getn(tab_node) do
    if nx_is_valid(tab_node[i]) and tab_node[i].select_type == 2 and tab_node[i].select then
      tab_node[i].select = false
      form.sifter_select_num = form.sifter_select_num - 1
      if form.sifter_select_num < 0 then
        form.sifter_select_num = 0
      end
      tab_node[i].NodeBackImage = "gui\\common\\treeview\\tree_3_out.png"
      tab_node[i].NodeFocusImage = "gui\\special\\maket\\shaixuan_on.png"
      tab_node[i].NodeSelectImage = "gui\\special\\maket\\shaixuan_on.png"
    end
  end
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
function set_node_prop(node, node_type)
  if not nx_is_valid(node) or node_type == nil then
    return 0
  end
  for key, value in pairs(NODE_PROP[node_type]) do
    nx_set_property(node, nx_string(key), value)
  end
end
function remove_sell_grid_item(form)
  if not nx_is_valid(form) then
    return false
  end
  local grid = form.ig_sell
  if grid:IsEmpty(0) then
    return false
  end
  custom_auction(CTS_SUB_AUCTION_SELL_CANCEL)
end
function init_search_info(form)
  if nx_is_valid(form) then
    form.ipt_search.Text = nx_widestr("")
    form.combo_search_1.Text = nx_widestr("")
    form.combo_search_2.Text = nx_widestr("")
  end
end
function check_serach_text(form, text)
  if not nx_is_valid(form) then
    return
  end
  if string.find(text, "%w") then
    return false
  end
  if form.cbtn_fuzzy_search.Checked and nx_int(string.len(text)) < nx_int(MIN_SERACH_TEXT_LEN) then
    return false
  end
  return true
end
function on_cbtn_fuzzy_search_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  if form.cbtn_fuzzy_search.Checked then
    update_fuzzy_search_config_list(form)
    form.combo_search_1.DroppedDown = false
  elseif nx_string(form.ipt_search.Text) ~= nx_string("") then
    form.combo_search_1.DroppedDown = true
  end
  return true
end
function update_fuzzy_search_config_list(form)
  if not nx_is_valid(form) then
    return false
  end
  local total_count = table.getn(market_item_table)
  if 0 == total_count then
    return false
  end
  if not check_serach_text(form, nx_string(form.ipt_search.Text)) then
    form.config = ""
    return
  end
  form.search_word = nx_widestr(form.ipt_search.Text)
  local str_config_list = ""
  form.config = ""
  form.item_type = 0
  for i = 1, total_count do
    str_config_list = str_config_list .. market_item_table[i]
    if string.len(str_config_list) > MAX_SERACH_DATA_LEN then
      form.config = str_config_list
      return true
    end
    if i ~= total_count then
      str_config_list = str_config_list .. ","
    end
  end
  if str_config_list ~= "" then
    form.config = str_config_list
  end
  return true
end
function on_ipt_buy_changed(edit)
  if not nx_is_valid(edit) then
    return
  end
  local form = edit.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  if form.ig_sell:IsEmpty(0) then
    return
  end
  local price_min = nx_number(form.ipt_compete_1.Text) * 1000000 + nx_number(form.ipt_compete_2.Text) * 1000 + nx_number(form.ipt_compete_3.Text)
  local price_max = nx_number(form.ipt_buy_1.Text) * 1000000 + nx_number(form.ipt_buy_2.Text) * 1000 + nx_number(form.ipt_buy_3.Text)
  if price_min > price_max then
    form.ipt_buy_1.ForeColor = "255,255,0,0"
    form.ipt_buy_2.ForeColor = "255,255,0,0"
    form.ipt_buy_3.ForeColor = "255,255,0,0"
  else
    form.ipt_buy_1.ForeColor = "255,228,109,10"
    form.ipt_buy_2.ForeColor = "255,0,176,80"
    form.ipt_buy_3.ForeColor = "255,255,255,255"
  end
  refresh_tax(form)
end
function on_ipt_compete_changed(edit)
  if not nx_is_valid(edit) then
    return
  end
  local form = edit.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  if form.ig_sell:IsEmpty(0) then
    return
  end
  local price_min = nx_number(form.ipt_compete_1.Text) * 1000000 + nx_number(form.ipt_compete_2.Text) * 1000 + nx_number(form.ipt_compete_3.Text)
  local price_max = nx_number(form.ipt_buy_1.Text) * 1000000 + nx_number(form.ipt_buy_2.Text) * 1000 + nx_number(form.ipt_buy_3.Text)
  if price_min > price_max then
    form.ipt_buy_1.ForeColor = "255,255,0,0"
    form.ipt_buy_2.ForeColor = "255,255,0,0"
    form.ipt_buy_3.ForeColor = "255,255,0,0"
  else
    form.ipt_buy_1.ForeColor = "255,228,109,10"
    form.ipt_buy_2.ForeColor = "255,0,176,80"
    form.ipt_buy_3.ForeColor = "255,255,255,255"
  end
end
function on_ipt_stack_num_changed(edit)
  if not nx_is_valid(edit) then
    return
  end
  local form = edit.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  if form.ig_sell:IsEmpty(0) then
    return
  end
  refresh_tax(form)
end
function on_ipt_stack_get_focus(edit)
  if not nx_is_valid(edit) then
    return
  end
  local form = edit.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  if form.ig_sell:IsEmpty(0) then
    return
  end
  if nx_int(form.ipt_num.Text) < nx_int(1) then
    form.ipt_stack.MaxDigit = form.ig_sell.count
  else
    form.ipt_stack.MaxDigit = math.floor(form.ig_sell.count / nx_number(form.ipt_num.Text))
  end
end
function on_ipt_num_get_focus(edit)
  if not nx_is_valid(edit) then
    return
  end
  local form = edit.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  if form.ig_sell:IsEmpty(0) then
    return
  end
  if nx_int(form.ipt_stack.Text) < nx_int(1) then
    form.ipt_num.MaxDigit = form.ig_sell.count
  else
    form.ipt_num.MaxDigit = math.floor(form.ig_sell.count / nx_number(form.ipt_stack.Text))
  end
end
function on_cbtn_search_price_checked(cbtn)
  if not nx_is_valid(cbtn) then
    return
  end
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if cbtn.Checked then
    form.lbl_search_max.Text = nx_widestr(util_text("ui_auction_price_max_t"))
  else
    form.lbl_search_max.Text = nx_widestr(util_text("ui_auction_price_max_s"))
  end
  if not nx_is_valid(form.gsb_search) then
    return
  end
  local gb_mod_search_tab = form.gsb_search:GetChildControlList()
  for i = 1, table.getn(gb_mod_search_tab) do
    local gb_mod_search = gb_mod_search_tab[i]
    if nx_is_valid(gb_mod_search) and nx_find_custom(gb_mod_search, "auction_uid") then
      local auction_uid = gb_mod_search.auction_uid
      local count = gb_mod_search.count
      local lbl_price = gb_mod_search:Find("lbl_1_price_max_" .. nx_string(auction_uid))
      if nx_is_valid(lbl_price) then
        if not form.cbtn_price.Checked then
          lbl_price.HtmlText = get_captial_text(nx_int(lbl_price.price / count))
        else
          lbl_price.HtmlText = get_captial_text(lbl_price.price)
        end
      end
      lbl_price = gb_mod_search:Find("lbl_1_price_min_" .. nx_string(auction_uid))
      if nx_is_valid(lbl_price) then
        if not form.cbtn_price.Checked then
          lbl_price.HtmlText = get_captial_text(nx_int(lbl_price.price / count))
        else
          lbl_price.HtmlText = get_captial_text(lbl_price.price)
        end
      end
    end
  end
end
function get_equip_score_name(config, count, prop)
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return ""
  end
  local xmldoc = nx_create("XmlDocument")
  if not xmldoc:ParseXmlData(nx_string(prop), 1) then
    nx_destroy(xmldoc)
    return ""
  end
  local xmlroot = xmldoc.RootElement
  local array_data = nx_call("util_gui", "get_arraylist", "form_auction_main:show_item_info")
  array_data:ClearChild()
  local xmlelement = xmlroot:GetChildByIndex(0)
  if not nx_is_valid(xmlelement) then
    nx_destroy(xmldoc)
    return ""
  end
  for i = 0, xmlelement:GetAttrCount() - 1 do
    local name = xmlelement:GetAttrName(i)
    local value = xmlelement:GetAttrValue(i)
    nx_set_custom(array_data, name, value)
  end
  nx_set_custom(array_data, "ConfigID", config)
  nx_set_custom(array_data, "Amount", count)
  local item_type = get_prop_in_ItemQuery(config, "ItemType")
  local phy_def = get_prop_in_ItemQuery(config, "PhyDef")
  local max_melee_damage = get_prop_in_ItemQuery(config, "MaxMeleeDamage")
  nx_set_custom(array_data, "ItemType", item_type)
  nx_set_custom(array_data, "PhyDef", phy_def)
  nx_set_custom(array_data, "MaxMeleeDamage", max_melee_damage)
  local xml_element_record = xmlroot:GetChildByIndex(1)
  if nx_is_valid(xml_element_record) then
    local record_num = xml_element_record:GetChildCount()
    local str_record_group = ""
    for i = 0, record_num - 1 do
      local child = xml_element_record:GetChildByIndex(i)
      local record_name = child:QueryAttr("name")
      local record_rows = child:QueryAttr("rows")
      local sz_child_info = nx_string(record_name) .. "," .. nx_string(record_rows)
      local record_prop_num = 0
      for index = 0, record_rows - 1 do
        local child_child = child:GetChildByIndex(index)
        record_prop_num = nx_int(record_prop_num) + (nx_int(child_child:GetAttrCount()) - 1)
      end
      sz_child_info = nx_string(sz_child_info) .. "," .. nx_string(record_prop_num / record_rows)
      for index = 0, record_rows - 1 do
        local child_child = child:GetChildByIndex(index)
        local record_prop_num = child_child:GetAttrCount()
        for record_index = 1, record_prop_num - 1 do
          local prop_name = child_child:GetAttrName(record_index)
          local prop_value = child_child:GetAttrValue(record_index)
          sz_child_info = nx_string(sz_child_info) .. "," .. nx_string(prop_value)
        end
      end
      if str_record_group == "" then
        str_record_group = nx_string(sz_child_info)
      else
        str_record_group = nx_string(str_record_group) .. "," .. nx_string(sz_child_info)
      end
    end
    if nx_int(record_num) > nx_int(0) then
      array_data.item_rec_data_info = str_record_group
    end
  end
  local name = tips_manager:GetEquipScoreName(config, array_data)
  nx_destroy(array_data)
  nx_destroy(xmldoc)
  return name
end
function get_captial_text(capital_num)
  local gui = nx_value("gui")
  local capital = nx_number(capital_num)
  local ding = math.floor(capital / 1000000)
  local liang = math.floor(capital % 1000000 / 1000)
  local wen = math.floor(capital % 1000)
  local htmlTextYinZi = nx_widestr("")
  if 0 < ding then
    local text = nx_widestr(nx_int(ding)) .. nx_widestr(gui.TextManager:GetText("ui_ding"))
    htmlTextYinZi = htmlTextYinZi .. nx_widestr("<font color=\"#e46d0a\">") .. nx_widestr(text) .. nx_widestr("</font>")
  end
  if 0 < liang then
    local text = nx_widestr(nx_int(liang)) .. nx_widestr(gui.TextManager:GetText("ui_liang"))
    htmlTextYinZi = htmlTextYinZi .. nx_widestr("<font color=\"#00b50a\">") .. nx_widestr(text) .. nx_widestr("</font>")
  end
  if 0 < wen then
    local text = nx_widestr(nx_int(wen)) .. nx_widestr(gui.TextManager:GetText("ui_wen"))
    htmlTextYinZi = htmlTextYinZi .. nx_widestr("<font color=\"#ffffff\">") .. nx_widestr(text) .. nx_widestr("</font>")
  end
  if capital == 0 then
    local text = gui.TextManager:GetText("ui_wen")
    htmlTextYinZi = htmlTextYinZi .. nx_widestr("0") .. nx_widestr(text)
  end
  return htmlTextYinZi
end
function on_combobox_group_selected(combo)
  local form = combo.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = combo.DropListBox.SelectIndex
  refresh_tax(form)
end
function reset_tree_node(form)
  if not nx_is_valid(form.item_root) then
    return
  end
  local tab_node = get_all_node_list(form.item_root)
  for i = 1, table.getn(tab_node) do
    if nx_is_valid(tab_node[i]) then
      tab_node[i].Expand = false
    end
  end
  form.item_root.Expand = true
  form.tree_ex1.VScrollBar.Value = form.tree_ex1.VScrollBar.Minimum
end
function get_all_node_list(node)
  if not nx_is_valid(node) then
    return {}
  end
  local tab_node_result = {}
  local tab_node = node:GetNodeList()
  for i = 1, table.getn(tab_node) do
    table.insert(tab_node_result, tab_node[i])
    local tab_node_child = get_all_node_list(tab_node[i])
    for j = 1, table.getn(tab_node_child) do
      table.insert(tab_node_result, tab_node_child[j])
    end
  end
  return tab_node_result
end
function on_price_min_get_capture(mltbox)
  local form = mltbox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local tips_text = ""
  if form.cbtn_price.Checked then
    local group_box = mltbox.Parent
    if not nx_is_valid(group_box) then
      return
    end
    tips_text = gui.TextManager:GetFormatText("ui_auction_price_tips_0", nx_int(mltbox.price / group_box.count))
  else
    tips_text = gui.TextManager:GetFormatText("ui_auction_price_tips_3", nx_int(mltbox.price))
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), mltbox.AbsLeft, mltbox.AbsTop, 150, form)
end
function on_price_min_lost_capture(mltbox)
  nx_execute("tips_game", "hide_tip")
end
function on_price_max_get_capture(mltbox)
  local form = mltbox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local tips_text = ""
  if form.cbtn_price.Checked then
    local group_box = mltbox.Parent
    if not nx_is_valid(group_box) then
      return
    end
    tips_text = gui.TextManager:GetFormatText("ui_auction_price_tips_1", nx_int(mltbox.price / group_box.count))
  else
    tips_text = gui.TextManager:GetFormatText("ui_auction_price_tips_4", nx_int(mltbox.price))
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), mltbox.AbsLeft, mltbox.AbsTop, 150, form)
end
function on_price_max_lost_capture(mltbox)
  nx_execute("tips_game", "hide_tip")
end
function on_cur_price_get_capture(mltbox)
  if nx_number(mltbox.price) <= 0 then
    return
  end
  local form = mltbox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local group_box = mltbox.Parent
  if not nx_is_valid(group_box) then
    return
  end
  local gui = nx_value("gui")
  local tips_text = gui.TextManager:GetFormatText("ui_auction_price_tips_5", nx_int(mltbox.price / group_box.count))
  nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), mltbox.AbsLeft, mltbox.AbsTop, 150, form)
end
function on_cur_price_lost_capture(mltbox)
  nx_execute("tips_game", "hide_tip")
end
function on_min_price_get_capture(mltbox)
  local form = mltbox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local group_box = mltbox.Parent
  if not nx_is_valid(group_box) then
    return
  end
  local tips_text = gui.TextManager:GetFormatText("ui_auction_price_tips_0", nx_int(mltbox.price / group_box.count))
  nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), mltbox.AbsLeft, mltbox.AbsTop, 150, form)
end
function on_min_price_lost_capture(mltbox)
  nx_execute("tips_game", "hide_tip")
end
function on_max_price_get_capture(mltbox)
  local form = mltbox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local group_box = mltbox.Parent
  if not nx_is_valid(group_box) then
    return
  end
  local tips_text = gui.TextManager:GetFormatText("ui_auction_price_tips_1", nx_int(mltbox.price / group_box.count))
  nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), mltbox.AbsLeft, mltbox.AbsTop, 150, form)
end
function on_max_price_lost_capture(mltbox)
  nx_execute("tips_game", "hide_tip")
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
function load_ini(form)
  local ini = nx_create("IniDocument")
  ini.FileName = "game_client_save.ini"
  market_search_table = {}
  if ini:LoadFromFile() and ini:FindSection("auction_search_word") then
    local key_count = ini:GetItemCount("auction_search_word")
    for i = 1, nx_number(key_count) do
      local value = ini:ReadString("auction_search_word", nx_string(i), "")
      if nx_string(value) ~= nx_string("") then
        table.insert(market_search_table, nx_string(value))
      end
    end
  end
  nx_destroy(ini)
end
function save_ini(form)
  local ini = nx_create("IniDocument")
  ini.FileName = "game_client_save.ini"
  if not ini:LoadFromFile() then
    ini:SaveToFile()
  end
  if ini:LoadFromFile() then
    if nx_number(ini:GetItemCount("auction_search_word")) > nx_number(TOTAL_RECORD_COUNT) then
      ini:DeleteSection("auction_search_word")
    end
    local count = table.getn(market_search_table)
    if nx_number(count) > nx_number(TOTAL_RECORD_COUNT) then
      count = TOTAL_RECORD_COUNT
    end
    for i = 1, nx_number(count) do
      local item = market_search_table[i]
      ini:WriteString("auction_search_word", nx_string(i), nx_string(item))
      ini:SaveToFile()
    end
  end
  nx_destroy(ini)
end
function on_btn_compete_page_left_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.compete_page <= 1 then
    return
  end
  form.compete_page = form.compete_page - 1
  set_page_btn(form.btn_compete_right, form.btn_compete_left, form.compete_page, form.compete_count)
  begin_wait(form)
  local from = 1 + NUMS_PRE_PAGE * (form.compete_page - 1)
  local to = NUMS_PRE_PAGE * form.compete_page
  custom_auction(CTS_SUB_AUCTION_GET_COMPETE_INFO, from, to)
  form.info_from = from
end
function on_btn_compete_page_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.compete_page >= math.floor(nx_number(form.compete_count - 1) / NUMS_PRE_PAGE) + 1 then
    return
  end
  form.compete_page = form.compete_page + 1
  set_page_btn(form.btn_compete_right, form.btn_compete_left, form.compete_page, form.compete_count)
  begin_wait(form)
  local from = 1 + NUMS_PRE_PAGE * (form.compete_page - 1)
  local to = NUMS_PRE_PAGE * form.compete_page
  custom_auction(CTS_SUB_AUCTION_GET_COMPETE_INFO, from, to)
  form.info_from = from
end
function on_btn_sell_page_left_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.sell_page <= 1 then
    return
  end
  form.sell_page = form.sell_page - 1
  set_page_btn(form.btn_sell_right, form.btn_sell_left, form.sell_page, form.sell_count)
  begin_wait(form)
  local from = 1 + NUMS_PRE_PAGE * (form.sell_page - 1)
  local to = NUMS_PRE_PAGE * form.sell_page
  custom_auction(CTS_SUB_AUCTION_GET_SELLING_INFO, from, to)
  form.info_from = from
end
function on_btn_sell_page_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.sell_page >= math.floor(nx_number(form.sell_count - 1) / NUMS_PRE_PAGE) + 1 then
    return
  end
  form.sell_page = form.sell_page + 1
  set_page_btn(form.btn_sell_right, form.btn_sell_left, form.sell_page, form.sell_count)
  begin_wait(form)
  local from = 1 + NUMS_PRE_PAGE * (form.sell_page - 1)
  local to = NUMS_PRE_PAGE * form.sell_page
  custom_auction(CTS_SUB_AUCTION_GET_SELLING_INFO, from, to)
  form.info_from = from
end
function set_page_btn(btn_right, btn_left, page, total_count)
  btn_right.Enabled = false
  btn_left.Enabled = false
  if 1 < page then
    btn_left.Enabled = true
  end
  if page < math.floor(nx_number(total_count - 1) / NUMS_PRE_PAGE) + 1 then
    btn_right.Enabled = true
  end
end
function on_btn_jump_click(btn)
  local form = btn.ParentForm
  local text = form.ipt_search.Text
  close_form()
  nx_execute("form_stage_main\\form_market\\form_market", "open_form_and_search", nx_widestr(text))
end
