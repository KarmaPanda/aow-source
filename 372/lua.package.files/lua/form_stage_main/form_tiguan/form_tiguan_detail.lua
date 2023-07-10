require("form_stage_main\\form_tiguan\\form_tiguan_util")
require("util_functions")
function main_form_init(self)
  self.Fixed = false
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
end
function main_form_close(self)
  local common_execute = nx_value("common_execute")
  common_execute:RemoveExecute("ShowTGDetail", self)
  local timer = nx_value("timer_game")
  timer:UnRegister(FORM_TIGUAN_DETAIL, "show_score_ani", self)
  nx_destroy(self)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_gui_size_change()
  local gui = nx_value("gui")
  local form = util_get_form(FORM_TIGUAN_DETAIL, false)
  if not nx_is_valid(form) then
    return 0
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function set_tiguan_info(form, ...)
  local gui = nx_value("gui")
  local tiguan_finish_cdts = nx_value("tiguan_finish_cdts")
  if not nx_is_valid(tiguan_finish_cdts) then
    return 0
  end
  if nx_find_custom(tiguan_finish_cdts, "cg_id") then
    local ui_id = "ui_tiguan_name_" .. nx_string(tiguan_finish_cdts.cg_id)
    form.lbl_cgname.Text = gui.TextManager:GetText(ui_id)
  end
  form.mltbox_tgcdt:Clear()
  local total_repute = 0
  local cdt_tab = tiguan_finish_cdts:GetChildList()
  for i = 1, table.getn(cdt_tab) do
    local child = cdt_tab[i]
    if nx_number(child.ismust) == 1 then
      local cdt_desc = nx_widestr(" ")
      if nx_number(child.have) >= nx_number(child.need) then
        cdt_desc = cdt_desc .. gui.TextManager:GetFormatText(child.uiID, "#ffcc00") .. nx_widestr("<font color=\"#ffcc00\">") .. nx_widestr("(") .. nx_widestr(child.have) .. nx_widestr("/") .. nx_widestr(child.need) .. nx_widestr(")") .. nx_widestr("</font>")
      else
        cdt_desc = cdt_desc .. gui.TextManager:GetFormatText(child.uiID, "#ffffff") .. nx_widestr("<font color=\"#ffffff\">") .. nx_widestr("(") .. nx_widestr(child.have) .. nx_widestr("/") .. nx_widestr(child.need) .. nx_widestr(")") .. nx_widestr("</font>")
      end
      form.mltbox_tgcdt:AddHtmlText(cdt_desc, -1)
      total_repute = total_repute + nx_number(child.repute)
    end
  end
  for i = 1, table.getn(cdt_tab) do
    local child = cdt_tab[i]
    if nx_number(child.ismust) ~= 1 then
      local cdt_desc = nx_widestr(" ")
      if nx_number(child.have) >= nx_number(child.need) then
        cdt_desc = cdt_desc .. gui.TextManager:GetFormatText(child.uiID, "#ffcc00") .. nx_widestr("<font color=\"#ffcc00\">") .. nx_widestr("(") .. nx_widestr(child.have) .. nx_widestr("/") .. nx_widestr(child.need) .. nx_widestr(")") .. nx_widestr("</font>")
      else
        cdt_desc = cdt_desc .. gui.TextManager:GetFormatText(child.uiID, "#ffffff") .. nx_widestr("<font color=\"#ffffff\">") .. nx_widestr("(") .. nx_widestr(child.have) .. nx_widestr("/") .. nx_widestr(child.need) .. nx_widestr(")") .. nx_widestr("</font>")
      end
      form.mltbox_tgcdt:AddHtmlText(cdt_desc, -1)
      total_repute = total_repute + nx_number(child.repute)
    end
  end
  form.pbar_repute.Maximum = nx_int(total_repute)
  form.pbar_repute.Value = nx_int(0)
  form.pbar_livepoint.Maximum = nx_int(arg[5])
  form.pbar_livepoint.Value = nx_int(0)
  local today_success = nx_int(arg[6])
  local limit_success = nx_int(arg[7])
  local gbox_defeatlevel = form.gbox_defeatlevel
  for i = 1, nx_number(limit_success) do
    local lbl_str = "lbl_level_" .. nx_string(i)
    local lbl_level = gbox_defeatlevel:Find(lbl_str)
    if nx_is_valid(lbl_level) then
      lbl_level.BackImage = "gui\\special\\tiguan\\tz_2.png"
    end
  end
  for i = 1, nx_number(today_success) do
    local lbl_str = "lbl_level_" .. nx_string(i)
    local lbl_level = gbox_defeatlevel:Find(lbl_str)
    if nx_is_valid(lbl_level) then
      lbl_level.BackImage = "gui\\special\\tiguan\\tz_1.png"
    end
  end
  local player_name = arg[1]
  if nx_widestr(player_name) ~= nx_widestr("") then
    form.mltbox_winner.HtmlText = gui.TextManager:GetFormatText("ui_tiguan_winner", player_name)
  else
    form.mltbox_winner.HtmlText = nx_widestr("")
  end
  local tiguan_manager = nx_value("tiguan_manager")
  if not nx_is_valid(tiguan_manager) then
    return
  end
  local score = nx_int(arg[table.getn(arg)])
  form.ani_score.AnimationImage = get_ani_by_score(score)
  form.lbl_score.Text = gui.TextManager:GetFormatText("ui_tiguan_allscore", nx_widestr(score))
  local grid_basic = form.grid_basic_appraise
  grid_basic:ClearRow()
  grid_basic:BeginUpdate()
  grid_basic:SetColAlign(0, "left")
  grid_basic:SetColAlign(1, "right")
  grid_basic:SetColAlign(2, "right")
  grid_basic:InsertRow(grid_basic.RowCount)
  grid_basic:InsertRow(grid_basic.RowCount)
  grid_basic:InsertRow(grid_basic.RowCount)
  grid_basic:InsertRow(grid_basic.RowCount)
  grid_basic:InsertRow(grid_basic.RowCount)
  grid_basic:SetGridText(0, 0, gui.TextManager:GetText("ui_tiguan_mission"))
  grid_basic:SetGridText(1, 0, gui.TextManager:GetText("ui_tiguan_kill"))
  grid_basic:SetGridText(2, 0, gui.TextManager:GetText("ui_tiguan_dead"))
  grid_basic:SetGridText(3, 0, gui.TextManager:GetText("ui_tiguan_timeused"))
  grid_basic:SetGridText(4, 0, gui.TextManager:GetText("ui_tiguan_random_challenge"))
  local Task_Int = arg[8]
  local Task_tab = tiguan_manager:GetAwardNumber(nx_int(Task_Int))
  if table.getn(Task_tab) == 2 then
    grid_basic:SetGridText(0, 1, nx_widestr(Task_tab[1]))
    grid_basic:SetGridText(0, 2, nx_widestr("+" .. nx_string(Task_tab[2])))
  end
  local Mon_Int = arg[9]
  local Mon_tab = tiguan_manager:GetAwardNumber(nx_int(Mon_Int))
  if table.getn(Mon_tab) == 2 then
    grid_basic:SetGridText(1, 1, nx_widestr(Mon_tab[1]))
    grid_basic:SetGridText(1, 2, nx_widestr("+" .. nx_string(Mon_tab[2])))
  end
  local Dead_Int = arg[10]
  local Dead_tab = tiguan_manager:GetAwardNumber(nx_int(Dead_Int))
  if table.getn(Dead_tab) == 2 then
    grid_basic:SetGridText(2, 1, nx_widestr(Dead_tab[1]))
    grid_basic:SetGridText(2, 2, nx_widestr("-" .. nx_string(Dead_tab[2])))
  end
  local Time_Int = arg[11]
  local Time_tab = tiguan_manager:GetAwardNumber(nx_int(Time_Int))
  if table.getn(Time_tab) == 2 then
    local Min = nx_int(Time_tab[1] / 60)
    local Sec = nx_int(Time_tab[1] - Min * 60)
    local Time_Str = gui.TextManager:GetFormatText("ui_tiguan_usetime", nx_widestr(Min), nx_widestr(Sec))
    grid_basic:SetGridText(3, 1, nx_widestr(Time_Str))
    grid_basic:SetGridText(3, 2, nx_widestr("+" .. nx_string(Time_tab[2])))
  end
  grid_basic:EndUpdate()
  local Append_Int = arg[table.getn(arg) - 1]
  local Append_tab = tiguan_manager:GetAwardNumber(nx_int(Append_Int))
  if table.getn(Append_tab) == 2 then
    local is_finish = nx_number(Append_tab[1])
    if is_finish == 1 then
      grid_basic:SetGridText(4, 1, gui.TextManager:GetFormatText("ui_complete"))
      grid_basic:SetGridText(4, 2, nx_widestr("+" .. nx_string(Append_tab[2])))
    elseif is_finish == 0 then
      grid_basic:SetGridText(4, 1, gui.TextManager:GetFormatText("ui_faild"))
      grid_basic:SetGridText(4, 2, nx_widestr("-" .. nx_string(Append_tab[2])))
    end
  end
  if table.getn(arg) <= 13 then
    return 0
  end
  local grid_expand = form.grid_expand_appraise
  grid_expand:ClearRow()
  grid_expand:BeginUpdate()
  if 2 > grid_expand.ColCount then
    return 0
  end
  grid_expand:SetColAlign(0, "left")
  grid_expand:SetColAlign(1, "right")
  for k = 12, table.getn(arg) - 2 do
    local Appraise_Int = arg[k]
    local Appraise_tab = tiguan_manager:GetAwardNumber(nx_int(Appraise_Int))
    if table.getn(Appraise_tab) == 2 then
      local Appraise_name = gui.TextManager:GetText("ui_tiguan_extrapoint_" .. nx_string(nx_int(Appraise_tab[1])))
      grid_expand:InsertRow(grid_expand.RowCount)
      grid_expand:SetGridText(k - 12, 0, nx_widestr(Appraise_name))
      grid_expand:SetGridText(k - 12, 1, nx_widestr("+" .. nx_string(nx_int(Appraise_tab[2]))))
    end
  end
  grid_expand:EndUpdate()
