require("share\\view_define")
require("util_gui")
require("form_stage_main\\form_charge_shop\\charge_shop_define")
require("define\\gamehand_type")
require("define\\sysinfo_define")
require("share\\itemtype_define")
require("tips_func_equip")
require("util_functions")
require("share\\static_data_type")
require("util_role_prop")
require("control_set")
local FORM_ONESTEP_EQUIP = "form_stage_main\\form_role_info\\form_onestep_equip"
local EQUIP_KEY = 0
local EQUIP_UNIQUEID = 1
local COVER_IMG = "gui\\mainform\\cover_1.png"
local PROGECT_ID = 0
local EQUIP_UID = 1
local EQUIP_INDEX = 2
local CHANGE_OLD_ID_1 = 0
local CHANGE_OLD_ID_2 = 1
local CHANGE_OLD_ID_3 = 2
local CHANGE_OLD_ID_4 = 3
local CHANGE_NEW_ID_1 = 100
local CHANGE_NEW_ID_2 = 101
local CHANGE_NEW_ID_3 = 102
local CHANGE_NEW_ID_4 = 103
local EQUIP_STEP = 25
local equip_table = {
  [0] = "hat",
  [2] = "cloth",
  [4] = "pants",
  [6] = "shoes",
  [7] = "weapon"
}
local equip_model = {
  cloth_boy = "obj\\char\\b_jianghu000\\b_cloth000",
  cloth_girl = "obj\\char\\g_jianghu000\\g_cloth000",
  pants_boy = "obj\\char\\b_jianghu000\\b_pants000",
  pants_girl = "obj\\char\\g_jianghu000\\g_pants000",
  shoes_boy = "obj\\char\\b_jianghu000\\b_shoes000",
  shoes_girl = "obj\\char\\g_jianghu000\\g_shoes000"
}
local view_table = {
  VIEWPORT_EQUIP,
  VIEWPORT_EQUIP_TOOL,
  VIEWPORT_NEWEQUIPTOOLBOX
}
TREASURESTARTPOS = 14
TREASURESTART = 25
TREASUREEND = 34
function refresh_form(form)
  if not nx_is_valid(form) then
    return
  end
  if not form.Visible then
    return
  end
  if not nx_find_custom(form, "sel_index") then
    return
  end
  refresh_gridimage(form.equip_grid, form.sel_index)
  refresh_actor2(form)
end
function on_form_init(form)
  form.Fixed = true
end
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.sel_index = nx_number(rbtn.DataSource)
    refresh_form(form)
    local projid = get_real_projid(form.sel_index)
    nx_execute("form_stage_main\\form_role_info\\form_onestep_jingmai", "set_one_key_index", projid)
  end
end
function on_form_onestep_equip_open(form)
  init_bind_view_index(form)
  init_scene_box(form)
  refresh_name(form)
  refresh_school(form)
  local form_main_onestep = nx_value("form_main_onestep")
  if not nx_is_valid(form_main_onestep) then
    form_main_onestep = nx_create("form_main_onestep")
    nx_set_value("form_main_onestep", form_main_onestep)
  end
  form.sel_index = 0
  form.rbtn_1.Checked = true
  local form_main = nx_value("form_stage_main\\form_main\\form_main_shortcut_onestep")
  if not nx_is_valid(form_main) then
    form.cbtn_showkey.Checked = false
    return
  end
  form.cbtn_showkey.Checked = form_main.show_equip
  refresh_treasure_lock()
  form.groupbox_treasure_bg.Visible = false
  form.rbtn_equip.Checked = true
  form.cbtn_active_jingmai.Checked = nx_int(GetIniInfo("one_key_active_jingmai")) > nx_int(0)
end
function on_form_onestep_equip_close(form)
  nx_execute("tips_game", "hide_tip", form)
  nx_execute("util_gui", "ui_ClearModel", form.role_box)
  local form_main_onestep = nx_value("form_main_onestep")
  if nx_is_valid(form_main_onestep) then
    nx_destroy(form_main_onestep)
  end
  form.Visible = false
  nx_destroy(form)
end
function on_equipbox_record_change(form, tablename, op, raw, col)
  if op == "add" or op == "update" or op == "del" then
    refresh_form(form)
  end
end
function on_view_operat(grid, optype, view_ident, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if optype == "delitem" or optype == "additem" then
    refresh_form(form)
  end
end
function on_btn_clear_click(btn)
  local form = btn.ParentForm
  if nx_find_custom(form, "sel_index") and nx_find_custom(form, "type_index") then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(util_text("ui_onestep_equip_clear_confirm")))
    dialog:ShowModal()
    local gui = nx_value("gui")
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      local real_proj = get_real_projid(form.sel_index)
      nx_execute("custom_sender", "custom_onestep_equip_msg_clear", form.type_index, real_proj)
    end
  end
