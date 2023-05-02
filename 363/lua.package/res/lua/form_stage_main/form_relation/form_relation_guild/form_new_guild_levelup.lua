require("util_gui")
require("custom_sender")
require("util_functions")
require("tips_func_equip")
require("share\\client_custom_define")
require("form_stage_main\\form_relation\\form_relation_guild\\sub_command_define")
require("form_stage_main\\form_guildbuilding\\sub_command_define")
require("form_stage_main\\form_guildbuilding\\guildbuilding_getinfo")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
require("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_suits")
require("form_stage_main\\form_relation\\capital_funs")
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
local MAX_GUILD_LEVEL = 5
local SUB_CUSTOMMSG_GUILD_LEVEL_INFO = 110
local SUB_CUSTOMMSG_GUILD_UPGRADE = 111
local SUB_CUSTOMMSG_REQUEST_PROSPERITY_INFO = 113
local SUB_CUSTOMMSG_REQUEST_DEGRADE_INFO = 73
local ST_FUNCTION_GUILD_LEVEL_POS_MEMBER_MAX_PLUS = 789
local wen_to_ding = 1000000
local wen_to_liang = 1000
local LEVEL_FILE = "share\\Guild\\guild_limit_cost.ini"
function main_form_init(self)
  self.Fixed = false
  self.check = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.groupbox_level5.Visible = false
  self.groupbox_upgrading.Visible = false
  self.groupbox_contribute.Visible = false
  self.groupbox_5.Visible = false
  self.rbtn_build_levelup.Checked = true
  self.cur_buildid = "5_0"
  self.cur_buildid_main_type = 5
  self.cur_buildid_sub_type = 0
  self.cur_buildid_level = 0
  self.cur_build_state = 0
  self.stopLeftTime = 0
  self.coolLeftTime = 0
  self.upgrade_time = 0
  custom_request_darwings()
  custom_request_guild_level()
  custom_request_pros_info()
  req_level_down_data()
  degrade_info_ini()
  show_degrade_info(self)
  self.rbtn_guild_prosperity.Visible = false
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_LEVEL_POS_MEMBER_MAX_PLUS) then
    self.rbtn_guild_prosperity.Visible = true
  end
end
function on_main_form_close(self)
  local child = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_banghuicangku_contributemoneyconfirm")
  if nx_is_valid(child) then
    child:Close()
    nx_destroy(child)
    nx_set_value("form_stage_main\\form_guildbuilding\\form_guild_build_banghuicangku_contributemoneyconfirm", nx_null())
  end
  nx_destroy(self)
  nx_set_value("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_levelup", nx_null())
  nx_execute("tips_game", "hide_tip", form)
end
function on_building_left_down(self)
  local gui = nx_value("gui")
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_levelup", false)
  if not nx_is_valid(form) then
    return
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
    return
  end
  self.ParentForm.cur_buildid = self.buildingid
  self.ParentForm.cur_buildid_level = self.cur_level
  self.ParentForm.cur_build_state = self.cur_status
  local building_name = nx_widestr(gui.TextManager:GetFormatText("ui_guildbuilding_drawings_" .. nx_string(form.cur_buildid)))
  form.lbl_buildingname.Text = nx_widestr(building_name)
  form.mltbox_building_level.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_guild_drawings_level", nx_int(form.cur_buildid_level)))
  if nx_int(self.cur_level) >= nx_int(MAX_BUILDING_LEVEL) then
    form.groupbox_contribute.Visible = false
    form.groupbox_upgrading.Visible = false
    form.groupbox_level5.Visible = true
    final_cost(form)
    form.mltbox_building_level.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_guild_drawings_level", nx_int(MAX_BUILDING_LEVEL)))
    return
  end
  local str_lst = util_split_string(self.buildingid, "_")
  if nx_int(table.getn(str_lst)) == nx_int(2) then
    self.ParentForm.cur_buildid_main_type = nx_int(str_lst[1])
    self.ParentForm.cur_buildid_sub_type = nx_int(str_lst[2])
  end
  self.ParentForm.stopLeftTime = self.end_time
  self.ParentForm.coolLeftTime = self.cool_time
  if nx_int(self.cur_level) >= nx_int(MAX_BUILDING_LEVEL) then
    form.groupbox_contribute.Visible = false
    form.groupbox_upgrading.Visible = false
    form.groupbox_level5.Visible = true
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
  local game_visual = nx_value("game_visual")
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
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_levelup")
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
end
function add_close_condition_info()
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_levelup")
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
function custom_request_upgrade_darwings_accelerate(buildingid, moneynum)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_ACCELERATE_UPGRADE_DARWINGS), nx_string(buildingid), nx_int64(moneynum))
end
function custom_request_guild_level()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_LEVEL_INFO))
end
function custom_request_guild_upgrate(guild_name)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_UPGRADE), nx_widestr(guild_name))
end
function custom_request_pros_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_PROSPERITY_INFO))
end
function recv_guild_drawings_data(...)
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_levelup", false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_find_custom(form, "groupbox_buildings") then
    return
  end
  local building_control = form.groupbox_buildings
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
      btn_building.Text = nx_widestr(btn_building.cur_level) .. nx_widestr("/5")
    else
      arg_index = arg_index + 5
    end
    if nx_string(id) == nx_string(form.cur_buildid) then
      on_building_left_down(pic_building)
    end
  end
