require("util_functions")
require("util_gui")
require("role_composite")
require("form_stage_main\\form_home\\form_home_msg")
require("share\\itemtype_define")
require("share\\view_define")
local max_item_count = 12
local model_scale_table = {
  {
    name = "home_yi_tree_01",
    scale = 0.13
  },
  {
    name = "home_yi_tree_02",
    scale = 0.13
  }
}
function tc(msg)
  nx_msgbox(nx_string(msg))
end
function Log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function open_form(open_type)
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
    return
  end
  form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form.open_type = open_type
  form.Visible = true
  form:Show()
end
function main_form_init(form)
  form.Fixed = false
  form.open_type = 1
  form.select_node = nil
  form.select_grid = nil
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form_init(form)
  if nx_number(form.open_type) == 1 then
    form.groupbox_compose.Visible = false
    form.groupbox_buy.Visible = true
    form.groupbox_bind.Visible = false
    form.lbl_title.Text = nx_widestr("@ui_home_shop")
  else
    form.groupbox_compose.Visible = true
    form.groupbox_buy.Visible = false
    form.lbl_title.Text = nx_widestr("@ui_home_forge")
    on_rbtn_nobind_click(form.rbtn_nobind)
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_MATERIAL_TOOL, form, nx_current(), "on_toolbox_viewport_change")
    databinder:AddViewBind(VIEWPORT_TOOL, form, nx_current(), "on_toolbox_viewport_change")
  end
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form)
  end
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
end
function get_list_table(section, flag)
  if nx_string(section) == "" or nx_string(flag) == "" then
    return nil
  end
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\life\\home_xml.ini", true)
  if not nx_is_valid(ini) then
    return nil
  end
  local index = ini:FindSectionIndex(nx_string(section))
  if index < 0 then
    return nil
  end
  local list = ini:ReadString(index, nx_string(flag), "")
  local lists = util_split_string(list, ",")
  if table.getn(lists) < 1 then
    return nil
  end
  return lists
end
function clear_form(form)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("util_gui", "ui_ClearModel", form.scenebox_mod)
  form.Icg_ChildType:Clear()
  form.Icg_material:Clear()
  form.Icg_product:Clear()
  form.Icg_product.configid = ""
  form.Icg_ChildType:SetSelectItemIndex(-1)
  form.Icg_product:SetSelectItemIndex(-1)
  form.btn_compose.Enabled = false
  form.btn_buy.Enabled = false
  form.btn_give.Enabled = false
  form.lbl_num_child.Text = nx_widestr("1/1")
end
function form_init(form)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_num_child.count = 0
  form.lbl_num_child.now = 1
  form.lbl_num_child.max = 1
  form.lbl_num_child.number = 0
  clear_form(form)
  local tree = get_list_table("tree", "list")
  if nil == tree then
    return
  end
  local root = form.tree_list:CreateRootNode(nx_widestr("home_main"))
  form.tree_list.IsNoDrawRoot = true
  for i = 1, table.getn(tree) do
    local type1 = root:CreateNode(util_text(tree[i]))
    type1.ExpandCloseOffsetX = 3
    type1.ExpandCloseOffsetY = 2
    type1.TextOffsetX = 50
    type1.TextOffsetY = 5
    type1.ForeColor = "255,255,204,0"
    type1.ItemHeight = 22
    type1.NodeBackImage = "gui\\special\\home\\main\\bg_select.png"
    type1.NodeFocusImage = "gui\\special\\home\\main\\bg_select_down.png"
    type1.NodeSelectImage = "gui\\special\\home\\main\\bg_select.png"
    type1.Font = form.tree_list.Font
    local child_tree = get_list_table(tree[i], "list")
    if nil ~= child_tree then
      for j = 1, table.getn(child_tree) do
        local type2 = type1:CreateNode(util_text(child_tree[j]))
        type2.searchid = nx_string(child_tree[j])
        child_tree.node_name = child_tree[j]
        type2.ExpandCloseOffsetX = 3
        type2.ExpandCloseOffsetY = 2
        type2.TextOffsetX = 50
        type2.TextOffsetY = 5
        type2.ItemHeight = 22
        type2.NodeBackImage = "gui\\special\\home\\main\\bg_select.png"
        type2.NodeFocusImage = "gui\\special\\home\\main\\bg_select_down.png"
        type2.NodeSelectImage = "gui\\special\\home\\main\\bg_select_down.png"
        type2.Font = form.tree_list.Font
        if not nx_is_valid(form.tree_list.SelectNode) then
          form.tree_list.SelectNode = type2
        end
      end
    end
  end
  root.Expand = true
