require("util_gui")
require("util_functions")
require("define\\gamehand_type")
require("share\\itemtype_define")
local SUB_CLIENT_OPEN_BOX = 10
local SUB_CLIENT_WEAR_WUJI = 11
local SUB_CLIENT_CLEAR_WUJI = 12
local GRID_EMPTY = 0
local GRID_LOCK = 1
local GRID_EQUIP = 2
local WUJI_NUM = 8
function main_form_init(form)
  form.Fixed = false
  return 1
end
function main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("cancel_rule_rec", form, nx_current(), "on_cancel_rule_rec_change")
    databinder:AddRolePropertyBind("WuJiPoint", "int", form, nx_current(), "on_WuJiPoint_change")
  end
  show_skill_data(form)
  hide_empty_pic(form)
  form.btn_ok.Enabled = false
end
function main_form_close(form)
  nx_destroy(form)
end
function on_main_form_shut(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("cancel_rule_rec", form)
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "hide_empty_pic", form)
  end
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_imagegrid_skill_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  gui.GameHand:ClearHand()
  if gui.GameHand:IsEmpty() then
    local photo = grid:GetItemImage(index)
    local name = nx_string(grid:GetItemName(index))
    gui.GameHand:SetHand(GHT_COMBO, photo, photo, name, "", "")
    gui.GameHand.IsDropped = false
    show_empty_pic(form)
  end
end
function on_imagegrid_skill_drag_enter(grid, index)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    local game_hand = gui.GameHand
    game_hand.IsDragged = false
    game_hand.IsDropped = false
  end
