require("share\\client_custom_define")
require("util_functions")
require("util_gui")
require("share\\view_define")
local MENU_TYPE_NONE = 0
local MENU_TYPE_INTER = 1
local MENU_TYPE_GATHER = 2
local MENU_TYPE_TOOLBOX = 3
local MENU_TYPE_WEAPONHANGER = 4
local MENU_TYPE_CLOTHESHANGER = 5
local MENU_TYPE_HOMEPET = 6
local MENU_TYPE_WUXUE = 7
local MENU_TYPE_SAVEFURN = 8
local MENU_TYPE_CLOTHESRACK = 9
local MENU_TYPE_EMPLOYEE = 10
local MENU_TYPE_WEAPONRACK = 11
local MENU_TYPE_CLOTHESPRESS = 12
local MENU_TYPE_SHARE_FURN = 13
local MENU_TYPE_COMMON = 777
local IFT_CUSHION = 0
local IFT_BATH = 1
local IFT_BED = 2
local IFT_LIGHT = 3
local IFT_BROOM = 4
local IFT_CHAIR = 5
local IFT_BANQUET = 6
local IFT_SHAREFURN_BED = 7
local IFT_SHAREFURN_BATH = 8
local IFT_SHAREFURN_COUCH = 9
local HOME_GATHER = 10
local HOME_TOOLBOX = 11
local HOME_WEAPONHANGER = 12
local HOME_CLOTHESHANGER = 13
local HOME_PET = 14
local HOME_WUXUE = 15
local HOME_SAVEFURN = 16
local HOME_CLOTHESRACK = 17
local HOME_EMPLOYEE_STAY = 18
local HOME_EMPLOYEE_GUARD = 19
local HOME_EMPLOYEE_GRIL = 20
local HOME_WEAPONRACK = 21
local HOME_CLOTHESPRESS = 22
local IFT_OUTDOOR_STOOL = 23
local IFT_OUTDOOR_TABLE = 24
local IFT_LIGHT_CHAIR = 25
local IFT_EXTAND_BEGIN = 26
local IFT_SHAREFURN_JIGUANREN = 27
local IFT_EXTAND_END = 50
local HOME_COMMON = 777
local CLIENT_FURNITURE_OPEN_SAVEFURN = 15
local CLIENT_FURNITURE_OPEN_CLOTHES_RACK = 16
local CLIENT_FURNITURE_OPEN_RECOVER_EQUIP_FORM = 23
local CLIENT_FURNITURE_LINK_SHARE_FURN = 32
local MAX_BTN_COUNT = 6
local FORM_NAME = "form_stage_main\\form_home\\form_home_button"
local HOME_FUNC_NPC_TYPE_STAY = 1
local HOME_FUNC_NPC_TYPE_GUARD = 2
local HOME_FUNC_NPC_TYPE_GRIL = 3
local menu_item = {
  [IFT_CUSHION] = {
    "inter_furn_type0"
  },
  [IFT_BATH] = {
    "inter_furn_type1"
  },
  [IFT_BED] = {
    "inter_furn_type2"
  },
  [IFT_LIGHT] = {
    "inter_furn_type3"
  },
  [IFT_BROOM] = {
    "inter_furn_type4"
  },
  [IFT_CHAIR] = {
    "inter_furn_type5"
  },
  [IFT_BANQUET] = {
    "inter_furn_type6"
  },
  [IFT_SHAREFURN_BED] = {
    "inter_furn_type2"
  },
  [IFT_SHAREFURN_BATH] = {
    "inter_futn_type1_1"
  },
  [IFT_SHAREFURN_COUCH] = {
    "inter_furn_type2_1"
  },
  [HOME_GATHER] = {
    "inter_furn_type10"
  },
  [HOME_TOOLBOX] = {
    "inter_furn_type11_2"
  },
  [HOME_WEAPONHANGER] = {
    "inter_furn_type12"
  },
  [HOME_CLOTHESHANGER] = {
    "inter_furn_type13"
  },
  [HOME_PET] = {
    "inter_furn_type14"
  },
  [HOME_WUXUE] = {
    "inter_furn_type15_2",
    "ui_hone_wuxuexl_27"
  },
  [HOME_SAVEFURN] = {
    "inter_furn_type16"
  },
  [HOME_CLOTHESRACK] = {
    "inter_furn_type13"
  },
  [HOME_EMPLOYEE_STAY] = {
    "ui_home_fire"
  },
  [HOME_EMPLOYEE_GUARD] = {
    "inter_furn_type_depot",
    "inter_furn_type6_1",
    "inter_furn_type6_2",
    "ui_jiayuan_zbxf",
    "ui_home_fire"
  },
  [HOME_EMPLOYEE_GRIL] = {
    "ui_home_setca",
    "ui_home_fire"
  },
  [HOME_COMMON] = {
    "ui_home_back"
  },
  [HOME_WEAPONRACK] = {
    "inter_furn_type12"
  },
  [HOME_CLOTHESPRESS] = {
    "inter_furn_type13"
  },
  [IFT_OUTDOOR_STOOL] = {
    "inter_furn_type23"
  },
  [IFT_OUTDOOR_TABLE] = {
    "inter_furn_type24"
  },
  [IFT_LIGHT_CHAIR] = {
    "inter_furn_type3",
    "inter_furn_type5"
  },
  [IFT_EXTAND_BEGIN] = {
    "inter_furn_type26"
  },
  [IFT_SHAREFURN_JIGUANREN] = {
    "inter_furn_type27"
  }
}
function on_main_form_init(self)
  self.Fixed = true
  return 1
