require("util_gui")
require("custom_sender")
require("share\\client_custom_define")
require("form_stage_main\\form_arrest\\form_arrest_define")
local police_need_money = 0
local police_tipPK1 = 0
function on_main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  nx_execute("form_stage_main\\form_arrest\\form_arrest_define", "get_arrest_ini")
  police_need_money, police_tipPK1 = nx_execute("form_stage_main\\form_arrest\\form_arrest_define", "get_arrest_apply_police_need_info")
  form.redit_rule.Text = nx_widestr(get_format_text_info("ui_arrest_catch_rule", nx_int(police_tipPK1)))
  local need_money = money_info(police_need_money)
  form.lbl_money.Text = nx_widestr(get_format_text_info("ui_apply_money", need_money))
  nx_execute("util_gui", "ui_show_attached_form", form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function on_btn_apply_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), nx_int(ARREST_CUSTOMMSG_APPLY_POLICE))
  form:Close()
  return
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  return
end
function get_format_text_info(text_id, param)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName(text_id)
  gui.TextManager:Format_AddParam(param)
  local text = gui.TextManager:Format_GetText()
  return text
end
function on_btn_help_click(btn)
  local form = btn.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
