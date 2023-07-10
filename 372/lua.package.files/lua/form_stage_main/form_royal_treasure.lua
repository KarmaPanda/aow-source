require("util_gui")
local FORM_NAME = "form_stage_main\\form_royal_treasure"
local NORMAL_MAP_EFFECT = "9yin_wcbz_bzt_002"
local DELICATE_MAP_EFFECT = "9yin_wcbz_bzt_003"
local FADE_IN = 1
local FADE_OUT = 2
local FADE_RATIO = 300
local STAY_TIME = 1
function on_main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 5
end
function on_main_form_close(form)
  nx_destroy(form)
end
function open_form(config_id)
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  end
  form = util_get_form(FORM_NAME, true)
  form:Show()
  form.Visible = true
  form.ani_1.AnimationImage = get_ani_by_map(config_id)
  form.ani_1.Visible = true
  form.ani_1.Loop = false
  form.ani_1.PlayMode = 0
  nx_callback(form.ani_1, "on_animation_end", "on_ani_end")
end
function on_ani_end(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function get_ani_by_map(config_id)
  if config_id == "item_bzt_001" or config_id == "item_bzt_002" then
    return NORMAL_MAP_EFFECT
  elseif config_id == "item_bzt_003" then
    return DELICATE_MAP_EFFECT
  else
    return ""
  end
end
