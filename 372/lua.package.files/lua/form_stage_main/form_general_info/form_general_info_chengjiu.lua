require("util_functions")
local TitleType_1 = 1
local TitleType_2 = 2
local TitleType_3 = 3
local log = function(str)
  str = nx_string(str)
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
end
function on_main_form_open(self)
  self.rbtn_title.Checked = true
  self.groupbox_tips.Visible = false
  self.groupbox_4.Left = -1024
  self.cbtn_title_t.Left = -1024
  self.groupbox_title_t.Left = -1024
  self.cbtn_ls_t.Left = -1024
  self.groupbox_ls_t.Left = -1024
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_rbtn_title_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  form.groupbox_xz.Visible = false
  form.groupbox_ls.Visible = false
  form.groupbox_title.Visible = true
  form.rbtn_1.Checked = true
end
function on_rbtn_ls_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  form.groupbox_xz.Visible = false
  form.groupbox_ls.Visible = true
  form.groupbox_title.Visible = false
  form.rbtn_7.Checked = true
end
function on_rbtn_xz_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  form.groupbox_xz.Visible = true
  form.groupbox_ls.Visible = false
  form.groupbox_title.Visible = false
end
function on_cbtn_title_check_changed(cbtn)
  local form_chengjiu = nx_value("form_chengjiu")
  if not nx_is_valid(form_chengjiu) then
    return
  end
  local form = cbtn.ParentForm
  local groupscrollbox_title = form.groupscrollbox_title
  local form_chengjiu = nx_value("form_chengjiu")
  local gui = nx_value("gui")
  if cbtn.Checked then
    local title_list = form_chengjiu:GetSubTitleList(nx_string(get_curtitle_maintype(form)), nx_string(cbtn.DataSource))
    for _, title_id in pairs(title_list) do
      local groupbox = create_title_node(title_id, cbtn.DataSource)
      if nx_is_valid(groupbox) then
        groupbox.Left = 0
        groupscrollbox_title:InsertAfter(groupbox, cbtn)
      end
    end
  else
    for i, ctrl in ipairs(groupscrollbox_title:GetChildControlList()) do
      if ctrl.DataSource == cbtn.DataSource and not nx_id_equal(ctrl, cbtn) then
        groupscrollbox_title:Remove(ctrl)
        gui:Delete(ctrl)
      end
    end
  end
  groupscrollbox_title:ResetChildrenYPos()
  hide_tips(form)
end
function create_title_node(title_id, sub_type)
  local form_chengjiu = nx_value("form_chengjiu")
  if not nx_is_valid(form_chengjiu) then
    return
  end
  local title_info = form_chengjiu:GetTitleInfo(nx_int(title_id))
  if table.getn(title_info) < 2 then
    return
  end
  local form = nx_value(nx_current())
  local form_chengjiu = nx_value("form_chengjiu")
  local gui = nx_value("gui")
  local groupbox = gui:Create("GroupBox")
  copy_ent_info(groupbox, form.groupbox_title_t)
  groupbox.DataSource = nx_string(sub_type)
  groupbox.Left = 0
  for i, ctrl in ipairs(form.groupbox_title_t:GetChildControlList()) do
    local ctrl_obj = gui:Create(nx_name(ctrl))
    copy_ent_info(ctrl_obj, ctrl)
    if nx_property(ctrl, "Name") == "lbl_1" then
      ctrl_obj.Text = util_text("role_title_" .. nx_string(title_id))
    end
    if nx_property(ctrl, "Name") == "lbl_6" then
      if form_chengjiu:IsCurTitile(nx_int(title_id)) then
        ctrl_obj.Text = util_text("ui_chengjiu_016")
        ctrl_obj.ForeColor = "255,124,252,0"
      elseif form_chengjiu:FindTitle(nx_int(title_id)) then
        ctrl_obj.Text = util_text("ui_chengjiu_004")
      else
        ctrl_obj.Text = util_text("ui_chengjiu_005")
        ctrl_obj.ForeColor = "255,255,69,0"
      end
    end
    if nx_property(ctrl, "Name") == "btn_1" then
      if form_chengjiu:IsCurTitile(nx_int(title_id)) then
        ctrl_obj.Enabled = false
      elseif not form_chengjiu:FindTitle(nx_int(title_id)) then
        ctrl_obj.Enabled = false
      end
    end
    if nx_property(ctrl, "Name") == "mltbox_3" then
      ctrl_obj:Clear()
      ctrl_obj:AddHtmlText(util_text(title_info[1]), -1)
    end
    if nx_property(ctrl, "Name") == "btn_3" then
      ctrl_obj.DataSource = nx_string(title_id)
      nx_bind_script(ctrl_obj, nx_current())
      nx_callback(ctrl_obj, "on_click", "on_title_detail_btn_click")
    end
    if nx_property(ctrl, "Name") == "btn_1" then
      ctrl_obj.DataSource = nx_string(title_id)
      nx_bind_script(ctrl_obj, nx_current())
      nx_callback(ctrl_obj, "on_click", "on_title_btn_click")
    end
    groupbox:Add(ctrl_obj)
  end
  return groupbox
