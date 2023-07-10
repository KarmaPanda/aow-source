require("util_gui")
local SINGLE_PAGE_MAX = 6
function main_form_init(form)
  form.Fixed = true
  form.Current_Page = 1
  form.Info_List = nx_call("util_gui", "get_arraylist", "hero:info_list")
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.textgrid_1:SetColTitle(0, nx_widestr(gui.TextManager:GetText("ui_lxc_touxiang")))
    form.textgrid_1:SetColTitle(1, nx_widestr(gui.TextManager:GetText("ui_lxc_heroname")))
    form.textgrid_1:SetColTitle(2, nx_widestr(gui.TextManager:GetText("ui_lxc_herotype")))
    form.textgrid_1:SetColTitle(3, nx_widestr(gui.TextManager:GetText("ui_lxc_herostate")))
    form.textgrid_1:SetColTitle(4, nx_widestr(gui.TextManager:GetText("ui_lxc_herodesc")))
    form.textgrid_1:SetColTitle(5, nx_widestr(gui.TextManager:GetText("ui_lxc_herojihuo")))
  end
  Load(form)
  Grid_Refresh(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function Load(form)
  local ini = nx_execute("util_functions", "get_ini", "share\\WorldWar\\WorldWarHero.ini")
  local count = ini:GetSectionCount()
  form.Info_List:ClearChild()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local world_war_force = client_player:QueryProp("WorldWarForce")
  for i = 1, count do
    local index = ini:FindSectionIndex(nx_string(i))
    if 0 <= index then
      local belone = ini:ReadInteger(index, "Belone", 0)
      if world_war_force == belone then
        local child = form.Info_List:CreateChild("")
        child.ID = ini:ReadString(index, "ID", "")
        child.PHOTO = ini:ReadString(index, "Photo", "")
        child.TYPE = ini:ReadString(index, "Type", "")
        child.STATE = ini:ReadString(index, "State", "")
        child.LEVEL = ini:ReadString(index, "Level", "")
        child.PLACE = ini:ReadString(index, "Place", "")
        child.BELONE = belone
      end
    end
  end
end
function update_hero_info(...)
  local form = util_get_form("form_stage_main\\form_world_war\\form_world_war_hero", false)
  if nx_is_valid(form) then
    local tbl_hero_info = util_split_string(nx_string(arg[1]), ";")
    local count = table.getn(tbl_hero_info) - 1
    for i = 1, count do
      local hero_info = util_split_string(nx_string(tbl_hero_info[i]), ",")
      local hero_id = nx_string(hero_info[1])
      local hero_type = nx_string(hero_info[2])
      local hero_place = nx_string(hero_info[3])
      local hero_state = nx_string(hero_info[4])
      update_info_list(form, hero_id, hero_type, hero_state, hero_place)
    end
    Grid_Refresh(form)
  end
end
function update_info_list(form, hero_id, hero_type, hero_state, hero_place)
  for i = 1, form.Info_List:GetChildCount() do
    if form.Info_List:GetChildByIndex(i - 1).ID == hero_id then
      form.Info_List:GetChildByIndex(i - 1).TYPE = hero_type
      form.Info_List:GetChildByIndex(i - 1).STATE = hero_state
      form.Info_List:GetChildByIndex(i - 1).PLACE = hero_place
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
          form.textgrid_1:SetGridText(row, 1, gui.TextManager:GetText(form.Info_List:GetChildByIndex(array).ID))
          if nx_string("0") == form.Info_List:GetChildByIndex(array).TYPE then
            form.textgrid_1:SetGridText(row, 2, nx_widestr(gui.TextManager:GetText("ui_lxc_hero_gongneng")))
          elseif nx_string("1") == form.Info_List:GetChildByIndex(array).TYPE then
            form.textgrid_1:SetGridText(row, 2, nx_widestr(gui.TextManager:GetText("ui_lxc_hero_zhandou")))
          elseif nx_string("2") == form.Info_List:GetChildByIndex(array).TYPE then
            form.textgrid_1:SetGridText(row, 2, nx_widestr(gui.TextManager:GetText("ui_lxc_renzhi")))
          elseif nx_string("3") == form.Info_List:GetChildByIndex(array).TYPE then
            form.textgrid_1:SetGridText(row, 2, nx_widestr(gui.TextManager:GetText("ui_lxc_guifu_gongneng")))
          elseif nx_string("4") == form.Info_List:GetChildByIndex(array).TYPE then
            form.textgrid_1:SetGridText(row, 2, nx_widestr(gui.TextManager:GetText("ui_lxc_guifu_zhandou")))
          else
            form.textgrid_1:SetGridText(row, 2, nx_widestr(gui.TextManager:GetText("ui_lxc_weizhi")))
          end
          if nx_string("0") == form.Info_List:GetChildByIndex(array).STATE then
            form.textgrid_1:SetGridText(row, 3, nx_widestr(gui.TextManager:GetText("ui_lxc_jiankang")))
          elseif nx_string("1") == form.Info_List:GetChildByIndex(array).STATE then
            form.textgrid_1:SetGridText(row, 3, nx_widestr(gui.TextManager:GetText("ui_lxc_neishang")))
          elseif nx_string("2") == form.Info_List:GetChildByIndex(array).STATE then
            form.textgrid_1:SetGridText(row, 3, nx_widestr(gui.TextManager:GetText("ui_lxc_zhongdu")))
          elseif nx_string("3") == form.Info_List:GetChildByIndex(array).STATE then
            form.textgrid_1:SetGridText(row, 3, nx_widestr(gui.TextManager:GetText("ui_lxc_jibin")))
          elseif nx_string("4") == form.Info_List:GetChildByIndex(array).STATE then
            form.textgrid_1:SetGridText(row, 3, nx_widestr(gui.TextManager:GetText("ui_lxc_qitafeijiankang")))
          elseif nx_string("5") == form.Info_List:GetChildByIndex(array).STATE then
            form.textgrid_1:SetGridText(row, 3, nx_widestr(gui.TextManager:GetText("ui_lxc_xuanyun")))
          else
            form.textgrid_1:SetGridText(row, 3, nx_widestr(gui.TextManager:GetText("ui_lxc_weizhi")))
          end
          form.textgrid_1:SetGridText(row, 4, nx_widestr(gui.TextManager:GetText(form.Info_List:GetChildByIndex(array).LEVEL)))
          if nx_string("0") == form.Info_List:GetChildByIndex(array).PLACE then
            form.textgrid_1:SetGridText(row, 5, nx_widestr(gui.TextManager:GetText("ui_lxc_weijihuo")))
          else
            if nx_string("1") == form.Info_List:GetChildByIndex(array).PLACE then
              form.textgrid_1:SetGridText(row, 5, nx_widestr(gui.TextManager:GetText("ui_lxc_jihuo")))
            else
            end
          end
          local Grid_Photo = form.textgrid_1:GetGridControl(i - 1, 0)
          if not nx_is_valid(Grid_Photo) then
            Grid_Photo = gui:Create("ImageGrid")
            Grid_Photo.Name = "Grid_Photo_" .. nx_string(i - 1)
            Grid_Photo.BackColor = "0,0,0,0"
            Grid_Photo.LineColor = "255,197,184,159"
            Grid_Photo.AutoSize = true
            Grid_Photo.DrawGridBack = "gui\\common\\imagegrid\\icon_item2.png"
            Grid_Photo.GridBackOffsetX = -2
            Grid_Photo.GridBackOffsetY = -2
            Grid_Photo.SelectColor = "0,0,0,0"
            Grid_Photo.MouseInColor = "0,0,0,0"
            Grid_Photo.CoverColor = "0,0,0,0"
            Grid_Photo.LockColor = "0,0,0,0"
            Grid_Photo.CoolColor = "0,0,0,0"
            Grid_Photo.ShowMouseDownState = false
            Grid_Photo.FitGrid = true
            Grid_Photo.GridWidth = 40
            Grid_Photo.GridHeight = 40
            Grid_Photo.GridsPos = "10,8"
          end
          if nx_is_valid(Grid_Photo) then
            Grid_Photo:Clear()
            Grid_Photo:AddItem(0, nx_string(form.Info_List:GetChildByIndex(array).PHOTO), "", 1, -1)
            form.textgrid_1:SetGridControl(i - 1, 0, Grid_Photo)
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
