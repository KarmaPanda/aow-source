require("define\\shortcut_key_define")
require("control_set")
local KEYTYPE_BASEKEY = 1
local KEYTYPE_FUNCKEY = 2
local KEYTYPE_GRIDKEY = 3
local KEYTYPE_CHATKEY = 4
local KEYTYPE_TARGETKEY = 5
local KEYTYPE_CAMERAKEY = 6
local KEYTYPE_OTHERKEY = 7
local BASE_KEYS = {
  [Key_Role_MoveForward] = {
    Key_Role_MoveForward,
    "ui_MoveForward"
  },
  [Key_Role_MoveBackward] = {
    Key_Role_MoveBackward,
    "ui_MoveBackward"
  },
  [Key_Role_MoveLeft] = {
    Key_Role_MoveLeft,
    "ui_MoveLeft"
  },
  [Key_Role_MoveRight] = {
    Key_Role_MoveRight,
    "ui_MoveRight"
  },
  [Key_Role_OrientLeft] = {
    Key_Role_OrientLeft,
    "ui_RoleOrientLeft"
  },
  [Key_Role_OrientRight] = {
    Key_Role_OrientRight,
    "ui_RoleOrientRight"
  },
  [Key_Func_Camera_RotateLeft] = {
    Key_Func_Camera_RotateLeft,
    "ui_CameraRotateLeft"
  },
  [Key_Func_Camera_RotateRight] = {
    Key_Func_Camera_RotateRight,
    "ui_CameraRotateRight"
  },
  [Key_Camera_LookUp] = {
    Key_Camera_LookUp,
    "ui_CameraLookUp"
  },
  [Key_Camera_LookDown] = {
    Key_Camera_LookDown,
    "ui_CameraLookDown"
  },
  [Key_Role_Jump] = {Key_Role_Jump, "ui_Jump"},
  [Key_Role_Parry] = {Key_Role_Parry, "ui_parry"},
  [Key_QG_Active1] = {
    Key_QG_Active1,
    "ui_QGActive1"
  },
  [Key_QG_Active2] = {
    Key_QG_Active2,
    "ui_QGActive2"
  },
  [Key_Role_RideFall] = {
    Key_Role_RideFall,
    "ui_RideFall"
  },
  [Key_Sys_Config] = {
    Key_Sys_Config,
    "ui_SysConfig"
  },
  [Key_QG_Active3] = {
    Key_QG_Active3,
    "ui_QGActive3"
  },
  [Key_Role_SwitchWeapon] = {
    Key_Role_SwitchWeapon,
    "ui_RoleSwitchWeapon"
  },
  [Key_Go_AHead] = {
    Key_Go_AHead,
    "ui_RoleAhead"
  },
  [Key_Form_Role] = {
    Key_Form_Role,
    "ui_FormRole"
  },
  [Key_Form_DailyLivePoint] = {
    Key_Form_DailyLivePoint,
    "ui_DailyLivePoint"
  },
  [Key_Form_Bag] = {Key_Form_Bag, "ui_FormBag"},
  [Key_Form_Map] = {Key_Form_Map, "ui_FormMap"},
  [Key_Form_Friend] = {
    Key_Form_Friend,
    "ui_FormFriend"
  },
  [Key_Form_Offline] = {
    Key_Form_Offline,
    "ui_FormOffline"
  },
  [Key_Form_WuXue] = {
    Key_Form_WuXue,
    "ui_FormWuXue"
  },
  [Key_Form_Task] = {
    Key_Form_Task,
    "ui_FormTask"
  },
  [Key_Role_MoveType] = {
    Key_Role_MoveType,
    "ui_RoleMoveType"
  },
  [Key_Form_Home] = {
    Key_Form_Home,
    "ui_FormLuoJiaoDian"
  },
  [Key_Form_Origin] = {
    Key_Form_Origin,
    "ui_FormOrigin"
  },
  [Key_Form_Life] = {
    Key_Form_Life,
    "ui_FormLife"
  },
  [Key_Form_Team] = {
    Key_Form_Team,
    "ui_FormTeam"
  },
  [Key_Form_StallOption] = {
    Key_Form_StallOption,
    "ui_FormOnlineStall"
  },
  [key_Func_ChatInput] = {
    key_Func_ChatInput,
    "ui_ChatInput"
  },
  [Key_Func_ChatIncPage] = {
    Key_Func_ChatIncPage,
    "ui_ChatIncPage"
  },
  [Key_Func_ChatDecPage] = {
    Key_Func_ChatDecPage,
    "ui_ChatDecPage"
  },
  [Key_Func_SelectNpc] = {
    Key_Func_SelectNpc,
    "ui_SelectNpc"
  },
  [Key_Func_VideoOrScreen] = {
    Key_Func_VideoOrScreen,
    "ui_VideoOrScreen"
  },
  [Key_Func_SwitchGui] = {
    Key_Func_SwitchGui,
    "ui_SwitchGui"
  },
  [Key_Func_ZoomInMap] = {
    Key_Func_ZoomInMap,
    "ui_ZoomInMap"
  },
  [Key_Func_ZoomOutMap] = {
    Key_Func_ZoomOutMap,
    "ui_ZoomOutMap"
  },
  [Key_Camera_MoveBackward] = {
    Key_Camera_MoveBackward,
    "ui_CameraMoveBackward"
  },
  [Key_Camera_MoveForward] = {
    Key_Camera_MoveForward,
    "ui_CameraMoveForward"
  },
  [Key_Func_HideOther] = {
    Key_Func_HideOther,
    "ui_hideplayer"
  },
  [Key_Func_Music] = {Key_Func_Music, "ui_music"},
  [Key_Func_YinXiao] = {Key_Func_YinXiao, "ui_yinxiao"},
  [Key_Func_MusicInc] = {
    Key_Func_MusicInc,
    "ui_musicInc"
  },
  [Key_Func_MusicDec] = {
    Key_Func_MusicDec,
    "ui_musicDec"
  },
  [Key_Func_FightInfoIncPage] = {
    Key_Func_FightInfoIncPage,
    "ui_FightInfoIncPage"
  },
  [Key_Func_FightInfoDecPage] = {
    Key_Func_FightInfoDecPage,
    "ui_FightInfoDecPage"
  },
  [Key_Func_Market] = {Key_Func_Market, "ui_Trade"},
  [Key_Func_Battle] = {Key_Func_Battle, "ui_TVT"},
  [Key_Func_Guild] = {Key_Func_Guild, "ui_guild"},
  [Key_Func_School] = {
    Key_Func_School,
    "ui_guild_school"
  },
  [Key_Func_Shop] = {
    Key_Func_Shop,
    "ui_ChargeShop"
  },
  [Key_Switch_PKMode] = {
    Key_Switch_PKMode,
    "ui_Switch_PKMode"
  },
  [Key_Func_SKSet] = {Key_Func_SKSet, "ui_SKSet"},
  [Key_ProtectOther_PKMode] = {
    Key_ProtectOther_PKMode,
    "ui_ProtectOther_PKMode"
  },
  [Key_Func_HideNoAttackPlayer] = {
    Key_Func_HideNoAttackPlayer,
    "ui_HideNoAttackPlayer"
  },
  [Key_Func_MarrySns] = {
    Key_Func_MarrySns,
    "ui_yinyuan_jm"
  },
  [Key_Func_Sweet] = {
    Key_Func_Sweet,
    "ui_sweet_jm"
  },
  [Key_Form_Formula] = {
    Key_Form_Formula,
    "ui_newworld_home_formal_shortcut"
  },
  [Key_Form_Bonfire] = {
    Key_Form_Bonfire,
    "ui_newjianghu_func_gouhuo_shortcut"
  },
  [Key_Form_Explore] = {
    Key_Form_Explore,
    "ui_newjianghu_func_jianghutansuo_shortcut"
  },
  [Key_Form_Friend_List] = {
    Key_Form_Friend_List,
    "ui_tips_siliao_shortcut"
  },
  [Key_FuncKey_Tent] = {
    Key_FuncKey_Tent,
    "ui_newjianghu_func_yingzhang_shortcut"
  },
  [Key_MainShortcutGrid_IncPage] = {
    Key_MainShortcutGrid_IncPage,
    "ui_MainShortcutGrid_IncPage"
  },
  [Key_MainShortcutGrid_DecPage] = {
    Key_MainShortcutGrid_DecPage,
    "ui_MainShortcutGrid_DecPage"
  },
  [Key_MainShortcutGrid_Page1] = {
    Key_MainShortcutGrid_Page1,
    "ui_MainShortcutGrid_Page1"
  },
  [Key_MainShortcutGrid_Page2] = {
    Key_MainShortcutGrid_Page2,
    "ui_MainShortcutGrid_Page2"
  },
  [Key_MainShortcutGrid_Page3] = {
    Key_MainShortcutGrid_Page3,
    "ui_MainShortcutGrid_Page3"
  },
  [Key_MainShortcutGrid_Page4] = {
    Key_MainShortcutGrid_Page4,
    "ui_MainShortcutGrid_Page4"
  },
  [Key_MainShortcutGrid_Page5] = {
    Key_MainShortcutGrid_Page5,
    "ui_MainShortcutGrid_Page5"
  },
  [Key_MainShortcutGrid_Page6] = {
    Key_MainShortcutGrid_Page6,
    "ui_MainShortcutGrid_Page6"
  },
  [Key_MainShortcutGrid_Page7] = {
    Key_MainShortcutGrid_Page7,
    "ui_MainShortcutGrid_Page7"
  },
  [Key_MainShortcutGrid_Page8] = {
    Key_MainShortcutGrid_Page8,
    "ui_MainShortcutGrid_Page8"
  },
  [Key_MainShortcutGrid_Page9] = {
    Key_MainShortcutGrid_Page9,
    "ui_MainShortcutGrid_Page9"
  },
  [Key_MainShortcutGrid_Index1] = {
    Key_MainShortcutGrid_Index1,
    "ui_MainShortcutGrid_Index1"
  },
  [Key_MainShortcutGrid_Index2] = {
    Key_MainShortcutGrid_Index2,
    "ui_MainShortcutGrid_Index2"
  },
  [Key_MainShortcutGrid_Index3] = {
    Key_MainShortcutGrid_Index3,
    "ui_MainShortcutGrid_Index3"
  },
  [Key_MainShortcutGrid_Index4] = {
    Key_MainShortcutGrid_Index4,
    "ui_MainShortcutGrid_Index4"
  },
  [Key_MainShortcutGrid_Index5] = {
    Key_MainShortcutGrid_Index5,
    "ui_MainShortcutGrid_Index5"
  },
  [Key_MainShortcutGrid_Index6] = {
    Key_MainShortcutGrid_Index6,
    "ui_MainShortcutGrid_Index6"
  },
  [Key_MainShortcutGrid_Index7] = {
    Key_MainShortcutGrid_Index7,
    "ui_MainShortcutGrid_Index7"
  },
  [Key_MainShortcutGrid_Index8] = {
    Key_MainShortcutGrid_Index8,
    "ui_MainShortcutGrid_Index8"
  },
  [Key_MainShortcutGrid_Index9] = {
    Key_MainShortcutGrid_Index9,
    "ui_MainShortcutGrid_Index9"
  },
  [Key_MainShortcutGrid_Index10] = {
    Key_MainShortcutGrid_Index10,
    "ui_MainShortcutGrid_Index10"
  },
  [Key_SubShortcutGrid_Index1] = {
    Key_SubShortcutGrid_Index1,
    "ui_SubShortcutGrid_Index1"
  },
  [Key_SubShortcutGrid_Index2] = {
    Key_SubShortcutGrid_Index2,
    "ui_SubShortcutGrid_Index2"
  },
  [Key_SubShortcutGrid_Index3] = {
    Key_SubShortcutGrid_Index3,
    "ui_SubShortcutGrid_Index3"
  },
  [Key_SubShortcutGrid_Index4] = {
    Key_SubShortcutGrid_Index4,
    "ui_SubShortcutGrid_Index4"
  },
  [Key_SubShortcutGrid_Index5] = {
    Key_SubShortcutGrid_Index5,
    "ui_SubShortcutGrid_Index5"
  },
  [Key_SubShortcutGrid_Index6] = {
    Key_SubShortcutGrid_Index6,
    "ui_SubShortcutGrid_Index6"
  },
  [Key_SubShortcutGrid_Index7] = {
    Key_SubShortcutGrid_Index7,
    "ui_SubShortcutGrid_Index7"
  },
  [Key_SubShortcutGrid_Index8] = {
    Key_SubShortcutGrid_Index8,
    "ui_SubShortcutGrid_Index8"
  },
  [Key_SubShortcutGrid_Index9] = {
    Key_SubShortcutGrid_Index9,
    "ui_SubShortcutGrid_Index9"
  },
  [Key_SubShortcutGrid_Index10] = {
    Key_SubShortcutGrid_Index10,
    "ui_SubShortcutGrid_Index10"
  },
  [Key_NGShortcutGrid_Index1] = {
    Key_NGShortcutGrid_Index1,
    "ui_neigong_1_1"
  },
  [Key_NGShortcutGrid_Index2] = {
    Key_NGShortcutGrid_Index2,
    "ui_neigong_2"
  },
  [Key_NGShortcutGrid_Index3] = {
    Key_NGShortcutGrid_Index3,
    "ui_neigong_3"
  },
  [Key_NGShortcutGrid_Index4] = {
    Key_NGShortcutGrid_Index4,
    "ui_neigong_4"
  },
  [Key_NGShortcutGrid_Index5] = {
    Key_NGShortcutGrid_Index5,
    "ui_neigong_5"
  },
  [Key_SubNGShortcutGrid_index1] = {
    Key_SubNGShortcutGrid_index1,
    "ui_neigong_6"
  },
  [Key_SubNGShortcutGrid_index2] = {
    Key_SubNGShortcutGrid_index2,
    "ui_neigong_7"
  },
  [Key_SubNGShortcutGrid_index3] = {
    Key_SubNGShortcutGrid_index3,
    "ui_neigong_8"
  },
  [Key_SubNGShortcutGrid_index4] = {
    Key_SubNGShortcutGrid_index4,
    "ui_neigong_9"
  },
  [Key_SubNGShortcutGrid_index5] = {
    Key_SubNGShortcutGrid_index5,
    "ui_neigong_10"
  },
  [Key_SubNGShortcutGrid_index6] = {
    Key_SubNGShortcutGrid_index6,
    "ui_neigong_11"
  },
  [Key_SubNGShortcutGrid_index7] = {
    Key_SubNGShortcutGrid_index7,
    "ui_neigong_12"
  },
  [Key_SubNGShortcutGrid_index8] = {
    Key_SubNGShortcutGrid_index8,
    "ui_neigong_13"
  },
  [Key_SubNGShortcutGrid_index9] = {
    Key_SubNGShortcutGrid_index9,
    "ui_neigong_14"
  },
  [Key_SubNGShortcutGrid_index10] = {
    Key_SubNGShortcutGrid_index10,
    "ui_neigong_15"
  },
  [Key_OneEquipShortcutGrid_index1] = {
    Key_OneEquipShortcutGrid_index1,
    "ui_onestep_equip_1"
  },
  [Key_OneEquipShortcutGrid_index2] = {
    Key_OneEquipShortcutGrid_index2,
    "ui_onestep_equip_2"
  },
  [Key_OneEquipShortcutGrid_index3] = {
    Key_OneEquipShortcutGrid_index3,
    "ui_onestep_equip_3"
  },
  [Key_OneEquipShortcutGrid_index4] = {
    Key_OneEquipShortcutGrid_index4,
    "ui_onestep_equip_4"
  },
  [Key_SubSkillShortcut1_index1] = {
    Key_SubSkillShortcut1_index1,
    "ui_SubShortcutGrid_Indexh1"
  },
  [Key_SubSkillShortcut1_index2] = {
    Key_SubSkillShortcut1_index2,
    "ui_SubShortcutGrid_Indexh2"
  },
  [Key_SubSkillShortcut1_index3] = {
    Key_SubSkillShortcut1_index3,
    "ui_SubShortcutGrid_Indexh3"
  },
  [Key_SubSkillShortcut1_index4] = {
    Key_SubSkillShortcut1_index4,
    "ui_SubShortcutGrid_Indexh4"
  },
  [Key_SubSkillShortcut1_index5] = {
    Key_SubSkillShortcut1_index5,
    "ui_SubShortcutGrid_Indexh5"
  },
  [Key_SubSkillShortcut1_index6] = {
    Key_SubSkillShortcut1_index6,
    "ui_SubShortcutGrid_Indexh6"
  },
  [Key_SubSkillShortcut1_index7] = {
    Key_SubSkillShortcut1_index7,
    "ui_SubShortcutGrid_Indexh7"
  },
  [Key_SubSkillShortcut1_index8] = {
    Key_SubSkillShortcut1_index8,
    "ui_SubShortcutGrid_Indexh8"
  },
  [Key_SubSkillShortcut1_index9] = {
    Key_SubSkillShortcut1_index9,
    "ui_SubShortcutGrid_Indexh9"
  },
  [Key_SubSkillShortcut1_index10] = {
    Key_SubSkillShortcut1_index10,
    "ui_SubShortcutGrid_Indexh0"
  },
  [Key_SubSkillShortcut2_index1] = {
    Key_SubSkillShortcut2_index1,
    "ui_subskillshortcut2_index1"
  },
  [Key_SubSkillShortcut2_index2] = {
    Key_SubSkillShortcut2_index2,
    "ui_subskillshortcut2_index2"
  },
  [Key_SubSkillShortcut2_index3] = {
    Key_SubSkillShortcut2_index3,
    "ui_subskillshortcut2_index3"
  },
  [Key_SubSkillShortcut2_index4] = {
    Key_SubSkillShortcut2_index4,
    "ui_subskillshortcut2_index4"
  },
  [Key_SubSkillShortcut2_index5] = {
    Key_SubSkillShortcut2_index5,
    "ui_subskillshortcut2_index5"
  },
  [Key_SubSkillShortcut2_index6] = {
    Key_SubSkillShortcut2_index6,
    "ui_subskillshortcut2_index6"
  },
  [Key_SubSkillShortcut2_index7] = {
    Key_SubSkillShortcut2_index7,
    "ui_subskillshortcut2_index7"
  },
  [Key_SubSkillShortcut2_index8] = {
    Key_SubSkillShortcut2_index8,
    "ui_subskillshortcut2_index8"
  },
  [Key_SubSkillShortcut2_index9] = {
    Key_SubSkillShortcut2_index9,
    "ui_subskillshortcut2_index9"
  },
  [Key_SubSkillShortcut2_index10] = {
    Key_SubSkillShortcut2_index10,
    "ui_subskillshortcut2_index10"
  },
  [Key_SubSkillShortcut3_index1] = {
    Key_SubSkillShortcut3_index1,
    "ui_subskillshortcut3_index1"
  },
  [Key_SubSkillShortcut3_index2] = {
    Key_SubSkillShortcut3_index2,
    "ui_subskillshortcut3_index2"
  },
  [Key_SubSkillShortcut3_index3] = {
    Key_SubSkillShortcut3_index3,
    "ui_subskillshortcut3_index3"
  },
  [Key_SubSkillShortcut3_index4] = {
    Key_SubSkillShortcut3_index4,
    "ui_subskillshortcut3_index4"
  },
  [Key_SubSkillShortcut3_index5] = {
    Key_SubSkillShortcut3_index5,
    "ui_subskillshortcut3_index5"
  },
  [Key_SubSkillShortcut3_index6] = {
    Key_SubSkillShortcut3_index6,
    "ui_subskillshortcut3_index6"
  },
  [Key_SubSkillShortcut3_index7] = {
    Key_SubSkillShortcut3_index7,
    "ui_subskillshortcut3_index7"
  },
  [Key_SubSkillShortcut3_index8] = {
    Key_SubSkillShortcut3_index8,
    "ui_subskillshortcut3_index8"
  },
  [Key_SubSkillShortcut3_index9] = {
    Key_SubSkillShortcut3_index9,
    "ui_subskillshortcut3_index9"
  },
  [Key_SubSkillShortcut3_index10] = {
    Key_SubSkillShortcut3_index10,
    "ui_subskillshortcut3_index10"
  },
  [Key_SubSkillShortcut4_index1] = {
    Key_SubSkillShortcut4_index1,
    "ui_subskillshortcut4_index1"
  },
  [Key_SubSkillShortcut4_index2] = {
    Key_SubSkillShortcut4_index2,
    "ui_subskillshortcut4_index2"
  },
  [Key_SubSkillShortcut4_index3] = {
    Key_SubSkillShortcut4_index3,
    "ui_subskillshortcut4_index3"
  },
  [Key_SubSkillShortcut4_index4] = {
    Key_SubSkillShortcut4_index4,
    "ui_subskillshortcut4_index4"
  },
  [Key_SubSkillShortcut4_index5] = {
    Key_SubSkillShortcut4_index5,
    "ui_subskillshortcut4_index5"
  },
  [Key_SubSkillShortcut4_index6] = {
    Key_SubSkillShortcut4_index6,
    "ui_subskillshortcut4_index6"
  },
  [Key_SubSkillShortcut4_index7] = {
    Key_SubSkillShortcut4_index7,
    "ui_subskillshortcut4_index7"
  },
  [Key_SubSkillShortcut4_index8] = {
    Key_SubSkillShortcut4_index8,
    "ui_subskillshortcut4_index8"
  },
  [Key_SubSkillShortcut4_index9] = {
    Key_SubSkillShortcut4_index9,
    "ui_subskillshortcut4_index9"
  },
  [Key_SubSkillShortcut4_index10] = {
    Key_SubSkillShortcut4_index10,
    "ui_subskillshortcut4_index10"
  },
  [Key_SubSkillShortcut_copy] = {
    Key_SubSkillShortcut_copy,
    "ui_subskillshortcut_copy"
  },
  [Key_NGShortcutGrid_IncPage] = {
    Key_NGShortcutGrid_IncPage,
    "ui_NGShortcutGrid_IncPage"
  },
  [Key_NGShortcutGrid_DecPage] = {
    Key_NGShortcutGrid_DecPage,
    "ui_NGShortcutGrid_DecPage"
  }
}
local NONEED_KEYS = {Key_Role_OrientLeft, Key_Role_OrientRight}
local ROW_COUNT = 10
local FORM_SHORTCUT_KEY = "form_stage_main\\form_shortcut_key"
local FORM_SETTING = "form_stage_main\\form_system\\form_system_interface_setting"
function on_key_up(key, ctrl, shift, alt, param1, param2)
  local form = nx_value(FORM_SHORTCUT_KEY)
  if not nx_is_valid(form) then
    return
  end
  local shortcut_keys = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_keys) then
    return
  end
  local grid = form.textgrid_key
  local row = form.select_index
  if row < 0 then
    return false
  end
  if param1 == 1 then
    return
  end
  local data = grid:GetGridTag(row, 0)
  if not nx_is_valid(data) then
    return
  end
  local key_id = shortcut_keys:GetEditKeyID(param1, ctrl, shift, alt)
  if data.KeyID == key_id then
    update_cbtn(grid)
    return
  end
  if key_id == Key_BaseKey_Last or key_id == Key_FuncKey_Begin or key_id == Key_FuncKey_Last or key_id == Key_MainShortcutGrid_Begin or key_id == Key_MainShortcutGrid_Last or key_id == Key_CameraKey_Begin or key_id == Key_CameraKey_Last or key_id == Key_ChatKey_Begin or key_id == Key_ChatKey_Last or key_id == Key_OtherKey_Begin or key_id == Key_OtherKey_Last or key_id == Key_TargetKey_Begin or key_id == Key_TargetKey_Last then
    return
  end
  if 0 <= key_id and BASE_KEYS[key_id] ~= nil then
    local operate_mode = GetIniInfo("operate_control_mode")
    if nx_int(operate_mode) == nx_int(1) and (key_id == Key_Role_OrientLeft or key_id == Key_Role_OrientRight) then
      shortcut_keys:ReplaceKey(data.KeyID, key_id)
      update_cbtn(grid)
      update_grid(grid)
      return
    end
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local dst_key_name = grid:GetGridText(row, 0)
    local dst_key_val = shortcut_keys:GetEditKeyNameByKeyID(key_id)
    local gui = nx_value("gui")
    local text = nx_widestr(gui.TextManager:GetText("ui_NewSet")) .. nx_widestr(" ") .. nx_widestr(dst_key_name)
    text = text .. nx_widestr(" ") .. nx_widestr(gui.TextManager:GetText("ui_KuaiJieJian")) .. nx_widestr(dst_key_val)
    text = text .. nx_widestr(" ") .. nx_widestr(gui.TextManager:GetText("ui_WillCover"))
    text = text .. nx_widestr(" ") .. nx_widestr(gui.TextManager:GetText(BASE_KEYS[key_id][2]))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      shortcut_keys:ReplaceKey(data.KeyID, key_id)
    end
  else
    local data = grid:GetGridTag(row, 0)
    shortcut_keys:ModifyKey(data.KeyID, param1, ctrl, shift, alt)
  end
  update_cbtn(grid)
  update_grid(grid)
  return true
