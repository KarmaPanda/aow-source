require("util_gui")
require("util_functions")
require("util_static_data")
local FORM_DUAL_PLAY_EXCHANGE = "form_stage_main\\form_tiguan\\form_tiguan_dual_play_exchange"
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function show_exchange_item_subform(item_id, limit_info, single_point, need_point, condition_id)
  local form = nx_value(FORM_DUAL_PLAY_EXCHANGE)
  if nx_is_valid(form) then
    form:Close()
  end
  form = util_show_form(FORM_DUAL_PLAY_EXCHANGE, true)
  if nx_is_valid(form) then
    form.item_id = nx_string(item_id)
    form.lbl_itemid.Text = util_text(nx_string(item_id))
    form.lbl_6.Text = nx_widestr(limit_info)
    photo = item_query_ArtPack_by_id(nx_string(item_id), "Photo")
    form.lbl_image.BackImage = photo
    form.single_point = single_point
    form.need_point = need_point
    form.condition_id = condition_id
    local MaxAmount = get_prop(nx_string(item_id), "MaxAmount")
    if MaxAmount == nil or nx_int(MaxAmount) <= nx_int(0) then
      form.MaxAmount = nx_int(1)
    else
      form.MaxAmount = nx_int(MaxAmount)
    end
  end
end
function on_lbl_item_get_capture(lbl)
  local form = lbl.ParentForm
  if not nx_find_custom(form, "item_id") then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local item_id = nx_string(form.item_id)
  if item_id == "" then
    return
  end
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_tips_by_config", item_id, x, y, form)
end
function on_lbl_item_lost_capture(lbl)
  local form = lbl.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_find_custom(form, "item_id") then
    return
  end
  local item_count = nx_int(form.name_edit.Text)
  local item_id = nx_string(form.item_id)
  if item_count > nx_int(0) and item_id ~= "" then
    if nx_int(item_count) > nx_int(form.MaxAmount) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_format_string("ui_tiguan_dual_play_38", nx_int(form.MaxAmount)), 2)
      end
      form:Close()
      return
    end
    if nx_find_custom(form, "single_point") and nx_find_custom(form, "need_point") and nx_int(form.single_point) < nx_int(form.need_point * item_count) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_guj_srltzbs_030"), 2)
      end
      form:Close()
      return
    end
    local CLIENT_MSG_DP_REQUEST_EXCHANGE = 5
    nx_execute("custom_sender", "custom_tiguan_dual_play", CLIENT_MSG_DP_REQUEST_EXCHANGE, item_id, item_count)
  end
  form:Close()
end
function on_name_edit_changed(ipt)
  if nx_int(ipt.Text) <= nx_int(0) then
    ipt.Text = nx_widestr(1)
  end
  if nx_int(ipt.Text) > nx_int(ipt.Max) then
    ipt.Text = nx_widestr(ipt.Max)
  end
end
function get_prop(id, prop)
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return nil
  end
  local value = item_query:GetItemPropByConfigID(id, prop)
  if value ~= nil and value ~= "" then
    return value
  end
  return nil
end
