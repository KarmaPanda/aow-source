require("util_gui")
require("util_functions")
local FORM_PATH = "form_stage_main\\form_task\\form_jianghu_guide_main"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.Left = (gui.Width - self.Width) * 13 / 15
    self.Top = (gui.Height - self.Height) * 4 / 11
  end
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_ok_click(btn)
  btn.ParentForm:Close()
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function on_rbtn_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  local index = get_index(rbtn)
  for i = 1, 20 do
    local group = form:Find("groupbox_" .. nx_string(i))
    if nx_is_valid(group) then
      if nx_int(index) == nx_int(i) then
        group.Visible = true
      else
        group.Visible = false
      end
    end
  end
end
function get_index(rbtn)
  if nx_widestr(rbtn.Name) == nx_widestr("rbtn_1") then
    return 1
  elseif nx_widestr(rbtn.Name) == nx_widestr("rbtn_2") then
    return 2
  elseif nx_widestr(rbtn.Name) == nx_widestr("rbtn_3") then
    return 3
  elseif nx_widestr(rbtn.Name) == nx_widestr("rbtn_4") then
    return 4
  elseif nx_widestr(rbtn.Name) == nx_widestr("rbtn_5") then
    return 5
  elseif nx_widestr(rbtn.Name) == nx_widestr("rbtn_6") then
    return 6
  elseif nx_widestr(rbtn.Name) == nx_widestr("rbtn_7") then
    return 7
  elseif nx_widestr(rbtn.Name) == nx_widestr("rbtn_8") then
    return 8
  elseif nx_widestr(rbtn.Name) == nx_widestr("rbtn_9") then
    return 9
  elseif nx_widestr(rbtn.Name) == nx_widestr("rbtn_10") then
    return 10
  elseif nx_widestr(rbtn.Name) == nx_widestr("rbtn_11") then
    return 11
  elseif nx_widestr(rbtn.Name) == nx_widestr("rbtn_12") then
    return 12
  elseif nx_widestr(rbtn.Name) == nx_widestr("rbtn_13") then
    return 13
  elseif nx_widestr(rbtn.Name) == nx_widestr("rbtn_14") then
    return 14
  elseif nx_widestr(rbtn.Name) == nx_widestr("rbtn_15") then
    return 15
  elseif nx_widestr(rbtn.Name) == nx_widestr("rbtn_16") then
    return 16
  elseif nx_widestr(rbtn.Name) == nx_widestr("rbtn_17") then
    return 17
  elseif nx_widestr(rbtn.Name) == nx_widestr("rbtn_18") then
    return 18
  elseif nx_widestr(rbtn.Name) == nx_widestr("rbtn_19") then
    return 19
  elseif nx_widestr(rbtn.Name) == nx_widestr("rbtn_20") then
    return 20
  end
end
function open_form()
  local form = util_get_form(FORM_PATH, true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  form.rbtn_1.Checked = true
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_PATH, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_form_by_type(type)
  local form = util_get_form(FORM_PATH, true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  local rbtn = form.groupbox_rbtn:Find("rbtn_" .. nx_string(type))
  if not nx_is_valid(rbtn) then
    form.rbtn_1.Checked = true
    return
  end
  rbtn.Checked = true
end
