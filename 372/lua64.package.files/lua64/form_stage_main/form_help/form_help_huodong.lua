require("util_functions")
local help_hd_bIsFirstOpen = true
function form_help_HuoDong_Init(self)
  self.Fixed = true
end
function form_help_HuoDong_Open(self)
  if help_hd_bIsFirstOpen == true then
    local help_hd_Sec = {}
    help_hd_Sec[1] = self.form_help_hd_LIST1
    help_hd_Sec[2] = self.form_help_hd_LIST2
    local gui = nx_value("gui")
    local IniManager = nx_value("IniManager")
    local ini = IniManager:GetIniDocument("ini\\syshelp\\HuoDong.ini")
    local ini = nx_execute("util_functions", "get_ini", "ini\\syshelp\\HuoDong.ini")
    if not nx_is_valid(ini) then
      nx_msgbox("ini\\syshelp\\HuoDong.ini " .. get_msg_str("msg_120"))
    end
    local item_count = ini:GetSectionItemCount()
    for i = 1, item_count do
      local sec_name = ini:GetSectionByIndex(i - 1)
      nx_execute("form_help", "Insert_Info_From_INI", ini, sec_name, help_hd_Sec[i])
    end
    help_hd_bIsFirstOpen = false
  end
end
function form_help_hd_OnClickItem(self, nItem)
  local item = self:GetString(nItem)
  local html = nx_execute("form_help", "find_HTML_In_INI", item, nx_resource_path() .. "ini\\syshelp\\HuoDong.ini")
  if html ~= "" then
    self.Parent.Parent.Parent.form_help_hd_HTML:Clear()
    self.Parent.Parent.Parent.form_help_hd_HTML:AddHtmlText(html, -1)
  end
end
