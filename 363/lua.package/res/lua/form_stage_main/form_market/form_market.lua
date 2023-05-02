require("util_gui")
require("util_functions")
require("share\\view_define")
require("util_static_data")
local STALL_INFO_NUM = 6
local HIRE_SHOP_INFO_NUM = 5
local ITEM_PAGE_COUNT = 7
local TOTAL_RECORD_COUNT = 20
local SUB_CLIENT_OPEN_MARKET = 1
local SUB_CLIENT_OPEN_STALL = 2
local SUB_CLIENT_SELECT_STALL = 3
local SUB_CLIENT_ClOSE_STALL = 4
local SUB_CLIENT_OPEN_HIRE_SHOP = 5
local SUB_CLIENT_SELECT_HIRE_SHOP = 6
local SUB_CLIENT_BUY_HIRE_SHOP_ITEM = 7
local SUB_CLIENT_ITEM_SELECT_COLOR = 20
local SUB_CLIENT_ITEM_SELECT_CONFIGID = 21
local SUB_CLIENT_ITEM_SELECT_TYPE = 23
local SUB_SERVER_OPEN_MARKET = 1
local SUB_SERVER_OPEN_STALL = 2
local SUB_SERVER_ADD_STALL_BOX = 3
local SUB_SERVER_OPEN_HIRE_SHOP = 4
local SUB_SERVER_LIUYAN_OKAY = 10
local SUB_SERVER_CLOSE_MARKET = 99
local MARKET_NODE_ITEM = 1
local MARKET_NODE_STALL = 2
local MARKET_NODE_HIRESHOP = 3
local MARKET_NODE_END = 4
local SEARCH_ITEM_TYPE_COLOR = 0
local SEARCH_ITEM_TYPE_CONFIGID = 1
local COLOR_LEVEL_COUNT = 6
local market_item_table = {}
market_search_table = {}
NODE_PROP = {
  first = {
    ForeColor = "255,220,198,160",
    NodeBackImage = "gui\\common\\treeview\\tree_1_out.png",
    NodeFocusImage = "gui\\common\\treeview\\tree_1_on.png",
    NodeSelectImage = "gui\\common\\button\\btn_normal1_out.png",
    ItemHeight = 30,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 1,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 20,
    TextOffsetY = 6,
    Font = "font_treeview"
  },
  second = {
    ForeColor = "255,152,128,114",
    NodeBackImage = "gui\\common\\treeview\\tree_2_out.png",
    NodeFocusImage = "gui\\common\\treeview\\tree_2_on.png",
    NodeSelectImage = "gui\\common\\treeview\\tree_2_on.png",
    ItemHeight = 22,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 0,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 25,
    TextOffsetY = 3,
    Font = "font_treeview"
  },
  third = {
    ForeColor = "255,182,177,171",
    NodeBackImage = "gui\\common\\treeview\\tree_3_out.png",
    NodeFocusImage = "gui\\common\\treeview\\tree_3_on.png",
    NodeSelectImage = "gui\\common\\treeview\\tree_3_on.png",
    ItemHeight = 20,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 0,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 30,
    TextOffsetY = 2,
    Font = "font_treeview"
  }
}
ItemSifter = {}
local sifter_tree_node_tab = {}
local ST_FUNCTION_MARKET_SIFTER = 637
local MAX_SELECT_SIFTER_NUMBER = 8
function open_form()
  auto_show_hide_form_market(nx_current())
end
function open_form_and_search(item_name)
  auto_show_hide_form_market(nx_current())
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local root = form.tree_market.RootNode
  if not nx_is_valid(root) then
    return
  end
  local node_table = root:GetNodeList()
  if table.getn(node_table) >= 1 then
    form.tree_market.SelectNode = node_table[1]
    node_table[1].Expand = true
  end
  form.ipt_search_key.Text = nx_widestr(item_name)
end
function auto_show_hide_form_market(show)
  util_auto_show_hide_form("form_stage_main\\form_market\\form_market")
end
function main_form_init(self)
  self.Fixed = false
  self.info_string = ""
  self.stall_master = ""
  self.type = 0
  self.show_type = 0
  self.item_type = 0
  self.search_type = 0
  self.cur_page = 1
  self.max_page = 1
  self.sifter_select_num = 0
  load_sifter_ini()
end
function on_main_form_open(self)
  ui_show_attached_form(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - (self.Width - self.groupbox_sifter.Width)) / 2
  self.Top = (gui.Height - self.Height) / 2
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("CapitalType2", "int", self, nx_current(), "show_money")
    databinder:AddViewBind(VIEWPORT_ITEM_MARKET_BOX, self, nx_current(), "on_market_viewport_change")
  end
  create_market_tree(self)
  self.ipt_search_key.Text = nx_widestr(util_text("ui_trade_search_key"))
  self.combobox_itemname.Visible = false
  self.groupbox_clolor.Visible = false
  self.groupbox_search.Visible = false
  self.btn_jump.Visible = false
  self.lbl_wait.Visible = false
  self.lbl_cover.Visible = false
  self.btn_select.Enabled = false
  self.lbl_tips.Visible = true
  self.mltbox_markethelp.Visible = true
  self.lbl_pictureback.Visible = true
  self.groupbox_sifter.item_type = 0
  set_clolor_level_combobox(self)
  show_money(self)
  show_market_name(self)
  show_market_back_picture(self)
  self.btn_webexchange.Visible = false
  nx_execute("form_stage_main\\form_webexchange\\form_exchange_main", "test_webexchange_switch")
end
function on_main_form_close(self)
  ui_destroy_attached_form(self)
  nx_destroy(self)
