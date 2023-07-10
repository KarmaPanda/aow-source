local table_inis = {
  "share\\skill\\qinggong_new.ini",
  "share\\skill\\qinggong_varprop.ini",
  "share\\task\\Task.ini",
  "share\\Npc\\funcnpc.ini",
  "share\\Npc\\attacknpc.ini",
  "share\\Task\\Origin\\origin.ini",
  "share\\task\\PrizeItemList.ini",
  "share\\task\\PrizePropList.ini",
  "share\\task\\AddPrizeItemList.ini",
  "share\\task\\AddPrizePropList.ini",
  "share\\Life\\jobinfo.ini",
  "share\\Life\\job_skill.ini",
  "ini\\ui\\wuxue\\wuxue_school.ini",
  "ini\\ui\\wuxue\\wuxue_zhaoshi.ini",
  "share\\Skill\\skill.ini",
  "ini\\ui\\wuxue\\wuxue_study.ini",
  "share\\Skill\\skill_varprop.ini",
  "ini\\ui\\npcheadtalk\\head_talk_info.ini",
  "ini\\ui\\npcheadtalk\\head_talk_rule.ini",
  "ini\\ui\\npcheadtalk\\npc_head_talk.ini",
  "share\\Skill\\buff_new.ini",
  "share\\Rule\\add_special_ability.ini",
  "ini\\ui\\buffer\\buff_effect.ini",
  "ini\\ui\\buffer\\buff_sound.ini",
  "share\\Task\\Movie\\MovieTalkList.ini",
  "obj\\char\\action_camera.ini",
  "ini\\effect\\effectcontent\\effect_footstep.ini",
  "ini\\effect\\effectcontent\\effect_mache.ini",
  "ini\\ui\\animation\\animation.ini",
  "ini\\systemset\\adapter.ini",
  "ini\\freshmanhelp\\camera_pos.ini",
  "ini\\equipbox.ini",
  "share\\creator\\scenenpc.ini",
  "share\\Task\\Origin\\ItemPrize.ini",
  "share\\Task\\Origin\\PropPrize.ini",
  "share\\Item\\general.ini",
  "ini\\offline\\workcloth.ini",
  "mus\\music.ini",
  "share\\Rule\\ScenePathPoint.ini",
  "share\\Skill\\skill_bullet.ini",
  "ini\\SelectBook\\books.ini",
  "share\\skill\\zhaoshi_limit.ini",
  "action_editor\\ini\\system.ini",
  "ini\\effect\\effectcontent\\weapon_trail.ini",
  "ini\\bone\\boneinfo.ini",
  "ini\\bone\\faceinfo.ini",
  "ini\\bone\\boneimage.ini",
  "ini\\ui\\animation\\login_animation.ini",
  "share\\relive\\sencerelive.ini",
  "share\\Skill\\skill_new.ini",
  "share\\Skill\\HuiHai\\huihai_skill.ini",
  "share\\Skill\\zhenfa_map.ini",
  "ini\\ui\\wuxue\\wuxue_zhenfa.ini",
  "ini\\ui\\wuxue\\wuxue_anqi.ini",
  "ini\\ui\\paoshang\\paoshanglist.ini",
  "ini\\syshelp\\syshelp.ini",
  "ini\\syshelp\\HuoDong.ini",
  "ini\\syshelp\\ShouYe.ini",
  "share\\Item\\addprop.ini",
  "ini\\ui\\wuxue\\wuxue_zhaoshi.ini",
  "ini\\ui\\life\\job_info.ini",
  "share\\Item\\life_formula.ini",
  "gui\\map\\maplist.ini",
  "ini\\wuxueshop.ini",
  "ini\\ui\\inforecord.ini",
  "config\\systeminfo.ini",
  "ini\\ui\\fightword\\fightword.ini",
  "ini\\ui\\zhaomu\\zhaomulist.ini",
  "share\\area\\AreaProp.ini",
  "share\\MiniGame\\findpic.ini",
  "share\\Life\\ConnectGame.ini",
  "share\\Life\\ForgeGame.ini",
  "share\\Life\\FortuneTellingGame.ini",
  "share\\Life\\JingmaiGame.ini",
  "share\\Activity\\day_signature.ini",
  "share\\Rule\\Vote.ini",
  "share\\Life\\Qin.ini",
  "share\\Life\\QinGame.ini",
  "share\\Life\\fortunetelling.ini",
  "share\\Item\\tool_item.ini",
  "share\\Rule\\CountLimit.ini",
  "share\\Rule\\TimeLimit.ini",
  "share\\Rule\\present.ini",
  "share\\Rule\\qifu.ini",
  "share\\Item\\item_ride.ini",
  "ini\\ui\\clonescene\\clonescenedesc.ini",
  "ini\\ui\\clonescene\\clonenpcdesc.ini",
  "share\\War\\schoolfight_attackpoint.ini",
  "share\\War\\schoolfight_defendpoint.ini",
  "share\\War\\schoolfight_guildpoint.ini",
  "ini\\ui\\relive\\schoolfight_maprange.ini",
  "ini\\ui\\schoolfight\\schoolfight_mapinfo.ini"
}
local table_form = {
  "form_stage_main\\form_sys_notice",
  "head\\form_head_npc_normal",
  "head\\form_head_game"
}
local table_particles_file = {
  "ini\\particles\\guoguo.ini",
  "ini\\particles\\hejian.ini",
  "ini\\particles\\particles.ini",
  "ini\\particles\\particlesohho2.ini",
  "ini\\particles\\particles_2011.ini",
  "ini\\particles\\particles_d.ini",
  "ini\\particles\\particles_dhf.ini",
  "ini\\particles\\particles_g.ini",
  "ini\\particles\\particles_gin.ini",
  "ini\\particles\\particles_gwy.ini",
  "ini\\particles\\particles_haku.ini",
  "ini\\particles\\particles_jff.ini",
  "ini\\particles\\particles_jq.ini",
  "ini\\particles\\particles_ldj.ini",
  "ini\\particles\\particles_lhl.ini",
  "ini\\particles\\particles_lits.ini",
  "ini\\particles\\particles_lp.ini",
  "ini\\particles\\particles_lx.ini",
  "ini\\particles\\particles_lzx.ini",
  "ini\\particles\\particles_mz.ini",
  "ini\\particles\\particles_mz2.ini",
  "ini\\particles\\particles_sl.ini",
  "ini\\particles\\particles_wjl.ini",
  "ini\\particles\\particles_wn.ini",
  "ini\\particles\\particles_yj.ini",
  "ini\\particles\\particles_yl.ini",
  "ini\\particles\\particles_ys.ini",
  "ini\\particles\\particles_ys02.ini",
  "ini\\particles\\particles_zdg.ini",
  "ini\\particles\\particles_zk.ini",
  "ini\\particles\\particles_zl.ini",
  "ini\\particles\\particles_zmt.ini",
  "ini\\particles\\particles_zrx.ini",
  "ini\\particles\\particles_zxy.ini",
  "ini\\particles\\particles_zyc.ini",
  "ini\\particles\\particles_zzy.ini",
  "ini\\particles\\yanweijian.ini"
}
function game_form_preload_load()
  for i = 1, table.getn(table_form) do
    nx_call("util_gui", "util_get_form", table_form[i], true, true)
  end
