require("util_gui")
function main_form_init(self)
  self.Fixed = true
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
end
function main_form_close(self)
  nx_destroy(self)
  nx_set_value("form_stage_main\\form_map\\form_map_world", nx_null())
end
function btn_show_region_click(self)
  util_auto_show_hide_form("form_stage_main\\form_map\\form_map_region")
end
function on_form_close(self)
  util_show_form("form_stage_main\\form_map\\form_map_world", false)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
