require("define\\gamehand_type")
require("util_static_data")
require("share\\client_custom_define")
require("goods_grid")
require("share\\view_define")
require("util_functions")
require("util_static_data")
require("util_gui")
require("goods_grid")
require("player_state\\state_input")
require("tips_func_skill")
require("util_static_data")
local MAXGRIDSIZE = 10
function main_form_init(self)
  self.Fixed = false
  self.no_need_motion_alpha = true
  return 1
end
function on_main_form_open(self)
  refresh_form_pos()
  refresh_form(self)
  local grid_shortcut_main = self.imagegrid_1
  local grid_count = grid_shortcut_main.RowNum * grid_shortcut_main.ClomnNum
  grid_shortcut_main.beginindex = 0
  grid_shortcut_main.endindex = grid_shortcut_main.beginindex + grid_count - 1
  local databinder = nx_value("data_binder")
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local find_buffer = nx_function("find_buffer", player, "buf_musejuben_bianshen")
  if find_buffer then
    self.btn_close.Visible = false
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function refresh_form_pos()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_itemskill")
  if not nx_is_valid(form) then
    return
  end
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(shortcut_grid) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2 + form.zaiju_touxiang.Left
  form.Top = gui.Desktop.Height - shortcut_grid.groupbox_shortcut_1.Height - form.zaiju_touxiang.Top - 20
end
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function refresh_form(form)
  local grid = form.imagegrid_1
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:GridClear(grid)
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local using_item_view = game_client:GetView(nx_string(VIEWPORT_USING_ITEM_BOX))
  if not nx_is_valid(using_item_view) then
    return
  end
  local item = using_item_view:GetViewObj("1")
  if not nx_is_valid(item) then
    return
  end
  local item_id = item:QueryProp("ConfigID")
  local photo = get_item_photo(item_id)
  if nx_string(photo) ~= "" then
    form.lbl_photo.BackImage = nx_string(photo)
  end
  local lifetime = item:QueryProp("ItemLifeTime")
  form.prog_hp.Maxinum = 300000
  form.prog_hp.Mininum = 0
  form.prog_hp.Value = nx_number(lifetime)
  form.lbl_hp.Text = nx_widestr(lifetime)
  local lifecount = item:QueryProp("ItemLifeCount")
  form.prog_mp.Maxinum = 5
  form.prog_mp.Mininum = 0
  form.prog_mp.Value = nx_number(lifecount)
  form.lbl_mp.Text = nx_widestr(lifecount)
  local lbl_num = form.imagegrid_1.ClomnNum
  for n = 1, lbl_num do
    local name = "lbl_" .. n
    local lbl_form = form:Find(name)
    lbl_form.Visible = false
  end
  local skill_id_lst = get_tmpskillitem_static_prop(item, "SkillList")
  if skill_id_lst == nil then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_SKILLITEM_BOX))
  if not nx_is_valid(view) then
    return
  end
  local skill_view_lst = view:GetViewObjList()
  local skill_tmp_lst = util_split_string(skill_id_lst, ",")
  local skill_count = table.getn(skill_tmp_lst)
  for i = 1, skill_count do
    if skill_tmp_lst[i] == "" then
      table.remove(skill_tmp_lst, i)
    end
  end
  grid.Width = nx_int(59 * skill_count)
  form.lbl_back.Width = grid.Width + 32
  form.btn_close.Left = grid.Width + 134
  for i = 1, table.getn(skill_tmp_lst) do
    local name = "lbl_" .. i
    local lbl_form = form:Find(name)
    lbl_form.Visible = true
    local configid = nx_string(skill_tmp_lst[i])
    for j, skill in pairs(skill_view_lst) do
      if nx_string(configid) == nx_string(skill:QueryProp("ConfigID")) then
        grid:SetBindIndex(i - 1, nx_int(skill.Ident))
        local prop_table = {}
        local proplist = skill:GetPropList()
        for i, prop in pairs(proplist) do
          prop_table[prop] = skill:QueryProp(prop)
        end
        prop_table.CoolDownCategory = skill_static_query_by_id(skill:QueryProp("ConfigID"), "CoolDownCategory")
        prop_table.CoolDownTeam = skill_static_query_by_id(skill:QueryProp("ConfigID"), "CoolDownTeam")
        local GoodsGrid = nx_value("GoodsGrid")
        if nx_is_valid(GoodsGrid) then
          local item_data = nx_create("ArrayList", nx_current())
          for prop, value in pairs(prop_table) do
            nx_set_custom(item_data, prop, value)
          end
          GoodsGrid:GridAddItem(grid, i - 1, item_data)
        end
        local canuse = skill:QueryProp("CanUse")
        if canuse == 0 or canuse == nil then
          grid:ChangeItemImageToBW(nx_int(i - 1), true)
        else
          grid:ChangeItemImageToBW(nx_int(i - 1), false)
        end
      end
    end
  end
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if nx_is_valid(shortcut_grid) and nx_find_custom(shortcut_grid, "Visible") then
    shortcut_grid.Visible = false
  end