end
function recv_guild_building_data(...)
  local gui = nx_value("gui")
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_levelup", false)
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
function on_recv_prosperity(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local size = table.getn(arg)
  if size < 7 then
    return
  end
  local guild_level = nx_int(arg[1])
  local evaluation = nx_int(arg[2])
  local base_max = nx_int(arg[3])
  local plus = nx_int(arg[4])
  local next_evaluation = nx_int(arg[5])
  local next_plus = nx_int(arg[6])
  local prosperity = nx_string(arg[7])
  form.lbl_evaluation.BackImage = "gui\\guild\\formback\\level_" .. nx_string(evaluation) .. ".png"
  form.lbl_total_max.Text = nx_widestr(base_max + plus)
  form.lbl_base_max.Text = nx_widestr(base_max)
  form.lbl_plus.Text = nx_widestr(plus)
  form.lbl_pros_lv.Text = nx_widestr(guild_level)
  form.lbl_evaluation_1.Text = nx_widestr(util_text("ui_prosperity_evaluation_" .. nx_string(evaluation)))
  form.lbl_next_evaluation.Text = nx_widestr(util_text("ui_prosperity_evaluation_" .. nx_string(next_evaluation)))
  form.lbl_next_plus.Text = nx_widestr(next_plus)
  local table_prosperity = util_split_string(prosperity, ",")
  local count = table.getn(table_prosperity)
  if count <= 0 or (count - 1) % 3 ~= 0 then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.groupscrollbox_event.IsEditMode = true
  form.groupscrollbox_event:DeleteAll()
  local prosperity_event_count = 0
  for i = 1, count - 1, 3 do
    local event_id = table_prosperity[i]
    local count = table_prosperity[i + 1]
    local total_count = table_prosperity[i + 2]
    local groupbox_one = create_ctrl("GroupBox", "groupbox_event_" .. nx_string(event_id), form.groupbox_event, form.groupscrollbox_event)
    if nx_is_valid(groupbox_one) then
      local lbl_event_name = create_ctrl("Label", "lbl_event_name_" .. nx_string(event_id), form.lbl_event_name, groupbox_one)
      if not nx_is_valid(lbl_event_name) then
        return
      end
      local lbl_event_count = create_ctrl("Label", "lbl_event_count_" .. nx_string(event_id), form.lbl_event_count, groupbox_one)
      if not nx_is_valid(lbl_event_count) then
        return
      end
      local lbl_bg_event = create_ctrl("Label", "lbl_bg_event_" .. nx_string(event_id), form.lbl_bg_event, groupbox_one)
      if not nx_is_valid(lbl_bg_event) then
        return
      end
      lbl_event_name.Text = gui.TextManager:GetFormatText("ui_prosperity_event_name_" .. nx_string(event_id), nx_int(total_count))
      lbl_event_count.Text = nx_widestr(nx_string(count) .. "/" .. nx_string(total_count))
      if nx_number(count) >= nx_number(total_count) then
        prosperity_event_count = prosperity_event_count + 1
      end
    end
  end
  form.groupscrollbox_event.IsEditMode = false
  form.groupscrollbox_event:ResetChildrenYPos()
  form.lbl_prosperity.Text = nx_widestr(nx_string(prosperity_event_count) .. "/" .. nx_string((count - 1) / 3))
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
function on_btn_left_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.groupbox_4.Visible then
    return
  end
  if nx_int(form.guild_level) <= nx_int(1) then
    return
  end
  form.guild_level = form.guild_level - 1
  local text_prefix = "ui_guild_levelup_"
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_LEVEL_POS_MEMBER_MAX_PLUS) then
    text_prefix = "ui_guild_levelup_789_"
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.mltbox_1.HtmlText = nx_widestr(gui.TextManager:GetFormatText(nx_string(text_prefix) .. nx_string(form.guild_level)))
    form.mltbox_2.HtmlText = nx_widestr(gui.TextManager:GetFormatText(nx_string(text_prefix) .. nx_string(form.guild_level + 1)))
  end
  get_level_up_ini(form, form.guild_level)
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.groupbox_4.Visible then
    return
  end
  if nx_int(form.guild_level) >= nx_int(5) then
    return
  end
  form.guild_level = form.guild_level + 1
  local text_prefix = "ui_guild_levelup_"
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_LEVEL_POS_MEMBER_MAX_PLUS) then
    text_prefix = "ui_guild_levelup_789_"
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    if nx_int(form.guild_level) >= nx_int(5) then
      form.mltbox_1.HtmlText = nx_widestr(gui.TextManager:GetFormatText(nx_string(text_prefix) .. nx_string(form.guild_level)))
      form.mltbox_2.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_guild_max_guild"))
    else
      form.mltbox_1.HtmlText = nx_widestr(gui.TextManager:GetFormatText(nx_string(text_prefix) .. nx_string(form.guild_level)))
      form.mltbox_2.HtmlText = nx_widestr(gui.TextManager:GetFormatText(nx_string(text_prefix) .. nx_string(form.guild_level + 1)))
    end
  end
  get_level_up_ini(form, form.guild_level)
