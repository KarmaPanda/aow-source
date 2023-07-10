require("util_functions")
require("util_gui")
require("define\\laba_define")
require("form_stage_main\\form_school_war\\school_war_define")
local form_name = "form_stage_main\\form_school_war\\form_school_fight_info"
local AttackWar = "ui_xiaolaba_special_attack"
local DefendWar = "ui_xiaolaba_special_defend"
local result_table = {
  [0] = "ui_schoolfight_info_ready",
  [1] = "ui_schoolfight_info_begin",
  [2] = "ui_schoolfight_info_ending"
}
local phase_table = {
  [0] = "ui_schoolfight_info_ready",
  [1] = "ui_schoolfight_info_ready",
  [2] = "ui_schoolfight_info_fighting",
  [3] = "end"
}
local desc_info = {
  "ui_schoolwar_cause_01",
  "ui_schoolwar_cause_02",
  "ui_schoolwar_cause_03",
  "ui_schoolwar_cause_04",
  "ui_schoolwar_cause_05",
  "ui_schoolwar_cause_06",
  "ui_schoolwar_cause_07",
  "ui_schoolwar_cause_08",
  "ui_schoolwar_cause_09",
  "ui_schoolwar_cause_10"
}
local power_info = {
  [0] = "ui_weak",
  [1] = "ui_normal",
  [2] = "ui_strong"
}
local fight_time_desc = {
  [1] = "ui_monday",
  [2] = "ui_tuesday",
  [3] = "ui_wednesday",
  [4] = "ui_thursday",
  [5] = "ui_friday",
  [6] = "ui_saturday",
  [7] = "ui_sunday"
}
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  self.rbtn_today.Checked = true
  self.today_index = 1
  self.order_index = 1
  self.groupbox_week.Visible = false
  if not isschoolleader() then
    self.btn_startfight.Enabled = false
    self.btn_schoolhelp.Enabled = false
  end
  self.btn_otherhelp.Enabled = false
  self.mltbox_help.HtmlText = gui.TextManager:GetText("desc_schoolwar_guize")
end
function on_main_form_close(self)
  if nx_find_custom(self, "today_data") and nx_is_valid(self.today_data) then
    self.today_data:ClearChild()
    nx_destroy(self.today_data)
  end
  if nx_find_custom(self, "week_data") and nx_is_valid(self.week_data) then
    self.week_data:ClearChild()
    nx_destroy(self.week_data)
  end
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function isschoolleader()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local row = client_player:GetRecordRows("SchoolPoseRec")
  if nx_int(row) < nx_int(0) then
    return false
  end
  local player_name = client_player:QueryProp("Name")
  for i = 0, row - 1 do
    local posindex = client_player:QueryRecord("SchoolPoseRec", i, 0)
    local poseuser = client_player:QueryRecord("SchoolPoseRec", i, 1)
    local tmpindex = math.floor(math.fmod(posindex, 100) / 10)
    if nx_number(tmpindex) == 1 and nx_ws_equal(nx_widestr(player_name), nx_widestr(poseuser)) then
      return true
    end
  end
  return false
