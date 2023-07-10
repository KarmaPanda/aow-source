require("util_gui")
require("custom_sender")
require("util_functions")
require("tips_func_equip")
require("share\\client_custom_define")
require("form_stage_main\\form_relation\\form_relation_guild\\sub_command_define")
require("form_stage_main\\form_guildbuilding\\sub_command_define")
require("form_stage_main\\form_guildbuilding\\guildbuilding_getinfo")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
local DRAWINGS_STATUS_MAX = -1
local DRAWINGS_STATUS_INIT = 0
local DRAWINGS_STATUS_CONTRIBUTE = 1
local DRAWINGS_STATUS_UPGRADING = 2
local DRAWINGS_STATUS_CLOSE = 3
local REMOVE_FROM_PLAYER_ALL = 0
local REMOVE_FROM_PLAYER_NONE = 1
local REMOVE_FROM_PLAYER_CAPITALTYPE = 2
local REMOVE_FROM_PLAYER_GOODS = 3
local MAX_BUILDING_LEVEL = 5
function main_form_init(self)
  self.Fixed = false
  self.check = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.groupbox_level5.Visible = false
  self.groupbox_upgrading.Visible = false
  self.groupbox_contribute.Visible = false
  self.cur_buildid = "5_0"
  self.cur_buildid_main_type = 5
  self.cur_buildid_sub_type = 0
  self.cur_buildid_level = 0
  self.cur_build_state = 0
  self.stopLeftTime = 0
  self.coolLeftTime = 0
  self.upgrade_time = 0
  self.groupbox_right.Visible = false
  self.btn_12.Visible = false
  self.btn_11.Visible = true
  custom_request_darwings()
end
function on_main_form_close(self)
  local child = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_banghuicangku_contributemoneyconfirm")
  if nx_is_valid(child) then
    child:Close()
    nx_destroy(child)
    nx_set_value("form_stage_main\\form_guildbuilding\\form_guild_build_banghuicangku_contributemoneyconfirm", nx_null())
  end
  nx_destroy(self)
  nx_set_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_drawings", nx_null())
  nx_execute("tips_game", "hide_tip", form)
end
function on_btn_11_click(self)
  local form = self.ParentForm
  if nx_int(form.cur_build_state) == nx_int(DRAWINGS_STATUS_CLOSE) then
    return
  end
  form.groupbox_right.Visible = true
  self.Visible = false
  form.btn_12.Visible = true
end
function on_btn_12_click(self)
  local form = self.ParentForm
  form.groupbox_right.Visible = false
  self.Visible = false
  form.btn_11.Visible = true
