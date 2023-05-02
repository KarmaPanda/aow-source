require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("utils")
require("util_gui")
require("define\\gamehand_type")
require("game_object")
require("util_functions")
require("define\\object_type_define")
require("define\\request_type")
require("share\\client_custom_define")
require("util_vip")
HomePointList = "HomePointList"
HOMEPOINT_INI_FILE = "share\\Rule\\HomePoint.ini"
HOMEPOINT_DEFAULT_INI_FILE = "share\\Rule\\DefaultHomePoint.ini"
HOMEPOINT_PRICE_INI_FILE = "share\\Rule\\HomePointPrice.ini"
NormalImage = "gui\\common\\treeview\\tree_2_out.png"
FocusImage = "gui\\common\\treeview\\tree_2_on.png"
PushImage = "gui\\common\\treeview\\tree_2_on.png"
Btn_Del_NormalImage = "gui\\common\\button\\btn_del_out.png"
Btn_Del_FocusImage = "gui\\common\\button\\btn_del_on.png"
Btn_Del_PushImage = "gui\\common\\button\\btn_del_down.png"
Btn_add_NormalImage = "gui\\common\\button\\btn_add_out.png"
Btn_add_FocusImage = "gui\\common\\button\\btn_add_on.png"
Btn_add_PushImage = "gui\\common\\button\\btn_add_down.png"
SelHomePoint = "gui\\common\\treeview\\tree_2_on.png"
Hp_jianghu = "gui\\language\\ChineseS\\homepoint\\icon_jianghu.png"
Hp_School = "gui\\language\\ChineseS\\homepoint\\icon_school.png"
Hp_BangPai = "gui\\language\\ChineseS\\homepoint\\icon_guild.png"
Hp_KuoChong = "gui\\language\\ChineseS\\homepoint\\icon_extend.png"
HP_KuoChong_JiangHu = "gui\\language\\ChineseS\\homepoint\\icon_jianghu1.png"
HP_KuoChong_Guild = "gui\\language\\ChineseS\\homepoint\\icon_guild1.png"
Hp_ChengZhen = "gui\\language\\ChineseS\\homepoint\\icon_city.png"
Hp_JiaoWai = "gui\\language\\ChineseS\\homepoint\\icon_environs.png"
Hp_Fix = "gui\\map\\HomePoint\\HomePoint007.png"
PER_MINUTE = 60000
PER_SECOND = 1000
THIRTY_MINUTE = 600000
SHOW_TYPE_HOMEPOINT = 0
SHOW_TYPE_SCENE_HOMEPOINT = 1
SHOW_TYPE_KUOCHONG_HOMEPOINT = 2
SHOW_TYPE_KONG_HOMEPOINT = 3
SHOW_TYPE_HIRE_HOMEPOINT = 4
HP_ID = 1
HP_SCENE_NO = 2
HP_NAME = 3
HP_SAFE = 4
HP_POS = 5
HP_DES = 6
HP_PHOTO = 7
HP_TYPE = 8
HP_AREA = 9
HP_TERRITORY_TYPE = 10
HP_COMP_TYPE = 11
Max_JiangHu_HomePoint_Count = 5
Max_School_HomePoint_Count = 1
Max_Guild_HomePoint_Count = 3
function GetSceneHomePointCount()
  local ini = nx_execute("util_functions", "get_ini", HOMEPOINT_INI_FILE)
  if not nx_is_valid(ini) then
    return 0
  end
  local sec_count = ini:GetSectionCount()
  return sec_count
end
function GetRecordHomePointCount()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local nCount = client_player:GetRecordRows(HomePointList)
  return nCount