end
function on_btn_left_child_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.lbl_num_child.now) > nx_int(1) then
    form.lbl_num_child.now = form.lbl_num_child.now - 1
    update_item_info(form)
  end
end
function on_btn_right_child_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.lbl_num_child.now) >= nx_int(form.lbl_num_child.max) then
    return
  end
  form.lbl_num_child.now = form.lbl_num_child.now + 1
  update_item_info(form)
end
function on_tree_list_select_changed(tree, node)
  local form = tree.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local node_name = nx_custom(node, "searchid")
  if node_name == nil or node_name == "" then
    return
  end
  local lists = get_list_table(node_name, "list")
  local item_num = table.getn(lists)
  if nx_int(item_num) <= nx_int(0) then
    return
  end
  clear_form(form)
  form.select_node = node
  form.lbl_num_child.now = 1
  local page_max = nx_int(item_num / max_item_count)
  if nx_int(page_max * max_item_count) < nx_int(item_num) then
    page_max = page_max + 1
  end
  form.lbl_num_child.max = page_max
  form.ipt_1.Text = nx_widestr("1")
  update_item_info(form)
end
function update_item_info(form, node)
  if not nx_is_valid(form) then
    return
  end
  form.Icg_ChildType:Clear()
  form.Icg_ChildType:SetSelectItemIndex(-1)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  if form.select_node == nil then
    return
  end
  local indexid = form.select_node.searchid
  if indexid == "" then
    return
  end
  local lists = get_list_table(indexid, "list")
  local item_num = table.getn(lists)
  if nx_int(item_num) <= nx_int(0) then
    return
  end
  form.lbl_num_child.Text = nx_widestr(nx_string(form.lbl_num_child.now) .. "/" .. nx_string(form.lbl_num_child.max))
  local cur_page = nx_int(form.lbl_num_child.now)
  local begin_pos = (cur_page - nx_int(1)) * max_item_count + 1
  local end_pos = cur_page * max_item_count
  local cur_pos = begin_pos
  for i = cur_pos, table.getn(lists) do
    if lists[i] == "" then
      break
    end
    if can_show(form, lists[i]) then
      local grid_index = cur_pos - begin_pos
      local item_photo = ItemQuery:GetItemPropByConfigID(lists[i], "Photo")
      form.Icg_ChildType:AddItem(nx_int(grid_index), item_photo, nx_widestr(lists[i]), 1, -1)
      if 0 > form.Icg_ChildType:GetSelectItemIndex() then
        form.Icg_ChildType:SetSelectItemIndex(grid_index)
        on_Icg_ChildType_select_changed(form.Icg_ChildType, grid_index)
      end
      if end_pos <= cur_pos then
        return
      end
      cur_pos = cur_pos + 1
    end
  end
end
function on_Icg_ChildType_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Icg_product:Clear()
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local configid = grid:GetItemName(index)
  if configid == "" then
    return
  end
  local item_photo = ItemQuery:GetItemPropByConfigID(nx_string(configid), "Photo")
  local item_name = util_text(nx_string(configid))
  form.Icg_product:AddItem(nx_int(0), item_photo, nx_widestr(item_name), 0, -1)
  local ini = nx_execute("util_functions", "get_ini", "share\\Item\\home_furniture.ini", true)
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(configid))
  if sec_index < 0 then
    return
  end
  form.Icg_product.configid = nx_string(configid)
  form.Icg_product.huali = ini:ReadInteger(sec_index, "ui_gorgeous", 0)
  form.Icg_product.type = ini:ReadInteger(sec_index, "type", 0)
  form.Icg_product.money = ini:ReadInteger(sec_index, "money", 0)
  form.Icg_product.money2 = ini:ReadInteger(sec_index, "money2", 0)
  form.Icg_product.formula = ini:ReadInteger(sec_index, "formula", 0)
  local item_mod = ini:ReadString(sec_index, "mod", "")
  local item_mod_ini = ini:ReadString(sec_index, "mod_ini", "")
  local hualidu = util_text("hualidu_ds")
  local huali = hualidu .. nx_widestr(": ") .. nx_widestr(form.Icg_product.huali)
  form.Icg_product:SetItemAddInfo(nx_int(0), nx_int(1), nx_widestr(huali))
  form.Icg_product:ShowItemAddInfo(nx_int(0), nx_int(1), true)
  form.Icg_product:SetItemAddInfo(nx_int(0), nx_int(2), nx_widestr(configid))
  form.Icg_product:ShowItemAddInfo(nx_int(0), nx_int(2), true)
  set_model(form, item_mod, item_mod_ini)
  on_Icg_product_select_changed(form.Icg_product, 0)