end
function on_btn_set_jingmai_click(btn)
  local form = btn.ParentForm
  if not nx_find_custom(form, "sel_index") then
    return 0
  end
  local form_jingmai = nx_value("form_stage_main\\form_role_info\\form_onestep_jingmai")
  if not nx_is_valid(form_jingmai) then
    return 0
  end
  local form_role_info = nx_value("form_stage_main\\form_role_info\\form_role_info")
  if not nx_is_valid(form_role_info) then
    return 0
  end
  if form_jingmai.Visible then
    form_jingmai.Visible = false
    form_role_info.Width = form_role_info.groupbox_1.Width
  else
    local projid = get_real_projid(form.sel_index)
    nx_execute("form_stage_main\\form_role_info\\form_onestep_jingmai", "set_one_key_index", projid)
    form_jingmai.Visible = true
    form_role_info.Width = form_jingmai.Left + form_jingmai.Width
  end
end
function on_btn_left_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_left_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_left_push(btn)
  btn.MouseDown = true
  local form = btn.Parent
  local speed = 3.1415926
  while nx_is_valid(form) and nx_is_valid(btn) and btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if not nx_is_valid(form) then
      return
    end
    nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
  end
end
function on_btn_right_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_right_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_right_push(btn)
  btn.MouseDown = true
  local form = btn.Parent
  local speed = -3.1415926
  while nx_is_valid(form) and nx_is_valid(btn) and btn.MouseDown do
    local elapse = nx_pause(0)
    if not nx_is_valid(form) then
      return
    end
    local dist = speed * elapse
    nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
  end
end
function on_equip_grid_mousein(equip_grid, index)
  local form = equip_grid.ParentForm
  local item_data = get_item_by_gridindex(form, index)
  if nx_is_valid(item_data) then
    nx_execute("tips_game", "show_3d_tips_one", item_data, equip_grid:GetMouseInItemLeft(), equip_grid:GetMouseInItemTop(), equip_grid.ParentForm, false)
  else
    local text = get_grid_pos_tip(index)
    nx_execute("tips_game", "show_text_tip", text, equip_grid:GetMouseInItemLeft(), equip_grid:GetMouseInItemTop(), 0, equip_grid.ParentForm)
  end
  refresh_drawmousein(equip_grid, index)
end
function on_equip_grid_mouseout(equip_grid, index)
  nx_execute("tips_game", "hide_tip", equip_grid.ParentForm)
end
function on_equip_grid_rightclick_grid(equip_grid, index)
  local form = equip_grid.ParentForm
  if not equip_grid:IsEmpty(index) then
    local i = equip_grid:GetBindIndex(index)
    local proj = get_real_projid(form.sel_index)
    local pos = i
    nx_execute("custom_sender", "custom_onestep_equip_msg_del", proj, pos)
  end
end
function init_bind_view_index(form)
  form.equip_grid:SetBindIndex(0, 1)
  form.equip_grid:SetBindIndex(1, 13)
  form.equip_grid:SetBindIndex(2, 3)
  form.equip_grid:SetBindIndex(3, 6)
  form.equip_grid:SetBindIndex(4, 4)
  form.equip_grid:SetBindIndex(5, 7)
  form.equip_grid:SetBindIndex(6, 8)
  form.equip_grid:SetBindIndex(7, 22)
  form.equip_grid:SetBindIndex(8, 23)
  form.equip_grid:SetBindIndex(9, 11)
  form.equip_grid:SetBindIndex(10, 12)
  form.equip_grid:SetBindIndex(11, 14)
  form.equip_grid:SetBindIndex(12, 15)
  form.equip_grid:SetBindIndex(13, 24)
  form.equip_grid:SetBindIndex(14, 25)
  form.equip_grid:SetBindIndex(15, 26)
  form.equip_grid:SetBindIndex(16, 27)
  form.equip_grid:SetBindIndex(17, 28)
  form.equip_grid:SetBindIndex(18, 29)
  form.equip_grid:SetBindIndex(19, 30)
  form.equip_grid:SetBindIndex(20, 31)
  form.equip_grid:SetBindIndex(21, 32)
  form.equip_grid:SetBindIndex(22, 33)
  form.equip_grid:SetBindIndex(23, 34)
end
function on_equip_grid_drag_enter(self, index)
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  game_hand.IsDragged = false
  game_hand.IsDropped = false