end
function game_form_preload_clear()
  for i = 1, table.getn(table_form) do
    local form = nx_value(table_form[i])
    if nx_is_valid(form) then
      form:Close()
      if nx_is_valid(form) then
        nx_destroy(form)
      end
    end
  end
end
function game_preload_load()
  image_preload_load()
  ini_preload_load()
  local world = nx_value("world")
  world:LoadCache(nx_resource_path() .. "skin\\head\\form_head_npc_normal.xml")
  world:LoadCache(nx_resource_path() .. "skin\\head\\form_head_game.xml")
  world:LoadCache(nx_resource_path() .. "skin\\head\\form_head_npc_special.xml")
  world:LoadCacheIni(nx_resource_path() .. "ini\\effect\\model.ini", true)
  for i = 1, table.maxn(table_particles_file) do
    world:LoadCacheIni(nx_resource_path() .. nx_string(table_particles_file[i]), true)
  end
  world:LoadCacheIni(nx_resource_path() .. "map\\ini\\particles_mdl.ini", true)
  world:LoadCacheIni(nx_resource_path() .. "map\\ini\\particles_scene.ini", true)
  world:LoadCacheIni(nx_resource_path() .. "ini\\lights\\lights.ini", true)
  world:LoadCacheIni(nx_resource_path() .. "ini\\saberarc\\saberarc.ini", true)
  world:LoadCacheIni(nx_resource_path() .. "obj\\actionlibrary\\malenpc\\index.ini", true)
  world:LoadCacheIni(nx_resource_path() .. "obj\\actionlibrary\\malenpc\\index_atk.ini", true)
  world:LoadCacheIni(nx_resource_path() .. "obj\\actionlibrary\\malenpc\\index_clone.ini", true)
  world:LoadCacheIni(nx_resource_path() .. "obj\\actionlibrary\\femalenpc\\index.ini", true)
  world:LoadCacheIni(nx_resource_path() .. "obj\\actionlibrary\\femalenpc\\index_atk.ini", true)
  world:LoadCacheIni(nx_resource_path() .. "obj\\actionlibrary\\femalenpc\\index_clone.ini", true)
end
function game_preload_clear()
  image_preload_clear()
  ini_preload_clear()
  local world = nx_value("world")
  world:UnloadAllCache()
end
function image_preload_load()
  nx_execute("util_gui", "util_get_form", "form_image_preload", true, true)
end
function image_preload_clear()
  local form_image_preload = nx_value("form_image_preload")
  if nx_is_valid(form_image_preload) then
    nx_destroy(form_image_preload)
  end
end
function ini_preload_load()
  local ini_manager = nx_value("IniManager")
  if not nx_is_valid(ini_manager) then
    return
  end
  for i = 1, table.getn(table_inis) do
    ini_manager:LoadIniToManager(nx_string(table_inis[i]))
  end
end
function ini_preload_clear()
  local ini_manager = nx_value("IniManager")
  if not nx_is_valid(ini_manager) then
    return
  end
  for i = 1, table.maxn(table_inis) do
    ini_manager:UnloadIniFromManager(nx_string(table_inis[i]))
  end
end
