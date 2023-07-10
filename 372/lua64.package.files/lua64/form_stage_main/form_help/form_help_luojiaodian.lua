require("util_functions")
require("util_gui")
local image_list = {
  [1] = "gui\\special\\helper\\luojiaodian\\1.png",
  [2] = "gui\\special\\helper\\luojiaodian\\2.png",
  [3] = "gui\\special\\helper\\luojiaodian\\3.png",
  [4] = "gui\\special\\helper\\luojiaodian\\4.png"
}
local text_list = {
  [1] = "ui_luojiaodian_yindao_1",
  [2] = "ui_luojiaodian_yindao_2",
  [3] = "ui_luojiaodian_yindao_3",
  [4] = "ui_luojiaodian_yindao_4"
}
function on_main_form_open(self)
  on_gui_size_change(self)
  self.btn_next_page.index = 1
  self.lbl_6.Text = nx_widestr(util_text(nx_string(text_list[1])))
  self.btn_pre_page.Visible = false
  self.btn_next_page.Left = (self.Width - self.btn_next_page.Width) / 2
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_ok_click(self)
  local form = self.ParentForm
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  local index = form.btn_next_page.index
  if index == table.getn(image_list) then
    form.Visible = false
    form:Close()
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", nx_string("luojiaodian_help"), "1")
    return 1
  end
  index = index + 1
  if index == table.getn(image_list) then
    self.Text = nx_widestr("@ui_sns_chat_close")
  end
  form.lbl_5.BackImage = image_list[index]
  form.btn_next_page.index = index
  form.btn_next_page.Left = form.btn_pre_page.Left + form.btn_pre_page.Width + 30
  form.lbl_6.Text = nx_widestr(util_text(nx_string(text_list[index])))
  form.btn_pre_page.Visible = true
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form.Visible = false
  form:Close()
end
function on_gui_size_change(form)
  if not nx_is_valid(form) then
    form = nx_value(nx_current())
  end
  if not nx_is_valid(form) then
    return 1
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_btn_pre_page_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "last_helper_form")
  local index = form.btn_next_page.index
  index = index - 1
  if index == 1 then
    btn.Visible = false
    form.btn_next_page.Left = (form.Width - form.btn_next_page.Width) / 2
  end
  if index ~= table.getn(image_list) then
    form.btn_next_page.Text = nx_widestr("@ui_xiayiye")
  end
  form.lbl_5.BackImage = image_list[index]
  form.btn_next_page.index = index
  form.lbl_6.Text = nx_widestr(util_text(nx_string(text_list[index])))
end
