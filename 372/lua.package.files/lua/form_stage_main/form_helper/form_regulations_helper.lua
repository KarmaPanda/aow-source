require("util_gui")
local form_map_scene = "form_stage_main\\form_map\\form_map_scene"
local form_main_map = "form_stage_main\\form_main\\form_main_map"
local form_regulations_more_helper = "form_stage_main\\form_helper\\form_regulations_more_helper"
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
local image_type_list = {
  "gui\\special\\lead\\lable_01.png",
  "gui\\special\\lead\\lable_02.png",
  "gui\\special\\lead\\lable_03.png",
  "gui\\special\\lead\\lable_08.png",
  "gui\\special\\lead\\lable_09.png",
  "gui\\special\\lead\\lable_06.png",
  "gui\\special\\lead\\lable_05.png",
  "gui\\special\\lead\\lable_04.png",
  "gui\\special\\lead\\lable_07.png",
  "gui\\special\\lead\\lable_10.png",
  "gui\\special\\lead\\lable_11.png",
  "gui\\special\\lead\\lable_12.png",
  "gui\\special\\lead\\lable_13.png",
  "gui\\special\\lead\\lable_14.png",
  "gui\\special\\lead\\lable_15.png"
}
local function get_custom(ent)
  if not nx_is_valid(ent) then
    log("no \163\186need entity")
    return 1
  end
  local custom_list = nx_custom_list(ent)
  log("custom_list bagin")
  for _, custom in ipairs(custom_list) do
    log("custom = " .. custom)
  end
  log("custom_list end")
end
local function get_property(ent)
  if not nx_is_valid(ent) then
    log("no \163\186need entity")
    return 1
  end
  local prop_list = nx_property_list(ent)
  log("prop_list bagin")
  for _, prop in ipairs(prop_list) do
    log("property = " .. prop)
  end
  log("prop_list end")
end
local get_global_list = function(global_list_name)
  return get_global_arraylist(global_list_name)
end
local function get_new_global_list(global_list_name)
  local global_list = get_global_list(global_list_name)
  global_list:ClearChild()
  return global_list
end
local function set_ent_property(ent, name)
  local create_info = get_global_list("theme_create_info")
  local node = create_info:GetChild(name)
  if not nx_is_valid(node) then
    return
  end
  local custom_list = nx_custom_list(node)
  for i, custom in ipairs(custom_list) do
    local value = nx_property(ent, custom)
    local custom_type = nx_type(value)
    if "number" == nx_string(custom_type) then
      nx_set_property(ent, custom, nx_number(nx_custom(node, custom)))
    elseif "string" == nx_string(custom_type) then
      nx_set_property(ent, custom, nx_custom(node, custom))
    elseif "boolean" == nx_string(custom_type) then
      nx_set_property(ent, custom, nx_boolean(nx_custom(node, custom)))
    end
  end
end
function on_main_form_init(form)
  form.Fixed = false
  nx_execute("form_stage_main\\form_helper\\form_theme_helper", "load_create_info")
end
function get_limit_condition(condition_type, list)
  if 1 == condition_type then
    local drama_id = get_current_drama()
  elseif 2 == condition_type then
    local scene_id = get_current_scene()
  end
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  nx_execute(form_regulations_more_helper, "util_open_more_form", form)
  local tree_info_list = get_global_list("regulations_tree_info")
  load_help_info(form)
  form.tree_ex_main:CreateRootNode(nx_widestr("root"))
  form.tree_ex_main.IsNoDrawRoot = true
  form.tree_ex_main.RootNode.data_source = "root"
  local tree_info_list = get_global_list("regulations_tree_info")
  local node = tree_info_list:GetChild("root")
  show_node_tree(form, "", true)
  check_tree_ex_main_node(form.tree_ex_main.RootNode)
  form.tree_ex_main.RootNode:ExpandAll()
  local freshman_helper_mgr = nx_value("freshman_helper_mgr")
  freshman_helper_mgr:ReloadResource()
  set_control_prop(form)
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.groupbox_aide.Visible = false
  set_default_help(form)
  form.rbtn_life.Checked = true
  form.rbtn_fight.Checked = true
