require("share\\server_custom_define")
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
end
function on_main_form_close(self)
end
function form_open(btn_emotion)
  if not nx_is_valid(btn_emotion) then
    return
  end
  local form_page_emotion = nx_value("form_stage_main\\form_main\\form_main_page_emotion")
  if not nx_is_valid(form_page_emotion) then
    form_page_emotion = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main_page_emotion", true, false)
  end
  form_page_emotion.Visible = true
  local gui = nx_value("gui")
  local width = gui.Desktop.Width
  local height = gui.Desktop.Height
  form_page_emotion.Left = (width - form_page_emotion.Width) / 2
  form_page_emotion.Top = (height - form_page_emotion.Height) / 2
  form_page_emotion:Show()
  local btn_emotion_type
  for i = TIPSTYPE_EMOTIONINFO_NPC, TIPSTYPE_EMOTIONINFO_REWARD do
    btn_emotion_type = form_page_emotion.groupbox_1:Find("cbtn_" .. nx_string(i))
    if nx_is_valid(btn_emotion_type) then
      local prop_value = nx_custom(btn_emotion, "emotion_type_" .. nx_string(i))
      btn_emotion_type.Checked = prop_value
    end
  end
end
function on_btn_no_click(btn)
  local form_emotion = btn.ParentForm
  if nx_is_valid(form_emotion) then
    form_emotion.Visible = false
  end
end
function on_btn_yes_click(btn)
  local form_system = nx_value("form_stage_main\\form_main\\form_main_sysinfo")
  if not nx_is_valid(form_system) then
    return
  end
  local form_page_emotion = btn.ParentForm
  local btn_emotion = form_system.btn_emotion
  local btn_emotion_type
  form_system.emotion_list:ShowKeyItems(-1)
  for i = TIPSTYPE_EMOTIONINFO_NPC, TIPSTYPE_EMOTIONINFO_REWARD do
    btn_emotion_type = form_page_emotion.groupbox_1:Find("cbtn_" .. i)
    if nx_is_valid(btn_emotion_type) then
      local b_btn_checked = btn_emotion_type.Checked
      nx_set_custom(btn_emotion, "emotion_type_" .. i, b_btn_checked)
      if b_btn_checked then
        form_system.emotion_list:ShowKeyItems(i)
      end
    end
  end
  form_system.emotion_list:ShowKeyItems(100)
  form_page_emotion.Visible = false
end