end
function on_main_form_open(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function menu_1_click(menu)
  local form = menu.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  if not nx_find_custom(form, "op_type") then
    return
  end
  local op_type = form.op_type
  if nx_number(op_type) >= nx_number(IFT_CUSHION) and nx_number(op_type) <= nx_number(IFT_BANQUET) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), 4)
  elseif nx_number(op_type) == nx_number(HOME_GATHER) then
    if nx_find_custom(form, "op_obj") then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), 9, nx_object(form.op_obj))
    end
  elseif nx_number(op_type) == nx_number(HOME_TOOLBOX) then
    nx_execute("custom_sender", "send_home_depot_msg", 54, 1)
  elseif nx_number(op_type) == nx_number(HOME_WEAPONHANGER) then
    local form_weapon_hanger = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_home\\form_weapon_hanger", true)
    if nx_is_valid(form_weapon_hanger) then
      form_weapon_hanger:Show()
      form_weapon_hanger.Visible = true
      local gui = nx_value("gui")
      if nx_is_valid(gui) then
        gui.Desktop:ToFront(form_weapon_hanger)
      end
    end
    nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
  elseif nx_number(op_type) == nx_number(HOME_CLOTHESHANGER) then
    local form_clothes_hanger = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_home\\form_clothes_hanger", true)
    if nx_is_valid(form_clothes_hanger) then
      form_clothes_hanger:Show()
      form_clothes_hanger.Visible = true
      local gui = nx_value("gui")
      if nx_is_valid(gui) then
        gui.Desktop:ToFront(form_clothes_hanger)
      end
    end
    nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
  elseif nx_number(op_type) == nx_number(HOME_PET) then
  elseif nx_number(op_type) == nx_number(HOME_WUXUE) then
    if nx_find_custom(form, "op_obj") then
      local client_scene_obj = game_client:GetSceneObj(nx_string(form.op_obj))
      if nx_is_valid(client_scene_obj) then
        nx_execute("form_stage_main\\form_home\\form_home_wuxue", "open_form", client_scene_obj, 2)
      end
    end
  elseif nx_number(op_type) == nx_number(HOME_SAVEFURN) then
    if nx_find_custom(form, "op_obj") then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), CLIENT_FURNITURE_OPEN_SAVEFURN, nx_object(form.op_obj))
    end
  elseif nx_number(op_type) == nx_number(HOME_CLOTHESRACK) then
    if nx_find_custom(form, "op_obj") then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), CLIENT_FURNITURE_OPEN_CLOTHES_RACK, nx_object(form.op_obj))
    end
  elseif nx_number(op_type) == nx_number(HOME_EMPLOYEE_STAY) then
    if nx_find_custom(form, "op_obj") then
      local client_scene_obj = game_client:GetSceneObj(nx_string(form.op_obj))
      if nx_is_valid(client_scene_obj) then
        nx_execute("form_stage_main\\form_home\\form_home_myhome", "fire_home_npc", client_scene_obj)
      end
    end
  elseif nx_number(op_type) == nx_number(HOME_EMPLOYEE_GUARD) then
    if nx_find_custom(form, "op_obj") then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_DEPOT_MSG), 7, nx_object(form.op_obj))
    end
  elseif nx_number(op_type) == nx_number(HOME_EMPLOYEE_GRIL) then
    if nx_find_custom(form, "op_obj") then
      local client_scene_obj = game_client:GetSceneObj(nx_string(form.op_obj))
      if nx_is_valid(client_scene_obj) then
        nx_execute("form_stage_main\\form_home\\form_home_set_ca", "open_form", client_scene_obj)
      end
    end
  elseif nx_number(op_type) == nx_number(HOME_COMMON) then
    if nx_find_custom(form, "op_obj") then
      local client_scene_obj = game_client:GetSceneObj(nx_string(form.op_obj))
      if nx_is_valid(client_scene_obj) then
        nx_execute("form_stage_main\\form_home\\form_home_myhome", "back_furniture", client_scene_obj)
      end
    end
  elseif nx_number(op_type) == nx_number(HOME_WEAPONRACK) then
    local SUBMSG_REQ_OPEN_WEAPON_RACK = 26
    if nx_find_custom(form, "op_obj") then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), SUBMSG_REQ_OPEN_WEAPON_RACK, nx_object(form.op_obj))
    end
  elseif nx_number(op_type) == nx_number(HOME_CLOTHESPRESS) then
    local SUBMSG_REQ_OPEN_CLOTHESPRESS = 29
    if nx_find_custom(form, "op_obj") then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), SUBMSG_REQ_OPEN_CLOTHESPRESS, nx_object(form.op_obj))
    end
  elseif nx_number(op_type) == nx_number(IFT_SHAREFURN_BED) or nx_number(op_type) == nx_number(IFT_SHAREFURN_BATH) or nx_number(op_type) == nx_number(IFT_SHAREFURN_COUCH) or nx_number(op_type) == nx_number(IFT_OUTDOOR_STOOL) or nx_number(op_type) == nx_number(IFT_OUTDOOR_TABLE) or nx_number(op_type) == nx_number(IFT_EXTAND_BEGIN) or nx_number(op_type) == nx_number(IFT_SHAREFURN_JIGUANREN) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), nx_int(CLIENT_FURNITURE_LINK_SHARE_FURN))
  elseif nx_number(op_type) == nx_number(IFT_LIGHT_CHAIR) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), 4, 0)
  end
  form:Close()
