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
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2 - 300
  form.Top = (gui.Height - form.Height) / 2 - 150
  form.imagegrid.ClomnNum = 1
  form.count = 0
  form.lbl_value.Text = nx_widestr("0")
  form.imagegrid.ViewRect = "0,0," .. nx_string(form.imagegrid.Width) .. "," .. nx_string(form.imagegrid.Height)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_form_close_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function ok_btn_click(self)
  local form = self.ParentForm
  local event_type
  event_type = ""
  if event_type == "" then
    nx_gen_event(form, "confirm_return", "ok")
  else
  end
  if nx_is_valid(form) then
    form:Close()
  end
  return 1
end
function cancel_btn_click(self)
  local form = self.ParentForm
  local event_type = ""
  if event_type == "" then
    nx_gen_event(form, "confirm_return", "cancel")
  else
    nx_gen_event(form, event_type .. "_" .. "confirm_return", "cancel")
  end
  if nx_is_valid(form) then
    form:Close()
  end
  return 1
end
function on_btn_add_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local price = form.price
  form.count = form.count + 1
  if nx_int(form.count) >= nx_int(10) then
    form.count = 10
  end
  local value = nx_int(form.count) * nx_int(price)
  form.lbl_value.Text = nx_widestr(get_yin_info(nx_int(value)))
end
function on_btn_dec_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local price = form.price
  form.count = form.count - 1
  if nx_int(form.count) <= nx_int(0) then
    form.count = 0
  end
  local value = nx_int(form.count) * nx_int(price)
  if nx_int(value) <= nx_int(0) then
    form.lbl_value.Text = nx_widestr("0")
  else
    form.lbl_value.Text = nx_widestr(get_yin_info(nx_int(value)))
  end
end
function on_imagegrid_skill_mousein_grid(grid, index)
  local skill_configID = grid:GetItemName(index)
  local gui = nx_value("gui")
  if skill_configID == nil or nx_string(skill_configID) == "" then
    return
  end
  local skill_name = gui.TextManager:GetText("tips_budai_" .. nx_string(skill_configID))
  nx_execute("tips_game", "show_text_tip", skill_name, grid:GetMouseInItemLeft() + 5, grid:GetMouseInItemTop() + 5, 0, grid.ParentForm)
end
function on_imagegrid_skill_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function get_yin_info(n)
  local gui = nx_value("gui")
  local capital_manager = nx_value("CapitalModule")
  local res = {}
  local htmlTextYinZi = nx_widestr("")
  if nx_is_valid(capital_manager) then
    res = capital_manager:SplitCapital(nx_int(n), 1)
    local ding = res[1]
    local liang = res[2]
    local wen = res[3]
    local capital = nx_int(n)
    local gui = nx_value("gui")
    local textyZi = nx_widestr("")
    if nx_int(ding) > nx_int(0) then
      local text = gui.TextManager:GetText("ui_ding")
      local htmlText = nx_widestr(nx_widestr(text))
      htmlTextYinZi = htmlTextYinZi .. nx_widestr(nx_int(ding)) .. nx_widestr(htmlText)
    end
    if nx_int(liang) > nx_int(0) then
      local text = gui.TextManager:GetText("ui_liang")
      local htmlText = nx_widestr(nx_widestr(text))
      htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(liang)) .. nx_widestr(htmlText)
    end
    if nx_int(wen) > nx_int(0) then
      local text = gui.TextManager:GetText("ui_wen")
      local htmlText = nx_widestr(nx_widestr(text))
      htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(wen)) .. nx_widestr(htmlText)
    end
    if capital == 0 then
      local text = gui.TextManager:GetText("ui_wen")
      local htmlText = nx_widestr(nx_widestr(text))
      htmlTextYinZi = htmlTextYinZi .. nx_widestr("0") .. nx_widestr(htmlText)
    end
  end
  return htmlTextYinZi
end
