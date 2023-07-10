require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("utils")
require("util_gui")
require("define\\gamehand_type")
require("game_object")
require("util_functions")
require("define\\object_type_define")
require("define\\request_type")
local MAX_PATH_COUNT = 9
local MAX_TEAM_INFO = 5
local escort_team_detail_name = {
  [1] = {},
  [2] = {},
  [3] = {},
  [4] = {},
  [5] = {}
}
local escort_path_info_name = {
  [0] = {},
  [1] = {},
  [2] = {},
  [3] = {},
  [4] = {},
  [5] = {},
  [6] = {},
  [7] = {},
  [8] = {}
}
local escort_path_table = {}
local escort_path_detailinfo_table = {}
local Sel_Escort = -1
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.groupbox_escort_detail_info.Visible = false
  form.escort_table = ""
  init_escort_info_name(form.groupbox_escort_detail_info)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_form_close_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function ok_btn_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_escort_info_click(btn)
  local form = btn.ParentForm
  form.escort_table = btn.escort_table
  Sel_Escort = btn.escort_id
  if form.groupbox_escort_detail_info.Visible then
    local time_down = form.time_down
    if nx_int(time_down) <= nx_int(0) then
      local gui = nx_value("gui")
      if not nx_is_valid(gui) then
        return
      end
      local nMoney, nTimeDown = Get_Escort_ConfigInfo()
      gui.TextManager:Format_SetIDName("ui_buy_team_detailinfo")
      gui.TextManager:Format_AddParam(nx_int(nMoney))
      local text = nx_widestr(gui.TextManager:Format_GetText())
      if not ShowTipDialog(text) then
        return
      end
    end
    nx_execute("custom_sender", "custom_get_escort_info", btn.escort_table)
  end
end
function init_default_sel_escort(escort_id, escort_info)
  local form = util_get_form("form_stage_main\\form_school_war\\form_escortpath_info", true)
  if not nx_is_valid(form) then
    return
  end
  form.escort_table = escort_info
  Sel_Escort = escort_id
end
function btn_escort_detail_info_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.escort_table == "" or form.escort_table == nil then
    return
  end
  local time_down = form.time_down
  if nx_int(time_down) <= nx_int(0) then
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    local nMoney, nTimeDown = Get_Escort_ConfigInfo()
    gui.TextManager:Format_SetIDName("ui_buy_team_detailinfo")
    gui.TextManager:Format_AddParam(nx_int(nMoney))
    local text = nx_widestr(gui.TextManager:Format_GetText())
    if not ShowTipDialog(text) then
      return
    end
    form.time_down = nTimeDown
  end
  nx_execute("custom_sender", "custom_get_escort_info", form.escort_table)
  form.groupbox_escort_detail_info.Visible = true
end
function init_escort_path_ctrl_name(self)
  local num = table.getn(escort_path_info_name)
  for i = 0, num do
    escort_path_info_name[i][1] = nx_string("groupbox_path") .. nx_string(i)
    escort_path_info_name[i][2] = nx_string("escort_info") .. nx_string(i)
    escort_path_info_name[i][3] = nx_string("type") .. nx_string(i)
    escort_path_info_name[i][4] = nx_string("desc") .. nx_string(i)
    escort_path_info_name[i][5] = nx_string("escort_num") .. nx_string(i)
    escort_path_info_name[i][6] = nx_string("startaera") .. nx_string(i)
  end
  for row = 0, num do
    local initgroupboxobj = self:Find(nx_string(escort_path_info_name[row][1]))
    if nx_is_valid(initgroupboxobj) then
      initgroupboxobj.Visible = false
    end
  end
