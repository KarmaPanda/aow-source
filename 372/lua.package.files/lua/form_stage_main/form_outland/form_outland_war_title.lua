require("utils")
require("util_gui")
require("util_functions")
local OUTLAND_STAGE = {
  [1] = "1",
  [2] = "2",
  [3] = "3",
  [4] = "4"
}
local TVT_OUTLAND_WAR_TITLE = 92
function getStrByStage(stageid)
  if stageid == nil or stageid <= 0 or stageid > table.getn(OUTLAND_STAGE) then
    return nil
  end
  return OUTLAND_STAGE[stageid]
end
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_update_scene_info", self, -1, -1)
  return 1
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_scene_info", self)
  nx_destroy(self)
end
function on_open_outland_war_map()
  util_auto_show_hide_form("form_stage_main\\form_outland\\form_outland_eren_warmap")
end
function on_ready()
  check_on_off_this()
end
function get_client_scene()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nil
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return nil
  end
  return client_scene
end
function get_outland_war_scene()
  local ini = nx_execute("util_functions", "get_ini", "share\\WorldEvent\\bad_guy_vally.ini")
  if nx_is_valid(ini) then
    local sec_index = ini:FindSectionIndex(nx_string("Stages"))
    local content = ini:ReadInteger(sec_index, nx_string("SceneID"), 0)
    if content ~= 0 then
      return content
    end
  end
  return nil
end
function check_on_off_this()
  local client_scene = get_client_scene()
  if client_scene == nil then
    return
  end
  local scene_res_name = client_scene:QueryProp("Resource")
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return
  end
  local map_id = nx_int(map_query:GetSceneId(scene_res_name))
  local war_scene_id = get_outland_war_scene()
  if war_scene_id == nil then
    return
  end
  if map_id == nx_int(war_scene_id) then
    util_show_form("form_stage_main\\form_outland\\form_outland_eren_war_title", true)
    nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "add_form", 0, TVT_OUTLAND_WAR_TITLE)
  else
    util_show_form("form_stage_main\\form_outland\\form_outland_eren_war_title", false)
    nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "del_form", 0, TVT_OUTLAND_WAR_TITLE)
  end
end
function on_update_scene_info(form, param1, param2)
  local client_scene = get_client_scene()
  if client_scene == nil then
    return
  end
  local outlandscore = client_scene:QueryProp("OutLandScore")
  local locallandscore = client_scene:QueryProp("MainLandScore")
  if not nx_find_custom(form, "last_stage") then
    form.last_stage = 0
  end
  if not nx_find_custom(form, "last_outland_score") then
    form.last_outland_score = -1
  end
  if not nx_find_custom(form, "last_localland_score") then
    form.last_localland_score = -1
  end
  if outlandscore ~= form.last_outland_score then
    form.lbl_7.Text = nx_widestr(outlandscore)
  end
  if locallandscore ~= form.last_localland_score then
    form.lbl_8.Text = nx_widestr(locallandscore)
  end
  if outlandscore ~= form.last_outland_score and locallandscore ~= form.last_localland_score then
    if outlandscore + locallandscore ~= 0 then
      form.pbar_1.Value = outlandscore * 100 / (outlandscore + locallandscore)
      form.pbar_2.Value = locallandscore * 100 / (outlandscore + locallandscore)
    else
      form.pbar_1.Value = 0
      form.pbar_2.Value = 0
    end
  end
  local badguy_vally_stage = client_scene:QueryProp("BadGuyVallyStage")
  if badguy_vally_stage ~= form.last_stage then
    local stage_str = OUTLAND_STAGE[badguy_vally_stage]
    if stage_str ~= nil then
      form.lbl_6.Text = nx_widestr(stage_str)
      local bVisible = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_outland\\form_outland_eren_warmap")
      if bVisible then
        local map_form = nx_value("form_stage_main\\form_outland\\form_outland_eren_warmap")
        if nx_is_valid(map_form) then
          nx_execute("form_stage_main\\form_outland\\form_outland_war_map", "on_update_stage", map_form, badguy_vally_stage)
        end
      end
    end
  end
  form.last_outland_score = outlandscore
  form.last_localland_score = locallandscore
  form.last_stage = badguy_vally_stage
end
function get_cur_outland_stageid(self)
  if not nx_find_custom(self, "last_stage") then
    return nil
  end
  return self.last_stage
end
