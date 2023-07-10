require("util_functions")
require("util_gui")
require("form_stage_main\\form_relation\\form_feed_info")
function main_form_init(form)
  form.Fixed = false
  return 1
end
function main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = gui.Width - form.Width
  form.AbsTop = (gui.Height - form.Height) / 2
  form.redit_reply.facenum = 0
  form.Visible = true
  return 1
end
function change_form_size(form)
  local gui = nx_value("gui")
  form.AbsLeft = gui.Width - form.Width
  form.AbsTop = (gui.Height - form.Height) / 2
end
function on_mainform_close(form)
  form.Visible = false
  nx_destroy(form)
  local form_face = nx_value("form_stage_main\\form_main\\form_main_face")
  if nx_is_valid(form_face) then
    form_face:Close()
  end
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function update_reply_count(reply, good, bad)
  if util_is_form_visible("form_stage_main\\form_relationship") then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_reply_simple", true, false)
  form.good = good
  form.bad = bad
  form.Reply = reply
  if nx_number(reply) == 0 then
    show_reply("")
    return
  end
  if nx_find_custom(form, "FeedId") then
    nx_execute("form_stage_main\\form_relation\\form_feed_info", "get_reply", nx_string(form.FeedId))
  end
  form.redit_reply.Text = nx_widestr("")
  on_redit_reply_changed(form.redit_reply)
end
function show_reply(text)
  local table_reply = util_split_wstring(nx_widestr(text), "*")
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_reply_simple", true, false)
  local table_subobj = form.groupscrollbox_reply:GetChildControlList()
  for i = 1, table.getn(table_subobj) do
    if nx_string(form.groupbox_topic) ~= nx_string(table_subobj[i]) then
      form.groupscrollbox_reply:Remove(table_subobj[i])
    end
  end
  form.groupscrollbox_reply.IsEditMode = true
  if not init_topic(form) then
    return
  end
  local HasReply = true
  local num = table.getn(table_reply)
  if nx_number(num) > nx_number(0) then
    if nx_find_custom(form.groupscrollbox_reply, "CurHeight") then
      form.groupscrollbox_reply.CurHeight = form.groupbox_topic.Top + form.groupbox_topic.Height
    end
    for i = 1, num do
      add_reply(form, nx_widestr(table_reply[i]))
    end
    if nx_find_custom(form.groupscrollbox_reply, "MaxHeight") then
      form.groupscrollbox_reply.Height = form.groupscrollbox_reply.MaxHeight
    end
  else
    HasReply = false
    form.groupscrollbox_reply.Height = form.groupbox_topic.Top + form.groupbox_topic.Height
  end
  form.groupscrollbox_reply.IsEditMode = false
  form.groupscrollbox_reply.HasVScroll = true
  form.groupscrollbox_reply.VScrollBar.Value = 0
  form.groupbox_submit.Left = 29
  form.groupbox_submit.Top = form.groupscrollbox_reply.Top + form.groupscrollbox_reply.Height
  form.lbl_back.Height = form.groupbox_submit.Top + form.groupbox_submit.Height + 5
  form.groupbox_function.Left = 4
  form.groupbox_function.Top = form.lbl_back.Top + form.lbl_back.Height - 4
  form.Height = form.groupbox_function.Top + form.groupbox_function.Height + 5
  local gui = nx_value("gui")
  form.Top = (gui.Height - form.Height) / 2
  form:ShowModal()
