local INFO_TYPE_PLACE_HOLDER = 0
local INFO_TYPE_BANG_FEI = 1
local INFO_TYPE_HAI_BU = 2
local INFO_TYPE_LEI_TAI = 3
local INFO_TYPE_DUO_SHU = 4
local INFO_TYPE_CI_TAN = 5
local INFO_TYPE_MEN_PAI = 6
local INFO_TYPE_SET_FIRE = 7
local INFO_TYPE_YUN_BIAO = 8
local INFO_TYPE_BANG_PAI = 9
local INFO_TYPE_JIN_DI = 10
local INFO_TYPE_TI_GUAN = 11
local INFO_TYPE_LAO_YU = 12
function auto_show_hide_general_info()
  local form = nx_value("form_stage_main\\form_main\\form_main_general_info")
  if not nx_is_valid(form) then
    nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_main\\form_main_general_info")
  else
    form.Visible = not form.Visible
  end
  reset_form_pos(form)
end
function reset_scene()
  local form = nx_value("form_stage_main\\form_main\\form_main_general_info")
  if not nx_is_valid(form) then
    auto_show_hide_general_info()
  end
  local form = nx_value("form_stage_main\\form_main\\form_main_general_info")
  if nx_is_valid(form) then
    form.Visible = false
  end
end
function add_info(id, content)
  local form_logic = nx_value("form_main_general_info_logic")
  if nx_is_valid(form_logic) then
    form_logic:AddInfo(id, content)
  end
end
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  self.groupbox_alpha.Visible = false
  self.groupbox_filter.Visible = false
  local form_logic = nx_value("form_main_general_info_logic")
  if nx_is_valid(form_logic) and nx_find_method(form_logic, "InitForm") then
    form_logic:InitForm()
  end
  set_general_info_filter(self)
  local ini = get_general_info_filter_ini()
  if nx_is_valid(ini) then
    self.groupbox_active.Visible = 1 == ini:ReadInteger("Config", "ShowMax", 1)
    local alpha = ini:ReadInteger("Config", "Alpha", 60)
    set_alpha(self.tbar_alpha, nx_number(alpha))
  end
  update_form_size(self)
  reset_form_pos(self)
end
function on_main_form_close(self)
  local ini = get_general_info_filter_ini()
  if nx_is_valid(ini) then
    ini:SaveToFile()
    nx_destroy(ini)
  end
  nx_destroy(self)
end
function on_btn_hide_click(self)
  local form = self.ParentForm
  form.Visible = false
end
function on_cbtn_info_filter_checked_changed(self)
  local form_logic = nx_value("form_main_general_info_logic")
  if nx_is_valid(form_logic) then
    form_logic:ShowActiveInfo(self.info_type, self.Checked)
  end
  local ini = get_general_info_filter_ini()
  if nx_is_valid(ini) then
    ini:WriteInteger("Filter", self.info_name, self.Checked)
  end
end
function set_general_info_filter(form)
  local ini = get_general_info_filter_ini()
  if not nx_is_valid(ini) then
    return
  end
  form.cbtn_bangfei.info_name = "BangFei"
  form.cbtn_bangfei.info_type = INFO_TYPE_BANG_FEI
  form.cbtn_haibu.info_name = "HaiBu"
  form.cbtn_haibu.info_type = INFO_TYPE_HAI_BU
  form.cbtn_leitai.info_name = "LeiTai"
  form.cbtn_leitai.info_type = INFO_TYPE_LEI_TAI
  form.cbtn_duoshu.info_name = "DuoShu"
  form.cbtn_duoshu.info_type = INFO_TYPE_DUO_SHU
  form.cbtn_citan.info_name = "CiTan"
  form.cbtn_citan.info_type = INFO_TYPE_CI_TAN
  form.cbtn_menpai.info_name = "MenPai"
  form.cbtn_menpai.info_type = INFO_TYPE_MEN_PAI
  form.cbtn_fanghuo.info_name = "FangHuo"
  form.cbtn_fanghuo.info_type = INFO_TYPE_SET_FIRE
  form.cbtn_yunbiao.info_name = "YunBiao"
  form.cbtn_yunbiao.info_type = INFO_TYPE_YUN_BIAO
  form.cbtn_bangpai.info_name = "BangPai"
  form.cbtn_bangpai.info_type = INFO_TYPE_BANG_PAI
  form.cbtn_jindi.info_name = "JinDi"
  form.cbtn_jindi.info_type = INFO_TYPE_JIN_DI
  form.cbtn_tiguan.info_name = "TiGuan"
  form.cbtn_tiguan.info_type = INFO_TYPE_TI_GUAN
  form.cbtn_laoyu.info_name = "LaoYu"
  form.cbtn_laoyu.info_type = INFO_TYPE_LAO_YU
  local table_cbtns = {
    form.cbtn_bangfei,
    form.cbtn_haibu,
    form.cbtn_leitai,
    form.cbtn_duoshu,
    form.cbtn_citan,
    form.cbtn_menpai,
    form.cbtn_fanghuo,
    form.cbtn_yunbiao,
    form.cbtn_bangpai,
    form.cbtn_jindi,
    form.cbtn_tiguan,
    form.cbtn_laoyu
  }
  for _, cbtn in ipairs(table_cbtns) do
    cbtn.Checked = 1 == ini:ReadInteger("Filter", cbtn.info_name, 1)
  end
