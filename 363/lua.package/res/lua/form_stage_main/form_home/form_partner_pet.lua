require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
require("form_stage_main\\form_home\\form_pet")
local FORM_PARTNER_PET = "form_stage_main\\form_home\\form_partner_pet"
local FORM_PET = "form_stage_main\\form_home\\form_pet"
function main_form_init(form)
  form.Fixed = false
  form.partner_pet_str = nil
  form.partner_building_id = nil
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form_pet = nx_execute("util_gui", "util_get_form", FORM_PET, false, false)
  if not nx_is_valid(form_pet) then
    return
  else
    local right_length = gui.Width - form_pet.AbsLeft - form_pet.Width
    if right_length < form.Width then
      if form_pet.AbsLeft >= form.Width then
        form.AbsLeft = form_pet.AbsLeft - form.Width
        form.AbsTop = form_pet.AbsTop
      else
        form.AbsLeft = (gui.Width - form.Width) / 2
        form.AbsTop = (gui.Height - form.Height) / 2
      end
    else
      form.AbsLeft = form_pet.AbsLeft + form_pet.Width
      form.AbsTop = form_pet.AbsTop
    end
  end
  form.partner_building_id = form_pet.building_id
  form.partner_pet_str = form_pet.partner_pet_str
  if form.partner_pet_str == nil then
    form.groupscrollbox_1:DeleteAll()
    return
  end
  show_form(form.partner_pet_str)
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
function on_btn_all_out_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local partner_pet_table = util_split_string(form.partner_pet_str, ",")
  local num = table.getn(partner_pet_table)
  if num <= 0 then
    return
  end
  for i = 1, num do
    local gboxname = "gbox_partner_pet_" .. nx_string(i)
    local cbtnname = "cbtn_partner_pet_" .. nx_string(i)
    local gbox = form.groupscrollbox_1:Find(nx_string(gboxname))
    if nx_is_valid(gbox) then
      local cbtn = gbox:Find(nx_string(cbtnname))
      if nx_is_valid(cbtn) then
        cbtn.Checked = true
      end
    end
  end
  client_to_server_msg(CLIENT_SUB_PET_HOME, nx_int(3), nx_string(form.partner_building_id), nx_string(form.partner_pet_str))
  btn.Enabled = false
  local btn_out_sure = form.btn_out_sure
  btn_out_sure.Enabled = false
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "btn_all_out_refresh", form)
    timer:Register(5000, 1, nx_current(), "btn_all_out_refresh", form, -1, -1)
    timer:UnRegister(nx_current(), "btn_out_sure_refresh", form)
    timer:Register(5000, 1, nx_current(), "btn_out_sure_refresh", form, -1, -1)
  end
end
function on_btn_out_sure_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local partner_pet_info = get_player_selected_partner_pet(form)
  if partner_pet_info == "" or partner_pet_info == nil then
    return
  end
  client_to_server_msg(CLIENT_SUB_PET_HOME, nx_int(3), nx_string(form.partner_building_id), nx_string(partner_pet_info))
  btn.Enabled = false
  local btn_all_out = form.btn_all_out
  btn_all_out.Enabled = false
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "btn_all_out_refresh", form)
    timer:Register(5000, 1, nx_current(), "btn_all_out_refresh", form, -1, -1)
    timer:UnRegister(nx_current(), "btn_out_sure_refresh", form)
    timer:Register(5000, 1, nx_current(), "btn_out_sure_refresh", form, -1, -1)
  end
end
function on_cbtn_partner_checked_changed(cbtn)
end
function on_imagegrid_partner_get_capture(grid, index)
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
function on_imagegrid_partner_lost_capture(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function get_player_selected_partner_pet(form)
  if not nx_is_valid(form) then
    return ""
  end
  local player_selected_partner_pet = ""
  local partner_pet_table = util_split_string(form.partner_pet_str, ",")
  local partner_pet_num = table.getn(partner_pet_table)
  for i = 1, partner_pet_num do
    local gboxname = "gbox_partner_pet_" .. nx_string(i)
    local cbtnname = "cbtn_partner_pet_" .. nx_string(i)
    local gbox = form.groupscrollbox_1:Find(nx_string(gboxname))
    if nx_is_valid(gbox) then
      local cbtn = gbox:Find(nx_string(cbtnname))
      if nx_is_valid(cbtn) and cbtn.Checked then
        local cbtn_data = cbtn.DataSource
        if cbtn_data ~= "" then
          player_selected_partner_pet = player_selected_partner_pet .. cbtn_data .. ","
        end
      end
    end
  end
  return player_selected_partner_pet
end
function show_form(partner_pet_str)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = util_get_form(FORM_PARTNER_PET, true)
  if not nx_is_valid(form) then
    return
  end
  local groupscrollbox = form.groupscrollbox_1
  if not nx_is_valid(groupscrollbox) then
    return
  end
  groupscrollbox:DeleteAll()
  local partner_pet_list = util_split_string(partner_pet_str, ",")
  local partner_pet_count = table.getn(partner_pet_list)
  if 0 < partner_pet_count then
    for i = 1, partner_pet_count do
      if partner_pet_list[i] ~= nil and partner_pet_list[i] ~= "" then
        local groupbox = create_ctrl("GroupBox", "gbox_partner_pet_" .. nx_string(i), form.groupbox_refer, groupscrollbox)
        local imagegrid = create_ctrl("ImageGrid", "igrid_partner_pet_" .. nx_string(i), form.imagegrid_refer, groupbox)
        local label = create_ctrl("Label", "lab_partner_pet_" .. nx_string(i), form.lbl_refer, groupbox)
        local checkbutton = create_ctrl("CheckButton", "cbtn_partner_pet_" .. nx_string(i), form.cbtn_refer, groupbox)
        checkbutton.DataSource = nx_string(partner_pet_list[i])
        nx_bind_script(checkbutton, nx_current())
        nx_callback(checkbutton, "on_checked_changed", "on_cbtn_partner_checked_changed")
        local item = nx_string(partner_pet_list[i])
        local item_query = nx_value("ItemQuery")
        if not nx_is_valid(item_query) then
          return
        end
        local picture = item_query:GetItemPropByConfigID(item, "Photo")
        imagegrid:AddItem(0, picture, "", 1, -1)
        imagegrid.DataSource = nx_string(partner_pet_list[i])
        nx_bind_script(imagegrid, nx_current())
        nx_callback(imagegrid, "on_get_capture", "on_imagegrid_partner_get_capture")
        nx_callback(imagegrid, "on_lost_capture", "on_imagegrid_partner_lost_capture")
        change_pet_position(groupbox, nx_int(i))
      end
    end
  end
  groupscrollbox.IsEditMode = false
  groupscrollbox:ApplyChildrenCustomYPos()
end
function btn_all_out_refresh(form)
  if not nx_is_valid(form) then
    return
  end
  form.btn_all_out.Enabled = true
end
function btn_out_sure_refresh(form)
  if not nx_is_valid(form) then
    return
  end
  form.btn_out_sure.Enabled = true
end
function on_partner_form_update(...)
  local form = nx_execute("util_gui", "util_get_form", FORM_PARTNER_PET, false, false)
  if not nx_is_valid(form) then
    return
  end
  form.partner_pet_str = nx_string(arg[2])
  show_form(form.partner_pet_str)
  local form_pet = nx_execute("util_gui", "util_get_form", FORM_PET, false, false)
  if not nx_is_valid(form_pet) then
    return
  end
  form_pet.building_id = nx_string(arg[1])
  form_pet.partner_pet_str = nx_string(arg[2])
end
