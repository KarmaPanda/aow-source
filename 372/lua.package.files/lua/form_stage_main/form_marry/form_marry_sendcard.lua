require("form_stage_main\\form_marry\\form_marry_util")
function main_form_init(form)
  form.Fixed = false
  form.sel_count = 0
  form.player_names = nx_widestr("")
end
function on_main_form_open(form)
  form.edit_selects.Text = nx_widestr("")
  show_friend_list(form, form.grid_friend, TABLE_NAME_FRIEND_REC)
  show_friend_list(form, form.grid_buddy, TABLE_NAME_BUDDY_REC)
  form.rbtn_friend.Checked = true
  form.grid_friend.Visible = true
  form.grid_buddy.Visible = false
  set_form_pos(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_colse_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_btn_ok_click(self)
  local form = self.ParentForm
  local select_names = form.edit_selects.Text
  if select_names == nx_widestr("") then
    return 0
  end
  custom_marry(CLIENT_MSG_SUB_MARRY_SEND_CARD, select_names)
end
function on_btn_cancel_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_cbtn_select_checked_changed(self)
  local form = self.ParentForm
  local count1, names1 = get_select_player(form, form.grid_friend)
  local count2, names2 = get_select_player(form, form.grid_buddy)
  local select_name = names1
  if names2 ~= nx_widestr("") then
    if select_name ~= nx_widestr("") then
      select_name = select_name .. nx_widestr(",")
    end
    select_name = select_name .. names2
  end
  form.edit_selects.Text = select_name
end
function on_rbtn_friend_checked_changed(self)
  local form = self.ParentForm
  form.grid_friend.Visible = self.Checked
  form.grid_buddy.Visible = not self.Checked
end
function on_rbtn_buddy_checked_changed(self)
  local form = self.ParentForm
  form.grid_friend.Visible = not self.Checked
  form.grid_buddy.Visible = self.Checked
end
function get_select_player(form, grid)
  local count = 0
  local names = nx_widestr("")
  for i = 0, grid.RowCount do
    for j = 0, grid.ColCount do
      local gbox = grid:GetGridControl(i, j)
      if nx_is_valid(gbox) and nx_find_custom(gbox, "cbtn") then
        local cbtn = gbox.cbtn
        if nx_is_valid(cbtn) and cbtn.Checked then
          count = count + 1
          if names ~= nx_widestr("") then
            names = names .. nx_widestr(",")
          end
          names = names .. cbtn.player_name
        end
      end
    end
  end
  return count, names
end
function show_friend_list(form, grid, table_name)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindRecord(table_name) then
    return 0
  end
  grid:ClearSelect()
  grid:ClearRow()
  local partner_name = nx_widestr(get_player_prop("PartnerNamePrivate"))
  local count = client_player:GetRecordRows(table_name)
  local col_count = nx_number(grid.ColCount)
  local row = 0
  local index = 0
  for i = 0, count - 1 do
    local player_name = client_player:QueryRecord(table_name, i, FRIEND_REC_NAME)
    if nx_widestr(player_name) ~= partner_name then
      local col = index % col_count
      if col == 0 then
        row = grid:InsertRow(-1)
      end
      local gbox_name = create_ctrl_ex("GroupBox", "gbox_name_" .. nx_string(index), form.gbox_name)
      local cbtn_select = create_ctrl_ex("CheckButton", "cbtn_select_" .. nx_string(index), form.cbtn_select, gbox_name)
      local lbl_name = create_ctrl_ex("Label", "lbl_name_" .. nx_string(index), form.lbl_name, gbox_name)
      if not (nx_is_valid(gbox_name) and nx_is_valid(cbtn_select)) or not nx_is_valid(lbl_name) then
        break
      end
      gbox_name.cbtn = cbtn_select
      lbl_name.Text = nx_widestr(player_name)
      cbtn_select.player_name = nx_widestr(player_name)
      nx_bind_script(cbtn_select, nx_current())
      nx_callback(cbtn_select, "on_checked_changed", "on_cbtn_select_checked_changed")
      grid:SetGridControl(row, col, gbox_name)
      index = index + 1
    end
  end
end
function open_form()
  util_get_form(FORM_MARRY_SENDCARD, true)
  util_show_form(FORM_MARRY_SENDCARD, true)
end
