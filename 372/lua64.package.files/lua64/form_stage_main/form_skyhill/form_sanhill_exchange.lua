require("util_gui")
require("util_functions")
require("util_static_data")
require("share\\client_custom_define")
local FORM_NAME = "form_stage_main\\form_skyhill\\form_sanhill_exchange"
local FORM_EXCHANGE_ITEM = "form_stage_main\\form_skyhill\\form_sanhill_exchange_item"
local NODE_PROP = {
  [1] = {
    NodeBackImage = "gui\\special\\smzb\\anniu_out.png",
    NodeFocusImage = "gui\\special\\smzb\\anniu_on.png",
    NodeSelectImage = "gui\\special\\smzb\\anniu_on.png",
    NodeCoverImage = "gui\\special\\tiguan\\chac.png",
    Font = "font_treeview",
    ForeColor = "255,197,184,159",
    ItemHeight = 30,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 1,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 25,
    TextOffsetY = 6
  },
  [2] = {
    NodeBackImage = "gui\\common\\treeview\\tree_2_out.png",
    NodeFocusImage = "gui\\common\\treeview\\tree_2_on.png",
    NodeSelectImage = "gui\\common\\treeview\\tree_2_on.png",
    NodeCoverImage = "gui\\special\\tiguan\\chac.png",
    Font = "font_treeview",
    ItemHeight = 22,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 0,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 25,
    TextOffsetY = 3
  }
}
local INI_SANHILL_EXCHANGE = "share\\SkyHill\\sanhill_exchange.ini"
local HUXIAO_POINT_ONLY = 1
local GUPU_POINT_ONLY = 2
local SanHill_Point1 = 0
local SanHill_Point2 = 1
local SanHill_Point3 = 2
function on_main_form_init(form)
end
function on_main_form_open(form)
  form.point1 = 0
  form.point2 = 0
  form.point3 = 0
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("SanHillPoint1", "int", form, nx_current(), "on_update_sanhill_point1")
    databinder:AddRolePropertyBind("SanHillPoint2", "int", form, nx_current(), "on_update_sanhill_point2")
    databinder:AddRolePropertyBind("SanHillPoint3", "int", form, nx_current(), "on_update_sanhill_point3")
  end
  inner_refresh_exchange_item_list()
end
function on_main_form_close(form)
  nx_destroy(form)
end
function get_tiguan_dualplay_ini(path)
  return get_ini(nx_string(path), false)
end
function set_node_prop(node, index)
  if not nx_is_valid(node) then
    return
  end
  if nx_number(index) < 0 or nx_number(index) > table.getn(NODE_PROP) then
    return
  end
  for prop_name, value in pairs(NODE_PROP[nx_number(index)]) do
    nx_set_property(node, nx_string(prop_name), value)
  end
end
function clone_control(ctrl_type, name, refer_ctrl, parent_ctrl)
  if not (nx_is_valid(refer_ctrl) and nx_is_valid(parent_ctrl)) or ctrl_type == "" or name == "" then
    return nx_null()
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  local cloned_ctrl = gui:Create(ctrl_type)
  if not nx_is_valid(cloned_ctrl) then
    return nx_null()
  end
  local prop_list = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_list) do
    nx_set_property(cloned_ctrl, prop_list[i], nx_property(refer_ctrl, prop_list[i]))
  end
  cloned_ctrl.Left = refer_ctrl.Left
  cloned_ctrl.Top = refer_ctrl.Top
  nx_set_custom(parent_ctrl.ParentForm, name, cloned_ctrl)
  cloned_ctrl.Name = name
  parent_ctrl:Add(cloned_ctrl)
  return cloned_ctrl
