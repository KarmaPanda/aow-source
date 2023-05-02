require("util_functions")
require("util_gui")
require("role_composite")
require("form_stage_main\\form_home\\form_home_msg")
require("form_stage_main\\switch\\switch_define")
require("tips_data")
require("share\\view_define")
local STEP_SCENE = 1
local STEP_AREA = 2
local STEP_WORLD = 3
local area_xml = {
  xibei = "form_stage_main\\form_home\\form_home_area_xibei",
  xinan = "form_stage_main\\form_home\\form_home_area_xinan",
  jiangnan = "form_stage_main\\form_home\\form_home_area_jiangnan",
  huabei = "form_stage_main\\form_home\\form_home_area_huabei",
  zhongyuan = "form_stage_main\\form_home\\form_home_area_zhongyuan",
  jinling = "form_stage_main\\form_home\\form_home_area_jinling",
  world = "form_stage_main\\form_home\\form_home_area_world"
}
local child_form = {
  "form_stage_main\\form_home\\form_home_myhome",
  "form_stage_main\\form_home\\form_home_neighbor",
  "form_stage_main\\form_home\\form_home_world"
}
local clear_form = {
  "form_stage_main\\form_home\\form_home_button",
  "form_stage_main\\form_home\\form_clothes_rack",
  "form_stage_main\\form_home\\form_weapon_hanger",
  "form_stage_main\\form_home\\form_weapon_hanger",
  "form_stage_main\\form_home\\form_home_wuxue",
  "form_stage_main\\form_home\\form_building_select",
  "form_stage_main\\form_home\\form_building_levelup",
  "form_stage_main\\form_home\\form_building_hire",
  "form_stage_main\\form_home\\form_building_hire_money",
  "form_stage_main\\form_home\\form_building_hire_info",
  "form_stage_main\\form_home\\form_building_hire_all_info",
  "form_stage_main\\form_home\\form_building_active"
}
local ownership_table = {}
local ownership_time = {}
local once_page_count_ownership = 10
local least_interval = 10000
local CurrentPage = 1
local HomePageRowCount = 8
local HomeDealPageColumn = 9
local DealPageRowCount = 9
local DealPageColumn = 7
local enter_type_owner = 1
local enter_type_visit = 2
local enter_type_open_lock = 3
function tc(msg)
  nx_msgbox(nx_string(msg))
end
function open_form(...)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_HOME) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("11781"))
    return
  end
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form.Visible = not form.Visible
    return
  end
  form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "iscreatehouse") then
    nx_set_custom(form, "iscreatehouse", 0)
  end
  if nx_int(table.getn(arg)) == nx_int(1) and nx_int(arg[1]) == nx_int(1) then
    form.iscreatehouse = 1
  end
  form.Visible = true
  form:Show()
end
function main_form_init(form)
  form.Fixed = false
  form.step = STEP_SCENE
  form.areaid = ""
  form.sceneid = ""
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  for i = 1, table.getn(child_form) do
    local form_child = nx_execute("util_gui", "util_get_form", child_form[i], true, false)
    if nx_is_valid(form_child) then
      form.groupbox_main:Add(form_child)
      form_child.Top = 0
      form_child.Left = 0
      if i == 2 then
        form_child.Top = 316
      end
      form_child.Visible = false
    end
  end
  form.btn_buyback.Visible = false
  form.btn_deal_join.Visible = false
  form.btn_sellinfo.Visible = false
  form.groupbox_house.Visible = false
  form.groupbox_house_deal.Visible = false
  if not nx_find_custom(form, "iscreatehouse") then
    nx_set_custom(form, "iscreatehouse", 0)
  end
  if nx_int(form.iscreatehouse) == nx_int(1) then
    form.groupbox_menu.Visible = false
    on_rbtn_click(form.rbtn_neighbor)
    form.btn_enter.Visible = false
  else
    form.groupbox_menu.Visible = true
    on_btn_myhome_click(form.btn_myhome)
    form.btn_enter.Visible = true
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_HOME_OWNERSHIP) then
    form.btn_house.Enabled = false
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_HOME_BID) then
    form.btn_house_deal.Enabled = false
  end
  form.map_query = nx_value("MapQuery")
  local sceneid = get_current_sceneid(form)
  refresh_map(form, STEP_SCENE, sceneid)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function close_home_form()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.iscreatehouse) == nx_int(1) then
    form:Close()
  end
end
function on_btn_myhome_click(btn)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_house.Visible = false
  form.groupbox_house_deal.Visible = false
  on_rbtn_click(form.rbtn_myhome)
