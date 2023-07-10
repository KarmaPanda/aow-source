require("form_stage_main\\form_helper\\public_tree_operation")
require("util_gui")
require("util_functions")
function util_open_theme(data)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    util_auto_show_hide_form("form_stage_main\\form_helper\\form_theme_helper")
    form = nx_value(nx_current())
    if not nx_is_valid(form) then
      return
    end
  end
  click_hyperlink(form, data)
end
local HELPER_VOICE_PLAYER_ID = "helper_voice"
local helper_voice_list = {}
local function get_voice_path(id)
  local path = helper_voice_list[id]
  if nil == path then
    return ""
  end
  return path
end
local qastyle_main_node_list = {}
local function is_qastyle_main_node(node_name)
  for i, name in ipairs(qastyle_main_node_list) do
    if node_name == name then
      return true
    end
  end
  return false
end
local view_history_table = {}
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
local get_global_list = function(global_list_name)
  return get_global_arraylist(global_list_name)
end
local function get_new_global_list(global_list_name)
  local global_list = get_global_list(global_list_name)
  global_list:ClearChild()
  return global_list
end
function on_main_form_init(self)
  self.Fixed = false
  load_create_info()
end
local VIS_BTN_COUNT = 4
function on_main_form_open(self)
  self.groupbox_last.index = 0
  view_history_table = {}
  self.tree_search.Visible = false
  self.tree_ex_info.Visible = true
  self.gsbox_qa_info.group_name = ""
  self.gsbox_qa_info.is_scroll_jump = false
  load_help_info(self)
  init_voice_helper()
  local gui = nx_value("gui")
  self.ipt_search_text.Text = nx_widestr(gui.TextManager:GetText("ui_input_search_info"))
end
function on_main_form_close(self)
  local voice_manager = nx_value("voice_manager")
  if nx_is_valid(voice_manager) then
    voice_manager:ClearVoicePlayer(HELPER_VOICE_PLAYER_ID)
  end
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.Parent
  form:Close()
end
function set_ent_property(ent, name)
  local create_info = get_global_list("theme_create_info")
  local node = create_info:GetChild(name)
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
function create_main_rbtn(form)
  local child_control_list = form.groupbox_main:GetChildControlList()
  local size = table.getn(child_control_list)
  if 8 < size then
    return nx_null()
  end
  local gui = nx_value("gui")
  local rbtn = gui:Create("RadioButton")
  local label = gui:Create("Label")
  rbtn.Name = "rbtn_main_" .. nx_string(size)
  set_ent_property(rbtn, "main_radio_button")
  nx_bind_script(rbtn, nx_current())
  nx_callback(rbtn, "on_checked_changed", "on_rbtn_main_checked_changed")
  form.groupbox_main:Add(rbtn)
  form.groupbox_main:Add(label)
  rbtn.Left = 80 * size
  rbtn.Width = 80
  label.Left = 80 * size
  label.Width = rbtn.Width - 3
  return rbtn, label
end
function create_last_rbtn(form)
  local gui = nx_value("gui")
  local rbtn = gui:Create("RadioButton")
  local child_control_list = form.groupbox_last:GetChildControlList()
  local size = table.getn(child_control_list)
  rbtn.Name = "rbtn_last_" .. nx_string(size)
  set_ent_property(rbtn, "last_radio_button")
  nx_bind_script(rbtn, nx_current())
  nx_callback(rbtn, "on_checked_changed", "on_rbtn_last_checked_changed")
  form.groupbox_last:Add(rbtn)
  rbtn.Left = 105 * size
  return rbtn
end
function load_create_info(ini_name)
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. "ini\\new_helper\\theme_info.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local create_info_list = get_new_global_list("theme_create_info")
  local info_list = ini:GetSectionList()
  for i, info in ipairs(info_list) do
    local node = create_info_list:CreateChild(info)
    local prop_list = ini:GetItemList(info)
    for j, prop in ipairs(prop_list) do
      local value = ini:ReadString(info, prop, "")
      nx_set_custom(node, prop, value)
    end
  end
  nx_destroy(ini)