end
function on_equip_grid_drag_move(self, index, x, y)
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  if game_hand.IsDragged then
    return
  end
  game_hand.IsDragged = true
  if not game_hand:IsEmpty() then
    local gamehand_type = game_hand.Type
    if gamehand_type ~= GHT_VIEWITEM then
      return
    end
    local src_viewid = nx_int(game_hand.Para1)
    local src_pos = nx_int(game_hand.Para2)
    local GoodsGrid = nx_value("GoodsGrid")
    if nx_is_valid(GoodsGrid) and GoodsGrid:IsToolBoxViewport(nx_int(src_viewid)) then
      local item = nx_execute("goods_grid", "get_view_item", src_viewid, src_pos)
      local view_index = self:GetBindIndex(index)
      if not nx_execute("goods_grid", "can_change_equip", item, view_index) then
        local SystemCenterInfo = nx_value("SystemCenterInfo")
        if nx_is_valid(SystemCenterInfo) then
          SystemCenterInfo:ShowSystemCenterInfo(util_text("1220"), CENTERINFO_PERSONAL_NO)
        end
        game_hand:ClearHand()
        return
      end
    end
  else
    local photo = self:GetItemImage(index)
    gui.GameHand:SetHand("myself_grid", photo, nx_string(index), "", "", "")
  end
end
function on_equip_grid_select(equip_grid, index)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local form = equip_grid.ParentForm
  local bind_index = nx_number(equip_grid:GetBindIndex(index))
  if bind_index == nil then
    return
  end
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
  local gui = nx_value("gui")
  if gui.GameHand:IsEmpty() then
    local photo = equip_grid:GetItemImage(index)
    gui.GameHand:SetHand("myself_grid", photo, nx_string(index), "", "", "")
    return
  end
  local gamehand_type = gui.GameHand.Type
  if gamehand_type == GHT_VIEWITEM then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local src_pos = nx_int(gui.GameHand.Para2)
    if not GoodsGrid:IsToolBoxViewport(nx_int(src_viewid)) and not GoodsGrid:IsNewViewPort(nx_int(src_viewid)) then
      return
    end
    if bind_index >= TREASURESTART and bind_index <= TREASUREEND and not GoodsGrid:tersure_can_wear(bind_index) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "1214")
      return
    end
    local item = nx_execute("goods_grid", "get_view_item", src_viewid, src_pos)
    local client_player = game_client:GetPlayer()
    if nx_is_valid(client_player) then
      local reqLevel = item:QueryProp("ReqLevel")
      local powerLevel = client_player:QueryProp("PowerLevel")
      if reqLevel > powerLevel then
        nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "16618")
        return
      end
    end
    local view_index = equip_grid:GetBindIndex(index)
    if not nx_execute("goods_grid", "can_change_equip", item, view_index) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("1220"), CENTERINFO_PERSONAL_NO)
      end
      gui.GameHand:ClearHand()
      return
    else
      local sureequip = false
      local b_need_bind = nx_execute("form_stage_main\\form_itembind\\form_itembind_manager", "equip_itemobj_need_bind", nx_int(src_viewid), nx_int(src_pos))
      if b_need_bind then
        local dialog = show_dialog_tip(src_viewid, src_pos)
        local res = nx_wait_event(100000000, dialog, "onestep_equip_confirm_return")
        sureequip = res == "ok"
      else
        sureequip = true
      end
      local ret = get_gridindex_by_item(item)
      if ret == 100 then
        gui.GameHand:ClearHand()
        sureequip = false
      end
      if sureequip then
        local item_unid = item:QueryProp("UniqueID")
        local i = equip_grid:GetBindIndex(index)
        local proj = get_real_projid(form.sel_index)
        local pos = i
        nx_execute("custom_sender", "custom_onestep_equip_msg_add", proj, pos, item_unid)
        gui.GameHand:ClearHand()
      end
    end
  elseif gamehand_type == "myself_grid" and index == nx_int(gui.GameHand.Para1) then
    gui.GameHand:ClearHand()
  end
end
function on_equip_grid_drag_leave(self, index)
end
function on_equip_grid_drop_in(grid, index)
  local form = grid.ParentForm
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  if not game_hand.IsDragged or game_hand.IsDropped then
    return
  end
  game_hand.IsDropped = true
  if game_hand:IsEmpty() then
    return
  end
  local bind_index = nx_number(grid:GetBindIndex(index))
  if bind_index == nil then
    return
  end
  local gamehand_type = game_hand.Type
  if gamehand_type == GHT_VIEWITEM then
    local src_viewid = nx_int(game_hand.Para1)
    local src_pos = nx_int(game_hand.Para2)
    if not GoodsGrid:IsToolBoxViewport(nx_int(src_viewid)) then
      return
    end
    if bind_index >= TREASURESTART and bind_index <= TREASUREEND and not GoodsGrid:tersure_can_wear(bind_index) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "1214")
      return
    end
    local item = nx_execute("goods_grid", "get_view_item", src_viewid, src_pos)
    local client_player = game_client:GetPlayer()
    if nx_is_valid(client_player) then
      local reqLevel = item:QueryProp("ReqLevel")
      local powerLevel = client_player:QueryProp("PowerLevel")
      if reqLevel > powerLevel then
        nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "16618")
        return
      end
    end
    local view_index = grid:GetBindIndex(index)
    if not nx_execute("goods_grid", "can_change_equip", item, view_index) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("1220"), CENTERINFO_PERSONAL_NO)
      end
      game_hand:ClearHand()
      return
    else
      local sureequip = false
      local b_need_bind = nx_execute("form_stage_main\\form_itembind\\form_itembind_manager", "equip_itemobj_need_bind", nx_int(src_viewid), nx_int(src_pos))
      if b_need_bind then
        local dialog = show_dialog_tip(src_viewid, src_pos)
        local res = nx_wait_event(100000000, dialog, "onestep_equip_confirm_return")
        sureequip = res == "ok"
      else
        sureequip = true
      end
      local ret = get_gridindex_by_item(item)
      if ret == 100 then
        gui.GameHand:ClearHand()
        return
      end
      if sureequip then
        local item_unid = item:QueryProp("UniqueID")
        local i = grid:GetBindIndex(index)
        local proj = get_real_projid(form.sel_index)
        local pos = i
        nx_execute("custom_sender", "custom_onestep_equip_msg_add", proj, pos, item_unid)
        gui.GameHand:ClearHand()
      end
    end
  elseif gamehand_type == "myself_grid" and index == nx_int(game_hand.Para1) then
    game_hand:ClearHand()
  end
