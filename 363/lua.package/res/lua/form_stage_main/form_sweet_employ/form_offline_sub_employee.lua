require("util_static_data")
require("util_functions")
require("form_stage_main\\form_sweet_employ\\form_offline_employee_utils")
local SUB_FORM_NAME = "form_stage_main\\form_sweet_employ\\form_offline_sub_employee"
local SELECTED_IMAGE = "gui\\special\\sweetemploy\\sweetemploy_subdirectories_on.png"
local NORMAL_IMAGE = "gui\\special\\sweetemploy\\sweetemploy_subdirectories_out.png"
local FOCUS_IMAGE = "gui\\special\\sweetemploy\\sweetemploy_subdirectories_on.png"
local ALL = "gui\\special\\sweetemploy\\sweetemploy_choose_on.png"
local FLAG_NORMAL = "gui\\special\\sweetemploy\\sweetemploy_choose_off.png"
local JIHUO_IMAGE = "gui\\special\\xiulian\\cbtn_on_out.png"
local NO_ALL_IMAGE = "gui\\common\\button\\haoyoudu2.png"
local DEFAULT_PHOTO = "icon\\skill\\jn_all.png"
NORMAL_ATTACK_ID = "normal_attack"
ANQI_ATTACK_ID = "normal_anqi_attack"
local JINGMAI_MAX_NUMBER = 6
local WUXUE_NEIGONG = 1
local WUXUE_ZHAOSHI = 2
local WUXUE_JINGMAI = 6
local NEIGONG_TABLE = {}
local ZHAOSHI_TABLE = {}
local JINGMAI_TABLE = {}
function main_form_init(form)
  form.Fixed = false
  form.treenode_neigong = nil
  form.treenode_zhaoshi = nil
  form.treenode_jingmai = nil
  form.sel_zhaoshi = nx_null()
  form.sel_neigong = nx_null()
