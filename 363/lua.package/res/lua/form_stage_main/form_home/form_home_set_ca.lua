require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
require("tips_data")
local HOME_FUNC_NPC_TYPE_STAY = 1
local HOME_FUNC_NPC_TYPE_GUARD = 2
local HOME_FUNC_NPC_TYPE_GRIL = 3
function tc(msg, a, b)
  nx_msgbox(nx_string(msg) .. "-" .. nx_string(a) .. "-" .. nx_string(b))
end
function main_form_init(form)
  form.Fixed = false
  form.npc_obj = nil
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form_init(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function open_form(npc_obj)
  if not nx_is_valid(npc_obj) then
    return
  end
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  if not HomeManager:IsMyHome() and not HomeManager:IsPartnerHome() then
    return
  end
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
  end
  form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form.npc_obj = npc_obj
  form.Visible = true
  form:Show()
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  HomeManager:SetHomeNpcChat(form.npc_obj, nx_widestr(form.combobox_chat.Text))
  local index = form.imagegrid_action:GetSelectItemIndex()
  local action = form.imagegrid_action:GetItemName(index)
  HomeManager:SetHomeNpcAction(form.npc_obj, nx_string(action))
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_rbtn_chat_click(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  rbtn.Checked = true
  form.groupbox_chat.Visible = true
  form.groupbox_action.Visible = false
end
function on_rbtn_action_click(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  rbtn.Checked = true
  form.groupbox_chat.Visible = false
  form.groupbox_action.Visible = true
end
function on_imagegrid_action_select_changed(grid, index)
  local action = grid:GetItemName(index)
end
function on_imagegrid_action_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local action = grid:GetItemName(index)
  local tips = "home_npc_" .. nx_string(action)
  local text = util_text(tips)
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 0, grid.ParentForm)
end
function on_imagegrid_action_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function form_init(form)
  local ini = get_ini("ini\\ui\\life\\home_set.ini", true)
  if not nx_is_valid(ini) then
    form:Close()
  end
  local sec_index = ini:FindSectionIndex("chat")
  if sec_index < 0 then
    return
  end
  form.combobox_chat.DropListBox:ClearString()
  local list = ini:GetItemValueList(sec_index, "r")
  for i = 1, table.getn(list) do
    local text = util_text(nx_string(list[i]))
    form.combobox_chat.DropListBox:AddString(text)
  end
  form.combobox_chat.DropListBox.SelectIndex = 0
  form.combobox_chat.Text = nx_widestr(form.combobox_chat.DropListBox:GetString(form.combobox_chat.DropListBox.SelectIndex))
  sec_index = ini:FindSectionIndex("action")
  if sec_index < 0 then
    return
  end
  local index = 0
  list = ini:GetItemValueList(sec_index, "r")
  for i = 1, table.getn(list) do
    local actions = util_split_string(nx_string(list[i]), ",")
    if table.maxn(actions) == 2 then
      local action = actions[1]
      local photo = actions[2]
      form.imagegrid_action:AddItem(index, nx_string(photo), nx_widestr(action), 1, -1)
      index = index + 1
    end
  end
  form.imagegrid_action:SetSelectItemIndex(0)
end
function mouse_right_up(client_obj)
  if not nx_is_valid(client_obj) then
    return
  end
  local home_func_npc_type = client_obj:QueryProp("HomeFuncNpcType")
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "home_employee", "home_employee")
  nx_execute("menu_game", "menu_recompose", menu_game, home_func_npc_type)
  menu_game.target = client_obj
  local curx, cury = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, curx, cury)
end
