require("util_functions")
require("util_gui")
require("form_stage_main\\switch\\url_define")
local MatchRankRec = "MatchRankBase"
local vt1 = {
  61,
  62,
  63,
  64,
  65,
  66,
  102,
  103,
  104,
  105
}
local vt2 = {
  67,
  68,
  69,
  70,
  71,
  72,
  106,
  107,
  108,
  109,
  110
}
local vt3 = {
  77,
  78,
  79,
  80,
  81,
  82,
  83,
  84,
  101
}
local vt4 = {
  85,
  86,
  87,
  88,
  89,
  90
}
local vt5 = {
  73,
  74,
  75,
  76
}
local vt6 = {3, 21}
local vt7 = {
  14,
  112,
  114,
  115
}
local vt8 = {99, 100}
local FORM_QUERY_FRIEND = "form_stage_main\\form_general_info\\form_invrank_selfriend"
local FORM_PATH = "form_stage_main\\form_general_info\\form_general_info_bisai"
local GRID_ROW = 8
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function copy_ent_info(dest, src)
  if not nx_is_valid(src) or not nx_is_valid(dest) then
    return
  end
  local prop_list = nx_property_list(src)
  for i, prop in ipairs(prop_list) do
    if "Name" ~= prop then
      nx_set_property(dest, prop, nx_property(src, prop))
    end
  end
end
function on_main_form_init(self)
  self.Fixed = true
  self.rank_dt = -1
  self.rank_tt = -1
  self.rank_bm = -1
  self.query_type = 0
  self.sel_page = 0
  self.min_page = 0
  self.max_page = 0
  self.show_gb = nx_null()
