require("util_gui")
require("util_functions")
require("custom_sender")
require("share\\view_define")
require("share\\capital_define")
require("share\\client_custom_define")
require("form_stage_main\\form_tvt\\define")
FORM_DIE_GUILDWAR = "form_stage_main\\form_die_guildwar"
FORM_DIE_UNDERCITY_GUILDWAR = "form_stage_main\\form_die_undercity_guildwar"
AUTO_RELIVE_TIME = 180
RELIVE_POINT_COUNT = 4
UNDERCITY_RELIVE_POINT_COUNT = 3
RELIVE_TYPE_RETURNCITY = 0
RELIVE_TYPE_LOCAL = 1
RELIVE_TYPE_NEAR = 2
RELIVE_TYPE_PRISON = 3
RELIVE_TYPE_LOCAL_STRONG = 4
RELIVE_TYPE_GUILD = 5
RELIVE_TYPE_SCHOOL = 6
RELIVE_TYPE_CURE = 7
RELIVE_TYPE_SPECIAL = 8
RELIVE_TYPE_OTHER = 9
RELIVE_TYPE_BATTLEFIELD = 10
RELIVE_TYPE_FB_LOCAL = 11
RELIVE_TYPE_TG_CHALLENGE = 12
RELIVE_TYPE_TIGUAN = 13
RELIVE_TYPE_BATTLEFIELD_EXIT = 14
RELIVE_TYPE_ROB_PRISON = 15
RELIVE_TYPE_WORLD_NEAR = 16
RELIVE_TYPE_LOULAN = 23
RELIVE_TYPE_JHSCENE_HOME = 24
RELIVE_TYPE_GUMU_RESCUE = 25
RELIVE_TYPE_NLB_SHIMEN = 26
RELIVE_TYPE_HSP_MEET = 27
RELIVE_TYPE_GUILD_CROSS_WAR = 28
RELIVE_TYPE_OUTLAND_WAR = 31
RELIVE_TYPE_SANMENG = 32
RELIVE_TYPE_HOME = 33
RELIVE_TYPE_BALANCE_WAR = 35
RELIVE_TYPE_WUDAO_WAR = 36
RELIVE_TYPE_LUAN_DOU = 37
RELIVE_TYPE_WUDAO_YANWU = 40
RELIVE_TYPE_BALANCE_2 = 44
RELIVE_TYPE_POWER = 45
RELIVE_TYPE_LEAGUE_MATCHES = 47
RELIVE_TYPE_NEW_SCHOOL_FIGHT = 49
RELIVE_TYPE_MAX = 50
CAPITAL_TYPE_GOLDEN = 0
CAPITAL_TYPE_SILVER = 1
CAPITAL_TYPE_SILVER_CARD = 2
CURE_TYPE_INJURED = 1
CURE_TYPE_HELP = 2
RELIVE_NAME = {
  "ReturnCityRelive",
  "LocalRelive",
  "NearRelive",
  "PrisonRelive",
  "StrongRelive",
  "GuildRelive",
  "SchoolRelive",
  "CureRelive",
  "CloneDieRelive"
}
RELIVE_INFO = "share\\relive\\relive.ini"
RELIVE_POS_INFO = "share\\relive\\sencerelive.ini"
SCENE_INI = "share\\Rule\\scenes.ini"
RELIVE_SAFE_BUFFER = "buf_Relive_Safe"
BUFF_BAOHU = "gui\\special\\action_show\\zhaohu.png"
BUFF_JIANKANG = "gui\\special\\action_show\\huanhu.png"
BUFF_XURUO = "gui\\special\\action_show\\baiji.png"
BUFF_KUANG = "gui\\special\\relive\\buff_high_light.png"
TOP_X = 0
TOP_Y = 0
MID_X = 0
MID_Y = 128
BOTTOM_X = 0
BOTTOM_Y = 184
MOV_FPS = 30
MAX_RELIVE_COUNT_DAILY = 10
JHSCENE_MAX_RELIVE_COUNT_DAILY = 50
function get_relive_buff(relive_type, is_safe)
  local IniManager = nx_value("IniManager")
  if not IniManager:IsIniLoadedToManager(RELIVE_INFO) then
    IniManager:LoadIniToManager(RELIVE_INFO)
  end
  local ini = IniManager:GetIniDocument(RELIVE_INFO)
  if not nx_is_valid(ini) then
    return ""
  end
  if relive_type == "" or relive_type == nil then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string(RELIVE_NAME[nx_int(relive_type) + 1]))
  if sec_index < 0 then
    return ""
  end
  local buffer_info = ini:ReadString(sec_index, "DebuffID", "")
  if buffer_info == "" then
    return
  end
  if is_safe == 1 or is_safe == true then
    return buffer_info .. "," .. RELIVE_SAFE_BUFFER
  else
    return buffer_info
  end
