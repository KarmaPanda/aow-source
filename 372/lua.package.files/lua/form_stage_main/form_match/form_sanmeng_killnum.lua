local FORM_SANMENG_KILLNUM = "form_stage_main\\form_match\\form_sanmeng_killnum"
local SHUZITUPIAN = {
  "gui\\special\\clone\\0.png",
  "gui\\special\\clone\\1.png",
  "gui\\special\\clone\\2.png",
  "gui\\special\\clone\\3.png",
  "gui\\special\\clone\\4.png",
  "gui\\special\\clone\\5.png",
  "gui\\special\\clone\\6.png",
  "gui\\special\\clone\\7.png",
  "gui\\special\\clone\\8.png",
  "gui\\special\\clone\\9.png"
}
function main_form_init(self)
  self.Fixed = false
  self.Visible = true
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Visible = true
  self.lbl_1.Visible = false
  self.lbl_2.Visible = false
  self.lbl_3.Visible = false
  self.lbl_4.Visible = false
  self.lbl_zg.Visible = false
  self.lbl_zg_unit.Visible = false
  self.lbl_zg_decade.Visible = false
  self.lbl_zg_hundred.Visible = false
  return 1
end
function main_form_close(self)
  nx_destroy(self)
end
function refresh_killnum(kill_num)
  local form = nx_null()
  local kill_count = nx_number(kill_num)
  if kill_count < 0 then
    form = nx_execute("util_gui", "util_get_form", FORM_SANMENG_KILLNUM, false)
  else
    form = nx_execute("util_gui", "util_get_form", FORM_SANMENG_KILLNUM, true)
  end
  if not nx_is_valid(form) then
    return 0
  end
  if kill_count < 0 then
    form:Close()
    return 0
  end
  nx_execute("util_gui", "util_show_form", FORM_SANMENG_KILLNUM, true)
  if 0 <= kill_count and kill_count <= 9 then
    form.lbl_1.Visible = true
    form.lbl_4.Left = form.lbl_1.Width
    form.lbl_4.BackImage = nx_string(SHUZITUPIAN[kill_count + 1])
    form.lbl_4.Visible = true
    form.lbl_2.Visible = false
    form.lbl_3.Visible = false
  elseif 10 <= kill_count and kill_count <= 99 then
    form.lbl_1.Visible = true
    form.lbl_3.Left = form.lbl_1.Width
    form.lbl_3.BackImage = nx_string(SHUZITUPIAN[nx_int(kill_count / 10) + 1])
    form.lbl_3.Visible = true
    form.lbl_4.Left = form.lbl_1.Width + form.lbl_3.Width
    form.lbl_4.BackImage = nx_string(SHUZITUPIAN[kill_count % 10 + 1])
    form.lbl_4.Visible = true
    form.lbl_2.Visible = false
  elseif 100 <= kill_count and kill_count <= 999 then
    form.lbl_1.Visible = true
    form.lbl_2.Left = form.lbl_1.Width
    form.lbl_2.BackImage = nx_string(SHUZITUPIAN[nx_int(kill_count / 100) + 1])
    form.lbl_2.Visible = true
    form.lbl_3.Left = form.lbl_1.Width + form.lbl_2.Width
    form.lbl_3.BackImage = nx_string(SHUZITUPIAN[nx_int(kill_count % 100 / 10) + 1])
    form.lbl_3.Visible = true
    form.lbl_4.Left = form.lbl_1.Width + form.lbl_2.Width + form.lbl_3.Width
    form.lbl_4.BackImage = nx_string(SHUZITUPIAN[kill_count % 10 + 1])
    form.lbl_4.Visible = true
  end
end
function refresh_zhugong_num(zg_num)
  local form = nx_null()
  local zg_count = nx_number(zg_num)
  if nx_int(zg_count) < nx_int(0) then
    form = nx_execute("util_gui", "util_get_form", FORM_SANMENG_KILLNUM, false)
  else
    form = nx_execute("util_gui", "util_get_form", FORM_SANMENG_KILLNUM, true)
  end
  if not nx_is_valid(form) then
    return 0
  end
  if nx_int(zg_count) < nx_int(0) then
    form:Close()
    return 0
  end
  nx_execute("util_gui", "util_show_form", FORM_SANMENG_KILLNUM, true)
  if nx_int(zg_count) >= nx_int(0) and nx_int(zg_count) <= nx_int(9) then
    form.lbl_zg.Visible = true
    form.lbl_zg_unit.Left = form.lbl_zg.Width
    form.lbl_zg_unit.BackImage = nx_string(SHUZITUPIAN[zg_count + 1])
    form.lbl_zg_unit.Visible = true
    form.lbl_zg_decade.Visible = false
    form.lbl_zg_hundred.Visible = false
  elseif nx_int(zg_count) >= nx_int(10) and nx_int(zg_count) <= nx_int(99) then
    form.lbl_zg.Visible = true
    form.lbl_zg_decade.Left = form.lbl_zg.Width
    form.lbl_zg_decade.BackImage = nx_string(SHUZITUPIAN[nx_int(zg_count / 10) + 1])
    form.lbl_zg_decade.Visible = true
    form.lbl_zg_unit.Left = form.lbl_zg.Width + form.lbl_zg_decade.Width
    form.lbl_zg_unit.BackImage = nx_string(SHUZITUPIAN[zg_count % 10 + 1])
    form.lbl_zg_unit.Visible = true
    form.lbl_zg_hundred.Visible = false
  elseif nx_int(zg_count) >= nx_int(100) and nx_int(zg_count) <= nx_int(999) then
    form.lbl_zg.Visible = true
    form.lbl_zg_hundred.Left = form.lbl_zg.Width
    form.lbl_zg_hundred.BackImage = nx_string(SHUZITUPIAN[nx_int(zg_count / 100) + 1])
    form.lbl_zg_hundred.Visible = true
    form.lbl_zg_decade.Left = form.lbl_zg.Width + form.lbl_zg_hundred.Width
    form.lbl_zg_decade.BackImage = nx_string(SHUZITUPIAN[nx_int(zg_count % 100 / 10) + 1])
    form.lbl_zg_decade.Visible = true
    form.lbl_zg_unit.Left = form.lbl_zg.Width + form.lbl_zg_hundred.Width + form.lbl_zg_decade.Width
    form.lbl_zg_unit.BackImage = nx_string(SHUZITUPIAN[zg_count % 10 + 1])
    form.lbl_zg_unit.Visible = true
  end
end
