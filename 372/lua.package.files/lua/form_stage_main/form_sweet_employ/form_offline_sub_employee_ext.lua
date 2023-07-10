require("util_functions")
local FORM_NAME = "form_stage_main\\form_sweet_employ\\form_offline_sub_employee_ext"
local SPACE_NUMBER = 6
local TEAM_SET_NUMBER = 5
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  change_form_size(form)
  init_form(form)
  form.rbtn_type_1.Checked = true
end
function on_main_form_close(form)
  nx_destroy(form)
end
function change_form_size(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function init_form(form)
  if not nx_is_valid(form) then
    return
  end
  del_subcontrol(form.gsb_sweet)
  init_control(form.gsb_sweet, SPACE_NUMBER)
  del_subcontrol(form.gsb_team_set)
  init_team_set(form.gsb_team_set, TEAM_SET_NUMBER)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local photo = client_player:QueryProp("Photo")
  form.lbl_cur_image.BackImage = photo
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function open_form()
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    form.Visible = false
    form:Close()
    return
  end
  form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function on_rbtn_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local tab_index = rbtn.TabIndex
  if nx_number(tab_index) == nx_number(0) then
    show_sweet_lists(form)
  elseif nx_number(tab_index) == nx_number(1) then
    sweet_team_set(form)
  end
end
function show_sweet_lists(form)
  if not nx_is_valid(form) then
    return
  end
  form.gsb_sweet.Visible = true
  form.gsb_team_set.Visible = false
end
function del_subcontrol(ctl)
  local child_table = ctl:GetChildControlList()
  local child_count = table.getn(child_table)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  for i = child_count, 1, -1 do
    local child = child_table[i]
    if nx_is_valid(child) and nx_name(child) == "GroupBox" and nx_find_custom(child, "dynamic_create") then
      ctl:Remove(child)
      gui:Delete(child)
    end
  end
end
function init_control(ctl, space_number)
  local form = ctl.ParentForm
  if not (not (nx_number(space_number) <= nx_number(0)) and nx_is_valid(ctl)) or not nx_is_valid(form) then
    return
  end
  local cur_sweet_number = 1
  for i = 1, cur_sweet_number do
    local gb = clone_sweet_groupbox(form, 1)
    if nx_is_valid(gb) then
      gb.Visible = true
      gb.cbtn_bg.TabIndex = i
      gb.sweet_index = i
      fill_sweet_info(i, gb)
      ctl:Add(gb)
    end
  end
  for j = cur_sweet_number + 1, SPACE_NUMBER do
    local gb = clone_sweet_groupbox(form, 2)
    if nx_is_valid(gb) then
      gb.Visible = true
      gb.cbtn_bg.TabIndex = j
      gb.mltbox_no_hire_tips.HtmlText = nx_widestr("\191\213\207\208\192\184\206\187 ") .. nx_widestr(j)
      ctl:Add(gb)
    end
  end
  ctl.IsEditMode = false
  ctl:ResetChildrenYPos()
end
function fill_sweet_info(i, gb)
  if nx_number(i) < nx_number(1) or not nx_is_valid(gb) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindRecord("rec_pet_show") then
    return
  end
  local photo = client_player:QueryRecord("rec_pet_show", 0, 1)
  gb.lbl_photo.BackImage = photo
  local name = client_player:QueryRecord("rec_pet_show", 0, 0)
  gb.lbl_name.Text = nx_widestr(name)
  local level = client_player:QueryRecord("rec_pet_show", 0, 7)
  gb.lbl_shili.Text = nx_widestr(nx_string(util_text("desc_" .. nx_string(level))))
  local status = client_player:QueryRecord("rec_pet_show_base_prop", 0, 3)
  if nx_number(status) == nx_number(0) then
    gb.lbl_status.Text = nx_widestr(nx_string(util_text("ui_sweetemploy_08")))
    gb.btn_chuzhan.Enabled = true
    gb.btn_xiuxi.Enabled = false
  else
    gb.lbl_status.Text = nx_widestr(nx_string(util_text("ui_sweetemploy_07")))
    gb.btn_chuzhan.Enabled = false
    gb.btn_xiuxi.Enabled = true
  end
end
function clone_team_set_groupbox(form)
  local gui = nx_value("gui")
  if not nx_is_valid(form) or not nx_is_valid(gui) then
    return nil
  end
  local item = gui:Create("GroupBox")
  local tpl_item = form.gb_team_item
  if not nx_is_valid(item) or not nx_is_valid(tpl_item) then
    return nil
  end
  item.dynamic_create = true
  local prop_tab = nx_property_list(tpl_item)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(item, prop_tab[i], nx_property(tpl_item, prop_tab[i]))
  end
  local tmp_title = tpl_item:Find("cbtn_team_title")
  local cbtn_team_title = gui:Create("CheckButton")
  if nx_is_valid(cbtn_team_title) and nx_is_valid(tmp_title) then
    local props_tab = nx_property_list(tmp_title)
    for i = 1, table.getn(props_tab) do
      nx_set_property(cbtn_team_title, props_tab[i], nx_property(tmp_title, props_tab[i]))
    end
    nx_bind_script(cbtn_team_title, FORM_NAME)
    nx_callback(cbtn_team_title, "on_checked_changed", "on_cbtn_team_title_checked_changed")
    item:Add(cbtn_team_title)
    item.cbtn_team_title = cbtn_team_title
  end
  local tmp_zhenfa = tpl_item:Find("gb_zhenfa")
  local gb_zhenfa = gui:Create("GroupBox")
  if nx_is_valid(gb_zhenfa) and nx_is_valid(tmp_zhenfa) then
    local props_tab = nx_property_list(tmp_zhenfa)
    for i = 1, table.getn(props_tab) do
      nx_set_property(gb_zhenfa, props_tab[i], nx_property(tmp_zhenfa, props_tab[i]))
    end
    item:Add(gb_zhenfa)
    item.gb_zhenfa = gb_zhenfa
  end
  local tmp_lbl_8 = tmp_zhenfa:Find("lbl_8")
  local lbl_8 = gui:Create("Label")
  if nx_is_valid(lbl_8) and nx_is_valid(tmp_lbl_8) then
    local props_tab = nx_property_list(tmp_lbl_8)
    for i = 1, table.getn(props_tab) do
      nx_set_property(lbl_8, props_tab[i], nx_property(tmp_lbl_8, props_tab[i]))
    end
    gb_zhenfa:Add(lbl_8)
    gb_zhenfa.lbl_8 = lbl_8
  end
  local tmp_rbtn_1 = tmp_zhenfa:Find("rbtn_1")
  local rbtn_1 = gui:Create("RadioButton")
  if nx_is_valid(rbtn_1) and nx_is_valid(tmp_rbtn_1) then
    local props_tab = nx_property_list(tmp_rbtn_1)
    for i = 1, table.getn(props_tab) do
      nx_set_property(rbtn_1, props_tab[i], nx_property(tmp_rbtn_1, props_tab[i]))
    end
    gb_zhenfa:Add(rbtn_1)
    gb_zhenfa.rbtn_1 = rbtn_1
  end
  local tmp_rbtn_2 = tmp_zhenfa:Find("rbtn_2")
  local rbtn_2 = gui:Create("RadioButton")
  if nx_is_valid(rbtn_2) and nx_is_valid(tmp_rbtn_2) then
    local props_tab = nx_property_list(tmp_rbtn_2)
    for i = 1, table.getn(props_tab) do
      nx_set_property(rbtn_2, props_tab[i], nx_property(tmp_rbtn_2, props_tab[i]))
    end
    gb_zhenfa:Add(rbtn_2)
    gb_zhenfa.rbtn_2 = rbtn_2
  end
  local tmp_lbl_rbtn_1 = tmp_zhenfa:Find("lbl_rbtn_1")
  local lbl_rbtn_1 = gui:Create("Label")
  if nx_is_valid(lbl_rbtn_1) and nx_is_valid(tmp_lbl_rbtn_1) then
    local props_tab = nx_property_list(tmp_lbl_rbtn_1)
    for i = 1, table.getn(props_tab) do
      nx_set_property(lbl_rbtn_1, props_tab[i], nx_property(tmp_lbl_rbtn_1, props_tab[i]))
    end
    gb_zhenfa:Add(lbl_rbtn_1)
    gb_zhenfa.lbl_rbtn_1 = lbl_rbtn_1
  end
  local tmp_lbl_rbtn_2 = tmp_zhenfa:Find("lbl_rbtn_2")
  local lbl_rbtn_2 = gui:Create("Label")
  if nx_is_valid(lbl_rbtn_2) and nx_is_valid(tmp_lbl_rbtn_2) then
    local props_tab = nx_property_list(tmp_lbl_rbtn_2)
    for i = 1, table.getn(props_tab) do
      nx_set_property(lbl_rbtn_2, props_tab[i], nx_property(tmp_lbl_rbtn_2, props_tab[i]))
    end
    gb_zhenfa:Add(lbl_rbtn_2)
    gb_zhenfa.lbl_rbtn_2 = lbl_rbtn_2
  end
  local tmp_skill = tpl_item:Find("gb_skill")
  local gb_skill = gui:Create("GroupBox")
  if nx_is_valid(gb_skill) and nx_is_valid(tmp_skill) then
    local props_tab = nx_property_list(tmp_skill)
    for i = 1, table.getn(props_tab) do
      nx_set_property(gb_skill, props_tab[i], nx_property(tmp_skill, props_tab[i]))
    end
    item:Add(gb_skill)
    item.gb_skill = gb_skill
  end
  local tmp_lbl_9 = tmp_skill:Find("lbl_9")
  local lbl_9 = gui:Create("Label")
  if nx_is_valid(lbl_9) and nx_is_valid(tmp_lbl_9) then
    local props_tab = nx_property_list(tmp_lbl_9)
    for i = 1, table.getn(props_tab) do
      nx_set_property(lbl_9, props_tab[i], nx_property(tmp_lbl_9, props_tab[i]))
    end
    gb_skill:Add(lbl_9)
    gb_skill.lbl_9 = lbl_9
  end
  local tmp_rbtn_3 = tmp_skill:Find("rbtn_3")
  local rbtn_3 = gui:Create("RadioButton")
  if nx_is_valid(rbtn_3) and nx_is_valid(tmp_rbtn_3) then
    local props_tab = nx_property_list(tmp_rbtn_3)
    for i = 1, table.getn(props_tab) do
      nx_set_property(rbtn_3, props_tab[i], nx_property(tmp_rbtn_3, props_tab[i]))
    end
    gb_skill:Add(rbtn_3)
    gb_skill.rbtn_3 = rbtn_3
  end
  local tmp_rbtn_4 = tmp_skill:Find("rbtn_4")
  local rbtn_4 = gui:Create("RadioButton")
  if nx_is_valid(rbtn_4) and nx_is_valid(tmp_rbtn_4) then
    local props_tab = nx_property_list(tmp_rbtn_4)
    for i = 1, table.getn(props_tab) do
      nx_set_property(rbtn_4, props_tab[i], nx_property(tmp_rbtn_4, props_tab[i]))
    end
    gb_skill:Add(rbtn_4)
    gb_skill.rbtn_4 = rbtn_4
  end
  local tmp_lbl_rbtn_3 = tmp_skill:Find("lbl_rbtn_3")
  local lbl_rbtn_3 = gui:Create("Label")
  if nx_is_valid(lbl_rbtn_3) and nx_is_valid(tmp_lbl_rbtn_3) then
    local props_tab = nx_property_list(tmp_lbl_rbtn_3)
    for i = 1, table.getn(props_tab) do
      nx_set_property(lbl_rbtn_3, props_tab[i], nx_property(tmp_lbl_rbtn_3, props_tab[i]))
    end
    gb_skill:Add(lbl_rbtn_3)
    gb_skill.lbl_rbtn_3 = lbl_rbtn_3
  end
  local tmp_lbl_rbtn_4 = tmp_skill:Find("lbl_rbtn_4")
  local lbl_rbtn_4 = gui:Create("Label")
  if nx_is_valid(lbl_rbtn_4) and nx_is_valid(tmp_lbl_rbtn_4) then
    local props_tab = nx_property_list(tmp_lbl_rbtn_4)
    for i = 1, table.getn(props_tab) do
      nx_set_property(lbl_rbtn_4, props_tab[i], nx_property(tmp_lbl_rbtn_4, props_tab[i]))
    end
    gb_skill:Add(lbl_rbtn_4)
    gb_skill.lbl_rbtn_4 = lbl_rbtn_4
  end
  return item
end
function clone_sweet_groupbox(form, type)
  local gui = nx_value("gui")
  if not nx_is_valid(form) or not nx_is_valid(gui) then
    return nil
  end
  local item = gui:Create("GroupBox")
  local tpl_item = form.gb_place_item
  if not nx_is_valid(item) or not nx_is_valid(tpl_item) then
    return nil
  end
  item.dynamic_create = true
  local prop_tab = nx_property_list(tpl_item)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(item, prop_tab[i], nx_property(tpl_item, prop_tab[i]))
  end
  local tmp_bg = tpl_item:Find("cbtn_bg")
  local cbtn_bg = gui:Create("CheckButton")
  if nx_is_valid(cbtn_bg) and nx_is_valid(tmp_bg) then
    local props_tab = nx_property_list(tmp_bg)
    for i = 1, table.getn(props_tab) do
      nx_set_property(cbtn_bg, props_tab[i], nx_property(tmp_bg, props_tab[i]))
    end
    nx_bind_script(cbtn_bg, FORM_NAME)
    nx_callback(cbtn_bg, "on_checked_changed", "on_cbtn_bg_checked_changed")
    item.cbtn_bg = cbtn_bg
  end
  if nx_number(type) == nx_number(2) then
    local tmp_mtbox = tpl_item:Find("mltbox_no_hire_tips")
    if not nx_is_valid(tmp_mtbox) then
      return item
    end
    local mltbox_no_hire_tips = gui:Create("MultiTextBox")
    local props_tab = nx_property_list(tmp_mtbox)
    for i = 1, table.getn(props_tab) do
      nx_set_property(mltbox_no_hire_tips, props_tab[i], nx_property(tmp_mtbox, props_tab[i]))
    end
    item:Add(mltbox_no_hire_tips)
    item.mltbox_no_hire_tips = mltbox_no_hire_tips
    item:Add(cbtn_bg)
    return item
  end
  if nx_number(type) ~= nx_number(1) then
    return item
  end
  item:Add(cbtn_bg)
  local tmp_photo = tpl_item:Find("lbl_photo")
  local lbl_photo = gui:Create("Label")
  if nx_is_valid(lbl_photo) and nx_is_valid(tmp_photo) then
    local props_tab = nx_property_list(tmp_photo)
    for i = 1, table.getn(props_tab) do
      nx_set_property(lbl_photo, props_tab[i], nx_property(tmp_photo, props_tab[i]))
    end
    item:Add(lbl_photo)
    item.lbl_photo = lbl_photo
  end
  local tmp_lbl_1 = tpl_item:Find("lbl_1")
  local lbl_1 = gui:Create("Label")
  if nx_is_valid(lbl_1) and nx_is_valid(tmp_lbl_1) then
    local props_tab = nx_property_list(tmp_lbl_1)
    for i = 1, table.getn(props_tab) do
      nx_set_property(lbl_1, props_tab[i], nx_property(tmp_lbl_1, props_tab[i]))
    end
    item:Add(lbl_1)
    item.lbl_1 = lbl_1
  end
  local tmp_name = tpl_item:Find("lbl_name")
  local lbl_name = gui:Create("Label")
  if nx_is_valid(lbl_name) and nx_is_valid(tmp_name) then
    local props_tab = nx_property_list(tmp_name)
    for i = 1, table.getn(props_tab) do
      nx_set_property(lbl_name, props_tab[i], nx_property(tmp_name, props_tab[i]))
    end
    item:Add(lbl_name)
    item.lbl_name = lbl_name
  end
  local tmp_lbl_2 = tpl_item:Find("lbl_2")
  local lbl_2 = gui:Create("Label")
  if nx_is_valid(lbl_2) and nx_is_valid(tmp_lbl_2) then
    local props_tab = nx_property_list(tmp_lbl_2)
    for i = 1, table.getn(props_tab) do
      nx_set_property(lbl_2, props_tab[i], nx_property(tmp_lbl_2, props_tab[i]))
    end
    item:Add(lbl_2)
    item.lbl_2 = lbl_2
  end
  local tmp_shili = tpl_item:Find("lbl_shili")
  local lbl_shili = gui:Create("Label")
  if nx_is_valid(lbl_shili) and nx_is_valid(tmp_shili) then
    local props_tab = nx_property_list(tmp_shili)
    for i = 1, table.getn(props_tab) do
      nx_set_property(lbl_shili, props_tab[i], nx_property(tmp_shili, props_tab[i]))
    end
    item:Add(lbl_shili)
    item.lbl_shili = lbl_shili
  end
  local tmp_lbl_3 = tpl_item:Find("lbl_3")
  local lbl_3 = gui:Create("Label")
  if nx_is_valid(lbl_3) and nx_is_valid(tmp_lbl_3) then
    local props_tab = nx_property_list(tmp_lbl_3)
    for i = 1, table.getn(props_tab) do
      nx_set_property(lbl_3, props_tab[i], nx_property(tmp_lbl_3, props_tab[i]))
    end
    item:Add(lbl_3)
    item.lbl_3 = lbl_3
  end
  local tmp_level = tpl_item:Find("lbl_level")
  local lbl_level = gui:Create("Label")
  if nx_is_valid(lbl_level) and nx_is_valid(tmp_level) then
    local props_tab = nx_property_list(tmp_level)
    for i = 1, table.getn(props_tab) do
      nx_set_property(lbl_level, props_tab[i], nx_property(tmp_level, props_tab[i]))
    end
    item:Add(lbl_level)
    item.lbl_level = lbl_level
  end
  local tmp_lbl_4 = tpl_item:Find("lbl_4")
  local lbl_4 = gui:Create("Label")
  if nx_is_valid(lbl_4) and nx_is_valid(tmp_lbl_4) then
    local props_tab = nx_property_list(tmp_lbl_4)
    for i = 1, table.getn(props_tab) do
      nx_set_property(lbl_4, props_tab[i], nx_property(tmp_lbl_4, props_tab[i]))
    end
    item:Add(lbl_4)
    item.lbl_4 = lbl_4
  end
  local tmp_status = tpl_item:Find("lbl_status")
  local lbl_status = gui:Create("Label")
  if nx_is_valid(lbl_status) and nx_is_valid(tmp_status) then
    local props_tab = nx_property_list(tmp_status)
    for i = 1, table.getn(props_tab) do
      nx_set_property(lbl_status, props_tab[i], nx_property(tmp_status, props_tab[i]))
    end
    item:Add(lbl_status)
    item.lbl_status = lbl_status
  end
  local tmp_set = tpl_item:Find("btn_set")
  local btn_set = gui:Create("Button")
  if nx_is_valid(btn_set) and nx_is_valid(tmp_set) then
    local props_tab = nx_property_list(tmp_set)
    for i = 1, table.getn(props_tab) do
      nx_set_property(btn_set, props_tab[i], nx_property(tmp_set, props_tab[i]))
    end
    nx_bind_script(btn_set, FORM_NAME)
    nx_callback(btn_set, "on_click", "on_btn_set_click")
    item:Add(btn_set)
    item.btn_set = btn_set
  end
  local tmp_chuzhan = tpl_item:Find("btn_chuzhan")
  local btn_chuzhan = gui:Create("Button")
  if nx_is_valid(btn_chuzhan) and nx_is_valid(tmp_chuzhan) then
    local props_tab = nx_property_list(tmp_chuzhan)
    for i = 1, table.getn(props_tab) do
      nx_set_property(btn_chuzhan, props_tab[i], nx_property(tmp_chuzhan, props_tab[i]))
    end
    nx_bind_script(btn_chuzhan, FORM_NAME)
    nx_callback(btn_chuzhan, "on_click", "on_btn_chuzhan_click")
    item:Add(btn_chuzhan)
    item.btn_chuzhan = btn_chuzhan
  end
  local tmp_xiuxi = tpl_item:Find("btn_xiuxi")
  local btn_xiuxi = gui:Create("Button")
  if nx_is_valid(btn_xiuxi) and nx_is_valid(tmp_xiuxi) then
    local props_tab = nx_property_list(tmp_xiuxi)
    for i = 1, table.getn(props_tab) do
      nx_set_property(btn_xiuxi, props_tab[i], nx_property(tmp_xiuxi, props_tab[i]))
    end
    nx_bind_script(btn_xiuxi, FORM_NAME)
    nx_callback(btn_xiuxi, "on_click", "on_btn_xiuxi_click")
    item:Add(btn_xiuxi)
    item.btn_xiuxi = btn_xiuxi
  end
  return item
end
function on_cbtn_bg_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not cbtn.Checked or not nx_is_valid(form) then
    return
  end
  local child_table = form.gsb_sweet:GetChildControlList()
  local child_count = table.getn(child_table)
  for i = child_count, 1, -1 do
    local child = child_table[i]
    if nx_is_valid(child) and nx_find_custom(child, "dynamic_create") and nx_number(child.cbtn_bg.TabIndex) ~= nx_number(cbtn.TabIndex) then
      child.cbtn_bg.Checked = false
    end
  end
end
function on_btn_set_click(btn)
  local gb = btn.Parent
  if not nx_is_valid(gb) or not nx_find_custom(gb, "sweet_index") then
    return
  end
  local sweet_index = gb.sweet_index
  btn.ParentForm.sweet_index = sweet_index
  nx_execute("form_stage_main\\form_sweet_employ\\form_offline_employee", "open_form")
end
function on_btn_xiuxi_click(btn)
end
function on_btn_chuzhan_click(btn)
end
function on_cbtn_team_title_checked_changed(cbtn)
  local form = cbtn.ParentForm
  local gb = cbtn.Parent
  if not nx_is_valid(form) or not nx_is_valid(gb) then
    return
  end
  if cbtn.Checked then
    gb.Height = form.gb_team_item.Height
  else
    gb.Height = gb.cbtn_team_title.Height
  end
  form.gsb_team_set.IsEditMode = false
  form.gsb_team_set:ResetChildrenYPos()
end
function on_btn_jiejiao_record_click(btn)
  nx_execute("form_stage_main\\form_sweet_employ\\form_offline_employee_records", "open_form")
end
function sweet_team_set(form)
  if not nx_is_valid(form) then
    return
  end
  form.gsb_sweet.Visible = false
  form.gsb_team_set.Visible = true
end
function init_team_set(ctl, number)
  local form = ctl.ParentForm
  if nx_number(number) < nx_number(1) or not nx_is_valid(form) then
    return
  end
  for i = 1, number do
    local gb = clone_team_set_groupbox(form)
    if nx_is_valid(gb) then
      gb.Visible = true
      gb.cbtn_team_title.Text = nx_widestr(i) .. nx_widestr("\200\203\179\246\213\189")
      gb.Height = gb.cbtn_team_title.Height
      gb.cbtn_team_title.TabIndex = i
      gb.team_index = i
      ctl:Add(gb)
    end
  end
  ctl.IsEditMode = false
  ctl:ResetChildrenYPos()
end
