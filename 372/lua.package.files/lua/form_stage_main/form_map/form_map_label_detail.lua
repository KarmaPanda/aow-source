require("util_functions")
require("define\\sysinfo_define")
function main_form_init(self)
  self.Fixed = false
  self.allow_empty = true
  return 1
end
function main_form_open(self)
  self.cbtn_label_1.NpcTypes = "1996"
  self.cbtn_label_2.NpcTypes = "1997"
  self.cbtn_label_3.NpcTypes = "1998"
  self.cbtn_label_4.NpcTypes = "1999"
  self.NpcTypes = ""
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  gui.Focused = self.name_edit
  return 1
end
function on_main_form_close(self)
  nx_destroy(self)
end
function ok_btn_click(self)
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  local form = self.Parent
  local name = nx_string(form.name_edit.Text)
  if name == "" then
    local info = gui.TextManager:GetText("22001")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    return 0
  end
  local check_words = nx_value("CheckWords")
  if nx_is_valid(check_words) and not check_words:CheckBadWords(nx_widestr(name)) then
    local info = gui.TextManager:GetText("22004")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    return 0
  end
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local cbtns = {
    form.cbtn_label_1,
    form.cbtn_label_2,
    form.cbtn_label_3,
    form.cbtn_label_4
  }
  local checked = false
  for _, btn in ipairs(cbtns) do
    if btn.Checked then
      checked = true
      break
    end
  end
  if not checked then
    local info = gui.TextManager:GetText("22003")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    return 0
  end
  nx_gen_event(form, "input_name_return", "ok", name)
  form:Close()
  return 1
end
function cancel_btn_click(self)
  local form = self.Parent
  nx_gen_event(form, "input_name_return", "cancel")
  form:Close()
  return 1
end
function on_cbtn_label_checked_changed(self)
  local form = self.ParentForm
  local cbtns = {
    form.cbtn_label_1,
    form.cbtn_label_2,
    form.cbtn_label_3,
    form.cbtn_label_4
  }
  if self.Checked then
    form.NpcTypes = self.NpcTypes
    for _, btn in ipairs(cbtns) do
      if not nx_id_equal(btn, self) then
        btn.Checked = false
      end
    end
  end
end
function set_npc_type(form, npc_type)
  local cbtns = {
    form.cbtn_label_1,
    form.cbtn_label_2,
    form.cbtn_label_3,
    form.cbtn_label_4
  }
  for _, btn in ipairs(cbtns) do
    btn.Checked = npc_type == btn.NpcTypes
  end
end
function on_label_type_checked_changed(self)
  set_npc_type(self.ParentForm, self.NpcTypes)
end
function modify_map_label(npc_id)
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local ini = form_map.label_ini
  local sect = form_map.current_map
  local value = ini:ReadString(sect, npc_id, "")
  local tuple = util_split_string(value, ",")
  local x = nx_number(tuple[1])
  local y = nx_number(tuple[2])
  local z = nx_number(tuple[3])
  local npc_type = nx_string(tuple[4])
  local gui = nx_value("gui")
  local dialog = nx_call("util_gui", "util_get_form", "form_stage_main\\form_map\\form_map_label_detail", true, false)
  dialog.name_edit.Text = nx_widestr(npc_id)
  dialog.old_npc_id = npc_id
  dialog.old_npc_type = npc_type
  dialog.old_x = x
  dialog.old_y = y
  dialog.old_z = z
  dialog:ShowModal()
  set_npc_type(dialog, npc_type)
  local res = nx_wait_event(100000000, dialog, "input_name_return")
  if res == "cancel" then
    return
  end
  local new_npc_id = nx_string(dialog.name_edit.Text)
  local old_npc_id = dialog.old_npc_id
  local groupmap_objs = form_map.groupmap_objs
  local new_x = dialog.old_x
  local new_y = dialog.old_y
  local new_z = dialog.old_z
  local new_id = new_npc_id
  local new_npc_type
  if dialog.cbtn_label_1.Checked then
    new_npc_type = dialog.cbtn_label_1.NpcTypes
  end
  if dialog.cbtn_label_2.Checked then
    new_npc_type = dialog.cbtn_label_2.NpcTypes
  end
  if dialog.cbtn_label_3.Checked then
    new_npc_type = dialog.cbtn_label_3.NpcTypes
  end
  if dialog.cbtn_label_4.Checked then
    new_npc_type = dialog.cbtn_label_4.NpcTypes
  end
  groupmap_objs:RemoveElement(old_npc_id)
  form_map.label_ini:DeleteItem(form_map.current_map, old_npc_id)
  groupmap_objs:AddLabel(new_npc_type, new_x, new_y, new_z, new_id, nx_widestr(new_id))
  form_map.label_ini:WriteString(form_map.current_map, nx_string(new_id), new_x .. "," .. new_y .. "," .. new_z .. "," .. new_npc_type)
  form_map.label_ini:SaveToFile()
  nx_execute("form_stage_main\\form_map\\form_map_label_list", "modify_map_lable", old_npc_id, new_npc_id, nx_number(new_npc_type))
end