end
function on_rbtn_click(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  rbtn.Checked = true
  for i = 1, table.getn(child_form) do
    local sub_form = nx_value(child_form[i])
    if nx_is_valid(sub_form) then
      sub_form.Visible = false
    end
  end
  local form_child_myhome = form.groupbox_main:Find(child_form[1])
  local form_child_neighbor = form.groupbox_main:Find(child_form[2])
  local form_child_world = form.groupbox_main:Find(child_form[3])
  if not (nx_is_valid(form_child_myhome) and nx_is_valid(form_child_neighbor)) or not nx_is_valid(form_child_world) then
    return
  end
  form_child_myhome.lbl_home_name.Visible = false
  form_child_myhome.Visible = false
  form_child_neighbor.Visible = true
  form_child_neighbor.groupbox_6.Visible = false
  form_child_neighbor.groupbox_7.Visible = false
  form_child_world.Visible = false
  if rbtn.TabIndex == 1 then
    form_child_myhome.Visible = true
    form_child_neighbor.groupbox_6.Visible = true
  elseif rbtn.TabIndex == 2 then
    form_child_world.Visible = true
    form_child_neighbor.groupbox_7.Visible = true
  end
end
function on_btn_up_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.step == STEP_SCENE then
    refresh_map(form, STEP_AREA, form.areaid)
  elseif form.step == STEP_AREA then
    refresh_map(form, STEP_WORLD, "world")
  elseif form.step == STEP_WORLD then
    return
  end
end
function hide_all_child_form(form)
  if not nx_is_valid(form) then
    return
  end
  local childs = form.groupbox_map:GetChildControlList()
  for _, child in ipairs(childs) do
    if nx_is_valid(child) then
      child.Visible = false
    end
  end
end
function refresh_map(form, step, strid)
  if not nx_is_valid(form) then
    return
  end
  if nx_string(strid) == "" then
    return
  end
  if nx_number(step) == STEP_SCENE and not form.map_query:IsSceneVisited(nx_string(strid)) then
    return
  end
  hide_all_child_form(form)
  form.groupbox_2.Visible = false
  if nx_number(step) == STEP_SCENE then
    if open_scene_form(form, nx_string(strid)) then
      form.step = STEP_SCENE
      form.areaid = form.map_query:GetAreaOfScene(strid)
      form.sceneid = nx_string(strid)
      form.groupbox_2.Visible = true
    end
  elseif nx_number(step) == STEP_AREA then
    if open_area_form(form, nx_string(strid)) then
      form.step = STEP_AREA
    end
  elseif nx_number(step) == STEP_WORLD and open_world_form(form, nx_string(strid)) then
    form.step = STEP_WORLD
  end
end
function get_current_sceneid(form)
  return form.map_query:GetCurrentScene()
end
function open_world_form(parent_form, worldid)
  local ret = open_area_form(parent_form, worldid)
  return ret
end
function open_area_form(parent_form, areaid)
  if areaid == "" then
    return false
  end
  local area_path = area_xml[nx_string(areaid)]
  if nil == area_path or "" == area_path then
    return false
  end
  local child_form = nx_value(area_path)
  if not nx_is_valid(child_form) then
    child_form = nx_execute("util_gui", "util_get_form", area_path, true, false)
    if not nx_is_valid(child_form) then
      return false
    end
    local is_load = parent_form.groupbox_map:Add(child_form)
    if is_load == true then
      child_form.Top = 0
      child_form.Left = 0
    else
      return false
    end
  end
  if not nx_is_valid(child_form) then
    return false
  end
  child_form.Visible = true
  return true
end
function open_scene_form(parent_form, sceneid)
  if sceneid == "" then
    sceneid = get_current_sceneid(parent_form)
  end
  local child_form = nx_value("form_stage_main\\form_home\\form_home_map_scene")
  if not nx_is_valid(child_form) then
    child_form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_home\\form_home_map_scene", true, false)
    if not nx_is_valid(child_form) then
      return false
    end
    local is_load = parent_form.groupbox_map:Add(child_form)
    if is_load == true then
      child_form.Top = 0
      child_form.Left = 0
    else
      return false
    end
  end
  if not nx_is_valid(child_form) then
    return false
  end
  child_form.Visible = true
  if not nx_find_custom(parent_form, "iscreatehouse") then
    nx_set_custom(parent_form, "iscreatehouse", 0)
  end
  nx_execute("form_stage_main\\form_home\\form_home_map_scene", "refresh_form", child_form, sceneid, parent_form.iscreatehouse)
  return true
end
function on_btn_enter_click(btn)
  local main_form = btn.ParentForm
  local form = nx_value("form_stage_main\\form_home\\form_home_myhome")
  if not nx_is_valid(form) or not nx_is_valid(main_form) then
    return
  end
  if not form.Visible then
    return
  end
  if not nx_find_custom(form, "home_id") or nx_string(form.home_id) == nx_string("") then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_ENTRY, nx_string(form.home_id), 1)
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
  main_form:Close()
end
function on_btn_help_info_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_helper\\form_theme_helper", "util_open_theme", "jyxg")
end
function clear_home_form()
  for i = 1, table.getn(clear_form) do
    local close_form = nx_value(clear_form[i])
    if nx_is_valid(close_form) then
      close_form:Close()
    end
  end
end
function on_cbtn_set_visit_click(cbtn)
  local form_home_myhome = nx_value("form_stage_main\\form_home\\form_home_myhome")
  if not nx_is_valid(form_home_myhome) then
    return
  end
  if not nx_find_custom(form_home_myhome, "home_id") or nx_string(form_home_myhome.home_id) == nx_string("") then
    return
  end
  if not cbtn.Checked then
    set_visit(cbtn)
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = util_text("text_home_guest_set")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    set_visit(cbtn)
    return
  else
    cbtn.Checked = false
    return
  end
end
function set_visit(cbtn)
  local form_home_myhome = nx_value("form_stage_main\\form_home\\form_home_myhome")
  if not nx_is_valid(form_home_myhome) then
    return
  end
  if not nx_find_custom(form_home_myhome, "home_id") or nx_string(form_home_myhome.home_id) == nx_string("") then
    return
  end
  client_to_server_msg(CLIENT_SUB_SET_VISIT, nx_string(form_home_myhome.home_id), nx_int(cbtn.Checked))
