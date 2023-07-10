require("util_functions")
require("share\\view_define")
require("form_stage_main\\puzzle_quest\\puzzle_quest_define")
require("share\\client_custom_define")
local FORM_SKILL_HELP = "form_stage_main\\puzzle_quest\\form_skill_help"
local skill_id_list = {}
local temp_skill_id_list = {}
local all_skill_id_list = {}
local extra_skill_id_list = {}
local TEMP_SKILL_REC = "TempGemSkillRec"
local SKILL_REC = "GemSkillRec"
local JOB_GEM_SKILL_REC = "JobGemSkillRec"
local PAGE_ITEMS = 13
local EQUIP_ITEMS = 5
local SKILL_PIC_DIR = "icon\\skill\\"
local GRAY_COLOR = "255,125,125,125"
local BLACK_COLOR = "255,0,0,0"
local BLUE_COLOR = "255,0,0,255"
local RED_COLOR = "255,255,0,0"
local POINT_PIC_PATH = {
  [1] = {
    [1] = "gui\\mainform\\smallgame\\baoshi\\common\\ahong-on.png",
    [2] = "gui\\mainform\\smallgame\\baoshi\\skill\\ahong32.png"
  },
  [2] = {
    [1] = "gui\\mainform\\smallgame\\baoshi\\common\\ahuang-on.png",
    [2] = "gui\\mainform\\smallgame\\baoshi\\skill\\ahuang32.png"
  },
  [3] = {
    [1] = "gui\\mainform\\smallgame\\baoshi\\common\\alan-on.png",
    [2] = "gui\\mainform\\smallgame\\baoshi\\skill\\alan32.png"
  },
  [4] = {
    [1] = "gui\\mainform\\smallgame\\baoshi\\common\\alv-on.png",
    [2] = "gui\\mainform\\smallgame\\baoshi\\skill\\alv32.png"
  },
  [5] = {
    [1] = "gui\\mainform\\smallgame\\baoshi\\common\\azi-on.png",
    [2] = "gui\\mainform\\smallgame\\baoshi\\skill\\azi32.png"
  }
}
local EQUIP_PRESS_PIC = "gui\\common\\combobox\\bg_select2.png"
local EQUIP_NORMAL_PIC = ""
local NORMAL_EQUIP_BUTTON = "gui\\language\\ChineseS\\minigame\\baoshi\\zhuangbei-out.png"
local HEIGHT_EQUIP_BUTTON = "gui\\language\\ChineseS\\minigame\\baoshi\\zhuangbei-on.png"
local SKILL_HELP_ID = {
  sh_tj = "ui_gemjob_help_tj",
  sh_jq = "ui_gemjob_help_jq",
  sh_ds = "ui_gemjob_help_ds",
  sh_ys = "ui_gemjob_help_ys",
  sh_cf = "ui_gemjob_help_cf",
  sh_cs = "ui_gemjob_help_cs"
}
function on_main_form_init(form)
  form.curr_page = 0
  form.Fixed = false
  form.job_id = ""
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  get_data_and_update_form(form)
  return 1
end
function on_main_form_close(form)
  local form_skill_help = nx_execute("util_gui", "util_get_form", FORM_SKILL_HELP, false)
  if nx_is_valid(form_skill_help) then
    form_skill_help:Close()
  end
  nx_destroy(form)
  return 1
