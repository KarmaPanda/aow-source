require("util_gui")
require("util_functions")
require("form_stage_main\\form_tvt\\define")
local g_form_name = "form_stage_main\\form_tvt\\form_tvt_skill"
local g_tvtskills = {
  [TVT_SKILL_SOUCHA] = {
    normal = "icon\\skill\\spy_soucha.png",
    focus = "icon\\skill\\spy_soucha_on.png",
    push = "icon\\skill\\spy_soucha_down.png"
  },
  [TVT_SKILL_KDSOUCHA] = {
    normal = "icon\\skill\\spy_shipo.png",
    focus = "icon\\skill\\spy_shipo_on.png",
    push = "icon\\skill\\spy_shipo_down.png"
  },
  [TVT_SKILL_TOUDAO] = {
    normal = "icon\\skill\\spy_toudao.png",
    focus = "icon\\skill\\spy_toudao_on.png",
    push = "icon\\skill\\spy_toudao_down.png"
  },
  [TVT_SKILL_TOUXI] = {
    normal = "icon\\skill\\spy_touxi.png",
    focus = "icon\\skill\\spy_touxi_on.png",
    push = "icon\\skill\\spy_touxi_down.png"
  },
  [TVT_SKILL_GANGRAO] = {
    normal = "icon\\skill\\spy_tanlu.png",
    focus = "icon\\skill\\spy_tanlu_on.png",
    push = "icon\\skill\\spy_tanlu_down.png"
  },
  [TVT_SKILL_1] = {
    normal = "icon\\qianru\\qianru06.png",
    focus = "icon\\qianru\\qianru06.png",
    push = "icon\\qianru\\qianru06_down.png"
  },
  [TVT_SKILL_2] = {
    normal = "icon\\qianru\\qianru07.png",
    focus = "icon\\qianru\\qianru07.png",
    push = "icon\\qianru\\qianru07_down.png"
  },
  [TVT_SKILL_3] = {
    normal = "icon\\qianru\\qianru01.png",
    focus = "icon\\qianru\\qianru01.png",
    push = "icon\\qianru\\qianru01_down.png"
  },
  [TVT_SKILL_4] = {
    normal = "icon\\qianru\\qianru02.png",
    focus = "icon\\qianru\\qianru02.png",
    push = "icon\\qianru\\qianru02_down.png"
  },
  [TVT_SKILL_5] = {
    normal = "icon\\qianru\\qianru03.png",
    focus = "icon\\qianru\\qianru03.png",
    push = "icon\\qianru\\qianru03_down.png"
  }
}
function on_main_form_init(form)
  form.Fixed = false
  nx_set_custom(form, "type", nx_int(-1))
  refurbish()
end
function show_tvt_skill()
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    form = util_get_form(g_form_name, true, false)
  end
  if not nx_is_valid(form) then
    return
  end
  local delay_timer = nx_value("timer_game")
  delay_timer:UnRegister(nx_current(), "on_delay_show_form_time", form)
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
    delay_timer:Register(5000, -1, nx_current(), "on_delay_show_form_time", form, -1, -1)
  else
    util_show_form(g_form_name, true)
  end
end
function on_delay_show_form_time(form)
  if not nx_is_valid(form) then
    return
  end
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
    return
  end
  util_show_form(g_form_name, true)
  local delay_timer = nx_value("timer_game")
  delay_timer:UnRegister(nx_current(), "on_delay_show_form_time", form)
end
function refurbish()
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form) then
    form = nx_value("form_stage_main\\form_tvt\\form_tvt_skill")
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 1.3
end
function on_main_form_open(form)
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return
  end
  local type = mgr:GetCurrentTvtType()
  local count = mgr:GetTvtSkillCount(type)
  if count == nil or count == 0 then
    util_show_form(g_form_name, false)
    return
  end
  if form.type == nil or form.type ~= type then
    create_form(form)
  end
  form.type = type
  local databinder = nx_value("data_binder")
  if type == 136 or type == 137 then
    databinder:AddRolePropertyBind("StealInFindedValue", "int", form, nx_current(), "on_spyvalue_changed")
    local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
    local itemskill_shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut_itemskill")
    if nx_is_valid(shortcut_grid) and shortcut_grid.Visible == true then
      shortcut_grid.Visible = false
    end
    if nx_is_valid(itemskill_shortcut_grid) and itemskill_shortcut_grid.Visible == true then
      itemskill_shortcut_grid.Visible = false
    end
  else
    databinder:AddRolePropertyBind("OfflineInteractStatus", "int", form, nx_current(), "on_spyvalue_changed")
  end
