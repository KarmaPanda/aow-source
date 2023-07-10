require("util_functions")
require("define\\gamehand_type")
require("util_static_data")
require("util_gui")
local log = function(str)
  str = nx_string(str)
  nx_function("ext_log_testor", str .. "\n")
end
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local form_item_exchange = nx_value("form_item_exchange")
  if nx_is_valid(form_item_exchange) then
    nx_destroy(form_item_exchange)
  end
  form_item_exchange = nx_create("form_item_exchange")
  if nx_is_valid(form_item_exchange) then
    nx_set_value("form_item_exchange", form_item_exchange)
  end
  nx_execute("util_gui", "ui_show_attached_form", self)
end
function on_main_form_close(self)
  local form_item_exchange = nx_value("form_item_exchange")
  if nx_is_valid(form_item_exchange) then
    nx_destroy(form_item_exchange)
  end
  ui_destroy_attached_form(self)
  nx_destroy(self)
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function on_btn_help_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function on_main_form_active(form)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", form)
end
function on_btn_duihuan_click(btn)
  local form = btn.ParentForm
  if form.imagegrid_hh:IsEmpty(0) then
    return
  end
  if form.imagegrid_cl:IsEmpty(0) then
    return
  end
  local form_item_exchange = nx_value("form_item_exchange")
  if not nx_is_valid(form_item_exchange) then
    return
  end
  local src_id = form.imagegrid_hh.DataSource
  local src_num = nx_number(form.fipt_1.Text)
  local dest_id = form.imagegrid_cl.DataSource
  local rate = form_item_exchange:GetExchangeRate(src_id, dest_id)
  local all = nx_number(src_num) * nx_number(rate)
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "huohuan_duihuan")
  if not nx_is_valid(dialog) then
    return
  end
  local text = util_format_string("huohuan_exchange_tips", src_id, src_num, dest_id, all)
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "huohuan_duihuan_confirm_return")
  if "ok" == res then
    nx_execute("custom_sender", "custom_item_exchange", src_id, src_num, dest_id)
  end
end
function on_imagegrid_hh_select_changed(grid, index)
  local form = grid.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form_item_exchange = nx_value("form_item_exchange")
  if not nx_is_valid(form_item_exchange) then
    return
  end
  local game_hand = gui.GameHand
  local configid = ""
  if game_hand.Type == GHT_VIEWITEM then
    local view_id = game_hand.Para1
    local view_ident = game_hand.Para2
    local item = get_view_item(view_id, view_ident)
    if not nx_is_valid(item) then
      return
    end
    configid = item:QueryProp("ConfigID")
    if not form_item_exchange:ItemCanExchange(configid) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("huohuan_exchange_cannot"))
      return
    end
    grid:Clear()
    local photo = nx_execute("util_static_data", "queryprop_by_object", item, "Photo")
    grid:AddItem(0, photo, "", 1, -1)
    grid.DataSource = configid
    game_hand:ClearHand()
    local GoodsGrid = nx_value("GoodsGrid")
    local item_num = GoodsGrid:GetItemCount(configid)
    form.fipt_1.Text = nx_widestr(1)
  end
  refresh_combobox(form, configid)
end
function on_imagegrid_hh_rightclick_grid(grid, index)
  grid:Clear()
  local form = grid.ParentForm
  form.imagegrid_cl:Clear()
  form.fipt_1.Text = nx_widestr("0")
  form.lbl_bili.Text = nx_widestr("")
  form.combobox_k.Text = nx_widestr("")
  form.combobox_k.DropListBox:ClearString()
  refresh_combobox(grid.ParentForm)
end
function on_imagegrid_hh_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    nx_execute("tips_game", "show_text_tip", util_text("huohuan_exchange_spend"), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 150, grid.ParentForm)
  end
end
function on_imagegrid_hh_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_combobox_k_selected(self)
  local form = self.ParentForm
  local form_item_exchange = nx_value("form_item_exchange")
  if not nx_is_valid(form_item_exchange) then
    return
  end
  local item_list = form_item_exchange:GetExchangeItem(form.imagegrid_hh.DataSource)
  local item_num = table.getn(item_list) / 2
  if item_num <= 0 then
    return
  end
  for i = 1, item_num do
    local id = nx_string(item_list[i * 2 - 1])
    local num = item_list[i * 2]
    local str = nx_string(util_text(id)) .. "x" .. nx_string(num)
    str = nx_widestr(str)
    if str == self.Text then
      refresh_imagegrid_cl(self.ParentForm, nx_string(id .. "x" .. num))
    end
  end
end
function on_imagegrid_cl_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    nx_execute("tips_game", "show_text_tip", util_text("huohuan_exchange_get"), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 150, grid.ParentForm)
    return
  end
  local configid = grid.DataSource
  nx_execute("tips_game", "show_tips_by_config", configid, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_imagegrid_cl_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_fipt_1_changed(ipt)
  local form = ipt.ParentForm
  local configid = form.imagegrid_hh.DataSource
  if form.imagegrid_hh:IsEmpty(0) then
    return
  end
  local cur_count = nx_int(ipt.Text)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local max_count = nx_int(GoodsGrid:GetItemCount(configid))
  if cur_count > max_count then
    ipt.Text = nx_widestr(max_count)
  end
end
function refresh_combobox(form, configid)
  configid = configid or ""
  local list = form.combobox_k.DropListBox
  list:ClearString()
  local form_item_exchange = nx_value("form_item_exchange")
  local item_list = form_item_exchange:GetExchangeItem(configid)
  local item_num = table.getn(item_list) / 2
  if item_num <= 0 then
    return
  end
  for i = 1, item_num do
    local id = nx_string(item_list[i * 2 - 1])
    local num = item_list[i * 2]
    local str = nx_string(util_text(id)) .. "x" .. nx_string(num)
    str = nx_widestr(str)
    list:AddString(str)
  end
  if 0 < list.ItemCount then
    local id = nx_string(item_list[1])
    local num = item_list[2]
    form.combobox_k.Text = nx_widestr(nx_string(util_text(id)) .. "x" .. nx_string(num))
    refresh_imagegrid_cl(form, nx_string(id .. "x" .. num))
  end
end
function refresh_imagegrid_cl(form, text)
  local grid = form.imagegrid_cl
  grid:Clear()
  form.lbl_bili.Text = nx_widestr("")
  local text_t = util_split_string(text, "x")
  if 2 ~= table.getn(text_t) then
    return
  end
  local configid = text_t[1]
  local photo = item_query_ArtPack_by_id(configid, "Photo")
  if "" ~= photo then
    grid:AddItem(0, photo, "", 1, -1)
    grid.DataSource = configid
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText("huohuan_exchange_ratio", nx_int(text_t[2]))
  form.lbl_bili.Text = nx_widestr(text)
end
function get_view_item(view_id, view_index)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nx_null()
  end
  return game_client:GetViewObj(nx_string(view_id), nx_string(view_index))
end
function clear()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
  end
end