end
function inner_refresh_exchange_item_list()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local ini_exchange = get_tiguan_dualplay_ini(INI_SANHILL_EXCHANGE)
  if not nx_is_valid(ini_exchange) then
    return
  end
  local sec_index = ini_exchange:FindSectionIndex("0")
  local node_list, node_count, subnode_list, subnode_count, node_name, tmp_list, tmp_count, tmp_node, tmp_subnode
  local root_exchange = form.tree_exchange:CreateRootNode(nx_widestr("root"))
  local key_node_list = ini_exchange:GetItemValueList(sec_index, "r")
  local first_node
  form.tree_exchange:BeginUpdate()
  for m = 1, table.getn(key_node_list) do
    sec_index = ini_exchange:FindSectionIndex(nx_string(key_node_list[m]))
    node_list = ini_exchange:GetItemValueList(sec_index, "Node")
    node_count = table.getn(node_list)
    if node_count <= 0 then
      return
    end
    node_name = util_text(node_list[1])
    tmp_node = root_exchange:CreateNode(node_name)
    if m == 1 then
      first_node = tmp_node
    end
    set_node_prop(tmp_node, 1)
    tmp_node.node_type = nx_string(m) .. "_" .. nx_string(1)
    subnode_list = ini_exchange:GetItemValueList(sec_index, "SubNode")
    subnode_count = table.getn(subnode_list)
    for i = 1, subnode_count do
      tmp_list = util_split_string(nx_string(subnode_list[i]), ",")
      tmp_count = table.getn(tmp_list)
      if 2 <= tmp_count then
        node_name = util_text(tmp_list[1])
        if not nx_ws_equal(node_name, nx_widestr("")) then
          tmp_subnode = tmp_node:CreateNode(node_name)
          if i == 1 then
            first_node = tmp_subnode
          end
          set_node_prop(tmp_subnode, 2)
          tmp_subnode.node_type = nx_string(m) .. "_" .. nx_string(i)
        end
      end
    end
  end
  root_exchange.Expand = true
  root_exchange:ExpandAll()
  form.tree_exchange.IsNoDrawRoot = true
  form.tree_exchange:EndUpdate()
  if nx_is_valid(first_node) then
    form.tree_exchange.SelectNode = first_node
  end
end
function on_tree_exchange_select_changed(self, cur_node, pre_node)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(cur_node, "node_type") then
    show_exchange_info(form, cur_node.node_type)
  end
