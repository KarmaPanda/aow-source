require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
require("share\\itemtype_define")
require("share\\view_define")
local Fuse_OnlyUseBindType = 0
local Fuse_OnlyUseUnbindType = 1
local Fuse_UseAllType = 2
function main_form_init(form)
  form.Fixed = false
  form.job_id = ""
  form.sort_str = ""
  form.bind_type = Fuse_OnlyUsebindType
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 4
  form.ipt_in.Text = get_ipt_in_default()
  form.rbtn_feibangding.Checked = true
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_MATERIAL_TOOL, form, "form_stage_main\\form_home\\form_home_fuse", "on_toolbox_viewport_change")
    databinder:AddViewBind(VIEWPORT_TOOL, form, "form_stage_main\\form_home\\form_home_fuse", "on_toolbox_viewport_change")
  end
  refresh_formula_list(form)
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form)
  end
  nx_destroy(form)
end
function open_form(job_id)
  local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form.job_id = job_id
  form.Visible = true
  form:Show()
end
function close_form()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_toolbox_viewport_change(form, optype)
  if optype == "updateitem" or optype == "additem" or optype == "delitem" then
    refresh_node_info(form)
  end
end
function on_btn_fuse_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local select_node = form.tree_fuse.SelectNode
  if not nx_is_valid(select_node) then
    return
  end
  if not nx_find_custom(select_node, "formula_id") or nx_string(select_node.formula_id) == nx_string("") then
    return
  end
  local fuse_num = get_fuse_num(form)
  local actual_num = form.ipt_num.Text
  if nx_int(actual_num) > nx_int(fuse_num) then
    form.ipt_num.Text = nx_widestr(fuse_num)
    actual_num = fuse_num
  end
  nx_execute("custom_sender", "custom_send_fuse", nx_string(select_node.formula_id), nx_int(actual_num), 0, nx_int(form.bind_type))
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_cancel_fuse")
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function refresh_formula_list(form)
  if not nx_find_custom(form, "job_id") or nx_string(form.job_id) == nx_string("") then
    return
  end
  local fuse_formula_query = nx_value("FuseFormulaQuery")
  if not nx_is_valid(fuse_formula_query) then
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
  local fuse_formula_ini = nx_execute("util_functions", "get_ini", "share\\Item\\fuse_formula.ini")
  if not nx_is_valid(fuse_formula_ini) then
    return
  end
  local formula_list = fuse_formula_query:GetFormulas(form.job_id)
  local root = form.tree_fuse:CreateRootNode(nx_widestr("home_fuse_main"))
  form.tree_fuse.IsNoDrawRoot = true
  form.tree_fuse.LevelWidth = 25
  local formula_root = root:CreateNode(util_text("home_toolbox"))
  formula_root.ExpandCloseOffsetX = 3
  formula_root.ExpandCloseOffsetY = 2
  formula_root.TextOffsetX = 25
  formula_root.TextOffsetY = 5
  formula_root.ItemHeight = 22
  formula_root.NodeFocusImage = "gui\\common\\treeview\\tree_1_out.png"
  formula_root.NodeCoverImage = "gui\\common\\treeview\\tree_1_out.png"
  formula_root.NodeSelectImage = "gui\\common\\treeview\\tree_1_on.png"
  formula_root.Font = "font_tree_view"
  for _, formula in ipairs(formula_list) do
    local index = fuse_formula_ini:FindSectionIndex(nx_string(formula))
    if 0 <= index then
      local composite_name = fuse_formula_ini:ReadString(index, "ComposeResult", "")
      local node_name = util_text(composite_name)
      if nx_string(form.sort_str) == nx_string("") or string.find(nx_string(node_name), nx_string(form.sort_str)) ~= nil then
        local child_node = formula_root:CreateNode(nx_widestr(node_name))
        child_node.ItemHeight = 22
        child_node.TextOffsetX = 35
        child_node.TextOffsetY = 5
        child_node.Font = "font_tree_view"
        child_node.NodeFocusImage = "gui\\common\\treeview\\tree_2_out.png"
        child_node.NodeCoverImage = "gui\\common\\treeview\\tree_2_out.png"
        child_node.NodeSelectImage = "gui\\common\\treeview\\tree_2_on.png"
        child_node.formula_id = formula
        if not nx_is_valid(form.tree_fuse.SelectNode) then
          form.tree_fuse.SelectNode = child_node
        end
      end
    end
  end
  root:ExpandAll()
end
function on_tree_fuse_select_changed(tree, node, old_node)
  local form = tree.ParentForm
  if not nx_is_valid(form) then
    return
  end
  refresh_node_info(form)
