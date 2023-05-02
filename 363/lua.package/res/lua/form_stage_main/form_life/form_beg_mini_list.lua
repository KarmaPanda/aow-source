require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("utils")
require("util_gui")
require("define\\gamehand_type")
require("game_object")
require("util_functions")
require("define\\object_type_define")
require("define\\request_type")
local Object
local BegRank = 1
local CurSelect = 1
local PrimaryImage = "gui\\special\\qigai\\budai1_out.png"
local SelectImage = "gui\\special\\qigai\\budai1_out.png"
local BegTipsText = {
  "tips_qigai_1",
  "tips_qigai_2"
}
local g_normal_image1 = "gui\\special\\qigai\\budai1_out.png"
local g_focus_image1 = "gui\\special\\qigai\\budai1_on.png"
local g_push_image1 = "gui\\special\\qigai\\budai1_down.png"
local g_normal_image2 = "gui\\special\\qigai\\budai2_out.png"
local g_focus_image2 = "gui\\special\\qigai\\budai2_on.png"
local g_push_image2 = "gui\\special\\qigai\\budai2_down.png"
local g_normal_image3 = "gui\\special\\qigai\\budai3_out.png"
local g_focus_image3 = "gui\\special\\qigai\\budai3_on.png"
local g_push_image3 = "gui\\special\\qigai\\budai3_down.png"
local g_normal_image4 = "gui\\special\\qigai\\budai4_out.png"
local g_focus_image4 = "gui\\special\\qigai\\budai4_on.png"
local g_push_image4 = "gui\\special\\qigai\\budai4_down.png"
function main_form_init(form)
  form.Fixed = false
  form.size_adjust = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function Init_image(target, rank)
  local form = nx_value("form_stage_main\\form_life\\form_beg_mini_list")
  if not nx_is_valid(form) then
    return
  end
  local normal_image1, focus_image1, push_image1, normal_image2, focus_image2, push_image2
  if rank <= 3 then
    normal_image1 = g_normal_image1
    focus_image1 = g_focus_image1
    push_image1 = g_push_image1
    normal_image2 = g_normal_image1
    focus_image2 = g_focus_image1
    push_image2 = g_push_image1
  elseif 4 == rank then
    normal_image1 = g_normal_image1
    focus_image1 = g_focus_image1
    push_image1 = g_push_image1
    normal_image2 = g_normal_image2
    focus_image2 = g_focus_image2
    push_image2 = g_push_image2
  elseif rank <= 6 and 4 < rank then
    normal_image1 = g_normal_image2
    focus_image1 = g_focus_image2
    push_image1 = g_push_image2
    normal_image2 = g_normal_image2
    focus_image2 = g_focus_image2
    push_image2 = g_push_image2
  elseif 7 == rank then
    normal_image1 = g_normal_image2
    focus_image1 = g_focus_image2
    push_image1 = g_push_image2
    normal_image2 = g_normal_image3
    focus_image2 = g_focus_image3
    push_image2 = g_push_image3
  elseif 7 < rank and rank < 10 then
    normal_image1 = g_normal_image3
    focus_image1 = g_focus_image3
    push_image1 = g_push_image3
    normal_image2 = g_normal_image3
    focus_image2 = g_focus_image3
    push_image2 = g_push_image3
  else
    normal_image1 = g_normal_image3
    focus_image1 = g_focus_image3
    push_image1 = g_push_image3
    normal_image2 = g_normal_image4
    focus_image2 = g_focus_image4
    push_image2 = g_push_image4
  end
  local btn1 = form.groupbox_1:Find("1")
  local btn2 = form.groupbox_1:Find("2")
  if nx_is_valid(btn1) then
    btn1.NormalImage = normal_image1
    btn1.FocusImage = focus_image1
    btn1.PushImage = push_image1
  end
  if nx_is_valid(btn2) then
    btn2.NormalImage = normal_image2
    btn2.FocusImage = focus_image2
    btn2.PushImage = push_image2
  end
  return normal_image1, normal_image2
end
function Init(target, rank)
  local form = nx_value("form_stage_main\\form_life\\form_beg_mini_list")
  if not nx_is_valid(form) then
    return
  end
  Object = target
  BegRank = rank
  local game_client = nx_value("game_client")
  local target_obj = game_client:GetSceneObj(nx_string(Object))
  if not nx_is_valid(target_obj) then
    return
  end
  local name1
  local gui = nx_value("gui")
  name1 = nx_string("ui_qg_bd") .. rank
  if nx_is_valid(form.name_1) then
    local show_name = gui.TextManager:GetFormatText(nx_string(name1))
    if nx_ws_length(show_name) > 20 then
      form.name_1.HintText = gui.TextManager:GetFormatText(nx_string(name1))
      form.name_1.Transparent = false
      form.name_1.ClickEvent = false
      show_name = nx_function("ext_ws_substr", show_name, 0, 20) .. nx_widestr("...")
    else
      form.name_1.HintText = nx_widestr("")
    end
    form.name_1.Text = show_name
  end
  local normal_image1, normal_image2 = Init_image(target, rank)
  CurSelect = 1
  local select_btn = form.groupbox_1:Find(nx_string(CurSelect))
  select_btn.NormalImage = normal_image1
  if form.size_adjust == false then
    form.Width = form.Width / 2
    form.ok.Left = form.ok.Left - 248
    form.cancel.Left = form.cancel.Left - 248
    form.title.Left = form.title.Left - 120
    form.title_bk.Left = form.title_bk.Left - 120
    form.size_adjust = true
    form.groupbox_2.Width = form.groupbox_2.Width / 2 - 5
    form.groupbox_1.Width = form.groupbox_1.Width / 2 - 4
    form.bian.Width = form.bian.Width / 2 - 4
    form.bian2.Width = form.bian2.Width / 2 - 4
  end
end
function on_btn_click(btn)
  Init_image(Object, BegRank)
  CurSelect = nx_number(btn.Name)
  btn.NormalImage = btn.PushImage
end
function on_ok_click(btn)
  local game_client = nx_value("game_client")
  local target_obj = game_client:GetSceneObj(nx_string(Object))
  if not nx_is_valid(target_obj) then
    return
  end
  local type = target_obj:QueryProp("Type")
  local name = target_obj:QueryProp("Name")
  local gui = nx_value("gui")
  local form = btn.ParentForm
  local lbl_text = form.groupbox_1:Find("name_" .. nx_string(CurSelect))
  local desc_box = nx_string(lbl_text.Text)
  if nx_is_valid(form) then
    form:Close()
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local Text = nx_widestr(util_text("ui_sh_qg_1")) .. nx_widestr(name) .. nx_widestr(util_text("ui_sh_qg_2")) .. nx_widestr(util_text(desc_box)) .. nx_widestr(util_text("ui_sh_qg_3"))
  dialog.mltbox_info:AddHtmlText(Text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("60010"), name)
    nx_execute("custom_sender", "custom_send_begplayer", nx_object(Object), nx_int(BegRank))
  end
end
function on_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_get_capture(btn)
  local index = nx_number(btn.Name)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText(nx_string(BegTipsText[index]))
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", text, x, y, 0, btn.ParentForm)
end
function on_btn_lost_capture(btn)
  nx_execute("tips_game", "hide_tip", btn.ParentForm)
end
