require("util_functions")
local table_view = {
  [1] = "\215\176\177\184\192\184",
  [2] = "\181\192\190\223\192\184",
  [3] = "\184\189\188\211\181\196\176\252\185\252\192\184",
  [4] = "\178\214\191\226\192\184",
  [5] = "\184\189\188\211\181\196\178\214\191\226\192\184",
  [7] = "\179\232\206\239\192\185",
  [8] = "\198\239\179\203\192\185",
  [10] = "\215\176\177\184\188\248\182\168\192\184",
  [11] = "\215\176\177\184\201\253\188\182\192\184",
  [12] = "\188\211\208\199\192\184",
  [13] = "\207\226\199\182\192\184",
  [14] = "\180\242\191\215\192\184",
  [15] = "\184\189\196\167\192\184",
  [16] = "\184\189\196\167\201\253\188\182\192\184",
  [17] = "\184\196\212\236\192\184",
  [18] = "\215\176\177\184\199\169\195\251\192\184",
  [19] = "\206\239\198\183\176\243\182\168\178\217\215\247\192\184",
  [20] = "\206\239\198\183\206\229\208\208\161\162\193\233\187\234\203\248\193\180\214\216\214\195\181\196\178\217\215\247\192\184",
  [21] = "\215\176\177\184\215\163\184\163\192\184",
  [22] = "\215\176\177\184\215\170\187\187\192\184",
  [30] = "\215\212\188\186\181\196\189\187\187\187\192\184",
  [31] = "\198\228\203\251\205\230\188\210\181\196\189\187\187\187\192\184",
  [32] = "\215\212\188\186\181\196\179\246\202\219\192\184",
  [33] = "\198\228\203\251\205\230\188\210\181\196\179\246\202\219\192\184",
  [35] = "\211\202\188\196\188\196\206\239\198\183\181\196\200\221\198\247",
  [36] = "\211\202\188\196\202\213\206\239\198\183\181\196\200\221\198\247",
  [40] = "\188\188\196\220\200\221\198\247",
  [41] = "\198\213\205\168\185\165\187\247\188\188\196\220\200\221\198\247",
  [42] = "BUFFER\200\221\198\247",
  [43] = "\196\218\185\166\200\221\198\247",
  [44] = "\209\168\206\187\200\221\198\247",
  [45] = "\190\173\194\246\200\221\198\247",
  [46] = "\199\225\185\166\200\221\198\247",
  [47] = "\213\243\183\168\200\221\198\247",
  [48] = "\202\214\183\168\200\221\198\247",
  [50] = "\201\237\201\207\181\196\179\232\206\239\200\221\198\247",
  [51] = "\179\232\206\239\181\196\178\214\191\226\200\221\198\247",
  [60] = "\203\230\187\250\201\204\181\234\181\196\181\192\190\223\200\221\198\247",
  [61] = "\198\213\205\168\201\204\181\234\200\221\198\247",
  [62] = "\197\220\201\204\201\204\181\234\200\221\198\247",
  [63] = "\197\220\201\204\181\196\205\230\188\210\200\221\198\247",
  [64] = "\205\230\188\210\187\216\185\186\200\221\198\247 ",
  [80] = "NPC\181\244\194\228\202\176\200\161\200\221\198\247",
  [81] = " \197\169\215\247\206\239\181\200\192\224\203\198\215\202\212\180\192\224NPC\181\196\181\244\194\228\192\184",
  [90] = " \177\224\188\173\200\206\206\241\189\177\192\248\200\221\198\247",
  [91] = "\204\225\189\187\202\213\188\175\192\224\177\224\188\173\200\206\206\241\200\221\198\247",
  [92] = "\189\187\210\215\202\177\215\212\188\186\181\196\206\239\198\183\188\211\185\164\192\184",
  [93] = "\189\187\210\215\202\177\182\212\183\189\181\196\206\239\198\183\188\211\185\164\192\184",
  [100] = "\186\207\179\201\200\221\198\247",
  [101] = "\176\239\187\225\178\214\191\226\192\184",
  [110] = "\192\235\207\223\176\218\204\175 \206\239\198\183\201\207\188\220\181\196\200\221\198\247",
  [111] = "\178\233\191\180\198\228\203\252\205\230\188\210\179\246\202\219\192\184",
  [112] = "\185\171\187\225\214\198\212\236\187\250\185\216\200\221\198\247",
  [113] = "\198\229\197\204\202\211\180\176",
  [114] = "A\215\233\179\201\212\177",
  [115] = "b\215\233\179\201\212\177",
  [116] = "\205\230\188\210\211\206\207\183\215\211\182\212\207\243\200\221\198\247",
  [121] = "\215\176\177\184\176\252\185\252",
  [122] = "\215\176\177\184\184\189\188\211\176\252\185\252",
  [123] = "\178\196\193\207\176\252\185\252",
  [124] = "\178\196\193\207\184\189\188\211\176\252\185\252",
  [125] = "\200\206\206\241\176\252\185\252",
  [126] = "\200\206\206\241\184\189\188\211\176\252\185\252",
  [127] = "\184\177\177\190\205\168\185\216\189\177\192\248\200\221\198\247",
  [128] = "\213\253\212\218\202\185\211\195\181\196\206\239\198\183\200\221\198\247",
  [129] = "\183\214\189\226\206\239\198\183\200\221\198\247",
  [130] = "\192\222\204\168\178\169\178\202\200\221\198\247",
  [131] = "\189\204\205\183\200\221\198\247",
  [132] = "\176\239\197\201\213\189\200\221\198\247",
  [133] = "\192\222\204\168\193\236\189\177\206\239\198\183\200\221\198\247",
  [138] = "\176\239\187\225\201\250\187\238\190\237\214\225\200\221\198\247",
  [139] = "\176\239\187\225\187\250\185\216\200\221\198\247",
  [140] = "\201\250\187\238\185\178\207\237\183\254\206\241\200\221\198\247",
  [141] = "\206\228\209\167\195\216\188\174\186\207\179\201"
}
function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.no_need_motion_alpha = true
  show_client(self)
  return 1