end
local function update_skill_list_panel(form)
  local index = form.curr_page * PAGE_ITEMS + 1
  local gui = nx_value("gui")
  for i = 1, PAGE_ITEMS do
    local skill_level_ctl = form.groupbox_skill:Find("skill_level_" .. i)
    local skill_info_ctl = form.groupbox_skill:Find("skill_info_" .. i)
    local lbl_ctl = form.groupbox_skill:Find("desc_label_" .. i)
    local skill_picture_ctl = form.groupbox_skill:Find("pic_" .. i)
    if index > table.getn(all_skill_id_list) then
      skill_level_ctl.Visible = false
      skill_info_ctl.Visible = false
      lbl_ctl.Visible = false
    else
      local skill_str = all_skill_id_list[index]
      local str_list = util_split_string(skill_str, ",")
      local info = gui.TextManager:GetText(str_list[2])
      skill_info_ctl.Text = nx_widestr(info)
      skill_info_ctl.skill_id = str_list[2]
      skill_picture_ctl.skill_id = str_list[2]
      skill_level_ctl.Text = nx_widestr(str_list[1])
      local is_in_equip = false
      for j = 1, table.getn(temp_skill_id_list) do
        if str_list[2] == temp_skill_id_list[j] then
          is_in_equip = true
        end
      end
      local is_in_learn = false
      for j = 1, table.getn(skill_id_list) do
        if str_list[2] == skill_id_list[j] then
          is_in_learn = true
        end
      end
      lbl_ctl.Text = nx_widestr("")
      if is_in_equip then
        skill_info_ctl.ForeColor = BLUE_COLOR
        lbl_ctl.Text = nx_widestr(gui.TextManager:GetText("ui_have_equip"))
      elseif is_in_learn then
        skill_info_ctl.ForeColor = BLACK_COLOR
      else
        skill_info_ctl.ForeColor = GRAY_COLOR
      end
      skill_level_ctl.Visible = true
      skill_info_ctl.Visible = true
      lbl_ctl.Visible = true
      if str_list[1] == "-1" then
        skill_level_ctl.Visible = false
      end
    end
    index = index + 1
  end
  form.current_press_skill = nil
  return 1
end
local function update_equip_list_panel(form)
  local gui = nx_value("gui")
  form.current_press_equip = nil
  form.current_press_skill = nil
  for i = 1, EQUIP_ITEMS do
    local group_ctl = form:Find("equip_skill_" .. i)
    local skill_pic_ctl = group_ctl:Find("skill_pic_" .. i)
    local skill_name_ctl = group_ctl:Find("skill_name_" .. i)
    local need_point_info_ctl = group_ctl:Find("need_point_info_" .. i)
    local msg_pic_ctl = group_ctl:Find("msg_pic_" .. i)
    if i <= table.getn(temp_skill_id_list) then
      skill_pic_ctl.Visible = true
      skill_name_ctl.Visible = true
      need_point_info_ctl.Visible = true
      local info = gui.TextManager:GetText(temp_skill_id_list[i])
      skill_name_ctl.Text = nx_widestr(info)
      local jewel_game_manager = nx_value("jewel_game_manager")
      local skill_pic_path = jewel_game_manager:GetPhoto(temp_skill_id_list[i])
      skill_pic_ctl.Image = skill_pic_path
      skill_pic_ctl.AsyncLoad = false
      msg_pic_ctl.skill_id = temp_skill_id_list[i]
      local res_str = jewel_game_manager:QueryDataOperate(op_skill .. "," .. temp_skill_id_list[i])
      local res_lst = util_split_string(res_str, ",")
      local need_red = nx_number(res_lst[1])
      local need_yellow = nx_number(res_lst[2])
      local need_blue = nx_number(res_lst[3])
      local need_green = nx_number(res_lst[4])
      local need_purple = nx_number(res_lst[5])
      local red_ctl = need_point_info_ctl:Find("red_lbl_" .. i)
      local yellow_ctl = need_point_info_ctl:Find("yellow_lbl_" .. i)
      local blue_ctl = need_point_info_ctl:Find("blue_lbl_" .. i)
      local green_ctl = need_point_info_ctl:Find("green_lbl_" .. i)
      local purple_ctl = need_point_info_ctl:Find("purple_lbl_" .. i)
      local red_point_number_lbl = need_point_info_ctl:Find("red_point_number_" .. i)
      local yellow_point_number_lbl = need_point_info_ctl:Find("yellow_point_number_" .. i)
      local blue_point_number_lbl = need_point_info_ctl:Find("blue_point_number_" .. i)
      local green_point_number_lbl = need_point_info_ctl:Find("green_point_number_" .. i)
      local purple_point_number_lbl = need_point_info_ctl:Find("purple_point_number_" .. i)
      if 1 <= need_red then
        red_ctl.BackImage = POINT_PIC_PATH[1][1]
        red_point_number_lbl.Visible = true
      else
        red_ctl.BackImage = POINT_PIC_PATH[1][2]
        red_point_number_lbl.Visible = false
      end
      if 1 <= need_yellow then
        yellow_ctl.BackImage = POINT_PIC_PATH[2][1]
        yellow_point_number_lbl.Visible = true
      else
        yellow_ctl.BackImage = POINT_PIC_PATH[2][2]
        yellow_point_number_lbl.Visible = false
      end
      if 1 <= need_blue then
        blue_ctl.BackImage = POINT_PIC_PATH[3][1]
        blue_point_number_lbl.Visible = true
      else
        blue_ctl.BackImage = POINT_PIC_PATH[3][2]
        blue_point_number_lbl.Visible = false
      end
      if 1 <= need_green then
        green_ctl.BackImage = POINT_PIC_PATH[4][1]
        green_point_number_lbl.Visible = true
      else
        green_ctl.BackImage = POINT_PIC_PATH[4][2]
        green_point_number_lbl.Visible = false
      end
      if 1 <= need_purple then
        purple_ctl.BackImage = POINT_PIC_PATH[5][1]
        purple_point_number_lbl.Visible = true
      else
        purple_ctl.BackImage = POINT_PIC_PATH[5][2]
        purple_point_number_lbl.Visible = false
      end
      red_point_number_lbl.Text = nx_widestr(need_red)
      yellow_point_number_lbl.Text = nx_widestr(need_yellow)
      blue_point_number_lbl.Text = nx_widestr(need_blue)
      green_point_number_lbl.Text = nx_widestr(need_green)
      purple_point_number_lbl.Text = nx_widestr(need_purple)
      group_ctl.BackImage = EQUIP_NORMAL_PIC
    else
      skill_pic_ctl.Visible = false
      skill_name_ctl.Visible = false
      need_point_info_ctl.Visible = false
      group_ctl.BackImage = EQUIP_NORMAL_PIC
    end
  end
  return 1
