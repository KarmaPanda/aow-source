require("util_functions")
require("util_static_data")
require("utils")
require("util_gui")
require("define\\tip_define")
local FORM_NAME = "form_stage_main\\form_tips\\form_link_tips"
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  if nx_find_custom(form, "link_tips_index") then
    tips_manager:ClearLinkTipsControlInfo(form.link_tips_index)
  end
end
