require("util_gui")
require("form_stage_main\\form_guildbuilding\\guildbuilding_getinfo")
local REMOVE_FROM_PLAYER_ALL = 0
local REMOVE_FROM_PLAYER_NONE = 1
local REMOVE_FROM_PLAYER_CAPITALTYPE = 2
local REMOVE_FROM_PLAYER_GOODS = 3
local CLIENT_CUSTOMMSG_GUILDBUILDING = 1016
local pic_name_table = {
  ["5"] = "fangputuan",
  ["4"] = "meihuazhuang",
  ["1"] = "murenzhuang",
  ["2"] = "yuanputuan",
  ["3"] = "yuanputuan"
}
function main_form_init(form)
  form.Fixed = false
  form.npc_id = nil
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  show_upgrade_kengwei_condition(form)
  show_info_change(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_guildbuilding\\form_guildbuilding_upgrade_kengwei", nx_null())
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(4), form.npc_id)
  form:Close()
  return 1
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
  return 1
end
function show_upgrade_kengwei_condition(form)
  local gb_manager = nx_value("GuildbuildingManager")
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local condition = nx_widestr(gui.TextManager:GetText("ui_shenghuo0005")) .. nx_widestr(" ") .. nx_widestr("<BR>")
  local ident = nx_string(form.npc_id)
  local npc = game_client:GetSceneObj(ident)
  if not nx_is_valid(npc) then
    return false
  end
  local package_id = npc:QueryProp("AttributeBag")
  local Package_infos = gb_manager:GetKengWeiNpcPackageInfo(nx_int(package_id))
  local npc_type = Package_infos[1]
  local pre_pic_name = pic_name_table[nx_string(npc_type)]
  local func_level = npc:QueryProp("FuncLevel")
  form.lbl_old_title.Text = nx_widestr(gui.TextManager:GetText("ui_kengwei_level_" .. nx_string(func_level)))
  form.lbl_new_title.Text = nx_widestr(gui.TextManager:GetText("ui_kengwei_level_" .. nx_string(func_level + 1)))
  local pic_name = pre_pic_name .. nx_string(func_level)
  form.lbl_old_pic.BackImage = "gui\\guild\\kengwei\\" .. pic_name .. ".png"
  pic_name = pre_pic_name .. nx_string(func_level + 1)
  form.lbl_new_pic.BackImage = "gui\\guild\\kengwei\\" .. pic_name .. ".png"
  local infos = gb_manager:GetUpgradeKengWeiItemsInfo(nx_int(package_id))
  local remove_type = infos[1]
  local gold = infos[2]
  if nx_int(gold) > nx_int(0) then
    local head_str = nx_widestr(gui.TextManager:GetText("19308")) .. nx_widestr("-")
    local ui_gold = nx_widestr(gui.TextManager:GetText("ui_offline_form_jinbi"))
    condition = condition .. head_str .. ui_gold .. " : "
    local gold_text = nx_execute("util_functions", "trans_capital_string", gold)
    condition = condition .. nx_string(gold_text) .. " "
  end
  local silver = infos[3]
  if nx_int(silver) > nx_int(0) then
    local head_str = nx_widestr(gui.TextManager:GetText("19308")) .. nx_widestr("-")
    if remove_type == REMOVE_FROM_PLAYER_NONE or remove_type == REMOVE_FROM_PLAYER_GOODS then
      head_str = nx_widestr(gui.TextManager:GetText("19307")) .. nx_widestr("-")
    end
    local ui_silver = nx_widestr(gui.TextManager:GetText("ui_silvermoney"))
    condition = condition .. head_str .. ui_silver .. ":"
    local silver_text = nx_execute("util_functions", "trans_capital_string", silver)
    form.lbl_money.HtmlText = nx_widestr(nx_string(silver_text) .. "<img src=\"gui\\common\\money\\yyb.png\" valign=\"center\" data=\"\" />")
    condition = condition .. nx_string(silver_text) .. " "
  end
  local size = table.getn(infos)
  local item_count = (size - 3) / 2
  if 0 < item_count then
    local head_str = nx_widestr(gui.TextManager:GetText("19309")) .. nx_widestr("-")
    if remove_type == REMOVE_FROM_PLAYER_NONE or remove_type == REMOVE_FROM_PLAYER_CAPITALTYPE then
      head_str = nx_widestr(gui.TextManager:GetText("19306")) .. nx_widestr("-")
    end
    condition = condition .. head_str
    for i = 1, item_count do
      local config = infos[4 + (i - 1) * 2]
      local count = infos[4 + (i - 1) * 2 + 1]
      local str_config = nx_widestr(gui.TextManager:GetText(config))
      condition = condition .. nx_string(str_config) .. "x" .. nx_string(count) .. " "
    end
  end