end
function refresh_visit(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if table.getn(arg) < 5 then
    return
  end
  local home_id = nx_string(arg[1])
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local row = client_player:FindRecordRow("self_home_rec", 0, nx_string(home_id), 0)
  if nx_int(row) < nx_int(0) then
    return
  end
  form.cbtn_set_visit.Enabled = true
  local flag = nx_widestr(arg[5])
  if nx_widestr(flag) == nx_widestr("0") then
    form.cbtn_set_visit.Checked = true
  else
    form.cbtn_set_visit.Checked = false
  end
end
function on_btn_house_deal_click(btn)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_house.Visible = false
  form.groupbox_house_deal.Visible = true
  CurrentPage = 1
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_SCENE_SELL_INFO, nx_int(CurrentPage), nx_int(DealPageRowCount))
end
function on_btn_house_click(btn)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_house.Visible = true
  form.groupbox_house_deal.Visible = false
  CurrentPage = 1
  ModifyCurrentPage()
  local index = get_page_index(nx_int(CurrentPage), once_page_count_ownership)
  if is_current_page_available(index) then
    nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_HOME_INFO, nx_int(CurrentPage), nx_int(HomePageRowCount), nx_int(once_page_count_ownership))
    ownership_time[index] = GetServerTime()
  elseif nx_int(index) <= nx_int(table.getn(ownership_table)) then
    receive_home_data(unpack(ownership_table[index]))
  end
