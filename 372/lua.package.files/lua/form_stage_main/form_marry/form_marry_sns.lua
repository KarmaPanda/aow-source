require("util_gui")
require("role_composite")
require("form_stage_main\\switch\\switch_define")
FORM_NAME = "form_stage_main\\form_marry\\form_marry_sns"
ORIGIN_EM_BODY_WOMAN_JUV = 3
ORIGIN_EM_BODY_MAN_JUV = 4
ORIGIN_EM_BODY_WOMAN_MAJ = 5
ORIGIN_EM_BODY_MAN_MAJ = 6
g_hat_model = {
  [0] = "obj\\char\\b_hair\\b_hair1",
  [1] = "obj\\char\\g_hair\\g_hair1"
}
g_cloth_model = {
  [0] = "obj\\char\\b_jianghu001\\b_cloth001",
  [1] = "obj\\char\\g_jianghu001\\g_cloth001"
}
g_pants_model = {
  [0] = "obj\\char\\b_jianghu001\\b_pants001",
  [1] = "obj\\char\\g_jianghu001\\g_pants001"
}
g_shoes_model = {
  [0] = "obj\\char\\b_jianghu001\\b_shoes001",
  [1] = "obj\\char\\g_jianghu001\\g_shoes001"
}
function open_form()
  local switch_manager = nx_value("SwitchManager")
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_MARRY) then
    util_auto_show_hide_form(nx_current())
  else
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("7109"), 2)
    end
  end
end
function on_main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local form_chat = nx_value("form_stage_main\\form_main\\form_main_chat")
  if nx_is_valid(form_chat) then
    local gui = nx_value("gui")
    gui.Desktop:ToFront(form_chat)
  end
  init_scene(form)
  init_visible(form)
  change_form_size()
end
function on_main_form_close(form)
  if nx_find_custom(form.scenebox.Scene, "game_effect") and nx_is_valid(form.scenebox.Scene.game_effect) then
    nx_destroy(form.scenebox.Scene.game_effect)
  end
  if nx_find_custom(form.scenebox.Scene, "sky") and nx_is_valid(form.scenebox.Scene.sky) then
    form.scenebox.Scene:Delete(form.scenebox.Scene.sky)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function init_visible(form)
  form.first_open_yinyuan = true
  form.first_open_fuqifuli = true
  form.scenebox_male.first_show = true
  form.scenebox_famale.first_show = true
  form.rbtn_yinyuan.Checked = true
  form.gb_center.Visible = false
  form.groupbox_marry_info.Visible = false
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_MARRY_USE_BIND_CARD) then
    form.mltbox_marry_price_1.Visible = false
    form.lbl_7.Visible = false
  end
end
function change_form_size()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Desktop.Width
  form.Height = gui.Desktop.Height
  form.groupbox_rbtn.Left = 0
  form.groupbox_rbtn.Width = form.Width
  form.groupbox_rbtn.Top = form.Top + form.Height - form.groupbox_rbtn.Height
  form.scenebox.Left = 0
  form.scenebox.Top = 0
  form.scenebox.Width = form.Width
  form.scenebox.Height = form.Height - form.groupbox_rbtn.Height
  form.groupbox_yinyuan.Left = 0
  form.groupbox_yinyuan.Top = 0
  form.groupbox_yinyuan.Width = form.Width
  form.groupbox_yinyuan.Height = form.Height
  form.groupbox_fuqifuli.Left = 0
  form.groupbox_fuqifuli.Top = 0
  form.groupbox_fuqifuli.Width = form.Width
  form.groupbox_fuqifuli.Height = form.Height
end
function on_rbtn_yinyuan_checked_changed(btn)
  if btn.Checked then
    local form = btn.ParentForm
    if nx_is_valid(form) then
      form.groupbox_fuqifuli.Visible = false
      form.groupbox_yinyuan.Visible = true
      if form.first_open_yinyuan then
        local game_client = nx_value("game_client")
        local client_player = game_client:GetPlayer()
        local name = client_player:QueryProp("Name")
        local sex = client_player:QueryProp("Sex")
        local body_type = client_player:QueryProp("BodyType")
        form.self_name = name
        form.body_type = body_type
        if sex == 0 then
          form.partner_sex = 1
          form.self_scenebox = form.scenebox_male
          form.partner_scenebox = form.scenebox_famale
          form.self_namelbl = form.lbl_male_name
          form.partner_namelbl = form.lbl_famale_name
        elseif sex == 1 then
          form.partner_sex = 0
          form.self_scenebox = form.scenebox_famale
          form.partner_scenebox = form.scenebox_male
          form.self_namelbl = form.lbl_famale_name
          form.partner_namelbl = form.lbl_male_name
        end
        nx_execute("form_stage_main\\form_marry\\form_marry_util", "request_partner_info")
        form.first_open_yinyuan = false
      end
    end
  end