end
function on_main_form_close(form)
  if nx_find_custom(form, "first_flag") then
    local form_main_map = nx_value("form_stage_main\\form_main\\form_main_map")
    local t_x = form_main_map.btn_regulations.AbsLeft
    local t_y = form_main_map.btn_regulations.AbsTop
    local t_w = form_main_map.btn_regulations.Width
    local t_h = form_main_map.btn_regulations.Height
    nx_execute("form_stage_main\\form_helper\\form_move_win", "set_win_info", form.AbsLeft, form.AbsTop, form.Width, form.Height, "", t_x + t_w / 2, t_y + t_h / 2)
  end
  nx_destroy(form.groupbox_more)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.Parent
  if nx_find_custom(form, "first_flag") then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetText("ui_is_first")
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
    dialog:ShowModal()
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      form:Close()
    end
  else
    form:Close()
  end
end
function show_node_tree(form, node_name, is_total)
  if "" == node_name then
    return 1
  end
  local tree_info_list = get_global_list("regulations_tree_info")
  local node = find_node(tree_info_list, node_name)
  if not nx_is_valid(node) then
    return 1
  end
  local gui = nx_value("gui")
  form.tree_ex_main.RootNode:ClearNode()
  form.groupbox_lbl:DeleteAll()
  create_tree_node(gui, form, form.tree_ex_main.RootNode, node, is_total)
  form.tree_ex_main.RootNode:ExpandAll()
  set_tree_info(form, gui, form.tree_ex_main.RootNode)
end
function load_help_info()
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. "ini\\new_helper\\helper_regulations.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local item_list = ini:GetItemValueList("root", "node")
  local tree_info_list = get_new_global_list("regulations_tree_info")
  local condition_mgr = nx_value("ConditionManager")
  local client_player = get_player()
  create_node(condition_mgr, client_player, tree_info_list, ini, "root")
  nx_destroy(ini)
  return true
end
function create_node(condition_mgr, client_player, parent_node, ini, parent_item)
  local item_list = ini:GetItemValueList(parent_item, "node")
  for i, item in ipairs(item_list) do
    local name, type_info = get_coincidence_info(condition_mgr, client_player, item)
    if "" ~= name then
      local node = parent_node:CreateChild(nx_string(name))
      node.parent_node = parent_node
      node.mark_name = node.Name
      if nil == type_info then
        node.type_info = nx_int(0)
      else
        node.type_info = nx_int(type_info)
      end
      create_node(condition_mgr, client_player, node, ini, nx_string(name))
    end
  end
end
function create_tree_node(gui, form, target_node, source_node, is_check)
  local child_list = source_node:GetChildList()
  for i, child in ipairs(child_list) do
    local is_finish = check_node_valid(child.Name)
    local name = gui.TextManager:GetText("ui_" .. child.Name)
    if not is_check or is_finish then
      local node = target_node:CreateNode(name)
      set_ent_property(node, "regulations_tree_node" .. node.Level)
      node.node_name = child.Name
      node.data_source = target_node.data_source .. ";" .. node.node_name
      node.index = i
      node.mark_name = child.mark_name
      node.type_info = child.type_info
      node.is_finish = is_finish
      create_tree_node(gui, form, node, child, is_check)
    end
  end
end
function set_tree_info(form, gui, tree_node)
  local child_list = tree_node:GetNodeList()
  if tree_node.Expand then
    for i, node in ipairs(child_list) do
      local groupbox_lbl = form.groupbox_lbl
      local type_info = node.type_info
      local image = ""
      if nx_int(0) ~= nx_int(type_info) then
        image = image_type_list[nx_number(type_info)]
        if nil ~= image then
          local bg_image = gui:Create("Label")
          bg_image.Name = node.node_name .. "_bg_image"
          bg_image.BackImage = image
          bg_image.AutoSize = true
          bg_image.Left = node.TextOffsetX - bg_image.Width + 5
          bg_image.Top = form.tree_ex_main:GetNodeTop(node) + (node.ItemHeight - bg_image.Height) * 0.5
          groupbox_lbl:Add(bg_image)
        end
      end
      local regulations_new = get_global_list("regulations_new")
      local new_node = regulations_new:GetChild(node.node_name)
      local is_new = ""
      if nx_is_valid(new_node) then
        local new_image = gui:Create("Label")
        new_image.Name = node.node_name .. "_new_image"
        new_image.BackImage = "gui\\special\\tvt\\txt_star.png"
        new_image.AutoSize = true
        new_image.Left = node.TextOffsetX + 80
        new_image.Top = form.tree_ex_main:GetNodeTop(node) + (node.ItemHeight - new_image.Height) * 0.5
        groupbox_lbl:Add(new_image)
      end
      if nx_find_custom(node, "is_finish") and not nx_custom(node, "is_finish") then
        local finish_image = gui:Create("Label")
        finish_image.Name = node.node_name .. "_finish_image"
        finish_image.BackImage = "gui\\language\\ChineseS\\lead\\icon_finish.png"
        finish_image.AutoSize = true
        finish_image.Left = node.TextOffsetX + 120
        finish_image.Top = form.tree_ex_main:GetNodeTop(node) + (node.ItemHeight - finish_image.Height) * 0.5
        groupbox_lbl:Add(finish_image)
      end
      set_tree_info(form, gui, node)
    end
  end
  return 1