end
function load_help_info(form)
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. "ini\\new_helper\\helper.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  qastyle_main_node_list = ini:GetItemValueList("qastyle", "node")
  local item_list = ini:GetItemValueList("root", "node")
  local w = 80
  for i, item in ipairs(item_list) do
    local rbtn, label = create_main_rbtn(form)
    if nx_is_valid(rbtn) and nx_is_valid(label) then
      label.Left = w * (i - 1) + 3
      label.Top = 6
      label.Text = nx_widestr("@ui_" .. item)
      label.Transparent = true
      label.TestTrans = true
      label.LblLimitWidth = true
      label.ForeColor = "255,255,255,255"
      rbtn.Left = w * (i - 1)
      rbtn.HintText = nx_widestr("@ui_" .. item)
      rbtn.node_name = item
    end
  end
  local tree_info_list = get_new_global_list("tree_info")
  create_node(tree_info_list, ini, "root")
  nx_destroy(ini)
  form.tree_ex_info:CreateRootNode(nx_widestr("root"))
  form.tree_ex_info.IsNoDrawRoot = true
  local rbtn = form.groupbox_main:Find("rbtn_main_0")
  if nx_is_valid(rbtn) then
    rbtn.Checked = true
  end
  return true
end
function create_node(parent_node, ini, parent_item)
  local item_list = ini:GetItemValueList(parent_item, "node")
  for i, item in ipairs(item_list) do
    local node = parent_node:CreateChild(item)
    create_node(node, ini, item)
  end
end
function create_tree_node(gui, form, target_node, source_node, show_last)
  show_last = show_last or is_qastyle_main_node(source_node.Name)
  local child_list = source_node:GetChildList()
  for i, child in ipairs(child_list) do
    if show_last or child:GetChildCount() > 0 then
      local name = gui.TextManager:GetText("ui_" .. child.Name)
      local tips
      if nx_ws_length(name) > 20 then
        tips = name
        name = nx_function("ext_ws_substr", name, 0, 19) .. nx_widestr("...")
      end
      local node = target_node:CreateNode(nx_widestr(name))
      node.node_name = child.Name
      node.data_source = target_node.data_source .. ";" .. source_node.Name
      node.TextOffsetX = (node.Level + 1) * 10 + 10
      if nil ~= tips then
        node.tips = tips
      end
      if node.Level == 1 then
        set_ent_property(node, "tree_node")
      elseif node.Level > 1 then
        set_ent_property(node, "last_tree_node")
      end
      create_tree_node(gui, form, node, child, show_last)
    end
  end
end
function on_rbtn_main_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.tree_search.Visible = false
    form.tree_ex_info.Visible = true
    refresh_tree(form, form.tree_ex_info, rbtn.node_name)
  end
end
function on_rbtn_last_checked_changed(rbtn)
  if rbtn.Checked then
    local gui = nx_value("gui")
    local html_info = gui.TextManager:GetText("desc_" .. rbtn.data_source)
    local form = rbtn.ParentForm
    form.mltbox_info:Clear()
    form.mltbox_info:AddHtmlText(nx_widestr(html_info), -1)
    local select_node = form.tree_ex_info.SelectNode
    if not nx_is_valid(select_node) then
      return 1
    end
    local str_lst = util_split_string(select_node.data_source, ";")
    local size = table.getn(str_lst)
    local text = nx_widestr("")
    for i = 3, size do
      text = text .. nx_widestr(gui.TextManager:GetText("ui_" .. str_lst[i])) .. nx_widestr(">")
    end
    text = text .. nx_widestr(gui.TextManager:GetText("ui_" .. select_node.node_name))
    form.lbl_littletitle.Text = text
    local history_info = select_node.data_source .. ";" .. select_node.node_name .. ";" .. rbtn.data_source
    history_info = string.gsub(history_info, "root", string.sub(nx_string(rbtn.Text), 2))
    add_view_history(form, history_info)
  end
end
function get_tree_info_node(node)
  local tree_info_list = get_global_list("tree_info")
  local str_lst = util_split_string(node.data_source, ";")
  local target_node = tree_info_list
  local size = table.getn(str_lst)
  for i = size - 1, size do
    if not nx_is_valid(target_node) then
      return nx_null()
    end
    target_node = target_node:GetChild(str_lst[i])
  end
  return target_node
