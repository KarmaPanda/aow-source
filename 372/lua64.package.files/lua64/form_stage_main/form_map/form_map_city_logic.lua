require("form_stage_main\\form_map\\map_logic")
function main_form_init(form)
  return 1
end
function on_main_form_open(form)
  form.map_query = nx_value("MapQuery")
  local btn = form.btn_trans_npc1
  local id = btn.DataSource
  local text = form.map_query:GetNpcHintText(nx_string(id))
  btn.HintText = nx_widestr(text)
  local scene = form.map_query:GetTransNpcScene(nx_string(id))
  btn.Visible = form.map_query:IsSceneVisited(nx_string(scene))
end
function on_btn_trans_city_npc_click(btn)
  local form = btn.ParentForm
  local id = btn.DataSource
  if nil ~= id and "" ~= id then
    local target_scene = form.map_query:GetTransNpcScene(nx_string(id))
    if "" ~= target_scene and nil ~= target_scene then
      local form = nx_value("form_stage_main\\form_map\\form_map_scene")
      if nx_is_valid(form) and form.Visible then
        nx_execute("form_stage_main\\form_map\\form_map_scene", "turn_to_scene_map", form, nx_string(target_scene))
      end
    end
  end
end
