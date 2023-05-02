require("define\\gamehand_type")
require("share\\itemtype_define")
require("util_functions")
require("share\\view_define")
require("share\\static_data_type")
local script_process = {
  [1] = {
    "form_stage_main\\form_life\\form_job_split",
    "Set_Split_Control_State"
  }
}
function gamehand_init(game_hand)
  game_hand.IsDragged = false
  game_hand.IsDropped = false
  nx_callback(game_hand, "on_set_hand", "on_set_hand")
  nx_callback(game_hand, "on_clear_hand", "on_clear_hand")
end
function on_set_hand(game_hand)
  local gamehand_type = game_hand.Type
  if gamehand_type == GHT_VIEWITEM or gamehand_type == GHT_SHORTCUT or gamehand_type == GHT_FUNC and game_hand.Para1 == "func" then
    local form_shortcut = nx_value("form_stage_main\\form_main\\form_main_shortcut")
    if not nx_is_valid(form_shortcut) then
      return
    end
    form_shortcut.grid_shortcut_2.EmptyShowFade = not game_hand:IsEmpty()
    form_shortcut.grid_shortcut_2.ShowEmpty = not game_hand:IsEmpty()
    form_shortcut.grid_shortcut_2.EmptyGridState = nx_int(1)
  end
  if gamehand_type == GHT_GROUD_PICK then
    local decal_name = game_hand.Para1
    local size = nx_number(game_hand.Para2)
    local script_func = game_hand.Para3
    local arg = game_hand.Para4
    nx_execute("game_effect", "add_ground_pick_decal", decal_name, size, arg)
  elseif gamehand_type == GHT_GROUD_PICK_2 then
    local decal_name = game_hand.Para1
    local size = nx_number(game_hand.Para2)
    local script_func = game_hand.Para3
    local range = game_hand.Para4
    nx_execute("game_effect", "add_ground_pick_decal", decal_name, size, range)
    game_hand.initstate = true
  else
    nx_execute("game_effect", "del_ground_pick_decal")
  end
  if gamehand_type ~= GHT_VIEWITEM then
    return
  end
  local view_id = nx_number(game_hand.Para1)
  local view_index = nx_number(game_hand.Para2)
  local game_client = nx_value("game_client")
  local view_item = game_client:GetViewObj(nx_string(view_id), nx_string(view_index))
  if not nx_is_valid(view_item) then
    return
  end
  if not view_item:FindProp("ItemType") then
    return
  end
  local item_type = view_item:QueryProp("ItemType")
  if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
    nx_execute("goods_grid", "show_equip_pos_tips", view_item)
  elseif item_type == ITEMTYPE_MOUNT then
    nx_execute("goods_grid", "show_mount_pos_tips", view_item)
  end
  for i = 1, table.getn(script_process) do
    local form = nx_execute("util_gui", "util_get_form", script_process[i][1])
    if nx_is_valid(form) and form.Visible then
      form.SelectObject = view_item
      nx_execute(script_process[i][1], script_process[i][2], form, true)
    end
  end
end
function on_clear_hand(game_hand)
  nx_execute("game_effect", "del_ground_pick_decal")
  local form_shortcut = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if nx_is_valid(form_shortcut) then
    form_shortcut.grid_shortcut_2.EmptyShowFade = not game_hand:IsEmpty()
    form_shortcut.grid_shortcut_2.ShowEmpty = not game_hand:IsEmpty()
    form_shortcut.grid_shortcut_2.EmptyGridState = nx_int(2)
  end
  nx_execute("goods_grid", "clear_equip_pos_tips")
  nx_execute("goods_grid", "clear_mount_pos_tips")
  nx_execute("goods_grid", "view_grid_clear_item_indirect")
  for i = 1, table.getn(script_process) do
    local form = nx_execute("util_gui", "util_get_form", script_process[i][1])
    if nx_is_valid(form) and form.Visible then
      form.SelectObject = nil
      nx_execute(script_process[i][1], script_process[i][2], form, false)
    end
  end