end
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  init_grid(self.textgrid_key)
  local shortcut_keys = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_keys) then
    return
  end
  shortcut_keys:BeginEdit()
  self.rbtn_operate.Checked = true
  self.select_index = -1
  local gui = nx_value("gui")
  local operate_mode = GetIniInfo("operate_control_mode")
  if nx_int(operate_mode) == nx_int(0) then
    self.cbtn_tag3D.Checked = true
    self.cbtn_tag25D.Checked = false
  else
    self.cbtn_tag3D.Checked = false
    self.cbtn_tag25D.Checked = true
  end
end
function on_main_form_close(self)
  local grid = self.textgrid_key
  if nx_is_valid(grid) then
    for i = 0, grid.RowCount - 1 do
      local data = grid:GetGridTag(i, 0)
      if nx_is_valid(data) then
        nx_destroy(data)
      end
    end
  end
  nx_destroy(self)
  local shortcut_keys = nx_value("ShortcutKey")
  if nx_is_valid(shortcut_keys) and shortcut_keys:IsEdit() then
    shortcut_keys:EndEdit(false, 0)
  end
end
function on_rbtn_operate_checked_changed(rbtn)
  if rbtn.Checked then
    update_tag_color(rbtn)
    switch_cur_page(KEYTYPE_BASEKEY)
  end