end
function receive_home_data(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid_house
  grid:BeginUpdate()
  grid:ClearRow()
  grid:ClearSelect()
  grid.ColCount = HomeDealPageColumn
  grid.ColWidths = "135,90,105,115,75,75,75,50,50"
  grid.RowHeight = 56
  grid.RowHeaderVisible = true
  local nArgsCount = 11
  local PlayerArgsCount = table.getn(ownership_table.my)
  local row = grid:InsertRow(-1)
  if nx_int(PlayerArgsCount) ~= nx_int(nArgsCount) then
    grid:SetGridText(row, 0, nx_widestr("--"))
    grid:SetGridText(row, 1, nx_widestr("--"))
    grid:SetGridText(row, 2, nx_widestr("--"))
    grid:SetGridText(row, 3, nx_widestr("--"))
    grid:SetGridText(row, 4, nx_widestr("--"))
    grid:SetGridText(row, 5, nx_widestr("--"))
    grid:SetGridText(row, 6, nx_widestr("--"))
    grid:SetGridText(row, 7, nx_widestr("--"))
    grid:SetGridText(row, 8, nx_widestr("--"))
  else
    local HomeUid = ownership_table.my[1]
    local HomeName = ownership_table.my[2]
    local HomeLevel = ownership_table.my[3]
    local HomeStyle = ownership_table.my[4]
    local SignID = ownership_table.my[5]
    local HomePretty = ownership_table.my[6]
    local HomeFengShui = ownership_table.my[7]
    local HomeFeiQiData = ownership_table.my[8]
    local HomeOwnerName = ownership_table.my[9]
    local OutLevel = ownership_table.my[10]
    local OutDoorPretty = ownership_table.my[11]
    local WstrFeiqiDay = FormatFeiqiData(HomeFeiQiData)
    local GroupBoxLevel = GetLevelGroupBox(grid, nx_int(HomeLevel), nx_int(OutLevel), nx_int(4))
    local GridStyle = GetHomeStyle(nx_int(HomeStyle))
    local SceneName = GetSceneName(nx_int(SignID))
    local GroupBoxStyle = GetStyleGroupBox(grid, GridStyle, SceneName, nx_int(3))
    local GroupBoxVisitHouse = GetVisitHouseGroupBox(grid, nx_int(9), HomeUid)
    grid:SetGridText(row, 0, nx_widestr(HomeOwnerName))
    grid:SetGridText(row, 1, nx_widestr(HomeName))
    grid:SetGridControl(row, 2, GroupBoxStyle)
    grid:SetGridControl(row, 3, GroupBoxLevel)
    grid:SetGridText(row, 4, nx_widestr(HomeFengShui))
    grid:SetGridText(row, 5, nx_widestr(WstrFeiqiDay))
    grid:SetGridText(row, 6, nx_widestr(HomePretty))
    grid:SetGridText(row, 7, nx_widestr(OutDoorPretty))
    grid:SetGridControl(row, 8, GroupBoxVisitHouse)
  end
  form.ipt_house_cur.Text = nx_widestr(CurrentPage)
  if nx_int(table.getn(arg)) < nx_int(1) then
    return
  end
  local totalCount = nx_int(arg[1])
  table.remove(arg, 1)
  local StartArgs = 0
  if nx_number(once_page_count_ownership) == 0 then
    return
  end
  local cPage = nx_number(CurrentPage) % nx_number(once_page_count_ownership)
  if nx_int(cPage) > nx_int(0) then
    StartArgs = (nx_int(cPage) - nx_int(1)) * nx_int(HomePageRowCount)
  else
    StartArgs = (nx_int(once_page_count_ownership) - nx_int(1)) * nx_int(HomePageRowCount)
  end
  if nx_int(StartArgs) >= nx_int(totalCount) then
    return
  end
  local DataCount = totalCount - StartArgs
  if DataCount > HomePageRowCount then
    DataCount = HomePageRowCount
  end
  for i = 0, DataCount - 1 do
    local HomeUid = arg[(i + StartArgs) * nArgsCount + 1]
    if HomeUid == nil then
      grid:EndUpdate()
      return
    end
    local HomeName = arg[(i + StartArgs) * nArgsCount + 2]
    local HomeLevel = arg[(i + StartArgs) * nArgsCount + 3]
    local HomeStyle = arg[(i + StartArgs) * nArgsCount + 4]
    local SignID = arg[(i + StartArgs) * nArgsCount + 5]
    local HomePretty = arg[(i + StartArgs) * nArgsCount + 6]
    local HomeFengShui = arg[(i + StartArgs) * nArgsCount + 7]
    local HomeFeiQiData = arg[(i + StartArgs) * nArgsCount + 8]
    local HomeOwnerName = arg[(i + StartArgs) * nArgsCount + 9]
    local OutLevel = arg[(i + StartArgs) * nArgsCount + 10]
    local OutDoorPretty = arg[(i + StartArgs) * nArgsCount + 11]
    local WstrFeiqiDay = FormatFeiqiData(HomeFeiQiData)
    local GroupBoxLevel = GetLevelGroupBox(grid, nx_int(HomeLevel), nx_int(OutLevel), nx_int(4))
    local GridStyle = GetHomeStyle(nx_int(HomeStyle))
    local SceneName = GetSceneName(nx_int(SignID))
    local GroupBoxStyle = GetStyleGroupBox(grid, GridStyle, SceneName, nx_int(3))
    local GroupBoxVisitHouse = GetVisitHouseGroupBox(grid, nx_int(9), HomeUid)
    row = grid:InsertRow(-1)
    grid:SetGridText(row, 0, nx_widestr(HomeOwnerName))
    grid:SetGridText(row, 1, nx_widestr(HomeName))
    grid:SetGridControl(row, 2, GroupBoxStyle)
    grid:SetGridControl(row, 3, GroupBoxLevel)
    grid:SetGridText(row, 4, nx_widestr(HomeFengShui))
    grid:SetGridText(row, 5, nx_widestr(WstrFeiqiDay))
    grid:SetGridText(row, 6, nx_widestr(HomePretty))
    grid:SetGridText(row, 7, nx_widestr(OutDoorPretty))
    grid:SetGridControl(row, 8, GroupBoxVisitHouse)
  end
  grid:EndUpdate()
end
function receive_home_sell_data(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid_house_deal
  grid:BeginUpdate()
  grid:ClearRow()
  grid:ClearSelect()
  if form.btn_deal_join.Visible then
    form.btn_deal_join.Visible = false
  end
  grid.ColCount = DealPageColumn
  grid.RowHeight = 56
  grid.ColWidths = "100,118,145,105,115,135,70"
  grid.RowHeaderVisible = true
  if nx_int(table.getn(arg)) < nx_int(3) then
    return
  end
  local DataCount = arg[1]
  local TotalPage = arg[2]
  CurrentPage = arg[3]
  form.lbl_deal_total_page.Text = nx_widestr(TotalPage)
  form.ipt_in_page.Text = nx_widestr(CurrentPage)
  table.remove(arg, 1)
  table.remove(arg, 1)
  table.remove(arg, 1)
  local ArgsCount = 10
  if nx_int(DataCount * ArgsCount) ~= nx_int(table.getn(arg)) or nx_int(DataCount) == nx_int(0) then
    return
  end
  for i = 1, DataCount do
    local HomeUid = arg[(i - 1) * ArgsCount + 1]
    local HomeSignId = arg[(i - 1) * ArgsCount + 2]
    local HomeName = arg[(i - 1) * ArgsCount + 3]
    local HomeLevel = arg[(i - 1) * ArgsCount + 4]
    local HomeBidPrice = arg[(i - 1) * ArgsCount + 5]
    local HomeBiderName = arg[(i - 1) * ArgsCount + 6]
    local HomeBidDeadline = arg[(i - 1) * ArgsCount + 7]
    local HomeFixPrice = arg[(i - 1) * ArgsCount + 8]
    local isNeighbour = arg[(i - 1) * ArgsCount + 9]
    local HomeStyle = arg[(i - 1) * ArgsCount + 10]
    local GroupboxHomePlace = GetHomePlaceGroupbox(grid, nx_int(2), nx_int(HomeSignId), nx_int(HomeStyle))
    local GroupBoxBidPrice = GetBidPriceGroupBox(grid, nx_int64(HomeBidPrice), nx_int(3))
    local BidLeftTime = FormatBidLeftTime(HomeBidDeadline, HomeBiderName)
    local GroupBoxFixPrice = GetBidPriceGroupBox(grid, nx_int64(HomeFixPrice), nx_int(6))
    local GroupBoxVisitHosu = GetVisitHouseGroupBox(grid, nx_int(7), HomeUid, HomeSignId, HomeFixPrice)
    local row = grid:InsertRow(-1)
    grid:SetGridText(row, 0, nx_widestr(HomeName))
    grid:SetGridControl(row, 1, GroupboxHomePlace)
    grid:SetGridControl(row, 2, GroupBoxBidPrice)
    grid:SetGridText(row, 3, nx_widestr(HomeBiderName))
    grid:SetGridText(row, 4, nx_widestr(BidLeftTime))
    grid:SetGridControl(row, 5, GroupBoxFixPrice)
    grid:SetGridControl(row, 6, GroupBoxVisitHosu)
  end
  grid:EndUpdate()
end
function CreateGroupBox(Width, Height)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local GroupBox = gui:Create("GroupBox")
  if not nx_is_valid(GroupBox) then
    return
  end
  GroupBox.Width = Width
  GroupBox.Height = Height
  GroupBox.NoFrame = true
  GroupBox.BackColor = "0,255,255,255"
  GroupBox.Transparent = true
  return GroupBox
end
function GetLabelByLevel(groupbox, Level, LblName)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  for i = 1, nx_number(Level) do
    local lbl_star = gui:Create("Label")
    if not nx_is_valid(lbl_star) then
      return
    end
    lbl_star.Name = "lbl_star_" .. nx_string(i)
    groupbox:Add(lbl_star)
    lbl_star.Left = (i - 1) * 20 + LblName.Width + 25
    lbl_star.Top = 9
    lbl_star.BackImage = "gui\\special\\home\\main\\start.png"
    lbl_star.AutoSize = true
  end
end
function GetLevelGroupBox(grid, level, outlevel, gridcol)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ColWidth = grid:GetColWidth(gridcol)
  local LevelGroupBox = CreateGroupBox(ColWidth, nx_int(grid.RowHeight))
  if not nx_is_valid(LevelGroupBox) then
    return
  end
  local EachHeight = grid.RowHeight / 2
  local InnerGroupBox = CreateGroupBox(ColWidth, nx_int(EachHeight))
  if not nx_is_valid(InnerGroupBox) then
    return
  end
  local OutGroupBox = CreateGroupBox(ColWidth, nx_int(EachHeight))
  if not nx_is_valid(OutGroupBox) then
    return
  end
  LevelGroupBox:Add(InnerGroupBox)
  InnerGroupBox.Left = 0
  InnerGroupBox.Top = 0
  LevelGroupBox:Add(OutGroupBox)
  OutGroupBox.Left = 0
  OutGroupBox.Top = EachHeight - 5
  local lbl_inner = gui:Create("Label")
  if not nx_is_valid(lbl_inner) then
    return
  end
  InnerGroupBox:Add(lbl_inner)
  lbl_inner.Text = nx_widestr(gui.TextManager:GetText("ui_home_shinei"))
  lbl_inner.Width = 35
  lbl_inner.Align = Left
  lbl_inner.Left = 5
  lbl_inner.Top = 10
  GetLabelByLevel(InnerGroupBox, nx_number(level), lbl_inner)
  local lbl_out = gui:Create("Label")
  if not nx_is_valid(lbl_out) then
    return
  end
  OutGroupBox:Add(lbl_out)
  lbl_out.Text = nx_widestr(gui.TextManager:GetText("ui_home_shiwai"))
  lbl_out.Width = 35
  lbl_out.Align = Left
  lbl_out.Left = 5
  lbl_out.Top = 10
  GetLabelByLevel(OutGroupBox, nx_int(outlevel), lbl_out)
  return LevelGroupBox
end
function GetStyleGroupBox(grid, gridStyle, sceneName, gridcol)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ColWidth = grid:GetColWidth(gridcol)
  local StyleGroupBox = CreateGroupBox(ColWidth, nx_int(grid.RowHeight))
  if not nx_is_valid(StyleGroupBox) then
    return
  end
  local lbl_style = gui:Create("Label")
  if not nx_is_valid(lbl_style) then
    return
  end
  StyleGroupBox:Add(lbl_style)
  lbl_style.Text = nx_widestr(gridStyle)
  lbl_style.Width = 35
  lbl_style.Align = Left
  lbl_style.Left = ColWidth / 2 - lbl_style.Width / 2
  lbl_style.Top = grid.RowHeight / 5
  local lbl_scene = gui:Create("Label")
  if not nx_is_valid(lbl_scene) then
    return
  end
  StyleGroupBox:Add(lbl_scene)
  lbl_scene.Text = nx_widestr(gui.TextManager:GetText(sceneName))
  lbl_scene.Width = 35
  lbl_scene.Align = Left
  lbl_scene.Left = ColWidth / 2 - lbl_scene.Width / 2
  lbl_scene.Top = grid.RowHeight / 5 * 3
  return StyleGroupBox
end
function GetPlace(sign_id)
  local home_manager = nx_value("HomeManager")
  if not nx_is_valid(home_manager) then
    return
  end
  local place = nx_widestr("")
  local map_query = nx_value("MapQuery")
  if nx_is_valid(map_query) then
    local home_scene_father = nx_int(home_manager:GetHomeSceneID(sign_id))
    local scene_name = "scene_" .. map_query:GetSceneName(nx_string(home_scene_father))
    place = util_text(scene_name)
    local site = "(" .. nx_string(home_manager:GetHomeX(sign_id)) .. "," .. nx_string(home_manager:GetHomeZ(sign_id)) .. ")"
    place = place .. nx_widestr(site)
  end
  return place
end
function GetSceneName(sign_id)
  local home_manager = nx_value("HomeManager")
  if not nx_is_valid(home_manager) then
    return
  end
  local home_scene_father = nx_int(home_manager:GetHomeSceneID(sign_id))
  local scene_name = "ui_scene_" .. nx_string(home_scene_father)
  return scene_name
end
function GetBidPriceGroupBox(grid, bid_price, gridcol)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local BidPriceGroupBox = CreateGroupBox(grid:GetColWidth(gridcol), grid.RowHeight)
  if not nx_is_valid(BidPriceGroupBox) then
    return
  end
  local lbl_money = gui:Create("Label")
  BidPriceGroupBox:Add(lbl_money)
  lbl_money.Left = 4
  lbl_money.Top = nx_int(grid.RowHeight / 2 - 5)
  lbl_money.BackImage = "gui\\common\\money\\liang.png"
  lbl_money.AutoSize = true
  local lbl_bid_price = gui:Create("Label")
  BidPriceGroupBox:Add(lbl_bid_price)
  lbl_bid_price.Left = 4 + lbl_money.Width + 4
  lbl_bid_price.Top = nx_int(grid.RowHeight / 2 - 5) - 2
  lbl_bid_price.Text = FormatMoney(bid_price)
  return BidPriceGroupBox
end
function GetHomePlaceGroupbox(grid, gridcol, signId, style)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ColWidth = grid:GetColWidth(gridcol)
  local HomePlaceGroupBox = CreateGroupBox(ColWidth, grid.RowHeight)
  if not nx_is_valid(HomePlaceGroupBox) then
    return
  end
  local lbl_place = gui:Create("Label")
  HomePlaceGroupBox:Add(lbl_place)
  local HomePlace = GetPlace(nx_int(signId))
  lbl_place.Text = nx_widestr(HomePlace)
  lbl_place.Width = ColWidth
  lbl_place.Align = Left
  lbl_place.Left = 0
  lbl_place.Top = grid.RowHeight / 5
  local lbl_style = gui:Create("Label")
  HomePlaceGroupBox:Add(lbl_style)
  local HomeStyle = GetHomeStyle(nx_int(style))
  lbl_style.Text = nx_widestr(HomeStyle)
  lbl_style.Width = 35
  lbl_style.Align = Left
  lbl_style.Left = ColWidth / 2 - lbl_style.Width
  lbl_style.Top = grid.RowHeight / 5 * 3
  return HomePlaceGroupBox
end
function FormatMoney(money)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local base_ding = nx_int64(nx_int64(money) / 1000000)
  local base_liang = nx_int64((nx_int64(money) - nx_int64(base_ding) * 1000000) / 1000)
  local base_wen = nx_int64(nx_int64(money) - nx_int64(base_ding) * 1000000 - nx_int64(base_liang) * 1000)
  return nx_widestr(gui.TextManager:GetFormatText("ui_guild_capital1", base_ding, base_liang, base_wen))
end
function FormatBidLeftTime(bid_time, bid_name)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ServerTime = GetServerTime()
  local LeftTime = nx_int64(bid_time) - nx_int64(ServerTime)
  if LeftTime < 0 then
    if nx_widestr(bid_name) == nx_widestr("") then
      return nx_widestr(gui.TextManager:GetFormatText("ui_homehouse_deal_11"))
    else
      return nx_widestr(gui.TextManager:GetFormatText("ui_homehouse_deal_10"))
    end
  end
  local hour = nx_int(LeftTime / 1000 / 3600)
  local minute = nx_int((LeftTime / 1000 - 3600 * hour) / 60)
  return nx_widestr(gui.TextManager:GetFormatText("ui_guildbuilding_left_time", hour, minute))
end
function GetServerTime()
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return 0
  end
  return msg_delay:GetServerNowTime()
end
function GetVisitHouseGroupBox(grid, gridcol, HomeUid, HomeSignId, HomeFixPrice)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local VisitGroupBox = CreateGroupBox(grid:GetColWidth(gridcol), grid.RowHeight)
  if not nx_is_valid(VisitGroupBox) then
    return
  end
  VisitGroupBox.IsOverDay = false
  if nx_int64(0) == nx_int64(HomeFixPrice) then
    VisitGroupBox.IsOverDay = true
  end
  VisitGroupBox.HomeUid = HomeUid
  VisitGroupBox.HomeSignId = HomeSignId
  local RequestBtn = gui:Create("Button")
  if not nx_is_valid(RequestBtn) then
    return
  end
  VisitGroupBox:Add(RequestBtn)
  RequestBtn.Left = 2
  RequestBtn.Top = nx_int(grid.RowHeight / 2 - 5)
  RequestBtn.NormalImage = "gui\\special\\home\\friend_out.png"
  RequestBtn.FocusImage = "gui\\special\\home\\friend_out.png"
  RequestBtn.PushImage = "gui\\special\\home\\friend_out.png"
  RequestBtn.DrawMode = "Tile"
  RequestBtn.AutoSize = true
  nx_bind_script(RequestBtn, nx_current())
  nx_callback(RequestBtn, "on_click", "on_btn_request_visit_click")
  local VisitBtn = gui:Create("Button")
  if not nx_is_valid(RequestBtn) then
    return
  end
  VisitGroupBox:Add(VisitBtn)
  VisitBtn.Left = 2 + RequestBtn.Width + 4
  VisitBtn.Top = nx_int(grid.RowHeight / 2 - 5)
  VisitBtn.NormalImage = "gui\\special\\home\\baifang_out.png"
  VisitBtn.FocusImage = "gui\\special\\home\\baifang_out.png"
  VisitBtn.PushImage = "gui\\special\\home\\baifang_out.png"
  VisitBtn.DrawMode = "Tile"
  VisitBtn.AutoSize = true
  nx_bind_script(VisitBtn, nx_current())
  nx_callback(VisitBtn, "on_click", "on_btn_visit_click")
  if is_my_home(HomeUid) then
    VisitGroupBox.Visible = false
  end
  return VisitGroupBox
end
function on_btn_request_visit_click(btn)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local GroupBox = btn.Parent
  if not nx_is_valid(GroupBox) then
    return
  end
  local homeuid = GroupBox.HomeUid
  if nx_string(homeuid) == nx_string("") then
    return
  end
  if is_my_home(homeuid) then
    self_systemcenterinfo("home_enter_failed_03")
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_ADD_NEIGHBOUR, nx_string(homeuid))
end
function is_my_home(homeid)
  local recordname = "self_home_rec"
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  row = client_player:FindRecordRow(recordname, 0, homeid, 0)
  if row >= 0 then
    return true
  end
  return false
end
function self_systemcenterinfo(msgid)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(nx_widestr(util_text(nx_string(msgid))), 2)
  end
end
function on_btn_visit_click(btn)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local GroupBox = btn.Parent
  if not nx_is_valid(GroupBox) then
    return
  end
  local homeid = GroupBox.HomeUid
  if nx_string(homeid) == nx_string("") then
    return
  end
  if is_my_home(homeid) then
    self_systemcenterinfo("home_enter_failed_03")
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_ENTRY, nx_string(homeid), nx_int(enter_type_visit))
end
function on_btn_deal_last_click(btn)
  CurrentPage = nx_int(CurrentPage) - nx_int(1)
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_SCENE_SELL_INFO, nx_int(CurrentPage), nx_int(DealPageRowCount))
end
function on_btn_deal_next_click(btn)
  CurrentPage = nx_int(CurrentPage) + nx_int(1)
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_SCENE_SELL_INFO, nx_int(CurrentPage), nx_int(DealPageRowCount))
end
function on_btn_deal_skip_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  CurrentPage = form.ipt_in_page.Text
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_SCENE_SELL_INFO, nx_int(CurrentPage), nx_int(DealPageRowCount))
end
function on_textgrid_house_deal_select_row(grid, row)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form.btn_deal_join.Visible = false
  form.btn_sellinfo.Visible = false
  local GroupBox = grid:GetGridControl(row, 6)
  if not nx_is_valid(GroupBox) then
    return
  end
  if is_my_home(GroupBox.HomeUid) then
    if GroupBox.IsOverDay == false then
      form.btn_sellinfo.Visible = true
    end
    form.btn_sellinfo.HomeUid = GroupBox.HomeUid
    form.btn_sellinfo.HomeSignId = GroupBox.HomeSignId
  else
    form.btn_deal_join.Visible = true
    form.btn_deal_join.HomeUid = GroupBox.HomeUid
    form.btn_deal_join.HomeSignId = GroupBox.HomeSignId
  end
