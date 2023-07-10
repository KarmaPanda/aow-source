require("form_task\\common")
require("form_task\\public_svn")
function main_form_init(self)
  self.Fixed = false
  self.question_count = 0
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  load_context(self)
  return 1
end
function btn_close_click(self)
  local form = self.Parent
  form:Close()
  nx_destroy(form)
  return 1
end
function load_context(form)
  form.question_count = 0
  form.question_title.DropListBox:ClearString()
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. README_TXT
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    nx_msgbox("\188\211\212\216\206\196\188\254\163\168" .. work_path .. README_TXT .. "\163\169\202\167\176\220")
    return false
  end
  local context = HELP_SECT_NAME
  local item_list = ini:GetItemList(HELP_SECT_NAME)
  for i = 1, table.getn(item_list) do
    context = context .. "<br> <br>" .. item_list[i] .. ini:ReadString(HELP_SECT_NAME, item_list[i], "")
  end
  context = context .. "<br>--------------------------------<br> <br>" .. QUESTION_SECT_NAME .. "<br>"
  local sect_list = ini:GetSectionList()
  local sect_count = table.getn(sect_list)
  for i = 2, sect_count do
    local sect = sect_list[i]
    form.question_title.DropListBox:AddString(nx_widestr(sect))
    context = context .. " <br>" .. sect .. " " .. ini:ReadString(sect, "Q", "") .. "<br>"
    local item_list = ini:GetItemList(sect)
    for j = 2, table.getn(item_list) do
      context = context .. " " .. item_list[j] .. " " .. ini:ReadString(sect, item_list[j], "") .. "<br>"
    end
  end
  form.redit_context.Text = nx_widestr(context)
  nx_destroy(ini)
  return true
end
function btn_ok_click(self)
  local form = self.Parent
  local question = nx_string(form.question_edit.Text)
  local question_title = nx_string(form.question_title.Text)
  local answer = nx_string(form.answer_edit.Text)
  if question ~= "" or question_title ~= "" and answer ~= "" then
    local ini = nx_create("IniDocument")
    ini.FileName = nx_resource_path() .. README_TXT
    if not ini:LoadFromFile() then
      nx_destroy(ini)
      nx_msgbox("\188\211\212\216\206\196\188\254\163\168" .. work_path .. README_TXT .. "\163\169\202\167\176\220")
      return false
    end
    if question ~= "" then
      local sect_list = ini:GetSectionList()
      local sect = sect_list[table.getn(sect_list)]
      local num = nx_number(string.sub(sect, 3, string.len(sect)))
      local new_sect = string.sub(sect, 1, 2) .. nx_string(num + 1)
      ini:WriteString(new_sect, "Q", question)
    end
    if question_title ~= "" and answer ~= "" then
      local item_list = ini:GetItemList(question_title)
      local new_item
      if table.getn(item_list) > 1 then
        local item = item_list[table.getn(item_list)]
        local num = nx_number(string.sub(item, 3, string.len(item)))
        new_item = string.sub(item, 1, 2) .. nx_string(num + 1)
      else
        new_item = "A.1"
      end
      ini:WriteString(question_title, new_item, answer)
    end
    if ini:SaveToFile() then
      load_context(form)
      form.question_edit.Text = nx_widestr("")
      form.question_title.Text = nx_widestr("")
      form.answer_edit.Text = nx_widestr("")
    end
    nx_destroy(ini)
  end
  return true
end
function btn_lock_click(self)
  svn_lock(nx_resource_path() .. README_TXT)
end
function btn_release_click(self)
  svn_unlock(nx_resource_path() .. README_TXT)
end
function btn_submit_click(self)
  svn_commit(nx_resource_path() .. README_TXT)
end
