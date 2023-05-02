require("util_gui")
require("util_functions")
require("form_stage_main\\form_relation\\form_relation_news")
local SUB_MSG_FEED_RECENT = 2
local SUB_MSG_FEED_REPLY = 3
local SUB_MSG_FEED_TRANSMIT = 4
local SUB_MSG_FEED_GOOD = 5
local SUB_MSG_FEED_BAD = 6
local SUB_MSG_REPLY_COUNT = 7
local SUB_MSG_REPLY_RECENT = 8
local SUB_MSG_FEED_RECENT_SIMPLE = 9
local FORE_COLOR = "255,75,53,31"
function main_form_init(form)
  local gui = nx_value("gui")
  form.AbsLeft = gui.Width - form.Width
  form.AbsTop = (gui.Height - form.Height) / 2
  return 1
end
function main_form_open(form)
  nx_execute("custom_sender", "custom_sync_recent_feeds", nx_int(SUB_MSG_FEED_RECENT))
  form.Visible = true
  return 1
end
function change_form_size(form)
  local res = is_form_relation_news_show()
  if nx_boolean(res) then
    return
  end
  local gui = nx_value("gui")
  form.AbsLeft = gui.Width - form.Width - 10
  form.AbsTop = (gui.Height - form.Height) / 2
end
function main_form_close(form)
  close_menu()
  nx_execute("tips_game", "hide_tip")
  form.Visible = false
  nx_destroy(form)
  return 1
end
function on_btn_get_feeds_click(btn)
  nx_execute("custom_sender", "custom_sync_recent_feeds", nx_int(SUB_MSG_FEED_RECENT))
end
function get_reply_count(feed_id)
  nx_execute("custom_sender", "custom_sync_recent_feeds", nx_int(SUB_MSG_REPLY_COUNT), nx_string(feed_id))
end
function get_reply(feed_id)
  nx_execute("custom_sender", "custom_sync_recent_feeds", nx_int(SUB_MSG_REPLY_RECENT), nx_string(feed_id))
end
function submit_reply(owner, feed_id, text)
  nx_execute("custom_sender", "custom_sync_recent_feeds", nx_int(SUB_MSG_FEED_REPLY), nx_string(feed_id), nx_widestr(owner), nx_widestr(text))
end
function get_feeds_simple(owner)
  nx_execute("custom_sender", "custom_sync_recent_feeds", nx_int(SUB_MSG_FEED_RECENT_SIMPLE), nx_string(""), nx_widestr(owner))
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function show_feeds(feeds_info)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_info", true, false)
  form.groupscrollbox_feeds.IsEditMode = true
  form.groupscrollbox_feeds:DeleteAll()
  if nx_find_custom(form.groupscrollbox_feeds, "CurHeight") then
    form.groupscrollbox_feeds.CurHeight = 0
  end
  local table_feeds = util_split_wstring(nx_widestr(feeds_info), "*")
  local num = table.getn(table_feeds)
  if nx_number(num) <= nx_number(0) then
    return
  end
  form.lbl_back.BackImage = "gui\\common\\form_back\\bg_main.png"
  local feed_index = 1
  for i = 1, num do
    local gbox = add_feed(form, nx_widestr(table_feeds[i]), feed_index)
    feed_index = feed_index + 1
  end
  if nx_find_custom(form.groupscrollbox_feeds, "MaxHeight") then
    form.groupscrollbox_feeds.Height = form.groupscrollbox_feeds.MaxHeight
    local form_height_base = form.groupscrollbox_feeds.Height + 15
    if form_height_base < 500 then
      form_height_base = 500
    end
    form.lbl_back.Height = form_height_base
    form.Height = form_height_base + 30
  end
  form.groupscrollbox_feeds.IsEditMode = false
  form.groupscrollbox_feeds.HasVScroll = true
  form.groupscrollbox_feeds.VScrollBar.Value = 0
  form.groupscrollbox_feeds.Top = 20
  nx_execute("form_stage_main\\form_relation\\form_relation_news", "change_ctrls_size", "form_feed_info")