end
function on_main_form_open(self)
  self.rank_no = -1
  self.rank_dt = -1
  self.rank_tt = -1
  self.rank_bm = -1
  self.query_type = 0
  self.sel_page = 0
  self.min_page = 0
  self.max_page = 0
  self.show_gb = nx_null()
  create_tree_menu(self)
  refresh_grid(self)
  show_gaoshou_title(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
  end
  nx_execute("custom_sender", "custom_query_inv_rank")
  local form_invrank_friend = nx_value("form_invrank_friend")
  if not nx_is_valid(form_invrank_friend) then
    form_invrank_friend = nx_create("form_invrank_friend")
    nx_set_value("form_invrank_friend", form_invrank_friend)
  end
  form_invrank_friend.PlayerNum = 0
  self.groupbox_8.Visible = false
  self.groupbox_9.Visible = false
  self.btn_showFirend.Visible = true
end
function on_main_form_close(self)
  local form_invrank_friend = nx_value("form_invrank_friend")
  if nx_is_valid(form_invrank_friend) then
    nx_destroy(form_invrank_friend)
  end
  local form_query_friend = nx_value(FORM_QUERY_FRIEND)
  if nx_is_valid(form_query_friend) then
    nx_destroy(form_query_friend)
  end
  nx_destroy(self)
end
function on_server_msg(...)
  local data = arg[1]
  local form_general_info_bisai = nx_value("form_general_info_bisai")
  if nx_is_valid(form_general_info_bisai) then
    form_general_info_bisai:OnServMsg(nx_widestr(data))
  end
end
function create_tree_menu(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local tree_view = form.tree_menu
  local root = tree_view.RootNode
  if not nx_is_valid(root) then
    root = tree_view:CreateRootNode(nx_widestr("Root"))
  end
  root:ClearNode()
  tree_view:BeginUpdate()
  local node = root:CreateNode(util_text(""))
  node.Font = "font_btn"
  node.TextOffsetY = 4
  node.ItemHeight = 38
  node.NodeBackImage = "gui\\language\\ChineseS\\tianti\\bssj.png"
  node.NodeFocusImage = "gui\\language\\ChineseS\\tianti\\bssj.png"
  node.NodeSelectImage = "gui\\language\\ChineseS\\tianti\\bssj.png"
  node.ExpandCloseOffsetX = 143
  node.ExpandCloseOffsetY = 9
  node.NodeOffsetY = 3
  local sub_tyep_t = {
    "ui_MRBC_M1",
    "ui_MRBC_M2",
    "ui_MRBC_M3"
  }
  for _, sub_name in pairs(sub_tyep_t) do
    local sub_node = node:CreateNode(util_text(sub_name))
    sub_node.Font = "font_text"
    sub_node.TextOffsetX = 56
    sub_node.TextOffsetY = 5
    sub_node.ItemHeight = 28
    sub_node.NodeFocusImage = "gui\\special\\tianti\\strength\\btn_left_on.png"
    sub_node.NodeSelectImage = "gui\\special\\tianti\\strength\\btn_left_down.png"
    sub_node.NodeBackImage = "gui\\special\\tianti\\strength\\btn_left_out.png"
    sub_node.ExpandCloseOffsetY = 9
    sub_node.NodeImageOffsetX = 30
    sub_node.NodeOffsetY = 3
    sub_node.Type = sub_name == "ui_MRBC_M1" and "vt1" or sub_name == "ui_MRBC_M2" and "vt3" or sub_name == "ui_MRBC_M3" and "vt6"
  end
  root.Expand = true
  node.Expand = true
  local t = node:FindNode(util_text("ui_MRBC_M1"))
  tree_view.SelectNode = node:FindNode(util_text("ui_MRBC_M1"))
  local node = root:CreateNode(util_text(""))
  node.Font = "font_btn"
  node.TextOffsetY = 4
  node.ItemHeight = 38
  node.NodeBackImage = "gui\\language\\ChineseS\\tianti\\bwcj.png"
  node.NodeFocusImage = "gui\\language\\ChineseS\\tianti\\bwcj.png"
  node.NodeSelectImage = "gui\\language\\ChineseS\\tianti\\bwcj.png"
  node.ExpandCloseOffsetX = 143
  node.ExpandCloseOffsetY = 9
  node.NodeOffsetY = 3
  local sub_tyep_t = {
    "ui_MRBC_M4",
    "ui_MRBC_M5",
    "ui_MRBC_M6"
  }
  for _, sub_name in pairs(sub_tyep_t) do
    local sub_node = node:CreateNode(util_text(sub_name))
    sub_node.Font = "font_text"
    sub_node.TextOffsetX = 56
    sub_node.TextOffsetY = 5
    sub_node.ItemHeight = 28
    sub_node.NodeFocusImage = "gui\\special\\tianti\\strength\\btn_left_on.png"
    sub_node.NodeSelectImage = "gui\\special\\tianti\\strength\\btn_left_down.png"
    sub_node.NodeBackImage = "gui\\special\\tianti\\strength\\btn_left_out.png"
    sub_node.ExpandCloseOffsetY = 9
    sub_node.NodeImageOffsetX = 30
    sub_node.NodeOffsetY = 3
    sub_node.Type = sub_name
  end
  tree_view:EndUpdate()
end
function on_tree_menu_expand_changed(self, node)
end
function on_tree_menu_select_changed(self, node, old_node)
  local form = self.ParentForm
  if nx_find_custom(node, "Type") then
    form.rbtn_1.Checked = true
    local type = nx_custom(node, "Type")
    if "vt1" == type then
      form.rbtn_3.Text = util_text("ui_MRBC_M1_1")
      form.rbtn_4.Text = util_text("ui_MRBC_M1_2")
      form.rbtn_5.Visible = false
      form.rbtn_6.Text = util_text("ui_MRBC_M1_1")
      form.rbtn_7.Text = util_text("ui_MRBC_M1_2")
      form.rbtn_8.Visible = false
      refresh_grid(form, vt1)
      show_gaoshou_title(form, vt1)
    elseif "vt3" == type then
      form.rbtn_3.Text = util_text("ui_MRBC_M2_1")
      form.rbtn_4.Text = util_text("ui_MRBC_M2_2")
      form.rbtn_5.Text = util_text("ui_MRBC_M2_3")
      form.rbtn_5.Visible = true
      form.rbtn_6.Text = util_text("ui_MRBC_M2_1")
      form.rbtn_7.Text = util_text("ui_MRBC_M2_2")
      form.rbtn_8.Text = util_text("ui_MRBC_M2_3")
      form.rbtn_8.Visible = true
      refresh_grid(form, vt3)
      show_gaoshou_title(form, vt3)
    elseif "vt6" == type then
      form.rbtn_3.Text = util_text("ui_MRBC_M3_1")
      form.rbtn_4.Text = util_text("ui_MRBC_M3_2")
      form.rbtn_5.Text = util_text("ui_MRBC_M3_3")
      form.rbtn_5.Visible = true
      form.rbtn_6.Text = util_text("ui_MRBC_M3_1")
      form.rbtn_7.Text = util_text("ui_MRBC_M3_2")
      form.rbtn_8.Text = util_text("ui_MRBC_M3_3")
      form.rbtn_8.Visible = true
      refresh_grid(form, vt6)
      show_gaoshou_title(form, vt6)
    elseif "ui_MRBC_M4" == type or "ui_MRBC_M5" == type or "ui_MRBC_M6" == type then
      refresh_gaoshou_groupbox(form, type)
    end
    if "ui_MRBC_M6" ~= type then
      clear_ls_effect(form)
    end
    if type ~= "ui_MRBC_M5" then
      form.groupbox_8.Visible = false
      form.groupbox_9.Visible = false
    end
    form.rbtn_3.Checked = true
    form.rbtn_6.Checked = true
  end
end
function refresh_grid(form, vis_list)
  local form_general_info_bisai = nx_value("form_general_info_bisai")
  if not nx_is_valid(form_general_info_bisai) then
    return
  end
  vis_list = vis_list or vt1
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_1.Visible = true
  form.groupbox_6.Visible = false
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local player_name = client_player:QueryProp("Name")
  if not client_player:FindRecord(MatchRankRec) then
    return
  end
  local grid = form.textgrid_1
  grid:BeginUpdate()
  grid:ClearRow()
  grid:ClearSelect()
  grid.ColCount = 3
  if form.cbtn_1.Checked then
    grid.ColWidths = "100, 90, 0"
  else
    grid.ColWidths = "100, 90, 50"
  end
  grid:SetColTitle(0, util_text("ui_MRBC_T1"))
  grid:SetColTitle(1, util_text("ui_MRBC_T2"))
  grid:SetColTitle(2, util_text("ui_MRBC_T3"))
  for _, value in pairs(vis_list) do
    local row = grid:InsertRow(grid.RowCount)
    local name = "ui_MRBC_" .. value
    grid:SetGridText(row, 0, util_text(name))
    local num = client_player:QueryRecord(MatchRankRec, value, 0)
    local max_num = form_general_info_bisai:GetRankValue(value)
    local level = 1
    local image = "gui\\language\\ChineseS\\tianti\\w.png"
    if 0 < max_num then
      local t = num * 100 / max_num
      if 100 <= t then
        if nx_ws_equal(player_name, form_general_info_bisai:GetRankPlayer(value)) then
          image = "gui\\language\\ChineseS\\tianti\\ws.png"
        else
          image = "gui\\language\\ChineseS\\tianti\\j.png"
        end
      elseif 90 <= t then
        image = "gui\\language\\ChineseS\\tianti\\j.png"
      elseif 80 <= t then
        image = "gui\\language\\ChineseS\\tianti\\y.png"
      elseif 60 <= t then
        image = "gui\\language\\ChineseS\\tianti\\b.png"
      elseif 30 <= t then
        image = "gui\\language\\ChineseS\\tianti\\d.png"
      else
        image = "gui\\language\\ChineseS\\tianti\\w.png"
      end
    end
    grid:SetGridText(row, 1, nx_widestr(num))
    local image_grid = gui:Create("ImageGrid")
    image_grid.BackColor = "0,255,255,255"
    image_grid.MouseInColor = "0,255,255,255"
    image_grid.SelectColor = "0,255,255,255"
    image_grid.ClomnNum = 1
    image_grid.RoundGird = true
    image_grid.FitGrid = false
    image_grid.NoFrame = true
    image_grid.GridHeight = 12
    image_grid.GridWidth = 12
    image_grid.ViewRect = "4,8,16,20"
    image_grid.value = value
    image_grid:AddItem(nx_int(0), nx_string(image), "", nx_int(1), nx_int(-1))
    grid:SetGridControl(row, 2, image_grid)
  end
  grid:EndUpdate()
end
function on_textgrid_1_mousein_row_changed(self, new_row, old_row)
  nx_execute("tips_game", "hide_tip")
  local image_grid = self:GetGridControl(new_row, 2)
  if not nx_is_valid(image_grid) then
    return
  end
  local value = nx_find_custom(image_grid, "value") and nx_custom(image_grid, "value") or 0
  local form_general_info_bisai = nx_value("form_general_info_bisai")
  if not nx_is_valid(form_general_info_bisai) then
    return
  end
  local player_name = form_general_info_bisai:GetRankPlayer(nx_int(value))
  local player_num = form_general_info_bisai:GetRankValue(nx_int(value))
  local tips_text = util_format_string("ui_MRBC_S1_tips", nx_widestr(player_name), nx_int(player_num))
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local mouseX, mouseY = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), mouseX, mouseY, 150, self.ParentForm)
end
function refresh_gaoshou_groupbox(form, type)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_1.Visible = false
  form.groupbox_6.Visible = true
  if type == "ui_MRBC_M4" then
    form.groupbox_zp.Visible = true
    form.groupbox_ph.Visible = false
    form.groupbox_ls.Visible = false
    show_zp(form)
  elseif type == "ui_MRBC_M5" then
    form.groupbox_zp.Visible = false
    form.groupbox_ph.Visible = true
    form.groupbox_ls.Visible = false
    form.groupbox_8.Visible = false
    form.groupbox_9.Visible = false
    form.btn_showFirend.Visible = true
    show_ph(form)
  elseif type == "ui_MRBC_M6" then
    form.groupbox_zp.Visible = false
    form.groupbox_ph.Visible = false
    form.groupbox_ls.Visible = true
    show_ls(form)
  end
