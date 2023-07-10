require("util_gui")
require("util_functions")
require("share\\view_define")
require("share\\client_custom_define")
require("form_stage_main\\form_guild_war\\form_guild_chase")
require("form_stage_main\\form_guildbuilding\\sub_command_define")
local FORM_NAME = "form_stage_main\\form_guildbuilding\\form_guildbuilding_repair"
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  form.ipt_1.Text = nx_widestr(0)
  form.DamageStateRate = 0.5
  form.RuinStateRate = 0.1
  read_repairinfo(form)
  read_build_damage_info(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.EndureValue = -1
  refresh_endure_info()
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:Register(1000, -1, nx_current(), "refresh_endure_info", form, -1, -1)
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("CapitalType0", "int", form, FORM_NAME, "refresh_capital_num")
    databinder:AddRolePropertyBind("CapitalType1", "int", form, FORM_NAME, "refresh_capital_num")
    databinder:AddViewBind(VIEWPORT_MATERIAL_TOOL, form, FORM_NAME, "refresh_material_num")
  end
end
function on_main_form_close(form)
  if nx_running(nx_current(), "refresh_endure_info") then
    nx_kill(nx_current(), "refresh_endure_info")
  end
  nx_destroy(form)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_repair_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local num = nx_int(form.ipt_1.Text)
  if nx_int(num) > nx_int(get_max_repair_value()) then
    local warn_dlg = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local text = gui.TextManager:GetFormatText("ui_guild_repair_unlimit")
    nx_execute("form_common\\form_confirm", "show_common_text", warn_dlg, nx_widestr(text))
    warn_dlg:ShowModal()
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_REPAIR_ENDURE), form.building, num)
end
function on_btn_max_repair_value_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.ipt_1.Text = nx_widestr(get_max_repair_value())
  local capital = nx_number(form.ipt_1.Text) * form.CapitalType0
  form.mltbox_jinzi.HtmlText = nx_widestr(nx_string(manage_capital(capital, 0)))
  local capital1 = nx_number(form.ipt_1.Text) * form.CapitalType1
  form.mltbox_yinzi.HtmlText = nx_widestr(nx_string(manage_capital(capital1, 1)))
  refresh_material_num()
end
function on_btn_Minus_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_number(form.ipt_1.Text) > 0 then
    form.ipt_1.Text = nx_widestr(nx_number(form.ipt_1.Text) - 1)
    local capital = nx_number(form.ipt_1.Text) * form.CapitalType0
    form.mltbox_jinzi.HtmlText = nx_widestr(nx_string(manage_capital(capital, 0)))
    local capital1 = nx_number(form.ipt_1.Text) * form.CapitalType1
    form.mltbox_yinzi.HtmlText = nx_widestr(nx_string(manage_capital(capital1, 1)))
  end
  refresh_material_num()
end
function on_btn_Add_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_number(form.ipt_1.Text) < nx_number(get_max_repair_value()) then
    form.ipt_1.Text = nx_widestr(nx_number(form.ipt_1.Text) + 1)
    local capital = nx_number(form.ipt_1.Text) * form.CapitalType0
    form.mltbox_jinzi.HtmlText = nx_widestr(nx_string(manage_capital(capital, 0)))
    local capital1 = nx_number(form.ipt_1.Text) * form.CapitalType1
    form.mltbox_yinzi.HtmlText = nx_widestr(nx_string(manage_capital(capital1, 1)))
  end
  refresh_material_num()