end
function save_today_fight_data(form, ...)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local player_school = nx_string(client_player:QueryProp("School"))
  local arg_num = table.getn(arg)
  if arg_num == 0 then
    return
  end
  local col_num = nx_number(arg[1])
  if not nx_find_custom(form, "today_data") or not nx_is_valid(form.today_data) then
    form.today_data = nx_call("util_gui", "get_arraylist", "schoolfighttodayinfo")
  end
  local item_num = math.floor((arg_num - 1) / col_num)
  if nx_int(item_num) <= nx_int(0) then
    return
  end
  local bEnableOtherHelp = false
  local base_index = 1
  for i = 1, item_num do
    local attackid = nx_number(arg[base_index + 1])
    local defendid = nx_number(arg[base_index + 2])
    local time = nx_number(arg[base_index + 3])
    local result = nx_number(arg[base_index + 4])
    local attackhelp = nx_number(arg[base_index + 5])
    local defendhelp = nx_number(arg[base_index + 6])
    local fightphase = nx_number(arg[base_index + 7])
    local fightsceneid = nx_number(arg[base_index + 8])
    local atttreanum = nx_number(arg[base_index + 9])
    local deftreanum = nx_number(arg[base_index + 10])
    local grabtrea = nx_string(arg[base_index + 11])
    local helporder = nx_number(arg[base_index + 12])
    local otherhelp = nx_number(arg[base_index + 13])
    local child = form.today_data:GetChild("index" .. nx_string(i))
    if not nx_is_valid(child) then
      child = form.today_data:CreateChild("index" .. nx_string(i))
    end
    child.attackid = attackid
    child.defendid = defendid
    child.time = time
    child.result = result
    child.attackhelp = attackhelp
    child.defendhelp = defendhelp
    child.fightphase = fightphase
    child.fightsceneid = fightsceneid
    child.atttreanum = atttreanum
    child.deftreanum = deftreanum
    child.grabtrea = grabtrea
    if nx_string(school_table[attackid].school) == nx_string(player_school) then
      bEnableOtherHelp = true
      if otherhelp == 2 or otherhelp == 3 then
        bEnableOtherHelp = false
      end
    elseif nx_string(school_table[defendid].school) == nx_string(player_school) then
      bEnableOtherHelp = true
      if otherhelp == 1 or otherhelp == 3 then
        bEnableOtherHelp = false
      end
    end
    base_index = base_index + col_num
  end
  if isschoolleader() then
    form.btn_otherhelp.Enabled = bEnableOtherHelp
  end
end
function save_week_fight_data(form, ...)
  local arg_num = table.getn(arg)
  if arg_num == 0 then
    return
  end
  local col_num = nx_number(arg[1])
  if not nx_find_custom(form, "week_data") or not nx_is_valid(form.week_data) then
    form.week_data = nx_call("util_gui", "get_arraylist", "schoolfightweekinfo")
  end
  local item_num = math.floor((arg_num - 1) / col_num)
  if nx_int(item_num) <= nx_int(0) then
    return
  end
  local base_index = 1
  for i = 1, item_num do
    local fightindex = nx_number(arg[base_index + 1])
    local attackid = nx_number(arg[base_index + 2])
    local defendid = nx_number(arg[base_index + 3])
    local atttreanum = nx_number(arg[base_index + 4])
    local deftreanum = nx_number(arg[base_index + 5])
    local attackhelp = nx_number(arg[base_index + 6])
    local defendhelp = nx_number(arg[base_index + 7])
    local attplayernum = nx_number(arg[base_index + 8])
    local defplayernum = nx_number(arg[base_index + 9])
    local begintime = nx_number(arg[base_index + 10])
    local fighttime = nx_number(arg[base_index + 11])
    local fightresult = nx_number(arg[base_index + 12])
    local grabtrea = nx_string(arg[base_index + 13])
    local number = math.fmod(fightindex, 10)
    local child = form.week_data:GetChild("index" .. nx_string(i))
    if not nx_is_valid(child) then
      child = form.week_data:CreateChild("index" .. nx_string(i))
    end
    child.fightindex = fightindex
    child.attackid = attackid
    child.defendid = defendid
    child.atttreanum = atttreanum
    child.deftreanum = deftreanum
    child.attackhelp = attackhelp
    child.defendhelp = defendhelp
    child.attplayernum = attplayernum
    child.defplayernum = defplayernum
    child.begintime = begintime
    child.fighttime = fighttime
    child.fightresult = fightresult
    child.grabtrea = grabtrea
    base_index = base_index + col_num
  end
end
function get_school_power(treanum)
  if nx_number(treanum) == 0 then
    return 0
  elseif nx_number(treanum) >= 3 then
    return 2
  else
    return 1
  end