end
function init_topic(form)
  if not (nx_find_custom(form, "FeedId") and nx_find_custom(form, "FeedDesc") and nx_find_custom(form, "Owner") and nx_find_custom(form, "Reply") and nx_find_custom(form, "good")) or not nx_find_custom(form, "bad") then
    return false
  end
  form.mltbox_topic:Clear()
  form.mltbox_topic:AddHtmlText(nx_widestr(form.FeedDesc), -1)
  form.mltbox_topic.Height = form.mltbox_topic:GetContentHeight()
  form.mltbox_topic.ViewRect = "0,0,340," .. nx_string(form.mltbox_topic.Height)
  form.mltbox_topic.Top = 0
  form.lbl_good.Text = nx_widestr(util_text("ui_sns_up")) .. nx_widestr("(" .. nx_string(form.good) .. ")")
  form.lbl_bad.Text = nx_widestr(util_text("ui_sns_down")) .. nx_widestr("(" .. nx_string(form.bad) .. ")")
  form.lbl_good.Top = form.mltbox_topic.Top + form.mltbox_topic.Height + 10
  form.lbl_bad.Top = form.lbl_good.Top
  form.lbl_icon_good.Top = form.lbl_good.Top
  form.lbl_icon_bad.Top = form.lbl_good.Top
  form.lbl_reply.Text = nx_widestr(util_text("ui_sns_review")) .. nx_widestr("(" .. nx_string(form.Reply) .. ")")
  form.lbl_reply.Top = form.lbl_good.Top
  form.lbl_split.Top = form.lbl_good.Top + 25
  form.groupbox_topic.Top = 10
  form.groupbox_topic.Height = form.lbl_split.Top + form.lbl_split.Height + 5
  return true
end
function on_btn_reply_click(btn)
  local form = btn.ParentForm
  if not nx_find_custom(form, "FeedId") or not nx_find_custom(form, "Owner") then
    return
  end
  local text_reply = form.redit_reply.Text
  if nx_ws_equal(nx_widestr(text_reply), nx_widestr("")) then
    return
  end
  local pos1 = string.find(nx_string(text_reply), "*")
  local pos2 = string.find(nx_string(text_reply), "&")
  if pos1 ~= nil and nx_number(pos1) > 0 then
    return
  end
  if pos2 ~= nil and nx_number(pos2) > 0 then
    return
  end
  local check_words = nx_value("CheckWords")
  local new_word = nx_widestr("")
  if nx_is_valid(check_words) then
    new_word = nx_execute("custom_sender", "check_word", check_words, nx_widestr(text_reply), 1)
  end
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_ws_equal(nx_widestr(text_reply), nx_widestr(new_word)) then
    local info = gui.TextManager:GetFormatText("9721")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
    return
  end
  if nx_number(string.len(nx_string(text_reply))) > nx_number(512) then
    local info = gui.TextManager:GetFormatText("9738")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
    return
  end
  nx_execute("form_stage_main\\form_relation\\form_feed_info", "submit_reply", nx_widestr(form.Owner), nx_string(form.FeedId), nx_widestr(text_reply))