end
function on_building_left_down(self)
  local gui = nx_value("gui")
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_drawings", false)
  if not nx_is_valid(form) then
    return
  end
  if not form.btn_11.Visible and not form.btn_12.Visible then
    form.btn_11.Visible = true
  end
  if nx_int(form.cur_build_state) == nx_int(DRAWINGS_STATUS_UPGRADING) then
    local game_timer = nx_value("timer_game")
    game_timer:UnRegister(nx_current(), "on_update_upgrading", form)
  end
  if not nx_find_custom(self, "buildingid") then
    form.cur_build_state = DRAWINGS_STATUS_CLOSE
    add_close_condition_info()
    form.groupbox_level5.Visible = false
    form.groupbox_upgrading.Visible = false
    form.groupbox_contribute.Visible = true
    form.lbl_buildingname.Text = nx_widestr(gui.TextManager:GetText("ui_guild_jiguan_weikaifang"))
    form.mltbox_building_level.HtmlText = nx_widestr("")
    on_btn_12_click(form.btn_12)
    form.btn_11.Visible = false
    return
  end
  self.ParentForm.cur_buildid = self.buildingid
  self.ParentForm.cur_buildid_level = self.cur_level
  self.ParentForm.cur_build_state = self.cur_status
  if nx_int(self.cur_level) >= nx_int(MAX_BUILDING_LEVEL) then
    form.groupbox_contribute.Visible = false
    form.groupbox_upgrading.Visible = false
    form.groupbox_level5.Visible = true
    final_cost(form)
    show_info_change(form)
    form.mltbox_building_level.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_guild_drawings_level", nx_int(MAX_BUILDING_LEVEL)))
    local building_name = nx_widestr(gui.TextManager:GetFormatText("ui_guildbuilding_drawings_" .. nx_string(form.cur_buildid)))
    form.lbl_buildingname.Text = nx_widestr(building_name)
    return
  end
  local str_lst = util_split_string(self.buildingid, "_")
  if nx_int(table.getn(str_lst)) == nx_int(2) then
    self.ParentForm.cur_buildid_main_type = nx_int(str_lst[1])
    self.ParentForm.cur_buildid_sub_type = nx_int(str_lst[2])
  end
  self.ParentForm.stopLeftTime = self.end_time
  self.ParentForm.coolLeftTime = self.cool_time
  show_info_change(form)
  if nx_int(self.cur_level) >= nx_int(MAX_BUILDING_LEVEL) then
    form.groupbox_contribute.Visible = false
    form.groupbox_upgrading.Visible = false
    form.groupbox_level5.Visible = true
    local building_name = nx_widestr(gui.TextManager:GetFormatText("ui_guildbuilding_drawings_" .. nx_string(form.cur_buildid)))
    form.lbl_buildingname.Text = nx_widestr(building_name)
    form.mltbox_building_level.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_guild_drawings_level", nx_int(MAX_BUILDING_LEVEL)))
    final_cost(form)
    return
  end
  if nx_int(form.cur_build_state) == nx_int(DRAWINGS_STATUS_CLOSE) then
    add_close_condition_info()
    form.groupbox_level5.Visible = false
    form.groupbox_upgrading.Visible = false
    form.groupbox_contribute.Visible = true
    form.lbl_buildingname.Text = nx_widestr(gui.TextManager:GetText("ui_guild_jiguan_weikaifang"))
    form.mltbox_building_level.HtmlText = nx_widestr("")
    on_btn_12_click(form.btn_12)
    form.btn_11.Visible = false
    return
  end
  custom_request_darwings_building(self.buildingid)
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
function on_btn_contribute_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.cur_build_state) == nx_int(DRAWINGS_STATUS_CLOSE) then
    return
  end
  show_contribute_form(btn.Max, btn.Value, btn.config, btn.contribute, btn.ParentForm.cur_buildid, TYPE_DRAWING)
end
function on_btn_use_guild_capital_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  show_contribute_guild_capital_form(btn.Max - btn.Value, btn.config, form.cur_buildid, TYPE_DRAWING)
end
function on_btn_faster_click(btn)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_upgrade_faster")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guildbuilding\\form_guild_build_upgrade_faster", true, false)
    nx_set_value("form_stage_main\\form_guildbuilding\\form_guild_build_upgrade_faster", form)
  end
  local id = btn.ParentForm.cur_buildid
  form.Left = (gui.Desktop.Width - form.Width) / 2
  form.Top = (gui.Desktop.Height - form.Height) / 2
  form:ShowModal()
  form.Visible = true
  form.Fixed = true
  local result, capital = nx_wait_event(100000000, form, "form_guild_build_upgrade_faster")
  if result == "ok" then
    custom_request_upgrade_darwings_accelerate(id, capital)
  end