end
function on_tree_ex_info_select_changed(tree)
  local select_node = tree.SelectNode
  if not nx_is_valid(select_node) then
    return 1
  end
  if set_default_node(tree, select_node) then
    return 1
  end
  local target_node = get_tree_info_node(select_node)
  if not nx_is_valid(target_node) then
    return 1
  end
  local form = tree.ParentForm
  local node = target_node:GetChild(select_node.node_name)
  if not nx_is_valid(node) then
    return 1
  end
  if node:GetChildCount() > 0 then
    show_hide_genstyle_ctrl(form, true)
    local child_list = node:GetChildList()
    form.groupbox_last:DeleteAll()
    form.groupbox_last.index = 0
    for i, child in ipairs(child_list) do
      if 0 == child:GetChildCount() then
        local rbtn = create_last_rbtn(form)
        if nx_is_valid(rbtn) then
          rbtn.data_source = child.Name
          rbtn.Text = nx_widestr("@ui_" .. child.Name)
        end
      end
    end
    local rbtn = form.groupbox_last:Find("rbtn_last_0")
    if nx_is_valid(rbtn) then
      rbtn.Checked = true
    end
  else
    show_hide_qastyle_ctrl(form, true)
    local gbox_qa = form.gsbox_qa_info:Find("gbox_qa_" .. select_node.node_name)
    if nx_is_valid(gbox_qa) then
      local cbtn_qa = gbox_qa:Find("cbtn_qa_" .. select_node.node_name)
      if nx_is_valid(cbtn_qa) and cbtn_qa.Checked then
        return
      end
    end
    local parent_node = select_node.ParentNode
    if not nx_is_valid(parent_node) then
      return
    end
    if form.gsbox_qa_info.group_name ~= parent_node.node_name then
      form.lbl_littletitle.Text = nx_widestr("@ui_" .. parent_node.node_name)
      form.gsbox_qa_info:DeleteAll()
      for i, node in ipairs(parent_node:GetNodeList()) do
        show_qa_question(form.gsbox_qa_info, node.node_name)
      end
      refresh_gsbox_qa_info(form.gsbox_qa_info)
      form.gsbox_qa_info.group_name = parent_node.node_name
    end
    local gbox_qa = form.gsbox_qa_info:Find("gbox_qa_" .. select_node.node_name)
    if nx_is_valid(gbox_qa) then
      local cbtn_qa = gbox_qa:Find("cbtn_qa_" .. select_node.node_name)
      if nx_is_valid(cbtn_qa) then
        form.gsbox_qa_info.is_scroll_jump = true
        cbtn_qa.Checked = true
      end
    end
  end
end
function on_mltbox_info_click_hyperlink(self, index, data)
  local form = self.ParentForm
  data = nx_string(data)
  if nx_is_valid(form) then
    click_hyperlink(form, data)
  end
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  set_lats_btn_pos(form, -1)
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  set_lats_btn_pos(form, 1)
end
function set_lats_btn_pos(form, offset)
  local child_control_list = form.groupbox_last:GetChildControlList()
  local index = form.groupbox_last.index + offset
  local count = table.getn(child_control_list)
  local size = count - VIS_BTN_COUNT
  if size < 1 or size < math.abs(index) or 0 < index then
    return 1
  end
  form.groupbox_last.index = index
  local offset_x = index * 105
  for i, rbtn in ipairs(child_control_list) do
    rbtn.Left = offset_x + (i - 1) * 105
  end
end
function game_test()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local html_info = gui.TextManager:GetText("desc_shaolinng_01")
  form.mltbox_info:Clear()
  form.mltbox_info:AddHtmlText(nx_widestr(html_info), -1)
end
function set_checked_btn(groupbox, text)
  if not nx_is_valid(groupbox) then
    return
  end
  local rbtn_list = groupbox:GetChildControlList()
  if text ~= nil then
    for __i, rbtn in ipairs(rbtn_list) do
      local rbtn_txt = nx_string(rbtn.Text)
      if text == string.sub(rbtn_txt, 5, -1) then
        rbtn.Checked = true
        return __i
      end
    end
  else
    local rbtn_list = groupbox:GetChildControlList()
    local rbtn = rbtn_list[1]
    if nx_is_valid(rbtn) then
      rbtn.Checked = true
    end
  end
  return 1
