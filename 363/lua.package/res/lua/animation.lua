require("util_functions")
function load_animation_info()
  animationini = nx_execute("util_functions", "get_ini", "ini\\ui\\animation\\animation.ini")
  if not nx_is_valid(animationini) then
    nx_msgbox("ini\\ui\\animation\\animation.ini" .. get_msg_str("msg_052"))
  end
  nx_set_value("animationini", animationini)
end
function get_animation_info(name)
  local ini = nx_value("animationini")
  local ani_info_str = ini:ReadString("animation", name, "")
  if ani_info_str == "" then
    return
  end
  local str_lst = util_split_string(ani_info_str, ",")
  local ani_info = {
    form_name = {},
    crl_name = {}
  }
  ani_info.form_name = str_lst[1]
  ani_info.crl_name = str_lst[2]
  return ani_info
end
function show_animation(name, index)
  local ani_info = get_animation_info(name)
  local form = nx_value(ani_info.form_name)
  if nx_is_valid(form) then
    if form.Visible == false then
      return
    end
    local crl = form:Find(ani_info.crl_name)
    if nx_is_valid(crl) then
      if crl.Visible == false then
        return
      end
      local animation = nx_null()
      animation = nx_value(name)
      if nx_is_valid(animation) then
        return
      end
      local gui = nx_value("gui")
      animation = gui:Create("Animation")
      animation.AnimationImage = name
      animation.AutoSize = true
      form:Add(animation)
      if index == -1 then
        animation.Top = crl.Top
        animation.Left = crl.Left
        animation.Width = crl.Width
        animation.Height = crl.Height
      else
        local strpos = util_split_string(crl.ViewRect, ",")
        local x1 = crl.AbsLeft + strpos[1]
        local y1 = crl.AbsTop + strpos[2]
        local x2 = crl:GetItemLeft(nx_int(index))
        local y2 = crl:GetItemTop(nx_int(index))
        animation.AbsLeft = x1 + x2
        animation.AbsTop = y1 + y2
      end
      animation.index = nx_int(index)
      animation.Visible = true
      nx_set_value(name, animation)
    end
  end
end
function del_animation(name)
  local gui = nx_value("gui")
  local animation = nx_value(name)
  if not nx_is_valid(animation) then
    return
  end
  gui:Delete(animation)
  nx_set_value(name, nx_null())
end
function check_has_animation(name, index)
  local animation = nx_value(name)
  if not nx_is_valid(animation) then
    return false
  end
  if nx_int(index) == nx_int(animation.index) then
    return true
  end
  return false
end
