local MAX_CHECKED_NUM = 2
local FORM_SET
checked_log = {
  true,
  true,
  false,
  false,
  false,
  false
}
function on_main_form_init(self)
  FORM_SET = self
end
function on_main_form_open(self)
  local form_buttons = nx_value("form_clone_damage_statistics_buttons")
  if not nx_is_valid(form_buttons) then
    return
  end
  self.Left = form_buttons.Left + form_buttons.Width
  self.Top = form_buttons.Top + form_buttons.btn_3.Height
  local gui = nx_value("gui")
  if not nx_is_valid then
    return
  end
  update_state(self)
  self.Fixed = false
  self.Visible = true
end
function on_main_form_close(self)
  self.Visible = false
end
function on_cbtn_checked_changed(self)
  update_state(FORM_SET)
end
function update_state(self)
  local checked_num = 0
  for var = 1, 6 do
    local control_name = "cbtn_" .. nx_string(var)
    local check_button = self.groupbox_1:Find(control_name)
    if nx_is_valid(check_button) and check_button.Checked == true then
      checked_num = checked_num + 1
    end
  end
  if checked_num >= MAX_CHECKED_NUM then
    for var = 1, 6 do
      local control_name = "cbtn_" .. nx_string(var)
      local check_button = self.groupbox_1:Find(control_name)
      if nx_is_valid(check_button) and check_button.Checked == false then
        check_button.Enabled = false
      end
    end
  else
    for var = 1, 6 do
      local control_name = "cbtn_" .. nx_string(var)
      local check_button = self.groupbox_1:Find(control_name)
      if nx_is_valid(check_button) then
        check_button.Enabled = true
      end
    end
  end
  local Statistics = nx_value("form_stage_main\\form_clone_damage_statistics")
  if not nx_is_valid(Statistics) then
    nx_msgbox("Statistics UI Not Found")
  end
  nx_execute("form_stage_main\\form_clone_damage_statistics", "update_top_items", self, Statistics)
end
