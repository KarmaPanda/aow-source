require("util_functions")
local help_bz_bIsFirstOpen = true
function form_help_BangZhu_Init(self)
  self.Fixed = true
end
function form_help_BangZhu_Open(self)
  if help_bz_bIsFirstOpen == true then
    local help_bz_Sec = {}
    help_bz_Sec[1] = self.form_help_bz_List1
    help_bz_Sec[2] = self.form_help_bz_List2
    local gui = nx_value("gui")
    local ini = nx_execute("util_functions", "get_ini", "ini\\syshelp\\syshelp.ini")
    if not nx_is_valid(ini) then
      nx_msgbox("ini\\syshelp\\syshelp.ini " .. get_msg_str("msg_120"))
    end
    local sec_count = ini:GetSectionCount()
    for i = 1, sec_count do
      local sec_name = ini:GetSectionByIndex(i - 1)
      nx_execute("form_help", "Insert_Info_From_INI", ini, sec_name, help_bz_Sec[i])
    end
    help_bz_bIsFirstOpen = false
  end
end
function form_help_bz_OnClickItem(self, nItem)
  local item = self:GetString(nItem)
  local html = nx_execute("form_help", "find_HTML_In_INI", item, nx_resource_path() .. "ini\\syshelp\\BangZhu.ini")
  if html ~= "" then
    self.Parent.Parent.Parent.form_help_bz_HTML:Clear()
    self.Parent.Parent.Parent.form_help_bz_HTML:AddHtmlText(html, -1)
  end
end
function form_help_BangZhu_OnClickSection(checkbutton)
  local groupscrollablebox = checkbutton.Parent.Parent
  if checkbutton.Checked then
    checkbutton.Parent.Height = 120
  end
  if not checkbutton.Checked then
    checkbutton.Parent.Height = checkbutton.Height
  end
  groupscrollablebox:ResetChildrenYPos()
end
