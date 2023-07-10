require("util_gui")
require("util_functions")
require("game_object")
function on_main_form_init(self)
  self.Fixed = false
  self.max_member = 0
  self.min_member = 0
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.cbtn_1.Checked = true
  self.cbtn_2.Checked = false
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if form.cbtn_1.Checked then
    nx_execute("custom_sender", "custom_rob_prison", 1)
  elseif form.cbtn_2.Checked then
    nx_execute("form_stage_main\\form_rob_prison\\form_rob_prison_select_friend", "show_rob_prison_select_friend", form.max_member, form.min_member)
  end
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_cbtn_1_click(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  cbtn.Checked = true
  form.cbtn_2.Checked = false
end
function on_cbtn_2_click(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  cbtn.Checked = true
  form.cbtn_1.Checked = false
end
function show_rob_prison_apply(...)
  if arg == nil or table.getn(arg) < 3 then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local cost_1 = nx_int(arg[1])
  local cost_2 = nx_int(arg[2])
  local max_member = nx_int(arg[3])
  local min_member = nx_int(arg[4])
  local other_form = util_get_form("form_stage_main\\form_rob_prison\\form_rob_prison_select_friend", false, false)
  if nx_is_valid(other_form) then
    other_form.Visible = false
    other_form:Close()
  end
  local form = util_get_form("form_stage_main\\form_rob_prison\\from_rob_prison_apply", true, false)
  if not nx_is_valid(form) then
    return 0
  end
  local cost_1_L = nx_int(cost_1 / 1000)
  local cost_1_W = cost_1 - cost_1_L * 1000
  local cost_2_L = nx_int(cost_2 / 1000)
  local cost_2_W = cost_2 - cost_2_L * 1000
  form.lbl_cost1.Text = gui.TextManager:GetFormatText("ui_rob_prison_cost_1", nx_widestr(cost_1_L), nx_widestr(cost_1_W))
  form.lbl_cost2.Text = gui.TextManager:GetFormatText("ui_rob_prison_cost_2", nx_widestr(cost_2_L), nx_widestr(cost_2_W))
  form.max_member = max_member
  form.min_member = min_member
  form.Visible = true
  form:Show()
end