end
function get_mark(self, rank)
  if rank <= 0 then
    return 1
  end
  local t = self * 100 / rank
  if 100 <= t then
    return 10
  elseif 90 <= t then
    return 5
  elseif 80 <= t then
    return 4
  elseif 60 <= t then
    return 3
  elseif 30 <= t then
    return 2
  else
    return 1
  end
end
function show_zp(form)
  if not nx_is_valid(form) then
    return
  end
  local form_general_info_bisai = nx_value("form_general_info_bisai")
  if not nx_is_valid(form_general_info_bisai) then
    return
  end
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local t1 = 0
  for _, value in pairs(vt1) do
    local num = client_player:QueryRecord(MatchRankRec, value, 0)
    local max_num = form_general_info_bisai:GetRankValue(value)
    t1 = t1 + get_mark(num, max_num)
  end
  for _, value in pairs(vt2) do
    local num = client_player:QueryRecord(MatchRankRec, value, 0)
    local max_num = form_general_info_bisai:GetRankValue(value)
    t1 = t1 + get_mark(num, max_num)
  end
  local t2 = 0
  for _, value in pairs(vt3) do
    local num = client_player:QueryRecord(MatchRankRec, value, 0)
    local max_num = form_general_info_bisai:GetRankValue(value)
    t2 = t2 + get_mark(num, max_num)
  end
  for _, value in pairs(vt4) do
    local num = client_player:QueryRecord(MatchRankRec, value, 0)
    local max_num = form_general_info_bisai:GetRankValue(value)
    t2 = t2 + get_mark(num, max_num)
  end
  for _, value in pairs(vt5) do
    local num = client_player:QueryRecord(MatchRankRec, value, 0)
    local max_num = form_general_info_bisai:GetRankValue(value)
    t2 = t2 + get_mark(num, max_num)
  end
  local t3 = 0
  for _, value in pairs(vt6) do
    local num = client_player:QueryRecord(MatchRankRec, value, 0)
    local max_num = form_general_info_bisai:GetRankValue(value)
    t3 = t3 + get_mark(num, max_num)
  end
  for _, value in pairs(vt7) do
    local num = client_player:QueryRecord(MatchRankRec, value, 0)
    local max_num = form_general_info_bisai:GetRankValue(value)
    t3 = t3 + get_mark(num, max_num)
  end
  for _, value in pairs(vt8) do
    local num = client_player:QueryRecord(MatchRankRec, value, 0)
    local max_num = form_general_info_bisai:GetRankValue(value)
    t3 = t3 + get_mark(num, max_num)
  end
  local t_num_pic = num_to_pic(t1)
  local t_num_ctrl = {
    "lbl_11_2",
    "lbl_11_1",
    "lbl_11"
  }
  for _, lbl_name in ipairs(t_num_ctrl) do
    local lbl_obj = nx_custom(form, lbl_name)
    if nx_is_valid(lbl_obj) then
      lbl_obj.Visible = false
    end
  end
  local i = 1
  for _, num_pic in ipairs(t_num_pic) do
    local lbl_name = t_num_ctrl[i]
    local lbl_obj = nx_custom(form, lbl_name)
    if nx_is_valid(lbl_obj) then
      lbl_obj.BackImage = nx_string(num_pic)
      lbl_obj.Visible = true
    end
    i = i + 1
    if i > table.getn(t_num_ctrl) then
      break
    end
  end
  local t_num_pic = num_to_pic(t2)
  local t_num_ctrl = {
    "lbl_12_2",
    "lbl_12_1",
    "lbl_12"
  }
  for _, lbl_name in ipairs(t_num_ctrl) do
    local lbl_obj = nx_custom(form, lbl_name)
    if nx_is_valid(lbl_obj) then
      lbl_obj.Visible = false
    end
  end
  local i = 1
  for _, num_pic in ipairs(t_num_pic) do
    local lbl_name = t_num_ctrl[i]
    local lbl_obj = nx_custom(form, lbl_name)
    if nx_is_valid(lbl_obj) then
      lbl_obj.BackImage = nx_string(num_pic)
      lbl_obj.Visible = true
    end
    i = i + 1
    if i > table.getn(t_num_ctrl) then
      break
    end
  end
  local t_num_pic = num_to_pic(t3)
  local t_num_ctrl = {
    "lbl_13_2",
    "lbl_13_1",
    "lbl_13"
  }
  for _, lbl_name in ipairs(t_num_ctrl) do
    local lbl_obj = nx_custom(form, lbl_name)
    if nx_is_valid(lbl_obj) then
      lbl_obj.Visible = false
    end
  end
  local i = 1
  for _, num_pic in ipairs(t_num_pic) do
    local lbl_name = t_num_ctrl[i]
    local lbl_obj = nx_custom(form, lbl_name)
    if nx_is_valid(lbl_obj) then
      lbl_obj.BackImage = nx_string(num_pic)
      lbl_obj.Visible = true
    end
    i = i + 1
    if i > table.getn(t_num_ctrl) then
      break
    end
  end
  local t_num_pic = num_to_pic(t1 + t2 + t3, true)
  local t_num_ctrl = {
    "lbl_28_2",
    "lbl_28_1",
    "lbl_28"
  }
  for _, lbl_name in ipairs(t_num_ctrl) do
    local lbl_obj = nx_custom(form, lbl_name)
    if nx_is_valid(lbl_obj) then
      lbl_obj.Visible = false
    end
  end
  local i = 1
  for _, num_pic in ipairs(t_num_pic) do
    local lbl_name = t_num_ctrl[i]
    local lbl_obj = nx_custom(form, lbl_name)
    if nx_is_valid(lbl_obj) then
      lbl_obj.BackImage = nx_string(num_pic)
      lbl_obj.Visible = true
    end
    i = i + 1
    if i > table.getn(t_num_ctrl) then
      break
    end
  end