end
function show_client(form)
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local tree = form.object_tree
  local root = tree:CreateRootNode(nx_widestr(util_text("ui_Client")))
  root.type = "client"
  root.object = client
  local scene = client:GetScene()
  if nx_is_valid(scene) then
    local scene_node = root:CreateNode(nx_widestr(util_text("ui_CurrentScene")) .. nx_widestr(":") .. nx_widestr(util_text(scene:QueryProp("ConfigID"))))
    scene_node.type = "scene"
    scene_node.object = scene
    scene_node.vis_object = game_visual:GetScene()
    local prop_node = scene_node:CreateNode(nx_widestr(util_text("ui_Property")))
    prop_node.type = "prop_set"
    prop_node.object = scene
    local scene_obj_table = scene:GetSceneObjList()
    for k = 1, table.getn(scene_obj_table) do
      local scene_obj = scene_obj_table[k]
      local node_name
      if client:IsPlayer(scene_obj.Ident) then
        node_name = nx_widestr(util_text("ui_MainRoleX")) .. nx_widestr(scene_obj.Ident) .. nx_widestr("]")
      elseif scene_obj:QueryProp("Type") == 2 then
        node_name = nx_widestr(util_text("ui_TargetX")) .. nx_widestr(scene_obj:QueryProp("Name")) .. nx_widestr("][") .. nx_widestr(scene_obj.Ident) .. nx_widestr("]")
      else
        node_name = nx_widestr(util_text("ui_TargetX")) .. nx_widestr(util_text(scene_obj:QueryProp("ConfigID"))) .. nx_widestr("][") .. nx_widestr(scene_obj.Ident) .. nx_widestr("]")
      end
      local scene_obj_node = scene_node:CreateNode(nx_widestr(node_name))
      scene_obj_node.type = "scene_obj"
      scene_obj_node.object = scene_obj
      scene_obj_node.vis_object = game_visual:GetSceneObj(scene_obj.Ident)
      local prop_node = scene_obj_node:CreateNode(nx_widestr(util_text("ui_Property")))
      prop_node.type = "prop_set"
      prop_node.object = scene_obj
      local record_table = scene_obj:GetRecordList()
      for k = 1, table.getn(record_table) do
        local record_name = record_table[k]
        local record_node = scene_obj_node:CreateNode(nx_widestr(util_text("ui_TableX")) .. nx_widestr(record_name) .. nx_widestr("]"))
        record_node.type = "record"
        record_node.object = scene_obj
        record_node.record_name = record_name
      end
    end
  end
  local view_set_node = root:CreateNode(nx_widestr(util_text("ui_ContainerView")))
  view_set_node.type = "view_set"
  local view_table = client:GetViewList()
  for i = 1, table.getn(view_table) do
    local view = view_table[i]
    local viewName = ""
    if table_view[nx_number(view.Ident)] ~= nil then
      viewName = nx_string(table_view[nx_number(view.Ident)])
    else
      viewName = "\206\180\195\252\195\251\202\211\205\188"
    end
    view_node = view_set_node:CreateNode(nx_widestr(util_text("ui_ViewX") .. nx_widestr(view.Ident) .. nx_widestr("]") .. nx_widestr(viewName)))
    view_node.type = "view"
    view_node.object = view
    local prop_node = view_node:CreateNode(nx_widestr(util_text("ui_Property")))
    prop_node.type = "prop_set"
    prop_node.object = view
    local view_obj_table = view:GetViewObjList()
    for k = 1, table.getn(view_obj_table) do
      local view_obj = view_obj_table[k]
      local view_obj_node = view_node:CreateNode(nx_widestr(util_text("ui_GoodsX") .. nx_widestr(view_obj.Ident) .. nx_widestr("]") .. util_text(view_obj:QueryProp("ConfigID"))))
      view_obj_node.type = "view_obj"
      view_obj_node.object = view_obj
      local prop_node = view_obj_node:CreateNode(nx_widestr(util_text("ui_Property")))
      prop_node.type = "prop_set"
      prop_node.object = view_obj
      local record_table = view_obj:GetRecordList()
      for k = 1, table.getn(record_table) do
        local record_name = record_table[k]
        local record_node = view_obj_node:CreateNode(nx_widestr(util_text("ui_TableX") .. nx_widestr(record_name) .. nx_widestr("]")))
        record_node.type = "record"
        record_node.object = view_obj
        record_node.record_name = record_name
      end
    end
  end
  local global_node = root:CreateNode(nx_widestr(util_text("ui_GlobalObject")))
  global_node.type = "global_value_set"
  local global_values_table = nx_value_list()
  table.sort(global_values_table)
  for i, value in pairs(global_values_table) do
    value_node = global_node:CreateNode(nx_widestr(value))
    value_node.type = "global_value"
    value_node.object = nx_value(value)
  end
  root.Expand = true
  return 1