end
function add_feed(form, feed_text, feed_index)
  local table_feed = util_split_wstring(nx_widestr(feed_text), "&")
  local num = table.getn(table_feed)
  if nx_number(num) ~= nx_number(10) then
    return
  end
  local uid = table_feed[1]
  local name = table_feed[2]
  local target_name = table_feed[3]
  local type = table_feed[4]
  local desc = table_feed[5]
  local comment = table_feed[6]
  local time_left = table_feed[7]
  local good = table_feed[8]
  local bad = table_feed[9]
  local reply_count = table_feed[10]
  local snsmgr = nx_value("sns_manager")
  if not nx_is_valid(snsmgr) then
    return
  end
  local strPara = snsmgr:GetFeedInfo(nx_int(type), nx_widestr(name))
  if nx_string(strPara) == "" then
    return
  end
  local no_send_text = util_split_string(nx_string(strPara), "&")
  local no_send_num = table.getn(no_send_text)
  if nx_number(no_send_num) ~= nx_number(3) then
    return
  end
  if nx_string(no_send_text[2]) == "no_send" then
    return
  end
  local table_desc = util_split_wstring(nx_widestr(desc), ";")
  local desc_para_num = table.getn(table_desc)
  if nx_number(desc_para_num) <= nx_number(0) then
    return
  end
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName(nx_string(table_desc[1]))
  local text_desc = gui.TextManager:GetText(nx_string(table_desc[1]))
  local pos = string.find(nx_string(text_desc), "{@0:name}")
  if pos ~= nil and nx_number(pos) > 0 then
    local html_name = nx_widestr("<a href=\"") .. nx_widestr("PLAYER,") .. nx_widestr(name) .. nx_widestr("\" style=\"HLStype2\">") .. nx_widestr(name) .. nx_widestr("</a>")
    gui.TextManager:Format_AddParam(nx_widestr(html_name))
  end
  local pos_item = string.find(nx_string(text_desc), ":item}")
  local index_item = -1
  if pos_item ~= nil and nx_number(pos_item) > 1 then
    index_item = nx_int(string.sub(nx_string(text_desc), pos_item - 1, pos_item - 1))
  end
  local pos_wuxue = string.find(nx_string(text_desc), ":wuxue}")
  local index_wuxue = -1
  if pos_wuxue ~= nil and nx_number(pos_wuxue) > 1 then
    index_wuxue = nx_int(string.sub(nx_string(text_desc), pos_wuxue - 1, pos_wuxue - 1))
  end
  for i = 2, desc_para_num do
    local type = nx_type(table_desc[i])
    if type == "widestr" then
      if nx_number(index_item) >= 0 and nx_number(i) == nx_number(index_item + 1) then
        local html_item = nx_widestr("<a href=\"") .. nx_widestr("ITEM,") .. nx_widestr(table_desc[i]) .. nx_widestr("\" style=\"HLStype2\">") .. nx_widestr(gui.TextManager:GetText(nx_string(table_desc[i]))) .. nx_widestr("</a>")
        gui.TextManager:Format_AddParam(html_item)
      elseif nx_number(index_wuxue) >= 0 and nx_number(i) == nx_number(index_wuxue + 1) then
        local html_wuxue = nx_widestr("<a href=\"") .. nx_widestr("WUXUE,") .. nx_widestr(table_desc[i]) .. nx_widestr("\" style=\"HLStype2\">") .. nx_widestr(gui.TextManager:GetText(nx_string(table_desc[i]))) .. nx_widestr("</a>")
        gui.TextManager:Format_AddParam(html_wuxue)
      elseif nx_number(table_desc[i]) > 0 then
        gui.TextManager:Format_AddParam(nx_int(table_desc[i]))
      else
        gui.TextManager:Format_AddParam(gui.TextManager:GetText(nx_string(table_desc[i])))
      end
    else
      gui.TextManager:Format_AddParam(table_desc[i])
    end
  end
  local result_desc = gui.TextManager:Format_GetText()
  local groupbox_feed = gui:Create("GroupBox")
  groupbox_feed.Width = 360
  groupbox_feed.Height = 200
  groupbox_feed.LineColor = "0,0,0,0"
  groupbox_feed.BackColor = "0,0,0,0"
  groupbox_feed.Name = "feed_" .. nx_string(feed_index)
  local height_total = 15
  local mltbox_desc = gui:Create("MultiTextBox")
  mltbox_desc.Width = 350
  mltbox_desc.ViewRect = "0,0,305,100"
  mltbox_desc.LineColor = "0,0,0,0"
  mltbox_desc.TextColor = FORE_COLOR
  mltbox_desc.SelectBarColor = "0,0,0,0"
  mltbox_desc.MouseInBarColor = "0,0,0,0"
  mltbox_desc.Font = "font_sns_list"
  mltbox_desc:AddHtmlText(nx_widestr(result_desc), -1)
  mltbox_desc.Name = "MultiTextBox" .. nx_string(feed_index)
  mltbox_desc.Height = mltbox_desc:GetContentHeight()
  mltbox_desc.ViewRect = "0,0,305," .. nx_string(mltbox_desc.Height)
  nx_bind_script(mltbox_desc, nx_current())
  nx_callback(mltbox_desc, "on_mousein_hyperlink", "on_mousein_hyperlink")
  nx_callback(mltbox_desc, "on_mouseout_hyperlink", "on_mouseout_hyperlink")
  nx_callback(mltbox_desc, "on_right_click_hyperlink", "on_right_click_hyperlink")
  nx_callback(mltbox_desc, "on_click_hyperlink", "on_right_click_hyperlink")
  groupbox_feed:Add(mltbox_desc)
  mltbox_desc.Left = 25
  mltbox_desc.Top = height_total
  height_total = height_total + mltbox_desc.Height + 5
  local lbl_time = gui:Create("Label")
  lbl_time.Width = 50
  lbl_time.Height = 20
  lbl_time.Font = "font_sns_list"
  lbl_time.ForeColor = FORE_COLOR
  lbl_time.Align = "Left"
  lbl_time.Text = nx_widestr(format_time_left(nx_double(time_left)))
  lbl_time.Name = "lbl_time_" .. nx_string(feed_index)
  groupbox_feed:Add(lbl_time)
  lbl_time.Left = 25
  lbl_time.Top = height_total
  local lbl_icon_good = gui:Create("Label")
  lbl_icon_good.Width = 13
  lbl_icon_good.Height = 16
  lbl_icon_good.BackImage = "gui\\special\\sns\\icon_up.png"
  lbl_icon_good.DrawMode = "Title"
  lbl_icon_good.Name = "lbl_icon_good_" .. nx_string(feed_index)
  groupbox_feed:Add(lbl_icon_good)
  lbl_icon_good.Left = 210
  lbl_icon_good.Top = height_total
  local lbl_good = gui:Create("Label")
  lbl_good.Width = 50
  lbl_good.Height = 20
  lbl_good.Transparent = false
  lbl_good.ClickEvent = true
  lbl_good.Text = nx_widestr(util_text("ui_sns_up")) .. nx_widestr("(") .. nx_widestr(good) .. nx_widestr(")")
  lbl_good.BackImage = "gui\\special\\sns\\bg_event.png"
  lbl_good.DrawMode = "Center"
  lbl_good.Font = "font_sns_list"
  lbl_good.ForeColor = FORE_COLOR
  lbl_good.BlendColor = "0,0,0,0"
  lbl_good.Name = "lbl_good_" .. nx_string(groupbox_feed.Name)
  nx_bind_script(lbl_good, nx_current())
  nx_callback(lbl_good, "on_click", "on_lbl_good_click")
  nx_callback(lbl_good, "on_get_capture", "on_lbl_get_capture")
  nx_callback(lbl_good, "on_lost_capture", "on_lbl_lost_capture")
  groupbox_feed:Add(lbl_good)
  lbl_good.Left = lbl_icon_good.Left + lbl_icon_good.Width + 2
  lbl_good.Top = height_total
  lbl_time.Left = 25
  lbl_time.Top = height_total
  local lbl_icon_bad = gui:Create("Label")
  lbl_icon_bad.Width = 13
  lbl_icon_bad.Height = 16
  lbl_icon_bad.BackImage = "gui\\special\\sns\\icon_down.png"
  lbl_icon_bad.DrawMode = "Title"
  groupbox_feed:Add(lbl_icon_bad)
  lbl_icon_bad.Left = 280
  lbl_icon_bad.Top = height_total
  lbl_icon_bad.Name = "lbl_icon_bad_" .. nx_string(feed_index)
  local lbl_bad = gui:Create("Label")
  lbl_bad.Width = 50
  lbl_bad.Height = 20
  lbl_bad.Transparent = false
  lbl_bad.ClickEvent = true
  lbl_bad.Text = nx_widestr(util_text("ui_sns_down")) .. nx_widestr("(") .. nx_widestr(bad) .. nx_widestr(")")
  lbl_bad.BackImage = "gui\\special\\sns\\bg_event.png"
  lbl_bad.DrawMode = "Center"
  lbl_bad.Font = "font_sns_list"
  lbl_bad.ForeColor = FORE_COLOR
  lbl_bad.BlendColor = "0,0,0,0"
  lbl_bad.Name = "lbl_bad_" .. nx_string(groupbox_feed.Name)
  nx_bind_script(lbl_bad, nx_current())
  nx_callback(lbl_bad, "on_click", "on_lbl_bad_click")
  nx_callback(lbl_bad, "on_get_capture", "on_lbl_get_capture")
  nx_callback(lbl_bad, "on_lost_capture", "on_lbl_lost_capture")
  groupbox_feed:Add(lbl_bad)
  lbl_bad.Left = lbl_icon_bad.Left + lbl_icon_bad.Width + 2
  lbl_bad.Top = height_total
  height_total = height_total + lbl_bad.Height + 15
  local lbl_back = gui:Create("Label")
  lbl_back.Width = groupbox_feed.Width - 13
  lbl_back.BackImage = "gui\\special\\sns_new\\bg_event1.png"
  lbl_back.DrawMode = "Expand"
  lbl_back.HAnchor = "Left"
  lbl_back.Name = "lbl_back_" .. nx_string(feed_index)
  groupbox_feed:Add(lbl_back)
  groupbox_feed:ToBack(lbl_back)
  lbl_back.Left = 10
  lbl_back.Top = 5
  lbl_back.Height = lbl_bad.Top + lbl_bad.Height + 5
  local lbl_reply = gui:Create("Label")
  lbl_reply.Width = 70
  lbl_reply.Height = 20
  lbl_reply.Transparent = false
  lbl_reply.ClickEvent = true
  lbl_reply.Align = "Left"
  lbl_reply.Font = "font_sns_list"
  lbl_reply.ForeColor = FORE_COLOR
  lbl_reply.BlendColor = "0,0,0,0"
  lbl_reply.Text = nx_widestr(util_text("ui_sns_review")) .. nx_widestr("(") .. nx_widestr(reply_count) .. nx_widestr(")")
  lbl_reply.BackImage = "gui\\common\\form_back\\bg_main.png"
  lbl_reply.DrawMode = "Center"
  lbl_reply.Name = "lbl_reply_" .. nx_string(groupbox_feed.Name)
  nx_bind_script(lbl_reply, nx_current())
  nx_callback(lbl_reply, "on_click", "on_lbl_reply_click")
  nx_callback(lbl_reply, "on_get_capture", "on_lbl_get_capture")
  nx_callback(lbl_reply, "on_lost_capture", "on_lbl_lost_capture")
  groupbox_feed:Add(lbl_reply)
  lbl_reply.Left = 25
  lbl_reply.Top = height_total
  height_total = height_total + lbl_reply.Height
  local lbl_reply_new = gui:Create("Label")
  lbl_reply_new.Name = "lbl_reply_new_" .. nx_string(groupbox_feed.Name)
  lbl_reply_new.AutoSize = true
  lbl_reply_new.Left = lbl_reply.Left + 40
  lbl_reply_new.Top = lbl_reply.Top
  lbl_reply_new.BackImage = "gui\\animations\\sns\\tip.png"
  lbl_reply_new.Visible = true
  local ani_reply_new = gui:Create("Animation")
  ani_reply_new.Name = "ani_reply_new_" .. nx_string(groupbox_feed.Name)
  ani_reply_new.Width = 20
  ani_reply_new.Height = 18
  ani_reply_new.Left = lbl_reply.Left + 40
  ani_reply_new.Top = lbl_reply.Top
  ani_reply_new.AnimationImage = nx_string("sns_tip")
  ani_reply_new.Loop = true
  ani_reply_new.PlayMode = 0
  ani_reply_new.Visible = false
  local sns_manager = nx_value("sns_manager")
  if not nx_is_valid(sns_manager) then
    return
  end
  local lastReplyCount = sns_manager:GetLastReplyCount(nx_string(uid))
  if nx_number(lastReplyCount) == -1 and nx_number(reply_count) ~= 0 and nx_number(time_left) < nx_number(nx_double(1) / nx_double(24)) then
    ani_reply_new.Visible = true
    lbl_reply_new.Visible = false
  end
  if nx_number(lastReplyCount) ~= -1 and nx_number(reply_count) > nx_number(lastReplyCount) then
    ani_reply_new.Visible = true
    lbl_reply_new.Visible = false
  end
  groupbox_feed:Add(lbl_reply_new)
  groupbox_feed:Add(ani_reply_new)
  local lbl_jing = gui:Create("Label")
  lbl_jing.Width = 19
  lbl_jing.Height = 19
  lbl_jing.Left = mltbox_desc.Left + 307
  lbl_jing.Top = mltbox_desc.Top - 5
  lbl_jing.BackImage = nx_string("gui\\language\\ChineseS\\sns_new\\icon_jing.png")
  lbl_jing.Visible = false
  lbl_jing.Name = "lbl_jing_" .. nx_string(feed_index)
  local strPara = sns_manager:GetFeedInfo(nx_int(type), nx_widestr(name))
  if nx_string(strPara) ~= "" then
    local str = util_split_string(nx_string(strPara), "&")
    if nx_number(table.getn(str)) == nx_number(3) and nx_number(str[1]) >= 7 then
      lbl_jing.Visible = true
    end
  end
  groupbox_feed:Add(lbl_jing)
  local lbl_split = gui:Create("Label")
  lbl_split.Width = 350
  lbl_split.Height = 20
  lbl_split.DrawMode = "FitWindow"
  lbl_split.BackImage = "gui\\common\\form_line\\line_bg3.png"
  lbl_split.Name = "lbl_split_" .. nx_string(feed_index)
  groupbox_feed:Add(lbl_split)
  lbl_split.Left = 15
  lbl_split.Top = height_total - 13
  height_total = height_total + 10
  groupbox_feed.Height = height_total
  groupbox_feed.FeedId = uid
  groupbox_feed.Owner = name
  groupbox_feed.TextTimeLeft = nx_widestr(lbl_time.Text)
  groupbox_feed.TextDesc = nx_widestr(result_desc)
  groupbox_feed.Reply = nx_int(reply_count)
  groupbox_feed.good = nx_int(good)
  groupbox_feed.bad = nx_int(bad)
  form.groupscrollbox_feeds:Add(groupbox_feed)
  if not nx_find_custom(form.groupscrollbox_feeds, "CurHeight") then
    form.groupscrollbox_feeds.CurHeight = 0
  end
  groupbox_feed.Left = 5
  groupbox_feed.Top = form.groupscrollbox_feeds.CurHeight
  form.groupscrollbox_feeds.CurHeight = form.groupscrollbox_feeds.CurHeight + groupbox_feed.Height
  if form.groupscrollbox_feeds.CurHeight < 480 then
    form.groupscrollbox_feeds.MaxHeight = form.groupscrollbox_feeds.CurHeight
  end
  return groupbox_feed
