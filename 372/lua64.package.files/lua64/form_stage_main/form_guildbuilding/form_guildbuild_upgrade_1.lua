require("util_gui")
require("game_object")
require("tips_func_equip")
require("util_static_data")
require("define\\tip_define")
require("share\\view_define")
require("define\\sysinfo_define")
require("share\\client_custom_define")
require("form_stage_main\\form_guildbuilding\\guildbuilding_getinfo")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
require("util_functions")
local REMOVE_FROM_PLAYER_ALL = 0
local REMOVE_FROM_PLAYER_NONE = 1
local REMOVE_FROM_PLAYER_CAPITALTYPE = 2
local REMOVE_FROM_PLAYER_GOODS = 3
local MAX_BUILDING_LEVEL = 5
local MENU_GUILDBUILDING_REVERT = 809000103
function auto_show_hide_form_guildbuild_upgrade_1(show)
  local skin_path = "form_stage_main\\form_guildbuilding\\form_guild_build_upgrade_1"
  local form = nx_value(skin_path)
  if nx_is_valid(form) and form.Visible == show then
    return
  end
  if show == nil then
    if not nx_is_valid(form) then
      util_show_form(skin_path, true)
    else
      form.Visible = not form.Visible
    end
  else
    if not nx_is_valid(form) then
      util_show_form(skin_path, true)
    end
    local form = nx_value(skin_path)
    form.Visible = show
  end
  local form = nx_value(skin_path)
  ui_show_attached_form(form)
end
function main_form_init(self)
  self.Fixed = false
  self.main_type = 1
  self.sub_type = 1
  self.level = 0
  self.npcid = nil
  self.stopLeftTime = 0
  self.coolLeftTime = 0
  self.kengweiCount = 0
  self.received = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Fixed = false
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.btn_2.Visible = false
  form.btn_3.Visible = false
  form.btn_4.Visible = false
  form.btn_5.Visible = false
  form.btn_6.Visible = false
  form.lbl_4.Visible = false
  form.lbl_5.Visible = false
  form.lbl_6.Visible = false
  form.lbl_7.Visible = false
  form.lbl_8.Visible = false
  form.groupbox_left.Visible = false
  form.groupbox_left_1.Visible = false
  form.groupbox_upgrading.Visible = false
  form.groupscrollbox_1.Visible = false
  form.btn_upgrade.Visible = false
  form.groupbox_level5.Visible = false
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:Register(1000, -1, nx_current(), "update_upgrading", form, -1, -1)
  end
  return 1
end
function on_main_form_close(form)
  ui_destroy_attached_form(form)
  local door_npc = form.npcid
  local child = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_banghuicangku_contributemoneyconfirm")
  if nx_is_valid(child) then
    child:Close()
    nx_destroy(child)
    nx_set_value("form_stage_main\\form_guildbuilding\\form_guild_build_banghuicangku_contributemoneyconfirm", nx_null())
  end
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_guildbuilding\\form_guild_build_upgrade_1", nx_null())
  nx_execute("tips_game", "hide_tip", form)
  local game_timer = nx_value("timer_game")
  game_timer:UnRegister(nx_current(), "update_upgrading", form)
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function on_btn_upgrade_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  if nx_int(form.stopLeftTime) == nx_int(0) and nx_int(form.coolLeftTime) == nx_int(0) then
    game_visual:CustomSend(nx_int(1016), nx_int(1), form.npcid)
  end
  form:Close()
  return 1
end
function on_btn_buy_kw_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local buy_form = nx_value("form_stage_main\\form_guildbuilding\\form_guildbuilding_buykengwei")
  if not nx_is_valid(buy_form) then
    buy_form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guildbuilding\\form_guildbuilding_buykengwei", true, false)
    nx_set_value("form_stage_main\\form_guildbuilding\\form_guildbuilding_buykengwei", buy_form)
  end
  buy_form.npcid = form.npcid
  buy_form.type = form.sub_type
  buy_form.level = form.level
  buy_form.kengweiNum = form.kengweiCount
  buy_form:Show()
  buy_form.Visible = true
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
  return 1