end
function get_help_list(helpdata)
  local result = {}
  local tmpdata = helpdata
  for i = table.getn(school_id_table) - 1, 0, -1 do
    if tmpdata <= 0 then
      return result
    end
    local tmp = math.floor(tmpdata / math.pow(2, i))
    if tmp == 1 then
      table.insert(result, school_id_table[i])
      tmpdata = tmpdata - math.pow(2, i)
    end
  end
  return result
end
function refresh_today_info(form, index)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local player_school = nx_string(client_player:QueryProp("School"))
  local is_in_fight = nx_number(client_player:QueryProp("IsInSchoolFight"))
  local leave_school_type = nx_number(client_player:QueryProp("LeaveSchoolType"))
  local last_school = nx_string(client_player:QueryProp("LastSchool"))
  if nx_number(index) < 1 or nx_number(index) > 4 then
    return
  end
  if not nx_find_custom(form, "today_data") or not nx_is_valid(form.today_data) then
    return
  end
  form.groupbox_2.Visible = true
  form.groupbox_today.Visible = true
  form.groupbox_week.Visible = false
  form.btn_prev.Enabled = true
  form.btn_next.Enabled = true
  form.btn_join_att_a.Visible = false
  form.btn_join_def_a.Visible = false
  form.btn_join_att_b.Visible = false
  form.btn_join_def_b.Visible = false
  local data_num = form.today_data:GetChildCount()
  local page_num = math.ceil(data_num / 2)
  if nx_number(page_num) <= 1 then
    form.btn_prev.Enabled = false
    form.btn_next.Enabled = false
  elseif nx_number(index) >= nx_number(page_num) then
    form.btn_next.Enabled = false
  elseif nx_number(index) <= 1 then
    form.btn_prev.Enabled = false
  end
  local hour, minute, second = get_server_time()
  local format_time = nx_number(hour) * 100 + nx_number(minute)
  local gui = nx_value("gui")
  math.randomseed(os.time())
  math.random(10)
  form.lbl_number.Text = nx_widestr(index)
  local frist_index = "index" .. nx_string(2 * index - 1)
  local child = form.today_data:GetChild(nx_string(frist_index))
  form.lbl_school_a.Text = nx_widestr("")
  form.lbl_time_a.Text = nx_widestr("")
  form.lbl_locale_a.Text = nx_widestr("")
  form.lbl_result_a.Text = nx_widestr("")
  form.lbl_power_a.Text = nx_widestr("")
  form.lbl_treasurenum_a.Text = nx_widestr("")
  form.lbl_attackhelp_a.Text = nx_widestr("")
  form.lbl_defendhelp_a.Text = nx_widestr("")
  form.mltbox_info_a:Clear()
  if nx_is_valid(child) then
    local school_attack = gui.TextManager:GetText(school_table[nx_number(child.attackid)].school)
    local school_defend = gui.TextManager:GetText(school_table[nx_number(child.defendid)].school)
    local time = get_format_time_text(nx_number(child.time))
    form.lbl_school_a.Text = nx_widestr(school_attack) .. nx_widestr("-") .. nx_widestr(school_defend)
    form.lbl_time_a.Text = nx_widestr(time)
    form.lbl_locale_a.Text = school_defend
    local result = ""
    if 2 >= nx_number(child.fightphase) then
      result = gui.TextManager:GetText(phase_table[nx_number(child.fightphase)])
    elseif nx_number(child.fightphase) == 3 then
      result = gui.TextManager:GetText(result_table[nx_number(child.result)])
    end
    form.lbl_result_a.Text = nx_widestr(result)
    local att_power_index = get_school_power(nx_number(child.atttreanum))
    local def_power_index = get_school_power(nx_number(child.deftreanum))
    local att_power_info = gui.TextManager:GetText(power_info[nx_number(att_power_index)])
    local def_power_info = gui.TextManager:GetText(power_info[nx_number(def_power_index)])
    form.lbl_power_a.Text = nx_widestr(att_power_info) .. nx_widestr("-") .. nx_widestr(def_power_info)
    form.lbl_treasurenum_a.Text = nx_widestr(child.atttreanum) .. nx_widestr("-") .. nx_widestr(child.deftreanum)
    local atthelplist = get_help_list(nx_number(child.attackhelp))
    local defhelplist = get_help_list(nx_number(child.defendhelp))
    local atthelpstr = nx_widestr("")
    local defhelpstr = nx_widestr("")
    local isatthelp = false
    local isdefhelp = false
    if leave_school_type ~= 1 then
      for i = 1, table.getn(atthelplist) do
        local tmpschoolname = school_table[nx_number(atthelplist[i])].school
        if nx_string(tmpschoolname) == nx_string(player_school) or nx_string(tmpschoolname) == nx_string(last_school) then
          isatthelp = true
        end
      end
      for i = 1, table.getn(defhelplist) do
        local tmpschoolname = school_table[nx_number(defhelplist[i])].school
        if nx_string(tmpschoolname) == nx_string(player_school) or nx_string(tmpschoolname) == nx_string(last_school) then
          isdefhelp = true
        end
      end
    end
    for i = 1, table.getn(atthelplist) do
      local tmpschoolname = school_table[nx_number(atthelplist[i])].school
      atthelpstr = nx_widestr(atthelpstr) .. nx_widestr(" ") .. nx_widestr(gui.TextManager:GetText(tmpschoolname))
    end
    for i = 1, table.getn(defhelplist) do
      local tmpschoolname = school_table[nx_number(defhelplist[i])].school
      defhelpstr = nx_widestr(defhelpstr) .. nx_widestr(" ") .. nx_widestr(gui.TextManager:GetText(tmpschoolname))
    end
    form.lbl_attackhelp_a.Text = nx_widestr(atthelpstr)
    form.lbl_defendhelp_a.Text = nx_widestr(defhelpstr)
    local index = math.random(10)
    local strdesc = gui.TextManager:GetFormatText(nx_string(desc_info[index]), school_defend)
    form.mltbox_info_a:Clear()
    form.mltbox_info_a:AddHtmlText(nx_widestr(strdesc), -1)
    form.btn_join_att_a.Visible = true
    form.btn_join_def_a.Visible = true
    form.btn_join_att_a.Enabled = false
    form.btn_join_def_a.Enabled = false
    if is_in_fight == 0 and nx_number(child.result) == 0 and nx_number(format_time) >= nx_number(child.time) then
      if nx_string(school_table[nx_number(child.attackid)].school) == nx_string(player_school) or isatthelp then
        form.btn_join_att_a.Enabled = true
      elseif nx_string(school_table[nx_number(child.defendid)].school) == nx_string(player_school) or isdefhelp then
        form.btn_join_def_a.Enabled = true
      elseif leave_school_type == 1 then
        form.btn_join_att_a.Enabled = true
        form.btn_join_def_a.Enabled = true
      elseif nx_string(school_table[nx_number(child.attackid)].school) == nx_string(last_school) then
        form.btn_join_att_a.Enabled = true
      elseif nx_string(school_table[nx_number(child.defendid)].school) == nx_string(last_school) then
        form.btn_join_def_a.Enabled = true
      else
        form.btn_join_att_a.Enabled = true
        form.btn_join_def_a.Enabled = true
      end
    end
  end
  local second_index = "index" .. nx_string(2 * index)
  child = form.today_data:GetChild(nx_string(second_index))
  form.lbl_school_b.Text = nx_widestr("")
  form.lbl_time_b.Text = nx_widestr("")
  form.lbl_locale_b.Text = nx_widestr("")
  form.lbl_result_b.Text = nx_widestr("")
  form.lbl_power_b.Text = nx_widestr("")
  form.lbl_treasurenum_b.Text = nx_widestr("")
  form.lbl_attackhelp_b.Text = nx_widestr("")
  form.lbl_defendhelp_b.Text = nx_widestr("")
  form.mltbox_info_b:Clear()
  if nx_is_valid(child) then
    local school_attack = gui.TextManager:GetText(school_table[nx_number(child.attackid)].school)
    local school_defend = gui.TextManager:GetText(school_table[nx_number(child.defendid)].school)
    local time = get_format_time_text(nx_number(child.time))
    form.lbl_school_b.Text = nx_widestr(school_attack) .. nx_widestr("-") .. nx_widestr(school_defend)
    form.lbl_time_b.Text = nx_widestr(time)
    form.lbl_locale_b.Text = school_defend
    local result = ""
    if 2 >= nx_number(child.fightphase) then
      result = gui.TextManager:GetText(phase_table[nx_number(child.fightphase)])
    elseif nx_number(child.fightphase) == 3 then
      result = gui.TextManager:GetText(result_table[nx_number(child.result)])
    end
    form.lbl_result_b.Text = result
    local att_power_index = get_school_power(nx_number(child.atttreanum))
    local def_power_index = get_school_power(nx_number(child.deftreanum))
    local att_power_info = gui.TextManager:GetText(power_info[nx_number(att_power_index)])
    local def_power_info = gui.TextManager:GetText(power_info[nx_number(def_power_index)])
    form.lbl_power_b.Text = nx_widestr(att_power_info) .. nx_widestr("-") .. nx_widestr(def_power_info)
    form.lbl_treasurenum_b.Text = nx_widestr(child.atttreanum) .. nx_widestr("-") .. nx_widestr(child.deftreanum)
    local atthelplist = get_help_list(nx_number(child.attackhelp))
    local defhelplist = get_help_list(nx_number(child.defendhelp))
    local atthelpstr = nx_widestr("")
    local defhelpstr = nx_widestr("")
    local isatthelp = false
    local isdefhelp = false
    if leave_school_type ~= 1 then
      for i = 1, table.getn(atthelplist) do
        local tmpschoolname = school_table[nx_number(atthelplist[i])].school
        if nx_string(tmpschoolname) == nx_string(player_school) or nx_string(tmpschoolname) == nx_string(last_school) then
          isatthelp = true
        end
      end
      for i = 1, table.getn(defhelplist) do
        local tmpschoolname = school_table[nx_number(defhelplist[i])].school
        if nx_string(tmpschoolname) == nx_string(player_school) or nx_string(tmpschoolname) == nx_string(last_school) then
          isdefhelp = true
        end
      end
    end
    for i = 1, table.getn(atthelplist) do
      local tmpschoolname = school_table[nx_number(atthelplist[i])].school
      atthelpstr = nx_widestr(atthelpstr) .. nx_widestr(" ") .. nx_widestr(gui.TextManager:GetText(tmpschoolname))
    end
    for i = 1, table.getn(defhelplist) do
      local tmpschoolname = school_table[nx_number(defhelplist[i])].school
      defhelpstr = nx_widestr(defhelpstr) .. nx_widestr(" ") .. nx_widestr(gui.TextManager:GetText(tmpschoolname))
    end
    form.lbl_attackhelp_b.Text = nx_widestr(atthelpstr)
    form.lbl_defendhelp_b.Text = nx_widestr(defhelpstr)
    local index = math.random(10)
    local strdesc = gui.TextManager:GetFormatText(nx_string(desc_info[index]), school_defend)
    form.mltbox_info_b:Clear()
    form.mltbox_info_b:AddHtmlText(nx_widestr(strdesc), -1)
    form.btn_join_att_b.Visible = true
    form.btn_join_def_b.Visible = true
    form.btn_join_att_b.Enabled = false
    form.btn_join_def_b.Enabled = false
    if is_in_fight == 0 and nx_number(child.result) == 0 and nx_number(format_time) >= nx_number(child.time) then
      if nx_string(school_table[nx_number(child.attackid)].school) == nx_string(player_school) or isatthelp then
        form.btn_join_att_b.Enabled = true
      elseif nx_string(school_table[nx_number(child.defendid)].school) == nx_string(player_school) or isdefhelp then
        form.btn_join_def_b.Enabled = true
      elseif leave_school_type == 1 then
        form.btn_join_att_b.Enabled = true
        form.btn_join_def_b.Enabled = true
      elseif nx_string(school_table[nx_number(child.attackid)].school) == nx_string(last_school) then
        form.btn_join_att_b.Enabled = true
      elseif nx_string(school_table[nx_number(child.defendid)].school) == nx_string(last_school) then
        form.btn_join_def_b.Enabled = true
      else
        form.btn_join_att_b.Enabled = true
        form.btn_join_def_b.Enabled = true
      end
    end
  end
