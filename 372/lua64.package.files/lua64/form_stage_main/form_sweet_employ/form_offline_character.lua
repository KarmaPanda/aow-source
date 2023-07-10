require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_sweet_employ\\form_offline_character"
local SEX_MALE = 0
local SEX_FEMALE = 1
local IMAGE_PATH = "gui\\special\\offline\\accost\\"
local MIN_OFFLINE_CHARACTER = 100
local MAX_OFFLINE_CHARACTER = 104
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  set_form_pos(form)
  set_form_control(form)
  set_default_offline_character(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function set_form_pos(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function get_offline_character(player)
  local character = 0
  if player:FindProp("OfflineCharacter") then
    character = player:QueryProp("OfflineCharacter")
  end
  if nx_int(character) == nx_int(0) then
    character = player:QueryProp("CharacterFlag") + 100
  end
  return character
end
function set_default_offline_character(form)
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local character = get_offline_character(player)
  nx_set_custom(form, "character", nx_int(character))
  set_default_rbtn_check(form, character)
end
function set_default_rbtn_check(form, character)
  if nx_int(character) == nx_int(99) then
    return
  end
  if nx_int(character) < nx_int(MIN_OFFLINE_CHARACTER) or nx_int(character) > nx_int(MAX_OFFLINE_CHARACTER) then
    return
  end
  local id = nx_int(character) - nx_int(100)
  local name = "rbtn_" .. nx_string(id)
  local rbtn = form.gb_char:Find(name)
  if not nx_is_valid(rbtn) then
    return
  end
  rbtn.Checked = true
end
function on_rbtn_char_checked_changed(btn)
  if btn.Checked ~= true then
    return
  end
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local character = btn.DataSource
  nx_set_custom(form, "character", nx_int(character))
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
  nx_execute("custom_sender", "custom_offline_employ", nx_int(10), nx_int(99))
end
function on_btn_confirm_click(btn)
  local form = btn.ParentForm
  local char = 0
  if nx_find_custom(form, "character") then
    character = form.character
  end
  form:Close()
  nx_execute("custom_sender", "custom_offline_employ", nx_int(10), nx_int(character))
end
function get_player_prop(prop)
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return ""
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return ""
  end
  if not player:FindProp(nx_string(prop)) then
    return ""
  end
  return player:QueryProp(nx_string(prop))
end
function is_player_male()
  local sex = get_player_prop("Sex")
  if nx_int(sex) == nx_int(SEX_MALE) then
    return true
  end
  return false
end
function set_form_control(form)
  set_character_image(form)
  set_character_rbtn_text(form)
  set_character_desc_text(form)
end
function set_character_image(form)
  local name_image_pre = "offaccost"
  if is_player_male() then
    name_image_pre = name_image_pre .. nx_string("_b_")
  else
    name_image_pre = name_image_pre .. nx_string("_g_")
  end
  for i = 0, 4 do
    local name_ctrl = "lbl_img_" .. nx_string(i)
    local ctrl = form.gb_char:Find(name_ctrl)
    if not nx_is_valid(ctrl) then
      return
    end
    local name_image = name_image_pre .. nx_string(i) .. nx_string(".png")
    local path_image = IMAGE_PATH .. name_image
    ctrl.BackImage = path_image
  end
end
function set_character_rbtn_text(form)
  local text_id_pre = "ui_off_accost_title"
  if is_player_male() then
    text_id_pre = text_id_pre .. nx_string("_b_")
  else
    text_id_pre = text_id_pre .. nx_string("_g_")
  end
  for i = 0, 4 do
    local name_ctrl = "rbtn_" .. nx_string(i)
    local ctrl = form.gb_char:Find(name_ctrl)
    if not nx_is_valid(ctrl) then
      return
    end
    local text_id = text_id_pre .. nx_string(i)
    ctrl.Text = nx_widestr(util_text(text_id))
  end
end
function set_character_desc_text(form)
  local text_id_pre = "ui_off_accost"
  if is_player_male() then
    text_id_pre = text_id_pre .. nx_string("_b_")
  else
    text_id_pre = text_id_pre .. nx_string("_g_")
  end
  for i = 0, 4 do
    local name_ctrl = "mltbox_txt_" .. nx_string(i)
    local ctrl = form.gb_char:Find(name_ctrl)
    if not nx_is_valid(ctrl) then
      return
    end
    local text_id = text_id_pre .. nx_string(i)
    ctrl.HtmlText = nx_widestr(util_text(text_id))
  end
end
