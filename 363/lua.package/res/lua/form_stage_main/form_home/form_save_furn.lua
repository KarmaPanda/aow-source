require("util_functions")
require("util_gui")
require("define\\gamehand_type")
require("share\\itemtype_define")
require("share\\client_custom_define")
local g_NonePhoto = "gui\\common\\imagegrid\\icon_item_tiancheng.png"
local G_SIZE_PHOTO = {
  [1] = "gui\\special\\home\\jiaju\\1.png",
  [2] = "gui\\special\\home\\jiaju\\2.png",
  [3] = "gui\\special\\home\\jiaju\\3.png",
  [4] = "gui\\special\\home\\jiaju\\4.png",
  [5] = "gui\\special\\home\\jiaju\\5.png",
  [6] = "gui\\special\\home\\jiaju\\6.png"
}
function tc(aaa, bbb, ccc, ddd)
  nx_msgbox(nx_string(aaa) .. "/" .. nx_string(bbb) .. "/" .. nx_string(ccc) .. "/" .. nx_string(ddd))
end
function on_main_form_init(self)
  self.Fixed = false
  self.LimitInScreen = true
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    self:Close()
  end
  self.AbsLeft = self.Width / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  gui.Desktop:ToFront(self)
  init_form(self)
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function open_form(...)
  if not CanOperation() then
    return
  end
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
  end
  form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  fresh_form(unpack(arg))
end
function fresh_form(...)
  if not CanOperation() then
    return
  end
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local grid = form.ImageControlGrid_type
  local count = grid.RowNum * grid.ClomnNum
  for i = 0, table.getn(arg), 3 do
    if i >= table.getn(arg) then
      break
    end
    local index = nx_number(arg[i + 1])
    if index < 0 or count <= index then
      break
    end
    local configid = nx_string(arg[i + 2])
    local size = nx_number(arg[i + 3])
    grid:DelItem(index)
    grid:CoverItem(index, false)
    local photo = g_NonePhoto
    if G_SIZE_PHOTO[size] ~= nil then
      photo = nx_string(G_SIZE_PHOTO[size])
    end
    if configid ~= "" then
      photo = nx_string(ItemQuery:GetItemPropByConfigID(configid, "Photo"))
    end
    grid:AddItem(index, photo, nx_widestr(configid), 0, -1)
    if 0 > grid:GetSelectItemIndex() then
      grid:SetSelectItemIndex(index)
    end
    grid:ShowItemAddInfo(index, nx_int(0), false)
  end
end
function init_form(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.ImageControlGrid_type
  grid:Clear()
  local count = grid.RowNum * grid.ClomnNum
  for i = 0, count - 1 do
    grid:CoverItem(i, true)
  end
end
function close_form()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_ImageControlGrid_type_rightclick_grid(grid, index)
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == "" then
    return
  end
  nx_execute("custom_sender", "custom_home_furn", 7, index)
end
function on_ImageControlGrid_type_select_changed(grid, index)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if grid:IsEmpty(index) then
    return
  end
  if gui.GameHand:IsEmpty() then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) ~= "" then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "home_item_failed_02")
    return
  end
  if gui.GameHand.Type == GHT_VIEWITEM then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local src_pos = nx_int(gui.GameHand.Para2)
    local amount = nx_int(gui.GameHand.Para3)
    nx_execute("custom_sender", "custom_home_furn", 6, index, src_viewid, src_pos)
    gui.GameHand:ClearHand()
  end
end
function on_ImageControlGrid_type_mousein_grid(grid, index)
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == "" then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(item_config)
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_ImageControlGrid_type_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function CanOperation()
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return false
  end
  return HomeManager:IsMyHome()
end