end
function show_ph(form)
  if not nx_is_valid(form) then
    return
  end
  on_show_ph_info(form.rank_dt, form.lbl_tiger_none, form.lbl_tiger_1, form.lbl_tiger_2, form.lbl_tiger_3)
  on_show_ph_info(form.rank_tt, form.lbl_tt_none, form.lbl_tt_1, form.lbl_tt_2, form.lbl_tt_3)
  on_show_ph_info(form.rank_bm, form.lbl_bm_none, form.lbl_bm_1, form.lbl_bm_2, form.lbl_bm_3)
end
function show_ls(form)
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_9.Checked = true
end
function create_ls_groupbox(ls_point, win_con, win_desc, effect, win_level)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return nx_null()
  end
  local groupbox = gui:Create("GroupBox")
  copy_ent_info(groupbox, form.groupbox_ls_t)
  groupbox.Left = 0
  for i, ctrl in ipairs(form.groupbox_ls_t:GetChildControlList()) do
    local ctrl_obj = gui:Create(nx_name(ctrl))
    copy_ent_info(ctrl_obj, ctrl)
    if nx_property(ctrl, "Name") == "lbl_18" then
      ctrl_obj.Text = util_text(win_con)
    end
    if nx_property(ctrl, "Name") == "mltbox_3" then
      ctrl_obj:Clear()
      ctrl_obj:AddHtmlText(util_format_string(win_desc, nx_int(ls_point)), -1)
    end
    if nx_property(ctrl, "Name") == "btn_3" then
      nx_bind_script(ctrl_obj, nx_current())
      ctrl_obj.effect_name = effect
      nx_callback(ctrl_obj, "on_click", "on_btn_3_click")
    end
    groupbox:Add(ctrl_obj)
  end
  return groupbox
end
function show_gaoshou_title(form, vis_list)
  local form_general_info_bisai = nx_value("form_general_info_bisai")
  if not nx_is_valid(form_general_info_bisai) then
    return
  end
  vis_list = vis_list or vt1
  if not nx_is_valid(form) then
    return
  end
  local groupscrollbox = form.groupscrollbox_1
  groupscrollbox:DeleteAll()
  for _, value in pairs(vis_list) do
    local groupbox = create_title_node(value)
    if nx_is_valid(groupbox) then
      groupbox.Left = 0
      groupscrollbox:Add(groupbox)
    end
  end
  groupscrollbox:ResetChildrenYPos()
end
function on_cbtn_1_checked_changed(cbtn)
  local form = cbtn.ParentForm
  local select = get_curr_tree_select()
  if not select then
    return
  end
  local rbtn_index = 1
  local t_rbtn_list = {
    "rbtn_3",
    "rbtn_4",
    "rbtn_5"
  }
  for i, ctrl_name in ipairs(t_rbtn_list) do
    local ctrl_obj = nx_custom(form, ctrl_name)
    if nx_is_valid(ctrl_obj) and ctrl_obj.Checked then
      rbtn_index = i
    end
  end
  local t = {}
  if "vt1" == select then
    if rbtn_index == 1 then
      t = vt1
    elseif rbtn_index == 2 then
      t = vt2
    end
  elseif "vt3" == select then
    if rbtn_index == 1 then
      t = vt3
    elseif rbtn_index == 2 then
      t = vt4
    elseif rbtn_index == 3 then
      t = vt5
    end
  elseif "vt6" == select then
    if rbtn_index == 1 then
      t = vt6
    elseif rbtn_index == 2 then
      t = vt7
    elseif rbtn_index == 3 then
      t = vt8
    end
  end
  refresh_grid(form, t)