end
function on_btn_compose_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_string(btn.formula) == nx_string("") then
    return
  end
  local create_num = nx_int(form.ipt_1.Text)
  if create_num < nx_int(1) then
    return
  end
  nx_execute("custom_sender", "custom_send_fuse", nx_string(btn.formula), nx_int(create_num), 0, nx_int(btn.bindtype))
end
function on_btn_buy_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_string(form.Icg_product.configid) == nx_string("") then
    return
  end
  local buy_num = nx_int(form.ipt_2.Text)
  if buy_num < nx_int(1) then
    return
  end
  client_to_server_msg(CLIENT_BUY_FURNITURN, nx_string(form.Icg_product.configid), buy_num)
end
function on_btn_give_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_string(form.Icg_product.configid) == nx_string("") then
    return
  end
  local path = "form_stage_main\\form_home\\form_home_input_name"
  local dialog = nx_value(path)
  if nx_is_valid(dialog) then
    dialog:Close()
    return
  end
  dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_home\\form_home_input_name", true, false)
  dialog.lbl_text.HtmlText = nx_widestr("@ui_home_zensong")
  dialog.ipt_name.Text = nx_widestr("")
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "form_home_input_name")
  if nx_string(res) == "cancel" then
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
  local playername = nx_widestr(client_player:QueryProp("Name"))
  if nx_widestr(res) == playername then
    return
  end
  client_to_server_msg(CLIENT_SEND_FURNITURN, nx_string(form.Icg_product.configid), nx_int(1), nx_widestr(res))
end
function on_Icg_product_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if grid.type == 1 then
    local buy_num = nx_int(form.ipt_2.Text)
    local need_money = grid.money2 * buy_num
    form.lbl_b_silver_card.Text = trans_capital_string(need_money)
    local game_client = nx_value("game_client")
    if nx_is_valid(game_client) then
      local client_player = game_client:GetPlayer()
      if nx_is_valid(client_player) then
        local bind_money = client_player:QueryProp("CapitalType1")
        local nobind_money = client_player:QueryProp("CapitalType2")
        if nx_int64(nobind_money) >= nx_int64(need_money) then
          form.btn_buy.Enabled = true
          form.btn_give.Enabled = true
        end
      end
    end
  elseif grid.type == 2 then
    local crete_num = nx_int(form.ipt_1.Text)
    local need_money = grid.money * crete_num
    form.lbl_b_silver.Text = trans_capital_string(need_money)
    fresh_material(form)
  end
