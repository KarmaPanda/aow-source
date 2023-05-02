require("util_gui")
require("util_functions")
local FORM_TIGUAN_DUAL_PLAY = "form_stage_main\\form_tiguan\\form_tiguan_dual_play"
local FORM_DUAL_PLAY_RESULT = "form_stage_main\\form_tiguan\\form_tiguan_dual_play_result"
local TG_SHOW_DETAIL_CLOSE = 1
local TG_SHOW_DETAIL_DUALPLAYER_OPEN = 2
local ANI_PATH = {
  "smzb_jin",
  "smzb_yu",
  "smzb_yin",
  "smzb_tong"
}
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
  form.groupbox_score.Visible = false
  form.groupbox_final_score.Visible = false
  form.btn_cancel.TabIndex = 1
  form.btn_cancel2.TabIndex = 2
end
function on_main_form_close(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(FORM_DUAL_PLAY_RESULT, "H_show_final_form", form)
  end
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(btn.TabIndex) == nx_int(1) then
    form.Visible = false
  else
    form:Close()
  end
end
function on_open_single_guan_result_form(submsg, ...)
  if nx_number(submsg) == TG_SHOW_DETAIL_DUALPLAYER_OPEN then
    local form = util_show_form(FORM_DUAL_PLAY_RESULT, true)
    if not nx_is_valid(form) then
      return
    end
    local form_dualplay = nx_value(FORM_TIGUAN_DUAL_PLAY)
    if nx_is_valid(form_dualplay) then
      form_dualplay:Close()
    end
    refresh_single_guan_result_form(unpack(arg))
    form.groupbox_score.Visible = true
    form.groupbox_final_score.Visible = false
  elseif nx_number(submsg) == TG_SHOW_DETAIL_CLOSE then
    local form = nx_value(FORM_DUAL_PLAY_RESULT)
    if nx_is_valid(form) then
      form.Visible = false
    end
  end
end
function refresh_single_guan_result_form(...)
  local form = nx_value(FORM_DUAL_PLAY_RESULT)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local tiguan_manager = nx_value("tiguan_manager")
  if not nx_is_valid(tiguan_manager) then
    return
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  local tiguan_finish_cdts = nx_value("tiguan_finish_cdts")
  if nx_is_valid(tiguan_finish_cdts) then
    if nx_find_custom(tiguan_finish_cdts, "cg_id") then
      local ui_id = "ui_tiguan_name_" .. nx_string(tiguan_finish_cdts.cg_id)
      form.lbl_guanmingditu.Text = gui.TextManager:GetText(ui_id)
    end
    form.mltbox_task:Clear()
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
        form.mltbox_task:AddHtmlText(cdt_desc, -1)
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
        form.mltbox_task:AddHtmlText(cdt_desc, -1)
        total_repute = total_repute + nx_number(child.repute)
      end
    end
  end
  local guan_index = arg[1]
  local Task_Int = arg[2]
  local Mon_Int = arg[3]
  local Dead_Int = arg[4]
  local Time_Int = arg[5]
  local Append_Int = arg[table.getn(arg) - 1]
  local final_score = arg[table.getn(arg)]
  local bold_num = util_text("ui_create_" .. nx_string(guan_index))
  form.lbl_guan_index.Text = util_format_string("ui_tiguan_dual_play_32", bold_num)
  form.lbl_score.Text = util_format_string("ui_tiguan_dual_play_21", nx_int(final_score))
  add_star(form.groupbox_stars, final_score)
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
  local Task_tab = tiguan_manager:GetAwardNumber(nx_int(Task_Int))
  if table.getn(Task_tab) == 2 then
    grid_basic:SetGridText(0, 1, nx_widestr(Task_tab[1]))
    grid_basic:SetGridText(0, 2, nx_widestr("+" .. nx_string(Task_tab[2])))
  end
  local Mon_tab = tiguan_manager:GetAwardNumber(nx_int(Mon_Int))
  if table.getn(Mon_tab) == 2 then
    grid_basic:SetGridText(1, 1, nx_widestr(Mon_tab[1]))
    grid_basic:SetGridText(1, 2, nx_widestr("+" .. nx_string(Mon_tab[2])))
  end
  local Dead_tab = tiguan_manager:GetAwardNumber(nx_int(Dead_Int))
  if table.getn(Dead_tab) == 2 then
    grid_basic:SetGridText(2, 1, nx_widestr(Dead_tab[1]))
    grid_basic:SetGridText(2, 2, nx_widestr("-" .. nx_string(Dead_tab[2])))
  end
  local Time_tab = tiguan_manager:GetAwardNumber(nx_int(Time_Int))
  if table.getn(Time_tab) == 2 then
    local Min = nx_int(Time_tab[1] / 60)
    local Sec = nx_int(Time_tab[1] - Min * 60)
    local Time_Str = gui.TextManager:GetFormatText("ui_tiguan_usetime", nx_widestr(Min), nx_widestr(Sec))
    grid_basic:SetGridText(3, 1, nx_widestr(Time_Str))
    grid_basic:SetGridText(3, 2, nx_widestr("+" .. nx_string(Time_tab[2])))
  end
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
  grid_basic:EndUpdate()
  local grid_expand = form.grid_expand_appraise
  grid_expand:ClearRow()
  grid_expand:BeginUpdate()
  if 2 > grid_expand.ColCount then
    return
  end
  grid_expand:SetColAlign(0, "left")
  grid_expand:SetColAlign(1, "right")
  for k = 6, table.getn(arg) - 2 do
    local Appraise_Int = arg[k]
    local Appraise_tab = tiguan_manager:GetAwardNumber(nx_int(Appraise_Int))
    if table.getn(Appraise_tab) == 2 and nx_int(Appraise_tab[2]) > nx_int(0) then
      local Appraise_name = gui.TextManager:GetText("ui_tiguan_extrapoint_" .. nx_string(nx_int(Appraise_tab[1])))
      grid_expand:InsertRow(grid_expand.RowCount)
      grid_expand:SetGridText(k - 6, 0, nx_widestr(Appraise_name))
      grid_expand:SetGridText(k - 6, 1, nx_widestr("+" .. nx_string(nx_int(Appraise_tab[2]))))
      SystemCenterInfo:ShowSystemCenterInfo(util_format_string("ui_tiguan_dual_play_35", nx_widestr(Appraise_name), nx_int(Appraise_tab[2])), 8)
    end
  end
  grid_expand:EndUpdate()
end
function add_star(groupbox, score)
  if not nx_is_valid(groupbox) or score < 0 then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  groupbox:DeleteAll()
  local lbl_star
  local star_count = nx_execute("form_stage_main\\form_tiguan\\form_tiguan_util", "get_dual_play_star_by_score", score)
  for i = 1, star_count do
    lbl_star = gui:Create("Label")
    groupbox:Add(lbl_star)
    lbl_star.Left = (i - 1) * 20
    lbl_star.Top = 0
    lbl_star.BackImage = "gui\\special\\helper\\school_introduction\\star_2.png"
    lbl_star.AutoSize = true
  end
end
function on_open_final_result_form(...)
  local form = util_get_form(FORM_DUAL_PLAY_RESULT, true, false)
  if not nx_is_valid(form) then
    return
  end
  local mltbox, tmp_text, mlt_score
  local final_score = 0
  local begin_index = 1
  for i = 1, 5 do
    mltbox = nx_custom(form, "mltbox_" .. nx_string(i))
    mlt_score = nx_custom(form, "mltbox_" .. nx_string(i) .. "_1")
    if nx_is_valid(mltbox) and nx_is_valid(mlt_score) then
      if begin_index <= table.getn(arg) then
        tmp_text = nx_execute(FORM_TIGUAN_DUAL_PLAY, "get_guan_name", arg[begin_index])
        mltbox.HtmlText = nx_widestr(tmp_text)
        mlt_score.HtmlText = nx_widestr(nx_int(arg[begin_index + 1]))
        final_score = final_score + nx_number(arg[begin_index + 1])
        begin_index = begin_index + 2
        mltbox.Visible = true
        mlt_score.Visible = true
      else
        mltbox.Visible = false
        mlt_score.Visible = false
      end
    end
  end
  form.lbl_final_score.Text = util_format_string("ui_tiguan_dual_play_20", nx_int(final_score))
  local score_level = get_final_evaluation(final_score)
  form.ani_score.AnimationImage = ANI_PATH[nx_number(score_level)]
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(3000, 2, FORM_DUAL_PLAY_RESULT, "H_show_final_form", form, -1, -1)
  end
end
function H_show_final_form(form)
  local form_result = nx_value(FORM_DUAL_PLAY_RESULT)
  if nx_is_valid(form_result) then
    form_result:Show()
    form_result.Visible = true
    form.ani_score.Loop = false
    form.ani_score:Play()
    form_result.groupbox_score.Visible = false
    form_result.groupbox_final_score.Visible = true
  end
end
function get_final_evaluation(score)
  local final_score = nx_int(score)
  if final_score < nx_int(0) then
    return 0
  end
  local ini = get_ini("share\\War\\tiguan_dual_player.ini", true)
  if not nx_is_valid(ini) then
    return 0
  end
  local sec_index = ini:FindSectionIndex("score_evaluate")
  if 0 <= sec_index then
    local max_count = ini:GetSectionItemCount(sec_index)
    for i = 1, max_count do
      local range_string = ini:ReadString(sec_index, nx_string(i), "")
      local value_list = util_split_string(nx_string(range_string), ",")
      if table.getn(value_list) == 2 and final_score >= nx_int(value_list[1]) and final_score <= nx_int(value_list[2]) then
        return i
      end
    end
  end
  return 0
end
