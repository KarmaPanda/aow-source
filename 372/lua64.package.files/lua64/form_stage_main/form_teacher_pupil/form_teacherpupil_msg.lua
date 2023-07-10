require("util_functions")
require("util_gui")
require("form_stage_main\\form_teacher_pupil\\teacherpupil_define")
require("form_stage_main\\form_teacher_pupil\\form_teacherpupil_func")
function open_form()
  local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  Init_tree(form)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
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
function on_rbtn_1_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form.mltbox_info.HtmlText = util_text("ui_shitu_09")
end
function on_rbtn_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form.mltbox_info.HtmlText = util_text("ui_shitu_07")
end
function on_rbtn_3_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form.mltbox_info.HtmlText = util_text("ui_shitu_08")
end
function on_rbtn_4_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form.mltbox_info.HtmlText = util_text("ui_shitu_11")
end
function on_rbtn_5_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form.mltbox_info.HtmlText = util_text("ui_shitu_12")
end
function on_tree_sublist_select_changed(tree, node, old_node)
  local form = tree.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(node) then
    return
  end
  local node_count = node:GetNodeCount()
  if 0 < node_count then
    return
  end
  if not nx_find_custom(node, "subform_id") then
    return
  end
  local subform_id = node.subform_id
  local shitu_flag = get_shitu_flag()
  if nx_int(shitu_flag) == nx_int(Senior_fellow_apprentice) then
    if nx_int(subform_id) == nx_int(SUB_FORM_MY_TEACHER) then
      tree.SelectNode = old_node
      return
    end
  elseif nx_int(shitu_flag) == nx_int(Junior_fellow_apprentice) then
    if nx_int(subform_id) == nx_int(SUB_FORM_MY_PUPIL) then
      tree.SelectNode = old_node
      return
    end
  elseif nx_int(subform_id) == nx_int(SUB_FORM_MY_PUPIL) or nx_int(subform_id) == nx_int(SUB_FORM_MY_TEACHER) then
    tree.SelectNode = old_node
    return
  end
  show_page(form, subform_id)
