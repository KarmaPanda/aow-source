require("util_gui")
function on_path_finding_stop()
  Clear_Task_FindPath()
end
function on_begin_trace_target_by_id(target_scene, target_x, target_y, target_z, radius, target_id)
  Show_FindPath_Dialog("scene_" .. target_scene, target_id)
end
function Clear_Task_FindPath()
  local dialog = util_get_form("form_stage_main\\form_task_findpath", true, false)
  dialog:Close()
end
function Show_FindPath_Dialog(target_scene, npc_id)
  local dialog = util_get_form("form_stage_main\\form_task_findpath", true, false)
  local gui = nx_value("gui")
  dialog.Top = (gui.Desktop.Height - dialog.Height) / 2 - 180
  if dialog.Top <= 0 then
    dialog.Top = 0
  end
  dialog.Left = (gui.Desktop.Width - dialog.Width) / 2
  dialog:Show()
  nx_set_value("form_stage_main\\form_task_findpath", dialog)
end
function get_autotrace_flag()
  local ini = nx_execute("util_functions", "get_ini", "ini\\autotrace.ini")
  if not nx_is_valid(ini) then
    return 2
  end
  local sect_index = ini:FindSectionIndex("autotrace")
  if sect_index < 0 then
    return 2
  end
  local flag = ini:ReadInteger(sect_index, "model", 2)
  return nx_number(flag)
end