end
function gamehand_left_mouse_down()
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not gui.GameHand:IsEmpty() then
    if gui.GameHand.Type == GHT_SHORTCUT then
      local index = nx_number(gui.GameHand.Para1)
      nx_execute("shortcut_game", "remove_shortcut", index)
    elseif gui.GameHand.Type == GHT_VIEWITEM then
      local view_id = nx_number(gui.GameHand.Para1)
      local view_index = nx_number(gui.GameHand.Para2)
      local amount = nx_number(gui.GameHand.Para3)
      local goods_grid = nx_value("GoodsGrid")
      if nx_is_valid(goods_grid) and (goods_grid:IsToolBoxViewport(nx_int(view_id)) or goods_grid:IsNewViewPort(nx_int(view_id))) then
        local item = game_client:GetViewObj(nx_string(view_id), nx_string(view_index))
        if nx_is_valid(item) then
          local pack = item:QueryProp("LogicPack")
          local cant_delete = nx_execute("util_static_data", "item_static_query", pack, "CantDelete", STATIC_DATA_ITEM_LOGIC)
          cant_delete = nx_int(cant_delete)
          if cant_delete >= nx_int(1) then
            local gui = nx_value("gui")
            local configID = item:QueryProp("ConfigID")
            local name = gui.TextManager:GetText(configID)
            gui.TextManager:Format_SetIDName("1315")
            gui.TextManager:Format_AddParam(nx_widestr(name))
            local info = gui.TextManager:Format_GetText()
            local SystemCenterInfo = nx_value("SystemCenterInfo")
            if nx_is_valid(SystemCenterInfo) then
              SystemCenterInfo:ShowSystemCenterInfo(info, 2)
            end
          else
            local flag = nx_execute("form_stage_main\\form_taosha\\taosha_util", "is_in_taosha_scene")
            if flag then
              nx_execute("custom_sender", "custom_delete_item", view_id, view_index, amount)
              return true
            end
            local flag_apex = nx_execute("form_stage_main\\form_taosha\\apex_util", "is_in_apex_scene")
            if flag_apex then
              nx_execute("custom_sender", "custom_delete_item", view_id, view_index, amount)
              return true
            end
            local configID = item:QueryProp("ConfigID")
            local is_spacil = nx_execute("form_stage_main\\form_bag", "is_important_item", item)
            if 1 == is_spacil then
              local dia = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm_del", true, false)
              dia.event_type = "my_del"
              dia:ShowModal()
              local res = nx_wait_event(100000000, dia, "my_del_confirm_return")
              if "ok" == res then
                nx_execute("custom_sender", "custom_delete_item", view_id, view_index, amount)
                gui.GameHand:ClearHand()
                return true
              else
                gui.GameHand:ClearHand()
                return false
              end
            end
            local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
            local text = gui.TextManager:GetText("ui_confirm_destroyitem")
            nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
            dialog:ShowModal()
            local res = nx_wait_event(100000000, dialog, "confirm_return")
            if res == "ok" then
              nx_execute("custom_sender", "custom_delete_item", view_id, view_index, amount)
            end
          end
        end
      end
    elseif gui.GameHand.Type == GHT_FUNC then
      local para3 = gui.GameHand.Para3
      if para3 == "func_btns" then
        local btn_name = gui.GameHand.Para2
        nx_execute("form_stage_main\\form_main\\form_main_func_btns", "delete_custom_btn", btn_name)
      end
    elseif gui.GameHand.Type == GHT_GROUD_PICK then
      local game_hand = gui.GameHand
      local decal_name = game_hand.Para1
      local size = nx_number(game_hand.Para2)
      local script_func = game_hand.Para3
      local arg = game_hand.Para4
      local tuple = util_split_string(script_func, ",")
      local script_name = tuple[1]
      local func_name = tuple[2]
      local decal = nx_value("ground_pick_decal")
      if nx_is_valid(decal) and not decal.Visible then
        return false
      end
      nx_execute("game_effect", "hide_ground_pick_decal")
      local bItemSkillForm = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_main\\form_main_shortcut_itemskill")
      if bItemSkillForm then
        nx_execute("form_stage_main\\form_main\\form_main_shortcut_itemskill", "use_grid_shortcut_item")
      elseif nx_find_custom(game_hand, "wait_copy_skill") and game_hand.wait_copy_skill == 1 then
        nx_execute("form_stage_main\\form_main\\form_main_shortcut_copyskill", "use_circle_select_skill")
        game_hand.wait_copy_skill = 0
      elseif nx_find_custom(game_hand, "wait_ride_skill") and game_hand.wait_ride_skill == 1 then
        nx_execute("form_stage_main\\form_main\\form_main_shortcut_ride", "use_circle_select_skill")
        game_hand.wait_ride_skill = 0
      elseif nx_find_custom(game_hand, "wait_buff_skill") and game_hand.wait_buff_skill == 1 then
        nx_execute("form_stage_main\\form_main\\form_main_shortcut_buff_common", "use_circle_select_skill")
        game_hand.wait_buff_skill = 0
      else
        nx_execute("form_stage_main\\form_main\\form_main_shortcut", "use_grid_shortcut_item")
      end
      nx_execute("form_stage_main\\form_bag_func", "use_grid_item_skill")
      nx_execute("form_stage_main\\form_card\\form_card_skill", "custom_card_skill")
      nx_execute("form_stage_main\\form_sweet_employ\\form_task_skill", "use_task_skill")
    elseif gui.GameHand.Type == GHT_GROUD_PICK_2 then
      local game_hand = gui.GameHand
      local decal_name = game_hand.Para1
      local size = nx_number(game_hand.Para2)
      local script_func = game_hand.Para3
      local arg = game_hand.Para4
      local tuple = util_split_string(script_func, ",")
      local script_name = tuple[1]
      local func_name = tuple[2]
      local decal = nx_value("ground_pick_decal")
      if nx_is_valid(decal) and not decal.Visible then
        return false
      end
      nx_execute("game_effect", "hide_ground_pick_decal")
      local x = decal.PosX
      local y = decal.PosY
      local z = decal.PosZ
      nx_execute(script_name, func_name, true, x, y, z, arg)
    elseif gui.GameHand.Type == "myself_grid" then
      local index = nx_number(gui.GameHand.Para1)
      nx_execute("form_stage_main\\form_role_info\\form_onestep_equip", "del_grid_equip", index)
    elseif gui.GameHand.Type == "recast_equip" then
      nx_execute("form_stage_main\\form_life\\form_recast_attribute", "del_equip_info")
    elseif gui.GameHand.Type == "recast_weapon" then
      nx_execute("form_stage_main\\form_life\\form_recast_attribute_weapon", "del_equip_info")
    elseif gui.GameHand.Type == "repair_new_byself" then
      local form_bag = nx_value("form_stage_main\\form_bag_new")
      if nx_is_valid(form_bag) then
        form_bag.btn_repair.Checked = false
      end
    end
    gui.GameHand:ClearHand()
    return true
  end
  return false
