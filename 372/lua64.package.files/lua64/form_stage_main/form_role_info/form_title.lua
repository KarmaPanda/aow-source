require("util_gui")
require("custom_sender")
local MAX_TITLE_TYPE = 8
function refresh_form(form)
  if nx_is_valid(form) then
  end
end
function data_bind_prop(self)
  if not nx_is_valid(self) then
    return
  end
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:AddRolePropertyBind("TitleID", "int", self, nx_current(), "update_prop")
  databinder:AddTableBind("title_rec", self, nx_current(), "update_record")
end
function del_data_bind_prop(self)
  if not nx_is_valid(self) then
    return
  end
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:DelTableBind("title_rec", self)
  databinder:DelRolePropertyBind("TitleID", self)
end
function main_form_init(form)
  form.Fixed = true
  form.cur_type = 0
  form.cur_title = 0
  form.cur_titlelist = nx_call("util_gui", "get_arraylist", nx_current() .. "_cur_titlelist")
  form.cur_titlelist:ClearChild()
  return 1
end
function on_main_form_open(form)
  show_type(form)
  form.btn_set_title.Visible = false
  form.btn_cancel_title.Visible = false
  form.lbl_cur_title.Text = ""
  data_bind_prop(form)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  del_data_bind_prop(form)
  nx_destroy(form.cur_titlelist)
  nx_destroy(form)
  nx_set_value("form_title", nx_null())
end
function update_prop(form, PropName, PropType, Value)
  if not nx_is_valid(form) then
    return 1
  end
  if nx_int(Value) == nx_int(0) then
    form.btn_set_title.Visible = false
    form.btn_cancel_title.Visible = false
    form.lbl_cur_title.Text = nx_widestr("@ui_none")
    return
  end
  if nx_int(form.cur_title) == nx_int(Value) or form.lbl_cur_title.Text ~= nx_widestr("@ui_none") then
    form.btn_set_title.Visible = false
    form.btn_cancel_title.Visible = true
  else
    form.btn_set_title.Visible = true
    form.btn_cancel_title.Visible = false
  end
  local gui = nx_value("gui")
  if nx_int(Value) ~= nx_int(0) then
    if nx_int(Value) >= nx_int(9001) and nx_int(Value) <= nx_int(9100) then
      set_sworn_title(form, Value)
    else
      form.lbl_cur_title.Text = gui.TextManager:GetText("role_title_" .. nx_string(Value))
    end
  end
  return 1
end
function update_record(form, record, optype, row, col)
  if not nx_is_valid(form) then
    return
  end
  show_type(form)
end
function find_max_title(list, nType)
  local title_list = {}
  if nx_int(nType) == nx_int(1) then
    local temp_list_1 = {}
    local temp_list_2 = {}
    local temp_list_3 = {}
    for i = 1, table.getn(list) do
      if 1151 <= list[i] and list[i] <= 1199 then
        table.insert(temp_list_1, list[i])
      elseif 9010 < list[i] and list[i] <= 9500 then
        table.insert(temp_list_3, list[i])
      else
        table.insert(temp_list_2, list[i])
      end
    end
    local max_title = -1
    for i = 1, table.getn(temp_list_1) do
      for j = 1, table.getn(temp_list_1) do
        if max_title < temp_list_1[j] then
          max_title = temp_list_1[j]
        end
      end
    end
    if 0 < max_title then
      table.insert(title_list, max_title)
    end
    for i = 1, table.getn(temp_list_2) do
      local HasNext = false
      for j = 1, table.getn(temp_list_2) do
        if temp_list_2[j] == temp_list_2[i] + 1 then
          HasNext = true
          break
        end
      end
      if not HasNext then
        table.insert(title_list, temp_list_2[i])
      end
    end
    for i = 1, table.getn(temp_list_3) do
      table.insert(title_list, temp_list_3[i])
    end
  elseif nx_int(nType) == nx_int(2) then
    if is_check_special_school() then
      local max_level, title_id = 0, 0
      for i = 1, table.getn(list) do
        if nx_number(list[i]) >= 4149 and nx_number(list[i]) <= 4155 or nx_number(list[i]) >= 1466 and nx_number(list[i]) <= 1472 then
          table.insert(title_list, list[i])
        else
          local lvl = check_special_title_show_limit(list[i])
          if max_level < nx_number(lvl) then
            max_level = nx_number(lvl)
            title_id = list[i]
          end
        end
      end
      if 0 < max_level and 0 < title_id then
        table.insert(title_list, title_id)
      end
    else
      local origin_manager = nx_value("OriginManager")
      if not nx_is_valid(origin_manager) then
        return false
      end
      local max_level = -1
      local max_id = -1
      for i = 1, table.getn(list) do
        local IDindex = list[i] % 100
        if 28 < IDindex then
          table.insert(title_list, list[i])
        else
          local level = origin_manager:GetOriginLevel(list[i])
          if max_level < level then
            max_level = level
            max_id = list[i]
          end
        end
      end
      table.insert(title_list, max_id)
    end
  elseif nx_int(nType) == nx_int(3) then
    for i = 1, table.getn(list) do
      if list[i] % 10 == 0 then
        table.insert(title_list, list[i])
      else
        local HasNext = false
        for j = 1, table.getn(list) do
          if list[j] == list[i] + 1 then
            HasNext = true
            break
          end
        end
        if not HasNext then
          table.insert(title_list, list[i])
        end
      end
    end
  elseif nx_int(nType) == nx_int(4) then
    title_list = list
  elseif nx_int(nType) == nx_int(6) then
    title_list = list
  end
  return title_list