end
function on_tree_ex_main_select_changed(tree)
  local select_node = tree.SelectNode
  local form = tree.ParentForm
  if not nx_is_valid(select_node) then
    return 1
  end
  if not nx_find_custom(select_node, "mark_name") then
    return 1
  end
  local data_source = select_node.data_source
  if "" == data_source then
    return 1
  end
  local count = select_node:GetNodeCount()
  if 0 < count then
    return 1
  end
  local str_lst = util_split_string(data_source, ";")
  local node = get_tree_info_node(select_node)
  local btn = get_checked_btn(form)
  local gui = nx_value("gui")
  form.lbl_main_title.Text = gui.TextManager:GetText("ui_" .. btn.DataSource)
  show_or_hide_groupbox_mian(form, false)
  on_last_checked_changed(form, node)
  remove_child_info(form, select_node.node_name)
  if nx_find_custom(select_node, "index") then
    if nx_int(1) == nx_int(select_node.index) then
      form.btn_last.Enabled = false
      form.btn_next.Enabled = true
    elseif nx_int(count) == nx_int(select_node.index) then
      form.btn_last.Enabled = true
      form.btn_next.Enabled = false
    end
  end
  return 1
end
function remove_child_info(form, mark_name)
  local regulations_new = get_global_list("regulations_new")
  regulations_new:RemoveChild(mark_name)
  local groupbox_lbl = form.groupbox_lbl
  local new_image = groupbox_lbl:Find(mark_name .. "_new_image")
  if nx_is_valid(new_image) then
    groupbox_lbl:Remove(new_image)
  end
end
function set_no_open_form_desc(form, freshman_helper_mgr, node_name)
  local desc_info = freshman_helper_mgr:GetFreshmanHelperInfo(node_name, "no_desc")
  local title_info = freshman_helper_mgr:GetFreshmanHelperInfo(node_name, "title")
  local image_info = freshman_helper_mgr:GetFreshmanHelperInfo(node_name, "image")
  local client_player = get_player()
  local gui = nx_value("gui")
  local condition_mgr = nx_value("ConditionManager")
  local image = get_coincidence_info(condition_mgr, client_player, image_info)
  local title = get_coincidence_info(condition_mgr, client_player, title_info)
  local desc = get_coincidence_info(condition_mgr, client_player, desc_info)
  local gui_title = gui.TextManager:GetText(title)
  form.lbl_image.BackImage = image
  form.lbl_no_title.Text = gui_title
  local gui_desc = gui.TextManager:GetText(desc)
  gui.TextManager:GetText(gui_desc)
  form.mltbox_no_desc:Clear()
  form.mltbox_no_desc:AddHtmlText(gui_desc, -1)
end
function set_open_form_desc(form, freshman_helper_mgr, node_name)
  local desc_info = freshman_helper_mgr:GetFreshmanHelperInfo(node_name, "desc")
  local title_info = freshman_helper_mgr:GetFreshmanHelperInfo(node_name, "title")
  local image_info = freshman_helper_mgr:GetFreshmanHelperInfo(node_name, "image")
  local award_info = freshman_helper_mgr:GetFreshmanHelperInfo(node_name, "award")
  local client_player = get_player()
  local condition_mgr = nx_value("ConditionManager")
  local gui = nx_value("gui")
  local desc = get_coincidence_info(condition_mgr, client_player, desc_info)
  local title = get_coincidence_info(condition_mgr, client_player, title_info)
  local award = get_coincidence_info(condition_mgr, client_player, award_info)
  local image = get_coincidence_info(condition_mgr, client_player, image_info)
  local gui_desc = gui.TextManager:GetText(desc)
  local gui_title = gui.TextManager:GetText(title)
  local gui_award = gui.TextManager:GetText(award)
  form.lbl_image.BackImage = image
  form.lbl_title.Text = gui_title
  form.mltbox_desc:Clear()
  form.mltbox_desc:AddHtmlText(gui_desc, -1)
  form.mltbox_award:Clear()
  form.mltbox_award:AddHtmlText(gui_award, -1)
