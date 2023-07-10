require("util_functions")
require("util_gui")
require("form_stage_main\\form_school_war\\school_war_define")
local school_table_sx = {
  school_jinyiwei = "jy",
  school_gaibang = "gb",
  school_junzitang = "jz",
  school_jilegu = "jl",
  school_tangmen = "tm",
  school_emei = "em",
  school_wudang = "wd",
  school_shaolin = "sl",
  school_mingjiao = "mj",
  school_tianshan = "ts"
}
local form_name = "form_stage_main\\form_school_war\\form_school_war_control"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(self)
  nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 9)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.targetschool = 0
  self.selective_btn = nil
  forbidselfschool(self)
  self.mtb_jy3.HtmlText = nx_widestr("@ui_school_wubaobei")
  self.mtb_gb3.HtmlText = nx_widestr("@ui_school_wubaobei")
  self.mtb_jz3.HtmlText = nx_widestr("@ui_school_wubaobei")
  self.mtb_jl3.HtmlText = nx_widestr("@ui_school_wubaobei")
  self.mtb_tm3.HtmlText = nx_widestr("@ui_school_wubaobei")
  self.mtb_em3.HtmlText = nx_widestr("@ui_school_wubaobei")
  self.mtb_wd3.HtmlText = nx_widestr("@ui_school_wubaobei")
  self.mtb_sl3.HtmlText = nx_widestr("@ui_school_wubaobei")
  self.mtb_mj3.HtmlText = nx_widestr("@ui_school_wubaobei")
  self.mtb_ts3.HtmlText = nx_widestr("@ui_school_wubaobei")
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "close_form", self)
    timer:Register(300000, 1, nx_current(), "close_form", self, -1, -1)
  end
end
function open_form(...)
  for _, j in pairs(sf_school_table) do
    school_table[j].treasureSUM = 0
  end
  refresh(unpack(arg))
end
function refresh(...)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local arg_num = table.getn(arg)
  for i = 1, arg_num / 2 do
    local schoolid = nx_number(arg[(i - 1) * 2 + 1])
    local item_id = nx_string(arg[(i - 1) * 2 + 2])
    school_table[schoolid].treasureSUM = school_table[schoolid].treasureSUM + 1
    local grp_box = form.groupbox_msg:Find(nx_string("groupbox_") .. nx_string(school_table_sx[school_table[schoolid].school]))
    local grp_text = grp_box:Find(nx_string("mtb_") .. nx_string(school_table_sx[school_table[schoolid].school]) .. nx_string("3"))
    if school_table[schoolid].treasureSUM == 1 then
      if nx_string(item_id) ~= nx_string("") then
        grp_text.HtmlText = nx_widestr(gui.TextManager:GetText(item_table[item_id][2])) .. nx_widestr("  ")
      end
    else
      if school_table[schoolid].treasureSUM % 5 == 0 then
        grp_text.HtmlText = nx_widestr(grp_text.HtmlText) .. nx_widestr("<br>")
        grp_text.Top = 5
      end
      if nx_string(item_id) ~= nx_string("") then
        grp_text.HtmlText = nx_widestr(grp_text.HtmlText) .. nx_widestr(gui.TextManager:GetText(item_table[item_id][2])) .. nx_widestr("  ")
      end
    end
  end
  for _, j in pairs(sf_school_table) do
    local grp_box = form.groupbox_msg:Find(nx_string("groupbox_") .. nx_string(school_table_sx[school_table[j].school]))
    local grp_text = grp_box:Find(nx_string("lbl_") .. nx_string(school_table_sx[school_table[j].school]) .. nx_string("2"))
    local Text, ForeColor = refresh_sl(school_table[j].treasureSUM)
    grp_text.Text = nx_widestr(Text)
    grp_text.ForeColor = nx_string(ForeColor)
  end
end
function refresh_sl(lv)
  if lv == 0 then
    return nx_widestr("@ui_schoolwar_rou"), "255,0,139,69"
  elseif lv == 1 or lv == 2 then
    return nx_widestr("@ui_schoolwar_putong"), "255,0,0,128"
  elseif 3 <= lv then
    return nx_widestr("@ui_schoolwar_qiang"), "255,178,34,34"
  end
end
function on_main_form_close(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "close_form", form)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  return
end
function on_btn_start_school_war_click(btn)
  local form = btn.ParentForm
  if form.targetschool ~= 0 then
    nx_execute("custom_sender", "custom_send_Request_Declare_Fight", nx_int(form.targetschool))
  end
end
function on_btn_click(btn)
  local form = btn.ParentForm
  if btn.Name == "btn_shaolin" then
    form.targetschool = sf_school_shaolin
  elseif btn.Name == "btn_wudang" then
    form.targetschool = sf_school_wudang
  elseif btn.Name == "btn_emei" then
    form.targetschool = sf_school_emei
  elseif btn.Name == "btn_gaibang" then
    form.targetschool = sf_school_gaibang
  elseif btn.Name == "btn_tangmen" then
    form.targetschool = sf_school_tangmen
  elseif btn.Name == "btn_junzi" then
    form.targetschool = sf_school_junzi
  elseif btn.Name == "btn_jinyi" then
    form.targetschool = sf_school_jinyi
  elseif btn.Name == "btn_jile" then
    form.targetschool = sf_school_jile
  elseif btn.Name == "btn_mingjiao" then
    form.targetschool = sf_school_mingjiao
  elseif btn.Name == "btn_tianshan" then
    form.targetschool = sf_school_tianshan
  end
end
function forbidselfschool(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local playerschool = client_player:QueryProp("School")
  local btn_name = ""
  if playerschool == "school_jinyiwei" then
    btn_name = "btn_jinyi"
  elseif playerschool == "school_gaibang" then
    btn_name = "btn_gaibang"
  elseif playerschool == "school_junzitang" then
    btn_name = "btn_junzi"
  elseif playerschool == "school_jilegu" then
    btn_name = "btn_jile"
  elseif playerschool == "school_tangmen" then
    btn_name = "btn_tangmen"
  elseif playerschool == "school_emei" then
    btn_name = "btn_emei"
  elseif playerschool == "school_wudang" then
    btn_name = "btn_wudang"
  elseif playerschool == "school_shaolin" then
    btn_name = "btn_shaolin"
  elseif playerschool == "school_mingjiao" then
    btn_name = "btn_mingjiao"
  elseif playerschool == "school_tianshan" then
    btn_name = "btn_tianshan"
  end
  if btn_name == "" then
    return
  end
  local school_btn = form.groupbox_msg:Find(btn_name)
  if nx_is_valid(school_btn) then
    school_btn.Enabled = false
  end
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", form_name, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