end
function on_main_form_shut(self)
  local databinder = nx_value("data_binder")
  databinder:DelRolePropertyBind("FillSpeed", self)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "close_wait_cover", self)
  timer:UnRegister(nx_current(), "refresh_item_form", self)
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
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
function refresh_stall_form(form, issearch)
  if not nx_is_valid(form) then
    return
  end
  form.show_type = nx_int(MARKET_NODE_STALL)
  form.lbl_background.BackImage = "gui\\special\\maket\\maket_stall_bg.png"
  form.textgrid_market:BeginUpdate()
  form.textgrid_market:ClearRow()
  form.textgrid_market:ClearSelect()
  form.btn_select.Enabled = false
  form.btn_select.Text = nx_widestr(util_text("ui_trade_look"))
  local gui = nx_value("gui")
  form.textgrid_market.ColCount = 4
  form.textgrid_market.ColWidths = "140, 250, 100, 100"
  form.textgrid_market:SetColTitle(0, nx_widestr(util_text("ui_trade_master")))
  form.textgrid_market:SetColTitle(1, nx_widestr(util_text("ui_trade_name")))
  form.textgrid_market:SetColTitle(2, nx_widestr(util_text("ui_trade_address")))
  form.textgrid_market:SetColTitle(3, nx_widestr(util_text("ui_stall_level")))
  local string_table = util_split_wstring(nx_widestr(form.info_string), nx_widestr("^"))
  local stall_num = nx_int(table.getn(string_table) / STALL_INFO_NUM)
  local begin_index = 1
  for i = 0, stall_num - 1 do
    local nosearch = nx_ws_equal(nx_widestr(util_text("ui_trade_search_key")), nx_widestr(form.ipt_search_key.Text))
    local inmaster = nx_function("ext_ws_find", nx_widestr(string_table[begin_index]), nx_widestr(form.ipt_search_key.Text))
    local inname = nx_function("ext_ws_find", nx_widestr(string_table[begin_index + 1]), nx_widestr(form.ipt_search_key.Text))
    if nosearch or nx_int(inmaster) >= nx_int(0) or nx_int(inname) >= nx_int(0) then
      local row = form.textgrid_market:InsertRow(-1)
      local stall_place = nx_widestr(string_table[begin_index + 2]) .. nx_widestr(",") .. nx_widestr(string_table[begin_index + 3])
      form.textgrid_market:SetGridText(row, 0, nx_widestr(string_table[begin_index]))
      form.textgrid_market:SetGridText(row, 1, nx_widestr(string_table[begin_index + 1]))
      form.textgrid_market:SetGridText(row, 2, nx_widestr(stall_place))
      form.textgrid_market:SetGridText(row, 3, nx_widestr(string_table[begin_index + 4]))
      local stall_level = get_stall_level(nx_int(string_table[begin_index + 4]))
      local level_photo = creat_level_photo(nx_int(stall_level))
      form.textgrid_market:SetGridControl(row, 3, level_photo)
      if nx_int(string_table[begin_index + 5]) == nx_int(1) then
        form.textgrid_market:SetGridForeColor(row, 0, "255,153,51,0")
        form.textgrid_market:SetGridForeColor(row, 1, "255,153,51,0")
        form.textgrid_market:SetGridForeColor(row, 2, "255,153,51,0")
      else
        form.textgrid_market:SetGridForeColor(row, 0, "255,69,51,38")
        form.textgrid_market:SetGridForeColor(row, 1, "255,127,101,74")
        form.textgrid_market:SetGridForeColor(row, 2, "255,127,101,74")
      end
    end
    begin_index = begin_index + STALL_INFO_NUM
  end
  form.textgrid_market:SortRowsByInt(3, true)
  form.textgrid_market:EndUpdate()
  form.groupbox_page.Visible = false
end
function refresh_hire_shop_form(form)
  if not nx_is_valid(form) then
    return
  end
  form.show_type = nx_int(MARKET_NODE_HIRESHOP)
  form.lbl_background.BackImage = "gui\\special\\maket\\maket_stall_bg.png"
  form.textgrid_market:BeginUpdate()
  form.textgrid_market:ClearRow()
  form.textgrid_market:ClearSelect()
  form.btn_select.Enabled = false
  form.btn_select.Text = nx_widestr(util_text("ui_trade_look"))
  local gui = nx_value("gui")
  form.textgrid_market.ColCount = 4
  form.textgrid_market.ColWidths = "140, 250, 100, 0"
  form.textgrid_market:SetColTitle(0, nx_widestr(util_text("ui_trade_master")))
  form.textgrid_market:SetColTitle(1, nx_widestr(util_text("ui_trade_name")))
  form.textgrid_market:SetColTitle(2, nx_widestr(util_text("ui_trade_address")))
  form.textgrid_market:SetColTitle(3, nx_widestr(util_text("")))
  local string_table = util_split_wstring(nx_widestr(form.info_string), nx_widestr("^"))
  local shop_num = table.getn(string_table) / HIRE_SHOP_INFO_NUM
  local begin_index = 1
  for i = 0, shop_num - 1 do
    local nosearch = nx_ws_equal(nx_widestr(util_text("ui_trade_search_key")), nx_widestr(form.ipt_search_key.Text))
    local inmaster = nx_function("ext_ws_find", nx_widestr(string_table[begin_index + 1]), nx_widestr(form.ipt_search_key.Text))
    local inname = nx_function("ext_ws_find", nx_widestr(string_table[begin_index + 2]), nx_widestr(form.ipt_search_key.Text))
    if nosearch or nx_int(inmaster) >= nx_int(0) or nx_int(inname) >= nx_int(0) then
      local row = form.textgrid_market:InsertRow(-1)
      local shop_place = nx_widestr(string_table[begin_index + 3]) .. nx_widestr(",") .. nx_widestr(string_table[begin_index + 4])
      form.textgrid_market:SetGridText(row, 0, nx_widestr(string_table[begin_index + 1]))
      form.textgrid_market:SetGridText(row, 1, nx_widestr(string_table[begin_index + 2]))
      form.textgrid_market:SetGridText(row, 2, nx_widestr(shop_place))
      form.textgrid_market:SetGridText(row, 3, nx_widestr(string_table[begin_index]))
    end
    begin_index = begin_index + HIRE_SHOP_INFO_NUM
  end
  form.textgrid_market:EndUpdate()
  form.groupbox_page.Visible = false