end
function update_feed_info_count(feed_id, good, bad, reply)
  local form_info = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_info", true, false)
  local table_groupbox = form_info.groupscrollbox_feeds:GetChildControlList()
  for i = 1, table.getn(table_groupbox) do
    if nx_string(feed_id) == nx_string(table_groupbox[i].FeedId) then
      local table_sub_control = table_groupbox[i]:GetChildControlList()
      for j = 1, table.getn(table_sub_control) do
        if nx_string(table_sub_control[j].Name) == nx_string("lbl_good_" .. table_groupbox[i].Name) then
          table_sub_control[j].Text = nx_widestr(util_text("ui_sns_up")) .. nx_widestr("(" .. nx_string(good) .. ")")
          table_groupbox[i].good = nx_int(good)
        elseif nx_string(table_sub_control[j].Name) == nx_string("lbl_bad_" .. table_groupbox[i].Name) then
          table_sub_control[j].Text = nx_widestr(util_text("ui_sns_down")) .. nx_widestr("(" .. nx_string(bad) .. ")")
          table_groupbox[i].bad = nx_int(bad)
        elseif nx_string(table_sub_control[j].Name) == nx_string("lbl_reply_new_" .. table_groupbox[i].Name) then
          if nx_number(reply) > nx_number(table_groupbox[i].Reply) then
            table_sub_control[j].Visible = false
          end
        elseif nx_string(table_sub_control[j].Name) == nx_string("ani_reply_new_" .. table_groupbox[i].Name) then
          if nx_number(reply) > nx_number(table_groupbox[i].Reply) then
            table_sub_control[j].Visible = true
            table_groupbox[i].Reply = nx_int(reply)
          end
        elseif nx_string(table_sub_control[j].Name) == nx_string("lbl_reply_" .. table_groupbox[i].Name) then
          table_sub_control[j].Text = nx_widestr(util_text("ui_sns_review")) .. nx_widestr("(" .. nx_string(reply) .. ")")
        end
      end
    end
  end
  nx_execute("form_stage_main\\form_relation\\form_feed_reply", "update_reply_count", reply, good, bad)
  nx_execute("form_stage_main\\form_relation\\form_feed_reply_simple", "update_reply_count", reply, good, bad)
