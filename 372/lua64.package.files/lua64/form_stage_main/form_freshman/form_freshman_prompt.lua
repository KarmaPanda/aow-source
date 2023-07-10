require("util_functions")
require("util_gui")
local file_ini = "ini\\ui\\freshman\\mltbox_info.ini"
local main_form_name = "form_stage_main\\form_freshman\\form_freshman_main"
local child_form_name = "form_stage_main\\form_freshman\\form_freshman_particularize"
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
local get_global_list = function(global_list_name)
  return get_global_arraylist(global_list_name)
end
local function get_new_global_list(global_list_name)
  local global_list = get_global_list(global_list_name)
  global_list:ClearChild()
  return global_list
end
function util_open_freshman_prompt(node_name)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
    if not nx_is_valid(form) then
      return nx_null()
    end
    form.node_name = node_name
    form:ShowModal()
  end
end
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  set_mltbox_info(form)
end
function on_btn_close_click(btn)
  local form = btn.Parent
  form:Close()
end
function on_btn_look_click(btn)
  local form = btn.ParentForm
  nx_execute(child_form_name, "util_open_fresman_info", form.node_name)
  form:Close()
end
function on_main_form_close(form)
  local ini_mgr = nx_value("IniManager")
  if nx_is_valid(ini_mgr) then
    ini_mgr:UnloadIniFromManager(file_ini)
  end
  nx_destroy(form)
end
function set_mltbox_info(form)
  local ini = nx_execute("util_functions", "get_ini", file_ini)
  if not nx_is_valid(ini) then
    return false
  end
  local index = ini:FindSectionIndex(form.node_name)
  if -1 == index then
    return false
  end
  local value = ini:ReadString(index, "desc", "")
  local gui = nx_value("gui")
  local desc = gui.TextManager:GetText(value)
  form.mltbox_info:Clear()
  form.mltbox_info:AddHtmlText(nx_widestr(desc), -1)
  reset_control_pos(form)
  return true
end
function reset_control_pos(form)
  local cur_height = form.mltbox_info:GetContentHeight()
  if cur_height < 80 then
    cur_height = 80
  end
  form.mltbox_info.Height = cur_height + 20
  form.mltbox_info.ViewRect = "4,4,238," .. nx_string(cur_height + 20)
  form.Height = cur_height + 100
end