end
function add_reply(form, text)
  local table_reply = util_split_wstring(nx_widestr(text), "&")
  local target_name = table_reply[3]
  local desc = table_reply[5]
  local time_left = table_reply[7]
  local text_time_left = nx_execute("form_stage_main\\form_relation\\form_feed_info", "format_time_left", nx_double(time_left))
  local html_name = nx_widestr("<a href=\"") .. nx_widestr("PLAYER,") .. nx_widestr(target_name) .. nx_widestr("\" style=\"HLStype2\">") .. nx_widestr(target_name) .. nx_widestr("</a>")
  local gui = nx_value("gui")
  local groupbox_reply = gui:Create("GroupBox")
  groupbox_reply.Width = 340
  groupbox_reply.Height = 200
  groupbox_reply.LineColor = "0,0,0,0"
  groupbox_reply.BackColor = "0,0,0,0"
  groupbox_reply.DrawMode = "Expand"
  local mltbox_name = gui:Create("MultiTextBox")
  mltbox_name.Width = 60
  mltbox_name.LineHeight = 15
  mltbox_name.ViewRect = "0,0,60,15"
  mltbox_name.LineColor = "0,0,0,0"
  mltbox_name.TextColor = "255,06,68,99"
  mltbox_name.SelectBarColor = "0,0,0,0"
  mltbox_name.MouseInBarColor = "0,0,0,0"
  mltbox_name.Font = "font_sns_list"
  mltbox_name:AddHtmlText(nx_widestr(html_name), -1)
  nx_bind_script(mltbox_name, nx_current())
  nx_callback(mltbox_name, "on_right_click_hyperlink", "on_right_click_hyperlink")
  mltbox_name.Height = mltbox_name:GetContentHeight()
  mltbox_name.ViewRect = "0,0,60," .. nx_string(mltbox_name.Height)
  groupbox_reply:Add(mltbox_name)
  mltbox_name.Left = 5
  mltbox_name.Top = 5
  local lbl_time = gui:Create("Label")
  lbl_time.Width = 50
  lbl_time.Height = 20
  lbl_time.Align = "Right"
  lbl_time.Font = "font_sns_list"
  lbl_time.ForeColor = "255,101,80,63"
  lbl_time.Text = nx_widestr(text_time_left)
  groupbox_reply:Add(lbl_time)
  lbl_time.Left = mltbox_name.Left + mltbox_name.Width + 5
  lbl_time.Top = 5
  local btn_reply = gui:Create("Button")
  btn_reply.Width = 45
  btn_reply.Height = 16
  btn_reply.Align = "Center"
  btn_reply.Font = "font_sns_list"
  btn_reply.ForeColor = "255,101,80,63"
  btn_reply.NormalImage = "gui\\special\\sns\\btn_reply_out.png"
  btn_reply.FocusImage = "gui\\special\\sns\\btn_reply_on.png"
  btn_reply.PushImage = "gui\\special\\sns\\btn_reply_down.png"
  btn_reply.DrawMode = "ExpandH"
  btn_reply.Text = nx_widestr(util_text("ui_sns_reply"))
  btn_reply.ReplyName = nx_widestr(target_name)
  nx_bind_script(btn_reply, nx_current())
  nx_callback(btn_reply, "on_click", "on_sub_btn_reply_click")
  groupbox_reply:Add(btn_reply)
  btn_reply.Left = 295
  btn_reply.Top = 6
  local mltbox_desc = gui:Create("MultiTextBox")
  mltbox_desc.Width = 340
  mltbox_desc.Height = 210
  mltbox_desc.LineHeight = 15
  mltbox_desc.ViewRect = "5,15,330,200"
  mltbox_desc.LineColor = "0,0,0,0"
  mltbox_desc.TextColor = "255,101,80,63"
  mltbox_desc.SelectBarColor = "0,0,0,0"
  mltbox_desc.MouseInBarColor = "0,0,0,0"
  mltbox_desc.Font = "font_sns_list"
  mltbox_desc.BackImage = "gui\\special\\sns\\bg_talk.png"
  mltbox_desc.DrawMode = "ExpandV"
  mltbox_desc.BlendColor = "255,0,0,0"
  mltbox_desc:AddHtmlText(nx_widestr(desc), -1)
  mltbox_desc.Height = mltbox_desc:GetContentHeight() + 20
  mltbox_desc.ViewRect = "5,15,330," .. nx_string(mltbox_desc.Height)
  groupbox_reply:Add(mltbox_desc)
  groupbox_reply:ToFront(mltbox_desc)
  mltbox_desc.Left = 0
  mltbox_desc.Top = mltbox_name.Top + mltbox_name.Height
  local lbl_split = gui:Create("Label")
  lbl_split.Width = 340
  lbl_split.Height = 5
  lbl_split.DrawMode = "Title"
  lbl_split.BackImage = "gui\\common\\form_line\\line_bg2.png"
  lbl_split.BlendColor = "255,0,0,0"
  groupbox_reply:Add(lbl_split)
  groupbox_reply:ToFront(lbl_split)
  lbl_split.Left = 0
  lbl_split.Top = mltbox_desc.Top + mltbox_desc.Height + 5
  groupbox_reply.Left = 28
  groupbox_reply.Height = lbl_split.Top + lbl_split.Height + 5
  form.groupscrollbox_reply:Add(groupbox_reply)
  if not nx_find_custom(form.groupscrollbox_reply, "CurHeight") then
    form.groupscrollbox_reply.CurHeight = form.groupbox_topic.Top + form.groupbox_topic.Height
  end
  groupbox_reply.Top = form.groupscrollbox_reply.CurHeight
  form.groupscrollbox_reply.CurHeight = form.groupscrollbox_reply.CurHeight + groupbox_reply.Height
  if form.groupscrollbox_reply.CurHeight < 430 then
    form.groupscrollbox_reply.MaxHeight = form.groupscrollbox_reply.CurHeight
  end
