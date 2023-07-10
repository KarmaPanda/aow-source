require("define\\team_rec_define")
local FORM_TEAM_ASSIGN = "form_stage_main\\form_team\\form_team_assign"
local MAX_TEAM_COUNT = 8
PlayList = {}
function main_form_init(form)
  form.Fixed = false
  form.cur_sel_str = ""
  return 1
end
function on_main_form_open(form)
  form.cur_sel_str = ""
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_memeberlist_select_click(list, index)
  local form = list.Parent.Parent
  form.cur_sel_str = list.SelectString
end
function on_team_selected(self)
  self.Text = self.DropListBox.SelectString
  local index = self.DropListBox.SelectIndex
  local form = self.Parent.Parent
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local team_recrows = client_player:GetRecordRows("team_rec")
  if team_recrows < 0 then
    return
  end
  form.memberlist:ClearString()
  for j = 0, team_recrows - 1 do
    local pos = client_player:QueryRecord("team_rec", j, TEAM_REC_COL_TEAMPOSITION)
    if nx_int(pos / 10) == nx_int(index) then
      local teamate_name = client_player:QueryRecord("team_rec", j, TEAM_REC_COL_NAME)
      form.memberlist:AddString(nx_widestr(teamate_name))
    end
  end
end
function on_btn_close_click(btn)
  local form = btn.Parent
  form:Close()
end
function on_ok_click(btn)
  local form = btn.Parent.Parent
  if nx_string(form.cur_sel_str) ~= nx_string("") then
    nx_gen_event(form, "listbox_return", nx_widestr(form.cur_sel_str))
    form:Close()
  end
end
function show_form_assign(form, mode)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local game_role = game_client:GetPlayer()
  local dialog = nx_execute("util_gui", "util_get_form", FORM_TEAM_ASSIGN, true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local team_recrows = game_role:GetRecordRows("team_rec")
  if team_recrows < 0 then
    return
  end
  if nx_int(mode) == nx_int(0) then
    dialog.AbsLeft = form.AbsLeft + form.Width
    dialog.AbsTop = form.AbsTop
  elseif nx_int(mode) == nx_int(1) then
    dialog.AbsLeft = form.icg_items.AbsLeft + form.icg_items.Width
    dialog.AbsTop = form.icg_items.AbsTop
  end
  dialog:ShowModal()
  local team_type = game_role:QueryProp("TeamType")
  if team_type == TYPE_NORAML_TEAM then
    dialog.groupbox_1.Visible = false
    dialog.groupbox_2.Left = 16
    dialog.groupbox_2.Top = 40
    dialog.Height = 254
    for i = 0, team_recrows - 1 do
      local teamate_name = game_role:QueryRecord("team_rec", i, TEAM_REC_COL_NAME)
      if nx_int(dialog.memberlist:FindString(nx_widestr(teamate_name))) == nx_int(-1) then
        dialog.memberlist:AddString(nx_widestr(teamate_name))
      end
    end
  elseif team_type == TYPE_LARGE_TEAM then
    dialog.groupbox_1.Visible = true
    dialog.groupbox_2.Left = 16
    dialog.groupbox_2.Top = 112
    dialog.Height = 318
    for i = 1, MAX_TEAM_COUNT do
      local text = gui.TextManager:GetFormatText("ui_zudui003" .. nx_string(i))
      local index = dialog.teamlist.DropListBox:FindString(text)
      if nx_int(index) == nx_int(-1) then
        dialog.teamlist.DropListBox:AddString(text)
      end
    end
  end
  local gainer_name = nx_wait_event(3000, dialog, "listbox_return")
  if not nx_is_valid(form) then
    return
  end
  local nrealindex = form.nCurrentIndex + (form.nCurrentPage - 1) * form.nItemTypeShowPerPage + 1
  nx_execute("custom_sender", "custom_teamleader_alloc_item", nrealindex, nx_widestr(gainer_name), mode)
end