end
function on_btn_get_capture(self)
  local form = self.ParentForm
  local item_data = get_global_arraylist("form_guildbuild_upgrade_2_get_capture")
  if not nx_find_custom(self, "config") then
    return
  end
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
      local lbl_obj = form.groupbox_contribute:Find("lbl_num_" .. nx_string(nx_number(i)))
      if nx_is_valid(lbl_obj) then
        local Text = nx_widestr(gui.TextManager:GetText("ui_Number")) .. nx_widestr(":") .. nx_widestr(lbl_obj.Text)
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
function add_condition_info(buildingid, level, now_goods_list)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_drawings")
  local guildbuilding_manager = nx_value("GuildbuildingManager")
  local condition = nx_widestr(gui.TextManager:GetText("ui_shenghuo0005")) .. nx_widestr(" ") .. nx_widestr("<BR>")
  local upgrade_info = guildbuilding_manager:GetGuildDrawingsLevelInfo(buildingid, level)
  local upgrade_time = upgrade_info[4] * 60000
  local cool_time = upgrade_info[5] * 60000
  local remove_type = upgrade_info[7]
  local gold = upgrade_info[8]
  local item_list = guildbuilding_manager:GetGuildDrawingsItemsInfo(buildingid, level)
  local size = table.getn(item_list)
  local count = size / 3
  local goods_size = table.getn(now_goods_list)
  if nx_int(goods_size) == nx_int(0) then
    local index = 1
    now_goods_list[index] = nx_string("CapitalType0")
    index = index + 1
    now_goods_list[index] = nx_int(0)
    index = index + 1
    now_goods_list[index] = nx_string("CapitalType1")
    index = index + 1
    now_goods_list[index] = nx_int(0)
    index = index + 1
    if 0 < count then
      for i = 1, count do
        now_goods_list[index] = item_list[i * 3 - 2]
        index = index + 1
        now_goods_list[index] = nx_int(0)
        index = index + 1
      end
    end
    goods_size = index / 2
  else
    goods_size = goods_size / 2
  end
  if nx_int(gold) > nx_int(0) then
    local head_str = nx_widestr(gui.TextManager:GetText("19308")) .. nx_widestr("-")
    local ui_gold = nx_widestr(gui.TextManager:GetText("ui_offline_form_jinbi"))
    condition = nx_widestr(condition) .. nx_widestr(head_str) .. nx_widestr(ui_gold) .. nx_widestr(" : ")
    local gold_text = nx_execute("util_functions", "trans_capital_string", gold)
    condition = nx_widestr(condition) .. nx_widestr(gold_text) .. nx_widestr(" ")
  end
  local silver = upgrade_info[9]
  if 0 < silver then
    local head_str = nx_widestr(gui.TextManager:GetText("19308")) .. nx_widestr("-")
    if remove_type == REMOVE_FROM_PLAYER_NONE or remove_type == REMOVE_FROM_PLAYER_GOODS then
      head_str = nx_widestr(gui.TextManager:GetText("19307")) .. nx_widestr("-")
    end
    local ui_silver = nx_widestr(gui.TextManager:GetText("ui_silvermoney"))
    condition = nx_widestr(condition) .. nx_widestr(head_str) .. nx_widestr(ui_silver) .. nx_widestr(":")
    form.pbar_1.Maximum = 100
    form.pbar_1.Value = now_goods_list[4] / silver * 100
    form.btn_capital.config = now_goods_list[3]
    form.btn_capital.num = now_goods_list[4]
    form.btn_capital.Max = silver
    form.btn_capital.Value = now_goods_list[4]
    form.btn_capital.contribute = 1.5
    form.btn_capital.Enabled = true
    form.btn_use_guild_capital.config = now_goods_list[3]
    form.btn_use_guild_capital.Max = silver
    form.btn_use_guild_capital.Value = now_goods_list[4]
    form.btn_use_guild_capital.Enabled = true
    local cur_money = nx_widestr(gui.TextManager:GetFormatText("ui_gc_money", now_goods_list[4]))
    local max_silver = nx_widestr(gui.TextManager:GetFormatText("ui_gc_money", silver))
    form.lbl_pbar_text.Text = nx_widestr(cur_money) .. nx_widestr("/") .. nx_widestr(max_silver)
    local silver_text = nx_execute("util_functions", "trans_capital_string", silver)
    condition = nx_widestr(condition) .. nx_widestr(silver_text) .. nx_widestr(" ")
  end
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
        local item_query = nx_value("ItemQuery")
        local PhotoPath = ""
        if nx_is_valid(item_query) then
          PhotoPath = item_query:GetItemPropByConfigID(config, "Photo")
        end
        local btn_obj = form.groupbox_contribute:Find("btn_" .. nx_string(i))
        if nx_is_valid(btn_obj) then
          btn_obj.NormalImage = nx_string(nx_resource_path() .. PhotoPath)
          btn_obj.config = config
          btn_obj.num = num
          btn_obj.contribute = contribute
          btn_obj.Enabled = true
        end
        local btn_clone = form.groupbox_contribute:Find("btn_clone_" .. nx_string(i))
        if nx_is_valid(btn_obj) then
          btn_clone.config = config
          btn_clone.num = num
          btn_clone.contribute = contribute
          btn_clone.Enabled = true
        end
        local lbl_obj = form.groupbox_contribute:Find("lbl_num_" .. nx_string(i))
        local Text = "/" .. nx_string(num)
        btn_obj.Max = num
        btn_clone.Max = num
        for j = 1, goods_size do
          if nx_string(now_goods_list[j * 2 - 1 + 4]) == nx_string(config) then
            Text = nx_string(now_goods_list[j * 2 + 4]) .. Text
            btn_obj.Value = now_goods_list[j * 2 + 4]
            btn_clone.Value = now_goods_list[j * 2 + 4]
          end
        end
        lbl_obj.Text = nx_widestr(Text)
        btn_obj.Visible = true
        btn_clone.Visible = true
        lbl_obj.Visible = true
      end
    end
  end
  for k = count, 5 do
    local btn_obj = form.groupbox_contribute:Find("btn_" .. nx_string(i))
    if nx_is_valid(btn_obj) then
      btn_obj.Visible = false
    end
    local btn_clone = form.groupbox_contribute:Find("btn_clone_" .. nx_string(i) .. nx_string(i))
    if nx_is_valid(btn_clone) then
      btn_clone.Visible = false
    end
    local lbl_obj = form.groupbox_contribute:Find("lbl_num_" .. nx_string(i))
    if nx_is_valid(lbl_obj) then
      lbl_obj.Visible = false
    end
  end
  return nx_widestr(condition)
