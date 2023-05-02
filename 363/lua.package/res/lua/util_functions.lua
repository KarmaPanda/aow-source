require("const_define")
ERROR_ANGLE = -1000
PLAY_WEAPON_PATH = {
  ["101"] = "ini\\effect\\playerweapon\\weapon_1h.ini",
  ["102"] = "ini\\effect\\playerweapon\\weapon_2h.ini",
  ["103"] = "ini\\effect\\playerweapon\\weapon_3h.ini",
  ["104"] = "ini\\effect\\playerweapon\\weapon_4h.ini",
  ["105"] = "ini\\effect\\playerweapon\\weapon_5h.ini",
  ["106"] = "ini\\effect\\playerweapon\\weapon_6h.ini",
  ["107"] = "ini\\effect\\playerweapon\\weapon_7h.ini",
  ["108"] = "ini\\effect\\playerweapon\\weapon_8h.ini",
  ["127"] = "ini\\effect\\playerweapon\\weapon_27h.ini"
}
OPERATORS_TYPE_WONIU = 1
OPERATORS_TYPE_SNDA = 2
OPERATORS_TYPE_GOOGLE = 3
OPERATORS_TYPE_YAHOO = 4
OPERATORS_TYPE_FACEBOOK = 5
OPERATORS_TYPE_YOUXIJIDI = 6
OPERATORS_TYPE_BAHAMUTE = 7
OPERATORS_TYPE_BFAGE = 9
OPERATORS_TABLE = {
  ["1"] = OPERATORS_TYPE_WONIU,
  ["7"] = OPERATORS_TYPE_WONIU,
  ["186"] = OPERATORS_TYPE_SNDA,
  ["230"] = OPERATORS_TYPE_GOOGLE,
  ["231"] = OPERATORS_TYPE_YAHOO,
  ["232"] = OPERATORS_TYPE_FACEBOOK,
  ["238"] = OPERATORS_TYPE_BAHAMUTE,
  ["239"] = OPERATORS_TYPE_YOUXIJIDI,
  ["240"] = OPERATORS_TYPE_BFAGE
}
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function util_get_role_model()
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    local role = game_visual:GetSceneObj(game_visual.PlayerIdent)
    return role
  end
  return nx_null()
end
function util_get_target_role_model()
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    local client_role = game_client:GetSceneObj(game_visual.PlayerIdent)
    local target_ident = client_role:QueryProp("LastObject")
    local vis_target = game_visual:GetSceneObj(target_ident)
    return vis_target
  end
  return nx_null()
end
function util_split_string(szbuffer, splits)
  if szbuffer == nil then
    return {}
  end
  return nx_function("ext_split_string", szbuffer, splits)
end
function util_split_wstring(wszBuffer, splits)
  if wszBuffer == nil then
    return {}
  end
  return nx_function("ext_split_wstring", wszBuffer, nx_widestr(splits))
end
function util_encrypt_string(src)
  if src == nil or string.len(nx_string(src)) == 0 then
    return ""
  end
  local content = nx_function("ext_widestr_to_utf8", nx_widestr(src))
  return nx_function("ext_encrypt_string", content)
end
function util_dencrypt_string(des)
  if des == nil or string.len(nx_string(des)) == 0 then
    return ""
  end
  local content = nx_function("ext_dencrypt_string", nx_string(des))
  return nx_function("ext_utf8_to_widestr", content)
end
function util_get_account_path(account)
  local exe_path = nx_function("ext_get_current_exe_path")
  local login_account = ""
  if account == nil then
    local game_config = nx_value("game_config")
    if not nx_is_valid(game_config) then
      return exe_path
    end
    if not nx_find_property(game_config, "login_account") and nx_string(game_config.login_account) == "" then
      return exe_path
    end
    login_account = nx_string(game_config.login_account)
  else
    login_account = nx_string(account)
  end
  local path = nx_string(exe_path) .. login_account
  if not nx_path_exists(path) then
    nx_path_create(path)
  end
  return path .. "\\"
end
function is_space(text)
  local cpy = nx_string(text)
  for i = 1, string.len(cpy) do
    if string.sub(cpy, i, i) ~= " " then
      return false
    end
  end
  return true
end
function util_get_equip_artpkg(config_id)
  local item_query = nx_value("ItemQuery")
  local config_id = nx_string(config_id)
  if item_query:FindItemByConfigID(config_id) then
    return nx_number(item_query:GetItemPropByConfigID(config_id, "ArtPack"))
  end
  return -1