end
function on_btn_sellinfo_click(btn)
  if not nx_find_custom(btn, "HomeUid") then
    return
  end
  local homeuid = btn.HomeUid
  if nx_string(homeuid) == nx_string("") then
    return
  end
  if not is_my_home(homeuid) then
    self_systemcenterinfo("home_enter_failed_02")
    return
  end
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_SELLINFO, nx_string(homeuid), nx_int(btn.HomeSignId))
end
function on_btn_deal_join_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_HOME_BID) then
    return
  end
  if not nx_find_custom(btn, "HomeUid") then
    return
  end
  local homeuid = btn.HomeUid
  if nx_string(homeuid) == nx_string("") then
    return
  end
  if is_my_home(homeuid) then
    self_systemcenterinfo("home_enter_failed_03")
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_BUYHOME, nx_string(homeuid), nx_int(btn.HomeSignId))
end
function GetHomeStyle(homestyle)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
  end
  if nx_int(1) == nx_int(homestyle) then
    return gui.TextManager:GetText("ui_home_caofang")
  elseif nx_int(2) == nx_int(homestyle) then
    return gui.TextManager:GetText("ui_home_mufang")
  elseif nx_int(3) == nx_int(homestyle) then
    return gui.TextManager:GetText("ui_home_zhuanfang")
  elseif nx_int(4) == nx_int(homestyle) then
    return gui.TextManager:GetText("ui_home_shifang")
  elseif nx_int(5) == nx_int(homestyle) then
    return gui.TextManager:GetText("ui_home_dongfang")
  elseif nx_int(6) == nx_int(homestyle) then
    return gui.TextManager:GetText("ui_home_yuanlin")
  elseif nx_int(7) == nx_int(homestyle) then
    return gui.TextManager:GetText("ui_home_daofang")
  elseif nx_int(8) == nx_int(homestyle) then
    return gui.TextManager:GetText("ui_home_shufang")
  end