end
function set_content_info(form, content_info, help_type, data_source)
  form.mltbox_npc_info:Clear()
  if "1" == help_type then
    set_control_prop(form, 1)
    find_scene_npc(form, content_info, data_source)
  elseif "2" == help_type then
    set_control_prop(form, 2)
    find_help_node(form, content_info, data_source)
  end
end
function on_btn_link_click(self)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", nx_string(self.content_info), "1")
end
function find_help_node(form, content_info)
  form.btn_link.content_info = content_info
end
function find_scene_npc(form, content_info, data_source)
  local client_player = get_player()
  local find_scene = false
  local find_book = false
  if not nx_is_valid(client_player) then
    return
  end
  local self_x = 10
  local self_y = 10
  local self_z = 10
  local condition_mgr = nx_value("ConditionManager")
  local content_list = util_split_string(content_info, ";")
  local coincidence_list = {}
  form.mltbox_npc_info:Clear()
  for i, info in ipairs(content_list) do
    local info_list = util_split_string(info, ",")
    local count = table.getn(info_list)
    if nx_int(1) == nx_int(count) then
      coincidence_list[table.getn(coincidence_list) + 1][1] = info_list[1]
    elseif nx_int(1) < nx_int(count) then
      local is_ok = condition_mgr:CanSatisfyCondition(client_player, client_player, nx_int(info_list[1]))
      if is_ok then
        local size = nx_int(table.getn(info_list))
        if size == nx_int(1) then
          coincidence_list[table.getn(coincidence_list) + 1] = {}
          coincidence_list[table.getn(coincidence_list)][1] = info_list[2]
        elseif size > nx_int(1) then
          coincidence_list[table.getn(coincidence_list) + 1] = {}
          coincidence_list[table.getn(coincidence_list)][1] = info_list[2]
          coincidence_list[table.getn(coincidence_list)][2] = info_list[3]
        end
      end
    end
  end
  local count = table.getn(coincidence_list)
  local gui = nx_value("gui")
  local distance = 1000000000
  local index = 0
  local cur_scene = get_current_scene()
  if 1 == count then
    form.btn_open_more.Visible = false
    index = 1
  else
    form.btn_open_more.Visible = true
  end
  for i, info_list in ipairs(coincidence_list) do
    local scene_id = info_list[1]
    local npc_config_id = info_list[2]
    if cur_scene == scene_id then
      local x, y, z = find_npc_pos(scene_id, npc_config_id)
      if -10000 ~= x and -10000 ~= y and -10000 ~= z then
        local need_x = x - self_x
        local need_y = y - self_y
        local need_z = z - self_z
        local dis = need_x * need_x + need_y * need_y + need_z * need_z
        if distance > dis then
          distance = dis
          index = i
        end
      end
    end
  end
  if 0 ~= index then
    local info_list = coincidence_list[index]
    local scene_id = info_list[1]
    local npc_config_id = info_list[2]
    local text = gui.TextManager:GetFormatText("ui_" .. data_source .. "_" .. npc_config_id .. "_format_text", nx_string(scene_id), nx_string(npc_config_id)) .. nx_widestr("<br>")
    form.mltbox_npc_info:AddHtmlText(text, nx_int(1))
    nx_set_custom(form.mltbox_npc_info, "item_scene_id_" .. nx_string(1), scene_id)
    nx_set_custom(form.mltbox_npc_info, "item_config_id_" .. nx_string(1), npc_config_id)
  else
    local text = gui.TextManager:GetText("ui_cur_scene_no_npc")
    form.mltbox_npc_info:AddHtmlText(text, nx_int(1))
    nx_set_custom(form.mltbox_npc_info, "item_scene_id_" .. nx_string(1), "nil")
    nx_set_custom(form.mltbox_npc_info, "item_config_id_" .. nx_string(1), "nil")
  end
  form.mltbox_more:Clear()
  local j = 0
  for i, info_list in ipairs(coincidence_list) do
    if i ~= index then
      local scene_id = info_list[1]
      local npc_config_id = info_list[2]
      local text = gui.TextManager:GetFormatText("ui_" .. data_source .. "_" .. npc_config_id .. "_format_text", nx_string(scene_id), nx_string(npc_config_id)) .. nx_widestr("<br>")
      form.mltbox_more:AddHtmlText(text, nx_int(j))
      nx_set_custom(form.mltbox_more, "item_scene_id_" .. nx_string(j + 1), scene_id)
      nx_set_custom(form.mltbox_more, "item_config_id_" .. nx_string(j + 1), npc_config_id)
      j = j + 1
    end
  end