end
function on_main_form_open(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("sweet_pet_ng", form, nx_current(), "on_rec_change")
    databinder:AddTableBind("sweet_pet_jm", form, nx_current(), "on_rec_change")
    databinder:AddTableBind("sweet_pet_zs", form, nx_current(), "on_rec_change")
    databinder:AddRolePropertyBind("CurPetTaoLu", "string", form, nx_current(), "refresh_taolu_button")
    databinder:AddRolePropertyBind("CurPetNeiGong", "string", form, nx_current(), "refresh_neigong_button")
  end
end
function on_main_form_close(form)
  local sub_form_learn = nx_value("form_stage_main\\form_sweet_employ\\form_offline_wuxue_learn")
  if nx_is_valid(sub_form_learn) then
    sub_form_learn.Visible = false
    sub_form_learn:Close()
    nx_destroy(sub_form_learn)
  end
  local xiulian_form = nx_value("form_stage_main\\form_sweet_employ\\form_offline_wuxue_xiulian")
  if nx_is_valid(xiulian_form) then
    xiulian_form.Visible = false
    xiulian_form:Close()
    nx_destroy(xiulian_form)
  end
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:DelTableBind("sweet_pet_ng", form)
    data_binder:DelTableBind("sweet_pet_jm", form)
    data_binder:DelTableBind("sweet_pet_zs", form)
    data_binder:DelRolePropertyBind("CurPetTaoLu", form)
    data_binder:DelRolePropertyBind("CurPetNeiGong", form)
  end
  nx_destroy(form)
end
function change_form_size(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) or not nx_find_custom(form, "type") then
    return
  end
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.groupbox_item.Visible = false
  form.groupbox_mark.Visible = false
  form.gb_neigong_item.Visible = false
  form.gb_taolu_item.Visible = false
  form.gb_jingmai_item.Visible = false
end
function init_treenode_neigong(form)
  if not nx_is_valid(form) then
    return
  end
  form.sel_neigong = ""
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return
  end
  local type_tab = wuxue_query:GetMainNames(WUXUE_NEIGONG)
  for i = 1, table.getn(type_tab) do
    local type_name = type_tab[i]
    local sub_type_tab = wuxue_query:GetItemNames(WUXUE_NEIGONG, type_name)
    for j = 1, table.getn(sub_type_tab) do
      local sub_type_name = sub_type_tab[j]
      local b_learn, level, flag = is_learn_neigong(form, sub_type_name)
      if b_learn then
        local child = form.treenode_neigong:GetChild(nx_string(type_name))
        if not nx_is_valid(child) then
          child = form.treenode_neigong:CreateChild(nx_string(type_name))
          child.type_name = type_name
          child.mark_node = nil
          local mark = GetNewMark()
          if nx_is_valid(mark) then
            mark.type_name = child.type_name
            mark.mark_bg.Text = gui.TextManager:GetText(type_name)
            mark.Top = i * mark.Height
            child.mark_node = mark
          end
          SetExtButtonStyle(mark, false)
        end
        local sub_child = child:CreateChild("")
        if not nx_is_valid(sub_child) then
          break
        end
        local new_item = GetNewItem(form.type)
        if not nx_is_valid(new_item) then
          break
        end
        new_item.Visible = false
        new_item.lbl_neigong_name.Text = gui.TextManager:GetText(sub_type_name)
        if nx_number(flag) == nx_number(1) then
          new_item.item_bg.NormalImage = SELECTED_IMAGE
          new_item.item_bg.FocusImage = SELECTED_IMAGE
          new_item.item_bg.PushImage = SELECTED_IMAGE
          new_item.lbl_jihuo.BackImage = ALL
          show_neigong_detail(form, sub_type_name)
        end
        new_item.type_name = sub_type_name
        sub_child.item = new_item
        sub_child.type_name = new_item.type_name
        if nx_number(flag) == nx_number(1) then
          SetExtButtonStyle(child.mark_node, true)
        end
      end
    end
  end
  local VScrollBar = form.gsb_neigong.VScrollBar
  VScrollBar.SmallChange = 10
  VScrollBar.LargeChange = 20
  AdjustTreeLayout(form.gsb_neigong)
end
function initform_treenode(form)
  local treenode_neigong = nx_call("util_gui", "get_arraylist", "offline_employ:treenode_neigong")
  if not nx_is_valid(treenode_neigong) then
    return
  end
  form.treenode_neigong = treenode_neigong
  ClearAllChildneigong(form.gsb_neigong)
  init_treenode_neigong(form)
end
function init_treenode_jingmai(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return
  end
  local type_tab = wuxue_query:GetMainNames(WUXUE_JINGMAI)
  for i = 1, table.getn(type_tab) do
    local type_name = type_tab[i]
    local sub_type_tab = wuxue_query:GetSubNames(WUXUE_JINGMAI, type_name)
    for j = 1, table.getn(sub_type_tab) do
      local sub_type_name = sub_type_tab[j]
      local b_learn, level, flag = is_learn_neigong(form, sub_type_name)
      if b_learn then
        local child = form.treenode_jingmai:GetChild(nx_string(type_name))
        if not nx_is_valid(child) then
          child = form.treenode_jingmai:CreateChild(nx_string(type_name))
          child.type_name = type_name
          child.mark_node = nil
          local mark = GetNewMark()
          if nx_is_valid(mark) then
            mark.type_name = child.type_name
            mark.mark_bg.Text = gui.TextManager:GetText(type_name)
            mark.Top = i * mark.Height
            child.mark_node = mark
          end
          SetExtButtonStyle(mark, false)
        end
        local sub_child = child:CreateChild("")
        if not nx_is_valid(sub_child) then
          break
        end
        local new_item = GetNewItem()
        if not nx_is_valid(new_item) then
          break
        end
        new_item.Visible = false
        new_item.lbl_neigong_name.Text = gui.TextManager:GetText(sub_type_name)
        if nx_number(flag) == nx_number(1) then
          new_item.lbl_jihuo.Visible = true
          new_item.item_bg.NormalImage = SELECTED_IMAGE
          new_item.item_bg.FocusImage = SELECTED_IMAGE
          new_item.item_bg.PushImage = SELECTED_IMAGE
          new_item.lbl_jihuo.BackImage = ALL
          show_jingmai_detail(form, sub_type_name)
        end
        new_item.type_name = sub_type_name
        sub_child.item = new_item
        sub_child.type_name = new_item.type_name
        if nx_number(flag) == nx_number(1) then
          SetExtButtonStyle(child.mark_node, true)
        end
      end
    end
  end
  local VScrollBar = form.gsb_neigong.VScrollBar
  VScrollBar.SmallChange = 10
  VScrollBar.LargeChange = 20
  AdjustTreeLayout(form.gsb_neigong)
end
function initform_jingmai(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local treenode_jingmai = nx_call("util_gui", "get_arraylist", "offline_employ:treenode_jingmai")
  if not nx_is_valid(treenode_jingmai) then
    return
  end
  form.treenode_jingmai = treenode_jingmai
  form.treenode_jingmai:ClearChild()
  local child_table = form.gsb_neigong:GetChildControlList()
  local child_count = table.getn(child_table)
  for i = child_count, 1, -1 do
    local child = child_table[i]
    if nx_is_valid(child) and nx_name(child) == "GroupBox" and nx_find_custom(child, "ctrltype") then
      form.gsb_neigong:Remove(child)
      gui:Delete(child)
    end
  end
  init_treenode_jingmai(form)
end
function init_treenode_zhaoshi(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return
  end
  local type_tab = wuxue_query:GetMainNames(WUXUE_ZHAOSHI)
  for i = 1, table.getn(type_tab) do
    local type_name = type_tab[i]
    local sub_type_tab = wuxue_query:GetSubNames(WUXUE_ZHAOSHI, type_name)
    for j = 1, table.getn(sub_type_tab) do
      local sub_type_name = sub_type_tab[j]
      local flag_sjm = 0
      if nx_string(sub_type_name) == nx_string("skill_changyon_sjm") then
        flag_sjm = 1
      end
      local learn_taolu, all_zhaoshi = check_taolu_is_learn(sub_type_name)
      if nx_number(flag_sjm) == nx_number(0) and learn_taolu then
        local child = form.treenode_zhaoshi:GetChild(nx_string(type_name))
        if not nx_is_valid(child) then
          child = form.treenode_zhaoshi:CreateChild(nx_string(type_name))
          child.type_name = type_name
          child.mark_node = nil
          local mark = GetNewMark()
          if nx_is_valid(mark) then
            mark.type_name = child.type_name
            mark.mark_bg.Text = nx_widestr(gui.TextManager:GetText(type_name))
            mark.Top = i * mark.Height
            child.mark_node = mark
          end
          SetExtButtonStyle(mark, false)
        end
        local sub_child = child:CreateChild("")
        if not nx_is_valid(sub_child) then
          break
        end
        local new_item = GetNewItem(form.type)
        if not nx_is_valid(new_item) then
          break
        end
        new_item.Visible = false
        new_item.lbl_neigong_name.Text = nx_widestr(gui.TextManager:GetText(sub_type_name))
        if all_zhaoshi then
          new_item.item_bg.can_select = true
          new_item.HintText = nx_widestr(nx_string(util_text("tips_sweetemploy_01")))
        else
          new_item.item_bg.can_select = false
          new_item.HintText = nx_widestr(nx_string(util_text("tips_sweetemploy_03")))
        end
        local jihuo_type_name = ""
        if nx_find_custom(form, "zhaoshi_type_name") then
          jihuo_type_name = form.zhaoshi_type_name
        end
        if nx_string(jihuo_type_name) == nx_string(sub_type_name) then
          SetExtButtonStyle(child.mark_node, true)
          new_item.item_bg.Enabled = true
          new_item.lbl_jihuo.BackImage = ALL
          new_item.item_bg.NormalImage = SELECTED_IMAGE
          new_item.item_bg.FocusImage = SELECTED_IMAGE
          new_item.item_bg.PushImage = SELECTED_IMAGE
          new_item.HintText = nx_widestr(nx_string(util_text("tips_sweetemploy_02")))
          show_taolu_detail(form, sub_type_name)
        end
        new_item.type_name = sub_type_name
        sub_child.item = new_item
        sub_child.type_name = new_item.type_name
      end
    end
  end
  local VScrollBar = form.gsb_neigong.VScrollBar
  VScrollBar.SmallChange = 10
  VScrollBar.LargeChange = 20
  AdjustTreeLayout(form.gsb_neigong)
end
function initform_zhaoshi(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local treenode_zhaoshi = nx_call("util_gui", "get_arraylist", "offline_employ:treenode_zhaoshi")
  if not nx_is_valid(treenode_zhaoshi) then
    return
  end
  form.treenode_zhaoshi = treenode_zhaoshi
  form.treenode_zhaoshi:ClearChild()
  local child_table = form.gsb_neigong:GetChildControlList()
  local child_count = table.getn(child_table)
  for i = child_count, 1, -1 do
    local child = child_table[i]
    if nx_is_valid(child) and nx_name(child) == "GroupBox" and nx_find_custom(child, "ctrltype") then
      form.gsb_neigong:Remove(child)
      gui:Delete(child)
    end
  end
  init_treenode_zhaoshi(form)
end
function ClearAllChildneigong(groupbox)
  local gui = nx_value("gui")
  local form = groupbox.ParentForm
  if not nx_is_valid(form) or not nx_is_valid(groupbox) then
    return
  end
  form.treenode_neigong:ClearChild()
  local child_table = groupbox:GetChildControlList()
  local child_count = table.getn(child_table)
  for i = child_count, 1, -1 do
    local child = child_table[i]
    if nx_is_valid(child) and nx_name(child) == "GroupBox" and nx_find_custom(child, "ctrltype") then
      groupbox:Remove(child)
      gui:Delete(child)
    end
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) or not nx_find_custom(form, "type") then
    return
  end
  form:Close()
end
function on_btn_ok_click(btn)
  local form = nx_value(SUB_FORM_NAME)
  if not nx_is_valid(form) or not nx_find_custom(form, "type") then
    return
  end
  if not nx_find_custom(form, "parent_form") then
    return
  end
  local parent_form = form.parent_form
  if not nx_is_valid(parent_form) then
    return
  end
  local type = form.type
  if nx_number(type) == nx_number(WUXUE_ZHAOSHI) then
    local type_name = get_wuxueID_from_table(type)
    parent_form.lbl_taolu.type_name = nx_widestr(type_name)
    if nx_string(type_name) ~= nx_string("") then
      local main_type_name, skill_list = GetSelectResult(parent_form, 2)
      local table_list = {}
      local number = 0
      local str_lst = util_split_string(nx_string(skill_list), ";")
      for _, val in ipairs(str_lst) do
        local tmp_lst = util_split_string(nx_string(val), ",")
        if table.getn(tmp_lst) == nx_number(2) then
          local skill_id = tmp_lst[1]
          local level = tmp_lst[2]
          number = number + 1
          table_list[number] = skill_id
          number = number + 1
          table_list[number] = level
        end
      end
      nx_execute("custom_sender", "custom_offline_employ", nx_number(11), nx_string(main_type_name), nx_string(type_name), unpack(table_list))
    end
  elseif nx_number(type) == nx_number(WUXUE_JINGMAI) then
    local type_name = get_wuxueID_from_table(type)
    if nx_find_custom(parent_form, "jingmai") then
      if nx_string(type_name) ~= nx_string("") then
        parent_form.btn_jingmaiquery.Text = util_text("ui_hasselected")
      else
        parent_form.btn_jingmaiquery.Text = util_text("")
      end
    end
  end
end
function is_learn_neigong(form, neigong_id)
  if not nx_is_valid(form) or not nx_find_custom(form, "type") then
    return
  end
  local type = form.type
  local tmp_table = {}
  if nx_number(type) == nx_number(WUXUE_NEIGONG) then
    tmp_table = NEIGONG_TABLE
  elseif nx_number(type) == nx_number(WUXUE_ZHAOSHI) then
    tmp_table = ZHAOSHI_TABLE
  elseif nx_number(type) == nx_number(WUXUE_JINGMAI) then
    tmp_table = JINGMAI_TABLE
  end
  for i = 1, table.getn(tmp_table) do
    local neigong_table = tmp_table[i]
    if nx_string(neigong_id) == nx_string(neigong_table.ID) then
      return true, neigong_table.Level, neigong_table.Flag
    end
  end
  return false, 0, 0
end
function GetNewMark()
  local gui = nx_value("gui")
  local form = nx_value(SUB_FORM_NAME)
  if not nx_is_valid(form) then
    return nil
  end
  local mark = gui:Create("GroupBox")
  local tpl_mark = form.groupbox_mark
  if not nx_is_valid(mark) or not nx_is_valid(tpl_mark) then
    return nil
  end
  mark.ctrltype = "mark"
  mark.isUnfold = true
  mark.isneedremove = false
  mark.Left = tpl_mark.Left
  mark.Top = tpl_mark.Top
  mark.Width = tpl_mark.Width
  mark.Height = tpl_mark.Height
  mark.BackColor = tpl_mark.BackColor
  mark.NoFrame = tpl_mark.NoFrame
  local btn_bg = tpl_mark:Find("mark_bg")
  if nx_is_valid(btn_bg) then
    local mark_bg = gui:Create("Button")
    mark_bg.Left = btn_bg.Left
    mark_bg.Top = btn_bg.Top
    mark_bg.Width = btn_bg.Width
    mark_bg.Height = btn_bg.Height
    mark_bg.ForeColor = btn_bg.ForeColor
    mark_bg.Font = btn_bg.Font
    mark_bg.Align = btn_bg.Align
    mark_bg.NormalImage = btn_bg.NormalImage
    mark_bg.FocusImage = btn_bg.FocusImage
    mark_bg.PushImage = btn_bg.PushImage
    mark_bg.DrawMode = btn_bg.DrawMode
    mark:Add(mark_bg)
    mark.mark_bg = mark_bg
    nx_bind_script(mark_bg, nx_current())
    nx_callback(mark_bg, "on_click", "on_btn_mark_click")
  end
  return mark
end
function on_btn_mark_click(btn)
  local form = btn.ParentForm
  local mark = btn.Parent
  if not (nx_is_valid(form) and nx_is_valid(mark)) or not nx_find_custom(form, "type") then
    return
  end
  if not mark.isUnfold then
    reset_mark_close(form)
  end
  SetExtButtonStyle(mark, not mark.isUnfold)
  local type = form.type
  AdjustTreeLayout(form.gsb_neigong)
end
function SetExtButtonStyle(mark, isUnfold)
  if nx_is_valid(mark) then
    mark.isUnfold = isUnfold
  end
end
function GetNewItem(type)
  local gui = nx_value("gui")
  local form = nx_value(SUB_FORM_NAME)
  if not nx_is_valid(form) then
    return nil
  end
  local item = gui:Create("GroupBox")
  local tpl_item = form.groupbox_item
  if not nx_is_valid(item) or not nx_is_valid(tpl_item) then
    return nil
  end
  item.ctrltype = "item"
  item.isneedremove = false
  item.Left = tpl_item.Left
  item.Top = tpl_item.Top
  item.Width = tpl_item.Width
  item.Height = tpl_item.Height
  item.BackColor = tpl_item.BackColor
  item.NoFrame = tpl_item.NoFrame
  local tmp_btn = tpl_item:Find("item_bg")
  if nx_is_valid(tmp_btn) then
    local item_bg = gui:Create("Button")
    item_bg.Left = tmp_btn.Left
    item_bg.Top = tmp_btn.Top
    item_bg.Width = tmp_btn.Width
    item_bg.Height = tmp_btn.Height
    item_bg.ForeColor = tmp_btn.ForeColor
    item_bg.Font = tmp_btn.Font
    item_bg.Align = tmp_btn.Align
    item_bg.NormalImage = tmp_btn.NormalImage
    item_bg.FocusImage = tmp_btn.FocusImage
    item_bg.PushImage = tmp_btn.PushImage
    item_bg.DrawMode = tmp_btn.DrawMode
    item:Add(item_bg)
    item.item_bg = item_bg
    nx_bind_script(item_bg, nx_current())
    nx_callback(item_bg, "on_click", "on_item_bg_click")
  end
  local tmp_lbl = tpl_item:Find("lbl_neigong_name")
  if nx_is_valid(tmp_lbl) then
    local lbl_neigong_name = gui:Create("Label")
    lbl_neigong_name.Left = tmp_lbl.Left
    lbl_neigong_name.Top = tmp_lbl.Top
    lbl_neigong_name.Width = tmp_lbl.Width
    lbl_neigong_name.Height = tmp_lbl.Height
    lbl_neigong_name.ForeColor = tmp_lbl.ForeColor
    lbl_neigong_name.Font = tmp_lbl.Font
    lbl_neigong_name.Align = tmp_lbl.Align
    item:Add(lbl_neigong_name)
    item.lbl_neigong_name = lbl_neigong_name
  end
  local jihuo = tpl_item:Find("lbl_jihuo")
  if nx_is_valid(jihuo) then
    local lbl_jihuo = gui:Create("Label")
    lbl_jihuo.Left = jihuo.Left
    lbl_jihuo.Top = jihuo.Top
    lbl_jihuo.Width = jihuo.Width
    lbl_jihuo.Height = jihuo.Height
    lbl_jihuo.ForeColor = jihuo.ForeColor
    lbl_jihuo.Transparent = jihuo.Transparent
    lbl_jihuo.Font = jihuo.Font
    lbl_jihuo.Align = jihuo.Align
    lbl_jihuo.DrawMode = jihuo.DrawMode
    lbl_jihuo.Text = jihuo.Text
    lbl_jihuo.BackImage = jihuo.BackImage
    lbl_jihuo.TransParent = false
    lbl_jihuo.ClickEvent = true
    nx_bind_script(lbl_jihuo, nx_current())
    nx_callback(lbl_jihuo, "on_click", "on_item_jihuo_click")
    item:Add(lbl_jihuo)
    item.lbl_jihuo = lbl_jihuo
  end
  return item
end
function GetSecondItem()
  local gui = nx_value("gui")
  local form = nx_value(SUB_FORM_NAME)
  if not nx_is_valid(form) then
    return nil
  end
  local item = gui:Create("GroupBox")
  local tpl_item = form.gb_taolu_item
  if not nx_is_valid(item) or not nx_is_valid(tpl_item) then
    return nil
  end
  item.ctrltype = "item"
  item.isneedremove = false
  item.Left = tpl_item.Left
  item.Top = tpl_item.Top
  item.Width = tpl_item.Width
  item.Height = tpl_item.Height
  item.BackColor = tpl_item.BackColor
  item.NoFrame = tpl_item.NoFrame
  local tmp_grid = tpl_item:Find("imagegrid_taolu")
  if nx_is_valid(tmp_grid) then
    local imagegrid_taolu = gui:Create("ImageGrid")
    imagegrid_taolu.Width = tmp_grid.Width
    imagegrid_taolu.Height = tmp_grid.Height
    imagegrid_taolu.Top = tmp_grid.Top
    imagegrid_taolu.Left = tmp_grid.Left
    imagegrid_taolu.NoFrame = tmp_grid.NoFrame
    imagegrid_taolu.BackImage = tmp_grid.BackImage
    imagegrid_taolu.DrawMode = tmp_grid.DrawMode
    imagegrid_taolu.BackColor = tmp_grid.BackColor
    imagegrid_taolu.DrawMouseIn = tmp_grid.DrawMouseIn
    imagegrid_taolu.RowNum = tmp_grid.RowNum
    imagegrid_taolu.ClomnNum = tmp_grid.ClomnNum
    imagegrid_taolu.ViewRect = tmp_grid.ViewRect
    imagegrid_taolu.HasVScroll = tmp_grid.HasVScroll
    imagegrid_taolu.DrawMouseSelect = ""
    item:Add(imagegrid_taolu)
    item.imagegrid_taolu = imagegrid_taolu
    nx_bind_script(imagegrid_taolu, SUB_FORM_NAME)
    nx_callback(imagegrid_taolu, "on_mousein_grid", "zhaoshi_grid_mousein_grid")
    nx_callback(imagegrid_taolu, "on_mouseout_grid", "zhaoshi_grid_mouseout_grid")
  end
  local tmp_lbl2 = tpl_item:Find("lbl_taolu_name")
  if nx_is_valid(tmp_lbl2) then
    local lbl_taolu_name = gui:Create("Label")
    lbl_taolu_name.Left = tmp_lbl2.Left
    lbl_taolu_name.Top = tmp_lbl2.Top
    lbl_taolu_name.Width = tmp_lbl2.Width
    lbl_taolu_name.Height = tmp_lbl2.Height
    lbl_taolu_name.ForeColor = tmp_lbl2.ForeColor
    lbl_taolu_name.Font = tmp_lbl2.Font
    lbl_taolu_name.Align = tmp_lbl2.Align
    item:Add(lbl_taolu_name)
    item.lbl_taolu_name = lbl_taolu_name
  end
  local tmp_lbl = tpl_item:Find("lbl_taolu_level")
  if nx_is_valid(tmp_lbl) then
    local lbl_taolu_level = gui:Create("Label")
    lbl_taolu_level.Left = tmp_lbl.Left
    lbl_taolu_level.Top = tmp_lbl.Top
    lbl_taolu_level.Width = tmp_lbl.Width
    lbl_taolu_level.Height = tmp_lbl.Height
    lbl_taolu_level.ForeColor = tmp_lbl.ForeColor
    lbl_taolu_level.Font = tmp_lbl.Font
    lbl_taolu_level.Align = tmp_lbl.Align
    item:Add(lbl_taolu_level)
    item.lbl_taolu_level = lbl_taolu_level
  end
  local tmp_pgb = tpl_item:Find("pbar_taolu")
  if nx_is_valid(tmp_pgb) then
    local pbar_taolu = gui:Create("ProgressBar")
    pbar_taolu.Left = tmp_pgb.Left
    pbar_taolu.Top = tmp_pgb.Top
    pbar_taolu.Width = tmp_pgb.Width
    pbar_taolu.Height = tmp_pgb.Height
    pbar_taolu.ForeColor = tmp_pgb.ForeColor
    pbar_taolu.DrawMode = tmp_pgb.DrawMode
    pbar_taolu.BackImage = tmp_pgb.BackImage
    pbar_taolu.ProgressImage = tmp_pgb.ProgressImage
    pbar_taolu.ProgressMode = tmp_pgb.ProgressMode
    item:Add(pbar_taolu)
    item.pbar_taolu = pbar_taolu
  end
  local tmp_cover = tpl_item:Find("lbl_taolu_cover")
  if nx_is_valid(tmp_cover) then
    local lbl_taolu_cover = gui:Create("Label")
    lbl_taolu_cover.Left = tmp_cover.Left
    lbl_taolu_cover.Top = tmp_cover.Top
    lbl_taolu_cover.Width = tmp_cover.Width
    lbl_taolu_cover.Height = tmp_cover.Height
    lbl_taolu_cover.BackImage = tmp_cover.BackImage
    lbl_taolu_cover.DrawMode = tmp_cover.DrawMode
    lbl_taolu_cover.AutoSize = tmp_cover.AutoSize
    item:Add(lbl_taolu_cover)
    item.lbl_taolu_cover = lbl_taolu_cover
  end
  local tmp_boss = tpl_item:Find("lbl_taolu_boss")
  if nx_is_valid(tmp_boss) then
    local lbl_taolu_boss = gui:Create("Label")
    lbl_taolu_boss.Left = tmp_boss.Left
    lbl_taolu_boss.Top = tmp_boss.Top
    lbl_taolu_boss.Width = tmp_boss.Width
    lbl_taolu_boss.Height = tmp_boss.Height
    lbl_taolu_boss.BackImage = tmp_boss.BackImage
    lbl_taolu_boss.DrawMode = tmp_boss.DrawMode
    lbl_taolu_boss.AutoSize = tmp_boss.AutoSize
    item:Add(lbl_taolu_boss)
    item.lbl_taolu_boss = lbl_taolu_boss
  end
  local learn = tpl_item:Find("btn_taolu_learn")
  if nx_is_valid(learn) then
    local btn_taolu_learn = gui:Create("Button")
    btn_taolu_learn.Left = learn.Left
    btn_taolu_learn.Top = learn.Top
    btn_taolu_learn.Width = learn.Width
    btn_taolu_learn.Height = learn.Height
    btn_taolu_learn.ForeColor = learn.ForeColor
    btn_taolu_learn.Font = learn.Font
    btn_taolu_learn.Align = learn.Align
    btn_taolu_learn.NormalImage = learn.NormalImage
    btn_taolu_learn.FocusImage = learn.FocusImage
    btn_taolu_learn.PushImage = learn.PushImage
    btn_taolu_learn.DrawMode = learn.DrawMode
    btn_taolu_learn.DisableImage = learn.DisableImage
    btn_taolu_learn.Text = learn.Text
    btn_taolu_learn.InSound = learn.InSound
    nx_bind_script(btn_taolu_learn, SUB_FORM_NAME)
    nx_callback(btn_taolu_learn, "on_click", "on_btn_neigong_learn_click")
    item:Add(btn_taolu_learn)
    item.btn_taolu_learn = btn_taolu_learn
  end
  local xiulian = tpl_item:Find("btn_taolu_xiulian")
  if nx_is_valid(xiulian) then
    local btn_taolu_xiulian = gui:Create("Button")
    btn_taolu_xiulian.Left = xiulian.Left
    btn_taolu_xiulian.Top = xiulian.Top
    btn_taolu_xiulian.Width = xiulian.Width
    btn_taolu_xiulian.Height = xiulian.Height
    btn_taolu_xiulian.ForeColor = xiulian.ForeColor
    btn_taolu_xiulian.Font = xiulian.Font
    btn_taolu_xiulian.Align = xiulian.Align
    btn_taolu_xiulian.NormalImage = xiulian.NormalImage
    btn_taolu_xiulian.FocusImage = xiulian.FocusImage
    btn_taolu_xiulian.PushImage = xiulian.PushImage
    btn_taolu_xiulian.DrawMode = xiulian.DrawMode
    btn_taolu_xiulian.DisableImage = xiulian.DisableImage
    btn_taolu_xiulian.Text = xiulian.Text
    btn_taolu_xiulian.InSound = xiulian.InSound
    btn_taolu_xiulian.Enabled = true
    nx_bind_script(btn_taolu_xiulian, SUB_FORM_NAME)
    nx_callback(btn_taolu_xiulian, "on_click", "on_btn_neigong_xiulian_click")
    item:Add(btn_taolu_xiulian)
    item.btn_taolu_xiulian = btn_taolu_xiulian
  end
  return item
end
function on_item_bg_dbclick(btn)
  if nx_find_custom(btn, "can_select") and not btn.can_select then
    return
  end
  local groupbox = btn.Parent
  local form = btn.ParentForm
  if not (nx_is_valid(groupbox) and nx_find_custom(groupbox, "type_name") and nx_is_valid(form)) or not nx_find_custom(form, "type") then
    return
  end
  local type_name = groupbox.type_name
  local type = form.type
  if nx_number(type) == nx_number(WUXUE_ZHAOSHI) then
    local learn_taolu, all_zhaoshi = check_taolu_is_learn(type_name)
    if learn_taolu and all_zhaoshi then
      RecoverOtherItemImage(form, type_name, true)
      groupbox.lbl_jihuo.BackImage = JIHUO_IMAGE
      groupbox.HintText = nx_widestr(nx_string(util_text("tips_sweetemploy_02")))
      form.zhaoshi_type_name = type_name
    end
  end
  set_jihuo_icon(form, type_name, true)
  on_btn_ok_click()
end
function on_item_bg_click(btn)
  local groupbox = btn.Parent
  local form = btn.ParentForm
  if not (nx_is_valid(groupbox) and nx_is_valid(form) and nx_find_custom(form, "type")) or not nx_find_custom(groupbox, "type_name") then
    return
  end
  local type = form.type
  local type_name = groupbox.type_name
  close_learn_xiulian_form()
  btn.NormalImage = SELECTED_IMAGE
  btn.FocusImage = SELECTED_IMAGE
  btn.PushImage = SELECTED_IMAGE
  RecoverOtherItemImage(form, type_name, false)
  if nx_number(type) == nx_number(WUXUE_ZHAOSHI) then
    show_taolu_detail(form, type_name)
    return
  end
  local _, level, flag = is_learn_neigong(form, type_name)
  if nx_number(type) == nx_number(WUXUE_JINGMAI) then
    show_jingmai_detail(form, type_name)
    return
  end
  show_neigong_detail(form, type_name)
end
function RecoverOtherItemImage(form, type_name, db_click)
  if not nx_is_valid(form) or not nx_find_custom(form, "type") then
    return
  end
  local type = form.type
  local treenode_neigong
  if nx_number(type) == nx_number(WUXUE_NEIGONG) then
    treenode_neigong = form.treenode_neigong
  elseif nx_number(type) == nx_number(WUXUE_ZHAOSHI) then
    treenode_neigong = form.treenode_zhaoshi
  elseif nx_number(type) == nx_number(WUXUE_JINGMAI) then
    treenode_neigong = form.treenode_jingmai
  end
  if not nx_is_valid(treenode_neigong) then
    return
  end
  local list_count = treenode_neigong:GetChildCount()
  for i = 0, list_count - 1 do
    local node = treenode_neigong:GetChildByIndex(i)
    if not nx_is_valid(node) then
      break
    end
    local node_child_count = node:GetChildCount()
    for j = node_child_count - 1, 0, -1 do
      local sub_node = node:GetChildByIndex(j)
      if not nx_is_valid(sub_node) then
        break
      end
      local item = sub_node.item
      if not nx_is_valid(item) then
        break
      end
      if nx_string(sub_node.type_name) ~= nx_string(type_name) then
        item.item_bg.NormalImage = NORMAL_IMAGE
        item.item_bg.FocusImage = FOCUS_IMAGE
      end
      local learn_taolu, all_zhaoshi = check_taolu_is_learn(sub_node.type_name)
      if db_click and learn_taolu and all_zhaoshi then
        item.lbl_jihuo.BackImage = ALL
        item.HintText = nx_widestr(nx_string(util_text("tips_sweetemploy_01")))
      end
    end
  end
  AdjustTreeLayout(form.gsb_neigong)
end
function AdjustTreeLayout(groupbox)
  local form = groupbox.ParentForm
  if not nx_is_valid(form) or not nx_find_custom(form, "type") then
    return
  end
  local treenode
  local type = form.type
  if nx_number(type) == nx_number(WUXUE_NEIGONG) then
    treenode = form.treenode_neigong
  elseif nx_number(type) == nx_number(WUXUE_ZHAOSHI) then
    treenode = form.treenode_zhaoshi
  elseif nx_number(type) == nx_number(WUXUE_JINGMAI) then
    treenode = form.treenode_jingmai
  end
  if not nx_is_valid(treenode) then
    return
  end
  local list_count = treenode:GetChildCount()
  for i = 0, list_count - 1 do
    local node = treenode:GetChildByIndex(i)
    if not nx_is_valid(node) then
      break
    end
    local mark = node.mark_node
    if not nx_is_valid(mark) then
      break
    end
    if not groupbox:IsChild(mark) then
      groupbox:Add(mark)
    end
    local node_child_count = node:GetChildCount()
    for j = node_child_count - 1, 0, -1 do
      local sub_node = node:GetChildByIndex(j)
      if not nx_is_valid(sub_node) then
        break
      end
      local item = sub_node.item
      if not nx_is_valid(item) then
        break
      end
      if not groupbox:IsChild(item) then
        groupbox:InsertAfter(item, mark)
      end
      if mark.isUnfold and item.isneedremove == false then
        item.Visible = true
      else
        item.Visible = false
      end
    end
  end
  groupbox.IsEditMode = false
  groupbox:ResetChildrenYPos()
end
function initsweetnpcinfor(...)
  NEIGONG_TABLE = {}
  ZHAOSHI_TABLE = {}
  JINGMAI_TABLE = {}
  local cnt = table.getn(arg)
  if nx_number(cnt) ~= nx_number(3) then
    return
  end
  for i = 1, cnt do
    local str_lst = util_split_string(nx_string(arg[i]), ";")
    for _, val in ipairs(str_lst) do
      local str_temp = util_split_string(val, ",")
      if table.getn(str_temp) == nx_number(3) then
        local id = str_temp[1]
        local level = str_temp[2]
        local flag = str_temp[3]
        local infor = {}
        infor.ID = id
        infor.Level = level
        infor.Flag = flag
        if nx_number(i) == nx_number(1) then
          table.insert(NEIGONG_TABLE, infor)
        elseif nx_number(i) == nx_number(2) then
          table.insert(ZHAOSHI_TABLE, infor)
        elseif nx_number(i) == nx_number(3) then
          table.insert(JINGMAI_TABLE, infor)
        end
      end
    end
  end
end
function InitSubForm(type, taolu_selected)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_sweet_employ\\form_offline_sub_employee", true, false)
  if not nx_is_valid(form) then
    return nil
  end
  form.type = type
  change_form_size(form)
  local child_table = form.gsb_item:GetChildControlList()
  local child_count = table.getn(child_table)
  local gui = nx_value("gui")
  for i = child_count, 1, -1 do
    local child = child_table[i]
    if nx_is_valid(child) and nx_name(child) == "GroupBox" and nx_find_custom(child, "ctrltype") then
      form.gsb_item:Remove(child)
      gui:Delete(child)
    end
  end
  if nx_number(type) == nx_number(WUXUE_NEIGONG) then
    form.lbl_title.Text = nx_widestr(nx_string(util_text("ui_sweetemploy_09")))
    initform_treenode(form)
  elseif nx_number(type) == nx_number(WUXUE_ZHAOSHI) then
    form.lbl_title.Text = nx_widestr(nx_string(util_text("ui_sweetemploy_03")))
    form.zhaoshi_type_name = taolu_selected
    initform_zhaoshi(form)
  elseif nx_number(type) == nx_number(WUXUE_JINGMAI) then
    form.lbl_title.Text = nx_widestr(nx_string(util_text("ui_sweetemploy_14")))
    initform_jingmai(form)
  end
  return form
end
function SetTableValue(type, type_name)
  if nx_number(type) == nx_number(WUXUE_NEIGONG) then
    for i = 1, table.getn(NEIGONG_TABLE) do
      local neigong_table = NEIGONG_TABLE[i]
      local flag = neigong_table.Flag
      if nx_string(type_name) == neigong_table.ID then
        if nx_number(0) == nx_number(flag) then
          NEIGONG_TABLE[i].Flag = 2
        end
      elseif nx_number(2) == nx_number(flag) then
        NEIGONG_TABLE[i].Flag = 0
      end
    end
  elseif nx_number(type) == nx_number(WUXUE_ZHAOSHI) then
  elseif nx_number(type) == nx_number(WUXUE_JINGMAI) then
    for i = 1, table.getn(JINGMAI_TABLE) do
      local jingmai_table = JINGMAI_TABLE[i]
      local flag = jingmai_table.Flag
      if nx_string(type_name) == jingmai_table.ID and nx_number(0) == nx_number(flag) then
        JINGMAI_TABLE[i].Flag = 2
      end
    end
  end
end
function SetTableValueDBClick(type, type_name)
  if nx_number(type) == nx_number(WUXUE_NEIGONG) then
    for i = 1, table.getn(NEIGONG_TABLE) do
      local neigong_table = NEIGONG_TABLE[i]
      if nx_string(type_name) == neigong_table.ID then
        NEIGONG_TABLE[i].Flag = 1
      else
        NEIGONG_TABLE[i].Flag = 0
      end
    end
  elseif nx_number(type) == nx_number(WUXUE_ZHAOSHI) then
  elseif nx_number(type) == nx_number(WUXUE_JINGMAI) then
    for i = 1, table.getn(JINGMAI_TABLE) do
      local jingmai_table = JINGMAI_TABLE[i]
      if nx_string(type_name) == jingmai_table.ID then
        JINGMAI_TABLE[i].Flag = 1
      end
    end
  end
end
function get_wuxueID_from_table(type)
  if nx_number(type) == nx_number(WUXUE_NEIGONG) then
    for i = 1, table.getn(NEIGONG_TABLE) do
      local neigong_table = NEIGONG_TABLE[i]
      local flag = neigong_table.Flag
      if nx_number(flag) == nx_number(1) then
        return neigong_table.ID
      end
    end
  elseif nx_number(type) == nx_number(WUXUE_ZHAOSHI) then
    local form = nx_value(SUB_FORM_NAME)
    if nx_is_valid(form) then
      if nx_find_custom(form, "zhaoshi_type_name") then
        return nx_string(form.zhaoshi_type_name)
      else
        return ""
      end
    end
  elseif nx_number(type) == nx_number(WUXUE_JINGMAI) then
    local ids = ""
    for i = 1, table.getn(JINGMAI_TABLE) do
      local jingmai_table = JINGMAI_TABLE[i]
      local flag = jingmai_table.Flag
      if nx_number(flag) == nx_number(1) then
        ids = addstrings(ids, jingmai_table.ID)
      end
    end
    return ids
  end
end
function ResetTable(type, type_name)
  if nx_number(type) == nx_number(WUXUE_NEIGONG) then
    for i = 1, table.getn(WUXUE_NEIGONG) do
      local tlb = WUXUE_NEIGONG[i]
      if nx_string(type_name) == tlb.ID then
        WUXUE_NEIGONG[i].Flag = 0
      end
    end
  elseif nx_number(type) == nx_number(WUXUE_ZHAOSHI) then
  elseif nx_number(type) == nx_number(WUXUE_JINGMAI) then
    for i = 1, table.getn(JINGMAI_TABLE) do
      local tlb = JINGMAI_TABLE[i]
      if nx_string(type_name) == tlb.ID then
        JINGMAI_TABLE[i].Flag = 0
      end
    end
  end
end
function addstrings(desc, src)
  local str_lst = util_split_string(nx_string(desc), ",")
  local bCanAdd = true
  for _, val in ipairs(str_lst) do
    if nx_string(val) == nx_string(src) then
      bCanAdd = false
    end
  end
  if bCanAdd then
    desc = desc .. "," .. nx_string(src)
  end
  return desc
end
function Getjingmai_number()
  local ids = ""
  for i = 1, table.getn(JINGMAI_TABLE) do
    local jingmai_table = JINGMAI_TABLE[i]
    local flag = jingmai_table.Flag
    if nx_number(flag) == nx_number(1) then
      ids = addstrings(ids, jingmai_table.ID)
    end
  end
  local num = 0
  local str_lst = util_split_string(nx_string(ids), ",")
  for _, val in ipairs(str_lst) do
    if nx_string(val) ~= nx_string("") then
      num = num + 1
    end
  end
  return nx_number(num)
end
function check_taolu_is_learn(taolu_name)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0, 0
  end
  local fight = nx_value("fight")
  if not nx_is_valid(fight) then
    return 0, 0
  end
  local learn_taolu = false
  local all_zhaoshi = false
  local zhaoshi_number = 0
  local item_tab = wuxue_query:GetItemNames(WUXUE_ZHAOSHI, nx_string(taolu_name))
  for i = 1, table.getn(item_tab) do
    local item_name = item_tab[i]
    local item_name_old = item_name
    if item_name == NORMAL_ATTACK_ID then
      item_name = fight:GetNormalAttackSkillID()
    elseif item_name == ANQI_ATTACK_ID then
      item_name = fight:GetNormalAnqiAttackSkillID(false)
    end
    if nx_string(item_name) == nx_string("") then
      item_name = item_name_old
    end
    for i = 1, table.getn(ZHAOSHI_TABLE) do
      local zhaoshi_table = ZHAOSHI_TABLE[i]
      if nx_string(item_name) == nx_string(zhaoshi_table.ID) then
        learn_taolu = true
        zhaoshi_number = zhaoshi_number + 1
      end
    end
  end
  if nx_number(zhaoshi_number) == nx_number(table.getn(item_tab)) then
    all_zhaoshi = true
  else
    all_zhaoshi = false
  end
  return learn_taolu, all_zhaoshi
end
function show_taolu_detail(form, type_name)
  form.gb_neigong_item.Visible = false
  form.gb_taolu_item.Visible = false
  form.gb_jingmai_item.Visible = false
  local child_table = form.gsb_item:GetChildControlList()
  local child_count = table.getn(child_table)
  local gui = nx_value("gui")
  for i = child_count, 1, -1 do
    local child = child_table[i]
    if nx_is_valid(child) and nx_name(child) == "GroupBox" and nx_find_custom(child, "ctrltype") then
      form.gsb_item:Remove(child)
      gui:Delete(child)
    end
  end
  local VScrollBar = form.gsb_item.VScrollBar
  VScrollBar.SmallChange = 10
  VScrollBar.LargeChange = 20
  local wuxue_query = nx_value("WuXueQuery")
  local item_tab = wuxue_query:GetItemNames(WUXUE_ZHAOSHI, nx_string(type_name))
  local fight = nx_value("fight")
  if not nx_is_valid(fight) then
    return 0
  end
  for i = 1, table.getn(item_tab) do
    local item_name = item_tab[i]
    local sub_item = GetSecondItem()
    local level = GetDataFromRecord("sweet_pet_zs", 1, item_name)
    local max_level = GetDataFromRecord("sweet_pet_zs", 2, item_name)
    sub_item.btn_taolu_learn.Enabled = true
    sub_item.btn_taolu_xiulian.Enabled = true
    if nx_number(level) >= nx_number(max_level) then
      sub_item.btn_taolu_learn.Enabled = true
      sub_item.btn_taolu_xiulian.Enabled = false
      sub_item.lbl_taolu_level.Visible = true
      sub_item.pbar_taolu.Visible = true
      sub_item.lbl_taolu_cover.Visible = true
      sub_item.lbl_taolu_boss.Visible = true
    end
    local item_name_old = item_name
    if item_name == NORMAL_ATTACK_ID then
      item_name = fight:GetNormalAttackSkillID()
    elseif item_name == ANQI_ATTACK_ID then
      item_name = fight:GetNormalAnqiAttackSkillID(false)
    end
    if nx_string(item_name) == nx_string("") then
      item_name = item_name_old
    end
    local b_learn, _ = get_taolu_level(item_name)
    if b_learn then
      sub_item.type_name = item_name
      local photo = skill_static_query_by_id(item_name, "Photo")
      sub_item.imagegrid_taolu:AddItem(0, nx_string(photo), 0, 1, -1)
    else
      sub_item.type_name = ""
      sub_item.imagegrid_taolu:AddItem(0, nx_string(DEFAULT_PHOTO), 0, 1, -1)
      sub_item.btn_taolu_xiulian.Enabled = false
      sub_item.btn_taolu_learn.Visible = true
      sub_item.lbl_taolu_level.Visible = true
      sub_item.pbar_taolu.Visible = true
      sub_item.lbl_taolu_cover.Visible = true
      sub_item.lbl_taolu_boss.Visible = false
      sub_item.Height = form.gb_taolu_item.Height
      sub_item.btn_taolu_learn.Enabled = true
      sub_item.btn_taolu_xiulian.Enabled = false
    end
    sub_item.lbl_taolu_name.Text = nx_widestr(gui.TextManager:GetText(item_name))
    sub_item.lbl_taolu_level.Text = gui.TextManager:GetText("ui_wuxue_level_" .. nx_string(nx_int(level)))
    sub_item.level = level
    sub_item.parent_type_name = type_name
    local fillvalue_cur = GetDataFromRecord("sweet_pet_zs", 3, item_name)
    local fillvalue_all = GetMaxFacutlyValue(nx_string(item_name), nx_number(level))
    if nx_number(fillvalue_all) <= nx_number(0) then
      sub_item.btn_taolu_xiulian.Enabled = false
      fillvalue_all = 100
    end
    sub_item.pbar_taolu.Maximum = nx_int(fillvalue_all)
    sub_item.pbar_taolu.Value = nx_int(fillvalue_cur)
    local max_value = fillvalue_all
    if nx_int(level) >= nx_int(max_level) then
      max_value = 0
    end
    if b_learn ~= true then
      max_value = 0
    end
    sub_item.pbar_taolu.HintText = nx_widestr(nx_number(fillvalue_cur)) .. nx_widestr(" / ") .. nx_widestr(nx_number(max_value))
    if nx_int(fillvalue_cur) ~= nx_int(0) and sub_item.pbar_taolu.Visible then
      sub_item.lbl_taolu_boss.Visible = true
    else
      sub_item.lbl_taolu_boss.Visible = false
    end
    form.gsb_item:Add(sub_item)
  end
  form.gsb_item.type_name = type_name
  form.gsb_item.IsEditMode = false
  form.gsb_item:ResetChildrenYPos()
end
function show_neigong_detail(form, type_name)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.gb_neigong_item.Visible = true
  form.gb_taolu_item.Visible = false
  form.gb_jingmai_item.Visible = false
  local _, level, flag = is_learn_neigong(form, type_name)
  level = GetDataFromRecord("sweet_pet_ng", 1, type_name)
  local photo = neigong_query_photo_by_configid(nx_string(type_name))
  form.imagegrid_neigong:AddItem(0, nx_string(photo), 0, 1, -1)
  form.lbl_neigong_level.Text = gui.TextManager:GetText("ui_wuxue_level_" .. nx_string(nx_int(level)))
  if nx_number(flag) == nx_number(1) then
    form.btn_yungong.Enabled = false
  else
    form.btn_yungong.Enabled = true
  end
  local max_level = GetDataFromRecord("sweet_pet_ng", 2, type_name)
  if nx_number(level) >= nx_number(max_level) then
    form.btn_neigong_xiulian.Enabled = false
    form.btn_neigong_learn.Enabled = true
  else
    form.pbar_neigong.Visible = true
    form.lbl_cover.Visible = true
    form.lbl_boss.Visible = true
    form.btn_neigong_xiulian.Enabled = true
    form.btn_neigong_learn.Visible = true
  end
  local fillvalue_cur = GetDataFromRecord("sweet_pet_ng", 3, type_name)
  local fillvalue_all = GetMaxFacutlyValue(nx_string(type_name), nx_number(level))
  if nx_number(fillvalue_all) <= nx_number(0) then
    form.btn_neigong_xiulian.Enabled = false
    fillvalue_all = 100
  end
  form.pbar_neigong.Maximum = nx_int(fillvalue_all)
  form.pbar_neigong.Value = nx_int(fillvalue_cur)
  form.pbar_neigong.HintText = nx_widestr(nx_number(fillvalue_cur)) .. nx_widestr(" / ") .. nx_widestr(nx_number(fillvalue_all))
  if nx_int(fillvalue_cur) ~= nx_int(0) and form.pbar_neigong.Visible then
    form.lbl_boss.Visible = true
  else
    form.lbl_boss.Visible = false
  end
  form.gb_neigong_item.type_name = type_name
end
function show_jingmai_detail(form, type_name)
  form.gb_neigong_item.Visible = false
  form.gb_taolu_item.Visible = false
  form.gb_jingmai_item.Visible = true
  form.gb_jingmai_item.Top = 0
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local b_learn, level, flag = is_learn_neigong(form, type_name)
  level = GetDataFromRecord("sweet_pet_jm", 1, type_name)
  local static_id = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\JingMai\\jingmai.ini", type_name, "StaticData", "0")
  local photo = jingmai_static_query(static_id, "Photo")
  form.imagegrid_jingmai:AddItem(0, nx_string(photo), 0, 1, -1)
  form.lbl_zhoutian.Text = gui.TextManager:GetText("ui_wuxue_level_" .. nx_string(nx_int(level)))
  if nx_number(flag) == nx_number(1) then
    form.btn_jihuo.Text = nx_widestr(nx_string(util_text("ui_close")))
    form.btn_jihuo.Enabled = true
    form.btn_jihuo.HintText = nx_widestr("")
  else
    form.btn_jihuo.Text = gui.TextManager:GetText("ui_jm_jihuo")
    if nx_number(Getjingmai_number()) >= nx_number(JINGMAI_MAX_NUMBER) then
      form.btn_jihuo.HintText = gui.TextManager:GetFormatText("tips_jingmai_active_num", nx_int(Getjingmai_number()), nx_int(JINGMAI_MAX_NUMBER))
      form.btn_jihuo.Enabled = false
    end
  end
  local canlevel = GetDataFromRecord("sweet_pet_jm", 2, type_name)
  if nx_number(canlevel) == nx_number(level) then
    form.btn_xiulian_jm.Visible = false
  else
    form.btn_xiulian_jm.Visible = true
  end
  form.lbl_zhoutian.Text = nx_widestr(level)
  form.lbl_zhoutian.Text = form.lbl_zhoutian.Text .. nx_widestr("/")
  form.lbl_zhoutian.Text = form.lbl_zhoutian.Text .. nx_widestr(nx_string(canlevel))
  form.lbl_zhoutian.Text = form.lbl_zhoutian.Text .. nx_widestr(nx_string(util_text("ui_cycle_day")))
  form.imagegrid_jingmai.type_name = type_name
  form.gb_jingmai_item.type_name = type_name
end
function on_btn_jihuo_click(btn)
  local groupbox = btn.Parent
  local form = btn.ParentForm
  if not (nx_is_valid(groupbox) and nx_find_custom(groupbox, "type_name") and nx_is_valid(form)) or not nx_find_custom(form, "type") then
    return
  end
  local type = form.type
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local type_name = groupbox.type_name
  local _, level, flag = is_learn_neigong(form, type_name)
  if nx_number(flag) == nx_number(1) then
    btn.Text = gui.TextManager:GetText("ui_jm_jihuo")
    ResetTable(type, type_name)
    set_jihuo_icon(form, type_name, false)
  else
    if nx_number(Getjingmai_number()) >= nx_number(JINGMAI_MAX_NUMBER) then
      btn.HintText = gui.TextManager:GetFormatText("tips_jingmai_active_num", nx_int(Getjingmai_number()), nx_int(JINGMAI_MAX_NUMBER))
      btn.Enabled = false
      return
    end
    btn.Text = nx_widestr(nx_string(util_text("ui_close")))
    SetTableValueDBClick(type, type_name)
    set_jihuo_icon(form, type_name, true)
  end
end
function on_imagegrid_jingmai_mousein_grid(grid, index)
  if not nx_find_custom(grid, "type_name") then
    return
  end
  local form = grid.ParentForm
  local type_name = grid.type_name
  local _, level, flag = is_learn_neigong(form, type_name)
  level = GetDataFromRecord("sweet_pet_jm", 1, type_name)
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  local static_id = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\JingMai\\jingmai.ini", type_name, "StaticData", "0")
  item.ConfigID = type_name
  item.ItemType = nx_number(1003)
  item.StaticData = nx_number(static_id)
  item.is_static = false
  item.Level = level
  if nx_number(flag) == nx_number(1) then
    item.BindStatus = true
  else
    item.BindStatus = false
  end
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, form)
end
function on_imagegrid_jingmai_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_neigong_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_neigong_mousein_grid(grid, index)
  local form = grid.ParentForm
  local groupbox = grid.Parent
  if not (nx_is_valid(form) and nx_is_valid(groupbox)) or not nx_find_custom(groupbox, "type_name") then
    return
  end
  local type_name = groupbox.type_name
  local _, level, flag = is_learn_neigong(form, type_name)
  level = GetDataFromRecord("sweet_pet_ng", 1, type_name)
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  local static_id = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\NeiGong\\neigong.ini", type_name, "StaticData", "0")
  item.ConfigID = type_name
  item.ItemType = nx_number(1002)
  item.StaticData = nx_number(static_id)
  item.is_static = false
  item.Level = level
  item.MaxLevel = GetDataFromRecord("sweet_pet_ng", 2, type_name)
  item.VarPropNo = neigong_static_query(type_name, "MinVarPropNo")
  local faculty_query = nx_value("faculty_query")
  if nx_is_valid(faculty_query) then
    item.WuXing = faculty_query:GetWuXing(nx_string(type_name))
  end
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager.InShortcut = true
  end
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, form)
end
function zhaoshi_grid_mousein_grid(grid, index)
  local groupbox = grid.Parent
  local form = grid.ParentForm
  if not (nx_is_valid(groupbox) and nx_is_valid(form)) or not nx_find_custom(groupbox, "type_name") then
    return
  end
  local type_name = groupbox.type_name
  if nx_string(type_name) == nx_string("") then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  local static_id = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\skill_new.ini", type_name, "StaticData", "0")
  item.ConfigID = type_name
  item.ItemType = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\skill_new.ini", type_name, "ItemType", "0")
  item.StaticData = nx_number(static_id)
  item.is_static = false
  item.Level = GetDataFromRecord("sweet_pet_zs", 1, type_name)
  item.MaxLevel = GetDataFromRecord("sweet_pet_zs", 2, type_name)
  local faculty_query = nx_value("faculty_query")
  if nx_is_valid(faculty_query) then
    item.WuXing = faculty_query:GetWuXing(nx_string(type_name))
  end
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager.InShortcut = true
  end
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, form)
end
function zhaoshi_grid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_yungong_click(btn)
end
function get_taolu_level(zhaoshi)
  for i = 1, table.getn(ZHAOSHI_TABLE) do
    local zhaoshi_table = ZHAOSHI_TABLE[i]
    if nx_string(zhaoshi) == nx_string(zhaoshi_table.ID) then
      return true, zhaoshi_table.Level
    end
  end
  return false, 0
end
function set_jihuo_icon(form, type_name, b_set)
  if not nx_find_custom(form, "type") then
    return
  end
  local type = form.type
  local treenode
  if nx_number(type) == nx_number(WUXUE_NEIGONG) and nx_find_custom(form, "treenode_neigong") then
    treenode = form.treenode_neigong
  elseif nx_number(type) == nx_number(WUXUE_ZHAOSHI) and nx_find_custom(form, "treenode_zhaoshi") then
    treenode = form.treenode_zhaoshi
  elseif nx_number(type) == nx_number(WUXUE_JINGMAI) and nx_find_custom(form, "treenode_jingmai") then
    treenode = form.treenode_jingmai
  end
  local list_count = treenode:GetChildCount()
  for i = 0, list_count - 1 do
    local node = treenode:GetChildByIndex(i)
    if not nx_is_valid(node) then
      break
    end
    local node_child_count = node:GetChildCount()
    for j = node_child_count - 1, 0, -1 do
      local sub_node = node:GetChildByIndex(j)
      if not nx_is_valid(sub_node) then
        break
      end
      sub_node.item.lbl_jihuo.BackImage = FLAG_NORMAL
      if nx_string(sub_node.type_name) == nx_string(type_name) and b_set then
        sub_node.item.lbl_jihuo.BackImage = ALL
      end
    end
  end
end
function on_btn_neigong_xiulian_click(btn)
  local learn_form = nx_value("form_stage_main\\form_sweet_employ\\form_offline_wuxue_learn")
  if nx_is_valid(learn_form) then
    learn_form.Visible = false
    learn_form:Close()
    nx_destroy(learn_form)
  end
  local groupbox = btn.Parent
  if not nx_is_valid(groupbox) or not nx_find_custom(groupbox, "type_name") then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) or not nx_find_custom(form, "type") then
    return
  end
  local type_name = groupbox.type_name
  local xiulian_form = nx_value("form_stage_main\\form_sweet_employ\\form_offline_wuxue_xiulian")
  if nx_is_valid(xiulian_form) then
    xiulian_form.Visible = false
    xiulian_form:Close()
    nx_destroy(xiulian_form)
  end
  xiulian_form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_sweet_employ\\form_offline_wuxue_xiulian", true, false)
  xiulian_form.wuxue_name = type_name
  xiulian_form.Visible = true
  xiulian_form.type = form.type
  xiulian_form:Show()
