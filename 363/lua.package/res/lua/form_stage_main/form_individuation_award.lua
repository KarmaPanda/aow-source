require("util_gui")
function on_init_form(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  self.Fixed = false
  self.msgbox = nx_widestr(gui.TextManager:GetText("ui_idt_back_1"))
  return 1
end
function on_open_form(form)
  form.Visible = true
  return 1
end
function on_close_form(form)
  form.Visible = false
  nx_destroy(form)
end
function close_form()
  local form = nx_value("form_stage_main\\form_individuation_award")
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  nx_destroy(form)
end
function show_form(award_type, str_config_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_individuation_award", true)
  if not nx_is_valid(form) then
    return
  end
  form.msgbox.HtmlText = nx_widestr(gui.TextManager:GetText("ui_idt_back_" .. nx_string(award_type)))
  local ItemsQuery = nx_value("ItemQuery")
  local photo = ItemsQuery:GetItemPropByConfigID(str_config_id, "Photo")
  if photo ~= "" then
    form.imagegrid_1:AddItem(nx_int(0), photo, util_text(str_config_id), nx_int(0), -1)
  end
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_individuation_award", true)
end
function on_click_get_award(btn)
  nx_execute("custom_sender", "custom_enter_scene", 0)
end
