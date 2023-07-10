require("util_functions")
require("custom_sender")
require("util_gui")
require("share\\static_data_type")
require("share\\itemtype_define")
require("define\\tip_define")
require("util_static_data")
require("tips_data")
local money_ding_wen = 1000000
local money_siliver_wen = 1000
local CLIENT_CUSTOMMSG_GUILD_WAR = 8
local CLIENT_SUBMSG_GET_PRIZENAME_LIST = 36
local CLIENT_SUBMSG_AWARD_WEAPON = 37
function on_main_form_init(self)
  self.Fixed = true
  self.pageno = 1
  self.page_next_ok = 1
  self.weapon_type = -1
  self.domain_id = 0
end
function on_main_form_open(self)
  local width = self.textgrid_2.Width
  self.textgrid_2:SetColWidth(0, width * 0.45)
  self.textgrid_2:SetColWidth(1, width * 0.45)
  self.textgrid_2:SetColTitle(0, nx_widestr(util_text("ui_guild_player_name")))
  self.textgrid_2:SetColTitle(1, nx_widestr(util_text("ui_jiangli")))
  request_list(self, self.pageno)
  self.weapon_type = 1
  bind_item_grid(self)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_last_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if form.pageno > 1 then
    request_list(form, form.pageno - 1)
  end
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if 0 < form.page_next_ok then
    request_list(form, form.pageno + 1)
  end
end
function request_list(form, pageno)
  local from = (nx_int(pageno) - 1) * 10
  local to = pageno * 10
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_GET_PRIZENAME_LIST), nx_int(form.domain_id), nx_int(from), nx_int(to))
end
function on_rev_refresh_list(from, to, rowcount, ...)
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_prize")
  if not nx_is_valid(form) then
    return 0
  end
  local size = table.getn(arg)
  if size <= 0 then
    return 0
  end
  if from < 0 or from == to then
    form.page_next_ok = 0
    return 0
  end
  form.page_next_ok = 1
  form.pageno = from / 10 + 1
  local nowpage = nx_string(form.pageno)
  local maxpage = "/" .. nx_string(math.ceil(rowcount / 10))
  form.lbl_pageno.Text = nx_widestr(nowpage .. maxpage)
  local rows = size
  if 10 < rows then
    rows = 10
  end
  form.textgrid_2:BeginUpdate()
  form.textgrid_2:ClearRow()
  local GuildWarManager = nx_value("GuildWarManager")
  if not nx_is_valid(GuildWarManager) then
    return
  end
  form.rbtn_knife.Checked = true
  local silver = GuildWarManager:GetWeaponPrice(form.domain_id)
  local ding = nx_int(silver / money_ding_wen)
  local liang = nx_int((silver - ding * money_ding_wen) / money_siliver_wen)
  local wen = silver - ding * money_ding_wen - liang * money_siliver_wen
  local str_capital = get_text("ui_guild_capital1", nx_int(ding), nx_int(liang), nx_int(wen))
  for i = 1, rows do
    local row = form.textgrid_2:InsertRow(-1)
    form.textgrid_2:SetGridText(row, 0, nx_widestr(arg[i]))
    form.textgrid_2:SetGridText(row, 1, nx_widestr(str_capital))
  end
  form.textgrid_2:EndUpdate()
end
function get_text(ui_text, ...)
  local gui = nx_value("gui")
  local size = table.getn(arg)
  gui.TextManager:Format_SetIDName(ui_text)
  for i = 1, size do
    gui.TextManager:Format_AddParam(arg[i])
  end
  return gui.TextManager:Format_GetText()
end
function on_rbtn_sword_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if rbtn.Checked then
    form.weapon_type = 0
  else
    return
  end
  bind_item_grid(form)
end
function on_rbtn_knife_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if rbtn.Checked then
    form.weapon_type = 1
  else
    return
  end
  bind_item_grid(form)
end
function on_rbtn_gun_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if rbtn.Checked then
    form.weapon_type = 2
  else
    return
  end
  bind_item_grid(form)
end
function bind_item_grid(form)
  local GuildWarManager = nx_value("GuildWarManager")
  if not nx_is_valid(GuildWarManager) then
    return
  end
  local weapon_id = GuildWarManager:GetWeaponAward(form.domain_id, form.weapon_type)
  local gui = nx_value("gui")
  local desc = "ui_" .. weapon_id .. "_desc"
  form.mltbox_1.HtmlText = gui.TextManager:GetText(desc)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local sex = client_player:QueryProp("Sex")
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return
  end
  local nArtPack = item_query_ArtPack_by_id(weapon_id, "ArtPack", sex)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local photo = data_query:Query(STATIC_DATA_ITEM_ART, nx_int(nArtPack), nx_string("Photo"))
  local grid = form.imagegrid_item
  grid:AddItem(0, photo, nx_widestr(weapon_id), nx_int(1), 0)
  grid:SetBindIndex(0, weapon_id)
end
function on_btn_prize_click(btn)
  local form = btn.ParentForm
  if form.weapon_type == -1 then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_AWARD_WEAPON), nx_int(form.weapon_type))
end
function on_imagegrid_item_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_item_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function show_prize_tips(grid, index)
  local prize_id = grid:GetItemName(nx_int(index))
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  nx_execute("tips_game", "show_tips_by_config", prize_id, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
