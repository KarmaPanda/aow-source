require("util_gui")
other_group_info = {}
function refresh_form(form)
  if nx_is_valid(form) then
  end
end
function data_bind_prop(self)
  if not nx_is_valid(self) then
    return
  end
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  for i, group in pairs(other_group_info) do
    databinder:AddRolePropertyBind(nx_string(group.prop), nx_string(group.type), self, nx_current(), nx_string(group.func))
  end
end
function del_data_bind_prop(self)
  if not nx_is_valid(self) then
    return
  end
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  for i, group in pairs(other_group_info) do
    databinder:DelRolePropertyBind(nx_string(group.prop), self)
  end
end
function form_others_init(form)
  form.Fixed = true
  return 1
end
function on_form_others_open(form)
  data_bind_prop(form)
end
function on_form_others_close(form)
  if not nx_is_valid(form) then
    return
  end
  del_data_bind_prop(form)
  nx_destroy(form)
  nx_set_value("form_others", nx_null())
end
function refresh_hy(self, prop_name, prop_type, prop_value)
end
