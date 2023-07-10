require("util_gui")
require("util_functions")
require("form_stage_main\\switch\\switch_define")
local PAGE = {
  [1] = "form_stage_main\\form_redeem\\form_character_zonglan",
  [2] = "form_stage_main\\form_redeem\\form_character_information",
  [3] = "form_stage_main\\form_redeem\\form_redeem",
  [4] = "form_stage_main\\form_redeem\\form_punish_note"
}
function open_form()
  if not is_open_character_pk() then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("7544"), 2)
    end
    return
  end
  util_auto_show_hide_form(nx_current())
end
function main_form_init(form)
  form.Fixed = false
  form.cur_page = 1
  form.max_page = 3
  form.icg_goods = nx_null()
  for i = 1, 4 do
    nx_set_custom(form, "InitPage_" .. nx_string(i), false)
  end
  return 1
end
function on_main_form_open(form)
  change_form_size(form)
  local helper_form = nx_value("helper_form")
  if not helper_form then
    form.rbtn_1.Checked = true
  else
    form.rbtn_3.Checked = true
  end
  return 1
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function change_form_size(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_rbtn_checked_changed(btn)
  if not btn.Checked then
    return
  end
  local form = btn.ParentForm
  local res_str = util_split_string(nx_string(btn.Name), "_")
  local page_index = nx_number(res_str[2])
  hide_all_page(form)
  if not nx_custom(form, "InitPage_" .. nx_string(page_index)) then
    local page = util_get_form(nx_string(PAGE[page_index]), true, false)
    if nx_is_valid(page) and form:Add(page) then
      page.Width = form.groupbox_subform.Width
      page.Height = form.groupbox_subform.Height
      page.Left = form.groupbox_subform.Left
      page.Top = form.groupbox_subform.Top
      page.Visible = false
      nx_set_custom(form, "Page_" .. nx_string(page_index), page)
      nx_set_custom(form, "InitPage_" .. nx_string(page_index), true)
      if nx_string("3") == nx_string(page_index) then
        nx_set_custom(form, "icg_goods", page.icg_goods)
      end
    end
  end
  local page = nx_custom(form, "Page_" .. nx_string(page_index))
  page.Visible = true
  form:ToFront(page)
end
function hide_all_page(form)
  for i = 1, 4 do
    if nx_custom(form, "InitPage_" .. nx_string(i)) then
      local page = nx_custom(form, "Page_" .. nx_string(i))
      page.Visible = false
    end
  end
end
function is_open_character_pk()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return false
  end
  return switch_manager:CheckSwitchEnable(ST_FUNCTION_PK_PUNISH)
end