end
function set_default_node(tree_view, cur_sel_node)
  if not nx_is_valid(tree_view) then
    return false
  end
  local change_node = false
  if cur_sel_node == nil or not nx_is_valid(cur_sel_node) then
    cur_sel_node = tree_view.RootNode
  end
  while cur_sel_node:GetNodeCount() > 0 do
    local node_list = cur_sel_node:GetNodeList()
    cur_sel_node = node_list[1]
    change_node = true
  end
  tree_view.SelectNode = cur_sel_node
  return change_node
end
function on_btn_back_click(self)
  local form = self.ParentForm
  local node_name = get_main_select_btn(form)
  form.tree_search.Visible = false
  form.tree_ex_info.Visible = true
  refresh_tree(form, form.tree_ex_info, node_name)
end
function get_main_select_btn(form)
  local child_control_list = form.groupbox_main:GetChildControlList()
  for i, btn in ipairs(child_control_list) do
    if nx_name(btn) == "RadioButton" and btn.Checked then
      return btn.node_name
    end
  end
  return ""
end
function refresh_tree(form, tree_view, name)
  local tree_info_list = get_global_list("tree_info")
  local node = nx_null()
  if nil == name then
    node = tree_info_list
  else
    node = tree_info_list:GetChild(name)
  end
  tree_view.RootNode:ClearNode()
  form.groupbox_last:DeleteAll()
  form.groupbox_last.index = 0
  tree_view.RootNode.data_source = "root"
  if nx_is_valid(node) then
    local gui = nx_value("gui")
    create_tree_node(gui, form, tree_view.RootNode, node)
  end
  form.gsbox_qa_info:DeleteAll()
  form.gsbox_qa_info.group_name = ""
  form.gsbox_qa_info.is_scroll_jump = false
  local voice_player = get_voice_player()
  if nx_is_valid(voice_player) then
    voice_player:Stop()
  end
  tree_view.RootNode:ExpandAll()
  set_default_node(tree_view, nil)
  set_checked_btn(form.groupbox_last)
end
function on_btn_search_click(self)
  local form = self.ParentForm
  local find_str = nx_string(form.ipt_search_text.Text)
  if "" ~= find_str then
    form.tree_search.Visible = true
    form.tree_ex_info.Visible = false
    form.gsbox_qa_info.group_name = ""
    get_search_filter_tree(form, find_str)
    form.mltbox_info:Clear()
    form.lbl_littletitle.Text = nx_widestr("")
    form.groupbox_last:DeleteAll()
  else
    form.tree_search.Visible = false
    form.tree_ex_info.Visible = true
    on_btn_back_click(self)
  end
end
function get_search_filter_tree(form, find_str)
  local child_control_list = form.groupbox_main:GetChildControlList()
  if not nx_is_valid(form.tree_search.RootNode) then
    form.tree_search:CreateRootNode(nx_widestr("root"))
    form.tree_search.IsNoDrawRoot = true
  end
  refresh_tree(form, form.tree_search)
  set_filter(form.tree_search.RootNode, find_str)
end
function on_ipt_search_text_enter(edit)
  on_btn_search_click(edit)
end
function on_mltbox_news_click_hyperlink(self, index, data)
  data = nx_string(data)
  local form = self.ParentForm
  if nx_is_valid(form) then
    click_hyperlink(form, data)
  end
end
function click_hyperlink(form, data)
  local data_list = util_split_string(nx_string(data), ",")
  local main_rbtn_txt = data_list[1]
  local data_cnt = table.getn(data_list)
  set_checked_btn(form.groupbox_main, main_rbtn_txt)
  local root_node = form.tree_ex_info.RootNode
  if not nx_is_valid(root_node) then
    return
  end
  if data_cnt == 4 then
    data_cnt = data_cnt - 1
  end
  for i = 2, data_cnt do
    local tree_node_txt = data_list[i]
    local node_list = root_node:GetNodeList()
    for __nu, sub_node in pairs(node_list) do
      if nx_find_custom(sub_node, "node_name") and sub_node.node_name == tree_node_txt then
        root_node = sub_node
        break
      end
    end
  end
  set_default_node(form.tree_ex_info, root_node)
  if table.getn(data_list) == 4 then
    local last_rbtn_txt = nx_string(data_list[table.getn(data_list)])
    local pos = set_checked_btn(form.groupbox_last, last_rbtn_txt)
    set_lats_btn_pos(form, VIS_BTN_COUNT - pos)
  else
    local btn_list = form.groupbox_last:GetChildControlList()
    if table.getn(btn_list) > 0 then
      btn_list[1].Checked = true
    end
  end