end
function on_title_btn_click(btn)
  nx_execute("custom_sender", "custom_set_title", nx_int(btn.DataSource))
end
function on_title_detail_btn_click(btn)
  local form_chengjiu = nx_value("form_chengjiu")
  if not nx_is_valid(form_chengjiu) then
    return
  end
  local form = btn.ParentForm
  local title_id = btn.DataSource
  local desc_id = form_chengjiu:GetTitleDetail(nx_int(title_id))
  form.mltbox_text:Clear()
  form.mltbox_text:AddHtmlText(util_text(desc_id), -1)
  form.groupbox_tips.Visible = true
end
function get_curtitle_maintype(form)
  local groupbox = form.groupbox_1
  local child_ctrls = groupbox:GetChildControlList()
  for i, ctrl in ipairs(child_ctrls) do
    if nx_name(ctrl) == "RadioButton" and ctrl.Checked then
      return ctrl.DataSource
    end
  end
  return ""
end
function show_title_groupbox(form, main_type)
  local form_chengjiu = nx_value("form_chengjiu")
  if not nx_is_valid(form_chengjiu) then
    return
  end
  local gui = nx_value("gui")
  local groupscrollbox_title = form.groupscrollbox_title
  groupscrollbox_title:DeleteAll()
  local sub_tyep_t = form_chengjiu:GetSubTitleNameList(nx_string(main_type))
  for _, sub_name in pairs(sub_tyep_t) do
    local cbtn = gui:Create("CheckButton")
    groupscrollbox_title:Add(cbtn)
    copy_ent_info(cbtn, form.cbtn_title_t)
    cbtn.DataSource = nx_string(sub_name)
    cbtn.Text = util_text(sub_name)
    cbtn.Left = -3
    nx_bind_script(cbtn, nx_current())
    nx_callback(cbtn, "on_checked_changed", "on_cbtn_title_check_changed")
  end
  groupscrollbox_title:ResetChildrenYPos()
end
function on_rbtn_7_checked_changed(rbtn)
  hide_tips(rbtn.ParentForm)
  if not rbtn.Checked then
    return
  end
  show_liansheng_groupbox(rbtn.ParentForm, rbtn.DataSource)
end
function on_rbtn_8_checked_changed(rbtn)
  hide_tips(rbtn.ParentForm)
  if not rbtn.Checked then
    return
  end
  show_liansheng_groupbox(rbtn.ParentForm, rbtn.DataSource)
end
function on_rbtn_9_checked_changed(rbtn)
  hide_tips(rbtn.ParentForm)
  if not rbtn.Checked then
    return
  end
  show_liansheng_groupbox(rbtn.ParentForm, rbtn.DataSource)
end
function on_rbtn_1_checked_changed(rbtn)
  hide_tips(rbtn.ParentForm)
  if not rbtn.Checked then
    return
  end
  show_title_groupbox(rbtn.ParentForm, rbtn.DataSource)
end
function on_rbtn_5_checked_changed(rbtn)
  hide_tips(rbtn.ParentForm)
  if not rbtn.Checked then
    return
  end
  show_title_groupbox(rbtn.ParentForm, rbtn.DataSource)
end
function on_cbtn_ls_check_changed(cbtn)
  local form_chengjiu = nx_value("form_chengjiu")
  if not nx_is_valid(form_chengjiu) then
    return
  end
  local form = cbtn.ParentForm
  local groupscrollbox_ls = form.groupscrollbox_ls
  local form_chengjiu = nx_value("form_chengjiu")
  local gui = nx_value("gui")
  if cbtn.Checked then
    local ls_list = form_chengjiu:GetSubWinList(nx_string(get_curls_maintype(form)), nx_string(cbtn.DataSource))
    for i, ls_id in ipairs(ls_list) do
      local groupbox = create_ls_node(ls_id, cbtn.DataSource)
      if nx_is_valid(groupbox) then
        groupbox.Left = 0
        groupscrollbox_ls:InsertAfter(groupbox, cbtn)
      end
    end
  else
    for i, ctrl in ipairs(groupscrollbox_ls:GetChildControlList()) do
      if ctrl.DataSource == cbtn.DataSource and not nx_id_equal(ctrl, cbtn) then
        log(cbtn.DataSource)
        groupscrollbox_ls:Remove(ctrl)
        gui:Delete(ctrl)
      end
    end
  end
  groupscrollbox_ls:ResetChildrenYPos()
  hide_tips(form)
