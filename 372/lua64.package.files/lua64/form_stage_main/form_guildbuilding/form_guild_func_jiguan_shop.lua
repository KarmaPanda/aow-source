require("util_gui")
require("custom_sender")
local buy_jiguan = 0
local show_jiguan = 1
local MAX_ROWS_PER_PAGE = 10
local BTN_COOL_DOWN_TIME = 1000
function form_jiguan_shop_Init(form)
  form.Fixed = false
  form.cur_page = 0
  form.npcid = nil
  form.jiguan_name = nil
  form.jiguan_photo = nil
end
function form_jiguan_shop_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.cur_page = 0
  form.lbl_1.Text = nx_widestr(gui.TextManager:GetText("ui_jiguan_title"))
  reset_grid(form)
  custom_guild_func_jiguan(show_jiguan, form.cur_page * MAX_ROWS_PER_PAGE, MAX_ROWS_PER_PAGE)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_guildbuilding\\form_guild_func_jiguan_shop")
end
function on_ImageControlGrid_select_changed(ImageControlGrid, index)
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_func_jiguan_trade_buy")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guildbuilding\\form_guild_func_jiguan_trade_buy", true, false)
    nx_set_value("form_stage_main\\form_guildbuilding\\form_guild_func_jiguan_trade_buy", form)
  end
  local formSelf = ImageControlGrid.ParentForm
  form.selectRow = index
  form:Show()
  form.Visible = true
  formSelf.Visible = false
end
function recv_show_data(...)
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_func_jiguan_shop")
  if not nx_is_valid(form) then
    return false
  end
  local gui = nx_value("gui")
  local size = table.getn(arg)
  if size < 3 then
    return false
  end
  local index = arg[1]
  local jiguan_configID = arg[2]
  local jiguan_level = arg[3]
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return false
  end
  if not ItemQuery:FindItemByConfigID(nx_string(jiguan_configID)) then
    return false
  end
  local photo = ItemQuery:GetItemPropByConfigID(nx_string(jiguan_configID), nx_string("Photo"))
  local jiguan_name = ItemQuery:GetItemPropByConfigID(nx_string(jiguan_configID), nx_string("Name"))
  form.ImageControlGrid:AddItem(index, nx_string(photo), nx_widestr(jiguan_name), nx_int(0), nx_int(0))
  form.ImageControlGrid:SetItemName(index, nx_widestr(jiguan_configID))
  form.ImageControlGrid:ShowItemAddInfo(index, 0, true)
  form.jiguan_name = jiguan_name
  form.jiguan_photo = photo
end
function reset_grid(form)
  form.ImageControlGrid:Clear()
end
