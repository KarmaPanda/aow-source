require("form_stage_main\\form_marry\\form_marry_util")
local OPERATOR_TYPE_GATHER = 1
local OERRATOR_TYPE_ATTACK = 2
local OERRATOR_TYPE_PROTECT = 3
function main_form_init(form)
  form.Fixed = false
  form.npc = nil
end
function on_main_form_open(form)
  set_form_pos(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function show_data(npc, is_mast, count, cost, man_name, woman_name)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", FORM_MARRY_DESK, true)
  if not nx_is_valid(form) then
    return
  end
  if form.npc ~= nil then
    return
  end
  form.npc = npc
  init_btn_visible(form)
  if nx_number(is_mast) == 1 then
    form.btn_marry_protect.Visible = true
  elseif nx_number(is_mast) == 0 then
    form.btn_marry_eat.Visible = true
    form.btn_marry_attack.Visible = true
  end
  local show_id = "ui_marry_desk_operator_" .. nx_string(is_mast)
  local desc = gui.TextManager:GetFormatText(show_id, nx_int(count), nx_int(cost), man_name, woman_name)
  form.mltbox_info:AddHtmlText(desc, -1)
  util_show_form(FORM_MARRY_DESK, true)
end
function init_btn_visible(form)
  form.btn_marry_eat.Visible = false
  form.btn_marry_attack.Visible = false
  form.btn_marry_protect.Visible = false
end
function on_btn_marry_eat_click(btn)
  local form = btn.ParentForm
  custom_marry(CLIENT_MSG_SUB_WINE_DESK, form.npc, OPERATOR_TYPE_GATHER)
  on_btn_close_click(btn)
end
function on_btn_marry_attack_click(btn)
  local form = btn.ParentForm
  custom_marry(CLIENT_MSG_SUB_WINE_DESK, form.npc, OERRATOR_TYPE_ATTACK)
  on_btn_close_click(btn)
end
function on_btn_marry_protect_click(btn)
  local form = btn.ParentForm
  custom_marry(CLIENT_MSG_SUB_WINE_DESK, form.npc, OERRATOR_TYPE_PROTECT)
  on_btn_close_click(btn)
end
