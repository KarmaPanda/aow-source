require("util_gui")
require("util_functions")
require("custom_handler")
local FORM_MAIN = "form_stage_main\\form_school_destroy\\form_school_destroy_main"
local INI_SHCOOL_SCENE = "share\\SchoolExtinct\\school_name_scene_id.ini"
local DESTROY_FORM = {
  "",
  "form_stage_main\\form_school_destroy\\form_invade_battle",
  "form_stage_main\\form_school_destroy\\form_school_destroy_extermination",
  "form_stage_main\\form_school_destroy\\form_school_destroy_fightback"
}
local school_image_path = {
  [12] = {
    back_image_path = "gui\\special\\school_destroy\\school08.png",
    current_stage_path = "gui\\special\\school_destroy\\title08.png"
  },
  [11] = {
    back_image_path = "gui\\special\\school_destroy\\school07.png",
    current_stage_path = "gui\\special\\school_destroy\\title07.png"
  },
  [10] = {
    back_image_path = "gui\\special\\school_destroy\\school06.png",
    current_stage_path = "gui\\special\\school_destroy\\title06.png"
  },
  [9] = {
    back_image_path = "gui\\special\\school_destroy\\school05.png",
    current_stage_path = "gui\\special\\school_destroy\\title05.png"
  },
  [8] = {
    back_image_path = "gui\\special\\school_destroy\\school04.png",
    current_stage_path = "gui\\special\\school_destroy\\title04.png"
  },
  [7] = {
    back_image_path = "gui\\special\\school_destroy\\school03.png",
    current_stage_path = "gui\\special\\school_destroy\\title03.png"
  },
  [6] = {
    back_image_path = "gui\\special\\school_destroy\\school02.png",
    current_stage_path = "gui\\special\\school_destroy\\title02.png"
  },
  [5] = {
    back_image_path = "gui\\special\\school_destroy\\school01.png",
    current_stage_path = "gui\\special\\school_destroy\\title01.png"
  }
}
function open_form()
  local ST_FUNCTION_SCHOOL_DESTROY_MAIN = 744
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_SCHOOL_DESTROY_MAIN) then
    custom_sysinfo(1, 1, 1, 2, "19919")
    return
  end
  local form = nx_value(FORM_MAIN)
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
  else
    util_show_form(FORM_MAIN, true)
  end
end
function main_form_init(form)
  if not nx_is_valid(form) then
    return
  end
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  local rbtn = form.rbtn_1
  if nx_is_valid(rbtn) then
    rbtn.Checked = true
  end
  form.lbl_2.Visible = false
  form.lbl_3.Visible = false
  form.lbl_4.Visible = false
  on_school_Extinct(form)
end
function on_school_historylog(...)
  local form = nx_value(FORM_MAIN)
  if not nx_is_valid(form) then
    return
  end
  local log_table = util_split_string(arg[1], "|")
  local count = table.getn(log_table)
  if count < 1 then
    return
  end
  local ini_school_scene = get_ini(INI_SHCOOL_SCENE, true)
  if not nx_is_valid(ini_school_scene) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.textgrid_1.CanSelectRow = false
  form.textgrid_1:ClearRow()
  form.textgrid_1:SetColAlign(0, "Left")
  local grid_title = gui.TextManager:GetFormatText("ui_school_destroy_log")
  form.textgrid_1:SetColTitle(0, nx_widestr(grid_title))
  local log_table_count = table.getn(log_table)
  if log_table_count < 1 then
    return
  end
  for i = 1, log_table_count - 1 do
    local row = form.textgrid_1:InsertRow(-1)
    local log_table_sub = util_split_string(log_table[i], ";")
    if table.getn(log_table_sub) < 5 then
      return
    end
    local str_type
    if nx_string(log_table_sub[2]) == "0" then
      if nx_string(log_table_sub[4]) == "0" then
        str_type = "19914"
      elseif nx_string(log_table_sub[4]) == "1" then
        str_type = "19913"
      end
    elseif nx_string(log_table_sub[2]) == "1" then
      if nx_string(log_table_sub[4]) == "1" then
        str_type = "19915"
      elseif nx_string(log_table_sub[4]) == "0" then
        str_type = "19916"
      end
    end
    local school_name = ini_school_scene:ReadString("config", nx_string(log_table_sub[3]), "")
    local str = gui.TextManager:GetFormatText(str_type, nx_string(log_table_sub[1]), nx_string(school_name), nx_int(log_table_sub[5]))
    form.textgrid_1:SetGridText(row, 0, nx_widestr(str))
  end
