require("const_define")
function SetIniDocument(name, ini)
  animationini = nx_create("IniDocument")
  animationini.FileName = nx_string(nx_resource_path() .. ini)
  animationini:LoadFromFile()
  nx_set_value(nx_string(name), animationini)
end
function open_animation(form, index, flag, name)
  create_animation(form, index, flag, name)
end
function create_animation(form, index, flag, name)
  if check_is_form_close(form) then
    return
  end
  local animation_info = get_step_info(index, name)
  if animation_info == nil then
    return 1
  end
  if animation_info[1] == "animation" then
    local gui = nx_value("gui")
    local ini = nx_value(name)
    local animation = nx_null()
    if animation_info[3] == "true" then
      animation = nx_value(animation_info[2])
      animation = gui:Create("Animation")
      animation.Visible = false
      animation.form = form
      animation.endflag = false
      animation.name = name
      form:Add(animation)
      start_animation(form, animation, index, animation_info)
    end
  elseif animation_info[1] == "item" then
    local group = nx_custom(form, nx_string(animation_info[2]))
    group.name = name
    if not nx_is_valid(group) then
      return 1
    end
    group.endflag = false
    local startitem = nx_custom(form, nx_string(animation_info[3]))
    local enditem = nx_custom(form, nx_string(animation_info[4]))
    start_item_animiation(form, group, startitem, enditem, animation_info, flag)
  elseif animation_info[1] == "itemlist" then
    local group = nx_custom(form, nx_string(animation_info[2]))
    local playtime = nx_number(animation_info[3])
    start_itemlist_animation(form, group, animation_info, playtime, flag)
  end
end
function start_item_animiation(form, item, startitem, enditem, animation_info, flag)
  if check_is_form_close(form) then
    return
  end
  item.VAnchor = startitem.VAnchor
  item.HAnchor = startitem.HAnchor
  item.Top = startitem.Top
  item.Left = startitem.Left
  local parentform = form.ParentForm
  local startaphle = nx_int(animation_info[5])
  local endaphle = nx_int(animation_info[6])
  local finishtime = animation_info[7]
  nx_execute(nx_current(), "play_item_animation", form, item, enditem, startaphle, endaphle, finishtime, flag)
  local num = table.getn(animation_info)
  if num - 7 > 0 then
    local count = (num - 7) / 2
    local created_table = {}
    local real_time_count = 0
    while true do
      if not nx_is_valid(item) then
        return 1
      end
      if item.endflag == true then
        return 1
      end
      local new_index = 8
      local all_create = true
      local time_count = nx_number(item.playtime)
      if nx_number(time_count) > nx_number(finishtime) then
        time_count = real_time_count * 1000
      end
      for i = 1, count do
        if created_table[new_index] == nil or not created_table[new_index] then
          local need_time = nx_number(animation_info[new_index + 1])
          if time_count >= need_time then
            nx_execute(nx_current(), "create_animation", form, nx_int(animation_info[new_index]), flag, form.name)
            created_table[new_index] = true
          else
            all_create = false
          end
        end
        new_index = new_index + 2
      end
      if all_create then
        break
      end
      real_time_count = real_time_count + nx_pause(0)
      if check_is_form_close(form) then
        return
      end
    end
  end
