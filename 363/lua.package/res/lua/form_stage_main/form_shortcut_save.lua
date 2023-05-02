require("util_gui")
require("util_functions")
require("define\\sysinfo_define")
require("custom_handler")
local FORM_NAME = "form_stage_main\\form_shortcut_save"
local FORM_SHORTCUT_KEY = "form_stage_main\\form_shortcut_key"
local FORM_SYS_SETTING = "form_stage_main\\form_system\\form_system_interface_setting"
local SHORTCUT_SCHEME_DEFAULT = 0
local SHORTCUT_SCHEME_1 = 1
local SHORTCUT_SCHEME_2 = 2
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local parent_form = nx_value(FORM_SHORTCUT_KEY)
  if not nx_is_valid(parent_form) then
    return
  end
  form.Top = parent_form.Top + 16
  form.Left = parent_form.Left + parent_form.Width - 5
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:Register(300, -1, nx_current(), "check_saved", form, -1, -1)
  end
  check_saved()
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local shortcut_keys = nx_value("ShortcutKey")
  if nx_is_valid(shortcut_keys) and not shortcut_keys:IsEdit() then
    shortcut_keys:BeginEdit()
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "check_saved", form)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute(FORM_SHORTCUT_KEY, "update_window")
  form:Close()
end
function on_btn_apply_click(btn)
  local shortcut_keys = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_keys) then
    return
  end
  local form = btn.ParentForm
  local rbtn_1 = form.rbtn_pro1
  local rbtn_2 = form.rbtn_pro2
  if nil == rbtn_1 or nil == rbtn_2 then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local text = gui.TextManager:GetText("ui_key_save_tips02")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local result = nx_wait_event(100000000, dialog, "confirm_return")
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return
  end
  local form_shortcut_key = nx_value(FORM_SHORTCUT_KEY)
  if not nx_is_valid(form_shortcut_key) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local ShortcutKey1 = client_player:QueryProp("ShortcutKey1")
  local ShortcutKey2 = client_player:QueryProp("ShortcutKey2")
  if result == "ok" then
    local res = false
    if rbtn_1.Checked == true then
      if nx_string("") == nx_string(ShortcutKey1) or nx_string(0) == nx_string(ShortcutKey1) then
        custom_sysinfo(1, 1, 1, 2, "sys_key_save_03")
        return
      end
      local shortcut_keys1_control_mode = game_config_info.shortcut_keys1_control_mode
      if nx_string(shortcut_keys1_control_mode) == nx_string("0") then
        nx_execute(FORM_SYS_SETTING, "switch_mode", 0)
        if nx_find_custom(form_shortcut_key, "subform") and nx_is_valid(form_shortcut_key.subform) then
          nx_execute(nx_string(form_shortcut_key.subform.Name), "on_switchto_3dmode", form_shortcut_key.subform)
        end
        form_shortcut_key.cbtn_tag3D.Checked = true
        form_shortcut_key.cbtn_tag25D.Checked = false
      elseif nx_string(shortcut_keys1_control_mode) == nx_string("1") then
        nx_execute(FORM_SYS_SETTING, "switch_mode", 1)
        if nx_find_custom(form_shortcut_key, "subform") and nx_is_valid(form_shortcut_key.subform) then
          nx_execute(nx_string(form_shortcut_key.subform.Name), "on_switchto_25dmode", form_shortcut_key.subform)
        end
        form_shortcut_key.cbtn_tag3D.Checked = false
        form_shortcut_key.cbtn_tag25D.Checked = true
      end
      res = shortcut_keys:ApplySavedShortcut(SHORTCUT_SCHEME_1)
      game_config_info.apply_shortcut_keys = SHORTCUT_SCHEME_1
    end
    if rbtn_2.Checked == true then
      if nx_string("") == nx_string(ShortcutKey2) or nx_string(0) == nx_string(ShortcutKey2) then
        custom_sysinfo(1, 1, 1, 2, "sys_key_save_03")
        return
      end
      local shortcut_keys2_control_mode = game_config_info.shortcut_keys2_control_mode
      if nx_string(shortcut_keys2_control_mode) == nx_string("0") then
        nx_execute(FORM_SYS_SETTING, "switch_mode", 0)
        if nx_find_custom(form_shortcut_key, "subform") and nx_is_valid(form_shortcut_key.subform) then
          nx_execute(nx_string(form_shortcut_key.subform.Name), "on_switchto_3dmode", form_shortcut_key.subform)
        end
        form_shortcut_key.cbtn_tag3D.Checked = true
        form_shortcut_key.cbtn_tag25D.Checked = false
      elseif nx_string(shortcut_keys2_control_mode) == nx_string("1") then
        nx_execute(FORM_SYS_SETTING, "switch_mode", 1)
        if nx_find_custom(form_shortcut_key, "subform") and nx_is_valid(form_shortcut_key.subform) then
          nx_execute(nx_string(form_shortcut_key.subform.Name), "on_switchto_25dmode", form_shortcut_key.subform)
        end
        form_shortcut_key.cbtn_tag3D.Checked = false
        form_shortcut_key.cbtn_tag25D.Checked = true
      end
      res = shortcut_keys:ApplySavedShortcut(SHORTCUT_SCHEME_2)
      game_config_info.apply_shortcut_keys = SHORTCUT_SCHEME_2
    end
    local info
    if res == true then
      info = "sys_key_save_02"
    else
      info = "sys_key_save_03"
      game_config_info.apply_shortcut_keys = SHORTCUT_SCHEME_DEFAULT
    end
    custom_sysinfo(1, 1, 1, 2, info)
    nx_execute("form_stage_main\\form_main\\form_main_shortcut", "update_shortcut_key")
    nx_execute("form_stage_main\\form_main\\form_main_shortcut_ride", "refresh_shortcut_key")
    nx_execute("form_stage_main\\form_main\\form_main_func_btns", "update_shortcut_key")
    nx_execute("form_stage_main\\form_main\\form_main_shortcut_onestep", "update_shortcut_key")
    nx_execute("form_stage_main\\form_main\\form_main_shortcut_copyskill", "update_shortcut_key")
    nx_execute("game_config", "save_game_config", game_config_info, "systeminfo.ini", "Config")
    local customizing = nx_value("customizing_manager")
    if not nx_is_valid(customizing) then
      return
    end
    customizing:SaveConfigToServer()
  end
  if nx_find_custom(form_shortcut_key, "textgrid_key") and nx_is_valid(form_shortcut_key.textgrid_key) then
    nx_execute(FORM_SHORTCUT_KEY, "update_grid", form_shortcut_key.textgrid_key)
  end
  nx_execute(FORM_SHORTCUT_KEY, "update_window")