end
function get_beginindex(grid)
  local res = -1
  if not nx_is_valid(grid) then
    return res
  end
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_itemskill")
  if not nx_is_valid(form) then
    return res
  end
  res = grid.beginindex
  return res
end
function get_skill_obj(self, index)
  local skill = 0
  if not nx_is_valid(self) then
    return skill
  end
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_itemskill")
  if not nx_is_valid(form) then
    return skill
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_SKILLITEM_BOX))
  if not nx_is_valid(view) then
    return skill
  end
  local skillident = self:GetBindIndex(index)
  skill = view:GetViewObj(nx_string(skillident))
  if not nx_is_valid(skill) then
    return 0
  end
  return skill
end
function use_grid_shortcut_item()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if client_player:FindProp("LogicState") then
    local offline_state = client_player:QueryProp("LogicState")
    if nx_int(offline_state) == nx_int(LS_OFFLINEJOB) then
      return
    end
  end
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_itemskill")
  if not nx_is_valid(form) then
    return
  end
  local grid = form.imagegrid_1
  local skill = grid.right_click_itemskill
  if not nx_is_valid(skill) then
    return
  end
  local game_shortcut = nx_value("GameShortcut")
  if nx_is_valid(game_shortcut) then
    game_shortcut:on_shortcut_itemskill_useitem(grid, skill)
  end
end
function on_rightclick_grid(self, index)
  local game_shortcut = nx_value("GameShortcut")
  if nx_is_valid(game_shortcut) then
    game_shortcut:on_itemskill_shortcut_useitem(self, index, false)
  end
  local form = self.ParentForm
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_SKILLITEM_BOX))
  if not nx_is_valid(view) then
    return
  end
  local fight = nx_value("fight")
  local skillident = self:GetBindIndex(index)
  local skill = view:GetViewObj(nx_string(skillident))
  if not nx_is_valid(skill) then
    return
  end
  self.right_click_itemskill = skill
  local skillid = skill:QueryProp("ConfigID")
  refresh_form(form)
end
function on_imagegrid_1_doubleclick_grid(self, index)
end
function on_mousein_grid(grid, index)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local item_data = GoodsGrid:GetItemData(grid, index)
  if not nx_is_valid(item_data) then
    return
  end
  nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function delay_show_form(form)
  if not nx_is_valid(form) then
    return
  end
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
    return
  end
  local delay_timer = nx_value("timer_game")
  delay_timer:UnRegister(nx_current(), "delay_show_form", form)
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(shortcut_grid) then
    return
  end
  shortcut_grid.Visible = false
  local form_relation = nx_value("form_stage_main\\form_relationship")
  local form_talkmovie = nx_value("form_stage_main\\form_talk_movie")
  form:Show()
  form.Visible = true
  if not nx_is_valid(form_relation) then
    form.Visible = true
  else
    form.Visible = false
  end
  if form.Visible == true and nx_is_valid(form_talkmovie) then
    if form_talkmovie.Visible == true then
      form.Visible = false
    else
      form.Visible = true
    end
  end
  refresh_form(form)