end
function on_ipt_1_changed(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local ipt_str = self.Text
  local start_index, end_index = string.find(nx_string(ipt_str), nx_string("-"))
  if start_index ~= nil then
    form.mltbox_jinzi.HtmlText = nx_widestr(nx_string(manage_capital(0, 0)))
    form.mltbox_yinzi.HtmlText = nx_widestr(nx_string(manage_capital(0, 0)))
    self.Text = nx_widestr("0")
    return
  end
  if nx_int(ipt_str) > nx_int(form.MaxRepairValue) then
    ipt_str = nx_string(form.MaxRepairValue)
    self.Text = nx_widestr(ipt_str)
  end
  refresh_material_num()
  form.lbl_BurnPointTime.Text = nx_widestr(get_format_time(nx_number(ipt_str)))
  local capital = nx_number(self.Text) * form.CapitalType0
  form.mltbox_jinzi.HtmlText = nx_widestr(nx_string(manage_capital(capital, 0)))
  local capital1 = nx_number(form.ipt_1.Text) * form.CapitalType1
  form.mltbox_yinzi.HtmlText = nx_widestr(nx_string(manage_capital(capital1, 1)))
end
function on_MaterialGrid_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "mark_material_num") then
    return
  end
  if index < form.mark_material_num then
    local gui = nx_value("gui")
    tips_text = gui.TextManager:GetFormatText(nx_string("desc_") .. nx_string(nx_custom(form, "material" .. nx_string(index + 1))))
    nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 150, 32)
  end