end
function on_rbtn_bind_click(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  rbtn.Checked = true
  form.cbtn_bu.Visible = true
  form.lbl_12.Visible = true
  fresh_material(rbtn.ParentForm)
end
function on_rbtn_nobind_click(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  rbtn.Checked = true
  form.cbtn_bu.Visible = false
  form.lbl_12.Visible = false
  fresh_material(rbtn.ParentForm)
end
function on_cbtn_bu_checked_changed(cbtn)
  fresh_material(cbtn.ParentForm)
end
function on_toolbox_viewport_change(form, optype)
  if optype == "updateitem" or optype == "additem" or optype == "delitem" then
    fresh_material(form)
  end
end
function fresh_material(form)
  if not nx_is_valid(form) then
    return
  end
  local product = form.Icg_product
  if nx_string(product.configid) == nx_string("") or nx_int(product.formula) <= nx_int(0) then
    return
  end
  if nx_int(product.type) ~= nx_int(2) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_MATERIAL_TOOL))
  if not nx_is_valid(view) then
    return
  end
  local tool = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(tool) then
    return
  end
  form.Icg_material:Clear()
  local iniformula = nx_execute("util_functions", "get_ini", "share\\Item\\fuse_formula.ini")
  if not nx_is_valid(iniformula) then
    return
  end
  local sec_index = iniformula:FindSectionIndex(nx_string(product.formula))
  if sec_index < 0 then
    return
  end
  if iniformula:ReadString(sec_index, "Profession", "") ~= "my_home" then
    return
  end
  local needitem = iniformula:ReadString(sec_index, "Material", "")
  if needitem == "" then
    return
  end
  form.btn_compose.Enabled = true
  form.btn_compose.formula = nx_int(product.formula)
  local viewobj_count = view:GetViewObjCount()
  local toolobj_count = tool:GetViewObjCount()
  local str_lst = util_split_string(needitem, ";")
  for i = 1, table.getn(str_lst) do
    local str_temp = util_split_string(str_lst[i], ",")
    local item = str_temp[1]
    local neednum = nx_int(str_temp[2])
    if neednum <= nx_int(0) then
      neednum = 1
    end
    local bind_num = 0
    local nobind_num = 0
    for i = 1, viewobj_count do
      local obj = view:GetViewObjByIndex(i - 1)
      local tempid = obj:QueryProp("ConfigID")
      local bind_status = obj:QueryProp("BindStatus")
      if tempid == item then
        local cur_amount = obj:QueryProp("Amount")
        if bind_status == 1 then
          bind_num = bind_num + cur_amount
        end
        if bind_status == 0 then
          nobind_num = nobind_num + cur_amount
        end
      end
    end
    for i = 1, toolobj_count do
      local obj = tool:GetViewObjByIndex(i - 1)
      local tempid = obj:QueryProp("ConfigID")
      local bind_status = obj:QueryProp("BindStatus")
      if tempid == item then
        local cur_amount = obj:QueryProp("Amount")
        if bind_status == 1 then
          bind_num = bind_num + cur_amount
        end
        if bind_status == 0 then
          nobind_num = nobind_num + cur_amount
        end
      end
    end
    local all_num = 0
    if form.cbtn_bu.Checked then
      all_num = bind_num + nobind_num
      form.btn_compose.bindtype = 2
    elseif form.rbtn_bind.Checked then
      all_num = bind_num
      form.btn_compose.bindtype = 0
    elseif form.rbtn_nobind.Checked then
      all_num = nobind_num
      form.btn_compose.bindtype = 1
    end
    local bExist = ItemQuery:FindItemByConfigID(item)
    local node_name = util_text(item)
    local photo = ItemQuery:GetItemPropByConfigID(item, "Photo")
    form.Icg_material:AddItem(nx_int(i - 1), photo, nx_widestr(node_name), 0, -1)
    local num_text = ""
    if nx_number(all_num) >= nx_number(neednum) then
      num_text = "<font color=\"#00ff00\">" .. nx_string(all_num) .. "/" .. nx_string(neednum) .. "</font>"
      form.Icg_material:ChangeItemImageToBW(nx_int(i - 1), false)
    else
      num_text = "<font color=\"#ff0000\">" .. nx_string(all_num) .. "/" .. nx_string(neednum) .. "</font>"
      form.Icg_material:ChangeItemImageToBW(nx_int(i - 1), true)
      form.btn_compose.Enabled = false
    end
    form.Icg_material:SetItemAddInfo(nx_int(i - 1), nx_int(1), nx_widestr(num_text))
    form.Icg_material:SetItemAddInfo(nx_int(i - 1), nx_int(2), nx_widestr(item))
    form.Icg_material:ShowItemAddInfo(nx_int(i - 1), nx_int(1), true)
    form.Icg_material:ShowItemAddInfo(nx_int(i - 1), nx_int(2), false)
  end
end
function on_Icg_Type_mousein_grid(grid, index)
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == nx_string("") then
    return
  end
  local tips = "tips_" .. nx_string(item_config)
  local text = util_text(tips)
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 0, grid.ParentForm)
end
function on_Icg_Type_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_Icg_ChildType_mousein_grid(grid, index)
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == "" then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(item_config)
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_Icg_ChildType_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_Icg_product_mousein_grid(grid, index)
  local item_config = grid:GetItemAddText(index, 2)
  if nx_string(item_config) == "" then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(item_config)
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_Icg_product_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_Icg_material_mousein_grid(grid, index)
  local item_config = grid:GetItemAddText(index, 2)
  if nx_string(item_config) == "" then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(item_config)
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_Icg_material_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_turn_left_click(btn)
  btn.MouseDown = false
  return
end
function on_btn_turn_left_lost_capture(btn)
  btn.MouseDown = false
  return
end
function on_btn_turn_left_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = 3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if not nx_is_valid(form) then
      return
    end
    nx_execute("util_gui", "ui_RotateModel", form.scenebox_mod, dist)
  end
end
function on_btn_turn_right_click(btn)
  btn.MouseDown = false
  return
end
function on_btn_turn_right_lost_capture(btn)
  btn.MouseDown = false
  return
end
function on_btn_turn_right_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = -3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if not nx_is_valid(form) then
      return
    end
    nx_execute("util_gui", "ui_RotateModel", form.scenebox_mod, dist)
  end
end
function on_btn_min_click(btn)
  btn.MouseDown = false
end
function on_btn_min_lost_capture(btn)
  btn.MouseDown = false