end
function init_escort_info_name(self)
  local num = table.getn(escort_team_detail_name)
  for i = 1, num do
    escort_team_detail_name[i][1] = nx_string("groupbox_") .. nx_string(i)
    escort_team_detail_name[i][2] = nx_string("name") .. nx_string(i)
    escort_team_detail_name[i][3] = nx_string("titlelevel") .. nx_string(i)
    escort_team_detail_name[i][4] = nx_string("team_num") .. nx_string(i)
    escort_team_detail_name[i][5] = nx_string("guildname") .. nx_string(i)
    escort_team_detail_name[i][6] = nx_string("team_sence") .. nx_string(i)
    escort_team_detail_name[i][7] = nx_string("pos") .. nx_string(i)
    escort_team_detail_name[i][8] = nx_string("goods_rank") .. nx_string(i)
    escort_team_detail_name[i][9] = nx_string("goods_num") .. nx_string(i)
  end
  for row = 1, num do
    local initgroupboxobj = self:Find(nx_string(escort_team_detail_name[row][1]))
    if nx_is_valid(initgroupboxobj) then
      initgroupboxobj.Visible = false
    end
  end
end
function ParsePathInfo(PathInfo)
  if string.len(nx_string(PathInfo)) <= 0 then
    return false
  end
  local info = util_split_string(nx_string(PathInfo), ",")
  return true, info
end
function init_escort_path_info(form, path_info_table)
  escort_path_table = {}
  local info_table = util_split_string(nx_string(path_info_table), ";")
  local size = table.getn(info_table)
  for i = 1, size - 1 do
    local bRet, escort_path = ParsePathInfo(info_table[i])
    if bRet == true then
      local nEscortID = escort_path[1]
      local strStartArea, strEndArea, strTypePhoto = Get_Path_Info(nEscortID)
      table.insert(escort_path, strStartArea)
      table.insert(escort_path, strEndArea)
      table.insert(escort_path, strTypePhoto)
      table.insert(escort_path_table, escort_path)
    end
  end
  local nCount = table.getn(escort_path_table)
  if nCount <= MAX_PATH_COUNT then
    form.path_bar.Visible = false
    if nCount <= 0 then
      return 0
    end
  else
    self.path_bar.Visible = true
    self.path_bar.Maximum = nCount - MAX_PATH_COUNT
  end
  path_fresh(form.groupbox_escortpathinfo, 0, MAX_PATH_COUNT, nCount)
end
function Is_Exist_Escort(escort_id)
  local nCount = table.getn(escort_path_table)
  for i = 1, nCount do
    if escort_path_table[i][1] == escort_id then
      return true
    end
  end
  return false
end
function Get_Path_Info(Escort_id)
  local formula_path = nx_execute("util_functions", "get_ini", "share\\War\\escort_path.ini")
  if not nx_is_valid(formula_path) then
    return -1
  end
  local path_index = formula_path:FindSectionIndex(nx_string(Escort_id))
  if path_index < 0 then
    return -1
  end
  local strStartArea = formula_path:ReadString(path_index, "StartArea", "")
  local strEndArea = formula_path:ReadString(path_index, "EndArea", "")
  local strTypePhoto = formula_path:ReadString(path_index, "SmallTypePhoto", "")
  return strStartArea, strEndArea, strTypePhoto
end
function Get_Escort_ConfigInfo()
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\escort_config.ini")
  if not nx_is_valid(ini) then
    return -1
  end
  local index = ini:FindSectionIndex("BaseInfo")
  if index < 0 then
    return -1
  end
  local nBuyTeamInfoMoney = ini:ReadInteger(index, "BuyTeamInfoMoney", 0)
  local nTimeDown = ini:ReadInteger(index, "BuyTeamInfoTime", 0)
  return nBuyTeamInfoMoney, nTimeDown
end
function get_goods_num(escort_id)
  local formula_path = nx_execute("util_functions", "get_ini", "share\\War\\escort_path.ini")
  if not nx_is_valid(formula_path) then
    return -1
  end
  local path_index = formula_path:FindSectionIndex(nx_string(escort_id))
  if path_index < 0 then
    return -1
  end
  local goods_num = formula_path:ReadString(path_index, "GoodsNum", "")
  return goods_num
