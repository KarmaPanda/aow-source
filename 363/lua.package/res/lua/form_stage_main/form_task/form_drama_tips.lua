require("util_functions")
require("util_gui")
function main_form_init(self)
  self.Fixed = false
  self.Visible = false
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  local chapter_index = gui.TextManager:GetText("ui_chapter_" .. nx_string(self.chapter))
  local chapter_name = gui.TextManager:GetText(nx_string(self.chapter_name))
  local context_text = nx_widestr(chapter_index) .. nx_widestr(" ") .. nx_widestr(chapter_name)
  self.lbl_drama_chapter.Text = nx_widestr(context_text)
  for i = 5, self.explore + 1, -1 do
    local lable = self:Find("lbl_explore_pic_" .. nx_string(i))
    if nx_is_valid(lable) then
      lable.BlendColor = "50,0,0,0"
    end
  end
  for i = 5, self.challenge + 1, -1 do
    local lable = self:Find("lbl_challenge_pic_" .. nx_string(i))
    if nx_is_valid(lable) then
      lable.BlendColor = "50,0,0,0"
    end
  end
  gui.TextManager:Format_SetIDName("ui_drama_explore_" .. nx_string(self.explore))
  self.mltbox_explore.HtmlText = gui.TextManager:Format_GetText()
  gui.TextManager:Format_SetIDName("ui_drama_challenge_" .. nx_string(self.challenge))
  self.mltbox_challenge.HtmlText = gui.TextManager:Format_GetText()
  if self.detail == "" then
    self.lbl_detail.Visible = false
    self.mltbox_detail.Visible = false
    self.lbl_brief.Visible = false
    self.mltbox_brief.Visible = false
    self.lbl_detail_title.Visible = false
    self.lbl_detail_pic_1.Visible = false
    self.lbl_detail_pic_2.Visible = false
    self.lbl_detail_pic_3.Visible = false
    self.lbl_detail_pic_4.Visible = false
    self.lbl_detail_pic_5.Visible = false
    gui.TextManager:Format_SetIDName(self.brief)
    self.mltbox_brief_bak.HtmlText = gui.TextManager:Format_GetText()
  else
    self.lbl_brief_bak.Visible = false
    self.mltbox_brief_bak.Visible = false
    for i = 1, 5 do
      local lable = self:Find("lbl_detail_pic_" .. nx_string(i))
      if nx_is_valid(lable) then
        if nx_int(i) <= nx_int(self.pic_num) then
          lable.BackImage = "gui\\special\\task\\drama\\" .. self.title .. "_" .. nx_string(i) .. ".png"
        else
          lable.Visible = false
        end
      end
    end
    gui.TextManager:Format_SetIDName(self.title)
    self.lbl_detail_title.Text = gui.TextManager:Format_GetText()
    gui.TextManager:Format_SetIDName(self.detail)
    self.mltbox_detail.HtmlText = gui.TextManager:Format_GetText()
    gui.TextManager:Format_SetIDName(self.brief)
    self.mltbox_brief.HtmlText = gui.TextManager:Format_GetText()
  end
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
  return 1
end
function on_btn_ok_click(self)
  local form = self.ParentForm
  form:Close()
  return 1
end
function show_begin_drama_info(...)
  if table.getn(arg) < 6 then
    return
  end
  local chapter = arg[1]
  local chapter_name = arg[2]
  local explore = arg[3]
  local challenge = arg[4]
  local brief = arg[5]
  local detail = arg[6]
  local title = arg[7]
  local pic_num = arg[8]
  local form = util_get_form("form_stage_main\\form_task\\form_drama_tips", true)
  if not nx_is_valid(form) then
    return
  end
  form.chapter = chapter
  form.chapter_name = chapter_name
  form.explore = explore
  form.challenge = challenge
  form.brief = brief
  form.detail = detail
  form.title = title
  form.pic_num = pic_num
  util_show_form("form_stage_main\\form_task\\form_drama_tips", true)
end
