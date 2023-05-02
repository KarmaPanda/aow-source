require("share\\capital_define")
require("util_functions")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  form.groupbox_1.Visible = false
  form.Width = 490
  local gui = nx_value("gui")
  form.mltbox_1:Clear()
  form.mltbox_1:AddHtmlText(gui.TextManager:GetText("ui_oldserver_redeem"), -1)
  form.mltbox_2:Clear()
  form.mltbox_2:AddHtmlText(gui.TextManager:GetText("ui_power_redeem_1"), -1)
  form.mltbox_3:Clear()
  form.mltbox_3:AddHtmlText(gui.TextManager:GetText("ui_oldserver_redeem_1"), -1)
  init_imagegrid(form.imagegrid_1)
end
local itmes_table = {
  [0] = "additem_0020_4",
  [1] = "zhenqi_activity_001_3",
  [2] = "faculty_event_02_3",
  [3] = "box_redeem_menpaipaizi"
}
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_buy_click(self)
  local form = self.ParentForm
  local max_num = form.mltbox_num.num
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_shop\\form_trade_buy", true, false)
  local gui = nx_value("gui")
  dialog.Left = (gui.Desktop.Width - dialog.Width) / 2
  dialog.Top = (gui.Desktop.Height - dialog.Height) / 2
  dialog:ShowModal()
  nx_execute("form_stage_main\\form_shop\\form_trade_buy", "init_buy_form", dialog, CAPITAL_TYPE_GOLDEN, 1, max_num)
  local res, count, paymodel = nx_wait_event(100000000, dialog, "form_retail_return")
  if res == "ok" then
    if count < 0 or max_num < count then
      return
    end
    nx_execute("custom_sender", "custom_old_redeem", count)
  end
end
function on_imagegrid_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  if 3 < index then
    return
  end
  local ConfigID = itmes_table[index]
  nx_execute("tips_game", "show_tips_by_config", ConfigID, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function init_imagegrid(grid)
  local ItemsQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemsQuery) then
    return
  end
  grid:Clear()
  local photo = ItemsQuery:GetItemPropByConfigID("additem_0020_4", "Photo")
  grid:AddItem(0, photo, util_text("additem_0020_4"), 1, -1)
  photo = ItemsQuery:GetItemPropByConfigID("zhenqi_activity_001_3", "Photo")
  grid:AddItem(1, photo, util_text("zhenqi_activity_001_3"), 25, -1)
  photo = ItemsQuery:GetItemPropByConfigID("faculty_event_02_3", "Photo")
  grid:AddItem(2, photo, util_text("faculty_event_02_3"), 10, -1)
  photo = ItemsQuery:GetItemPropByConfigID("box_redeem_menpaipaizi", "Photo")
  grid:AddItem(3, photo, util_text("box_redeem_menpaipaizi"), 1, -1)
end
function open_form(num)
  if update_num(num) then
    return true
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_activity\\form_activity_oldserver_redeem", true, false)
  if not nx_is_valid(form) then
    return false
  end
  local gui = nx_value("gui")
  form.Left = (gui.Desktop.Width - form.Width) / 2
  form.Top = (gui.Desktop.Height - form.Height) / 2
  if num <= 0 then
    form.btn_buy.Enabled = false
  else
    form.btn_buy.Enabled = true
  end
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_power_redeem_5")
  gui.TextManager:Format_AddParam(nx_int(num))
  form.mltbox_num:Clear()
  form.mltbox_num:AddHtmlText(gui.TextManager:Format_GetText(), -1)
  form.mltbox_num.num = num
  form:Show()
  return true
end
function update_num(num)
  local form = nx_value("form_stage_main\\form_activity\\form_activity_oldserver_redeem")
  if nx_is_valid(form) and form.Visible then
    if num <= 0 then
      form.btn_buy.Enabled = false
    else
      form.btn_buy.Enabled = true
    end
    local gui = nx_value("gui")
    gui.TextManager:Format_SetIDName("ui_power_redeem_5")
    gui.TextManager:Format_AddParam(nx_int(num))
    form.mltbox_num:Clear()
    form.mltbox_num:AddHtmlText(gui.TextManager:Format_GetText(), -1)
    form.mltbox_num.num = num
    return true
  else
    return false
  end
end
function on_btn_desc_click(self)
  local form = self.ParentForm
  form.groupbox_1.Visible = true
  form.Width = 789
end
function on_btn_hide_groupbox_click(self)
  local form = self.ParentForm
  form.Width = 490
  form.groupbox_1.Visible = false
end
