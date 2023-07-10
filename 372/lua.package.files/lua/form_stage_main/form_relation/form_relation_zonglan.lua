require("role_composite")
require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\view_define")
require("game_object")
require("form_stage_main\\form_relation\\relation_define")
function on_main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  change_form_size()
end
function on_main_form_close(self)
  nx_destroy(self)
end
function show_form(flag)
  local form = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form) then
    return
  end
  if flag then
    local form_zonglan = nx_value("form_stage_main\\form_relation\\form_relation_zonglan")
    if not nx_is_valid(form_zonglan) then
      local form_zonglan = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_relation_zonglan", true, false)
      if nx_is_valid(form_zonglan) then
        form:Add(form_zonglan)
      end
    else
      form_zonglan:Show()
      form_zonglan.Visible = true
    end
  else
    local form_zonglan = nx_value("form_stage_main\\form_relation\\form_relation_zonglan")
    if nx_is_valid(form_zonglan) then
      form_zonglan.Visible = false
    end
  end
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form) then
    return
  end
  local form_zonglan = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_relation_zonglan", true, false)
  if nx_is_valid(form_zonglan) then
    form_zonglan.Left = 0
    form_zonglan.Top = 0
    form_zonglan.Width = form.Width
    form_zonglan.Height = form.Height - form.groupbox_rbtn.Height
  end
end
function on_relation_type_change_event(group_id, relation_type)
  if nx_int(group_id) ~= nx_int(RELATION_GROUP_ZONGLAN) then
    return
  end
  local form = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_zonglan.Checked = true
  form.rbtn_zonglan.Visible = false
  form.rbtn_renmai.NormalImage = "gui\\language\\ChineseS\\sns_new\\cbtn_rm_out1.png"
  form.rbtn_shili.NormalImage = "gui\\language\\ChineseS\\sns_new\\cbtn_sl_out1.png"
  form.rbtn_fujin.NormalImage = "gui\\language\\ChineseS\\sns_new\\cbtn_fj_out.png"
  form.rbtn_geren.NormalImage = "gui\\language\\ChineseS\\sns_new\\cbtn_gr_out1.png"
  if nx_int(relation_type) == nx_int(RELATION_TYPE_RENMAI) then
    form.rbtn_renmai.NormalImage = "gui\\language\\ChineseS\\sns_new\\cbtn_rm_down1.png"
  elseif nx_int(relation_type) == nx_int(RELATION_TYPE_SHILI) then
    form.rbtn_shili.NormalImage = "gui\\language\\ChineseS\\sns_new\\cbtn_sl_down1.png"
  elseif nx_int(relation_type) == nx_int(RELATION_TYPE_FUJIN) then
    form.rbtn_fujin.NormalImage = "gui\\language\\ChineseS\\sns_new\\cbtn_fj_down.png"
  elseif nx_int(relation_type) == nx_int(RELATION_TYPE_SELF) then
    form.rbtn_geren.NormalImage = "gui\\language\\ChineseS\\sns_new\\cbtn_gr_down1.png"
  end
end
function on_focus_change_event(relation_type, name)
end
