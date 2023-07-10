require("util_functions")
require("role_composite")
require("util_gui")
require("scene")
require("scenario_npc_manager")
require("tips_data")
local ENTER_LOAD_NEW_INI = "ini\\form\\enter_load.ini"
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
local get_global_list = function(global_list_name)
  return get_global_arraylist(global_list_name)
end
local function get_new_global_list(global_list_name)
  local global_list = get_global_list(global_list_name)
  global_list:ClearChild()
  return global_list
end
local control_list = {
  "scenebox_grass",
  "scenebox_1"
}
function main_form_init(form)
  form.role_actor2 = nx_null()
  form.b_show_alpha_lbl = false
  form.init = false
  return 1
end
function init_form_ratio(form)
  local main_w = 1600
  local main_h = 900
  if true == form.init then
    return
  end
  for i, control_name in ipairs(control_list) do
    local control = nx_custom(form, control_name)
    if nx_is_valid(control) then
      local w_r = control.Width / main_w
      local h_r = control.Height / main_h
      local x_r = control.Left / main_w
      local y_r = control.Top / main_h
      control.w_r = w_r
      control.h_r = h_r
      control.x_r = x_r
      control.y_r = y_r
    end
  end
  form.init = true
end
function refresh_control_pos_size(form)
  local main_w = form.Width
  local main_h = form.Height
  for i, control_name in ipairs(control_list) do
    local control = nx_custom(form, control_name)
    if nx_is_valid(control) then
      local width = control.w_r * main_w
      local height = control.h_r * main_h
      local left = control.x_r * main_w
      local top = control.y_r * main_h
      control.Width = width
      control.Height = height
      control.Left = left
      control.Top = top
    end
  end
