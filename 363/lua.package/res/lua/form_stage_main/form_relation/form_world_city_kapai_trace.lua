require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("form_stage_main\\form_origin\\kapai_define")
local color_0 = "255,248,222,6"
local color_1 = "255,255,0,0"
local color_2 = "255,247,136,6"
local color_3 = "255,155,199,31"
local color_4 = "255,255,0,0"
local state_0 = "ui_kapai_state_0"
local state_1 = "ui_kapai_state_1"
local state_2 = "ui_kapai_state_2"
local state_3 = "ui_kapai_state_3"
local state_4 = "ui_kapai_state_4"
local color_condition_true = "255,155,199,31"
local color_condition_false = "255,255,0,0"
function main_form_init(form)
  form.Fixed = false
  change_form_size(form)
  return 1
end
function on_main_form_open(form)
  change_form_size(form)
  init_form_lock_state(form, false)
  init_form_alpha(form)
  set_form_blend_color(form, nx_int(160))
  init_kapai_trace(form)
  check_tree_condition(form)
  change_form_width(form)
  form.Visible = true
  return 1
end
function on_main_form_close(form)
  nx_execute("tips_game", "hide_tip")
  form.Visible = false
  nx_destroy(form)
  return 1
end
function init_kapai_trace(form)
  local tree_kapai = form.tree_kapai
  if not nx_is_valid(tree_kapai) then
    return
  end
  clear_tree(tree_kapai)
  local root_node = tree_kapai.RootNode
  if not nx_is_valid(root_node) then
    root_node = tree_kapai:CreateRootNode(nx_widestr(""))
  end
  local gui = nx_value("gui")
  local imagelist = gui:CreateImageList()
  imagelist:AddImage("gui\\special\\task\\wuzhuizong.png")
  imagelist:AddImage("gui\\language\\ChineseS\\prestige\\btn_type1_out.png")
  imagelist:AddImage("gui\\language\\ChineseS\\prestige\\btn_type2_out.png")
  imagelist:AddImage("gui\\language\\ChineseS\\prestige\\btn_type3_out.png")
  imagelist:AddImage("gui\\language\\ChineseS\\prestige\\btn_type4_out.png")
  tree_kapai.ItemHeight = 23
  tree_kapai.ImageList = imagelist
  root_node.Mark = nx_int(-1)
  root_node.ImageIndex = 0
  root_node.Font = "font_treeview"
  root_node.ForeColor = "255,255,153,0"
  update_kapai_trace(root_node)
  root_node:ExpandAll()
end
function update_kapai_trace(root_node)
  if not nx_is_valid(root_node) then
    return
  end
  local scene_id = get_world_scene()
  local table_kapai = get_scene_kapai_info(scene_id)
  local kapai_num = table.getn(table_kapai)
  if nx_int(kapai_num) ~= nx_int(nx_int(nx_int(kapai_num) / nx_int(3)) * nx_int(3)) then
    return
  end
  for i = 1, kapai_num, 3 do
    local kapai_name = nx_widestr(table_kapai[i])
    local kapai_type = nx_int(table_kapai[i + 1])
    local kapai_id = nx_int(table_kapai[i + 2])
    add_kapai_node(root_node, kapai_name, kapai_type, kapai_id)
  end
end
function add_kapai_node(root_node, title_text, kapai_type, kapai_id)
  if not nx_is_valid(root_node) then
    return
  end
  local main_node = root_node:CreateNode(nx_widestr(title_text))
  if not nx_is_valid(main_node) then
    main_node = root_node:CreateNode(nx_widestr(title_text))
  end
  local color = get_kapai_color(kapai_type)
  main_node.Mark = nx_int(kapai_id)
  _, _, image_index = get_open_type(kapai_id)
  main_node.ImageIndex = image_index
  main_node.Font = "font_treeview"
  main_node.ForeColor = color
  main_node.NodeImageOffsetX = 0
  main_node.TextOffsetX = 5
  main_node.TextOffsetY = 0
  main_node.NodeBackImage = "gui\\common\\treeview\\tree_2_out.png"
  main_node.NodeFocusImage = "gui\\common\\treeview\\tree_2_out.png"
  main_node.NodeSelectImage = "gui\\common\\treeview\\tree_2_on.png"
  local table_condition_list = get_condition_list(kapai_id, kapai_type)
  local condition_num = table.getn(table_condition_list)
  if nx_int(condition_num) ~= nx_int(nx_int(nx_int(condition_num) / nx_int(2)) * nx_int(2)) then
    return
  end
  for i = 1, condition_num, 2 do
    local condition_desc = nx_widestr(table_condition_list[i])
    local condition_id = nx_int(table_condition_list[i + 1])
    add_sub_kapai_node(main_node, condition_desc, condition_id)
  end