end
function OnEscortListMsg(...)
  local form = util_get_form("form_stage_main\\form_school_war\\form_escortpath_info", true)
  if not nx_is_valid(form) then
    return
  end
  form.time_down = nx_int(arg[2])
  form.timer_span = 1000
  init_escort_path_ctrl_name(form.groupbox_escortpathinfo)
  init_escort_path_info(form, nx_string(arg[1]))
  Escort_time_down_Started(form)
  util_auto_show_hide_form("form_stage_main\\form_school_war\\form_escortpath_info")
end
function path_fresh(self, startrow, endrow, rownum)
  init_escort_path_ctrl_name(self)
  local num = table.getn(escort_path_table)
  local index = 0
  for row = rownum - startrow, rownum - endrow + 1, -1 do
    if row <= 0 then
      return
    end
    local groupboxname = escort_path_info_name[index][1]
    local groupboxobj = self:Find(groupboxname)
    groupboxobj.Visible = true
    local typename = escort_path_info_name[index][3]
    local lbl_type = groupboxobj:Find(typename)
    if nx_is_valid(lbl_type) then
      lbl_type.BackImage = nx_string(escort_path_table[row][6])
    end
    local descname = escort_path_info_name[index][4]
    local lbl_desc = groupboxobj:Find(descname)
    if nx_is_valid(lbl_desc) then
      lbl_desc.Text = nx_widestr(util_text(nx_string(escort_path_table[row][5])))
    end
    local startaeraname = escort_path_info_name[index][6]
    local lbl_startaera = groupboxobj:Find(startaeraname)
    if nx_is_valid(lbl_startaera) then
      lbl_startaera.Text = nx_widestr(util_text(nx_string(escort_path_table[row][4])))
    end
    local team_num = escort_path_info_name[index][5]
    local lbl_team_num = groupboxobj:Find(team_num)
    if nx_is_valid(lbl_team_num) then
      lbl_team_num.Text = nx_widestr(nx_string(nx_int(escort_path_table[row][2])))
    end
    local btn_name = escort_path_info_name[index][2]
    local btn_obj = groupboxobj:Find(btn_name)
    if nx_is_valid(btn_obj) then
      btn_obj.escort_id = escort_path_table[row][1]
      btn_obj.escort_table = escort_path_table[row][3]
      if nx_int(index) == nx_int(0) then
        init_default_sel_escort(escort_path_table[row][1], escort_path_table[row][3])
      end
    end
    index = index + 1
  end
end
function ParseEscortInfo(escort_info)
  if string.len(nx_string(escort_info)) <= 0 then
    return false
  end
  local info = util_split_string(nx_string(escort_info), ",")
  return true, info
end
function get_sel_escort_goods_num()
  local nGoodsCount = get_goods_num(Sel_Escort)
  return nGoodsCount
end
function OnEscortInfoMsg(escort_info_table)
  escort_path_detailinfo_table = {}
  local string_table = util_split_string(nx_string(escort_info_table), ";")
  local nCount = table.getn(string_table)
  for i = 1, nCount do
    local bRet, team_info = ParseEscortInfo(string_table[i])
    if bRet == true then
      table.insert(escort_path_detailinfo_table, team_info)
    end
  end
  local nCount = table.getn(escort_path_detailinfo_table)
  local form = util_get_form("form_stage_main\\form_school_war\\form_escortpath_info", true)
  if not nx_is_valid(form) then
    return
  end
  if nCount <= MAX_TEAM_INFO then
    form.team_bar.Visible = false
    if nCount <= 0 then
      return 0
    end
  else
    form.team_bar.Visible = true
    form.team_bar.Maximum = nCount - MAX_TEAM_INFO
  end
  init_escort_info_name(form.groupbox_escort_detail_info)
  team_info_fresh(form.groupbox_escort_detail_info, 0, MAX_TEAM_INFO, nCount)
