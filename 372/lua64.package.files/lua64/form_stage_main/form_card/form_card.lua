require("util_gui")
require("role_composite")
require("util_static_data")
require("define\\sysinfo_define")
require("tips_data")
local image_lable = "\\gui\\special\\card\\"
local inmage_path = "gui\\language\\ChineseS\\card\\"
local inmage_backgroud = "gui\\language\\ChineseS\\card\\0.png"
local FORM_CARD = "form_stage_main\\form_card\\form_card"
local CARD_FILL_PATH = "share\\Rule\\card.ini"
local CARD_FILL_STATIC_INFO_PATH = "share\\Item\\ItemArtStatic.ini"
local flag_no_open = 0
local flag_open = 1
local flag_no_active = 2
local CARD_HEIGHT = 168
local CARD_WIDTH = 130
local CARDS_LEFT = 65
local cards_space = 40
local CARD_MAIN_TYPE_WEAPON = 1
local CARD_MAIN_TYPE_EQUIP = 2
local CARD_MAIN_TYPE_HORSE = 3
local CARD_MAIN_TYPE_OTHENR = 4
local CARD_MAIN_TYPE_DECORATE = 5
local ITEMTYPE_WEAPON_BLADE = 101
local ITEMTYPE_WEAPON_SWORD = 102
local ITEMTYPE_WEAPON_THORN = 103
local ITEMTYPE_WEAPON_SBLADE = 104
local ITEMTYPE_WEAPON_SSWORD = 105
local ITEMTYPE_WEAPON_STHORN = 106
local ITEMTYPE_WEAPON_STUFF = 107
local ITEMTYPE_WEAPON_COSH = 108
local EQUIP_SUB_TYPE_SUIT = 1
local EQUIP_SUB_TYPE_CLOTH = 2
local EQUIP_SUB_TYPE_HAT = 3
local EQUIP_SUB_TYPE_SHOSE = 4
local DECORATE_SUB_TYPE_ARM = 1
local DECORATE_SUB_TYPE_WAIST = 2
local DECORATE_SUB_TYPE_BACK = 3
local DECORATE_SUB_TYPE_PIFENG = 4
local DECORATE_SUB_TYPE_FACE = 5
local CLIENT_CUSTOMMSG_CARD = 180
local CLIENT_CUSTOMMSG_CARD_USE = 0
local CLIENT_CUSTOMMSG_CARD_CANCEL = 1
local PAGE_COUNT = 20
local CARD_MAX_COUNT = 1000
local g_select_author = 0
local g_select_book = 0
local max_info_count = 12
local lbl_top_percent = 0
local lbl_left_percent = 0
local card_info_table = {}
local card_id_table = {}
local card_used_info_table = {}
local config_cloth_table = {}
function main_form_init(form)
  form.Fixed = false
  form.cur_page = 1
  form.max_page = 0
  form.node_choose_state = 0
  form.actor2 = nil
  form.refresh_time = 0
  form.face_effect_id = ""