end
function refresh_item_form(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.type) ~= nx_int(MARKET_NODE_ITEM) then
    return
  end
  form.show_type = nx_int(MARKET_NODE_ITEM)
  form.lbl_background.BackImage = "gui\\special\\maket\\maket_bg.png"
  form.btn_select.Enabled = false
  form.btn_select.Text = nx_widestr(util_text("ui_goumai"))
  local gui = nx_value("gui")
  form.textgrid_market:BeginUpdate()
  form.textgrid_market:ClearRow()
  form.textgrid_market.ColCount = 6
  form.textgrid_market.ColWidths = "60, 150, 60, 60, 85, 170"
  form.textgrid_market:SetColTitle(0, nx_widestr(util_text("ui_market_item_photo")))
  form.textgrid_market:SetColTitle(1, nx_widestr(util_text("ui_market_item_name")))
  form.textgrid_market:SetColTitle(2, nx_widestr(util_text("ui_trade_colorlevel")))
  form.textgrid_market:SetColTitle(3, nx_widestr(util_text("ui_number")))
  form.textgrid_market:SetColTitle(4, nx_widestr(util_text("ui_trade_master")))
  form.textgrid_market:SetColTitle(5, nx_widestr(util_text("ui_market_item_price")))
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_ITEM_MARKET_BOX))
  if nx_is_valid(view) then
    for i = 1, ITEM_PAGE_COUNT do
      local row = form.textgrid_market:InsertRow(-1)
      local item_id = view:GetViewObj(nx_string(i))
      if nx_is_valid(item_id) then
        local temp_name = item_id:QueryProp("ConfigID")
        local item_amount = item_id:QueryProp("Amount")
        local color_level = item_id:QueryProp("ColorLevel")
        local color_text = "ui_market_color_level_" .. nx_string(color_level)
        local item_image = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(temp_name), "Photo")
        local grp = gui:Create("GroupBox")
        grp.LineColor = "0,0,0,0"
        grp.BackColor = "0,0,0,0"
        grp.Transparent = true
        local lbl = gui:Create("Label")
        lbl.Width = 45
        lbl.Height = 45
        lbl.Left = 5
        lbl.Top = 3
        lbl.BackImage = item_image
        lbl.DrawMode = FitWindow
        lbl.Transparent = false
        lbl.item = item_id
        nx_bind_script(lbl, nx_current())
        nx_callback(lbl, "on_get_capture", "on_item_photo_get_capture")
        nx_callback(lbl, "on_lost_capture", "on_item_photo_lost_capture")
        nx_callback(lbl, "on_left_double_click", "on_item_photo_left_double_click")
        grp:Add(lbl)
        local item_owner = view:QueryRecord("show_item_rec", row, 0)
        local item_price = view:QueryRecord("show_item_rec", row, 1)
        local capital_manager = nx_value("CapitalModule")
        local price_ctrl = create_price_ctrl(form, item_price)
        form.textgrid_market:SetGridControl(row, 0, grp)
        local equip_type = item_id:QueryProp("EquipType")
        if nx_string(equip_type) == nx_string("NewTreasure") then
          if color_level < 4 then
            temp_name = gui.TextManager:GetText(temp_name)
          else
            local suit_id = item_id:QueryProp("TersureSuitID")
            if 0 < suit_id and suit_id <= 10 then
              local item_name_1 = gui.TextManager:GetText("desc_newtreasure_combination_" .. suit_id)
              local item_name_2 = gui.TextManager:GetText(item_id:QueryProp("ConfigID"))
              temp_name = nx_widestr(item_name_1) .. nx_widestr(item_name_2)
            end
          end
          form.textgrid_market:SetGridText(row, 1, nx_widestr(temp_name))
        else
          form.textgrid_market:SetGridText(row, 1, nx_widestr(util_text(temp_name)))
        end
        form.textgrid_market:SetGridText(row, 2, nx_widestr(util_text(color_text)))
        form.textgrid_market:SetGridText(row, 3, nx_widestr(item_amount))
        form.textgrid_market:SetGridText(row, 4, nx_widestr(item_owner))
        form.textgrid_market:SetGridControl(row, 5, price_ctrl)
      end
    end
  end
  form.textgrid_market:EndUpdate()
  show_form_page(form)
