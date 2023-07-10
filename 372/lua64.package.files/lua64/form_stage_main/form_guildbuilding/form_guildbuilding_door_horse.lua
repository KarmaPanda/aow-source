require("goods_grid")
require("share\\view_define")
require("define\\tip_define")
require("tips_func_equip")
require("util_functions")
local CLIENT_CUSTOMMSG_GUILDBUILDING = 1016
local CLIENT_SUBMSG_GET_HORSE_CARD = 146
local ConfigID = "MOUNT_6_009_b"
function main_form_init(form)
  form.Fixed = false
  form.npc_id = ""
  form.max_number = 0
  form.remain_number = 0
end
function on_main_form_open(form)
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    local item_data = nx_create("ArrayList", nx_current())
    item_data.ConfigID = ConfigID
    item_data.Count = 1
    item_data.item_type = get_prop_in_ItemQuery(ConfigID, nx_string("ItemType"))
    GoodsGrid:GridAddItem(form.form_goods, 0, item_data)
    form.form_goods:SetBindIndex(0, 1)
  end
  form.lbl_num_info.Text = nx_widestr(form.remain_number) .. nx_widestr("/") .. nx_widestr(form.max_number)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.Parent.Parent
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_take_card_click(btn)
  local form = btn.Parent.Parent
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_GET_HORSE_CARD), form.npc_id)
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.Parent.Parent
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_form_shop_goods_mousein_grid(self, index)
  if self:IsEmpty(index) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    local viewobj = GoodsGrid:GetItemData(self, index)
    viewobj.Amount = viewobj.Count
    viewobj.MaxAmount = viewobj.Count
    nx_execute("tips_game", "show_goods_tip", viewobj, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), 32, 32, self.ParentForm)
  end
end
function on_form_shop_goods_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