end
function on_school_Extinct(form)
  if not nx_is_valid(form) then
    return
  end
  local SchoolExtinct = nx_value("SchoolExtinct")
  if not nx_is_valid(SchoolExtinct) then
    return nx_null()
  end
  local ExtinctedSchoolID = SchoolExtinct:GetExtinctSchoolSceneId()
  local ExtinctedSchoolName = SchoolExtinct:GetExtinctSchool()
  local ini_school_scene = get_ini(INI_SHCOOL_SCENE, true)
  if not nx_is_valid(ini_school_scene) then
    return
  end
  local item_count = ini_school_scene:GetSectionItemCount(0)
  if ExtinctedSchoolName == "" then
    form.lbl_6.BackImage = "gui\\special\\school_destroy\\title.png"
    form.lbl_8.BackImage = "gui\\special\\school_destroy\\main.png"
  else
    for i = 1, item_count do
      local school_id = ini_school_scene:GetSectionItemKey("config", i - 1)
      if nx_int(ExtinctedSchoolID) == nx_int(school_id) and school_image_path[ExtinctedSchoolID] then
        form.lbl_6.BackImage = school_image_path[ExtinctedSchoolID].current_stage_path
        form.lbl_8.BackImage = school_image_path[ExtinctedSchoolID].back_image_path
      end
    end
  end
end
function on_school_current_stage(...)
  local form = nx_value(FORM_MAIN)
  if not nx_is_valid(form) then
    return
  end
  local count = table.getn(arg)
  if count < 1 then
    return
  end
  set_bottom_page_state(form, arg[1])
end
function set_bottom_page_state(form, stage_num)
  if stage_num == 0 then
    form.lbl_2.Visible = true
    form.lbl_3.Visible = false
    form.lbl_4.Visible = false
  elseif stage_num == 1 then
    form.lbl_2.Visible = false
    form.lbl_3.Visible = true
    form.lbl_4.Visible = true
  else
    form.lbl_2.Visible = false
    form.lbl_3.Visible = false
    form.lbl_4.Visible = false
  end
end
function on_main_form_close(form)
  for i, sub_form in ipairs(DESTROY_FORM) do
    local form_sub_page = nx_value(sub_form)
    if nx_is_valid(form_sub_page) then
      nx_destroy(form_sub_page)
    end
  end
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_cancel_click(btn)
  local form = nx_value(FORM_MAIN)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
end
function on_rbtn_sub_form_checked_changed(rbtn)
  if rbtn.Checked ~= true then
    return
  end
  local form = nx_value(FORM_MAIN)
  if not nx_is_valid(form) then
    return
  end
  local form_type = nx_number(rbtn.DataSource)
  local gbox_subform = form.groupbox_all
  if form_type == 1 then
    form.groupbox_2.Visible = true
    gbox_subform.Visible = false
    on_school_Extinct(form)
    nx_execute("custom_sender", "custom_shcool_destroy", 40)
    nx_execute("custom_sender", "custom_shcool_destroy", 41)
  else
    form.groupbox_2.Visible = false
    gbox_subform.Visible = true
    gbox_subform:DeleteAll()
    local cur_subform = nx_execute(DESTROY_FORM[form_type], "open_form", form)
    if not nx_is_valid(cur_subform) then
      return
    end
    gbox_subform:Add(cur_subform)
    cur_subform.Left = -88
    cur_subform.Top = -152
  end
end
