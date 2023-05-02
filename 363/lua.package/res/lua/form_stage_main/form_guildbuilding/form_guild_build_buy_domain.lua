require("util_gui")
local REMOVE_FROM_PLAYER_ALL = 0
local REMOVE_FROM_PLAYER_NONE = 1
local REMOVE_FROM_PLAYER_CAPITALTYPE = 2
local REMOVE_FROM_PLAYER_GOODS = 3
function form_init(form)
  form.Fixed = false
  form.row = nil
  form.domainID = 0
  form.fieldNum = nil
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.pic_2.Visible = false
  form.pic_3.Visible = false
  form.pic_4.Visible = false
  form.pic_5.Visible = false
  form.pic_6.Visible = false
  form.pic_7.Visible = false
  form.pic_8.Visible = false
  form.pic_9.Visible = false
  form.lbl_4.Visible = false
  form.lbl_5.Visible = false
  form.lbl_6.Visible = false
  form.lbl_7.Visible = false
  form.lbl_8.Visible = false
  form.lbl_9.Visible = false
  form.lbl_10.Visible = false
  form.lbl_11.Visible = false
  form.lbl_b1.Visible = false
  form.lbl_b2.Visible = false
  form.lbl_b3.Visible = false
  form.lbl_b4.Visible = false
  form.lbl_b5.Visible = false
  form.lbl_b6.Visible = false
  form.lbl_b7.Visible = false
  form.lbl_b8.Visible = false
  form.lbl_16.Visible = false
  form.lbl_17.Visible = false
  nx_execute("form_stage_main\\form_guildbuilding\\form_guild_build_buy_domain", "show_buy_domain_info", form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_guildbuilding\\form_guild_build_buy_domain")
end
function on_btn_click(btn)
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_buy_domain_confirm")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guildbuilding\\form_guild_build_buy_domain_confirm", true, false)
    nx_set_value("form_stage_main\\form_guildbuilding\\form_guild_build_buy_domain_confirm", form)
  end
  form.file_name = "form_guild_build_buy_domain"
  form.function_name = "buy_domain"
  form:ShowModal()
  form.Visible = true
end
function on_pic_get_capture(pic)
  local gui = nx_value("gui")
  local mouse_x, mouse_z = gui:GetCursorPosition()
  local pic_info = nx_widestr(gui.TextManager:GetText("ui_show_building_info_" .. nx_string(pic.building_ID)))
  nx_execute("tips_game", "show_text_tip", nx_widestr(pic_info), mouse_x, mouse_z)
end
function on_pic_lost_capture(pic)
  nx_execute("tips_game", "hide_tip")
end
function show_buy_domain_info(form)
  local gui = nx_value("gui")
  form.lbl_1.Text = nx_widestr(gui.TextManager:GetText("ui_buy_domain"))
  form.lbl_2.Text = nx_widestr(gui.TextManager:GetText("ui_dipan_guild_" .. nx_string(form.fieldNum + 1)))
  form.lbl_3.Text = nx_widestr(gui.TextManager:GetText("ui_dipan_build_" .. nx_string(form.fieldNum + 1)))
  local domain_manager = nx_value("GuildDomainManager")
  local building_info = domain_manager:GetFieldBuildingInfo(form.fieldNum + 1)
  show_building_info(form, gui, unpack(building_info))
  local buy_info = domain_manager:GetDomainRemoveInfo(form.fieldNum + 1)
  show_buy_info(form, gui, unpack(buy_info))
  if form.fieldNum > 0 then
    form.btn_1.Text = nx_widestr(gui.TextManager:GetText("ui_domain_kuozhang"))
  else
    form.btn_1.Text = nx_widestr(gui.TextManager:GetText("ui_domain_qiangzhan"))
  end
end
function buy_domain()
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_buy_domain")
  local CUSTOMMSG_OPER_GUILD_DOMAIN_BUY = 0
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_guildbuilding\\form_guild_build_domain", "request_data", CUSTOMMSG_OPER_GUILD_DOMAIN_BUY, form.row)
  util_auto_show_hide_form("form_stage_main\\form_guildbuilding\\form_guild_build_buy_domain")