end
function get_weaponmode_path_by_name(item_name, prop_name)
  local itemmap = nx_value("ItemQuery")
  local model_path = item_query_ArtPack_by_id(nx_string(item_name), nx_string(prop_name))
  local item_type = itemmap:GetItemPropByConfigID(nx_string(item_name), nx_string("ItemType"))
  if PLAY_WEAPON_PATH[nx_string(item_type)] ~= nil then
    model_path = nx_string(model_path)
    local ini = get_ini(PLAY_WEAPON_PATH[nx_string(item_type)])
    if not nx_is_valid(ini) then
      return ""
    end
    if not ini:FindSection(model_path) then
      return ""
    end
    local sec_index = ini:FindSectionIndex(model_path)
    if sec_index < 0 then
      return ""
    end
    model_path = ini:ReadString(sec_index, "Model", "")
    local path_len = nx_number(string.len(nx_string(model_path)))
    if nx_number(path_len) > 5 and string.sub(nx_string(model_path), path_len - 4) == ".xmod" then
      model_path = string.sub(nx_string(model_path), 1, path_len - 5)
    end
  end
  return model_path
end
function util_load_prop_from_ini(ini_file_lst, id)
  local prop_table = {}
  local item_query = nx_value("ItemQuery")
  local config_id = nx_string(id)
  if item_query:FindItemByConfigID(config_id) then
    local prop_name_table = item_query:GetItemPropNameArrayByConfigID(config_id)
    local count = table.maxn(prop_name_table)
    for i = 1, count do
      prop_table[prop_name_table[i]] = item_query:GetItemPropByConfigID(config_id, prop_name_table[i])
    end
  end
  return prop_table
end
function util_load_itemprop_from_ini(itemid)
  local ini_file_lst = {
    "share\\item\\Tool_Item.ini",
    "share\\item\\OtherItem.ini",
    "share\\item\\EquipItem.ini"
  }
  return util_load_prop_from_ini(ini_file_lst, itemid)
end
function util_load_npcprop_from_ini(npcid)
  local ini_file_lst = {
    "share\\npc\\funcnpc.ini",
    "share\\npc\\fightnpc.ini"
  }
  return util_load_prop_from_ini(ini_file_lst, npcid)
end
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function play_scene_random_music(scene, type, scene_res_name, start_time, fade_time, Loop)
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return ""
  end
  local map_id = nx_int(map_query:GetSceneId(scene_res_name))
  local scene_music_play_manager = nx_value("scene_music_play_manager")
  if not nx_is_valid(scene_music_play_manager) then
    return ""
  end
  local scene_music_name = "main_scene_music_" .. nx_string(scene_music_play_manager:GetRandomSceneMusicName(map_id))
  if scene_music_name == "main_scene_music_" then
    scene_music_name = scene_res_name
    play_music(scene, "scene", scene_music_name)
    return ""
  end
  play_music(scene, "scene", scene_music_name, start_time, fade_time, false)
end
function play_music(scene, type, name, start_time, fade_time, loop, volume, b_wait_last)
  local sound_man = scene.sound_man
  if nx_is_valid(sound_man) then
    sound_man.cur_music_name = name
  end
  local game_config = nx_value("game_config")
  if fade_time == nil then
    fade_time = 1
  end
  if start_time == nil then
    start_time = 0
  end
  if loop == nil then
    loop = true
  end
  if volume == nil then
    volume = game_config.music_volume
  end
  if b_wait_last == nil then
    b_wait_last = false
  end
  local scene_music_play_manager = nx_value("scene_music_play_manager")
  if nx_is_valid(scene_music_play_manager) then
    return scene_music_play_manager:PlayGameMusic(type, name, start_time, fade_time, loop, volume, b_wait_last)
  end
  return 0
end
function stop_music(fadeout_time)
  local game_config = nx_value("game_config")
  local real_fadeout_time = fadeout_time
  if not game_config.music_enable or game_config.music_volume == 0 then
    real_fadeout_time = 0
  end
  local scene_music_play_manager = nx_value("scene_music_play_manager")
  if nx_is_valid(scene_music_play_manager) then
    scene_music_play_manager:StopGameMusic(real_fadeout_time)
  end
end
function play_music_file(musicfile, volume, fade_time, b_play)
  if musicfile ~= "" then
    musicfile = nx_resource_path() .. musicfile
    if volume == nil then
      volume = 1
    elseif nx_number(volume) < 0 or 1 < nx_number(volume) then
      volume = 1
    end
    if fade_time == nil then
      fade_time = 1
    end
    if b_play == nil then
      b_play = true
    end
    return nx_function("ext_play_music_file", musicfile, fade_time, b_play)
  end
  return nx_null()