end
function show_money(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local capital = client_player:QueryProp("CapitalType2")
  local money_text = nx_execute("util_functions", "trans_capital_string", nx_int(capital))
  form.lbl_money.Text = nx_widestr(money_text)
end
function show_market_name(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local scene_config = client_scene:QueryProp("ConfigID")
  form.lbl_market_name.Text = nx_widestr(util_text(scene_config) .. util_text("ui_trade_title"))
end
function on_market_viewport_change(form)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  timer:Register(800, 1, nx_current(), "refresh_item_form", form, -1, -1)
end
function on_market_msg(sub_cmd, arg1, arg2)
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_OPEN_STALL) then
    if arg1 == nil then
      return false
    end
    local form_market = util_get_form("form_stage_main\\form_market\\form_market", false)
    if not nx_is_valid(form_market) then
      return false
    end
    form_market.info_string = arg1
    refresh_stall_form(form_market)
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_OPEN_HIRE_SHOP) then
    if arg1 == nil then
      return false
    end
    local form_market = util_get_form("form_stage_main\\form_market\\form_market", false)
    if not nx_is_valid(form_market) then
      return false
    end
    form_market.info_string = arg1
    refresh_hire_shop_form(form_market)
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_ADD_STALL_BOX) then
    util_show_form("form_stage_main\\form_market\\form_market_stall", true)
    local form_stall = util_get_form("form_stage_main\\form_market\\form_market_stall", false)
    if not nx_is_valid(form_stall) then
      return false
    end
    form_stall.master = nx_widestr(arg1)
    form_stall.lbl_form_name.Text = nx_widestr(arg2)
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_LIUYAN_OKAY) then
    nx_execute("form_stage_main\\form_market\\form_market_liuyan", "on_liuyan_ok")
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_CLOSE_MARKET) then
    util_show_form("form_stage_main\\form_market\\form_market_stall", false)
    util_show_form("form_stage_main\\form_market\\form_market", false)
    util_show_form("form_stage_main\\form_hire_shop\\form_hire_shop_mine", false)
    util_show_form("form_stage_main\\form_hire_shop\\form_hire_shop", false)
    local form_buy = util_get_form("form_stage_main\\form_shop\\form_trade_buy", false, false)
    if nx_is_valid(form_buy) then
      nx_execute("form_stage_main\\form_shop\\form_trade_buy", "on_btn_cancel_click", form_buy.btn_cancel)
    end
  end
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_tree_market_select_changed(self, cur_node)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.lbl_wait.Visible == true then
    return
  end
  form.combobox_itemname.Visible = true
  form.groupbox_clolor.Visible = true
  form.btn_search_key.Enabled = false
  form.groupbox_search.Visible = true
  form.btn_jump.Visible = true
  form.lbl_tips.Visible = false
  form.mltbox_markethelp.Visible = false
  form.lbl_pictureback.Visible = false
  form.ipt_search_key.Text = nx_widestr(util_text("ui_trade_search_key"))
  form.cur_page = nx_int(1)
  if nx_find_custom(cur_node, "market_type") then
    if nx_int(cur_node.market_type) == nx_int(MARKET_NODE_STALL) then
      form.combobox_itemname.Visible = false
      form.groupbox_clolor.Visible = false
      form.btn_search_key.Enabled = true
      show_wait_cover(form)
      nx_execute("custom_sender", "custom_market_msg", SUB_CLIENT_OPEN_STALL)
    elseif nx_int(cur_node.market_type) == nx_int(MARKET_NODE_HIRESHOP) then
      form.combobox_itemname.Visible = false
      form.groupbox_clolor.Visible = false
      form.btn_search_key.Enabled = true
      show_wait_cover(form)
      nx_execute("custom_sender", "custom_market_msg", SUB_CLIENT_OPEN_HIRE_SHOP)
    end
    form.type = nx_int(cur_node.market_type)
  else
    form.type = nx_int(MARKET_NODE_ITEM)
  end
  if nx_find_custom(cur_node, "item_type") then
    form.item_type = nx_int(cur_node.item_type)
    form.cur_page = nx_int(1)
    form.max_page = nx_int(1)
    if nx_find_custom(cur_node, "select_color") then
      form.combobox_color.DropListBox.SelectIndex = nx_int(cur_node.select_color)
      form.combobox_color.Text = nx_widestr(form.combobox_color.DropListBox:GetString(nx_int(cur_node.select_color)))
    end
    show_sifter(form, form.item_type)
    search_item_color(form)
    on_market_viewport_change(form)
    show_wait_cover(form)
  end
end
function on_btn_webexchange_click(self)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local powerlevel = client_player:QueryProp("PowerLevel")
  if nx_int(powerlevel) < nx_int(11) then
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("10020"), 2)
    end
    return
  end
  nx_execute("form_stage_main\\form_webexchange\\form_exchange_main", "open_close_webexchange")
end
function on_textgrid_market_right_select_grid(self, row, col)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local name = ""
  if nx_int(form.type) == nx_int(MARKET_NODE_ITEM) then
    name = self:GetGridText(row, 4)
  else
    name = self:GetGridText(row, 0)
  end
  if nx_string(name) == "" then
    return
  end
  nx_pause(0.1)
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "market", "market")
  nx_execute("menu_game", "menu_recompose", menu_game, name)
  local curx, cury = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, curx, cury)
end
function on_btn_search_key_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.type) == nx_int(MARKET_NODE_STALL) then
    refresh_stall_form(form)
  elseif nx_int(form.type) == nx_int(MARKET_NODE_HIRESHOP) then
    refresh_hire_shop_form(form)
  elseif nx_int(form.type) == nx_int(MARKET_NODE_ITEM) then
    form.cur_page = nx_int(1)
    show_wait_cover(form)
    search_item_config(form)
    record_search_item(form)
  end
end
function on_btn_refresh_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.show_type) == nx_int(MARKET_NODE_STALL) then
    nx_execute("custom_sender", "custom_market_msg", SUB_SERVER_OPEN_STALL)
  elseif nx_int(form.show_type) == nx_int(MARKET_NODE_HIRESHOP) then
    nx_execute("custom_sender", "custom_market_msg", SUB_CLIENT_OPEN_HIRE_SHOP)
  elseif nx_int(form.show_type) == nx_int(MARKET_NODE_ITEM) then
    request_page_item(form)
  end
  show_wait_cover(form)
end
function on_ipt_search_key_get_focus(self)
  local gui = nx_value("gui")
  gui.hyperfocused = self
  if nx_string(self.Text) == nx_string(util_text("ui_trade_search_key")) then
    self.Text = ""
  end