end
function final_cost(form)
  local guildbuilding_manager = nx_value("GuildbuildingManager")
  local MaxLevel = 5
  local final_money = 0
  local kuangshi_1_num = 0
  local tre_1_num = 0
  for i = 0, MaxLevel do
    local upgrade_info = guildbuilding_manager:GetGuildDrawingsLevelInfo(form.cur_buildid, i)
    final_money = final_money + upgrade_info[9]
    local item_list = guildbuilding_manager:GetGuildDrawingsItemsInfo(form.cur_buildid, i)
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
  form.lbl_all_money.Text = nx_widestr(gui.TextManager:GetFormatText("ui_gc_money", final_money))
  form.lbl_all_or.Text = nx_widestr(tre_1_num)
  form.lbl_all_tr.Text = nx_widestr(kuangshi_1_num)
  form.lbl_nextlevel.Text = nx_widestr("")
  form.mltbox_new_info:Clear()
end
function show_info_change(form)
  local gui = nx_value("gui")
  local main_type = form.cur_buildid_main_type
  local sub_type = form.cur_buildid_sub_type
  local level = form.cur_buildid_level
  local next_level = level + 1
  form.mltbox_build_desc:Clear()
  form.mltbox_info:Clear()
  form.mltbox_new_info:Clear()
  local building_name = nx_widestr(gui.TextManager:GetFormatText("ui_guildbuilding_drawings_" .. nx_string(form.cur_buildid)))
  form.lbl_buildingname.Text = nx_widestr(building_name)
  form.mltbox_building_level.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_guild_drawings_levelup", nx_int(level), nx_int(next_level)))
  local bulid_desc = get_building_content(main_type, sub_type)
  form.mltbox_build_desc:AddHtmlText(nx_widestr(bulid_desc), -1)
  form.lbl_building_name.Text = nx_widestr(gui.TextManager:GetFormatText("ui_guild_drawings_02", nx_widestr(building_name)))
  form.lbl_curlevel.Text = nx_widestr(gui.TextManager:GetText("ui_guild_drawings_level_" .. nx_string(level)))
  if nx_int(next_level) <= nx_int(MAX_BUILDING_LEVEL) then
    form.lbl_nextlevel.Text = nx_widestr(gui.TextManager:GetText("ui_guild_drawings_level_" .. nx_string(next_level)))
  end
  if nx_int(sub_type) > nx_int(0) then
    local gb_manager = nx_value("GuildbuildingManager")
    local infos = gb_manager:GetZhenFaInfo(sub_type, level)
    local id = 0
    if table.getn(infos) >= 2 then
      id = infos[1]
    end
    local str = "ui_guildbuilding_zhenfa_" .. nx_string(id)
    local zhenfa_wstr = nx_widestr(gui.TextManager:GetText(str))
    form.mltbox_info:AddHtmlText(nx_widestr(zhenfa_wstr), -1)
    if nx_int(next_level) <= nx_int(MAX_BUILDING_LEVEL) then
      infos = gb_manager:GetZhenFaInfo(sub_type, next_level)
    end
    id = 0
    if table.getn(infos) >= 2 then
      id = infos[1]
    end
    local str = "ui_guildbuilding_zhenfa_" .. nx_string(id)
    zhenfa_wstr = nx_widestr(gui.TextManager:GetText(str))
    form.mltbox_new_info:AddHtmlText(nx_widestr(zhenfa_wstr), -1)
    local zengyi = nx_string(get_building_zengyi(main_type, sub_type, level))
    form.mltbox_info:AddHtmlText(nx_widestr(zengyi), -1)
    if nx_int(next_level) <= nx_int(MAX_BUILDING_LEVEL) then
      local zengyi = nx_string(get_building_zengyi(main_type, sub_type, next_level))
      form.mltbox_new_info:AddHtmlText(nx_widestr(zengyi), -1)
    end
  else
    local bulid_desc = get_building_level_info_desc(main_type, sub_type, level)
    form.mltbox_info:AddHtmlText(nx_widestr(bulid_desc), -1)
    form.lbl_curlevel.Text = nx_widestr(gui.TextManager:GetText("ui_guild_drawings_level_" .. nx_string(level)))
    if nx_int(next_level) <= nx_int(MAX_BUILDING_LEVEL) then
      bulid_desc = get_building_level_info_desc(main_type, sub_type, next_level)
      form.mltbox_new_info:AddHtmlText(nx_widestr(bulid_desc), -1)
      form.lbl_nextlevel.Text = nx_widestr(gui.TextManager:GetText("ui_guild_drawings_level_" .. nx_string(next_level)))
    end
  end
  return