end
function IsExistRecordHomePoint(hp_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local row = client_player:FindRecordRow(HomePointList, 0, hp_id, 0)
  local row_hire = client_player:FindRecordRow("HireHomePointList", 0, hp_id, 0)
  if row < 0 and row_hire < 0 then
    return false
  end
  return true
end
function GetHomePointFromHPid(hpid)
  local ini = nx_execute("util_functions", "get_ini", HOMEPOINT_INI_FILE)
  if not nx_is_valid(ini) then
    return false
  end
  local index = ini:FindSectionIndex(hpid)
  if index < 0 then
    return false
  end
  local hp_info = {}
  hp_info[HP_ID] = hpid
  hp_info[HP_SCENE_NO] = ini:ReadInteger(index, "SceneID", 0)
  hp_info[HP_NAME] = ini:ReadString(index, "Name", "")
  hp_info[HP_SAFE] = ini:ReadInteger(index, "Safe", 0)
  local pos_text = ini:ReadString(index, "PositonXYZ", "")
  hp_info[HP_POS] = util_split_string(nx_string(pos_text), ",")
  hp_info[HP_DES] = ini:ReadString(index, "Ui_Introduction", "")
  hp_info[HP_PHOTO] = ini:ReadString(index, "Ui_Picture", "")
  hp_info[HP_TYPE] = ini:ReadInteger(index, "Type", 0)
  hp_info[HP_AREA] = ini:ReadString(index, "SpecialSec", "")
  return true, hp_info
end
function GetHomePointFromIndexNo(index)
  if index < 0 then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", HOMEPOINT_INI_FILE)
  if not nx_is_valid(ini) then
    return false
  end
  local sec_count = ini:GetSectionCount()
  if index > sec_count then
    return false
  end
  local hp_info = {}
  hp_info[HP_ID] = ini:GetSectionByIndex(index)
  hp_info[HP_SCENE_NO] = ini:ReadInteger(index, "SceneID", 0)
  hp_info[HP_NAME] = ini:ReadString(index, "Name", "")
  hp_info[HP_SAFE] = ini:ReadInteger(index, "Safe", 0)
  local pos_text = ini:ReadString(index, "PositonXYZ", "")
  hp_info[HP_POS] = util_split_string(nx_string(pos_text), ",")
  hp_info[HP_DES] = ini:ReadString(index, "Ui_Introduction", "")
  hp_info[HP_PHOTO] = ini:ReadString(index, "Ui_Picture", "")
  hp_info[HP_TYPE] = ini:ReadInteger(index, "Type", 0)
  hp_info[HP_AREA] = ini:ReadString(index, "SpecialSec", "")
  return true, hp_info
end
function Get_Recortd_HpPhoto(Type)
  if Type == School_HomePoint then
    return Hp_School
  elseif Type == Guild_HomePoint then
    return Hp_BangPai
  else
    return Hp_jianghu
  end
end
function Get_HomePoint_Safe(safe)
  if 1 == safe then
    return Hp_ChengZhen
  else
    return Hp_JiaoWai
  end
end
function Get_HomePoint_Text(Type)
  if Type == School_HomePoint then
    return nx_widestr(util_text("ui_main_pk_protect_2"))
  elseif Type == Guild_HomePoint then
    return nx_widestr(util_text("ui_main_pk_protect_1"))
  else
    return nx_widestr(util_text("ui_main_pk_state_1"))
  end
end
function Get_HomePoint_KuoChong_Photo(Type)
  if Type == Guild_HomePoint then
    return HP_KuoChong_Guild
  else
    return HP_KuoChong_JiangHu
  end
end
function ShowTipDialog(content)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, content)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    return true
  else
    return false
  end
  return false
end
function get_hp_type(nType)
  return (nx_int(nType) == nx_int(0) or nx_int(nType) == nx_int(1)) and JiangHu_HomePoint or nType
end
function get_scene_name(index)
  local ini = nx_execute("util_functions", "get_ini", "share\\rule\\maplist.ini")
  if not nx_is_valid(ini) then
    return
  end
  return ini:ReadString(0, nx_string(index), "")
end
function IsOwnGuild()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local guild_name = client_player:QueryProp("GuildName")
  if nx_widestr(guild_name) == nx_widestr("") or guild_name == nil then
    return false
  end
  return true
end
function IsSchoolHomePoint(hp_info)
  if hp_info[HP_TYPE] ~= School_HomePoint then
    return true
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local school_name = client_player:QueryProp("School")
  local Type_hp = get_type_homepoint(school_name)
  if nx_string(Type_hp) == nx_string(hp_info[HP_ID]) then
    return true
  end
  return false
end
function send_homepoint_msg_to_server(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SET_HOMEPOINT), unpack(arg))
end
function get_type_homepoint(type_name)
  local ini = nx_execute("util_functions", "get_ini", HOMEPOINT_DEFAULT_INI_FILE)
  if not nx_is_valid(ini) then
    return ""
  end
  local index = ini:FindSectionIndex(type_name)
  if index < 0 then
    return ""
  end
  local hp = ini:ReadString(index, "HomePointID", "")
  return hp
end
