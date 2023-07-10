require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
require("share\\capital_define")
local FORM_PATH = "form_stage_main\\form_home\\form_home_move"
local CUSTOM_SUB_CHOOSEFORM_TRANSJH = 7
local em_enter_no = 1
local em_eneter_new = 2
local em_enter_old = 3
function open_form(choose_scene)
  util_auto_show_hide_form(FORM_PATH)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  form.choose_scene = choose_scene
end
function main_form_init(form)
  form.Fixed = false
  form.move_op = 0
  form.choose_scene = -1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 4
  form.rbtn_1.Checked = true
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function on_rbtn_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    if nx_string(rbtn.DataSource) == "1" then
      form.move_op = em_enter_old
    elseif nx_string(rbtn.DataSource) == "2" then
      form.move_op = em_eneter_new
    end
  end
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  if form.move_op == 0 then
    return
  end
  local gui = nx_value("gui")
  local text = nx_widestr("")
  if form.move_op == em_eneter_new then
    text = gui.TextManager:GetText("ui_carry_yes_sure")
  elseif form.move_op == em_enter_old then
    text = gui.TextManager:GetText("ui_carry_no_sure")
  end
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "enter_jinaghu_req")
  if not nx_is_valid(dialog) then
    return
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "enter_jinaghu_req_confirm_return")
  if res ~= "ok" then
    return
  end
  nx_execute("custom_sender", "custom_send_scene_jhpk", nx_int(CUSTOM_SUB_CHOOSEFORM_TRANSJH), nx_int(form.choose_scene), nx_int(form.move_op))
  form:Close()
end