end
function Init_tree(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ini_doc = nx_execute("util_functions", "get_ini", "ini\\ui\\teacherpupil\\teacherpupil.ini")
  if not nx_is_valid(ini_doc) then
    return
  end
  local NodeCount = 0
  local selectNode
  local map_root = form.tree_sublist:CreateRootNode(nx_widestr(""))
  local count_node1 = ini_doc:GetSectionCount()
  for i = 0, count_node1 - 1 do
    local name_nodeid1 = ini_doc:GetSectionByIndex(i)
    local name_node1 = gui.TextManager:GetFormatText(name_nodeid1)
    if not nx_ws_equal(name_node1, nx_widestr("")) then
      local map_node1 = map_root:CreateNode(name_node1)
      if nx_is_valid(map_node1) then
        local out_png = ini_doc:ReadString(i, "Outpng", "")
        local on_png = ini_doc:ReadString(i, "Onpng", "")
        local down_png = ini_doc:ReadString(i, "Downpng", "")
        map_node1.DrawMode = "FitWindow"
        map_node1.ExpandCloseOffsetX = 0
        map_node1.ExpandCloseOffsetY = 10
        map_node1.TextOffsetX = 10
        map_node1.TextOffsetY = 11
        map_node1.NodeOffsetY = 10
        map_node1.Font = "font_btn"
        map_node1.ForeColor = "255,255,255,255"
        map_node1.NodeBackImage = out_png
        map_node1.NodeFocusImage = on_png
        map_node1.NodeSelectImage = down_png
        map_node1.ItemHeight = 40
        local subform_info = ini_doc:GetItemValueList(i, "r")
        local count_node2 = table.getn(subform_info)
        for j = 1, count_node2 do
          local infos = subform_info[j]
          local info_list = util_split_string(infos, nx_string(","))
          local nCount = table.getn(info_list)
          if 6 <= nCount then
            local name_nodeid2 = info_list[1]
            local name_node2 = gui.TextManager:GetFormatText(info_list[2])
            if nx_ws_equal(name_node2, nx_widestr("")) then
              return
            end
            if is_show_menu(name_nodeid2) then
              local map_node2 = map_node1:CreateNode(name_node2)
              map_node2.subform_id = nx_int(name_nodeid2)
              map_node2.DrawMode = "FitWindow"
              map_node2.ExpandCloseOffsetX = 0
              map_node2.ExpandCloseOffsetY = 0
              map_node2.TextOffsetX = 10
              map_node2.TextOffsetY = 5
              map_node2.NodeOffsetY = 5
              map_node2.Font = "font_main"
              map_node2.ForeColor = "255,197,184,159"
              map_node2.NodeBackImage = nx_string(info_list[4])
              map_node2.NodeFocusImage = nx_string(info_list[5])
              map_node2.NodeSelectImage = nx_string(info_list[6])
              map_node2.ItemHeight = 25
            end
          end
        end
      end
    end
  end
  map_root:ExpandAll()
end
function is_show_menu(subform_id)
  if nx_int(subform_id) ~= nx_int(SUB_FORM_MY_PUPIL) and nx_int(subform_id) ~= nx_int(SUB_FORM_MY_TEACHER) then
    return true
  end
  local shitu_flag = get_shitu_flag()
  if nx_int(shitu_flag) == nx_int(0) then
    return false
  end
  if nx_int(shitu_flag) == nx_int(Senior_fellow_apprentice) and nx_int(subform_id) == nx_int(SUB_FORM_MY_PUPIL) then
    return true
  end
  if nx_int(shitu_flag) == nx_int(Junior_fellow_apprentice) and nx_int(subform_id) == nx_int(SUB_FORM_MY_TEACHER) then
    return true
  end
  return false
end
function open_subform(form, subform_path, subform_id)
  local subform = nx_value(subform_path)
  if not nx_is_valid(subform) then
    subform = nx_execute("util_gui", "util_get_form", subform_path, true, false)
    if not nx_is_valid(subform) then
      return
    end
  elseif subform.Visible == true then
    return
  end
  subform.Left = form.groupbox_msginfo.Left
  subform.Top = form.groupbox_msginfo.Top
  subform.subform_id = subform_id
  local is_load = form:Add(subform)
  if not is_load then
    return
  end
  form.groupbox_1.Visible = false
  subform.Visible = true
  subform:Show()
end
function close_subform(subform_path)
  local subform = nx_value(subform_path)
  if not nx_is_valid(subform) then
    return
  else
    subform.Visible = false
    subform:Close()
  end
end
function cloase_register_form()
  close_subform("form_stage_main\\form_teacher_pupil\\form_teacherpupil_register")
end
function closeteacherpupilform()
  close_subform("form_stage_main\\form_teacher_pupil\\form_teacherpupil_register")
end
function close_teacherpupil_form()
  close_subform("form_stage_main\\form_teacher_pupil\\form_my_teacher_pupil")
end
function close_teacherpupil_shop_form()
  close_subform("form_stage_main\\form_teacher_pupil\\form_teacherpupil_shop")
end
function show_page(form, subform_id)
  if nx_int(SUB_FORM_PUPIL_REGISTER) ~= nx_int(subform_id) or nx_int(SUB_FORM_TEACHER_REGISTER_REGISTER) ~= nx_int(subform_id) then
    cloase_register_form()
  end
  if nx_int(SUB_FORM_MY_TEACHER) ~= nx_int(subform_id) and nx_int(SUB_FORM_MY_PUPIL) ~= nx_int(subform_id) then
    close_teacherpupil_form()
  end
  if nx_int(SUB_FORM_SHOP) ~= nx_int(subform_id) then
    close_teacherpupil_shop_form()
  end
  if nx_int(SUB_FORM_MAIN) == nx_int(subform_id) then
    form.groupbox_1.Visible = true
    form.tree_sublist:BeginUpdate()
    form.tree_sublist.SelectNode = form.tree_sublist.RootNode
    form.tree_sublist.RootNode:ExpandAll()
    form.tree_sublist:EndUpdate()
  elseif nx_int(SUB_FORM_PUPIL_REGISTER) == nx_int(subform_id) or nx_int(SUB_FORM_TEACHER_REGISTER) == nx_int(subform_id) then
    open_subform(form, "form_stage_main\\form_teacher_pupil\\form_teacherpupil_register", subform_id)
  elseif nx_int(SUB_FORM_MY_TEACHER) == nx_int(subform_id) or nx_int(SUB_FORM_MY_PUPIL) == nx_int(subform_id) then
    open_subform(form, "form_stage_main\\form_teacher_pupil\\form_my_teacher_pupil", subform_id)
  elseif nx_int(SUB_FORM_SHOP) == nx_int(subform_id) then
    open_subform(form, "form_stage_main\\form_teacher_pupil\\form_teacherpupil_shop", subform_id)
  end
end
function show_main_page()
  local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  show_page(form, SUB_FORM_MAIN)
end
function show_main_reg_shixiong_page()
  open_form()
  local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  show_page(form, SUB_FORM_TEACHER_REGISTER)
  set_sel_flag(form, SUB_FORM_TEACHER_REGISTER)
end
function set_sel_flag(form, sum_id)
  local rootNode = form.tree_sublist.RootNode
  if not nx_is_valid(form) then
    return
  end
  local node_table = rootNode:GetNodeList()
  local length = table.getn(node_table)
  for i = 1, length do
    local node = node_table[i]
    if nx_is_valid(node) then
      local child_table = node:GetNodeList()
      local num = table.getn(child_table)
      for j = 1, num do
        local child = child_table[j]
        if nx_is_valid(child) and nx_find_custom(child, "subform_id") and nx_int(sum_id) == nx_int(child.subform_id) then
          form.tree_sublist:BeginUpdate()
          form.tree_sublist.SelectNode = child
          form.tree_sublist:EndUpdate()
          return
        end
      end
    end
  end
end