end
function on_btn_save_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local rbtn_1 = form.rbtn_pro1
  local rbtn_2 = form.rbtn_pro2
  if nil == rbtn_1 or nil == rbtn_2 then
    return
  end
  local shortcut_keys = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_keys) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local text = gui.TextManager:GetText("ui_key_save_tips01")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return
  end
  local operate_mode = game_config_info.operate_control_mode
  local result = nx_wait_event(100000000, dialog, "confirm_return")
  if result == "ok" then
    local res = false
    if rbtn_1.Checked == true then
      res = shortcut_keys:EndEdit(true, SHORTCUT_SCHEME_1)
      game_config_info.shortcut_keys1_control_mode = nx_int(operate_mode)
      game_config_info.apply_shortcut_keys = SHORTCUT_SCHEME_1
    end
    if rbtn_2.Checked == true then
      res = shortcut_keys:EndEdit(true, SHORTCUT_SCHEME_2)
      game_config_info.shortcut_keys2_control_mode = nx_int(operate_mode)
      game_config_info.apply_shortcut_keys = SHORTCUT_SCHEME_2
    end
    if res == true then
      custom_sysinfo(1, 1, 1, 2, "sys_key_save_01")
    end
    nx_execute("game_config", "save_game_config", game_config_info, "systeminfo.ini", "Config")
    local customizing = nx_value("customizing_manager")
    if not nx_is_valid(customizing) then
      return
    end
    customizing:SaveConfigToServer()
  end
  nx_execute("form_stage_main\\form_main\\form_main_shortcut", "update_shortcut_key")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_ride", "refresh_shortcut_key")
  nx_execute("form_stage_main\\form_main\\form_main_func_btns", "update_shortcut_key")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_onestep", "update_shortcut_key")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_copyskill", "update_shortcut_key")
  form:Close()
end
function check_saved()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return
  end
  local ShortcutKey = client_player:QueryProp("ShortcutKey")
  local ShortcutKey1 = client_player:QueryProp("ShortcutKey1")
  local ShortcutKey2 = client_player:QueryProp("ShortcutKey2")
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local rbtn_1 = form.rbtn_pro1
  local rbtn_2 = form.rbtn_pro2
  if nil == rbtn_1 or nil == rbtn_2 then
    return
  end
  if nx_string("") == nx_string(ShortcutKey1) or nx_string(0) == nx_string(ShortcutKey1) then
    rbtn_1.Text = gui.TextManager:GetFormatText("ui_save_04")
    rbtn_1.ForeColor = "255,255,0,0"
  else
    if nx_string(ShortcutKey) == nx_string(ShortcutKey1) and nx_string(game_config_info.apply_shortcut_keys) == nx_string(1) then
      rbtn_1.Text = gui.TextManager:GetFormatText("ui_save_03")
    else
      rbtn_1.Text = gui.TextManager:GetFormatText("ui_save_06")
    end
    rbtn_1.ForeColor = "255,255,192,25"
  end
  if nx_string("") == nx_string(ShortcutKey2) or nx_string(0) == nx_string(ShortcutKey2) then
    rbtn_2.Text = gui.TextManager:GetFormatText("ui_save_05")
    rbtn_2.ForeColor = "255,255,0,0"
  else
    if nx_string(ShortcutKey) == nx_string(ShortcutKey2) and nx_string(game_config_info.apply_shortcut_keys) == nx_string(2) then
      rbtn_2.Text = gui.TextManager:GetFormatText("ui_save_07")
    else
      rbtn_2.Text = gui.TextManager:GetFormatText("ui_save_08")
    end
    rbtn_2.ForeColor = "255,255,192,25"
  end
end
