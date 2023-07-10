require("form_stage_main\\form_huashan\\huashan_define")
require("form_stage_main\\form_huashan\\huashan_function")
require("util_functions")
require("util_gui")
require("share\\itemtype_define")
require("custom_sender")
function main_form_init(form)
  form.Fixed = true
  form.nowmonthday = 0
end
function open_form()
  nx_execute(m_Main_Path, "open_form")
end
function on_main_form_open(form)
  now_month_ishave_huashan(form)
  on_rbtn_text_click(form.rbtn_wl)
  on_rbtn_click(form.rbtn_pw)
  init_form(form)
  set_my_lj_msg(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_rbtn_click(rbtn)
  rbtn.Checked = true
  local form = rbtn.ParentForm
  if 1 == rbtn.TabIndex then
    form.groupbox_pw.Visible = true
    form.groupbox_zd.Visible = false
  elseif 2 == rbtn.TabIndex then
    form.groupbox_pw.Visible = false
    form.groupbox_zd.Visible = true
    roll_text(form)
  else
    return
  end
end
function on_rbtn_text_click(rbtn)
  rbtn.Checked = true
  local form = rbtn.ParentForm
  if 5 == rbtn.TabIndex then
    form.mltbox_gun.HtmlText = nx_widestr("@ui_huashan_ruledesc_1")
  elseif 6 == rbtn.TabIndex then
    form.mltbox_gun.HtmlText = nx_widestr("@ui_huashan_ruledesc_2")
  else
    return
  end
  roll_text(form)
end
function on_btn_phb_click(btn)
  local form_rank_path = "form_stage_main\\form_rank\\form_rank_main"
  local form_rank = nx_value(form_rank_path)
  if not nx_is_valid(form_rank) then
    form_rank = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_rank\\form_rank_main", true, false)
  end
  if not nx_is_valid(form_rank) then
    return
  end
  form_rank:Show()
  form_rank.Visible = true
  nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", form_rank, "rank_8_huashanlunjian")
end
function on_btn_wlxx_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_huashan\\form_wac_wulindahui")
end
function set_my_lj_msg(form)
  if not nx_is_valid(form) then
    return
  end
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  local playername = client_player:QueryProp("Name")
  local point = client_player:QueryProp("HuaShanPoint")
  form.lbl_name.Text = nx_widestr(playername)
  form.lbl_point.Text = nx_widestr(nx_string(point))
  nx_execute(m_Main_Path, "on_custom_msg", m_child_list[1], "on_server_msg_get_rankno", HuaShanCToS_GetRankNo)
end
function on_server_msg_get_rankno(...)
  if HuaShanSToC_GetRankNo ~= arg[1] then
    return
  end
  local form = nx_value(m_child_list[1])
  if not nx_is_valid(form) then
    return
  end
  local rankno = nx_number(arg[2])
  local text = ""
  if rankno <= 0 or 32 < rankno then
    text = ">32"
  else
    text = nx_string(rankno)
  end
  form.lbl_paiming.Text = nx_widestr(text)
end
function init_form(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if form.nowmonthday > 0 then
    gui.TextManager:Format_SetIDName("ui_huashan_open")
    gui.TextManager:Format_AddParam(nx_int(form.nowmonthday))
    form.mltbox_6.HtmlText = gui.TextManager:Format_GetText()
    gui.TextManager:Format_SetIDName("ui_huashan_ready")
    gui.TextManager:Format_AddParam(nx_int(form.nowmonthday))
    form.mltbox_4.HtmlText = gui.TextManager:Format_GetText()
  end
  local grid = form.textgrid_pw
  grid:ClearRow()
  local huashan_ini = nx_execute("util_functions", "get_ini", "ini\\ui\\huashan\\huashanlunjian.ini")
  if not nx_is_valid(huashan_ini) then
    return
  end
  local rank_ini = nx_execute("util_functions", "get_ini", "share\\Rule\\RankPrizeTime.ini")
  if not nx_is_valid(rank_ini) then
    return
  end
  for i = 1, 99 do
    local sec_index = huashan_ini:FindSectionIndex("sort" .. nx_string(i))
    if sec_index < 0 then
      break
    end
    local name = huashan_ini:ReadString(sec_index, "name", "")
    local rank = huashan_ini:ReadString(sec_index, "rank", "")
    local rule = huashan_ini:ReadString(sec_index, "rule", "")
    local text = huashan_ini:ReadString(sec_index, "text", "")
    local strs = nx_widestr("")
    if form.nowmonthday > 0 then
      if "" ~= rank then
        local index = rank_ini:FindSectionIndex(rank)
        if index < 0 then
          break
        end
        strs = nx_widestr(rank_ini:ReadString(index, "info", ""))
      else
        strs = gui.TextManager:GetText(text)
      end
    else
      strs = util_text("ui_huashan_close_text")
    end
    local row = grid:InsertRow(-1)
    local multibox_name = creat_grid_multitextbox(nx_widestr(gui.TextManager:GetText(name)), grid:GetColWidth(0))
    local multibox_info = creat_grid_multitextbox(nx_widestr(strs), grid:GetColWidth(1))
    local multibox_rule = creat_grid_multitextbox(nx_widestr(gui.TextManager:GetText(rule)), grid:GetColWidth(2))
    grid:SetGridControl(row, 0, multibox_name)
    grid:SetGridControl(row, 1, multibox_info)
    grid:SetGridControl(row, 2, multibox_rule)
  end
end
function roll_text(form)
  if not nx_is_valid(form) then
    return
  end
  local asynor = nx_value("common_execute")
  if not nx_is_valid(asynor) then
    return
  end
  asynor:RemoveExecute("RollText", form.mltbox_gun)
  form.mltbox_gun.Top = form.groupbox_roll_text.Height
  form.mltbox_gun.ExecuteRollText_Now_Accumulate_Times = 0
  asynor:AddExecute("RollText", form.mltbox_gun, nx_float(0), nx_int(1), nx_int(3), nx_int(form.mltbox_gun.Top), nx_int(0))
end
function now_month_ishave_huashan(form)
  if not nx_is_valid(form) then
    return
  end
  local huashan_ini = nx_execute("util_functions", "get_ini", "share\\War\\HuaShan\\HuaShan.ini")
  if not nx_is_valid(huashan_ini) then
    return
  end
  local sec_index = huashan_ini:FindSectionIndex("HuaShanTime")
  if sec_index < 0 then
    return
  end
  local months = huashan_ini:ReadString(sec_index, "month", "")
  if "" == months then
    return
  end
  local fightday = huashan_ini:ReadInteger(sec_index, "fightday", 0)
  if fightday < 0 or 31 < fightday then
    return
  end
  local now_time = os.time()
  local now_date = os.date("*t", now_time)
  local nowmonth = nx_number(now_date.month)
  local nowday = nx_number(now_date.day)
  local nowweek = nx_number(now_date.wday) - 1
  local ishave = false
  local month_tab = util_split_string(months, ",")
  for _, month in ipairs(month_tab) do
    if nowmonth == nx_number(month) then
      ishave = true
      break
    end
  end
  if not ishave then
    return
  end
  if fightday >= nowday then
    form.nowmonthday = fightday + 6 - (nowweek + (fightday - nowday) % 7) % 7
  else
    form.nowmonthday = fightday + 6 - (nowweek - (nowday - fightday) % 7 + 7) % 7
  end
end
function creat_grid_multitextbox(text, col_width)
  local gui = nx_value("gui")
  local multi_box = gui:Create("MultiTextBox")
  multi_box.ForeColor = "255,0,0,0"
  multi_box.Transparent = true
  multi_box.HAlign = "Center"
  multi_box.VAlign = "Center"
  multi_box.Height = 36
  multi_box.Width = col_width
  multi_box.ViewRect = "0,0," .. nx_string(col_width) .. ",36"
  multi_box.LineTextAlign = "Center"
  multi_box.NoFrame = true
  multi_box.AutoSize = true
  multi_box.Font = "font_text_figure"
  multi_box.DrawMode = "ExpandH"
  multi_box.DisableColor = "255,255,255,255"
  multi_box.TextColor = "255,255,217,188"
  multi_box:AddHtmlText(text, -1)
  return multi_box
end
