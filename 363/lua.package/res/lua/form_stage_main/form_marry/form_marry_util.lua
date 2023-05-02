require("utils")
require("util_gui")
require("util_functions")
require("util_functions")
require("role_composite")
require("custom_sender")
require("player_state\\state_const")
FORM_MARRY_COLLECT = "form_stage_main\\form_marry\\form_marry_collect"
FORM_MARRY_REQUEST = "form_stage_main\\form_marry\\form_marry_request"
FORM_MARRY_CANCEL = "form_stage_main\\form_marry\\form_marry_cancel"
FORM_MARRY_RESPONSE = "form_stage_main\\form_marry\\form_marry_response"
FORM_MARRY_CONFIRMDATE = "form_stage_main\\form_marry\\form_marry_confirmdate"
FORM_MARRY_DIVORCE = "form_stage_main\\form_marry\\form_marry_divorce"
FORM_MARRY_DETAILS = "form_stage_main\\form_marry\\form_marry_details"
FORM_MARRY_DINNER = "form_stage_main\\form_marry\\form_marry_dinner"
FORM_MARRY_DESK = "form_stage_main\\form_marry\\form_marry_desk"
FORM_MARRY_SENDCARD = "form_stage_main\\form_marry\\form_marry_sendcard"
FORM_MARRY_TRACE = "form_stage_main\\form_marry\\form_marry_trace"
FORM_MARRY_GIFT = "form_stage_main\\form_marry\\form_marry_gift"
FORM_MARRY_BTNS = "form_stage_main\\form_marry\\form_marry_btns"
INI_FILE_MARRY_MAIN = "share\\InterActive\\marry\\marry_main.ini"
INI_FILE_MARRY_RITE = "share\\InterActive\\marry\\marry_rite.ini"
INI_FILE_MARRY_TIME = "share\\InterActive\\marry\\marry_time.ini"
INI_FILE_MARRY_GIFT = "share\\InterActive\\marry\\marry_gift_info.ini"
TABLE_NAME_FRIEND_REC = "rec_friend"
TABLE_NAME_BUDDY_REC = "rec_buddy"
MARRY_BTN_LABA = 1
MARRY_BTN_ZHUFU = 2
MARRY_BTN_DONGFANG = 3
FRIEND_REC_UID = 0
FRIEND_REC_NAME = 1
FRIEND_REC_PHOTO = 2
FRIEND_REC_CHENGHAO = 3
FRIEND_REC_LEVEL = 4
FRIEND_REC_MENPAI = 5
FRIEND_REC_BANGPAI = 6
FRIEND_REC_XINQING = 7
FRIEND_REC_ONLINE = 8
FRIEND_REC_SCENE = 9
FRIEND_REC_MODEL = 10
DINNER_TYPE_ONLY_FRIEND = 1
DINNER_TYPE_ALL_PERPLE = 2
MARRY_CONFIRMDATE_TYPE_LOOK = 1
MARRY_CONFIRMDATE_TYPE_SELECT = 2
MARRY_CONFIRMDATE_TYPE_RESET = 3
SERVER_MSG_SUB_MARRY_COLLECT = 1
SERVER_MSG_SUB_MARRY_REQUEST = 2
SERVER_MSG_SUB_MARRY_CANCEL = 3
SERVER_MSG_SUB_MARRY_RESPONSE = 4
SERVER_MSG_SUB_MARRY_CONFIRMDATE = 5
SERVER_MSG_SUB_MARRY_DINNER = 6
SERVER_MSG_SUB_MARRY_DIVORCE = 7
SERVER_MSG_SUB_MARRY_FLOWTRACE = 8
SERVER_MSG_SUM_MARRY_HAVED_COLLECT = 9
SERVER_MSG_SUB_MARRY_PARTNER_INFO = 30
SERVER_MSG_SUB_WINE_DESK = 50
SERVER_MSG_SUB_WISH_COST_RANK = 70
CLIENT_MSG_SUB_MARRY_COLLECT = 1
CLIENT_MSG_SUB_MARRY_COLLECT_LOOK = 2
CLIENT_MSG_SUB_MARRY_REQUEST_SEND = 3
CLIENT_MSG_SUB_MARRY_REQUEST_CANCEL = 4
CLIENT_MSG_SUB_MARRY_REQUEST_AGREE = 5
CLIENT_MSG_SUB_MARRY_REQUEST_REFUSE = 6
CLIENT_MSG_SUB_MARRY_CONFIRM_DATE = 7
CLIENT_MSG_SUB_MARRY_SEND_CARD = 8
CLIENT_MSG_SUB_MARRY_DINNER_START = 9
CLIENT_MSG_SUB_MARRY_DIVORCE_T = 10
CLIENT_MSG_SUB_MARRY_DIVORCE_M = 11
CLIENT_MSG_SUB_MARRY_SHOW_DATE = 12
CLIENT_MSG_SUB_MARRY_SHOW_COLLECT = 13
CLIENT_MSG_SUB_MARRY_GET_FLOW_INFO = 14
CLIENT_MSG_SUB_MARRY_GIVEUP_COLLECT = 15
CLIENT_MSG_SUB_MARRY_PARTNER_INFO = 30
CLIENT_MSG_SUB_MARRY_SHOW_PARTNER_NAME = 31
CLIENT_MSG_SUB_WINE_DESK = 50
CLIENT_MSG_SUB_WISH_COST_RANK = 70
CLIENT_MSG_SUB_MARRY_USE_GIFT = 71
MARRY_STATUS_SINGLE = 1
MARRY_STATUS_REQUEST_SEND = 2
MARRY_STATUS_REQUEST_REFUSE = 3
MARRY_STATUS_REQUEST_AGREE = 4
MARRY_STATUS_CONFIRM_DATE = 5
MARRY_STATUS_WEDDING = 6
MARRY_STATUS_BAITANG_MIDDLE = 7
MARRY_STATUS_BAITANG_FINISH = 8
MARRY_STATUS_PARADE1_MIDDLE = 9
MARRY_STATUS_PARADE1_FINISH = 10
MARRY_STATUS_DINNER_MIDDLE = 11
MARRY_STATUS_DINNER_FINISH = 12
MARRY_STATUS_PARADE2_MIDDLE = 13
MARRY_STATUS_PARADE2_FINISH = 14
MARRY_STATUS_DONGFANG_MIDDLE = 15
MARRY_STATUS_DONGFANG_FINISH = 16
MARRY_STATUS_MARRIED = 17
function set_form_pos(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  return 1
end
function set_form_all_screen(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Width
  form.Height = gui.Height
  return 1
end
function on_size_change()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local form_collect = nx_value(FORM_MARRY_COLLECT)
  if nx_is_valid(form_collect) then
    set_form_all_screen(form_collect)
  end
  local form_request = nx_value(FORM_MARRY_REQUEST)
  if nx_is_valid(form_request) then
    set_form_pos(form_request)
  end
  local form_cancel = nx_value(FORM_MARRY_CANCEL)
  if nx_is_valid(form_cancel) then
    set_form_pos(form_cancel)
  end
  local form_response = nx_value(FORM_MARRY_RESPONSE)
  if nx_is_valid(form_response) then
    set_form_pos(form_response)
  end
  local form_confirmdate = nx_value(FORM_MARRY_CONFIRMDATE)
  if nx_is_valid(form_confirmdate) then
    set_form_all_screen(form_confirmdate)
  end
  local form_divorce = nx_value(FORM_MARRY_DIVORCE)
  if nx_is_valid(form_divorce) then
    set_form_pos(form_divorce)
  end
  local form_trace = nx_value(FORM_MARRY_TRACE)
  if nx_is_valid(form_trace) then
    form_trace.AbsLeft = gui.Width - form_trace.Width - 20
    form_trace.AbsTop = (gui.Height - form_trace.Height) / 2
  end
  local form_dinner = nx_value(FORM_MARRY_DINNER)
  if nx_is_valid(form_dinner) then
    set_form_pos(form_dinner)
  end
  local form_details = nx_value(FORM_MARRY_DETAILS)
  if nx_is_valid(form_details) then
    set_form_pos(form_details)
  end
  local form_sendcard = nx_value(FORM_MARRY_SENDCARD)
  if nx_is_valid(form_sendcard) then
    set_form_pos(form_sendcard)
  end
  local form_btns = nx_value(FORM_MARRY_BTNS)
  if nx_is_valid(form_btns) then
    form_btns.AbsLeft = (gui.Width - form_btns.Width) / 2
    form_btns.AbsTop = gui.Height - form_btns.Height - 200
  end
end
function split_capital(money_type, value)
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return {
      0,
      0,
      0
    }
  end
  return capital:SplitCapital(nx_int64(value), nx_int(money_type))
end
function get_format_capital_html(money_type, value)
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return ""
  end
  return capital:GetFormatCapitalHtml(nx_int(money_type), nx_int64(value))
end
function split_role_info(role_info)
  local info_tab = {}
  if nx_widestr(role_info) == nx_widestr("") then
    return info_tab
  end
  local temp_tab = nx_function("ext_split_wstring", nx_widestr(role_info), nx_widestr(","))
  if table.getn(temp_tab) < 24 then
    return info_tab
  end
  info_tab.Sex = temp_tab[1]
  info_tab.School = temp_tab[2]
  info_tab.Stand = temp_tab[3]
  info_tab.Character = temp_tab[4]
  info_tab.Favorite = temp_tab[5]
  local pre_len = string.len(nx_string(temp_tab[1])) + 1 + string.len(nx_string(temp_tab[2])) + 1 + string.len(nx_string(temp_tab[3])) + 1 + string.len(nx_string(temp_tab[4])) + 1 + string.len(nx_string(temp_tab[5])) + 1
  local face_len = string.find(nx_string(role_info), ",", pre_len + 44)
  info_tab.Face = nx_widestr(string.sub(nx_string(role_info), pre_len + 1, face_len - 1))
  local suf_str = string.sub(nx_string(role_info), face_len + 1)
  local suf_temp_tab = nx_function("ext_split_wstring", nx_widestr(suf_str), nx_widestr(","))
  if table.getn(suf_temp_tab) < 18 then
    return info_tab
  end
  info_tab.ShowEquipType = suf_temp_tab[1]
  info_tab.Hat = suf_temp_tab[2]
  info_tab.Mask = suf_temp_tab[3]
  info_tab.Cloth = suf_temp_tab[4]
  info_tab.Pants = suf_temp_tab[5]
  info_tab.Shoes = suf_temp_tab[6]
  info_tab.Weapon = suf_temp_tab[7]
  info_tab.Mantle = suf_temp_tab[8]
  info_tab.HatEffect = suf_temp_tab[9]
  info_tab.MaskEffect = suf_temp_tab[10]
  info_tab.ClothEffect = suf_temp_tab[11]
  info_tab.PantsEffect = suf_temp_tab[12]
  info_tab.ShoesEffect = suf_temp_tab[13]
  info_tab.WeaponEffect = suf_temp_tab[14]
  info_tab.MantleEffect = suf_temp_tab[15]
  info_tab.ActionSet = suf_temp_tab[16]
  info_tab.Address = suf_temp_tab[17]
  info_tab.LevelTitle = suf_temp_tab[18]
  if nx_int(info_tab.Sex) == 0 then
    info_tab.BodyType = nx_widestr("2")
  else
    info_tab.BodyType = nx_widestr("1")
  end
  info_tab.FaceType = nx_widestr("0")
  if table.getn(suf_temp_tab) >= 31 and suf_temp_tab[31] ~= nx_widestr("") then
    info_tab.BodyType = suf_temp_tab[31]
  end
  if table.getn(suf_temp_tab) >= 32 and suf_temp_tab[32] ~= nx_widestr("") then
    info_tab.FaceType = suf_temp_tab[32]
  end
  return info_tab
end
function create_role_model_by_role_info(scene_ctrl, role_info, x, y, z, o)
  if not nx_is_valid(scene_ctrl) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return 0
  end
  if nx_find_custom(scene_ctrl, "Actor2") and nx_is_valid(scene_ctrl.Actor2) then
    ui_ClearModel(scene_ctrl)
  end
  if not nx_is_valid(scene_ctrl.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", scene_ctrl)
  end
  local info_tab = split_role_info(role_info)
  scene_ctrl.Actor2 = create_role_composite(scene_ctrl.Scene, true, nx_number(info_tab.Sex), nil, nx_number(info_tab.BodyType))
  if not nx_is_valid(scene_ctrl.Actor2) then
    return 0
  end
  game_visual:CreateRoleUserData(scene_ctrl.Actor2)
  scene_ctrl.Actor2.sex = nx_string(info_tab.Sex)
  scene_ctrl.Actor2.school = nx_string(info_tab.School)
  scene_ctrl.Actor2.stand = nx_string(info_tab.Stand)
  scene_ctrl.Actor2.character = nx_string(info_tab.Character)
  scene_ctrl.Actor2.favorite = nx_string(info_tab.Favorite)
  scene_ctrl.Actor2.face = nx_string(info_tab.Face)
  scene_ctrl.Actor2.impress = nx_string(info_tab.ShowEquipType)
  scene_ctrl.Actor2.hat = nx_string(info_tab.Hat)
  scene_ctrl.Actor2.mask = nx_string(info_tab.Mask)
  scene_ctrl.Actor2.cloth = nx_string(info_tab.Cloth)
  scene_ctrl.Actor2.pants = nx_string(info_tab.Pants)
  scene_ctrl.Actor2.shoes = nx_string(info_tab.Shoes)
  scene_ctrl.Actor2.weapon = nx_string(info_tab.Weapon)
  scene_ctrl.Actor2.mantle = nx_string(info_tab.Mantle)
  scene_ctrl.Actor2.hateffect = nx_string(info_tab.HatEffect)
  scene_ctrl.Actor2.maskeffect = nx_string(info_tab.MaskEffect)
  scene_ctrl.Actor2.clotheffect = nx_string(info_tab.ClothEffect)
  scene_ctrl.Actor2.pantseffect = nx_string(info_tab.PantsEffect)
  scene_ctrl.Actor2.shoeseffect = nx_string(info_tab.ShoesEffect)
  scene_ctrl.Actor2.weaponeffect = nx_string(info_tab.WeaponEffect)
  scene_ctrl.Actor2.mantleeffect = nx_string(info_tab.MantleEffect)
  scene_ctrl.Actor2.bodytype = nx_string(info_tab.BodyType)
  scene_ctrl.Actor2.facetype = nx_string(info_tab.FaceType)
  game_visual:SetRoleActionSet(scene_ctrl.Actor2, nx_string(info_tab.ActionSet))
  composite_role_model(scene_ctrl.Scene, scene_ctrl.Actor2)
  util_add_model_to_scenebox(scene_ctrl, scene_ctrl.Actor2)
  local camera = scene_ctrl.Scene.camera
  if nx_is_valid(camera) then
    camera:SetAngle(0, o, 0)
    camera:SetPosition(x, y, z)
  end
  return 1
end
function composite_role_model(scene, actor2)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return false
  end
  if not nx_is_valid(actor2) then
    return false
  end
  local actor_role = get_actor_role(actor2)
  if not nx_is_valid(actor_role) then
    return false
  end
  while nx_is_valid(scene) and nx_is_valid(actor_role) and not actor_role.LoadFinish do
    nx_pause(0.5)
  end
  if not nx_is_valid(actor2) then
    return false
  end
  local face_actor2 = get_role_faceEx(actor2)
  while nx_is_valid(face_actor2) and not face_actor2.LoadFinish do
    nx_pause(0.5)
  end
  if nx_is_valid(face_actor2) then
    if nx_int(actor2.facetype) > nx_int(0) then
      role_composite:LinkFaceSkin(face_actor2, nx_int(actor2.sex), nx_int(actor2.facetype), false)
    else
      role_composite:SetPlayerFaceDetial(face_actor2, nx_string(actor2.face), nx_int(actor2.sex), actor2)
    end
  end
  local skin_info = {
    [1] = {link_name = "face", model_name = ""},
    [2] = {
      link_name = "impress",
      model_name = actor2.impress
    },
    [3] = {
      link_name = "mask",
      model_name = actor2.mask
    },
    [4] = {
      link_name = "hat",
      model_name = actor2.hat
    },
    [5] = {
      link_name = "cloth",
      model_name = actor2.cloth
    },
    [6] = {
      link_name = "pants",
      model_name = actor2.pants
    },
    [7] = {
      link_name = "shoes",
      model_name = actor2.shoes
    },
    [8] = {
      link_name = "mantle",
      model_name = actor2.mantle
    }
  }
  local effect_info = {
    [1] = {
      link_name = "WeaponEffect",
      model_name = actor2.weaponeffect
    },
    [2] = {
      link_name = "MaskEffect",
      model_name = actor2.maskeffect
    },
    [3] = {
      link_name = "HatEffect",
      model_name = actor2.hateffect
    },
    [4] = {
      link_name = "ClothEffect",
      model_name = actor2.clotheffect
    },
    [5] = {
      link_name = "PantsEffect",
      model_name = actor2.pantseffect
    },
    [6] = {
      link_name = "ShoesEffect",
      model_name = actor2.shoeseffect
    },
    [7] = {
      link_name = "MantleEffect",
      model_name = actor2.mantleeffect
    }
  }
  nx_execute("role_composite", "unlink_skin", actor2, "Hat")
  for i, info in pairs(skin_info) do
    if info.model_name ~= nil and 0 < string.len(nx_string(info.model_name)) then
      if "Cloth" == info.link_name or "cloth" == info.link_name then
        role_composite:LinkClothSkin(actor2, info.model_name)
      else
        role_composite:LinkSkin(actor2, info.link_name, info.model_name .. ".xmod", false)
      end
    end
  end
  if nx_int(1) == nx_int(actor2.impress) then
    link_skin(actor2, "cloth_h", nx_string(nx_string(actor2.cloth) .. "_h" .. ".xmod"))
  end
  for i, info in pairs(effect_info) do
    if model_name ~= nil and model_name ~= null then
      role_composite:LinkEffect(actor2, info.link_name, info.model_name)
    end
  end
  if actor2.weapon ~= "" then
    game_visual:SetRoleWeaponName(actor2, actor2.weapon)
    role_composite:RefreshWeapon(actor2)
  end
  if not nx_is_valid(actor2) or not nx_is_valid(scene) then
    return false
  end
  while nx_is_valid(scene) and nx_is_valid(actor2) and not actor2.LoadFinish do
    nx_pause(0.1)
  end
  return true
end
function create_ctrl(ctrl_name)
  local gui = nx_value("gui")
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  return ctrl
end
function create_ctrl_ex(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  return ctrl
end
function request_open_confirm_date()
  custom_marry(CLIENT_MSG_SUB_MARRY_SHOW_DATE)
end
function request_open_collect()
  custom_marry(CLIENT_MSG_SUB_MARRY_SHOW_COLLECT)
end
function request_partner_info()
  custom_marry(CLIENT_MSG_SUB_MARRY_PARTNER_INFO)
end
function request_set_show_partner_name(flag)
  custom_marry(CLIENT_MSG_SUB_MARRY_SHOW_PARTNER_NAME, nx_int(flag))
end
function request_wish_cost()
  custom_marry(CLIENT_MSG_SUB_WISH_COST_RANK)
end
function request_use_gift(gift_id)
  custom_marry(CLIENT_MSG_SUB_MARRY_USE_GIFT, gift_id)
end
function get_player_prop(prop_name)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if not client_player:FindProp(nx_string(prop_name)) then
    return ""
  end
  return client_player:QueryProp(nx_string(prop_name))
end
function show_form_by_scene()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return 0
  end
  local wedding_rite = client_scene:QueryProp("WeddingRite")
  local wedding_proc = client_scene:QueryProp("WeddingProc")
  local status = get_player_prop("MarryStatus")
  local is_show_zhufu = nx_number(wedding_proc) == 1
  if 0 >= nx_number(wedding_rite) then
    is_show_zhufu = false
  end
  nx_execute(FORM_MARRY_BTNS, "show_data", MARRY_BTN_ZHUFU, is_show_zhufu)
  nx_execute(FORM_MARRY_BTNS, "show_data", MARRY_BTN_LABA, nx_number(wedding_proc) == 1)
  local form_trace = nx_value(FORM_MARRY_TRACE)
  if not nx_is_valid(form_trace) and nx_number(status) >= MARRY_STATUS_WEDDING and nx_number(status) < MARRY_STATUS_MARRIED then
    custom_marry(CLIENT_MSG_SUB_MARRY_GET_FLOW_INFO)
  end
end
function show_marry_form(sub_msg_type, ...)
  local form_name = ""
  if sub_msg_type == SERVER_MSG_SUB_MARRY_COLLECT then
    form_name = FORM_MARRY_COLLECT
  elseif sub_msg_type == SERVER_MSG_SUB_MARRY_REQUEST then
    form_name = FORM_MARRY_REQUEST
  elseif sub_msg_type == SERVER_MSG_SUB_MARRY_CANCEL then
    form_name = FORM_MARRY_CANCEL
  elseif sub_msg_type == SERVER_MSG_SUB_MARRY_RESPONSE then
    form_name = FORM_MARRY_RESPONSE
  elseif sub_msg_type == SERVER_MSG_SUB_MARRY_CONFIRMDATE then
    form_name = FORM_MARRY_CONFIRMDATE
  elseif sub_msg_type == SERVER_MSG_SUB_MARRY_DINNER then
    form_name = FORM_MARRY_DINNER
  elseif sub_msg_type == SERVER_MSG_SUB_MARRY_DIVORCE then
    form_name = FORM_MARRY_DIVORCE
  elseif sub_msg_type == SERVER_MSG_SUB_MARRY_FLOWTRACE then
    form_name = FORM_MARRY_TRACE
  elseif sub_msg_type == SERVER_MSG_SUM_MARRY_HAVED_COLLECT then
    nx_execute(FORM_MARRY_COLLECT, "update_give_up_btn", unpack(arg))
    return 0
  elseif sub_msg_type == SERVER_MSG_SUB_MARRY_PARTNER_INFO then
    nx_execute("form_stage_main\\form_marry\\form_marry_sns", "show_partner_info", unpack(arg))
    return 0
  elseif sub_msg_type == SERVER_MSG_SUB_WINE_DESK then
    form_name = FORM_MARRY_DESK
  elseif sub_msg_type == SERVER_MSG_SUB_WISH_COST_RANK then
    nx_execute(FORM_MARRY_GIFT, "Refresh_WishCostRank", unpack(arg))
    return 0
  end
  if form_name ~= "" then
    nx_execute(form_name, "show_data", unpack(arg))
  end
end
