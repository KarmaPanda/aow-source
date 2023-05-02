require("share\\view_define")
require("util_gui")
require("define\\gamehand_type")
require("game_object")
MAX_SEARCH_SHOW_COUNT = 12
SearchItemsRecord = {}
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  self.result_grid.beginindex = 1
  self.result_grid.endindex = 13
  self.result_grid.canselect = true
  self.result_grid.candestroy = false
  self.result_grid.cansplit = false
  self.result_grid.canlock = false
  self.result_grid.canarrange = false
  move_position(self)
  self.lbl_bj.Visible = false
  self.ani_loading.Visible = false
end
function on_main_form_close(self)
  nx_execute("tips_game", "hide_tip", self)
  nx_destroy(self)
  nx_set_value("form_stage_main\\form_stall\\form_stallsearch", nx_null())
end
function move_position(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_btn_close_click(self)
  local gui = nx_value("gui")
  if gui.GameHand:IsEmpty() then
    util_show_form("form_stage_main\\form_stall\\form_stallsearch", false)
    return 1
  end
  local gamehand_type = gui.GameHand.Type
  if gamehand_type == GHT_FUNC then
    local func = gui.GameHand.Para1
    if func == "search" then
      gui.GameHand:ClearHand()
    end
  end
  util_show_form("form_stage_main\\form_stall\\form_stallsearch", false)
  return 1
end
function on_ipt_key_enter(self)
  on_btn_search_click(self.Parent.btn_search)
end
function on_btn_search_click(self)
  nx_execute("form_stage_main\\form_stall\\form_stallsearch", "search_item_info", self.ParentForm)
end
function search_item_info(form)
  if not nx_is_valid(form) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) or nx_string(form.ipt_key.Text) == nx_string("") then
  else
    form.lbl_bj.Visible = true
    form.ani_loading.Visible = true
    form.ani_loading.PlayMode = 0
    SearchItemsRecord = ItemQuery:FindItemsByName(nx_widestr(form.ipt_key.Text))
    form.result_grid:Clear()
    local image_index = 0
    local nTracker = 0
    local nItemCount = table.getn(SearchItemsRecord)
    if nx_int(nItemCount) < nx_int(1) then
      return
    end
    for i = 1, nx_number(nItemCount) do
      local item_config = SearchItemsRecord[i]
      local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
      if bExist == true then
        local NpcType = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("NpcType"))
        if NpcType == nil or nx_string(NpcType) == nx_string("") then
          local Camp = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Camp"))
          if Camp == nil or nx_string(Camp) == nx_string("") then
            local item_image = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(item_config), "Photo")
            form.result_grid:AddItem(image_index, item_image, nx_widestr(item_config), 1, -1)
            image_index = image_index + 1
          end
        end
      end
      if i % 10 == 0 then
        nx_pause(0.1)
        if not nx_is_valid(form) then
          return
        end
      end
    end
    form.lbl_bj.Visible = false
    form.ani_loading.Visible = false
  end
end
function on_result_grid_select_changed(self, index)
  local gui = nx_value("gui")
  if self:IsEmpty(index) then
    return 1
  end
  if gui.GameHand:IsEmpty() then
    local photo = self:GetItemImage(index)
    gui.GameHand:SetHand(GHT_FUNC, photo, "search", nx_string(index), "", "")
  end
end
function on_result_grid_mousein_grid(self, index)
  local item_config = get_search_item_config(index)
  if not item_config then
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
  local prop_array = {}
  prop_array.ConfigID = nx_string(item_config)
  prop_array.ItemType = nx_int(item_type)
  if not nx_is_valid(self.Data) then
    self.Data = nx_create("ArrayList", nx_current())
  end
  self.Data:ClearChild()
  for prop, value in pairs(prop_array) do
    nx_set_custom(self.Data, prop, value)
  end
  nx_execute("tips_game", "show_goods_tip", self.Data, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), self.GridWidth, self.GridHeight, self.ParentForm)
end
function on_result_grid_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function get_search_item_config(index)
  local form = nx_value("form_stage_main\\form_stall\\form_stallsearch")
  if not nx_is_valid(form) then
    return
  end
  return nx_string(form.result_grid:GetItemName(index))
end
