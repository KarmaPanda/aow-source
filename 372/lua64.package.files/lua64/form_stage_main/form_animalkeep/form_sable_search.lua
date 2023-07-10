require("util_functions")
require("share\\client_custom_define")
require("util_gui")
require("form_stage_main\\form_tiguan\\form_tiguan_util")
require("share\\view_define")
require("util_static_data")
require("define\\sysinfo_define")
function main_form_init(self)
  self.Fixed = false
  self.Visible = false
  self.cur_gbox_count = 0
  return 1
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  form.Visible = false
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_cbtn_select_click(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  for i = 1, form.cur_gbox_count do
    local gbox = form.groupscrollbox_1:Find("gbox_choice_" .. nx_string(i))
    if nx_is_valid(gbox) then
      local cbtn_select = gbox:Find("cbtn_choice_select_" .. nx_string(i))
      if nx_is_valid(cbtn_select) and cbtn.sort_id ~= cbtn_select.sort_id then
        cbtn_select.Checked = false
      end
    end
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_select_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local select_index = -1
  for i = 1, form.cur_gbox_count do
    local gbox = form.groupscrollbox_1:Find("gbox_choice_" .. nx_string(i))
    if nx_is_valid(gbox) then
      local cbtn_select = gbox:Find("cbtn_choice_select_" .. nx_string(i))
      if nx_is_valid(cbtn_select) and cbtn_select.Checked then
        select_index = cbtn_select.sort_id
      end
    end
  end
  if select_index == -1 then
    local text = get_desc_by_id("ui_sable_select_none")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, CENTERINFO_PERSONAL_NO)
    end
  else
    local skill_form = nx_value("form_stage_main\\form_animalkeep\\form_sable_skill")
    if nx_is_valid(skill_form) then
      nx_execute("form_stage_main\\form_animalkeep\\form_sable_skill", "set_select_type", select_index)
    end
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    form:Close()
  end
end
function get_desc_by_id(text_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  return gui.TextManager:GetText(nx_string(text_id))
end
function show_choice_info(str_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local form = util_get_form("form_stage_main\\form_animalkeep\\form_sable_search", true)
  if not nx_is_valid(form) then
    return 0
  end
  form.groupscrollbox_1:DeleteAll()
  local boss_list = util_split_string(str_id, ",")
  if boss_list ~= nil then
    local option_count = table.getn(boss_list)
    form.cur_gbox_count = option_count
    for i = 1, option_count do
      local groupbox = create_ctrl("GroupBox", "gbox_choice_" .. nx_string(i), form.groupbox_template, form.groupscrollbox_1)
      local cbtn_select = create_ctrl("CheckButton", "cbtn_choice_select_" .. nx_string(i), form.cbtn_tmp_select, groupbox)
      local lbl_name = create_ctrl("Label", "lbl_choice_boss_name_" .. nx_string(i), form.lbl_tmp_name, groupbox)
      cbtn_select.sort_id = nx_number(boss_list[i])
      nx_bind_script(cbtn_select, nx_current())
      nx_callback(cbtn_select, "on_click", "on_cbtn_select_click")
      local boss_id = "sable_choice_" .. nx_string(boss_list[i])
      lbl_name.Text = gui.TextManager:GetText(boss_id)
    end
    if 0 < option_count then
      local h = form.groupbox_template.Height
      form.groupscrollbox_1.Height = h * nx_number(option_count)
      form.lbl_2.Top = 40 + h * nx_number(option_count)
      form.btn_select.Top = 55 + h * nx_number(option_count)
      form.Height = 100 + h * nx_number(option_count)
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    end
  end
  form.groupscrollbox_1:ResetChildrenYPos()
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  ctrl.Name = name
  return ctrl
end
