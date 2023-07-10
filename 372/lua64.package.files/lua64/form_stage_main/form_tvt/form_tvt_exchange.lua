require("util_gui")
require("util_static_data")
require("util_functions")
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
local CLIENT_SUBMSG_REQUEST_CONDS = 0
local CLIENT_SUBMSG_BUY_ITEM = 1
local PT_EXPERT = 1
local PT_RELAXATION = 2
local PT_ORDERBRAND = 3
local ITEM_BRAND_ID = "item_99wuxue_ww001"
local POINT_IMAGE = {
  [PT_EXPERT] = "gui\\language\\ChineseS\\tvt\\icon_zj.png",
  [PT_RELAXATION] = "gui\\language\\ChineseS\\tvt\\icon_xx.png",
  [PT_ORDERBRAND] = "gui\\language\\ChineseS\\tvt\\icon_99ww.png"
}
local eWeekExpertPointMax = 0
local eWeekRelaxationPointMax = 1
local eTotalExpertPointMax = 2
local eTotalRelaxationPointMax = 3
local PAGE_COUNT = 18
local NODE_PROP = {
  first = {
    ForeColor = "255,197,184,159",
    NodeBackImage = "gui\\language\\ChineseS\\newtvt\\dianshu\\biaow.png",
    NodeFocusImage = "gui\\language\\ChineseS\\newtvt\\dianshu\\biaox.png",
    NodeSelectImage = "gui\\language\\ChineseS\\newtvt\\dianshu\\biaox.png",
    ItemHeight = 30,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 1,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 25,
    TextOffsetY = 6,
    Font = "font_treeview"
  },
  second = {
    ForeColor = "255,197,184,159",
    NodeBackImage = "gui\\common\\treeview\\tree_2_out.png",
    NodeFocusImage = "gui\\common\\treeview\\tree_2_on.png",
    NodeSelectImage = "gui\\common\\treeview\\tree_2_on.png",
    ItemHeight = 24,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 0,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 5,
    TextOffsetY = 3,
    Font = "font_treeview"
  }
}
function set_copy_ent_info(form, source, target_ent)
  local source_ent = nx_custom(form, source)
  if not nx_is_valid(source_ent) then
    return
  end
  local prop_list = nx_property_list(source_ent)
  for i, prop in ipairs(prop_list) do
    if "Name" ~= prop then
      nx_set_property(target_ent, prop, nx_property(source_ent, prop))
    end
  end
end
function set_node_prop(node, node_type)
  if not nx_is_valid(node) or node_type == nil then
    return 0
  end
  for key, value in pairs(NODE_PROP[node_type]) do
    nx_set_property(node, nx_string(key), value)
  end
end
function main_form_init(self)
  self.ITEM_IDS = ""
  self.PAGE = 0
  self.Fixed = false
end
function on_main_form_open(self)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:AddRolePropertyBind("ExpertPoint", "int", self, nx_current(), "on_point_change")
    data_binder:AddRolePropertyBind("RelaxationPoint", "int", self, nx_current(), "on_point_change")
    data_binder:AddRolePropertyBind("WeekEP", "int", self, nx_current(), "on_point_change")
    data_binder:AddRolePropertyBind("WeekRP", "int", self, nx_current(), "on_point_change")
  end
  updata_order_brand()
  nx_execute("custom_sender", "custommsg_activity_point", nx_int(CLIENT_SUBMSG_REQUEST_CONDS))
  local form_tvt_exchange = nx_value("form_tvt_exchange")
  if nx_is_valid(form_tvt_exchange) then
    nx_destroy(form_tvt_exchange)
  end
  form_tvt_exchange = nx_create("form_tvt_exchange")
  if nx_is_valid(form_tvt_exchange) then
    nx_set_value("form_tvt_exchange", form_tvt_exchange)
  end
  init_groupbox_2(self)
end
function on_main_form_close(self)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:DelRolePropertyBind("ExpertPoint", self)
    data_binder:DelRolePropertyBind("RelaxationPoint", self)
    data_binder:DelRolePropertyBind("WeekEP", self)
    data_binder:DelRolePropertyBind("WeekRP", self)
  end
  local form_tvt_exchange = nx_value("form_tvt_exchange")
  if nx_is_valid(form_tvt_exchange) then
    nx_destroy(form_tvt_exchange)
  end
  nx_destroy(self)