end
function add_close_condition_info()
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_drawings")
  form.pbar_1.Maximum = 100
  form.pbar_1.Value = 0
  form.btn_capital.config = "CapitalType1"
  form.btn_capital.num = 0
  form.btn_capital.Max = 0
  form.btn_capital.Value = 0
  form.btn_capital.contribute = 1.5
  form.btn_capital.Enabled = false
  form.btn_use_guild_capital.config = "CapitalType1"
  form.btn_use_guild_capital.Max = 0
  form.btn_use_guild_capital.Value = 0
  form.btn_use_guild_capital.Enabled = false
  form.lbl_pbar_text.Text = nx_widestr("0/0")
  for i = 0, 5 do
    local btn_obj = form.groupbox_contribute:Find("btn_" .. nx_string(i))
    if nx_is_valid(btn_obj) then
      btn_obj.Enabled = false
      btn_obj.NormalImage = "icon\\prop\\prop845.png"
    end
    local btn_clone = form.groupbox_contribute:Find("btn_clone_" .. nx_string(i))
    if nx_is_valid(btn_clone) then
      btn_clone.Enabled = false
      btn_clone.config = ""
      btn_clone.num = 0
      btn_clone.Max = 0
      btn_clone.Value = 0
      btn_clone.contribute = 1.5
    end
    local lbl_obj = form.groupbox_contribute:Find("lbl_num_" .. nx_string(i))
    if nx_is_valid(lbl_obj) then
      lbl_obj.Enabled = false
      lbl_obj.Text = nx_widestr("0/0")
    end
  end
end
function recv_guild_drawings_data(...)
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_drawings", false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local building_control = form:Find("groupbox_buildings")
  if not nx_is_valid(building_control) then
    return
  end
  local arg_group_num = 5
  local arg_index = 1
  if nx_int(table.getn(arg) % arg_group_num) ~= nx_int(0) then
    return
  end
  local count = table.getn(arg) / arg_group_num
  for i = 1, count do
    local id = arg[arg_index]
    local level = 0
    local pic_building = building_control:Find("pic_building_" .. nx_string(id))
    local btn_building = building_control:Find("btn_" .. nx_string(id))
    if nx_is_valid(pic_building) and nx_is_valid(btn_building) then
      pic_building.buildingid = arg[arg_index]
      btn_building.buildingid = arg[arg_index]
      arg_index = arg_index + 1
      level = arg[arg_index]
      pic_building.cur_level = level
      btn_building.cur_level = level
      arg_index = arg_index + 1
      pic_building.cur_status = arg[arg_index]
      btn_building.cur_status = arg[arg_index]
      arg_index = arg_index + 1
      pic_building.end_time = arg[arg_index]
      btn_building.end_time = arg[arg_index]
      arg_index = arg_index + 1
      pic_building.cool_time = cool_time
      btn_building.cool_time = cool_time
      arg_index = arg_index + 1
    end
    local pic_level = building_control:Find("pic_" .. nx_string(id))
    if nx_is_valid(pic_level) then
      pic_level.Image = "gui\\guild\\guildpaper\\guildbuilding_" .. nx_string(level) .. ".png"
      if nx_int(pic_building.cur_status) == nx_int(DRAWINGS_STATUS_CLOSE) then
        pic_building.HintText = nx_widestr(gui.TextManager:GetText("ui_guild_jiguan_weikaifang"))
        pic_building.NormalImage = "gui\\guild\\guildpaper\\" .. nx_string(id) .. "_3.png"
        pic_building.FocusImage = "gui\\guild\\guildpaper\\" .. nx_string(id) .. "_3.png"
        pic_building.PushImage = "gui\\guild\\guildpaper\\" .. nx_string(id) .. "_3.png"
        pic_building.DisableImage = "gui\\guild\\guildpaper\\" .. nx_string(id) .. "_3.png"
        pic_level.Image = "gui\\guild\\guildpaper\\guildbuilding_weikaifang.png"
      end
      if nx_string(id) == nx_string(form.cur_buildid) then
        on_building_left_down(pic_building)
      end
    end
  end