end
function on_lbl_reply_click(lbl)
  local res = is_form_relation_news_show()
  if nx_boolean(res) then
    local groupbox_feed = lbl.Parent
    if nx_is_valid(groupbox_feed) then
      save_reply_form_data(groupbox_feed)
    end
    local form = nx_value("form_stage_main\\form_relation\\form_feed_reply")
    if nx_is_valid(form) then
      form:Close()
    end
    open_relation_news_subform("form_feed_reply")
    local sns_manager = nx_value("sns_manager")
    if nx_is_valid(sns_manager) then
      local FeedId = nx_execute("form_stage_main\\form_relation\\form_relation_news", "get_reply_form_data", 1)
      local Reply = nx_execute("form_stage_main\\form_relation\\form_relation_news", "get_reply_form_data", 5)
      sns_manager:SetLastReplyCount(nx_string(FeedId), nx_int(Reply))
    end
    return
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_reply", false, false)
  if nx_is_valid(form) then
    form:Close()
  end
  form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_reply", true, false)
  if not nx_is_valid(lbl) then
    return
  end
  local groupbox_feed = lbl.Parent
  if not nx_is_valid(groupbox_feed) then
    return
  end
  form.FeedId = groupbox_feed.FeedId
  form.Owner = groupbox_feed.Owner
  form.TimeLeft = groupbox_feed.TextTimeLeft
  form.TextDesc = groupbox_feed.TextDesc
  form.Reply = groupbox_feed.Reply
  form.good = groupbox_feed.good
  form.bad = groupbox_feed.bad
  form:Show()
  local sns_manager = nx_value("sns_manager")
  if not nx_is_valid(sns_manager) then
    return
  end
  sns_manager:SetLastReplyCount(nx_string(form.FeedId), nx_int(form.Reply))
  form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_lbl_good_click(lbl)
  local groupbox_feed = lbl.Parent
  if not nx_is_valid(groupbox_feed) then
    return
  end
  if not nx_find_custom(groupbox_feed, "FeedId") then
    return
  end
  nx_execute("custom_sender", "custom_sync_recent_feeds", nx_int(SUB_MSG_FEED_GOOD), nx_string(groupbox_feed.FeedId))