end
function show_exchange_info(form, node_type)
  if not nx_is_valid(form) then
    return
  end
  local tmp_list = util_split_string(nx_string(node_type), "_")
  if table.getn(tmp_list) ~= 2 then
    return
  end
  local find_index_node = nx_number(tmp_list[1])
  local find_index_subnode = nx_number(tmp_list[2])
  local ini_exchange = get_tiguan_dualplay_ini(INI_SANHILL_EXCHANGE)
  if not nx_is_valid(ini_exchange) then
    return
  end
  local sec_index = ini_exchange:FindSectionIndex(nx_string(find_index_node))
  if sec_index < 0 then
    return
  end
  local subnode_list = ini_exchange:GetItemValueList(sec_index, "SubNode")
  local subnode_count = table.getn(subnode_list)
  if subnode_count <= 0 or find_index_subnode > subnode_count then
    return
  end
  local subnode_string = util_split_string(nx_string(subnode_list[find_index_subnode]), ",")
  local subnode_string_count = table.getn(subnode_string)
  local div, mod
  if 4 < subnode_string_count then
    div = nx_int((subnode_string_count - 1) / 4)
    mod = math.mod(subnode_string_count - 1, 4)
    if mod ~= 0 then
      div = div + 1
    end
  else
    div = 1
  end
  form.groupscrollbox_reward_items.IsEditMode = true
  form.groupscrollbox_reward_items:DeleteAll()
  local t_gbox, t_btn, t_imagegrid, t_mltbox_name, t_mltbox_exchange, t_mltbox_desc, t_mltbox_condition, gbox_parent, gbox, btn, imagegrid, mltbox_name, mltbox_exchange, mltbox_desc, mltbox_condition, tmp_text, photo
  local begin_index = 2
  for i = 1, nx_number(div) do
    gbox_parent = clone_control("GroupBox", "gbox_exchange_parent_" .. nx_string(i), form.groupbox_template_reward, form.groupscrollbox_reward_items)
    if nx_is_valid(gbox_parent) then
      gbox_parent.Left = 0
      gbox_parent.Visible = true
      for j = 1, 4 do
        t_gbox = nx_custom(form, "groupbox_template_eh" .. nx_string(j))
        gbox = clone_control("GroupBox", "gbox_exchange_" .. nx_string(i) .. nx_string(j), t_gbox, gbox_parent)
        if nx_is_valid(gbox) then
          sec_index = ini_exchange:FindSectionIndex(nx_string(subnode_string[begin_index]))
          if 0 <= sec_index then
            gbox.Visible = true
            t_btn = nx_custom(form, "btn_tmp_back" .. nx_string(j))
            btn = clone_control("Button", "btn_exchange_" .. nx_string(i) .. nx_string(j), t_btn, gbox)
            if nx_is_valid(btn) then
              tmp_text = ini_exchange:ReadString(sec_index, "ConditionID", "")
              if nx_string(tmp_text) == "" then
                tmp_text = 0
              end
              btn.condition_id = nx_int(tmp_text)
              btn.Visible = true
              btn.DataSource = subnode_list[begin_index]
              btn.SubType = nx_int(find_index_node)
              nx_bind_script(btn, nx_current())
              nx_callback(btn, "on_click", "on_btn_exchange_click")
            end
            t_imagegrid = nx_custom(form, "imagegrid_eh" .. nx_string(j))
            imagegrid = clone_control("ImageGrid", "imagegrid_exchange_" .. nx_string(i) .. nx_string(j), t_imagegrid, gbox)
            if nx_is_valid(imagegrid) then
              imagegrid.Visible = true
              imagegrid.TestTrans = false
              imagegrid.Transparent = false
              tmp_text = ini_exchange:ReadString(sec_index, "ItemID", "")
              if nx_is_valid(btn) then
                btn.item_id = tmp_text
              end
              imagegrid:Clear()
              photo = item_query_ArtPack_by_id(tmp_text, "Photo")
              imagegrid.DataSource = tmp_text
              imagegrid:AddItem(0, photo, nx_widestr(tmp_text), 1, -1)
              imagegrid:CoverItem(0, true)
              nx_bind_script(imagegrid, nx_current())
              nx_callback(imagegrid, "on_mousein_grid", "on_imagegrid_item_mousein_grid")
              nx_callback(imagegrid, "on_mouseout_grid", "on_imagegrid_item_mouseout_grid")
            end
            t_mltbox_name = nx_custom(form, "mltbox_tmp_name" .. nx_string(j))
            mltbox_name = clone_control("MultiTextBox", "mltbox_exchange_name_" .. nx_string(i) .. nx_string(j), t_mltbox_name, gbox)
            if nx_is_valid(mltbox_name) then
              mltbox_name.Visible = true
              mltbox_name.TestTrans = true
              mltbox_name.Transparent = true
              if nx_is_valid(btn) then
                mltbox_name.HtmlText = util_text(nx_string(btn.item_id))
              end
            end
            t_mltbox_desc = nx_custom(form, "mltbox_tmp_desc" .. nx_string(j))
            mltbox_desc = clone_control("MultiTextBox", "mltbox_exchange_desc_" .. nx_string(i) .. nx_string(j), t_mltbox_desc, gbox)
            if nx_is_valid(mltbox_desc) then
              mltbox_desc.Visible = true
              mltbox_desc.TestTrans = true
              mltbox_desc.Transparent = true
              tmp_text = ini_exchange:ReadString(sec_index, "SanHillPoint1", "")
              local point_count = nx_int(tmp_text)
              if point_count > nx_int(0) then
                mltbox_desc.HtmlText = util_format_string("ui_sanhill_exchange1", point_count)
                if nx_is_valid(btn) then
                  btn.limit_point_type = nx_int(SanHill_Point1)
                end
              end
              tmp_text = ini_exchange:ReadString(sec_index, "SanHillPoint2", "")
              point_count = nx_int(tmp_text)
              if point_count > nx_int(0) then
                mltbox_desc.HtmlText = util_format_string("ui_sanhill_exchange2", point_count)
                if nx_is_valid(btn) then
                  btn.limit_point_type = nx_int(SanHill_Point2)
                end
              end
              tmp_text = ini_exchange:ReadString(sec_index, "SanHillPoint3", "")
              point_count = nx_int(tmp_text)
              if point_count > nx_int(0) then
                mltbox_desc.HtmlText = util_format_string("ui_sanhill_exchange3", point_count)
                if nx_is_valid(btn) then
                  btn.limit_point_type = nx_int(SanHill_Point3)
                end
              end
              if nx_is_valid(btn) then
                btn.limit_info = mltbox_desc.HtmlText
                btn.limit_point_count = nx_int(point_count)
              end
            end
            t_mltbox_exchange = nx_custom(form, "mltbox_tmp_exchange" .. nx_string(j))
            mltbox_exchange = clone_control("MultiTextBox", "mltbox_exchange_info_" .. nx_string(i) .. nx_string(j), t_mltbox_exchange, gbox)
            if nx_is_valid(mltbox_exchange) then
              mltbox_exchange.Visible = true
              mltbox_exchange.TestTrans = true
              mltbox_exchange.Transparent = true
              mltbox_exchange.exchange_type = 0
              mltbox_exchange.exchange_count = 0
              tmp_text = ini_exchange:ReadString(sec_index, "ExchangeType", "")
              mltbox_exchange.exchange_type = tmp_text
              if nx_int(tmp_text) <= nx_int(0) then
                mltbox_exchange.HtmlText = util_text("ui_tiguan_dual_play_11")
              elseif nx_int(tmp_text) == nx_int(1) then
                tmp_text = ini_exchange:ReadString(sec_index, "ExchangeCount", "")
                mltbox_exchange.HtmlText = util_format_string("ui_tiguan_dual_play_12", nx_int(tmp_text))
                mltbox_exchange.exchange_count = tmp_text
              elseif nx_int(tmp_text) == nx_int(2) then
                tmp_text = ini_exchange:ReadString(sec_index, "ExchangeCount", "")
                mltbox_exchange.HtmlText = util_format_string("ui_tiguan_dual_play_13", nx_int(tmp_text))
                mltbox_exchange.exchange_count = tmp_text
              end
            end
            t_mltbox_condition = nx_custom(form, "mltbox_condicon" .. nx_string(j))
            mltbox_condition = clone_control("MultiTextBox", "mltbox_condiconinfo" .. nx_string(i) .. nx_string(j), t_mltbox_condition, gbox)
            if nx_is_valid(mltbox_condition) then
              tmp_text = ini_exchange:ReadString(sec_index, "ConditionID", "")
              mltbox_condition.HtmlText = util_text("sanhill_exchange_condition_" .. nx_string(tmp_text))
            end
          else
            gbox.Visible = false
          end
          begin_index = begin_index + 1
        end
      end
    end
  end
  form.groupscrollbox_reward_items.IsEditMode = false
  form.groupscrollbox_reward_items:ResetChildrenYPos()
