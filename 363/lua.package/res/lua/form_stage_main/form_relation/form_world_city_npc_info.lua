require("share\\view_define")
require("define\\gamehand_type")
require("util_gui")
require("custom_sender")
require("util_functions")
require("role_composite")
require("util_static_data")
require("share\\logicstate_define")
require("share\\view_define")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  nx_destroy(form)
  nx_set_value("form_world_city_npc_info", nx_null())
end
function show_npc_desc(...)
  local form = util_get_form("form_stage_main\\form_relation\\form_world_city_npc_info", true, false)
  if not nx_is_valid(form) then
    return
  end
  local lbl_lst = get_npc_info_lbl_list(form)
  local lbl_count = table.getn(lbl_lst)
  form.lbl_npc_head.BackImage = nx_string(arg[1])
  form.lbl_npc_head.Enabled = false
  show_npc_model(form.scenebox_npc, arg[2])
  form.lbl_npc_name.Text = util_text(arg[2])
  for i = 1, lbl_count do
    lbl_lst[i].Text = nx_widestr(arg[i + 2])
  end
  form.lbl_npc_special_value_1.Visible = false
  form.lbl_npc_special_value_2.Visible = false
  form.lbl_npc_special_value_3.Visible = false
  if arg[lbl_count + 3] then
    form.lbl_npc_special_value_1.DrawMode = "FitWindow"
    form.lbl_npc_special_value_1.BackImage = "gui\\special\\sns_new\\btn_enchou_price\\money1_on.png"
    form.lbl_npc_special_value_1.HintText = util_text("tips_npcfunc_award")
    form.lbl_npc_special_value_1.Transparent = false
    form.lbl_npc_special_value_1.Visible = true
  end
  if arg[lbl_count + 4] then
    form.lbl_npc_special_value_2.DrawMode = "FitWindow"
    form.lbl_npc_special_value_2.BackImage = "gui\\special\\karma\\avenge.png"
    form.lbl_npc_special_value_2.HintText = util_text("tips_npcfunc_avenge")
    form.lbl_npc_special_value_2.Transparent = false
    form.lbl_npc_special_value_2.Visible = true
  end
  if not arg[lbl_count + 4] and arg[lbl_count + 5] then
    form.lbl_npc_special_value_2.DrawMode = "FitWindow"
    form.lbl_npc_special_value_2.BackImage = "gui\\special\\btn_main\\btn_zhibao_out.png"
    form.lbl_npc_special_value_2.HintText = util_text("tips_npcfunc_zhibao")
    form.lbl_npc_special_value_2.Transparent = false
    form.lbl_npc_special_value_2.Visible = true
  end
  if arg[lbl_count + 4] and arg[lbl_count + 5] then
    form.lbl_npc_special_value_3.DrawMode = "FitWindow"
    form.lbl_npc_special_value_3.BackImage = "gui\\special\\btn_main\\btn_zhibao_out.png"
    form.lbl_npc_special_value_3.HintText = util_text("tips_npcfunc_zhibao")
    form.lbl_npc_special_value_3.Transparent = false
    form.lbl_npc_special_value_3.Visible = true
  end
  form:Show()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
  nx_set_value("form_world_city_npc_info", nx_null())
end
function close_form_when_enter_world()
  local form = nx_value("form_stage_main\\form_relation\\form_world_city_npc_info")
  if nx_is_valid(form) then
    nx_destroy(form)
    nx_set_value("form_world_city_npc_info", nx_null())
  end
  local form_menu = nx_value("form_stage_main\\form_relation\\form_sns_menu")
  if nx_is_valid(form_menu) then
    nx_destroy(form_menu)
    nx_set_value("form_sns_menu", nx_null())
  end
end
function get_npc_info_lbl_list(form)
  local npc_info_lbl_list = {
    form.lbl_npc_desc,
    form.lbl_npc_shane_value,
    form.lbl_npc_guanxi_value,
    form.lbl_npc_scene_value,
    form.lbl_npc_pos_value,
    form.lbl_npc_shili_value,
    form.lbl_npc_yinxiang_value
  }
  return npc_info_lbl_list
end
function show_npc_model(scenebox, npc_id)
  if not nx_is_valid(scenebox) then
    return
  end
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  if nx_find_custom(scenebox, "role_actor2") and nx_is_valid(scenebox.role_actor2) then
    local world = nx_value("world")
    world:Delete(scenebox.role_actor2)
  end
  if not nx_is_valid(scenebox.Scene) then
    util_addscene_to_scenebox(scenebox)
  end
  local world = nx_value("world")
  if nx_is_valid(world) then
    nx_call("scene", "support_physics", world, scenebox.Scene)
  end
  local resource = item_query:GetItemPropByConfigID(nx_string(npc_id), nx_string("Resource"))
  local actor2 = scenebox.Scene:Create("Actor2")
  load_from_ini(actor2, "ini\\" .. resource .. ".ini")
  if not nx_is_valid(actor2) then
    return
  end
  local action = nx_value("action_module")
  if nx_is_valid(action) then
    action:BlendAction(actor2, "ty_stand_01", false, true)
  end
  util_add_model_to_scenebox(scenebox, actor2)
  scenebox.role_actor2 = actor2
  local scene = scenebox.Scene
  local radius = 2.1
  scene.camera:SetPosition(0, radius * 0.4, -radius * 1.45)
end