end
function on_btn_equip_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local real_proj = get_real_projid(form.sel_index)
  nx_execute("custom_sender", "custom_onestep_equip_msg_equipall", real_proj)
  nx_execute("form_stage_main\\form_role_info\\form_onestep_jingmai", "one_key_active_jingmai", real_proj)
end
function refresh_school(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local school = nx_string(client_player:QueryProp("School"))
  local school_name = ""
  if school == "school_shaolin" then
    school_name = gui.TextManager:GetText("ui_neigong_category_sl")
  elseif school == "school_wudang" then
    school_name = gui.TextManager:GetText("ui_neigong_category_wd")
  elseif school == "school_emei" then
    school_name = gui.TextManager:GetText("ui_neigong_category_em")
  elseif school == "school_junzitang" then
    school_name = gui.TextManager:GetText("ui_neigong_category_jz")
  elseif school == "school_jinyiwei" then
    school_name = gui.TextManager:GetText("ui_neigong_category_jy")
  elseif school == "school_jilegu" then
    school_name = gui.TextManager:GetText("ui_neigong_category_jl")
  elseif school == "school_gaibang" then
    school_name = gui.TextManager:GetText("ui_neigong_category_gb")
  elseif school == "school_tangmen" then
    school_name = gui.TextManager:GetText("ui_neigong_category_tm")
  elseif school == "school_mingjiao" then
    school_name = gui.TextManager:GetText("ui_neigong_category_mj")
  elseif school == "school_tianshan" then
    school_name = gui.TextManager:GetText("ui_neigong_category_ts")
  else
    school_name = gui.TextManager:GetText("ui_task_school_null")
  end
  form.lbl_school.Text = nx_widestr(school_name)
end
function refresh_name(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local name = client_player:QueryProp("Name")
  form.name.Text = nx_widestr(name)
end
function refresh_gridimage(grid, rbtn_index)
  if not nx_is_valid(grid) then
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
  local index = get_real_projid(rbtn_index)
  if index < 0 then
    return
  end
  grid:Clear()
  clear_grid_coverimg(grid)
  local bIsNewJHModule = is_newjhmodule()
  if client_player:FindRecord("equip_box_rec") then
    local selMin, selMax = get_cur_proj(index)
    if selMin == -1 then
      return
    end
    local rows = client_player:GetRecordRows("equip_box_rec")
    for i = 0, rows - 1 do
      local key = client_player:QueryRecord("equip_box_rec", i, EQUIP_KEY)
      if selMin <= key and selMax >= key then
        local item_uniqueId = client_player:QueryRecord("equip_box_rec", i, EQUIP_UNIQUEID)
        local item, view_id = get_item_by_uid(nx_string(item_uniqueId))
        local bind_index = key % EQUIP_STEP
        local grid_index = get_gridindex_by_bindindex(bind_index)
        if grid_index ~= -1 then
          local photo, amount = get_photo_amont(item)
          if "" ~= photo then
            grid:AddItem(grid_index, photo, "", amount, -1)
            local show_cover = true
            if bIsNewJHModule then
              if view_id == VIEWPORT_EQUIP_TOOL then
                show_cover = false
              end
            elseif view_id == VIEWPORT_NEWEQUIPTOOLBOX then
              show_cover = false
            end
            if show_cover == true then
              set_grid_coverimg(grid, grid_index, COVER_IMG)
            else
              set_grid_coverimg(grid, grid_index, "")
            end
          end
        end
      end
    end
  end
  if client_player:FindRecord("equip_scheme_rec") then
    local rows = client_player:GetRecordRows("equip_scheme_rec")
    for i = 0, rows - 1 do
      if client_player:QueryRecord("equip_scheme_rec", i, PROGECT_ID) == index then
        local item_uniqueId = client_player:QueryRecord("equip_scheme_rec", i, EQUIP_UID)
        local item, view_id = get_item_by_uid(nx_string(item_uniqueId))
        local bind_index = client_player:QueryRecord("equip_scheme_rec", i, EQUIP_INDEX)
        local grid_index = get_gridindex_by_bindindex(bind_index)
        if grid_index ~= -1 then
          local photo, amount = get_photo_amont(item)
          if "" ~= photo then
            grid:AddItem(grid_index, photo, "", amount, -1)
            local show_cover = true
            if bIsNewJHModule then
              if view_id == VIEWPORT_EQUIP_TOOL then
                show_cover = false
              end
            elseif view_id == VIEWPORT_NEWEQUIPTOOLBOX then
              show_cover = false
            end
            if show_cover == true then
              set_grid_coverimg(grid, grid_index, COVER_IMG)
            else
              set_grid_coverimg(grid, grid_index, "")
            end
          end
        end
      end
    end
  end
  refresh_treasure_lock()
end
function set_grid_coverimg(grid, index, image)
  if not nx_is_valid(grid) then
    return
  end
  if grid:IsEmpty(index) then
    return
  end
  grid:SetItemCoverImage(index, image)
  grid:CoverItem(index, true)
end
function clear_grid_coverimg(grid)
  if not nx_is_valid(grid) then
    return
  end
  for i = 0, 23 do
    grid:CoverItem(i, false)
  end
end
function refresh_actor2(form)
  if not nx_is_valid(form) then
    return
  end
  init_role_model(form.role_model)
  for i, name in pairs(equip_table) do
    local item = get_item_by_gridindex(form, i)
    if nx_is_valid(item) then
      refresh_role_model_by_equip(form.role_model, item)
    end
  end
end
function get_equip_model(item, sex_prop_name)
  local pack_id
  local id = item:QueryProp("ReplacePack")
  if id ~= nil and 0 < id then
    pack_id = id
  else
    id = item:QueryProp("ArtPack")
    if id ~= nil and 0 < id then
      pack_id = id
    end
  end
  local data_query = nx_value("data_query_manager")
  local modelfile = data_query:Query(STATIC_DATA_ITEM_ART, nx_int(pack_id), sex_prop_name)
  return modelfile
end
function get_photo_amont(item)
  local photo = ""
  local amount = 0
  if nx_is_valid(item) then
    photo = nx_execute("util_static_data", "query_equip_photo_by_sex", item)
    amount = 1
  end
  return photo, amount
end
function get_item_by_uid(uni_id)
  local game_client = nx_value("game_client")
  local size = table.maxn(view_table)
  for i = 1, size do
    local view = game_client:GetView(nx_string(view_table[i]))
    if nx_is_valid(view) then
      local viewobj_list = view:GetViewObjList()
      local count = table.maxn(viewobj_list)
      for j = 1, count do
        local itemobj = viewobj_list[j]
        local tempid = itemobj:QueryProp("UniqueID")
        if nx_string(tempid) == nx_string(uni_id) then
          return itemobj, view_table[i]
        end
      end
    end
  end
  return nil, nil
end
function get_gridindex_by_bindindex(bind_index)
  local form = util_get_form(FORM_ONESTEP_EQUIP, false)
  if not nx_is_valid(form) then
    return -1
  end
  local grid = form.equip_grid
  local size = grid.ClomnNum
  for i = 0, size - 1 do
    local index = grid:GetBindIndex(i)
    if index == bind_index then
      return i
    end
  end
  return -1
end
function get_equip_pos(equip)
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(equip) then
    return nil
  end
  return goods_grid:GetEquipPositionList(equip)
end
function get_gridindex_by_item(item)
  local form = util_get_form(FORM_ONESTEP_EQUIP, false)
  if not nx_is_valid(form) then
    return -1
  end
  local pos_list = get_equip_pos(item)
  if pos_list == nil then
    return -1
  end
  local grid = form.equip_grid
  local size = grid.ClomnNum
  for i, pos in pairs(pos_list) do
    for j = 0, size - 1 do
      local grid_pos = form.equip_grid:GetBindIndex(j)
      if grid_pos == pos then
        local item_obj = get_item_by_gridindex(form, j)
        if not nx_is_valid(item_obj) then
          return j
        end
        local item_src = item_obj:QueryProp("UniqueID")
        local item_des = item:QueryProp("UniqueID")
        if nx_string(item_src) == nx_string(item_des) then
          return 100
        end
      end
    end
  end
  return -1
end
function get_item_by_gridindex(form, index)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local equip_index = form.equip_grid:GetBindIndex(index)
  local real_proj = get_real_projid(form.sel_index)
  if equip_index <= 24 then
    local key = real_proj * EQUIP_STEP + form.equip_grid:GetBindIndex(index)
    local row = client_player:FindRecordRow("equip_box_rec", EQUIP_KEY, key, 0)
    if 0 <= row then
      local item_uniqueId = client_player:QueryRecord("equip_box_rec", row, EQUIP_UNIQUEID)
      local item = get_item_by_uid(item_uniqueId)
      return item
    end
  else
    for i = 0, client_player:GetRecordRows("equip_scheme_rec") - 1 do
      if real_proj == client_player:QueryRecord("equip_scheme_rec", i, PROGECT_ID) and client_player:QueryRecord("equip_scheme_rec", i, EQUIP_INDEX) == equip_index then
        local item_uniqueId = client_player:QueryRecord("equip_scheme_rec", i, EQUIP_UID)
        local item = get_item_by_uid(item_uniqueId)
        return item
      end
    end
  end
  return nil
end
function get_cur_proj(index)
  if index == CHANGE_OLD_ID_1 then
    return 1, 25
  elseif index == CHANGE_OLD_ID_2 then
    return 26, 50
  elseif index == CHANGE_OLD_ID_3 then
    return 51, 75
  elseif index == CHANGE_OLD_ID_4 then
    return 76, 100
  elseif index == CHANGE_NEW_ID_1 then
    return 2501, 2525
  elseif index == CHANGE_NEW_ID_2 then
    return 2526, 2550
  elseif index == CHANGE_NEW_ID_3 then
    return 2551, 2575
  elseif index == CHANGE_NEW_ID_4 then
    return 2576, 2600
  end
  return -1, -1
end
function init_scene_box(form)
  nx_execute("util_gui", "ui_ClearModel", form.role_box)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not nx_is_valid(form.role_box.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.role_box)
  end
  local actor2 = nx_execute("role_composite", "create_role_composite", form.role_box.Scene, true, client_player:QueryProp("Sex"))
  if not nx_is_valid(actor2) then
    return
  end
  while nx_is_valid(form) and nx_is_valid(actor2) and nx_call("role_composite", "is_loading", 2, actor2) do
    nx_pause(0)
  end
  if not nx_is_valid(form) then
    return
  end
  actor2.sex = client_player:QueryProp("Sex")
  nx_execute("util_gui", "util_add_model_to_scenebox", form.role_box, actor2)
  form.role_model = actor2
end
function init_role_model(actor2)
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
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
  local addr = ""
  if actor2.sex == 0 then
    addr = "_boy"
  elseif actor2.sex == 1 then
    addr = "_girl"
  end
  local cloth = "cloth" .. addr
  local pants = "pants" .. addr
  local Shoes = "shoes" .. addr
  local Hat_model = client_player:QueryProp("Hair")
  local Cloth_model = equip_model[cloth]
  local Pants_model = equip_model[pants]
  local Shoes_model = equip_model[Shoes]
  link_hat_skin(role_composite, actor2, Hat_model)
  link_cloth_skin(role_composite, actor2, Cloth_model)
  link_pants_skin(role_composite, actor2, Pants_model)
  refresh_skin(actor2, "shoes", Shoes_model)
  role_composite:UnLinkWeapon(actor2)
  local action = nx_value("action_module")
  if nx_is_valid(action) then
    action:BlendAction(actor2, "stand", false, true)
  end
end
function refresh_skin(actor2, prop_name, model_name)
  local role_composite = nx_value("role_composite")
  if nx_is_valid(role_composite) then
    role_composite:LinkSkin(actor2, prop_name, model_name .. ".xmod", false)
  end
end
function refresh_role_model_by_equip(actor2, item)
  if not nx_is_valid(actor2) then
    return
  end
  if not nx_is_valid(item) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
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
  local sex = client_player:QueryProp("Sex")
  local need_sex = item:QueryProp("NeedSex")
  if nx_int(need_sex) <= nx_int(1) and nx_int(need_sex) ~= nx_int(sex) then
    return
  end
  local sex_prop_name = ""
  if sex == 0 then
    sex_prop_name = "MaleModel"
  elseif sex == 1 then
    sex_prop_name = "FemaleModel"
  end
  if sex_prop_name == "" then
    return
  end
  local item_type = item:QueryProp("ItemType")
  if ITEMTYPE_EQUIP_HAT == item_type then
    local art_value = get_equip_model(item, sex_prop_name)
    link_hat_skin(role_composite, actor2, art_value)
  elseif ITEMTYPE_EQUIP_CLOTH == item_type then
    local art_value = get_equip_model(item, sex_prop_name)
    link_cloth_skin(role_composite, actor2, art_value)
  elseif ITEMTYPE_EQUIP_PANTS == item_type then
    local art_value = get_equip_model(item, sex_prop_name)
    role_composite:LinkSkin(actor2, "pants", art_value .. ".xmod", false)
  elseif ITEMTYPE_EQUIP_SHOES == item_type then
    local art_value = get_equip_model(item, sex_prop_name)
    role_composite:LinkSkin(actor2, "shoes", art_value .. ".xmod", false)
  elseif ITEMTYPE_EQUIP_LEG == item_type then
  elseif ITEMTYPE_EQUIP_WRIST == item_type then
  elseif item_type >= ITEMTYPE_WEAPON_SHOW_MIN and item_type <= ITEMTYPE_WEAPON_SHOW_MAX then
    local pack_no = item:QueryProp("ArtPack")
    if item:FindProp("ReplacePack") then
      local id = item:QueryProp("ReplacePack")
      if id ~= nil and 0 < id then
        pack_no = id
      end
    end
    role_composite:RefreshCustomWeaponFormArtPack(actor2, nx_string(pack_no))
  end
end
function get_grid_pos_tip(grid_index)
  local gui = nx_value("gui")
  local pos = nx_string(grid_index)
  local text
  if pos == "0" then
    text = gui.TextManager:GetText("tips_equip_pos_0")
  elseif pos == "1" then
    text = gui.TextManager:GetText("tips_equip_pos_10")
  elseif pos == "2" then
    text = gui.TextManager:GetText("tips_equip_pos_2")
  elseif pos == "3" then
    text = gui.TextManager:GetText("tips_equip_pos_5")
  elseif pos == "4" then
    text = gui.TextManager:GetText("tips_equip_pos_3")
  elseif pos == "5" then
    text = gui.TextManager:GetText("tips_equip_pos_6")
  elseif pos == "6" then
    text = gui.TextManager:GetText("tips_equip_pos_7")
  elseif pos == "7" then
    text = gui.TextManager:GetText("tips_equip_pos_17")
  elseif pos == "8" then
    text = gui.TextManager:GetText("tips_equip_pos_18")
  elseif pos == "9" then
    text = gui.TextManager:GetText("tips_equip_pos_8")
  elseif pos == "10" then
    text = gui.TextManager:GetText("tips_equip_pos_9")
  elseif pos == "11" then
    text = gui.TextManager:GetText("tips_equip_pos_11")
  elseif pos == "12" then
    text = gui.TextManager:GetText("tips_equip_pos_12")
  elseif pos == "13" then
    text = gui.TextManager:GetText("tips_equip_pos_19")
  elseif pos == "14" then
    text = gui.TextManager:GetText("tips_equip_pos_20")
  elseif pos == "15" then
    text = gui.TextManager:GetText("tips_equip_pos_21")
  elseif pos == "16" then
    text = gui.TextManager:GetText("tips_equip_pos_22")
  elseif pos == "17" then
    text = gui.TextManager:GetText("tips_equip_pos_23")
  elseif pos == "18" then
    text = gui.TextManager:GetText("tips_equip_pos_24")
  elseif pos == "19" then
    text = gui.TextManager:GetText("tips_equip_pos_25")
  elseif pos == "20" then
    text = gui.TextManager:GetText("tips_equip_pos_26")
  elseif pos == "21" then
    text = gui.TextManager:GetText("tips_equip_pos_27")
  elseif pos == "22" then
    text = gui.TextManager:GetText("tips_equip_pos_28")
  elseif pos == "23" then
    text = gui.TextManager:GetText("tips_equip_pos_29")
  end
  return text
end
function show_dialog_tip(view_id, view_index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_id))
  local gui = nx_value("gui")
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(view_index))
  if not nx_is_valid(viewobj) then
    return
  end
  local viewobj_name = gui.TextManager:GetText(viewobj:QueryProp("ConfigID"))
  gui.TextManager:Format_SetIDName("16526")
  gui.TextManager:Format_AddParam(viewobj_name)
  local text = gui.TextManager:Format_GetText()
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "onestep_equip")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  return dialog
end
function refresh_drawmousein(grid, index)
  local form = grid.ParentForm
  local item = get_item_by_gridindex(form, index)
  if nx_is_valid(item) then
    local item_type = item:QueryProp("ItemType")
    if nx_int(item_type) >= nx_int(ITEMTYPE_EQUIP_MIN) and nx_int(item_type) <= nx_int(ITEMTYPE_EQUIP_MAX) then
      local replace_pack = item:QueryProp("ReplacePack")
      if nx_int(replace_pack) > nx_int(0) then
        grid.DrawMouseIn = nx_string("")
        return
      end
    end
  end
  grid.DrawMouseIn = nx_string("xuanzekuang_on")
