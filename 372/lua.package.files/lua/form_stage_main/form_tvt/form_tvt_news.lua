require("util_gui")
require("util_functions")
require("form_stage_main\\switch\\url_define")
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.Left = (gui.Width - self.Width) / 2
    self.Top = (gui.Height - self.Height) / 2
  end
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    local url = switch_manager:GetUrl(URL_TYPE_TVT_NEWS)
    if url ~= "" then
      self.WebView1.Url = nx_widestr(url)
      self.WebView1:Refresh()
      self.WebView1:Enable()
    end
  end
  self.cbtn_1.Checked = load_tvt_news_checkstate()
end
function on_main_form_active(self)
  self.WebView1:Enable()
end
function on_main_form_unactive(self)
  self.WebView1:Disable()
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_1_click(btn)
  btn.ParentForm:Close()
end
function on_cbtn_1_checked_changed(cbtn)
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    nx_destroy(ini)
    return
  end
  ini.FileName = account .. "\\tvt_update.ini"
  ini:LoadFromFile()
  ini:WriteInteger("news", "checked", nx_int(cbtn.Checked))
  ini:SaveToFile()
  nx_destroy(ini)
end
function load_tvt_news_checkstate()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return false
  end
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    nx_destroy(ini)
    return false
  end
  ini.FileName = account .. "\\tvt_update.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local checked = 1 == ini:ReadInteger("news", "checked", 1)
  nx_destroy(ini)
  return checked
end
function is_need_tips()
  if load_tvt_news_checkstate() then
    return false
  end
  return true
end
