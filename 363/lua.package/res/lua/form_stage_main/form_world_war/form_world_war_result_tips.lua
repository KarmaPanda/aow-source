require("util_gui")
local FORM_NAME = "form_stage_main\\form_world_war\\form_world_war_result_tips"
local RESULT_PIC = {
  [400] = {
    [0] = "gui\\language\\ChineseS\\worldwar\\lbjs.png",
    [1] = "gui\\language\\ChineseS\\worldwar\\dmyyjsl.png",
    [2] = "gui\\language\\ChineseS\\worldwar\\xmfgjsl.png"
  },
  [401] = {
    [0] = "gui\\language\\ChineseS\\worldwar\\lxcpj.png",
    [1] = "gui\\language\\ChineseS\\worldwar\\lxcsl.png",
    [2] = "gui\\language\\ChineseS\\worldwar\\lxcxssysl.png",
    [3] = "gui\\language\\ChineseS\\worldwar\\lxcblgsl.png",
    [4] = "gui\\language\\ChineseS\\worldwar\\lxcxdmsl.png"
  }
}
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2 - 100
  gui.Desktop:ToFront(form)
  local timer = nx_value(GAME_TIMER)
  timer:Register(10000, -1, nx_current(), "close_self", form, -1, -1)
end
function close_self(form, param1, param2)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "close_self", form)
  end
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function open_form(...)
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    form:Close()
    return
  end
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  if table.getn(arg) <= 0 then
    return
  end
  local result = arg[1]
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local scene = game_client:GetScene()
  if not nx_is_valid(scene) then
    return
  end
  local scene_id = nx_number(scene:QueryProp("SourceID"))
  local info = RESULT_PIC[scene_id]
  if info == nil then
    return
  end
  if info[result] == nil then
    return
  end
  form.lbl_result.BackImage = nx_string(info[result])
  form.lbl_result.Left = (form.Width - form.lbl_result.Width) / 2
  form.lbl_result.Top = (form.Height - form.lbl_result.Height) / 2
end
