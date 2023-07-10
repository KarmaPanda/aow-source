require("util_gui")
require("util_functions")
require("define\\object_type_define")
require("control_set")
local FORM_EMPLOY_CONFIRM = "form_stage_main\\form_sweet_employ\\form_employ_confirm"
function main_form_init(form)
  form.Fixed = false
  form.name = ""
  return 1
end
function on_main_form_open(form)
  change_form_size()
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_employ_click(btn)
  local form = btn.ParentForm
  local info = util_format_string("ui_sweetemploy_24", nx_widestr(form.name))
  local res = util_form_confirm("", info)
  if res == "ok" then
    nx_execute("custom_sender", "custom_offline_employ", nx_int(1), nx_widestr(form.name))
    form:Close()
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(btn, "flag_show_strength") and nx_int(btn.flag_show_strength) == nx_int(1) then
    form:Close()
    return
  end
  local info = util_format_string("ui_sweetemploy_26", nx_widestr(form.name))
  local res = util_form_confirm("", info)
  if res == "ok" then
    form:Close()
  end
end
function init_info(form, show_strength, ...)
  local name = arg[2]
  local leveltitle = arg[3]
  local school = arg[4]
  local weapon = arg[5]
  local neigong = arg[6]
  local jingmai = arg[7]
  local pos = arg[8]
  local maxhp = arg[9]
  local maxmp = arg[10]
  local sceneid = arg[11]
  local photo = arg[12]
  form.name = name
  form.lbl_photo.BackImage = nx_string(photo)
  form.lbl_name.Text = nx_widestr(name)
  form.lbl_leveltitle.Text = util_text("desc_" .. leveltitle)
  form.lbl_school.Text = util_text(school)
  if nx_string(school) == nx_string("") then
    form.lbl_school.Text = util_text("ui_none")
  end
  local text_weapon = util_text("ui_none")
  if nx_number(weapon) ~= nx_number(0) then
    text_weapon = util_text("tips_itemtype_" .. nx_string(weapon))
  end
  form.mltbox_weapon:Clear()
  form.mltbox_weapon:AddHtmlText(text_weapon, -1)
  form.lbl_neigong.Text = util_text(neigong)
  form.lbl_jingmai.Text = nx_widestr(jingmai)
  form.lbl_zuobiao.Text = nx_widestr(pos)
  form.lbl_HP.Text = nx_widestr(maxhp)
  form.lbl_MP.Text = nx_widestr(maxmp)
  form.lbl_sence.Text = util_text("ui_scene_" .. nx_string(sceneid))
  form.lbl_karmalevel.Text = nx_widestr("0")
  show_strength_button(form, show_strength)
end
function change_form_size()
  local form = nx_value(FORM_EMPLOY_CONFIRM)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_btn_add_attention_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local name = form.lbl_name.Text
  if nx_string(name) == nx_string("") then
    return
  end
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_attention", name)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function show_strength_button(form, bShow)
  if bShow then
    form.btn_add_attention.Visible = true
    form.btn_close1.Visible = true
    form.btn_employ.Visible = false
    form.btn_cancel.Visible = false
    nx_set_custom(form.btn_close, "flag_show_strength", nx_int(1))
  else
    form.btn_add_attention.Visible = false
    form.btn_close1.Visible = false
    form.btn_employ.Visible = true
    form.btn_cancel.Visible = true
    nx_set_custom(form.btn_close, "flag_show_strength", nx_int(0))
  end
end