end
function refresh_node_info(form)
  if not nx_is_valid(form) then
    return
  end
  local select_node = form.tree_fuse.SelectNode
  if not nx_is_valid(select_node) then
    return
  end
  if not nx_find_custom(select_node, "formula_id") then
    return
  end
  local formula_id = select_node.formula_id
  local fuse_formula_ini = nx_execute("util_functions", "get_ini", "share\\Item\\fuse_formula.ini")
  if not nx_is_valid(fuse_formula_ini) then
    return
  end
  local index = fuse_formula_ini:FindSectionIndex(nx_string(formula_id))
  if index < 0 then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  clear_data(form)
  local composite_name = fuse_formula_ini:ReadString(index, "ComposeResult", "")
  local material_str = fuse_formula_ini:ReadString(index, "Material", "")
  local money_sy = fuse_formula_ini:ReadString(index, "Money", "")
  local money_zy = fuse_formula_ini:ReadString(index, "Money2", "")
  if nx_string(money_sy) ~= nx_string("") then
    local sy_photo = "<img src=\"gui\\common\\money\\suiyin.png\" valign=\"top\" only=\"line\" data=\"\" />"
    form.lbl_price1.HtmlText = nx_widestr(sy_photo) .. nx_widestr(price_to_text(money_sy))
  end
  if nx_string(money_zy) ~= nx_string("") then
    local zy_photo = "<img src=\"gui\\common\\money\\yyb.png\" valign=\"center\" only=\"line\" data=\"\" />"
    form.lbl_price2.HtmlText = nx_widestr(zy_photo) .. nx_widestr(price_to_text(money_zy))
  end
  local composite_photo = ItemQuery:GetItemPropByConfigID(composite_name, "Photo")
  form.imagegrid_fuseitem:AddItem(nx_int(0), composite_photo, nx_widestr(composite_name), 1, -1)
  local index = 0
  local material_list = util_split_string(material_str, ";")
  for i = 1, table.getn(material_list) do
    local temp = util_split_string(material_list[i], ",")
    local item_id = nx_string(temp[1])
    local need_num = nx_int(temp[2])
    local have_num = get_item_num(form, item_id)
    local bexist = ItemQuery:FindItemByConfigID(item_id)
    if bexist then
      local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
      local res = form.imagegrid_1:AddItem(nx_int(index), nx_string(photo), nx_widestr(item_id), 1, -1)
      form.imagegrid_1:SetItemAddInfo(nx_int(index), 0, nx_widestr(nx_string(have_num) .. "/" .. nx_string(need_num)))
      index = index + 1
    end
  end
  local fuse_num = get_fuse_num(form)
  if nx_int(fuse_num) > nx_int(0) then
    form.btn_fuse.Visible = true
  end
end
function clear_data(form)
  form.imagegrid_1:Clear()
  form.imagegrid_fuseitem:Clear()
  form.btn_cancel.Visible = false
  form.btn_fuse.Visible = false
  form.lbl_price1.HtmlText = nx_widestr("")
  form.lbl_price2.HtmlText = nx_widestr("")
  form.ipt_num.Text = nx_widestr("1")
end
function on_imagegrid_1_mousein_grid(grid, index)
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == nx_string("") then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", nx_string(item_config), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_imagegrid_1_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_fuse_mousein_grid(grid, index)
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == nx_string("") then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", nx_string(item_config), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_imagegrid_fuse_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_rbtn_bangding_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form.groupbox_select.Visible = true
  if form.cbtn_bdgx.Checked then
    form.bind_type = Fuse_UseAllType
  else
    form.bind_type = Fuse_OnlyUseBindType
  end
  refresh_node_info(form)
end
function on_rbtn_feibangding_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form.groupbox_select.Visible = false
  form.bind_type = Fuse_OnlyUseUnbindType
  refresh_node_info(form)
end
function on_cbtn_bdgx_click(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if cbtn.Checked then
    form.bind_type = Fuse_UseAllType
  else
    form.bind_type = Fuse_OnlyUseBindType
  end
  refresh_node_info(form)
end
function on_ipt_in_get_focus(edit)
  if edit.Text == get_ipt_in_default() then
    edit.Text = nx_widestr("")
  end
end
function on_ipt_in_lost_focus(edit)
  if edit.Text == nx_widestr("") then
    edit.Text = get_ipt_in_default()
  end
end
function on_ipt_in_changed(edit)
  local form = edit.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if edit.Text == get_ipt_in_default() then
    form.sort_str = ""
  else
    form.sort_str = nx_string(edit.Text)
  end
  refresh_formula_list(form)
end
function on_ipt_num_changed(edit)
  local form = edit.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local value = nx_int(edit.Text)
  if value > nx_int(edit.MaxDigit) then
    edit.Text = nx_widestr(edit.MaxDigit)
  elseif value < nx_int(0) then
    edit.Text = nx_widestr("0")
  end
end
function get_ipt_in_default()
  return util_text("ui_sh_ss")
end
function price_to_text(price)
  local ding = math.floor(nx_number(price) / 1000000)
  local liang = math.floor(nx_number(price) % 1000000 / 1000)
  local wen = math.floor(nx_number(price) % 1000)
  local htmlTextYinZi = nx_widestr("")
  if 0 < ding then
    local text = util_text("ui_ding")
    local htmlText = nx_widestr(text)
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(nx_int(ding)) .. nx_widestr(htmlText)
  end
  if 0 < liang then
    local text = util_text("ui_liang")
    local htmlText = nx_widestr(text)
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(liang)) .. nx_widestr(htmlText)
  end
  if 0 < wen then
    local text = util_text("ui_wen")
    local htmlText = nx_widestr(text)
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(wen)) .. nx_widestr(htmlText)
  end
  if price == 0 then
    htmlTextYinZi = htmlTextYinZi .. nx_widestr("0")
  end
  return nx_widestr(htmlTextYinZi)
