require("share\\view_define")
require("define\\gamehand_type")
require("util_gui")
require("custom_sender")
require("util_functions")
require("role_composite")
require("util_static_data")
require("share\\logicstate_define")
require("share\\view_define")
MAX_TRAIN_PAT_NUM = 6
function main_form_init(form)
  form.Fixed = true
  return 1
end
function on_main_form_open(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_TRAINPAT_ITEM_BOX, form.imagegrid_trainpat, nx_current(), "on_item_change")
  end
  on_item_change(form.imagegrid_trainpat, 0, VIEWPORT_TRAINPAT_ITEM_BOX, 0)
  form.btn_put_bag.Enable = true
  form.btn_put_bag.Visible = true
  form.btn_call.Visible = false
  form.btn_take_back.Visible = false
  form.btn_cure.Visible = false
  form.ipt_selffoodname.Visible = false
  form.lbl_name_state.Visible = false
  form.chose_item_index = -1
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    local databinder = nx_value("data_binder")
    if nx_is_valid(form) then
      databinder:DelViewBind(form.imagegrid_trainpat)
    end
    form.chose_item_index = -1
    nx_destroy(form)
  end
end
function on_item_change(grid, optype, view_ident, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TRAINPAT_ITEM_BOX))
  if not nx_is_valid(view) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  for count = MAX_TRAIN_PAT_NUM, 1, -1 do
    grid:DelItem(nx_int(count - 1))
    if nx_is_valid(grid.Data) then
      grid.Data:RemoveChild(nx_string(count - 1))
    end
    local viewobj = view:GetViewObj(nx_string(count))
    if nx_is_valid(viewobj) then
      grid:SetBindIndex(nx_int(count - 1), nx_int(count))
      local prop_table = {}
      local proplist = viewobj:GetPropList()
      for i, prop in pairs(proplist) do
        prop_table[prop] = viewobj:QueryProp(prop)
      end
      local item_data = nx_create("ArrayList", nx_current())
      for prop, value in pairs(prop_table) do
        nx_set_custom(item_data, prop, value)
      end
      GoodsGrid:GridAddItem(grid, count - 1, item_data)
    end
  end
end
function refresh_form(form)
  form.groupbox_right.Visible = false
  form.btn_put_bag.Enable = true
  form.btn_put_bag.Visible = true
  form.btn_call.Visible = false
  form.btn_take_back.Visible = false
  form.btn_cure.Visible = false
  form.ipt_selffoodname.Visible = false
  form.lbl_trainpat_name.Text = ""
  form.chose_item_index = -1
  form.groupbox_top.Visible = false
  form.btn_1.Visible = false
  refresh_pat_shuxing(form)
  form.scenebox_show_trainpat.Visible = true
  if nx_is_valid(form.scenebox_show_trainpat.Scene) then
    nx_execute("util_gui", "ui_ClearModel", form.scenebox_show_trainpat)
  end
end
function on_trainpat_mousein_grid(grid, index)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local item_data = GoodsGrid:GetItemData(grid, index)
  if not nx_is_valid(item_data) then
    return
  end
  nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_trainpat_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_put_bag_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if -1 == form.chose_item_index then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TRAINPAT_ITEM_BOX))
  if not nx_is_valid(view) then
    return
  end
  local item_select = view:GetViewObj(nx_string(form.chose_item_index))
  if not nx_is_valid(item_select) then
    return
  end
  local cell_state = item_select:QueryProp("Cell_State")
  if 1 == cell_state then
    return
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TRAINPAT_PUTBACK), nx_int(form.chose_item_index))
  end
  if nx_is_valid(form.scenebox_show_trainpat.Scene) then
    nx_execute("util_gui", "ui_ClearModel", form.scenebox_show_trainpat)
  end
  form.lbl_trainpat_name.Text = nx_string("")
end
function on_btn_call_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if -1 == form.chose_item_index then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TRAINPAT_ITEM_BOX))
  if not nx_is_valid(view) then
    return
  end
  local item_select = view:GetViewObj(nx_string(form.chose_item_index))
  if not nx_is_valid(item_select) then
    return
  end
  local cell_state = item_select:QueryProp("Cell_State")
  if 1 == cell_state then
    return
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TRAINPAT_CELLPAT), nx_int(form.chose_item_index), 1)
  end
end
function on_btn_take_back_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if -1 == form.chose_item_index then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TRAINPAT_ITEM_BOX))
  if not nx_is_valid(view) then
    return
  end
  local item_select = view:GetViewObj(nx_string(form.chose_item_index))
  if not nx_is_valid(item_select) then
    return
  end
  local cell_state = item_select:QueryProp("Cell_State")
  if 0 == cell_state then
    return
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TRAINPAT_CELLPAT), nx_int(form.chose_item_index), 0)
  end
end
function on_btn_arrage_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_arrange_item", nx_int(VIEWPORT_TRAINPAT_ITEM_BOX), 1, 1024)
end
function on_btn_cure_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if -1 == form.chose_item_index then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TRAINPAT_ITEM_BOX))
  if not nx_is_valid(view) then
    return
  end
  local item_select = view:GetViewObj(nx_string(form.chose_item_index))
  if not nx_is_valid(item_select) then
    return
  end
  local cure_state = item_select:QueryProp("TrainPat_Dead")
  if 0 == cure_state then
    return
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TRAINPAT_CELLPAT), nx_int(form.chose_item_index), 2)
  end
end
function on_trainpat_select_changed(grid, index)
  on_trainpat_right_click(grid, index)