end
function on_btn_neigong_learn_click(btn)
  local xiulian_form = nx_value("form_stage_main\\form_sweet_employ\\form_offline_wuxue_xiulian")
  if nx_is_valid(xiulian_form) then
    xiulian_form.Visible = false
    xiulian_form:Close()
    nx_destroy(xiulian_form)
  end
  nx_execute("form_stage_main\\form_sweet_employ\\form_offline_wuxue_learn", "open_form")
end
function on_rec_change(form, recordname, optype, row, col)
  if optype == "add" then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "learn_new_wuxue", form)
      timer:Register(1000, 1, nx_current(), "learn_new_wuxue", form, -1, -1)
    end
  end
  if optype == "update" then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "refresh_panel", form)
      timer:Register(500, 1, nx_current(), "refresh_panel", form, -1, -1)
    end
  end
  return
end
function refresh_panel(form, param1, param2)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "type") then
    return
  end
  local type = form.type
  if nx_number(type) == nx_number(WUXUE_NEIGONG) then
    if nx_find_custom(form.gb_neigong_item, "type_name") then
      show_neigong_detail(form, form.gb_neigong_item.type_name)
    end
  elseif nx_number(type) == nx_number(WUXUE_ZHAOSHI) then
    if nx_find_custom(form.gsb_item, "type_name") then
      show_taolu_detail(form, form.gsb_item.type_name)
    end
  elseif nx_number(type) == nx_number(WUXUE_JINGMAI) and nx_find_custom(form.gb_jingmai_item, "type_name") then
    show_jingmai_detail(form, form.gb_jingmai_item.type_name)
  end