end
function main_form_open(form)
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) then
    game_config.show_activity = true
  end
  local AOWSteamClient = nx_value("AOWSteamClient")
  if nx_is_valid(AOWSteamClient) then
    form.back_btn.Enabled = false
  end
  local funcbtns = nx_value("form_main_func_btns")
  if nx_is_valid(funcbtns) then
    funcbtns:ResetLoadAddbtn()
  end
  local LogicVmChecker = nx_value("LogicVmChecker")
  if nx_is_valid(LogicVmChecker) then
    LogicVmChecker:UnRegisterUpLoad()
  end
  init_form_ratio(form)
  form.lbl_screen_hide.Visible = false
  form.Default = form.enter_btn
  local gui = nx_value("gui")
  on_info_size_change(form)
  form.enter_btn.Enabled = false
  form.vip_btn.Enabled = false
  local sock = nx_value("game_sock")
  local receiver = sock.Receiver
  form.role_name = receiver:GetRoleName(0)
  local role_info = nx_string(receiver:GetRolePara(0))
  local role_info_table = nx_function("ext_split_string", role_info, ",")
  form.sex = nx_number(role_info_table[1])
  form.school = role_info_table[2]
  form.stand = nx_number(role_info_table[3])
  form.character = nx_number(role_info_table[4])
  form.favorite = nx_number(role_info_table[5])
  local offset = 0
  form.face, offset = get_face(role_info_table)
  form.show_equip_type = role_info_table[7 + offset]
  form.hat = role_info_table[8 + offset]
  form.mask = role_info_table[9 + offset]
  form.cloth = role_info_table[10 + offset]
  form.pants = role_info_table[11 + offset]
  form.shoes = role_info_table[12 + offset]
  form.weapon = role_info_table[13 + offset]
  form.mantle = role_info_table[14 + offset]
  form.hateffect = role_info_table[15 + offset]
  form.maskeffect = role_info_table[16 + offset]
  form.clotheffect = role_info_table[17 + offset]
  form.pantseffect = role_info_table[18 + offset]
  form.shoeseffect = role_info_table[19 + offset]
  form.weaponeffect = role_info_table[20 + offset]
  form.mantleeffect = role_info_table[21 + offset]
  form.action_set = role_info_table[22 + offset]
  form.last_ip = role_info_table[23 + offset]
  local level_title = role_info_table[24 + offset]
  form.scene_nameid = role_info_table[25 + offset]
  form.scenario = role_info_table[26 + offset]
  if table.getn(role_info_table) > 31 + offset then
    form.origin_1 = role_info_table[27 + offset]
    form.origin_2 = role_info_table[28 + offset]
    form.origin_3 = role_info_table[29 + offset]
    form.origin_4 = role_info_table[30 + offset]
    form.origin_5 = role_info_table[31 + offset]
  else
    form.origin_1 = "empty"
    form.origin_2 = "empty"
    form.origin_3 = "empty"
    form.origin_4 = "empty"
    form.origin_5 = "empty"
  end
  local vip = role_info_table[32 + offset]
  form.vip_info = "ui_notvip"
  local bookid = role_info_table[33 + offset]
  form.hair = role_info_table[34 + offset]
  if table.getn(role_info_table) > 35 + offset then
    form.guildtitle = role_info_table[35 + offset]
  else
    form.guildtitle = ""
  end
  if table.getn(role_info_table) >= 36 + offset then
    form.modify_face = role_info_table[36 + offset]
  else
    form.modify_face = ""
  end
  if table.getn(role_info_table) >= 37 + offset then
    form.body_type = nx_int(role_info_table[37 + offset])
  else
    form.body_type = nx_int(0)
  end
  if table.getn(role_info_table) >= 38 + offset then
    form.face_type = nx_int(role_info_table[38 + offset])
  else
    form.face_type = nx_int(0)
  end
  if vip ~= nil then
    local vipInfos = nx_function("ext_split_string", vip, "_")
    local valid_time = vipInfos[2]
    if valid_time ~= nil and 1 < string.len(valid_time) then
      form.vip_info = nx_widestr(util_format_string("ui_vip_time", valid_time))
    end
  end
  local gui = nx_value("gui")
  if 0 < nx_ws_length(form.role_name) then
    form.name_label.Text = form.role_name
    form.menpai_label.Text = get_school_name(form.school)
    local title = gui.TextManager:GetText("desc_" .. nx_string(level_title))
    form.zhuangtai_label.Text = nx_widestr(title)
    if form.scenario ~= nil then
      if form.scenario == "empty" then
        form.chushen_label.Text = nx_widestr("@ui_weijinru")
      else
        form.chushen_label.Text = gui.TextManager:GetText(form.scenario)
      end
      if form.scenario == "" then
        form.chushen_label.Text = nx_widestr("@ui_weijinru")
      end
    end
    local name = bookid
    if nil ~= name then
      local image = "gui\\create\\" .. name .. ".png"
      form.lbl_bg.BackImage = image
    end
    if form.scene_nameid ~= nil then
      if form.scene_nameid == "empty" then
        form.place_label.Text = nx_widestr("@ui_none")
      else
        form.place_label.Text = gui.TextManager:GetText(form.scene_nameid)
      end
    end
    form.address_label.Text = nx_widestr(form.last_ip)
    if nx_string(form.vip_info) == "ui_notvip" then
      form.lbl_vip.Text = gui.TextManager:GetText("@ui_notvip")
    elseif gui.TextManager:IsIDName(nx_string(form.vip_info)) then
      form.lbl_vip.Text = gui.TextManager:GetText(form.vip_info)
    else
      form.lbl_vip.Text = nx_widestr(form.vip_info)
    end
    if not nx_is_valid(form.scenebox_1.Scene) then
      util_addscene_to_scenebox(form.scenebox_1)
      local game_visual = nx_value("game_visual")
      if nx_is_valid(game_visual) and game_visual.GameTest then
        nx_set_value("debug_scene_box_light", form.scenebox_1.Scene)
      end
    end
    show_role_model(form)
  end
  if not (nx_is_valid(form) and nx_find_custom(form, "enter_btn")) or not nx_is_valid(form.enter_btn) then
    return
  end
  form:ToFront(form.enter_btn)
  form:ToFront(form.vip_btn)
  form:ToFront(form.lbl_endtime)
  local asynor = nx_value("common_execute")
  asynor:AddExecute("blend_color", form.lbl_animations1, nx_float(0), nx_float(100), form.lbl_animations2)
  if not nx_is_valid(form.scenebox_grass.Scene) then
    util_addscene_to_scenebox(form.scenebox_grass)
  end
  local file_path = nx_resource_path() .. "ini\\create\\ter\\"
  local scene = form.scenebox_1.Scene
  init_scene(scene)
  scene.ppglow_uiparam = nx_null()
  scene.ppglow = nx_null()
  scene.terrain = nx_null()
  nx_call("terrain\\weather", "create_weather", scene)
  nx_call("terrain\\terrain", "create_screen", scene)
  nx_execute("terrain\\role_param", "load_role_ini", scene, nx_resource_path() .. "ini\\create\\ter\\role.ini")
  if not (nx_is_valid(form) and nx_find_custom(form, "enter_btn")) or not nx_is_valid(form.enter_btn) then
    return
  end
  create_grass_info(form)
  if not (nx_is_valid(form) and nx_find_custom(form, "enter_btn")) or not nx_is_valid(form.enter_btn) then
    return
  end
  local game_config = nx_value("game_config")
  if not nx_find_custom(game_config, "login_type") then
    game_config.login_type = "2"
  end
  if game_config.login_type == "2" then
    reset_form_ui(form)
  end
  local IsDelete = receiver:GetRoleDeleted(0)
  if 0 < IsDelete then
    delete_protect_process(form, receiver)
  else
    if not (nx_is_valid(form) and nx_find_custom(form, "enter_btn")) or not nx_is_valid(form.enter_btn) then
      return
    end
    form.enter_btn.Enabled = true
    form.vip_btn.Enabled = true
    form.lbl_endtime.Visible = false
    local game_config = nx_value("game_config")
    if game_config.login_type == "2" then
      form.delete_btn.NormalImage = "gui\\language\\ChineseS\\create\\creat_face\\bshanchu_out.png"
      form.delete_btn.FocusImage = "gui\\language\\ChineseS\\create\\creat_face\\bshanchu_on.png"
      form.delete_btn.PushImage = "gui\\language\\ChineseS\\create\\creat_face\\bshanchu_down.png"
    else
      form.delete_btn.NormalImage = "gui\\language\\ChineseS\\create\\delete_out.png"
      form.delete_btn.FocusImage = "gui\\language\\ChineseS\\create\\delete_on.png"
      form.delete_btn.PushImage = "gui\\language\\ChineseS\\create\\delete_down.png"
    end
  end
  if not nx_is_valid(form.scenebox_2.Scene) then
    util_addscene_to_scenebox(form.scenebox_2)
  end
  if nx_is_valid(form.scenebox_2.Scene) then
    nx_execute("utils_weather_set", "show_snow", form.scenebox_2.Scene, nx_null(), form.scenebox_2.Scene.camera)
  end
  return 1