end
function create_form(form)
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return
  end
  local type = mgr:GetCurrentTvtType()
  if type == nil or type == -1 then
    util_show_form(g_form_name, false)
    return
  end
  local count = mgr:GetTvtSkillCount(type)
  if count == nil or count == 0 then
    util_show_form(g_form_name, false)
    return
  end
  if type == 0 or type == 136 or type == 137 then
    form.groupbox_1.Visible = true
    form.lbl_value.Text = nx_widestr("0")
    form.lbl_plan.Width = 0
    form.Height = 94
  else
    form.groupbox_1.Visible = false
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local group = form.groupbox_skill
  group:DeleteAll()
  local group_cool = form.groupbox_cool
  group_cool:DeleteAll()
  for i = 1, count do
    local skill = mgr:GetTvtSkill(type, i - 1)
    local cooltm = mgr:GetTvtSkillCoolTm(type, i - 1)
    local lbl = gui:Create("Label")
    group_cool:Add(lbl)
    lbl.Width = 36
    lbl.Height = 1
    lbl.Left = 20 + 60 * (i - 1)
    lbl.Top = 11
    lbl.Visible = false
    lbl.VAnchor = Bottom
    lbl.Solid = true
    lbl.BackColor = "170,128,128,128"
    local btn = gui:Create("Button")
    group:Add(btn)
    btn.Width = 36
    btn.Height = 36
    btn.Left = 20 + 60 * (i - 1)
    btn.Top = 11
    btn.Font = "font_main"
    btn.ShadowColor = "0,20,0,0"
    btn.FocusColor = "0,100,0,0"
    btn.PushColor = "0,0,100,0"
    local cfg = g_tvtskills[skill]
    if cfg ~= nil then
      btn.NormalImage = cfg.normal
      btn.FocusImage = cfg.focus
      btn.PushImage = cfg.push
      btn.DrawMode = "FitWindow"
    end
    nx_bind_script(btn, nx_current())
    nx_callback(btn, "on_click", "on_btn_skill_click")
    nx_callback(btn, "on_lost_capture", "on_btn_skill_lost_capture")
    nx_callback(btn, "on_get_capture", "on_btn_skill_get_capture")
    nx_set_custom(btn, "skill", skill)
    nx_set_custom(btn, "cooltime", nx_int(0))
    nx_set_custom(btn, "delay", nx_int(0))
    nx_set_custom(btn, "maxcooltime", nx_int(cooltm))
    nx_set_custom(btn, "tvttype", type)
    nx_set_custom(btn, "coollabel", lbl)
  end
  refurbish()
end
function on_main_form_close(form)
  if form.type == 136 or form.type == 137 then
    local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
    local itemskill_shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut_itemskill")
    if nx_is_valid(shortcut_grid) and shortcut_grid.Visible == false then
      shortcut_grid.Visible = true
    end
    if nx_is_valid(itemskill_shortcut_grid) and itemskill_shortcut_grid.Visible == false then
      itemskill_shortcut_grid.Visible = true
    end
  end
  form.type = -1
  nx_destroy(form)
end
function on_spyvalue_changed(form, ...)
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  local spyval = form.lbl_value
  spyval.Text = nx_widestr(arg[3])
  local lblplan = form.lbl_plan
  lblplan.Width = nx_int(arg[3]) / 100 * nx_int(form.lbl_14.Width)
end
function add_spy_val(num)
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  local spyval = form.lbl_value
  spyval.Text = nx_widestr(num)
  local lblplan = form.lbl_plan
  lblplan.Width = nx_int(num) / 100 * nx_int(form.lbl_14.Width)
end
function cool_btn(name)
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  local group = form.groupbox_skill
  local tab = group:GetChildControlList()
  for i = 1, table.getn(tab) do
    local btn = tab[i]
    if btn.skill == name then
      btn.cooltime = btn.maxcooltime
      btn.Enabled = true
    end
  end
end
function on_btn_skill_click(btn)
  local skill = btn.skill
  local type = btn.tvttype
  send_server_msg(g_msg_useskill, type, nx_string(skill))
  if btn.delay <= 2 then
    btn.Enabled = false
    btn.delay = 2
  end
  nx_execute("tips_game", "hide_tip", btn.ParentForm)
end
function on_btn_skill_get_capture(btn)
  local gui = nx_value("gui")
  local func_manager = nx_value("func_manager")
  local x = btn.AbsLeft
  local y = btn.AbsTop
  local gui = nx_value("gui")
  nx_execute("tips_game", "show_tips_common", btn.skill, 1018, gui.Width - 10, gui.Height - 40, btn.ParentForm)
end
function on_btn_skill_lost_capture(btn)
  nx_execute("tips_game", "hide_tip", btn.ParentForm)
end