end
function on_btn_min_push(btn)
  btn.MouseDown = true
  min_max_change(btn, -0.02)
end
function on_btn_max_click(btn)
  btn.MouseDown = false
end
function on_btn_max_lost_capture(btn)
  btn.MouseDown = false
end
function on_btn_max_push(btn)
  btn.MouseDown = true
  min_max_change(btn, 0.02)
end
function min_max_change(btn, value)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local scene = form.scenebox_mod.Scene
  if not nx_is_valid(scene) then
    return
  end
  if not nx_find_custom(scene, "model") then
    return
  end
  local model = scene.model
  local min_scale = 0.2
  local max_scale = 1.5
  local model_min_scale = get_special_model_scale(form.Icg_product.configid)
  if min_scale > model_min_scale then
    min_scale = model_min_scale
  end
  while btn.MouseDown do
    nx_pause(0)
    if not nx_is_valid(model) then
      break
    end
    local x = model.ScaleX + value
    local y = model.ScaleY + value
    local z = model.ScaleZ + value
    if min_scale > x or max_scale < x or min_scale > y or max_scale < y or min_scale > z or max_scale < z then
      break
    end
    model:SetScale(x, y, z)
  end
end
function set_model(form, mods, mods_ini)
  nx_execute("util_gui", "ui_ClearModel", form.scenebox_mod)
  if nx_string(mods) == "" and (mods_ini == nil or mods_ini == "") then
    return
  end
  if not nx_is_valid(form.scenebox_mod.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_mod)
  end
  local mode
  if mods_ini ~= nil and mods_ini ~= "" then
    mode = form.scenebox_mod.Scene:Create("Actor2")
    load_from_ini(mode, "ini\\" .. mods_ini .. ".ini")
    if not nx_is_valid(form) then
      return
    end
  else
    mode = nx_execute("util_functions", "util_create_model", nx_string(mods), "", "", "", "", false, form.scenebox_mod.Scene)
  end
  if not nx_is_valid(mode) then
    return
  end
  local scale = get_special_model_scale(form.Icg_product.configid)
  if scale < 0.55 then
    mode:SetScale(scale, scale, scale)
  else
    mode:SetScale(0.55, 0.55, 0.55)
  end
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_mod, mode)
  nx_execute("util_gui", "ui_RotateModel", form.scenebox_mod, math.pi)
end
function set_xmod(form, mods)
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if nx_is_valid(form.scenebox_mod.Scene) then
    nx_execute("util_gui", "ui_ClearModel", form.scenebox_mod)
  end
  if nx_string(mods) == "" then
    return
  end
  if not nx_is_valid(form.scenebox_mod.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_mod)
  end
  local actor2 = form.scenebox_mod.Scene:Create("Actor2")
  nx_execute("role_composite", "load_from_ini", actor2, "ini\\" .. nx_string(mods) .. ".ini")
  if not nx_is_valid(actor2) then
    return
  end
  if not nx_find_custom(form, "scenebox_mod") then
    return
  end
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_mod, actor2)
  if game_visual:QueryRoleActionSet(actor2) ~= "" then
    game_visual:SetRoleActionSet(actor2, game_visual:QueryRoleActionSet(actor2))
  end
  local action = nx_value("action_module")
  if nx_is_valid(action) then
    action:BlendAction(actor2, "ty_stand_01", false, true)
  end
  form.scenebox_mod.Visible = true
  local scene = form.scenebox_mod.Scene
  local radius = 2.1
  scene.camera:SetPosition(0, radius * 0.4, -radius * 1.45)
  nx_execute("util_gui", "ui_RotateModel", form.scenebox_mod, 0)
end
function can_show_child(form, indexid)
  local lists = get_list_table(nx_string(indexid), "list")
  if lists == nil then
    return false
  end
  for i = 1, table.getn(lists) do
    if lists[i] == "" then
      break
    end
    if can_show(form, lists[i]) then
      return true
    end
  end
  return false
end
function can_show(form, configid)
  local type1 = nx_number(nx_execute("tips_data", "get_ini_prop", "share\\Item\\home_furniture.ini", nx_string(configid), "type", "0"))
  if nx_number(form.open_type) ~= type1 then
    return false
  end
  return true
end
function on_ipt_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.Icg_product) then
    return
  end
  on_Icg_product_select_changed(form.Icg_product, 0)
end
function get_special_model_scale(config_id)
  local scale = 0.55
  for i = 1, table.getn(model_scale_table) do
    if model_scale_table[i].name == config_id then
      scale = model_scale_table[i].scale
      break
    end
  end
  return scale
end