end
function menu_2_click(menu)
  local form = menu.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  if not nx_find_custom(form, "op_type") then
    return
  end
  local op_type = form.op_type
  if nx_number(op_type) == nx_number(HOME_WUXUE) then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return
    end
    local tips_str = util_text("ui_hone_wuxuexl_28")
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(tips_str))
    dialog:ShowModal()
    local gui = nx_value("gui")
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" and nx_is_valid(form) and nx_find_custom(form, "op_obj") then
      local client_scene_obj = game_client:GetSceneObj(nx_string(form.op_obj))
      if nx_is_valid(client_scene_obj) then
        nx_execute("form_stage_main\\form_home\\form_home_myhome", "back_furniture", client_scene_obj)
      end
    end
  elseif nx_number(op_type) == nx_number(HOME_EMPLOYEE_GUARD) then
    if nx_find_custom(form, "op_obj") then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), 14, nx_object(form.op_obj))
    end
  elseif nx_number(op_type) == nx_number(HOME_EMPLOYEE_GRIL) then
    if nx_find_custom(form, "op_obj") then
      local client_scene_obj = game_client:GetSceneObj(nx_string(form.op_obj))
      if nx_is_valid(client_scene_obj) then
        nx_execute("form_stage_main\\form_home\\form_home_myhome", "fire_home_npc", client_scene_obj)
      end
    end
  elseif nx_number(op_type) == nx_number(IFT_LIGHT_CHAIR) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), 4, 1)
  end
  form:Close()