end
function learn_new_wuxue(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "type") then
    return
  end
  local type = form.type
  local main_form = nx_value("form_stage_main\\form_sweet_employ\\form_offline_employee")
  if not nx_is_valid(main_form) then
    return
  end
  local neigong = GetFormatStringFromRecord(1, nx_string(GetPlayerProp("CurPetNeiGong")))
  local zhaoshi = GetFormatStringFromRecord(2)
  local jingmai = GetFormatStringFromRecord(6)
  main_form.neigong = neigong
  main_form.zhaoshi = zhaoshi
  main_form.jingmai = jingmai
  if nx_number(type) == nx_number(WUXUE_NEIGONG) then
    initsweetnpcinfor(main_form.neigong, "", "")
    initform_treenode(form)
  elseif nx_number(type) == nx_number(WUXUE_ZHAOSHI) then
    initsweetnpcinfor("", main_form.zhaoshi, "")
    initform_zhaoshi(form)
    if nx_find_custom(form.gsb_item, "type_name") then
      show_taolu_detail(form, form.gsb_item.type_name)
    end
  elseif nx_number(type) == nx_number(WUXUE_JINGMAI) then
    initsweetnpcinfor("", "", main_form.jingmai)
    initform_jingmai(form)
  end
end
function reset_mark_close(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "type") then
    return
  end
  local treenode
  local type = form.type
  if nx_number(type) == nx_number(WUXUE_NEIGONG) then
    treenode = form.treenode_neigong
  elseif nx_number(type) == nx_number(WUXUE_ZHAOSHI) then
    treenode = form.treenode_zhaoshi
  elseif nx_number(type) == nx_number(WUXUE_JINGMAI) then
    treenode = form.treenode_jingmai
  end
  if not nx_is_valid(treenode) then
    return
  end
  local list_count = treenode:GetChildCount()
  for i = 0, list_count - 1 do
    local node = treenode:GetChildByIndex(i)
    if not nx_is_valid(node) then
      break
    end
    local mark = node.mark_node
    if not nx_is_valid(mark) then
      break
    end
    mark.isUnfold = false
  end