end
function on_rbtn_interface_checked_changed(rbtn)
  if rbtn.Checked then
    update_tag_color(rbtn)
    switch_cur_page(KEYTYPE_FUNCKEY)
  end
end
function on_rbtn_chat_checked_changed(rbtn)
  if rbtn.Checked then
    update_tag_color(rbtn)
    switch_cur_page(KEYTYPE_CHATKEY)
  end
end
function on_rbtn_target_checked_changed(rbtn)
  if rbtn.Checked then
    update_tag_color(rbtn)
    switch_cur_page(KEYTYPE_TARGETKEY)
  end
end
function on_rbtn_camera_checked_changed(rbtn)
  if rbtn.Checked then
    update_tag_color(rbtn)
    switch_cur_page(KEYTYPE_CAMERAKEY)
  end
end
function on_rbtn_other_checked_changed(rbtn)
  if rbtn.Checked then
    update_tag_color(rbtn)
    switch_cur_page(KEYTYPE_OTHERKEY)
  end
end
function on_rbtn_column_checked_changed(rbtn)
  if rbtn.Checked then
    update_tag_color(rbtn)
    switch_cur_page(KEYTYPE_GRIDKEY)
  end
end
function switch_cur_page(keytype)
  local form = nx_value(FORM_SHORTCUT_KEY)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid_key
  grid.KeyType = keytype
  grid:ClearSelect()
  grid:ClearSelect()
  show_grid(grid)
  update_cbtn(grid)
