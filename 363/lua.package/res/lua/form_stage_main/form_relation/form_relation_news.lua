require("util_gui")
require("util_functions")
require("define\\sysinfo_define")
local FORM_RELATION_NEWS = "form_stage_main\\form_relation\\form_relation_news"
local SUBFORM_RELATION_NEWS = {
  form_world_news = "form_stage_main\\form_relation\\form_world_news",
  form_great_events = "form_stage_main\\form_relation\\form_great_events",
  form_feed_info = "form_stage_main\\form_relation\\form_feed_info",
  form_gossip_info = "form_stage_main\\form_relation\\form_gossip_info",
  form_feed_reply = "form_stage_main\\form_relation\\form_feed_reply",
  form_feed_reply2 = "form_stage_main\\form_relation\\form_feed_reply",
  form_feed_reply3 = "form_stage_main\\form_relation\\form_feed_reply",
  form_feed_reply4 = "form_stage_main\\form_relation\\form_feed_reply"
}
local SUBFORM_TEMPLATE_GBOX_LIST = {
  form_great_events = {
    "groupbox_template_greatevent",
    "gsb_events",
    "lbl_back"
  },
  form_feed_info = {
    "groupbox_template_feedinfo",
    "groupscrollbox_feeds",
    "lbl_back"
  },
  form_gossip_info = {
    "groupbox_template_gossip",
    "gsb_gossip",
    ""
  },
  form_feed_reply = {
    "groupscrollbox_template_reply",
    "groupscrollbox_reply",
    "lbl_back"
  },
  form_feed_reply2 = {
    "groupbox_template_submit",
    "groupbox_submit",
    "lbl_back"
  },
  form_feed_reply3 = {
    "groupbox_template_topic",
    "groupbox_topic",
    "lbl_back"
  },
  form_feed_reply4 = {
    "groupbox_template_reply",
    "",
    "lbl_back"
  }
}
local reply_list = {
  "FeedId",
  "Owner",
  "TextTimeLeft",
  "TextDesc",
  "Reply",
  "good",
  "bad"
}
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(form)
  local ST_FUNCTION_JIANGHU_GREAT_NEWS = 883
  local SwitchManager = nx_value("SwitchManager")
  if not nx_is_valid(SwitchManager) then
    return
  end
  if not SwitchManager:CheckSwitchEnable(ST_FUNCTION_JIANGHU_GREAT_NEWS) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      local info = util_text("sys_jianghu_great_news_001")
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    form:Close()
    return
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
  form.groupbox_main.Visible = false
  form.ani_back:Play()
  form.last_1step_subform = ""
  form.groupbox_template.Visible = false
  local subform = create_subform_in_gbox(form.groupbox_subform, "form_world_news")
  if nx_is_valid(subform) then
    subform.rbtn_1.Checked = true
  end
  form.lbl_no_msg.Visible = true
  form.msg_count = 0
end
function on_main_form_close(form)
  for _, subform_name in pairs(SUBFORM_RELATION_NEWS) do
    local subform = nx_value(subform_name)
    if nx_is_valid(subform) then
      subform:Close()
    end
  end
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_ani_back_animation_end(ani)
  local form = ani.ParentForm
  if not nx_is_valid(form) then
    return
  end
  ani.Visible = false
  form.groupbox_main.Visible = true
end
function open_relation_news_subform(form_name)
  local form = nx_value(FORM_RELATION_NEWS)
  if not nx_is_valid(form) then
    return false
  end
  for _, subform_name in pairs(SUBFORM_RELATION_NEWS) do
    local subform = nx_value(subform_name)
    if nx_is_valid(subform) and subform_name ~= SUBFORM_RELATION_NEWS.form_world_news then
      subform:Close()
    end
  end
  nx_execute("form_stage_main\\form_relation\\form_relation_news", "show_no_msg_lbl", true)
  local subform = create_subform_in_gbox(form.groupbox_content, form_name)
  if not nx_is_valid(subform) then
    return false
  end
  local lbl_back = subform:Find(SUBFORM_TEMPLATE_GBOX_LIST[form_name][3])
  if nx_is_valid(lbl_back) then
    lbl_back.Visible = false
  end
  if nx_find_custom(form, "last_1step_subform") and form.last_1step_subform ~= "" and form.last_1step_subform ~= nil then
    local cur_subform = nx_value(form.last_1step_subform)
    if nx_is_valid(cur_subform) then
      cur_subform:Close()
    end
  end
  form.last_1step_subform = SUBFORM_RELATION_NEWS[form_name]
  return true