end
function refresh_week_info(form, index)
  if not nx_is_valid(form) then
    return
  end
  if nx_number(index) < 1 or nx_number(index) > 14 then
    return
  end
  if not nx_find_custom(form, "week_data") or not nx_is_valid(form.week_data) then
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 6)
    return
  end
  form.groupbox_2.Visible = false
  form.groupbox_week.Visible = true
  form.groupbox_today.Visible = false
  form.btn_front.Enabled = true
  form.btn_back.Enabled = true
  local data_num = form.week_data:GetChildCount()
  if nx_number(data_num) <= 1 then
    form.btn_front.Enabled = false
    form.btn_back.Enabled = false
  elseif nx_number(index) >= nx_number(data_num) then
    form.btn_back.Enabled = false
  elseif nx_number(index) <= 1 then
    form.btn_front.Enabled = false
  end
  form.lbl_index.Text = nx_widestr(index)
  form.lbl_week_school.Text = nx_widestr("")
  form.lbl_week_starttime.Text = nx_widestr("")
  form.lbl_week_locate.Text = nx_widestr("")
  form.lbl_week_power.Text = nx_widestr("")
  form.lbl_week_atthelp.Text = nx_widestr("")
  form.lbl_week_defhelp.Text = nx_widestr("")
  form.lbl_week_playernum.Text = nx_widestr("")
  form.lbl_week_fighttime.Text = nx_widestr("")
  form.lbl_week_result.Text = nx_widestr("")
  form.lbl_week_treastate.Text = nx_widestr("")
  form.mltbox_week_info:Clear()
  form.lbl_week_back.BackImage = "gui\\special\\helper\\jianghuzhengdou\\menpaizhan.png"
  local child = form.week_data:GetChild("index" .. nx_string(index))
  if not nx_is_valid(child) then
    return
  end
  local gui = nx_value("gui")
  local school_attack = gui.TextManager:GetText(school_table[nx_number(child.attackid)].school)
  local school_defend = gui.TextManager:GetText(school_table[nx_number(child.defendid)].school)
  form.lbl_week_school.Text = nx_widestr(school_attack) .. nx_widestr("-") .. nx_widestr(school_defend)
  local week_index = math.floor(nx_number(child.fightindex) / 10)
  local week_day = gui.TextManager:GetText(fight_time_desc[week_index])
  local begin_time = get_format_time_text(nx_number(child.begintime))
  form.lbl_week_starttime.Text = nx_widestr(week_day) .. nx_widestr(begin_time)
  form.lbl_week_locate.Text = nx_widestr(school_defend)
  local att_power_index = get_school_power(nx_number(child.atttreanum))
  local def_power_index = get_school_power(nx_number(child.deftreanum))
  local att_power_info = gui.TextManager:GetText(power_info[nx_number(att_power_index)])
  local def_power_info = gui.TextManager:GetText(power_info[nx_number(def_power_index)])
  form.lbl_week_power.Text = nx_widestr(att_power_info) .. nx_widestr("-") .. nx_widestr(def_power_info)
  local atthelplist = get_help_list(nx_number(child.attackhelp))
  local defhelplist = get_help_list(nx_number(child.defendhelp))
  local atthelpstr = nx_widestr("")
  local defhelpstr = nx_widestr("")
  for i = 1, table.getn(atthelplist) do
    atthelpstr = nx_widestr(atthelpstr) .. nx_widestr(" ") .. nx_widestr(gui.TextManager:GetText(school_table[nx_number(atthelplist[i])].school))
  end
  for i = 1, table.getn(defhelplist) do
    defhelpstr = nx_widestr(defhelpstr) .. nx_widestr(" ") .. nx_widestr(gui.TextManager:GetText(school_table[nx_number(defhelplist[i])].school))
  end
  form.lbl_week_atthelp.Text = nx_widestr(atthelpstr)
  form.lbl_week_defhelp.Text = nx_widestr(defhelpstr)
  local player_num = nx_widestr(child.attplayernum) .. nx_widestr("-") .. nx_widestr(child.defplayernum)
  form.lbl_week_playernum.Text = nx_widestr(player_num)
  form.lbl_week_fighttime.Text = nx_widestr(child.fighttime)
  local result = gui.TextManager:GetText(result_table[nx_number(child.fightresult)])
  form.lbl_week_result.Text = nx_widestr(result)
  local treasure = gui.TextManager:GetText(nx_string(child.grabtrea))
  form.lbl_week_treastate.Text = nx_widestr(treasure)
  local index = math.random(10)
  local strdesc = gui.TextManager:GetFormatText(nx_string(desc_info[index]), school_defend)
  form.mltbox_week_info:Clear()
  form.mltbox_week_info:AddHtmlText(nx_widestr(strdesc), -1)
  form.lbl_week_back.BackImage = "gui\\special\\helper\\jianghuzhengdou\\menpaizhan.png"