end
function get_fuse_num(form)
  if not nx_is_valid(form) then
    return
  end
  local select_node = form.tree_fuse.SelectNode
  if not nx_is_valid(select_node) then
    return
  end
  if not nx_find_custom(select_node, "formula_id") then
    return
  end
  local formula_id = select_node.formula_id
  local fuse_formula_ini = nx_execute("util_functions", "get_ini", "share\\Item\\fuse_formula.ini")
  if not nx_is_valid(fuse_formula_ini) then
    return
  end
  local index = fuse_formula_ini:FindSectionIndex(nx_string(formula_id))
  if index < 0 then
    return
  end
  local fuse_num = 0
  local material_str = fuse_formula_ini:ReadString(index, "Material", "")
  local material_list = util_split_string(material_str, ";")
  for i = 1, table.getn(material_list) do
    local temp = util_split_string(material_list[i], ",")
    local item_id = nx_string(temp[1])
    local need_num = nx_int(temp[2])
    if need_num <= nx_int(0) then
      need_num = 1
    end
    local have_num = get_item_num(form, item_id)
    if nx_int(have_num) == nx_int(0) or nx_int(have_num) < nx_int(need_num) then
      return 0
    end
    local count = math.floor(nx_int(have_num) / nx_int(need_num))
    if nx_int(fuse_num) == nx_int(0) or nx_int(count) < nx_int(fuse_num) then
      fuse_num = nx_int(count)
    end
  end
  return fuse_num
end
function get_item_num(form, item_id)
  if not nx_find_custom(form, "bind_type") then
    return 0
  end
  local bind_type = nx_int(form.bind_type)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local toolbox = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(toolbox) then
    return 0
  end
  local materialbox = game_client:GetView(nx_string(VIEWPORT_MATERIAL_TOOL))
  if not nx_is_valid(materialbox) then
    return 0
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return 0
  end
  local have_num = 0
  local toolbox_objlist = toolbox:GetViewObjList()
  for j, obj in pairs(toolbox_objlist) do
    local config_id = obj:QueryProp("ConfigID")
    local bind_status = nx_int(obj:QueryProp("BindStatus"))
    if nx_ws_equal(nx_widestr(config_id), nx_widestr(item_id)) and (nx_int(bind_type) == nx_int(Fuse_OnlyUseBindType) and nx_int(bind_status) == nx_int(1) or nx_int(bind_type) == nx_int(Fuse_OnlyUseUnbindType) and nx_int(bind_status) == nx_int(0) or nx_int(bind_type) == nx_int(Fuse_UseAllType)) then
      have_num = nx_int(have_num) + nx_int(obj:QueryProp("Amount"))
    end
  end
  if nx_int(have_num) == nx_int(0) then
    local material_objlist = materialbox:GetViewObjList()
    for j, obj in pairs(material_objlist) do
      local config_id = obj:QueryProp("ConfigID")
      local bind_status = nx_int(obj:QueryProp("BindStatus"))
      if nx_ws_equal(nx_widestr(config_id), nx_widestr(item_id)) and (nx_int(bind_type) == nx_int(Fuse_OnlyUseBindType) and nx_int(bind_status) == nx_int(1) or nx_int(bind_type) == nx_int(Fuse_OnlyUseUnbindType) and nx_int(bind_status) == nx_int(0) or nx_int(bind_type) == nx_int(Fuse_UseAllType)) then
        have_num = nx_int(have_num) + nx_int(obj:QueryProp("Amount"))
      end
    end
  end
  return have_num
end
function process_break_btn_show(form, show)
  if nx_int(show) == nx_int(1) then
    form.btn_fuse.Visible = false
    form.btn_cancel.Visible = true
  else
    form.btn_fuse.Visible = true
    form.btn_cancel.Visible = false
  end
end
