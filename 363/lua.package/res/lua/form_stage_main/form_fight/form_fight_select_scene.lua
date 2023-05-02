require("utils")
require("util_gui")
require("const_define")
require("custom_sender")
local FORM_FIGHT_SELECT_SCENE = "form_stage_main\\form_fight\\form_fight_select_scene"
local scene_list = {
  0,
  251,
  252,
  253,
  254
}
function main_form_init(form)
  form.Fixed = false
  form.select_scene_id = 0
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  for i = 1, #scene_list do
    form.combobox_scene_list.DropListBox:AddString(nx_widestr(util_text("arena_scene_name_" .. nx_string(scene_list[i]))))
  end
  form.combobox_scene_list.DropListBox.SelectIndex = 1
  on_combobox_scene_list_selected(form.combobox_scene_list)
  form.combobox_scene_list.Text = nx_widestr(util_text("arena_scene_name_251"))
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_main_form_shut(form)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_arena_create(form.select_scene_id)
  form:Close()
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_combobox_scene_list_selected(combobox)
  local form = combobox.ParentForm
  local select_index = combobox.DropListBox.SelectIndex
  if nx_int(select_index) >= nx_int(#scene_list) then
    return
  end
  local select_scene_id = scene_list[select_index + 1]
  form.select_scene_id = select_scene_id
  form.lbl_scene_name.Text = nx_widestr(util_text("arena_scene_name_" .. nx_string(select_scene_id)))
  form.lbl_scene_image.BackImage = "gui\\special\\leitai\\fight_" .. nx_string(select_scene_id) .. ".png"
end