end
function show_building_info(form, gui, ...)
  local arg_num = table.getn(arg)
  local map_res = "gui\\guild\\guildbuilding\\"
  form.pic_1.Image = map_res .. nx_string("quyu_") .. nx_string(form.fieldNum + 1) .. ".png"
  for i = 1, arg_num do
    local pic_name = "pic_" .. nx_string(1 + i)
    local pic_obj = form:Find(pic_name)
    if not nx_is_valid(pic_obj) then
      return false
    end
    local map_name = map_res .. nx_string("GuildBuilding_") .. nx_string(arg[i]) .. ".png"
    pic_obj.Image = map_name
    pic_obj.Visible = true
    pic_obj.building_ID = arg[i]
    local lbl_name = "lbl_" .. nx_string(3 + i)
    local lbl_obj = form:Find(lbl_name)
    if not nx_is_valid(lbl_obj) then
      return false
    end
    lbl_obj.Text = nx_widestr(gui.TextManager:GetText("ui_show_building_name_" .. nx_string(arg[i])))
    lbl_obj.Visible = true
    local lbl_b = form.groupbox_1:Find("lbl_b" .. nx_string(i))
    if nx_is_valid(lbl_b) then
      lbl_b.Visible = true
    end
  end
end
function show_buy_info(form, gui, ...)
  form.lbl_12.Text = nx_widestr(gui.TextManager:GetText("19308") .. gui.TextManager:GetText("ui_maohao"))
  form.lbl_14.Text = nx_widestr(gui.TextManager:GetText("19307") .. gui.TextManager:GetText("ui_maohao"))
  local remove_type = arg[1]
  local money_gold = ""
  local money_silver = ""
  local goods_info = ""
  local gold = arg[2]
  if nx_int(gold) > nx_int(0) then
    money_gold = nx_widestr(gui.TextManager:GetText("ui_offline_form_jinbi")) .. nx_widestr(gui.TextManager:GetText("ui_maohao")) .. nx_widestr(nx_execute("util_functions", "trans_capital_string", gold))
  end
  local silver = arg[3]
  if nx_int(silver) > nx_int(0) then
    money_silver = nx_widestr(gui.TextManager:GetText("ui_silvermoney")) .. nx_widestr(gui.TextManager:GetText("ui_maohao")) .. nx_widestr(nx_execute("util_functions", "trans_capital_string", silver))
  end
  local removeGoodsNum = (table.getn(arg) - 3) / 2
  if 0 < removeGoodsNum then
    for i = 0, removeGoodsNum - 1 do
      local config = arg[i * 2 + 4]
      local num = arg[i * 2 + 5]
      local str_config = nx_widestr(gui.TextManager:GetText(config))
      goods_info = goods_info .. nx_string(str_config) .. "x" .. nx_string(num) .. " "
    end
  end
  if remove_type == REMOVE_FROM_PLAYER_ALL then
    if nx_int(gold) > nx_int(0) or nx_int(silver) > nx_int(0) then
      money_gold = nx_widestr(money_gold) .. nx_widestr(" ") .. nx_widestr(money_silver)
      form.lbl_13.HtmlText = nx_widestr(money_gold) .. nx_widestr("<img src=\"gui\\common\\money\\liang.png\" valign=\"center\" only=\"line\" data=\"\" />")
    else
      form.lbl_12.Visible = false
      form.lbl_13.Visible = false
    end
    form.lbl_14.Visible = false
    form.lbl_15.Visible = false
  elseif remove_type == REMOVE_FROM_PLAYER_NONE then
    if nx_int(gold) > nx_int(0) then
      form.lbl_13.Text = nx_widestr(money_gold)
    else
      form.lbl_12.Visible = false
      form.lbl_13.Visible = false
    end
    if nx_int(silver) > nx_int(0) then
      form.lbl_15.Text = nx_widestr(money_silver)
    else
      form.lbl_14.Visible = false
      form.lbl_15.Visible = false
    end
  elseif remove_type == REMOVE_FROM_PLAYER_CAPITALTYPE then
    if nx_int(gold) > nx_int(0) or nx_int(silver) > nx_int(0) then
      money_gold = money_gold .. " " .. money_silver
      form.lbl_13.Text = nx_widestr(money_gold)
    else
      form.lbl_12.Visible = false
      form.lbl_13.Visible = false
    end
    form.lbl_14.Visible = false
    form.lbl_15.Visible = false
  elseif remove_type == REMOVE_FROM_PLAYER_GOODS then
    if nx_int(gold) > nx_int(0) then
      form.lbl_13.Text = nx_widestr(money_gold)
    else
      form.lbl_12.Visible = false
      form.lbl_13.Visible = false
    end
    if nx_int(silver) > nx_int(0) then
      form.lbl_15.Text = nx_widestr(money_silver)
    else
      form.lbl_14.Visible = false
      form.lbl_15.Visible = false
    end
  end
end