end
function on_imagegrid_skill_drag_move(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local gamehand = gui.GameHand
  if not gamehand.IsDragged then
    local photo = grid:GetItemImage(index)
    local name = nx_string(grid:GetItemName(index))
    gamehand.IsDragged = true
    gui.GameHand:SetHand(GHT_COMBO, photo, photo, name, "", "")
    show_empty_pic(form)
  end
end
function on_imagegrid_wuji_drop_in(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  if game_hand:IsEmpty() then
    return
  end
  if game_hand.Type ~= GHT_COMBO then
    return
  end
  local market = grid:GetItemMark(index)
  if nx_int(market) == nx_int(GRID_EQUIP) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_need_choose_reset_wuji"), 2)
    end
  end
  if nx_int(market) ~= nx_int(GRID_EMPTY) then
    return
  end
  local photo = nx_string(gui.GameHand.Para1)
  local name = nx_widestr(gui.GameHand.Para2)
  for i = 0, WUJI_NUM - 1 do
    if grid:GetItemName(i) == name then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_wuji_cant_equip_again"), 2)
      end
      return
    end
  end
  if not game_hand.IsDropped then
    grid:SetItemImage(nx_int(index), photo)
    grid:SetItemName(nx_int(index), name)
    gui.GameHand.IsDropped = true
    form.btn_ok.Enabled = true
    hide_empty_pic(form)
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "hide_empty_pic", form)
    end
  end
  gui.GameHand:ClearHand()
end
function on_imagegrid_wuji_right_click(self, index)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local imagegrid = form.imagegrid_wuji
  if nx_int(imagegrid:GetItemMark(index)) == nx_int(GRID_EQUIP) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_need_choose_reset_wuji"), 2)
    end
  end
  if nx_int(imagegrid:GetItemMark(index)) ~= nx_int(GRID_EMPTY) then
    return
  end
  if nx_ws_length(nx_widestr(imagegrid:GetItemName(index))) > 0 then
    imagegrid:SetItemImage(nx_int(index), "")
    imagegrid:SetItemName(nx_int(index), nx_widestr(""))
  end
  form.btn_ok.Enabled = false
  for i = 0, WUJI_NUM - 1 do
    if nx_int(imagegrid:GetItemMark(i)) == nx_int(GRID_EMPTY) and nx_string(imagegrid:GetItemName(i)) ~= "" then
      form.btn_ok.Enabled = true
      return
    end
  end
end
function on_imagegrid_wuji_select_changed(grid, index)
  if nx_int(index) < nx_int(0) or nx_int(index) > nx_int(WUJI_NUM - 1) then
    return
  end
  local market = grid:GetItemMark(index)
  if nx_int(market) ~= nx_int(GRID_LOCK) then
    return
  end
  local gui = nx_value("gui")
  if not gui.GameHand:IsEmpty() then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local rows = client_player:GetRecordRows("cancel_rule_rec")
  if nx_int(index) ~= nx_int(rows) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Skill\\JingMai\\wuji.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("wujibox_need")
  if sec_index < 0 then
    return
  end
  local need = ini:ReadInteger(sec_index, nx_string(index + 1), 0)
  local wuji_point = client_player:QueryProp("WuJiPoint")
  if nx_int(wuji_point) < nx_int(need) then
    local gui = nx_value("gui")
    local txt = gui.TextManager:GetFormatText("ui_wuji_point_not_enough", nx_int(need))
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(txt, 2)
    end
    return
  end
  local gui = nx_value("gui")
  local ask_dialog = util_get_form("form_common\\form_confirm", true, false)
  ask_dialog.Left = (gui.Width - ask_dialog.Width) / 2
  ask_dialog.Top = (gui.Height - ask_dialog.Height) / 2
  local text = nx_widestr(util_text("ui_jingmai_wuji_open"))
  nx_execute("form_common\\form_confirm", "show_common_text", ask_dialog, text)
  ask_dialog:ShowModal()
  local res = nx_wait_event(100000000, ask_dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_jingmai_wuji_msg", SUB_CLIENT_OPEN_BOX, nx_int(index))
  end
end
function on_btn_reset_click(self)
  local gui = nx_value("gui")
  local ask_dialog = util_get_form("form_common\\form_confirm", true, false)
  ask_dialog.Left = (gui.Width - ask_dialog.Width) / 2
  ask_dialog.Top = (gui.Height - ask_dialog.Height) / 2
  local text = nx_widestr(util_text("ui_clear_jingmai_wuji"))
  nx_execute("form_common\\form_confirm", "show_common_text", ask_dialog, text)
  ask_dialog:ShowModal()
  local res = nx_wait_event(100000000, ask_dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_jingmai_wuji_msg", SUB_CLIENT_CLEAR_WUJI, nx_int(index))
  end
end
function on_btn_ok_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  for i = 0, WUJI_NUM - 1 do
    local market = nx_int(form.imagegrid_wuji:GetItemMark(i))
    local name = nx_string(form.imagegrid_wuji:GetItemName(i))
    if market == nx_int(GRID_EMPTY) and name ~= "" then
      nx_execute("custom_sender", "custom_jingmai_wuji_msg", SUB_CLIENT_WEAR_WUJI, nx_string(name), nx_int(i))
    end
  end
  self.Enabled = false
end
function on_imagegrid_skill_mousein_grid(grid, index)
  show_wuji_tips(grid, index)
end
function on_imagegrid_skill_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_wuji_mousein_grid(grid, index)
  local market = grid:GetItemMark(index)
  if nx_int(market) == nx_int(GRID_EMPTY) then
    if nx_ws_length(nx_widestr(grid:GetItemName(index))) > 0 then
      show_wuji_tips(grid, index)
    else
      nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("tips_wuji_empty")), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop())
    end
  elseif nx_int(market) == nx_int(GRID_LOCK) then
    local ini = nx_execute("util_functions", "get_ini", "share\\Skill\\JingMai\\wuji.ini")
    if not nx_is_valid(ini) then
      return
    end
    local sec_index = ini:FindSectionIndex("wujibox_need")
    if sec_index < 0 then
      return
    end
    local need = ini:ReadInteger(sec_index, nx_string(index + 1), 0)
    local gui = nx_value("gui")
    local txt = gui.TextManager:GetFormatText("tips_wuji_unlock_need", nx_int(need))
    nx_execute("tips_game", "show_text_tip", nx_widestr(txt), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop())
  elseif nx_int(market) == nx_int(GRID_EQUIP) then
    show_wuji_tips(grid, index)
  end
end
function on_imagegrid_wuji_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_cancel_rule_rec_change(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local rows = client_player:GetRecordRows("cancel_rule_rec")
  form.btn_reset.Enabled = false
  for i = 0, WUJI_NUM - 1 do
    if nx_int(i) < nx_int(rows) then
      local skill_name = client_player:QueryRecord("cancel_rule_rec", i, 0)
      if skill_name ~= "null" and skill_name ~= "" and skill_name ~= nil then
        local ini = nx_execute("util_functions", "get_ini", "share\\Skill\\JingMai\\wuji.ini")
        if not nx_is_valid(ini) then
          return
        end
        local sec_index = ini:FindSectionIndex("combo")
        if sec_index < 0 then
          return
        end
        local photo = ini:ReadString(sec_index, skill_name, "")
        form.imagegrid_wuji:AddItem(i, photo, nx_widestr(skill_name), 1, nx_int(GRID_EQUIP))
        form.imagegrid_wuji:ChangeItemImageToBW(i, false)
        form.imagegrid_wuji:SetItemBackImage(i, "gui\\special\\wuxue\\g2.png")
        form.imagegrid_wuji:SetItemCoverImage(i, "gui\\special\\wuxue\\button\\jiao2.png")
        form.imagegrid_wuji:CoverItem(i, true)
        form.btn_reset.Enabled = true
      else
        form.imagegrid_wuji:AddItem(i, " ", nx_widestr(""), 1, nx_int(GRID_EMPTY))
        form.imagegrid_wuji:ChangeItemImageToBW(i, true)
        form.imagegrid_wuji:SetItemBackImage(i, "gui\\special\\wuxue\\g2.png")
        form.imagegrid_wuji:SetItemCoverImage(i, "gui\\special\\wuxue\\button\\jiao1.png")
        form.imagegrid_wuji:CoverItem(i, true)
      end
    else
      form.imagegrid_wuji:AddItem(i, " ", nx_widestr(""), 1, nx_int(GRID_LOCK))
      form.imagegrid_wuji:ChangeItemImageToBW(i, false)
      form.imagegrid_wuji:SetItemBackImage(i, "gui\\special\\wuxue\\g1.png")
    end
  end
end
function on_WuJiPoint_change(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local wuji_point = client_player:QueryProp("WuJiPoint")
  form.lbl_wuji_point.Text = nx_widestr(wuji_point)
end
function show_skill_data(form)
  local gui = nx_value("gui")
  local ini = nx_execute("util_functions", "get_ini", "share\\Skill\\JingMai\\wuji.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("combo")
  if sec_index < 0 then
    return
  end
  local level_count = ini:GetSectionItemCount(sec_index)
  for i = 0, level_count - 1 do
    local key = ini:GetSectionItemKey(sec_index, i)
    local value = ini:GetSectionItemValue(sec_index, i)
    form.imagegrid_skill:AddItem(i, nx_string(value), nx_widestr(key), 1, -1)
  end
end
function show_empty_pic(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 0, WUJI_NUM - 1 do
    local pic = form:Find("lbl_empty_" .. nx_string(i))
    if nx_is_valid(pic) then
      local mark = form.imagegrid_wuji:GetItemMark(i)
      if nx_int(mark) == nx_int(GRID_EMPTY) then
        pic.Visible = true
      else
        pic.Visible = false
      end
    end
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(3000, 1, nx_current(), "hide_empty_pic", form, -1, -1)
  end
end
function hide_empty_pic(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 0, WUJI_NUM - 1 do
    local pic = form:Find("lbl_empty_" .. nx_string(i))
    if nx_is_valid(pic) then
      pic.Visible = false
    end
  end
end
function show_wuji_tips(grid, index)
  if not nx_is_valid(grid) then
    return
  end
  local name = grid:GetItemName(index)
  if name == nil or nx_string(name) == "" then
    return
  end
  local item_data = nx_call("util_gui", "get_arraylist", "wuji_list")
  item_data.ConfigID = nx_string(name)
  item_data.ItemType = nx_int(ITEMTYPE_WUJI)
  nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