end
function open_form(data_type, ...)
  local form = nx_execute("util_gui", "util_get_form", form_name, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  if nx_number(data_type) == 0 then
    save_today_fight_data(form, unpack(arg))
  elseif nx_number(data_type) == 3 then
    save_week_fight_data(form, unpack(arg))
  end
  if form.rbtn_week.Checked then
    refresh_week_info(form, nx_number(form.order_index))
  else
    refresh_today_info(form, nx_number(form.today_index))
  end
end
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    if nx_number(rbtn.DataSource) == 1 then
      refresh_today_info(form, nx_number(form.today_index))
    elseif nx_number(rbtn.DataSource) == 2 then
      refresh_week_info(form, nx_number(form.order_index))
    end
  end
end
function on_btn_front_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_number(form.order_index) > 1 then
    form.order_index = form.order_index - 1
    refresh_week_info(form, nx_number(form.order_index))
  end
end
function on_btn_back_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_number(form.order_index) < 14 then
    form.order_index = form.order_index + 1
    refresh_week_info(form, nx_number(form.order_index))
  end
end
function on_btn_startfight_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not isschoolleader() then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 17, "83181")
    return
  end
  local hour, minute, second = get_server_time()
  local now_time = nx_number(hour) * 100 + nx_number(minute)
  if nx_number(now_time) < 5 or nx_number(now_time) >= 1800 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 17, "83161", 18)
    return
  end
  util_show_form("form_stage_main\\form_school_war\\form_school_war_control", true)