end
function on_mltbox_npc_info_select_item_change(self, newitemindex)
  on_mltbox_select_item_change(self, newitemindex)
  return 0
end
function get_npc_info(scene_id, npc_config_id)
  local x, y, z = find_npc_pos(scene_id, npc_config_id)
  if -10000 == x and -10000 == y and -10000 == z then
    return 1
  end
  local path_finding = nx_value("path_finding")
  if nx_is_valid(path_finding) then
    path_finding:DrawToTarget(scene_id, nx_float(x), nx_float(y), nx_float(z), 1.8, npc_config_id)
    nx_execute(form_map_scene, "auto_show_hide_map_scene")
    nx_execute(form_map_scene, "set_trace_npc_id", npc_config_id, x, y, z, scene_id, false)
  end
end
function get_current_drama()
  local player_obj = get_player()
  if not nx_is_valid(player_obj) then
    return ""
  end
  local DramaRec = "DramaRec"
  if not player_obj:FindRecord(DramaRec) then
    return ""
  end
  if player_obj:GetRecordRows(DramaRec) < 1 then
    return ""
  end
  local drama_name = player_obj:QueryRecord(DramaRec, 0, 0)
  return drama_name
end
function get_current_scene()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return ""
  end
  local resource = client_scene:QueryProp("Resource")
  return nx_string(resource)
end
function find_npc_pos(scene_id, search_npc_id)
  local mgr = nx_value("SceneCreator")
  if nx_is_valid(mgr) then
    local res = mgr:GetNearestNpcPos(scene_id, search_npc_id)
    if res ~= nil and table.getn(res) == 3 then
      return res[1], res[2], res[3]
    end
  end
  return -10000, -10000, -10000
end
function set_control_prop(form, info_type)
  if 1 == info_type then
    form.btn_link.Visible = false
    form.groupbox_more.Visible = false
    form.btn_open_more.Visible = true
  elseif 2 == info_type then
    form.btn_link.Visible = true
    form.btn_open_more.Visible = false
    form.groupbox_more.Visible = false
  else
    form.btn_link.Visible = false
    form.groupbox_more.Visible = false
    form.btn_open_more.Visible = true
  end
end
function get_coincidence_info(condition_mgr, client_player, content_info)
  local content_list = util_split_string(content_info, ";")
  for i, info in ipairs(content_list) do
    local info_list = util_split_string(info, ",")
    local count = table.getn(info_list)
    if nx_int(1) == nx_int(count) then
      return info_list[1]
    elseif nx_int(2) == nx_int(count) then
      local condition = nx_int(info_list[1])
      local is_ok = condition_mgr:CanSatisfyCondition(client_player, client_player, nx_int(condition))
      if is_ok then
        return info_list[2]
      end
    elseif nx_int(3) == nx_int(count) then
      local is_ok = true
      local condition = nx_int(info_list[1])
      is_ok = condition_mgr:CanSatisfyCondition(client_player, client_player, nx_int(condition))
      if is_ok then
        return info_list[2], info_list[3]
      end
    end
  end
  return ""
end
function get_player()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  return client_player
end
function on_change_form_size(form)
  local gui = nx_value("gui")
  local w = gui.Width
  local h = gui.Height
  return true
end
function get_tree_info_node(node)
  local tree_info_list = get_global_list("regulations_tree_info")
  local str_lst = util_split_string(node.data_source, ";")
  local target_node = find_node(tree_info_list, str_lst[table.getn(str_lst)])
  return target_node
