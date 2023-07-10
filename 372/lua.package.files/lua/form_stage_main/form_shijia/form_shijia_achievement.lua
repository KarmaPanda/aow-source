require("util_functions")
require("util_gui")
require("form_stage_main\\switch\\switch_define")
local FORM = "form_stage_main\\form_shijia\\form_shijia_achievement"
local shijia_origin = {
  "ui_shijia_ac_dongfang",
  "ui_shijia_ac_nangong",
  "ui_shijia_ac_yanmen",
  "ui_shijia_ac_murong"
}
local shijia_classify = {
  "ui_shijia_ac_dongfang_1",
  "ui_shijia_ac_nangong_11",
  "ui_shijia_ac_yanmen_21",
  "ui_shijia_ac_nangong_31"
}
local shijia_classify_num = {
  1,
  11,
  21,
  31
}
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  form.node = ""
  local btn = form.btn_2
  btn.type = 1
  init_tree(form)
end
function on_main_form_close(form)
  local form_logic = nx_value("form_shijia_achievement")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  nx_destroy(form)
end
function on_btn_jiangli_click(btn)
  local SwitchManager = nx_value("SwitchManager")
  if not nx_is_valid(SwitchManager) then
    return
  end
  local open = SwitchManager:CheckSwitchEnable(ST_FUNCTION_SHIJIA_CHENGJIU)
  if open ~= true then
    return
  end
  if not nx_find_custom(btn, "ID") then
    return
  end
  local id = nx_int(btn.ID)
  btn.Text = ""
  btn.DisableImage = "gui\\special\\shijia\\btn_get.png"
  btn.Enabled = false
  nx_execute("custom_sender", "custom_shijia_achievement_data", nx_int(1), nx_int(id))
end
function init_tree(form)
  if not nx_is_valid(form) then
    return
  end
  form.tree_ex1:BeginUpdate()
  local tree_root = form.tree_ex1:CreateRootNode(nx_widestr(""))
  local count = table.getn(shijia_origin)
  for i = 1, count do
    local main_node_name = nx_widestr(util_text(shijia_origin[i]))
    if not nx_ws_equal(main_node_name, nx_widestr("")) then
      local main_node = tree_root:CreateNode(main_node_name)
      if nx_is_valid(main_node) then
        main_node.main_type = shijia_classify_num[i]
        main_node.DrawMode = "FitWindow"
        main_node.ExpandCloseOffsetX = 0
        main_node.ExpandCloseOffsetY = 0
        main_node.TextOffsetX = 10
        main_node.TextOffsetY = 2
        main_node.NodeOffsetY = 0
        main_node.Font = "font_btn"
        main_node.ForeColor = "255,255,255,255"
        main_node.ShadowColor = "10,0,0,0"
        main_node.NodeBackImage = "gui\\special\\shijia\\btn_t1_out.png"
        main_node.NodeFocusImage = "gui\\special\\shijia\\btn_t1_on.png"
        main_node.NodeSelectImage = "gui\\special\\shijia\\btn_t1_down.png"
        main_node.ItemHeight = 26
        main_node.Expand = false
      end
      if i == 1 then
        form.node = main_node
        form.tree_ex1.SelectNode = main_node
      end
    end
  end
  tree_root.Expand = true
  form.tree_ex1:EndUpdate()
end
function on_tree_ex1_select_changed(tree, node)
  if not nx_is_valid(tree) then
    return
  end
  local form = tree.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(node) then
    return
  end
  form.node = node
  local node_count = node:GetNodeCount()
  if 0 < node_count then
    return
  end
  if nx_find_custom(node, "main_type") then
    nx_execute("custom_sender", "custom_shijia_achievement_data", nx_int(0), nx_int(node.main_type))
  end
end
function on_tree_ex1_left_click(tree, node)
  if not nx_is_valid(tree) then
    return
  end
  if not nx_is_valid(node) then
    return
  end
  on_tree_ex1_select_double_click(tree, node)
end
function on_tree_ex1_select_double_click(tree, node)
  if not nx_is_valid(tree) then
    return
  end
  local form = tree.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(node) then
    return
  end
  local node_num = node:GetNodeCount()
  if 0 < node_num then
    node.Expand = true
  end
end
function on_imagegrid_prize_mousein_grid(grid, index)
  local grid_id = grid.DataSource
  local form_logic = nx_value("form_shijia_achievement")
  if nx_is_valid(form_logic) then
    local form = grid.ParentForm
    if not nx_is_valid(form) then
      return
    end
    local x = grid.AbsLeft
    local y = grid.AbsTop
    local config_id = form_logic:GetPrizeConfig(nx_string(grid_id))
    if config_id ~= "" then
      nx_execute("tips_game", "show_tips_by_config", config_id, x, y, grid.ParentForm)
    end
  end
end
function on_imagegrid_prize_mouseout_grid(grid)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function open_form(...)
  local form = util_get_form(FORM, true)
  if not nx_is_valid(form) then
    return
  end
  local shijia_type = nx_int(arg[1])
  local arraylist = ""
  local count = table.getn(arg)
  for i = 2, count do
    arraylist = arraylist .. nx_string(arg[i])
    if i ~= count then
      arraylist = arraylist .. ";"
    end
  end
  local form_logic = nx_value("form_shijia_achievement")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  form_logic = nx_create("form_shijia_achievement")
  if nx_is_valid(form_logic) then
    nx_set_value("form_shijia_achievement", form_logic)
    form_logic:InitSJUI(form, nx_int(shijia_type), nx_string(arraylist))
  end
end