end
function on_btn_sure_click(btn)
end
function on_item_jihuo_click(lbl)
  local form = lbl.ParentForm
  local groupbox = lbl.Parent
  if not nx_find_custom(form, "type") then
    return
  end
  if not nx_find_custom(groupbox, "item_bg") or not nx_is_valid(groupbox.item_bg) then
    return
  end
  local btn = groupbox.item_bg
  btn.NormalImage = SELECTED_IMAGE
  btn.FocusImage = SELECTED_IMAGE
  btn.PushImage = SELECTED_IMAGE
  if nx_int(form.type) == nx_int(WUXUE_NEIGONG) then
    RecoverOtherItemImage(form, groupbox.type_name, false)
    form.sel_neigong = groupbox
    nx_execute("custom_sender", "custom_offline_employ", nx_number(9), nx_string(groupbox.type_name))
  elseif nx_int(form.type) == nx_int(WUXUE_ZHAOSHI) then
    if not nx_find_custom(btn, "can_select") or not btn.can_select then
      return
    end
    local learn_taolu, all_zhaoshi = check_taolu_is_learn(groupbox.type_name)
    if learn_taolu and all_zhaoshi then
      RecoverOtherItemImage(form, type_name, false)
      form.sel_zhaoshi = groupbox
      form.zhaoshi_type_name = groupbox.type_name
      on_btn_ok_click()
    end
  end