end
function on_btn_exchange_click(btn)
  local form = btn.ParentForm
  local point_1 = nx_int(form.point1)
  local point_2 = nx_int(form.point2)
  local point_3 = nx_int(form.point3)
  local single_point = nx_int(0)
  local need_point = nx_int(btn.limit_point_count)
  local need_type = nx_int(btn.limit_point_type)
  if need_type == nx_int(SanHill_Point1) then
    single_point = point_3
  elseif need_type == nx_int(SanHill_Point2) then
    single_point = point_2
  elseif need_type == nx_int(SanHill_Point3) then
    single_point = point_3
  end
  nx_execute(FORM_EXCHANGE_ITEM, "show_exchange_item_subform", btn.item_id, btn.limit_info, single_point, need_point, btn.condition_id, btn.SubType)
end
function on_update_sanhill_point1(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
    return
  end
  form.point1 = nx_int(prop_value)
  form.lbl_point1.Text = nx_widestr(form.point1)
end
function on_update_sanhill_point2(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
    return
  end
  form.point2 = nx_int(prop_value)
  form.lbl_point2.Text = nx_widestr(form.point2)
end
function on_update_sanhill_point3(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
    return
  end
  form.point3 = nx_int(prop_value)
  form.lbl_point3.Text = nx_widestr(form.point3)
end
function on_imagegrid_item_mousein_grid(grid)
  local ConfigID = grid.DataSource
  nx_execute("tips_game", "show_tips_by_config", ConfigID, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_imagegrid_item_mouseout_grid(grid)
  nx_execute("tips_game", "hide_tip")
end
