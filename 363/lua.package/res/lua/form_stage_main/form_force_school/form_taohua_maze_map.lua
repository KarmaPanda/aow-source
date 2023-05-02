require("util_gui")
require("util_functions")
local g_tab_color_seq = {
  [1] = "255,255,0,0",
  [2] = "255,255,85,0",
  [3] = "255,241,255,0",
  [4] = "255,45,255,0",
  [5] = "255,0,217,255",
  [6] = "255,0,87,255",
  [7] = "255,156,0,255"
}
function main_form_init(self)
  self.Fixed = false
  self.Visible = true
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 3
  self.type = 0
  self.seq = 0
  return 1
end
function on_main_form_open(self)
end
function refresh_form(bShow, ...)
  form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_force_school\\form_taohua_maze_map", bShow, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  for i = 2, table.getn(arg) do
    local tab_control = {
      form.lbl_1,
      form.lbl_2,
      form.lbl_3,
      form.lbl_4,
      form.lbl_5,
      form.lbl_6,
      form.lbl_7
    }
    local lbl = tab_control[nx_number(i - 1)]
    if lbl ~= nil then
      local backcolor = g_tab_color_seq[nx_number(arg[i])]
      if backcolor == nil then
        return
      end
      lbl.BackColor = backcolor
    end
  end
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