end
function init_grid(grid)
  grid.ColCount = 2
  grid:SetColAlign(0, "left")
  grid:SetColAlign(1, "center")
  grid:SetColWidth(0, 165)
  grid:SetColWidth(1, 170)
end
function show_grid(grid)
  local shortcut_keys = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_keys) then
    return
  end
  if not nx_is_valid(grid) then
    return
  end
  for i = 0, grid.RowCount - 1 do
    local data = grid:GetGridTag(i, 0)
    if nx_is_valid(data) then
      nx_destroy(data)
    end
  end
  grid:ClearRow()
  local key_begin, key_last = get_key_range(grid)
  local gui = nx_value("gui")
  local lm_mode_set = GetIniInfo("admove_mode")
  local operate_mode = GetIniInfo("operate_control_mode")
  for i = key_begin, key_last do
    if BASE_KEYS[i] ~= nil then
      local key_id = BASE_KEYS[i][1]
      local key_name = BASE_KEYS[i][2]
      if nx_int(lm_mode_set) == nx_int(1) then
        if i == Key_Role_MoveLeft then
          key_name = BASE_KEYS[Key_Role_OrientLeft][2]
        elseif i == Key_Role_MoveRight then
          key_name = BASE_KEYS[Key_Role_OrientRight][2]
        elseif i == Key_Role_OrientLeft then
          key_name = BASE_KEYS[Key_Role_MoveLeft][2]
        elseif i == Key_Role_OrientRight then
          key_name = BASE_KEYS[Key_Role_MoveRight][2]
        end
      end
      local data = nx_create("ArrayList", nx_current())
      data.KeyID = key_id
      if nx_int(operate_mode) == nx_int(1) and gui.TextManager:IsIDName(key_name .. "2") then
        key_name = key_name .. "2"
      end
      if nx_int(operate_mode) == nx_int(0) or is_needshow_key(key_id) then
        local row = grid:InsertRow(-1)
        grid:SetGridText(row, 0, gui.TextManager:GetText(key_name))
        grid:SetGridText(row, 1, nx_widestr(shortcut_keys:GetEditKeyNameByKeyID(key_id)))
        grid:SetGridTag(row, 0, data)
      end
    end
  end
  update_item_visible(grid)
  local form = grid.ParentForm
  form.btn_undo.Enabled = shortcut_keys:CanUnDo()
  form.btn_redo.Enabled = shortcut_keys:CanReDo()
