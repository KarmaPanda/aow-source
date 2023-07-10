require("form_stage_main\\form_main\\form_main_fightvs_util")
local note_image = {
  [1] = "gui\\language\\ChineseS\\wuxue\\bhcsq\\1.png",
  [2] = "gui\\language\\ChineseS\\wuxue\\bhcsq\\2.png",
  [3] = "gui\\language\\ChineseS\\wuxue\\bhcsq\\3.png",
  [4] = "gui\\language\\ChineseS\\wuxue\\bhcsq\\4.png",
  [5] = "gui\\language\\ChineseS\\wuxue\\bhcsq\\5.png"
}
local note_image_left = {
  510,
  294,
  209,
  124,
  -72
}
function main_form_init(form)
  form.Fixed = true
  form.note4 = 0
  form.Pos = 175
  form.MoveSpeed = 10
  form.ChangeColor = 15
  form.bExecute = 1
end
function on_main_form_open(form)
  local note_ini = nx_execute("util_functions", "get_ini", "ini\\ui\\wuxue\\musical_note.ini")
  if nx_is_valid(note_ini) then
    local index = note_ini:FindSectionIndex("Prop")
    if index ~= -1 then
      form.Pos = note_ini:ReadInteger(index, "Pos", 175)
      form.MoveSpeed = note_ini:ReadInteger(index, "MoveSpeed", 10)
      form.ChangeColor = note_ini:ReadInteger(index, "ChangeColor", 15)
    end
  end
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Desktop.Width - form.Width) / 2
  form.AbsTop = gui.Desktop.Height - form.Height - form.Pos
  gui.Desktop:ToBack(form)
  local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_effect")
  if bMovie then
    form.Visible = false
    nx_execute("form_stage_main\\form_movie_effect", "add_hide_control", form)
  else
    form.Visible = true
  end
  local image_count = table.getn(note_image_left)
  for i = 1, image_count do
    local lbl_note = form.groupbox_1:Find("lbl_musical_note_" .. nx_string(i))
    if lbl_note ~= nil then
      note_image_left[i] = lbl_note.Left
      lbl_note.alpha = 255
    end
  end
end
function on_main_form_close(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(FORM_FIGHT_VS_MUSICAL, "on_delay_show_form_time", form)
  end
  nx_destroy(form)
end
function change_form_size()
  local form = util_get_form(FORM_FIGHT_VS_MUSICAL, false)
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Desktop.Width - form.Width) / 2
  form.AbsTop = gui.Desktop.Height - form.Height - form.Pos
end
function show_musical_note(value)
  local form = util_get_form(FORM_FIGHT_VS_MUSICAL, true, false)
  if not nx_is_valid(form) then
    return 0
  end
  local note = nx_number(value)
  if note <= 0 then
    form:Close()
    return 0
  end
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
    local timer = nx_value("timer_game")
    timer:UnRegister(FORM_FIGHT_VS_MUSICAL, "on_delay_show_form_time", form)
    timer:Register(5000, -1, FORM_FIGHT_VS_MUSICAL, "on_delay_show_form_time", form, note, -1)
    return 0
  end
  util_show_form(FORM_FIGHT_VS_MUSICAL, true)
  musical_note_info(form, note)
end
function musical_note_info(form, note)
  if not nx_is_valid(form) then
    return 0
  end
  local max_value = table.getn(note_image)
  local value1 = nx_number(nx_int(note % 10))
  local value2 = nx_number(nx_int(note % 100 / 10))
  local value3 = nx_number(nx_int(note % 1000 / 100))
  if value1 <= 0 or max_value < value1 then
    form.lbl_musical_note_1.BackImage = ""
  else
    form.lbl_musical_note_1.BackImage = note_image[value1]
  end
  if value2 <= 0 or max_value < value2 then
    form.lbl_musical_note_2.BackImage = ""
  else
    form.lbl_musical_note_2.BackImage = note_image[value2]
  end
  if value3 <= 0 or max_value < value3 then
    form.lbl_musical_note_3.BackImage = ""
  else
    form.lbl_musical_note_3.BackImage = note_image[value3]
  end
  if form.note4 == 0 then
    form.lbl_musical_note_4.BackImage = ""
  else
    form.lbl_musical_note_4.BackImage = note_image[form.note4]
  end
  form.note4 = value3
  form.lbl_front.Visible = false
  local note_ini = nx_execute("util_functions", "get_ini", "ini\\ui\\wuxue\\musical_note.ini")
  if nx_is_valid(note_ini) then
    local index = note_ini:FindSectionIndex("Note")
    if index ~= -1 then
      local value_list = note_ini:GetItemValueList(index, "r")
      local value_count = table.getn(value_list)
      if value_count <= 0 then
        return 0
      end
      for i = 1, value_count do
        local value = nx_number(value_list[i])
        if value == note then
          form.lbl_front.Visible = true
          break
        end
      end
    end
  end
  reset_note_image(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_musical_note_info", form)
    timer:Register(60000, 1, nx_current(), "on_musical_note_info", form, -1, -1)
  end
  if nx_number(table.getn(note_image_left)) < 5 then
    return
  end
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    form.bExecute = 1
    common_execute:RemoveExecute("MusicalNoteAmt", form)
    common_execute:AddExecute("MusicalNoteAmt", form, 0.05, nx_int(form.MoveSpeed), nx_int(form.ChangeColor), nx_int(note_image_left[1]), nx_int(note_image_left[2]), nx_int(note_image_left[3]), nx_int(note_image_left[4]), nx_int(note_image_left[5]))
  end
end
function hide_musical_note_form()
  local form = util_get_form(FORM_FIGHT_VS_MUSICAL, false)
  if nx_is_valid(form) then
    form.Visible = false
  end
end
function on_musical_note_info(form)
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return 0
  end
  if not nx_is_valid(form) then
    return 0
  end
  form.note4 = 0
  timer:UnRegister(nx_current(), "on_musical_note_info", form)
  form:Close()
end
function reset_note_image(form)
  if not nx_is_valid(form) then
    return 0
  end
  local image_count = table.getn(note_image_left)
  for i = 1, image_count do
    local lbl_note = form.groupbox_1:Find("lbl_musical_note_" .. nx_string(i))
    if lbl_note ~= nil then
      lbl_note.Left = note_image_left[i]
      if i == 1 then
        lbl_note.BlendColor = "0,255,255,255"
        lbl_note.alpha = 0
      end
      if i == image_count - 1 then
        lbl_note.BlendColor = "255,255,255,255"
        lbl_note.alpha = 255
      end
    end
  end
end
function on_delay_show_form_time(form, note)
  if not nx_is_valid(form) then
    return 0
  end
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
    return 0
  end
  util_show_form(FORM_FIGHT_VS_MUSICAL, true)
  musical_note_info(form, note)
  local timer = nx_value("timer_game")
  timer:UnRegister(FORM_FIGHT_VS_MUSICAL, "on_delay_show_form_time", form)
end
