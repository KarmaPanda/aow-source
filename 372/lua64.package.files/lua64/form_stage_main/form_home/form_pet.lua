require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
PARTNER_PET_HOME = ""
BUILDING_ID = ""
local FORM = "form_stage_main\\form_home\\form_pet"
local FORM_PARTNER = "form_stage_main\\form_home\\form_partner_pet"
local PET_RECORD = "sable_rec"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = (gui.Width - form.Width) / 4
  form.AbsTop = (gui.Height - form.Height) / 2
  form.building_id = nil
  form.partner_pet_str = nil
  local pet_str = get_player_pet_list()
  if pet_str == "" or pet_str == nil then
    form.groupscrollbox_1:DeleteAll()
    return
  end
  show_form(pet_str)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_all_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local pet_str = get_player_pet_list()
  if pet_str == "" or pet_str == nil then
    return
  end
  local pet_table = util_split_string(pet_str, ",")
  local num = table.getn(pet_table)
  for i = 1, num do
    local gboxname = "gbox_pet_" .. nx_string(i)
    local cbtnname = "cbtn_pet_" .. nx_string(i)
    local gbox = form.groupscrollbox_1:Find(nx_string(gboxname))
    if nx_is_valid(gbox) then
      local cbtn = gbox:Find(nx_string(cbtnname))
      if nx_is_valid(cbtn) then
        cbtn.Checked = true
      end
    end
  end
  client_to_server_msg(CLIENT_SUB_PET_HOME, nx_int(1), nx_string(form.building_id), nx_string(pet_str))
  btn.Enabled = false
  local btn_sure = form.btn_in
  local btn_out = form.btn_out
  btn_sure.Enabled = false
  btn_out.Enabled = false
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "btn_all_refresh", form)
    timer:Register(5000, 1, nx_current(), "btn_all_refresh", form, -1, -1)
    timer:UnRegister(nx_current(), "btn_in_refresh", form)
    timer:Register(5000, 1, nx_current(), "btn_in_refresh", form, -1, -1)
    timer:UnRegister(nx_current(), "btn_out_refresh", form)
    timer:Register(5000, 1, nx_current(), "btn_out_refresh", form, -1, -1)
  end
end
function on_btn_partner_click(btn)
  local HomeManager = nx_value("HomeManager")
  if nx_is_valid(HomeManager) then
    local partner_name = HomeManager:GetPartnerName()
    if nx_widestr(partner_name) == nx_widestr("") then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("sys_petpen_001"), 2)
        return
      end
    end
  end
  util_auto_show_hide_form(FORM_PARTNER)
end
function on_btn_in_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local pet_info = get_player_selected_pet(form)
  if pet_info == "" or pet_info == nil then
    return
  end
  client_to_server_msg(CLIENT_SUB_PET_HOME, nx_int(1), nx_string(form.building_id), nx_string(pet_info))
  btn.Enabled = false
  local btn_all = form.btn_all
  local btn_out = form.btn_out
  btn_all.Enabled = false
  btn_out.Enabled = false
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "btn_in_refresh", form)
    timer:Register(5000, 1, nx_current(), "btn_in_refresh", form, -1, -1)
    timer:UnRegister(nx_current(), "btn_all_refresh", form)
    timer:Register(5000, 1, nx_current(), "btn_all_refresh", form, -1, -1)
    timer:UnRegister(nx_current(), "btn_out_refresh", form)
    timer:Register(5000, 1, nx_current(), "btn_out_refresh", form, -1, -1)
  end
end
function on_btn_out_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local pet_info = get_player_selected_pet(form)
  if pet_info == "" or pet_info == nil then
    return
  end
  client_to_server_msg(CLIENT_SUB_PET_HOME, nx_int(2), nx_string(form.building_id), nx_string(pet_info))
  btn.Enabled = false
  local btn_all = form.btn_all
  local btn_sure = form.btn_in
  btn_all.Enabled = false
  btn_sure.Enabled = false
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "btn_in_refresh", form)
    timer:Register(5000, 1, nx_current(), "btn_in_refresh", form, -1, -1)
    timer:UnRegister(nx_current(), "btn_all_refresh", form)
    timer:Register(5000, 1, nx_current(), "btn_all_refresh", form, -1, -1)
    timer:UnRegister(nx_current(), "btn_out_refresh", form)
    timer:Register(5000, 1, nx_current(), "btn_out_refresh", form, -1, -1)
  end
