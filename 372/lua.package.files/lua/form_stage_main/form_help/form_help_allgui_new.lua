require("util_gui")
require("util_functions")
function main_form_init(form)
  form.Fixed = false
  form.page_index = 1
  form.pageCount = 0
  form.ini_doc = nil
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.btn_front.Enabled = false
end
function on_main_form_close(form)
  nx_destroy(form)
  return
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  return
end
function on_btn_front_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.btn_next.Enabled == false then
    form.btn_next.Enabled = true
  end
  form.page_index = form.page_index - 1
  if form.page_index <= 1 then
    form.btn_front.Enabled = false
  end
  change_help_illuminate(form)
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.btn_front.Enabled == false then
    form.btn_front.Enabled = true
  end
  form.page_index = form.page_index + 1
  if form.page_index <= form.pageCount then
    change_help_illuminate(form)
  elseif form.page_index == form.pageCount + 1 then
    form:Close()
  end
end
function change_help_illuminate(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if form.page_index == 1 then
    form.btn_next.Left = 227
    form.btn_front.Visible = false
  elseif form.page_index == 2 then
    form.btn_next.Left = 342
    form.btn_front.Visible = true
  elseif form.page_index == form.pageCount - 1 then
    form.btn_next.Text = nx_widestr("@ui_next")
  elseif form.page_index == form.pageCount then
    form.btn_next.Text = nx_widestr("@ui_ok")
  end
  local photos = form.ini_doc:ReadString(form.page_index - 1, "photo", "")
  local texts = form.ini_doc:ReadString(form.page_index - 1, "text", "")
  form.lbl_1.BackImage = photos
  form.mltbox_1.HtmlText = nx_widestr(gui.TextManager:GetText(texts))
end
function init_help_form(name)
  local ini_doc = get_ini(name)
  if nx_is_null(ini_doc) then
    nx_msgbox("ini\188\211\212\216\202\167\176\220")
    return false
  else
    local gui = nx_value("gui")
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_help\\form_help_AllGui_New", true, false)
    if not nx_is_valid(form) then
      return false
    end
    form.ini_doc = ini_doc
    form.pageCount = form.ini_doc:GetSectionCount()
    change_help_illuminate(form)
    form:ShowModal()
  end
end