end
function on_MaterialGrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function read_repairinfo(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\guild_building_repair.ini")
  if not nx_is_valid(ini) then
    nx_msgbox("share\\Rule\\guild_building_repair.ini " .. get_msg_str("msg_120"))
    return
  end
  local game_client = nx_value("game_client")
  local build_object = game_client:GetSceneObj(nx_string(form.building))
  if not nx_is_valid(build_object) or not nx_is_valid(game_client) then
    return
  end
  local mainType = nx_string(build_object:QueryProp("MainType"))
  local subType = nx_string(build_object:QueryProp("SubType"))
  local level = nx_string(build_object:QueryProp("CurLevel"))
  local sec_count = ini:GetSectionCount()
  local sect
  for i = 0, sec_count - 1 do
    sect = ini:GetSectionByIndex(i)
    if ini:ReadString(i, "MainType", "") == mainType and ini:ReadString(i, "SubType", "") == subType and ini:ReadString(i, "Level", "") == level then
      break
    end
  end
  local index = ini:FindSectionIndex(sect)
  if index < 0 then
    return
  end
  form.CapitalType0 = ini:ReadInteger(index, "CapitalType0", 0)
  form.CapitalType1 = ini:ReadInteger(index, "CapitalType1", 0)
  form.MaxEndure = ini:ReadInteger(index, "MaxEndure", 0)
  form.Needed_Item_Num = ini:ReadString(index, "Needed_Item_Num", "")
  form.lbl_Name.Text = nx_widestr(util_text(ini:ReadString(index, "Name", "")))
  local guild_photo = ini:ReadString(index, "Photo", "")
  if guild_photo ~= "" then
    form.lbl_buliding_photo.BackImage = guild_photo .. ".png"
  end
  form.lbl_MaxEndure.Text = nx_widestr(form.MaxEndure)
  if nx_number(form.CapitalType0) == 0 and nx_number(form.CapitalType1) == 0 then
    form.groupbox_3.Visible = false
    form.groupbox_4.Visible = false
    form.Height = form.groupbox_2.Top + form.groupbox_2.Height + 50
    form.lbl_bg_main.Height = form.Height - form.lbl_bg_main.Top + form.lbl_line_2.Top + 10
    return
  else
    refresh_capital_num(form)
  end
  if form.Needed_Item_Num == "" then
    form.groupbox_4.Visible = false
    form.Height = form.groupbox_3.Top + form.groupbox_3.Height + 50
    form.lbl_bg_main.Height = form.Height - form.lbl_bg_main.Top + form.lbl_line_2.Top + 10
    return
  end
  local material_str = form.Needed_Item_Num
  local str_lst = util_split_string(material_str, ";")
  local gui = nx_value("gui")
  local goods_grid = nx_value("GoodsGrid")
  form.MaterialGrid:Clear()
  local ini_item = nx_execute("util_functions", "get_ini", "share\\Item\\tool_item.ini")
  for i, v in ipairs(str_lst) do
    local material_id = util_split_string(v, ":")[1]
    local material_num = util_split_string(v, ":")[2]
    if material_id ~= nil then
      nx_set_custom(form, "material" .. nx_string(i), material_id)
      nx_set_custom(form, "materialnum" .. nx_string(i), material_num)
      form.mark_material_num = i
      local index1 = ini_item:FindSectionIndex(material_id)
      if 0 <= index1 then
        local name = nx_widestr("<center>") .. nx_widestr(ini_item:ReadString(index1, "Name", "")) .. nx_widestr("</center>")
        form.MaterialGrid:AddItem(i - 1, nx_string(ini_item:ReadString(index1, "Photo", "")), nx_widestr(""), 0, -1)
        form.MaterialGrid:SetItemAddInfo(i - 1, 0, nx_widestr(name))
        form.MaterialGrid:ShowItemAddInfo(i - 1, 0, true)
      end
    end
  end
  refresh_material_num()
end
function read_build_damage_info(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\InterActive\\Arsonist\\arsonist.ini")
  if not nx_is_valid(ini) then
    nx_msgbox("share\\InterActive\\Arsonist\\arsonist.ini " .. get_msg_str("msg_120"))
    return
  end
  local index = ini:FindSectionIndex("build")
  if index < 0 then
    return
  end
  form.DamageStateRate = ini:ReadFloat(index, "DamageStateRate", 0.5)
  form.RuinStateRate = ini:ReadFloat(index, "RuinStateRate", 0.1)
end
function get_num_string(bag_num, repair_need_num)
  local form = nx_value(FORM_NAME)
  local return_str = nx_widestr("")
  if not nx_is_valid(form) then
    return return_str
  end
  if bag_num < repair_need_num then
    return_str = return_str .. nx_widestr("<center><font color=\"#FF0000\">") .. nx_widestr(bag_num)
    return_str = return_str .. nx_widestr("</font>") .. nx_widestr("/") .. nx_widestr(repair_need_num) .. nx_widestr("</center>")
    return return_str
  end
  return_str = return_str .. nx_widestr("<center>") .. nx_widestr(bag_num) .. nx_widestr("/")
  return_str = return_str .. nx_widestr(repair_need_num) .. nx_widestr("</center>")
  return return_str
end
function refresh_material_num()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  if not nx_find_custom(form, "mark_material_num") then
    return
  end
  for i = 1, form.mark_material_num do
    local count = goods_grid:GetItemCount(nx_string(nx_custom(form, "material" .. nx_string(i))))
    local repair_cout = nx_number(form.ipt_1.Text) * nx_custom(form, "materialnum" .. nx_string(i))
    local num_string = get_num_string(count, repair_cout)
    form.MaterialGrid:SetItemAddInfo(i - 1, 1, nx_widestr(num_string))
    form.MaterialGrid:ShowItemAddInfo(i - 1, 1, true)
  end
end
function refresh_capital_num(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "CapitalType0") then
    local capital = nx_number(form.ipt_1.Text) * nx_number(form.CapitalType0)
    form.mltbox_jinzi.HtmlText = nx_widestr(nx_string(manage_capital(capital, 0)))
  end
  if nx_find_custom(form, "CapitalType1") then
    local capital1 = nx_number(form.ipt_1.Text) * nx_number(form.CapitalType1)
    form.mltbox_yinzi.HtmlText = nx_widestr(nx_string(manage_capital(capital1, 1)))
  end
end
function refresh_endure_info()
  local form = nx_value(FORM_NAME)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local buildid = form.building
  local game_client = nx_value("game_client")
  local build_object = game_client:GetSceneObj(nx_string(buildid))
  if not nx_is_valid(game_client) or not nx_is_valid(build_object) then
    return
  end
  local cur_endure = build_object:QueryProp("GuildBuildEndure")
  local cur_repair_endure = build_object:QueryProp("GuildBuildRepairingEndure")
  if 0 < cur_repair_endure then
    form.lbl_repair_time.Text = nx_widestr(get_format_time(nx_number(cur_repair_endure)))
  else
    form.lbl_repair_time.Text = nx_widestr("00:00:00")
  end
  if form.EndureValue == cur_endure then
    return
  end
  if cur_endure < form.MaxEndure * form.RuinStateRate then
    form.lbl_build_state.Text = gui.TextManager:GetText("ui_sunhui")
  elseif cur_endure < form.MaxEndure * form.DamageStateRate then
    form.lbl_build_state.Text = gui.TextManager:GetText("ui_sunshang")
  else
    form.lbl_build_state.Text = gui.TextManager:GetText("build_state_lab_normal")
  end
  form.EndureValue = cur_endure
  form.MaxRepairValue = form.MaxEndure - form.EndureValue
  form.lbl_Endure.Text = nx_widestr(form.EndureValue)
  form.pbar_Endure.Value = form.EndureValue
  form.pbar_Endure.Maximum = form.MaxEndure
end
function manage_capital(capital, capital_type)
  local ding = math.floor(capital / 1000000)
  local liang = math.floor(capital % 1000000 / 1000)
  local wen = math.floor(capital % 1000)
  local gui = nx_value("gui")
  local text_money = nx_widestr("")
  if 0 < ding then
    local text = gui.TextManager:GetText("ui_ding")
    text_money = nx_widestr(ding) .. nx_widestr(text)
  end
  if 0 < liang then
    local text = gui.TextManager:GetText("ui_liang")
    text_money = text_money .. nx_widestr(liang) .. nx_widestr(text)
  end
  if 0 < wen then
    local text = gui.TextManager:GetText("ui_wen")
    text_money = text_money .. nx_widestr(wen) .. nx_widestr(text)
  end
  if capital == 0 then
    text_money = nx_widestr(0)
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local capital_name = "CapitalType" .. nx_string(capital_type)
  local capital_player = client_player:QueryProp(nx_string(capital_name))
  if capital > capital_player then
    return nx_widestr("<center><font color=\"#FF0000\">") .. text_money .. nx_widestr("</font></center>")
  else
    return nx_widestr("<center>") .. text_money .. nx_widestr("</font></center>")
  end
end
function get_max_repair_value()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local repair_value = -1
  if form.Needed_Item_Num ~= "" then
    local goods_grid = nx_value("GoodsGrid")
    if not nx_find_custom(form, "mark_material_num") then
      return
    end
    for i = 1, form.mark_material_num do
      local count = goods_grid:GetItemCount(nx_string(nx_custom(form, "material" .. nx_string(i))))
      local repair_cout = nx_custom(form, "materialnum" .. nx_string(i))
      if nx_number(repair_cout) ~= 0 then
        if repair_value < 0 then
          repair_value = math.floor(count / repair_cout)
        elseif math.floor(count / repair_cout) < nx_number(repair_value) then
          repair_value = math.floor(count / repair_cout)
        end
      end
    end
  end
  if nx_number(form.CapitalType0) ~= 0 or nx_number(form.CapitalType1) ~= 0 then
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    local capital0 = client_player:QueryProp("CapitalType0")
    local capital1 = client_player:QueryProp("CapitalType1")
    if nx_number(form.CapitalType0) ~= 0 then
      if repair_value < 0 then
        repair_value = math.floor(capital0 / form.CapitalType0)
      elseif math.floor(capital0 / form.CapitalType0) < nx_number(repair_value) then
        repair_value = math.floor(capital0 / form.CapitalType0)
      end
    end
    if nx_number(form.CapitalType1) ~= 0 then
      if repair_value < 0 then
        repair_value = math.floor(capital1 / form.CapitalType1)
      elseif math.floor(capital1 / form.CapitalType1) < nx_number(repair_value) then
        repair_value = math.floor(capital1 / form.CapitalType1)
      end
    end
  end
  if repair_value > form.MaxRepairValue then
    repair_value = form.MaxRepairValue
  end
  if repair_value <= 0 then
    repair_value = 0
  end
  return repair_value
end