end
function play_item_animation(form, item, enditem, startaphle, endaphle, finishtime, flag)
  local gui = nx_value("gui")
  item.playtime = 0
  item.Visible = true
  local res = endaphle - startaphle
  local finish_alpha, start_alpah
  local parentform = form.ParentForm
  item.BlendAlpha = start_alpah
  finish_alpha = endaphle - startaphle
  start_alpah = startaphle
  local startTop = item.Top
  local startLeft = item.Left
  local offleft = enditem.Left - item.Left
  local offTop = enditem.Top - item.Top
  local topmove = false
  local leftmove = false
  local itemplaytime = 0
  local itemtop = 0
  local itemleft = 0
  if nx_number(offleft) == 0 then
    topmove = true
  elseif nx_number(offTop) == 0 then
    leftmove = true
  end
  while itemplaytime <= nx_number(finishtime) do
    if not nx_is_valid(form) then
      return 1
    end
    if item.endflag == true then
      break
    end
    if topmove then
      itemtop = startTop + itemplaytime / finishtime * offTop
      if nx_is_valid(item) then
        item.Top = itemtop
      end
    elseif leftmove then
      itemleft = startLeft + itemplaytime / finishtime * offleft
      if nx_is_valid(item) then
        item.Left = itemleft
      end
    end
    item.BlendAlpha = start_alpah + itemplaytime / finishtime * finish_alpha
    if not nx_is_valid(item) then
      return 1
    end
    itemplaytime = itemplaytime + 1 + nx_pause(0) * 1000
    if not nx_is_valid(item) then
      return 1
    else
      item.playtime = itemplaytime
    end
    if not nx_is_valid(form) then
      return 1
    end
  end
  item.Top = enditem.Top
  item.Left = enditem.Left
  item.BlendAlpha = start_alpah + finish_alpha
end
function start_animation(form, animation, index, animation_info)
  if check_is_form_close(form) then
    return
  end
  local gui = nx_value("gui")
  local timer = nx_value(GAME_TIMER)
  local form = animation.form
  local controlitem = nx_custom(form, nx_string(animation_info[7]))
  if nx_is_valid(controlitem) then
    animation.VAnchor = controlitem.VAnchor
    animation.HAnchor = controlitem.HAnchor
    animation.Top = controlitem.Top
    animation.Left = controlitem.Left
  else
    animation.Top = 0
    animation.Left = 0
  end
  animation.index = index
  gui.AnimationManager:StartAnimation(animation_info[2])
  animation.AnimationImage = animation_info[2]
  animation.Visible = true
  flag = animation_info[4]
  local startflag = true
  if flag == "true" then
    if not nx_is_valid(controlitem) then
      return
    end
    local upflag = nx_string(animation_info[9])
    if upflag == "true" then
      form:ToFront(controlitem)
      form:ToFront(animation)
    elseif upflag == "false" then
      form:ToFront(animation)
      form:ToFront(controlitem)
    end
    animation.Loop = true
  else
    nx_bind_script(animation, nx_current(), "animation_init")
    animation.Loop = false
    nx_callback(animation, "on_animation_end", "animation_event_end")
  end
  local Athwartflag = nx_string(animation_info[5])
  if Athwartflag == "true" then
    animation.Athwart = true
  elseif Athwartflag == "false" then
    animation.Athwart = false
  end
  animation:Stop()
  animation:Play()
  child_data = nx_call("util_gui", "get_arraylist", "UIAnimation_" .. nx_string(animation) .. "_" .. nx_string(animation_info[2]))
  child_data.Name = nx_string(animation_info[2])
  child_data.animation = animation
  form.Data:AddChild(child_data)
  local num = table.getn(animation_info)
  if 0 < num - 9 then
    local count = (num - 9) / 2
    local created_table = {}
    local real_time_count = 0
    while true do
      if nx_is_valid(animation) and animation.endflag == true then
        break
      end
      local new_index = 10
      local all_create = true
      local time_count = real_time_count
      for i = 1, count do
        if created_table[new_index] == nil or not created_table[new_index] then
          local need_time = nx_number(animation_info[new_index + 1])
          if need_time <= time_count * 1000 then
            nx_execute(nx_current(), "create_animation", form, nx_int(animation_info[new_index]), startflag, nx_string(form.name))
            created_table[new_index] = true
          else
            all_create = false
          end
        end
        new_index = new_index + 2
      end
      if all_create then
        break
      end
      real_time_count = real_time_count + nx_pause(0)
      if check_is_form_close(form) then
        if nx_is_valid(animation) then
          animation:Stop()
        end
        return
      end
    end
  end