end
function on_ipt_search_key_lost_focus(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_string(self.Text) == nx_string("") then
    self.Text = nx_widestr(util_text("ui_trade_search_key"))
  end
end
function on_textgrid_market_double_click_grid(self, row)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.show_type) == nx_int(MARKET_NODE_STALL) then
    local master_name = self:GetGridText(row, 0)
    form.stall_master = master_name
    nx_execute("custom_sender", "custom_market_msg", SUB_CLIENT_SELECT_STALL, nx_widestr(master_name))
  elseif nx_int(form.show_type) == nx_int(MARKET_NODE_HIRESHOP) then
    local npc_id = self:GetGridText(row, 3)
    nx_execute("custom_sender", "custom_market_msg", SUB_CLIENT_SELECT_HIRE_SHOP, nx_string(npc_id))
  elseif nx_int(form.show_type) == nx_int(MARKET_NODE_ITEM) then
    market_buy_one_item(self, row)
  end
end
function on_btn_select_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local select_row = form.textgrid_market.RowSelectIndex
  local row_cout = form.textgrid_market.RowCount
  if nx_int(select_row) < nx_int(0) or nx_int(select_row) >= nx_int(row_cout) then
    return
  end
  if nx_int(form.show_type) == nx_int(MARKET_NODE_STALL) then
    local master_name = form.textgrid_market:GetGridText(select_row, 0)
    form.stall_master = master_name
    nx_execute("custom_sender", "custom_market_msg", SUB_CLIENT_SELECT_STALL, nx_widestr(master_name))
  elseif nx_int(form.show_type) == nx_int(MARKET_NODE_HIRESHOP) then
    local npc_id = form.textgrid_market:GetGridText(select_row, 3)
    nx_execute("custom_sender", "custom_market_msg", SUB_CLIENT_SELECT_HIRE_SHOP, nx_string(npc_id))
  elseif nx_int(form.show_type) == nx_int(MARKET_NODE_ITEM) then
    market_buy_one_item(form.textgrid_market, select_row)
  end
end
function on_textgrid_market_select_row(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.btn_select.Enabled = true
end
function on_ipt_search_key_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.type) ~= nx_int(MARKET_NODE_ITEM) then
    return
  end
  if nx_string(self.Text) == nx_string("") then
    show_search_item(form)
    return
  end
  if nx_string(self.Text) == nx_string(util_text("ui_trade_search_key")) then
    return
  end
  local gui = nx_value("gui")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  form.combobox_itemname.DropListBox:ClearString()
  local search_table = ItemQuery:FindItemsByName(nx_widestr(self.Text))
  market_item_table = {}
  for i = 1, nx_number(table.getn(search_table)) do
    local item_config = search_table[i]
    local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
    if bExist == true then
      local IsMarketItem = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("IsMarketItem"))
      if nx_int(IsMarketItem) == nx_int(1) then
        local static_data = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("LogicPack"))
        local bind_type = item_static_query(nx_int(static_data), "BindType", STATIC_DATA_ITEM_LOGIC)
        if nx_int(bind_type) ~= nx_int(1) and gui.TextManager:IsIDName(search_table[i]) then
          form.combobox_itemname.DropListBox:AddString(nx_widestr(util_text(search_table[i])))
          table.insert(market_item_table, search_table[i])
        end
      end
    end
  end
  if not form.combobox_itemname.DroppedDown then
    form.combobox_itemname.DroppedDown = true
  end