end
function on_btn_refresh_click(btn)
  local form = btn.Parent
  local tree = form.object_tree
  local value_grid = form.value_grid
  local visual_grid = form.visual_grid
  local cur_scroll_value_1 = value_grid.VScrollBar.Value
  local cur_scroll_value_2 = visual_grid.VScrollBar.Value
  object_select_changed(tree)
  value_grid.VScrollBar.Value = cur_scroll_value_1
  visual_grid.VScrollBar.Value = cur_scroll_value_2
end
function on_btn_close_click(btn)
  local form = btn.Parent
  form:Close()
  nx_gen_event(form, "debug_return", "cancel")
  nx_destroy(form)
  return 1
end
function get_type_string(type)
  if type == 1 then
    return "bool"
  elseif type == 2 then
    return "int"
  elseif type == 3 then
    return "int64"
  elseif type == 4 then
    return "float"
  elseif type == 5 then
    return "double"
  elseif type == 6 then
    return "string"
  elseif type == 7 then
    return "widestr"
  elseif type == 8 then
    return "object"
  elseif type == 9 then
    return "pointer"
  elseif type == 10 then
    return "userdata"
  elseif type == 11 then
    return "table"
  end
  return "unknown"
end
function clear_grid(form)
  form.value_grid:ClearRow()
  form.visual_grid:ClearRow()
  return 1
end
function grid_set_col(grid, cols)
  grid:ClearRow()
  grid.ColWidth = (grid.Width - 20) / cols
  grid.ColCount = cols
  return 1
end
function grid_add_prop(grid, obj, prop)
  if not nx_find_property(obj, prop) then
    return 0
  end
  local row = grid:InsertRow(-1)
  grid:SetGridText(row, 0, nx_widestr(prop))
  grid:SetGridText(row, 1, nx_widestr(nx_property(obj, prop)))
  return 1
end
function grid_add_custom(grid, obj, prop)
  if not nx_find_custom(obj, prop) then
    return 0
  end
  local row = grid:InsertRow(-1)
  grid:SetGridText(row, 0, nx_widestr(prop))
  grid:SetGridText(row, 1, nx_widestr(nx_custom(obj, prop)))
  return 1
