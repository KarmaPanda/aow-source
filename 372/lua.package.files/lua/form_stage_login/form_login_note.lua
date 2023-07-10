require("util_gui")
require("util_functions")
function show_login_note_form()
  local ini = get_ini("ini\\res_ver.ini")
  if nx_is_valid(ini) then
    local sect_index = ini:FindSectionIndex("switch")
    if 0 <= sect_index then
      local res_val = ini:ReadString(sect_index, "ShowLoginNote", "1")
      if res_val ~= "1" then
        return
      end
    end
  end
  local form_login_note = util_get_form("form_stage_login\\form_login_note", true)
  if nx_is_valid(form_login_note) then
    local gui = nx_value("gui")
    form_login_note.Top = (gui.Desktop.Height - form_login_note.Height) / 2
    form_login_note.Left = (gui.Desktop.Width - form_login_note.Width) / 2
    form_login_note.cbtn_1.Checked = false
    form_login_note.Visible = true
    form_login_note:ShowModal()
  end
end
function main_form_init(self)
end
function on_main_form_open(self)
end
function on_main_form_close(self)
end
function on_btn_1_click(self)
  local form = self.ParentForm
  form.Visible = false
  form:Close()
  nx_gen_event(nx_null(), "login_note", "close")
end
function on_btn_2_click(self)
  local form = self.ParentForm
  form.Visible = false
  form:Close()
  nx_gen_event(nx_null(), "login_note", "close")
end
function on_cbtn_1_checked_changed(cbtn)
  local file_name = "loginnote.ini"
  local ini = nx_create("IniDocument")
  ini.FileName = file_name
  if not ini:LoadFromFile() then
    ini:SaveToFile()
  end
  ini:WriteInteger("Show", "Checked", cbtn.Checked)
  ini:SaveToFile()
  nx_destroy(ini)
  ini = nx_null()
end
function is_need_login_note()
  local file_name = "loginnote.ini"
  local ini = nx_create("IniDocument")
  ini.FileName = file_name
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    ini = nx_null()
    return true
  end
  local check = ini:ReadString("Show", "Checked", "0")
  nx_destroy(ini)
  ini = nx_null()
  return nx_int(check) == nx_int(0)
end
