local edit_table = {
  cbtn_findpath = {
    cbx_scene_id = true,
    ipt_x = true,
    ipt_y = true,
    ipt_z = true,
    ipt_uniqueid = false
  },
  cbtn_findnpc_new = {
    cbx_scene_id = true,
    ipt_x = false,
    ipt_y = false,
    ipt_z = false,
    ipt_uniqueid = true
  },
  cbtn_findnpc = {
    cbx_scene_id = true,
    ipt_x = true,
    ipt_y = true,
    ipt_z = true,
    ipt_uniqueid = false
  }
}
function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  self.cbtn_findnpc.Checked = true
  InitSceneID(self)
  Init(self)
end
function ok_btn_click(self)
  local form = self.Parent
  form:Close()
  nx_gen_event(form, "form_edit_findpath_return", "ok", GetResult(form))
  nx_destroy(form)
  return 1
end
function cancel_btn_click(self)
  local form = self.Parent
  form:Close()
  nx_gen_event(form, "form_edit_findpath_return", "cancel")
  nx_destroy(form)
  return 1
end
function select_cbtn(form, cbtn)
  if form.cbtn_findpath.Name ~= cbtn.Name then
    form.cbtn_findpath.Checked = false
  end
  if form.cbtn_findnpc.Name ~= cbtn.Name then
    form.cbtn_findnpc.Checked = false
  end
  if form.cbtn_findnpc_new.Name ~= cbtn.Name then
    form.cbtn_findnpc_new.Checked = false
  end
end
function set_Edit_Enabled(form, cbtn_table)
  set_control_enabled(form.cbx_scene_id, cbtn_table)
  set_control_enabled(form.ipt_x, cbtn_table)
  set_control_enabled(form.ipt_y, cbtn_table)
  set_control_enabled(form.ipt_z, cbtn_table)
  set_control_enabled(form.ipt_uniqueid, cbtn_table)
end
function set_control_enabled(ctrl, cbtn_table)
  ctrl.Enabled = cbtn_table[ctrl.Name]
  ctrl.Text = nx_widestr("")
  if ctrl.Enabled then
    ctrl.BackColor = "255, 255, 255, 255"
  else
    ctrl.BackColor = "255, 150, 150, 150"
  end
end
function on_cbtn_checked_changed(self)
  if not self.Checked then
    return
  end
  select_cbtn(self.Parent, self)
  local cbtn_table = edit_table[self.Name]
  set_Edit_Enabled(self.Parent, cbtn_table)
end
function Init(form)
  local args = nx_function("ext_split_string", nx_string(form.input_href), ",")
  local count = table.getn(args)
  local cmd = args[1]
  if cmd == "findpath" then
    form.cbtn_findpath.Checked = true
    if count == 4 then
      form.cbx_scene_id.Text = nx_widestr(args[2])
      form.ipt_x.Text = nx_widestr(args[3])
      form.ipt_z.Text = nx_widestr(args[4])
    elseif 4 < count then
      form.cbx_scene_id.Text = nx_widestr(args[2])
      form.ipt_x.Text = nx_widestr(args[3])
      form.ipt_y.Text = nx_widestr(args[4])
      form.ipt_z.Text = nx_widestr(args[5])
    end
  elseif cmd == "findnpc_new" then
    form.cbtn_findnpc_new.Checked = true
    if 3 <= count then
      form.cbx_scene_id.Text = nx_widestr(args[2])
      form.ipt_uniqueid.Text = nx_widestr(args[3])
    end
  elseif cmd == "findnpc" then
    form.cbtn_findnpc.Checked = true
    if count == 4 then
      form.cbx_scene_id.Text = nx_widestr(args[2])
      form.ipt_x.Text = nx_widestr(args[3])
      form.ipt_z.Text = nx_widestr(args[4])
    elseif 4 < count then
      form.cbx_scene_id.Text = nx_widestr(args[2])
      form.ipt_x.Text = nx_widestr(args[3])
      form.ipt_y.Text = nx_widestr(args[4])
      form.ipt_z.Text = nx_widestr(args[5])
    end
  end
end
function InitSceneID(form)
  local filepath = nx_resource_path() .. "ini\\scenes.ini"
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  ini.FileName = filepath
  ini:LoadFromFile()
  local count = ini:GetSectionCount()
  for n = 0, count do
    local scenepath = ini:ReadString(n, "Config", "")
    local tables = nx_function("ext_split_string", scenepath, "\\")
    tables = nx_function("ext_split_string", tables[table.getn(tables)], "_")
    form.cbx_scene_id.DropListBox:AddString(nx_widestr(tables[1]))
  end
  nx_destroy(ini)
end
function GetResult(form)
  local result = ""
  if form.cbtn_findpath.Checked then
    result = "findpath"
    result = result .. "," .. nx_string(form.cbx_scene_id.Text)
    result = result .. "," .. nx_string(form.ipt_x.Text)
    if nx_string(form.ipt_y.Text) ~= "" then
      result = result .. "," .. nx_string(form.ipt_y.Text)
    end
    result = result .. "," .. nx_string(form.ipt_z.Text)
  elseif form.cbtn_findnpc_new.Checked then
    result = "findnpc_new"
    result = result .. "," .. nx_string(form.cbx_scene_id.Text)
    result = result .. "," .. nx_string(form.ipt_uniqueid.Text)
  elseif form.cbtn_findnpc.Checked then
    result = "findnpc"
    result = result .. "," .. nx_string(form.cbx_scene_id.Text)
    result = result .. "," .. nx_string(form.ipt_x.Text)
    if nx_string(form.ipt_y.Text) ~= "" then
      result = result .. "," .. nx_string(form.ipt_y.Text)
    end
    result = result .. "," .. nx_string(form.ipt_z.Text)
  end
  return result
end