end
function on_recv_houseinfo(...)
  local gui = nx_value("gui")
  local size = table.getn(arg)
  if size < 9 then
    return 0
  end
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_upgrade_1")
  if not nx_is_valid(form) then
    if nx_int(arg[2]) == nx_int(1) then
      auto_show_hide_form_guildbuild_upgrade_1(true)
      form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_upgrade_1")
      nx_set_value("form_stage_main\\form_guildbuilding\\form_guild_build_upgrade_1", form)
    else
      return 0
    end
  end
  form.main_type = nx_int(arg[1])
  form.sub_type = nx_int(arg[3])
  form.npcid = arg[4]
  local level = nx_int(arg[5])
  form.level = level
  form.stopLeftTime = arg[6]
  form.coolLeftTime = arg[7]
  form.funcid = nx_int(arg[8])
  local kengweiNum = nx_int(arg[9])
  form.kengweiCount = kengweiNum
  form:Show()
  form.Visible = true
  nx_execute("util_gui", "ui_show_attached_form", form)
  local argSize = table.getn(arg)
  local now_goods_list = {}
  for i = 10, argSize do
    now_goods_list[i - 9] = arg[i]
  end
  local guildbuilding_Manager = nx_value("GuildbuildingManager")
  if form.level == 0 then
    form.btn_buy_kw.Enabled = false
  else
    form.btn_buy_kw.Enabled = true
  end
  form.lbl_title.Text = get_building_name(form.main_type, form.sub_type)
  local bulid_desc = get_building_content(form.main_type, form.sub_type)
  form.mltbox_build_desc:Clear()
  form.mltbox_build_desc:AddHtmlText(nx_widestr(bulid_desc), -1)
  form.lbl_building_name.Text = get_level_change_text(form)
  form.lbl_building_name_upgrade.Text = get_level_change_text(form)
  form.lbl_building_name_copy.Text = get_level_change_text(form)
  form.lbl_zx_name.Text = get_cur_level_name(form)
  show_pic_change(form)
  form.received = true
  show_info_change(form)
  form.mltbox_condition.HtmlText = add_condition_info(form.main_type, form.sub_type, level, now_goods_list)
  form.btn_upgrade.Enabled = true
  if 0 < form.stopLeftTime or 0 < form.coolLeftTime then
    form.btn_upgrade.Enabled = false
    form.groupscrollbox_1.Visible = false
    form.groupbox_upgrading.Visible = true
    form.pbar_upgrading.Maximum = 100
    form.pbar_upgrading.Value = (form.upgrade_time - form.stopLeftTime) / form.upgrade_time * 100
    local game_timer = nx_value("timer_game")
    if nx_is_valid(game_timer) then
      update_upgrading(form)
      game_timer:UnRegister(nx_current(), "update_upgrading", form)
      game_timer:Register(1000, -1, nx_current(), "update_upgrading", form, -1, -1)
    end
  else
    if form.groupbox_level5.Visible then
      form.groupscrollbox_1.Visible = false
    else
      form.groupscrollbox_1.Visible = true
    end
    form.groupbox_upgrading.Visible = false
  end
  return 1
end
function update_upgrading(form)
  if form.stopLeftTime <= 0 and 0 >= form.coolLeftTime then
    return
  end
  local value = (form.upgrade_time - form.stopLeftTime) / form.upgrade_time * 100
  if value >= form.pbar_upgrading.Maximum then
    local game_timer = nx_value("timer_game")
    game_timer:UnRegister(nx_current(), "update_upgrading", form)
    form:Close()
  else
    form.pbar_upgrading.Value = value
    form.stopLeftTime = form.stopLeftTime - 1000
    form.lbl_11.Text = nx_widestr(transform_time(form.stopLeftTime))
  end
end
function on_recv_kengweinum(...)
  local size = table.getn(arg)
  if size < 9 then
    return 0
  end
end
function show_kengwei_count(form, sub_type, level, cur_count, next_level)
  local gb_manager = nx_value("GuildbuildingManager")
  local gui = nx_value("gui")
  local infos = gb_manager:GetZhenFaInfo(sub_type, level)
  local max_count = 0
  if table.getn(infos) >= 2 then
    max_count = infos[2]
  end
  if next_level == 0 then
    form.btn_buy_kw.Enabled = true
    if nx_int(cur_count) >= nx_int(max_count) then
      form.btn_buy_kw.Enabled = false
    end
  end
  local str = "ui_kengwei_type_" .. nx_string(sub_type)
  local r = nx_widestr(gui.TextManager:GetText(str)) .. nx_widestr(" : ") .. nx_widestr(cur_count) .. nx_widestr("/") .. nx_widestr(max_count)
  if level == 5 then
    form.lbl_kw.Text = nx_widestr(nx_string(cur_count) .. nx_string("/") .. nx_string(max_count))
  end
  local wstr = nx_widestr(r)
  return wstr