end
function gamehand_right_mouse_down()
  local gui = nx_value("gui")
  if not gui.GameHand:IsEmpty() then
    if gui.GameHand.Type == GHT_SHORTCUT then
    elseif gui.GameHand.Type == GHT_VIEWITEM then
    elseif gui.GameHand.Type == GHT_FUNC then
    elseif gui.GameHand.Type == GHT_GROUD_PICK then
      local game_hand = gui.GameHand
      local decal_name = game_hand.Para1
      local size = nx_number(game_hand.Para2)
      local script_func = game_hand.Para3
      local arg = game_hand.Para4
      local tuple = util_split_string(script_func, ",")
      local script_name = tuple[1]
      local func_name = tuple[2]
      nx_execute("game_effect", "del_ground_pick_decal")
      gui.GameHand:ClearHand()
    elseif gui.GameHand.Type == GHT_GROUD_PICK_2 then
      local game_hand = gui.GameHand
      local decal_name = game_hand.Para1
      local size = nx_number(game_hand.Para2)
      local script_func = game_hand.Para3
      local arg = game_hand.Para4
      local tuple = util_split_string(script_func, ",")
      local script_name = tuple[1]
      local func_name = tuple[2]
      nx_execute("game_effect", "del_ground_pick_decal")
      nx_execute(script_name, func_name, false)
      gui.GameHand:ClearHand()
    elseif gui.GameHand.Type == "repair_new_byself" then
      local form_bag = nx_value("form_stage_main\\form_bag_new")
      if nx_is_valid(form_bag) then
        form_bag.btn_repair.Checked = false
      end
    end
    return true
  end
  return false
