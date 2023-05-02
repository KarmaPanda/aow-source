require("utils")
require("util_gui")
local sex_table = {
  [1] = "ui_male",
  [2] = "ui_female"
}
local head_image = {
  [1] = {
    [1] = "gui\\create\\b_head_1_out.png",
    [2] = "gui\\create\\b_head_2_out.png",
    [3] = "gui\\create\\b_head_3_out.png",
    [4] = "gui\\create\\b_head_4_out.png"
  },
  [2] = {
    [1] = "gui\\create\\g_head_1_out.png",
    [2] = "gui\\create\\g_head_2_out.png",
    [3] = "gui\\create\\g_head_3_out.png",
    [4] = "gui\\create\\g_head_4_out.png"
  }
}
function add_card(form, file_name)
  local groupbox = form.groupscrollbox
  local gui = nx_value("gui")
  local pos = string.find(file_name, ".face") - 1
  local show_name = string.sub(file_name, 0, pos)
  local card = util_get_form("form_stage_create\\form_face_card", true, false, show_name)
  card.Left = groupbox.Left
  local str_data = nx_function("ext_read_face_file", form.path, file_name)
  if 0 == string.len(str_data) then
    return
  end
  local gender = string.byte(string.sub(str_data, 52, 52))
  if gender == nil then
    gender = 1
  end
  local photo = string.byte(string.sub(str_data, 54, 54))
  if photo == nil then
    photo = 1
  end
  local create_time = string.sub(str_data, 55, 70)
  local create_time_list = util_split_string(create_time, ".")
  if nx_int(create_time_list[1]) < nx_int(2013) then
    return
  elseif nx_int(create_time_list[1]) == nx_int(2013) then
    if nx_int(create_time_list[2]) < nx_int(7) then
      return
    elseif nx_int(create_time_list[2]) == nx_int(7) then
      local time_list = util_split_string(create_time_list[3], " ")
      if nx_int(time_list[1]) < nx_int(25) then
        return
      elseif nx_int(time_list[1]) == nx_int(25) then
        local time_info_list = util_split_string(time_list[2], ":")
        if nx_int(time_info_list[1]) < nx_int(22) then
          return
        end
      end
    end
  end
  card.lbl_name.Text = nx_widestr(show_name)
  if 1 <= gender and gender <= 2 then
    card.lbl_gender.Text = nx_widestr(gui.TextManager:GetText(sex_table[gender]))
    if 1 <= photo and photo <= 4 then
      card.lbl_pic.BackImage = head_image[gender][photo - 1]
    end
  end
  card.lbl_time.Text = nx_widestr(create_time)
  card.file_name = file_name
  card.show_name = show_name
  groupbox:Add(card)
end
function update_cards_show(form)
  local groupbox = form.groupscrollbox
  groupbox:DeleteAll()
  local path = form.path
  local file_search = form.file_search
  file_search:SearchFile(path, "*.face")
  local file_list = file_search:GetFileList()
  local file_count = table.getn(file_list)
  for i = 1, file_count do
    local file_name = file_list[i]
    add_card(form, file_name)
  end
  groupbox:ResetChildrenYPos()
  groupbox.IsEditMode = false
end