end
function refresh_taolu_button(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
    return
  end
  if form.Visible ~= true then
    return
  end
  if nx_int(form.type) ~= nx_int(WUXUE_ZHAOSHI) then
    return
  end
  local groupbox = form.sel_zhaoshi
  if not nx_is_valid(groupbox) then
    return
  end
  if nx_string(groupbox.type_name) ~= nx_string(prop_value) then
    return
  end
  set_jihuo_icon(form, groupbox.type_name, true)
  groupbox.HintText = nx_widestr(nx_string(util_text("tips_sweetemploy_02")))
  form.zhaoshi_type_name = groupbox.type_name
  local zhaoshi = GetFormatStringFromRecord(2)
  initsweetnpcinfor("", zhaoshi, "")
  show_taolu_detail(form, groupbox.type_name)
end
function refresh_neigong_button(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
    return
  end
  if form.Visible ~= true then
    return
  end
  if nx_int(form.type) ~= nx_int(WUXUE_NEIGONG) then
    return
  end
  local groupbox = form.sel_neigong
  if not nx_is_valid(groupbox) then
    return
  end
  if nx_string(groupbox.type_name) ~= nx_string(prop_value) then
    return
  end
  set_jihuo_icon(form, groupbox.type_name, true)
  local neigong = GetFormatStringFromRecord(1, nx_string(prop_value))
  initsweetnpcinfor(neigong, "", "")
  show_neigong_detail(form, groupbox.type_name)
end