end
function gamehand_left_mouse_up()
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if gui.GameHand:IsEmpty() then
    return false
  end
  if GHT_SHORTCUT == gui.GameHand.Type then
    local index = nx_number(gui.GameHand.Para1)
    if gui.GameHand.Para4 ~= "imagegrid_1" then
      nx_execute("shortcut_game", "remove_shortcut", index)
    end
    gui.GameHand:ClearHand()
    return false
  end
  if GHT_VIEWITEM ~= gui.GameHand.Type then
    return false
  end
  local view_id = nx_number(gui.GameHand.Para1)
  local view_index = nx_number(gui.GameHand.Para2)
  local amount = nx_number(gui.GameHand.Para3)
  local goods_grid = nx_value("GoodsGrid")
  local isSplit = nx_value("isSplit")
  if "split" == isSplit then
    return false
  end
  if nx_is_valid(goods_grid) and goods_grid:IsToolBoxViewport(nx_int(view_id)) then
    local item = game_client:GetViewObj(nx_string(view_id), nx_string(view_index))
    if nx_is_valid(item) then
      local pack = item:QueryProp("LogicPack")
      local cant_delete = nx_execute("util_static_data", "item_static_query", pack, "CantDelete", STATIC_DATA_ITEM_LOGIC)
      cant_delete = nx_int(cant_delete)
      if cant_delete >= nx_int(1) then
        local gui = nx_value("gui")
        local configID = item:QueryProp("ConfigID")
        local name = gui.TextManager:GetText(configID)
        gui.TextManager:Format_SetIDName("1315")
        gui.TextManager:Format_AddParam(nx_widestr(name))
        local info = gui.TextManager:Format_GetText()
        local SystemCenterInfo = nx_value("SystemCenterInfo")
        if nx_is_valid(SystemCenterInfo) then
          SystemCenterInfo:ShowSystemCenterInfo(info, 2)
        end
      else
        local flag = nx_execute("form_stage_main\\form_taosha\\taosha_util", "is_in_taosha_scene")
        if flag then
          nx_execute("custom_sender", "custom_delete_item", view_id, view_index, amount)
          gui.GameHand:ClearHand()
          return true
        end
        local flag_apex = nx_execute("form_stage_main\\form_taosha\\apex_util", "is_in_apex_scene")
        if flag_apex then
          nx_execute("custom_sender", "custom_delete_item", view_id, view_index, amount)
          gui.GameHand:ClearHand()
          return true
        end
        local configID = item:QueryProp("ConfigID")
        local is_spacil = nx_execute("form_stage_main\\form_bag", "is_important_item", item)
        if 1 == is_spacil then
          local dia = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm_del", true, false)
          dia.event_type = "my_del"
          dia:ShowModal()
          local res = nx_wait_event(100000000, dia, "my_del_confirm_return")
          if "ok" == res then
            nx_execute("custom_sender", "custom_delete_item", view_id, view_index, amount)
            gui.GameHand:ClearHand()
            return true
          else
            gui.GameHand:ClearHand()
            return false
          end
        end
        local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
        local text = gui.TextManager:GetText("ui_confirm_destroyitem")
        nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
        dialog:ShowModal()
        local res = nx_wait_event(100000000, dialog, "confirm_return")
        if "ok" == res then
          nx_execute("custom_sender", "custom_delete_item", view_id, view_index, amount)
        end
      end
    end
  end
  gui.GameHand:ClearHand()
  return true
end
function do_split_item(amount)
  local gui = nx_value("gui")
  amount = amount or 1
  gui.GameHand:SetHand(GHT_FUNC, GHT_FUNC_ICON.split, "split", nx_string(amount), "", "")
end
function do_destroy_item()
  local gui = nx_value("gui")
  gui.GameHand:SetHand(GHT_FUNC, GHT_FUNC_ICON.destroy, "destroy", "", "", "")
end
