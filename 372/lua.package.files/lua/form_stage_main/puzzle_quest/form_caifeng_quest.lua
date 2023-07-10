require("util_gui")
require("util_functions")
require("share\\view_define")
require("form_stage_main\\puzzle_quest\\puzzle_quest_define")
require("form_stage_main\\puzzle_quest\\puzzle_breakdoor_define")
require("share\\itemtype_define")
local PBRA_NAME = {
  ["0"] = "turnleft",
  ["1"] = "progress"
}
local ANIM_WITDH = 0
anim_left = 0
local hits = 0
local isHit = false
local form_name = ""
function bg_form_init(self)
  self.is_anim_play = false
  self.is_play_skull_ainm = false
  self.Fixed = true
  self.no_need_motion_alpha = true
end
function log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
  nx_function("ext_trace_log", info)
end
function on_bg_form_open(self)
  set_bg_visible(true)
  init_anim_info(self.type)
  form_name = skin_lst_1[self.gem_game_type]
  self.anim_x = anim_x
  self.gemgame_lst = nx_call("util_gui", "get_arraylist", "form_caifeng_quest:gemgame_lst")
  self.gemgame_lst.CurOPName = ""
  self.gemgame_lst.CurOPGroup = -1
  self.gemgame_lst.RemainTime = 0
  self.gemgame_lst.CurGroupAIndex = 0
  self.gemgame_lst.CurGroupBIndex = 0
  self.gemgame_lst.Width = 0
  self.gemgame_lst.Height = 0
  self.gem_game_times = 1
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    local player = game_client:GetPlayer()
    if nx_is_valid(player) then
      self.playername = player:QueryProp("Name")
      self.gem_game_times = nx_number(player:QueryProp("GemGameTimes")) + 1
    end
  end
  self.group_a_lst = nx_call("util_gui", "get_arraylist", "form_caifeng_quest_group_a_lst")
  self.group_b_lst = nx_call("util_gui", "get_arraylist", "form_caifeng_quest_group_b_lst")
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_GEM_BOX, self, nx_current(), "on_gem_box_view_operat")
  databinder:AddViewBind(VIEWPORT_GEM_GROUP_A, self, nx_current(), "on_gem_group_view_operat")
  databinder:AddViewBind(VIEWPORT_GEM_GROUP_B, self, nx_current(), "on_gem_group_view_operat")
  ANIM_WITDH = self.anim_progress.Width