end
function on_btn_house_last_click(btn)
  CurrentPage = nx_int(CurrentPage) - nx_int(1)
  ModifyCurrentPage()
  local index = get_page_index(nx_int(CurrentPage), once_page_count_ownership)
  if is_current_page_available(index) then
    nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_HOME_INFO, nx_int(CurrentPage), nx_int(HomePageRowCount), nx_int(once_page_count_ownership))
    ownership_time[index] = GetServerTime()
  elseif nx_int(index) <= nx_int(table.getn(ownership_table)) then
    receive_home_data(unpack(ownership_table[index]))
  end
end
function on_btn_house_next_click(btn)
  CurrentPage = nx_int(CurrentPage) + nx_int(1)
  ModifyCurrentPage()
  local index = get_page_index(nx_int(CurrentPage), once_page_count_ownership)
  if is_current_page_available(index) then
    nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_HOME_INFO, nx_int(CurrentPage), nx_int(HomePageRowCount), nx_int(once_page_count_ownership))
    ownership_time[index] = GetServerTime()
  elseif nx_int(index) <= nx_int(table.getn(ownership_table)) then
    receive_home_data(unpack(ownership_table[index]))
  end
end
function on_btn_house_skip_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  CurrentPage = form.ipt_house_cur.Text
  ModifyCurrentPage()
  local index = get_page_index(nx_int(CurrentPage), once_page_count_ownership)
  if is_current_page_available(index) then
    nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_HOME_INFO, nx_int(CurrentPage), nx_int(HomePageRowCount), nx_int(once_page_count_ownership))
    ownership_time[index] = GetServerTime()
  elseif nx_int(index) <= nx_int(table.getn(ownership_table)) then
    receive_home_data(unpack(ownership_table[index]))
  end
