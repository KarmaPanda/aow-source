require("util_functions")
require("define\\gamehand_type")
require("util_gui")
require("share\\itemtype_define")
require("form_stage_main\\form_charge_shop\\charge_shop_define")
require("custom_sender")
require("share\\view_define")
local m_Path = "form_stage_main\\form_life\\form_npc_exchange"
local sortString = ""
local SelectNode = ""
function main_form_init(form)
  form.Fixed = false
  form.npc_id = ""
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2 - 40
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_NPCEXCHANGE, form.imagegrid_contribute, m_Path, "on_contribute_box_change")
  end
  form.imagegrid_contribute.typeid = VIEWPORT_NPCEXCHANGE
  for i = 1, 10 do
    form.imagegrid_contribute:SetBindIndex(nx_int(i - 1), nx_int(i))
  end
  fresh_form(form)
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form.imagegrid_contribute)
  end
  nx_destroy(form)
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  nx_execute("custom_sender", "custom_cancel_npc_exchange")
end
function on_main_form_visible(form)
  if form.Visible == false then
    form:Close()
  end
end
function fresh_form(form)
  if nx_string("") == nx_string(form.npc_id) then
    return
  end
  local exchange_ini = nx_execute("util_functions", "get_ini", "share\\Rule\\page_exchange.ini")
  if not nx_is_valid(exchange_ini) then
    return
  end
  local index = exchange_ini:FindSectionIndex(nx_string(form.npc_id))
  if index < 0 then
    return
  end
  local recives = exchange_ini:ReadString(index, "RecieveID", "")
  fresh_mltbox_desc_lost(form, recives)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.combobox_area.Text = nx_widestr("")
  form.combobox_area.DropListBox:ClearString()
  local default_area = ""
  for i = 1, 10 do
    local dropid = exchange_ini:ReadString(index, "DropID" .. nx_string(i), "")
    if "" == dropid then
      break
    end
    form.combobox_area.DropListBox:AddString(nx_widestr(gui.TextManager:GetText("desc_" .. nx_string(dropid) .. "_2")))
    if "" == default_area then
      default_area = gui.TextManager:GetText("desc_" .. nx_string(dropid) .. "_2")
    end
  end
  form.combobox_area.Text = nx_widestr(default_area)
  on_combobox_area_selected(form.combobox_area)
end
function fresh_mltbox_desc_lost(form, recives)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local text = nx_widestr("")
  local str_lst = util_split_string(recives, ",")
  for i = 1, table.getn(str_lst) do
    local book_name = nx_widestr(gui.TextManager:GetText(str_lst[i]))
    if nx_widestr("") == book_name then
      break
    end
    if nx_widestr("") == text then
      text = book_name
    else
      text = text .. nx_widestr(",") .. book_name
    end
  end
  form.mltbox_desc_lost.HtmlText = nx_widestr(text)
end
function fresh_mltbox_desc_get(form, text)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dropid, index = get_drop_id(form, text)
  if "" == dropid then
    return
  end
  form.mltbox_desc_get.HtmlText = nx_widestr(gui.TextManager:GetText("desc_" .. nx_string(dropid) .. "_1"))
end
function get_drop_id(form, str_name)
  local exchange_ini = nx_execute("util_functions", "get_ini", "share\\Rule\\page_exchange.ini")
  if not nx_is_valid(exchange_ini) then
    return "", 0
  end
  local index = exchange_ini:FindSectionIndex(nx_string(form.npc_id))
  if index < 0 then
    return "", 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return "", 0
  end
  local dropid = ""
  for i = 1, 10 do
    dropid = exchange_ini:ReadString(index, "DropID" .. nx_string(i), "")
    if "" == dropid then
      break
    end
    if nx_string(str_name) == nx_string(gui.TextManager:GetText("desc_" .. nx_string(dropid) .. "_2")) then
      return dropid, i
    end
  end
  return "", 0
end
function on_combobox_area_selected(self)
  local form = self.ParentForm
  fresh_mltbox_desc_get(form, nx_string(self.Text))
end
function on_contribute_box_change(grid, optype, view_ident, index)
  if not nx_is_valid(grid) then
    return 1
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local form = grid.ParentForm
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return 1
  end
  if optype == "createview" then
    GoodsGrid:GridClear(grid)
    GoodsGrid:ViewUpdateItem(grid, index)
  elseif optype == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "additem" or optype == "delitem" or optype == "updateitem" then
    local viewobj = view:GetViewObj(nx_string(index))
    ShowItem(form, view, viewobj, index)
  end
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) then
    nx_execute("form_stage_main\\form_bag", "refresh_lock_item", form_bag)
  end
  return 1
end
function ShowItem(form, view, viewobj, index)
  if not nx_is_valid(viewobj) then
    form.imagegrid_contribute:DelItem(index - 1)
  else
    local photo = nx_execute("util_static_data", "queryprop_by_object", viewobj, "Photo")
    form.imagegrid_contribute:AddItem(index - 1, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
  end
end
function on_npc_exchange_form_open(npc_id)
  local form = util_get_form(m_Path, true)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.npc_id = nx_string(npc_id)
  util_auto_show_hide_form(m_Path)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_btn_contribute_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local dropid, index = get_drop_id(form, nx_string(form.combobox_area.Text))
  if "" == dropid then
    form:Close()
  else
    nx_execute("custom_sender", "custom_start_npc_exchange", index)
  end
end
function on_btn_cancel_click(btn)
  nx_execute("custom_sender", "custom_cancel_npc_exchange")
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_imagegrid_contribute_rightclick_grid(grid, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_NPCEXCHANGE))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if nx_is_valid(viewobj) then
    nx_execute("custom_sender", "custom_remove_npc_exchange_item", index + 1)
  end
end
function on_imagegrid_contribute_select_changed(grid)
  local gui = nx_value("gui")
  local selected_index = grid:GetSelectItemIndex()
  if gui.GameHand:IsEmpty() then
    return
  end
  if not grid:IsEmpty(selected_index) then
    return
  end
  if gui.GameHand.Type == GHT_VIEWITEM then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local src_pos = nx_int(gui.GameHand.Para2)
    local amount = nx_int(gui.GameHand.Para3)
    nx_execute("custom_sender", "custom_add_npc_exchange_item", src_viewid, src_pos, selected_index + 1)
    gui.GameHand:ClearHand()
  end
end
function on_imagegrid_contribute_mousein_grid(grid, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_NPCEXCHANGE))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if nx_is_valid(viewobj) then
    viewobj.view_obj = viewobj
    nx_execute("tips_game", "show_goods_tip", viewobj, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
    return
  end
end
function on_imagegrid_contribute_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