end
function on_gem_group_view_operat(form, optype, view_ident, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if optype == "createview" then
    create_fight(form, view, view_ident, index)
  elseif optype == "deleteview" then
  elseif optype == "addview" then
  elseif optype == "updateitem" then
    reflesh_fight(form, view, view_ident, index, flag)
  elseif optype == "delitem" then
  end
  return 1
end
function on_gem_box_view_operat(form, optype, view_ident, index)
  local game_client = nx_value("game_client")
  local view_item = game_client:GetView(nx_string(view_ident))
  camp = 0
  local group_control = form:Find("gb_puzzle_" .. PBRA_NAME[nx_string(camp)])
  local pbar_control, lbl_control, anim_control
  if nx_is_valid(group_control) then
    local pbar_conrtol_name = "pbar_" .. PBRA_NAME[nx_string(camp)]
    pbar_control = group_control:Find(pbar_conrtol_name)
    local mtb_conrtol_name = "mtb_" .. PBRA_NAME[nx_string(camp)]
    mtb_control = group_control:Find(mtb_conrtol_name)
    local anim_control_name = "anim_" .. PBRA_NAME[nx_string(camp)]
    anim_control = group_control:Find(anim_control_name)
  end
  if nx_is_valid(pbar_control) and nx_is_valid(view_item) and view_item:FindProp("MaxTurn") then
    pbar_control.Maximum = nx_number(view_item:QueryProp("MaxTurn"))
    pbar_control.Value = pbar_control.Maximum - (nx_number(view_item:QueryProp("CurTurn")) - 1)
  end
  if nx_is_valid(mtb_control) then
    local gui = nx_value("gui")
    mtb_control.HtmlText = nx_widestr(nx_widestr("<center>") .. gui.TextManager:GetFormatText("ui_puzzle_" .. PBRA_NAME[nx_string(camp)], pbar_control.Value, pbar_control.Maximum) .. nx_widestr("</center>"))
  end
  if nx_is_valid(anim_control) then
    anim_control.Left = form.anim_x + (pbar_control.Maximum - pbar_control.Value) / pbar_control.Maximum * pbar_control.Width
  end
  if nx_is_valid(view_item) and view_item:FindProp("EliminateNum") then
    local temp_hits = nx_number(view_item:QueryProp("EliminateNum"))
    if temp_hits ~= 0 and temp_hits > hits then
      hits = temp_hits
      isHit = true
    end
    if isHit and temp_hits == 0 then
      if 3 <= hits then
        if 5 < hits then
          hits = 5
        end
        local gui = nx_value("gui")
        nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_quest", "create_diamond_hits_img_effect", gui.Desktop.Width / 2 - 260, gui.Desktop.Height / 3, nx_number(hits))
        nx_execute(nx_current(), "play_anim", "hit_" .. nx_string(hits))
      end
      hits = 0
      isHit = false
    end
  end
end
function create_fight(form, view, view_ident, index)
  local camp = 0
  local parent_form = nx_value(FORM_PUZZLE_QUEST)
  if nx_number(view_ident) == VIEWPORT_GEM_GROUP_A then
    camp = 0
    return
  elseif nx_number(view_ident) == VIEWPORT_GEM_GROUP_B then
    camp = 1
  end
  local player_list = view:GetViewObjList()
  local all_players_info
  if nx_number(view_ident) == VIEWPORT_GEM_GROUP_A then
    form.group_a_lst:ClearChild()
    all_players_info = form.group_a_lst
  elseif nx_number(view_ident) == VIEWPORT_GEM_GROUP_B then
    form.group_b_lst:ClearChild()
    all_players_info = form.group_b_lst
  end
  local group_control = form:Find("gb_puzzle_" .. PBRA_NAME[nx_string(camp)])
  local pbar_control, lbl_control, anim_control
  if nx_is_valid(group_control) then
    local pbar_conrtol_name = "pbar_" .. PBRA_NAME[nx_string(camp)]
    pbar_control = group_control:Find(pbar_conrtol_name)
    local mtb_conrtol_name = "mtb_" .. PBRA_NAME[nx_string(camp)]
    mtb_control = group_control:Find(mtb_conrtol_name)
    local anim_control_name = "anim_" .. PBRA_NAME[nx_string(camp)]
    anim_control = group_control:Find(anim_control_name)
  end
  for j, view_item in pairs(player_list) do
    if nx_is_valid(pbar_control) and camp == 1 then
      pbar_control.Maximum = nx_number(view_item:QueryProp("MaxHP"))
      pbar_control.Value = 0
      local product_id = nx_string(view_item:QueryProp("PlayerName"))
      get_item_info(product_id)
      form.good_id = product_id
    end
    form.lbl_num.Text = nx_widestr(view_item:QueryProp("GemLevel"))
    if nx_is_valid(mtb_control) then
      local gui = nx_value("gui")
      mtb_control.HtmlText = nx_widestr(nx_widestr("<center>") .. gui.TextManager:GetFormatText("ui_puzzle_" .. PBRA_NAME[nx_string(camp)], pbar_control.Value, pbar_control.Maximum) .. nx_widestr("</center>"))
    end
    if nx_is_valid(anim_control) then
      local sacle = pbar_control.Value / pbar_control.Maximum
      if sacle == 0 then
        anim_control.Visible = false
      else
        anim_control.Visible = true
        anim_control.Width = sacle * ANIM_WITDH
      end
    end
  end
end
function reflesh_fight(form, view, view_ident, index, flag)
  local camp = 0
  local parent_form = nx_value(FORM_PUZZLE_QUEST)
  if nx_number(view_ident) == VIEWPORT_GEM_GROUP_A then
    camp = 0
    return
  elseif nx_number(view_ident) == VIEWPORT_GEM_GROUP_B then
    camp = 1
  end
  local player_list = view:GetViewObjList()
  local all_players_info
  if nx_number(view_ident) == VIEWPORT_GEM_GROUP_A then
    form.group_a_lst:ClearChild()
    all_players_info = form.group_a_lst
  elseif nx_number(view_ident) == VIEWPORT_GEM_GROUP_B then
    form.group_b_lst:ClearChild()
    all_players_info = form.group_b_lst
  end
  local group_control = form:Find("gb_puzzle_" .. PBRA_NAME[nx_string(camp)])
  local pbar_control, lbl_control, anim_control
  if nx_is_valid(group_control) then
    local pbar_conrtol_name = "pbar_" .. PBRA_NAME[nx_string(camp)]
    pbar_control = group_control:Find(pbar_conrtol_name)
    local mtb_conrtol_name = "mtb_" .. PBRA_NAME[nx_string(camp)]
    mtb_control = group_control:Find(mtb_conrtol_name)
    local anim_control_name = "anim_" .. PBRA_NAME[nx_string(camp)]
    anim_control = group_control:Find(anim_control_name)
  end
  for j, view_item in pairs(player_list) do
    if nx_is_valid(pbar_control) and camp == 1 then
      pbar_control.value_new = pbar_control.Maximum - nx_number(view_item:QueryProp("HP"))
      pbar_control.value_old = pbar_control.Value
      nx_execute(nx_current(), "set_finish_control_value_slow_change")
    end
  end
end
function set_finish_control_value_slow_change()
  local form = nx_value(nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_quest", "get_current_form_name"))
  camp = 1
  if not nx_is_valid(form) then
    return
  end
  local group_control = form:Find("gb_puzzle_" .. PBRA_NAME[nx_string(camp)])
  local pbar_control, lbl_control, anim_control
  if nx_is_valid(group_control) then
    local pbar_conrtol_name = "pbar_" .. PBRA_NAME[nx_string(camp)]
    pbar_control = group_control:Find(pbar_conrtol_name)
    local mtb_conrtol_name = "mtb_" .. PBRA_NAME[nx_string(camp)]
    mtb_control = group_control:Find(mtb_conrtol_name)
    local anim_control_name = "anim_" .. PBRA_NAME[nx_string(camp)]
    anim_control = group_control:Find(anim_control_name)
  end
  while true do
    nx_pause(0.15)
    if not nx_is_valid(pbar_control) then
      return
    end
    if not nx_find_custom(pbar_control, "value_new") or not nx_find_custom(pbar_control, "value_old") then
      return
    end
    if pbar_control.value_new == pbar_control.value_old then
      return
    end
    if pbar_control.value_new - pbar_control.value_old > 0 then
      pbar_control.value_old = pbar_control.value_old + 1
    else
      pbar_control.value_old = pbar_control.value_old - 1
    end
    if nx_is_valid(pbar_control) then
      pbar_control.Value = pbar_control.value_old
    end
    if nx_is_valid(mtb_control) then
      local gui = nx_value("gui")
      mtb_control.HtmlText = nx_widestr(nx_widestr("<center>") .. gui.TextManager:GetFormatText("ui_puzzle_" .. PBRA_NAME[nx_string(camp)], pbar_control.Value, pbar_control.Maximum) .. nx_widestr("</center>"))
    end
    if nx_is_valid(anim_control) then
      local sacle = pbar_control.Value / pbar_control.Maximum
      if sacle == 0 then
        anim_control.Visible = false
      else
        anim_control.Visible = true
        anim_control.Width = sacle * ANIM_WITDH
      end
    end
  end
end
function on_bg_close(self)
  local databinder = nx_value("data_binder")
  databinder:DelViewBind(self)
  nx_destroy(self.group_a_lst)
  nx_destroy(self.group_b_lst)
  nx_destroy(self.gemgame_lst)
  nx_destroy(self)
end
function log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function set_bg_visible(isshow)
  local form = nx_value(nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_quest", "get_current_form_name"))
  if nx_is_valid(form) then
    local bg_groupbox = form:Find("gb_chessboard")
    if nx_is_valid(bg_groupbox) then
      bg_groupbox.Visible = isshow
    end
  end
end
function play_anim(type)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  if form.is_anim_play == true then
    return
  else
    form.is_anim_play = true
  end
  local anims_list = util_split_string(anims_type_array[nx_string(type)], ",")
  local count = table.getn(anims_list)
  if count == 0 then
    return
  end
  math.randomseed(os.time())
  math.random(1, count)
  local anim_id = anims_list[math.random(1, count)]
  set_bg_visible(false)
  set_anim_control(anim_id)
  set_label_control(anim_id)
end
function set_anim_control(anim_id)
  local form = nx_value(nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_quest", "get_current_form_name"))
  if not nx_is_valid(form) then
    return
  end
  for i = 1, anim_cout do
    local anim_control = form:Find("ani_layer_" .. nx_string(i))
    if nx_is_valid(anim_control) then
      anim_control.AnimationImage = get_anim_image(anim_id, i)
      anim_control.Loop = false
      anim_control.Independent = true
      anim_control:Play()
    end
  end
end
function set_label_control(anim_id)
  local form = nx_value(nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_quest", "get_current_form_name"))
  if not nx_is_valid(form) then
    return
  end
  for i = 1, label_cout do
    local label_control = form:Find("label_" .. nx_string(i))
    if nx_is_valid(label_control) then
      label_control.BackImage = get_label_image(anim_id, i)
    end
  end
end
function set_all_anim_show_control()
  local form = nx_value(nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_quest", "get_current_form_name"))
  if not nx_is_valid(form) then
    return
  end
  for i = 1, anim_cout do
    local anim_control = form:Find("ani_layer_" .. nx_string(i))
    if nx_is_valid(anim_control) then
      anim_control.AnimationImage = ""
    end
  end
  for i = 1, label_cout do
    local label_control = form:Find("label_" .. nx_string(i))
    if nx_is_valid(label_control) then
      label_control.BackImage = ""
    end
  end
end
function on_anim_end()
  set_all_anim_show_control()
  set_bg_visible(true)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  form.is_anim_play = false
end
function get_item_info(product_id)
  local form = nx_value(nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_quest", "get_current_form_name"))
  if not nx_is_valid(form) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  local porduct_item = product_id
  form.product_grid.porduct_item = porduct_item
  local item_type = nx_number(ItemQuery:GetItemPropByConfigID(nx_string(porduct_item), "ItemType"))
  if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
    photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(porduct_item), "Photo")
  else
    photo = ItemQuery:GetItemPropByConfigID(nx_string(porduct_item), nx_string("Photo"))
  end
  form.product_grid:AddItem(0, photo, nx_widestr(nx_string(name)), 1, -1)
end
function on_product_grid_mousein_grid(grid, index)
  local item_config = grid.porduct_item
  if item_config == "" then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
  if bExist == false then
    return
  end
  local item_name = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Name"))
  local item_type = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("ItemType"))
  local item_sellPrice1 = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("sellPrice1"))
  local photo = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Photo"))
  local prop_array = {}
  prop_array.ConfigID = nx_string(item_config)
  prop_array.ItemType = nx_int(item_type)
  prop_array.SellPrice1 = nx_int(item_sellPrice1)
  prop_array.Photo = nx_string(photo)
  if not nx_is_valid(grid.Data) then
    grid.Data = nx_create("ArrayList", nx_current())
  end
  grid.Data:ClearChild()
  for prop, value in pairs(prop_array) do
    nx_set_custom(grid.Data, prop, value)
  end
  nx_execute("tips_game", "show_goods_tip", grid.Data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_product_grid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function failure_tips_dialog()
  local form = nx_value(nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_quest", "get_current_form_name"))
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "good_id") then
    return
  end
  local gui = nx_value("gui")
  local ask_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  ask_dialog.Left = form.Left + (form.Width - ask_dialog.Width) / 2
  ask_dialog.Top = form.Top + (form.Height - ask_dialog.Height) / 2
  local name = nx_widestr(gui.TextManager:GetText(nx_string(form.good_id)))
  local text = nx_widestr(gui.TextManager:GetFormatText("ui_yihan", name))
  nx_execute("form_common\\form_confirm", "show_common_text", ask_dialog, text)
  ask_dialog.cancel_btn.Visible = false
  ask_dialog:ShowModal()
end
function on_btn_help_click(self)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  local help_form = nx_value(help_skin_lst_1[form.gem_game_type])
  if nx_is_valid(help_form) then
    help_form.Visible = not help_form.Visible
  else
    help_form = nx_execute("util_gui", "util_get_form", help_skin_lst_1[form.gem_game_type], true, false)
    help_form.count = 5
    help_form:Show()
  end
  help_form.no_need_motion_alpha = false
end
function on_btn_quit_click(self)
  nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_quest", "hide_form")
end
function play_skull_ainm()
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "is_play_skull_ainm") and form.is_play_skull_ainm then
    return
  end
  local anim_control = form:Find("ani_skull")
  if nx_is_valid(anim_control) then
    anim_control.AnimationImage = anim_skull
    anim_control.Loop = false
    anim_control.Independent = true
    anim_control:Play()
    form.is_play_skull_ainm = true
  end
end
function on_ani_skull_animation_end(self)
  self.AnimationImage = ""
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "is_play_skull_ainm") then
    form.is_play_skull_ainm = false
  end
end