end
function get_confirm_info(relive_type, relive_index, relivepoint_name)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return ""
  end
  local form_home_point = nx_value("form_home_point")
  if not nx_is_valid(form_home_point) then
    return
  end
  local str = ""
  if nx_int(relive_type) == nx_int(RELIVE_TYPE_RETURNCITY) and is_in_cross_station_war() then
    relive_type = RELIVE_TYPE_NEAR
  end
  if nx_int(relive_type) == nx_int(RELIVE_TYPE_RETURNCITY) then
    local relive_positon_name = "RelivePositon"
    if form_home_point:IsNewTerritoryType() then
      relive_positon_name = "DongHaiRelivePositon"
    end
    local relive_info = player:QueryProp(relive_positon_name)
    local relive_lst = nx_function("ext_split_string", relive_info, ",")
    local hp_ratio = GetReliveHpResumeRatio(RELIVE_TYPE_RETURNCITY)
    if relive_lst[6] == nil then
      local scene_name = get_scene_name(nx_int(relive_lst[1]))
      str = gui.TextManager:GetFormatText("ui_fuhuo_nobind", scene_name, nx_int(hp_ratio))
    else
      local relive_name = gui.TextManager:GetFormatText(relive_lst[6])
      str = gui.TextManager:GetFormatText("ui_fuhuo_bind", relive_name, nx_int(hp_ratio))
    end
  elseif nx_int(relive_type) == nx_int(RELIVE_TYPE_LOCAL_STRONG) then
    if IsInJHScene() then
      str = gui.TextManager:GetFormatText("ui_jhscene_fuhuo_local_strong")
    else
      str = gui.TextManager:GetFormatText("ui_fuhuo_local_strong")
    end
  elseif nx_int(relive_type) == nx_int(RELIVE_TYPE_FB_LOCAL) then
    str = gui.TextManager:GetFormatText("ui_clonedie_tips")
  elseif nx_int(relive_type) == nx_int(RELIVE_TYPE_LOCAL) then
    if IsInJHScene() then
      str = gui.TextManager:GetFormatText("ui_jhscene_fuhuo_local")
    else
      str = gui.TextManager:GetFormatText("ui_fuhuo_local")
    end
  elseif nx_int(relive_type) == nx_int(RELIVE_TYPE_NEAR) then
    local relive_point_info = getNearRelivePosInfo()
    if relive_point_info == nil or relive_point_info == "" then
      str = gui.TextManager:GetFormatText("ui_fuhuo_near_2")
    elseif not CurSceneIsCloneScene() then
      str = gui.TextManager:GetFormatText("ui_fuhuo_near_1", relive_point_info)
    else
      str = gui.TextManager:GetFormatText("ui_fuhuo_jindi_1", relive_point_info)
    end
  elseif nx_int(relive_type) == nx_int(RELIVE_TYPE_GUILD) then
    str = gui.TextManager:GetFormatText("ui_fuhuo_guild_1", relivepoint_name)
  elseif nx_int(relive_type) == nx_int(RELIVE_TYPE_SCHOOL) then
    str = gui.TextManager:GetFormatText("ui_fuhuo_schoolfight_1", relivepoint_name)
  elseif nx_int(relive_type) == nx_int(RELIVE_TYPE_TIGUAN) then
    str = gui.TextManager:GetText("ui_tiguan_relive")
  elseif nx_int(relive_type) == nx_int(RELIVE_TYPE_WORLD_NEAR) then
    if relivepoint_name == nil or relivepoint_name == "" then
      str = gui.TextManager:GetFormatText("ui_worldwar_relive_default", "ui_zhanchang")
    else
      str = gui.TextManager:GetFormatText("ui_worldwar_relive_default", relivepoint_name)
    end
  elseif nx_int(relive_type) == nx_int(RELIVE_TYPE_LOULAN) then
    str = gui.TextManager:GetText("sys_mijing_relive")
  elseif nx_int(relive_type) == nx_int(RELIVE_TYPE_JHSCENE_HOME) then
    str = gui.TextManager:GetText("jhscene_grain_home_relive")
  elseif nx_int(relive_type) == nx_int(RELIVE_TYPE_SPECIAL) then
    str = gui.TextManager:GetText("ui_fuhuo_special")
  elseif nx_int(relive_type) == nx_int(RELIVE_TYPE_SANMENG) then
    if nx_int(relive_index) == nx_int(1) or nx_int(relive_index) == nx_int(2) then
      str = gui.TextManager:GetText("ui_sanmengwar_relive_" .. nx_string(relive_index))
    end
  elseif nx_int(relive_type) == nx_int(RELIVE_TYPE_HOME) then
    str = gui.TextManager:GetText("ui_jy_fszh_03")
  elseif nx_int(relive_type) == nx_int(RELIVE_TYPE_NEW_SCHOOL_FIGHT) then
    str = gui.TextManager:GetText("ui_gujmpzwar_relive_" .. nx_string(relive_index))
  end
  return str
