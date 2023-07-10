require("util_static_data")
require("util_functions")
require("util_gui")
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function open_form(...)
  util_auto_show_hide_form("form_stage_main\\form_night_forever\\form_letter")
  local form = nx_value("form_stage_main\\form_night_forever\\form_letter")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local info = arg[1]
  local index = 1
  local str = gui.TextManager:GetText(info)
  for i = 1, 16 do
    local child_name = string.format("%s_%s", nx_string("mltbox"), nx_string(i))
    local mltbox = form.groupbox_1:Find(child_name)
    local font_count = (nx_number(mltbox.LineHeight) - 1) / 2
    local end_index = index + font_count * 2 - 1
    local sub_str = nx_function("ext_ws_substr", str, index, end_index)
    index = index + font_count * 2
    mltbox:AddHtmlText(nx_widestr(sub_str), nx_int(-1))
  end
end
