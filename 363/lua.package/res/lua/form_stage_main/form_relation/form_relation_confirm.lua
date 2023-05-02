require("util_functions")
require("define\\object_type_define")
function main_form_init(self)
  self.Fixed = false
  self.event_type = ""
  self.add_arrest = 0
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.Default = self.ok_btn
  show_publish_or_add(self)
  return 1
end
function on_main_form_close(self)
  self.info_label.Text = nx_widestr("")
  self.mltbox_info:Clear()
  if nx_is_valid(self) then
    nx_destroy(self)
  end
end
function ok_btn_click(self)
  local form = self.ParentForm
  local event_type = form.event_type
  if event_type == "" then
    nx_gen_event(form, "relation_confirm_return", "ok")
  else
    nx_gen_event(form, event_type .. "_" .. "relation_confirm_return", "ok")
  end
  if nx_is_valid(form) then
    form:Close()
  end
  return 1
end
function cancel_btn_click(self)
  local form = self.ParentForm
  local event_type = form.event_type
  if event_type == "" then
    nx_gen_event(form, "relation_confirm_return", "cancel")
  else
    nx_gen_event(form, event_type .. "_" .. "relation_confirm_return", "cancel")
  end
  if nx_is_valid(form) then
    form:Close()
  end
  return 1
end
function on_btn_add_publish_click(self)
  local form = self.ParentForm
  local event_type = form.event_type
  if event_type == "" then
    nx_gen_event(form, "relation_confirm_return", "ok_publish")
  else
    nx_gen_event(form, event_type .. "_" .. "relation_confirm_return", "ok_publish")
  end
  if nx_is_valid(form) then
    form:Close()
  end
  return 1
end
function on_btn_add_money_click(btn)
  local form = btn.ParentForm
  local event_type = form.event_type
  if event_type == "" then
    nx_gen_event(form, "relation_confirm_return", "ok_add_money")
  else
    nx_gen_event(form, event_type .. "_" .. "relation_confirm_return", "ok_add_money")
  end
  if nx_is_valid(form) then
    form:Close()
  end
  return 1
end
function show_common_text(dialog, text)
  if not nx_is_valid(dialog) then
    return
  end
  text = nx_widestr(text)
  local len = nx_ws_length(text)
  if len <= 10 then
    dialog.mltbox_info.Visible = false
    dialog.info_label.Visible = true
    dialog.info_label.Text = nx_widestr(text)
  else
    dialog.info_label.Visible = false
    dialog.mltbox_info.Visible = true
    dialog.mltbox_info:Clear()
    dialog.mltbox_info:AddHtmlText(text, -1)
  end
end
function clear()
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_relation_confirm", false, false)
  if nx_is_valid(dialog) then
    dialog:Close()
    if nx_is_valid(dialog) then
      nx_destroy(dialog)
    end
  end
end
function get_arrest_flag(form, name)
  local arrest_flag = 0
  form.add_arrest = 0
  if nx_ws_equal(nx_widestr(name), nx_widestr("")) or not nx_is_valid(form) then
    return 0
  end
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local game_scene = game_client:GetScene()
  local table_client_obj = game_scene:GetSceneObjList()
  for i, client_obj in pairs(table_client_obj) do
    local obj_type = client_obj:QueryProp("Type")
    local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
    if nx_is_valid(visual_obj) and nx_number(obj_type) == TYPE_PLAYER then
      local obj_name = ""
      if client_obj:FindProp("Name") then
        obj_name = nx_widestr(client_obj:QueryProp("Name"))
        if nx_ws_equal(nx_widestr(obj_name), nx_widestr(name)) and client_obj:FindProp("ArrestFlag") then
          arrest_flag = client_obj:QueryProp("ArrestFlag")
        end
      end
    end
  end
  form.add_arrest = arrest_flag
  return arrest_flag
end
function show_publish_or_add(form)
  form.mltbox_1:Clear()
  if form.add_arrest == 2 or form.add_arrest == 3 or form.add_arrest == 4 then
    form.btn_add_money.Visible = true
    form.btn_add_publish.Visible = false
    form.mltbox_1:AddHtmlText(nx_widestr(util_text("ui_chouren_zhujiaxuanshang")), -1)
  else
    form.btn_add_money.Visible = false
    form.btn_add_publish.Visible = true
    form.mltbox_1:AddHtmlText(nx_widestr(util_text("ui_chouren_haibu")), -1)
  end
end
