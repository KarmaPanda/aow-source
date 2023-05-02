require("util_gui")
require("role_composite")
require("util_static_data")
require("define\\sysinfo_define")
require("share\\client_custom_define")
require("tips_data")
require("util_role_prop")
local CARD_SKILL_REC = "CardSkillRec"
local CARD_MAIN_TYPE_NONE = 0
local CARD_MAIN_TYPE_WEAPON = 1
local CARD_MAIN_TYPE_EQUIP = 2
local CARD_MAIN_TYPE_HORSE = 3
local skill_table = {}
local CLIENT_CUSTOMMSG_CARD_USESKILL = 2
local SKILL_FILL_PATH = "share\\Skill\\skill_new.ini"
function main_form_init(form)
  form.Fixed = false
  form.gui_Width = 0
  form.gui_Height = 0
end
function on_main_form_open(form)
  on_gui_size_change()
  load_location()
  local grid = form.skillgrid
  grid:Clear()
  local count = grid.RowNum * grid.ClomnNum
  for i = 1, count do
    grid:SetBindIndex(nx_int(i - 1), nx_int(i))
  end
  grid.canselect = true
  grid.candestroy = false
  grid.cansplit = false
  grid.canlock = false
  grid.canarrange = false
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind(CARD_SKILL_REC, form, nx_current(), "on_cardskill_rec_refresh")
    databinder:AddRolePropertyBind("CurJHSceneConfigID", "string", form, nx_current(), "update_newjh_form_card_skill")
  end
  local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
  if bMovie then
    if not nx_is_valid(form) then
      return
    end
    nx_execute("form_stage_main\\form_movie_new", "add_hide_control", form.skillgrid)
  end
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind(CARD_SKILL_REC, form)
  end
  nx_destroy(form)
end
function on_main_form_shut(self)
  save_location()
end
function on_gui_size_change()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if nx_int(form.gui_Width) == nx_int(gui.Width) and nx_int(form.gui_Height) == nx_int(gui.Height) then
    return
  end
  form.Left = gui.Width - form.Width
  form.Top = (gui.Height - form.Height) / 1.5
  form.gui_Width = 0
  form.gui_Height = 0
end
function close_form()
  local form = nx_value("form_stage_main\\form_card\\form_card_skill")
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_cardskill_rec_refresh(form, recordname, optype, row, clomn)
  if optype ~= "add" and optype ~= "del" and optype ~= "clear" and optype ~= "update" then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.skillgrid:Clear()
  local grid = form.skillgrid
  local rows = client_player:GetRecordRows(CARD_SKILL_REC)
  if nx_int(rows) <= nx_int(0) then
    if nx_is_valid(form) then
      form.Visible = false
    end
    return false
  else
    form.Visible = true
  end
  local count = grid.RowNum * grid.ClomnNum
  if nx_int(rows) > nx_int(count) then
    rows = count
  end
  local is_bind = false
  for i = 1, rows do
    local skill_id = client_player:QueryRecord(CARD_SKILL_REC, i - 1, 0)
    local card_id = client_player:QueryRecord(CARD_SKILL_REC, i - 1, 3)
    if skill_id ~= nil and skill_id ~= "" then
      local photo = skill_static_query_by_id(skill_id, "Photo")
      local cooltype = skill_static_query_by_id(skill_id, "CoolDownCategory")
      local coolteam = skill_static_query_by_id(skill_id, "CoolDownTeam")
      local bind_index = 0
      local card_main_type = get_card_main_type(card_id)
      if card_main_type == CARD_MAIN_TYPE_WEAPON then
        if is_bind then
          bind_index = 2
        else
          bind_index = 1
          is_bind = true
        end
      elseif card_main_type == CARD_MAIN_TYPE_EQUIP then
        bind_index = 3
      elseif card_main_type == CARD_MAIN_TYPE_HORSE then
        bind_index = 2
      end
      grid:AddItem(bind_index - 1, photo, nx_widestr(skill_id), nx_int(1), 0)
      grid:SetBindIndex(bind_index - 1, i)
      if nx_number(cooltype) > nx_number(0) then
        grid:SetCoolType(nx_int(bind_index - 1), nx_int(cooltype))
      end
      if nx_number(coolteam) > nx_number(0) then
        grid:SetCoolTeam(nx_int(bind_index - 1), nx_int(coolteam))
      end
    end
  end
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    form.Visible = false
  end
end
function on_skillgrid_select_changed(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local skill_id = grid:GetItemName(index)
  local form = grid.ParentForm
  if nx_string(skill_id) == nx_string("") then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  grid.temp_skill_id = skill_id
  local target_type = skill_static_query_by_id(skill_id, "TargetType")
  if nx_int(target_type) == nx_int(1) then
    local radius, range = get_skill_info(skill_id)
    nx_execute("game_effect", "add_ground_pick_effect", radius * 2, range)
  else
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CARD), nx_int(CLIENT_CUSTOMMSG_CARD_USESKILL), nx_string(skill_id))
  end
