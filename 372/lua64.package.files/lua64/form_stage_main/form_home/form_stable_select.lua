require("util_functions")
require("util_gui")
local FORM_STABLE = "form_stage_main\\form_home\\form_stable"
local FORM_STABLE_SELECT = "form_stage_main\\form_home\\form_stable_select"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.building_id = nil
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  close_form()
end
function on_btn_card_click(btn)
  local card_id = btn.card_id
  local form = btn.ParentForm
  local index = form.index
  nx_execute(FORM_STABLE, "set_horse", index, card_id)
  close_form()
end
function open_form(index)
  local form = nx_execute("util_gui", "util_get_form", FORM_STABLE_SELECT, true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  form.index = index
  local card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(card_manager) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local card_list = card_manager:GetCardActivedListByType(3)
  form.gsb_card.IsEditMode = true
  form.gsb_card:DeleteAll()
  for i = 1, table.getn(card_list) do
    local card_id = card_list[i]
    if not nx_execute(FORM_STABLE, "check_card_id_in", card_id) then
      local fix_id = nx_int(10000) + nx_int(card_id)
      local config_id = "card_item_" .. nx_string(fix_id)
      local item_name = ItemQuery:GetItemPropByConfigID(nx_string(config_id), nx_string("Name"))
      local gb_card = create_ctrl("GroupBox", "groupbox_card_" .. nx_string(card_id), form.gb_model, form.gsb_card)
      if nx_is_valid(gb_card) then
        gb_card.card_id = nx_int(card_id)
        local btn = create_ctrl("Button", "btn_card_" .. nx_string(card_id), form.btn_card, gb_card)
        nx_bind_script(btn, nx_current())
        nx_callback(btn, "on_click", "on_btn_card_click")
        btn.card_id = nx_int(card_id)
        btn.Text = nx_widestr(item_name)
        gb_card.Left = 0
        gb_card.Top = gb_card.Height * (i - 1)
      end
    end
  end
  form.gsb_card.IsEditMode = false
  form.gsb_card:ResetChildrenYPos()
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_STABLE_SELECT, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  ctrl.Name = name
  return ctrl
end