end
function menu_3_click(menu)
  local form = menu.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  if not nx_find_custom(form, "op_type") then
    return
  end
  local op_type = form.op_type
  if nx_number(op_type) == nx_number(HOME_TOOLBOX) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), 10, 2)
  elseif nx_number(op_type) == nx_number(HOME_EMPLOYEE_GUARD) and nx_find_custom(form, "op_obj") then
    local client_scene_obj = game_client:GetSceneObj(nx_string(form.op_obj))
    if nx_is_valid(client_scene_obj) and client_scene_obj:FindProp("Job") then
      local job_id = client_scene_obj:QueryProp("Job")
      nx_execute("custom_sender", "custom_lifeskill_split_item", nx_string(job_id))
    end
  end
  if nx_is_valid(form) then
    form:Close()
  end
end
function menu_4_click(menu)
  local form = menu.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  if not nx_find_custom(form, "op_type") then
    return
  end
  local op_type = form.op_type
  if nx_number(op_type) == nx_number(HOME_EMPLOYEE_GUARD) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), CLIENT_FURNITURE_OPEN_RECOVER_EQUIP_FORM)
  end
  form:Close()
  return
end
function menu_5_click(menu)
  local form = menu.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  if not nx_find_custom(form, "op_type") then
    return
  end
  local op_type = form.op_type
  if nx_number(op_type) == nx_number(HOME_EMPLOYEE_GUARD) and nx_find_custom(form, "op_obj") then
    local client_scene_obj = game_client:GetSceneObj(nx_string(form.op_obj))
    if nx_is_valid(client_scene_obj) then
      nx_execute("form_stage_main\\form_home\\form_home_myhome", "fire_home_npc", client_scene_obj)
    end
  end
  form:Close()
  return