end
function on_btn_schoolhelp_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not isschoolleader() then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 17, "83181")
    return
  end
  local hour, minute, second = get_server_time()
  local now_time = nx_number(hour) * 100 + nx_number(minute)
  if nx_number(now_time) < 5 or nx_number(now_time) >= 1800 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 17, "83161", 18)
    return
  end
  nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 5)
end
function get_server_time()
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return 0
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  local strdate = nx_function("format_date_time", nx_double(cur_date_time))
  local table_date = util_split_string(strdate, ";")
  if table.getn(table_date) ~= 2 then
    return 0
  end
  local table_time = util_split_string(table_date[2], ":")
  if table.getn(table_time) ~= 3 then
    return 0
  end
  return nx_number(table_time[1]), nx_number(table_time[2]), nx_number(table_time[3])
end
function on_btn_prev_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_number(form.today_index) > 1 then
    form.today_index = form.today_index - 1
    refresh_today_info(form, nx_number(form.today_index))
  end
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_number(form.today_index) < 4 then
    form.today_index = form.today_index + 1
    refresh_today_info(form, nx_number(form.today_index))
  end
end
function on_btn_join_att_a_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetText("ui_join_att"))
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local fightindex = 2 * nx_number(form.today_index) - 1
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 7, nx_number(fightindex), 2)
  end
