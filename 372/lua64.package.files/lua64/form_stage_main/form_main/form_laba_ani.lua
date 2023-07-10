require("util_gui")
local ANI_PAGE_SIZE = 4
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local form_laba_logic = nx_value("form_laba_info")
  if not nx_is_valid(form_laba_logic) then
    return
  end
  form_laba_logic.AniPageSize = ANI_PAGE_SIZE
  form_laba_logic.AniCurrPageIdx = 0
  form_laba_logic:ShowAniPage()
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_movefront_click(btn)
  local form = btn.ParentForm
  local form_laba_logic = nx_value("form_laba_info")
  if not nx_is_valid(form_laba_logic) then
    return
  end
  if 0 == form_laba_logic.AniCurrPageIdx then
    return
  end
  form_laba_logic.AniCurrPageIdx = form_laba_logic.AniCurrPageIdx - 1
  form_laba_logic:ShowAniPage()
end
function on_btn_moveback_click(btn)
  local form = btn.ParentForm
  local form_laba_logic = nx_value("form_laba_info")
  if not nx_is_valid(form_laba_logic) then
    return
  end
  if form_laba_logic.AniCurrPageIdx == form_laba_logic.AniPageCnt - 1 then
    return
  end
  form_laba_logic.AniCurrPageIdx = form_laba_logic.AniCurrPageIdx + 1
  form_laba_logic:ShowAniPage()
end
function on_lbl_ani_click(btn)
  local form_laba_logic = nx_value("form_laba_info")
  if not nx_is_valid(form_laba_logic) then
    return
  end
  local form_laba_info = nx_value("form_stage_main\\form_main\\form_laba_info")
  if not nx_is_valid(form_laba_info) then
    return
  end
  if form_laba_logic:IsAniCanUse(btn.ani_idx) then
    form_laba_logic:ShowAniPreview(btn.ani_idx)
  end
end
function open_select_animation(left, top, hight)
  local form = nx_value("form_stage_main\\form_main\\form_laba_ani")
  if nx_is_valid(form) then
    local gui = nx_value("gui")
    gui.Desktop:ToFront(form)
    return
  end
  local form = util_get_form("form_stage_main\\form_main\\form_laba_ani", true, false, "", true)
  if not nx_is_valid(form) then
    return
  end
  if nil ~= left and nil ~= top and nil ~= hight then
    form.AbsLeft = left
    form.AbsTop = top + hight - form.Height
  end
  form:Show()
end