end
function show_form(...)
  if table.getn(arg) < 1 then
    return
  end
  local form_interaction_menu = nx_execute("util_gui", "util_auto_show_hide_form", FORM_NAME)
  if not nx_is_valid(form_interaction_menu) then
    return
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  form_interaction_menu.AbsLeft = x
  form_interaction_menu.AbsTop = y
  reset_item_btn(form_interaction_menu)
  local inter_furn_type = nx_number(arg[1])
  local menudata = menu_item[inter_furn_type]
  if menudata == nil then
    return
  end
  local menucnt = table.getn(menudata)
  if menucnt == 0 then
    return
  end
  for i = 1, menucnt do
    local item_btn = form_interaction_menu.groupbox_1:Find("btn_" .. nx_string(i))
    if nx_is_valid(item_btn) then
      local menutext = gui.TextManager:GetText(menudata[i])
      if i == 1 and (nx_number(inter_furn_type) == 3 or nx_number(inter_furn_type) == 25) then
        local light_state = 0
        if table.getn(arg) >= 2 then
          light_state = nx_number(arg[2])
        end
        menutext = gui.TextManager:GetText(nx_string("inter_furn_type") .. "_" .. nx_string(light_state))
      end
      item_btn.Text = nx_widestr(menutext)
      item_btn.Visible = true
    end
  end
  form_interaction_menu.Height = 58 + 40 * nx_number(menucnt)
  form_interaction_menu.op_type = inter_furn_type
  if nx_number(inter_furn_type) == nx_number(HOME_GATHER) or nx_number(inter_furn_type) == nx_number(HOME_TOOLBOX) or nx_number(inter_furn_type) == nx_number(HOME_PET) or nx_number(inter_furn_type) == nx_number(HOME_WUXUE) or nx_number(inter_furn_type) == nx_number(HOME_SAVEFURN) or nx_number(inter_furn_type) == nx_number(HOME_EMPLOYEE_STAY) or nx_number(inter_furn_type) == nx_number(HOME_EMPLOYEE_GUARD) or nx_number(inter_furn_type) == nx_number(HOME_EMPLOYEE_GRIL) or nx_number(inter_furn_type) == nx_number(HOME_COMMON) then
    form_interaction_menu.op_obj = arg[2]
  end
  if nx_number(inter_furn_type) == nx_number(HOME_CLOTHESRACK) then
    form_interaction_menu.op_obj = arg[2]
  end
  if nx_number(inter_furn_type) == nx_number(HOME_WEAPONRACK) then
    form_interaction_menu.op_obj = arg[2]
  end
  if nx_number(inter_furn_type) == nx_number(HOME_CLOTHESPRESS) then
    form_interaction_menu.op_obj = arg[2]
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    gui.Desktop:ToFront(form_interaction_menu)
  end
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function mouse_right_up(client_ident)
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  local menu_type = show_menu_type(client_ident)
  if nx_number(menu_type) == nx_number(MENU_TYPE_NONE) then
    return
  end
  if HomeManager:IsMyHome() then
    local form_home_enter = util_get_form("form_stage_main\\form_home\\form_home_enter", false)
    if nx_is_valid(form_home_enter) and form_home_enter.Visible and form_home_enter.groupbox_op.Visible then
      if nx_number(menu_type) == nx_number(MENU_TYPE_WUXUE) then
        return
      end
      menu_type = MENU_TYPE_COMMON
    end
  elseif HomeManager:IsPartnerHome() then
    if nx_number(menu_type) == nx_number(MENU_TYPE_WUXUE) or nx_number(menu_type) == nx_number(MENU_TYPE_CLOTHESRACK) or nx_number(menu_type) == nx_number(MENU_TYPE_WEAPONRACK) or nx_number(menu_type) == nx_number(MENU_TYPE_SAVEFURN) or nx_number(menu_type) == nx_number(MENU_TYPE_CLOTHESPRESS) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("home_guyong_12"))
      return
    end
    local form_home_enter = util_get_form("form_stage_main\\form_home\\form_home_enter", false)
    if nx_is_valid(form_home_enter) and form_home_enter.Visible and form_home_enter.groupbox_op.Visible then
      menu_type = MENU_TYPE_COMMON
    end
  elseif nx_number(menu_type) ~= nx_number(MENU_TYPE_INTER) and nx_number(menu_type) ~= nx_number(MENU_TYPE_WUXUE) and nx_number(menu_type) ~= nx_number(MENU_TYPE_TOOLBOX) and nx_number(menu_type) ~= nx_number(MENU_TYPE_SHARE_FURN) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene_obj = game_client:GetSceneObj(client_ident)
  if not nx_is_valid(client_scene_obj) then
    return
  end
  if nx_number(menu_type) == nx_number(MENU_TYPE_INTER) or nx_number(menu_type) == nx_number(MENU_TYPE_WEAPONHANGER) or nx_number(menu_type) == nx_number(MENU_TYPE_CLOTHESHANGER) or nx_number(menu_type) == nx_number(MENU_TYPE_SHARE_FURN) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), 8, nx_object(client_ident))
  elseif nx_number(menu_type) == nx_number(MENU_TYPE_GATHER) then
    show_form(HOME_GATHER, client_ident)
  elseif nx_number(menu_type) == nx_number(MENU_TYPE_TOOLBOX) then
    show_form(HOME_TOOLBOX, client_ident)
  elseif nx_number(menu_type) == nx_number(MENU_TYPE_HOMEPET) then
    show_form(HOME_PET, client_ident)
  elseif nx_number(menu_type) == nx_number(MENU_TYPE_WUXUE) then
    if is_exist_back_item() then
      nx_execute("form_stage_main\\form_home\\form_home_wuxue_shoulu", "show_form")
    else
      show_form(HOME_WUXUE, client_ident)
    end
  elseif nx_number(menu_type) == nx_number(MENU_TYPE_SAVEFURN) then
    show_form(HOME_SAVEFURN, client_ident)
  elseif nx_number(menu_type) == nx_number(MENU_TYPE_CLOTHESRACK) then
    show_form(HOME_CLOTHESRACK, client_ident)
  elseif nx_number(menu_type) == nx_number(MENU_TYPE_EMPLOYEE) then
    local home_func_npc_type = client_scene_obj:QueryProp("HomeFuncNpcType")
    if nx_number(home_func_npc_type) == nx_number(HOME_FUNC_NPC_TYPE_STAY) then
      show_form(HOME_EMPLOYEE_STAY, client_ident)
    elseif nx_number(home_func_npc_type) == nx_number(HOME_FUNC_NPC_TYPE_GUARD) then
      show_form(HOME_EMPLOYEE_GUARD, client_ident)
    elseif nx_number(home_func_npc_type) == nx_number(HOME_FUNC_NPC_TYPE_GRIL) then
      show_form(HOME_EMPLOYEE_GRIL, client_ident)
    end
  elseif nx_number(menu_type) == nx_number(MENU_TYPE_COMMON) then
    if can_show_common_menu(client_scene_obj) then
      show_form(HOME_COMMON, client_ident)
    end
  elseif nx_number(menu_type) == nx_number(MENU_TYPE_WEAPONRACK) then
    show_form(HOME_WEAPONRACK, client_ident)
  elseif nx_number(menu_type) == nx_number(MENU_TYPE_CLOTHESPRESS) then
    show_form(HOME_CLOTHESPRESS, client_ident)
  end