end
function on_btn_up_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.groupbox_4.Visible then
    return
  end
  local guild_name = get_player_gild_name()
  if nx_widestr(guild_name) == nx_widestr("") then
    return 0
  end
  custom_request_guild_upgrate(guild_name)
end
function trans_money(form, money)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(money) < nx_int(0) then
    money = 0
  end
  local ding = nx_int(money / wen_to_ding)
  local liang = nx_int((money - ding * wen_to_ding) / wen_to_liang)
  local wen = money - ding * wen_to_ding - liang * wen_to_liang
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.lbl_17.Text = nx_widestr(gui.TextManager:GetFormatText("ui_newguild_money", nx_int(ding), nx_int(liang), nx_int(wen)))
  end
end
function show_level_up_info(form)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_level_old.Text = nx_widestr(form.guild_level)
  if nx_int(form.guild_level) >= nx_int(5) then
    form.lbl_level_next.Text = nx_widestr(util_text("ui_newguild_max_title"))
    form.lbl_15.Visible = false
  else
    form.lbl_level_next.Text = nx_widestr(form.guild_level + 1)
    form.lbl_15.Visible = true
  end
  for i = 1, MAX_GUILD_LEVEL do
    local ctrl = nx_custom(form, "lbl_light_" .. nx_string(i))
    if ctrl ~= nil and nx_is_valid(ctrl) then
      if nx_int(i) == nx_int(form.guild_level) then
        ctrl.Visible = true
      else
        ctrl.Visible = false
      end
    end
  end
end
function show_other_condition(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    if nx_int(form.guild_level) >= nx_int(5) then
      form.mltbox_4.HtmlText = nx_widestr("")
    else
      form.mltbox_4.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_guild_levelupcost_" .. nx_string(form.guild_level)))
    end
  end
end
function get_level_up_ini(form, level)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(level) < nx_int(0) or nx_int(level) > nx_int(5) then
    return
  end
  local file = "share\\Guild\\guild_limit_cost.ini"
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_LEVEL_POS_MEMBER_MAX_PLUS) then
    file = "share\\Guild\\guild_limit_cost_plus.ini"
  end
  local ini = nx_execute("util_functions", "get_ini", file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex(nx_string(level))
  if sec_count < 0 then
    return
  end
  local level_info = ini:GetSectionItemValue(sec_count, nx_int(0))
  local level_info_list = util_split_string(level_info, ",")
  local count = table.getn(level_info_list)
  if nx_int(count) < nx_int(7) then
    return
  end
  local need_money = nx_int(level_info_list[3])
  trans_money(form, need_money)
  local need_renqi = nx_int(level_info_list[4])
  form.lbl_16.Text = nx_widestr(need_renqi)
  show_level_up_info(form)
  show_other_condition(form)
end
function recv_guild_level_up_data(...)
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_levelup", false)
  if not nx_is_valid(form) then
    return
  end
  local num = table.getn(arg)
  if num < 1 then
    return
  end
  form.guild_level = nx_int(arg[1])
  if nx_int(form.guild_level) < nx_int(1) then
    form.guild_level = 1
  end
  local text_prefix = "ui_guild_levelup_"
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_LEVEL_POS_MEMBER_MAX_PLUS) then
    text_prefix = "ui_guild_levelup_789_"
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    if nx_int(form.guild_level) >= nx_int(5) then
      form.mltbox_1.HtmlText = nx_widestr(gui.TextManager:GetFormatText(nx_string(text_prefix) .. "5"))
      form.mltbox_2.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_guild_max_guild"))
    else
      form.mltbox_1.HtmlText = nx_widestr(gui.TextManager:GetFormatText(nx_string(text_prefix) .. nx_string(form.guild_level)))
      form.mltbox_2.HtmlText = nx_widestr(gui.TextManager:GetFormatText(nx_string(text_prefix) .. nx_string(form.guild_level + 1)))
    end
  end
  get_level_up_ini(form, nx_int(form.guild_level))