end
function show_pic_change(form)
  local gb_manager = nx_value("GuildbuildingManager")
  if form.level == 0 or form.level == 5 then
    form.lbl_build_pic.BackImage = nx_resource_path() .. "gui\\guild\\preview\\" .. gb_manager:GetPreview(nx_int(form.main_type), nx_int(form.sub_type), nx_int(form.level))
    form.groupbox_left_1.Visible = true
    form.groupbox_left.Visible = false
    form.mltbox_info:Clear()
    local bulid_desc = get_building_content(form.main_type, form.sub_type)
    form.mltbox_info:AddHtmlText(nx_widestr(bulid_desc), -1)
    if form.level == 5 then
      form.groupscrollbox_1.Visible = false
      form.groupbox_upgrading.Visible = false
      final_cost(form)
      form.groupbox_level5.Visible = true
    end
  else
    local old_pic = gb_manager:GetPreview(nx_int(form.main_type), nx_int(form.sub_type), nx_int(form.level))
    local new_pic = gb_manager:GetPreview(nx_int(form.main_type), nx_int(form.sub_type), nx_int(form.level + 1))
    form.lbl_old_pic.BackImage = nx_resource_path() .. "gui\\guild\\preview\\" .. old_pic
    form.lbl_new_pic.BackImage = nx_resource_path() .. "gui\\guild\\preview\\" .. new_pic
    form.groupbox_left.Visible = true
    form.groupbox_left_1.Visible = false
  end
  return
end
function show_info_change(form)
  local gui = nx_value("gui")
  local main_type = form.main_type
  local sub_type = form.sub_type
  local level = form.level
  form.mltbox_upgrade_info:Clear()
  form.mltbox_upgrade_new_info:Clear()
  local gb_manager = nx_value("GuildbuildingManager")
  local infos = gb_manager:GetZhenFaInfo(sub_type, level)
  local id = 0
  if table.getn(infos) >= 2 then
    id = infos[1]
  end
  local zhenfa_wstr = nx_widestr(gui.TextManager:GetText("ui_guildbuilding_zhenfa_" .. nx_string(id)))
  form.mltbox_upgrade_info:AddHtmlText(nx_widestr(zhenfa_wstr), -1)
  local kengwei = show_kengwei_count(form, form.sub_type, level, form.kengweiCount, 0)
  form.mltbox_upgrade_info:AddHtmlText(nx_widestr(kengwei), -1)
  local zhenfa_desc = nx_widestr(gui.TextManager:GetText("ui_guildbuilding_zhenfa_desc_" .. nx_string(id)))
  form.mltbox_upgrade_info:AddHtmlText(nx_widestr(zhenfa_desc), -1)
  infos = gb_manager:GetZhenFaInfo(sub_type, level + 1)
  id = 0
  if table.getn(infos) >= 2 then
    id = infos[1]
  end
  zhenfa_wstr = nx_widestr(gui.TextManager:GetText("ui_guildbuilding_zhenfa_" .. nx_string(id)))
  form.mltbox_upgrade_new_info:AddHtmlText(nx_widestr(zhenfa_wstr), -1)
  kengwei = show_kengwei_count(form, form.sub_type, level + 1, form.kengweiCount, 1)
  form.mltbox_upgrade_new_info:AddHtmlText(nx_widestr(kengwei), -1)
  zhenfa_desc = nx_widestr(gui.TextManager:GetText("ui_guildbuilding_zhenfa_desc_" .. nx_string(id)))
  form.mltbox_upgrade_new_info:AddHtmlText(nx_widestr(zhenfa_desc), -1)
  local level_info = get_building_level_info_desc(main_type, sub_type, level)
  form.mltbox_upgrade_cur_info:AddHtmlText(level_info, -1)
  if level < 5 then
    form.mltbox_upgrade_next_info:Clear()
    level_info = get_building_level_info_desc(main_type, sub_type, level + 1)
    form.mltbox_upgrade_next_info:AddHtmlText(level_info, -1)
  end
  return