end
function on_rbtn_1_checked_changed(rbtn)
  local form = rbtn.ParentForm
  form.groupbox_2.Visible = rbtn.Checked
end
function on_rbtn_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  form.groupbox_3.Visible = rbtn.Checked
end
function on_rbtn_3_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  local select = get_curr_tree_select()
  if not select then
    return
  end
  if "vt1" == select then
    refresh_grid(form, vt1)
  elseif "vt3" == select then
    refresh_grid(form, vt3)
  elseif "vt6" == select then
    refresh_grid(form, vt6)
  end
end
function on_rbtn_4_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  local select = get_curr_tree_select()
  if not select then
    return
  end
  if "vt1" == select then
    refresh_grid(form, vt2)
  elseif "vt3" == select then
    refresh_grid(form, vt4)
  elseif "vt6" == select then
    refresh_grid(form, vt7)
  end
end
function on_rbtn_5_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  local select = get_curr_tree_select()
  if not select then
    return
  end
  if "vt3" == select then
    refresh_grid(form, vt5)
  elseif "vt6" == select then
    refresh_grid(form, vt8)
  end
end
function on_rbtn_6_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  local select = get_curr_tree_select()
  if not select then
    return
  end
  if "vt1" == select then
    show_gaoshou_title(form, vt1)
  elseif "vt3" == select then
    show_gaoshou_title(form, vt3)
  elseif "vt6" == select then
    show_gaoshou_title(form, vt6)
  end
end
function on_rbtn_7_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  local select = get_curr_tree_select()
  if not select then
    return
  end
  if "vt1" == select then
    show_gaoshou_title(form, vt2)
  elseif "vt3" == select then
    show_gaoshou_title(form, vt4)
  elseif "vt6" == select then
    show_gaoshou_title(form, vt7)
  end
end
function on_rbtn_8_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  local select = get_curr_tree_select()
  if not select then
    return
  end
  if "vt3" == select then
    show_gaoshou_title(form, vt5)
  elseif "vt6" == select then
    show_gaoshou_title(form, vt8)
  end
end
function get_curr_ls_maintype(form)
  local rst = "ui_tianti_rank1"
  if not nx_is_valid(form) then
    return rst
  end
  local t_rbtn = {
    "rbtn_9",
    "rbtn_10",
    "rbtn_11"
  }
  for _, ctrl_name in pairs(t_rbtn) do
    local rbtn_obj = nx_custom(form, ctrl_name)
    if nx_is_valid(rbtn_obj) and rbtn_obj.Checked then
      return rbtn_obj.DataSource
    end
  end
  return rst
end
function on_rbtn_9_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  form.rbtn_12.Visible = true
  form.rbtn_12.Text = util_text("ui_MRBC_M6_1")
  form.rbtn_12.Checked = true
  show_ls_sub_type(form, rbtn.DataSource, "ui_MRBC_M6_1")
  form.rbtn_13.Visible = true
  form.rbtn_13.Text = util_text("ui_MRBC_M6_2")
end
function on_rbtn_10_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  form.rbtn_12.Visible = false
  form.rbtn_13.Visible = false
  show_ls_sub_type(form, rbtn.DataSource, "")
end
function on_rbtn_11_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  form.rbtn_12.Visible = true
  form.rbtn_12.Text = util_text("ui_MRBC_M6_3")
  form.rbtn_12.Checked = true
  show_ls_sub_type(form, rbtn.DataSource, "ui_MRBC_M6_3")
  form.rbtn_13.Visible = true
  form.rbtn_13.Text = util_text("ui_MRBC_M6_4")
end
function on_rbtn_12_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  local main_ls_type = get_curr_ls_maintype(form)
  if main_ls_type == "ui_tianti_rank3" then
    show_ls_sub_type(form, main_ls_type, "ui_MRBC_M6_3")
  else
    show_ls_sub_type(form, main_ls_type, "ui_MRBC_M6_1")
  end
end
function on_rbtn_13_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  local main_ls_type = get_curr_ls_maintype(form)
  if main_ls_type == "ui_tianti_rank3" then
    show_ls_sub_type(form, main_ls_type, "ui_MRBC_M6_4")
  else
    show_ls_sub_type(form, main_ls_type, "ui_MRBC_M6_2")
  end
end
function on_lbl_20_get_capture(lbl)
  local tips_text = util_text("ui_MRBC_S1_tips")
  nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), lbl.AbsLeft, lbl.AbsTop, 150, lbl.ParentForm)
end
function on_lbl_20_lost_capture(lbl)
  nx_execute("tips_game", "hide_tip")
end
function on_lbl_34_get_capture(lbl)
  local tips_text = util_text("ui_MRBC_M4_tips")
  nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), lbl.AbsLeft, lbl.AbsTop + 50, 150, lbl.ParentForm)
end
function on_lbl_34_lost_capture(lbl)
  nx_execute("tips_game", "hide_tip")
end
function on_lbl_37_get_capture(lbl)
  local tips_text = util_text("ui_MRBC_S2_tips")
  nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), lbl.AbsLeft, lbl.AbsTop + 50, 150, lbl.ParentForm)
end
function on_lbl_37_lost_capture(lbl)
  nx_execute("tips_game", "hide_tip")