end
function on_combobox_itemname_selected(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = form.combobox_itemname.DropListBox.SelectIndex
  if index < table.getn(market_item_table) then
    form.combobox_itemname.config = market_item_table[index + 1]
    form.btn_search_key.Enabled = true
  end
  form.ipt_search_key.Text = form.combobox_itemname.Text
  form.combobox_itemname.Text = nx_widestr("")
end
function on_combobox_color_selected(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.item_type == nil or nx_int(form.item_type) == nx_int(0) then
    return
  end
  form.cur_page = nx_int(1)
  form.max_page = nx_int(1)
  search_item_color(form)
  on_market_viewport_change(form)
  show_wait_cover(form)
end
function on_item_photo_get_capture(self)
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_goods_tip", self.item, x, y, 32, 32, self.ParentForm)
end
function on_item_photo_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_item_photo_left_double_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local select_row = form.textgrid_market.RowSelectIndex
  local row_cout = form.textgrid_market.RowCount
  if nx_int(select_row) < nx_int(0) or nx_int(select_row) >= nx_int(row_cout) then
    return
  end
  market_buy_one_item(form.textgrid_market, select_row)
end
function on_ipt_page_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(self.Text) > nx_int(form.max_page) then
    self.Text = nx_widestr(form.max_page)
  end
  if nx_int(self.Text) < nx_int(1) then
    self.Text = nx_widestr(1)
  end
end
function on_btn_page_dec_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.cur_page = form.cur_page - 1
  if nx_int(form.cur_page) < nx_int(1) then
    form.cur_page = nx_int(1)
    return
  end
  request_page_item(form)
  show_wait_cover(form)
end
function on_btn_page_add_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.cur_page = form.cur_page + 1
  if nx_int(form.cur_page) > nx_int(form.max_page + 1) then
    form.cur_page = nx_int(form.max_page + 1)
    return
  end
  request_page_item(form)
  show_wait_cover(form)
end
function on_btn_goto_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.cur_page = nx_int(form.ipt_page.Text)
  if nx_int(form.cur_page) < nx_int(1) then
    form.cur_page = nx_int(1)
  end
  if nx_int(form.cur_page) > nx_int(form.max_page + 1) then
    form.cur_page = nx_int(form.max_page + 1)
  end
  request_page_item(form)
  show_wait_cover(form)
end
function on_btn_hire_shop_mine_click(self)
  nx_execute("form_stage_main\\form_hire_shop\\form_hire_shop_mine", "open_close_form")
end
function on_btn_hireshop_compete_click(self)
  nx_execute("form_stage_main\\form_hire_shop\\form_hire_shop_my_compete", "open_close_form")
end
function on_btn_sift_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_MARKET_SIFTER) then
    return
  end
  local form = btn.ParentForm
  search_item_config(form)
end
function get_stall_level(sellamount)
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\market.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local sec_index = ini:FindSectionIndex(nx_string("StallLevel"))
  if sec_index < 0 then
    return 0
  end
  local level_count = ini:GetSectionItemCount(sec_index)
  for i = 0, level_count - 1 do
    local value = ini:GetSectionItemValue(sec_index, i)
    if nx_int(sellamount) < nx_int(value) then
      return ini:GetSectionItemKey(sec_index, i) - 1
    end
  end
  return ini:GetSectionItemKey(sec_index, level_count - 1)
end
function show_market_back_picture(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return nx_int(-1)
  end
  local scene_config = client_scene:QueryProp("ConfigID")
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\market.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local sec_index = ini:FindSectionIndex(nx_string("Background"))
  if sec_index < 0 then
    return 0
  end
  local item_index = ini:FindSectionItemIndex(sec_index, nx_string(scene_config))
  if nx_int(item_index) < nx_int(0) then
    return
  end
  form.lbl_pictureback.BackImage = ini:GetSectionItemValue(sec_index, item_index)
end
function creat_level_photo(level)
  local gui = nx_value("gui")
  local grp = gui:Create("GroupBox")
  grp.LineColor = "0,0,0,0"
  grp.BackColor = "0,0,0,0"
  grp.Transparent = true
  local index = 1
  local sunlevel = nx_int(level / 9)
  for i = 1, nx_number(sunlevel) do
    local lbl = gui:Create("Label")
    lbl.Left = index * 18
    lbl.Top = 16
    lbl.AutoSize = true
    lbl.BackImage = "gui\\special\\maket\\sun01.png"
    grp:Add(lbl)
    index = index + 1
  end
  local moonlevel = nx_int((level - sunlevel * 9) / 3)
  for i = 1, nx_number(moonlevel) do
    local lbl = gui:Create("Label")
    lbl.Left = index * 18
    lbl.Top = 16
    lbl.AutoSize = true
    lbl.BackImage = "gui\\special\\maket\\moon01.png"
    grp:Add(lbl)
    index = index + 1
  end
  local starlevel = nx_int(level - sunlevel * 9 - moonlevel * 3)
  for i = 1, nx_number(starlevel) do
    local lbl = gui:Create("Label")
    lbl.Left = index * 18
    lbl.Top = 16
    lbl.AutoSize = true
    lbl.BackImage = "gui\\special\\maket\\star01.png"
    grp:Add(lbl)
    index = index + 1
  end
  return grp
end
function search_item_by_thirdnode(form)
  if not nx_is_valid(form) then
    return false
  end
  local select_node = form.tree_market.SelectNode
  if not nx_is_valid(select_node) then
    return false
  end
  if not nx_find_custom(select_node, "item_type") then
    return false
  end
  if form.ipt_search_key.Text ~= nx_widestr("") and form.ipt_search_key.Text ~= nx_widestr(util_text("ui_trade_search_key")) then
    return false
  end
  form.search_type = nx_int(SEARCH_ITEM_TYPE_COLOR)
  form.item_type = nx_int(select_node.item_type)
  form.cur_page = nx_int(1)
  form.max_page = nx_int(1)
  local search_index = nx_int((form.cur_page - 1) * ITEM_PAGE_COUNT)
  local color_level = nx_int(form.combobox_color.DropListBox.SelectIndex)
  if nx_int(color_level) == nx_int(0) then
    nx_execute("custom_sender", "custom_market_msg", SUB_CLIENT_ITEM_SELECT_TYPE, nx_int(select_node.item_type), nx_int(search_index), nx_string(get_sifter_str(form, form.item_type)))
  else
    nx_execute("custom_sender", "custom_market_msg", SUB_CLIENT_ITEM_SELECT_COLOR, nx_int(select_node.item_type), nx_int(color_level), nx_int(search_index), nx_string(get_sifter_str(form, form.item_type)))
  end
  on_market_viewport_change(form)
  show_wait_cover(form)
  show_sifter(form, form.item_type)
  return true
end
function search_item_config(form)
  if not nx_is_valid(form) then
    return
  end
  if search_item_by_thirdnode(form) then
    return
  end
  local item_config = form.combobox_itemname.config
  if item_config == nil or nx_string(item_config) == "" then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  if ItemQuery:FindItemByConfigID(nx_string(item_config)) then
    local item_type = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("ItemType"))
    local color_level = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("ColorLevel"))
    local search_index = nx_int((form.cur_page - 1) * ITEM_PAGE_COUNT)
    if nx_int(item_type) >= nx_int(146) and nx_int(item_type) <= nx_int(150) then
      nx_execute("custom_sender", "custom_market_msg", SUB_CLIENT_ITEM_SELECT_TYPE, nx_int(item_type), nx_int(search_index), nx_string(get_sifter_str(form, item_type)))
      on_market_viewport_change(form)
      show_wait_cover(form)
      return
    end
    nx_execute("custom_sender", "custom_market_msg", SUB_CLIENT_ITEM_SELECT_CONFIGID, nx_int(item_type), nx_int(color_level), nx_string(item_config), nx_int(search_index))
    form.item_type = 0
    form.search_type = nx_int(SEARCH_ITEM_TYPE_CONFIGID)
  end
end
function search_item_color(form)
  if not nx_is_valid(form) then
    return
  end
  form.search_type = nx_int(SEARCH_ITEM_TYPE_COLOR)
  local search_index = nx_int((form.cur_page - 1) * ITEM_PAGE_COUNT)
  local color_level = nx_int(form.combobox_color.DropListBox.SelectIndex)
  if nx_int(color_level) == nx_int(0) then
    nx_execute("custom_sender", "custom_market_msg", SUB_CLIENT_ITEM_SELECT_TYPE, nx_int(form.item_type), nx_int(search_index), nx_string(get_sifter_str(form, form.item_type)))
  else
    nx_execute("custom_sender", "custom_market_msg", SUB_CLIENT_ITEM_SELECT_COLOR, nx_int(form.item_type), nx_int(color_level), nx_int(search_index), nx_string(get_sifter_str(form, form.item_type)))
  end