end
function on_close_click(btn)
  btn.Parent:Close()
end
function updata_order_brand(number)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form.lbl_brand_num.Text = nx_widestr(number)
end
function init_groupbox_2(form)
  if not nx_is_valid(form) then
    return
  end
  local form_tvt_exchange = nx_value("form_tvt_exchange")
  if not nx_is_valid(form_tvt_exchange) then
    return
  end
  local TotalExpertPointMax = form_tvt_exchange:GetLimitCount(eTotalExpertPointMax)
  local TotalRelaxationPointMax = form_tvt_exchange:GetLimitCount(eTotalRelaxationPointMax)
  local TotalWeekExpertPointMax = form_tvt_exchange:GetLimitCount(eWeekExpertPointMax)
  local TotalWeekRelaxationPointMax = form_tvt_exchange:GetLimitCount(eWeekRelaxationPointMax)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local value = client_player:QueryProp("ExpertPoint")
  value = math.floor(value / 1000)
  TotalExpertPointMax = math.floor(TotalExpertPointMax / 1000)
  form.lbl_exp.Text = nx_widestr(value .. "/" .. TotalExpertPointMax)
  value = client_player:QueryProp("RelaxationPoint")
  value = math.floor(value / 1000)
  TotalRelaxationPointMax = math.floor(TotalRelaxationPointMax / 1000)
  form.lbl_relaxa.Text = nx_widestr(value .. "/" .. TotalRelaxationPointMax)
  value = client_player:QueryProp("WeekEP")
  value = math.floor(value / 1000)
  TotalWeekExpertPointMax = math.floor(TotalWeekExpertPointMax / 1000)
  form.pbar_expert.Maximum = TotalWeekExpertPointMax
  form.pbar_expert.Value = value
  value = client_player:QueryProp("WeekRP")
  value = math.floor(value / 1000)
  TotalWeekRelaxationPointMax = math.floor(TotalWeekRelaxationPointMax / 1000)
  form.pbar_relaxation.Maximum = TotalWeekRelaxationPointMax
  form.pbar_relaxation.Value = value
end
function on_point_change(form, prop_name, prop_type, value)
  local form_tvt_exchange = nx_value("form_tvt_exchange")
  if not nx_is_valid(form_tvt_exchange) then
    return
  end
  local TotalExpertPointMax = form_tvt_exchange:GetLimitCount(eTotalExpertPointMax)
  local TotalRelaxationPointMax = form_tvt_exchange:GetLimitCount(eTotalRelaxationPointMax)
  local TotalWeekExpertPointMax = form_tvt_exchange:GetLimitCount(eWeekExpertPointMax)
  local TotalWeekRelaxationPointMax = form_tvt_exchange:GetLimitCount(eWeekRelaxationPointMax)
  value = math.floor(value / 1000)
  if nx_string(prop_name) == "ExpertPoint" then
    TotalExpertPointMax = math.floor(TotalExpertPointMax / 1000)
    form.lbl_exp.Text = nx_widestr(value .. "/" .. TotalExpertPointMax)
  elseif nx_string(prop_name) == "RelaxationPoint" then
    TotalRelaxationPointMax = math.floor(TotalRelaxationPointMax / 1000)
    form.lbl_relaxa.Text = nx_widestr(value .. "/" .. TotalRelaxationPointMax)
  elseif nx_string(prop_name) == "WeekEP" then
    TotalWeekExpertPointMax = math.floor(TotalWeekExpertPointMax / 1000)
    form.pbar_expert.Maximum = TotalWeekExpertPointMax
    form.pbar_expert.Value = value
  elseif nx_string(prop_name) == "WeekRP" then
    TotalWeekRelaxationPointMax = math.floor(TotalWeekRelaxationPointMax / 1000)
    form.pbar_relaxation.Maximum = TotalWeekRelaxationPointMax
    form.pbar_relaxation.Value = value
  end