end
function get_ls_point(main_type, sub_type)
  sub_type = sub_type or ""
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindRecord(MatchRankRec) then
    return 0
  end
  local line_num = -1
  if "ui_tianti_rank1" == main_type then
    if "ui_MRBC_M6_1" == sub_type then
      line_num = 1
    elseif "ui_MRBC_M6_2" == sub_type then
      line_num = 8
    end
  elseif "ui_tianti_rank2" == main_type then
    line_num = 15
  elseif "ui_tianti_rank3" == main_type then
    if "ui_MRBC_M6_3" == sub_type then
      line_num = 19
    elseif "ui_MRBC_M6_4" == sub_type then
      line_num = 26
    end
  end
  if line_num < 0 then
    return 0
  end
  local ls_point = client_player:QueryRecord(MatchRankRec, line_num, 0)
  return ls_point
end
function show_ls_sub_type(form, main_type, sub_type)
  if not nx_is_valid(form) then
    return
  end
  local form_general_info_bisai = nx_value("form_general_info_bisai")
  if not nx_is_valid(form_general_info_bisai) then
    return
  end
  local ls_point = get_ls_point(main_type, sub_type)
  local ls_list = form_general_info_bisai:GetWinList(nx_string(main_type), nx_string(sub_type))
  local ls_count = table.getn(ls_list) / 4
  local groupscrollbox = form.groupscrollbox_2
  groupscrollbox:DeleteAll()
  local need_show = true
  for i = 1, ls_count do
    local win_con, win_desc, effect, win_level = ls_list[(i - 1) * 4 + 1], ls_list[(i - 1) * 4 + 2], ls_list[(i - 1) * 4 + 3], ls_list[i * 4]
    if need_show or ls_point >= win_level then
      local groupbox = create_ls_groupbox(ls_point, win_con, win_desc, effect, win_level)
      if nx_is_valid(groupbox) then
        groupbox.Left = 0
        groupscrollbox:Add(groupbox)
      end
    end
    if ls_point < win_level and need_show then
      need_show = false
    end
  end
  groupscrollbox:ResetChildrenYPos()
end
function on_btn_1_click(btn)
  if nx_find_custom(btn, "PlayerName") then
    local player_name = nx_custom(btn, "PlayerName")
    nx_execute("custom_sender", "custom_send_get_player_game_info", nx_widestr(player_name))
  end
end
function on_btn_2_click(btn)
  if nx_find_custom(btn, "TitleID") then
    local title_id = nx_custom(btn, "TitleID")
    nx_execute("custom_sender", "custom_set_title", nx_int(title_id))
  end
end
function on_btn_3_click(btn)
  local form = btn.ParentForm
  local form_general_info_main = nx_value("form_stage_main\\form_general_info\\form_general_info_main")
  if not nx_is_valid(form_general_info_main) then
    return
  end
  clear_ls_effect(form)
  nx_execute("game_effect", "create_effect", nx_custom(btn, "effect_name"), nx_custom(form_general_info_main, "actor2"))
  form.curr_effect_name = nx_custom(btn, "effect_name")
end
function clear_ls_effect(form)
  if not nx_is_valid(form) then
    return
  end
  local form_general_info_main = nx_value("form_stage_main\\form_general_info\\form_general_info_main")
  if not nx_is_valid(form_general_info_main) then
    return
  end
  if nx_find_custom(form, "curr_effect_name") then
    local curr_effect_name = nx_custom(form, "curr_effect_name")
    nx_execute("game_effect", "remove_effect", curr_effect_name, nx_custom(form_general_info_main, "actor2"), nx_custom(form_general_info_main, "actor2"))
  end
end
function create_title_node(value)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return nx_null()
  end
  local form_general_info_bisai = nx_value("form_general_info_bisai")
  if not nx_is_valid(form_general_info_bisai) then
    return nx_null()
  end
  local t = form_general_info_bisai:GetRankList(nx_int(value))
  if table.getn(t) ~= 2 then
    return nx_null()
  end
  local title_id = t[1]
  local player_name = t[2]
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  local groupbox = gui:Create("GroupBox")
  copy_ent_info(groupbox, form.groupbox_t)
  groupbox.Left = 0
  for i, ctrl in ipairs(form.groupbox_t:GetChildControlList()) do
    local ctrl_obj = gui:Create(nx_name(ctrl))
    copy_ent_info(ctrl_obj, ctrl)
    if nx_property(ctrl, "Name") == "lbl_1" then
      ctrl_obj.BackImage = form_general_info_bisai:GetTitlePic(nx_int(title_id))
    end
    if nx_property(ctrl, "Name") == "lbl_5" then
      if nx_ws_equal(player_name, nx_widestr("")) then
        player_name = util_text("ui_MRBC_S3_1")
      end
      ctrl_obj.Text = nx_widestr(player_name)
    end
    if nx_property(ctrl, "Name") == "btn_1" then
      local name = player_name
      if nx_ws_equal(name, nx_widestr("")) then
        player_name = util_text("ui_MRBC_S3_1")
      end
      ctrl_obj.PlayerName = name
      nx_bind_script(ctrl_obj, nx_current())
      nx_callback(ctrl_obj, "on_click", "on_btn_1_click")
    end
    if nx_property(ctrl, "Name") == "btn_2" then
      ctrl_obj.TitleID = title_id
      if not form_general_info_bisai:FindTitle(nx_int(title_id)) then
        ctrl_obj.Enabled = false
      end
      nx_bind_script(ctrl_obj, nx_current())
      nx_callback(ctrl_obj, "on_click", "on_btn_2_click")
    end
    groupbox:Add(ctrl_obj)
  end
  return groupbox
end
function show_form(form)
  local form_bisai = nx_value(nx_current())
  if not nx_is_valid(form_bisai) then
    local form_bisai = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
    if nx_is_valid(form_bisai) then
      form.groupbox_main:Add(form_bisai)
      form.groupbox_main:ToFront(form_bisai)
      form_bisai.Left = 0
      form_bisai.Top = 0
    end
  else
    form_bisai:Show()
    form_bisai.Visible = true
  end
  if nx_is_valid(form_bisai) then
    form_bisai.groupbox_8.Visible = false
  end
  local form_invrank_friend = nx_value("form_invrank_friend")
  if nx_is_valid(form_invrank_friend) then
    form_invrank_friend.PlayerNum = 0
  end