end
function show_object(form, obj)
  if not nx_is_valid(obj) then
    return 0
  end
  local grid = form.value_grid
  grid_set_col(grid, 2)
  grid_set_col(grid, 2)
  grid:SetColTitle(0, nx_widestr(util_text("ui_Name")))
  grid:SetColTitle(1, nx_widestr(util_text("ui_Value")))
  local prop_table = nx_property_list(obj)
  for i = 1, table.getn(prop_table) do
    grid_add_prop(grid, obj, prop_table[i])
  end
  local custom_table = nx_custom_list(obj)
  for i = 1, table.getn(custom_table) do
    grid_add_custom(grid, obj, custom_table[i])
  end
  return 1
end
function show_vis_object(form, obj)
  if not nx_is_valid(obj) then
    return 0
  end
  local grid = form.visual_grid
  grid_set_col(grid, 2)
  grid_set_col(grid, 2)
  grid:SetColTitle(0, nx_widestr(util_text("ui_Name")))
  grid:SetColTitle(1, nx_widestr(util_text("ui_Value")))
  local prop_table = nx_property_list(obj)
  for i = 1, table.getn(prop_table) do
    grid_add_prop(grid, obj, prop_table[i])
  end
  local custom_table = nx_custom_list(obj)
  for i = 1, table.getn(custom_table) do
    grid_add_custom(grid, obj, custom_table[i])
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 1
  end
  return 1
end
function show_prop_set(form, obj)
  if not nx_is_valid(obj) then
    return 0
  end
  local grid = form.value_grid
  grid_set_col(grid, 2)
  grid:SetColTitle(0, nx_widestr(util_text("ui_PropertyName")))
  grid:SetColTitle(1, nx_widestr(util_text("ui_PropertyValue")))
  local prop_table = obj:GetPropList()
  local prop_num = table.getn(prop_table)
  grid.RowCount = prop_num
  for i = 1, prop_num do
    local prop_name = prop_table[i]
    local prop_value = obj:QueryProp(prop_name)
    grid:SetGridText(i - 1, 0, nx_widestr(prop_name))
    grid:SetGridText(i - 1, 1, nx_widestr(prop_value))
  end
  return 1
end
function show_record(form, obj, name)
  if not nx_is_valid(obj) then
    return 0
  end
  local cols = obj:GetRecordCols(name)
  local rows = obj:GetRecordRows(name)
  local grid = form.value_grid
  grid:ClearRow()
  grid.ColWidth = 100
  grid.ColCount = cols
  for i = 0, cols - 1 do
    grid:SetColTitle(i, nx_widestr(i))
  end
  grid.RowCount = rows
  for r = 0, rows - 1 do
    for c = 0, cols - 1 do
      local value = obj:QueryRecord(name, r, c)
      grid:SetGridText(r, c, nx_widestr(value))
    end
  end
  return 1
end
function object_select_changed(self)
  local form = self.Parent
  local node = self.SelectNode
  clear_grid(form)
  if node.type == "client" then
  elseif node.type == "view_set" then
  elseif node.type == "view" then
    show_object(form, node.object)
  elseif node.type == "view_obj" then
    show_object(form, node.object)
  elseif node.type == "player" then
    show_object(form, node.object)
    show_vis_object(form, node.vis_object)
  elseif node.type == "scene" then
    show_object(form, node.object)
    show_vis_object(form, node.vis_object)
  elseif node.type == "scene_obj" then
    show_object(form, node.object)
    show_vis_object(form, node.vis_object)
  elseif node.type == "prop_set" then
    show_prop_set(form, node.object)
  elseif node.type == "record" then
    show_record(form, node.object, node.record_name)
  elseif node.type == "global_value_set" then
  elseif node.type == "global_value" then
    show_object(form, node.object)
  end
  return 1
end
function on_btn_pos_click(btn)
  local form = btn.Parent
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local game_player = game_visual:GetPlayer()
  if not nx_is_valid(game_player) then
    return
  end
  local x = string.format("%.3f", game_player.PositionX)
  local y = string.format("%.3f", game_player.PositionY)
  local z = string.format("%.3f", game_player.PositionZ)
  local o = string.format("%.3f", game_player.AngleY)
  form.ipt_pos.Text = nx_widestr("")
  form.ipt_pos:Append(nx_widestr(nx_string(x) .. "," .. nx_string(y) .. "," .. nx_string(z) .. "," .. nx_string(o)))
end
function on_btn_select_click(btn)
  local form = btn.ParentForm
  local node = form.object_tree.SelectNode
  if not nx_is_valid(node) or not nx_is_valid(node.object) then
    return
  end
  nx_call("custom_sender", "custom_gminfo", nx_widestr("setobj"))
  nx_call("custom_sender", "custom_gminfo", nx_widestr("set LastObject " .. nx_string(node.object.Ident)))
end
