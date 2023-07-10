require("util_gui")
require("util_functions")
local FORM_COUNTERATTACKRANK = "form_stage_main\\form_school_counterattack\\form_counter_attack_rank"
local EVERYPAGE_COUNT = 100
local DATA_COL_NUM = 6
local CLIENT_MSG_DS_REQUEST_QUIT = 1
local rank_head_name = {
  "ui_guildwar_order_mingci",
  "ui_guildwar_order_xingming",
  "ui_menpai",
  "ui_sca_damage",
  "ui_sca_hostage",
  "ui_sca_point"
}
local rank_school_pic = {
  [""] = "gui\\language\\ChineseS\\shengwang\\wmp.png",
  school_shaolin = "gui\\language\\ChineseS\\shengwang\\sl.png",
  school_wudang = "gui\\language\\ChineseS\\shengwang\\wd.png",
  school_gaibang = "gui\\language\\ChineseS\\shengwang\\gb.png",
  school_tangmen = "gui\\language\\ChineseS\\shengwang\\tm.png",
  school_emei = "gui\\language\\ChineseS\\shengwang\\em.png",
  school_jinyiwei = "gui\\language\\ChineseS\\shengwang\\jy.png",
  school_jilegu = "gui\\language\\ChineseS\\shengwang\\jl.png",
  school_junzitang = "gui\\language\\ChineseS\\shengwang\\jz.png",
  school_mingjiao = "gui\\language\\ChineseS\\shengwang\\mj.png",
  school_tianshan = "gui\\language\\ChineseS\\shengwang\\ts.png",
  force_jinzhen = "gui\\special\\forceschool\\shililogo\\jinzhen02.png",
  force_taohua = "gui\\special\\forceschool\\shililogo\\taohua02.png",
  force_wanshou = "gui\\special\\forceschool\\shililogo\\wanshou02.png",
  force_wugen = "gui\\special\\forceschool\\shililogo\\wugen02.png",
  force_xujia = "gui\\special\\forceschool\\shililogo\\xujia02.png",
  force_yihua = "gui\\special\\forceschool\\shililogo\\yihua02.png",
  newschool_gumu = "gui\\special\\newschool\\logo\\gumu.png",
  newschool_xuedao = "gui\\special\\newschool\\logo\\xuedao.png",
  newschool_damo = "gui\\special\\newschool\\logo\\damo.png",
  newschool_shenshui = "gui\\special\\newschool\\logo\\shenshui.png",
  newschool_changfeng = "gui\\special\\newschool\\logo\\changfeng.png",
  newschool_nianluo = "gui\\special\\newschool\\logo\\nianluoba.png",
  newschool_wuxian = "gui\\special\\newschool\\logo\\wuxian.png",
  newschool_huashan = "gui\\special\\newschool\\logo\\huashan.png"
}
function main_form_init(self)
  self.Fixed = false
  self.cur_page = 1
  self.max_page = 1
end
function on_main_form_open(self)
  if not nx_is_valid(self) then
    return
  end
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  init_grid(self)
  nx_execute("custom_sender", "custom_school_counter_attack_data", 0)
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
  return
end
function on_btn_close_click(self)
  local form = self.Parent
  form:Close()
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_COUNTERATTACKRANK, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function update_rank(...)
  local form = nx_value(FORM_COUNTERATTACKRANK)
  if not nx_is_valid(form) then
    return
  end
  local count = table.getn(arg)
  if count < 1 then
    return
  end
  local data_string = nx_string(arg[1])
  grid_sort_rank(form, data_string)
  rank_data_sort(form)
  local palyer_num = form.textgrid_sort.RowCount
  if palyer_num <= 0 then
    return
  end
  form.max_page = nx_int(palyer_num / EVERYPAGE_COUNT)
  if math.mod(palyer_num, EVERYPAGE_COUNT) ~= 0 then
    form.max_page = form.max_page + 1
  end
  form.lbl_page.Text = nx_widestr(form.cur_page) .. nx_widestr("/") .. nx_widestr(form.max_page)
  fresh_rank(form)
end
function fresh_rank(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.textgrid_rank) then
    return
  end
  if not nx_is_valid(form.textgrid_sort) then
    return
  end
  local count = form.textgrid_sort.RowCount
  if count <= 0 then
    return
  end
  form.textgrid_rank:BeginUpdate()
  form.textgrid_rank:ClearRow()
  local index = (form.cur_page - 1) * EVERYPAGE_COUNT
  local rank = 1
  for row = 0, EVERYPAGE_COUNT - 1 do
    if count < index + 1 then
      break
    end
    form.textgrid_rank:InsertRow(-1)
    form.textgrid_rank:SetGridText(row, 1, form.textgrid_sort:GetGridText(index, 1))
    create_school_grid_control(form, row, 2, nx_string(form.textgrid_sort:GetGridText(index, 2)))
    form.textgrid_rank:SetGridText(row, 3, form.textgrid_sort:GetGridText(index, 3))
    form.textgrid_rank:SetGridText(row, 4, form.textgrid_sort:GetGridText(index, 4))
    form.textgrid_rank:SetGridText(row, 5, form.textgrid_sort:GetGridText(index, 5))
    rank = rank + 1
    index = index + 1
  end
  for row = 1, rank do
    form.textgrid_rank:SetGridText(row - 1, 0, nx_widestr((form.cur_page - 1) * EVERYPAGE_COUNT + row))
  end
  form.textgrid_rank:EndUpdate()