end
function get_confirm_menoy(relive_type)
  if IsInJHScene() then
    if relive_type == RELIVE_TYPE_LOCAL then
      return CAPITAL_TYPE_SILVER, 10000
    elseif relive_type == RELIVE_TYPE_LOCAL_STRONG then
      return CAPITAL_TYPE_SILVER_CARD, 10000
    end
  end
  local IniManager = nx_value("IniManager")
  if not IniManager:IsIniLoadedToManager(RELIVE_INFO) then
    IniManager:LoadIniToManager(RELIVE_INFO)
  end
  local ini = IniManager:GetIniDocument(RELIVE_INFO)
  if not nx_is_valid(ini) then
    return nil, nil
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nil, nil
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return nil, nil
  end
  if relive_type == nil then
    return nil, nil
  end
  if nx_number(relive_type) < RELIVE_TYPE_RETURNCITY or nx_number(relive_type) >= RELIVE_TYPE_MAX then
    return nil
  end
  local sec_index = ini:FindSectionIndex(nx_string(RELIVE_NAME[nx_int(relive_type) + 1]))
  if sec_index < 0 then
    return nil
  end
  local money_info = ini:ReadString(sec_index, "NeedMoney", "")
  local relive_lst = nx_function("ext_split_string", money_info, ",")
  local money_type = 0
  local money_num = 0
  if table.getn(relive_lst) >= 2 then
    money_type = nx_int(relive_lst[1])
    money_num = nx_int(relive_lst[2])
    return money_type, money_num
  end
  local relive_count = nx_int(player:QueryProp("ReliveCount")) + 1
  local logic_state = player:QueryProp("LogicState")
  local base_money = 5
  if logic_state == 121 then
    if relive_type == RELIVE_TYPE_LOCAL then
      money_type = CAPITAL_TYPE_SILVER
      base_money = 5
    elseif relive_type == RELIVE_TYPE_LOCAL_STRONG then
      money_type = CAPITAL_TYPE_SILVER_CARD
      base_money = 10
    end
  elseif relive_type == RELIVE_TYPE_LOCAL then
    money_type = CAPITAL_TYPE_SILVER
    base_money = 8
  elseif relive_type == RELIVE_TYPE_LOCAL_STRONG then
    money_type = CAPITAL_TYPE_SILVER_CARD
    base_money = 16
  end
  local need_money = base_money * (5 + (relive_count - 3) * (relive_count - 3) / 2) / 5
  if relive_count <= 3 then
    need_money = base_money
  end
  return money_type, need_money * 1000
end
function check_is_enough_money(capital_type, capital_num)
  if capital_type == nil or capital_num == nil then
    return false
  end
  local capital_manager = nx_value("CapitalModule")
  if not nx_is_valid(capital_manager) then
    return false
  end
  return capital_manager:CanDecCapital(capital_type, capital_num)
end
function check_is_enough_item(relive_type)
  local IniManager = nx_value("IniManager")
  if not IniManager:IsIniLoadedToManager(RELIVE_INFO) then
    IniManager:LoadIniToManager(RELIVE_INFO)
  end
  local ini = IniManager:GetIniDocument(RELIVE_INFO)
  if not nx_is_valid(ini) then
    return false
  end
  if relive_type == "" or relive_type == nil then
    return false
  end
  local str_info = ini:ReadString(nx_string(RELIVE_NAME[nx_int(relive_type) + 1]), "NeedItem", "")
  local str_lst = nx_function("ext_split_string", str_info, "/")
  for i = 1, table.getn(str_lst) do
    local item_info = str_lst[i]
    local item_lst = nx_function("ext_split_string", item_info, ",")
    if table.getn(item_lst) == 2 then
      local item_id = nx_string(item_lst[1])
      local item_num = nx_int(item_lst[2])
      if not isHaveItem(item_id, item_num) then
        return false
      end
    end
  end
  return true
end
function isHaveItem(item_id, item_number)
  local game_client = nx_value("game_client")
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return false
  end
  local view_id = goods_grid:GetToolBoxViewport(nx_string(item_id))
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_id))
  if not nx_is_valid(view) then
    return false
  end
  local total = 0
  local viewobj_list = view:GetViewObjList()
  for i, obj in pairs(viewobj_list) do
    if nx_string(obj:QueryProp("ConfigID")) == nx_string(item_id) then
      total = total + nx_number(obj:QueryProp("Amount"))
    end
  end
  return nx_int(item_number) <= nx_int(total)
end
function GetReliveHpResumeRatio(relive_type)
  local IniManager = nx_value("IniManager")
  if not IniManager:IsIniLoadedToManager(RELIVE_INFO) then
    IniManager:LoadIniToManager(RELIVE_INFO)
  end
  local ini = IniManager:GetIniDocument(RELIVE_INFO)
  if not nx_is_valid(ini) then
    return 10
  end
  if relive_type == "" or relive_type == nil then
    return 10
  end
  local hpratio = ini:ReadString(nx_string(RELIVE_NAME[nx_int(relive_type) + 1]), "HPRate", "")
  return nx_number(hpratio)
end
function GetReliveMpResumeRatio(relive_type)
  local IniManager = nx_value("IniManager")
  if not IniManager:IsIniLoadedToManager(RELIVE_INFO) then
    IniManager:LoadIniToManager(RELIVE_INFO)
  end
  local ini = IniManager:GetIniDocument(RELIVE_INFO)
  if not nx_is_valid(ini) then
    return 10
  end
  if relive_type == "" or relive_type == nil then
    return 10
  end
  local MpRatio = ini:ReadString(nx_string(RELIVE_NAME[nx_int(relive_type) + 1]), "MPRate", "")
  return nx_number(MpRatio)
end
function isHaveMoney(capital_type, capital_num)
  local capital_manager = nx_value("CapitalModule")
  if not nx_is_valid(capital_manager) then
    return false
  end
  return capital_manager:CanDecCapital(capital_type, capital_num)
end
function get_scene_name(sceneid)
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(SCENE_INI)
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(sceneid))
  if sec_index < 0 then
    return ""
  end
  return ini:ReadString(sec_index, "Config", "")
