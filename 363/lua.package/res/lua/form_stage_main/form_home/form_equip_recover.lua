require("share\\view_define")
require("define\\gamehand_type")
require("share\\client_custom_define")
require("util_functions")
require("util_gui")
local CLIENT_FURNITURE_ADD_RECOVER_EQUIP = 20
local CLIENT_FURNITURE_REMOVE_RECOVER_EQUIP = 21
local CLIENT_FURNITURE_START_RECOVER_EQUIP = 22
local CLIENT_FURNITURE_OPEN_RECOVER_EQUIP_FORM = 23
local CLIENT_FURNITURE_CLOSE_RECOVER_EQUIP_FORM = 24
local EQUIP_RECOVER_NORMAL = 0
local EQUIP_RECOVER_DAMAGED = 1
local EQUIP_RECOVER_BROKEN = 2
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = form.Width / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_EQUIP_RECOVER_BOX, form, nx_current(), "on_equip_recover_viewport_changed")
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function on_main_form_close(form)
  ui_destroy_attached_form(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form)
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), CLIENT_FURNITURE_CLOSE_RECOVER_EQUIP_FORM)
  end
  nx_destroy(form)
end
function on_equip_recover_viewport_changed(form, optype, view_ident, index)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return
  end
  if optype == "additem" then
    local viewobj = view:GetViewObj(nx_string(index))
    if not nx_is_valid(viewobj) then
      return
    end
    local photo = nx_execute("util_static_data", "queryprop_by_object", viewobj, "Photo")
    form.imagegrid_equip:AddItem(0, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
    local silver_value = get_equip_recover_cost(viewobj)
    local silver_photo = "<img src=\"gui\\common\\money\\yyb.png\" valign=\"center\" only=\"line\" data=\"\" />"
    local text_desc = nx_widestr(silver_photo) .. nx_widestr(price_to_text(silver_value))
    form.mltbox_1:Clear()
    form.mltbox_1:AddHtmlText(nx_widestr(text_desc), -1)
  elseif optype == "delitem" then
    form.imagegrid_equip:Clear()
    form.mltbox_1:Clear()
  end
end
function on_imagegrid_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not gui.GameHand:IsEmpty() and gui.GameHand.Type == GHT_VIEWITEM then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local src_pos = nx_int(gui.GameHand.Para2)
    local src_amount = nx_int(gui.GameHand.Para3)
    local game_client = nx_value("game_client")
    local view = game_client:GetView(nx_string(src_viewid))
    if not nx_is_valid(view) then
      return
    end
    local viewobj = view:GetViewObj(nx_string(src_pos))
    if not nx_is_valid(viewobj) then
      return
    end
    if not is_need_recover_equip(viewobj) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_drop_repair_nomatch"))
      return
    end
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), CLIENT_FURNITURE_ADD_RECOVER_EQUIP, nx_int(src_viewid), nx_int(src_pos), nx_int(index + 1))
    gui.GameHand:ClearHand()
  end
end
function on_imagegrid_rightclick_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), CLIENT_FURNITURE_REMOVE_RECOVER_EQUIP, nx_int(index + 1))
end
function on_imagegrid_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_EQUIP_RECOVER_BOX))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if nx_is_valid(viewobj) then
    nx_execute("tips_game", "show_goods_tip", viewobj, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, form)
  end
end
function on_imagegrid_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local tips_str = util_text("ui_equip_repair_confirm")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(tips_str))
  dialog:ShowModal()
  local gui = nx_value("gui")
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if nx_is_valid(game_visual) then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), CLIENT_FURNITURE_START_RECOVER_EQUIP)
    end
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function show_form()
  local form_recover = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form_recover) then
    return
  end
  form_recover.Visible = true
  form_recover:Show()
  nx_execute("util_gui", "ui_show_attached_form", form_recover)
end
function close_form()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function is_need_recover_equip(equip)
  if not nx_is_valid(equip) then
    return false
  end
  if not equip:FindProp("RecoverFlag") then
    return false
  end
  local recover_flag = equip:QueryProp("RecoverFlag")
  if nx_number(recover_flag) ~= nx_number(EQUIP_RECOVER_DAMAGED) then
    return false
  end
  return true
end
function get_equip_recover_cost(equip)
  if not nx_is_valid(equip) then
    return 0
  end
  local recover_cost_ini = nx_execute("util_functions", "get_ini", "share\\Rule\\JHrepair_cost.ini")
  if not nx_is_valid(recover_cost_ini) then
    return 0
  end
  local item_type = equip:QueryProp("ItemType")
  local level = equip:QueryProp("Level")
  local color_level = equip:QueryProp("ColorLevel")
  local sec_count = recover_cost_ini:GetSectionCount()
  for i = 0, sec_count - 1 do
    local tmp_item_type = recover_cost_ini:ReadInteger(i, "ItemType", 0)
    local tmp_level = recover_cost_ini:ReadInteger(i, "Level", 0)
    local tmp_color_level = recover_cost_ini:ReadInteger(i, "ColorLevel", 0)
    local tmp_cost = recover_cost_ini:ReadInteger(i, "Cost", 0)
    if nx_number(tmp_item_type) == nx_number(item_type) and nx_number(tmp_level) == nx_number(level) and nx_number(tmp_color_level) == nx_number(color_level) then
      return tmp_cost
    end
  end
  return 0
end
function price_to_text(price)
  local ding = math.floor(nx_number(price) / 1000000)
  local liang = math.floor(nx_number(price) % 1000000 / 1000)
  local wen = math.floor(nx_number(price) % 1000)
  local htmlTextYinZi = nx_widestr("")
  if 0 < ding then
    local text = util_text("ui_ding")
    local htmlText = nx_widestr(text)
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(nx_int(ding)) .. nx_widestr(htmlText)
  end
  if 0 < liang then
    local text = util_text("ui_liang")
    local htmlText = nx_widestr(text)
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(liang)) .. nx_widestr(htmlText)
  end
  if 0 < wen then
    local text = util_text("ui_wen")
    local htmlText = nx_widestr(text)
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(wen)) .. nx_widestr(htmlText)
  end
  if price == 0 then
    htmlTextYinZi = htmlTextYinZi .. nx_widestr("0")
  end
  return nx_widestr(htmlTextYinZi)
end