end
function on_srv_msg(item_ids)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form.ITEM_IDS = item_ids
  refresh_form(form)
  show_tree_view(form.tree)
end
function refresh_form(form, main_type, sub_type)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_1:DeleteAll()
  local t_items = get_items(main_type, sub_type)
  local begin = form.PAGE * PAGE_COUNT
  local size = PAGE_COUNT
  local table_count = table.getn(t_items)
  if table_count - begin < PAGE_COUNT then
    size = table_count - begin
  end
  for i = 1, size do
    local groupbox = create_groupbox(form, t_items[begin + i], i)
    if nx_is_valid(groupbox) then
      groupbox.Left = (i - 1) % 2 * (groupbox.Width + 6) + 10
      groupbox.Top = nx_int((i - 1) / 2) * (groupbox.Height + 3) + 6
      form.groupbox_1:Add(groupbox)
    end
  end
  local all_page = math.ceil(table_count / PAGE_COUNT)
  form.lbl_page.Text = nx_widestr(nx_string(form.PAGE + 1) .. "/" .. nx_string(all_page))
end
function create_groupbox(form, str, index)
  local t = util_split_string(nx_string(str), ",")
  if table.getn(t) ~= 6 then
    return
  end
  local gui = nx_value("gui")
  local groupbox = gui:Create("GroupBox")
  set_copy_ent_info(form, "groupbox_t", groupbox)
  groupbox.Name = form.groupbox_t.Name .. nx_string(index)
  local child_ctrls = form.groupbox_t:GetChildControlList()
  for i, ctrl in ipairs(child_ctrls) do
    local ctrl_obj = gui:Create(nx_name(ctrl))
    set_copy_ent_info(form, ctrl.Name, ctrl_obj)
    ctrl_obj.Name = ctrl.Name .. nx_string(index)
    groupbox:Add(ctrl_obj)
  end
  local imagegrid = groupbox:Find("imagegrid_t" .. nx_string(index))
  local ItemsQuery = nx_value("ItemQuery")
  local ConfigID = t[1]
  local photo = item_query_ArtPack_by_id(nx_string(ConfigID), "Photo")
  imagegrid:AddItem(0, photo, util_text(ConfigID), 1, -1)
  nx_bind_script(imagegrid, nx_current())
  nx_callback(imagegrid, "on_mousein_grid", "on_mousein_grid")
  nx_callback(imagegrid, "on_mouseout_grid", "on_mouseout_grid")
  local lbl_name = groupbox:Find("lbl_name_t" .. nx_string(index))
  lbl_name.Text = util_text(ConfigID)
  local lbl_type = groupbox:Find("lbl_type_t" .. nx_string(index))
  local type = nx_number(t[2])
  lbl_type.BackImage = POINT_IMAGE[type]
  local lbl_num = groupbox:Find("lbl_num_t" .. nx_string(index))
  local num = t[3]
  if type ~= PT_ORDERBRAND then
    num = math.floor(num / 1000)
  end
  lbl_num.Text = nx_widestr(num)
  local btn_buy = groupbox:Find("btn_buy_t" .. nx_string(index))
  nx_bind_script(btn_buy, nx_current())
  nx_callback(btn_buy, "on_click", "on_click")
  local bCdt = nx_number(t[6])
  if bCdt == 0 then
    btn_buy.Enabled = false
    if PT_ORDERBRAND == type then
      btn_buy.HintText = nx_widestr(util_text("tips_99ww_lp03"))
    end
  elseif bCdt == 1 then
    btn_buy.Enabled = true
    btn_buy.HintText = nx_widestr("")
  end
  groupbox.ConfigID = ConfigID
  groupbox.Type = type
  return groupbox