end
function convert_money(money)
  local gui = nx_value("gui")
  local ding = math.floor(money / 1000000)
  local liang = math.floor(money % 1000000 / 1000)
  local wen = math.floor(money % 1000)
  local htmlTextYinZi = nx_widestr("")
  if 0 < ding then
    local text = gui.TextManager:GetText("ui_ding")
    local htmlText = nx_widestr(text)
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(nx_int(ding)) .. nx_widestr(htmlText)
  end
  if 0 < liang then
    local text = gui.TextManager:GetText("ui_liang")
    local htmlText = nx_widestr(text)
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(liang)) .. nx_widestr(htmlText)
  end
  if 0 < wen then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr(text)
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(wen)) .. nx_widestr(htmlText)
  end
  if money == 0 then
    htmlTextYinZi = htmlTextYinZi .. nx_widestr("0") .. nx_widestr(gui.TextManager:GetText("ui_wen"))
  end
  return htmlTextYinZi
end
function GetSceneSourceID()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return ""
  end
  local scene_res = client_scene:QueryProp("Resource")
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument("share\\rule\\maplist.ini")
  if not nx_is_valid(ini) then
    return
  end
  local section_index = ini:FindSectionIndex("MapList")
  if 0 <= section_index then
    local item_count = ini:GetSectionItemCount(section_index)
    for i = 0, item_count - 1 do
      local item_key = ini:GetSectionItemKey(section_index, i)
      local item_val = ini:GetSectionItemValue(section_index, i)
      if nx_string(item_val) == nx_string(scene_res) then
        return nx_string(item_key)
      end
    end
  end
  return ""
