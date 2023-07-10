require("util_gui")
require("util_role_prop")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  change_form_size(form)
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:AddRolePropertyBind("CurJHSceneConfigID", "string", form, nx_current(), "update_newjh_form_main_sweet_employ")
end
function on_main_form_close(form)
  local asynor = nx_value("common_execute")
  if not nx_is_valid(asynor) then
    return
  end
  asynor:RemoveExecute("SweetHP", form)
  nx_destroy(form)
end
function change_form_size(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = (gui.Width - form.Width) / 12 + 100
  form.AbsTop = (gui.Height - form.Height) / 4 - 100
end
function refresh_form_data(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindRecord("rec_pet_show") then
    return
  end
  local photo = client_player:QueryRecord("rec_pet_show", 0, 2)
  form.lbl_photo_1.BackImage = photo
  local name = client_player:QueryRecord("rec_pet_show", 0, 1)
  form.lbl_name_1.Text = nx_widestr(name)
end
function open_form(sweet_id)
  if nx_string(sweet_id) == nx_string("") then
    return
  end
  local form = util_get_form("form_stage_main\\form_main\\form_main_sweet_employ", true, false)
  if not nx_is_valid(form) then
    return
  end
  refresh_form_data(form)
  local asynor = nx_value("common_execute")
  if not nx_is_valid(asynor) then
    return
  end
  asynor:RemoveExecute("SweetHP", form)
  asynor:AddExecute("SweetHP", form, nx_float(0), nx_string(sweet_id))
  form.Visible = true
  form:Show()
end
function dismiss_sweet(sweet_id)
  if nx_string(sweet_id) == nx_string("") then
    return
  end
end
function refresh_form(type, sweet_id)
end
function on_lbl_photo_1_right_click(pic)
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "sweet_employee_menu", "sweet_employee_menu")
  nx_execute("menu_game", "menu_recompose", menu_game)
  local curx, cury = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, curx + 25, cury)
end
function on_btn_fight_click(btn)
  nx_execute("custom_sender", "custom_offline_employ", nx_int(15))
end
function on_btn_follow_click(btn)
  nx_execute("custom_sender", "custom_offline_employ", nx_int(16))
end
function update_newjh_form_main_sweet_employ(form)
  if not nx_is_valid(form) then
    return
  end
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    form.Visible = false
  else
    form.Visible = true
  end
end
