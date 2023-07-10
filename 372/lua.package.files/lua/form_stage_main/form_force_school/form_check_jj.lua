require("define\\gamehand_type")
require("util_gui")
require("util_functions")
require("role_composite")
require("util_static_data")
require("share\\logicstate_define")
local g_form_name = "form_stage_main\\form_force_school\\form_check_jj"
local jj_model_path = "obj\\item\\npcitem\\npcitem639"
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local player_name = client_player:QueryProp("Name")
  form.lbl_qinmi.Text = nx_widestr(player_name)
  show_trainpat_model(form, "npc\\npcitem639")
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    form.chose_item_index = -1
    nx_destroy(form)
  end
end
function on_btn_close_click(btn)
  util_show_form(g_form_name, false)
end
function refresh_form(form)
  form.lbl_trainpat_name.Text = ""
  form.groupbox_top.Visible = true
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
function show_trainpat_model(form, resource_path)
  if not nx_is_valid(form) then
    return false
  end
  if resource_path == "" then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  form.scenebox_show_trainpat.Visible = true
  if nx_is_valid(form.scenebox_show_trainpat.Scene) then
    nx_execute("util_gui", "ui_ClearModel", form.scenebox_show_trainpat)
  end
  nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_show_trainpat)
  local actor2 = form.scenebox_show_trainpat.Scene:Create("Actor2")
  local resource = resource_path
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
  local radius = 0.5
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
function open_form(nType)
  local form = nx_value("form_stage_main\\form_match\\form_match")
  form = util_get_form("form_stage_main\\form_force_school\\form_check_jj", true)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_force_school\\form_check_jj", "refresh_form", form)
  form:Show()
  form.Visible = true
end