end
function on_lbl_bad_click(lbl)
  local groupbox_feed = lbl.Parent
  if not nx_is_valid(groupbox_feed) then
    return
  end
  if not nx_find_custom(groupbox_feed, "FeedId") then
    return
  end
  nx_execute("custom_sender", "custom_sync_recent_feeds", nx_int(SUB_MSG_FEED_BAD), nx_string(groupbox_feed.FeedId))
end
function format_time_left(text_time)
  local time_left = nx_double(text_time)
  local time_left_day = nx_int(time_left)
  local time_left_time = nx_double(time_left) - nx_double(time_left_day)
  local time_base_min = nx_double(1) / nx_double(1440)
  local time_left_min = nx_double(time_left_time) / nx_double(time_base_min)
  if nx_number(time_left_day) > 365 then
    return nx_widestr(nx_int(nx_number(time_left_day) / 365)) .. nx_widestr(util_text("ui_sns_year"))
  elseif nx_number(time_left_day) > 30 then
    return nx_widestr(nx_int(nx_number(time_left_day) / 30)) .. nx_widestr(util_text("ui_sns_month"))
  elseif nx_number(time_left_day) > 7 then
    return nx_widestr(nx_int(nx_number(time_left_day) / 7)) .. nx_widestr(util_text("ui_sns_week"))
  elseif nx_number(time_left_day) > 0 then
    return nx_widestr(nx_number(time_left_day)) .. nx_widestr(util_text("ui_sns_day"))
  elseif nx_number(time_left_min) > 60 then
    return nx_widestr(nx_int(time_left_min / 60)) .. nx_widestr(util_text("ui_sns_hour"))
  elseif nx_number(time_left_min) >= 0 then
    if time_left_min < 1 then
      time_left_min = 1
    end
    return nx_widestr(nx_int(time_left_min)) .. nx_widestr(util_text("ui_sns_minute"))
  else
    return "error time"
  end
