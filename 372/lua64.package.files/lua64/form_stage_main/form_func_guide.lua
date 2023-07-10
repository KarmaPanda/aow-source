require("util_functions")
local MIN_CHAPTER = 1
local MAX_CHAPTER = 5
function main_form_init(self)
  self.Fixed = false
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2 + 50
  self.AbsTop = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_open(self)
  local form_logic = nx_value("form_func_guide_logic")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  local form_logic = nx_create("form_func_guide")
  if nx_is_valid(form_logic) then
    nx_set_value("form_func_guide_logic", form_logic)
    update_lc_data()
    update_sl_data()
  end
  set_chapter_title(self)
  self.rbtn_licheng.Checked = true
  self.btn_sl_ng.Checked = true
  return 1
end
function on_main_form_close(self)
  local form_logic = nx_value("form_func_guide_logic")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  nx_destroy(self)
  return 1
end
function on_rbtn_licheng_checked_changed(self)
  local form = self.ParentForm
  form.groupbox_shili.Visible = not self.Checked
  form.groupbox_licheng.Visible = self.Checked
  form.groupbox_desc.Visible = false
end
function on_rbtn_shili_checked_changed(self)
  local form = self.ParentForm
  form.groupbox_licheng.Visible = not self.Checked
  form.groupbox_shili.Visible = self.Checked
  form.groupbox_desc.Visible = false
  if self.Checked then
    form.btn_sl_ng.Checked = true
  end
end
function on_cbtn_licheng_item_checked_changed(self)
  if not self.Checked then
    return
  end
  local form = self.ParentForm
  local groupbox = form.groupbox_licheng_btns
  local ctls = groupbox:GetChildControlList()
  for _, gbx in ipairs(ctls) do
    local cbtns = gbx:GetChildControlList()
    for _, btn in ipairs(cbtns) do
      if not nx_id_equal(btn, self) then
        btn.Checked = false
      end
    end
  end
  form.groupbox_desc.Visible = true
  local mltbox = form.mltbox_desc
  mltbox:Clear()
  local form_logic = nx_value("form_func_guide_logic")
  if nx_is_valid(form_logic) then
    local desc = form_logic:GetLcDesc(self.lc_id)
    mltbox:AddHtmlText(desc, -1)
  end
end
function on_rbtn_shili_item_checked_changed(self)
  if not self.Checked then
    return
  end
  local form = self.ParentForm
  local sl_type = self.sl_type
  form.sl_type = sl_type
  local form_logic = nx_value("form_func_guide_logic")
  if nx_is_valid(form_logic) then
    form_logic:ShowSlData(sl_type)
  end
  local form = self.ParentForm
  form.groupbox_desc.Visible = false
end
function on_cbtn_shili_data_checked_changed(self)
  if not self.Checked then
    return
  end
  local form = self.ParentForm
  local groupbox = form.groupbox_shili_list
  local ctls = groupbox:GetChildControlList()
  for _, gbx in ipairs(ctls) do
    local cbtns = gbx:GetChildControlList()
    for _, btn in ipairs(cbtns) do
      if nx_name(btn) == "CheckButton" and not nx_id_equal(btn, self) then
        btn.Checked = false
      end
    end
  end
  form.groupbox_desc.Visible = true
  local mltbox = form.mltbox_desc
  mltbox:Clear()
  local form_logic = nx_value("form_func_guide_logic")
  if nx_is_valid(form_logic) then
    local desc = form_logic:GetSlDataDesc(self.sl_type, self.sl_index)
    mltbox:AddHtmlText(desc, -1)
  end
end
function on_btn_forward_click(self)
  local form = self.ParentForm
  local form_logic = nx_value("form_func_guide_logic")
  if not nx_is_valid(form_logic) then
    return
  end
  local done = form_logic:DecChapter()
  if done then
    set_chapter_title(form)
    update_lc_data()
    update_sl_data()
    form.groupbox_desc.Visible = false
  end
  form.btn_forward.Enabled = form_logic:GetChapter() > MIN_CHAPTER
  form.btn_backward.Enabled = form_logic:GetChapter() < MAX_CHAPTER
end
function on_btn_backward_click(self)
  local form = self.ParentForm
  local form_logic = nx_value("form_func_guide_logic")
  if not nx_is_valid(form_logic) then
    return
  end
  local done = form_logic:IncChapter()
  if done then
    set_chapter_title(form)
    update_lc_data()
    update_sl_data()
    form.groupbox_desc.Visible = false
  end
  form.btn_forward.Enabled = form_logic:GetChapter() > MIN_CHAPTER
  form.btn_backward.Enabled = form_logic:GetChapter() < MAX_CHAPTER
end
function update_lc_data()
  local form_logic = nx_value("form_func_guide_logic")
  if nx_is_valid(form_logic) then
    form_logic:LoadLcData()
    form_logic:UpdateLcData()
  end
end
function update_sl_data()
  local form_logic = nx_value("form_func_guide_logic")
  if nx_is_valid(form_logic) then
    form_logic:LoadSlData()
    form_logic:UpdateSlData()
  end
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function set_chapter_title(form)
  local lbl = form.lbl_chapter
  local form_logic = nx_value("form_func_guide_logic")
  local chapter = form_logic:GetChapter()
  local chapter_table = {
    "@ui_wlzj_jyz_01",
    "@ui_wlzj_jyz_02",
    "@ui_wlzj_jyz_03",
    "@ui_wlzj_jyz_04",
    "@ui_wlzj_jyz_05"
  }
  lbl.Text = nx_widestr(chapter_table[chapter])
end
function on_btn_left_click(self)
  local form = self.ParentForm
  local gbx_btns = form.groupbox_shili_btns
  local gbx_cover = form.groupbox_shili_cover
  local btn_width = gbx_cover.Width / 4
  if gbx_btns.Left < 0 then
    gbx_btns.Left = gbx_btns.Left + btn_width
  end
end
function on_btn_right_click(self)
  local form = self.ParentForm
  local gbx_cover = form.groupbox_shili_cover
  local btn_width = gbx_cover.Width / 4
  local gbx_btns = form.groupbox_shili_btns
  local min_left = gbx_btns.min_left
  if min_left < gbx_btns.Left then
    gbx_btns.Left = gbx_btns.Left - btn_width
  end
end
function reset_scene()
  local form = nx_value("form_stage_main\\form_func_guide")
  if nx_is_valid(form) then
    form:Close()
  end
end