end
function on_last_checked_changed(form, node)
  local freshman_helper_mgr = nx_value("freshman_helper_mgr")
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(freshman_helper_mgr) or not nx_is_valid(condition_manager) then
    return 1
  end
  if not nx_is_valid(node) then
    return
  end
  local condition = nx_int(freshman_helper_mgr:GetFreshmanHelperInfo(node.Name, "condition"))
  local client_player = get_player()
  local is_open = condition_manager:CanSatisfyCondition(client_player, client_player, condition)
  form.groupbox_no_open.Visible = not is_open
  form.groupbox_open.Visible = is_open
  local help_type = freshman_helper_mgr:GetFreshmanHelperInfo(node.Name, "type")
  local content_info = freshman_helper_mgr:GetFreshmanHelperInfo(node.Name, "content")
  set_content_info(form, content_info, help_type, node.Name)
  if is_open then
    set_open_form_desc(form, freshman_helper_mgr, node.Name)
  else
    set_no_open_form_desc(form, freshman_helper_mgr, node.Name)
  end
end
function check_node_valid(node_name)
  local index = get_node_indx(node_name)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if nx_int(-1) == nx_int(index) then
    return true
  end
  local str_rec = client_player:QueryProp("FinishFreshmanRecStr")
  local value = nx_function("get_str_rec_flag", str_rec, index - 1)
  return not value
end
function get_node_indx(node_name)
  local ini_doc = nx_create("CFastReadIni")
  ini_doc.FileName = nx_resource_path() .. "share\\Rule\\Freshman.ini"
  if not ini_doc:LoadFromFile() then
    return -1
  end
  local size = ini_doc:GetSectionCount() - 1
  for n_index = 0, size do
    if node_name == ini_doc:GetSectionItemValue(n_index, 0) then
      return nx_number(ini_doc:GetSectionByIndex(n_index))
    end
  end
  nx_destroy(ini_doc)
  return -1
end
function check_tree_ex_main_node(node)
  local child_node_list = node:GetNodeList()
  if table.getn(child_node_list) > 0 then
    local check_res = false
    for _i, child_node in ipairs(child_node_list) do
      check_res = check_tree_ex_main_node(child_node) or check_res
    end
    if not check_res then
      local child_parent = node.ParentNode
      if nx_is_valid(child_parent) then
        child_parent:RemoveNode(node)
      end
    end
    return check_res
  else
    local tmp_node = get_tree_info_node(node)
    if not nx_is_valid(tmp_node) then
      return false
    end
    local child_list = tmp_node:GetChildList()
    for _i, child in ipairs(child_list) do
      if check_node_valid(child.Name) then
        return true
      end
    end
    local node_parent = node.ParentNode
    if nx_is_valid(node_parent) then
      node_parent:RemoveNode(node)
    end
    return false
  end
end
function regulations_select_helper(str_node)
  local form = nx_execute("util_gui", "util_get_form", nx_current(), true, true)
  if not nx_is_valid(form) then
    return false
  end
  form.Visible = true
  form:Show()
  local root_node = form.tree_ex_main.RootNode
  if not nx_is_valid(root_node) then
    return false
  end
  local data_list = util_split_string(str_node, ",")
  local count = table.getn(data_list)
  if count < 2 then
    return false
  end
  local rbtn = nx_null()
  if data_list[2] == form.rbtn_life.DataSource then
    rbtn = form.rbtn_life
  elseif data_list[2] == form.rbtn_fight.DataSource then
    rbtn = form.rbtn_fight
  elseif data_list[2] == form.rbtn_jianghu.DataSource then
    rbtn = form.rbtn_jianghu
  end
  rbtn.Checked = true
  return true
end
function on_rbtn_total_checked_changed(self)
  local form = self.ParentForm
  local btn = get_checked_btn(form)
  local data_source = btn.DataSource
  local form = self.ParentForm
  if self.Checked then
    show_node_tree(form, data_source, false)
  else
    show_node_tree(form, data_source, true)
  end
  show_or_hide_groupbox_mian(form, true)
end
function get_frist_tree_node(node)
  if node:GetNodeCount() > 0 then
    local child_node_list = node:GetNodeList()
    return get_frist_tree_node(child_node_list[1])
  else
    return node
  end
end
function set_default_help(form)
  local root_node = form.tree_ex_main.RootNode
  local node = get_frist_tree_node(root_node)
  form.tree_ex_main.SelectNode = node
  show_or_hide_groupbox_mian(form, true)
end
function on_btn_close_more_click(self)
  local form = self.ParentForm
  form.groupbox_more.Visible = false
  return 0
end
function on_btn_open_more_click(self)
  local form = self.ParentForm
  form.groupbox_more.Visible = true
  return 0