end
function can_show_common_menu(client_obj)
  if not nx_is_valid(client_obj) then
    return false
  end
  if not client_obj:FindProp("ConfigID") then
    return false
  end
  local config_id = client_obj:QueryProp("ConfigID")
  local ItemsQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemsQuery) then
    return false
  end
  local script = ItemsQuery:GetItemPropByConfigID(config_id, "script")
  if nx_string(script) == nx_string("HomeToolBoxNpc") then
    return false
  elseif nx_string(script) == nx_string("InterFurnNpc") and client_obj:FindProp("InterFurnType") and nx_number(client_obj:QueryProp("InterFurnType")) == nx_number(IFT_BANQUET) then
    return false
  end
  return true
end
function show_menu_type(client_ident)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return MENU_TYPE_NONE
  end
  local client_scene_obj = game_client:GetSceneObj(client_ident)
  if not nx_is_valid(client_scene_obj) then
    return MENU_TYPE_NONE
  end
  if not client_scene_obj:FindProp("ConfigID") then
    return MENU_TYPE_NONE
  end
  local config_id = client_scene_obj:QueryProp("ConfigID")
  local ItemsQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemsQuery) then
    return MENU_TYPE_NONE
  end
  local script = ItemsQuery:GetItemPropByConfigID(config_id, "script")
  if nx_string(script) == nx_string("InterFurnNpc") then
    return MENU_TYPE_INTER
  elseif nx_string(script) == nx_string("HomeGatherNpc") then
    return MENU_TYPE_GATHER
  elseif nx_string(script) == nx_string("HomeToolBoxNpc") then
    return MENU_TYPE_TOOLBOX
  elseif nx_string(script) == nx_string("WeaponHangerNpc") then
    return MENU_TYPE_WEAPONHANGER
  elseif nx_string(script) == nx_string("ClothesHangerNpc") then
    return MENU_TYPE_CLOTHESHANGER
  elseif nx_string(script) == nx_string("FurniturePetNpc") then
    return MENU_TYPE_HOMEPET
  elseif nx_string(script) == nx_string("HomeWuXueNpc") then
    return MENU_TYPE_WUXUE
  elseif nx_string(script) == nx_string("SaveFurnNpc") then
    return MENU_TYPE_SAVEFURN
  elseif nx_string(script) == nx_string("ClothesRackNpc") then
    return MENU_TYPE_CLOTHESRACK
  elseif nx_string(script) == nx_string("HomeFuncNpc") then
    return MENU_TYPE_EMPLOYEE
  elseif nx_string(script) == nx_string("WeaponRackNpc") then
    return MENU_TYPE_WEAPONRACK
  elseif nx_string(script) == nx_string("ClothespressNpc") then
    return MENU_TYPE_CLOTHESPRESS
  elseif nx_string(script) == nx_string("ShareFurnitureNpc") then
    return MENU_TYPE_SHARE_FURN
  end
  return MENU_TYPE_NONE
end
function reset_item_btn(form)
  for i = 1, MAX_BTN_COUNT do
    local item_btn = form.groupbox_1:Find("btn_" .. nx_string(i))
    if nx_is_valid(item_btn) then
      item_btn.Visible = false
    end
  end
end
function is_exist_back_item()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local toolbox = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(toolbox) then
    return false
  end
  local wuxue_back_item_id = "home_wuxuexl_101"
  local toolbox_objlist = toolbox:GetViewObjList()
  for j, obj in pairs(toolbox_objlist) do
    local config_id = obj:QueryProp("ConfigID")
    if nx_string(config_id) == nx_string(wuxue_back_item_id) then
      return true
    end
  end
  return false
end
