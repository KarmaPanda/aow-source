require("share\\itemtype_define")
require("util_functions")
require("util_gui")
local form_name = "form_stage_main\\form_wuxue\\form_skillbook_preview"
local file_fuse_skillbook = "share\\Item\\fuse_skillbook.ini"
local file_fuse_skillpage = "share\\Item\\fuse_skillpage.ini"
local max_page_num = 12
function main_form_init(self)
  self.Fixed = false
  self.view_id = 0
  self.view_index = 0
  self.view_item = ""
  nx_execute("util_functions", "get_ini", file_fuse_skillbook)
  nx_execute("util_functions", "get_ini", file_fuse_skillpage)
end
function on_main_form_open(self)
  refresh_form_pos(self)
  init_form(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function open_form(full, view_id, view_index, configid, ...)
  local form = util_get_form(form_name, true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  form.view_id = view_id
  form.view_index = view_index
  local skillbook_ini = nx_execute("util_functions", "get_ini", file_fuse_skillbook)
  local skillpage_ini = nx_execute("util_functions", "get_ini", file_fuse_skillpage)
  if not nx_is_valid(skillbook_ini) or not nx_is_valid(skillpage_ini) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  for i = 1, max_page_num do
    local btn = form.groupbox_fenye:Find("rbtn_" .. nx_string(i))
    if nx_is_valid(btn) then
      btn.Enabled = false
      btn.Visible = false
    end
  end
  if nx_int(full) == nx_int(1) then
    local name_photo = ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string("NamePhoto"))
    form.lbl_book_name.BackImage = nx_string(name_photo)
    form.view_item = nx_string(configid)
    form.btn_study.Enabled = true
    local sec_index = skillbook_ini:FindSectionIndex(nx_string(configid))
    if sec_index < 0 then
      return
    end
    local materials_id = skillbook_ini:ReadString(sec_index, "Materials", "")
    local page_list = util_split_string(materials_id, ",")
    local page_num = table.getn(page_list)
    if page_num <= 0 then
      return
    end
    refresh_page_num(page_num, true)
  else
    form.btn_study.Enabled = false
    local gui = nx_value("gui")
    form.btn_study.HintText = nx_widestr(gui.TextManager:GetText("ui_wuxue_book_tips"))
    local sec_index = skillpage_ini:FindSectionIndex(nx_string(configid))
    if sec_index < 0 then
      return
    end
    local skillbook_id = skillpage_ini:ReadString(sec_index, "FinishBook", "")
    form.view_item = nx_string(skillbook_id)
    local name_photo = ItemQuery:GetItemPropByConfigID(nx_string(skillbook_id), nx_string("NamePhoto"))
    form.lbl_book_name.BackImage = nx_string(name_photo)
    sec_index = skillbook_ini:FindSectionIndex(nx_string(skillbook_id))
    if sec_index < 0 then
      return
    end
    local materials_id = skillbook_ini:ReadString(sec_index, "Materials", "")
    local page_list = util_split_string(materials_id, ",")
    local page_num = table.getn(page_list)
    if page_num <= 0 then
      return
    end
    refresh_page_num(page_num, false)
    for i = 1, table.getn(arg) do
      local btn = form.groupbox_fenye:Find("rbtn_" .. nx_string(i))
      if nx_is_valid(btn) then
        if nx_int(arg[i]) == nx_int(1) then
          btn.Enabled = true
        else
          btn.Enabled = false
        end
      end
    end
  end
end
function refresh_form_pos(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function init_form(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, max_page_num do
    local btn = form.groupbox_fenye:Find("rbtn_" .. nx_string(i))
    if nx_is_valid(btn) then
      btn.Visible = false
      btn.Enabled = false
    end
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_preview_click(btn)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_wuxue\\form_skillbook_view", "show_form", form.view_item, form.view_id, form.view_index, form.btn_study.Enabled)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_study_click(btn)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_use_item", form.view_id, form.view_index)
  if nx_is_valid(form) then
    form:Close()
  end
end
function refresh_page_num(num, enable)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  if num <= 0 or num > max_page_num then
    return
  end
  for i = 1, num do
    local btn = form.groupbox_fenye:Find("rbtn_" .. nx_string(i))
    if nx_is_valid(btn) then
      btn.Enabled = enable
      btn.Visible = true
    end
  end
end