end
function custom_card_skill(use_skill_id)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_card\\form_card_skill", true)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local rows = client_player:GetRecordRows(CARD_SKILL_REC)
  if nx_int(rows) <= nx_int(0) then
    return false
  end
  local b_in = false
  local grid = form.skillgrid
  if not nx_find_custom(grid, "skillgrid") then
    return false
  end
  use_skill_id = grid.temp_skill_id
  for i = 1, rows do
    local skill_id = client_player:QueryRecord(CARD_SKILL_REC, i - 1, 0)
    if skill_id ~= nil and skill_id ~= "" and nx_string(skill_id) == nx_string(use_skill_id) then
      b_in = true
      break
    end
  end
  if b_in == false then
    return false
  end
  local decal = nx_value("ground_pick_decal")
  if not nx_is_valid(decal) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CARD), nx_int(CLIENT_CUSTOMMSG_CARD_USESKILL), nx_string(use_skill_id), decal.PosX, decal.PosY, decal.PosZ)
  grid.temp_skill_id = ""
end
function on_skillgrid_mousein_grid(grid, index)
  local form = grid.ParentForm
  if grid:IsEmpty(index) then
    return
  end
  local skill_id = grid:GetItemName(index)
  if nx_string(skill_id) == nx_string("") then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  if nx_is_valid(item) then
    item.is_static = true
    item.ConfigID = nx_string(skill_id)
    item.ItemType = get_ini_prop(SKILL_FILL_PATH, skill_id, "ItemType", "0")
    item.Level = 1
    item.static_skill_level = 1
    nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 40, 40, grid.ParentForm)
  end
end
function on_skillgrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function is_show_cardskill_form()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local rows = client_player:GetRecordRows(CARD_SKILL_REC)
  if nx_int(rows) > nx_int(0) then
    return true
  end
  return false
end
function show_form_cardskill()
  local form_cardskill = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_card\\form_card_skill", true)
  if not nx_is_valid(form_cardskill) then
    form_cardskill = nx_execute("util_gui", "util_show_form", "form_stage_main\\form_card\\form_card_skill", true)
  end
  if nx_is_valid(form_cardskill) then
    if is_show_cardskill_form() == true then
      form_cardskill:Show()
      form_cardskill.Visible = true
    else
      form_cardskill.Visible = false
    end
  end
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    form_cardskill.Visible = false
  end
end
function get_skill_info(use_skill_id)
  local radius = 0
  local range = 0
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return radius, range
  end
  local rows = client_player:GetRecordRows(CARD_SKILL_REC)
  if nx_int(rows) <= nx_int(0) then
    return radius, range
  end
  for i = 1, rows do
    local skill_id = client_player:QueryRecord(CARD_SKILL_REC, i - 1, 0)
    if nx_string(skill_id) == nx_string(use_skill_id) then
      radius = client_player:QueryRecord(CARD_SKILL_REC, i - 1, 1)
      range = client_player:QueryRecord(CARD_SKILL_REC, i - 1, 2)
      break
    end
  end
  return radius, range
end
function get_card_main_type(card_id)
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return 0
  end
  local card_info_table = {}
  card_info_table = collect_card_manager:GetCardInfo(card_id)
  local length = table.getn(card_info_table)
  if nx_int(length) <= nx_int(0) then
    return 0
  end
  return card_info_table[2]
end
function save_location()
  local form = nx_value("form_stage_main\\form_card\\form_card_skill")
  if not nx_is_valid(form) then
    return false
  end
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  ini.FileName = account .. "\\form_cardskill.ini"
  ini:LoadFromFile()
  ini:WriteInteger("form", "Left", nx_int(form.Left))
  ini:WriteInteger("form", "Top", nx_int(form.Top))
  local gui = nx_value("gui")
  ini:WriteInteger("form", "gui_Width", nx_int(gui.Width))
  ini:WriteInteger("form", "gui_Height", nx_int(gui.Height))
  ini:SaveToFile()
  nx_destroy(ini)
end
function load_location()
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  local form = nx_value("form_stage_main\\form_card\\form_card_skill")
  if not nx_is_valid(form) then
    nx_destroy(ini)
    return
  end
  if nx_is_valid(ini) then
    ini.FileName = account .. "\\form_cardskill.ini"
    if not ini:LoadFromFile() then
      nx_destroy(ini)
      return
    end
    form.Left = ini:ReadInteger("form", "Left", 0)
    form.Top = ini:ReadInteger("form", "Top", 0)
    form.gui_Width = ini:ReadInteger("form", "gui_Width", 0)
    form.gui_Height = ini:ReadInteger("form", "gui_Height", 0)
  end
  nx_destroy(ini)
end
function reset_scene()
  local form = nx_value("form_stage_main\\form_card\\form_card_skill")
  if nx_is_valid(form) then
    if not form.Visible then
      form:Show()
      form.Visible = false
    end
  else
    form = util_get_form("form_stage_main\\form_card\\form_card_skill", true, true)
    if nx_is_valid(form) then
      form:Show()
      form.Visible = false
    end
  end
end
function update_newjh_form_card_skill(form)
  if not nx_is_valid(form) then
    return
  end
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    form.Visible = false
  else
    form.Visible = true
  end
end
