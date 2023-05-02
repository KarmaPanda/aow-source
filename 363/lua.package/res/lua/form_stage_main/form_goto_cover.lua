require("util_functions")
require("share\\view_define")
require("util_gui")
DISAPPAER_START_TIME = 3
DISAPPAER_END_TIME = 4
function form_init(self)
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Width = gui.Width
  self.Height = gui.Height
  self.Left = 0
  self.Top = 0
  self.BlendAlpha = 255
  self.BackImage, self.time = get_image_time(self)
  self.load_pbar.Value = 0
  nx_execute("form_stage_main\\form_goto_cover", "disappear_timer", self)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_goto_cover", nx_null())
end
function get_image_time(form)
  local default_image = nx_execute("form_common\\form_loading", "get_image")
  if form.ImageIndex == nil or form.ImageIndex == "" then
    return default_image, DISAPPAER_START_TIME
  end
  local ini = nx_execute("util_functions", "get_ini", "ini\\doornpcloading.ini")
  if not nx_is_valid(ini) then
    return default_image, DISAPPAER_START_TIME
  end
  local sec_index = ini:FindSectionIndex("backimage")
  if sec_index < 0 then
    return default_image, DISAPPAER_START_TIME
  end
  local info = ini:ReadString(sec_index, nx_string(form.ImageIndex), "")
  if "" == info then
    return default_image, DISAPPAER_START_TIME
  end
  local results = util_split_string(info, ",")
  local back_image = results[1]
  local time = DISAPPAER_START_TIME
  if 1 < table.getn(results) then
    time = results[2]
  end
  return nx_string(back_image), nx_int(time)
end
function disappear_timer(form)
  local times = 0
  local value = 0
  local total_time = DISAPPAER_START_TIME
  if nx_find_custom(form, "time") and nx_float(form.time) > nx_float(0) then
    total_time = form.time
  end
  while true do
    local sep = nx_pause(0.1)
    times = times + sep
    if not nx_is_valid(form) then
      return
    end
    value = times * 100 / total_time
    if nx_float(value) >= nx_float(0) and nx_float(value) <= nx_float(100) then
      form.load_pbar.Value = nx_int(value)
    end
    if nx_float(times) > nx_float(total_time) then
      local now_alpha = form.BlendAlpha
      form.BlendAlpha = nx_int(now_alpha - 20)
    end
    if nx_float(times) >= nx_float(total_time + 1) then
      form:Close()
      return
    end
  end
end
