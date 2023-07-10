function entry_stage_prepare(old_stage)
  local gui = nx_value("gui")
  gui.ScaleEnable = false
  gui.Desktop:Close()
  gui.Desktop.Left = 0
  gui.Desktop.Top = 0
  gui.Desktop.Width = gui.Width
  gui.Desktop.Height = gui.Height
  gui.Desktop.Transparent = false
  gui.Desktop.DrawMode = "FitWindow"
  gui.Desktop.BackImage = "gui\\loading\\login.jpg"
  gui.Desktop:ShowModal()
  return 1
end
function exit_stage_prepare(new_stage)
  local gui = nx_value("gui")
  gui.Desktop.BackImage = ""
  nx_set_value("exit_success", true)
  return 1
end