end
function change_ctrls_size(form_name, target)
  local form = nx_value(FORM_RELATION_NEWS)
  if not nx_is_valid(form) then
    return false
  end
  if nx_string(form_name) == "" or form_name == nil then
    return false
  end
  if (not nx_find_custom(form, "last_1step_subform") or form.last_1step_subform ~= SUBFORM_RELATION_NEWS[form_name]) and form_name ~= "form_gossip_info" then
    return false
  end
  local subform = nx_value(SUBFORM_RELATION_NEWS[form_name])
  if not nx_is_valid(subform) then
    return false
  end
  local target_ctrl = nx_null()
  if target == nil then
    target_ctrl = get_operation_ctrl(subform, SUBFORM_TEMPLATE_GBOX_LIST[form_name][2])
    if not nx_is_valid(target_ctrl) then
      return false
    end
  else
    if not nx_is_valid(target) then
      return false
    end
    target_ctrl = target
  end
  local template_ctrl = get_operation_ctrl(form.groupbox_template, SUBFORM_TEMPLATE_GBOX_LIST[form_name][1])
  if not nx_is_valid(template_ctrl) then
    return false
  end
  if not inner_change_ctrls_size(subform, target_ctrl, form, template_ctrl) then
    return false
  end
  if form_name == "form_feed_reply4" then
    local form_feed_reply = nx_value(SUBFORM_RELATION_NEWS.form_feed_reply)
    if nx_is_valid(form_feed_reply) then
      form_feed_reply.Visible = true
    end
  end
  show_no_msg_lbl(false)
  if form.last_1step_subform == SUBFORM_RELATION_NEWS.form_feed_info and nx_find_custom(form, "msg_count") and nx_int(form.msg_count) == nx_int(0) then
    show_no_msg_lbl(true)
  end
  return true
end
function inner_change_ctrls_size(subform, target_ctrl, form, template_ctrl)
  if not (nx_is_valid(subform) and nx_is_valid(target_ctrl) and nx_is_valid(form)) or not nx_is_valid(template_ctrl) then
    return false
  end
  local target_ctrl_type = nx_name(target_ctrl)
  local template_ctrl_type = nx_name(template_ctrl)
  if template_ctrl_type ~= "GroupBox" and template_ctrl_type ~= "GroupScrollableBox" then
    return false
  end
  subform.Left = 0
  subform.Top = 0
  subform.Width = form.groupbox_content.Width
  subform.Height = form.groupbox_content.Height
  target_ctrl.Left = subform.Left
  target_ctrl.Top = subform.Top
  target_ctrl.Width = subform.Width
  target_ctrl.Height = subform.Height
  if template_ctrl.Name == "groupbox_template_gossip" then
    subform.groupbox_gossip.Left = target_ctrl.Left
    subform.groupbox_gossip.Top = target_ctrl.Top
    subform.groupbox_gossip.Width = target_ctrl.Width
    subform.groupbox_gossip.Height = target_ctrl.Height
  end
  local info_count = 0
  if target_ctrl_type == "GroupScrollableBox" then
    local tartget_sbar = target_ctrl.VScrollBar
    local template_sbar = form.template_ScrollBar
    if nx_is_valid(tartget_sbar) and nx_is_valid(template_sbar) then
      tartget_sbar.BackImage = template_sbar.BackImage
      local prop_list = {
        "NormalImage",
        "FocusImage",
        "PushImage"
      }
      set_ctrl_prop(tartget_sbar.DecButton, template_sbar.DecButton, prop_list)
      set_ctrl_prop(tartget_sbar.IncButton, template_sbar.IncButton, prop_list)
      set_ctrl_prop(tartget_sbar.TrackButton, template_sbar.TrackButton, prop_list)
    end
    if template_ctrl.Name == "groupscrollbox_template_reply" then
    else
      target_ctrl.IsEditMode = true
      local target_gbox_list = target_ctrl:GetChildControlList()
      for _, target_gbox in ipairs(target_gbox_list) do
        change_gbox_size(target_gbox, template_ctrl)
      end
      target_ctrl.IsEditMode = false
      target_ctrl:ResetChildrenYPos()
      info_count = table.getn(target_gbox_list)
      if nx_find_custom(form, "msg_count") then
        form.msg_count = info_count
      end
    end
  elseif target_ctrl_type == "GroupBox" and template_ctrl_type == "GroupBox" then
    change_gbox_size(target_ctrl, template_ctrl)
  else
    return false
  end
  return true
