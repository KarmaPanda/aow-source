require("util_static_data")
require("share\\client_custom_define")
require("goods_grid")
require("share\\view_define")
require("util_functions")
require("util_gui")
require("goods_grid")
require("player_state\\state_input")
require("player_state\\state_const")
require("tips_func_skill")
require("util_static_data")
require("define\\shortcut_key_define")
local MAXGRIDSIZE = 8
function main_form_init(self)
  self.Fixed = false
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 1.3
  self.SelectType = 0
  return 1
end
function on_main_form_open(self)
  self.item_configid = ""
  load_location()
  refresh_form(self, "", "", nil)
  self.pbar_mp.Visible = false
  self.btn_search.Visible = false
  data_bind_prop(self)
end
function on_main_form_close(self)
  del_data_bind_prop(self)
  nx_destroy(self)
end
function on_main_form_shut(self)
  save_location()
  del_data_bind_prop(self)
end
function on_gui_size_change()
  load_location()
end
function refresh_form(form, skill_id_lst, photo, skillini)
  local grid = form.imagegrid_1
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:GridClear(grid)
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local skill_tmp_lst = util_split_string(skill_id_lst, ",")
  for i = 1, table.getn(skill_tmp_lst) do
    if skill_tmp_lst[i] == "" then
      table.remove(skill_tmp_lst, i)
    end
  end
  if skillini == nil then
    return
  end
  for i = 1, table.getn(skill_tmp_lst) do
    if skillini:FindSection(nx_string(skill_tmp_lst[i])) then
      local sec_index = skillini:FindSectionIndex(nx_string(skill_tmp_lst[i]))
      if 0 <= sec_index then
        local static_data = skillini:ReadInteger(sec_index, "StaticData", 0)
        local name = skillini:GetSectionByIndex(sec_index)
        local photo = skill_static_query(static_data, "Photo")
        local cooltype = skill_static_query(static_data, "CoolDownCategory")
        local coolteam = skill_static_query(static_data, "CoolDownTeam")
        grid:AddItem(nx_int(i - 1), nx_string(photo), nx_widestr(name), nx_int(0), i)
        if 0 < nx_number(cooltype) then
          grid:SetCoolType(nx_int(i - 1), nx_int(cooltype))
        end
        if 0 < nx_number(coolteam) then
          grid:SetCoolTeam(nx_int(i - 1), nx_int(coolteam))
        end
        local canuse = skill_static_query(static_data, "CanUse")
        grid:ChangeItemImageToBW(nx_int(i - 1), false)
      end
    end
  end
end
function on_rightclick_grid(self, index)
  if not nx_is_valid(self) then
    return
  end
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.Visible then
    return
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  local AllowControl = nx_execute("form_stage_main\\form_main\\form_main_buff", "IsAllowControl")
  if not AllowControl then
    return
  end
  local name = self:GetItemName(index)
  if 0 == nx_ws_length(name) then
    return
  end
  local game_visual = nx_value("game_visual")
  local player = game_visual:GetPlayer()
  local state_index = game_visual:QueryRoleStateIndex(player)
  if state_index == STATE_STATIC_INDEX then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SABLE_HANDLE), 1, nx_string(name), nx_number(form.SelectType))
    return
  end
  local gui = nx_value("gui")
  local info = gui.TextManager:GetFormatText("11601")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(info, 2)
  end
end
function on_select_changed(self, index)
  on_rightclick_grid(self, index)
end
function on_mousein_grid(grid, index)
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  tips_manager.InShortcut = true
  local name = grid:GetItemName(index)
  name = nx_string(name)
  if name == "" then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = name
  item.ItemType = ITEMTYPE_ZHAOSHI
  local StaticData = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\skill_new.ini", name, "StaticData", "0")
  item.StaticData = nx_number(StaticData)
  item.is_static = true
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function server_open_sable_skill(form, configid)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local itemini = nx_execute("util_functions", "get_ini", "share\\Item\\tool_item.ini")
  if not nx_is_valid(itemini) then
    nx_msgbox("share\\Item\\tool_item.ini" .. " " .. get_msg_str("msg_120"))
    return
  end
  if not itemini:FindSection(nx_string(configid)) then
    return
  end
  local sec_index = itemini:FindSectionIndex(nx_string(configid))
  if sec_index < 0 then
    return ""
  end
  local skill_lst = itemini:ReadString(sec_index, "SableSkillID", "")
  local ArtPack_id = itemini:ReadString(sec_index, "ArtPack", "")
  local ArtPackini = nx_execute("util_functions", "get_ini", "share\\Item\\ItemArtStatic.ini")
  if not nx_is_valid(ArtPackini) then
    nx_msgbox("share\\Item\\ItemArtStatic.ini" .. " " .. get_msg_str("msg_120"))
    return
  end
  if not ArtPackini:FindSection(nx_string(ArtPack_id)) then
    return
  end
  local sec_index_ArtPack = ArtPackini:FindSectionIndex(nx_string(ArtPack_id))
  if sec_index_ArtPack < 0 then
    return ""
  end
  local photo = ArtPackini:ReadString(sec_index_ArtPack, "Photo", "")
  local skillini = nx_execute("util_functions", "get_ini", "share\\Skill\\skill_new.ini")
  if not nx_is_valid(skillini) then
    nx_msgbox("share\\Skill\\skill_new.ini" .. " " .. get_msg_str("msg_120"))
    return
  end
  local form = util_get_form("form_stage_main\\form_animalkeep\\form_sable_skill", true)
  if not nx_is_valid(form) then
    return
  end
  refresh_form(form, skill_lst, photo, skillini)
  refresh_pbar_mp(form)
