require("const_define")
require("util_functions")
require("util_gui")
require("tips_data")
require("form_stage_main\\form_origin_new\\new_origin_define")
MAIN_TYPE_BACKGROUND = 1
MAIN_TYPE_DES = 2
CONTROL_SPACE = 20
SUBTYPE_OPEN = 1
SUBTYPE_CLOSE = 2
local maintype_info_list = {}
local origin_search_result_table = {}
local ST_FUNCTION_ORIGIN_DONGHAI = 331
function open_form()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_ORIGIN_DONGHAI) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "sys_neworigin_close")
    return
  end
  local form = util_get_form(FORM_NEW_ORIGIN_MAIN, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  refresh_form(form)
end
function refresh_form(form)
  if form.form_type == FORM_TYPE_SUB then
    nx_execute(FORM_NEW_ORIGIN_ALL, "refresh_form")
  elseif form.form_type == FORM_TYPE_ORIGIN_INFO then
    nx_execute(FORM_NEW_ORIGIN_DESC, "refresh_form")
  elseif form.form_type == FORM_TYPE_ORIGIN_PERSON then
    nx_execute(FORM_NEW_ORIGIN_PERSON, "refresh_form")
  elseif form.form_type == FORM_TYPE_ORIGIN_ACTIVED then
    nx_execute(FORM_NEW_ORIGIN_ACTIVED, "refresh_form")
  end
  show_donghai_exp(form)
end
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  form.sel = nil
  form.main_type = ""
  form.sub_type = ""
  form.b_preview = false
  form.form_type = 0
  form.return_form_type = 0
  form.subform = nil
  form.originform = nil
  init_main_type(form)
  init_search(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
end
function on_btn_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.main_type = btn.main_type
  form.lbl_title.Text = btn.Text
  show_chapters(form, form.main_type)
  adjust_btn_pos(form, btn)
end
function on_btn_person_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  open_subform(form, FORM_TYPE_ORIGIN_PERSON)
end
function on_btn_actived_origin_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  open_subform(form, FORM_TYPE_ORIGIN_ACTIVED)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return
  end
  local info = origin_manager:GetNewMainTypeInfo(btn.main_type)
  form.mltbox_2.HtmlText = nx_widestr(util_text(info[MAIN_TYPE_DES]))
  form.pic_2.Image = nx_string(info[MAIN_TYPE_BACKGROUND])
end
function on_tree_main_mouse_in_node(tree, node)
  local form = tree.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(node, "main_type") then
    return
  end
  local main_type = node.main_type
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return
  end
  local info = origin_manager:GetNewMainTypeInfo(main_type)
  form.mltbox_2.HtmlText = nx_widestr(util_text(info[MAIN_TYPE_DES]))
  form.pic_2.Image = nx_string(info[MAIN_TYPE_BACKGROUND])
end
function on_tree_main_mouse_out_node(tree, node)
  local form = tree.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(node, "main_type") then
    return
  end
end
function on_tree_main_select_double_click(tree, node)
  local form = tree.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(node, "main_type") then
    form.main_type = node.main_type
    form.tree_main:BeginUpdate()
    if node.Expand then
      node.Expand = false
    else
      node.Expand = true
    end
    form.tree_main:EndUpdate()
  end
  if nx_find_custom(node, "sub_type") then
    form.sub_type = node.sub_type
    form.lbl_subtype.Text = node.Text
    open_subform(form, FORM_TYPE_SUB, form.main_type, form.sub_type)
  end
  if is_show_main_form(form) then
    open_subform(form, FORM_TYPE_MAIN, form.main_type, form.sub_type)
  end
end
function on_tree_main_left_click(tree, node)
  on_tree_main_select_double_click(tree, node)
end
function on_tree_main_select_changed(tree, node, old_node)
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
  if not nx_find_custom(node, "sub_type") then
    return
  end
end
function is_show_main_form(form)
  local rootnode = form.tree_main.RootNode
  if not nx_is_valid(rootnode) then
    return false
  end
  local nodelist = rootnode:GetNodeList()
  local count = table.getn(nodelist)
  for i = 1, count do
    if nodelist[i].Expand then
      return false
    end
  end
  return true
end
function init_main_type(form)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return
  end
  local main_type_list = origin_manager:GetNewMainTypeList()
  local count = table.getn(main_type_list)
  if count <= 0 then
    return
  end
  form.tree_main:BeginUpdate()
  local map_root = form.tree_main:CreateRootNode(nx_widestr(""))
  for i = 1, count do
    local main_type = main_type_list[i]
    local name_node1 = nx_widestr(util_text("ui_" .. nx_string(main_type)))
    if not nx_ws_equal(name_node1, nx_widestr("")) then
      local map_node1 = map_root:CreateNode(name_node1)
      if nx_is_valid(map_node1) then
        map_node1.main_type = main_type
        map_node1.DrawMode = "FitWindow"
        map_node1.ExpandCloseOffsetX = 0
        map_node1.ExpandCloseOffsetY = 0
        map_node1.TextOffsetX = 70
        map_node1.TextOffsetY = 14
        map_node1.NodeOffsetY = -8
        map_node1.Font = "font_btn"
        map_node1.ForeColor = "255,255,255,255"
        map_node1.ShadowColor = "10,0,0,0"
        map_node1.NodeBackImage = form.btn.NormalImage
        map_node1.NodeFocusImage = form.btn.FocusImage
        map_node1.NodeSelectImage = form.btn.PushImage
        map_node1.ItemHeight = 47
        map_node1.Expand = false
        if 1 == i then
          form.selbtn = map_node1
        end
        local new_origin_chapter = origin_manager:GetNewSubTypeList(main_type)
        local count_node2 = table.getn(new_origin_chapter)
        for j = 1, count_node2 do
          local sub_type = new_origin_chapter[j]
          local name_node2 = nx_widestr(util_text("ui_SubtypeList_" .. nx_string(sub_type)))
          if sub_type == "" then
            name_node2 = nx_widestr("")
          end
          if not nx_ws_equal(name_node2, nx_widestr("")) then
            local map_node2 = map_node1:CreateNode(name_node2)
            map_node2.main_type = main_type
            map_node2.sub_type = sub_type
            map_node2.DrawMode = "FitWindow"
            map_node2.ExpandCloseOffsetX = 0
            map_node2.ExpandCloseOffsetY = 0
            map_node2.TextOffsetX = 70
            map_node2.TextOffsetY = 10
            map_node2.NodeOffsetY = 3
            map_node2.Font = "font_main"
            map_node2.ForeColor = "255,255,255,255"
            map_node2.ShadowColor = "10,0,0,0"
            map_node2.NodeBackImage = form.btn_sub.NormalImage
            map_node2.NodeFocusImage = form.btn_sub.FocusImage
            map_node2.NodeSelectImage = form.btn_sub.PushImage
            map_node2.ItemHeight = 34
          end
        end
      end
    end
  end
  map_root.Expand = true
  form.tree_main:EndUpdate()
  form.selbtn.NormalImage = form.btn.FocusImage
  local info = origin_manager:GetNewMainTypeInfo("maintype_1")
  form.mltbox_2.HtmlText = nx_widestr(util_text(nx_string(info[MAIN_TYPE_DES])))
  form.pic_2.Image = nx_string(info[MAIN_TYPE_BACKGROUND])
  form.groupbox_3.Visible = false
  form.groupbox_1.Visible = true
end
function open_subform(form, form_type, data, data1)
  local subform = nx_execute("util_gui", "util_get_form", FORM_NEW_ORIGIN_ALL, false, false)
  if nx_is_valid(subform) then
    subform.Visible = false
  end
  subform = nx_execute("util_gui", "util_get_form", FORM_NEW_ORIGIN_DESC, false, false)
  if nx_is_valid(subform) then
    subform.Visible = false
  end
  subform = nx_execute("util_gui", "util_get_form", FORM_NEW_ORIGIN_PERSON, false, false)
  if nx_is_valid(subform) then
    subform.Visible = false
  end
  subform = nx_execute("util_gui", "util_get_form", FORM_NEW_ORIGIN_ACTIVED, false, false)
  if nx_is_valid(subform) then
    subform.Visible = false
  end
  form.form_type = form_type
  form.groupbox_3.Visible = false
  form.groupbox_2.Visible = false
  form.groupbox_origin.Visible = false
  form.lbl_title.Text = nx_widestr(util_text("ui_neworigin_title_18"))
  local isload = false
  if FORM_TYPE_SUB == form_type then
    subform = nx_execute("util_gui", "util_get_form", FORM_NEW_ORIGIN_ALL, true, false)
    if not nx_is_valid(subform) then
      return
    end
    form.subform = subform
    subform.main_type = data
    subform.chapter_id = data1
    isload = form.groupbox_3:Add(subform)
    form.groupbox_1.Visible = true
    form.groupbox_3.Visible = true
    form.lbl_5.Visible = false
    form.lbl_origin.Visible = false
  elseif FORM_TYPE_ORIGIN_INFO == form_type then
    subform = nx_execute("util_gui", "util_get_form", FORM_NEW_ORIGIN_DESC, true, false)
    if not nx_is_valid(subform) then
      return
    end
    form.originform = subform
    subform.origin_id = data
    form.lbl_5.Visible = true
    form.lbl_origin.Visible = true
    form.lbl_origin.Text = nx_widestr(util_text("origin_" .. nx_string(data)))
    isload = form.groupbox_origin:Add(subform)
    form.groupbox_1.Visible = false
    form.groupbox_2.Visible = false
    form.groupbox_origin.Visible = true
  elseif FORM_TYPE_ORIGIN_PERSON == form_type then
    subform = nx_execute("util_gui", "util_get_form", FORM_NEW_ORIGIN_PERSON, true, false)
    if not nx_is_valid(subform) then
      return
    end
    form.lbl_title.Text = nx_widestr(util_text("ui_maintype_personal"))
    isload = form.groupbox_3:Add(subform)
    form.groupbox_3.Visible = true
  elseif FORM_TYPE_ORIGIN_ACTIVED == form_type then
    subform = nx_execute("util_gui", "util_get_form", FORM_NEW_ORIGIN_ACTIVED, true, false)
    if not nx_is_valid(subform) then
      return
    end
    form.lbl_title.Text = nx_widestr(util_text("ui_maintype_personal"))
    isload = form.groupbox_3:Add(subform)
    form.groupbox_1.Visible = true
    form.groupbox_3.Visible = true
  elseif FORM_TYPE_MAIN == form_type then
    form.groupbox_1.Visible = true
    form.groupbox_2.Visible = true
    return
  end
  subform.Left = 0
  subform.Top = 0
  subform.Visible = true
  subform:Show()
  if not isload then
    refresh_form(form)
  end
end
function init_search(form)
  if not nx_is_valid(form) then
    return
  end
  form.ipt_search.Text = nx_widestr(util_text("ui_trade_search_key"))
  form.combobox_search.Visible = true
  form.btn_search.Enabled = false
  return
end
function on_combobox_search_selected(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = form.combobox_search.DropListBox.SelectIndex
  if index < table.getn(origin_search_result_table) then
    form.combobox_search.target_origin_id = origin_search_result_table[index + 1]
    form.btn_search.Enabled = true
  end
  form.ipt_search.Text = form.combobox_search.Text
  form.combobox_search.Text = nx_widestr("")
  return
end
function on_btn_search_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return
  end
  local origin_id = form.combobox_search.target_origin_id
  if not origin_manager:IsActiveOrigin(origin_id) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "sys_neworigin_001")
    return
  end
  open_subform(form, FORM_TYPE_ORIGIN_INFO, origin_id, "")
  return
end
function on_ipt_search_get_focus(self)
  if not nx_is_valid(self) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.hyperfocused = self
  if nx_string(self.Text) == nx_string(util_text("ui_trade_search_key")) then
    self.Text = ""
  end
  return
end
function on_ipt_search_lost_focus(self)
  if not nx_is_valid(self) then
    return
  end
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_string(self.Text) == nx_string("") then
    self.Text = nx_widestr(util_text("ui_trade_search_key"))
  end
  return
end
function on_ipt_search_changed(self)
  if not nx_is_valid(self) then
    return
  end
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local OriginManager = nx_value("OriginManager")
  if not nx_is_valid(OriginManager) then
    return
  end
  if nx_string(self.Text) == nx_string("") then
    form.combobox_search.DroppedDown = false
    form.btn_search.Enabled = false
    return
  end
  if nx_widestr("") == form.combobox_search.Text then
    form.btn_search.Enabled = false
  end
  if nx_string(self.Text) == nx_string(util_text("ui_trade_search_key")) then
    return
  end
  local result_table = OriginManager:SearchOrigin(nx_widestr(self.Text))
  if math.mod(table.getn(result_table), 2) ~= 0 then
    return
  end
  form.combobox_search.DropListBox:ClearString()
  origin_search_result_table = {}
  for i = 1, table.getn(result_table), 2 do
    local origin_id = nx_int(result_table[i])
    local origin_name = nx_widestr(result_table[i + 1])
    form.combobox_search.DropListBox:AddString(origin_name)
    table.insert(origin_search_result_table, origin_id)
  end
  if not form.combobox_search.DroppedDown then
    form.combobox_search.DroppedDown = true
  end
  return
end
function show_origin_tag(form, origin_id)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return
  end
  local chapter_info = origin_manager:GetChapterSectionInfo(origin_id)
  form.lbl_maintype.Text = nx_widestr(util_text("ui_" .. nx_string(chapter_info[1])))
  form.lbl_subtype.Text = nx_widestr(util_text("ui_SubtypeList_" .. nx_string(chapter_info[2])))
  form.lbl_origin.Text = nx_widestr(util_text("origin_" .. nx_string(origin_id)))
  form.lbl_maintype.Visible = true
  form.lbl_subtype.Visible = true
  form.lbl_origin.Visible = true
  form.lbl_4.Visible = true
  form.lbl_5.Visible = true
end
function open_origin_form_by_id(origin_id)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_ORIGIN_DONGHAI) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "sys_neworigin_close")
    return
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return false
  end
  form = util_get_form(FORM_NEW_ORIGIN_MAIN, true, false)
  if not nx_is_valid(form) then
    return
  end
  local chapter_info = origin_manager:GetChapterSectionInfo(origin_id)
  local main_type = chapter_info[1]
  local sub_type = chapter_info[2]
  form.Visible = true
  form:Show()
  form.main_type = main_type
  form.sub_type = sub_type
  show_donghai_exp(form)
  local can_get_origin = nx_execute(FORM_NEW_ORIGIN_DESC, "can_get_origin", player, condition_manager, origin_manager, origin_id)
  if can_get_origin then
    open_subform(form, FORM_TYPE_ORIGIN_INFO, origin_id, "")
  else
    open_subform(form, FORM_TYPE_ORIGIN_ACTIVED)
  end
end
function open_origin_desc_form_by_id(origin_id)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_ORIGIN_DONGHAI) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "sys_neworigin_close")
    return
  end
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return
  end
  form = util_get_form(FORM_NEW_ORIGIN_MAIN, true, false)
  if not nx_is_valid(form) then
    return
  end
  local chapter_info = origin_manager:GetChapterSectionInfo(origin_id)
  local main_type = chapter_info[1]
  local sub_type = chapter_info[2]
  form.Visible = true
  form:Show()
  form.b_preview = true
  form.main_type = main_type
  form.sub_type = sub_type
  show_donghai_exp(form)
  open_subform(form, FORM_TYPE_ORIGIN_INFO, origin_id, "")
end
function show_donghai_exp(form)
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  local donghaiexp = player:QueryProp("DongHaiExperience")
  form.lbl_donghaiexp.Text = nx_widestr(donghaiexp)
end
