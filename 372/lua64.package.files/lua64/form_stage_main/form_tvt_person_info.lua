require("util_functions")
require("util_gui")
require("define\\object_type_define")
local FORM_MAIN = "form_stage_main\\form_tvt_person_info"
local vt1 = {
  15,
  16,
  67,
  68,
  69,
  70,
  71,
  72,
  93,
  94,
  95,
  96,
  97,
  98,
  103,
  104,
  105,
  106,
  107,
  108,
  109
}
local vt2 = {
  116,
  117,
  118,
  119,
  120,
  121,
  122,
  123
}
function main_form_init(self)
  self.Fixed = false
end
function on_server_msg_manyrevenge(subid, ...)
  local form = nx_value(FORM_MAIN)
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", FORM_MAIN, true, false)
  end
  if 3 == subid then
    local size = table.getn(arg)
    if nx_number(size) ~= 34 then
      return
    end
    local player = get_player()
    if not nx_is_valid(player) then
      return
    end
    local win_num = nx_number(arg[2])
    local lose_num = nx_number(arg[3])
    form.lbl_3.Text = nx_widestr(player:QueryProp("RevengeIntegral"))
    form.lbl_5.Text = nx_widestr(win_num)
    form.lbl_9.Text = nx_widestr(lose_num)
    local grid = form.textgrid_1
    grid:BeginUpdate()
    grid:ClearRow()
    grid:ClearSelect()
    grid.ColCount = 2
    grid.ColWidths = "200, 150"
    for i = 1, 21 do
      local row = grid:InsertRow(-1)
      local value = nx_number(vt1[i])
      local name = "ui_MRBC_" .. value
      grid:SetGridText(row, 0, util_text(name))
      grid:SetGridText(row, 1, nx_widestr(arg[i + 3]))
    end
    grid:EndUpdate()
    local revenge = nx_number(arg[1])
    local win_num_1 = nx_number(arg[25])
    local lose_num_1 = nx_number(arg[26])
    form.lbl_4.Text = nx_widestr(revenge)
    form.lbl_13.Text = nx_widestr(win_num_1)
    form.lbl_14.Text = nx_widestr(lose_num_1)
    local grid_1 = form.textgrid_2
    grid_1:BeginUpdate()
    grid_1:ClearRow()
    grid_1:ClearSelect()
    grid_1.ColCount = 2
    grid_1.ColWidths = "200, 150"
    for j = 27, 34 do
      local row = grid_1:InsertRow(-1)
      local value = nx_number(vt2[j - 26])
      local name = "ui_MRBC_" .. value
      grid_1:SetGridText(row, 0, util_text(name))
      grid_1:SetGridText(row, 1, nx_widestr(arg[j]))
    end
    grid_1:EndUpdate()
  end
  form:Show()
  form.Visible = true
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.rbtn_person.Checked = true
  form.groupbox_1.Visible = true
  form.groupbox_4.Visible = false
  form.groupbox_player.Visible = true
  form.groupbox_multiplayer.Visible = false
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function get_player_tvt_info(name)
  nx_execute("custom_sender", "custom_manyrevenge_match", 3, name)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_rbtn_person_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_1.Visible = true
  form.groupbox_4.Visible = false
  form.groupbox_player.Visible = true
  form.groupbox_multiplayer.Visible = false
end
function on_rbtn_friend_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_1.Visible = false
  form.groupbox_4.Visible = true
  form.groupbox_player.Visible = false
  form.groupbox_multiplayer.Visible = true
end
function get_player()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nil
  end
  local target = nx_value("game_select_obj")
  if not nx_is_valid(target) then
    return nil
  end
  local select_type = target:QueryProp("Type")
  if TYPE_PLAYER ~= nx_number(select_type) then
    return nil
  end
  local visual_player = game_client:GetSceneObj(target.Ident)
  return visual_player
end
