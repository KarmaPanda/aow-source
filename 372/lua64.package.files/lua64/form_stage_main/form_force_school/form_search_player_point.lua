require("util_functions")
require("share\\client_custom_define")
local CLIENT_CUSTOM_SUBMSG_SEARCH_PLAYER = 2
function main_form_init(form)
  form.Fixed = false
  return 1
end
function change_form_size(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  nx_bind_script(form.combobox_1.InputEdit, nx_current())
  form.lbl_result_search.Visible = false
  form.Visible = true
  return 1
end
function main_form_close(form)
  form.Visible = false
  nx_destroy(form)
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_search_click(btn)
  local form = btn.ParentForm
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  if nx_widestr(form.combobox_1.InputEdit.Text) == nx_widestr("") then
    return
  end
  if nx_widestr(form.combobox_1.InputEdit.Text) == nx_widestr(player:QueryProp("Name")) then
    form.lbl_result_search.Text = nx_widestr(util_text("29230"))
    form.lbl_result_search.Visible = true
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_QS_HELPER), nx_int(CLIENT_CUSTOM_SUBMSG_SEARCH_PLAYER), nx_widestr(form.combobox_1.InputEdit.Text))
end