end
function add_view_history(form, str_info)
  for n_index = 1, table.getn(view_history_table) do
    if view_history_table[n_index] == str_info then
      table.remove(view_history_table, n_index)
      break
    end
  end
  if table.getn(view_history_table) > 4 then
    table.remove(view_history_table, 1)
  end
  table.insert(view_history_table, str_info)
  local gui = nx_value("gui")
  local text_manager = gui.TextManager
  local history_hyperlink = ""
  local history_hyperlink_item = ""
  local hyperlink_name = ""
  local n_pos = 0
  for n_index = 1, table.getn(view_history_table) do
    history_hyperlink_item = view_history_table[n_index]
    n_pos = string.find(history_hyperlink_item, ";")
    hyperlink_name = text_manager:GetText(string.sub(history_hyperlink_item, 1, n_pos - 1))
    history_hyperlink_item = string.sub(history_hyperlink_item, n_pos + 1)
    history_hyperlink_item = string.gsub(history_hyperlink_item, ";", ",")
    history_hyperlink_item = nx_widestr("<a href=\"") .. nx_widestr(history_hyperlink_item) .. nx_widestr("\" style=\"HLStype3\">") .. nx_widestr(hyperlink_name) .. nx_widestr("</a>    ")
    history_hyperlink = nx_widestr(history_hyperlink) .. nx_widestr(history_hyperlink_item)
  end
  form.mltbox_view_history:Clear()
  form.mltbox_view_history:AddHtmlText(nx_widestr(history_hyperlink), -1)
end
function on_mltbox_view_history_click_hyperlink(self, index, data)
  data = nx_string(data)
  local form = self.ParentForm
  if nx_is_valid(form) then
    click_hyperlink(form, data)
  end
end
function on_ipt_search_text_lost_focus(self)
  if nx_ws_length(self.Text) == 0 then
    local gui = nx_value("gui")
    self.Text = nx_widestr(gui.TextManager:GetText("ui_input_search_info"))
  end
end
function show_hide_genstyle_ctrl(form, is_show)
  if not nx_is_valid(form) then
    return
  end
  if is_show then
    show_hide_qastyle_ctrl(form, false)
    form.lbl_littletitle.Top = 74
    form.lbl_littletitle2.Top = 84
  end
  form.groupbox_last.Visible = is_show
  form.lbl_bg_last.Visible = is_show
  form.btn_left.Visible = is_show
  form.btn_right.Visible = is_show
  form.mltbox_info.Visible = is_show
end
function show_hide_qastyle_ctrl(form, is_show)
  if not nx_is_valid(form) then
    return
  end
  if is_show then
    show_hide_genstyle_ctrl(form, false)
    form.lbl_littletitle.Top = 18
    form.lbl_littletitle2.Top = 28
  end
  form.gsbox_qa_info.Visible = is_show
  form.lbl_qa_mask.Visible = is_show
