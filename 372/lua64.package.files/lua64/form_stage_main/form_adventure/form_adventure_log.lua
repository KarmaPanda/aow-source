require("util_gui")
require("custom_sender")
require("share\\client_custom_define")
require("share\\chat_define")
local MLTBOX_DETAIL_HEIGHT = 230
local MLTBOX_TIPS_HEIGHT = 94
local GROUPSCROLLBOX_HEIGHT = 476
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.lbl_title_1.adventure_plot = ""
  form.lbl_title_2.adventure_plot = ""
  form.lbl_title_3.adventure_plot = ""
  form.lbl_title_4.adventure_plot = ""
  form.lbl_title_5.adventure_plot = ""
  form.btn_del.adventure_plot = ""
  clear_show_info(form)
  local flag = init_list_content(form, 1)
  if nx_number(flag) == 0 then
    local info = gui.TextManager:GetFormatText("1751")
    util_auto_show_hide_form("form_stage_main\\form_adventure\\form_adventure_log")
    local form_main_chat_logic = nx_value("form_main_chat")
    if nx_is_valid(form_main_chat_logic) then
      form_main_chat_logic:AddChatInfoEx(info, CHATTYPE_SYSTEM, false)
    end
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
    return 0
  end
  get_detail_info(form, 1)
  bind_record_call_back(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    util_auto_show_hide_form("form_stage_main\\form_adventure\\form_adventure_log")
  end
end
function on_btn_last_click(btn)
  local form = btn.ParentForm
  local cur_page = nx_int(form.lbl_cur_page.Text) - nx_int(1)
  if nx_int(cur_page) == nx_int(0) then
    return
  end
  form.lbl_cur_page.Text = nx_widestr(cur_page)
  clear_show_info(form)
  init_list_content(form, cur_page)
  get_detail_info(form, 1)
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  local cur_page = nx_int(form.lbl_cur_page.Text) + nx_int(1)
  local total_page = form.lbl_total_page.Text
  if nx_int(cur_page) > nx_int(total_page) then
    return
  end
  form.lbl_cur_page.Text = nx_widestr(cur_page)
  clear_show_info(form)
  init_list_content(form, cur_page)
  get_detail_info(form, 1)
end
function update_catalog(form, index, adventure_plot, plot_text, brief_text, icon_id, iscomplete)
  if index == 1 then
    form.mltbox_brief_1.HtmlText = nx_widestr(brief_text)
    form.lbl_title_1.Text = nx_widestr(plot_text)
    form.lbl_icon_1.BackImage = icon_id
    form.lbl_title_1.adventure_plot = adventure_plot
    form.mltbox_brief_1.Visible = true
    form.lbl_title_1.Visible = true
    form.lbl_icon_1.Visible = true
    form.btn_del_1.Visible = true
    if iscomplete == 1 then
      form.btn_del_1.Text = nx_widestr("ui_complete")
    else
      form.btn_del_1.Text = nx_widestr("ui_uncomplete")
    end
  elseif index == 2 then
    form.mltbox_brief_2.HtmlText = nx_widestr(brief_text)
    form.lbl_title_2.Text = nx_widestr(plot_text)
    form.lbl_icon_2.BackImage = icon_id
    form.lbl_title_2.adventure_plot = adventure_plot
    form.mltbox_brief_2.Visible = true
    form.lbl_title_2.Visible = true
    form.lbl_icon_2.Visible = true
    form.btn_del_2.Visible = true
    if iscomplete == 1 then
      form.btn_del_2.Text = nx_widestr("ui_complete")
    else
      form.btn_del_2.Text = nx_widestr("ui_uncomplete")
    end
  elseif index == 3 then
    form.mltbox_brief_3.HtmlText = nx_widestr(brief_text)
    form.lbl_title_3.Text = nx_widestr(plot_text)
    form.lbl_icon_3.BackImage = icon_id
    form.lbl_title_3.adventure_plot = adventure_plot
    form.mltbox_brief_3.Visible = true
    form.lbl_title_3.Visible = true
    form.lbl_icon_3.Visible = true
    form.btn_del_3.Visible = true
    if iscomplete == 1 then
      form.btn_del_3.Text = nx_widestr("ui_complete")
    else
      form.btn_del_3.Text = nx_widestr("ui_uncomplete")
    end
  elseif index == 4 then
    form.mltbox_brief_4.HtmlText = nx_widestr(brief_text)
    form.lbl_title_4.Text = nx_widestr(plot_text)
    form.lbl_icon_4.BackImage = icon_id
    form.lbl_title_4.adventure_plot = adventure_plot
    form.mltbox_brief_4.Visible = true
    form.lbl_title_4.Visible = true
    form.lbl_icon_4.Visible = true
    form.btn_del_4.Visible = true
    if iscomplete == 1 then
      form.btn_del_4.Text = nx_widestr("ui_complete")
    else
      form.btn_del_4.Text = nx_widestr("ui_uncomplete")
    end
  elseif index == 5 then
    form.mltbox_brief_5.HtmlText = nx_widestr(brief_text)
    form.lbl_title_5.Text = nx_widestr(plot_text)
    form.lbl_icon_5.BackImage = icon_id
    form.lbl_title_5.adventure_plot = adventure_plot
    form.mltbox_brief_5.Visible = true
    form.lbl_title_5.Visible = true
    form.lbl_icon_5.Visible = true
    form.btn_del_5.Visible = true
    if iscomplete == 1 then
      form.btn_del_5.Text = nx_widestr("ui_complete")
    else
      form.btn_del_5.Text = nx_widestr("ui_uncomplete")
    end
  end
end
function init_list_content(form, page)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindRecord("Plot_Record") then
    return 0
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return 0
  end
  local row = client_player:GetRecordRows("Plot_Record")
  if row == 0 then
    form.lbl_cur_page.Text = nx_widestr(1)
    form.lbl_total_page.Text = nx_widestr(1)
    return 0
  elseif 0 < row then
    local b_add_page = row % 5
    local add_page = 0
    if 0 < b_add_page then
      add_page = 1
    end
    local total_page = nx_int(row / 5) + add_page
    local cur_page = page
    form.lbl_cur_page.Text = nx_widestr(cur_page)
    form.lbl_total_page.Text = nx_widestr(total_page)
    for i = 1, row do
      if 5 < i then
        break
      end
      if page == total_page and i > row - (total_page - 1) * 5 then
        break
      end
      local adventure_plot = client_player:QueryRecord("Plot_Record", (page - 1) * 5 + i - 1, 0)
      if adventure_plot ~= nil and nx_int(adventure_plot) ~= nx_int(0) then
        local plot_text = gui.TextManager:GetText(adventure_plot)
        local brief_id = taskmgr:GetPlotProp(nx_string(adventure_plot), "PlotDescShort")
        local brief_text = gui.TextManager:GetText(brief_id)
        local icon_id = taskmgr:GetPlotProp(nx_string(adventure_plot), "PlotImg")
        local iscomplete = client_player:QueryRecord("Plot_Record", (page - 1) * 5 + i - 1, 1)
        update_catalog(form, i, adventure_plot, plot_text, brief_text, icon_id, iscomplete)
      end
    end
  end
  return 1
end
function get_plot_info(form, index)
  if index == 1 then
    local plot_text = form.mltbox_1.plot_name
    local detail_text = form.mltbox_1.plot_detail
    local tips_text = form.mltbox_1.plot_tips
    return plot_text, detail_text, tips_text
  elseif index == 2 then
    local plot_text = form.mltbox_2.plot_name
    local detail_text = form.mltbox_2.plot_detail
    local tips_text = form.mltbox_2.plot_tips
    return plot_text, detail_text, tips_text
  elseif index == 3 then
    local plot_text = form.mltbox_3.plot_name
    local detail_text = form.mltbox_3.plot_detail
    local tips_text = form.mltbox_3.plot_tips
    return plot_text, detail_text, tips_text
  elseif index == 4 then
    local plot_text = form.mltbox_4.plot_name
    local detail_text = form.mltbox_4.plot_detail
    local tips_text = form.mltbox_4.plot_tips
    return plot_text, detail_text, tips_text
  elseif index == 5 then
    local plot_text = form.mltbox_5.plot_name
    local detail_text = form.mltbox_5.plot_detail
    local tips_text = form.mltbox_5.plot_tips
    return plot_text, detail_text, tips_text
  else
    return "", "", ""
  end
end
function get_detail_info(form, index)
  local control_id = "lbl_title_" .. nx_string(index)
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  lbl_title = form.groupbox_list:Find(nx_string(control_id))
  if not nx_is_valid(lbl_title) then
    return
  end
  local adventure_plot = lbl_title.adventure_plot
  form.btn_del.adventure_plot = adventure_plot
  if adventure_plot == "" or adventure_plot == nil then
    return
  end
  local gui = nx_value("gui")
  local plot_title = taskmgr:GetPlotProp(nx_string(adventure_plot), "PlotTitle")
  local plot_text = gui.TextManager:GetText(plot_title)
  local detail_id = taskmgr:GetPlotProp(nx_string(adventure_plot), "PlotDesc")
  local detail_text = gui.TextManager:GetText(detail_id)
  local tips_id = taskmgr:GetPlotProp(nx_string(adventure_plot), "PlotInfo")
  local tips_text = gui.TextManager:GetText(tips_id)
  local icon_id = taskmgr:GetPlotProp(nx_string(adventure_plot), "PlotImg")
  local back_pic_id = taskmgr:GetPlotProp(nx_string(adventure_plot), "BackImg")
  form.lbl_plot_name.Text = nx_widestr(plot_text)
  form.mltbox_detail.HtmlText = nx_widestr(detail_text)
  form.mltbox_tips.HtmlText = nx_widestr(tips_text)
  form.lbl_icon.BackImage = icon_id
  form.lbl_back_pic.BackImage = back_pic_id
  form.lbl_plot.Visible = true
  form.lbl_plot_name.Visible = true
  form.lbl_divide_line_1.Visible = true
  form.lbl_divide_line_2.Visible = true
  form.lbl_detail.Visible = true
  form.mltbox_detail.Visible = true
  form.mltbox_tips.Visible = true
  form.lbl_tips.Visible = true
  form.lbl_icon.Visible = true
  form.lbl_back_pic.Visible = true
  set_detail_tips_pos(form)
end
function init_detail_tips_pos(form)
  form.lbl_icon.Top = 22
  form.lbl_plot.Top = 54
  form.lbl_plot_name.Top = 54
  form.lbl_detail.Top = 94
  form.lbl_divide_line_1.Top = 80
  form.mltbox_detail.Top = 114
  form.lbl_back_pic.Top = 195
  form.lbl_divide_line_2.Top = 348
  form.lbl_tips.Top = 358
  form.mltbox_tips.Top = 378
end
function set_detail_tips_pos(form)
  form.groupscrollbox_info.IsEditMode = true
  init_detail_tips_pos(form)
  local content_height = form.mltbox_detail:GetContentHeight()
  local detail_height = MLTBOX_DETAIL_HEIGHT
  if content_height > MLTBOX_DETAIL_HEIGHT then
    detail_height = content_height
  end
  form.mltbox_detail.Height = detail_height
  form.lbl_divide_line_2.Top = form.mltbox_detail.Top + form.mltbox_detail.Height + 4
  form.lbl_tips.Top = form.lbl_divide_line_2.Top + form.lbl_divide_line_2.Height + 4
  form.mltbox_tips.Top = form.lbl_tips.Top + form.lbl_tips.Height + 4
  content_height = form.mltbox_tips:GetContentHeight()
  local tips_height = MLTBOX_TIPS_HEIGHT
  if content_height > MLTBOX_TIPS_HEIGHT then
    tips_height = content_height
  end
  form.mltbox_tips.Height = tips_height + 10
  form.groupscrollbox_info.Height = GROUPSCROLLBOX_HEIGHT
  form.groupscrollbox_info.IsEditMode = false
end
function on_mltbox_brief_1_select_item_change(mltbox)
  local form = mltbox.ParentForm
  form.btn_del.adventure_plot = form.lbl_title_1.adventure_plot
  get_detail_info(form, 1)
end
function on_mltbox_brief_2_select_item_change(mltbox)
  local form = mltbox.ParentForm
  form.btn_del.adventure_plot = form.lbl_title_2.adventure_plot
  get_detail_info(form, 2)
end
function on_mltbox_brief_3_select_item_change(mltbox)
  local form = mltbox.ParentForm
  form.btn_del.adventure_plot = form.lbl_title_3.adventure_plot
  get_detail_info(form, 3)
end
function on_mltbox_brief_4_select_item_change(mltbox)
  local form = mltbox.ParentForm
  form.btn_del.adventure_plot = form.lbl_title_4.adventure_plot
  get_detail_info(form, 4)
end
function on_mltbox_brief_5_select_item_change(mltbox)
  local form = mltbox.ParentForm
  form.btn_del.adventure_plot = form.lbl_title_5.adventure_plot
  get_detail_info(form, 5)
end
function clear_show_info(form)
  form.mltbox_brief_1.Visible = false
  form.mltbox_brief_2.Visible = false
  form.mltbox_brief_3.Visible = false
  form.mltbox_brief_4.Visible = false
  form.mltbox_brief_5.Visible = false
  form.lbl_title_1.Visible = false
  form.lbl_title_2.Visible = false
  form.lbl_title_3.Visible = false
  form.lbl_title_4.Visible = false
  form.lbl_title_5.Visible = false
  form.btn_del_1.Visible = false
  form.btn_del_2.Visible = false
  form.btn_del_3.Visible = false
  form.btn_del_4.Visible = false
  form.btn_del_5.Visible = false
  form.lbl_icon_1.Visible = false
  form.lbl_icon_2.Visible = false
  form.lbl_icon_3.Visible = false
  form.lbl_icon_4.Visible = false
  form.lbl_icon_5.Visible = false
  form.lbl_plot.Visible = false
  form.lbl_plot_name.Visible = false
  form.lbl_divide_line_1.Visible = false
  form.lbl_divide_line_2.Visible = false
  form.lbl_detail.Visible = false
  form.mltbox_detail.Visible = false
  form.mltbox_tips.Visible = false
  form.lbl_tips.Visible = false
  form.lbl_back_pic.Visible = false
  form.lbl_icon.Visible = false
end
function on_btn_del_click(btn)
  local form = btn.ParentForm
  local adventure_plot = form.btn_del.adventure_plot
  if adventure_plot == "" or adventure_plot == nil then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(util_text("ui_del_adventure_plot"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_delete_plot", nx_int(adventure_plot))
    form.btn_del.adventure_plot = form.lbl_title_1.adventure_plot
  end
  return
end
function bind_record_call_back(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("Plot_Record", form, "form_stage_main\\form_adventure\\form_adventure_log", "on_plot_record_change")
  end
end
function on_plot_record_change(self, recordname, optype, row, clomn)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindRecord("Plot_Record") then
    return 0
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_adventure\\form_adventure_log", true, false)
  if not nx_is_valid(form) then
    return 0
  end
  if optype == "add" or optype == "update" or optype == "del" or optype == "clear" then
    clear_show_info(form)
    if nx_number(init_list_content(form, 1)) ~= 0 then
      get_detail_info(form, 1)
    end
    return 0
  end
  return 1
end