end
function getNearRelivePosInfo()
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local form_home_point = nx_value("form_home_point")
  if not nx_is_valid(form_home_point) then
    return
  end
  local nTerritoryCompIndex = 0
  if form_home_point:IsNewTerritoryType() then
    nTerritoryCompIndex = client_player:QueryProp("NewTerritoryCampIndex")
  end
  local x = visual_player.PositionX
  local y = visual_player.PositionY
  local z = visual_player.PositionZ
  local sourceid = GetSceneSourceID()
  local dis = 100000000
  local postion_des = ""
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument("share\\relive\\sencerelive.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(sourceid))
  if sec_index < 0 then
    return
  end
  local item_count = ini:GetSectionItemCount(sec_index)
  if item_count == 1 then
    local str = ini:GetSectionItemValue(sec_index, 0)
    local str_lst = util_split_string(str, ",")
    local nCompType = 0
    if table.getn(str_lst) >= 8 then
      nCompType = str_lst[8]
    end
    if table.getn(str_lst) >= 6 then
      if 0 ~= nCompType then
        if nx_int(nTerritoryCompIndex) == nx_int(nCompType) then
          return str_lst[6]
        end
      else
        return str_lst[6]
      end
    end
  else
    for i = 0, item_count - 1 do
      local str = ini:GetSectionItemValue(sec_index, i)
      local str_lst = util_split_string(str, ",")
      if table.getn(str_lst) >= 6 then
        local pos_x = str_lst[2]
        local pos_y = str_lst[3]
        local pos_z = str_lst[4]
        local orint = str_lst[5]
        local pos_des = str_lst[6]
        local nCompType = 0
        if table.getn(str_lst) >= 8 then
          nCompType = str_lst[8]
        end
        local tmp_dis = (pos_x - x) * (pos_x - x) + (pos_z - z) * (pos_z - z)
        if nx_int(tmp_dis) < nx_int(dis) then
          if 0 ~= nCompType then
            if nx_int(nTerritoryCompIndex) == nx_int(nCompType) then
              dis = tmp_dis
              postion_des = pos_des
            end
          else
            dis = tmp_dis
            postion_des = pos_des
          end
        end
      end
    end
  end
  return postion_des
end
function get_buff_photo(buff_id)
  if buff_id == "" or buff_id == nil then
    return ""
  end
  local IniManager = nx_value("IniManager")
  local buff_data_ini = IniManager:GetIniDocument("share\\Skill\\buff_new.ini")
  if not nx_is_valid(buff_data_ini) then
    return ""
  end
  local sec_index = buff_data_ini:FindSectionIndex(buff_id)
  if sec_index < 0 then
    return ""
  end
  local buffer_num = buff_data_ini:ReadString(sec_index, "StaticData", "")
  if buffer_num == "" then
    return
  end
  local buff_static_ini = IniManager:GetIniDocument("share\\Skill\\buff_static.ini")
  if not nx_is_valid(buff_static_ini) then
    return ""
  end
  local sec_index_num = buff_static_ini:FindSectionIndex(buffer_num)
  if sec_index_num < 0 then
    return ""
  end
  local buff_photo = buff_static_ini:ReadString(sec_index_num, "Photo", "")
  return buff_photo
end
function cancure(client_player, select_obj)
  if not nx_is_valid(client_player) or not nx_is_valid(select_obj) then
    return false
  end
  local select_type = select_obj:QueryProp("Type")
  if select_type ~= 2 then
    return false
  end
  local select_state = select_obj:QueryProp("LogicState")
  if select_state ~= 121 then
    return false
  end
  if client_player:FindProp("Mount") and string.len(client_player:QueryProp("Mount")) > 0 then
    return false
  end
  if 3 == client_player:QueryProp("BattlefieldState") then
    return false
  end
  if client_player:QueryProp("PKMode") == 3 and client_player:QueryProp("ArenaSide") ~= select_obj:QueryProp("ArenaSide") then
    return false
  end
  local fight = nx_value("fight")
  if nx_is_valid(fight) then
    if client_player:QueryProp("IsSanmeng") == 1 and fight:CanAttackPlayer(client_player, select_obj) then
      return false
    end
    local can_attack = fight:CanAttackPlayer(client_player, select_obj)
    if client_player:QueryProp("IsNewWarRule") == 1 and can_attack then
      return false
    end
    if IsInTaoShaScene() and can_attack then
      return false
    end
    if IsInApexScene() and can_attack then
      return false
    end
  end
  if client_player:QueryProp("IsJYFaucltyAttacker") ~= select_obj:QueryProp("IsJYFaucltyAttacker") then
    return false
  end
  local player_mpratio = nx_number(client_player:QueryProp("MPRatio"))
  if player_mpratio <= 40 then
    return false
  end
  local player_power_level = nx_number(client_player:QueryProp("PowerLevel"))
  local select_power_level = nx_number(select_obj:QueryProp("PowerLevel"))
  local powerdelta = player_power_level - select_power_level
  if nx_number(powerdelta) <= -40 then
    return false
  end
  local curhpratio = nx_number(client_player:QueryProp("HPRatio"))
  if nx_number(curhpratio * 2) <= nx_number(160 - powerdelta) then
    return false
  end
  local player_buffer = nx_function("find_buffer", client_player, "buf_assist_1")
  if player_buffer then
    return false
  end
  local select_buffer = nx_function("find_buffer", select_obj, "buf_assist_2")
  if select_buffer then
    return false
  end
  local is_in_cure = nx_function("find_buffer", select_obj, "buf_hurt_assist")
  if is_in_cure then
    return false
  end
  local game_visual = nx_value("game_visual")
  local visual_self_obj = game_visual:GetSceneObj(client_player.Ident)
  if not nx_is_valid(visual_self_obj) then
    return false
  end
  local visual_select_obj = game_visual:GetSceneObj(select_obj.Ident)
  if not nx_is_valid(visual_select_obj) then
    return false
  end
  local self_x = visual_self_obj.PositionX
  local self_y = visual_self_obj.PositionY
  local self_z = visual_self_obj.PositionZ
  local select_x = visual_select_obj.PositionX
  local select_y = visual_select_obj.PositionY
  local select_z = visual_select_obj.PositionZ
  local dx = select_x - self_x
  local dy = select_y - self_y
  local dz = select_z - self_z
  local MAXDISTANCE = 15
  local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
  if nx_float(dist) >= nx_float(MAXDISTANCE) then
    return false
  end
  return true
end
function curetarget(curetype, cure_target)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local select_obj = cure_target
  if select_obj == nil or not nx_is_valid(select_obj) then
    select_obj = nx_value("game_select_obj")
  end
  if not nx_is_valid(select_obj) then
    return false
  end
  if not cancure(client_player, select_obj) then
    return false
  end
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return
  end
  if nx_int(interactmgr:GetCurrentTvtType()) == nx_int(ITT_BALANCE_WAR) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  dialog.mltbox_info:Clear()
  local text = nx_widestr(util_text("ui_curetarget"))
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    if not cancure(client_player, select_obj) then
      return false
    end
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return false
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_RELIVE), RELIVE_TYPE_CURE, nx_int(curetype), nx_object(select_obj.Ident))
  end
  return true
end
function show_dead_form_delay()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindProp("Dead") then
    return
  end
  if nx_int(client_player:FindProp("Dead")) ~= nx_int(1) then
    return
  end
  local form_path = nx_string(get_die_form_res())
  if form_path == nil or form_path == "" then
    return
  end
  local form_die = util_get_form(nx_string(form_path), true)
  util_show_form(nx_string(form_path), true)
  local gui = nx_value("gui")
  if util_is_form_visible(nx_string(form_path)) then
  end
  local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
  if bMovie then
    form_die.Visible = false
    nx_execute("form_stage_main\\form_movie_new", "add_hide_control", form_die)
  end
  initial_dead_form(form_die, form_path)