end
function show_info_change(form)
  local ident = nx_string(form.npc_id)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local npc = game_client:GetSceneObj(ident)
  if not nx_is_valid(npc) then
    return false
  end
  local build_npc = game_client:GetSceneObj(nx_string(npc:QueryProp("BelongGuildBuilding")))
  if not nx_is_valid(build_npc) then
    return false
  end
  local gui = nx_value("gui")
  local main_type = build_npc:QueryProp("MainType")
  local sub_type = build_npc:QueryProp("SubType")
  local level = npc:QueryProp("FuncLevel")
  local gb_manager = nx_value("GuildbuildingManager")
  local infos = gb_manager:GetZhenFaInfo(sub_type, level)
  local id = 0
  if table.getn(infos) >= 2 then
    id = infos[1]
  end
  infos = gb_manager:GetZhenFaInfo(sub_type, level + 1)
  id = 0
  if table.getn(infos) >= 2 then
    id = infos[1]
  end
  local package_id = npc:QueryProp("AttributeBag")
  local Package_infos = gb_manager:GetKengWeiNpcPackageInfo(nx_int(package_id))
  local str = "ui_xiulian_add_speed"
  local old_speed_wstr = nx_widestr(gui.TextManager:GetText(str)) .. nx_widestr(Package_infos[9] * 10) .. nx_widestr("%")
  form.lbl_old_zhenfa.Text = nx_widestr(old_speed_wstr)
  local xiuwei = nx_widestr(gui.TextManager:GetText("ui_talk_movie_xiuwei")) .. nx_widestr(Package_infos[6])
  form.lbl_old_xiuwei.Text = nx_widestr(xiuwei)
  local lilian = nx_widestr(gui.TextManager:GetText("ui_talk_movie_lilian")) .. nx_widestr(nx_int(Package_infos[7] / 1000))
  form.lbl_old_lilian.Text = nx_widestr(lilian)
  local life_exp = nx_widestr(gui.TextManager:GetText("ui_xiulian_add_life_exp")) .. nx_widestr(Package_infos[8])
  form.lbl_old_exp.Text = nx_widestr(life_exp)
  local new_Package_infos = gb_manager:GetKengWeiNpcPackageInfo(nx_int(package_id + 1))
  local str = "ui_xiulian_add_speed"
  speed_wstr = nx_widestr(gui.TextManager:GetText(str)) .. nx_widestr(new_Package_infos[9] * 10) .. nx_widestr("%")
  form.lbl_new_zhenfa.Text = nx_widestr(speed_wstr)
  local xiuwei = nx_widestr(gui.TextManager:GetText("ui_talk_movie_xiuwei")) .. nx_widestr(new_Package_infos[6])
  form.lbl_new_xiuwei.Text = nx_widestr(xiuwei)
  local lilian = nx_widestr(gui.TextManager:GetText("ui_talk_movie_lilian")) .. nx_widestr(nx_int(new_Package_infos[7] / 1000))
  form.lbl_new_lilian.Text = nx_widestr(lilian)
  local life_exp = nx_widestr(gui.TextManager:GetText("ui_xiulian_add_life_exp")) .. nx_widestr(new_Package_infos[8])
  form.lbl_new_exp.Text = nx_widestr(life_exp)
  return
end
