require("util_gui")
require("util_functions")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local form_rank = util_get_form("form_stage_main\\form_rank\\form_rank_main", false, false)
  if nx_is_valid(form_rank) then
    form.Left = (form_rank.lbl_grid_bg.Width - form.Width) / 2 + form_rank.lbl_grid_bg.Left + form_rank.Left
    form.Top = (form_rank.lbl_grid_bg.Height - form.Height) / 2 + form_rank.lbl_grid_bg.Top + form_rank.Top
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