end
function create_grass_info(form)
  local grass_node = get_global_list("grass_node")
  local scene = form.scenebox_grass.Scene
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. "ini\\rolecreate.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local grass_list = ini:GetItemValueList("grass_info", "grass")
  local grass_size = table.getn(grass_list)
  local pos_info = "0,0,0"
  local scale_info = "1,1,1"
  local angle_info = "0,0,0"
  for i = 1, grass_size do
    local actor2_grass = create_scene_npc(nil, grass_list[i], scene)
    if nx_is_valid(actor2_grass) then
      local node = grass_node:CreateChild("grass_" .. i)
      node.grass = actor2_grass
      util_add_model_to_scenebox(form.scenebox_grass, actor2_grass)
      pos_info = ini:ReadString("grass_info", "grass_pos_" .. i, "0,0,0")
      local pos_list = util_split_string(pos_info, ",")
      actor2_grass:SetPosition(nx_float(pos_list[1]) - 0.6, nx_float(pos_list[2]) - 0.45, nx_float(pos_list[3]))
      scale_info = ini:ReadString("grass_info", "grass_scale_" .. i, "1,1,1")
      local scale_list = util_split_string(scale_info, ",")
      actor2_grass:SetScale(nx_float(scale_list[1]), nx_float(scale_list[2]), nx_float(scale_list[3]))
      angle_info = ini:ReadString("grass_info", "grass_angle_" .. i, "0,0,0")
      local angle_list = util_split_string(angle_info, ",")
      actor2_grass:SetAngle(nx_float(angle_list[1]), nx_float(angle_list[2]), nx_float(angle_list[3]))
    end
  end
  nx_destroy(ini)
end
function on_main_form_close(form)
  local IniManager = nx_value("IniManager")
  if nx_is_valid(IniManager) then
    IniManager:UnloadIniFromManager(ENTER_LOAD_NEW_INI)
  end
end
function remove_role(form)
  if nx_is_valid(form) and nx_is_valid(form.role_actor2) then
    local scene = form.scenebox_1.Scene
    scene:Delete(form.role_actor2)
  end
end
function enter_btn_click(btn)
  nx_log("flow enter_btn_click")
  btn.Enabled = false
  local form = btn.Parent
  endPossAction(form.role_actor2, "stand")
  local role_index = 0
  nx_execute("client", "choose_role", role_index)
  res = nx_wait_event(100000000, nx_null(), "choose_role")
  if nx_is_valid(btn) then
    btn.Enabled = true
  end
  if res == "failed" then
    return 0
  end
  local asynor = nx_value("common_execute")
  asynor:RemoveExecute("blend_color", form.lbl_animations1)
  nx_log("flow choose role form close choose_role_success")
  return 1
end
function vip_btn_click(btn)
  local form = btn.ParentForm
  local status = false
  if form.vip_info ~= "ui_notvip" then
    status = true
  end
  nx_execute("form_stage_main\\form_vip_info", "open_vip_form_login", status)
