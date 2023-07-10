local SHUZITUPIAN = {
  "gui\\special\\battlefield\\battle_0.png",
  "gui\\special\\battlefield\\battle_1.png",
  "gui\\special\\battlefield\\battle_2.png",
  "gui\\special\\battlefield\\battle_3.png",
  "gui\\special\\battlefield\\battle_4.png",
  "gui\\special\\battlefield\\battle_5.png",
  "gui\\special\\battlefield\\battle_6.png",
  "gui\\special\\battlefield\\battle_7.png",
  "gui\\special\\battlefield\\battle_8.png",
  "gui\\special\\battlefield\\battle_9.png",
  "gui\\language\\ChineseS\\battlefield\\battle_lz.png",
  "gui\\language\\ChineseS\\battlefield\\battle_js.png",
  "gui\\language\\ChineseS\\battlefield\\battle_zg.png"
}
function init_form(self)
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "form_close", form)
  end
  form.Visible = false
  nx_destroy(form)
end
function DisplayInfo(arg1, ...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_battlefield\\form_battlefield_display", true)
  if not nx_is_valid(form) then
    return
  end
  init_form_lbl(form)
  local temp = nx_number(arg1)
  if 0 <= temp and temp <= 9 then
    form.lbl_3.BackImage = nx_string(SHUZITUPIAN[temp + 1])
    form.lbl_3.Visible = true
    form.lbl_4.Left = form.lbl_3.Left + form.lbl_3.Width
    if temp == 1 then
      form.lbl_4.BackImage = nx_string(SHUZITUPIAN[12])
    elseif 1 < temp then
      form.lbl_4.BackImage = nx_string(SHUZITUPIAN[11])
    end
    form.lbl_4.Visible = true
    form.lbl_5.Visible = true
  elseif 10 <= temp and temp <= 99 then
    form.lbl_2.BackImage = nx_string(SHUZITUPIAN[nx_int(temp / 10) + 1])
    form.lbl_2.Visible = true
    form.lbl_3.Left = form.lbl_2.Left + form.lbl_2.Width
    form.lbl_3.BackImage = nx_string(SHUZITUPIAN[temp % 10 + 1])
    form.lbl_3.Visible = true
    form.lbl_4.Left = form.lbl_3.Left + form.lbl_3.Width
    form.lbl_4.BackImage = nx_string(SHUZITUPIAN[11])
    form.lbl_4.Visible = true
    form.lbl_5.Visible = true
  elseif 100 <= temp and temp <= 999 then
    form.lbl_1.BackImage = nx_string(SHUZITUPIAN[nx_int(temp / 100) + 1])
    form.lbl_1.Visible = true
    form.lbl_2.Left = form.lbl_1.Left + form.lbl_1.Width
    form.lbl_2.BackImage = nx_string(SHUZITUPIAN[nx_int(temp % 100 / 10) + 1])
    form.lbl_2.Visible = true
    form.lbl_3.Left = form.lbl_2.Left + form.lbl_2.Width
    form.lbl_3.BackImage = nx_string(SHUZITUPIAN[temp % 10 + 1])
    form.lbl_3.Visible = true
    form.lbl_4.Left = form.lbl_3.Left + form.lbl_3.Width
    form.lbl_4.BackImage = nx_string(SHUZITUPIAN[11])
    form.lbl_4.Visible = true
    form.lbl_5.Visible = true
    form.Width = form.lbl_4.Left + form.lbl_4.Width
  end
  form.Left = -form.Width * 3 / 2
  form.Top = -form.Height * 11 / 6
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "form_close", form)
    timer:Register(5000, 1, nx_current(), "form_close", form, -1, -1)
  end
  form.Visible = true
  form:Show()
end
function DisplayInfo2()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_battlefield\\form_battlefield_display", true)
  if not nx_is_valid(form) then
    return
  end
  init_form_lbl(form)
  form.lbl_3.BackImage = SHUZITUPIAN[2]
  form.lbl_3.Visible = true
  form.lbl_4.Left = form.lbl_3.Left + form.lbl_3.Width
  form.lbl_4.BackImage = nx_string(SHUZITUPIAN[13])
  form.lbl_4.Visible = true
  form.lbl_5.Visible = true
  form.Left = -form.Width * 3 / 2
  form.Top = -form.Height * 11 / 6
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "form_close", form)
    timer:Register(5000, 1, nx_current(), "form_close", form, -1, -1)
  end
  form.Visible = true
  form:Show()
end
function form_close(self)
  if nx_is_valid(self) then
    self:Close()
  end
end
function init_form_lbl(form)
  form.lbl_1.Visible = false
  form.lbl_2.Visible = false
  form.lbl_3.Visible = false
  form.lbl_4.Visible = false
  form.lbl_5.Visible = false
end