end
function on_cbtn_checked_changed(cbtn)
end
function on_imagegrid_get_capture(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local config_id = nx_string(grid.DataSource)
  if config_id ~= "" then
    local x = grid.AbsLeft
    local y = grid.AbsTop
    nx_execute("tips_game", "show_tips_by_config", config_id, x, y, form)
  end
end
function on_imagegrid_lost_capture(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function btn_all_refresh(form)
  if not nx_is_valid(form) then
    return
  end
  form.btn_all.Enabled = true
end
function btn_in_refresh(form)
  if not nx_is_valid(form) then
    return
  end
  form.btn_in.Enabled = true
end
function btn_out_refresh(form)
  if not nx_is_valid(form) then
    return
  end
  form.btn_out.Enabled = true
end
function get_player_selected_pet(form)
  if not nx_is_valid(form) then
    return ""
  end
  local player_selected_pet = ""
  local pet_str = get_player_pet_list()
  if pet_str == "" or pet_str == nil then
    return ""
  end
  local pet_table = util_split_string(pet_str, ",")
  local pet_num = table.getn(pet_table)
  for i = 1, pet_num do
    local gboxname = "gbox_pet_" .. nx_string(i)
    local cbtnname = "cbtn_pet_" .. nx_string(i)
    local gbox = form.groupscrollbox_1:Find(nx_string(gboxname))
    if nx_is_valid(gbox) then
      local cbtn = gbox:Find(nx_string(cbtnname))
      if nx_is_valid(cbtn) and cbtn.Checked then
        local cbtn_data = cbtn.DataSource
        if cbtn_data ~= "" then
          player_selected_pet = player_selected_pet .. cbtn_data .. ","
        end
      end
    end
  end
  local new_player_selected_pet = handel_string(player_selected_pet)
  return new_player_selected_pet
end
function handel_string(str)
  if str == "" then
    return ""
  end
  local new_str = ""
  local str_arr = util_split_string(str, ",")
  local str_count = table.getn(str_arr)
  local str_no_null = 0
  local flag = 0
  for j = 1, str_count do
    if str_arr[j] ~= "" then
      str_no_null = str_no_null + 1
    end
  end
  for i = 1, str_count do
    if str_arr[i] ~= "" then
      flag = flag + 1
      new_str = new_str .. str_arr[i]
      if flag ~= str_no_null then
        new_str = new_str .. ","
      end
    end
  end
  return new_str
end
function get_player()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  return client_player
end
function get_player_pet_list()
  local player = get_player()
  if not nx_is_valid(player) then
    return ""
  end
  if not player:FindRecord(PET_RECORD) then
    return ""
  end
  local row = player:GetRecordRows(PET_RECORD)
  if nx_int(row) <= nx_int(0) then
    return ""
  end
  local pet_list = ""
  for i = 1, row do
    local pet_config = player:QueryRecord(PET_RECORD, i - 1, 3)
    if pet_config ~= "" then
      pet_list = pet_list .. nx_string(pet_config)
      if i ~= row then
        pet_list = pet_list .. ","
      end
    end
  end
  return pet_list
end
function show_form(pet_str)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = util_get_form(FORM, true)
  if not nx_is_valid(form) then
    return
  end
  local groupscrollbox = form.groupscrollbox_1
  if not nx_is_valid(groupscrollbox) then
    return
  end
  groupscrollbox:DeleteAll()
  local pet_list = util_split_string(pet_str, ",")
  local pet_count = table.getn(pet_list)
  if 0 < pet_count then
    for i = 1, pet_count do
      if pet_list[i] ~= nil and pet_list[i] ~= "" then
        local groupbox = create_ctrl("GroupBox", "gbox_pet_" .. nx_string(i), form.groupbox_reference, groupscrollbox)
        local imagegrid = create_ctrl("ImageGrid", "igrid_pet_" .. nx_string(i), form.imagegrid_reference, groupbox)
        local label = create_ctrl("Label", "lab_pet_" .. nx_string(i), form.lbl_reference, groupbox)
        local checkbutton = create_ctrl("CheckButton", "cbtn_pet_" .. nx_string(i), form.cbtn_reference, groupbox)
        checkbutton.DataSource = nx_string(pet_list[i])
        nx_bind_script(checkbutton, nx_current())
        nx_callback(checkbutton, "on_checked_changed", "on_cbtn_checked_changed")
        local item = nx_string(pet_list[i])
        local item_query = nx_value("ItemQuery")
        if not nx_is_valid(item_query) then
          return
        end
        local picture = item_query:GetItemPropByConfigID(item, "Photo")
        imagegrid:AddItem(0, picture, "", 1, -1)
        imagegrid.DataSource = nx_string(pet_list[i])
        nx_bind_script(imagegrid, nx_current())
        nx_callback(imagegrid, "on_get_capture", "on_imagegrid_get_capture")
        nx_callback(imagegrid, "on_lost_capture", "on_imagegrid_lost_capture")
        change_pet_position(groupbox, nx_int(i))
      end
    end
  end
  groupscrollbox.IsEditMode = false
  groupscrollbox:ApplyChildrenCustomYPos()
end
function change_pet_position(gbox, index)
  if not nx_is_valid(gbox) then
    return
  end
  if nx_int(index) <= nx_int(0) then
    return
  end
  local count = nx_number(index - 1)
  local row = math.fmod(count, 3)
  local col = math.floor(count / 3)
  gbox.Left = (gbox.Width + 3) * row
  gbox.Top = (gbox.Height + 3) * col
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  ctrl.Name = name
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  return ctrl
end
function on_server_msg_open_form(...)
  local form = nx_execute("util_gui", "util_get_form", FORM, true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  form.building_id = nx_string(arg[1])
  form.partner_pet_str = nx_string(arg[2])
end