end
function add_sub_kapai_node(main_node, title_text, condition_id)
  if not nx_is_valid(main_node) then
    return
  end
  local sub_node = main_node:CreateNode(nx_widestr(title_text))
  if not nx_is_valid(sub_node) then
    sub_node = main_node:CreateNode(nx_widestr(title_text))
  end
  sub_node.Mark = nx_int(condition_id)
  sub_node.ImageIndex = 0
  sub_node.Font = "font_treeview"
  sub_node.ForeColor = "255,153,255,0"
  sub_node.NodeImageOffsetX = 0
  sub_node.TextOffsetX = 10
  sub_node.TextOffsetY = 0
end
function clear_tree(tree)
  if not nx_is_valid(tree) then
    return
  end
  local root_node = tree.RootNode
  if not nx_is_valid(root_node) then
    return
  end
  local table_main_node = root_node:GetNodeList()
  for i, main_node in pairs(table_main_node) do
    main_node:ClearNode()
  end
  root_node:ClearNode()
end
function get_scene_kapai_info(scene_id, degree_type)
  local table_scene_kapai = {}
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(game_client) or not nx_is_valid(client_player) then
    return table_scene_kapai
  end
  local kapai_manager = nx_value("Kapai")
  if not nx_is_valid(kapai_manager) then
    return table_scene_kapai
  end
  if nx_int(scene_id) <= nx_int(0) then
    return table_scene_kapai
  end
  local row = client_player:GetRecordRows("Origin_Kapai")
  for i = 0, row - 1 do
    local kapai_id = client_player:QueryRecord("Origin_Kapai", i, 0)
    local kapai_type = client_player:QueryRecord("Origin_Kapai", i, 2)
    local is_right_type = true
    if degree_type ~= nil and nx_number(degree_type) ~= nx_number(kapai_type) then
      is_right_type = false
    end
    if check_kapai_scene(kapai_id, scene_id) and is_right_type then
      local kapai_state = client_player:QueryRecord("Origin_Kapai", i, 3)
      local sub_kapai_id = client_player:QueryRecord("Origin_Kapai", i, 1)
      if nx_number(kapai_state) == nx_number(0) then
        table.insert(table_scene_kapai, nx_widestr(gui.TextManager:GetText("sub_prestige_" .. nx_string(sub_kapai_id))) .. nx_widestr(gui.TextManager:GetText(state_0)))
        table.insert(table_scene_kapai, 0)
        table.insert(table_scene_kapai, nx_int(sub_kapai_id))
      elseif nx_number(kapai_state) == nx_number(1) then
        table.insert(table_scene_kapai, nx_widestr(gui.TextManager:GetText("prestige_" .. nx_string(kapai_id))) .. nx_widestr(gui.TextManager:GetText(state_1)))
        table.insert(table_scene_kapai, 1)
        table.insert(table_scene_kapai, nx_int(kapai_id))
      elseif nx_number(kapai_state) == nx_number(2) then
        table.insert(table_scene_kapai, nx_widestr(gui.TextManager:GetText("prestige_" .. nx_string(kapai_id))) .. nx_widestr(gui.TextManager:GetText(state_2)))
        table.insert(table_scene_kapai, 2)
        table.insert(table_scene_kapai, nx_int(kapai_id))
      elseif nx_number(kapai_state) == nx_number(3) then
        table.insert(table_scene_kapai, nx_widestr(gui.TextManager:GetText("sub_prestige_" .. nx_string(sub_kapai_id))) .. nx_widestr(gui.TextManager:GetText(state_3)))
        table.insert(table_scene_kapai, 3)
        table.insert(table_scene_kapai, nx_int(sub_kapai_id))
      elseif nx_number(kapai_state) == nx_number(4) then
        table.insert(table_scene_kapai, nx_widestr(gui.TextManager:GetText("prestige_" .. nx_string(kapai_id))) .. nx_widestr(gui.TextManager:GetText(state_4)))
        table.insert(table_scene_kapai, 4)
        table.insert(table_scene_kapai, nx_int(kapai_id))
      end
    end
  end
  return table_scene_kapai