end
function on_trainpat_right_click(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.btn_call.Visible = false
  form.btn_take_back.Visible = false
  form.btn_cure.Visible = false
  local itembind_index = grid:GetBindIndex(index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TRAINPAT_ITEM_BOX))
  if not nx_is_valid(view) then
    return
  end
  local item_select = view:GetViewObj(nx_string(itembind_index))
  if not nx_is_valid(item_select) then
    return
  end
  form.chose_item_index = itembind_index
  local cure_state = item_select:QueryProp("TrainPat_Dead")
  if 0 == cure_state then
    local cell_state = item_select:QueryProp("Cell_State")
    if 0 == cell_state then
      form.btn_call.Visible = true
    else
      form.btn_take_back.Visible = true
    end
  else
    form.btn_cure.Visible = true
  end
  local item_name = item_select:QueryProp("train_cellnpc")
  if nx_string("") ~= nx_string(item_name) then
    local name = nx_widestr(util_text(nx_string(item_name)))
    form.lbl_trainpat_name.Text = nx_widestr(name)
  end
  show_trainpat_model(grid, item_name)
  refresh_pat_shuxing(form)
  local self_name = item_select:QueryProp("SelfHoodName")
  if nx_string(self_name) == nx_string("") then
  else
    form.ipt_selffoodname.Text = self_name
  end
  form.ipt_selffoodname.Visible = true
end
function show_trainpat_model(grid, item_name)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local game_visual = nx_value("game_visual")
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) or not nx_is_valid(game_visual) then
    return false
  end
  form.scenebox_show_trainpat.Visible = true
  if nx_is_valid(form.scenebox_show_trainpat.Scene) then
    nx_execute("util_gui", "ui_ClearModel", form.scenebox_show_trainpat)
  end
  nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_show_trainpat)
  local resource = item_query:GetItemPropByConfigID(item_name, nx_string("Resource"))
  local actor2 = form.scenebox_show_trainpat.Scene:Create("Actor2")
  load_from_ini(actor2, "ini\\" .. resource .. ".ini")
  if not nx_is_valid(actor2) then
    return false
  end
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_show_trainpat, actor2)
  if game_visual:QueryRoleActionSet(actor2) ~= "" then
    game_visual:SetRoleActionSet(actor2, game_visual:QueryRoleActionSet(actor2))
  end
  local action = nx_value("action_module")
  if nx_is_valid(action) then
    action:BlendAction(actor2, "ty_stand_01", false, true)
  end
  local scene = form.scenebox_show_trainpat.Scene
  local radius = 2.1
  scene.camera:SetPosition(0, radius * 0.4, -radius * 1.45)
  nx_execute("util_gui", "ui_RotateModel", form.scenebox_show_trainpat, 0)
end
function on_btn_turn_left_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_turn_left_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_turn_left_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = 3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if not nx_is_valid(form) then
      return
    end
    nx_execute("util_gui", "ui_RotateModel", form.scenebox_show_trainpat, dist)
  end
end
function on_btn_turn_right_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_turn_right_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_turn_right_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = -3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if not nx_is_valid(form) then
      return
    end
    nx_execute("util_gui", "ui_RotateModel", form.scenebox_show_trainpat, dist)
  end
end
function refresh_pat_shuxing(form)
  if not nx_is_valid(form) then
    return
  end
  if -1 == form.chose_item_index then
    form.mltbox_xunyang.HtmlText = nx_widestr("")
    form.mltbox_qinmi.HtmlText = nx_widestr("")
    form.mltbox_baoshi.HtmlText = nx_widestr("")
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TRAINPAT_ITEM_BOX))
  if not nx_is_valid(view) then
    return
  end
  local item_select = view:GetViewObj(nx_string(form.chose_item_index))
  if not nx_is_valid(item_select) then
    return
  end
  local num_xunyang = item_select:QueryProp("TrainState")
  local num_qinmi = item_select:QueryProp("FamiliarExtent")
  local num_baoshi = item_select:QueryProp("SatietyExtent")
  form.mltbox_xunyang.HtmlText = nx_widestr(num_xunyang)
  form.mltbox_qinmi.HtmlText = nx_widestr(num_qinmi)
  form.mltbox_baoshi.HtmlText = nx_widestr(num_baoshi)
end
function refresh_trainpat_main(sign_cell)
  local form_train_pat = util_get_form("form_stage_main\\form_role_info\\form_train_pat", true)
  if not nx_is_valid(form_train_pat) then
    return
  end
  if 0 == sign_cell then
    form_train_pat.btn_call.Visible = true
    form_train_pat.btn_take_back.Visible = false
    form_train_pat.btn_cure.Visible = false
  elseif 1 == sign_cell then
    form_train_pat.btn_take_back.Visible = true
    form_train_pat.btn_call.Visible = false
    form_train_pat.btn_cure.Visible = false
  elseif 2 == sign_cell then
    form_train_pat.btn_call.Visible = true
    form_train_pat.btn_cure.Visible = false
    form_train_pat.btn_take_back.Visible = false
  elseif 99 == sign_cell then
    form_train_pat.btn_cure.Visible = true
    form_train_pat.btn_call.Visible = false
    form_train_pat.btn_take_back.Visible = false
  end
end
function on_ipt_selffoodname_changed(self)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  local CheckWords = nx_value("CheckWords")
  if not CheckWords:CheckChinese(nx_widestr(name)) then
  end
  if not CheckWords:CheckBadWords(nx_widestr(name)) then
    return false
  end
  if -1 == form.chose_item_index then
    return
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TRAINPAT_CELLPAT), nx_int(form.chose_item_index), 3, nx_widestr(self.Text))
  end
end
function on_ipt_selffoodname_get_focus(self, lost)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  form.lbl_name_state.Visible = true
end
function on_ipt_selffoodname_lost_focus(self, get)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  form.lbl_name_state.Visible = false
end
