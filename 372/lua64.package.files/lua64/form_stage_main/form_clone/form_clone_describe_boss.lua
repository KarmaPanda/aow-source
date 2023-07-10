require("custom_sender")
require("util_functions")
require("util_gui")
local FORM_NAME = "form_stage_main\\form_clone\\form_clone_describe_boss"
local scene_file_name = "ini\\ui\\clonescene\\clonescenedesc.ini"
local npc_file_name = "ini\\ui\\clonescene\\clonenpcdesc.ini"
function main_form_init(self)
  self.Fixed = false
  load_clone_scene_data(self)
end
function on_main_form_open(form, ...)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2 - 120
  form.Top = (gui.Height - form.Height) / 2
  form.clone_id = 0
end
function open_form(...)
  local boss_id = nx_string(arg[1])
  local form = util_show_form(nx_string(FORM_NAME), true)
  if not nx_is_valid(form) then
    return
  end
  on_show_describe(form, boss_id)
end
function close_form(...)
  util_show_form(FORM_NAME, false)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_show_describe(form, ...)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local mainform = nx_value("form_stage_main\\form_clone\\form_clone_main")
  if not nx_is_valid(mainform) then
    return
  end
  form.AbsTop = mainform.AbsTop + 7
  form.AbsLeft = mainform.AbsLeft + mainform.Width
  local npc_ini = nx_execute("util_functions", "get_ini", npc_file_name)
  if not nx_is_valid(npc_ini) then
    return 0
  end
  local boss_id = nx_string(arg[1])
  local boss_index = npc_ini:FindSectionIndex(nx_string(boss_id))
  local boss_power = npc_ini:ReadString(boss_index, "Power", "")
  local boss_photo = npc_ini:ReadString(boss_index, "Photo", "")
  form.boss_name.Text = nx_widestr(gui.TextManager:GetText(nx_string(boss_id)))
  form.boss_power.Text = nx_widestr(gui.TextManager:GetText(boss_power))
  form.imagegrid_boss:Clear()
  form.imagegrid_boss:AddItem(0, nx_string(boss_photo), "", 1, -1)
  if boss_index < 0 then
    return
  end
  local story = npc_ini:ReadString(boss_index, "Desc", "")
  form.boss_describe:Clear()
  form.boss_describe:AddHtmlText(gui.TextManager:GetText(story), 1)
end
function load_clone_scene_data(form)
  local IniManager = nx_value("IniManager")
  if not IniManager:IsIniLoadedToManager(scene_file_name) then
    IniManager:LoadIniToManager(scene_file_name)
  end
end
