require("util_functions")
local help_sy_bIsFirstOpen = true
function form_help_ShouYe_Init(self)
  self.Fixed = true
end
function form_help_ShouYe_Open(self)
  if help_sy_bIsFirstOpen == true then
    local help_sy_Sec = {}
    help_sy_Sec[1] = self.form_help_sy_List
    local gui = nx_value("gui")
    local ini = nx_execute("util_functions", "get_ini", "ini\\syshelp\\ShouYe.ini")
    if not nx_is_valid(ini) then
      nx_msgbox("ini\\syshelp\\ShouYe.ini " .. get_msg_str("msg_120"))
    end
    local sec_count = ini:GetSectionCount()
    for i = 1, sec_count do
      local sec_name = ini:GetSectionByIndex(i - 1)
      nx_execute("form_help", "Insert_Info_From_INI", ini, sec_name, help_sy_Sec[i])
    end
    help_sy_bIsFirstOpen = false
  end
end
function form_help_ShouYe_OnClickItem(self, nItem)
  local item = self:GetString(nItem)
  local html = nx_execute("form_help", "find_HTML_In_INI", item, nx_resource_path() .. "ini\\syshelp\\ShouYe.ini")
  if html ~= "" then
    self.Parent.form_help_sy_HTML:Clear()
    self.Parent.form_help_sy_HTML:AddHtmlText(html, -1)
  end
end
