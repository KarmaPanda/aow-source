require("utils")
require("util_gui")
require("util_functions")
require("device_const")
local FORM_VIDEO_SETTING = "form_stage_main\\form_system\\form_system_setting"
local DELAY_UNIT = 10
function game_experience_init()
  local world = nx_value("world")
  nx_bind_script(world, "game_experience")
  nx_callback(world, "on_device_error", "on_device_error")
end
function write_trace_log()
  local fmt = "device error - " .. "TotalVirtualMemory: %s  FreeVirtualMemory: %s  UseVirtualMemory: %s    " .. "TotalVideoMemory: %s  FreeVideoMemory: %s  UsedVideoMemory: %s    " .. "TotalAgpMemory: %s  FreeAgpMemory: %s  UsedAgpMemory: %s"
  local dev_caps = nx_value("device_caps")
  if not nx_is_valid(dev_caps) then
    local value = "unknown"
    nx_log(string.format(fmt, value, value, value, value, value, value))
  end
  local video_table = dev_caps:QueryVideoMemory()
  if video_table == nil or table.getn(video_table) == 0 then
    return
  end
  local total_video_memory = nx_decimals(video_table[1], 2) .. "(M)"
  local free_video_memory = nx_decimals(video_table[2], 2) .. "(M)"
  local used_video_memory = nx_decimals(video_table[1] - video_table[2], 2) .. "(M)"
  local total_agp_memory = nx_decimals(video_table[3], 2) .. "(M)"
  local free_agp_memory = nx_decimals(video_table[4], 2) .. "(M)"
  local used_agp_memory = nx_decimals(video_table[3] - video_table[4], 2) .. "(M)"
  local memory_table = dev_caps:QueryMemory()
  if memory_table == nil or table.getn(memory_table) == 0 then
    return
  end
  local total_virtual_memory = nx_decimals(memory_table[6], 2) .. "(M)"
  local free_virtual_memory = nx_decimals(memory_table[7], 2) .. "(M)"
  local used_virtual_memory = nx_decimals(memory_table[6] - memory_table[7], 2) .. "(M)"
  nx_log(string.format(fmt, total_virtual_memory, free_virtual_memory, used_virtual_memory, total_video_memory, free_video_memory, used_video_memory, total_agp_memory, free_agp_memory, used_agp_memory))
end
function on_device_error()
  local world = nx_value("world")
  if nx_find_custom(world, "deviceerr_noshow") and world.deviceerr_noshow then
    return 1
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    write_trace_log()
    util_confirm("Prompt", "The program crashed! Please restart it.", MB_OK, MB_ICONWARNING)
    world.deviceerr_noshow = true
    delay_execute("on_exit_game", 1000, world)
    return 1
  end
  local game_config = nx_value("game_config")
  local simple_config = nx_value("game_config_simple")
  if not (nx_is_valid(game_config) and nx_is_valid(simple_config)) or game_config.level == "simple" or game_config.level == "supersimple" then
    write_trace_log()
    local desc_title = gui.TextManager:GetText("str_tishi")
    local desc_text = gui.TextManager:GetText("desc_switchconfig_game_crash")
    util_confirm(desc_title, desc_text, MB_OK, MB_ICONWARNING)
    world.deviceerr_noshow = true
    delay_execute("on_exit_game", 1000, world)
    return 1
  end
  local desc_title = gui.TextManager:GetText("str_tishi")
  local desc_text = gui.TextManager:GetText("desc_switchconfig_device_error")
  local result = util_confirm(desc_title, desc_text, MB_OKCANCEL, MB_ICONWARNING)
  world.deviceerr_noshow = true
  if result == IDOK then
    local form_video_setting = nx_value(FORM_VIDEO_SETTING)
    if nx_is_valid(form_video_setting) and form_video_setting.Visible then
      delay_execute("on_switch_to_simple", 1000, world)
    else
      local scene = world.MainScene
      nx_call("game_config", "copy_performance_config", game_config, simple_config)
      nx_call("game_config", "apply_performance_config", scene, game_config)
      game_config.level = "simple"
      util_remove_custom(world, "deviceerr_noshow")
    end
    clear_delay("on_exit_game", world)
  else
    world.deviceerr_noshow = true
    delay_execute("on_exit_game", 1000, world)
  end
  write_trace_log()
  return 1
end
function on_exit_game(world)
  nx_execute("main", "direct_exit_game")
end
function on_reload_scene(world)
  util_remove_custom(world, "deviceerr_noshow")
  reload_current_scene()
  util_remove_custom(world, "reload_flag")
end
function reload_current_scene()
  nx_set_value("stage", "main")
  nx_set_value("entry_scene_success", false)
  nx_execute("stage_main", "on_device_error_reset_all")
  local entry_success = nx_value("entry_scene_success")
  while not entry_success do
    nx_pause(0.1)
    entry_success = nx_value("entry_scene_success")
  end
end
function on_switch_to_simple(world)
  local form_video_setting = nx_value(FORM_VIDEO_SETTING)
  if nx_is_valid(form_video_setting) and form_video_setting.Visible then
    form_video_setting.config_simple_check.Checked = true
  end
  util_remove_custom(world, "deviceerr_noshow")
