function image_animation_manager_init(self)
  nx_callback(self, "on_animation_event", "on_animation_event")
  self.Data = nx_call("util_gui", "get_arraylist", "image_animation_manager")
end
function on_animation_event(self, name, mode, lusfile, luafunc, id)
  if nx_is_valid(id) then
    nx_execute(lusfile, luafunc, id, name, mode)
  end
end