end
function start_itemlist_animation(form, group, animation_info, playtime, flag)
  if check_is_form_close(form) then
    return 1
  end
  nx_execute(nx_current(), "play_itemlist_animation", form, group, playtime)
  local num = table.getn(animation_info)
  if num - 3 > 0 then
    local count = (num - 3) / 2
    local created_table = {}
    local real_time_count = 0
    while true do
      if not nx_is_valid(group) then
        return 1
      end
      if item.endflag == true then
        return 1
      end
      local new_index = 4
      local all_create = true
      local time_count = nx_number(group.playtime)
      if nx_number(time_count) > nx_number(playtime) then
        time_count = real_time_count * 1000
      end
      for i = 1, count do
        if created_table[new_index] == nil or not created_table[new_index] then
          local need_time = nx_number(animation_info[new_index + 1])
          if time_count >= need_time then
            nx_execute(nx_current(), "create_animation", form, nx_int(animation_info[new_index]), flag, form.name)
            created_table[new_index] = true
          else
            all_create = false
          end
        end
        new_index = new_index + 2
      end
      if all_create then
        break
      end
      real_time_count = real_time_count + nx_pause(0)
      if check_is_form_close(form) then
        return
      end
    end
  end
end
function play_itemlist_animation(form, item, playtime)
  local gui = nx_value("gui")
  item.playtime = 0
  local itemplaytime = 0
  local timer = nx_value(GAME_TIMER)
  local itemtable = item:GetChildControlList()
  local count = table.getn(itemtable)
  local offtime = playtime / count
  for i = 1, count do
    timer:Register(offtime * i, 1, nx_current(), "show_itemlist", itemtable[i], 1, 0)
  end
  while itemplaytime <= nx_number(playtime) do
    itemplaytime = itemplaytime + 1 + nx_pause(0) * 1000
    if nx_is_valid(item) then
      item.playtime = itemplaytime
    end
  end
end
function show_itemlist(item)
  item.Visible = true
end
function animation_event_end(animation, ani_name, mode)
  local index = animation.index
  local form = animation.ParentForm
  local animation_info = get_step_info(index, nx_string(animation.name))
  local name = animation_info[2]
  local controlitem = nx_custom(form, nx_string(animation_info[7]))
  if not nx_is_valid(controlitem) then
    local group = animation.Parent
    controlitem = nx_custom(group, nx_string(animation_info[3]))
  end
  local flag = animation_info[8]
  if nx_is_valid(controlitem) and flag == "true" and animation.endflag == false then
    controlitem.Visible = true
  end
  if nx_is_valid(controlitem) and flag == "false" then
    controlitem.Visible = false
  end
  local gui = nx_value("gui")
  gui:Delete(animation)
end
function get_step_info(step, name)
  local ini = nx_value(name)
  local ani_info_str = ini:ReadString("creat_animation", nx_string(step), "")
  if ani_info_str == "" then
    return
  end
  local str_lst = nx_function("ext_split_string", ani_info_str, ",")
  return str_lst
end
function hideitem(form, name)
  local ini = nx_value(nx_string(name))
  local itemlist = ini:GetItemList("creat_animation")
  for i = 1, table.getn(itemlist) do
    local ani_info_str = ini:ReadString("creat_animation", nx_string(i), "")
    local str_lst = nx_function("ext_split_string", ani_info_str, ",")
    local flag = nx_string(str_lst[1])
    if flag == "item" then
      local item = nx_custom(form, nx_string(str_lst[2]))
      item.Visible = false
    elseif flag == "animation" then
      local item = nx_custom(form, nx_string(str_lst[7]))
      item.Visible = false
    elseif flag == "itemlist" then
      local item = nx_custom(form, nx_string(str_lst[2]))
      local itemtable = item:GetChildControlList()
      local count = table.getn(itemtable)
      for i = 1, count do
        itemtable[i].Visible = false
      end
    end
  end
end
function close_animation_ini(file)
  local ini = nx_value()
  nx_destroy(ini)
end
function close_animation(form)
  local animation_table = form.Data:GetChildList()
  for i, item in pairs(animation_table) do
    if nx_is_valid(item.animation) then
      item.animation.Visible = false
      item.animation:Stop()
    end
    form.Data:RemoveChild(item.Name)
  end
end
function check_is_form_close(form)
  if not nx_is_valid(form) then
    return true
  end
  if not form.Visible then
    return true
  end
  return false
end