end
function on_right_click_hyperlink(mltbox, linkitem, linkdata)
  local str_data = nx_function("ext_split_wstring", nx_widestr(linkdata), nx_widestr(","))
  if "ITEM" == nx_string(str_data[1]) then
    return
  elseif "PLAYER" == nx_string(str_data[1]) then
    nx_execute("custom_sender", "custom_send_get_player_game_info", nx_widestr(str_data[2]))
    return
  end
end
function on_mousein_hyperlink(mltbox, linkitem, linkdata)
  local str_data = nx_function("ext_split_wstring", nx_widestr(linkdata), nx_widestr(","))
  if "ITEM" == nx_string(str_data[1]) then
    show_item_tips(mltbox, str_data[2])
    close_menu()
    return
  elseif "WUXUE" == nx_string(str_data[1]) then
    show_wuxue_tips(mltbox, str_data[2])
    close_menu()
    return
  elseif "PLAYER" == nx_string(str_data[1]) then
    return
  end
end
function on_mouseout_hyperlink(mltbox, linkitem, linkdata)
  nx_execute("tips_game", "hide_tip")
end
function show_item_tips(mltbox, item_id)
  if nx_string(item_id) == "" then
    return
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_tips_by_config", nx_string(item_id), x, y)
end
function show_wuxue_tips(mltbox, wuxue_id)
  if nx_string(wuxue_id) == "" then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.is_static = true
  item.ConfigID = nx_string(wuxue_id)
  item.ItemType = 1002
  item.Level = 1
  local owner = nx_string(mltbox)
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager.InShortcut = true
  end
  nx_execute("tips_game", "show_neigong_tip", item, x, y, owner)