end
function on_sub_btn_reply_click(btn)
  if not nx_find_custom(btn, "ReplyName") then
    return
  end
  local name = btn.ReplyName
  if nx_string(name) == "" then
    return
  end
  local form = btn.ParentForm
  form.redit_reply.Text = nx_widestr(util_text("ui_sns_reply")) .. nx_widestr(name) .. nx_widestr("\163\186")
end
function on_lbl_good_click(btn)
  local form = btn.ParentForm
  if not nx_find_custom(form, "FeedId") then
    return
  end
  local feed_id = form.FeedId
  if nx_string(feed_id) == "" then
    return
  end
  nx_execute("custom_sender", "custom_sync_recent_feeds", nx_int(5), nx_string(feed_id))
end
function on_lbl_bad_click(btn)
  local form = btn.ParentForm
  if not nx_find_custom(form, "FeedId") then
    return
  end
  local feed_id = form.FeedId
  if nx_string(feed_id) == "" then
    return
  end
  nx_execute("custom_sender", "custom_sync_recent_feeds", nx_int(6), nx_string(feed_id))
end
function on_btn_gift_click(btn)
  local form = btn.ParentForm
  if not nx_find_custom(form, "Owner") then
    return
  end
  local form_gift = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_present", true, false)
  form_gift.SendPlayerName = form.Owner
  form_gift:ShowModal()
end
function on_btn_lucky_click(btn)
  local form = btn.ParentForm
  if not nx_find_custom(form, "Owner") then
    return
  end
  local form_lucky = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_qifu", true, false)
  form_lucky.SendPlayerName = form.Owner
  form_lucky:ShowModal()
end
function on_btn_face_click(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  gui.Focused = form.redit_reply
  local face_form = nx_value("form_stage_main\\form_main\\form_main_face_chat")
  if nx_is_valid(face_form) then
    nx_gen_event(face_form, "selectface_return", "cancel", "")
  else
    local groupbox = self.Parent
    local form_main_face = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main_face", true, false, "", true)
    nx_set_value("form_stage_main\\form_main\\form_main_face_chat", form_main_face)
    form_main_face.AbsLeft = groupbox.AbsLeft - groupbox.Width
    form_main_face.AbsTop = groupbox.AbsTop + groupbox.Height - form_main_face.Height
    form_main_face.type = 1
    form_main_face:ShowModal()
    form_main_face.Visible = true
    local res, html = nx_wait_event(100000000, form_main_face, "selectface_return")
    if res == "ok" then
      add_chatface_to_chatedit(html)
    end
    form_main_face:Close()
  end
  nx_set_value("form_stage_main\\form_main\\form_main_face_chat", nil)
end
function add_chatface_to_chatedit(html)
  local form_main = nx_value("form_stage_main\\form_relation\\form_feed_reply_simple")
  if nx_number(form_main.redit_reply.facenum) < 5 then
    form_main.redit_reply:Append(html, -1)
  end
  local gui = nx_value("gui")
  gui.Focused = nx_null()
  gui.Focused = form_main.redit_reply
  on_redit_reply_changed(form_main.redit_reply)
end
function on_redit_reply_changed(self)
  local form = self.ParentForm
  local count = 0
  for w in string.gmatch(nx_string(self.Text), "img") do
    count = count + 1
  end
  self.facenum = count
  local str_len = self.Size - 1
  if str_len < 0 then
    str_len = 0
  end
  form.lbl_word_count.Text = nx_widestr("" .. str_len .. "/150")
end
function on_redit_reply_enter(self)
  local count = 0
  for w in string.gmatch(nx_string(self.Text), "<br/>") do
    count = count + 1
  end
  if 10 <= count then
    local form = self.ParentForm
    on_btn_reply_click(form.btn_reply)
  end
end