end
function get_data_and_update_form(form)
  skill_id_list = {}
  temp_skill_id_list = {}
  all_skill_id_list = {}
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local row = client_player:GetRecordRows("job_rec")
  local index = 1
  for i = 0, row - 1 do
    local job_id = client_player:QueryRecord("job_rec", i, 0)
    local jewel_game_manager = nx_value("jewel_game_manager")
    local list = jewel_game_manager:GetJobSkillList(job_id)
    for j = 1, table.getn(list) do
      all_skill_id_list[index] = list[j]
      index = index + 1
    end
  end
  local view = game_client:GetView(nx_string(VIEWPORT_GAME_SUBOBJ_BOX))
  if not nx_is_valid(view) then
    update_skill_list_panel(form)
    update_equip_list_panel(form)
    update_page_tip(form)
    return 0
  end
  local viewobj_list = view:GetViewObjList()
  local view_item = viewobj_list[1]
  if nx_is_valid(view_item) then
    form.job_id = view_item:QueryProp("GemConfig")
    local row = view_item:GetRecordRows(TEMP_SKILL_REC)
    for i = 0, row - 1 do
      local skill_id = view_item:QueryRecord(TEMP_SKILL_REC, i, 0)
      temp_skill_id_list[i + 1] = skill_id
    end
    row = view_item:GetRecordRows(JOB_GEM_SKILL_REC)
    for i = 0, row - 1 do
      local skill_id = view_item:QueryRecord(JOB_GEM_SKILL_REC, i, 0)
      skill_id_list[i + 1] = skill_id
    end
    row = view_item:GetRecordRows(SKILL_REC)
    for i = 0, row - 1 do
      local skill_id = view_item:QueryRecord(SKILL_REC, i, 0)
      all_skill_id_list[table.getn(all_skill_id_list) + 1] = "-1," .. skill_id
      skill_id_list[table.getn(skill_id_list) + 1] = skill_id
    end
    table.sort(temp_skill_id_list)
    table.sort(skill_id_list)
    update_skill_list_panel(form)
    update_equip_list_panel(form)
    update_page_tip(form)
  end
  return 1
end
function on_close_btn_click(self)
  local form = self.Parent
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_GAME_SUBOBJ_BOX))
  if not nx_is_valid(view) then
    return 0
  end
  local temp_skill_rec_server = {}
  local index = 0
  local viewobj_list = view:GetViewObjList()
  local view_item = viewobj_list[1]
  if nx_is_valid(view_item) then
    local row = view_item:GetRecordRows(TEMP_SKILL_REC)
    for i = 0, row - 1 do
      local skill_id = view_item:QueryRecord(TEMP_SKILL_REC, i, 0)
      index = index + 1
      temp_skill_rec_server[index] = skill_id
    end
  end
  local differ = false
  if table.getn(temp_skill_rec_server) ~= table.getn(temp_skill_id_list) then
    differ = true
  else
    table.sort(temp_skill_rec_server)
    table.sort(temp_skill_id_list)
    for i = 1, table.getn(temp_skill_rec_server) do
      if temp_skill_id_list[i] ~= temp_skill_rec_server[i] then
        differ = true
        break
      end
    end
  end
  local zero_skill = table.getn(temp_skill_id_list) == 0
  if differ or zero_skill then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local text = nx_widestr(util_text("ui_puzzle_quest_skill_modify"))
    if zero_skill then
      text = nx_widestr(util_text("ui_puzzle_quest_none_skill"))
    end
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "cancel" then
      return 0
    elseif differ then
      on_useful_curr_setting_btn_click(form.close_btn)
    end
  end
  form:Close()
  return 1
