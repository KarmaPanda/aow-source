require("share\\client_custom_define")
local FORM_SELF = "form_stage_main\\form_tvt\\form_tvt_active"
function on_main_form_open(self)
  req_active()
  req_for_loading(self)
end
function on_main_form_close(self)
  self.groupscrollbox_1:DeleteAll()
  nx_destroy(self)
end
function req_for_loading(form)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(1000, 30, nx_current(), "t_req_for_loading", form, -1, -1)
  end
end
function t_req_for_loading(form)
  if not nx_is_valid(form) then
    return
  end
  local groupscrollbox = form.groupscrollbox_1
  local t = groupscrollbox:GetChildControlList()
  if table.getn(t) > 0 then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "t_req_for_loading", form)
    end
    return
  end
  nx_execute("custom_sender", "custom_req_active")
end
function req_active()
  local form = nx_value(FORM_SELF)
  if not nx_is_valid(form) then
    return
  end
  local now = os.time()
  local pre_time = nx_find_custom(form, "pre_time") and nx_custom(form, "pre_time") or 0
  if now - pre_time < 30 then
    return
  end
  nx_set_custom(form, "pre_time", now)
  nx_execute("custom_sender", "custom_req_active")
end
function on_srv_msg(...)
  local form = nx_value(FORM_SELF)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local groupscrollbox = form.groupscrollbox_1
  groupscrollbox:DeleteAll()
  local groupbox_base = form.groupbox_base
  local lbl_title_base = form.lbl_title_base
  local mltbox_content_base = form.mltbox_content_base
  local msg_size = table.maxn(arg)
  if msg_size < 2 then
    return
  end
  for i = 1, msg_size / 2 do
    local groupbox = gui:Create("GroupBox")
    groupbox.Width = groupbox_base.Width
    groupbox.BackColor = groupbox_base.BackColor
    groupbox.LineColor = groupbox_base.LineColor
    groupbox.DrawMode = groupbox_base.DrawMode
    local lbl_title = gui:Create("Label")
    local prop_list = nx_property_list(lbl_title_base)
    for i, prop in ipairs(prop_list) do
      if "Name" ~= prop then
        nx_set_property(lbl_title, prop, nx_property(lbl_title_base, prop))
      end
    end
    lbl_title.Text = nx_widestr(arg[2 * i - 1])
    groupbox:Add(lbl_title)
    local mltbox_content = gui:Create("MultiTextBox")
    mltbox_content.TextColor = mltbox_content_base.TextColor
    mltbox_content.SelectBarColor = mltbox_content_base.SelectBarColor
    mltbox_content.MouseInBarColor = mltbox_content_base.MouseInBarColor
    mltbox_content.ViewRect = mltbox_content_base.ViewRect
    mltbox_content.LineHeight = mltbox_content_base.LineHeight
    mltbox_content.Left = mltbox_content_base.Left
    mltbox_content.LineColor = mltbox_content_base.LineColor
    mltbox_content.NoFrame = mltbox_content_base.NoFrame
    mltbox_content.Top = mltbox_content_base.Top
    mltbox_content.Width = mltbox_content_base.Width
    mltbox_content.Height = mltbox_content_base.Height
    mltbox_content.Font = mltbox_content_base.Font
    mltbox_content.HasVScroll = false
    mltbox_content:Clear()
    mltbox_content:AddHtmlText(nx_widestr(arg[2 * i]), -1)
    mltbox_content.Height = mltbox_content:GetContentHeight()
    groupbox:Add(mltbox_content)
    groupbox.Height = lbl_title.Height + mltbox_content.Height + 20
    groupscrollbox:Add(groupbox)
  end
  groupscrollbox.IsEditMode = false
  groupscrollbox:ResetChildrenYPos()
end
