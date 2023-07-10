require("util_functions")
function rp_GetRoleMingCheng()
  local sock = nx_value("game_sock")
  if nx_is_valid(sock) then
    local receiver = sock.Receiver
    local role_name = receiver:GetRoleName(0)
    return role_name
  end
  return ""
end
function rp_GetRoleInfo()
  local sock = nx_value("game_sock")
  if nx_is_valid(sock) then
    local receiver = sock.Receiver
    local role_info = receiver:GetRolePara(0)
    return role_info
  end
  return ""
end
function rp_GetRoleShengMing()
  return nx_int(100)
end
function rp_GetRoleFaLi()
  return nx_int(50)
end
function rp_GetRoleDengJi()
  return nx_int(0)
end
function rp_GetRoleMenPai()
  return nx_widestr(util_text("ui_MenPai"))
end
function rp_GetRoleXiuWei()
  return nx_widestr(util_text("ui_XiuWei"))
end
function rp_GetRoleShanE()
  return nx_widestr(util_text("ui_ShanE"))
end
function rp_GetRoleJingYan()
  return nx_widestr(util_text("ui_JingYan"))
end
function rp_GetRoleMenPai2()
  return nx_widestr(util_text("ui_MenPai2"))
end
function rp_GetRoleGongXian()
  return nx_widestr(util_text("ui_Contribution"))
end
function rp_GetRoleBangHui()
  return nx_widestr(util_text("ui_BangHui"))
end
function rp_GetRoleRongYu()
  return nx_widestr(util_text("ui_Hornor"))
end
function rp_GetRoleLiLiang()
  return nx_int(0)
end
function rp_GetRoleMinJie()
  return nx_int(0)
end
function rp_GetRoleNeiLi()
  return nx_int(0)
end
function rp_GetRoleTiZhi()
  return nx_int(0)
end
function rp_GetRoleJingShen()
  return nx_int(0)
end
function rp_GetRoleWuGong()
  return nx_int(0)
end
function rp_GetRoleWuFang()
  return nx_int(0)
end
function rp_GetRoleFaGong()
  return nx_int(0)
end
function rp_GetRoleFaFang()
  return nx_int(0)
end
function rp_GetRolePropPoint()
  return nx_int(100)
end
function rp_GetRoleTeamMark()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if nx_is_valid(client_player) and client_player:FindProp("TeamMark") then
    return client_player:QueryProp("TeamMark")
  end
  return 0
end
function rp_SetRoleLiLiang()
end
function rp_SetRoleMinJie()
end
function rp_SetRoleNeiLi()
end
function rp_SetRoleTiZhi()
end
function rp_SetRoleJingShen()
end
function rp_LiLiangOnePoint()
  return 5, 1, 0, 0
end
function rp_MinJieOnePoint()
  return 2, 3, 0, 1
end
function rp_NeiLiOnePoint()
  return 1, 1, 3, 2
end
function rp_TiZhiOnePoint()
  return 0, 5, 0, 3
end
function rp_JingShenOnePoint()
  return 0, 0, 5, 1
end
function rp_GetTouXiang()
  return nx_string("gui\\icon\\monk.png")
end
function role_is_dead()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if nx_is_valid(client_player) and client_player:FindProp("Dead") and client_player:QueryProp("Dead") > 0 then
    return true
  end
  return false
end
function is_newjhmodule()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if not client_player:FindProp(nx_string("CurJHSceneConfigID")) then
    return false
  end
  return nx_string(client_player:QueryProp(nx_string("CurJHSceneConfigID"))) ~= ""
end