end
function get_die_form_res()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local form_home_point = nx_value("form_home_point")
  if not nx_is_valid(form_home_point) then
    return
  end
  local interactmgr = nx_value("InteractManager")
  if nx_is_valid(interactmgr) and PIS_IN_GAME == interactmgr:GetInteractStatus(ITT_HUASHAN_FIGHTER) then
    return ""
  end
  if client_player:FindProp("InteractStatus") then
    local nSta = client_player:QueryProp("InteractStatus")
    if nSta == ITT_EGWAR then
      local revive_form = nx_value("form_stage_main\\form_die")
      if nx_is_valid(revive_form) and revive_form.Visible then
        revive_form.Visible = false
      end
      return ""
    end
  end
  if client_player:QueryProp("GuildWarSide") ~= 0 then
    local is_undercity = client_player:QueryProp("IsUnderGuildArea")
    if nx_int(is_undercity) ~= nx_int(1) then
      return "form_stage_main\\form_die_guildwar"
    else
      return "form_stage_main\\form_die_undercity_guildwar"
    end
  end
  if client_player:QueryProp("IsInSchoolFight") == 1 then
    return "form_stage_main\\form_die_schoolwar"
  end
  if client_player:QueryProp("BattlefieldState") == 3 then
    return "form_stage_main\\form_die_battlefield"
  end
  if client_player:QueryProp("IsInWorldWar") == 1 then
    return "form_stage_main\\form_die_world_war"
  end
  local game_scene = game_client:GetScene()
  if not nx_is_valid(game_scene) then
    return ""
  end
  if game_scene:FindProp("Level") and game_scene:FindProp("ProtoSceneID") then
    local ProtoSceneID = game_scene:QueryProp("ProtoSceneID")
    if ProtoSceneID == 100 then
      return "form_stage_main\\form_die_clone"
    end
  end
  if game_scene:FindProp("Level") then
    if not game_scene:FindProp("SourceID") then
      return ""
    end
    if form_home_point:IsNewTerritoryType() then
      return "form_stage_main\\form_die_donghai_clone"
    end
    return "form_stage_main\\form_die_clone"
  end
  if IsInJHScene() then
    if IsInLoulan() then
      return "form_stage_main\\form_die_loulan"
    else
      return "form_stage_main\\form_die_jhscene"
    end
  end
  if IsInHspMeet() then
    return "form_stage_main\\form_die_hsp_meet"
  end
  if is_guild_cross_war() then
    return "form_stage_main\\form_die_guild_cross_war"
  end
  if form_home_point:IsNewTerritoryType() then
    return "form_stage_main\\form_die_donghai"
  end
  if IsInErgWar() then
    return "form_stage_main\\form_die_erg_war"
  end
  if IsInSanMeng() then
    return "form_stage_main\\form_die_sanmeng"
  end
  if IsInBalanceWar() then
    return "form_stage_main\\form_die_balance_war"
  end
  if IsInWuDaoFighting() then
    return "form_stage_main\\form_die_wudao_war"
  end
  if IsInLuanDouFightScene() then
    return "form_stage_main\\form_die_luandou"
  end
  if IsInTaoShaScene() then
    return ""
  end
  if IsInApexScene() then
    return ""
  end
  if nx_int(IsInSanHillScene()) == nx_int(1) then
    return ""
  end
  if IsInAgreeWar() then
    return ""
  end
  if IsInGuildGlobalWar() then
    return "form_stage_main\\form_guild_global_war\\form_guild_global_war_dead"
  end
  if IsInWuDaoYanWuScene() then
    return "form_stage_main\\form_die_luandou"
  end
  if IsInGuildBalone() then
    return ""
  end
  if IsInGuildBaltwo() then
    return "form_stage_main\\form_die_guildbalance"
  end
  if IsInGuildPower() then
    return "form_stage_main\\form_die_guildpower"
  end
  if IsInLeagueMatches() then
    return "form_stage_main\\form_die_league_matches"
  end
  if IsInNewWarRule() then
    local game_type = client_player:QueryProp("BattleSubType")
    if game_type == 3 or game_type == 4 then
      return "form_stage_main\\form_die_new_school_fight"
    end
  end
  return "form_stage_main\\form_die"