end
function get_general_info_filter_ini()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return nx_null()
  end
  if not nx_find_property(game_config, "login_account") then
    return nx_null()
  end
  local account = game_config.login_account
  local ini = nx_value("general_info_filter_ini")
  if not nx_is_valid(ini) then
    ini = nx_create("IniDocument")
    ini.FileName = account .. "\\" .. "general_info_filter.ini"
    ini:LoadFromFile()
    nx_set_value("general_info_filter_ini", ini)
  end
  return ini
end
function update_form_size(form)
  local abs_top = form.groupbox_tool.AbsTop + form.groupbox_tool.Height
  if form.groupbox_fixed.Visible then
    form.groupbox_fixed.AbsTop = abs_top
    form.groupbox_bot.AbsTop = form.groupbox_fixed.AbsTop + form.groupbox_fixed.Height
  end
  if form.groupbox_active.Visible then
    form.Height = form.groupbox_bot.Height + form.groupbox_fixed.Height + 50
  else
    form.Height = form.groupbox_fixed.Height + 100 + 180
  end
end
function on_btn_lock_click(self)
  local form = self.ParentForm
  local multibox = form.multibox_active
  multibox.AutoScroll = not multibox.AutoScroll
  self.Visible = false
  form.btn_unlock.Visible = true
end
function on_btn_unlock_click(self)
  local form = self.ParentForm
  local multibox = form.multibox_active
  multibox.AutoScroll = not multibox.AutoScroll
  self.Visible = false
  form.btn_lock.Visible = true
end
function on_btn_filter_click(self)
  local form = self.ParentForm
  form.groupbox_filter.Visible = not form.groupbox_filter.Visible
  form.groupbox_filter.AbsLeft = self.AbsLeft - form.groupbox_filter.Width
  form.groupbox_filter.AbsTop = self.AbsTop + 10
end
function on_btn_show_active_click(self)
  local form = self.ParentForm
  form.groupbox_active.Visible = not form.groupbox_active.Visible
  if not form.groupbox_active.Visible then
    self.NormalImage = "gui\\common\\scrollbar\\button_1\\btn_down_out.png"
    self.FocusImage = "gui\\common\\scrollbar\\button_1\\btn_down_on.png"
    self.CheckedImage = "gui\\common\\scrollbar\\button_1\\btn_down_down.png"
  else
    self.NormalImage = "gui\\common\\scrollbar\\button_1\\btn_up_out.png"
    self.FocusImage = "gui\\common\\scrollbar\\button_1\\btn_up_on.png"
    self.CheckedImage = "gui\\common\\scrollbar\\button_1\\btn_up_down.png"
  end
  local ini = get_general_info_filter_ini()
  if nx_is_valid(ini) then
    ini:WriteInteger("Config", "ShowMax", form.groupbox_active.Visible)
  end
  if form.groupbox_filter.Visible then
    form.groupbox_filter.Visible = false
  end
  update_form_size(form)
end
function on_btn_end_click(self)
  local form = self.ParentForm
  form.multibox_active:GotoEnd()
end
function on_multibox_active_vscroll_changed(self)
  if math.abs(self.VerticalMaxValue - self.VerticalValue) < 2 then
    self.AutoScroll = true
  else
    self.AutoScroll = false
  end
end
function on_btn_alpha_click(btn)
  local form = btn.ParentForm
  form.groupbox_alpha.Visible = not form.groupbox_alpha.Visible
  form.groupbox_alpha.AbsLeft = btn.AbsLeft - form.groupbox_alpha.Width
  form.groupbox_alpha.AbsTop = btn.AbsTop - 3
end
function on_tbar_alpha_value_changed(self)
  local form = self.ParentForm
  local lbl = form.lbl_p
  lbl.Top = self.Top
  lbl.Left = self.Left
  local length = self.TrackButton.Left
  if 5 < length then
    length = length + 3
  end
  lbl.Width = length
  local num = nx_int(self.Value / (self.Maximum - self.Minimum) * 100)
  if num == nx_int(0) then
    lbl.Visible = false
  else
    lbl.Visible = true
  end
  form.lbl_num.Text = nx_widestr(nx_string(num) .. nx_string("%"))
  local alpha = num / 100 * 255
  if 100 <= alpha and alpha <= 255 then
    local both_list = {
      form.groupbox_fixed,
      form.groupbox_active
    }
    for _, groupbox in ipairs(both_list) do
      groupbox.BlendAlpha = alpha
    end
  end
  local ini = get_general_info_filter_ini()
  if nx_is_valid(ini) then
    ini:WriteInteger("Config", "Alpha", nx_int(alpha))
  end
end
function set_alpha(control, alpha)
  control.Value = nx_int((control.Maximum - control.Minimum) * alpha / 255)
end
function reset_form_pos(form)
  if nx_is_valid(form) then
    form.Top = 40
    form.Left = -form.Width - 280
  end
end