end
function on_cbtn_qa_changed(cbtn)
  local form = cbtn.ParentForm
  local scroll_bar = form.gsbox_qa_info.VScrollBar
  local old_pos = nx_number(0)
  if nx_is_valid(scroll_bar) and 0 ~= scroll_bar.Maximum then
    old_pos = nx_number(scroll_bar.Value) / nx_number(scroll_bar.Maximum)
  end
  show_hide_qa_answer(form.gsbox_qa_info, cbtn.DataSource, cbtn.Checked)
  if cbtn.Checked then
    for i, ctrl in ipairs(form.gsbox_qa_info:GetChildControlList()) do
      if nx_name(ctrl) == "GroupBox" then
        local cbtn_qa = ctrl:Find("cbtn_qa_" .. ctrl.DataSource)
        if nx_is_valid(cbtn_qa) and not nx_id_equal(cbtn_qa, cbtn) and cbtn_qa.Checked then
          cbtn_qa.Enabled = true
          cbtn_qa.Checked = false
        end
      end
    end
    cbtn.Enabled = false
    if nx_is_valid(scroll_bar) and 0 ~= scroll_bar.Maximum then
      if form.gsbox_qa_info.is_scroll_jump then
        local gbox_qa = cbtn.Parent
        if nx_is_valid(gbox_qa) then
          local distance = nx_number(form.gsbox_qa_info:GetContentHeight() - form.gsbox_qa_info.Height)
          if 0 < distance then
            local pos = nx_number(gbox_qa.Top - form.lbl_qa_mask.Height + 1) / distance
            scroll_bar.Value = nx_int(pos * (nx_number(scroll_bar.Maximum) - 10) + 0.5)
          end
        end
      else
        scroll_bar.Value = nx_int(old_pos * nx_number(scroll_bar.Maximum) + 0.5)
      end
    end
    updete_selected_node(form.tree_ex_info, cbtn.DataSource)
    updete_selected_node(form.tree_search, cbtn.DataSource)
    local voice_player = get_voice_player()
    if nx_is_valid(voice_player) then
      stop_other_voice_player()
      voice_player:Play(get_voice_path(cbtn.DataSource))
    end
    form.gsbox_qa_info.is_scroll_jump = false
  end
end
function show_qa_question(gsbox_qa_info, node_name)
  local form = gsbox_qa_info.ParentForm
  if not nx_is_valid(gsbox_qa_info) then
    return
  end
  local gui = nx_value("gui")
  local gbox_qa = gui:Create("GroupBox")
  if not nx_is_valid(gbox_qa) then
    return
  end
  set_ent_property(gbox_qa, "gbox_qa")
  gbox_qa.Name = "gbox_qa_" .. node_name
  gbox_qa.DataSource = node_name
  local cbtn_qa = gui:Create("CheckButton")
  if nx_is_valid(cbtn_qa) then
    set_ent_property(cbtn_qa, "cbtn_qa")
    cbtn_qa.Name = "cbtn_qa_" .. node_name
    cbtn_qa.DataSource = node_name
    nx_bind_script(cbtn_qa, nx_current())
    nx_callback(cbtn_qa, "on_checked_changed", "on_cbtn_qa_changed")
    gbox_qa:Add(cbtn_qa)
  end
  local lbl_question = gui:Create("Label")
  if nx_is_valid(lbl_question) then
    set_ent_property(lbl_question, "lbl_question")
    lbl_question.Name = "lbl_question_" .. node_name
    lbl_question.Text = nx_widestr("@ui_" .. node_name)
    lbl_question.DataSource = node_name
    gbox_qa:Add(lbl_question)
  end
  if not nx_find_custom(gsbox_qa_info, "mtbox_answer") or not nx_is_valid(gsbox_qa_info.mtbox_answer) then
    local mtbox_answer = gui:Create("MultiTextBox")
    if nx_is_valid(mtbox_answer) then
      set_ent_property(mtbox_answer, "mtbox_answer")
      mtbox_answer.Name = "mtbox_answer"
      gbox_qa:Add(mtbox_answer)
      gsbox_qa_info.mtbox_answer = mtbox_answer
    end
  end
  gbox_qa.Height = lbl_question.Top + lbl_question.Height
  gbox_qa.Width = lbl_question.Left + lbl_question.Width + 5
  gsbox_qa_info:Add(gbox_qa)