end
function get_kapai_scene(kapai_id)
  local table_scene_list = {}
  local kapai_manager = nx_value("Kapai")
  if not nx_is_valid(kapai_manager) then
    return table_scene_kapai
  end
  local str_scene_list = kapai_manager:GetKapaiScene(kapai_id)
  table_scene_list = nx_function("ext_split_string", nx_string(str_scene_list), ",")
  return table_scene_list
end
function get_condition_list(kapai_id, kapai_type)
  local table_condition_list = {}
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return table_condition_list
  end
  local kapai_manager = nx_value("Kapai")
  if not nx_is_valid(kapai_manager) then
    return table_condition_list
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return table_condition_list
  end
  local condition_list = {}
  if nx_number(kapai_type) == nx_number(3) or nx_number(kapai_type) == nx_number(4) then
    return table_condition_list
  end
  if nx_number(kapai_type) == nx_number(0) or nx_number(kapai_type) == nx_number(3) then
    condition_list = kapai_manager:GetComConditionList(kapai_id)
  elseif nx_number(kapai_type) == nx_number(1) or nx_number(kapai_type) == nx_number(2) or nx_number(kapai_type) == nx_number(4) then
    condition_list = kapai_manager:GetConditionList(kapai_id)
  end
  for i, condition_id in pairs(condition_list) do
    local condition_decs = gui.TextManager:GetText(condition_manager:GetConditionDesc(nx_int(condition_id)))
    table.insert(table_condition_list, condition_decs)
    table.insert(table_condition_list, nx_int(condition_id))
  end
  return table_condition_list
end
function is_kapai_in_scene_list(scene_id, table_scene_list)
  local scene_num = table.getn(table_scene_list)
  for i = 1, scene_num do
    if nx_int(scene_id) == nx_int(table_scene_list[i]) then
      return true
    end
  end
  return false
end
function check_tree_condition(form)
  local tree_kapai = form.tree_kapai
  if not nx_is_valid(tree_kapai) then
    return
  end
  local root_node = tree_kapai.RootNode
  if not nx_is_valid(root_node) then
    return
  end
  local table_node_kapai_list = root_node:GetNodeList()
  local table_condition = {}
  for i, node in pairs(table_node_kapai_list) do
    local table_node_condition_list = node:GetNodeList()
    for j, node_condition in pairs(table_node_condition_list) do
      local condition_id = node_condition.Mark
      table.insert(table_condition, nx_int(condition_id))
    end
  end
  if table.getn(table_condition) > 0 then
    nx_execute("custom_sender", "custom_kapai_msg", CHECK_CONDITION, unpack(table_condition))
  end
