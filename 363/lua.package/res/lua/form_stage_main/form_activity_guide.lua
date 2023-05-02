require("form_stage_main\\switch\\url_define")
require("util_gui")
local FORM_ACTIVITY_GUILD = "form_stage_main\\form_activity_guide"
function on_main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  nx_execute("custom_sender", "custom_msg_activity_guide")
end
function on_main_form_close(self)
  local form_logic = nx_value("form_activity_guide")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  nx_destroy(self)
end
function on_btn_checked_changed(self)
  if not self.Checked then
    return
  end
  if self.Name == "ui_tvt_news" then
    local form = self.ParentForm
    form.groupbox_web.Visible = true
    form.ctrl_web.Visible = true
    form.ctrl_web:Renew()
    form.groupbox_detail.Visible = false
  else
    local form = self.ParentForm
    form.groupbox_web.Visible = false
    form.ctrl_web.Visible = false
    form.ctrl_web:Renew()
    form.groupbox_detail.Visible = true
    form.cur_name = self.Name
    local form_logic = nx_value("form_activity_guide")
    if nx_is_valid(form_logic) then
      form_logic:Update(self.ParentForm, self.Name)
    end
  end
end
function update_webview(self)
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    local url = switch_manager:GetUrl(URL_TYPE_TVT_NEWS)
    if url ~= "" then
      self.ctrl_web.Url = nx_widestr(url)
      self.ctrl_web:Refresh()
      self.ctrl_web:Enable()
    end
  end
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_imagegrid_prize_mousein_grid(grid, index)
  local form_logic = nx_value("form_activity_guide")
  if nx_is_valid(form_logic) then
    local form = grid.ParentForm
    local config_id = form_logic:GetItem(form.cur_name, index)
    if config_id ~= "" then
      nx_execute("tips_game", "show_tips_by_config", config_id, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
    end
  end
end
function on_imagegrid_prize_mouseout_grid(grid)
  local form = grid.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function load_activity_guide_info(...)
  local count = table.getn(arg)
  if count < 4 then
    return
  end
  if 10 < count then
    count = 10
  end
  local form = util_get_form(FORM_ACTIVITY_GUILD, false, false)
  if not nx_is_valid(form) then
    return
  end
  if form.Visible == false then
    return
  end
  local form_logic = nx_value("form_activity_guide")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  local load_flag = 0
  form_logic = nx_create("form_activity_guide")
  if nx_is_valid(form_logic) then
    nx_set_value("form_activity_guide", form_logic)
    local flag = false
    for i = 4, count do
      local xml_act = arg[i]
      if xml_act ~= nil then
        flag = form_logic:LoadInfo(nx_string(xml_act))
        if flag then
          load_flag = load_flag + 1
        end
      end
    end
  end
  if 1 <= load_flag then
    update_webview(form)
    local form_logic = nx_value("form_activity_guide")
    if nx_is_valid(form_logic) then
      form_logic:InitUI(form)
    end
  end
end