end
function close_menu()
  local menu_game = nx_value("menu_game")
  if nx_is_valid(menu_game) then
    menu_game.Visible = false
  end
end
function on_lbl_get_capture(lbl)
  lbl.ForeColor = "255,255,0,0"
end
function on_lbl_lost_capture(lbl)
  lbl.ForeColor = FORE_COLOR
end
function close_all_blog()
  local form_feeds = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_info", false, false)
  if nx_is_valid(form_feeds) then
    form_feeds:Close()
    if nx_is_valid(form_feeds) then
      nx_destroy(form_feeds)
    end
  end
  local form_reply = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_reply", false, false)
  if nx_is_valid(form_reply) then
    form_reply:Close()
    if nx_is_valid(form_reply) then
      nx_destroy(form_reply)
    end
  end
  local form_feed_simple = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_simple", false, false)
  if nx_is_valid(form_feed_simple) then
    form_feed_simple:Close()
    if nx_is_valid(form_feed_simple) then
      nx_destroy(form_feed_simple)
    end
  end
end
function get_sub_form()
  local form_feeds = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_info", false, false)
  if nx_is_valid(form_feeds) and form_feeds.Visible then
    return 1, form_feeds
  end
  local form_reply = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_reply", false, false)
  if nx_is_valid(form_reply) and form_reply.Visible then
    return 2, form_reply
  end
  local form_feed_simple = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_simple", false, false)
  if nx_is_valid(form_feed_simple) and form_feed_simple.Visible then
    return 3, form_feed_simple
  end
  return 0, form_feeds
