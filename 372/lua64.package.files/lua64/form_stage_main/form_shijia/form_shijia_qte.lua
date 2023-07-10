require("util_gui")
local SUB_SERVER_PLAY_OPEN = 0
local SUB_SERVER_PLAY_CLOSE = 1
local SUB_SERVER_PLAY_CLOSE_BTN = 3
local FORM_DANCE = "form_stage_main\\form_shijia\\form_shijia_qte_dance"
function on_msg(sub_cmd, ...)
  if sub_cmd == nil then
    return false
  end
  if nx_int(sub_cmd) == nx_int(SUB_SERVER_PLAY_OPEN) then
    local form_dance = util_get_form(FORM_DANCE, true)
    if not nx_is_valid(form_dance) then
      return
    end
    if arg[1] == nil or arg[2] == nil then
      return
    end
    form_dance.time = nx_int(arg[1])
    form_dance.key_str = nx_string(arg[2])
    if table.getn(arg) >= 3 then
      form_dance.back_image_type = nx_int(arg[3])
    end
    form_dance.Visible = true
    form_dance:Show()
  elseif nx_int(sub_cmd) == nx_int(SUB_SERVER_PLAY_CLOSE) then
    local form_dance = nx_value(FORM_DANCE)
    if nx_is_valid(form_dance) then
      form_dance:Close()
    end
  elseif nx_int(sub_cmd) == nx_int(SUB_SERVER_PLAY_CLOSE_BTN) then
    local form_main = nx_value("form_stage_main\\form_main\\form_main")
    if nx_is_valid(form_main) then
      return
    end
    form_main.btn_sjqte_ready.Visible = false
    form_main.btn_sjqte_quit.Visible = false
  end
end