end
function create_school_grid_control(form, row, col, rank_school)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local groupbox = gui:Create("GroupBox")
  groupbox.BackColor = "0,0,0,0"
  groupbox.NoFrame = true
  groupbox.Name = "groupbox_school_" .. nx_string(row) .. "_" .. nx_string(col)
  local grid_item = gui:Create("ImageGrid")
  groupbox:Add(grid_item)
  grid_item.Width = 30
  grid_item.Height = 30
  grid_item.Top = 0
  grid_item.Left = 10
  grid_item.Name = "imagegrid_rank_reward_item_" .. nx_string(row) .. "_" .. nx_string(col)
  grid_item.DrawMode = "FitWindow"
  grid_item.SelectColor = "0,0,0,0"
  grid_item.MouseInColor = "0,0,0,0"
  grid_item.NoFrame = true
  grid_item.BackImage = rank_school_pic[rank_school]
  form.textgrid_rank:SetGridControl(row, col, groupbox)
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.cur_page <= 1 then
    return
  end
  form.cur_page = form.cur_page - 1
  fresh_rank(form)
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.cur_page >= form.max_page then
    return
  end
  form.cur_page = form.cur_page + 1
  fresh_rank(form)
end
function init_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local grid = form.textgrid_rank
  grid:BeginUpdate()
  grid:ClearRow()
  grid.ColCount = DATA_COL_NUM + 1
  grid:SetColTitle(0, gui.TextManager:GetText(rank_head_name[1]))
  grid:SetColTitle(1, gui.TextManager:GetText(rank_head_name[2]))
  grid:SetColTitle(2, gui.TextManager:GetText(rank_head_name[3]))
  grid:SetColTitle(3, gui.TextManager:GetText(rank_head_name[4]))
  grid:SetColTitle(4, gui.TextManager:GetText(rank_head_name[5]))
  grid:SetColTitle(5, gui.TextManager:GetText(rank_head_name[6]))
  grid:EndUpdate()
  local grid_sort = form.textgrid_sort
  grid_sort:BeginUpdate()
  grid_sort:ClearRow()
  grid_sort.ColCount = DATA_COL_NUM + 1
  grid_sort.RowCount = 0
  grid_sort:EndUpdate()
end
function on_btn_quit_click()
  nx_execute("custom_sender", "custom_school_counter_attack_data", CLIENT_MSG_DS_REQUEST_QUIT)
end
function grid_sort_rank(form, data_string)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.textgrid_sort) then
    return
  end
  local rank_data = util_split_string(data_string, ",")
  local count = table.getn(rank_data)
  if 0 < count then
    count = count - 1
  end
  if count <= 0 then
    return
  end
  if count < DATA_COL_NUM or math.mod(count, DATA_COL_NUM) ~= 0 then
    return
  end
  local player_num = count / DATA_COL_NUM
  form.textgrid_sort:BeginUpdate()
  form.textgrid_sort:ClearRow()
  local begin_index = count
  for row = 0, player_num - 1 do
    if count < begin_index then
      break
    end
    form.textgrid_sort:InsertRow(-1)
    local index = begin_index - 5
    form.textgrid_sort:SetGridText(row, 0, nx_widestr(player_num - row))
    form.textgrid_sort:SetGridText(row, 1, nx_widestr(rank_data[index]))
    index = begin_index - 4
    form.textgrid_sort:SetGridText(row, 2, nx_widestr(rank_data[index]))
    index = begin_index - 3
    form.textgrid_sort:SetGridText(row, 3, nx_widestr(rank_data[index]))
    index = begin_index - 2
    form.textgrid_sort:SetGridText(row, 4, nx_widestr(rank_data[index]))
    index = begin_index - 1
    form.textgrid_sort:SetGridText(row, 5, nx_widestr(rank_data[index]))
    begin_index = begin_index - DATA_COL_NUM
  end
  form.textgrid_sort:SortRowsByInt(5, true)
  form.textgrid_sort:EndUpdate()
end
function rank_data_sort(form)
  local count = form.textgrid_sort.RowCount
  if count <= 0 then
    return
  end
  form.textgrid_sort:BeginUpdate()
  local begin_index = -1
  for row = 0, count - 2 do
    local x = nx_int(form.textgrid_sort:GetGridText(row, 5))
    local y = nx_int(form.textgrid_sort:GetGridText(row + 1, 5))
    if x == y then
      if begin_index < 0 then
        begin_index = row
      end
    elseif 0 <= begin_index then
      form.textgrid_sort:SortRowsRang(0, begin_index, row + 1, false)
      begin_index = -1
    else
      begin_index = -1
    end
  end
  form.textgrid_sort:EndUpdate()
end
