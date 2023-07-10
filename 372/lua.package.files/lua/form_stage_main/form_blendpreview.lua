require("utils")
require("util_gui")
require("util_functions")
require("util_static_data")
require("role_composite")
require("share\\itemtype_define")
require("share\\item_static_data_define")
local FORM_PREVIEW = "form_stage_main\\form_blendpreview"
function on_main_form_init(form)
  form.Fixed = false
  form.actor2 = nil
  form.suit_list = nil
  form.cur_index = -1
  form.max_record = -1
end
function on_main_form_open(form)
  form.suit_list = nx_call("util_gui", "get_arraylist", "blendpreview:suit_list")
  on_gui_size_change()
end
function on_main_form_close(form)
  if nx_is_valid(form.suit_list) then
    form.suit_list:ClearChild()
    nx_destroy(form.suit_list)
  end
  nx_execute("util_gui", "ui_ClearModel", form.role_box)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_prev_click(btn)
  local form = btn.ParentForm
  if nx_int(form.cur_index) <= nx_int(1) then
    form.cur_index = 1
  else
    form.cur_index = form.cur_index - 1
  end
  ShowSuitItem(form, form.cur_index)
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if nx_int(form.cur_index) >= nx_int(form.max_record) then
    form.cur_index = form.max_record
  else
    form.cur_index = form.cur_index + 1
  end
  ShowSuitItem(form, form.cur_index)
end
function on_btn_left_click(btn)
  btn.MouseDown = false
end
function on_btn_left_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = 3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
  end
end
function on_btn_left_lost_capture(btn)
  btn.MouseDown = false
end
function on_btn_right_click(btn)
  btn.MouseDown = false
end
function on_btn_right_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = -3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
  end
end
function on_btn_right_lost_capture(btn)
  btn.MouseDown = false
end
function init_form(form, cur_index, ...)
  if not nx_is_valid(form) then
    return
  end
  ParserArgs(form, arg)
  form.cur_index = cur_index
  form.btn_prev.Visible = nx_int(cur_index) > nx_int(1)
  form.btn_next.Visible = nx_int(cur_index) < nx_int(form.max_record)
  local child = form.suit_list:GetChildByIndex(cur_index - 1)
  if nx_is_valid(child) then
    local gui = nx_value("gui")
    form.lbl_suitname.Text = nx_widestr(gui.TextManager:GetText(child.suit_name))
  end
  if not nx_find_custom(form, "actor2") or not nx_is_valid(form.actor2) then
    form.actor2 = CreateRoleModel(form)
  end
  ShowSuitItem(form, cur_index)
end
function ShowSuitItem(form, index)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  form.max_record = form.suit_list:GetChildCount()
  if nx_int(index) < nx_int(1) or nx_int(index) > nx_int(form.max_record) then
    return
  end
  form.cur_index = nx_int(index)
  form.btn_prev.Visible = nx_int(index) > nx_int(1)
  form.btn_next.Visible = nx_int(index) < nx_int(form.max_record)
  local child = form.suit_list:GetChildByIndex(index - 1)
  form.lbl_suitname.Text = nx_widestr(gui.TextManager:GetText(child.suit_name))
  link_model(form.actor2, "Hat", get_model(child.hat))
  link_model(form.actor2, "Cloth", get_model(child.cloth))
  link_model(form.actor2, "Pants", get_model(child.pants))
  link_model(form.actor2, "Shoes", get_model(child.shoes))
end
function ParserArgs(form, suitlist)
  form.suit_list:ClearChild()
  local count = table.getn(suitlist) / 10
  for i = 1, count do
    local item = form.suit_list:CreateChild("")
    local base = (i - 1) * 10
    item.suit_name = nx_string(suitlist[base + 1])
    item.isopened = nx_boolean(suitlist[base + 2])
    item.hat = nx_string(suitlist[base + 3])
    item.act_hat = nx_boolean(suitlist[base + 4])
    item.cloth = nx_string(suitlist[base + 5])
    item.act_cloth = nx_boolean(suitlist[base + 6])
    item.pants = nx_string(suitlist[base + 7])
    item.act_pants = nx_boolean(suitlist[base + 8])
    item.shoes = nx_string(suitlist[base + 9])
    item.act_shoes = nx_boolean(suitlist[base + 10])
  end
  form.max_record = form.suit_list:GetChildCount()
end
function CreateRoleModel(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nx_null()
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return nx_null()
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nx_null()
  end
  local client_obj = game_client:GetSceneObj(nx_string(client_player.Ident))
  if not nx_is_valid(client_obj) then
    return nx_null()
  end
  if not nx_is_valid(form.role_box.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.role_box)
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return nx_null()
  end
  local actor2 = role_composite:CreateSceneObject(form.role_box.Scene, client_obj, false, false)
  if not nx_is_valid(actor2) then
    return nx_null()
  end
  while not actor2.LoadFinish do
    nx_pause(0.1)
  end
  local face_actor2 = get_role_face(actor2)
  while not nx_is_valid(face_actor2) do
    nx_pause(0.1)
    face_actor2 = get_role_face(actor2)
  end
  if not nx_is_valid(face_actor2) then
    return false
  end
  while not face_actor2.LoadFinish do
    nx_pause(0.1)
  end
  nx_execute("util_gui", "util_add_model_to_scenebox", form.role_box, actor2)
  return actor2
end
function link_model(actor2, part_name, model)
  if not nx_is_valid(actor2) then
    return
  end
  if nx_string(part_name) == nx_string("") or nx_string(model) == nx_string("") then
    return
  end
  local prop = nx_string("cur") .. nx_string(part_name)
  if nx_find_custom(actor2, prop) then
    local cur_model = nx_custom(actor2, prop)
    if nx_string(cur_model) == nx_string(model) then
      return
    end
  end
  nx_execute("role_composite", "unlink_skin", actor2, nx_string(part_name))
  local role_composite = nx_value("role_composite")
  if "cloth" == part_name then
    link_cloth_skin(role_composite, actor2, model)
  elseif "hat" == part_name then
    link_hat_skin(role_composite, actor2, model)
  elseif "pants" == part_name then
    link_pants_skin(role_composite, actor2, model)
  else
    nx_execute("role_composite", "link_skin", actor2, nx_string(part_name), nx_string(model) .. ".xmod")
  end
  nx_set_custom(actor2, prop, nx_string(model))
end
function get_custom_prop(part_name)
end
function get_model(configid)
  local staticdatamgr = nx_value("data_query_manager")
  if not nx_is_valid(staticdatamgr) then
    return ""
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return ""
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local sex = nx_number(client_player:QueryProp("Sex"))
  local g_sex_prop = {
    [0] = "MaleModel",
    [1] = "FemaleModel"
  }
  local col_name = g_sex_prop[nx_number(sex)]
  local model = ""
  if nx_string(configid) ~= nx_string("") then
    local artpack = 0
    local item_type = ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string("ItemType"))
    if nx_int(item_type) >= nx_int(ITEMTYPE_HUANPIMIN) and nx_int(item_type) <= nx_int(ITEMTYPE_HUANPIMAX) then
      artpack = ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string("ArtPack"))
    end
    model = staticdatamgr:Query(nx_int(STATIC_DATA_ITEM_ART), nx_int(artpack), nx_string(col_name))
  end
  return model
end
function get_role_face(actor2)
  if not nx_is_valid(actor2) then
    return nil
  end
  local actor_role = actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    return nil
  end
  return actor_role:GetLinkObject("actor_role_face")
end
function on_gui_size_change()
  local gui = nx_value("gui")
  local form = nx_value(FORM_PREVIEW)
  if not nx_is_valid(form) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
