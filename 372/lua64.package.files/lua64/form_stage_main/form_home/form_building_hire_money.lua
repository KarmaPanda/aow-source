require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
local ARRAY_NAME_BUILDING = "COMMON_ARRAY_HOME_BUILDING_HIRE_MONEY_BUILDING"
local ARRAY_NAME = "COMMON_ARRAY_HOME_BUILDING_HIRE_MONEY_"
local ARRAY_NAME_NPC_DROPLIST = "COMMON_ARRAY_HOME_BUILDING_HIRE_MONEY_DROPLIST"
local FORM_BUILDING_HIRE_MONEY = "form_stage_main\\form_home\\form_building_hire_money"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  close_form()
end
function on_combobox_npc_selected(combo)
  local form = combo.ParentForm
  show_image(form)
  init_combobox_time(combo.ParentForm)
end
function on_combobox_time_selected(combo)
  clac_price(combo.ParentForm)
end
function on_btn_hire_click(btn)
  local form = btn.ParentForm
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local npc_id = common_array:FindChild(ARRAY_NAME_NPC_DROPLIST, nx_string(form.combobox_npc.DropListBox.SelectIndex))
  if npc_id == nil then
    return
  end
  local index = form.combobox_time.DropListBox.SelectIndex
  client_to_server_msg(CLIENT_SUB_BUILDING_HIRE, nx_string(form.building_id), nx_string(npc_id), nx_int(index))
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_BUILDING_HIRE_MONEY, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_form(building_id)
  local form = nx_execute("util_gui", "util_get_form", FORM_BUILDING_HIRE_MONEY, true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  form.building_id = building_id
  load_ini(form)
  init_form(form)
end
function load_ini(form)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Home\\HomeBuilding.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(form.building_id))
  if sec_index < 0 then
    return
  end
  common_array:RemoveArray(ARRAY_NAME_BUILDING)
  common_array:AddArray(ARRAY_NAME_BUILDING, form, 600, true)
  local friend_npc = ini:ReadString(sec_index, "friend_npc", "")
  common_array:AddChild(ARRAY_NAME_BUILDING, "friend_npc", nx_string(friend_npc))
  ini = nx_execute("util_functions", "get_ini", "share\\Home\\HomeBuilding\\Friends.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:GetSectionCount()
  for i = 0, sec_count - 1 do
    local sec = ini:GetSectionByIndex(i)
    local array_name = get_array_name(sec)
    common_array:RemoveArray(array_name)
    common_array:AddArray(array_name, form, 600, true)
    local hire_type = ini:ReadInteger(i, "hire_type", 0)
    local hire_money = ini:ReadInteger(i, "hire_money", 0)
    local hire_money_index = ini:ReadString(i, "hire_money_index", 0)
    local image = ini:ReadString(i, "image", "")
    common_array:AddChild(array_name, "hire_type", nx_int(hire_type))
    common_array:AddChild(array_name, "hire_money", nx_int(hire_money))
    common_array:AddChild(array_name, "hire_money_index", nx_string(hire_money_index))
    common_array:AddChild(array_name, "image", nx_string(image))
  end
end
function init_form(form)
  init_combobox_npc(form)
  init_combobox_time(form)
end
function init_combobox_npc(form)
  form.combobox_npc.DropListBox:ClearString()
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local friend_npc = common_array:FindChild(ARRAY_NAME_BUILDING, "friend_npc")
  local friend_npc_list = util_split_string(friend_npc, ",")
  common_array:RemoveArray(ARRAY_NAME_NPC_DROPLIST)
  common_array:AddArray(ARRAY_NAME_NPC_DROPLIST, form, 600, true)
  local index = 0
  for i = 1, table.getn(friend_npc_list) do
    local hire_type = common_array:FindChild(get_array_name(friend_npc_list[i]), "hire_type")
    if nx_int(hire_type) == nx_int(1) then
      local is_hired = nx_execute("form_stage_main\\form_home\\form_building_hire", "is_be_hired", friend_npc_list[i])
      if not is_hired then
        form.combobox_npc.DropListBox:AddString(nx_widestr(util_text(friend_npc_list[i])))
        common_array:AddChild(ARRAY_NAME_NPC_DROPLIST, nx_string(index), nx_string(friend_npc_list[i]))
        index = index + 1
      end
    end
  end
  form.combobox_npc.DropListBox.SelectIndex = 0
  form.combobox_npc.Text = nx_widestr(form.combobox_npc.DropListBox:GetString(form.combobox_npc.DropListBox.SelectIndex))
  show_image(form)
end
function init_combobox_time(form)
  form.combobox_time.DropListBox:ClearString()
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local npc_id = common_array:FindChild(ARRAY_NAME_NPC_DROPLIST, nx_string(form.combobox_npc.DropListBox.SelectIndex))
  if npc_id ~= nil then
    local time_index = common_array:FindChild(nx_string(get_array_name(npc_id)), "hire_money_index")
    local time_index_list = util_split_string(time_index, ",")
    for i = 1, table.getn(time_index_list) do
      form.combobox_time.DropListBox:AddString(nx_widestr(util_text("ui_time_index_" .. nx_string(i))))
    end
  end
  form.combobox_time.DropListBox.SelectIndex = 0
  form.combobox_time.Text = nx_widestr(form.combobox_time.DropListBox:GetString(form.combobox_time.DropListBox.SelectIndex))
  clac_price(form)
end
function show_image(form)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local npc_id = common_array:FindChild(ARRAY_NAME_NPC_DROPLIST, nx_string(form.combobox_npc.DropListBox.SelectIndex))
  if npc_id == nil then
    return
  end
  local image = common_array:FindChild(get_array_name(npc_id), "image")
  form.lbl_image.BackImage = nx_string(image)
end
function clac_price(form)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local npc_id = common_array:FindChild(ARRAY_NAME_NPC_DROPLIST, nx_string(form.combobox_npc.DropListBox.SelectIndex))
  if npc_id == nil then
    return
  end
  local time_index = common_array:FindChild(get_array_name(npc_id), "hire_money_index")
  local time_index_list = util_split_string(time_index, ",")
  local rate = time_index_list[form.combobox_time.DropListBox.SelectIndex + 1]
  local price_total = common_array:FindChild(get_array_name(npc_id), "hire_money")
  local price = price_total * rate / 100
  local ding1 = math.floor(price / 1000000)
  local liang1 = math.floor(price % 1000000 / 1000)
  local wen1 = math.floor(price % 1000)
  local gui = nx_value("gui")
  local htmlTextYinKa = nx_widestr("")
  if 0 < ding1 then
    local text = gui.TextManager:GetText("ui_ding")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(ding1) .. nx_widestr(htmlText)
  end
  if 0 < liang1 then
    local text = gui.TextManager:GetText("ui_liang")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(" ") .. nx_widestr(liang1) .. nx_widestr(htmlText)
  end
  if 0 < wen1 then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(" ") .. nx_widestr(wen1) .. nx_widestr(htmlText)
  end
  if capital1 == 0 then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinKa = htmlTextYinKa .. nx_widestr("0") .. nx_widestr(htmlText)
  end
  form.mltbox_yinka.HtmlText = util_text("ui_home_hire_money") .. htmlTextYinKa
end
function get_array_name(npc_id)
  return ARRAY_NAME .. nx_string(npc_id)
end
function a(str)
  nx_msgbox(nx_string(str))
end
