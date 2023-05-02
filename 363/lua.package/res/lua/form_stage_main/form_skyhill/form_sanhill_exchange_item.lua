require("util_gui")
require("util_functions")
require("util_static_data")
local FORM_NAME = "form_stage_main\\form_skyhill\\form_sanhill_exchange_item"
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
function show_exchange_item_subform(item_id, limit_info, single_point, need_point, condition_id, sub_type)
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    form:Close()
  end
  local gui = nx_value("gui")
  form = util_show_form(FORM_NAME, true)
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
    if nx_int(sub_type) == nx_int(1) then
      form.lbl_explian.Visible = true
      form.btn_ok.Text = gui.TextManager:GetText("ui_lzy_fyy_002")
    else
      form.lbl_explian.Visible = false
      form.btn_ok.Text = gui.TextManager:GetText("ui_ok")
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
    local SanHill_ClientMsg_Exchange = 14
    nx_execute("custom_sender", "custom_sanhill_msg", SanHill_ClientMsg_Exchange, item_id, item_count)
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