end
function refreash_trace_condition(...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_world_city_kapai_trace", true, false)
  if not nx_is_valid(form) or not form.Visible then
    return
  end
  local tree_kapai = form.tree_kapai
  if not nx_is_valid(tree_kapai) then
    return
  end
  local root_node = tree_kapai.RootNode
  if not nx_is_valid(root_node) then
    return
  end
  local num = table.getn(arg)
  local condition_num = num - 1
  if nx_int(condition_num) ~= nx_int(nx_int(nx_int(condition_num) / nx_int(2)) * nx_int(2)) then
    return
  end
  for i = 2, num, 2 do
    local condition_id = nx_int(arg[i])
    local condition_result = nx_int(arg[i + 1])
    refreash_node_condition(root_node, condition_id, condition_result)
  end
end
function refreash_node_condition(root_node, condition_id, condition_result)
  if not nx_is_valid(root_node) then
    return
  end
  local table_node_kapai_list = root_node:GetNodeList()
  for i, node in pairs(table_node_kapai_list) do
    local table_node_condition_list = node:GetNodeList()
    for j, node_condition in pairs(table_node_condition_list) do
      local node_condition_id = node_condition.Mark
      if nx_int(condition_id) == nx_int(node_condition_id) then
        if nx_int(condition_result) == nx_int(1) then
          node_condition.ForeColor = color_condition_true
        elseif nx_int(condition_result) == nx_int(0) then
          node_condition.ForeColor = color_condition_false
        end
      end
    end
  end
end
function get_kapai_color(kapai_type)
  if nx_number(kapai_type) == nx_number(0) then
    return color_0
  elseif nx_number(kapai_type) == nx_number(1) then
    return color_1
  elseif nx_number(kapai_type) == nx_number(2) then
    return color_2
  elseif nx_number(kapai_type) == nx_number(3) then
    return color_3
  elseif nx_number(kapai_type) == nx_number(4) then
    return color_4
  end
  return color_4
end
function get_world_scene()
  local form = nx_value("form_stage_main\\form_relationship")
  if nx_is_valid(form) and nx_find_custom(form, "cur_scene_id") and nx_int(form.cur_scene_id) > nx_int(0) then
    return nx_int(form.cur_scene_id)
  end
  return nx_int(0)
end
function change_form_size(form)
  local gui = nx_value("gui")
  local width_rest = gui.Width - form.Width
  local height_rest = gui.Height - form.Height
  form.AbsLeft = width_rest - gui.Width / 50 + 18
  form.AbsTop = gui.Height / 10 + 10
end
function change_form_width(form)
  if not nx_is_valid(form) then
    return
  end
  local tree = form.tree_kapai
  local max_size = tree.HScrollBar.Maximum
  tree.Width = nx_number(374) + nx_number(max_size) + 40
  form.gb_kapai_trace.Width = tree.Width + 15
  form.Width = form.gb_kapai_trace.Width
  form.lbl_back2.Width = tree.Width
  local gui = nx_value("gui")
  local width_rest = gui.Width - form.Width
  form.AbsLeft = width_rest - gui.Width / 50 + 18
  form.groupbox_control.AbsLeft = form.AbsLeft + tree.Width - form.groupbox_control.Width
end
function on_btn_minimize_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form.Visible = false
  end
end
function on_btn_unfix_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    init_form_lock_state(form, true)
  end
end
function on_btn_fix_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    init_form_lock_state(form, false)
  end
end
function on_btn_alpha_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_alpha.Visible = not form.groupbox_alpha.Visible
end
function init_form_lock_state(form, state)
  form.Fixed = state
  form.btn_fix.Visible = state
  form.btn_unfix.Visible = not state
end
function init_form_alpha(form)
  form.groupbox_alpha.Visible = false
end
function on_tbar_alpha_drag_leave(control)
  local group_box = control.Parent
  group_box.Visible = false
end
function on_tbar_alpha_value_changed(control)
  local form = control.ParentForm
  local alpha = control.Value
  if nx_int(alpha) >= nx_int(0) and nx_int(alpha) <= nx_int(255) then
    set_form_blend_color(form, alpha)
  end
end
function set_form_blend_color(form, alpha)
  form.BlendColor = nx_string(nx_int(alpha)) .. ",255,255,255"
  form.gb_kapai_trace.BlendColor = nx_string(nx_int(alpha)) .. ",255,255,255"
end
function on_tree_kapai_mouse_in_node(tree, node)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  nx_execute("tips_game", "hide_tip")
  if nx_number(node.Level) ~= nx_number(2) then
    return
  end
  local condition_id = node.Mark
  if nx_number(condition_id) <= nx_number(0) then
    return
  end
  local tips_text = util_text("tips_condition_" .. nx_string(nx_int(condition_id)))
  if nx_string(tips_text) == nx_string("tips_condition_" .. nx_string(nx_int(condition_id))) then
    return
  end
  local mouse_x, mouse_z = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), mouse_x, mouse_z)
