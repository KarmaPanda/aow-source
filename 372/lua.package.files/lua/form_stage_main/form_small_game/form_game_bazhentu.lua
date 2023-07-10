require("util_functions")
require("util_gui")
local FORM_SELF = "form_stage_main\\form_small_game\\form_game_bazhentu"
local FORM_MAIN = "form_stage_main\\form_main\\form_main"
function main_form_init(form)
  return 1
end
function on_main_form_open(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  local form_main = nx_value(FORM_MAIN)
  if not nx_is_valid(form_main) then
    return
  end
  local btn_bzt = form_main.btn_bzt
  if not nx_is_valid(btn_bzt) then
    return
  end
  if not nx_find_custom(btn_bzt, "group") then
    return
  end
  local group = btn_bzt.group
  if nx_int(group) < nx_int(0) or nx_int(group) > nx_int(3) then
    return
  end
  local lbl_zhentu = form.lbl_zhentu
  if nx_is_valid(lbl_zhentu) then
    lbl_zhentu.BackImage = "gui\\special\\ymsj_bzt\\bg_ymsj_bzt00" .. nx_string(group) .. ".png"
    local btn_close = form.btn_close
    if nx_is_valid(btn_close) then
      form:ToFront(form.btn_close)
    end
  end
  return 1
end
function on_main_form_close(form)
  local form_main = nx_value(FORM_MAIN)
  if not nx_is_valid(form_main) then
    return
  end
  local btn_bzt = form_main.btn_bzt
  if not nx_is_valid(btn_bzt) then
    return
  end
  btn_bzt.Visible = true
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = nx_value(FORM_SELF)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