end
function change_gbox_size(target_gbox, template_gbox)
  if not nx_is_valid(target_gbox) or not nx_is_valid(template_gbox) then
    return
  end
  target_gbox.Width = template_gbox.Width
  target_gbox.Height = template_gbox.Height
  local tartget_list = target_gbox:GetChildControlList()
  local template_list = template_gbox:GetChildControlList()
  local tartget_count = table.getn(tartget_list)
  local template_count = table.getn(template_list)
  if nx_int(tartget_count) ~= nx_int(template_count) then
    nx_msgbox("bad count " .. nx_string(nx_string(tartget_count)) .. " " .. nx_string(nx_string(template_count)))
    return false
  end
  for i = 1, tartget_count do
    if nx_name(tartget_list[i]) == nx_name(template_list[i]) then
      tartget_list[i].Left = template_list[i].Left
      tartget_list[i].Top = template_list[i].Top
      tartget_list[i].Width = template_list[i].Width
      tartget_list[i].Height = template_list[i].Height
      if nx_name(tartget_list[i]) == "MultiTextBox" and template_gbox.Name ~= "groupbox_template_reply" then
        tartget_list[i].ViewRect = template_list[i].ViewRect
        tartget_list[i]:Reset()
      end
      if template_list[i].Name == "template_gossip_lbl_back" then
        tartget_list[i].BackImage = template_list[i].BackImage
      end
    else
      nx_msgbox(nx_string(i) .. " " .. nx_name(tartget_list[i]) .. " <bad type> " .. nx_string(nx_string(tartget_list[i].Name)) .. "----" .. nx_string(nx_string(template_list[i].Name)))
    end
  end
end
function create_subform_in_gbox(gbox, name)
  local form_name = nx_string(name)
  if not nx_is_valid(gbox) or form_name == "" then
    return nx_null()
  end
  local cur_subform = util_get_form(SUBFORM_RELATION_NEWS[form_name], true, false)
  if not nx_is_valid(cur_subform) then
    return nx_null()
  end
  cur_subform.Left = 0
  cur_subform.Top = 0
  cur_subform.Width = gbox.Width
  cur_subform.Height = gbox.Height
  cur_subform.Visible = true
  gbox:DeleteAll()
  gbox:Add(cur_subform)
  if form_name ~= "form_world_news" and form_name ~= "form_feed_reply" and form_name ~= "form_feed_reply2" and form_name ~= "form_feed_reply3" then
    nx_execute(SUBFORM_RELATION_NEWS[form_name], "open_form", true)
  end
  return cur_subform
end
function is_form_relation_news_show()
  local form = nx_value(FORM_RELATION_NEWS)
  if not nx_is_valid(form) then
    return false
  end
  return true
end
function change_form_size()
  local form = nx_value(FORM_RELATION_NEWS)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
end
function get_operation_ctrl(parent_ctrl, ctrl_name)
  local ctrl = parent_ctrl:Find(ctrl_name)
  if nx_is_valid(ctrl) then
    return ctrl
  end
  local next_level_list = parent_ctrl:GetChildControlList()
  for _, child in ipairs(next_level_list) do
    if nx_is_valid(child) and (nx_name(child) == "GroupScrollableBox" or nx_name(child) == "GroupBox") then
      ctrl = child:Find(ctrl_name)
      if nx_is_valid(ctrl) then
        return ctrl
      end
    end
  end
  return nx_null()
end
function set_ctrl_prop(targetctrl, template_ctrl, prop_list)
  if not nx_is_valid(targetctrl) or not nx_is_valid(template_ctrl) then
    return
  end
  for i = 1, table.getn(prop_list) do
    nx_set_property(targetctrl, prop_list[i], nx_property(template_ctrl, prop_list[i]))
  end
end
function save_reply_form_data(gbox)
  local form = nx_value(FORM_RELATION_NEWS)
  if not nx_is_valid(form) then
    return false
  end
  if not nx_is_valid(gbox) then
    return false
  end
  local prop_count = table.getn(reply_list)
  for i = 1, prop_count do
    if nx_find_custom(gbox, reply_list[i]) then
      nx_set_custom(form, reply_list[i], nx_custom(gbox, reply_list[i]))
    end
  end
  return true
end
function get_reply_form_data(index)
  local form = nx_value(FORM_RELATION_NEWS)
  if not nx_is_valid(form) then
    return nil
  end
  if not nx_find_custom(form, reply_list[nx_number(index)]) then
    return nil
  end
  return nx_custom(form, reply_list[nx_number(index)])
end
function show_no_msg_lbl(b_show)
  local form = nx_value(FORM_RELATION_NEWS)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_no_msg.Visible = nx_boolean(b_show)
end