end
function update_life_time(form)
  for i = 1, 4 do
    local lbl = form.groupbox_back:Find("lbl_life_time_" .. i)
    if nx_is_valid(lbl) then
      if lbl.life_time > 0 then
        lbl.life_time = lbl.life_time - 1000
      else
        lbl.life_time = 0
      end
      lbl.Text = nx_widestr(transform_time(lbl.life_time))
    end
  end
end
function add_condition_info(main_type, sub_type, level, now_goods_list)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_upgrade_1")
  local guildbuilding_manager = nx_value("GuildbuildingManager")
  local condition = nx_widestr(gui.TextManager:GetText("ui_shenghuo0005")) .. nx_widestr(" ") .. nx_widestr("<BR>")
  form.lbl_2.Text = nx_widestr(gui.TextManager:GetText("ui_shenghuo0005"))
  local upgrade_info
  if form.funcid == MENU_GUILDBUILDING_REVERT then
    upgrade_info = guildbuilding_manager:GetGuildBuildingRevertInfo(main_type, sub_type, level)
  else
    upgrade_info = guildbuilding_manager:GetGuildBuildingLevelInfo(main_type, sub_type, level)
  end
  local goods_size = table.getn(now_goods_list)
  goods_size = goods_size / 2
  form.upgrade_time = upgrade_info[4] * 60000
  local remove_type = upgrade_info[7]
  local gold = upgrade_info[8]
  if nx_int(gold) > nx_int(0) then
    local head_str = nx_widestr(gui.TextManager:GetText("19308")) .. nx_widestr("-")
    local ui_gold = nx_widestr(gui.TextManager:GetText("ui_offline_form_jinbi"))
    condition = condition .. head_str .. ui_gold .. " : "
    local gold_text = nx_execute("util_functions", "trans_capital_string", gold)
    condition = condition .. nx_string(gold_text) .. " "
  end
  local silver = upgrade_info[9]
  if 0 < silver then
    local head_str = nx_widestr(gui.TextManager:GetText("19308")) .. nx_widestr("-")
    if remove_type == REMOVE_FROM_PLAYER_NONE or remove_type == REMOVE_FROM_PLAYER_GOODS then
      head_str = nx_widestr(gui.TextManager:GetText("19307")) .. nx_widestr("-")
    end
    local ui_silver = nx_widestr(gui.TextManager:GetText("ui_silvermoney"))
    condition = condition .. head_str .. ui_silver .. nx_widestr(":")
    form.lbl_3.Text = nx_widestr(gui.TextManager:GetText("ui_silvermoney"))
    form.pbar_1.Maximum = 100
    form.pbar_1.Value = now_goods_list[4] / silver * 100
    form.btn_1.config = now_goods_list[3]
    form.btn_1.num = now_goods_list[4]
    form.btn_1.max = silver
    form.btn_1.value = now_goods_list[4]
    form.btn_1.contribute = 1.5
    form.btn_use_guild_capital.config = now_goods_list[3]
    form.btn_use_guild_capital.max = silver
    form.btn_use_guild_capital.value = now_goods_list[4]
    local cur_money = nx_widestr(gui.TextManager:GetFormatText("ui_gc_money", now_goods_list[4]))
    local max_silver = nx_widestr(gui.TextManager:GetFormatText("ui_gc_money", silver))
    form.lbl_pbar_text.Text = nx_widestr(cur_money) .. nx_widestr("/") .. nx_widestr(max_silver)
    local silver_text = nx_execute("util_functions", "trans_capital_string", silver)
    condition = nx_widestr(condition) .. nx_widestr(silver_text) .. nx_widestr(" ")
  end
  local item_list
  if form.funcid == MENU_GUILDBUILDING_REVERT then
    item_list = guildbuilding_manager:GetGuildBuildingRevertItemsInfo(main_type, sub_type, level)
  else
    item_list = guildbuilding_manager:GetGuildBuildingItemsInfo(main_type, sub_type, level)
  end
  local size = table.getn(item_list)
  local count = size / 3
  if 0 < count then
    local head_str = nx_widestr(gui.TextManager:GetText("19309")) .. nx_widestr("-")
    if remove_type == REMOVE_FROM_PLAYER_NONE or remove_type == REMOVE_FROM_PLAYER_CAPITALTYPE then
      head_str = nx_widestr(gui.TextManager:GetText("19306")) .. nx_widestr("-")
    end
    condition = nx_widestr(condition) .. nx_widestr(head_str)
    for i = 1, count do
      local config = item_list[i * 3 - 2]
      local num = item_list[i * 3 - 1]
      local contribute = item_list[i * 3]
      if 0 < num then
        local str_config = nx_widestr(gui.TextManager:GetText(config))
        local btn_obj = form.groupscrollbox_1:Find("btn_" .. nx_string(i + 1))
        local btn_clone = form.groupscrollbox_1:Find("btn_" .. nx_string(i + 1) .. nx_string(i + 1))
        local item_query = nx_value("ItemQuery")
        local PhotoPath = ""
        if nx_is_valid(item_query) then
          PhotoPath = item_query:GetItemPropByConfigID(config, "Photo")
        end
        btn_obj.NormalImage = nx_string(nx_resource_path() .. PhotoPath)
        btn_obj.config = config
        btn_obj.num = num
        btn_obj.contribute = contribute
        btn_clone.config = config
        btn_clone.num = num
        btn_clone.contribute = contribute
        local lbl_obj = form.groupscrollbox_1:Find("lbl_" .. nx_string(i + 3))
        local Text = "/" .. nx_string(num)
        btn_obj.max = num
        btn_clone.max = num
        for j = 1, goods_size do
          if now_goods_list[j * 2 - 1] == config then
            Text = nx_string(now_goods_list[j * 2]) .. Text
            btn_obj.value = now_goods_list[j * 2]
            btn_clone.value = now_goods_list[j * 2]
          end
        end
        lbl_obj.Text = nx_widestr(Text)
        btn_obj.Visible = true
        btn_clone.Visible = true
        lbl_obj.Visible = true
      end
    end
  end
  return nx_widestr(condition)