end
function util_create_model(mod, eff, tex1, tex2, tex3, is_asynload, scene_obj)
  local tex_paths = ""
  if tex1 ~= "" then
    tex_paths = tex1
  end
  if tex2 ~= "" then
    tex_paths = tex_paths .. "|" .. tex2
  end
  if tex3 ~= "" then
    tex_paths = tex_paths .. "|" .. tex3
  end
  local scene
  if scene_obj == nil or not nx_is_valid(scene_obj) then
    local world = nx_value("world")
    scene = nx_value("game_scene")
    if not nx_is_valid(scene) then
      return nx_null()
    end
  else
    scene = scene_obj
  end
  local model = scene:Create("Model")
  if is_asynload == nil then
    is_asynload = true
  end
  model.AsyncLoad = is_asynload
  model.ModelFile = mod
  model.Effect = eff
  model.TexPaths = tex_paths
  model:Load()
  if is_asynload then
    while not model.LoadFinish do
      nx_pause(0)
    end
  end
  return model
end
function trans_capital_string(capital, bJin)
  local gui = nx_value("gui")
  if bJin then
    local text = nx_string(capital) .. nx_string(gui.TextManager:GetText("ui_liang"))
    return nx_widestr(text)
  end
  if nx_number(capital) > 0 then
    return util_format_string("{@0:$}", nx_int64(capital))
  end
  return nx_widestr("0" .. nx_string(gui.TextManager:GetText("ui_Wen")))
end
function util_find_client_player_by_name(player_name)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nil
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return nil
  end
  local client_object_list = client_scene:GetSceneObjList()
  local count = table.maxn(client_object_list)
  for i = 1, count do
    local obj_type = client_object_list[i]:QueryProp("Type")
    if obj_type == 2 then
      local name = client_object_list[i]:QueryProp("Name")
      if nx_string(name) == nx_string(player_name) then
        return client_object_list[i]
      end
    end
  end
  return nil
end
function get_ini(file_name, reload)
  local ini_mgr = nx_value("IniManager")
  if not nx_is_valid(ini_mgr) then
    return nx_null()
  end
  if reload == true then
    ini_mgr:UnloadIniFromManager(file_name)
  end
  return ini_mgr:LoadIniToManager(file_name)
end
function get_xml(file)
  local xml_mgr = nx_value("XMLManager")
  if not nx_is_valid(xml_mgr) then
    return nx_null()
  end
  return xml_mgr:Load(file)
end
function unload_xml(file)
  local xml_mgr = nx_value("XMLManager")
  if not nx_is_valid(xml_mgr) then
    return nx_null()
  end
  return xml_mgr:Unload(file)
end
function util_text(id)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    return gui.TextManager:GetText(id)
  end
  return nx_widestr("no")
end
function get_actor_role(role)
  local game_visual = nx_value("game_visual")
  local role_type = game_visual:QueryRoleType(role)
  if role_type == 2 then
    local actor_role = role:GetLinkObject("actor_role")
    if not nx_is_valid(actor_role) then
      actor_role = role
    end
    return actor_role
  end
  return role
end
function nip_radian(r)
  local ret = r - nx_number(nx_int(r / (2 * math.pi))) * (2 * math.pi)
  if ret < 0 then
    ret = ret + 2 * math.pi
  end
  return ret
end
function nip_radianII(r)
  local ret = nip_radian(r)
  if ret > math.pi then
    ret = ret - 2 * math.pi
  end
  return ret
end
function math_get_angle(z, x)
  local ret = 0
  local dist = math.sqrt(z * z + x * x)
  if 0.001 < dist then
    if z < 0 then
      ret = math.acos(-z / dist)
      ret = math.pi - ret
    else
      ret = math.acos(z / dist)
    end
    if x < 0 then
      ret = -ret
    end
  end
  return nip_radian(ret)
end
function float_equal(a, b, dist, info)
  if (a == nil or b == nil) and info ~= nil then
    nx_msgbox(nx_string(info))
  end
  if dist >= math.abs(a - b) then
    return true
  else
    return false
  end
end
function float_bigger(a, b, dist)
  if a > b + dist then
    return true
  else
    return false
  end
end
function float_smaller(a, b, dist)
  if a < b - dist then
    return true
  else
    return false
  end
