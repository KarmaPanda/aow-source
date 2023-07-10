require("util_functions")
function cool_manager_init(cool_manager)
  cool_manager:SetDefCoolSize(48, 48)
  local gui = nx_value("gui")
  cool_manager.AnimationMng = gui.AnimationManager
  cool_manager.AnimationTime = 0
  cool_manager:SetCommonCoolRange(0, 100, 2000)
  cool_manager:SetCommonCoolRange(1, 2000, 19999)
  cool_manager:SetCommonCoolRange(2, 24000, 29999)
  cool_manager:SetCommonTeamCoolRange(50000, 50001, 51000)
  cool_manager:SetCommonTeamCoolNoEffectRange(50000, 50001, 50100)
  local cool_logic_manager = util_get_global_entity("cool_logic_manager", "CoolLogicManager", true)
  if nx_is_valid(cool_logic_manager) then
    cool_logic_manager.CoolManagerID = cool_manager
  end
end