end
function team_info_fresh(self, startrow, endrow, rownum)
  local index = 1
  for row = rownum - startrow, rownum - endrow + 1, -1 do
    if row <= 0 then
      return
    end
    local groupboxname = escort_team_detail_name[index][1]
    local groupboxobj = self:Find(groupboxname)
    groupboxobj.Visible = true
    local playername = escort_team_detail_name[index][2]
    local lbl_name = groupboxobj:Find(playername)
    if nx_is_valid(lbl_name) then
      lbl_name.Text = nx_widestr(nx_string(escort_path_detailinfo_table[row][2]))
    end
    local titlelevel_name = escort_team_detail_name[index][3]
    local lbl_level = groupboxobj:Find(titlelevel_name)
    if nx_is_valid(lbl_level) then
      lbl_level.Text = nx_widestr(util_text("desc_" .. nx_string(escort_path_detailinfo_table[row][3])))
    end
    local mem_num_name = escort_team_detail_name[index][4]
    local lbl_mem_num = groupboxobj:Find(mem_num_name)
    if nx_is_valid(lbl_mem_num) then
      lbl_mem_num.Text = nx_widestr(nx_string(escort_path_detailinfo_table[row][5]))
    end
    local guild_name = escort_team_detail_name[index][5]
    local lbl_guild = groupboxobj:Find(guild_name)
    if nx_is_valid(lbl_guild) then
      lbl_guild.Text = nx_widestr(nx_string(escort_path_detailinfo_table[row][4]))
    end
    local sence_name = escort_team_detail_name[index][6]
    local lbl_sence = groupboxobj:Find(sence_name)
    if nx_is_valid(lbl_sence) then
      lbl_sence.Text = nx_widestr(util_text("ui_scene_" .. nx_string(escort_path_detailinfo_table[row][7])))
    end
    local pos_name = escort_team_detail_name[index][7]
    local lbl_pos = groupboxobj:Find(pos_name)
    if nx_is_valid(lbl_pos) then
      lbl_pos.Text = nx_widestr(nx_string(escort_path_detailinfo_table[row][8]) .. "," .. nx_string(escort_path_detailinfo_table[row][9]))
    end
    local goodsnum_name = escort_team_detail_name[index][9]
    local lbl_goods_num = groupboxobj:Find(goodsnum_name)
    if nx_is_valid(lbl_goods_num) then
      lbl_goods_num.Text = nx_widestr(nx_string(escort_path_detailinfo_table[row][6]) .. "/" .. nx_string(get_sel_escort_goods_num()))
    end
    index = index + 1
  end
end
function on_path_table_scrollbar_value_changed(self, oldvalue)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local rownum = table.getn(escort_path_table)
  if rownum < MAX_PATH_COUNT + 1 then
    return 0
  end
  local endrow = self.Value + MAX_PATH_COUNT
  if rownum < endrow then
    endrow = rownum
  end
  local form = self.ParentForm
  path_fresh(form.groupbox_escortpathinfo, self.Value, endrow, rownum)
end
function on_escort_info_scrollbar_value_changed(self, oldvalue)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local rownum = table.getn(escort_path_detailinfo_table)
  if rownum < MAX_TEAM_INFO + 1 then
    return 0
  end
  local endrow = self.Value + MAX_TEAM_INFO
  if rownum < endrow then
    endrow = rownum
  end
  local form = self.ParentForm
  team_info_fresh(form.groupbox_escort_detail_info, self.Value, endrow, rownum)
end
function ShowTipDialog(content)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, content)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    return true
  else
    return false
  end
  return false
end
function Escort_time_down_Started(form)
  local timer = nx_value(GAME_TIMER)
  timer:Register(nx_int(form.timer_span), -1, nx_current(), "On_Update_Escort_Time", form, -1, -1)
end
function Reset_Escort_time_down(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "On_Update_Escort_Time", form)
end
function On_Update_Escort_Time(form)
  local time_down = form.time_down
  if nx_int(time_down) <= nx_int(0) then
    form.time_down = 0
    return
  end
  form.time_down = time_down - 1
end