end
function get_client_player()
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    return game_client:GetPlayer()
  end
  return nx_null()
end
function get_curr_tree_select()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local tree_menu = form.tree_menu
  local selectnode = tree_menu.SelectNode
  if not nx_is_valid(selectnode) then
    return
  end
  if nx_find_custom(selectnode, "Type") then
    local type = nx_custom(selectnode, "Type")
    return type
  end
end
function num_to_pic(num, is_gold)
  local rst = {}
  if num < 0 then
    return rst
  end
  local path = "gui\\special\\tianti\\rank\\"
  if is_gold then
    path = "gui\\special\\tianti\\rank\\g"
  end
  while nx_int(num) > nx_int(0) do
    local tail = nx_number(num) % 10
    num = nx_int(num / 10)
    table.insert(rst, path .. nx_string(tail) .. ".png")
  end
  return rst
end
function on_btn_showFirend_click(btn)
  local form = btn.ParentForm
  form.query_type = 0
  local gb_friend = form.groupbox_8
  gb_friend.Visible = not gb_friend.Visible
  if gb_friend.Visible then
    on_recovry_show(form)
    form.query_type = 2
    form.groupbox_1.Visible = false
    form.groupbox_6.Visible = false
    init_grid(form.textgrid_rank)
    on_update_grid_info(form, form.sel_page)
    on_btn_friend_click(form.btn_friend)
  else
    if nx_is_valid(form.show_gb) then
      form.show_gb.Visible = true
    end
    local form_sel_friend = nx_value(FORM_QUERY_FRIEND)
    if nx_is_valid(form_sel_friend) then
      form_sel_friend.Visible = false
      form_sel_friend:Close()
    end
  end
end
function on_refesh_firend(query_rec, playerNameList)
  local form_invrank_friend = nx_value("form_invrank_friend")
  if not nx_is_valid(form_invrank_friend) then
    return
  end
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.Visible ~= true then
    return
  end
  if form.query_type ~= 2 then
    return
  end
  form_invrank_friend:RankTianTi(query_rec, playerNameList)
  local num = form_invrank_friend.PlayerNum
  local page_num = num / GRID_ROW
  local page_mod = num % GRID_ROW
  if page_mod == 0 then
    form.max_page = page_num
  else
    form.max_page = page_num + 1
  end
  form.sel_page = 1
  form.min_page = 1
  form.btn_page_after.Enabled = true
  form.groupbox_8.Visible = true
  if num <= GRID_ROW then
    form.btn_page_after.Enabled = false
  end
  form.btn_page_pre.Enabled = false
  on_update_grid_info(form, 1)
end
function on_update_grid_info(form, page)
  if not nx_is_valid(form) then
    return
  end
  if page <= 0 then
    return
  end
  if form.query_type ~= 2 then
    return
  end
  local form_invrank_friend = nx_value("form_invrank_friend")
  if not nx_is_valid(form_invrank_friend) then
    return
  end
  on_init_tianti(form)
  local rank_gird = form.textgrid_rank
  init_grid(rank_gird)
  local count = form_invrank_friend.PlayerNum
  if count <= 0 then
    return
  end
  local begin_index = (page - 1) * GRID_ROW
  local end_index = page * GRID_ROW
  form.lbl_page.Text = nx_widestr(page)
  rank_gird:BeginUpdate()
  for i = begin_index, end_index - 1 do
    local name = form_invrank_friend:GetRankPlayerName(i)
    local score = form_invrank_friend:GetRankPlayerScore(i)
    if 0 <= score and nx_widestr(name) ~= nx_widestr("") then
      local row = rank_gird:InsertRow(-1)
      rank_gird:SetGridText(row, 0, nx_widestr(i + 1))
      rank_gird:SetGridText(row, 1, nx_widestr(name))
      rank_gird:SetGridText(row, 2, nx_widestr(score))
    end
  end
  rank_gird:EndUpdate()
end
function init_grid(grid)
  if not nx_is_valid(grid) then
    return
  end
  local gui = nx_value("gui")
  local rank_gird = grid
  rank_gird:ClearRow()
  rank_gird.ColCount = 3
  rank_gird:SetColWidth(0, rank_gird.Width / 5)
  rank_gird:SetColWidth(1, rank_gird.Width / 5 * 2)
  rank_gird:SetColWidth(2, rank_gird.Width / 5 * 2)
  local text = gui.TextManager:GetText("ui_tianti_number")
  rank_gird:SetColTitle(0, text)
  text = gui.TextManager:GetText("ui_tianti_name")
  rank_gird:SetColTitle(1, text)
  text = gui.TextManager:GetText("ui_tianti_point")
  rank_gird:SetColTitle(2, text)