end
function get_level_change_text(form)
  local gui = nx_value("gui")
  local cur_level = form.level
  local next_level = form.level + 1
  if next_level > MAX_BUILDING_LEVEL then
    next_level = MAX_BUILDING_LEVEL
  end
  local level_str = nx_widestr(gui.TextManager:GetText("ui_g_level"))
  local str = ""
  if cur_level == 0 or cur_level == 5 then
    str = nx_widestr(level_str) .. nx_widestr(cur_level)
  else
    str = nx_widestr(level_str) .. nx_widestr(cur_level) .. nx_widestr(" => ") .. nx_widestr(level_str) .. nx_widestr(next_level)
  end
  local wstr = nx_widestr(str)
  return wstr
end
function get_cur_level_name(form)
  local gui = nx_value("gui")
  local build_str = get_building_name(form.main_type, form.sub_type)
  local cur_level = form.level
  local level_str = nx_widestr(gui.TextManager:GetText("ui_g_level"))
  local str = nx_widestr(level_str) .. nx_widestr(cur_level)
  local r_str = nx_widestr(build_str) .. nx_widestr(":") .. nx_widestr(str)
  local wstr = nx_widestr(r_str)
  return wstr
end
function on_btn_use_guild_capital_get_capture(btn)
  if not nx_is_valid(btn) then
    return
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_use_guild_capital_tips")), btn.AbsLeft - 80, btn.AbsTop, 0, btn)
end
function on_btn_use_guild_capital_lost_capture(btn)
  if not nx_is_valid(btn) then
    return
  end
  nx_execute("tips_game", "hide_tip", btn)