end
function create_ls_node(ls_id, ls_type)
  local form_chengjiu = nx_value("form_chengjiu")
  if not nx_is_valid(form_chengjiu) then
    return
  end
  local ls_info = form_chengjiu:GetWinInfo(nx_string(ls_id))
  if table.getn(ls_info) < 2 then
    return
  end
  local form = nx_value(nx_current())
  local gui = nx_value("gui")
  local groupbox = gui:Create("GroupBox")
  copy_ent_info(groupbox, form.groupbox_ls_t)
  groupbox.DataSource = nx_string(ls_type)
  groupbox.Left = 0
  for i, ctrl in ipairs(form.groupbox_ls_t:GetChildControlList()) do
    local ctrl_obj = gui:Create(nx_name(ctrl))
    copy_ent_info(ctrl_obj, ctrl)
    groupbox:Add(ctrl_obj)
    if nx_property(ctrl, "Name") == "lbl_11" then
      ctrl_obj.Text = util_text(nx_string(ls_id))
    end
    if nx_property(ctrl, "Name") == "lbl_12" then
      local condid = ls_info[2]
      if not check_condition(condid) then
        ctrl_obj.Text = util_text("ui_chengjiu_005")
        ctrl_obj.ForeColor = "255,255,69,0"
      end
    end
    if nx_property(ctrl, "Name") == "mltbox_5" then
      ctrl_obj:Clear()
      ctrl_obj:AddHtmlText(util_text(ls_info[1]), -1)
    end
    if nx_property(ctrl, "Name") == "btn_2" then
      ctrl_obj.DataSource = nx_string(ls_id)
      nx_bind_script(ctrl_obj, nx_current())
      nx_callback(ctrl_obj, "on_click", "on_ls_btn_click")
    end
  end
  return groupbox
end
function on_ls_btn_click(btn)
  local form_chengjiu = nx_value("form_chengjiu")
  if not nx_is_valid(form_chengjiu) then
    return
  end
  local form = btn.ParentForm
  local ls_id = btn.DataSource
  local desc_id = form_chengjiu:GetWinDetail(nx_string(ls_id))
  form.mltbox_text:Clear()
  form.mltbox_text:AddHtmlText(util_text(desc_id), -1)
  form.groupbox_tips.Visible = true
end
function show_liansheng_groupbox(form, main_type)
  local form_chengjiu = nx_value("form_chengjiu")
  if not nx_is_valid(form_chengjiu) then
    return
  end
  local gui = nx_value("gui")
  local groupscrollbox_ls = form.groupscrollbox_ls
  groupscrollbox_ls:DeleteAll()
  local sub_tyep_t = form_chengjiu:GetSubWinNameList(nx_string(main_type))
  for _, sub_name in pairs(sub_tyep_t) do
    local cbtn = gui:Create("CheckButton")
    groupscrollbox_ls:Add(cbtn)
    copy_ent_info(cbtn, form.cbtn_ls_t)
    cbtn.DataSource = nx_string(sub_name)
    cbtn.Text = util_text(sub_name)
    cbtn.Left = -3
    nx_bind_script(cbtn, nx_current())
    nx_callback(cbtn, "on_checked_changed", "on_cbtn_ls_check_changed")
  end
  groupscrollbox_ls:ResetChildrenYPos()
end
function hide_tips(form)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_tips.Visible = false
end
function get_curls_maintype(form)
  local groupbox = form.groupbox_5
  local child_ctrls = groupbox:GetChildControlList()
  for i, ctrl in ipairs(child_ctrls) do
    if nx_name(ctrl) == "RadioButton" and ctrl.Checked then
      return ctrl.DataSource
    end
  end
  return ""
end
function check_condition(condition_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return false
  end
  return condition_manager:CanSatisfyCondition(client_player, client_player, nx_int(condition_id))
end
function show_form(form)
  local form_chengjiu = nx_value(nx_current())
  if not nx_is_valid(form_chengjiu) then
    local form_chengjiu = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
    if nx_is_valid(form_chengjiu) then
      form.groupbox_main:Add(form_chengjiu)
      form.groupbox_main:ToFront(form_chengjiu)
      form_chengjiu.Left = 0
      form_chengjiu.Top = 0
    end
  else
    form_chengjiu:Show()
    form_chengjiu.Visible = true
  end
end