end
function on_init_tianti(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player_obj = game_client:GetPlayer()
  if not nx_is_valid(player_obj) then
    return
  end
  local RevengeIntegral = player_obj:QueryProp("RevengeIntegral")
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_tianti_personalpoint")
  gui.TextManager:Format_AddParam(RevengeIntegral)
  local text = gui.TextManager:Format_GetText()
  form.mltbox_1.HtmlText = text
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_tianti_personalranking")
  gui.TextManager:Format_AddParam(form.rank_no)
  local text = gui.TextManager:Format_GetText()
  form.mltbox_2.HtmlText = text
end
function on_textgrid_rank_right_select_grid(grid, row, col)
  local form = grid.ParentForm
  local player_name = grid:GetGridText(row, 1)
  if nx_widestr(player_name) == nx_widestr("") then
    return
  end
  form.sel_player = player_name
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  form.groupbox_9.AbsLeft = x
  form.groupbox_9.AbsTop = y
  form.groupbox_9.Visible = true
end
function on_btn_friend_click(btn)
  local form = btn.ParentForm
  if form.query_type ~= 2 then
    return
  end
  local form_query_friend = nx_execute("util_gui", "util_get_form", FORM_QUERY_FRIEND, true, false)
  if nx_is_valid(form_query_friend) then
    form_query_friend.AbsLeft = form.groupbox_8.AbsLeft - 10
    form_query_friend.AbsTop = form.groupbox_8.AbsTop + form.groupbox_8.Height / 3
    form_query_friend:Show()
    form_query_friend.Visible = true
    nx_execute(FORM_QUERY_FRIEND, "refresh_form", form_query_friend, form.query_type)
  end
end
function on_btn_chat_click(btn)
  local form = btn.ParentForm
  if nx_widestr(form.sel_player) == nx_widestr("") then
    return
  end
  nx_execute("custom_sender", "custom_request_chat", nx_widestr(form.sel_player))
  form.groupbox_9.Visible = false
end
function on_btn_email_click(btn)
  local form = btn.ParentForm
  if nx_widestr(form.sel_player) == nx_widestr("") then
    return
  end
  nx_execute("form_stage_main\\form_mail\\form_mail", "open_form", 1)
  local form_send_mail = nx_value("form_stage_main\\form_mail\\form_mail_send")
  if nx_is_valid(form_send_mail) then
    form_send_mail.targetname.Text = nx_widestr(form.sel_player)
  end
  form.groupbox_9.Visible = false
end
function on_btn_look_click(btn)
  local form = btn.ParentForm
  if nx_widestr(form.sel_player) == nx_widestr("") then
    return
  end
  nx_execute("custom_sender", "custom_send_get_player_game_info", form.sel_player)
  form.groupbox_9.Visible = false
end
function on_textgrid_rank_select_grid(grid)
  local form = grid.ParentForm
  form.groupbox_9.Visible = false
end
function on_btn_4_click(btn)
  nx_execute("form_stage_main\\form_advanced_weapon_and_origin", "show_ws")
end
function on_btn_page_pre_click(btn)
  local form = btn.ParentForm
  if form.sel_page == 0 then
    return
  end
  local page = form.sel_page
  page = page - 1
  if page <= 1 then
    btn.Enabled = false
  end
  if form.sel_page == form.max_page then
    form.btn_page_after.Enabled = true
  end
  form.sel_page = page
  on_update_grid_info(form, page)
end
function on_btn_page_after_click(btn)
  local form = btn.ParentForm
  if form.sel_page == 0 then
    return
  end
  local page = form.sel_page
  page = page + 1
  if page >= form.max_page then
    btn.Enabled = false
  end
  if form.sel_page == form.min_page then
    form.btn_page_pre.Enabled = true
  end
  form.sel_page = page
  on_update_grid_info(form, page)
end
function on_refesh_form(dt, tt, bm)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  form.rank_dt = dt
  form.rank_tt = tt
  form.rank_bm = bm
end
function on_get_valid_no(rank_no)
  if nx_int(rank_no) <= nx_int(0) or nx_int(rank_no) > nx_int(100) then
    return 0, 0, 0, 0
  end
  local hundreds = -1
  local tens = -1
  local units = -1
  hundreds = nx_int(rank_no / 100)
  tens = nx_int((rank_no - hundreds * 100) / 10)
  units = nx_int((rank_no - hundreds * 100) % 10)
  return 1, hundreds, tens, units
end
function on_show_ph_info(rank_no, lbl_none, lbl_h, lbl_t, lbl_u)
  if not (nx_is_valid(lbl_none) and nx_is_valid(lbl_h) and nx_is_valid(lbl_t)) or not nx_is_valid(lbl_u) then
    return
  end
  local valid, hundreds, tens, units = on_get_valid_no(rank_no)
  if valid == 0 then
    local gui = nx_value("gui")
    lbl_none.Text = gui.TextManager:GetText("ui_tianti_rank7")
    lbl_none.Visible = true
  elseif rank_no < 10 then
    on_set_rank(lbl_u, rank_no, 0)
  else
    if nx_int(hundreds) > nx_int(0) then
      on_set_rank(lbl_h, hundreds, 1)
    end
    if nx_int(tens) > nx_int(-1) then
      on_set_rank(lbl_t, tens, 2)
    end
    if nx_int(units) > nx_int(-1) then
      on_set_rank(lbl_u, units, 3)
    end
  end
end
function on_set_rank(lbl, rank, rank_type)
  if not nx_is_valid(lbl) then
    return
  end
  if nx_int(rank) < nx_int(0) or nx_int(rank) > nx_int(9) then
    return
  end
  if rank_type < 0 or 3 < rank_type then
    return
  end
  if rank_type == 0 then
    if nx_int(rank) > nx_int(0) then
      local path = "gui\\special\\tianti\\rank\\g"
      lbl.BackImage = path .. nx_string(rank) .. ".png"
      lbl.Visible = true
    end
  else
    local path = "gui\\special\\tianti\\rank\\"
    lbl.BackImage = path .. nx_string(rank) .. ".png"
    lbl.Visible = true
  end
end
function on_btn_more_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_rank\\form_rank_main")
  local rang_form = nx_value("form_stage_main\\form_rank\\form_rank_main")
  if not nx_is_valid(rang_form) then
    return
  end
  nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", rang_form, "rank_17_match_win_net")
end
function on_recovry_show(form)
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_1.Visible then
    form.show_gb = form.groupbox_1
  elseif form.groupbox_6.Visible then
    form.show_gb = form.groupbox_6
  end
end
function on_btn_wycx_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  switch_manager:OpenUrl(URL_TYPE_REVENGE_URL)
end