end
function del_grid_equip(index)
  local form = util_get_form(FORM_ONESTEP_EQUIP, false)
  if not nx_is_valid(form) then
    return
  end
  local i = form.equip_grid:GetBindIndex(index)
  local proj = get_real_projid(form.sel_index)
  local pos = i
  nx_execute("custom_sender", "custom_onestep_equip_msg_del", proj, pos)
end
function on_btn_setkey_click(btn)
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_shortcut_key", true, false)
  dialog:ShowModal()
  dialog.rbtn_column.Checked = true
end
function on_cbtn_showkey_checked_changed(self)
  if not nx_is_valid(self) then
    return
  end
  local show = false
  if self.Checked then
    show = true
  else
    show = false
  end
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_onestep", "show_shortcut_equip", show)
end
function on_cbtn_active_jingmai_checked_changed(self)
  if not nx_is_valid(self) then
    return
  end
  local game_config_info = nx_value("game_config_info")
  if nx_is_valid(game_config_info) then
    SetIniInfo("one_key_active_jingmai", nx_int(self.Checked))
    local CustomizingManager = nx_value("customizing_manager")
    if nx_is_valid(CustomizingManager) then
      CustomizingManager:SaveConfigToServer()
    end
  end
end
function on_rbtn_equip_checked_changed(btn)
  if btn.Checked == true then
    local form = btn.ParentForm
    if not nx_is_valid(form) then
      return
    end
    form.equip_grid.Left = 4
    form.groupbox_equip_bg.Visible = true
    form.groupbox_treasure_bg.Visible = false
    form.bg_main.BackImage = "gui\\special\\role\\bg_main.png"
    form.type_index = nx_number(btn.DataSource)
  end