end
function on_rbtn_main_checked_changed(self)
  if not self.Checked then
    return 1
  end
  local data_source = self.DataSource
  local form = self.ParentForm
  show_node_tree(form, data_source, not form.cbtn_total.Checked)
  show_or_hide_groupbox_mian(form, true)
end
function on_mltbox_more_select_item_change(self, newitemindex)
  on_mltbox_select_item_change(self, newitemindex)
  return 0
end
function on_mltbox_select_item_change(self, newitemindex)
  local scene_id = nx_custom(self, "item_scene_id_" .. nx_string(newitemindex + 1))
  local npc_config_id = nx_custom(self, "item_config_id_" .. nx_string(newitemindex + 1))
  if nx_string("nil") == nx_string(scene_id) or nx_string("nil") == nx_string(npc_config_id) then
    return 0
  end
  get_npc_info(scene_id, npc_config_id)
end
function find_node(root_node, find_info, type_info)
  local node_list = {}
  if nil == type_info or "ArrayList" == type_info then
    node_list = root_node:GetChildList()
  elseif "TreeViewEx" == type_info or "TreeView" == type_info then
    node_list = root_node:GetNodeList()
  end
  for i, node in ipairs(node_list) do
    if nx_string(node.mark_name) == nx_string(find_info) then
      return node
    else
      local node_find = find_node(node, find_info, type_info)
      if nx_is_valid(node_find) then
        return node_find
      end
    end
  end
  return nil
end
function on_btn_last_click(btn)
  local form = btn.ParentForm
  local select_node = form.tree_ex_main.SelectNode
  if not nx_is_valid(select_node) then
    return
  end
  set_select_node(form, select_node, false)
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  local select_node = form.tree_ex_main.SelectNode
  if not nx_is_valid(select_node) then
    return
  end
  set_select_node(form, select_node, true)
end
function set_select_node(form, select_node, is_next)
  local info_list = util_split_string(select_node.data_source, ";")
  local pos = table.getn(info_list) - 1
  local node_name = info_list[pos]
  local node = find_node(form.tree_ex_main.RootNode, node_name, "TreeViewEx")
  local index = select_node.index
  if not nx_is_valid(node) then
    return
  end
  form.btn_next.Enabled = true
  form.btn_last.Enabled = true
  local child_list = node:GetNodeList()
  if is_next then
    index = index + 1
    if index > table.getn(child_list) then
      return
    end
  else
    index = index - 1
    if index < 1 then
      return
    end
  end
  if index > table.getn(child_list) - 1 then
    form.btn_next.Enabled = false
  elseif index - 1 < 1 then
    form.btn_last.Enabled = false
  end
  local node_select = child_list[index]
  form.tree_ex_main.SelectNode = node_select
end
function on_btn_back_click(btn)
  local form = btn.ParentForm
  local select_node = form.tree_ex_main.SelectNode
  if not nx_is_valid(select_node) then
    return
  end
  show_or_hide_groupbox_mian(form, true)
  form.tree_ex_main.SelectNode = form.tree_ex_main.RootNode
end
function set_checked_vis(form, vis)
  form.lbl_4.Visible = vis
  form.cbtn_total.Visible = vis
end
function show_or_hide_groupbox_mian(form, vis)
  form.groupbox_aide.Visible = not vis
  form.groupbox_mian.Visible = vis
  form.lbl_main_title.Visible = not vis
  set_checked_vis(form, vis)
end
function on_tree_ex_main_expand_changed(tree)
  local form = tree.ParentForm
  local gui = nx_value("gui")
  form.groupbox_lbl:DeleteAll()
  set_tree_info(form, gui, form.tree_ex_main.RootNode)
end
function get_checked_btn(form)
  if form.rbtn_life.Checked then
    return form.rbtn_life
  elseif form.rbtn_fight.Checked then
    return form.rbtn_fight
  elseif form.rbtn_jianghu.Checked then
    return form.rbtn_jianghu
  end
  return nx_null()
end
function on_rbtn_main_get_capture(btn)
  local gui = nx_value("gui")
  local cursor_x, cursor_y = gui:GetCursorPosition()
  local data_source = btn.DataSource
  local text = gui.TextManager:GetText("ui_" .. data_source)
  nx_execute("tips_game", "show_text_tip", text, cursor_x, cursor_y, 0, btn)
end
function on_rbtn_mian_lost_capture(btn)
  nx_execute("tips_game", "hide_tip", form)
end