end
function show_buy_myhome_btn(HomeUid, IsShow)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  form.btn_buyback.Visible = IsShow
  form.btn_buyback.HomeUid = HomeUid
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_HOME_BUYBACK) then
    form.btn_buyback.Visible = false
    return
  end
end
function on_btn_buyback_click(btn)
  if not nx_find_custom(btn, "HomeUid") or nx_string(btn.HomeUid) == nx_string("") then
    return
  end
  if not is_my_home(btn.HomeUid) then
    self_systemcenterinfo("home_enter_failed_02")
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_REQUEST_HOME_PRICE, nx_string(btn.HomeUid))
end
function show_current_recycle_price(...)
  local form_myhome = nx_value("form_stage_main\\form_home\\form_home_myhome")
  if not nx_is_valid(form_myhome) then
    return
  end
  if not form_myhome.Visible then
    return
  end
  if not nx_find_custom(form_myhome, "home_id") or nx_string(form_myhome.home_id) == nx_string("") then
    return
  end
  if nx_int(table.getn(arg)) ~= nx_int(1) then
    return
  end
  local current_price = arg[1]
  if nx_int64(current_price) < nx_int64(1) then
    return
  end
  local wsprice = FormatMoney(current_price)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local show_price = gui.TextManager:GetFormatText("ui_home_byback", wsprice)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(show_price))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if nx_string(res) == nx_string("ok") then
    nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_BUY_MY_HOME, nx_string(form_myhome.home_id))
  end