end
function close_dead_form()
  local form_die = nx_value("form_stage_main\\form_die")
  if nx_is_valid(form_die) then
    form_die.Visible = false
    form_die:Close()
  end
  local form_die_clone = nx_value("form_stage_main\\form_die_clone")
  if nx_is_valid(form_die_clone) then
    form_die_clone.Visible = false
    form_die_clone:Close()
  end
  local form_die_guildwar = nx_value("form_stage_main\\form_die_guildwar")
  if nx_is_valid(form_die_guildwar) then
    form_die_guildwar.Visible = false
    form_die_guildwar:Close()
  end
  local form_die_undercity_guildwar = nx_value("form_stage_main\\form_die_undercity_guildwar")
  if nx_is_valid(form_die_undercity_guildwar) then
    form_die_undercity_guildwar.Visible = false
    form_die_undercity_guildwar:Close()
  end
  local form_die_schoolwar = nx_value("form_stage_main\\form_die_schoolwar")
  if nx_is_valid(form_die_schoolwar) then
    form_die_schoolwar.Visible = false
    form_die_schoolwar:Close()
  end
  local form_die_battlefield = nx_value("form_stage_main\\form_die_battlefield")
  if nx_is_valid(form_die_battlefield) then
    form_die_battlefield.Visible = false
    form_die_battlefield:Close()
  end
  local form_hurt_danger = nx_value("form_stage_main\\form_hurt_danger")
  if nx_is_valid(form_hurt_danger) then
    form_hurt_danger.Visible = false
    form_hurt_danger:Close()
  end
  local form_die_world_war_mingjun = nx_value("form_stage_main\\form_die_world_war")
  if nx_is_valid(form_die_world_war_mingjun) then
    form_die_world_war_mingjun.Visible = false
    form_die_world_war_mingjun:Close()
  end
  local form_die_loulan = nx_value("form_stage_main\\form_die_loulan")
  if nx_is_valid(form_die_loulan) then
    form_die_loulan.Visible = false
    form_die_loulan:Close()
  end
  local form_die_jhscene = nx_value("form_stage_main\\form_die_jhscene")
  if nx_is_valid(form_die_jhscene) then
    form_die_jhscene.Visible = false
    form_die_jhscene:Close()
  end
  local form_die_hsp_meet = nx_value("form_stage_main\\form_die_hsp_meet")
  if nx_is_valid(form_die_hsp_meet) then
    form_die_hsp_meet.Visible = false
    form_die_hsp_meet:Close()
  end
  local form_die_guild_cross_war = nx_value("form_stage_main\\form_die_guild_cross_war")
  if nx_is_valid(form_die_guild_cross_war) then
    form_die_guild_cross_war.Visible = false
    form_die_guild_cross_war:Close()
  end
  local form_die_donghai = nx_value("form_stage_main\\form_die_donghai")
  if nx_is_valid(form_die_donghai) then
    form_die_donghai.Visible = false
    form_die_donghai:Close()
  end
  local form_die_donghai_clone = nx_value("form_stage_main\\form_die_donghai_clone")
  if nx_is_valid(form_die_donghai_clone) then
    form_die_donghai_clone.Visible = false
    form_die_donghai_clone:Close()
  end
  local form_die_erg_war = nx_value("form_stage_main\\form_die_erg_war")
  if nx_is_valid(form_die_erg_war) then
    form_die_erg_war.Visible = false
    form_die_erg_war:Close()
  end
  local form_die_sanmeng = nx_value("form_stage_main\\form_die_sanmeng")
  if nx_is_valid(form_die_sanmeng) then
    form_die_sanmeng.Visible = false
    form_die_sanmeng:Close()
  end
  local form_die_balance_war = nx_value("form_stage_main\\form_die_balance_war")
  if nx_is_valid(form_die_balance_war) then
    form_die_balance_war.Visible = false
    form_die_balance_war:Close()
  end
  local form_die_wudao_war = nx_value("form_stage_main\\form_die_wudao_war")
  if nx_is_valid(form_die_wudao_war) then
    form_die_wudao_war.Visible = false
    form_die_wudao_war:Close()
  end
  local form_die_luandou = nx_value("form_stage_main\\form_die_luandou")
  if nx_is_valid(form_die_luandou) then
    form_die_luandou.Visible = false
    form_die_luandou:Close()
  end
  local form_guild_global_war = nx_value("form_stage_main\\form_guild_global_war\\form_guild_global_war_dead")
  if nx_is_valid(form_guild_global_war) then
    form_guild_global_war.Visible = false
    form_guild_global_war:Close()
  end
  local form_die_guildbalance2 = nx_value("form_stage_main\\form_die_guildbalance")
  if nx_is_valid(form_die_guildbalance2) then
    form_die_guildbalance2.Visible = false
    form_die_guildbalance2:Close()
  end
  local form_die_guildpower = nx_value("form_stage_main\\form_die_guildpower")
  if nx_is_valid(form_die_guildpower) then
    form_die_guildpower.Visible = false
    form_die_guildpower:Close()
  end
  local form_die_league_matches = nx_value("form_stage_main\\form_die_league_matches")
  if nx_is_valid(form_die_league_matches) then
    form_die_league_matches.Visible = false
    form_die_league_matches:Close()
  end
  local form_die_new_school_fight = nx_value("form_stage_main\\form_die_new_school_fight")
  if nx_is_valid(form_die_new_school_fight) then
    form_die_new_school_fight.Visible = false
    form_die_new_school_fight:Close()
  end
end
function initial_dead_form(form_die, form_path)
  if not nx_is_valid(form_die) or form_path == nil or form_path == "" then
    return
  end
  if form_path == "form_stage_main\\form_die_schoolwar" then
    local game_client = nx_value("game_client")
    if not nx_is_valid(game_client) then
      return
    end
    local player = game_client:GetPlayer()
    if not nx_is_valid(player) then
      return
    end
    local bind_state = player:QueryProp("CurBindState")
    if bind_state == 8 or bind_state == 9 or bind_state == 10 then
      close_dead_form()
      return
    end
    if not nx_find_value("school_war_dead_info") then
      return
    end
    local school_war_dead_info = nx_value("school_war_dead_info")
    if not nx_find_custom(school_war_dead_info, "sceneid") then
      return
    end
    local sceneid = school_war_dead_info.sceneid
    local num = table.getn(nx_custom_list(school_war_dead_info))
    local arg = {}
    for i = 1, num - 1 do
      if nx_find_custom(school_war_dead_info, "arg" .. nx_string(i)) then
        local tmpvalue = nx_custom(school_war_dead_info, "arg" .. nx_string(i))
        table.insert(arg, tmpvalue)
      end
    end
    nx_execute("form_stage_main\\form_die_schoolwar", "load_relive_location_info", form_die, sceneid, unpack(arg))
    return
  end
end
function CurSceneIsCloneScene()
  local game_client = nx_value("game_client")
  local scene = game_client:GetScene()
  if not nx_is_valid(scene) then
    return false
  end
  local configid = scene:QueryProp("ConfigID")
  local ini = get_ini("share\\Rule\\scenes.ini", false)
  if not nx_is_valid(ini) then
    return false
  end
  local section_count = ini:GetSectionCount()
  for i = 0, section_count - 1 do
    local item_config = ini:ReadString(i, "Config", "")
    local item_cloneable = ini:ReadString(i, "Clonable", "0")
    if nx_string(item_config) == nx_string(configid) then
      if nx_string(item_cloneable) == nx_string("1") then
        return true
      else
        return false
      end
    end
  end
