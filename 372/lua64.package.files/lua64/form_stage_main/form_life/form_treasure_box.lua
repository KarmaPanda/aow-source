require("share\\view_define")
require("define\\gamehand_type")
require("share\\client_custom_define")
require("util_gui")
require("goods_grid")
MSG_CS_TREASUREBOX_OPEN = 0
MSG_CS_TREASUREBOX_CLOSE = 1
MSG_CS_TREASUREBOX_BEGIN = 2
MSG_CS_TREASUREBOX_CANCEL = 3
MSG_SC_TREASUREBOX_SHOW_FORM = 0
MSG_SC_TREASUREBOX_CANCEL_BTN = 1
TREASURE_SPLIT = 0
TREASURE_FUSE = 1
TREASURE_SPLIT_ALL = 2
TREASURE_FUSE_ALL = 3
local SelectNode = ""
local TotalCellCount = 16
function open_form()
  nx_execute("custom_sender", "custom_treasurebox_msg", MSG_CS_TREASUREBOX_OPEN)
end
function main_form_init(self)
  self.Fixed = false
end
function on_form_open(self)
  set_grid(self.goods_grid)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_TREASUREBOX, self.goods_grid, nx_current(), "on_view_operat")
    databinder:AddViewBind(VIEWPORT_MATERIAL_TOOL, self, nx_current(), "on_toolbox_viewport_change")
    databinder:AddViewBind(VIEWPORT_TOOL, self, nx_current(), "on_toolbox_viewport_change")
  end
  self.btn_split.Enabled = true
  self.btn_fuse.Enabled = true
  self.btn_fuse_all.Enabled = true
  self.btn_cancel.Enabled = false
  view_grid_fresh_all(self.goods_grid)
  refresh_tree_list_fuse(self)
  refresh_item_info(self)
end
function on_form_close(self)
  nx_execute("custom_sender", "custom_treasurebox_msg", MSG_CS_TREASUREBOX_CLOSE)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(self.goods_grid)
    databinder:DelViewBind(self)
  end
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form.Visible = false
  form:Close()
end
function on_btn_split_click(btn)
  nx_execute("custom_sender", "custom_treasurebox_msg", MSG_CS_TREASUREBOX_BEGIN, TREASURE_SPLIT_ALL)
end
function on_btn_fuse_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "CurID") then
    local formula_id = form.CurID
    nx_execute("custom_sender", "custom_treasurebox_msg", MSG_CS_TREASUREBOX_BEGIN, TREASURE_FUSE, nx_string(formula_id))
  end
end
function on_btn_fuse_all_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "CurID") then
    local formula_id = form.CurID
    nx_execute("custom_sender", "custom_treasurebox_msg", MSG_CS_TREASUREBOX_BEGIN, TREASURE_FUSE_ALL, nx_string(formula_id))
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.btn_split.Enabled = true
  form.btn_fuse.Enabled = true
  form.btn_fuse_all.Enabled = true
  form.btn_cancel.Enabled = false
  nx_execute("custom_sender", "custom_treasurebox_msg", MSG_CS_TREASUREBOX_CANCEL)
end
function on_goods_grid_select_changed(grid, index)
  local goodsgrid = nx_value("GoodsGrid")
  if not nx_is_valid(goodsgrid) then
    return
  end
  goodsgrid:ViewGridOnSelectItem(grid, -1)
end
function on_goods_grid_rightclick_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) and form_bag.Visible then
    local view_index = grid:GetBindIndex(index)
    local view_obj = get_view_item(grid.typeid, view_index)
    if nx_is_valid(view_obj) then
      local view_id = ""
      local goods_grid = nx_value("GoodsGrid")
      if nx_is_valid(goods_grid) then
        view_id = goods_grid:GetToolBoxViewport(view_obj)
        goods_grid:ViewGridPutToAnotherView(grid, view_id)
      end
    end
  end