end
function on_rbtn_build_levelup_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_3.Visible = true
  form.groupbox_4.Visible = false
  form.groupbox_5.Visible = false
  form.groupbox_demotion.Visible = false
end
function on_rbtn_guild_levelup_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_3.Visible = false
  form.groupbox_4.Visible = true
  form.groupbox_5.Visible = false
  form.groupbox_demotion.Visible = false
end
function on_rbtn_guild_prosperity_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_3.Visible = false
  form.groupbox_4.Visible = false
  form.groupbox_5.Visible = true
  form.groupbox_demotion.Visible = false
end
function on_rbtn_guild_demotion_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_3.Visible = false
  form.groupbox_4.Visible = false
  form.groupbox_5.Visible = false
  form.groupbox_demotion.Visible = true
end
function req_level_down_data()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_DEGRADE_INFO))
end
function on_recv_degrade_info(...)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_levelup")
  if not nx_is_valid(form) then
    return
  end
  local size = table.getn(arg)
  if size < 2 then
    return
  end
  local dif_mopney = nx_int64(arg[1])
  local dif_hotness = nx_int64(arg[2])
  local gui = nx_value("gui")
  if nx_int64(dif_mopney) > nx_int64(0) then
    local money = nx_widestr(gui.TextManager:GetFormatText("ui_gc_money", nx_int64(dif_mopney)))
    form.lbl_demotion_dif_money.ForeColor = "255,255,204,0"
    form.lbl_demotion_dif_money.Text = nx_widestr(money)
  else
    form.lbl_demotion_dif_money.ForeColor = "255,255,0,0"
    local temp_money = nx_int64(dif_mopney) * nx_int(-1)
    local money = nx_widestr(gui.TextManager:GetFormatText("ui_gc_money", nx_int64(temp_money)))
    form.lbl_demotion_dif_money.Text = nx_widestr("-") .. nx_widestr(money)
  end
  if nx_int64(dif_hotness) > nx_int64(0) then
    form.lbl_demotion__dif_hotness.ForeColor = "255,255,204,0"
  else
    form.lbl_demotion__dif_hotness.ForeColor = "255,255,0,0"
  end
  form.lbl_demotion__dif_hotness.Text = nx_widestr(dif_hotness)
end
function show_degrade_info(form)
  for i = 1, nx_number(MAX_GUILD_LEVEL) do
    if ini_degrade_tab[i] ~= nil then
      local lbl_daly_hotness = form.groupbox_demotion:Find("lbl_demotion_daly_hotness_" .. nx_string(i))
      if nx_is_valid(lbl_daly_hotness) then
        lbl_daly_hotness.Text = nx_widestr(ini_degrade_tab[i].dailycosthotness)
      end
      local lbl_daly_money = form.groupbox_demotion:Find("lbl_demotion_daly_money_" .. nx_string(i))
      if nx_is_valid(lbl_daly_money) then
        lbl_daly_money.Text = get_captial_text(ini_degrade_tab[i].dailycostcapital)
      end
      local lbl_min_hotness = form.groupbox_demotion:Find("lbl_demotion_min_hotness_" .. nx_string(i))
      if nx_is_valid(lbl_min_hotness) then
        lbl_min_hotness.Text = nx_widestr(ini_degrade_tab[i].minhotness)
      end
      local lbl_min_money = form.groupbox_demotion:Find("lbl_demotion_min_money_" .. nx_string(i))
      if nx_is_valid(lbl_min_money) then
        lbl_min_money.Text = get_captial_text(ini_degrade_tab[i].minmoney)
      end
    end
  end
end
function degrade_info_ini()
  local file = "share\\Guild\\guild_limit_cost.ini"
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_LEVEL_POS_MEMBER_MAX_PLUS) then
    file = "share\\Guild\\guild_limit_cost_plus.ini"
  end
  local ini = nx_execute("util_functions", "get_ini", file)
  if not nx_is_valid(ini) then
    return
  end
  ini_degrade_tab = {}
  local section_count = ini:GetSectionCount()
  if section_count <= 0 then
    return
  end
  for i = nx_number(0), nx_number(section_count - 1) do
    local section = nx_number(ini:GetSectionByIndex(i))
    local item_count = nx_number(ini:GetSectionItemCount(i))
    if 0 < item_count then
      local str_info = nx_string(ini:GetSectionItemValue(i, 0))
      local str_list = util_split_string(str_info, ",")
      local tab = {}
      tab.dailycostcapital = str_list[2]
      tab.dailycosthotness = str_list[5]
      tab.minmoney = str_list[6]
      tab.minhotness = str_list[7]
      table.insert(ini_degrade_tab, section, tab)
    end
  end
end