end
function check_special_title_show_limit(title_id)
  if nx_number(title_id) < 1451 or nx_number(title_id) > 1472 and nx_number(title_id) < 4139 or nx_number(title_id) > 4155 then
    return 0
  end
  local ini = nx_execute("util_functions", "get_ini", "ini\\title_special_show_limit.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local index = ini:FindSectionIndex("newschool_shenji")
  if 0 <= index then
    return nx_number(ini:ReadInteger(index, nx_string(title_id), 0))
  end
  return 0
end
function is_check_special_school()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local new_school = client_player:QueryProp("NewSchool")
  local school = client_player:QueryProp("School")
  return nx_string(new_school) == nx_string("newschool_shenji") or nx_string(school) == nx_string("school_mingjiao")
end
function on_click_type(self)
  local form = self.ParentForm
  form.mltbox_title:Clear()
  form.cur_titlelist:ClearChild()
  local list_title = {}
  list_title = GetTitles(self.DataSource)
  local gui = nx_value("gui")
  if list_title == nil or table.getn(list_title) <= 0 then
    local text_parp = gui.TextManager:GetText("ui_none")
    form.mltbox_title:AddHtmlText(nx_widestr("<center>") .. nx_widestr(text_parp) .. nx_widestr("</center>"), nx_int(-1))
    return
  end
  local list_max_title = {}
  list_max_title = find_max_title(list_title, nx_int(self.DataSource))
  for i = 1, table.getn(list_max_title) do
    form.cur_titlelist:CreateChild(nx_string(list_max_title[i]))
    if nx_int(list_max_title[i]) >= nx_int(0) then
      if nx_int(list_max_title[i]) >= nx_int(9001) and nx_int(list_max_title[i]) <= nx_int(9100) then
        add_sworn_title_list(form, list_max_title[i])
      else
        local text_parp = gui.TextManager:GetText("role_title_" .. nx_string(list_max_title[i]))
        form.mltbox_title:AddHtmlText(nx_widestr("<center>") .. nx_widestr(text_parp) .. nx_widestr("</center>"), nx_int(-1))
      end
    end
  end
  form.cur_type = nx_int(self.DataSource)
end
function on_select_changed(grid, index)
  local form = grid.ParentForm
  form.cur_title = 0
  local select_title = form.cur_titlelist:GetChildByIndex(nx_int(index))
  if not nx_is_valid(select_title) then
    return
  end
  select_title = nx_int(select_title.Name)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local cur_title = client_player:QueryProp("TitleID")
  if nx_int(cur_title) > nx_int(0) and nx_int(cur_title) == nx_int(select_title) then
    form.btn_set_title.Visible = false
    form.btn_cancel_title.Visible = true
  else
    form.btn_set_title.Visible = true
    form.btn_cancel_title.Visible = false
  end
  form.cur_title = select_title
end
function on_btn_set_title(btn)
  local form = btn.ParentForm
  custom_set_title(nx_int(form.cur_title))
end
function on_btn_cancel_title(btn)
  local form = btn.ParentForm
  form.mltbox_title:SetHtmlItemSelected(form.mltbox_title:GetSelectItemIndex(), false)
  custom_set_title(nx_int(0))
end
function show_type(form)
  local gui = nx_value("gui")
  form.cur_type = 0
  form.mltbox_title:Clear()
  form.cur_titlelist:ClearChild()
  for i = 1, MAX_TITLE_TYPE do
    local rbtn_name = "rbtn_sub_" .. nx_string(i)
    local rbtn = nx_custom(form, rbtn_name)
    rbtn.Visible = false
  end
  local cur_index = 1
  for i = 1, MAX_TITLE_TYPE do
    local rbtn_name = "rbtn_sub_" .. nx_string(cur_index)
    local rbtn = nx_custom(form, rbtn_name)
    rbtn.Text = gui.TextManager:GetText("title_type_" .. nx_string(i))
    rbtn.DataSource = nx_string(i)
    rbtn.Visible = true
    if form.cur_type == 0 then
      form.cur_type = i
    end
    cur_index = cur_index + 1
  end
  if form.cur_type > 0 and form.cur_type <= MAX_TITLE_TYPE then
    local checked_rbtn_name = "rbtn_sub_" .. nx_string(form.cur_type)
    local checked_rbtn = nx_custom(form, checked_rbtn_name)
    checked_rbtn.Checked = true
    on_click_type(checked_rbtn)
  end
end
function HasType(type)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local row = client_player:FindRecordRow("title_rec", 1, nx_int(type))
  if 0 <= row then
    return true
  else
    return false
  end
end
function GetTitles(type)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if client_player:GetRecordRows("title_rec") <= 0 then
    return nil
  end
  local list_titles = {}
  local row_count = client_player:GetRecordRows("title_rec")
  for r = 0, row_count - 1 do
    local rec_type = client_player:QueryRecord("title_rec", r, 1)
    if nx_int(rec_type) == nx_int(type) then
      local rec_title = client_player:QueryRecord("title_rec", r, 0)
      table.insert(list_titles, rec_title)
    end
  end
  return list_titles
end
function on_lbl_cur_title_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  if btn.Text == nx_widestr("@ui_none") then
    return
  else
    form.btn_set_title.Visible = false
    form.btn_cancel_title.Visible = true
  end
end
function set_sworn_title(form, titleID)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  local title_info = player:QueryProp("SwornTitleInfo")
  local list = util_split_wstring(nx_widestr(title_info), nx_widestr(","))
  local counts = table.getn(list)
  if counts < 3 then
    return
  end
  local title_name = nx_widestr(list[1])
  local player_num = nx_int(list[2])
  if nx_int(player_num) >= nx_int(2) and nx_int(player_num) <= nx_int(6) then
    form.lbl_cur_title.Text = gui.TextManager:GetFormatText("role_title_" .. nx_string(player_num) .. "_" .. nx_string(titleID), nx_widestr(title_name))
  end
end
function add_sworn_title_list(form, titleID)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  local title_info = player:QueryProp("SwornTitleInfo")
  local cur_title = player:QueryProp("TitleID")
  local list = util_split_wstring(nx_widestr(title_info), nx_widestr(","))
  local counts = table.getn(list)
  if counts < 3 then
    return
  end
  local title_name = nx_widestr(list[1])
  local player_num = nx_int(list[2])
  if nx_int(player_num) >= nx_int(2) and nx_int(player_num) <= nx_int(6) then
    local text_parp = gui.TextManager:GetFormatText("role_title_" .. nx_string(player_num) .. "_" .. nx_string(titleID), nx_widestr(title_name))
    form.mltbox_title:AddHtmlText(nx_widestr("<center>") .. nx_widestr(text_parp) .. nx_widestr("</center>"), nx_int(-1))
    if nx_int(cur_title) == nx_int(titleID) then
      form.lbl_cur_title.Text = gui.TextManager:GetFormatText("role_title_" .. nx_string(player_num) .. "_" .. nx_string(titleID), nx_widestr(title_name))
    end
  end
end