end
function on_view_operat(grid, optype, view_ident, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return 0
  end
  if optype == "createview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "updateview" then
    GoodsGrid:ViewUpdateItem(grid, index)
  elseif optype == "additem" then
    GoodsGrid:ViewUpdateItem(grid, index)
  elseif optype == "delitem" then
    GoodsGrid:ViewDeleteItem(grid, index)
  elseif optype == "updateitem" then
    GoodsGrid:ViewUpdateItem(grid, index)
  end
  return 1
end
function on_tree_fuse_select_changed(tree)
  local form = tree.ParentForm
  SelectNode = tree.SelectNode
  local node = tree.SelectNode
  if nx_find_custom(node, "id") then
    tree.ParentForm.CurID = tree.SelectNode.id
    if get_canfuse_num(node.id) == nx_int(0) then
      form.btn_fuse.Enabled = false
      form.btn_fuse_all.Enabled = false
    else
      form.btn_fuse.Enabled = true
      form.btn_fuse_all.Enabled = true
    end
  else
    form.btn_fuse.Enabled = false
    form.btn_fuse_all.Enabled = false
  end
  refresh_fuse_info(form)
end
function on_goods_grid_mousein_grid(grid, index)
  local GoodsGrid = nx_value("GoodsGrid")
  local item_data
  if nx_is_valid(GoodsGrid) then
    item_data = GoodsGrid:GetItemData(grid, index)
  end
  if nx_is_valid(item_data) then
    nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
  end
end
function on_goods_grid_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_toolbox_viewport_change(form, optype)
  if optype == "updateitem" or optype == "additem" or optype == "delitem" then
    refresh_tree_list_fuse(form)
    refresh_item_info(form)
  end
end
function on_server_msg(...)
  local form = util_get_form(nx_current(), true)
  if not nx_is_valid(form) then
    return
  end
  local type = arg[1]
  if type == MSG_SC_TREASUREBOX_SHOW_FORM then
    util_show_form(nx_current(), true)
    nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
  elseif type == MSG_SC_TREASUREBOX_CANCEL_BTN then
    if nx_number(arg[2]) == nx_number(1) then
      form.btn_split.Enabled = false
      form.btn_fuse.Enabled = false
      form.btn_fuse_all.Enabled = false
      form.btn_cancel.Enabled = true
    elseif nx_number(arg[2]) == nx_number(0) then
      form.btn_split.Enabled = true
      form.btn_fuse.Enabled = true
      form.btn_fuse_all.Enabled = true
      form.btn_cancel.Enabled = false
    end
  end
end
function set_grid(grid)
  grid.typeid = VIEWPORT_TREASUREBOX
  grid.beginindex = 1
  grid.endindex = nx_int(TotalCellCount)
  local grid_index = 0
  for view_index = grid.beginindex, grid.endindex do
    grid:SetBindIndex(grid_index, view_index)
    grid_index = grid_index + 1
  end
  grid.canselect = true
  grid.candestroy = true
  grid.cansplit = true
  grid.canlock = true
  grid.canarrange = true
end
function refresh_tree_list_fuse(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.tree_fuse.SelectNode = SelectNode
  local fuse_name = gui.TextManager:GetFormatText("ui_bwrh1")
  local fuse_root_node = form.tree_fuse:CreateRootNode(nx_widestr(fuse_name))
  local fuse_root = fuse_root_node:CreateNode(nx_widestr(fuse_name))
  fuse_root.ExpandCloseOffsetX = 3
  fuse_root.ExpandCloseOffsetY = 2
  fuse_root.TextOffsetX = 25
  fuse_root.TextOffsetY = 5
  fuse_root.ItemHeight = 22
  fuse_root.NodeFocusImage = "gui\\common\\treeview\\tree_1_out.png"
  fuse_root.NodeCoverImage = "gui\\common\\treeview\\tree_1_out.png"
  fuse_root.NodeSelectImage = "gui\\common\\treeview\\tree_1_on.png"
  fuse_root.Font = "font_tip"
  local formula_list = get_formula("treasure")
  if formula_list == nil then
    return
  end
  config_sub_node(form, gui, fuse_root, formula_list, "share\\Item\\fuse_formula.ini")
  fuse_name = gui.TextManager:GetFormatText("ui_treasure_hht")
  fuse_root = fuse_root_node:CreateNode(nx_widestr(fuse_name))
  fuse_root.ExpandCloseOffsetX = 3
  fuse_root.ExpandCloseOffsetY = 2
  fuse_root.TextOffsetX = 25
  fuse_root.TextOffsetY = 5
  fuse_root.ItemHeight = 22
  fuse_root.NodeFocusImage = "gui\\common\\treeview\\tree_1_out.png"
  fuse_root.NodeCoverImage = "gui\\common\\treeview\\tree_1_out.png"
  fuse_root.NodeSelectImage = "gui\\common\\treeview\\tree_1_on.png"
  fuse_root.Font = "font_tip"
  local formula_list = get_formula("treasure_hht")
  if formula_list == nil then
    return
  end
  config_sub_node(form, gui, fuse_root, formula_list, "share\\Item\\fuse_formula.ini")
  fuse_root_node:ExpandAll()
end
function refresh_fuse_info(form)
  local node = form.tree_fuse.SelectNode
  if not nx_find_custom(node, "Material") then
    return
  end
  if not nx_find_custom(node, "formula_id") then
    return
  end
  if not nx_find_custom(node, "price") then
    return
  end
  if not nx_find_custom(node, "price_zy") then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.lbl_price1.HtmlText = nx_widestr("")
  form.lbl_price2.HtmlText = nx_widestr("")
  local sy = "<img src=\"gui\\common\\money\\suiyin.png\" valign=\"top\" only=\"line\" data=\"\" />"
  form.lbl_price1.HtmlText = nx_widestr(sy) .. nx_widestr(price_to_text(form, gui, node.price))
  local zy = "<img src=\"gui\\common\\money\\yyb.png\" valign=\"center\" only=\"line\" data=\"\" />"
  form.lbl_price2.HtmlText = nx_widestr(zy) .. nx_widestr(price_to_text(form, gui, node.price_zy))
  local need_string = nx_widestr("")
  local tbl_materials = util_split_string(node.Material, ";")
  for i = 1, table.getn(tbl_materials) do
    local str_material = tbl_materials[i]
    local tbl_material = util_split_string(str_material, ",")
    local material_id = tbl_material[1]
    local material_count = tbl_material[2]
    local material_name = nx_widestr(util_text(nx_string(material_id)))
    need_string = need_string .. material_name .. nx_widestr("(") .. nx_widestr(material_count) .. nx_widestr(")")
  end
  form.lbl_need.Text = need_string
end
function refresh_item_info(form)
  local goodsgrid = nx_value("GoodsGrid")
  if not nx_is_valid(goodsgrid) then
    return
  end
  local count = goodsgrid:GetItemCount("fenjie_treasure_10001")
  form.lbl_currtick_count.Text = nx_widestr(count)
  count = goodsgrid:GetItemCount("gn_Procon_001")
  form.lbl_13.Text = nx_widestr(count)
  count = goodsgrid:GetItemCount("hecheng_treasure_10003")
  form.lbl_14.Text = nx_widestr(count)
end
function get_formula(job_id)
  local fuse_formula_query = nx_value("FuseFormulaQuery")
  if not nx_is_valid(fuse_formula_query) then
    return nil
  end
  local formula_list = {}
  local formula_len = 0
  formula = fuse_formula_query:GetFormulas(job_id)
  local formula_num = table.getn(formula)
  for i, item in ipairs(formula) do
    table.insert(formula_list, item)
  end
  return formula_list
end
function config_sub_node(form, gui, fuse_root, formula_list, ini_path)
  local fuse_ini = nx_execute("util_functions", "get_ini", ini_path)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  for _, formula in ipairs(formula_list) do
    local index = fuse_ini:FindSectionIndex(nx_string(formula))
    if 0 <= index then
      local fuse_name = fuse_ini:ReadString(index, "ComposeResult", "")
      local Material_str = fuse_ini:ReadString(index, "Material", "")
      local fuse_type = fuse_ini:ReadString(index, "Profession", "")
      local money = fuse_ini:ReadString(index, "Money", "")
      local money_zy = fuse_ini:ReadString(index, "Money2", "")
      local PowerLevel = fuse_ini:ReadString(index, "PowerLevel", "")
      if fuse_name ~= "" and Material_str ~= "" and nx_number(PowerLevel) <= nx_number(client_player:QueryProp("PowerLevel")) then
        local node_name = gui.TextManager:GetFormatText(fuse_name)
        local node_id = fuse_ini:GetSectionByIndex(index)
        local canfuse_num = nx_string(get_canfuse_num(node_id))
        if nx_int(canfuse_num) == nx_int(0) then
          canfuse_num = ""
        else
          canfuse_num = "(" .. canfuse_num .. ")"
        end
        local sub_node = fuse_root:CreateNode(nx_widestr(node_name) .. nx_widestr(canfuse_num))
        sub_node.ItemHeight = 22
        sub_node.TextOffsetX = 35
        sub_node.TextOffsetY = 5
        sub_node.Material = Material_str
        sub_node.formula_id = fuse_name
        sub_node.id = node_id
        sub_node.price = money
        sub_node.price_zy = money_zy
        sub_node.Font = "font_tip"
        sub_node.NodeFocusImage = "gui\\common\\treeview\\tree_2_out.png"
        sub_node.NodeCoverImage = "gui\\common\\treeview\\tree_2_out.png"
        sub_node.NodeSelectImage = "gui\\common\\treeview\\tree_2_on.png"
        if nx_is_valid(sub_node) and not nx_is_valid(form.tree_fuse.SelectNode) then
          form.tree_fuse.SelectNode = sub_node
        end
      end
    end
  end
end
function price_to_text(form, gui, price)
  local ding = math.floor(nx_number(price) / 1000000)
  local liang = math.floor(nx_number(price) % 1000000 / 1000)
  local wen = math.floor(nx_number(price) % 1000)
  local htmlTextYinZi = nx_widestr("")
  if 0 < ding then
    local text = gui.TextManager:GetText("ui_ding")
    local htmlText = nx_widestr(text)
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(nx_int(ding)) .. nx_widestr(htmlText)
  end
  if 0 < liang then
    local text = gui.TextManager:GetText("ui_liang")
    local htmlText = nx_widestr(text)
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(liang)) .. nx_widestr(htmlText)
  end
  if 0 < wen then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr(text)
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(wen)) .. nx_widestr(htmlText)
  end
  if price == 0 then
    htmlTextYinZi = htmlTextYinZi .. nx_widestr("0")
  end
  return nx_widestr(htmlTextYinZi)