end
function show_partner_info(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local partner_name = arg[2]
  if partner_name == nx_widestr("") or partner_name == nil then
    nx_execute(nx_current(), "show_self", form)
    nx_execute(nx_current(), "show_single_partner", form)
    form.groupbox_marry_info.Visible = false
    form.gb_center.Visible = false
  else
    form.scenebox_male.Left = -176
    form.scenebox_famale.Left = -100
    form.lbl_male_name.Left = -18
    form.lbl_famale_name.Left = 56
    form.self_namelbl.Text = form.self_name
    form.partner_name = partner_name
    form.self_role_info = arg[1]
    form.role_info = arg[3]
    form.marry_date = arg[4]
    form.marry_score = arg[5]
    if nx_find_custom(form, "self_scenebox") and nx_is_valid(form.self_scenebox) then
      nx_execute(nx_current(), "show_role_info", form, form.self_role_info, form.self_scenebox)
    end
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    form.partner_namelbl.Text = form.partner_name
    local y, m, d = nx_function("ext_decode_date", nx_double(form.marry_date))
    local date = nx_string(y) .. "." .. nx_string(m) .. "." .. nx_string(d)
    form.lbl_marry_date.Text = nx_widestr(date)
    form.lbl_marry_score.Text = nx_widestr(form.marry_score)
    local marry_cooperation = client_player:QueryProp("MarryCooperation")
    form.lbl_marry_cooperation.Text = nx_widestr(marry_cooperation)
    if nx_find_custom(form, "partner_scenebox") and nx_is_valid(form.partner_scenebox) then
      nx_execute(nx_current(), "show_role_info", form, form.role_info, form.partner_scenebox)
    end
    form.groupbox_marry_info.Visible = true
    form.gb_center.Visible = true
  end
end
function show_self(form)
  if not (nx_is_valid(form) and nx_find_custom(form, "self_scenebox") and nx_is_valid(form.self_scenebox) and nx_find_custom(form, "self_namelbl") and nx_is_valid(form.self_namelbl) and nx_find_custom(form, "self_name")) or not nx_find_custom(form, "body_type") then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local sex = client_player:QueryProp("Sex")
  local scenebox = form.self_scenebox
  if nx_find_custom(form, "self_actor2") then
    local world = nx_value("world")
    world:Delete(form.self_actor2)
  end
  if not nx_is_valid(scenebox.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", scenebox)
  end
  local self_actor2
  self_actor2 = create_scene_obj_composite(scenebox.Scene, client_player, false)
  if form.body_type == ORIGIN_EM_BODY_WOMAN_JUV or form.body_type == ORIGIN_EM_BODY_MAN_JUV or form.body_type == ORIGIN_EM_BODY_WOMAN_MAJ or form.body_type == ORIGIN_EM_BODY_MAN_MAJ then
    self_actor2.sex = sex
    self_actor2.body_type = form.body_type
    self_actor2.body_face = client_player:QueryProp("BodyFace")
    role_composite:refresh_body(self_actor2, true)
  end
  if not nx_is_valid(self_actor2) then
    return
  end
  while nx_call("role_composite", "is_loading", 2, self_actor2) do
    nx_pause(0)
  end
  if not nx_is_valid(form) then
    return
  end
  util_add_model_to_scenebox(scenebox, self_actor2)
  form.self_actor2 = self_actor2
  form.self_namelbl.Text = form.self_name
end
function show_single_partner(form)
  if not (nx_is_valid(form) and nx_find_custom(form, "partner_scenebox") and nx_is_valid(form.partner_scenebox) and nx_find_custom(form, "partner_namelbl") and nx_is_valid(form.partner_namelbl)) or not nx_find_custom(form, "partner_sex") then
    return
  end
  local scenebox = form.partner_scenebox
  local sex = form.partner_sex
  if nx_find_custom(form, "partner_actor2") and nx_is_valid(form.partner_actor2) then
    local world = nx_value("world")
    world:Delete(form.partner_actor2)
  end
  if not nx_is_valid(scenebox.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", scenebox)
  end
  local partner_actor2
  partner_actor2 = create_role_composite(scenebox.Scene, true, sex)
  while nx_call("role_composite", "is_loading", 2, partner_actor2) do
    nx_pause(0)
  end
  if not nx_is_valid(form) then
    return
  end
  local skin_info = {
    [1] = {
      link_name = "hat",
      model_name = g_hat_model[sex]
    },
    [2] = {
      link_name = "cloth",
      model_name = g_cloth_model[sex]
    },
    [3] = {
      link_name = "pants",
      model_name = g_pants_model[sex]
    },
    [4] = {
      link_name = "shoes",
      model_name = g_shoes_model[sex]
    }
  }
  for i, info in pairs(skin_info) do
    if info.model_name ~= nil then
      link_skin(partner_actor2, info.link_name, info.model_name .. ".xmod")
    end
  end
  util_add_model_to_scenebox(scenebox, partner_actor2)
  form.partner_actor2 = partner_actor2
  nx_function("ext_set_model_single_color", partner_actor2, "0.05,0.05,0.05")
  nx_function("ext_set_model_around_color", partner_actor2, "0.69,0.825,0.996", "0.005")
end
function show_role_info(form, role_info, scene_box)
  if role_info == "" or role_info == nil then
    return
  end
  local role_info_table = nx_function("ext_split_string", nx_string(role_info), ",")
  scene_box.sex = nx_number(role_info_table[1])
  local offset = 0
  scene_box.face, offset = get_face(role_info_table)
  scene_box.show_equip_type = role_info_table[7 + offset]
  scene_box.hat = role_info_table[8 + offset]
  scene_box.mask = role_info_table[9 + offset]
  scene_box.cloth = role_info_table[10 + offset]
  scene_box.pants = role_info_table[11 + offset]
  scene_box.shoes = role_info_table[12 + offset]
  scene_box.weapon = role_info_table[13 + offset]
  scene_box.mantle = role_info_table[14 + offset]
  scene_box.hateffect = role_info_table[15 + offset]
  scene_box.maskeffect = role_info_table[16 + offset]
  scene_box.clotheffect = role_info_table[17 + offset]
  scene_box.pantseffect = role_info_table[18 + offset]
  scene_box.shoeseffect = role_info_table[19 + offset]
  scene_box.weaponeffect = role_info_table[20 + offset]
  scene_box.mantleeffect = role_info_table[21 + offset]
  scene_box.action_set = role_info_table[22 + offset]
  if table.getn(role_info_table) >= 36 + offset then
    scene_box.modify_face = role_info_table[36 + offset]
  else
    scene_box.modify_face = ""
  end
  if nx_int(scene_box.sex) == 0 then
    scene_box.body_type = 2
  else
    scene_box.body_type = 1
  end
  if table.getn(role_info_table) >= 37 + offset and role_info_table[37 + offset] ~= nx_widestr("") then
    scene_box.body_type = nx_number(role_info_table[37 + offset])
  end
  if table.getn(role_info_table) >= 38 + offset and role_info_table[38 + offset] ~= nx_widestr("") then
    scene_box.body_face = nx_number(role_info_table[38 + offset])
  else
    scene_box.body_face = 0
  end
  show_role_model(form, scene_box)
end
function show_role_model(form, scene_box)
  if not nx_is_valid(form) or not nx_is_valid(scene_box) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local game_visual = nx_value("game_visual")
  local world = nx_value("world")
  if not nx_is_valid(scene_box.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", scene_box)
  end
  local scene = scene_box.Scene
  if not nx_is_valid(scene) then
    return
  end
  local old_actor2
  if nx_find_custom(scene_box, "scene_box_actor2") then
    old_actor2 = scene_box.scene_box_actor2
    scene_box.first_show = false
  end
  if old_actor2 ~= nil and nx_is_valid(old_actor2) then
    scene_box.Scene:Delete(old_actor2)
  elseif not scene_box.first_show then
    while not nx_is_valid(old_actor2) do
      nx_pause(0.1)
    end
    scene:Delete(old_actor2)
  end
  local actor2 = create_role_composite(scene, false, scene_box.sex, "stand", nx_number(scene_box.body_type))
  scene_box.role_actor2 = actor2
  if not nx_is_valid(actor2) then
    return false
  end
  scene_box.scene_box_actor2 = actor2
  while nx_is_valid(actor2) and not actor2.LoadFinish do
    nx_pause(0.1)
  end
  if not nx_is_valid(actor2) then
    return
  end
  local face_actor2 = get_role_face(actor2)
  while nx_is_valid(actor2) and not nx_is_valid(face_actor2) do
    nx_pause(0.1)
    if not nx_is_valid(actor2) then
      return
    end
    face_actor2 = get_role_face(actor2)
  end
  if not nx_is_valid(face_actor2) then
    return
  end
  while nx_is_valid(face_actor2) and not face_actor2.LoadFinish do
    nx_pause(0.1)
  end
  if not nx_is_valid(form) then
    return
  end
  local skin_info = {
    [1] = {
      link_name = "mask",
      model_name = scene_box.mask
    },
    [2] = {
      link_name = "hat",
      model_name = scene_box.hat
    },
    [3] = {
      link_name = "cloth",
      model_name = scene_box.cloth
    },
    [4] = {
      link_name = "pants",
      model_name = scene_box.pants
    },
    [5] = {
      link_name = "shoes",
      model_name = scene_box.shoes
    },
    [6] = {
      link_name = "mantle",
      model_name = scene_box.mantle
    }
  }
  local effect_info = {
    [1] = {
      link_name = "WeaponEffect",
      model_name = scene_box.weaponeffect
    },
    [2] = {
      link_name = "MaskEffect",
      model_name = scene_box.maskeffect
    },
    [3] = {
      link_name = "HatEffect",
      model_name = scene_box.hateffect
    },
    [4] = {
      link_name = "ClothEffect",
      model_name = scene_box.clotheffect
    },
    [5] = {
      link_name = "PantsEffect",
      model_name = scene_box.pantseffect
    },
    [6] = {
      link_name = "ShoesEffect",
      model_name = scene_box.shoeseffect
    },
    [7] = {
      link_name = "MantleEffect",
      model_name = scene_box.mantleeffect
    }
  }
  for i, info in pairs(skin_info) do
    if string.len(nx_string(info.model_name)) > 0 and info.model_name ~= nil then
      if nx_int(scene_box.body_type) == nx_int(ORIGIN_EM_BODY_WOMAN_JUV) or nx_int(scene_box.body_type) == nx_int(ORIGIN_EM_BODY_MAN_JUV) or nx_int(scene_box.body_type) == nx_int(ORIGIN_EM_BODY_WOMAN_MAJ) or nx_int(scene_box.body_type) == nx_int(ORIGIN_EM_BODY_MAN_MAJ) then
        link_skin(actor2, info.link_name, nx_string(info.model_name) .. ".xmod", false)
      elseif "cloth" == info.link_name then
        local role_composite = nx_value("role_composite")
        link_cloth_skin(role_composite, actor2, nx_string(info.model_name))
      else
        link_skin(actor2, info.link_name, nx_string(info.model_name) .. ".xmod")
      end
    else
      unlink_skin(actor2, info.link_name)
    end
  end
  if nx_int(1) == nx_int(scene_box.show_equip_type) then
    link_skin(actor2, "cloth_h", nx_string(nx_string(scene_box.cloth) .. "_h" .. ".xmod"), false)
  end
  for i, info in pairs(effect_info) do
    if model_name ~= nil and model_name ~= null then
      link_effect(actor2, info.link_name, info.model_name)
    end
  end
  if nx_find_custom(scene_box, "sex") then
    if scene_box.sex == 1 then
      doPossAction(actor2, "interact_we_05")
    elseif scene_box.sex == 0 then
      doPossAction(actor2, "interact_we_04")
    end
  end
  local actor_role = actor2:GetLinkObject("actor_role")
  local actor2_face = actor_role:GetLinkObject("actor_role_face")
  actor2.modify_face = scene_box.modify_face
  if 0 < scene_box.body_face then
    local role_composite = nx_value("role_composite")
    role_composite:LinkFaceSkin(actor2, scene_box.sex, scene_box.body_face, false)
  else
    set_player_face_ex(actor2_face, scene_box.face, scene_box.sex, actor2)
  end
  util_add_model_to_scenebox(scene_box, actor2)
end
function del_actor(actor2)
  local world = nx_value("world")
  if nx_is_valid(world) and nx_is_valid(actor2) then
    world:Delete(actor2)
  end
end
function get_pi(degree)
  return math.pi * degree / 180
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
function get_role_face(role_actor2)
  if not nx_is_valid(role_actor2) then
    return nil
  end
  local actor_role = role_actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    return nil
  end
  local actor2_face = actor_role:GetLinkObject("actor_role_face")
  return actor2_face
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
function on_btn_zhenghun_click(btn)
  nx_execute("form_stage_main\\form_marry\\form_marry_util", "request_open_collect")
end
function on_btn_jiehunjiri_click(btn)
  nx_execute("form_stage_main\\form_marry\\form_marry_util", "request_open_confirm_date")
end
function create_marry_type_tree(form)
  local gui = nx_value("gui")
  local root = form.tree_marry_type:CreateRootNode(nx_widestr("marry_type"))
  root.Expand = true
  if not nx_is_valid(root) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "ini\\marry_sns_info.ini")
  if not nx_is_valid(ini) then
    return
  end
  local select_node
  for i = 0, ini:GetSectionCount() - 1 do
    local title = ini:ReadString(i, "title", "")
    local dooly_model = ini:ReadString(i, "dooly_model", "")
    local mount_model = ini:ReadString(i, "mount_model", "")
    local price = ini:ReadInteger(i, "price", 1)
    local flow_desc = ini:ReadString(i, "flow_desc", "")
    local prize_desc = ini:ReadString(i, "prize_desc", "")
    local dooly_scale = ini:ReadFloat(i, "dooly_scale", 1)
    local mount_scale = ini:ReadFloat(i, "mount_scale", 1)
    local dooly_rotate_speed = ini:ReadFloat(i, "dooly_rotate_speed", 1)
    local mount_rotate_speed = ini:ReadFloat(i, "mount_rotate_speed", 1)
    local dooly_title = ini:ReadString(i, "dooly_title", "ui_ride_weeding_desc")
    local mount_title = ini:ReadString(i, "mount_title", "ui_zuoji")
    local type_node = root:CreateNode(gui.TextManager:GetText(title))
    type_node.mark = 1
    type_node.price = price
    type_node.flow_desc = flow_desc
    type_node.prize_desc = prize_desc
    set_main_node_style(type_node)
    if dooly_model ~= "" then
      local dooly_node = type_node:CreateNode(gui.TextManager:GetText(dooly_title))
      set_sub_node_style(dooly_node)
      dooly_node.model = dooly_model
      dooly_node.mark = 2
      dooly_node.scale = dooly_scale
      dooly_node.rotate_speed = dooly_rotate_speed
      dooly_node.price = price
      dooly_node.flow_desc = flow_desc
      dooly_node.prize_desc = prize_desc
    end
    if mount_model ~= "" then
      local mount_node = type_node:CreateNode(gui.TextManager:GetText(mount_title))
      set_sub_node_style(mount_node)
      mount_node.model = mount_model
      mount_node.mark = 2
      mount_node.scale = mount_scale
      mount_node.rotate_speed = mount_rotate_speed
      mount_node.price = price
      mount_node.flow_desc = flow_desc
      mount_node.prize_desc = prize_desc
    end
    if dooly_model ~= "" then
      type_node.model = dooly_model
      type_node.scale = dooly_scale
      type_node.rotate_speed = dooly_rotate_speed
    elseif mount_model ~= "" then
      type_node.model = mount_model
      type_node.scale = mount_scale
      type_node.rotate_speed = mount_rotate_speed
    end
    if i == 0 then
      select_node = type_node
    end
    type_node.Expand = true
  end
  form.tree_marry_type.SelectNode = select_node
end
function set_main_node_style(node)
  node.Font = "DefaultT"
  node.TextOffsetY = 4
  node.ItemHeight = 26
  node.NodeBackImage = "gui\\special\\sns_new\\tree_2_out.png"
  node.NodeFocusImage = "gui\\special\\sns_new\\tree_2_on.png"
  node.NodeSelectImage = "gui\\special\\sns_new\\tree_2_on.png"
  node.ExpandCloseOffsetX = 155
  node.ExpandCloseOffsetY = 8
  node.NodeOffsetY = 3
end
function set_sub_node_style(node)
  node.Font = "font_text"
  node.NodeImageOffsetX = 30
  node.TextOffsetX = 10
  node.TextOffsetY = 2
  node.NodeFocusImage = "gui\\special\\sns_new\\tree_3_on.png"
  node.NodeSelectImage = "gui\\special\\sns_new\\tree_3_on.png"
end
function on_tree_marry_type_select_changed(tree)
  local node = tree.SelectNode
  local form = tree.ParentForm
  if not nx_is_valid(node) then
    return
  end
  if nx_find_custom(node, "mark") then
    if node.mark == 1 then
      if nx_find_custom(node, "price") and nx_find_custom(node, "flow_desc") and nx_find_custom(node, "prize_desc") and nx_find_custom(node, "model") and nx_find_custom(node, "scale") and nx_find_custom(node, "rotate_speed") then
        set_marry_type_info(form, node.price, node.flow_desc, node.prize_desc)
        set_marry_type_model(form, node.model, node.scale, node.rotate_speed)
      end
    elseif node.mark == 2 and nx_find_custom(node, "model") and nx_find_custom(node, "scale") and nx_find_custom(node, "rotate_speed") and nx_find_custom(node, "price") and nx_find_custom(node, "flow_desc") and nx_find_custom(node, "prize_desc") then
      set_marry_type_info(form, node.price, node.flow_desc, node.prize_desc)
      set_marry_type_model(form, node.model, node.scale, node.rotate_speed)
    end
  end
end
function set_marry_type_info(form, price, flow_desc, prize_desc)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  set_marry_type_price(form, price)
  form.mltbox_marry_prize_desc:Clear()
  form.mltbox_marry_prize_desc:AddHtmlText(gui.TextManager:GetText(prize_desc), nx_int(-1))
  form.mltbox_marry_flow_desc:Clear()
  form.mltbox_marry_flow_desc:AddHtmlText(gui.TextManager:GetText(flow_desc), nx_int(-1))
end
function set_marry_type_price(form, capital)
  local ding = math.floor(capital / 1000000)
  local liang = math.floor(capital % 1000000 / 1000)
  local wen = math.floor(capital % 1000)
  local gui = nx_value("gui")
  local textyZi = nx_widestr("")
  local htmlTextYinZi = nx_widestr("<center>")
  if 0 < ding then
    local text = gui.TextManager:GetText("ui_ding")
    local htmlText = nx_widestr(text)
    if add_color then
      ding = nx_widestr(nx_int(ding))
    end
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(ding) .. nx_widestr(htmlText)
  end
  if 0 < liang then
    local text = gui.TextManager:GetText("ui_liang")
    local htmlText = nx_widestr(text)
    if add_color then
      liang = nx_widestr(nx_int(liang))
    end
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(liang) .. nx_widestr(htmlText)
  end
  if 0 < wen then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr(text)
    if add_color then
      wen = nx_widestr(nx_int(wen))
    end
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(wen) .. nx_widestr(htmlText)
  end
  form.mltbox_marry_price:Clear()
  form.mltbox_marry_price:AddHtmlText(htmlTextYinZi, nx_int(-1))
  form.mltbox_marry_price_1:Clear()
  form.mltbox_marry_price_1:AddHtmlText(htmlTextYinZi, nx_int(-1))
end
function set_marry_type_model(form, model, scale, rotate_speed)
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  nx_execute("util_gui", "ui_ClearModel", form.scenebox_show_item)
  if not nx_is_valid(form.scenebox_show_item.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_show_item)
  end
  local scene = form.scenebox_show_item.Scene
  local actor2 = create_actor2(scene, "marry_dooly")
  local result = role_composite:CreateSceneObjectFromIni(actor2, model)
  if not result then
    scene:Delete(actor2)
  end
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_show_item, actor2)
  actor2:SetScale(scale, scale, scale)
  nx_execute(nx_current(), "rotate_y", actor2, rotate_speed)
end
function rotate_y(mode, rotate_y)
  local angle = 0
  while nx_is_valid(mode) do
    angle = rotate_y * nx_pause(0)
    if nx_is_valid(mode) then
      mode:SetAngle(mode.AngleX, mode.AngleY + angle, mode.AngleZ)
    end
  end
end
function on_rbtn_fuqifuli_checked_changed(btn)
  if btn.Checked then
    local form = btn.ParentForm
    if nx_is_valid(form) then
      form.groupbox_fuqifuli.Visible = true
      form.groupbox_yinyuan.Visible = false
      if form.first_open_fuqifuli then
        create_marry_type_tree(form)
        form.first_open_fuqifuli = false
      end
    end
  end
end
function on_btn_qingyuanpu_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_marry\\form_qingyuanpu")
end
function on_btn_player_info_click(btn)
  local form = btn.ParentForm
  if form.partner_name ~= "" and form.partner_name ~= nil then
    nx_execute("custom_sender", "custom_send_get_player_game_info", form.partner_name)
  end
end
function on_btn_qifu_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_qifu", true, false)
  dialog.SendPlayerName = form.partner_name
  gui.Desktop:ToFront(dialog)
  dialog.Visible = true
  dialog:Show()
end
function on_btn_present_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_present", true, false)
  dialog.SendPlayerName = form.partner_name
  gui.Desktop:ToFront(dialog)
  dialog.Visible = true
  dialog:Show()
end
function init_scene(form)
  util_addscene_to_scenebox(form.scenebox)
  local scene = form.scenebox.Scene
  if not nx_is_valid(scene) then
    return
  end
  local particle_man = nx_null()
  if not nx_is_valid(particle_man) then
    particle_man = scene:Create("ParticleManager")
    particle_man.TexturePath = "map\\tex\\particles\\"
    particle_man:Load()
    particle_man.EnableCacheIni = true
    scene:AddObject(particle_man, 100)
    scene.particle_man = particle_man
  end
  local sky = create_sky(scene)
  sky:Load()
  scene:AddObject(sky, 2)
  scene.sky = sky
  create_terrain(scene, 1, 4, 100, 100)
  local game_effect = nx_create("GameEffect")
  nx_bind_script(game_effect, "game_effect", "game_effect_init", scene)
  scene.game_effect = game_effect
  set_visual_radius(scene, 20)
  scene.ClearZBuffer = true
  scene.camera:SetPosition(3, 4, 0)
  scene.camera:SetAngle(0, 0, 0)
end
function util_addscene_to_scenebox(scenebox)
  local ini = nx_execute("util_functions", "get_ini", "ini\\sns\\sns_marry_weather.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local ambient_red = ini:ReadInteger("light", "ambient_red", 0)
  local ambient_green = ini:ReadInteger("light", "ambient_green", 0)
  local ambient_blue = ini:ReadInteger("light", "ambient_blue", 0)
  local ambient_intensity = ini:ReadFloat("light", "ambient_intensity", 0)
  local sunglow_red = ini:ReadInteger("light", "sunglow_red", 0)
  local sunglow_green = ini:ReadInteger("light", "sunglow_green", 0)
  local sunglow_blue = ini:ReadInteger("light", "sunglow_blue", 0)
  local sunglow_intensity = ini:ReadFloat("light", "sunglow_intensity", 0)
  local sun_height = ini:ReadInteger("light", "sun_height", 0)
  local sun_azimuth = ini:ReadInteger("light", "sun_azimuth", 0)
  local point_light_red = ini:ReadInteger("light", "point_light_red", 0)
  local point_light_green = ini:ReadInteger("light", "point_light_green", 0)
  local point_light_blue = ini:ReadInteger("light", "point_light_blue", 0)
  local point_light_range = ini:ReadFloat("light", "point_light_range", 0)
  local point_light_intensity = ini:ReadFloat("light", "point_light_intensity", 0)
  local point_light_pos_x = ini:ReadFloat("light", "point_light_pos_x", 0)
  local point_light_pos_y = ini:ReadFloat("light", "point_light_pos_y", 0)
  local point_light_pos_z = ini:ReadFloat("light", "point_light_pos_z", 0)
  local scene = scenebox.Scene
  if not nx_is_valid(scene) then
    local world = nx_value("world")
    scene = world:Create("Scene")
    scenebox.Scene = scene
    nx_call("scene", "support_physics", world, scene)
    local weather = scene.Weather
    weather.FogEnable = false
    weather.AmbientColor = "255," .. nx_string(ambient_red) .. "," .. nx_string(ambient_green) .. "," .. nx_string(ambient_blue)
    weather.SunGlowColor = "255," .. nx_string(sunglow_red) .. "," .. nx_string(sunglow_green) .. "," .. nx_string(sunglow_blue)
    weather.SpecularColor = "255,63,21,28"
    weather.AmbientIntensity = ambient_intensity
    weather.SunGlowIntensity = sunglow_intensity
    weather.SpecularIntensity = 2
    local sun_height_rad = sun_height / 360 * math.pi * 2
    local sun_azimuth_rad = sun_azimuth / 360 * math.pi * 2
    scenebox.sun_height_rad = sun_height_rad
    scenebox.sun_azimuth_rad = sun_azimuth_rad
    weather:MakeSunDirection(sun_height_rad, sun_azimuth_rad)
    scene.BackColor = scenebox.BackColor
    scene.EnableRealizeTempRT = false
    local camera = scene:Create("Camera")
    camera.AllowControl = false
    camera.Fov = 0.10416666666666667 * math.pi * 2
    scene.camera = camera
    scene:AddObject(camera, 0)
    local light_man = scene:Create("LightManager")
    scene.light_man = light_man
    scene.light_man = light_man
    scene:AddObject(light_man, 1)
    light_man.SunLighting = true
    local light = light_man:Create()
    scene.light = light
    light.Color = "255," .. nx_string(point_light_red) .. "," .. nx_string(point_light_green) .. "," .. nx_string(point_light_blue)
    light.Range = point_light_range
    light.Intensity = point_light_intensity
    light.Attenu0 = 0
    light.Attenu1 = 1
    light.Attenu2 = 0
    light:SetPosition(point_light_pos_x, point_light_pos_y, point_light_pos_z)
    local radius = 1.5
    scene.camera:SetPosition(0, radius * 0.6, -radius * 2.5)
    scene.camera:SetAngle(0, 0, 0)
    scene:Load()
  end
  return true
end
function create_terrain(scene, unit_size, tex_units, zone_rows, zone_cols)
  local terrain = scene:Create("Terrain")
  if unit_size == 1 then
    terrain:SetParameter(256, 32, 256, tex_units, 2, 2)
    terrain.UnitSize = 1
    terrain.LightPerUnit = 2
  else
    terrain:SetParameter(128, 16, 256, tex_units, 4, 4)
    terrain.UnitSize = 2
    terrain.LightPerUnit = 4
  end
  terrain.DesignMode = true
  terrain.InitHeight = 0
  terrain.ShowDesignLine = false
  local dev_caps = nx_value("device_caps")
  if 2 < dev_caps.MaxTextures then
    terrain.TexStage2 = false
  else
    terrain.TexStage2 = true
  end
  terrain.ZoneLightPath = "lzone"
  terrain.ModelLightPath = "lmodel"
  terrain.WalkablePath = "walk"
  terrain:AddBaseTex("base1", terrain.AppendPath .. "map\\tex\\dibiao_03")
  terrain:AddTexturePath("map\\tex\\model\\")
  local gui = nx_value("gui")
  terrain:Load()
  scene:AddObject(terrain, 20)
  scene.terrain = terrain
  nx_set_value("terrain", terrain)
  terrain:InitZones(zone_rows, zone_cols, zone_rows / 2, zone_cols / 2, 2)
  return terrain
end
function create_sky(scene)
  local sky = scene:Create("SkyBox")
  if not nx_is_valid(sky) then
    disp_error("create sky failed")
    return nil
  end
  local asyncLoad = true
  sky.AsyncLoad = nx_boolean(asyncLoad)
  local yawSpeed = 0.01
  sky.YawSpeed = yawSpeed
  local mulFactor = 500
  sky.MulFactor = mulFactor
  local visible = true
  sky.Visible = nx_boolean(visible)
  sky.UpTex = "map\\tex\\marry_sns_sky.dds"
  sky.SideTex = "map\\tex\\marry_sns_sky.dds"
  return sky
end
function set_visual_radius(scene, radius)
  local far_clip = 1000
  scene.FarClipDistance = far_clip
  local weather = scene.Weather
  if nx_is_valid(weather) then
    weather.FogStart = 100
    weather.FogEnd = 1000
    weather.FogLinear = true
    local color = "255,206,90,69"
    weather.FogColor = color
    weather.FogExpColor = color
    weather.FogHeight = 300
    weather.FogHeightExp = 1
    weather.FogExp = true
    weather.FogDensity = 0.07
    scene.BackColor = color
    weather.FogEnable = true
  end
end
function on_btn_fuqirenwu_click(btn)
  nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "show_type_info", 33)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_jiehunbaixiao_click(btn)
  local data = "jhbl"
  nx_execute("form_stage_main\\form_helper\\form_theme_helper", "util_open_theme", data)
end
