require("util_static_data")
require("util_functions")
local LIEZHEN_INI_PATH = "ini\\ui\\wuxue\\zhenfa_liezhen.ini"
local LIEZHEN_SKILL_INI_PATH = "share\\Skill\\skill_new.ini"
local liezhen_space_animation = false
function main_form_init(self)
  self.Fixed = true
  return 1
end
function on_main_form_open(self)
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(shortcut_grid) then
    return
  end
  shortcut_grid.Visible = false
  change_form_size()
  local form = self
  local label_block = form.lbl_skill_block
  local formWidth = form.Width
  local pos = label_block.Left + label_block.Width
  if formWidth <= pos then
    label_block.Left = 0
  end
  label_block.Left = label_block.Left + 2
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:Register(50, -1, nx_current(), "timer_callback", self, 0, 0)
  end
  self.is_new_game = true
end
function on_main_form_close(self)
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(shortcut_grid) then
    return
  end
  shortcut_grid.Visible = true
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "timer_callback", self)
  end
  nx_destroy(self)
  nx_set_value(nx_current(), nx_null())
end
function show_form(begin_id)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main_shortcut_liezhen_member", true)
  if not nx_is_valid(form) then
    return
  end
  local photo_res = ""
  local skillini = nx_execute("util_functions", "get_ini", LIEZHEN_SKILL_INI_PATH)
  if not nx_is_valid(skillini) then
    hide_form()
    return
  end
  if skillini:FindSection(nx_string(begin_id)) then
    local sec_index = skillini:FindSectionIndex(nx_string(begin_id))
    if 0 <= sec_index then
      local static_data = skillini:ReadInteger(sec_index, "StaticData", 0)
      photo_res = skill_static_query(static_data, "Photo")
    end
  end
  local label_block = form.lbl_skill_block
  label_block.BackImage = photo_res
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_main\\form_main_shortcut_liezhen_member", true)
end
function hide_form()
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_liezhen_member")
  if nx_is_valid(form) then
    form:Close()
  end
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_liezhen_member")
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = gui.Width / 2 - form.Width / 2
  form.Top = shortcut_grid.groupbox_shortcut_1.AbsTop - form.Height + 86
end
function timer_callback(form, para1, para2)
  local label_block = form.lbl_skill_block
  local label_space = form.lbl_space
  local formWidth = form.Width
  local pos = label_block.Left + label_block.Width
  if pos >= formWidth - 80 then
    label_block.Left = 80
    form.is_new_game = true
    label_space.BackImage = "gui\\animations\\liezhen\\liezhen_space_on.png"
  end
  if label_block.Left >= 455 and not liezhen_space_animation then
    label_space.BackImage = "liezhen_space"
    liezhen_space_animation = true
  end
  if label_block.Left >= 470 and liezhen_space_animation then
    label_space.BackImage = "gui\\animations\\liezhen\\liezhen_space_on.png"
    liezhen_space_animation = false
  end
  label_block.Left = label_block.Left + 2
end
function on_space_up()
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_liezhen_member")
  if not nx_is_valid(form) then
    return false
  end
  if not form.Visible then
    return false
  end
  if not form.is_new_game then
    return true
  end
  local label_block = form.lbl_skill_block
  ani_res = form.ani_result
  ani_res.Visible = true
  if label_block.Left >= 460 and label_block.Left <= 470 then
    ani_res.AnimationImage = "liezhen_win"
    ani_res.Loop = false
    ani_res.PlayMode = 0
    nx_execute("custom_sender", "custom_send_liezhen_skill", 2, "")
  else
    ani_res.AnimationImage = "liezhen_fail"
    ani_res.Loop = false
    ani_res.PlayMode = 0
    nx_execute("custom_sender", "custom_send_liezhen_skill", 2, "")
  end
  form.is_new_game = false
  return true
end