end
function update_grid(grid)
  local gui = nx_value("gui")
  local shortcut_keys = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_keys) then
    return
  end
  local operate_mode = GetIniInfo("operate_control_mode")
  local row = 0
  local key_begin, key_last = get_key_range(grid)
  for i = key_begin, key_last do
    if BASE_KEYS[i] ~= nil then
      local key_id = BASE_KEYS[i][1]
      local key_name = BASE_KEYS[i][2]
      local data = grid:GetGridTag(row, 0)
      if not nx_is_valid(data) then
        data = nx_create("ArrayList", nx_current())
      end
      data.KeyID = key_id
      if nx_int(operate_mode) == nx_int(1) and gui.TextManager:IsIDName(key_name .. "2") then
        key_name = key_name .. "2"
      end
      if nx_int(operate_mode) == nx_int(0) or is_needshow_key(key_id) then
        grid:SetGridText(row, 0, gui.TextManager:GetText(key_name))
        grid:SetGridText(row, 1, nx_widestr(shortcut_keys:GetEditKeyNameByKeyID(key_id)))
        grid:SetGridTag(row, 0, data)
        row = row + 1
      end
    end
  end
  local form = grid.ParentForm
  form.btn_undo.Enabled = shortcut_keys:CanUnDo()
  form.btn_redo.Enabled = shortcut_keys:CanReDo()