end
function create_market_tree(form)
  if not nx_is_valid(form) then
    return
  end
  local root = form.tree_market:CreateRootNode(nx_widestr("Root"))
  form.tree_market:BeginUpdate()
  for i = 1, MARKET_NODE_END - 1 do
    local market_root = root:CreateNode(nx_widestr(util_text("ui_market_node_" .. i)))
    market_root.market_type = i
    set_node_prop(market_root, "first")
  end
  local item_root = root:FindNode(nx_widestr(util_text("ui_market_node_" .. MARKET_NODE_ITEM)))
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
    end
  end
  root.Expand = true
  form.tree_market:EndUpdate()
end
function set_node_prop(node, node_type)
  if not nx_is_valid(node) or node_type == nil then
    return 0
  end
  for key, value in pairs(NODE_PROP[node_type]) do
    nx_set_property(node, nx_string(key), value)
  end
end
function set_clolor_level_combobox(form)
  form.combobox_itemname.DropListBox:ClearString()
  for i = 0, COLOR_LEVEL_COUNT do
    local color_text = "ui_market_color_level_" .. nx_string(i)
    form.combobox_color.DropListBox:AddString(nx_widestr(util_text(color_text)))
  end
  form.combobox_color.DropListBox.SelectIndex = COLOR_LEVEL_COUNT
  form.combobox_color.Text = nx_widestr(form.combobox_color.DropListBox:GetString(COLOR_LEVEL_COUNT))
end
function show_wait_cover(form)
  form.lbl_wait.Visible = true
  form.lbl_cover.Visible = true
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, 1, nx_current(), "close_wait_cover", form, -1, -1)
end
function close_wait_cover(form)
  if not nx_is_valid(form) then
    return 0
  end
  form.lbl_wait.Visible = false
  form.lbl_cover.Visible = false
end
function market_buy_one_item(grid, row)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_ITEM_MARKET_BOX))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(row + 1))
  if not nx_is_valid(viewobj) then
    return
  end
  local item_id = viewobj:QueryProp("ConfigID")
  local item_sellcount = viewobj:QueryProp("Amount")
  local item_uniqueid = viewobj:QueryProp("UniqueID")
  local master_name = view:QueryRecord("show_item_rec", row, 0)
  local item_price = view:QueryRecord("show_item_rec", row, 1)
  local source_type = view:QueryRecord("show_item_rec", row, 2)
  local owner_id = view:QueryRecord("show_item_rec", row, 3)
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_shop\\form_trade_buy", true, false)
  dialog.lbl_max_count.Text = nx_widestr(item_sellcount)
  dialog.lbl_max_count.Visible = false
  dialog.lbl_tip.Text = nx_widestr(util_text(item_id))
  dialog.ipt_count.Text = nx_widestr(1)
  dialog.Left = grid.Parent.Left + (grid.Parent.Width - dialog.Width) / 2
  dialog.Top = grid.Parent.Top + (grid.Parent.Height - dialog.Height) / 2
  nx_execute("form_stage_main\\form_shop\\form_trade_buy", "init_buy_form", dialog, 2, item_price, item_sellcount)
  dialog.retail_mode = "buy"
  dialog.Visible = true
  dialog:ShowModal()
  local res, count, paymodel = nx_wait_event(100000000, dialog, "form_retail_return")
  if res == "ok" then
    if count == 0 then
      count = item_sellcount
    end
    if nx_int(source_type) == nx_int(1) then
      nx_execute("custom_sender", "custom_stall_buy_from_stall", nx_widestr(master_name), nx_string(item_uniqueid), nx_int(count), nx_int64(item_price))
    elseif nx_int(source_type) == nx_int(2) then
      nx_execute("custom_sender", "custom_market_msg", SUB_CLIENT_BUY_HIRE_SHOP_ITEM, nx_object(owner_id), nx_string(item_uniqueid), nx_int(count), nx_int64(item_price))
    end
  end
end
function show_form_page(form)
  if not nx_is_valid(form) then
    return 0
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_ITEM_MARKET_BOX))
  if nx_is_valid(view) then
    local tatal_count = view:QueryProp("TotalCount")
    form.max_page = math.ceil(tatal_count / ITEM_PAGE_COUNT)
  end
  if nx_int(form.max_page) < nx_int(1) then
    form.max_page = 1
  end
  if nx_int(form.cur_page) <= nx_int(1) then
    form.cur_page = nx_int(1)
    form.btn_page_dec.Enabled = false
  else
    form.btn_page_dec.Enabled = true
  end
  if nx_int(form.cur_page) >= nx_int(form.max_page) then
    form.btn_page_add.Enabled = false
  else
    form.btn_page_add.Enabled = true
  end
  if nx_int(form.cur_page) >= nx_int(form.max_page + 1) then
    form.cur_page = form.max_page + 1
    form.max_page = form.max_page + 1
  end
  form.groupbox_page.Visible = true
  form.lbl_max_page.Text = nx_widestr(form.max_page)
  form.ipt_page.Text = nx_widestr(form.cur_page)
end
function request_page_item(form)
  local index = nx_int((form.cur_page - 1) * ITEM_PAGE_COUNT)
  if nx_int(form.search_type) == nx_int(SEARCH_ITEM_TYPE_COLOR) then
    search_item_color(form)
  elseif nx_int(form.search_type) == nx_int(SEARCH_ITEM_TYPE_CONFIGID) then
    search_item_config(form)
  end