end
function open_blog(type, playername)
  if nx_number(type) == 1 then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_info", true, false)
    if nx_is_valid(form) then
      form:Show()
    end
  elseif nx_number(type) == 2 then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_reply", true, false)
    if nx_is_valid(form) then
      form:Show()
    end
  elseif nx_number(type) == 3 then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_simple", true, false)
    if nx_is_valid(form) then
      form.PlayerName = nx_widestr(playername)
      form:Show()
    end
  elseif nx_number(type) == 9 then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_info", true, false)
    if nx_is_valid(form) then
      form:Show()
    end
  end
end
function open_form(flag)
  if not flag then
    close_all_blog()
    return
  end
  local form_renmai = nx_value("form_stage_main\\form_relation\\form_relation_renmai")
  local playername = ""
  if nx_is_valid(form_renmai) and nx_find_custom(form_renmai, "CheckPlayerName") then
    playername = form_renmai.CheckPlayerName
  else
    local game_client = nx_value("game_client")
    if not nx_is_valid(game_client) then
      return
    end
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return
    end
    playername = client_player:QueryProp("Name")
  end
  local type, form = get_sub_form()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local self_name = client_player:QueryProp("Name")
  local form
  if nx_number(type) == 0 then
    if nx_ws_equal(nx_widestr(playername), nx_widestr("")) or nx_ws_equal(nx_widestr(playername), nx_widestr(self_name)) then
      nx_execute("form_stage_main\\form_relation\\form_feed_info", "open_blog", nx_int(1))
      form = nx_value("form_stage_main\\form_relation\\form_feed_info")
    else
      nx_execute("form_stage_main\\form_relation\\form_feed_info", "open_blog", nx_int(3), nx_widestr(playername))
      form = nx_value("form_stage_main\\form_relation\\form_feed_simple")
    end
  elseif nx_number(type) == 1 then
    local res = is_form_relation_news_show()
    if nx_boolean(res) then
      return
    end
    nx_execute("form_stage_main\\form_relation\\form_feed_info", "close_all_blog")
  elseif nx_number(type) == 2 then
    local form_reply = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_feed_reply", false, false)
    if nx_is_valid(form_reply) then
      form_reply:Close()
    end
    if nx_ws_equal(nx_widestr(playername), nx_widestr("")) or nx_ws_equal(nx_widestr(playername), nx_widestr(self_name)) then
      nx_execute("form_stage_main\\form_relation\\form_feed_info", "open_blog", nx_int(1))
      form = nx_value("form_stage_main\\form_relation\\form_feed_info")
    else
      nx_execute("form_stage_main\\form_relation\\form_feed_info", "open_blog", nx_int(3), nx_widestr(playername))
      form = nx_value("form_stage_main\\form_relation\\form_feed_simple")
    end
  elseif nx_number(type) == 3 then
    nx_execute("form_stage_main\\form_relation\\form_feed_info", "close_all_blog")
  end
  return form
end