end
function on_btn_undo_click(btn)
  local shortcut_keys = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_keys) then
    return
  end
  local form = btn.ParentForm
  local grid = form.textgrid_key
  shortcut_keys:UnDo()
  update_grid(grid)
end
function on_btn_redo_click(btn)
  local shortcut_keys = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_keys) then
    return
  end
  local form = btn.ParentForm
  local grid = form.textgrid_key
  shortcut_keys:ReDo()
  update_grid(grid)
end
function on_btn_default_click(btn)
  local shortcut_keys = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_keys) then
    return
  end
  local form = btn.ParentForm
  local grid = form.textgrid_key
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return
  end
  shortcut_keys:Recover(nx_int(game_config_info.operate_control_mode))
  update_grid(grid)
  game_config_info.apply_shortcut_keys = 0
  nx_execute("game_config", "save_game_config", game_config_info, "systeminfo.ini", "Config")
  local customizing = nx_value("customizing_manager")
  if not nx_is_valid(customizing) then
    return
  end
end
function on_btn_apply_click(btn)
  local form = btn.ParentForm
  local grid = form.textgrid_key
  local shortcut_keys = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_keys) then
    return
  end
  shortcut_keys:EndEdit(true, 0)
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return
  end
  game_config_info.apply_shortcut_keys = 0
  nx_execute("game_config", "save_game_config", game_config_info, "systeminfo.ini", "Config")
  local customizing = nx_value("customizing_manager")
  if not nx_is_valid(customizing) then
    return
  end
  nx_execute("form_stage_main\\form_main\\form_main_shortcut", "update_shortcut_key")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_ride", "refresh_shortcut_key")
  nx_execute("form_stage_main\\form_main\\form_main_func_btns", "update_shortcut_key")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_onestep", "update_shortcut_key")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_copyskill", "update_shortcut_key")
  shortcut_keys:BeginEdit()
  switch_cur_page(grid.KeyType)