end
function show_tree_view(tree_view)
  local form_tvt_exchange = nx_value("form_tvt_exchange")
  if not nx_is_valid(form_tvt_exchange) then
    return
  end
  local root = tree_view.RootNode
  if not nx_is_valid(root) then
    root = tree_view:CreateRootNode(nx_widestr("Root"))
  end
  root:ClearNode()
  tree_view:BeginUpdate()
  local main_type_t = form_tvt_exchange:GetFirstTreeName()
  for _, name in pairs(main_type_t) do
    local node = root:CreateNode(util_text(name))
    node.MAINTYPE = name
    set_node_prop(node, "first")
    local sub_tyep_t = form_tvt_exchange:GetSecondTreeName(nx_string(name))
    for _, sub_name in pairs(sub_tyep_t) do
      local sub_node = node:CreateNode(util_text(sub_name))
      sub_node.MAINTYPE = name
      sub_node.SUBTYPE = sub_name
      set_node_prop(sub_node, "second")
    end
  end
  root.Expand = true
  tree_view:EndUpdate()
end
function on_tree_select_changed(self, node, old_node)
  local main_type = nx_custom(node, "MAINTYPE")
  local sub_type = nx_custom(node, "SUBTYPE")
  local form = self.ParentForm
  form.MAINTYPE = main_type
  form.SUBTYPE = sub_type
  form.PAGE = 0
  refresh_form(form, main_type, sub_type)
end
function on_mousein_grid(grid, index)
  local ConfigID = nx_custom(grid.Parent, "ConfigID")
  nx_execute("tips_game", "show_tips_by_config", ConfigID, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_click(btn)
  local groupbox = btn.Parent
  local configid = nx_custom(groupbox, "ConfigID")
  local type = nx_custom(groupbox, "Type")
  local max_amount = nx_number(get_prop(configid, "MaxAmount"))
  if max_amount <= 0 then
    max_amount = 1
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_inputbox", true, false)
  dialog:ShowModal()
  dialog.name_edit.Max = max_amount
  local res, text = nx_wait_event(100000000, dialog, "input_box_return")
  local amount = 0
  if res == "ok" then
    amount = nx_number(text)
  else
    return
  end
  nx_execute("custom_sender", "custommsg_activity_point", nx_int(CLIENT_SUBMSG_BUY_ITEM), nx_string(configid), nx_int(type), nx_int(amount))
end
function get_all_page_num(main_type, sub_type)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return 0
  end
  local t_items = get_items(main_type, sub_type)
  local table_count = table.getn(t_items)
  return math.ceil(table_count / PAGE_COUNT)
end
function on_btn_pre_click(btn)
  local form = btn.ParentForm
  local main_type = nx_custom(form, "MAINTYPE")
  local sub_type = nx_custom(form, "SUBTYPE")
  local all_page_num = get_all_page_num(main_type, sub_type)
  if 0 < all_page_num and 0 < form.PAGE then
    form.PAGE = form.PAGE - 1
    form.lbl_page.Text = nx_widestr(nx_string(form.PAGE + 1) .. "/" .. nx_string(all_page_num))
    refresh_form(form, main_type, sub_type)
  end
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  local main_type = nx_custom(form, "MAINTYPE")
  local sub_type = nx_custom(form, "SUBTYPE")
  local all_page_num = get_all_page_num(main_type, sub_type)
  if 0 < all_page_num and form.PAGE < all_page_num - 1 then
    form.PAGE = form.PAGE + 1
    form.lbl_page.Text = nx_widestr(nx_string(form.PAGE + 1) .. "/" .. nx_string(all_page_num))
    refresh_form(form, main_type, sub_type)
  end
end
function get_items(main_type, sub_type)
  local rst = {}
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return rst
  end
  local item_str = form.ITEM_IDS
  local all_items = util_split_string(nx_string(item_str), "|")
  for _, value in pairs(all_items) do
    local item = util_split_string(nx_string(value), ",")
    if 6 == table.getn(item) then
      if not main_type then
        table.insert(rst, value)
      end
      if main_type == item[4] and (not sub_type or sub_type == item[5]) then
        table.insert(rst, value)
      end
    end
  end
  return rst
end
function get_prop(id, prop)
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return nil
  end
  local value = item_query:GetItemPropByConfigID(id, prop)
  if value ~= nil and value ~= "" then
    return value
  end
  return nil
end
function close_form()
  local form = nx_value("form_stage_main\\form_tvt\\form_tvt_exchange")
  if nx_is_valid(form) then
    form:Close()
  end
end
