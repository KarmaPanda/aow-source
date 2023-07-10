require("util_static_data")
require("share\\client_custom_define")
require("goods_grid")
require("share\\view_define")
require("util_functions")
require("util_gui")
require("tips_func_skill")
require("util_static_data")
local FORM_NAME = "form_stage_main\\form_magicslave\\form_magicslave_skill"
local SKILL_INI_PATH = "share\\Skill\\skill_new.ini"
local FORM_LOCATION_INI_PATH = "\\form_magicslave_skill.ini"
local SKILL_ID_LIST = "skill_mutual_nvwang,skill_mutual_caitou,skill_mutual_bianda,skill_mutual_shuangdance,skill_mutual_doule,skill_mutual_shuangxiu,skill_mutual_baotui"
function main_form_init(self)
  self.Fixed = false
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 1.3
  return 1
end
function on_main_form_open(self)
  load_location()
  refresh_form(self, "", "", nil)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_main_form_shut(self)
  save_location()
end
function on_gui_size_change()
  load_location()
end
function refresh_form(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.imagegrid_1
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:GridClear(grid)
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local skill_id_list = util_split_string(SKILL_ID_LIST, ",")
  for i = 1, table.getn(skill_id_list) do
    if skill_id_list[i] == "" then
      table.remove(skill_id_list, i)
    end
  end
  local skill_ini = get_ini(SKILL_INI_PATH)
  if not nx_is_valid(skill_ini) then
    return
  end
  for i = 1, table.getn(skill_id_list) do
    if skill_ini:FindSection(nx_string(skill_id_list[i])) then
      local sec_index = skill_ini:FindSectionIndex(nx_string(skill_id_list[i]))
      if 0 <= sec_index then
        local name = skill_ini:GetSectionByIndex(sec_index)
        local static_data = skill_ini:ReadInteger(sec_index, "StaticData", 0)
        local photo = skill_static_query(static_data, "Photo")
        local cooltype = skill_static_query(static_data, "CoolDownCategory")
        grid:AddItem(nx_int(i - 1), nx_string(photo), nx_widestr(name), nx_int(0), i)
        if 0 < nx_number(cooltype) then
          grid:SetCoolType(nx_int(i - 1), nx_int(cooltype))
        end
        if 0 < nx_number(coolteam) then
          grid:SetCoolTeam(nx_int(i - 1), nx_int(coolteam))
        end
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
  local pet = game_visual:GetSceneObj(nx_string(form.pet_persist_id))
  if not nx_is_valid(pet) then
    return
  end
  if state_index == STATE_STATIC_INDEX then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    nx_execute("custom_sender", "custom_normal_pet", nx_int(1), nx_string(name))
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
  local StaticData = nx_execute("tips_data", "get_ini_prop", SKILL_INI_PATH, name, "StaticData", "0")
  item.StaticData = nx_number(StaticData)
  item.is_static = true
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function save_location()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return false
  end
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  ini.FileName = account .. FORM_LOCATION_INI_PATH
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
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    nx_destroy(ini)
    return
  end
  if nx_is_valid(ini) then
    ini.FileName = account .. FORM_LOCATION_INI_PATH
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
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form.imagegrid_1:Clear()
    nx_destroy(form)
  end
end
function server_custom_message_callback(...)
  if table.getn(arg) < 1 then
    return
  end
  local sub_id = nx_int(arg[2])
  if sub_id == nx_int(1) then
    local form = util_get_form(FORM_NAME, true)
    if not nx_is_valid(form) then
      return
    end
    form.Visible = true
    form.pet_persist_id = nx_string(arg[3])
    form:Show()
    refresh_form(form)
  elseif sub_id == nx_int(0) then
    close_form()
  end
end