end
function recv_guild_building_data(...)
  local gui = nx_value("gui")
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_drawings", false)
  if not nx_is_valid(form) then
    return
  end
  local argSize = table.getn(arg)
  if argSize < 2 then
    return
  end
  local buildingid = nx_string(arg[1])
  local upgrade_status = nx_int(arg[2])
  if nx_int(form.cur_buildid_level) >= nx_int(MAX_BUILDING_LEVEL) then
    form.groupbox_contribute.Visible = false
    form.groupbox_upgrading.Visible = false
    form.groupbox_level5.Visible = true
    local building_name = nx_widestr(gui.TextManager:GetFormatText("ui_guildbuilding_drawings_" .. nx_string(form.cur_buildid)))
    form.lbl_buildingname.Text = nx_widestr(building_name)
    form.mltbox_building_level.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_guild_drawings_level", nx_int(MAX_BUILDING_LEVEL)))
    final_cost(form)
    return
  end
  if upgrade_status == nx_int(DRAWINGS_STATUS_UPGRADING) then
    form.groupbox_contribute.Visible = false
    form.groupbox_level5.Visible = false
    form.groupbox_upgrading.Visible = true
    local guildbuilding_manager = nx_value("GuildbuildingManager")
    local upgrade_info = guildbuilding_manager:GetGuildDrawingsLevelInfo(form.cur_buildid, form.cur_buildid_level)
    form.upgrade_time = upgrade_info[4] * 60000
    form.pbar_upgrading.Maximum = 100
    form.pbar_upgrading.Value = (form.upgrade_time - form.stopLeftTime) / form.upgrade_time * 100
    local game_timer = nx_value("timer_game")
    game_timer:Register(100, -1, nx_current(), "update_upgrading", form, -1, -1)
    return
  end
  local now_goods_list = {}
  for i = 3, argSize do
    now_goods_list[i - 2] = arg[i]
  end
  add_condition_info(form.cur_buildid, form.cur_buildid_level, now_goods_list)
  form.groupbox_level5.Visible = false
  form.groupbox_upgrading.Visible = false
  form.groupbox_contribute.Visible = true
end
function update_upgrading(form)
  local value = (form.upgrade_time - form.stopLeftTime) / form.upgrade_time * 100
  if nx_int(value) >= nx_int(form.pbar_upgrading.Maximum) then
    local game_timer = nx_value("timer_game")
    game_timer:UnRegister(nx_current(), "update_upgrading", form)
    custom_request_darwings_building(form.cur_buildid)
  else
    form.pbar_upgrading.Value = value
    form.stopLeftTime = form.stopLeftTime - 100
    form.lbl_left_time.Text = nx_widestr(transform_time(form.stopLeftTime))
  end
end
function custom_request_darwings()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_DRAWINGS))
end
function custom_request_darwings_building(buildingid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_DARWINGS_BUILDING), nx_string(buildingid))
end
function custom_request_upgrade_darwings_contribute(buildingid, resid, resnum)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_UPGRADE_DARWINGS), nx_string(buildingid), nx_string(resid), nx_int64(resnum))
end
function custom_request_upgrade_darwings_accelerate(buildingid, moneynum)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_ACCELERATE_UPGRADE_DARWINGS), nx_string(buildingid), nx_int64(moneynum))
end