end
function server_close_sable_skill(form)
  if not nx_is_valid(form) then
    return
  end
  local sable_search = nx_value("form_stage_main\\form_animalkeep\\form_sable_search")
  if nx_is_valid(sable_search) then
    sable_search:Close()
  end
  form.imagegrid_1:Clear()
  form.Visible = false
  form:Close()
  nx_destroy(form)
end
function save_location()
  local form = nx_value("form_stage_main\\form_animalkeep\\form_sable_skill")
  if not nx_is_valid(form) then
    return false
  end
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  ini.FileName = account .. "\\form_sable_skill.ini"
  ini:LoadFromFile()
  ini:WriteInteger("form", "AbsLeft", nx_int(form.AbsLeft))
  ini:WriteInteger("form", "AbsTop", nx_int(form.AbsTop))
  ini:SaveToFile()
  nx_destroy(ini)
end
function load_location()
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  local form = nx_value("form_stage_main\\form_animalkeep\\form_sable_skill")
  if not nx_is_valid(form) then
    nx_destroy(ini)
    return
  end
  if nx_is_valid(ini) then
    ini.FileName = account .. "\\form_sable_skill.ini"
    if not ini:LoadFromFile() then
      nx_destroy(ini)
      local gui = nx_value("gui")
      form.AbsLeft = (gui.Width - form.Width) / 2
      form.AbsTop = (gui.Height - form.Height) / 1.3
      return
    end
    form.AbsLeft = ini:ReadInteger("form", "AbsLeft", 0)
    form.AbsTop = ini:ReadInteger("form", "AbsTop", 0)
  end
  nx_destroy(ini)
end
function close_form()
  local form = nx_value("form_stage_main\\form_animalkeep\\form_sable_skill")
  if nx_is_valid(form) then
    form.imagegrid_1:Clear()
    del_data_bind_prop(form)
    nx_destroy(form)
  end
end
function data_bind_prop(form)
  if not nx_is_valid(form) then
    return
  end
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:AddTableBind("sable_rec", form, nx_current(), "on_sable_mp_change")
end
function del_data_bind_prop(form)
  if not nx_is_valid(form) then
    return
  end
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:DelViewBind(form)
end
function on_sable_mp_change(form, recordname, optype, row, clomn)
  if not nx_is_valid(form) then
    return
  end
  if nx_string("update") ~= nx_string(optype) then
    return
  end
  if nx_string(clomn) ~= nx_string("8") and nx_string(clomn) ~= nx_string("7") then
    return
  end
  refresh_pbar_mp(form)
end
function refresh_pbar_mp(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local sable = client_player:QueryProp("Sable")
  if string.len(sable) == 0 or sable == 0 then
    return
  end
  if not client_player:FindRecord("sable_rec") then
    return
  end
  local row = client_player:QueryProp("SableCarryID")
  local row_max = client_player:GetRecordRows("sable_rec")
  if row < 0 or row >= row_max then
    return
  end
  local pet_type = client_player:QueryRecord("sable_rec", row, 6)
  if pet_type <= 0 then
    return
  end
  local max_mp = client_player:QueryRecord("sable_rec", row, 7)
  local cur_mp = client_player:QueryRecord("sable_rec", row, 8)
  form.pbar_mp.Maximum = max_mp
  form.pbar_mp.Value = cur_mp
  local sub_value = max_mp / 3
  if cur_mp >= 2 * sub_value then
    form.pbar_mp.ProgressImage = "gui\\special\\animal_keep\\green.png"
  elseif cur_mp >= sub_value then
    form.pbar_mp.ProgressImage = "gui\\special\\animal_keep\\yellow.png"
  else
    form.pbar_mp.ProgressImage = "gui\\special\\animal_keep\\red.png"
  end
  form.pbar_mp.Visible = true
  local skill_type = client_player:QueryRecord("sable_rec", row, 10)
  if string.len(skill_type) > 0 then
    form.btn_search.Visible = true
  else
    form.btn_search.Visible = false
  end
end
function on_btn_search_click(self, index)
  if not nx_is_valid(self) then
    return
  end
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.Visible then
    return
  end
  local search_form = nx_value("form_stage_main\\form_animalkeep\\form_sable_search")
  if nx_is_valid(search_form) then
    search_form:Close()
  else
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    if not client_player:FindRecord("sable_rec") then
      return
    end
    local row = client_player:QueryProp("SableCarryID")
    local row_max = client_player:GetRecordRows("sable_rec")
    if row < 0 or row >= row_max then
      return
    end
    local skill_type = client_player:QueryRecord("sable_rec", row, 10)
    if 0 < string.len(skill_type) then
      nx_execute("util_gui", "util_show_form", "form_stage_main\\form_animalkeep\\form_sable_search", true)
      nx_execute("form_stage_main\\form_animalkeep\\form_sable_search", "show_choice_info", skill_type)
    end
  end
end
function set_select_type(select_type)
  local form = nx_value("form_stage_main\\form_animalkeep\\form_sable_skill")
  if nx_is_valid(form) then
    form.SelectType = select_type
  end
end
function find_grid_item(grid, config_id)
  local size = grid.RowNum * grid.ClomnNum
  for i = 1, size do
    local skill_configID = grid:GetItemName(i - 1)
    if nx_string(skill_configID) == config_id then
      return i - 1
    end
  end
  return -1
end
