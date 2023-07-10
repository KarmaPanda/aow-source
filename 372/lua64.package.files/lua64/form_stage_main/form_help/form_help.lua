local maxpage = 50
function main_form_init(self)
  self.curpage = 1
  self.taskid = 0
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  form = self
  refresh_page(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  nx_execute("custom_sender", "custom_accept_task", nx_int(form.taskid))
  form:Close()
end
function on_btn_pageback_click(self)
  if form.curpage > 2 then
    form.curpage = form.curpage - 2
    refresh_page(form)
  end
end
function on_btn_pagenext_click(self)
  if form.curpage < maxpage - 1 then
    form.curpage = form.curpage + 2
    refresh_page(form)
  end
end
function on_btn_start_click(self)
  form.curpage = 3
  refresh_page(form)
end
function refresh_page(self)
  local gui = nx_value("gui")
  local tempinfo1 = gui.TextManager:GetFormatText("helppage" .. nx_string(self.curpage))
  local tempinfo2 = gui.TextManager:GetFormatText("helppage" .. nx_string(self.curpage + 1))
  self.mltbox_1:Clear()
  self.mltbox_2:Clear()
  self.mltbox_1:AddHtmlText(nx_widestr(tempinfo1), nx_int(self.curpage))
  self.mltbox_2:AddHtmlText(nx_widestr(tempinfo2), nx_int(self.curpage + 1))
  if self.curpage >= maxpage then
    return
  end
  self.lbl_curpage.Text = nx_widestr(self.curpage)
  if self.curpage == 1 then
    self.BackImage = "gui\\SystemHelp\\p1.png"
  elseif self.curpage == 3 then
    self.BackImage = "gui\\SystemHelp\\p3.png"
  else
    self.BackImage = "gui\\SystemHelp\\systemhelp.png"
  end
end
function on_mltbox_1_click_hyperlink(self, itemindex, linkdata)
  form.curpage = nx_int(linkdata)
  refresh_page(form)
end
function on_mltbox_2_click_hyperlink(self, itemindex, linkdata)
  form.curpage = nx_int(linkdata)
  refresh_page(form)
end