end
function on_btn_ok_click(btn)
  local shortcut_keys = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_keys) then
    return
  end
  shortcut_keys:EndEdit(true, 0)
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return
  end
  game_config_info.apply_shortcut_keys = 0
  nx_execute("game_config", "save_game_config", game_config_info, "systeminfo.ini", "Config")
  local customizing = nx_value("customizing_manager")
  if not nx_is_valid(customizing) then
    return
  end
  local form = btn.ParentForm
  form:Close()
  nx_execute("form_stage_main\\form_main\\form_main_shortcut", "update_shortcut_key")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_ride", "refresh_shortcut_key")
  nx_execute("form_stage_main\\form_main\\form_main_func_btns", "update_shortcut_key")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_onestep", "update_shortcut_key")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_copyskill", "update_shortcut_key")
end
function on_btn_cancel_click(btn)
  local shortcut_keys = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_keys) then
    return
  end
  shortcut_keys:EndEdit(false, 0)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_Close_click(btn)
  local shortcut_keys = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_keys) then
    return
  end
  shortcut_keys:EndEdit(false, 0)
  local form = btn.ParentForm
  form:Close()
end
function get_key_range(grid)
  local key_begin = 0
  local key_last = 0
  if grid.KeyType == KEYTYPE_BASEKEY then
    key_begin = Key_BaseKey_Begin
    key_last = Key_BaseKey_Last
  elseif grid.KeyType == KEYTYPE_FUNCKEY then
    key_begin = Key_FuncKey_Begin
    key_last = Key_FuncKey_Last
  elseif grid.KeyType == KEYTYPE_GRIDKEY then
    key_begin = Key_MainShortcutGrid_Begin
    key_last = Key_MainShortcutGrid_Last
  elseif grid.KeyType == KEYTYPE_CHATKEY then
    key_begin = Key_ChatKey_Begin
    key_last = Key_ChatKey_Last
  elseif grid.KeyType == KEYTYPE_TARGETKEY then
    key_begin = Key_TargetKey_Begin
    key_last = Key_TargetKey_Last
  elseif grid.KeyType == KEYTYPE_CAMERAKEY then
    key_begin = Key_CameraKey_Begin
    key_last = Key_CameraKey_Last
  elseif grid.KeyType == KEYTYPE_OTHERKEY then
    key_begin = Key_OtherKey_Begin
    key_last = Key_OtherKey_Last
  end
  return key_begin, key_last
end
function on_cbtn_checked_changed(self)
  local gui = nx_value("gui")
  local form = self.ParentForm
  local grid = form.textgrid_key
  local scroll_bar_index = grid.VScrollBar.Value
  local index = scroll_bar_index + self.DataSource - 1
  if self.Checked then
    set_other_check_btn_state(self, false)
    self.Text = nx_widestr(gui.TextManager:GetText("ui_gaijiantishi"))
    form.select_index = index
    grid:SelectRow(index)
    update_grid(grid)
    return
  else
    form.select_index = -1
    self.Text = nil
  end
end
function update_cbtn(grid)
  if not nx_is_valid(grid) then
    return
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local cbtn_name = "cbtn_"
  for i = 1, ROW_COUNT do
    local btn = cbtn_name .. nx_string(i)
    if not nx_find_custom(form, btn) then
      return
    end
    local cbtn = nx_custom(form, btn)
    if not nx_is_valid(cbtn) then
      return
    end
    if cbtn.Checked then
      cbtn.Checked = false
      form.select_index = -1
    end
  end
end
function update_tag_color(rbtn)
  local form = rbtn.ParentForm
  local forecolor = "255,178,153,127"
  form.rbtn_operate.ForeColor = forecolor
  form.rbtn_interface.ForeColor = forecolor
  form.rbtn_chat.ForeColor = forecolor
  form.rbtn_target.ForeColor = forecolor
  form.rbtn_camera.ForeColor = forecolor
  form.rbtn_other.ForeColor = forecolor
  form.rbtn_column.ForeColor = forecolor
  rbtn.ForeColor = "255,255,255,255"