end
function on_tree_kapai_mouse_out_node(tree, node)
  nx_execute("tips_game", "hide_tip")
end
function on_tree_kapai_lost_capture(tree)
  nx_execute("tips_game", "hide_tip")
end
function on_tree_kapai_right_click(tree, node)
  local select_node = tree.SelectNode
  if nx_string(select_node) ~= nx_string(node) then
    return
  end
  if nx_number(node.Level) ~= nx_number(1) then
    return
  end
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(gui) then
    return
  end
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "city_kapai_trace_menu_data", "city_kapai_trace_menu_data")
  nx_execute("menu_game", "menu_recompose", menu_game)
  menu_game.KapaiID = nx_int(node.Mark)
  local x, y = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, x, y)
end
function open_form_kapai(kapai_id)
  local kapai_sub, kapai_main, kapai_type = get_open_type(kapai_id)
  if nx_int(kapai_sub) == nx_int(0) and nx_int(kapai_main) == nx_int(0) and nx_int(kapai_type) == nx_int(0) then
    return
  end
  if nx_int(kapai_sub) > nx_int(0) then
    local form_kapai = util_get_form("form_stage_main\\form_origin\\form_kapai", true, false)
    if not nx_is_valid(form_kapai) then
      return
    end
    form_kapai:Show()
    local rbtn = form_kapai.groupbox_tab:Find("rbtn_type_" .. nx_string(kapai_type))
    if nx_is_valid(rbtn) then
      rbtn.Checked = true
    end
    nx_execute("custom_sender", "custom_kapai_msg", CLICK_KAPAI, nx_int(kapai_main))
    return
  end
  if nx_int(kapai_main) > nx_int(0) then
    local form_kapai = util_get_form("form_stage_main\\form_origin\\form_kapai", true, false)
    if not nx_is_valid(form_kapai) then
      return
    end
    form_kapai:Show()
    local rbtn = form_kapai.groupbox_tab:Find("rbtn_type_" .. nx_string(kapai_type))
    if nx_is_valid(rbtn) then
      rbtn.Checked = true
    end
  end
end
function get_open_type(kapai_id)
  local kapai_main = 0
  local kapai_sub = 0
  local kapai_type = 0
  if nx_int(kapai_id) <= nx_int(0) then
    return kapai_sub, kapai_main, kapai_type
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return kapai_sub, kapai_main, kapai_type
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return kapai_sub, kapai_main, kapai_type
  end
  if not client_player:FindRecord("Origin_Kapai") then
    return kapai_sub, kapai_main, kapai_type
  end
  local row_main = client_player:FindRecordRow("Origin_Kapai", 0, nx_int(kapai_id), 0)
  local row_sub = client_player:FindRecordRow("Origin_Kapai", 1, nx_int(kapai_id), 0)
  if nx_int(row_sub) >= nx_int(0) then
    kapai_sub = nx_int(kapai_id)
    kapai_main = client_player:QueryRecord("Origin_Kapai", row_sub, 0)
    kapai_type = client_player:QueryRecord("Origin_Kapai", row_sub, 2)
    return kapai_sub, kapai_main, kapai_type
  end
  if nx_int(row_main) >= nx_int(0) then
    kapai_sub = nx_int(0)
    kapai_main = nx_int(kapai_id)
    kapai_type = client_player:QueryRecord("Origin_Kapai", row_main, 2)
    return kapai_sub, kapai_main, kapai_type
  end
  return kapai_sub, kapai_main, kapai_type
end
function check_kapai_scene(kapai_id, scene_id)
  local table_scene_list = get_kapai_scene(kapai_id)
  if is_kapai_in_scene_list(scene_id, table_scene_list) then
    return true
  end
  return false
end
