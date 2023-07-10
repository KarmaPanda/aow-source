require("util_functions")
require("util_gui")
require("share\\client_custom_define")
require("form_stage_main\\form_relation\\form_relation_news")
local SELF_FORM = "form_stage_main\\form_relation\\form_world_news"
local secondary_form = {
  "form_stage_main\\form_relation\\form_great_events",
  "form_stage_main\\form_relation\\form_feed_info",
  "form_stage_main\\form_relation\\form_gossip_info"
}
local SUBFORM_NAME = {
  "form_great_events",
  "form_feed_info",
  "form_gossip_info"
}
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_rbtn_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = rbtn.TabIndex
  if index < 1 or 3 < index then
    return
  end
  open_relation_news_subform(SUBFORM_NAME[nx_number(index)])
  local form_relation_news = nx_value("form_stage_main\\form_relation\\form_relation_news")
  if not nx_is_valid(form_relation_news) then
    close_sub_form(form)
    local sub_form = nx_execute(secondary_form[index], "open_form", true)
    if not nx_is_valid(sub_form) then
      return
    end
    sub_form.Left = form.AbsLeft + 10
    sub_form.Top = form.groupbox_1.AbsTop + form.groupbox_1.Height
    adjust_all_form_pos()
    form:Add(sub_form)
    nx_set_custom(form, "index", index)
  end
  nx_execute("form_stage_main\\form_relation\\form_relation_renmai", "show_red_dot", false)
end
function close_sub_form(form)
  if not nx_find_custom(form, "index") then
    return
  end
  local index = form.index
  nx_execute(secondary_form[index], "open_form", false)
end
function custom_send_news(sub_msg)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SNS_NEWS), nx_int(sub_msg))
end
function show_form(flag, index, b_show_btn_list)
  if nx_boolean(flag) then
    local form = util_show_form(SELF_FORM, true)
    if nx_is_valid(form) then
      if index == 1 then
        form.rbtn_1.Checked = true
      elseif index == 2 then
        form.rbtn_2.Checked = true
      elseif index == 3 then
        form.rbtn_3.Checked = true
      end
      if b_show_btn_list ~= nil and not nx_boolean(b_show_btn_list) then
        form.Visible = false
      end
    end
    adjust_all_form_pos()
  else
    local form = nx_value(SELF_FORM)
    if nx_is_valid(form) then
      form:Close()
    end
  end
end
function adjust_all_form_pos()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form_world_news = nx_value(SELF_FORM)
  if not nx_is_valid(form_world_news) then
    return
  end
  local sub_form = nx_null()
  for _, subform_name in ipairs(secondary_form) do
    sub_form = nx_value(subform_name)
    if nx_is_valid(sub_form) and nx_boolean(sub_form.Visible) then
      break
    end
  end
  if not nx_is_valid(sub_form) or not nx_boolean(sub_form.Visible) then
    return
  end
  form_world_news.AbsTop = (gui.Height - (form_world_news.Height + sub_form.Height)) / 2
  form_world_news.AbsLeft = gui.Width - form_world_news.Width
  sub_form.AbsTop = form_world_news.AbsTop + form_world_news.Height
  sub_form.AbsLeft = form_world_news.AbsLeft
end