end
function on_btn_help_click(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if SKILL_HELP_ID[form.job_id] == nil or SKILL_HELP_ID[form.job_id] == "" then
    return 0
  end
  local form_skill_help = nx_execute("util_gui", "util_get_form", FORM_SKILL_HELP, true, false)
  local info = gui.TextManager:GetText(SKILL_HELP_ID[form.job_id])
  form_skill_help.mltbox_info:Clear()
  form_skill_help.mltbox_info:AddHtmlText(nx_widestr(info), -1)
  form_skill_help:Show()
end
function update_page_tip(form)
  local count = table.getn(all_skill_id_list)
  local max_page = math.floor(count / PAGE_ITEMS)
  if count % PAGE_ITEMS ~= 0 then
    max_page = max_page + 1
  end
  form.page_tip.Text = nx_widestr(form.curr_page + 1) .. nx_widestr("/") .. nx_widestr(max_page)
  form.up_page_btn.Visible = true
  form.down_page_btn.Visible = true
  if form.curr_page == 0 then
    form.up_page_btn.Visible = false
  end
  if form.curr_page == max_page - 1 then
    form.down_page_btn.Visible = false
  end
end
function on_up_page_btn_click(self)
  local form = self.Parent
  if form.curr_page >= 1 then
    form.curr_page = form.curr_page - 1
    update_skill_list_panel(form)
    update_page_tip(form)
  end
  return 1
end
function on_down_page_btn_click(self)
  local form = self.Parent
  local count = table.getn(all_skill_id_list)
  local max_page = math.floor(count / PAGE_ITEMS)
  if count % PAGE_ITEMS ~= 0 then
    max_page = max_page + 1
  end
  if form.curr_page < max_page - 1 then
    form.curr_page = form.curr_page + 1
    update_skill_list_panel(form)
    update_page_tip(form)
  end
  return 1
end
function on_no_use_btn_click(self)
  local form = self.Parent
  if nil == form.current_press_equip then
    return 0
  end
  local name = nx_string(form.current_press_equip.Name)
  local index = nx_number(string.sub(name, string.len(name), string.len(name)))
  local count = table.getn(temp_skill_id_list)
  for i = index, count - 1 do
    temp_skill_id_list[i] = temp_skill_id_list[i + 1]
  end
  temp_skill_id_list[count] = nil
  update_equip_list_panel(form)
  update_page_tip(form)
  update_skill_list_panel(form)
  return 1
end
function on_skill_equip_get_capture(self)
  local form = self.Parent
  if not nx_find_custom(self, "skill_id") then
    return 0
  end
  local skill_id = self.skill_id
  if skill_id == nil then
    return 0
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_tips_common", skill_id, 1017, x, y)
  return 1
end
function on_skill_equip_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
  return 1
end
function on_skill_pic_left_down(self)
  local form = self.Parent
  local name = nx_string(self.Name)
  local index = string.sub(name, string.len(name), string.len(name))
  local pic_name = "msg_pic_" .. index
  local pic_ctl = form:Find(pic_name)
  return on_msg_pic_left_down(pic_ctl)
end
function on_msg_pic_left_down(self)
  local form = self.ParentForm
  local index = string.sub(self.Name, string.len(self.Name), string.len(self.Name))
  if nx_number(index) > table.getn(temp_skill_id_list) then
    return 1
  end
  if form.current_press_equip ~= nil and nx_id_equal(self.Parent, form.current_press_equip) then
    form.current_press_equip.BackImage = EQUIP_NORMAL_PIC
    form.current_press_equip = nil
    return 1
  end
  if form.current_press_equip ~= nil then
    form.current_press_equip.BackImage = EQUIP_NORMAL_PIC
  end
  self.Parent.BackImage = EQUIP_PRESS_PIC
  form.current_press_equip = self.Parent
  return 1
end
function on_pic_left_down(self)
  local groupbox_skill = self.Parent
  local form = groupbox_skill.Parent
  local str_list = util_split_string(self.Name, "_")
  local skill_info = groupbox_skill:Find("skill_info_" .. str_list[2])
  hight_light_equip_button(form, false)
  if skill_info.ForeColor == BLUE_COLOR or skill_info.ForeColor == GRAY_COLOR then
    return 1
  end
  if form.current_press_skill ~= nil then
    if nx_id_equal(skill_info, form.current_press_skill) then
      if skill_info.ForeColor == RED_COLOR then
        skill_info.ForeColor = BLACK_COLOR
        form.current_press_skill = nil
        return 1
      end
    else
      form.current_press_skill.ForeColor = BLACK_COLOR
      skill_info.ForeColor = RED_COLOR
      hight_light_equip_button(form, true)
      form.current_press_skill = skill_info
    end
  else
    skill_info.ForeColor = RED_COLOR
    hight_light_equip_button(form, true)
    form.current_press_skill = skill_info
  end
  return 1
end
local show_error_oper_tip = function(info)
  local gui = nx_value("gui")
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "breakconnect")
  dialog.cancel_btn.Visible = false
  dialog.ok_btn.Width = dialog.ok_btn.Width + 30
  dialog.ok_btn.Left = (dialog.Width - dialog.ok_btn.Width) / 2
  dialog.mltbox_info.HtmlText = gui.TextManager:GetText(info)
  dialog.ok_btn.Text = gui.TextManager:GetText("ui_ok")
  dialog:ShowModal()
  return 1