end
function on_rbtn_treasure_checked_changed(btn)
  if btn.Checked == true then
    local form = btn.ParentForm
    if not nx_is_valid(form) then
      return
    end
    form.equip_grid.Left = -306
    form.groupbox_equip_bg.Visible = false
    form.groupbox_treasure_bg.Visible = true
    form.bg_main.BackImage = "gui\\special\\role\\bg_treasure.png"
    form.type_index = nx_number(btn.DataSource)
  end
end
function refresh_step(step)
  local form = nx_value(FORM_ONESTEP_EQUIP)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  client_player.jyz_step = step
  refresh_treasure_lock()
end
function refresh_treasure_lock()
  local form = nx_value(FORM_ONESTEP_EQUIP)
  if not nx_is_valid(form) then
    return
  end
  local step = 0
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_find_custom(client_player, "jyz_step") then
    step = 1
  else
    step = client_player.jyz_step
  end
  local treasure_num = 0
  local treasure_num_new = 0
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\RandomEquipRule\\BoxLevel.ini")
  if nx_is_valid(ini) then
    local table_flag = {
      "Treasure",
      "NewTreasure"
    }
    for j = 1, 2 do
      local sec_index = ini:FindSectionIndex(table_flag[j])
      if 0 <= sec_index then
        local GroupMsgData = ini:GetItemValueList(sec_index, nx_string("r"))
        for i = 1, nx_number(table.getn(GroupMsgData)) do
          local stepData = util_split_string(GroupMsgData[i], ",")
          if table.getn(stepData) == 3 and nx_int(stepData[1]) <= nx_int(step) and nx_int(step) <= nx_int(stepData[2]) then
            if j == 1 then
              treasure_num = nx_int(stepData[3])
            elseif j == 2 then
              treasure_num_new = nx_int(stepData[3])
            end
          end
        end
      end
    end
  end
  for i = 1, treasure_num + 1 do
    local label = form.groupbox_treasure_bg:Find("lbl_treasure_" .. nx_string(i))
    if nx_is_valid(label) then
      label.BackImage = "gui\\special\\role\\icon_treasure_null.png"
    end
  end
  for i = 1, treasure_num_new + 1 do
    i = i + 5
    local label = form.groupbox_treasure_bg:Find("lbl_treasure_" .. nx_string(i))
    if nx_is_valid(label) then
      label.BackImage = "gui\\special\\role\\icon_treasure_null.png"
    end
  end
  for i = treasure_num + 1, 5 do
    local label = form.groupbox_treasure_bg:Find("lbl_treasure_" .. nx_string(i))
    if nx_is_valid(label) then
      label.BackImage = "gui\\special\\role\\icon_treasure_lock.png"
    end
  end
  for i = treasure_num_new + 1, 5 do
    i = i + 5
    local label = form.groupbox_treasure_bg:Find("lbl_treasure_" .. nx_string(i))
    if nx_is_valid(label) then
      label.BackImage = "gui\\special\\role\\icon_treasure_lock.png"
    end
  end
  for i = 1, 10 do
    local label = form.groupbox_treasure_bg:Find("lbl_bg_treasure_" .. nx_string(i))
    if not nx_is_valid(label) then
      return
    end
    if form.equip_grid:IsEmpty(nx_int(i + TREASURESTARTPOS - 1)) then
      label.Visible = false
    else
      label.Visible = true
    end
  end
end
function get_real_projid(rbtn_index)
  local bIsNewJHModule = is_newjhmodule()
  if not bIsNewJHModule then
    return rbtn_index
  elseif rbtn_index == 0 then
    return CHANGE_NEW_ID_1
  elseif rbtn_index == 1 then
    return CHANGE_NEW_ID_2
  elseif rbtn_index == 2 then
    return CHANGE_NEW_ID_3
  elseif rbtn_index == 3 then
    return CHANGE_NEW_ID_4
  end
  return -1
end
