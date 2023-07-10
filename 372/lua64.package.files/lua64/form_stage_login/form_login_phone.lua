require("util_gui")
function main_form_init(self)
end
function on_main_form_open(self)
  local form = nx_value("form_stage_login\\form_login_phone")
  if not nx_is_valid(form) then
    return
  end
  form.Default = form.btn_ok
  local phone_number = get_phone()
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("login_errcode_51098")
  gui.TextManager:Format_AddParam(phone_number)
  local text = gui.TextManager:Format_GetText()
  form.mltbox_1:Clear()
  form.mltbox_1:AddHtmlText(text, -1)
end
function on_main_form_close(self)
  nx_destroy(self)
  nx_execute(nx_current(), "deley_clear")
end
function get_phone()
  local path = nx_work_path()
  if string.sub(path, string.len(path)) == "\\" then
    path = string.sub(path, 1, string.len(path) - 1)
  end
  local root_path, s1 = nx_function("ext_split_file_path", path)
  local file_name = root_path .. "updater\\updater_cfg\\url_config.ini"
  local ini = nx_create("IniDocumentUtf8")
  ini.FileName = file_name
  local phone_number = nx_widestr("")
  if ini:LoadFromFile() then
    phone_number = ini:ReadString(nx_widestr("PhoneLockNo"), nx_widestr("phone"), nx_widestr(""))
  end
  nx_destroy(ini)
  return phone_number
end
function deley_clear()
  nx_pause(1)
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) then
    game_config.phone_lock = 0
  end
end
function resize()
  local form = nx_value("form_stage_login\\form_login_phone")
  if nx_is_valid(form) then
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      form.AbsTop = (gui.Desktop.Height - form.Height) / 2
      form.AbsLeft = (gui.Desktop.Width - form.Width) / 2
    end
  end
end
function on_btn_ok_click(self)
  local form = self.ParentForm
  local game_config = nx_value("game_config")
  local game_config_info = nx_value("game_config_info")
  game_config.login_validate = form.validate
  game_config.login_password = form.pswd
  game_config.phone_lock = 1
  if game_config_info.ReconKey == "" then
    return
  end
  local form_login = nx_value("form_stage_login\\form_login")
  if not nx_is_valid(form_login) then
    return
  end
  nx_execute("form_stage_login\\form_login", "try_login_game", form_login)
  form:Close()
end
function on_btn_return_click(self)
  local form = self.ParentForm
  form:Close()
end
