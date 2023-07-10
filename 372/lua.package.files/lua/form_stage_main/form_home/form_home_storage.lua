require("util_functions")
require("util_gui")
require("role_composite")
require("tips_data")
require("util_static_data")
require("form_stage_main\\form_home\\form_home_msg")
local main_list = {
  "HomeCJ",
  "HomeCF",
  "HomeXL",
  "HomeZM",
  "HomeQJ",
  "HomeZS",
  "HomeBJ",
  "HomeCW"
}
local home_main = "form_stage_main\\form_home\\form_home_main"
function tc(msg)
  nx_msgbox(nx_string(msg))
end
function open_form()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
    return
  end
  form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form_init(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("HomeFurnitureRec", form, nx_current(), "on_HomeFurnitureRec_refresh")
  end
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("HomeFurnitureRec", form)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_destory_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local node = form.tree_list.SelectNode
  if not nx_is_valid(node) then
    return
  end
  if nx_string(node.configid) == nx_string("") then
    return
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_home_myhome_13")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "cancel" then
    return
  end
  client_to_server_msg(CLIENT_SUB_DESTORY, nx_string(node.configid), nx_int(1), nx_int(node.bindstatus))
end
function on_btn_bf_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local node = form.tree_list.SelectNode
  if not nx_is_valid(node) then
    return
  end
  if node.configid == "" then
    return
  end
  if node.npcid == "" then
    return
  end
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  HomeManager:SetCurrentGoods(node.npcid, node.configid, nx_int(node.bindstatus), 0)
  form:Close()
end
function on_btn_back_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local node = form.tree_list.SelectNode
  if not nx_is_valid(node) then
    return
  end
  if nx_string(node.configid) == nx_string("") then
    return
  end
  client_to_server_msg(CLIENT_GETBACK_STORAGE, nx_string(node.configid), nx_int(1), nx_int(node.bindstatus))
end
function form_init(form)
  if not nx_is_valid(form) then
    return
  end
  local root = form.tree_list.RootNode
  if nx_is_valid(root) then
    root:ClearNode()
  end
  root = form.tree_list:CreateRootNode(nx_widestr("home_main"))
  form.tree_list.IsNoDrawRoot = true
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\life\\home_furniture_type.ini", true)
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex("MainTitle")
  if index < 0 then
    return
  end
  local item_count = ini:GetSectionItemCount(index)
  for i = 1, item_count do
    local item_value = ini:GetSectionItemValue(index, i - 1)
    local str_list = util_split_string(item_value, ",")
    local node = root:CreateNode(util_text(str_list[1]))
    node.searchid = nx_string(str_list[1])
    node.configid = ""
    node.ExpandCloseOffsetX = -3
    node.ExpandCloseOffsetY = 2
    node.TextOffsetX = 50
    node.TextOffsetY = 5
    node.ItemHeight = 22
    node.NodeBackImage = "gui\\special\\home\\main\\bg_select.png"
    node.NodeFocusImage = "gui\\special\\home\\main\\bg_select_down.png"
    node.NodeSelectImage = "gui\\special\\home\\main\\bg_select.png"
    node.Font = form.tree_list.Font
  end
  root:ExpandAll()
end
function fresh_form(form)
  if not nx_is_valid(form) then
    return
  end
  clear_tree_view(form.tree_list)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not client_player:FindRecord("HomeFurnitureRec") then
    return
  end
  local rows = client_player:GetRecordRows("HomeFurnitureRec")
  if rows <= 0 then
    return
  end
  for i = 0, rows - 1 do
    local configid = nx_string(client_player:QueryRecord("HomeFurnitureRec", i, 0))
    local count = nx_int(client_player:QueryRecord("HomeFurnitureRec", i, 1))
    local bindstatus = nx_int(client_player:QueryRecord("HomeFurnitureRec", i, 2))
    insert_tree_view(form, configid, count, bindstatus)
  end
end
function on_HomeFurnitureRec_refresh(form, recordname, optype, row, clomn)
  if not nx_is_valid(form) then
    return
  end
  if optype ~= "add" and optype ~= "del" and optype ~= "clear" and optype ~= "update" then
    return
  end
  fresh_form(form)
end
function insert_tree_view(form, configid, count, bindstatus)
  if not nx_is_valid(form) then
    return
  end
  if configid == "" or count <= nx_int(0) then
    return
  end
  local script = get_ini_prop("share\\Item\\tool_item.ini", nx_string(configid), "script", "")
  if script == "" then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\life\\home_furniture_type.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(script))
  if sec_index < 0 then
    return
  end
  local item_index = ini:FindSectionItemIndex(sec_index, nx_string(configid))
  if item_index < 0 then
    return
  end
  local title_name = ini:GetSectionItemValue(sec_index, item_index)
  local root = form.tree_list.RootNode
  if not nx_is_valid(root) then
    return
  end
  local table_main_node = root:GetNodeList()
  for i, main_node in pairs(table_main_node) do
    if nx_string(main_node.searchid) == nx_string(title_name) then
      local node_name = util_text(configid) .. nx_widestr("(") .. nx_widestr(count) .. nx_widestr(")")
      local sub_node = main_node:CreateNode(node_name)
      local npcid = get_ini_prop("share\\Item\\home_furniture.ini", nx_string(configid), "npcid", "")
      local modid = get_ini_prop("share\\Item\\home_furniture.ini", nx_string(configid), "mod", "")
      sub_node.searchid = script
      sub_node.configid = configid
      sub_node.bindstatus = bindstatus
      sub_node.npcid = npcid
      sub_node.modid = modid
      sub_node.ForeColor = "255,255,255,255"
      sub_node.ExpandCloseOffsetX = 3
      sub_node.ExpandCloseOffsetY = 2
      sub_node.TextOffsetX = 50
      sub_node.TextOffsetY = 5
      sub_node.ItemHeight = 22
      sub_node.NodeBackImage = "gui\\special\\home\\main\\bg_select.png"
      sub_node.NodeFocusImage = "gui\\special\\home\\main\\bg_select_down.png"
      sub_node.NodeSelectImage = "gui\\special\\home\\main\\bg_select_down.png"
      sub_node.Font = form.tree_list.Font
      if not nx_is_valid(form.tree_list.SelectNode) then
        form.tree_list.SelectNode = sub_node
      end
      break
    end
  end
