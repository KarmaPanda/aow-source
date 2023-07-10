require("util_gui")
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  show_step_rule(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  return 1
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function show_step_rule(form)
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local character_flag = player:QueryProp("CharacterFlag")
  local character_value = player:QueryProp("CharacterValue")
  local character_step = nx_execute("form_stage_main\\form_redeem\\form_character_zonglan", "get_character_step", character_flag, character_value)
  form.lbl_character_step.Text = util_text("ui_sns_pk_part_0" .. nx_string(character_step))
  form.mltbox_rule.HtmlText = util_text("ui_sns_pk_bigrule_0" .. nx_string(character_step))
end
