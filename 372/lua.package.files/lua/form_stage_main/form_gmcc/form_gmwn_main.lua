require("util_gui")
require("util_functions")
require("tips_data")
local FORM_GMWN_NAME = "form_stage_main\\form_gmcc\\form_gmwn_main"
local GM_CONFIG_PATH = "ini\\gmconfig.ini"
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function on_main_form_init(form)
  form.Fixed = true
  form.url = ""
end
function on_main_form_open(form)
  change_form_size()
  form.web_help.Url = nx_widestr(form.url)
  form.web_help:Refresh()
  form.web_help:Enable()
end
function on_main_form_close(form)
  local IniManager = nx_value("IniManager")
  if nx_is_valid(IniManager) then
    IniManager:UnloadIniFromManager(GM_CONFIG_PATH)
  end
  nx_destroy(form)
end
function change_form_size(form)
  local form = util_get_form(FORM_GMWN_NAME, false)
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  form.AbsLeft = gui.Desktop.Width - form.Width - 20
  form.AbsTop = 180
end
function web_close_form()
  local form = util_get_form(FORM_GMWN_NAME, false)
  if nx_is_valid(form) and form.Visible then
    form.web_help:Disable()
    form:Close()
  end
end
function show_gmsd_form(url)
  local form = util_get_form(FORM_GMWN_NAME, false)
  if nx_is_valid(form) then
    if form.Visible then
      form.web_help:Disable()
    else
      form.web_help:Enable()
      form.web_help:Navigate()
    end
    form.Visible = not form.Visible
    return 0
  end
  local form = util_get_form(FORM_GMWN_NAME, true, false)
  if nx_is_valid(form) then
    form.url = url
    util_show_form(FORM_GMWN_NAME, true)
  end
end
function open_gm_form()
  local is_chatting = nx_call("form_stage_main\\form_gmcc\\form_gmcc_msg_call", "check_is_chatting")
  if is_chatting then
    nx_execute("form_stage_main\\form_gmcc\\form_gmcc_msg_call", "to_ask_gmcc")
    return 0
  end
  local url = get_ini_prop(GM_CONFIG_PATH, "config", "WNBZHelpUrl", "")
  if url ~= "" then
    nx_execute(FORM_GMWN_NAME, "show_gmsd_form", url)
  end
end
function on_btn_help_click(btn)
  local url = get_ini_prop(GM_CONFIG_PATH, "config", "WNTJWTHelpUrl", "")
  if url ~= "" then
    nx_function("ext_open_url", url)
  end
end
function on_btn_close_click(btn)
  web_close_form()
end