end
function clear_tree_view(tree_view)
  if not nx_is_valid(tree_view) then
    return
  end
  local root_node = tree_view.RootNode
  if not nx_is_valid(root_node) then
    return
  end
  local table_main_node = root_node:GetNodeList()
  for i, main_node in pairs(table_main_node) do
    main_node:ClearNode()
  end
end
function on_tree_list_select_changed(tree, node)
  local form = tree.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if node.configid == "" then
    return
  end
  if node.modid == "" then
    return
  end
  set_model(form, node.modid, node.npcid)
  set_info(form, node.configid)
end
function set_info(form, configid)
  local gui = nx_value("gui")
  local text_id = "desc_" .. nx_string(configid) .. "_sm"
  form.mltbox_info.HtmlText = gui.TextManager:GetText(text_id)
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
  while btn.MouseDown do
    nx_pause(0)
    if not nx_is_valid(model) then
      break
    end
    local x = model.ScaleX + value
    local y = model.ScaleY + value
    local z = model.ScaleZ + value
    if x < 0.2 or 1.5 < x or y < 0.2 or 1.5 < y or z < 0.2 or 1.5 < z then
      break
    end
    model:SetScale(x, y, z)
  end
end
function set_model(form, mods, configid)
  nx_execute("util_gui", "ui_ClearModel", form.scenebox_mod)
  if not nx_is_valid(form.scenebox_mod.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_mod)
  end
  local is_find = string.find(nx_string(mods), nx_string(".ini"))
  local actor2
  if is_find ~= nil then
    actor2 = form.scenebox_mod.Scene:Create("Actor2")
    if not nx_is_valid(actor2) then
      return
    end
    actor2.AsyncLoad = true
    load_from_ini(actor2, nx_string(mods))
    if not nx_is_valid(actor2) or actor2 == nil then
      return
    end
    actor2:SetScale(0.55, 0.55, 0.55)
    nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_mod, actor2)
  else
    actor2 = nx_execute("util_functions", "util_create_model", nx_string(mods), "", "", "", "", false, form.scenebox_mod.Scene)
    actor2:SetScale(0.55, 0.55, 0.55)
    nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_mod, actor2)
    nx_execute("util_gui", "ui_RotateModel", form.scenebox_mod, math.pi)
  end
end
function set_xmod(form, mods)
  if not nx_is_valid(form) then
    return
  end
  if nx_string(mods) == "" then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if nx_is_valid(form.scenebox_mod.Scene) then
    nx_execute("util_gui", "ui_ClearModel", form.scenebox_mod)
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
