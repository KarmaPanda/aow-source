require("util_functions")
require("custom_sender")
require("util_gui")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
local FORM_NAME = "form_stage_main\\form_relation\\form_relation_guild\\form_guild_list"
local ARRAY_NAME = "COMMON_ARRAY_GUILD_LIST"
local SUB_CUSTOMMSG_GUILD_LIST = 115
function main_form_init(self)
  self.Fixed = false
  self.pageno = 1
  self.page_next_ok = 1
end
function on_main_form_open(form)
  form.lbl_2.Text = util_text("ui_guild_key_word")
  form.lbl_10.Text = util_text("ui_guild_cur_guild")
  form.textgrid_1:SetColTitle(0, util_text("ui_guild_list_name"))
  form.textgrid_1:SetColTitle(1, util_text("ui_guild_list_level"))
  form.textgrid_1:SetColTitle(2, util_text("ui_guild_list_member"))
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  custom_guild_list(SUB_CUSTOMMSG_GUILD_LIST)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form.Visible = true
    form:Show()
  end
end
function on_btn_search_click(btn)
  local table_temp = {}
  local form = util_get_form(FORM_NAME, false)
  local text = form.ipt_2.Text
  if not nx_is_valid(form) then
    return
  end
  local form = nx_value(FORM_NAME)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  for i = 1, form.count do
    if nx_function("ext_ws_find", nx_widestr(common_array:FindChild(get_array_name(i), "_name")), nx_widestr(text)) >= 0 then
      local temp_name = nx_widestr(common_array:FindChild(get_array_name(i), "_name"))
      local temp_level = nx_widestr(common_array:FindChild(get_array_name(i), "_level"))
      local temp_member = nx_widestr(common_array:FindChild(get_array_name(i), "_member"))
      table.insert(table_temp, {
        temp_name,
        temp_level,
        temp_member
      })
    end
  end
  form.textgrid_1:ClearRow()
  for i = 1, table.getn(table_temp) do
    local row = form.textgrid_1:InsertRow(-1)
    form.textgrid_1:SetGridText(row, 0, nx_widestr(table_temp[i][1]))
    form.textgrid_1:SetGridText(row, 1, nx_widestr(table_temp[i][2]))
    form.textgrid_1:SetGridText(row, 2, nx_widestr(table_temp[i][3]))
  end
  table_temp = nil
end
function on_btn_close_click(btn)
  util_auto_show_hide_form(FORM_NAME)
end
function on_textgrid_1_select_grid(self, row, col)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  self:SelectRow(row)
  form.ipt_1.Text = nx_widestr(self:GetGridText(row, 0))
end
function on_btn_copy_click(btn)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  nx_function("ext_copy_wstr", nx_widestr(form.ipt_1.Text))
end
function guild_list_show(...)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local table_name = {}
  local table_level = {}
  local table_member = {}
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  local count = table.getn(arg)
  form.textgrid_1:ClearRow()
  local TABLE = {}
  for i = 1, count do
    local guild_list = util_split_wstring(arg[i], ",")
    local guild_name = nx_widestr(guild_list[1])
    local guild_level = nx_widestr(guild_list[2])
    local guild_member = nx_widestr(guild_list[3])
    table.insert(TABLE, {
      guild_name,
      guild_level,
      guild_member
    })
  end
  table.sort(TABLE, function(a, b)
    if nx_number(a[2]) > nx_number(b[2]) then
      return true
    elseif nx_number(a[2]) == nx_number(b[2]) and nx_number(a[3]) < nx_number(b[3]) then
      return true
    end
    return false
  end)
  for i = 1, table.getn(TABLE) do
    local row = form.textgrid_1:InsertRow(-1)
    form.textgrid_1:SetGridText(row, 0, nx_widestr(TABLE[i][1]))
    form.textgrid_1:SetGridText(row, 1, nx_widestr(TABLE[i][2]))
    form.textgrid_1:SetGridText(row, 2, nx_widestr(TABLE[i][3]))
  end
  for i = 1, table.getn(TABLE) do
    local name = nx_widestr(TABLE[i][1])
    local level = nx_widestr(TABLE[i][2])
    local member = nx_widestr(TABLE[i][3])
    table.insert(table_name, name)
    table.insert(table_level, level)
    table.insert(table_member, member)
  end
  for i = 1, table.getn(table_member) do
    local array_name = get_array_name(i)
    common_array:RemoveArray(array_name)
    common_array:AddArray(array_name, form, 600, true)
    local _name = nx_string(table_name[i])
    local _level = nx_int(table_level[i])
    local _member = nx_int(table_member[i])
    common_array:AddChild(array_name, "_name", nx_string(_name))
    common_array:AddChild(array_name, "_level", nx_int(_level))
    common_array:AddChild(array_name, "_member", nx_int(_member))
  end
  form.count = table.getn(table_name)
end
function get_array_name(index)
  return ARRAY_NAME .. nx_string(index)
end