end
function back_btn_click(btn)
  local form = btn.ParentForm
  remove_role(form)
  local sock = nx_value("game_sock")
  if nx_is_valid(sock) then
    sock:Disconnect()
  end
  nx_execute("stage", "set_current_stage", "login")
  return 1
end
function on_info_size_change(form)
  local gui = nx_value("gui")
  form.Width = gui.Width
  form.Height = gui.Height
  if nx_is_valid(form.lbl_bg) then
    form.lbl_bg.Width = gui.Width
    form.lbl_bg.Height = gui.Height
  end
  if nx_is_valid(form.lbl_animations1) then
    form.lbl_animations1.Width = gui.Width
    form.lbl_animations1.Height = gui.Height
  end
  if nx_is_valid(form.lbl_animations2) then
    form.lbl_animations2.Width = gui.Width
    form.lbl_animations2.Height = gui.Height
  end
  if nx_is_valid(form.lbl_down) then
    form.lbl_down.Width = gui.Width
  end
  if nx_is_valid(form.lbl_up) then
    form.lbl_up.Width = gui.Width
  end
  if nx_is_valid(form.scenebox_2) then
    form.scenebox_2.Width = gui.Width
    form.scenebox_2.Height = gui.Height
  end
  refresh_control_pos_size(form)
end
function delete_btn_click(btn)
  local form = btn.Parent
  local sock = nx_value("game_sock")
  local IsDelete = sock.Receiver:GetRoleDeleted(0)
  if 0 < IsDelete then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local text = nx_widestr(util_text("ui_role_recovery_tips"))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "cancel" then
      return 0
    end
    local role_name = sock.Receiver:GetRoleName(0)
    sock.Sender:ReviveRole(role_name)
    return 1
  end
  local role_index = 0
  local gui = nx_value("gui")
  if form.guildtitle == "ui_guild_pos_level1_name" then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local text = nx_widestr(util_text("ui_GuildDeleteRoleError"))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "cancel" then
      return 0
    end
    entry_btn = form:Find("enter_btn")
    if not nx_is_valid(entry_btn) then
      return 0
    end
    enter_btn_click(entry_btn)
    return 1
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  dialog.mltbox_info.HasVScroll = true
  dialog.mltbox_info.ViewRect = "0,0,238,118"
  dialog.mltbox_info.VScrollBar.Value = dialog.mltbox_info.VScrollBar.Maximum
  dialog.mltbox_info.VScrollBar.BackImage = "gui\\common\\scrollbar\\bg_scrollbar.png"
  dialog.mltbox_info.VScrollBar.DrawMode = "Expand"
  dialog.mltbox_info.VScrollBar.DecButton.NormalImage = "gui\\common\\scrollbar\\button_1\\btn_up_out.png"
  dialog.mltbox_info.VScrollBar.DecButton.FocusImage = "gui\\common\\scrollbar\\button_1\\btn_up_on.png"
  dialog.mltbox_info.VScrollBar.DecButton.PushImage = "gui\\common\\scrollbar\\button_1\\btn_up_down.png"
  dialog.mltbox_info.VScrollBar.DecButton.DrawMode = "ExpandV"
  dialog.mltbox_info.VScrollBar.IncButton.NormalImage = "gui\\common\\scrollbar\\button_1\\btn_down_out.png"
  dialog.mltbox_info.VScrollBar.IncButton.FocusImage = "gui\\common\\scrollbar\\button_1\\btn_down_on.png"
  dialog.mltbox_info.VScrollBar.IncButton.PushImage = "gui\\common\\scrollbar\\button_1\\btn_down_down.png"
  dialog.mltbox_info.VScrollBar.IncButton.DrawMode = "ExpandV"
  dialog.mltbox_info.VScrollBar.TrackButton.NormalImage = "gui\\common\\scrollbar\\button_1\\btn_trace_out.png"
  dialog.mltbox_info.VScrollBar.TrackButton.FocusImage = "gui\\common\\scrollbar\\button_1\\btn_trace_on.png"
  dialog.mltbox_info.VScrollBar.TrackButton.PushImage = "gui\\common\\scrollbar\\button_1\\btn_trace_on.png"
  dialog.mltbox_info.VScrollBar.TrackButton.DrawMode = "ExpandV"
  dialog.mltbox_info.VScrollBar.TrackButton.Width = 15
  dialog.cancel_btn.Text = nx_widestr(util_text("ui_role_del_cancel"))
  dialog.ok_btn.Text = nx_widestr(util_text("ui_role_del_sure"))
  local text = nx_widestr(util_text("ui_role_del_info"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "cancel" then
    return 0
  end
  nx_execute("client", "delete_role", role_index)
  res = nx_wait_event(100000000, nx_null(), "delete_role")
  if res == "succeed" and nx_is_valid(form) and nx_is_valid(form.role_actor2) then
    local scene = form.role_actor2.scene
    scene:Delete(form.role_actor2)
  end
  return 1
end
function exit_btn_click(btn)
  nx_execute("main", "exit_game")
  return 1
end
function get_pi(degree)
  return math.pi * degree / 180
end
function show_role_model(form)
  local game_visual = nx_value("game_visual")
  local world = nx_value("world")
  local scene = form.scenebox_1.Scene
  if not nx_is_valid(scene) then
    return false
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local actor2 = nx_value("stage_roles_actor2")
  if actor2 ~= nil and nx_is_valid(actor2) then
    scene:Delete(actor2)
  end
  actor2 = create_role_composite(scene, false, form.sex, "stand", form.body_type)
  form.role_actor2 = actor2
  if not nx_is_valid(actor2) then
    return false
  end
  actor2.Name = "form_roles_actor2"
  nx_set_value("stage_roles_actor2", actor2)
  while nx_is_valid(actor2) and not actor2.LoadFinish do
    nx_pause(0.1)
  end
  local face_actor2 = get_role_face(actor2)
  while nx_is_valid(actor2) and not nx_is_valid(face_actor2) do
    nx_pause(0.1)
    face_actor2 = get_role_face(actor2)
  end
  if not nx_is_valid(face_actor2) then
    return false
  end
  while nx_is_valid(face_actor2) and not face_actor2.LoadFinish do
    nx_pause(0.1)
  end
  local head_indo = {
    [1] = "hair",
    [2] = ""
  }
  role_composite:UnPlayerSkin(actor2, "hat")
  local skin_info = {
    [1] = {
      link_name = "mask",
      model_name = form.mask
    },
    [2] = {
      link_name = "hat",
      model_name = form.hat
    },
    [3] = {
      link_name = "cloth",
      model_name = form.cloth
    },
    [4] = {
      link_name = "pants",
      model_name = form.pants
    },
    [5] = {
      link_name = "shoes",
      model_name = form.shoes
    },
    [6] = {
      link_name = "mantle",
      model_name = form.mantle
    }
  }
  local effect_info = {
    [1] = {
      link_name = "WeaponEffect",
      model_name = form.weaponeffect
    },
    [2] = {
      link_name = "MaskEffect",
      model_name = form.maskeffect
    },
    [3] = {
      link_name = "HatEffect",
      model_name = form.hateffect
    },
    [4] = {
      link_name = "ClothEffect",
      model_name = form.clotheffect
    },
    [5] = {
      link_name = "PantsEffect",
      model_name = form.pantseffect
    },
    [6] = {
      link_name = "ShoesEffect",
      model_name = form.shoeseffect
    },
    [7] = {
      link_name = "MantleEffect",
      model_name = form.mantleeffect
    }
  }
  for i, info in pairs(skin_info) do
    if string.len(nx_string(info.model_name)) > 0 then
      if "cloth" == info.link_name then
        link_cloth_skin(role_composite, actor2, info.model_name)
      elseif info.link_name == "Hat" or info.link_name == "hat" then
        link_hat_skin(role_composite, actor2, info.model_name)
      elseif info.link_name == "Pants" or info.link_name == "pants" then
        link_pants_skin(role_composite, actor2, info.model_name)
      else
        link_skin(actor2, info.link_name, info.model_name .. ".xmod")
      end
    end
  end
  if nx_int(1) == nx_int(form.show_equip_type) then
    link_skin(actor2, "cloth_h", nx_string(nx_string(form.cloth) .. "_h" .. ".xmod"))
  end
  for i, info in pairs(effect_info) do
    if model_name ~= nil and model_name ~= null then
      link_effect(actor2, info.link_name, info.model_name)
    end
  end
  if form.action_set ~= "" then
    game_visual:SetRoleActionSet(actor2, form.action_set)
  end
  doPossAction(actor2, "stand")
  if form.weapon ~= "" then
    actor2.weapon_name = form.weapon
    refresh_weapon_position(actor2)
  end
  local actor_role = actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    del_actor(actor2)
    return false
  end
  local actor2_face = actor_role:GetLinkObject("actor_role_face")
  actor2.modify_face = form.modify_face
  if nx_int(form.face_type) > nx_int(0) then
    role_composite:LinkFaceSkin(actor2, form.sex, form.face_type, false)
  else
    set_player_face_ex(actor2_face, form.face, form.sex, actor2)
  end
  actor2:SetPosition(0, 0, 0)
  actor2:SetAngle(0, 0, 0)
  if not nx_is_valid(actor_role) then
    del_actor(actor2)
    return false
  end
  if not (nx_is_valid(form) and nx_find_custom(form, "scenebox_1")) or not nx_is_valid(form.scenebox_1) then
    del_actor(actor2)
    return false
  end
  if nx_is_valid(form.scenebox_1.Scene) then
    util_add_model_to_scenebox(form.scenebox_1, actor2)
    local camera = form.scenebox_1.Scene.camera
    if nx_is_valid(camera) then
      actor2.t_time = 5
      actor2.s_time = 0
      local x = 0
      local y = 1.2
      local z = -3.357
      local angle_y = 8
      actor2:SetPosition(0, -0.2, 0)
      local asynor = nx_value("common_execute")
      asynor:AddExecute("MoveCamera", camera, nx_float(0), actor2, nx_float(camera.PositionX), nx_float(camera.PositionY), nx_float(camera.PositionZ), nx_float(camera.AngleX), nx_float(x), nx_float(y), nx_float(z), nx_float(get_pi(angle_y)))
      player_face_random_action(form)
    end
  end
  return true
end
function get_role_face(role_actor2)
  local actor_role = role_actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    return nil
  end
  local actor2_face = actor_role:GetLinkObject("actor_role_face")
  return actor2_face
end
function apply_shadow_param(shadow)
  local shadow_uiparam = nx_value("shadow_uiparam")
  if not nx_is_valid(shadow_uiparam) then
    return false
  end
  shadow.ShadowTopColor = shadow_uiparam.topcolor
  shadow.ShadowBottomColor = shadow_uiparam.bottomcolor
  shadow.LightDispersion = shadow_uiparam.lightdispersion
  return true
end
function camera_moveto(target_x, target_y, target_z, keep_time)
  local world = nx_value("world")
  local scene = world.MainScene
  local camera_x = scene.camera.PositionX
  local camera_y = scene.camera.PositionY
  local camera_z = scene.camera.PositionZ
  local time_count = 0
  while nx_is_valid(scene) do
    local cur_x = time_count * (target_x - camera_x) / keep_time + camera_x
    local cur_y = time_count * (target_y - camera_y) / keep_time + camera_y
    local cur_z = time_count * (target_z - camera_z) / keep_time + camera_z
    scene.camera:SetPosition(cur_x, cur_y, cur_z)
    if keep_time < time_count then
      scene.camera:SetPosition(target_x, target_y, target_z)
      break
    end
    local wait_time = nx_pause(0)
    time_count = time_count + wait_time
    keep_time = keep_time + wait_time * 3 / 4
  end
  scene.camera.AllowControl = true
  scene.camera.allow_wasd = false
  scene.camera.drag_speed = 1
end
function auto_show_and_hide()
  local form = nx_value("form_stage_roles\\form_roles")
  if nx_is_valid(form) then
    form.enter_btn.Visible = not form.enter_btn.Visible
    form.delete_btn.Visible = form.enter_btn.Visible
    form.back_btn.Visible = form.enter_btn.Visible
    form.exit_btn.Visible = form.enter_btn.Visible
    form.GroupBox1.Visible = form.enter_btn.Visible
    form.vip_btn.Visible = form.enter_btn.Visible
    form.lbl_endtime.Visible = form.enter_btn.Visible
  end
end
function doPossAction(actor2, aciton)
  local action_module = nx_value("action_module")
  if nx_is_valid(action_module) and nx_is_valid(actor2) then
    actor2.cur_action = aciton
    local isExists = action_module:ActionExists(actor2, nx_string(aciton))
    if isExists then
      local is_in_list = action_module:ActionBlended(actor2, nx_string(aciton))
      if not is_in_list then
        action_module:BlendAction(actor2, nx_string(aciton), true, true)
      end
    end
  end
end
function endPossAction(actor2, aciton)
  local action_module = nx_value("action_module")
  if nx_is_valid(action_module) and nx_is_valid(actor2) then
    local is_exists = action_module:ActionExists(actor2, nx_string(aciton))
    if is_exists then
      action_module:UnblendAction(actor2, nx_string(aciton))
    end
    local action_stand = action_module:GetStandState(actor2)
    is_exists = action_module:ActionExists(actor2, nx_string(action_stand))
    if is_exists then
      action_module:BlendAction(actor2, nx_string(action_stand), true, true)
    end
  end
end
function change_action_poss(actor2, aciton)
  if nx_find_custom(actor2, "cur_action") then
    if nx_string(actor2.cur_action) == nx_string(aciton) then
      return
    end
    endPossAction(actor2, actor2.cur_action)
  end
  doPossAction(actor2, aciton)
end
function get_face(role_info_table)
  local face = role_info_table[6]
  local count = table.getn(role_info_table)
  local offset = 0
  for i = 7, count do
    if string.len(face) > 46 or string.len(face) == 46 then
      return face, offset
    end
    face = face .. string.char(44) .. role_info_table[i]
    offset = offset + 1
  end
  return face, offset
end
function del_actor(actor2)
  local world = nx_value("world")
  if nx_is_valid(world) and nx_is_valid(actor2) then
    world:Delete(actor2)
  end
end
function player_face_random_action(form)
  local asynor = nx_value("common_execute")
  if not nx_is_valid(form) or not nx_find_custom(form, "role_actor2") then
    return nil
  end
  if not nx_is_valid(form.role_actor2) then
    return nil
  end
  local role_actor2 = form.role_actor2
  role_actor2.random_eyes_time = math.random(2) + 4
  asynor:AddExecute("FaceRandomAction", role_actor2, nx_float(0))
end
function delete_protect_process(form, receiver)
  form.enter_btn.Enabled = false
  form.vip_btn.Enabled = false
  local game_config = nx_value("game_config")
  if game_config.login_type == "2" then
    form.delete_btn.NormalImage = "gui\\language\\ChineseS\\create\\creat_face\\btn_regain_out.png"
    form.delete_btn.FocusImage = "gui\\language\\ChineseS\\create\\creat_face\\btn_regain_on.png"
    form.delete_btn.PushImage = "gui\\language\\ChineseS\\create\\creat_face\\btn_regain_down.png"
  else
    form.delete_btn.NormalImage = "gui\\language\\ChineseS\\create\\recover_out.png"
    form.delete_btn.FocusImage = "gui\\language\\ChineseS\\create\\recover_on.png"
    form.delete_btn.PushImage = "gui\\language\\ChineseS\\create\\recover_down.png"
  end
  local delete_time = nx_string(receiver:GetRoleDeleteTime(0))
  delete_time = delete_time + 2
  local str_dt = nx_function("format_date_time", nx_double(delete_time))
  local table_dt = util_split_string(str_dt, ";")
  if table.getn(table_dt) ~= 2 then
    return ""
  end
  local year, month, day = format_date_text(table_dt[1])
  local day_time = format_time_text(table_dt[2])
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_role_del_timeout")
  gui.TextManager:Format_AddParam(nx_int(year))
  gui.TextManager:Format_AddParam(nx_int(month))
  gui.TextManager:Format_AddParam(nx_int(day))
  gui.TextManager:Format_AddParam(nx_int(day_time[1]))
  gui.TextManager:Format_AddParam(nx_int(day_time[2]))
  gui.TextManager:Format_AddParam(nx_int(day_time[3]))
  form.lbl_endtime.Visible = true
  form.lbl_endtime.Text = gui.TextManager:Format_GetText()
end
function format_date_text(text)
  local len = string.len(text)
  if nx_number(len) ~= 11 then
    return text
  end
  local hasYear = string.sub(nx_string(text), 1, 4)
  local hasMonth = string.sub(nx_string(text), 6, 7)
  local hasDay = string.sub(nx_string(text), 9, 10)
  return hasYear, hasMonth, hasDay
end
function format_time_text(text)
  local len = string.len(text)
  if nx_number(len) ~= 8 then
    return text
  end
  local table_dt = util_split_string(text, ":")
  if table.getn(table_dt) ~= 3 then
    return ""
  end
  return table_dt
end
function get_school_name(school_id)
  if school_id == "school_shaolin" then
    return nx_widestr("@ui_neigong_category_sl")
  elseif school_id == "school_wudang" then
    return nx_widestr("@ui_neigong_category_wd")
  elseif school_id == "school_emei" then
    return nx_widestr("@ui_neigong_category_em")
  elseif school_id == "school_junzitang" then
    return nx_widestr("@ui_neigong_category_jz")
  elseif school_id == "school_jinyiwei" then
    return nx_widestr("@ui_neigong_category_jy")
  elseif school_id == "school_jilegu" then
    return nx_widestr("@ui_neigong_category_jl")
  elseif school_id == "school_gaibang" then
    return nx_widestr("@ui_neigong_category_gb")
  elseif school_id == "school_tangmen" then
    return nx_widestr("@ui_neigong_category_tm")
  elseif school_id == "school_mingjiao" then
    return nx_widestr("@ui_neigong_category_mj")
  elseif school_id == "school_tianshan" then
    return nx_widestr("@ui_neigong_category_ts")
  elseif school_id == "force_yihua" then
    return nx_widestr("@ui_neigong_category_yh")
  elseif school_id == "force_taohua" then
    return nx_widestr("@ui_neigong_category_th")
  elseif school_id == "force_xujia" then
    return nx_widestr("@ui_neigong_category_xj")
  elseif school_id == "force_wugen" then
    return nx_widestr("@ui_neigong_category_wg")
  elseif school_id == "force_wanshou" then
    return nx_widestr("@ui_neigong_category_ws")
  elseif school_id == "force_jinzhen" then
    return nx_widestr("@ui_neigong_category_sj")
  elseif school_id == "newschool_gumu" then
    return nx_widestr("@ui_neigong_category_mu")
  elseif school_id == "newschool_xuedao" then
    return nx_widestr("@ui_neigong_category_xd")
  elseif school_id == "newschool_changfeng" then
    return nx_widestr("@ui_neigong_category_cf")
  elseif school_id == "newschool_nianluo" then
    return nx_widestr("@ui_neigong_category_nl")
  elseif school_id == "newschool_huashan" then
    return nx_widestr("@ui_neigong_category_hs")
  elseif school_id == "newschool_damo" then
    return nx_widestr("@ui_neigong_category_dm")
  elseif school_id == "newschool_shenshui" then
    return nx_widestr("@ui_neigong_category_ss")
  elseif school_id == "newschool_wuxian" then
    return nx_widestr("@ui_neigong_category_wx")
  elseif school_id == "newschool_shenji" then
    return nx_widestr("@ui_neigong_category_shenji")
  elseif school_id == "newschool_xingmiao" then
    return nx_widestr("@ui_neigong_category_xingmiao")
  else
    return nx_widestr("@ui_task_school_null")
  end
end
function get_format_text(stringid, param1, param2, param3, param4, param5, param6)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName(nx_string(stringid))
  if nil ~= param1 then
    gui.TextManager:Format_AddParam(param1)
  end
  if nil ~= param2 then
    gui.TextManager:Format_AddParam(param2)
  end
  if nil ~= param3 then
    gui.TextManager:Format_AddParam(param3)
  end
  if nil ~= param4 then
    gui.TextManager:Format_AddParam(param4)
  end
  if nil ~= param5 then
    gui.TextManager:Format_AddParam(param5)
  end
  if nil ~= param6 then
    gui.TextManager:Format_AddParam(param6)
  end
  return gui.TextManager:Format_GetText()
end
function set_control_ui(control)
  if not nx_is_valid(control) then
    return
  end
  local out_image = get_ini_prop(ENTER_LOAD_NEW_INI, control.Name, "out", "")
  local on_image = get_ini_prop(ENTER_LOAD_NEW_INI, control.Name, "on", "")
  local down_image = get_ini_prop(ENTER_LOAD_NEW_INI, control.Name, "down", "")
  local left = get_ini_prop(ENTER_LOAD_NEW_INI, control.Name, "left", "")
  local top = get_ini_prop(ENTER_LOAD_NEW_INI, control.Name, "top", "")
  local width = get_ini_prop(ENTER_LOAD_NEW_INI, control.Name, "width", "")
  local height = get_ini_prop(ENTER_LOAD_NEW_INI, control.Name, "height", "")
  if nx_name(control) == "Label" then
    if out_image ~= "" then
      control.BackImage = out_image
    end
  elseif nx_name(control) == "Button" then
    if out_image ~= "" then
      control.NormalImage = out_image
    end
    if on_image ~= "" then
      control.FocusImage = on_image
    end
    if down_image ~= "" then
      control.PushImage = down_image
    end
  elseif nx_name(control) == "CheckButton" or nx_name(control) == "RadioButton" then
    if out_image ~= "" then
      control.NormalImage = out_image
    end
    if on_image ~= "" then
      control.FocusImage = on_image
    end
    if down_image ~= "" then
      control.CheckedImage = down_image
    end
  elseif nx_name(control) == "GroupBox" or nx_name(control) == "GroupScrollableBox" then
    if out_image ~= "" then
      control.BackImage = out_image
    end
  elseif nx_name(control) == "Edit" then
    if out_image ~= "" then
      control.BackImage = out_image
    end
  elseif nx_name(control) == "MultiTextBox" then
    if out_image ~= "" then
      control.BackImage = out_image
    end
  else
    return
  end
  if left ~= "" and top ~= "" then
    control.Left = nx_number(left)
    control.Top = nx_number(top)
  end
  if width ~= "" and height ~= "" then
    control.Width = nx_number(width)
    control.Height = nx_number(height)
  end
end
function reset_form_ui(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", ENTER_LOAD_NEW_INI)
  if not nx_is_valid(ini) then
    return
  end
  local gui = nx_value("gui")
  local count = ini:GetSectionCount()
  for i = 0, count - 1 do
    local sec_name = ini:GetSectionByIndex(i)
    local control = nx_custom(form, sec_name)
    if nx_is_valid(control) then
      set_control_ui(control)
    end
  end
end