end
function on_btn_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  show_contribute_form(btn.max, btn.value, btn.config, btn.contribute, btn.ParentForm.npcid, TYPE_BUILD)
end
function on_btn_use_guild_capital_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  show_contribute_guild_capital_form(btn.max - btn.value, btn.config, form.npcid, TYPE_BUILD)
end
function on_btn_faster_click(btn)
  local gui = nx_value("gui")
  local sock = nx_value("game_sock")
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_upgrade_faster")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guildbuilding\\form_guild_build_upgrade_faster", true, false)
    nx_set_value("form_stage_main\\form_guildbuilding\\form_guild_build_upgrade_faster", form)
  end
  form.Left = (gui.Desktop.Width - form.Width) / 2
  form.Top = (gui.Desktop.Height - form.Height) / 2
  form:ShowModal()
  form.Visible = true
  local ParentForm = btn.ParentForm
  local result, capital = nx_wait_event(100000000, form, "form_guild_build_upgrade_faster")
  if result == "ok" then
    nx_execute("custom_sender", "custom_upgrade_faster", btn.ParentForm.npcid, capital)
  end
end
function final_cost(form)
  local guildbuilding_manager = nx_value("GuildbuildingManager")
  local MaxLevel = 5
  local final_money = 0
  local kuangshi_1_num = 0
  local tre_1_num = 0
  for i = 0, MaxLevel do
    local upgrade_info = guildbuilding_manager:GetGuildBuildingLevelInfo(form.main_type, form.sub_type, i)
    final_money = final_money + upgrade_info[9]
    local item_list = guildbuilding_manager:GetGuildBuildingItemsInfo(form.main_type, form.sub_type, i)
    local size = table.getn(item_list)
    local count = size / 3
    if 0 < count then
      for i = 1, count do
        local config = item_list[i * 3 - 2]
        local num = item_list[i * 3 - 1]
        local x, y = string.find(config, "_")
        if 0 < num then
          local type = string.sub(config, 1, y + 1)
          if type == "kuangshi_1" then
            kuangshi_1_num = kuangshi_1_num + num
          elseif type == "tre_1" then
            tre_1_num = tre_1_num + num
          end
        end
      end
    end
  end
  local gui = nx_value("gui")
  form.lbl_money.Text = nx_widestr(gui.TextManager:GetFormatText("ui_gc_money", final_money))
  form.lbl_or.Text = nx_widestr(tre_1_num)
  form.lbl_tr.Text = nx_widestr(kuangshi_1_num)
end
function on_btn_get_capture(self)
  local form = self.ParentForm
  local item_data = get_global_arraylist("form_guildbuild_upgrade_1_get_capture")
  item_data.ConfigID = self.config
  item_data.IsShowAmount = 1
  item_data.ItemType = get_prop_in_ItemQuery(self.config, nx_string("ItemType"))
  if nx_is_valid(item_data) then
    nx_execute("tips_game", "show_goods_tip", item_data, self.AbsLeft, self.AbsTop, 32, 32, form)
    local gui = nx_value("gui")
    local form_main = gui.Desktop
    local equip_tip = form_main.equip_tips_new
    if nx_is_valid(equip_tip) then
      local i = string.sub(nx_string(self.Name), -1, -1)
      local lbl_obj = form.groupscrollbox_1:Find("lbl_" .. nx_string(nx_number(i) + 2))
      if nx_is_valid(lbl_obj) then
        local Text = nx_widestr(gui.TextManager:GetText("ui_Number")) .. nx_widestr(":") .. lbl_obj.Text
        equip_tip.mltbox_left:AddHtmlText(nx_widestr(Text), -1)
        equip_tip.mltbox_left.Height = equip_tip.mltbox_left.Height + 30
      end
    end
  else
    nx_execute("tips_game", "hide_tip", form)
  end
end
function on_btn_lost_capture(self)
  local form = self.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function on_lbl_click(lbl)
  local form = lbl.ParentForm
  local level = form.level
  local coachNum = form.coachNum
  local index = nx_number(string.sub(lbl.Name, -1, -1)) - 1
  if 1 < level then
    if index > level - 2 then
      local form_logic = nx_value("form_main_sysinfo")
      if nx_is_valid(form_logic) then
        form_logic:AddSystemInfo(util_text("19260"), SYSTYPE_FIGHT, 0)
      end
    elseif index > coachNum - 1 then
      local form_logic = nx_value("form_main_sysinfo")
      if nx_is_valid(form_logic) then
        form_logic:AddSystemInfo(util_text("19259"), SYSTYPE_FIGHT, 0)
      end
    end
  else
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(util_text("19260"), SYSTYPE_FIGHT, 0)
    end
  end
end