end
function set_other_check_btn_state(self, state)
  if not nx_is_valid(self) then
    return
  end
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local btn_name = "cbtn_"
  for i = 1, ROW_COUNT do
    local btn = btn_name .. nx_string(i)
    if not nx_find_custom(form, btn) then
      return
    end
    cbtn = nx_custom(form, btn)
    if not nx_id_equal(cbtn, self) then
      cbtn.Checked = state
    end
  end
end
function on_textgrid_key_vscroll_changed(self, value)
  local gui = nx_value("gui")
  local form = self.ParentForm
  local grid = form.textgrid_key
  local btn_name = "cbtn_"
  for i = 1, ROW_COUNT do
    local btn = btn_name .. nx_string(i)
    if not nx_find_custom(form, btn) then
      return
    end
    cbtn = nx_custom(form, btn)
    if nx_is_valid(cbtn) then
      cbtn.Text = nil
    end
  end
  if nx_int(form.select_index) == nx_int(-1) then
    return
  end
  local select_index = grid.RowSelectIndex
  local len = grid.VScrollBar.Value
  local dist = select_index - len
  if 0 <= dist and dist < ROW_COUNT then
    local cbtn = nx_custom(form, "cbtn_" .. dist + 1)
    cbtn.Text = nx_widestr(gui.TextManager:GetText("ui_gaijiantishi"))
    cbtn.Checked = true
  end
end
function is_needshow_key(keyid)
  for i = 1, table.getn(NONEED_KEYS) do
    if nx_int(keyid) == nx_int(NONEED_KEYS[i]) then
      return false
    end
  end
  return true
end
function update_item_visible(grid)
  local form = grid.ParentForm
  local rowcount = grid.RowCount
  if not nx_is_valid(form) then
    return
  end
  local btn_name = "cbtn_"
  local back_name = "lbl_back"
  for i = 1, ROW_COUNT do
    local btn = btn_name .. nx_string(i)
    if nx_find_custom(form, btn) then
      local cbtn = nx_custom(form, btn)
      if nx_is_valid(cbtn) then
        cbtn.Visible = false
      end
    end
    local back = back_name .. nx_string(i)
    if nx_find_custom(form, back) then
      local lblback = nx_custom(form, back)
      if nx_is_valid(lblback) then
        lblback.Visible = false
      end
    end
  end
  for i = 1, rowcount do
    local btn = btn_name .. nx_string(i)
    if nx_find_custom(form, btn) then
      local cbtn = nx_custom(form, btn)
      if nx_is_valid(cbtn) then
        cbtn.Visible = true
      end
    end
    local back = back_name .. nx_string(i)
    if nx_find_custom(form, back) then
      local lblback = nx_custom(form, back)
      if nx_is_valid(lblback) then
        lblback.Visible = true
      end
    end
  end
end
function on_cbtn_tag3D_click(cbtn)
  local form = cbtn.ParentForm
  local gui = nx_value("gui")
  local game_config_info = nx_value("game_config_info")
  if nx_int(game_config_info.operate_control_mode) == nx_int(0) then
    cbtn.Checked = true
    return
  end
  local text = gui.TextManager:GetText("ui_control_3D")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local result = nx_wait_event(100000000, dialog, "confirm_return")
  if result == "ok" then
    nx_execute(FORM_SETTING, "switch_mode", "0")
    handle_switch_event(0)
    form.cbtn_tag3D.Checked = true
    form.cbtn_tag25D.Checked = false
  else
    form.cbtn_tag3D.Checked = false
    form.cbtn_tag25D.Checked = true
  end
end
function on_cbtn_tag25D_click(cbtn)
  local form = cbtn.ParentForm
  local gui = nx_value("gui")
  local game_config_info = nx_value("game_config_info")
  if nx_int(game_config_info.operate_control_mode) == nx_int(1) then
    cbtn.Checked = true
    return
  end
  local text = gui.TextManager:GetText("ui_control_2.5D")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local result = nx_wait_event(100000000, dialog, "confirm_return")
  if result == "ok" then
    nx_execute(FORM_SETTING, "switch_mode", "1")
    handle_switch_event(1)
    form.cbtn_tag3D.Checked = false
    form.cbtn_tag25D.Checked = true
  else
    form.cbtn_tag3D.Checked = true
    form.cbtn_tag25D.Checked = false
  end
end
function handle_switch_event(mode)
  local form = nx_value(FORM_SETTING)
  if nx_is_valid(form) and nx_find_custom(form, "subform") and nx_is_valid(form.subform) then
    nx_execute(nx_string(form.subform.Name), nx_int(mode) == nx_int(0) and "on_switchto_3dmode" or "on_switchto_25dmode", form.subform)
    form.rbtn_tag3D.Checked = nx_int(mode) == nx_int(0) and true or false
    form.rbtn_tag25D.Checked = nx_int(mode) == nx_int(1) and true or false
  end
end
function update_window()
  local form = nx_value(FORM_SHORTCUT_KEY)
  if nx_is_valid(form) then
    on_rbtn_operate_checked_changed(form.rbtn_operate)
    on_rbtn_interface_checked_changed(form.rbtn_interface)
    on_rbtn_chat_checked_changed(form.rbtn_chat)
    on_rbtn_target_checked_changed(form.rbtn_target)
    on_rbtn_camera_checked_changed(form.rbtn_camera)
    on_rbtn_other_checked_changed(form.rbtn_other)
    on_rbtn_column_checked_changed(form.rbtn_column)
  end
end
function on_btn_save_click(btn)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_shortcut_save", true, false)
  if not nx_is_valid(form) then
    return
  end
  form:ShowModal()
end
