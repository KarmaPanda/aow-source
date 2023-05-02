require("share\\view_define")
require("form_stage_main\\puzzle_quest\\puzzle_quest_define")
g_max_prize_num = 99
function on_main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  form.gemgame_lst = nx_call("util_gui", "get_arraylist", "form_caifeng_quest:gemgame_lst")
  form.gemgame_lst.CurOPName = ""
  form.gemgame_lst.CurOPGroup = -1
  form.gemgame_lst.RemainTime = 0
  form.gemgame_lst.CurGroupAIndex = 0
  form.gemgame_lst.CurGroupBIndex = 0
  form.gemgame_lst.Width = 0
  form.gemgame_lst.Height = 0
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_GEM_BOX, form, nx_current(), "on_gem_box_view_operat")
end
function on_gem_box_view_operat(form, optype, view_ident, index)
  local game_client = nx_value("game_client")
  local view_item = game_client:GetView(nx_string(view_ident))
  if nx_is_valid(view_item) and view_item:FindProp("MaxTurn") then
    form.pbar_turn.Maximum = nx_number(view_item:QueryProp("MaxTurn"))
    form.pbar_turn.Value = form.pbar_turn.Maximum - (nx_number(view_item:QueryProp("CurTurn")) - 1)
  end
  if not nx_is_valid(view_item) or not view_item:FindProp("RemainTime") then
    return
  end
  local gui = nx_value("gui")
  form.mltbox_turn.HtmlText = nx_widestr(nx_widestr("<center>") .. gui.TextManager:GetFormatText("ui_ydhd_time", form.pbar_turn.Value, form.pbar_turn.Maximum, nx_int(view_item:QueryProp("RemainTime"))) .. nx_widestr("</center>"))
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_exit_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_skill_click(btn)
  local form = nx_value(FORM_PUZZLE_QUEST)
  if nx_is_valid(form) then
    form.select_skill_id = btn.DataSource
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("yhg_mymh01"), 2)
    end
    gui.GameHand:SetHand("diamond_skill", "Attack", 0, "", "", "")
  end
end
function add_prize(...)
  local form = nx_value("form_stage_main\\puzzle_quest\\form_smahing_yhg")
  if not nx_is_valid(form) then
    return
  end
  if table.getn(arg) == 1 then
    if arg[1] == 0 then
      local gui = nx_value("gui")
      local ask_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
      ask_dialog.Left = form.Left + (form.Width - ask_dialog.Width) / 2
      ask_dialog.Top = form.Top + (form.Height - ask_dialog.Height) / 2
      nx_execute("form_common\\form_confirm", "show_common_text", ask_dialog, gui.TextManager:GetText("ui_yhgzd_ml"))
      ask_dialog:ShowModal()
      local res = nx_wait_event(100000000, ask_dialog, "confirm_return")
      if res == "ok" then
        if nx_is_valid(form) then
          nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_quest", "hide_form")
        end
      elseif res == "cancel" then
      end
    end
  else
    for i = 1, table.getn(arg) do
      local index = find_prize(arg[i])
      if 0 <= index then
        local num = form.imagegrid_prize:GetItemNumber(index)
        num = num + arg[i + 1]
        form.imagegrid_prize:SetItemNumber(index, num)
      else
        index = find_first_pos(form)
        if index < 0 or index > g_max_prize_num - 1 then
          return
        end
        local ini_item = nx_execute("util_functions", "get_ini", "share\\Item\\tool_item.ini")
        local section_index = ini_item:FindSectionIndex(arg[i])
        form.imagegrid_prize:AddItem(nx_int(index), ini_item:ReadString(section_index, "Photo", ""), nx_widestr(arg[i]), nx_int(arg[i + 1]), nx_int(-1))
      end
      i = i + 2
    end
  end
end
function find_prize(configid)
  local form = nx_value("form_stage_main\\puzzle_quest\\form_smahing_egg")
  if nx_is_valid(form) then
    for i = 1, g_max_prize_num do
      if form.imagegrid_prize:GetItemName(i - 1) == nx_widestr(configid) then
        return i - 1
      end
    end
  end
  return -1
end
function find_first_pos(form)
  if nx_is_valid(form) then
    for i = 1, g_max_prize_num do
      if form.imagegrid_prize:IsEmpty(i - 1) then
        return i - 1
      end
    end
  end
  return -1
end
function on_imagegrid_prize_mousein_grid(grid, index)
  local item_config = nx_string(grid:GetItemName(index))
  if item_config == "" then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
  if not bExist then
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
  prop_array.Amount = nx_string(grid:GetItemNumber(index))
  if not nx_is_valid(grid.Data) then
    grid.Data = nx_create("ArrayList", nx_current())
  end
  grid.Data:ClearChild()
  for prop, value in pairs(prop_array) do
    nx_set_custom(grid.Data, prop, value)
  end
  nx_execute("tips_game", "show_goods_tip", grid.Data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_imagegrid_prize_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_quit_click(self)
  nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_quest", "hide_form")
end
function on_btn_help_click(self)
  local help_form = nx_value("form_stage_main\\puzzle_quest\\form_puzzle_egg_help")
  if nx_is_valid(help_form) then
    help_form.Visible = not help_form.Visible
  else
    help_form = nx_execute("util_gui", "util_get_form", "form_stage_main\\puzzle_quest\\form_puzzle_egg_help", true, false)
    if nx_is_valid(help_form) then
      help_form.Fixed = false
      help_form:Show()
    end
  end
  help_form.no_need_motion_alpha = false
end