end
function FormatFeiqiData(FeiqiDay)
  if nx_int(FeiqiDay) < nx_int(0) then
    FeiqiDay = 0
  end
  local Maxday = nx_int(get_ini_prop("share\\Home\\HomeSystemConf.ini", "main", "over_time_day", "0"))
  if Maxday < nx_int(FeiqiDay) then
    FeiqiDay = Maxday
  end
  local WstrFeiqiDay = nx_widestr(FeiqiDay) .. nx_widestr("/") .. nx_widestr(Maxday)
  return WstrFeiqiDay
end
function change_home_btn(switch_type, isopen)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if switch_type == ST_FUNCTION_HOME_OWNERSHIP then
    form.btn_house.Enabled = isopen
  elseif switch_type == ST_FUNCTION_HOME_BID then
    form.btn_house_deal.Enabled = isopen
  elseif switch_type == ST_FUNCTION_HOME_BUYBACK then
    form.btn_buyback.Enabled = isopen
  end
end
function get_page_index(current_page, once_page_count)
  if nx_int(current_page) <= nx_int(0) then
    current_page = 1
  end
  if nx_int(once_page_count) == nx_int(0) then
    return
  end
  local index = nx_int((nx_int(current_page) - nx_int(1)) / nx_int(once_page_count)) + nx_int(1)
  return index
end
function is_current_page_available(index)
  local cur_time = GetServerTime()
  local last_time = ownership_time[index]
  if last_time == nil or cur_time - last_time > least_interval then
    return true
  end
  return false
end
function receive_server_ownership_data(...)
  if table.getn(arg) < 1 then
    return
  end
  local nArgsCount = 11
  local PlayerArgsCount = arg[1]
  table.remove(arg, 1)
  if nx_int(PlayerArgsCount) == nx_int(nArgsCount) then
    ownership_table.my = {}
    for i = 1, PlayerArgsCount do
      ownership_table.my[i] = arg[1]
      table.remove(arg, 1)
    end
  else
    ownership_table.my = {}
  end
  if table.getn(arg) < 2 then
    return
  end
  local nTotalPage = arg[1]
  CurrentPage = arg[2]
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form.lbl_house_total.Text = nx_widestr(nTotalPage)
  end
  table.remove(arg, 1)
  table.remove(arg, 1)
  local index = get_page_index(CurrentPage, once_page_count_ownership)
  ownership_table[index] = arg
  receive_home_data(unpack(arg))
end
function ModifyCurrentPage()
  local form = nx_value(nx_current())
  if not nx_is_valid then
    return
  end
  local TotalPage = nx_int(form.lbl_house_total.Text)
  if nx_int(CurrentPage) <= nx_int(0) then
    CurrentPage = 1
  elseif TotalPage < nx_int(CurrentPage) then
    CurrentPage = TotalPage
  end
end
function on_btn_homesearsh_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local home_name = nx_widestr(form.ipt_homesearsh.Text)
  if home_name == nx_widestr("") then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_SEARCH_HOME, home_name)
end
function receive_search_ownership(...)
  if table.getn(arg) < 11 then
    return
  end
  local form = nx_value(nx_current())
  if not nx_is_valid then
    return
  end
  local grid = form.textgrid_house
  if not nx_is_valid(grid) then
    return
  end
  grid:BeginUpdate()
  grid:ClearRow()
  grid:ClearSelect()
  grid.ColCount = HomeDealPageColumn
  grid.ColWidths = "145,95,70,75,75,100,75,100,60"
  grid.RowHeight = 56
  grid.RowHeaderVisible = true
  local HomeUid = arg[1]
  local HomeName = arg[2]
  local HomeLevel = arg[3]
  local HomeStyle = arg[4]
  local SignID = arg[5]
  local HomePretty = arg[6]
  local HomeFengShui = arg[7]
  local HomeFeiQiData = arg[8]
  local HomeOwnerName = arg[9]
  local OutLevel = arg[10]
  local OutDoorPretty = arg[11]
  local WstrFeiqiDay = FormatFeiqiData(HomeFeiQiData)
  local GroupBoxLevel = GetLevelGroupBox(grid, nx_int(HomeLevel), nx_int(OutLevel), nx_int(4))
  local GridStyle = GetHomeStyle(nx_int(HomeStyle))
  local SceneName = GetSceneName(nx_int(SignID))
  local GroupBoxStyle = GetStyleGroupBox(grid, GridStyle, SceneName, nx_int(3))
  local GroupBoxVisitHouse = GetVisitHouseGroupBox(grid, nx_int(9), HomeUid)
  row = grid:InsertRow(-1)
  grid:SetGridText(row, 0, nx_widestr(HomeOwnerName))
  grid:SetGridText(row, 1, nx_widestr(HomeName))
  grid:SetGridControl(row, 2, GroupBoxStyle)
  grid:SetGridControl(row, 3, GroupBoxLevel)
  grid:SetGridText(row, 4, nx_widestr(HomeFengShui))
  grid:SetGridText(row, 5, nx_widestr(WstrFeiqiDay))
  grid:SetGridText(row, 6, nx_widestr(HomePretty))
  grid:SetGridText(row, 7, nx_widestr(OutDoorPretty))
  grid:SetGridControl(row, 8, GroupBoxVisitHouse)
end
