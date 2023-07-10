require("util_functions")
require("util_gui")
require("custom_sender")
require("role_composite")
local FORM_NAME = "form_stage_main\\form_outland\\form_outland_person"
local Value_Ini = "share\\Rule\\outland_value.ini"
local flag_name = {
  "ui_outland_play_desc_1_68",
  "ui_outland_play_desc_1_69",
  "ui_outland_play_desc_1_70"
}
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local sex = get_player_prop("Sex")
  form.player_sex = nx_number(sex)
  show_client_body(form)
  show_person_info(form)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_running(nx_current(), "show_client_body") then
    nx_kill(nx_current(), "show_client_body")
  end
  ui_ClearModel(form.scenebox_1)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function show_person_info(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local value_ini = nx_execute("util_functions", "get_ini", Value_Ini)
  if not nx_is_valid(value_ini) then
    return
  end
  local max_outvalue = value_ini:ReadString("outland_value", "max_outvalue", "")
  local max_invalue = value_ini:ReadString("outland_value", "max_invalue", "")
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local value_zy = player:QueryProp("InlandValue")
  form.lbl_inland.Text = nx_widestr(value_zy .. "/" .. max_invalue)
  local value_wy = player:QueryProp("OutlandValue")
  form.lbl_outland.Text = nx_widestr(value_wy .. "/" .. max_outvalue)
  form.btn_wy.Enabled = false
  form.btn_zy.Enabled = false
  local value_px = 0
  local inland_reward = player:QueryProp("IsGotInlandReward")
  local outland_reward = player:QueryProp("IsGotOutlandReward")
  local value_add = nx_int(value_zy) + nx_int(value_wy)
  if 100 <= value_add then
    if nx_int(value_zy) > nx_int(value_wy) then
      value_px = nx_int(value_zy) - nx_int(value_wy)
      if nx_int(value_px) == nx_int(max_invalue) and inland_reward < 1 then
        form.btn_zy.Enabled = true
      else
        form.btn_zy.Enabled = false
      end
      form.lbl_6.Left = form.lbl_2.Width / 2 - form.lbl_2.Width * (value_px / (max_invalue + max_outvalue)) - form.lbl_6.Width / 2 + form.lbl_2.Left
      form.lbl_main.BackImage = "gui\\special\\outland\\bg_main_1.png"
    elseif nx_int(value_zy) < nx_int(value_wy) then
      value_px = nx_int(value_wy) - nx_int(value_zy)
      if nx_int(value_px) == nx_int(max_outvalue) and outland_reward < 1 then
        form.btn_wy.Enabled = true
      else
        form.btn_wy.Enabled = false
      end
      form.lbl_6.Left = form.lbl_2.Width / 2 + form.lbl_2.Width * (value_px / (max_invalue + max_outvalue)) - form.lbl_6.Width / 2 + form.lbl_2.Left
      form.lbl_main.BackImage = "gui\\special\\outland\\bg_main_2.png"
    else
      form.lbl_main.BackImage = "gui\\special\\outland\\bg_main_0.png"
    end
  else
    if nx_int(value_zy) > nx_int(value_wy) then
      value_px = nx_int(value_zy) - nx_int(value_wy)
      form.lbl_6.Left = form.lbl_2.Width / 2 - form.lbl_2.Width * (value_px / (max_invalue + max_outvalue)) - form.lbl_6.Width / 2 + form.lbl_2.Left
    elseif nx_int(value_zy) < nx_int(value_wy) then
      value_px = nx_int(value_wy) - nx_int(value_zy)
      form.lbl_6.Left = form.lbl_2.Width / 2 + form.lbl_2.Width * (value_px / (max_invalue + max_outvalue)) - form.lbl_6.Width / 2 + form.lbl_2.Left
    else
      form.lbl_6.Left = form.lbl_2.Width / 2 - form.lbl_6.Width / 2 + form.lbl_2.Left
    end
    form.lbl_main.BackImage = "gui\\special\\outland\\bg_main_0.png"
  end
  form.lbl_pianxiang.Text = nx_widestr(value_px)
  local land_flag = player:QueryProp("Landflag")
  if 3 <= land_flag then
    return
  end
  form.lbl_landflag.Text = util_text(flag_name[land_flag + 1])
  form.lbl_6.HintText = gui.TextManager:GetFormatText("ui_outland_play_desc_1_67", util_text(flag_name[land_flag + 1]), nx_widestr(value_px))
end
function on_btn_zy_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.btn_wy.Enabled = false
  form.btn_zy.Enabled = false
  nx_execute("custom_sender", "custom_outland_reward", 0)
end
function on_btn_wy_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.btn_wy.Enabled = false
  form.btn_zy.Enabled = false
  nx_execute("custom_sender", "custom_outland_reward", 1)
end
function get_player()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nx_null()
  end
  return game_client:GetPlayer()
end
function show_client_body(form)
  if not nx_is_valid(form) then
    return
  end
  local scene_box = form.scenebox_1
  if not nx_find_custom(form, "player_sex") then
    return
  end
  ui_ClearModel(scene_box)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local body_manager = nx_value("body_manager")
  if not nx_is_valid(body_manager) then
    return
  end
  util_addscene_to_scenebox(scene_box)
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local actor2
  if body_manager:IsNewBodyType(client_player) then
    local body = 2
    local body_type = body_manager:GetBodyType(client_player)
    if body_type == 3 then
      body = 1
    end
    actor2 = create_role_composite(scene_box.Scene, false, nx_number(form.player_sex), "stand", body)
  else
    actor2 = role_composite:CreateSceneObject(scene_box.Scene, client_player, false, false)
  end
  while not actor2.LoadFinish do
    nx_pause(0.1)
  end
  if not nx_is_valid(actor2) then
    return
  end
  util_add_model_to_scenebox(scene_box, actor2)
  local show_equip_type = 0
  if client_player:FindProp("ShowEquipType") then
    show_equip_type = client_player:QueryProp("ShowEquipType")
  end
  role_composite:RefreshBodyNorEquip(client_player, actor2, show_equip_type)
end
function get_player_prop(prop)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindProp(nx_string(prop)) then
    return
  end
  return client_player:QueryProp(nx_string(prop))
end
function on_lbl_helper_manager_click(lbl)
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
