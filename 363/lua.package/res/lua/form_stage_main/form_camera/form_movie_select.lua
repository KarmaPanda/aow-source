function main_form_init(form)
  form.Fixed = false
  form.cloneid = nil
  form.unauto_record = nx_call("util_gui", "get_arraylist", "select:unauto_list")
  form.auto_record = nx_call("util_gui", "get_arraylist", "select:auto_list")
end
function on_main_form_open(form)
  load_ini(form)
  init_mltbox_2(form)
end
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    save_ini(form)
    form:Close()
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_default_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    load_ini(form)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_to_right_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    local index = form.mltbox_1:GetSelectItemIndex()
    local count = form.mltbox_1.ItemCount
    if 0 < count and 0 <= index and index < count then
      set_auto_record(form, index)
    end
  end
end
function on_btn_to_left_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    local index = form.mltbox_2:GetSelectItemIndex()
    local count = form.mltbox_2.ItemCount
    if 0 < count and 0 <= index and index < count then
      set_unauto_record(form, index)
    end
  end
end
function init_mltbox_2(form)
  local count = form.mltbox_2.ItemCount
  for i = 1, count do
    set_unauto_record(form, 0)
  end
  save_ini(form)
end
function load_ini(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
  form.unauto_record:ClearChild()
  form.auto_record:ClearChild()
  form.mltbox_1:Clear()
  form.mltbox_2:Clear()
  local ini = nx_create("IniDocument")
  ini.FileName = "story_record.ini"
  if ini:LoadFromFile() then
    local cloneid
    if nx_find_custom(form, "cloneid") then
      cloneid = form.cloneid
    end
    local count = ini:GetSectionCount()
    for i = 1, count do
      if ini:FindSection(nx_string(i)) then
        local state = ini:ReadInteger(nx_string(i), "State", 0)
        local belone = ini:ReadString(nx_string(i), "Belone", "")
        if state <= 0 and (cloneid == nil or nx_string(cloneid) == nx_string(belone)) then
          local unauto = form.unauto_record:CreateChild("")
          unauto.ID = ini:ReadInteger(nx_string(i), "ID", 0)
          unauto.Name = ini:ReadString(nx_string(i), "Name", "")
          unauto.State = state
          unauto.Section = i
          unauto.Modify = 0
          if nx_is_valid(gui) then
            form.mltbox_1:AddHtmlText(gui.TextManager:GetText(unauto.Name), -1)
          end
        elseif 1 <= state and (cloneid == nil or nx_string(cloneid) == nx_string(belone)) then
          local auto = form.auto_record:CreateChild("")
          auto.ID = ini:ReadInteger(nx_string(i), "ID", 0)
          auto.Name = ini:ReadString(nx_string(i), "Name", "")
          auto.State = state
          auto.Section = i
          auto.Modify = 0
          if nx_is_valid(gui) then
            form.mltbox_2:AddHtmlText(gui.TextManager:GetText(auto.Name), -1)
          end
        end
      end
    end
  end
  nx_destroy(ini)
end
function save_ini(form)
  local ini = nx_create("IniDocument")
  ini.FileName = "story_record.ini"
  if ini:LoadFromFile() then
    local count = form.unauto_record:GetChildCount()
    for i = 1, count do
      local section = nx_string(form.unauto_record:GetChildByIndex(i - 1).Section)
      if ini:FindSection(section) then
        local modify = form.unauto_record:GetChildByIndex(i - 1).Modify
        if 1 <= modify then
          ini:WriteInteger(section, "State", 0)
          ini:SaveToFile()
          local list = form.unauto_record:GetChildByIndex(i - 1)
          list.Modify = 0
        end
      end
    end
    count = form.auto_record:GetChildCount()
    for i = 1, count do
      local section = nx_string(form.auto_record:GetChildByIndex(i - 1).Section)
      if ini:FindSection(section) then
        local modify = form.auto_record:GetChildByIndex(i - 1).Modify
        if 1 <= modify then
          ini:WriteInteger(section, "State", 1)
          ini:SaveToFile()
          local list = form.auto_record:GetChildByIndex(i - 1)
          list.Modify = 0
        end
      end
    end
  end
  nx_destroy(ini)
end
function set_auto_record(form, unauto_index)
  local auto = form.auto_record:CreateChild("")
  auto.ID = form.unauto_record:GetChildByIndex(unauto_index).ID
  auto.Name = form.unauto_record:GetChildByIndex(unauto_index).Name
  auto.State = 1
  auto.Section = form.unauto_record:GetChildByIndex(unauto_index).Section
  auto.Modify = 1
  form.unauto_record:RemoveChildByIndex(unauto_index)
  form.mltbox_1:DelHtmlItem(unauto_index)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.mltbox_2:AddHtmlText(gui.TextManager:GetText(auto.Name), -1)
  end
end
function set_unauto_record(form, auto_index)
  local unauto = form.unauto_record:CreateChild("")
  unauto.ID = form.auto_record:GetChildByIndex(auto_index).ID
  unauto.Name = form.auto_record:GetChildByIndex(auto_index).Name
  unauto.State = 0
  unauto.Section = form.auto_record:GetChildByIndex(auto_index).Section
  unauto.Modify = 1
  form.auto_record:RemoveChildByIndex(auto_index)
  form.mltbox_2:DelHtmlItem(auto_index)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.mltbox_1:AddHtmlText(gui.TextManager:GetText(unauto.Name), -1)
  end
end