end
function IsInJHScene()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local cur_jhscene_id = nx_string(client_player:QueryProp("CurJHSceneConfigID"))
  if cur_jhscene_id == "" or cur_jhscene_id == "0" then
    return false
  end
  return true
end
function IsInLoulan()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if nx_function("find_buffer", client_player, "buff_newworld_relive_mj") then
    return true
  end
  return false
end
function IsInHspMeet()
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return false
  end
  if interactmgr:GetInteractStatus(ITT_HUASHANSCHOOL_MEET) == PIS_IN_GAME then
    return true
  end
  return false
end
function is_guild_cross_war()
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return false
  end
  local resource = client_scene:QueryProp("ConfigID")
  if nx_string(resource) == nx_string("ini\\scene\\guildbattle01") then
    return true
  end
  return false
end
function IsInErgWar()
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return false
  end
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return false
  end
  local i = interactmgr:GetInteractStatus(ITT_OUTLAND_WAR)
  if interactmgr:GetInteractStatus(ITT_OUTLAND_WAR) == PIS_IN_GAME then
    return true
  end
  return false
end
function IsInSanMeng()
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return false
  end
  local resource = client_scene:QueryProp("ConfigID")
  if nx_string(resource) == nx_string("ini\\scene\\groupscene030") then
    return true
  end
  return false
end
function IsInBalanceWar()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  if not player:FindProp("BalanceWarIsInWar") then
    return false
  end
  local is_in_balance_war = player:QueryProp("BalanceWarIsInWar")
  return nx_int(is_in_balance_war) == nx_int(1)
end
function IsInBalanceWarScene()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  if not player:FindProp("InteractStatus") then
    return false
  end
  local interact_status = player:QueryProp("InteractStatus")
  return nx_int(interact_status) == nx_int(ITT_BALANCE_WAR)
end
function IsInAgreeWar()
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return false
  end
  if interactmgr:GetInteractStatus(ITT_AGREE_WAR) == PIS_IN_GAME then
    return true
  end
  return false
end
function is_in_cross_station_war()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if not client_player:FindProp("CrossType") then
    return false
  end
  local prop_value = client_player:QueryProp("CrossType")
  return nx_int(prop_value) == nx_int(28)
end
function IsInLeagueMatches()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if not client_player:FindProp("CrossType") then
    return false
  end
  local prop_value = client_player:QueryProp("CrossType")
  return nx_int(prop_value) == nx_int(32)
end
function IsInGuildGlobalWar()
  local GameShortcut = nx_value("GameShortcut")
  return GameShortcut:IsInGuildGlobalWar()
end
function IsInWuDaoFighting()
  return nx_execute("form_stage_main\\form_battlefield_wulin\\wudao_util", "is_in_wudao_fighting")
end
function IsInWuDaoScene()
  return nx_execute("form_stage_main\\form_battlefield_wulin\\wudao_util", "is_in_wudao_scene")
end
function IsInLuanDouFightScene()
  return nx_execute("form_stage_main\\form_war_scuffle\\luandou_util", "is_in_luandou_scene")
end
function IsInTaoShaScene()
  return nx_execute("form_stage_main\\form_taosha\\taosha_util", "is_in_taosha_scene")
end
function IsInApexScene()
  return nx_execute("form_stage_main\\form_taosha\\apex_util", "is_in_apex_scene")
end
function IsInSanHillScene()
  return nx_execute("form_stage_main\\form_skyhill\\form_sanhill", "is_in_sanhill")
end
function IsInWuDaoYanWuScene()
  local player = get_player()
  if not nx_is_valid(player) then
    return false
  end
  if not player:FindProp("WuDaoYanWuPlayerState") then
    return false
  end
  local nState = nx_int(player:QueryProp("WuDaoYanWuPlayerState"))
  return nState > nx_int(0)
end
function IsInGuildBalone()
  local player = get_player()
  if not nx_is_valid(player) then
    return false
  end
  if not player:FindProp("CW_TYPE") then
    return false
  end
  local nState = nx_int(player:QueryProp("CW_TYPE"))
  return nx_int(nState) == nx_int(101)
end
function IsInGuildBaltwo()
  local player = get_player()
  if not nx_is_valid(player) then
    return false
  end
  if not player:FindProp("CW_TYPE") then
    return false
  end
  local nState = nx_int(player:QueryProp("CW_TYPE"))
  return nx_int(nState) == nx_int(102)
end
function IsInGuildPower()
  local player = get_player()
  if not nx_is_valid(player) then
    return false
  end
  if not player:FindProp("CW_TYPE") then
    return false
  end
  local nState = nx_int(player:QueryProp("CW_TYPE"))
  if nx_int(nState) == nx_int(1) then
    return true
  elseif nx_int(nState) == nx_int(2) then
    return true
  end
  return false
end
function get_player()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  return client_player
end
function IsInNewWarRule()
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return false
  end
  if interactmgr:GetInteractStatus(ITT_NEW_SCHOOL_FIGHT) == PIS_IN_GAME then
    return true
  end
  return false
end
