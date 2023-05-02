require("tips_data")
require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_match\\form_sanmeng_exchange"
function open_form()
  local form = util_get_form(FORM_NAME, true, true)
  if nx_is_valid(form) then
    form.Visible = true
    form:Show()
  end
end
function on_main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_exchange1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if nx_find_custom(form, "exchange_type") and form.exchange_type == "yuezhan" then
    game_visual:CustomSend(nx_int(223), 7, nx_int(form.sel_cfg_id))
  elseif nx_find_custom(form, "exchange_type") and form.exchange_type == "rtm" then
    game_visual:CustomSend(nx_int(236), 4, nx_int(form.sel_cfg_id))
  else
    game_visual:CustomSend(nx_int(1003), 6, nx_int(form.sel_cfg_id))
  end
  form.exchange_type = ""
  form:Close()
end
function show_exchange_item_info(item_id, item_index, need_desc)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) or form.Visible == false then
    return
  end
  form.exchange_type = ""
  form.sel_cfg_id = item_index
  form.imagegrid_tmp_pic.item_id = item_id
  local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", item_id, "Photo")
  form.imagegrid_tmp_pic:AddItem(0, nx_string(photo), nx_widestr(item_id), nx_int(item_count), 0)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.lbl_tmp_name.Text = nx_widestr(gui.TextManager:GetText(item_id))
  if need_desc ~= nil then
    form.lbl_tmp_score.Text = nx_widestr(need_desc)
  end
end
function on_imagegrid_tmp_pic_mousein_grid(self, index)
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  if nx_is_valid(item) then
    item.is_static = true
    item.ConfigID = nx_string(self.item_id)
    item.ItemType = get_ini_prop("share\\Item\\tool_item.ini", nx_string(self.item_id), "ItemType", "0")
    nx_execute("tips_game", "show_goods_tip", item, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), 40, 40, self.ParentForm)
  end
end
function on_imagegrid_tmp_pic_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function show_exchange_item_info_yuezhan(item_id, item_index, need_desc)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) or form.Visible == false then
    return
  end
  form.exchange_type = "yuezhan"
  form.sel_cfg_id = item_index
  form.imagegrid_tmp_pic.item_id = item_id
  local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", item_id, "Photo")
  form.imagegrid_tmp_pic:AddItem(0, nx_string(photo), nx_widestr(item_id), nx_int(item_count), 0)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.lbl_tmp_name.Text = nx_widestr(gui.TextManager:GetText(item_id))
  if need_desc ~= nil then
    form.lbl_tmp_score.Text = nx_widestr(need_desc)
  end
end
function show_exchange_item_info_rtm(item_id, item_index, need_desc)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) or form.Visible == false then
    return
  end
  form.exchange_type = "rtm"
  form.sel_cfg_id = item_index
  form.imagegrid_tmp_pic.item_id = item_id
  local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", item_id, "Photo")
  form.imagegrid_tmp_pic:AddItem(0, nx_string(photo), nx_widestr(item_id), nx_int(item_count), 0)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.lbl_tmp_name.Text = nx_widestr(gui.TextManager:GetText(item_id))
  if need_desc ~= nil then
    form.lbl_tmp_score.Text = nx_widestr(need_desc)
  end
end
