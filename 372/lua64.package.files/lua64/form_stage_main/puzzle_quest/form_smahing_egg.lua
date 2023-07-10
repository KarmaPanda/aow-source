require("share\\view_define")
require("share\\static_data_type")
require("form_stage_main\\puzzle_quest\\puzzle_quest_define")
g_max_prize_num = 99
function on_main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  init_info(form)
  on_btn_egg_prize_click(form.btn_1)
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
  databinder:AddViewBind(VIEWPORT_TASK_TOOL, form, nx_current(), "on_view_operat")
end
function init_info(form)
  if nx_is_valid(form) then
    local red, gold, green = nx_execute(FORM_PUZZLE_QUEST, "get_diamond_count", 12, 11, 10)
    form.lbl_fuqi_sl.Text = nx_widestr(red)
    form.lbl_jinlong_sl.Text = nx_widestr(gold)
    form.lbl_feicui_sl.Text = nx_widestr(green)
  end
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
  init_info(form)
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form)
  end
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
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("8040"), 2)
    end
    gui.GameHand:SetHand("diamond_skill", "Attack", 0, "", "", "")
  end
end
function add_prize(...)
  local form = nx_value("form_stage_main\\puzzle_quest\\form_smahing_egg")
  if not nx_is_valid(form) then
    return
  end
  if table.getn(arg) == 1 then
    if arg[1] == 0 then
      local gui = nx_value("gui")
      local ask_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
      ask_dialog.Left = form.Left + (form.Width - ask_dialog.Width) / 2
      ask_dialog.Top = form.Top + (form.Height - ask_dialog.Height) / 2
      nx_execute("form_common\\form_confirm", "show_common_text", ask_dialog, gui.TextManager:GetText("ui_ydhd_ml"))
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
        local photo = ""
        if section_index < 0 then
          local game_client = nx_value("game_client")
          if nx_is_valid(game_client) then
            local client_player = game_client:GetPlayer()
            if nx_is_valid(client_player) then
              local sex = client_player:QueryProp("Sex")
              if sex == 0 then
                photo = nx_string(nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(arg[i]), "Photo"))
              else
                photo = nx_string(nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(arg[i]), "FemalePhoto"))
              end
            end
          end
        else
          photo = ini_item:ReadString(section_index, "Photo", "")
        end
        form.imagegrid_prize:AddItem(nx_int(index), photo, nx_widestr(arg[i]), nx_int(arg[i + 1]), nx_int(-1))
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
function on_btn_egg_prize_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if btn.DataSource == "" then
    return
  end
  form.imagegrid_egg_prize:Clear()
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\puzzlequest\\zadan_prize.ini")
  if nx_is_valid(ini) then
    local sec_index = ini:FindSectionIndex(btn.DataSource)
    if sec_index < 0 then
      return
    end
    if ini:GetSectionItemCount(sec_index) == 12 then
      for i = 1, ini:GetSectionItemCount(sec_index) do
        local configid = ini:ReadString(sec_index, nx_string(i), "")
        if configid == "" then
          return
        end
        local ini_item = nx_execute("util_functions", "get_ini", "share\\Item\\tool_item.ini")
        local section_index = ini_item:FindSectionIndex(configid)
        form.imagegrid_egg_prize:AddItem(nx_int(i - 1), ini_item:ReadString(section_index, "Photo", ""), nx_widestr(configid), nx_int(1), nx_int(-1))
      end
    end
  end
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
function on_view_operat(form, optype, view_ident, index)
  local count_1 = get_item_in_bag_count("item_zd_yinchui")
  form.lbl_yinchui_sl.Text = nx_widestr(count_1)
  local count_2 = get_item_in_bag_count("item_zd_jinchui")
  form.lbl_jinchui_sl.Text = nx_widestr(count_2)
  local count_3 = get_item_in_bag_count("item_zd_yuchui")
  form.lbl_yuchui_sl.Text = nx_widestr(count_3)
end
function get_item_in_bag_count(configid)
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return 0
  end
  local count = goods_grid:GetItemCount(configid)
  return count
end