end
function get_canfuse_num(node_id)
  local game_client = nx_value("game_client")
  local iniformula = nx_execute("util_functions", "get_ini", "share\\Item\\fuse_formula.ini")
  local sec_index = iniformula:FindSectionIndex(nx_string(node_id))
  if sec_index < 0 then
    return 0
  end
  local needitem = iniformula:ReadString(sec_index, "Material", "")
  if needitem == "" then
    return 0
  end
  local str_lst = util_split_string(needitem, ";")
  local flag = false
  local min_num = 999
  if 0 < table.getn(str_lst) then
    for i = 1, table.getn(str_lst) do
      local str_temp = util_split_string(str_lst[i], ",")
      local item = str_temp[1]
      local num = nx_int(str_temp[2])
      if num <= nx_int(0) then
        num = 1
      end
      local view = game_client:GetView(nx_string(VIEWPORT_MATERIAL_TOOL))
      local tool = game_client:GetView(nx_string(VIEWPORT_TOOL))
      if nx_is_valid(view) then
        local viewobj_list = view:GetViewObjList()
        local toolobj_list = tool:GetViewObjList()
        local total = 0
        local Material_total = 0
        local Tool_total = 0
        for i, obj in pairs(viewobj_list) do
          local tempid = obj:QueryProp("ConfigID")
          if tempid == item then
            flag = true
            local cur_amount = obj:QueryProp("Amount")
            Material_total = Material_total + cur_amount
          end
        end
        for i, obj in pairs(toolobj_list) do
          local tempid = obj:QueryProp("ConfigID")
          if tempid == item then
            flag = true
            local cur_amount = obj:QueryProp("Amount")
            Tool_total = Tool_total + cur_amount
          end
        end
        local Material_total = nx_int(Material_total / nx_int(num))
        local Tool_total = nx_int(Tool_total / nx_int(num))
        local temp_min_num = 0
        if Material_total > Tool_total then
          temp_min_num = Material_total
        else
          temp_min_num = Tool_total
        end
        if nx_int(temp_min_num) < nx_int(min_num) then
          min_num = temp_min_num
        end
      end
    end
  else
    flag = true
    min_num = 1
  end
  if flag == false then
    min_num = 0
  end
  return min_num
end