end
function get_role_to_target_angle(role)
  if not nx_is_valid(role) then
    return ERROR_ANGLE
  end
  local game_visual = nx_value("game_visual")
  local client_ident = game_visual:QueryRoleClientIdent(role)
  if client_ident == "" then
    return ERROR_ANGLE
  end
  local game_client = nx_value("game_client")
  local client_role = game_client:GetSceneObj(client_ident)
  if not nx_is_valid(client_role) then
    return ERROR_ANGLE
  end
  local target_ident = client_role:QueryProp("LastObject")
  local target_model = game_visual:GetSceneObj(target_ident)
  if nx_is_valid(target_model) then
    local sub_x = target_model.PositionX - role.PositionX
    local sub_z = target_model.PositionZ - role.PositionZ
    return math_get_angle(sub_z, sub_x)
  end
  return ERROR_ANGLE
end
function open_ini_doc(file_name)
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. file_name
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return nx_null()
  end
  return ini
end
function util_format_string(strid, ...)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_widestr(strid)
  end
  gui.TextManager:Format_SetIDName(strid)
  for i, para in pairs(arg) do
    local type = nx_type(para)
    if type == "number" then
      gui.TextManager:Format_AddParam(nx_int(para))
    elseif type == "string" then
      gui.TextManager:Format_AddParam(gui.TextManager:GetText(para))
    else
      gui.TextManager:Format_AddParam(para)
    end
  end
  return gui.TextManager:Format_GetText()
end
function get_msg_str(str_id, ...)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return str_id
  end
  gui.TextManager:Format_SetIDName(str_id)
  for i, para in pairs(arg) do
    local para_type = nx_type(para)
    if para_type == "number" then
      gui.TextManager:Format_AddParam(nx_int(para))
    elseif para_type == "string" then
      gui.TextManager:Format_AddParam(gui.TextManager:GetText(para))
    else
      gui.TextManager:Format_AddParam(para)
    end
  end
  return nx_string(gui.TextManager:Format_GetText())
end
function util_get_global_entity(global_name, entity_name, is_create)
  local entity_id = nx_value(global_name)
  if nx_is_valid(entity_id) then
    return entity_id
  end
  if not is_create then
    return nx_null()
  end
  entity_id = nx_create(entity_name)
  if nx_is_valid(entity_id) then
    nx_set_value(global_name, entity_id)
  end
  return entity_id
end
function util_set_custom_key(obj, key, value)
  if not nx_is_valid(obj) then
    return ""
  end
  nx_set_custom(obj, nx_string(key), value)
end
function util_get_custom_key(obj, key, default_value)
  if not nx_is_valid(obj) then
    return ""
  end
  if not nx_find_custom(obj, nx_string(key)) then
    nx_set_custom(obj, nx_string(key), default_value)
    if default_value == nil then
      return "0"
    else
      return default_value
    end
  end
  return nx_custom(obj, nx_string(key))
end
function util_set_property_key(obj, key, value)
  if not nx_is_valid(obj) then
    return ""
  end
  nx_set_property(obj, nx_string(key), value)
end
function util_get_property_key(obj, key, default_value)
  if not nx_is_valid(obj) then
    return default_value
  end
  if not nx_find_property(obj, nx_string(key)) then
    nx_set_property(obj, nx_string(key), default_value)
    if default_value == nil then
      return "0"
    else
      return default_value
    end
  end
  return nx_property(obj, nx_string(key))
end
function get_language()
  local default_lang = "ChineseS"
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) and nx_find_property(game_config, "Language") and game_config.Language ~= "" then
    return game_config.Language
  end
  local ini = open_ini_doc("text\\language.ini")
  if nx_is_valid(ini) then
    local lang = ini:ReadString("Language", "Local", default_lang)
    if lang ~= "" then
      nx_destroy(ini)
      return lang
    end
  end
  return "ChineseS"
end
function get_use_res_process()
  local ini = open_ini_doc("text\\language.ini")
  if nx_is_valid(ini) then
    local value = ini:ReadString("config", "UseResProcess", "")
    if value ~= "" then
      nx_destroy(ini)
      return nx_boolean(value)
    end
  end
  return false
end
function get_language_path()
  local default_lang = "ChineseS"
  local lang = ""
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) and game_config.Language ~= "" then
    lang = game_config.Language
    return "text\\" .. lang .. "\\"
  end
  local ini = open_ini_doc("text\\language.ini")
  if nx_is_valid(ini) then
    lang = ini:ReadString("Language", "Local", default_lang)
  end
  nx_destroy(ini)
  if lang == "" then
    lang = default_lang
  end
  return "text\\" .. lang .. "\\"