end
function create_price_ctrl(form, price)
  if not nx_is_valid(form) then
    return
  end
  local gbox_item = create_ctrl("GroupBox", form.groupbox_price)
  local lbl_yb = create_ctrl("Label", form.lbl_yb_src)
  gbox_item:Add(lbl_yb)
  local ding = math.floor(price / 1000000)
  local liang = math.floor(price % 1000000 / 1000)
  local wen = math.floor(price % 1000)
  if nx_int(ding) > nx_int(0) then
    local lbl_ding = create_ctrl("Label", form.lbl_ding_src)
    lbl_ding.Text = nx_widestr(nx_widestr(ding) .. nx_widestr(util_text("ui_ding")))
    gbox_item:Add(lbl_ding)
  end
  if nx_int(liang) > nx_int(0) or nx_int(ding) > nx_int(0) then
    local lbl_liang = create_ctrl("Label", form.lbl_liang_src)
    lbl_liang.Text = nx_widestr(nx_widestr(liang) .. nx_widestr(util_text("ui_liang")))
    gbox_item:Add(lbl_liang)
  end
  local lbl_wen = create_ctrl("Label", form.lbl_wen_src)
  lbl_wen.Text = nx_widestr(nx_widestr(wen) .. nx_widestr(util_text("ui_wen")))
  gbox_item:Add(lbl_wen)
  return gbox_item
end
function create_ctrl(ctrl_name, refer_ctrl)
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
  return ctrl
end
function record_search_item(form)
  local item_config = form.combobox_itemname.config
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
function show_search_item(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(table.getn(market_search_table)) <= nx_int(0) then
    return
  end
  form.combobox_itemname.DropListBox:ClearString()
  market_item_table = {}
  for i = table.getn(market_search_table), 1, -1 do
    form.combobox_itemname.DropListBox:AddString(nx_widestr(util_text(market_search_table[i])))
    table.insert(market_item_table, market_search_table[i])
  end
  if not form.combobox_itemname.DroppedDown then
    form.combobox_itemname.DroppedDown = true
  end
end
function show_sifter(form, item_type)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_MARKET_SIFTER) then
    return
  end
  if form.groupbox_sifter.item_type == item_type then
    return
  end
  form.sifter_select_num = 0
  form.groupbox_sifter.item_type = item_type
  local tab_node = sifter_tree_node_tab[item_type]
  local tab_sifter = ItemSifter[item_type]
  if tab_node == nil or table.getn(tab_node) == 0 or tab_sifter == nil or table.getn(tab_sifter) == 0 then
    form.groupbox_sifter.Visible = false
    return
  end
  form.groupbox_sifter.Visible = true
  form.tree_ex_sifter:BeginUpdate()
  local sifter_root = form.tree_ex_sifter.RootNode
  if not nx_is_valid(sifter_root) then
    sifter_root = form.tree_ex_sifter:CreateRootNode(nx_widestr(""))
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
              map_node2.sifter_type = tab_sifter[j].type
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
  form.tree_ex_sifter:EndUpdate()
end
function load_sifter_ini()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_MARKET_SIFTER) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\market_sifter.ini")
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
      if table.getn(tab_item_value) == 4 then
        tab.node_type = tab_item_value[1]
        tab.type = tab_item_value[2]
        tab.ui = tab_item_value[3]
        tab.sift = tab_item_value[4]
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
function on_tree_ex_sifter_select_double_click(tree, node)
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
    elseif form.sifter_select_num >= MAX_SELECT_SIFTER_NUMBER then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("tips_sifter_001"), 2)
      end
    else
      node.select = true
      form.sifter_select_num = form.sifter_select_num + 1
      node.NodeBackImage = "gui\\special\\maket\\shaixuan_down.png"
      node.NodeFocusImage = "gui\\special\\maket\\shaixuan_down.png"
      node.NodeSelectImage = "gui\\special\\maket\\shaixuan_down.png"
    end
  else
    form.tree_ex_sifter:BeginUpdate()
    if node.Expand then
      node.Expand = false
    else
      node.Expand = true
    end
    form.tree_ex_sifter:EndUpdate()
  end
end
function on_tree_ex_sifter_left_click(tree, node)
  on_tree_ex_sifter_select_double_click(tree, node)
end
function get_sifter_str(form, item_type)
  if not form.groupbox_sifter.Visible then
    return ""
  end
  local sift_prop_nums = 0
  local sift_prop_str = ""
  local sift_rec_nums = 0
  local sift_rec_str = ""
  local tab_node = form.tree_ex_sifter:GetAllNodeList()
  for i = 1, table.getn(tab_node) do
    if nx_is_valid(tab_node[i]) and tab_node[i].select_type == 2 and tab_node[i].select then
      if nx_number(tab_node[i].sifter_type) == 0 then
        sift_prop_nums = sift_prop_nums + 1
        sift_prop_str = sift_prop_str .. nx_string(tab_node[i].sifter)
      elseif nx_number(tab_node[i].sifter_type) == 1 then
        sift_rec_nums = sift_rec_nums + 1
        sift_rec_str = sift_rec_str .. nx_string(tab_node[i].sifter)
      end
    end
  end
  local sifter_str = ""
  if 0 < sift_prop_nums or 0 < sift_rec_nums then
    sifter_str = nx_string(sift_prop_nums) .. "," .. sift_prop_str .. nx_string(sift_rec_nums) .. "," .. sift_rec_str
  end
  return sifter_str
end
function on_btn_clear_sift_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local tab_node = form.tree_ex_sifter:GetAllNodeList()
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
function on_btn_jump_click(btn)
  local form = btn.ParentForm
  local text = form.ipt_search_key.Text
  form:Close()
  nx_execute("form_stage_main\\form_auction\\form_auction_main", "open_form_and_search", nx_widestr(text))
end