end
function on_equip_btn_click(self)
  local form = self.Parent
  if form.current_press_skill == nil then
    return 0
  end
  local count = table.getn(temp_skill_id_list)
  local new_skill_id = nx_string(form.current_press_skill.skill_id)
  for i = 1, count do
    if temp_skill_id_list[i] == new_skill_id then
      show_error_oper_tip("ui_skill_is_exist_equiplist")
      return 0
    end
  end
  if count >= EQUIP_ITEMS then
    show_error_oper_tip("ui_equip_skill_max_5")
    return 0
  end
  temp_skill_id_list[count + 1] = new_skill_id
  update_equip_list_panel(form)
  update_page_tip(form)
  update_skill_list_panel(form)
  hight_light_equip_button(form)
  return 1
end
function on_useful_curr_setting_btn_click(self)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GEM_RESET_SKILL), unpack(temp_skill_id_list))
  return 1
end
function on_pic_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
  return 1
end
function on_pic_get_capture(self)
  local form = self.Parent
  if not nx_find_custom(self, "skill_id") then
    return 0
  end
  local skill_id = self.skill_id
  if skill_id == nil then
    return 0
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_tips_common", skill_id, 1017, x - 20, y)
  return 1
end
function on_back_btn_click(self)
  if 0 == on_close_btn_click(self) then
    return 0
  end
  local form_job = nx_value("form_stage_main\\form_life\\form_job_main_new")
  if nx_is_valid(form_job) then
    if not form_job.Visible then
      form_job.Visible = true
      form_job:Show()
    end
  else
    util_auto_show_hide_form("form_stage_main\\form_life\\form_job_main_new")
  end
  return 1
end
function on_msg_pic_double_click(self)
  local form = self.ParentForm
  if form.current_press_equip == nil then
    on_msg_pic_left_down(self)
  elseif not nx_id_equal(form.current_press_equip, self.Parent) then
    on_msg_pic_left_down(self)
  end
  on_no_use_btn_click(form.no_use_btn)
  return 1
end
function on_pic_double_click(self)
  local groupbox_skill = self.Parent
  local form = groupbox_skill.Parent
  local str_list = util_split_string(self.Name, "_")
  local skill_info = groupbox_skill:Find("skill_info_" .. str_list[2])
  if form.current_press_skill == nil then
    on_pic_left_down(self)
  elseif not nx_id_equal(form.current_press_skill, skill_info) then
    on_pic_left_down(self)
  end
  on_equip_btn_click(form.equip_btn)
  return 1
end
function hight_light_equip_button(form, is_height)
  if is_height == nil or is_height == false then
    form.equip_btn.BackImage = NORMAL_EQUIP_BUTTON
  else
    form.equip_btn.BackImage = HEIGHT_EQUIP_BUTTON
  end
  return 1
end