end
MB_OK = 0
MB_OKCANCEL = 1
MB_ABORTRETRYIGNORE = 2
MB_YESNOCANCEL = 3
MB_YESNO = 4
MB_RETRYCANCEL = 5
MB_ICONHAND = 16
MB_ICONQUESTION = 32
MB_ICONEXCLAMATION = 48
MB_ICONASTERISK = 64
MB_USERICON = 128
MB_ICONWARNING = MB_ICONEXCLAMATION
MB_ICONERROR = MB_ICONHAND
MB_ICONINFORMATION = MB_ICONASTERISK
MB_ICONSTOP = MB_ICONHAND
IDOK = 1
IDCANCEL = 2
IDABORT = 3
IDRETRY = 4
IDIGNORE = 5
IDYES = 6
IDNO = 7
function util_confirm(caption, text, button, icon)
  caption = caption or ""
  text = text or ""
  button = button or 0
  icon = icon or 0
  return nx_function("ext_confirm", nx_widestr(caption), nx_widestr(text), nx_int(button) + nx_int(icon))
end
function util_form_confirm(caption, text, button, modal)
  caption = caption or ""
  text = text or ""
  button = button or 1
  if modal == nil then
    modal = true
  end
  local gui = nx_value("gui")
  local dialog
  local confirm_return = ""
  if nx_string(caption) == nx_string("") then
    dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    confirm_return = "confirm_return"
  else
    local form = nx_value(nx_string(caption) .. "_form_confirm")
    if nx_is_valid(form) then
      if nx_find_custom(form, "modal") then
        if form.modal then
          form.ShowModal()
        else
          form.Show()
        end
      else
        form:ShowModal()
      end
      return
    end
    dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", nx_string(caption))
    dialog.lbl_1.Text = nx_widestr(caption)
    confirm_return = nx_string(caption) .. "_confirm_return"
  end
  dialog.VAnchor = "Top"
  dialog.HAnchor = "Left"
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  dialog.mltbox_info:Clear()
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(text), nx_int(-1))
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  if nx_int(button) == nx_int(0) then
    dialog.relogin_btn.Visible = false
    dialog.ok_btn.Visible = true
    dialog.cancel_btn.Visible = false
    dialog.ok_btn.Left = (dialog.Width - dialog.ok_btn.Width) / 2
  else
    dialog.relogin_btn.Visible = false
    dialog.ok_btn.Visible = true
    dialog.cancel_btn.Visible = true
  end
  if modal then
    dialog:ShowModal()
  else
    dialog:Show()
  end
  dialog.modal = modal
  local res = nx_wait_event(100000000, dialog, confirm_return)
  return res, dialog
end
function get_operators_name()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return OPERATORS_TYPE_WONIU
  end
  local id = game_config.card_no
  local operators = OPERATORS_TABLE[nx_string(id)]
  if operators == nil then
    return OPERATORS_TYPE_WONIU
  end
  return operators
end
function get_login_info_list()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  return nx_function("ext_split_string", game_config.server_sdo, "|")
end
function util_clear_custom_list(id)
  if not nx_is_valid(id) then
    return false
  end
  return nx_function("ext_clear_custom_list", id)
end
function util_remove_custom(id, prop)
  if not nx_is_valid(id) then
    return false
  end
  if prop == nil or nx_string(prop) == nx_string("") then
    return false
  end
  return nx_function("ext_remove_custom", id, prop)
end
function get_grid_treasure_back_image(equip_type, color_level)
  if equip_type ~= "Treasure" and equip_type ~= "NewTreasure" then
    return ""
  else
    return "icon\\treasure\\" .. nx_string(color_level) .. ".png"
  end
end
function link_cloth_skin(role_composite, actor2, cloth_name)
  if nx_is_valid(role_composite) and nx_is_valid(actor2) and nil ~= cloth_name and nx_string("") ~= nx_string(cloth_name) then
    return role_composite:LinkClothSkin(actor2, cloth_name)
  end
  return false
end
function link_hat_skin(role_composite, actor2, hat_name)
  if nx_is_valid(role_composite) then
    if nx_find_method(role_composite, "LinkHatSkin") then
      return role_composite:LinkHatSkin(actor2, hat_name)
    else
      return role_composite:LinkSkin(actor2, "hat", hat_name .. ".xmod", false)
    end
  end
  return false
