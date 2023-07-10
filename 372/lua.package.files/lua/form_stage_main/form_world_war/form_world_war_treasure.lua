require("util_gui")
local SINGLE_PAGE_MAX = 8
function main_form_init(form)
  form.Fixed = true
  form.Current_Page = 1
  form.Info_List = nx_call("util_gui", "get_arraylist", "treasure:info_list")
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.textgrid_1:SetColTitle(0, nx_widestr(gui.TextManager:GetText("ui_lxc_baowuming")))
    form.textgrid_1:SetColTitle(1, nx_widestr(gui.TextManager:GetText("ui_lxc_baowujifen")))
    form.textgrid_1:SetColTitle(2, nx_widestr(gui.TextManager:GetText("ui_lxc_baowuzhongliang")))
    form.textgrid_1:SetColTitle(3, nx_widestr(gui.TextManager:GetText("ui_lxc_baowuzuoyong")))
    form.textgrid_1:SetColTitle(4, nx_widestr(gui.TextManager:GetText("ui_lxc_baowushuliang")))
  end
  Load(form)
  Grid_Refresh(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function Load(form)
  local ini = nx_execute("util_functions", "get_ini", "share\\WorldWar\\WorldWarTreasure.ini")
  local count = ini:GetSectionCount()
  form.Info_List:ClearChild()
  for i = 1, count do
    local index = ini:FindSectionIndex(nx_string(i))
    local child = form.Info_List:CreateChild("")
    child.NAME = ini:ReadString(index, "Name", "")
    child.SCORE = ini:ReadString(index, "Score", "")
    child.WEIGHT = ini:ReadString(index, "Weight", "")
    child.ACTION = ini:ReadString(index, "Action", "")
    child.QUANTITY = nil
    child.TOTAL = nil
    child.TYPE = ini:ReadInteger(index, "Type", 0)
  end
end
function update_treasure_info(...)
  local form = util_get_form("form_stage_main\\form_world_war\\form_world_war_treasure", false)
  if nx_is_valid(form) then
    local count = table.getn(arg)
    if 0 < count then
      for i = 1, count / 3 do
        local treasure_type = arg[3 * (i - 1) + 1] + 1
        local treasure_quantity = arg[3 * (i - 1) + 2]
        local treasure_total = arg[3 * (i - 1) + 3]
        update_info_list(form, treasure_type, treasure_quantity, treasure_total)
      end
    end
    Grid_Refresh(form)
  end
end
function update_info_list(form, treasure_type, treasure_quantity, treasure_total)
  for i = 1, form.Info_List:GetChildCount() do
    if form.Info_List:GetChildByIndex(i - 1).TYPE == treasure_type then
      form.Info_List:GetChildByIndex(i - 1).QUANTITY = treasure_quantity
      form.Info_List:GetChildByIndex(i - 1).TOTAL = treasure_total
      return 1
    end
  end
  return 0
end
function Grid_Refresh(form)
  local count = form.Info_List:GetChildCount()
  if 0 < count then
    if 0 < count % SINGLE_PAGE_MAX then
      form.ipt_1.MaxDigit = nx_int(count / SINGLE_PAGE_MAX) + 1
    else
      form.ipt_1.MaxDigit = nx_int(count / SINGLE_PAGE_MAX)
    end
    local current_page = nx_int(form.ipt_1.Text)
    if 0 >= nx_number(current_page) then
      form.Current_Page = 1
      form.ipt_1.Text = nx_widestr("1")
    else
      form.Current_Page = current_page
    end
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      form.textgrid_1:ClearRow()
      for i = 1, SINGLE_PAGE_MAX do
        if count >= SINGLE_PAGE_MAX * (form.Current_Page - 1) + i then
          local array = SINGLE_PAGE_MAX * (form.Current_Page - 1) + i - 1
          local row = form.textgrid_1:InsertRow(-1)
          form.textgrid_1:SetGridText(row, 0, nx_widestr(gui.TextManager:GetText(form.Info_List:GetChildByIndex(array).NAME)))
          form.textgrid_1:SetGridText(row, 1, nx_widestr(gui.TextManager:GetText(form.Info_List:GetChildByIndex(array).SCORE)))
          form.textgrid_1:SetGridText(row, 2, nx_widestr(gui.TextManager:GetText(form.Info_List:GetChildByIndex(array).WEIGHT)))
          form.textgrid_1:SetGridText(row, 3, nx_widestr(gui.TextManager:GetText(form.Info_List:GetChildByIndex(array).ACTION)))
          if form.Info_List:GetChildByIndex(array).QUANTITY ~= nil and form.Info_List:GetChildByIndex(array).TOTAL ~= nil then
            form.textgrid_1:SetGridText(row, 4, nx_widestr(form.Info_List:GetChildByIndex(array).QUANTITY) .. nx_widestr("/") .. nx_widestr(form.Info_List:GetChildByIndex(array).TOTAL))
          else
            form.textgrid_1:SetGridText(row, 4, nx_widestr(gui.TextManager:GetText("ui_lxc_weizhi")))
          end
        end
      end
    end
  end
end
function on_btn_1_click(btn)
  if btn.ParentForm.Current_Page > 1 then
    btn.ParentForm.ipt_1.Text = nx_widestr(btn.ParentForm.Current_Page - 1)
  else
    btn.ParentForm.ipt_1.Text = nx_widestr(btn.ParentForm.ipt_1.MaxDigit)
  end
  Grid_Refresh(btn.ParentForm)
end
function on_btn_2_click(btn)
  if btn.ParentForm.Current_Page < btn.ParentForm.ipt_1.MaxDigit then
    btn.ParentForm.ipt_1.Text = nx_widestr(btn.ParentForm.Current_Page + 1)
  else
    btn.ParentForm.ipt_1.Text = nx_widestr("1")
  end
  Grid_Refresh(btn.ParentForm)
end