end
function on_btn_join_def_a_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetText("ui_join_def"))
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local fightindex = 2 * nx_number(form.today_index) - 1
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 7, nx_number(fightindex), 1)
  end
end
function on_btn_join_att_b_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetText("ui_join_att"))
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local fightindex = 2 * nx_number(form.today_index)
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 7, nx_number(fightindex), 2)
  end
end
function on_btn_join_def_b_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetText("ui_join_def"))
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local fightindex = 2 * nx_number(form.today_index)
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 7, nx_number(fightindex), 1)
  end
end
function on_btn_otherhelp_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not isschoolleader() then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 17, "83181")
    return
  end
  local hour, minute, second = get_server_time()
  local now_time = nx_number(hour) * 100 + nx_number(minute)
  if nx_number(now_time) < 5 or nx_number(now_time) >= 1800 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 17, "83161", 18)
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetText("desc_schoolwar_jujueyuanzhu"))
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    btn.Enabled = false
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 8, 1)
  end
end
function request_open_form()
  local form = nx_value(form_name)
  if nx_is_valid(form) then
    form:Close()
    return
  end
  nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 0)
end
function get_format_time_text(time)
  local format_time = ""
  local hour = math.floor(nx_number(time) / 100)
  local minute = math.fmod(nx_number(time), 100)
  format_time = string.format("%02d:%02d", nx_number(hour), nx_number(minute))
  return nx_string(format_time)
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", form_name, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_cbtn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.groupbox_help) then
    return
  end
  if form.groupbox_help.Visible then
    form.groupbox_help.Visible = false
    form.Width = form.Width - form.groupbox_help.Width
  else
    form.groupbox_help.Visible = true
    form.Width = form.Width + form.groupbox_help.Width
  end
end
function on_btn_help_quit_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_help.Visible = false
  form.Width = form.Width - form.groupbox_help.Width
end
function on_school_fight_cele_win(...)
  local nSchoolID = nx_int(arg[1])
  local nOppoSchoolID = nx_int(arg[2])
  local IsAttack = nx_int(arg[3])
  local gui = nx_value("gui")
  local strSchool = gui.TextManager:GetText(school_table[nx_number(nSchoolID)].school)
  local strOppoSchool = gui.TextManager:GetText(school_table[nx_number(nOppoSchoolID)].school)
  local warDesc
  if nx_int(IsAttack) == nx_int(1) then
    warDesc = AttackWar
  elseif nx_int(IsAttack) == nx_int(0) then
    warDesc = DefendWar
  end
  nx_execute("form_stage_main\\form_main\\form_laba_info", "send_laba_immediate", gui.TextManager:GetText("ui_xiaolaba_special_tishi_2"), gui.TextManager:GetFormatText("ui_xiaolaba_special_title_2", nx_widestr(strSchool), nx_widestr(strOppoSchool), nx_widestr(warDesc)), 7, CONFIRM_SCHOOL_FIGHT_CELE_WIN)
end