end
function on_main_form_open(form)
  turn_to_full_screen(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  init_control(form)
  init_tree(form)
  show_all_card(form)
  get_uesd_card_list(form)
  form.combobox_pinjie.OnlySelect = true
  form.combobox_pinjie.DropListBox:ClearString()
  form.combobox_pinjie.DropListBox:AddString(gui.TextManager:GetText("ui_card_state_0"))
  for i = 1, 4 do
    form.combobox_pinjie.DropListBox:AddString(gui.TextManager:GetText("ui_card_level_" .. nx_string(i)))
    form.combobox_pinjie.DropListBox.SelectIndex = 0
    form.selectmapid = i
  end
  form.combobox_pinjie.Text = nx_widestr(gui.TextManager:GetText("ui_card_state_0"))
  form.grb_prview.Visible = false
  local grid_card = form.grid_card
  local grid_count = grid_card.RowNum * grid_card.ClomnNum
  grid_card.beginindex = 0
  grid_card.endindex = 6
  form.textgrid_author_list:BeginUpdate()
  form.textgrid_author_list.ColCount = 2
  form.textgrid_author_list:SetColWidth(0, 100)
  form.textgrid_author_list:SetColWidth(1, 0)
  form.textgrid_author_list:ClearRow()
  form.textgrid_author_list:EndUpdate()
  form.textgrid_book_list:BeginUpdate()
  form.textgrid_book_list.ColCount = 2
  form.textgrid_book_list:SetColWidth(1, 0)
  form.textgrid_book_list:ClearRow()
  init_grid_author_list(form)
  form.textgrid_book_list:EndUpdate()
  get_statistic_card_number(form)
  data_bind_prop(form)
  show_role_model(form)
  reset_control_layer(form.groupbox_centre)
  form.role_box.Transparent = true
  form.btn_show_gb.Visible = false
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_card\\form_card_skill", "show_form_cardskill")
  del_data_bind_prop(form)
  if nx_find_custom(form.role_box.Scene, "terrain") and nx_is_valid(form.role_box.Scene.Terrain) then
    form.role_box.Scene:Delete(self.role_box.Scene.Terrain)
  end
  nx_destroy(form)
end
function on_main_form_shut(form)
  if nx_is_valid(form.role_box) then
    if nx_find_custom(form, "actor2") and nx_is_valid(form.actor2) then
      form.role_box.Scene:Delete(form.actor2)
    end
    if nx_find_custom(form.role_box.Scene, "terrain") and nx_is_valid(form.role_box.Scene.Terrain) then
      form.role_box.Scene:Delete(self.role_box.Scene.Terrain)
    end
    nx_execute("scene", "delete_scene", form.role_box.Scene)
  end
end
function on_size_change()
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_card\\form_card")
  if nx_is_valid(form) then
    turn_to_full_screen(form)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function init_control(form)
  for i = 1, PAGE_COUNT do
    local control_name = "btn_card_" .. nx_string(i)
    local control = form.groupbox_centre:Find(control_name)
    if nx_is_valid(control) then
      control.card_id = 0
      control.Visible = false
    end
  end
  form.textgrid_author_list.Visible = false
  form.textgrid_book_list.Visible = false
  form.groupbox_centre.top_card = ""
  is_resort = true
  lbl_top_percent = (form.lbl_used_big.Top - form.btn_card_big.Top) / form.btn_card_big.Height
  lbl_left_percent = (form.lbl_used_big.Left - form.btn_card_big.Left) / form.btn_card_big.Width
  form.lbl_used_small.Visible = false
  form.lbl_used_big.Visible = false
  form.lbl_fog.Visible = false
end
function data_bind_prop(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("CardRec", form, nx_current(), "on_update_card_rec")
    databinder:AddTableBind("UseCardRec", form, nx_current(), "on_table_operat")
  end
end
function del_data_bind_prop(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("CardRec", form)
    databinder:DelTableBind("UseCardRec", form)
  end
end
function init_tree(form)
  form.groupscrollbox_left:DeleteAll()
  local gui = nx_value("gui")
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local control = gui:Create("TreeViewEx")
  control.Name = "tree_card_type"
  control.Left = 0
  control.Top = 0
  control.Width = form.groupscrollbox_left.Width
  control.NoFrame = true
  control.IsNoDrawRoot = true
  control.BackColor = "0,0,0,0"
  control.ForeColor = "255,255,255,255"
  control.TreeLineColor = "0,0,0,0"
  control.type = 2
  control.NodeExpandDraw = "gui\\special\\sns_new\\tree_expand.png"
  control.NodeCloseDraw = "gui\\special\\sns_new\\tree_close.png"
  local main_type_list = collect_card_manager:GetMainTypeList()
  local main_type_num = table.getn(main_type_list)
  local rootNode = control:CreateRootNode(nx_widestr(n))
  rootNode.type_string = "0-0"
  for n = 1, main_type_num do
    local main_type = main_type_list[n]
    local main_name = gui.TextManager:GetFormatText("ui_card_main_" .. nx_string(main_type))
    local mainNode = rootNode:CreateNode(nx_widestr(main_name))
    mainNode.Font = "font_btn"
    selectedNode = mainNode
    mainNode.type_string = nx_string(main_type) .. "-0"
    mainNode.TextOffsetY = 4
    mainNode.ItemHeight = 26
    mainNode.NodeBackImage = "gui\\special\\sns_new\\tree_2_out.png"
    mainNode.NodeFocusImage = "gui\\special\\sns_new\\tree_2_on.png"
    mainNode.NodeSelectImage = "gui\\special\\sns_new\\tree_2_on.png"
    mainNode.ExpandCloseOffsetX = 113
    mainNode.ExpandCloseOffsetY = 8
    mainNode.NodeOffsetY = 3
    local sub_type_list = collect_card_manager:GetSubTypeList(main_type)
    local sub_type_num = table.getn(sub_type_list)
    for m = 1, sub_type_num do
      local sub_type = sub_type_list[m]
      if 0 < sub_type then
        local sub_name = gui.TextManager:GetFormatText("ui_card_" .. nx_string(main_type) .. "_" .. nx_string(sub_type))
        local node = mainNode:CreateNode(nx_widestr(sub_name))
        node.Font = "font_text"
        node.type_string = nx_string(main_type) .. "-" .. nx_string(sub_type)
        node.TextOffsetX = 15
        node.TextOffsetY = 4
        node.ItemHeight = 24
        node.NodeOffsetY = 3
        node.NodeFocusImage = "gui\\special\\sns_new\\tree_2_on.png"
        node.NodeSelectImage = "gui\\special\\sns_new\\tree_2_on.png"
      end
    end
    rootNode.Expand = true
    if n == 1 then
      mainNode.Expand = true
    else
      mainNode.Expand = false
    end
    local list = control:GetAllNodeList()
    local count = table.getn(list)
    local container_height = form.groupscrollbox_left.Height
    local control_height = control.ItemHeight * (count - 1)
    if container_height < control_height then
      control.Height = control_height
    else
      control.Height = container_height
    end
  end
  form.groupscrollbox_left:Add(control)
  nx_bind_script(control, nx_current())
  nx_callback(control, "on_expand_changed", "on_expand_changed")
  nx_callback(control, "on_mouse_in_node", "on_mouse_in_node")
  nx_callback(control, "on_mouse_out_node", "on_mouse_out_node")
  nx_callback(control, "on_left_click", "on_left_click")
end
function on_left_click(self, node)
  local form = self.ParentForm
  if not nx_is_valid(node) then
    return
  end
  if node.Level == 1 then
    node.Expand = not node.Expand
    on_expand_changed(self, node)
  end
  if form.node_choose_state == 0 then
    if nx_find_custom(node, "type_string") then
      form.cur_page = 1
      choose_card(form)
    end
    form.node_choose_state = 1
    node.ForeColor = "255,255,180,40"
    if node.Level == 2 and node.ImageIndex ~= 2 then
      node.ImageIndex = 0
    end
  else
    form.node_choose_state = 0
    node.ForeColor = "255,255,255,255"
    if node.Level == 2 and node.ImageIndex ~= 2 then
      node.ImageIndex = 1
    end
    local tree_name = "tree_card_type"
    local tree = form.groupscrollbox_left:Find(tree_name)
    if nx_is_valid(tree) then
      local selected_node = tree.SelectNode
      if nx_is_valid(selected_node) then
        tree.SelectNode = tree.RootNode
      end
    end
  end
end
function on_mouse_in_node(self, node)
  local form = self.ParentForm
  if node ~= nil then
    node.ForeColor = "255,255,180,40"
    if node.Level == 2 and node.ImageIndex ~= 2 then
      node.ImageIndex = 0
    end
  end
  local pic_name = "pic_" .. nx_string(self.RootNode.Text)
  local pic_obj = form.groupscrollbox_left:Find(pic_name)
  if nx_is_valid(pic_obj) then
    local photo = pic_obj.Image
    pic_obj.Image = string.gsub(photo, "_bc.png", ".png")
  end
  form.node_choose_state = 0
end
function on_mouse_out_node(self, node)
  local form = self.ParentForm
  if node ~= nil then
    node.ForeColor = "255,255,255,255"
    if node.Level == 2 and node.ImageIndex ~= 2 then
      node.ImageIndex = 1
    end
  end
  local pic_name = "pic_" .. nx_string(self.RootNode.Text)
  local pic_obj = form.groupscrollbox_left:Find(pic_name)
  if nx_is_valid(pic_obj) then
    local photo = pic_obj.Image
    pic_obj.Image = string.gsub(photo, ".png", "_bc.png")
  end
  form.node_choose_state = 0
end
function on_expand_changed(self, node)
  local form = self.ParentForm
  local list = self:GetAllNodeList()
  local count = table.getn(list)
  if node.Expand then
    for i = 1, count do
      local tree_node = list[i]
      if nx_is_valid(tree_node) and tree_node.Level == 1 and tree_node.Text ~= node.Text then
        tree_node.Expand = false
      end
    end
  end
  local container_height = form.groupscrollbox_left.Height
  local control_height = self.ItemHeight * (count - 1)
  if container_height < control_height then
    self.Height = control_height
  else
    self.Height = container_height
  end
end
function on_btn_default_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.textgrid_author_list.Visible = true
end
function init_grid_author_list(form)
  if not nx_is_valid(form) then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local author_list = collect_card_manager:GetAuthorList()
  local author_count = table.getn(author_list)
  if author_count < 1 then
    return
  end
  local gui = nx_value("gui")
  form.textgrid_author_list:BeginUpdate()
  form.textgrid_author_list:ClearRow()
  for i = 1, author_count do
    local row = form.textgrid_author_list:InsertRow(-1)
    local author = gui.TextManager:GetFormatText("ui_card_author_" .. author_list[i])
    form.textgrid_author_list:SetGridText(row, 0, nx_widestr(author))
    form.textgrid_author_list:SetGridText(row, 1, nx_widestr(author_list[i]))
  end
  form.textgrid_author_list:EndUpdate()
end
function on_btn_card_click(btn)
  local form = btn.ParentForm
  local new_time = nx_function("ext_get_tickcount")
  if new_time - form.refresh_time < 1000 then
    return 0
  end
  form.refresh_time = new_time
  local gui = nx_value("gui")
  local parent = btn.Parent
  local form = btn.ParentForm
  form.grb_prview.Visible = false
  if parent.top_card ~= "" and btn.Name ~= parent.top_card then
    return
  end
  if not nx_find_custom(btn, "card_id") then
    return
  end
  local card_id = btn.card_id
  if nx_int(card_id) <= nx_int(0) or nx_int(card_id) > nx_int(CARD_MAX_COUNT) then
    local info = gui.TextManager:GetText("90205")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  if form.grb_prview.Visible == false then
    form.grb_prview.Visible = true
    form:ToFront(form.lbl_fog)
    form.lbl_fog.Visible = true
    form:ToFront(form.groupbox_right)
    form:ToFront(form.grb_prview)
    form:ToFront(form.btn_1)
    form.btn_card_big.NormalImage = btn.NormalImage
    form.btn_card_big.card_id = btn.card_id
  end
  local is_used = collect_card_manager:IsCardUsed(nx_int(card_id))
  if is_used then
    form.lbl_used_big.Visible = true
    form.btn_use.Visible = false
    form.btn_reback.Visible = false
  else
    form.lbl_used_big.Visible = false
    form.btn_use.Visible = true
    form.btn_reback.Visible = true
  end
  card_info_table = {}
  card_info_table = collect_card_manager:GetCardInfo(btn.card_id)
  local length = table.getn(card_info_table)
  if length < max_info_count then
    return
  end
  local card_id = card_info_table[1]
  local main_type = card_info_table[2]
  local level = card_info_table[5]
  local author = card_info_table[6]
  local book = card_info_table[7]
  local config_id = card_info_table[8]
  local condition = card_info_table[9]
  local female_model = card_info_table[10]
  local male_model = card_info_table[11]
  local flag = card_info_table[12]
  local sub_type = card_info_table[13]
  form.btn_card_big.BlendColor = "255,255,255,255"
  if nx_int(flag) == nx_int(0) then
    form.btn_use.Visible = false
    form.btn_reback.Visible = false
    return false
  end
  if nx_int(level) <= nx_int(3) and form.btn_use.Visible then
    form.btn_use.card_id = btn.card_id
    form.btn_reback.card_id = btn.card_id
  else
    form.btn_use.Visible = false
    form.btn_reback.Visible = false
  end
  delete_face_effect(form)
  if main_type == CARD_MAIN_TYPE_WEAPON then
    show_weapon(form, config_id, card_id)
  elseif main_type == CARD_MAIN_TYPE_EQUIP then
    show_cloth(form, female_model, male_model)
  elseif main_type == CARD_MAIN_TYPE_HORSE then
    show_mount(form, female_model, male_model)
  elseif main_type == CARD_MAIN_TYPE_DECORATE then
    if nx_int(sub_type) == nx_int(DECORATE_SUB_TYPE_FACE) then
      add_face_effect(form, card_id)
    elseif nx_int(sub_type) == nx_int(DECORATE_SUB_TYPE_PIFENG) then
      show_cloth(form, female_model, male_model)
    elseif nx_int(sub_type) == nx_int(DECORATE_SUB_TYPE_WAIST) then
      show_cloth(form, female_model, male_model)
    else
      show_decorate(form, female_model, male_model)
    end
  end
  local is_active = collect_card_manager:IsGetCard(nx_int(card_id))
  if is_active == false then
    form.btn_use.Visible = false
    form.btn_reback.Visible = false
    if flag == flag_no_active then
      form.btn_card_big.BlendColor = "255,190,190,190"
    end
    return
  end
end
function on_btn_use_click(btn)
  if not nx_find_custom(btn, "card_id") then
    return
  end
  local card_id = btn.card_id
  if nx_int(card_id) == nx_int(0) then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local bsucess = collect_card_manager:OnUseCrad(nx_int(card_id))
  if bsucess == true then
    local form = btn.ParentForm
    form.lbl_used_big.Visible = true
  end
end
function on_btn_reback_click(btn)
  if not nx_find_custom(btn, "card_id") then
    return
  end
  local card_id = btn.card_id
  if nx_int(card_id) == nx_int(0) then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local bsucess = collect_card_manager:OnRebackCrad(nx_int(card_id))
  if bsucess == true then
    local form = btn.ParentForm
    form.lbl_used_big.Visible = false
    form.grb_prview.Visible = true
    if form.grb_prview.Visible == true then
      form.grb_prview.Visible = false
      form.btn_use.Visible = false
      form.btn_reback.Visible = false
      form.lbl_fog.Visible = form.grb_prview.Visible
      form:ToFront(form.groupbox_centre)
    end
    show_role_model(form)
  end
end
function on_btn_pageup_click(btn)
  local form = btn.ParentForm
  if card_id_table == nil then
    return
  end
  local page = form.cur_page - 1
  if page <= 0 then
    return
  end
  form.cur_page = page
  refresh_card(card_id_table, page)
  form.combobox_page.Text = nx_widestr(page)
end
function on_btn_pagedown_click(btn)
  local form = btn.ParentForm
  if card_id_table == nil then
    return
  end
  local page = form.cur_page + 1
  if page <= 0 then
    return
  end
  if page > form.max_page then
    return
  end
  form.cur_page = page
  refresh_card(card_id_table, page)
  form.combobox_page.Text = nx_widestr(page)
end
function on_btn_allcard_click(btn)
  local form = btn.ParentForm
  local tree = form.groupscrollbox_left:Find("tree_card_type")
  if nx_is_valid(tree) then
    tree.SelectNode = tree.RootNode
  end
  show_all_card(form)
end
function on_btn_left_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_left_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_left_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = 3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
  end
end
function on_btn_right_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_right_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_right_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = -3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
  end
end
function on_btn_card_big_click(btn)
  local form = btn.ParentForm
  if form.grb_prview.Visible == true then
    form.grb_prview.Visible = false
    form.btn_use.Visible = false
    form.btn_reback.Visible = false
    form.lbl_fog.Visible = form.grb_prview.Visible
    form:ToFront(form.groupbox_centre)
  end
  show_role_model(form)
end
function on_combobox_page_selected(self)
  local form = self.ParentForm
  form.cur_page = nx_int(self.DropListBox.SelectIndex + 1)
  refresh_card(card_id_table, form.cur_page)
end
function on_combobox_pinjie_selected(self)
  local form = self.ParentForm
  choose_card(form)
  chang_combobox_page(form)
end
function on_textgrid_author_list_mousein_row_changed(grid, new_row, old_row)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local author = grid:GetGridText(new_row, 1)
  g_select_author = author
  if nx_int(author) < nx_int(1) then
    form.textgrid_book_list.Visible = false
    return
  end
  local book_list = collect_card_manager:GetAuthorBookList(nx_int(author))
  local book_count = table.getn(book_list)
  if nx_int(book_count) < nx_int(1) then
    form.textgrid_book_list.Visible = false
    return
  end
  local gui = nx_value("gui")
  form.textgrid_book_list:BeginUpdate()
  form.textgrid_book_list:ClearRow()
  for i = 1, book_count do
    local row = form.textgrid_book_list:InsertRow(-1)
    local book_name = "ui_card_book_" .. nx_string(author) .. "_" .. nx_string(book_list[i])
    local text = gui.TextManager:GetText(book_name)
    form.textgrid_book_list:SetGridText(row, 0, nx_widestr(text))
    form.textgrid_book_list:SetGridText(row, 1, nx_widestr(book_list[i]))
  end
  form.textgrid_book_list:EndUpdate()
  form.textgrid_book_list.Visible = true
  form.textgrid_book_list:ClearSelect()
  grid.Visible = true
  grid:SetGridBackColor(new_row, 0, "255,255,255,0")
  grid:SetGridBackColor(old_row, 0, "0,255,255,0")
  grid:ClearSelect()
end
function on_textgrid_book_list_mousein_row_changed(grid, new_row, old_row)
  grid:SetGridBackColor(new_row, 0, "255,255,255,0")
  grid:SetGridBackColor(old_row, 0, "0,255,255,0")
end
function on_textgrid_author_list_select_row(grid, new_row)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local main_type, sub_type, status, level, author, book = get_all_query_param()
  card_id_table = {}
  g_select_author = grid:GetGridText(new_row, 1)
  card_id_table = collect_card_manager:OnChooseCard(nx_int(0), nx_int(0), nx_int(status), nx_int(level), nx_int(g_select_author), nx_int(book))
  refresh_card(card_id_table, 1)
  g_select_author = 0
end
function on_textgrid_author_list_lost_capture(self)
  local form = self.ParentForm
  if form.textgrid_book_list.Visible == false then
    form.textgrid_author_list.Visible = false
  else
    form.textgrid_author_list.Visible = true
    form.textgrid_book_list.Visible = true
  end
end
function on_textgrid_book_list_lost_capture(self)
  local form = self.ParentForm
  if form.textgrid_book_list.Visible == true then
    form.textgrid_author_list.Visible = true
    form.textgrid_book_list.Visible = false
  else
  end
  g_select_author = 0
  g_select_book = 0
end
function on_textgrid_book_list_select_row(grid, row)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  g_select_book = nx_int(grid:GetGridText(row, 1))
  local main_type, sub_type, status, level, author, book = get_all_query_param()
  card_id_table = {}
  card_id_table = collect_card_manager:OnChooseCard(nx_int(0), nx_int(0), nx_int(status), nx_int(level), nx_int(g_select_author), nx_int(book))
  refresh_card(card_id_table, 1)
  form.textgrid_author_list.Visible = false
  form.textgrid_book_list.Visible = false
  g_select_author = 0
  g_select_book = 0
end
function on_grid_card_rightclick_grid(self, index)
  local form = self.ParentForm
  if self:IsEmpty(index) then
    return
  end
  local card_id = self:GetBindIndex(index)
  if nx_int(card_id) == nx_int(0) then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  collect_card_manager:OnCancelCrad(nx_int(card_id))
  show_role_model(form)
end
function on_grid_card_select_changed(self, index)
  local card_id = self:GetBindIndex(index)
  local form = self.ParentForm
  if nx_int(card_id) == nx_int(0) then
    return
  end
  if self:IsEmpty(index) then
    return
  end
  card_used_info_table = {}
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  card_used_info_table = collect_card_manager:GetCardInfo(card_id)
  local length = table.getn(card_used_info_table)
  if length < max_info_count then
    return
  end
  local card_id = card_used_info_table[1]
  local main_type = card_used_info_table[2]
  local level = card_used_info_table[5]
  local author = card_used_info_table[6]
  local book = card_used_info_table[7]
  local config_id = card_used_info_table[8]
  local condition = card_used_info_table[9]
  local female_model = card_used_info_table[10]
  local male_model = card_used_info_table[11]
  local flag = card_info_table[12]
  local sub_type = card_info_table[13]
  delete_face_effect(form)
  if main_type == CARD_MAIN_TYPE_WEAPON then
    show_weapon(form, config_id, card_id)
  elseif main_type == CARD_MAIN_TYPE_EQUIP then
    show_cloth(form, female_model, male_model)
  elseif main_type == CARD_MAIN_TYPE_HORSE then
    show_mount(form, female_model, male_model)
  elseif main_type == CARD_MAIN_TYPE_DECORATE then
    if nx_int(sub_type) == nx_int(DECORATE_SUB_TYPE_FACE) then
      add_face_effect(form, card_id)
    elseif nx_int(sub_type) == nx_int(DECORATE_SUB_TYPE_PIFENG) then
      show_cloth(form, female_model, male_model)
    elseif nx_int(sub_type) == nx_int(DECORATE_SUB_TYPE_WAIST) then
      show_cloth(form, female_model, male_model)
    else
      show_decorate(form, female_model, male_model)
    end
  end
  show_tips(form, main_type, condition, level, author, book)
end
function on_grid_card_mousein_grid(self, index)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local card_id = self:GetItemName(nx_int(index))
  if nx_ws_length(nx_widestr(card_id)) <= 0 then
    nx_execute("tips_game", "show_text_tip", gui.TextManager:GetText("tips_card_equip_pos_" .. nx_string(index)), self:GetMouseInItemLeft(), self:GetMouseInItemTop(), 0, form)
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return 0
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  if nx_is_valid(item) then
    local config_id = get_ini_prop(CARD_FILL_PATH, card_id, "ConfigID", "0")
    local card_name = get_ini_prop(CARD_FILL_PATH, card_id, "Name", "0")
    local item_type = get_ini_prop(CARD_FILL_PATH, card_id, "ItemType", "0")
    local item_photo = get_ini_prop(CARD_FILL_STATIC_INFO_PATH, card_id, "Photo", "0")
    item.ConfigID = nx_string(card_id)
    item.ItemType = nx_int(89)
    local str_id = "card_item_" .. nx_string(card_id)
    item.card_name = gui.TextManager:GetText(str_id)
    item.card_Item_type = nx_int(item_type)
    item.card_photo = nx_string("gui\\special\\card\\" .. nx_string(card_id) .. ".png")
    item.is_card = true
    nx_execute("tips_game", "show_goods_tip", item, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), 40, 40, self.ParentForm)
  end
end
function on_grid_card_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_btn_card_get_capture(btn)
  local parent = btn.Parent
  if not nx_is_valid(parent) then
    return
  end
  parent.top_card = btn.Name
  reset_control_layer(parent)
  resize_card(btn, 1.25)
  parent:ToFront(btn)
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local is_used = collect_card_manager:IsCardUsed(nx_int(btn.card_id))
  local form = btn.ParentForm
  if is_used then
    form.lbl_used_small.Top = btn.Top + btn.Height * lbl_top_percent
    form.lbl_used_small.Left = btn.Left + btn.Width * lbl_left_percent
    parent:ToFront(form.lbl_used_small)
    form.lbl_used_small.Visible = true
  else
    form.lbl_used_small.Visible = false
  end
end
function on_rbtn_status_checked_changed(rbtn)
  local form = rbtn.ParentForm
  choose_card(form)
end
function refresh_card(card_id_table, pageno)
  local form = nx_value(FORM_CARD)
  if not nx_is_valid(form) then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  form.lbl_used_small.Visible = false
  local begin_pos = (pageno - 1) * PAGE_COUNT + 1
  local end_pos = pageno * PAGE_COUNT
  local card_num = table.getn(card_id_table)
  if card_num == 0 then
    form.cur_page = 1
    form.max_page = 1
    form.combobox_page.Text = nx_widestr("")
    form.combobox_page.DropListBox:ClearString()
    form.lbl_pagenum.Text = nx_widestr("/0")
  end
  local records = card_num / 3
  if end_pos > records then
    end_pos = records
  end
  form.groupbox_centre.top_card = ""
  local index = 1
  for i = begin_pos, end_pos do
    local control_name = "btn_card_" .. nx_string(index)
    local card = form.groupbox_centre:Find(control_name)
    local base = (i - 1) * 3
    local card_id = card_id_table[1 + base]
    local get_state = card_id_table[2 + base]
    local open_flag = card_id_table[3 + base]
    local photo = ""
    if open_flag == flag_open or open_flag == flag_no_active then
      photo = nx_resource_path() .. inmage_path .. nx_string(card_id) .. ".png"
    else
      photo = inmage_backgroud
    end
    if nx_is_valid(card) then
      card.NormalImage = photo
      card.card_id = card_id
      card.Visible = true
      resize_card(card, 0, index)
      index = index + 1
      card.BlendColor = "255,255,255,255"
      local is_active = collect_card_manager:IsGetCard(nx_int(card_id))
      if is_active == false and open_flag == flag_no_active then
        card.BlendColor = "255,190,190,190"
      end
    end
  end
  if index <= PAGE_COUNT then
    for i = index, PAGE_COUNT do
      local control_name = "btn_card_" .. nx_string(i)
      local card = form.groupbox_centre:Find(control_name)
      if nx_is_valid(card) then
        card.NormalImage = inmage_backgroud
        card.card_id = 0
        card.Visible = false
        resize_card(card, 0, i)
        i = i + 1
      end
    end
  end
  reset_control_layer(form.groupbox_centre)
end
function show_all_card(form)
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local main_type, sub_type, status, level, author, book = get_all_query_param()
  form.cur_page = 1
  card_id_table = {}
  card_id_table = collect_card_manager:OnChooseCard(0, 0, status, level, 0, 0)
  refresh_card(card_id_table, 1)
  chang_combobox_page(form)
end
function get_card_id_by_index(form, index)
  if nx_int(index) < nx_int(1) or nx_int(index) > nx_int(PAGE_COUNT) then
    return 0
  end
  if not nx_is_valid(form) then
    return 0
  end
  local control_name = "btn_card_" .. nx_string(index)
  local control = form.groupbox_centre:Find(control_name)
  if nx_is_valid(control) then
    return nx_int(control.card_id)
  end
  return 0
end
function get_all_query_param()
  local form = nx_value(FORM_CARD)
  if not nx_is_valid(form) then
    return
  end
  local main_type, sub_type, status, level, author, book = 0, 0, 0, 0, 0, 0
  local tree_name = "tree_card_type"
  local tree = form.groupscrollbox_left:Find(tree_name)
  if nx_is_valid(tree) then
    local selected_node = tree.SelectNode
    if nx_is_valid(selected_node) then
      if nx_find_custom(selected_node, "type_string") then
        local type_string = selected_node.type_string
        local pos_begin, pos_end = string.find(type_string, "-")
        main_type = string.sub(type_string, 1, pos_begin - 1)
        sub_type = string.sub(type_string, pos_end + 1, -1)
      end
    else
      main_type = 0
      sub_type = 0
    end
  end
  if form.rbtn_status_1.Checked then
    status = 1
  else
    status = 0
  end
  level = nx_int(form.combobox_pinjie.DropListBox.SelectIndex)
  author = g_select_author
  book = g_select_book
  return main_type, sub_type, status, level, author, book
end
function show_role_model(form)
  local game_client = nx_value("game_client")
  local world = nx_value("world")
  local main_scene = world.MainScene
  if not nx_is_valid(form.role_box.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.role_box)
  end
  local scene = form.role_box.Scene
  local terrain = scene:Create("Terrain")
  scene.Terrain = terrain
  local game_effect = nx_create("GameEffect")
  nx_bind_script(game_effect, "game_effect", "game_effect_init", form.role_box.Scene)
  if not nx_is_valid(game_effect.Terrain) then
    game_effect.Terrain = form.role_box.Scene.Terrain
  end
  form.role_box.Scene.game_effect = game_effect
  local client_player = game_client:GetPlayer()
  local actor2 = form.actor2
  if nx_is_valid(actor2) then
    form.role_box.Scene:Delete(actor2)
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local actor2 = role_composite:CreateSceneObjectWithSubModel(form.role_box.Scene, client_player, false, false, false)
  if not nx_is_valid(actor2) then
    return
  end
  local game_visual = nx_value("game_visual")
  game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  form.actor2 = actor2
  nx_execute("util_gui", "util_add_model_to_scenebox", form.role_box, actor2)
  local scene = form.role_box.Scene
  local radius = 1.5
  scene.camera:SetPosition(-0.2, radius * 0.6, -radius * 2.5)
end
function show_mount(form, female_model, male_model)
  local actor2 = form.actor2
  if not nx_is_valid(actor2) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  role_composite:DeleteRideBase(actor2)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_ident = game_visual:QueryRoleClientIdent(actor2)
  local actor = game_client:GetSceneObj(nx_string(client_ident))
  if not nx_is_valid(actor) then
    return
  end
  local sex = actor:QueryProp("Sex")
  local mount = ""
  local mode = ""
  if sex == 0 then
    mount = female_model
  else
    mount = male_model
  end
  local model_name = ""
  local model_table = util_split_string(mount, ";")
  local count = table.getn(model_table)
  if count == 0 then
    return
  end
  for i = 1, count do
    local base_table = util_split_string(model_table[i], ":")
    if base_table ~= nil then
      local base_count = table.getn(base_table)
      if base_count == 2 then
        model_name = base_table[2]
        break
      end
    end
  end
  if 0 >= string.len(model_name) then
    return
  end
  if 0 < string.len(mount) then
    local role_composite = nx_value("role_composite")
    if not nx_is_valid(role_composite) then
      return
    end
    role_composite:CreateRideBase(actor2, model_name)
  end
  local action_module = nx_value("action_module")
  action_module:ClearState(actor2)
  action_module:BlendAction(actor2, "ride_stand", true, true)
  local scene = form.role_box.Scene
  local radius = 2.75
  local dist = 0
  scene.camera:SetPosition(0, radius * 0.6, -radius * 2.5)
  nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
end
function is_in_config_cloth_table(prop_name)
  local is_in = false
  if config_cloth_table == nil then
    return false
  end
  local len = table.getn(config_cloth_table)
  if nx_int(len) == nx_int(0) then
    return false
  end
  for i = 1, len do
    local name = config_cloth_table[i][1]
    if nx_string(name) == nx_string(prop_name) then
      return true
    end
  end
  return false
end
function reshresh_no_con_cloth(form)
  local actor2 = form.actor2
  if not nx_is_valid(actor2) then
    return
  end
  local prop_value = ""
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local is_in = is_in_config_cloth_table("Hat")
  if is_in == false then
    nx_execute("role_composite", "unlink_skin", actor2, "Hat")
    prop_value = client_player:QueryProp("Hair")
    reshresh_cloth(actor2, "Hat", prop_value)
  end
end
function show_cloth(form, female_model, male_model)
  local actor2 = form.actor2
  if not nx_is_valid(actor2) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  role_composite:DeleteRideBase(actor2)
  local action_module = nx_value("action_module")
  action_module:BlendAction(actor2, "stand", true, true)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_ident = game_visual:QueryRoleClientIdent(actor2)
  local actor = game_client:GetSceneObj(nx_string(client_ident))
  local sex = actor:QueryProp("Sex")
  local show_equip_type = actor:QueryProp("ShowEquipType")
  if nx_int(show_equip_type) ~= nx_int(0) then
    change_jianghu_cloth(actor2, sex)
  end
  local mode = ""
  if sex == 1 then
    model = female_model
  else
    model = male_model
  end
  local model_table = util_split_string(model, ";")
  local count = table.getn(model_table)
  if count == 0 then
    return
  end
  config_cloth_table = {}
  for i = 1, count do
    local base_table = util_split_string(model_table[i], ":")
    if base_table ~= nil then
      local base_count = table.getn(base_table)
      if base_count == 2 then
        local prop_name = base_table[1]
        local prop_value = base_table[2]
        if prop_name == "Hat" then
          nx_execute("role_composite", "unlink_skin", actor2, "Hat")
        elseif prop_name == "Shoes" then
          nx_execute("role_composite", "unlink_skin", actor2, "Shoes")
        elseif prop_name == "Cloth" then
          nx_execute("role_composite", "unlink_skin", actor2, "Cloth")
        elseif prop_name == "Pants" then
          nx_execute("role_composite", "unlink_skin", actor2, "Pants")
        elseif prop_name == "Cloak" then
          nx_execute("role_composite", "unlink_skin", actor2, "Cloak")
        elseif prop_name == "Waist" then
          nx_execute("role_composite", "unlink_skin", actor2, "Waist")
        end
        table.insert(config_cloth_table, {prop_name})
        reshresh_cloth(actor2, prop_name, prop_value)
      end
    end
  end
  reshresh_no_con_cloth(form)
  local scene = form.role_box.Scene
  local radius = 1.5
  local dist = 0
  scene.camera:SetPosition(-0.2, radius * 0.6, -radius * 2.5)
  nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
end
function reshresh_cloth(actor2, prop_name, prop_value)
  if not nx_is_valid(actor2) then
    return
  end
  if string.len(prop_name) <= 0 or string.len(prop_value) <= 0 then
    return
  end
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_ident = game_visual:QueryRoleClientIdent(actor2)
  local actor = game_client:GetSceneObj(nx_string(client_ident))
  if prop_name == "Hat" then
    nx_execute("role_composite", "link_skin", actor2, "hat", prop_value .. ".xmod")
  elseif prop_name == "Cloth" then
    nx_execute("role_composite", "link_skin", actor2, "cloth", prop_value .. ".xmod")
    nx_execute("role_composite", "link_skin", actor2, "cloth_h", prop_value .. "_h" .. ".xmod")
  elseif prop_name == "Shoes" then
    nx_execute("role_composite", "link_skin", actor2, "shoes", prop_value .. ".xmod")
  elseif prop_name == "Pants" then
    nx_execute("role_composite", "link_skin", actor2, "pants", prop_value .. ".xmod")
  elseif prop_name == "Cloak" then
    nx_execute("role_composite", "link_skin", actor2, "cloak", prop_value .. ".xmod")
  elseif prop_name == "Waist" then
    nx_execute("role_composite", "link_skin", actor2, "waist", prop_value .. ".xmod")
  end
end
function show_weapon(form, weapon, card_id)
  local actor2 = form.actor2
  if not nx_is_valid(actor2) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local action_module = nx_value("action_module")
  action_module:ClearState(actor2)
  role_composite:DeleteRideBase(actor2)
  actor2.card_id = card_id
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  temp_table = {}
  temp_table = collect_card_manager:GetCardInfo(card_id)
  local length = table.getn(temp_table)
  if length < max_info_count then
    return
  end
  local main_type = card_info_table[2]
  local sub_type = card_info_table[3]
  role_composite:RefreshCustomWeaponFormArtPack(actor2, weapon)
  if main_type == 1 and sub_type == 6 then
    local scene = form.role_box.Scene
    local radius = 1.8
    local dist = -0
    scene.camera:SetPosition(-0.2, radius * 0.6, -radius * 2.5)
    nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
  else
    local scene = form.role_box.Scene
    local radius = 1.5
    local dist = -0
    scene.camera:SetPosition(-0.2, radius * 0.6, -radius * 2.5)
    nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
  end
end
function get_item_info(configid, prop)
  local gui = nx_value("gui")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return ""
  end
  if not ItemQuery:FindItemByConfigID(nx_string(configid)) then
    return ""
  end
  return ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string(prop))
end
function chang_combobox_page(form)
  if card_id_table == nil then
    return
  end
  local length = table.getn(card_id_table)
  if length == 0 then
    return
  end
  form.combobox_page.DropListBox:ClearString()
  local length = length / 3
  if length % PAGE_COUNT == 0 then
    sum_page = nx_int(length / PAGE_COUNT)
  else
    sum_page = nx_int(length / PAGE_COUNT) + 1
  end
  for i = 0, sum_page - 1 do
    form.combobox_page.DropListBox:AddString(nx_widestr(i + 1))
    form.combobox_page.DropListBox.SelectIndex = 1
    form.selectmapid = i + 1
  end
  form.combobox_page.Text = nx_widestr(1)
  form.lbl_pagenum.Text = nx_widestr("/") .. nx_widestr(sum_page)
  form.max_page = sum_page
end
function choose_card(form)
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local main_type, sub_type, status, level, author, book = get_all_query_param()
  card_id_table = {}
  card_id_table = collect_card_manager:OnChooseCard(nx_int(main_type), nx_int(sub_type), nx_int(status), nx_int(level), nx_int(author), nx_int(book))
  refresh_card(card_id_table, 1)
  chang_combobox_page(form)
end
function get_statistic_card_number(form)
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local statistic_table = collect_card_manager:StatisticCardNumber()
  local length = table.getn(statistic_table)
  if length < 8 then
    return
  end
  local all_level_1 = statistic_table[1]
  local all_level_2 = statistic_table[2]
  local all_level_3 = statistic_table[3]
  local all_level_4 = statistic_table[4]
  local get_level_1 = statistic_table[5]
  local get_level_2 = statistic_table[6]
  local get_level_3 = statistic_table[7]
  local get_level_4 = statistic_table[8]
  local sum_all = all_level_2 + all_level_3 + all_level_4
  local sum_get = get_level_2 + get_level_3 + get_level_4
  form.lbl_sum.Text = nx_widestr(sum_get) .. nx_widestr("/") .. nx_widestr(sum_all)
  if sum_all ~= 0 then
    local ratio = sum_get / sum_all
    form.lbl_ratio.Text = nx_widestr(nx_decimals(ratio * 100, 2)) .. nx_widestr("%")
  else
    form.lbl_ratio.Text = nx_widestr("0%")
  end
  form.lbl_level_one.Text = nx_widestr(get_level_1)
  form.lbl_level_two.Text = nx_widestr(get_level_2) .. nx_widestr("/") .. nx_widestr(all_level_2)
  form.lbl_level_three.Text = nx_widestr(get_level_3) .. nx_widestr("/") .. nx_widestr(all_level_3)
  form.lbl_level_four.Text = nx_widestr(get_level_4) .. nx_widestr("/") .. nx_widestr(all_level_4)
end
function show_tips(form, main_type, condition, level, author, book)
  local gui = nx_value("gui")
  form.lbl_pinjie.Text = nx_widestr(gui.TextManager:GetText("ui_card_level_" .. nx_string(level)))
  form.lbl_author.Text = nx_widestr(gui.TextManager:GetFormatText("ui_card_author_" .. nx_string(author)))
  local book_name = "ui_card_book_" .. nx_string(author) .. "_" .. nx_string(book)
  form.lbl_book.Text = nx_widestr(gui.TextManager:GetFormatText(book_name))
  show_card_info(form, condition)
end
function show_card_info(form, condition)
  form.mltbox_condition:Clear()
  if condition == nil then
    return
  end
  local mltbox_condition = form.mltbox_condition
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return
  end
  local condition_table = util_split_string(condition, ";")
  local count = table.getn(condition_table)
  if count == 0 then
    return
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  local gui = nx_value("gui")
  local and_condition_desc = gui.TextManager:GetText("ui_and_condition_desc")
  if 0 < count then
    mlt_index = mltbox_condition:AddHtmlText(and_condition_desc, nx_int(-1))
    mltbox_condition:SetHtmlItemSelectable(mlt_index, false)
    for i = 1, count do
      local condition_id = condition_table[i]
      if condition_id ~= "" then
        local condition_decs = gui.TextManager:GetText(condition_manager:GetConditionDesc(nx_int(condition_id)))
        local b_ok = condition_manager:CanSatisfyCondition(player, player, condition_id)
        local real_text = color_text(condition_decs, b_ok)
        mlt_index = mltbox_condition:AddHtmlText(real_text, nx_int(-1))
        mltbox_condition:SetHtmlItemSelectable(mlt_index, false)
      end
    end
  end
end
function color_text(src, b_ok)
  local dest = nx_widestr("")
  if b_ok then
    dest = dest .. nx_widestr("<font color=\"#006600\">")
  else
    dest = dest .. nx_widestr("<font color=\"#ff0000\">")
  end
  dest = dest .. nx_widestr(src) .. nx_widestr("</font>")
  local ret = nx_widestr(dest)
  return ret
end
function on_table_operat(form, tablename, ttype, line, col)
  if col == 0 or col == 11 or nx_string(ttype) == nx_string("clear") or nx_string(ttype) == nx_string("del") or nx_string(ttype) == nx_string("add") then
    get_uesd_card_list(form)
  end
end
function get_uesd_card_list(form)
  form.grid_card:Clear()
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local usedcard_list = collect_card_manager:GetUsedCardList()
  if usedcard_list == nil then
    return
  end
  local count = table.getn(usedcard_list)
  local grid = form.grid_card
  for i = 1, count do
    local card_id = usedcard_list[i]
    local info_table = collect_card_manager:GetCardInfo(card_id)
    local length = table.getn(info_table)
    if length < max_info_count then
      return
    end
    local main_type = info_table[2]
    local sub_type = info_table[3]
    local item_type = info_table[4]
    local photo = image_lable .. nx_string(card_id) .. ".png"
    if card_id ~= nil then
      if main_type == CARD_MAIN_TYPE_WEAPON then
        if item_type == ITEMTYPE_WEAPON_BLADE then
          grid:AddItem(0, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(0, card_id)
        elseif item_type == ITEMTYPE_WEAPON_SWORD then
          grid:AddItem(1, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(1, card_id)
        elseif item_type == ITEMTYPE_WEAPON_THORN then
          grid:AddItem(2, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(2, card_id)
        elseif item_type == ITEMTYPE_WEAPON_SBLADE then
          grid:AddItem(3, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(3, card_id)
        elseif item_type == ITEMTYPE_WEAPON_SSWORD then
          grid:AddItem(4, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(4, card_id)
        elseif item_type == ITEMTYPE_WEAPON_STHORN then
          grid:AddItem(5, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(5, card_id)
        elseif item_type == ITEMTYPE_WEAPON_STUFF then
          grid:AddItem(6, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(6, card_id)
        elseif item_type == ITEMTYPE_WEAPON_COSH then
          grid:AddItem(7, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(7, card_id)
        end
      elseif main_type == CARD_MAIN_TYPE_EQUIP then
        grid:AddItem(8, photo, nx_widestr(card_id), nx_int(1), 0)
        grid:SetBindIndex(8, card_id)
      elseif main_type == CARD_MAIN_TYPE_HORSE then
        grid:AddItem(9, photo, nx_widestr(card_id), nx_int(1), 0)
        grid:SetBindIndex(9, card_id)
      elseif main_type == CARD_MAIN_TYPE_DECORATE then
        if sub_type == DECORATE_SUB_TYPE_ARM then
          grid:AddItem(10, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(10, card_id)
        elseif sub_type == DECORATE_SUB_TYPE_WAIST then
          grid:AddItem(11, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(11, card_id)
        elseif sub_type == DECORATE_SUB_TYPE_BACK then
          grid:AddItem(12, photo, nx_widestr(card_id), nx_int(1), 0)
          grid:SetBindIndex(12, card_id)
        end
      end
    end
  end
  update_card_name(form)
end
function on_update_card_rec(form, tablename, ttype, line, col)
  turn_to_full_screen(form)
  choose_card(form)
end
function reset_control_layer(parent)
  local pre_name = "btn_card_"
  local rule = "up"
  if parent.top_card == "" then
    rule = "down"
  end
  for i = 1, PAGE_COUNT do
    local control_name = pre_name .. nx_string(i)
    local control = parent:Find(control_name)
    if nx_is_valid(control) then
      if rule == "up" then
        parent:ToFront(control)
      else
        parent:ToBack(control)
      end
      resize_card(control, 0, i)
    end
    if control_name == parent.top_card then
      rule = "down"
    end
  end
end
function resize_card(card, multiple, ...)
  local old_top = card.Top
  local old_width = card.Width
  local bottom = card.Height + old_top
  if 0 < multiple then
    card.Height = card.Height * multiple
    card.Width = card.Width * multiple
    card.Top = bottom - card.Height
    card.Left = card.Left - (card.Width - old_width) / 2
  else
    local index = arg[1]
    card.Height = CARD_HEIGHT
    card.Width = CARD_WIDTH
    card.Top = bottom - card.Height
    card.Left = CARDS_LEFT + cards_space * ((index - 1) % 10)
  end
end
function turn_to_full_screen(self)
  local form = self
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Desktop.Width
  form.Height = gui.Desktop.Height
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Desktop.Width
  form.Height = gui.Desktop.Height
  form.lbl_bg_form.Width = form.Width
  form.lbl_bg_form.Height = form.Height
  form.lbl_fog.Width = form.Width
  form.lbl_fog.Height = form.Height
  form.groupbox_centre.Width = form.Width * 0.6
  cards_space = (form.groupbox_centre.Width - CARDS_LEFT * 2 - CARD_WIDTH) / 9
  refresh_card(card_id_table, form.cur_page)
  form.groupbox_centre.Left = (form.Width - form.groupbox_centre.Width) * 0.3
  form.groupbox_right.Width = form.groupbox_right.Height * 0.8
  form.groupbox_right.Left = -form.groupbox_right.Width
  form.groupscrollbox_left.Top = -form.groupscrollbox_left.Height
  form.role_box.Width = form.groupbox_right.Width - form.groupbox_grid.Width
  form.role_box.Height = form.groupbox_right.Height
  form.btn_left.Left = form.role_box.Width * 0.4
  form.btn_right.Left = form.role_box.Width * 0.8
  form.groupbox_grid.Top = (form.groupbox_right.Height - form.groupbox_grid.Height) / 2
end
function change_jianghu_cloth(actor2, sex)
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local jh_table = {}
  jh_table = collect_card_manager:GetClothModeList()
  local length = table.getn(jh_table)
  if length < 4 then
    return
  end
  local hat = jh_table[1]
  local cloth = jh_table[2]
  local pants = jh_table[3]
  local shoes = jh_table[4]
  nx_execute("role_composite", "unlink_skin", actor2, "Shoes")
  nx_execute("role_composite", "unlink_skin", actor2, "Cloth")
  nx_execute("role_composite", "unlink_skin", actor2, "Pants")
  local def_hat, def_cloth, def_pants, def_shoes = "", "", "", ""
  if nx_int(sex) == nx_int(0) then
    def_cloth = "obj\\char\\b_jianghu000\\b_cloth000"
    def_pants = "obj\\char\\b_jianghu000\\b_pants000"
    def_shoes = "obj\\char\\b_jianghu000\\b_shoes000"
  else
    def_cloth = "obj\\char\\g_jianghu000\\g_cloth000"
    def_pants = "obj\\char\\g_jianghu000\\g_pants000"
    def_shoes = "obj\\char\\g_jianghu000\\g_shoes000"
  end
  if string.len(cloth) == 0 then
    reshresh_cloth(actor2, "Cloth", def_cloth)
  else
    reshresh_cloth(actor2, "Cloth", cloth)
  end
  if string.len(pants) == 0 then
    reshresh_cloth(actor2, "Pants", def_cloth)
  else
    reshresh_cloth(actor2, "Pants", pants)
  end
  if string.len(shoes) == 0 then
    reshresh_cloth(actor2, "Shoes", def_pants)
  else
    reshresh_cloth(actor2, "Shoes", shoes)
  end
end
function update_card_name(form)
  local grid = form.grid_card
  local grid_count = grid.RowNum
  for i = 0, grid_count - 1 do
    local card_id = grid:GetItemName(nx_int(i))
    local control_name = form.groupbox_grid:Find("lbl_name_" .. nx_string(i))
    local control_stage = form.groupbox_grid:Find("lbl_stage_" .. nx_string(i))
    local card_name = util_text("card_item_" .. nx_string(card_id))
    if nx_is_valid(control_name) and nx_is_valid(control_name) then
      if 0 < string.len(nx_string(card_id)) then
        control_name.Text = card_name
        control_stage.Text = util_text("ui_equip")
      else
        control_name.Text = ""
        control_stage.Text = util_text("ui_can_equip")
      end
    end
  end
end
function on_btn_show_gb_click(btn)
  local form = btn.ParentForm
  form.groupbox_grid.Visible = true
  form.btn_show_gb.Visible = false
  form.groupbox_role.Left = form.groupbox_role.Left - form.groupbox_grid.Left / 4
end
function on_btn_hide_gb_click(btn)
  local form = btn.ParentForm
  form.groupbox_grid.Visible = false
  form.btn_show_gb.Visible = true
  form.groupbox_role.Left = form.groupbox_role.Left + form.groupbox_grid.Left / 4
end
function show_decorate(form, female_model, male_model)
  local actor2 = form.actor2
  if not nx_is_valid(actor2) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  role_composite:DeleteRideBase(actor2)
  local action_module = nx_value("action_module")
  action_module:BlendAction(actor2, "stand", true, true)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_ident = game_visual:QueryRoleClientIdent(actor2)
  local actor = game_client:GetSceneObj(nx_string(client_ident))
  local sex = actor:QueryProp("Sex")
  local show_equip_type = actor:QueryProp("ShowEquipType")
  if nx_int(show_equip_type) ~= nx_int(0) then
    change_jianghu_cloth(actor2, sex)
  end
  local mode = ""
  if sex == 1 then
    model = female_model
  else
    model = male_model
  end
  local model_table = util_split_string(model, ";")
  local count = table.getn(model_table)
  if count == 0 then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  config_cloth_table = {}
  for i = 1, count do
    local base_table = util_split_string(model_table[i], ":")
    if base_table ~= nil then
      local base_count = table.getn(base_table)
      if base_count == 2 then
        local prop_name = base_table[1]
        local prop_value = base_table[2]
        collect_card_manager:LinkCardDecorate(actor2, prop_value)
      end
    end
  end
  local scene = form.role_box.Scene
  local radius = 1.5
  local dist = 0
  scene.camera:SetPosition(-0.2, radius * 0.6, -radius * 2.5)
  nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
end
function add_face_effect(form, card_id)
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local BufferEffect = nx_value("BufferEffect")
  if not nx_is_valid(BufferEffect) then
    return
  end
  local buff_id = collect_card_manager:GetFaceEffectID(card_id)
  local effect_id = BufferEffect:GetBufferEffectInfoByID(buff_id, "effect")
  local actor2 = form.actor2
  local game_effect = form.role_box.Scene.game_effect
  if game_effect:FindEffect(effect_id, actor2, actor2) then
    return
  end
  game_effect:CreateEffect(nx_string(effect_id), actor2, actor2, "", "", "", "", actor2, true)
end
function delete_face_effect(form)
  local BufferEffect = nx_value("BufferEffect")
  if not nx_is_valid(BufferEffect) then
    return
  end
  local actor2 = form.actor2
  local game_effect = form.role_box.Scene.game_effect
  if game_effect:FindEffect(form.face_effect_id, actor2, actor2) then
    game_effect:RemoveEffect(form.face_effect_id, actor2, actor2)
  end
end
function init_face_effect(form)
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local card_id = collect_card_manager:GetUsedFaceCard()
  if nx_int(card_id) == nx_int(0) then
    return
  end
  add_face_effect(form, card_id)
end