end
function show_score_ani(form)
  if form.ani_score.PlayMode == nx_int(0) then
    form.ani_score.PlayMode = nx_int(2)
    form.ani_score.Loop = false
  else
    form.ani_score.PlayMode = nx_int(0)
    form.ani_score.Loop = false
  end
end
function show_tiguan_detail(type, ...)
  nx_execute("form_stage_main\\form_tiguan\\form_tiguan_dual_play_result", "on_open_single_guan_result_form", type, unpack(arg))
  if nx_number(type) == SHOW_DETAIL_OPEN then
    local common_execute = nx_value("common_execute")
    if not nx_is_valid(common_execute) then
      return 0
    end
    local timer = nx_value("timer_game")
    if not nx_is_valid(timer) then
      return 0
    end
    if table.getn(arg) < 13 then
      return 0
    end
    local form = util_get_form(FORM_TIGUAN_DETAIL, true, false, "", true)
    if not nx_is_valid(form) then
      return 0
    end
    local repute = arg[2]
    local faculty = arg[3]
    local livepoint = arg[4]
    set_tiguan_info(form, unpack(arg))
    nx_execute("util_gui", "util_show_form", FORM_TIGUAN_DETAIL, true)
    common_execute:AddExecute("ShowTGDetail", form, nx_float(0.01), nx_float(repute), nx_float(livepoint), nx_float(REPUTE_CHANGE_TIME))
    timer:Register(1000, 2, FORM_TIGUAN_DETAIL, "show_score_ani", form, -1, -1)
  elseif nx_number(type) == SHOW_DETAIL_CLOSE then
    local form = util_get_form(FORM_TIGUAN_DETAIL, false)
    if not nx_is_valid(form) then
      return 0
    end
    form:Close()
  end
end
