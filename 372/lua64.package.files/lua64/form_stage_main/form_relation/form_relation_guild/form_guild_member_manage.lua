require("custom_sender")
require("util_gui")
function main_form_init(self)
  self.Fixed = false
  self.checked_no = -1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.combobox_post.Text = nx_widestr(util_text("ui_xuanzezhiwei"))
  return 1
end
function open_member_manage(name, ...)
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_member_manage", true)
  if nx_is_valid(form) then
    form.lbl_name.Text = nx_widestr(name)
    custom_request_guild_pos_list()
  end
end
function on_recv_position_list(...)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_member_manage")
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local num = table.getn(arg)
  form.groupbox_pos:DeleteAll()
  form.combobox_post.DropListBox:ClearString()
  form.checked_no = -1
  for i = 1, num do
    if is_default_name(arg[i]) then
      form.combobox_post.DropListBox:AddString(nx_widestr(util_text(nx_string(arg[i]))))
    else
      form.combobox_post.DropListBox:AddString(nx_widestr(arg[i]))
    end
    local pro_name = "pos_" .. nx_string(i)
    nx_set_custom(form, pro_name, nx_widestr(arg[i]))
  end
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local select_index = form.combobox_post.DropListBox.SelectIndex
  if select_index < 0 then
    return
  end
  local cur_pro_name = "pos_" .. nx_string(select_index + 1)
  if not nx_find_custom(form, cur_pro_name) then
    return
  end
  local pos_name = nx_custom(form, cur_pro_name)
  custom_request_change_position(nx_widestr(form.lbl_name.Text), pos_name)
  form:Close()
end
function is_default_name(pos_name)
  if nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level1_name") then
    return true
  elseif nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level2_name") then
    return true
  elseif nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level3_name") then
    return true
  elseif nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level4_name") then
    return true
  elseif nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level5_name") then
    return true
  elseif nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level6_name") then
    return true
  elseif nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level7_name") then
    return true
  elseif nx_widestr(pos_name) == nx_widestr("ui_guild_pos_level8_name") then
    return true
  end
  return false
end
