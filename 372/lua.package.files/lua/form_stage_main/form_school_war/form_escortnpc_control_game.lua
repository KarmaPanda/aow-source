require("util_functions")
require("util_gui")
local CLIENT_CUSTOMMSG_ESCORT_GAME = 398
local escort_game_key_table = {}
local gb_back_image = "gui\\special\\xiulian\\team_scroll.png"
local gb_back_image_0 = "gui\\special\\xiulian\\team_scroll_y.png"
local gb_back_image_1 = "gui\\special\\xiulian\\team_scroll_r.png"
function main_form_init(self)
  self.key_str = ""
  self.view_left = 0
  self.back_image_type = -1
  self.Fixed = false
end
function on_main_form_open(self)
  self.groupbox_key.Visible = true
  change_form_size()
  local form_name = "form_stage_main\\form_school_war\\form_escortnpc_control_game"
  local form_chat = util_get_form("form_stage_main\\form_main\\form_main_chat", false)
  if nx_is_valid(form_chat) then
    nx_execute("form_stage_main\\form_main\\form_main_chat", "hide_chat_edit", form_chat)
  end
  on_refresh_picture(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_main_form_shut(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
end
function show_form(keylist)
  local form = util_get_form("form_stage_main\\form_school_war\\form_escortnpc_control_game", true)
  form.Visible = true
  form.key_str = nx_string(keylist)
  form:Show()
  on_refresh_picture(form)
  return 1
end
function hide_form()
  local form = util_get_form("form_stage_main\\form_school_war\\form_escortnpc_control_game", true)
  on_main_form_close(form)
end
function change_form_size()
  local form = util_get_form("form_stage_main\\form_school_war\\form_escortnpc_control_game", false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_refresh_picture(form)
  if not nx_is_valid(form) then
    return
  end
  form.imagegrid_key:Clear()
  local pic_num = string.len(form.key_str)
  form.imagegrid_key.ClomnNum = pic_num
  local view_left = (form.imagegrid_key.Width - form.imagegrid_key.GridWidth * pic_num) / 2
  local view_right = view_left + form.imagegrid_key.GridWidth * pic_num
  form.imagegrid_key.ViewRect = nx_string(view_left) .. ",8," .. nx_string(view_right) .. ",8"
  form.view_left = nx_int(view_left)
  for i = 1, pic_num do
    local key = string.char(string.byte(form.key_str, i, i))
    local photo = "gui\\special\\xiulian\\" .. nx_string(key) .. ".png"
    form.imagegrid_key:AddItem(i - 1, photo, 0, 1, -1)
    form.imagegrid_key:SetItemName(i - 1, nx_widestr(nx_string(key)))
    form.imagegrid_key:SetItemMark(i - 1, 0)
    form.imagegrid_key:ChangeItemImageToBW(i - 1, true)
  end
  if form.back_image_type == -1 then
  else
    if form.back_image_type == 0 then
    else
    end
  end
end
function on_key_up(key_value)
  local form = util_get_form("form_stage_main\\form_school_war\\form_escortnpc_control_game", false)
  if not nx_is_valid(form) then
    return
  end
  local key = ""
  if nx_int(key_value) == nx_int(87) or nx_int(key_value) == nx_int(38) then
    key = "W"
  elseif nx_int(key_value) == nx_int(65) or nx_int(key_value) == nx_int(37) then
    key = "A"
  elseif nx_int(key_value) == nx_int(83) or nx_int(key_value) == nx_int(40) then
    key = "S"
  elseif nx_int(key_value) == nx_int(68) or nx_int(key_value) == nx_int(39) then
    key = "D"
  elseif nx_int(key_value) == nx_int(74) then
    key = "J"
  elseif nx_int(key_value) == nx_int(75) then
    key = "K"
  elseif nx_int(key_value) == nx_int(76) then
    key = "L"
  end
  if key == "" then
    return
  end
  table.insert(escort_game_key_table, key)
  local key_count = form.imagegrid_key.ClomnNum
  for index = 0, key_count - 1 do
    local dance_flag = form.imagegrid_key:GetItemMark(index)
    if nx_int(dance_flag) == nx_int(0) then
      if nx_ws_equal(nx_widestr(key), nx_widestr(form.imagegrid_key:GetItemName(index))) then
        form.imagegrid_key:SetItemMark(index, 1)
        form.imagegrid_key:ChangeItemImageToBW(index, false)
        do
          local gui = nx_value("gui")
          local animation = gui:Create("Animation")
          animation.AnimationImage = "train_team_flash"
          animation.Loop = false
          animation.Top = 125
          animation.Left = index * 40 + form.view_left + 175
          nx_bind_script(animation, nx_current())
          nx_callback(animation, "on_animation_end", "animation_key_end")
          form:Add(animation)
          animation:Play()
          if nx_int(index) == nx_int(key_count - 1) then
            local res_list = escort_game_key_table[1]
            for i = 2, table.getn(escort_game_key_table) do
              res_list = res_list .. escort_game_key_table[i]
            end
            nx_execute("custom_sender", "custom_escort_game_answer", CLIENT_CUSTOMMSG_ESCORT_GAME, nx_string(res_list))
            escort_game_key_table = {}
            util_show_form("form_stage_main\\form_school_war\\form_escortnpc_control_game", false)
          end
        end
        break
      end
      for i = 0, key_count - 1 do
        form.imagegrid_key:SetItemMark(i, 0)
        form.imagegrid_key:ChangeItemImageToBW(i, true)
        escort_game_key_table = {}
      end
      break
    end
  end
end
function animation_key_end(self)
  if not nx_is_valid(self) then
    return
  end
  self.Visible = false
  local gui = nx_value("gui")
  if nx_is_valid(self) then
    gui:Delete(self)
  end
end