end
function on_detection_videomemory(videomemory)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_config = nx_value("game_config")
  local simple_config = nx_value("game_config_simple")
  if not (nx_is_valid(game_config) and nx_is_valid(simple_config)) or game_config.level == "simple" or game_config.level == "supersimple" then
    return
  end
  if nx_find_custom(game_config, "detectvm_noshow") and game_config.detectvm_noshow then
    return
  end
  local desc_title = gui.TextManager:GetText("str_tishi")
  local flag = nx_int(videomemory) > nx_int(100) and "desc_switchconfig_device_unstable" or "desc_switchconfig_device_serious"
  local desc_text = gui.TextManager:GetText(flag)
  desc_text = desc_text .. nx_widestr(" (") .. nx_widestr(nx_int(videomemory)) .. nx_widestr(")")
  nx_log(flag .. nx_string(" (") .. nx_string(nx_int(videomemory)) .. nx_string(")"))
  local select_result = true
  local stage = nx_string(nx_value("stage"))
  if stage == "login" then
    return
  end
  if stage == nil or stage == "" or stage == "start" or stage == "prepare" then
    select_result = util_confirm(desc_title, desc_text, MB_OKCANCEL, MB_ICONWARNING) == IDOK
  else
    local form = nx_value("detect_vm" .. "_form_confirm")
    if nx_is_valid(form) and form.Visible then
      if form.Visible then
        return
      end
      form:Close()
    end
    local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "detect_vm")
    if not nx_is_valid(dialog) then
      return
    end
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, desc_text)
    dialog:ShowModal()
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "detect_vm_confirm_return")
    select_result = res == "ok"
  end
  if select_result then
    local form_video_setting = nx_value(FORM_VIDEO_SETTING)
    if nx_is_valid(form_video_setting) and form_video_setting.Visible then
      form_video_setting.config_simple_check.Checked = true
    else
      local world = nx_value("world")
      local scene = world.MainScene
      game_config.level = "simple"
      nx_call("game_config", "copy_performance_config", game_config, simple_config)
      nx_call("game_config", "apply_performance_config", scene, game_config)
    end
    util_remove_custom(game_config, "detectvm_noshow")
    util_remove_custom(game_config, "detectvm_timeout")
    clear_delay("on_reset_detectprompt", game_config)
  else
    if not nx_find_custom(game_config, "detectvm_timeout") then
      game_config.detectvm_timeout = DELAY_UNIT
    else
      game_config.detectvm_timeout = nx_number(game_config.detectvm_timeout) + DELAY_UNIT
    end
    game_config.detectvm_noshow = true
    local delay_time = nx_number(game_config.detectvm_timeout) * 60 * 1000
    delay_execute("on_reset_detectprompt", delay_time, game_config)
  end
end
function on_reset_detectprompt(config)
  config.detectvm_noshow = false
end
function on_detection_memory(memory)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_config = nx_value("game_config")
  local simple_config = nx_value("game_config_simple")
  if not (nx_is_valid(game_config) and nx_is_valid(simple_config)) or game_config.level == "simple" or game_config.level == "supersimple" then
    return
  end
  if nx_find_custom(game_config, "detectmemory_noshow") and game_config.detectmemory_noshow then
    return
  end
  local desc_title = gui.TextManager:GetText("str_tishi")
  local flag = nx_int(memory) > nx_int(50) and "desc_switchconfig_device_unstable_mem" or "desc_switchconfig_device_serious_mem"
  local desc_text = gui.TextManager:GetText(flag)
  desc_text = desc_text .. nx_widestr(" (") .. nx_widestr(nx_int(memory)) .. nx_widestr(")")
  nx_log(flag .. nx_string(" (") .. nx_string(nx_int(memory)) .. nx_string(")"))
  local select_result = true
  local stage = nx_string(nx_value("stage"))
  if stage == "login" then
    return
  end
  if stage == nil or stage == "" or stage == "start" or stage == "prepare" then
    select_result = util_confirm(desc_title, desc_text, MB_OKCANCEL, MB_ICONWARNING) == IDOK
  else
    local form = nx_value("detect_memory" .. "_form_confirm")
    if nx_is_valid(form) and form.Visible then
      if form.Visible then
        return
      end
      form:Close()
    end
    local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "detect_memory")
    if not nx_is_valid(dialog) then
      return
    end
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, desc_text)
    dialog:ShowModal()
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "detect_memory_confirm_return")
    select_result = res == "ok"
  end
  if select_result then
    local form_video_setting = nx_value(FORM_VIDEO_SETTING)
    if nx_is_valid(form_video_setting) and form_video_setting.Visible then
      form_video_setting.config_simple_check.Checked = true
    else
      local world = nx_value("world")
      local scene = world.MainScene
      game_config.level = "simple"
      nx_call("game_config", "copy_performance_config", game_config, simple_config)
      nx_call("game_config", "apply_performance_config", scene, game_config)
    end
    util_remove_custom(game_config, "detectmemory_noshow")
    util_remove_custom(game_config, "detectmemory_timeout")
    clear_delay("on_reset_detectprompt2", game_config)
  else
    if not nx_find_custom(game_config, "detectmemory_timeout") then
      game_config.detectmemory_timeout = DELAY_UNIT
    else
      game_config.detectmemory_timeout = nx_number(game_config.detectmemory_timeout) + DELAY_UNIT
    end
    game_config.detectmemory_noshow = true
    local delay_time = nx_number(game_config.detectmemory_timeout) * 60 * 1000
    delay_execute("on_reset_detectprompt2", delay_time, game_config)
  end
end
function on_reset_detectprompt2(config)
  config.detectmemory_noshow = false
end
function delay_execute(callback, ms, object)
  if not nx_is_valid(object) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), nx_string(callback), object)
    timer:Register(nx_number(ms), 1, nx_current(), nx_string(callback), object, -1, -1)
  end
end
function clear_delay(callback, object)
  if not nx_is_valid(object) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), nx_string(callback), object)
  end
end