end
function server_install_itemskill()
  local form_main_shortcut_itemskill = util_get_form("form_stage_main\\form_main\\form_main_shortcut_itemskill", true)
  if not nx_is_valid(form_main_shortcut_itemskill) then
    return
  end
  local delay_timer = nx_value("timer_game")
  delay_timer:UnRegister(nx_current(), "delay_show_form", form_main_shortcut_itemskill)
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
    delay_timer:Register(3000, -1, nx_current(), "delay_show_form", form_main_shortcut_itemskill, -1, -1)
    return
  else
    delay_show_form(form_main_shortcut_itemskill)
  end
end
function server_uninstall_itemskill()
  local form_main_shortcut_itemskill = util_get_form("form_stage_main\\form_main\\form_main_shortcut_itemskill", true)
  if not nx_is_valid(form_main_shortcut_itemskill) then
    return
  end
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  local form_main_shortcut_ride = nx_value("form_stage_main\\form_main\\form_main_shortcut_ride")
  if not nx_is_valid(shortcut_grid) then
    return
  end
  shortcut_grid.Visible = true
  if nx_is_valid(form_main_shortcut_ride) and form_main_shortcut_ride.Visible == true then
    shortcut_grid.Visible = false
  end
  form_main_shortcut_itemskill.imagegrid_1:Clear()
  form_main_shortcut_itemskill:Close()
end
function get_tmpskillitem_static_prop(item, prop_name)
  if not nx_is_valid(item) then
    return nil
  end
  local static_data_id = nx_int(item:QueryProp("TempSkillPack"))
  if nx_number(static_data_id) <= nx_number(staic_data_id) then
    return nil
  end
  local data_query = nx_value("data_query_manager")
  if nx_is_valid(data_query) then
    return data_query:Query(nx_int(29), nx_int(static_data_id), prop_name)
  else
    nx_msgbox("[form_main_shortcut_itemskill] static data query manager not exist")
  end
  return nil
end
function on_btn_close_click(btn)
  local form = btn.Parent
  nx_execute("custom_sender", "custom_uninstall_skillitem")
end
function on_skill_change(grid, optype, view_ident, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_SKILLITEM_BOX))
  local viewobj = view:GetViewObj(nx_string(index))
  if not nx_is_valid(viewobj) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local configid = viewobj:QueryProp("ConfigID")
  for i = 0, grid.ClomnNum - 1 do
    local item = GoodsGrid:GetItemData(grid, i)
    if not nx_is_null(item) and nx_find_custom(item, "ConfigID") then
      local skillid = item.ConfigID
      if nx_string(skillid) == nx_string(viewobj:QueryProp("ConfigID")) then
        local canuse = viewobj:QueryProp("CanUse")
        if canuse == 0 or canuse == nil then
          grid:ChangeItemImageToBW(nx_int(i), true)
        else
          grid:ChangeItemImageToBW(nx_int(i), false)
        end
      end
    end
  end
end
function get_item_photo(config_id)
  local ini = nx_execute("util_functions", "get_ini", "share\\Item\\tool_item.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(config_id))
  if sec_index < 0 then
    return ""
  end
  local value = ini:ReadString(sec_index, "photo", "")
  if value == "" or value == nil then
    return
  end
  return value
end
function close_itemskill_form()
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_itemskill")
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_uninstall_skillitem")
end
function shortcut_itemskill_view()
  local form_itemskill = nx_value("form_stage_main\\form_main\\form_main_shortcut_itemskill")
  if nx_is_valid(form_itemskill) then
    local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
    if nx_is_valid(shortcut_grid) then
      shortcut_grid.Visible = false
    end
    form_itemskill:Show()
    form_itemskill.Visible = true
  end
end