end
function show_hide_qa_answer(gsbox_qa_info, node_name, is_show)
  local form = gsbox_qa_info.ParentForm
  if not nx_is_valid(gsbox_qa_info) then
    return
  end
  local gui = nx_value("gui")
  local gbox_qa = gsbox_qa_info:Find("gbox_qa_" .. node_name)
  if not nx_is_valid(gbox_qa) then
    return
  end
  if is_show then
    if nx_find_custom(gsbox_qa_info, "mtbox_answer") and nx_is_valid(gsbox_qa_info.mtbox_answer) then
      local mtbox_answer = gsbox_qa_info.mtbox_answer
      if nx_is_valid(mtbox_answer.Parent) then
        mtbox_answer.Parent:Remove(mtbox_answer)
      end
      mtbox_answer:Clear()
      mtbox_answer.ViewRect = "0,0," .. nx_string(mtbox_answer.Width) .. ",0"
      mtbox_answer:AddHtmlText(nx_widestr(gui.TextManager:GetText("desc_" .. node_name)), -1)
      mtbox_answer.Height = mtbox_answer:GetContentHeight()
      mtbox_answer.ViewRect = "0,0," .. nx_string(mtbox_answer.Width) .. "," .. nx_string(mtbox_answer.Height)
      mtbox_answer.DataSource = node_name
      gbox_qa:Add(mtbox_answer)
      gbox_qa.Height = mtbox_answer.Top + mtbox_answer.Height
      gbox_qa.Width = mtbox_answer.Left + mtbox_answer.Width + 5
      refresh_gsbox_qa_info(gsbox_qa_info)
    end
  else
    local lbl_question = gbox_qa:Find("lbl_question_" .. node_name)
    if nx_is_valid(lbl_question) then
      gbox_qa.Height = lbl_question.Top + lbl_question.Height
      gbox_qa.Width = lbl_question.Left + lbl_question.Width + 5
      refresh_gsbox_qa_info(gsbox_qa_info)
    end
  end
  return gbox_qa
end
function updete_selected_node(tree, node_name)
  if tree.Visible and tree.SelectNode.node_name ~= node_name then
    local parent_node = tree.SelectNode.ParentNode
    if not nx_is_valid(parent_node) then
      return
    end
    for i, node in ipairs(parent_node:GetNodeList()) do
      if node.node_name == node_name then
        tree.SelectNode = node
      end
    end
  end
end
function init_voice_helper()
  load_voice_helper()
  get_voice_player()
end
function load_voice_helper()
  helper_voice_list = {}
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return false
  end
  ini.FileName = nx_resource_path() .. "ini\\new_helper\\helper_voice.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local key_list = ini:GetItemList("voice")
  for i, key in ipairs(key_list) do
    local val = ini:ReadString("voice", key, "")
    helper_voice_list[key] = val
  end
  nx_destroy(ini)
end
function refresh_gsbox_qa_info(gsbox_qa_info)
  local form = gsbox_qa_info.ParentForm
  local gbox_qa_list = {}
  for i, ctrl in ipairs(gsbox_qa_info:GetChildControlList()) do
    if nx_name(ctrl) == "GroupBox" then
      table.insert(gbox_qa_list, ctrl)
      gsbox_qa_info:Remove(ctrl)
    end
  end
  local top = form.lbl_qa_mask.Height - 1
  for i, gbox_qa in ipairs(gbox_qa_list) do
    gbox_qa.Top = top
    gbox_qa.Left = 20
    gsbox_qa_info:Add(gbox_qa)
    top = top + gbox_qa.Height + 12
  end
  if 0 ~= gsbox_qa_info.VScrollBar.Maximum then
    gsbox_qa_info.VScrollBar.Maximum = gsbox_qa_info.VScrollBar.Maximum + 10
  end
end
function on_tree_ex_info_mouse_in_node(tree, new_node, x, y)
  if nx_find_custom(new_node, "tips") then
    tree.HintText = new_node.tips
  end
end
function on_tree_ex_info_mouse_out_node(tree, old_node, x, y)
  tree.HintText = nx_widestr("")
end
function get_voice_player()
  local voice_manager = nx_value("voice_manager")
  if not nx_is_valid(voice_manager) then
    return nx_null()
  end
  local voice_player = voice_manager:GetVoicePlayer(HELPER_VOICE_PLAYER_ID)
  if not nx_is_valid(voice_player) then
    return nx_null()
  end
  return voice_player
end
function stop_other_voice_player()
  local voice_manager = nx_value("voice_manager")
  if not nx_is_valid(voice_manager) then
    return
  end
  voice_manager:StopALLWithoutId(HELPER_VOICE_PLAYER_ID)
end
