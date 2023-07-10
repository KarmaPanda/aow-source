require("util_gui")
require("form_stage_main\\switch\\url_define")
local CLIENT_CUSTOMMSG_ACTIVITY_MANAGE = 182
local CLIENT_SUBMSG_REQUEST_FREE_WISH = 7
local CLIENT_SUBMSG_REQUEST_COST_WISH = 8
function on_main_form_init(self)
  self.Fixed = true
  self.change = 1
  self.image_index = 0
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  load_image_resource(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "change_image", self)
    timer:Register(3000, -1, nx_current(), "change_image", self, -1, -1)
  end
  return 1
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "change_image", form)
  end
  nx_destroy(form)
  return 1
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function on_btn_simple_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_MANAGE), nx_int(CLIENT_SUBMSG_REQUEST_FREE_WISH))
end
function on_btn_cost_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local dialog = util_get_form("form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  dialog.mltbox_info:Clear()
  dialog.mltbox_info.HtmlText = nx_widestr(util_text("ui_wish_info_1"))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_MANAGE), nx_int(CLIENT_SUBMSG_REQUEST_COST_WISH))
end
function on_btn_get_capture(btn)
  local form = btn.ParentForm
  if nx_custom(btn, "show_image") and btn.show_image ~= "" then
    form.btn_image.NormalImage = btn.show_image
  end
  form.change = 0
end
function on_btn_lost_capture(btn)
  local form = btn.ParentForm
  form.change = 1
end
function show_form_wish(...)
  if #arg < 1 then
    return
  end
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form_main) then
    return
  end
  local op = arg[1]
  if nx_int(op) == nx_int(0) then
    local form = nx_value("form_stage_main\\form_activity\\form_activity_seven")
    if nx_is_valid(form) then
      local parent_ctrl = form.Parent
      if nx_is_valid(parent_ctrl) then
        local parent_form = parent_ctrl.ParentForm
        if nx_is_valid(parent_form) and nx_script_name(parent_form) == "form_stage_main\\form_dbomall\\form_dbomall" then
          parent_form:Close()
        else
          form:Close()
        end
      else
        form:Close()
      end
    end
  elseif nx_int(op) == nx_int(1) then
  end
end
function change_image(form)
  if form.change == 0 then
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  form.image_index = form.image_index + 1
  local array_name = form.Name
  local image_node = common_array:FindChild(array_name, nx_string(form.image_index))
  if not image_node then
    form.image_index = 0
    image_node = common_array:FindChild(array_name, nx_string(form.image_index))
  end
  form.btn_image.NormalImage = image_node
end
function on_btn_url_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not nx_custom(btn, "url") then
    return
  end
  switch_manager:OpenUrl(nx_int(btn.url))
end
function load_image_resource(form)
  local ini = nx_execute("util_functions", "get_ini", "ini\\activity\\form_activity_seven.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex("image_set")
  if index < 0 then
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local array_name = form.Name
  if common_array:FindArray(array_name) then
    common_array:RemoveArray(array_name)
  end
  common_array:AddArray(array_name, form, 60, false)
  local image_count = ini:GetSectionItemCount(index)
  for i = 0, image_count - 1 do
    common_array:AddChild(array_name, nx_string(i), ini:GetSectionItemValue(index, i))
  end
  local default_image = common_array:FindChild(array_name, nx_string(0))
  if default_image then
    form.btn_image.NormalImage = default_image
  end
  index = ini:FindSectionIndex("focus_image")
  if index < 0 then
    return
  end
  local btn_count = ini:GetSectionItemCount(index)
  for i = 0, btn_count - 1 do
    local btn_name = ini:GetSectionItemKey(index, i)
    local btn = form:Find(btn_name)
    if nx_is_valid(btn) then
      btn.show_image = ini:GetSectionItemValue(index, i)
    end
  end
  index = ini:FindSectionIndex("url")
  if index < 0 then
    return
  end
  form.btn_url.url = ini:GetSectionItemValue(index, 0)
end