end
function link_pants_skin(role_composite, actor2, pants_name)
  if nx_is_valid(role_composite) then
    if nx_find_method(role_composite, "LinkPantsSkin") then
      return role_composite:LinkPantsSkin(actor2, pants_name)
    else
      return role_composite:LinkSkin(actor2, "pants", pants_name .. ".xmod", false)
    end
  end
  return false
end
function get_scene_obj_height(actor2)
  local actor_role = actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    return actor2.BoxSizeY
  end
  if actor_role:NodeIsExist("BoneRUe05") then
    local x, y, z = actor_role:GetNodePosition("BoneRUe05")
    return y
  end
  return actor2.BoxSizeY
end
function get_ini_key_data(path, section, key, key_type)
  local ini = nx_execute("util_functions", "get_ini", nx_string(path))
  if not nx_is_valid(ini) then
    if nx_string(key_type) == "string" then
      return ""
    elseif nx_string(key_type) == "integer" then
      return 0
    elseif nx_string(key_type) == "float" then
      return 0
    end
  end
  local sec_index = ini:FindSectionIndex(nx_string(section))
  if sec_index < 0 then
    if nx_string(key_type) == "string" then
      return ""
    elseif nx_string(key_type) == "integer" then
      return 0
    elseif nx_string(key_type) == "float" then
      return 0
    end
  end
  if nx_string(key_type) == "string" then
    return ini:ReadString(sec_index, nx_string(key), "")
  elseif nx_string(key_type) == "integer" then
    return ini:ReadInteger(sec_index, nx_string(key), 0)
  elseif nx_string(key_type) == "float" then
    return ini:ReadFloat(sec_index, nx_string(key), 0)
  end
end
function get_arraylist_by_parse_xmldata(item_info, array_data)
  local xmldoc = nx_create("XmlDocument")
  if not xmldoc:ParseXmlData(item_info, 1) then
    nx_destroy(xmldoc)
    return nil
  end
  local xmlroot = xmldoc.RootElement
  array_data:ClearChild()
  local xmlelement = xmlroot:GetChildByIndex(0)
  if not nx_is_valid(xmlelement) then
    nx_destroy(xmldoc)
    return nil
  end
  for i = 0, xmlelement:GetAttrCount() - 1 do
    local name = xmlelement:GetAttrName(i)
    local value = xmlelement:GetAttrValue(i)
    nx_set_custom(array_data, name, value)
  end
  local xml_element_record = xmlroot:GetChildByIndex(1)
  if nx_is_valid(xml_element_record) then
    local record_num = xml_element_record:GetChildCount()
    local str_record_group = ""
    for i = 0, record_num - 1 do
      local child = xml_element_record:GetChildByIndex(i)
      local record_name = child:QueryAttr("name")
      local record_rows = child:QueryAttr("rows")
      local sz_child_info = nx_string(record_name) .. "," .. nx_string(record_rows)
      local record_prop_num = 0
      for index = 0, record_rows - 1 do
        local child_child = child:GetChildByIndex(index)
        record_prop_num = nx_int(record_prop_num) + (nx_int(child_child:GetAttrCount()) - 1)
      end
      sz_child_info = nx_string(sz_child_info) .. "," .. nx_string(record_prop_num / record_rows)
      for index = 0, record_rows - 1 do
        local child_child = child:GetChildByIndex(index)
        local record_prop_num = child_child:GetAttrCount()
        for record_index = 1, record_prop_num - 1 do
          local prop_name = child_child:GetAttrName(record_index)
          local prop_value = child_child:GetAttrValue(record_index)
          sz_child_info = nx_string(sz_child_info) .. "," .. nx_string(prop_value)
        end
      end
      if str_record_group == "" then
        str_record_group = nx_string(sz_child_info)
      else
        str_record_group = nx_string(str_record_group) .. "," .. nx_string(sz_child_info)
      end
    end
    if nx_int(record_num) > nx_int(0) then
      array_data.item_rec_data_info = str_record_group
    end
  end
  array_data.is_chat_link = true
  nx_destroy(xmldoc)
  return array_data
end
function support_pom_rian_skin()
  local device_caps = nx_value("device_caps")
  if not nx_is_valid(device_caps) then
    return false
  end
  local card_level = nx_execute("device_test", "get_video_card_level", device_caps)
  if card_level < 3 then
    return false
  end
  local mem_size = device_caps.TotalVideoMemory + device_caps.TotalAgpMemory
  if mem_size < 800 then
    return false
  end
  return true
end
