require("form_stage_main\\form_wuxue\\form_wuxue_util")
require("util_functions")
require("utils")
local CAPITAL_TYPE_SILVER = 1
local CAPITAL_TYPE_SILVER_CARD = 2
local CAPITAL_TYPE_BIND_CARD = 4
local ST_FUNCTION_TONIC_YINPIAO = 105
local ST_FUNCTION_TONIC_PRIZE_OFF = 600
local CLIENT_CUSTOMMSG_TONIC = 160
local MSG_CLIENT_USE_TONIC = 1
local FORM_NAME = "form_stage_main\\form_wuxue\\form_use_tonicitem"
LAST_SELECT_CAPITAL_TYPE = CAPITAL_TYPE_SILVER
local QIZHEN_REC = "plug_record"
function open_form()
  util_auto_show_hide_form(nx_current())
end
function on_main_form_init(form)
  form.Fixed = false
  form.uid = ""
  form.curitem = nil
  form.jingmai = ""
  form.item_config = ""
  form.item_prop_add = ""
  form.jingmai_name = ""
  form.item_cost_money = 0
  form.sliver_need_sure = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  if LAST_SELECT_CAPITAL_TYPE == CAPITAL_TYPE_SILVER then
    form.rbtn_sliver.Checked = true
    form.rbtn_sliver_card.Checked = false
    form.rbtn_yinpiao.Checked = false
    form.lbl_capital_type.BackImage = "gui\\common\\money\\suiyin.png"
  elseif LAST_SELECT_CAPITAL_TYPE == CAPITAL_TYPE_SILVER_CARD then
    form.rbtn_sliver.Checked = false
    form.rbtn_sliver_card.Checked = true
    form.rbtn_yinpiao.Checked = false
    form.lbl_capital_type.BackImage = "gui\\common\\money\\yyb.png"
  else
    form.rbtn_sliver.Checked = true
    form.rbtn_sliver_card.Checked = false
    form.rbtn_yinpiao.Checked = false
    form.lbl_capital_type.BackImage = "gui\\common\\money\\suiyin.png"
  end
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    if switch_manager:CheckSwitchEnable(ST_FUNCTION_TONIC_YINPIAO) then
      if LAST_SELECT_CAPITAL_TYPE == CAPITAL_TYPE_BIND_CARD then
        form.rbtn_sliver.Checked = false
        form.rbtn_sliver_card.Checked = false
        form.rbtn_yinpiao.Checked = true
        form.lbl_capital_type.BackImage = "gui\\common\\money\\yinpiao.png"
      end
    else
      form.rbtn_yinpiao.Visible = false
      form.lbl_6.Visible = false
    end
    if switch_manager:CheckSwitchEnable(ST_FUNCTION_TONIC_PRIZE_OFF) then
      nx_execute("util_gui", "ui_show_attached_form", form)
    else
      form.btn_help.Visible = false
    end
  end
  refresh_item_name()
  on_refresh_prop(form)
  form.fipt_use_num_value.Text = nx_widestr(1)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind(QIZHEN_REC, form, nx_current(), "on_record_changed")
  end
  fill_total_cost(form)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind(QIZHEN_REC, form)
  end
  ui_destroy_attached_form(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if form.rbtn_sliver.Checked then
    form.lbl_capital_type.BackImage = "gui\\common\\money\\suiyin.png"
  elseif form.rbtn_sliver_card.Checked then
    form.lbl_capital_type.BackImage = "gui\\common\\money\\yyb.png"
  elseif form.rbtn_yinpiao.Checked then
    form.lbl_capital_type.BackImage = "gui\\common\\money\\yinpiao.png"
  end
  fill_total_cost(form)
end
function on_btn_ok_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  local item_obj = form.curitem
  if not nx_is_valid(item_obj) then
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    local view = game_client:GetView(nx_string(VIEWPORT_TOOL))
    if not nx_is_valid(view) then
      return
    end
    local item_list = view:GetViewObjList()
    for i, item in pairs(item_list) do
      local jingmai = item:QueryProp("jingmai")
      local itemtype = item:QueryProp("ItemType")
      if nx_string(jingmai) == nx_string(form.jingmai) and nx_int(itemtype) == nx_int(ITEMTYPE_TONIC_ITEM) then
        form.jingmai = jingmai
        form.uid = item:QueryProp("UniqueID")
        form.curitem = item
        break
      end
    end
  end
  if form.rbtn_sliver.Checked then
    if form.sliver_need_sure == true then
      local res = show_confirm(nx_widestr(gui.TextManager:GetText("desc_qizhen_suiyin_tankuang")))
      if "cancel" == res then
        return
      end
    end
    form.sliver_need_sure = false
    request_use_tonic_item(form, CAPITAL_TYPE_SILVER)
  elseif form.rbtn_sliver_card.Checked then
    request_use_tonic_item(form, CAPITAL_TYPE_SILVER_CARD)
  elseif form.rbtn_yinpiao.Checked then
    request_use_tonic_item(form, CAPITAL_TYPE_BIND_CARD)
  else
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text(""), 2)
    end
  end
  fill_total_cost(form)
end
function get_capital_type_selected(form)
  local capital_type = -1
  if form.rbtn_sliver.Checked then
    capital_type = CAPITAL_TYPE_SILVER
  elseif form.rbtn_sliver_card.Checked then
    capital_type = CAPITAL_TYPE_SILVER_CARD
  elseif form.rbtn_yinpiao.Checked then
    capital_type = CAPITAL_TYPE_BIND_CARD
  end
  return capital_type
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_jingmai_form_click(btn)
  local form = btn.ParentForm
  local item_obj = form.curitem
  if not nx_is_valid(item_obj) then
    return
  end
  local jingmai = nx_execute("util_static_data", "queryprop_by_object", item_obj, "jingmai")
  open_wuxue_sub_page(WUXUE_JINGMAI, jingmai)
end
function refresh_item_name()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local item_obj = form.curitem
  if nx_is_valid(item_obj) then
    local config_id = nx_execute("util_static_data", "queryprop_by_object", item_obj, "ConfigID")
    local Photo = nx_execute("util_static_data", "queryprop_by_object", item_obj, "Photo")
    form.grid_tonic.BackImage = Photo
    form.lbl_item_name.Text = nx_widestr(util_text(nx_string(config_id)))
    form.mltbox_tonic_info.HtmlText = nx_widestr("")
    set_tonic_info(form)
  end
end
function on_record_changed(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_refresh_prop", form)
    timer:Register(500, -1, nx_current(), "on_refresh_prop", form, -1, -1)
  end
end
function on_refresh_prop(form)
  local gui = nx_value("gui")
  local item_obj = form.curitem
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return
  end
  local configid = ""
  local propadd = ""
  local jingmai_name = ""
  if nx_is_valid(item_obj) then
    configid = item_obj:QueryProp("ConfigID")
    propadd = item_obj:QueryProp("propadd")
    jingmai_name = nx_execute("util_static_data", "queryprop_by_object", item_obj, "jingmai")
    form.item_config = configid
    form.item_prop_add = propadd
    form.jingmai_name = jingmai_name
    form.item_cost_money = item_obj:QueryProp("useprice")
  else
    configid = form.item_config
    propadd = form.item_prop_add
    jingmai_name = form.jingmai_name
  end
  local jingmai = wuxue_query:GetLearnID_JingMai(nx_string(jingmai_name))
  if not nx_is_valid(jingmai) then
    return
  end
  local str_lst = util_split_string(propadd, ",")
  if 0 == table.getn(str_lst) then
    return
  end
  local prop_name = ""
  local prop_value = 0
  local rows = jingmai:GetRecordRows("plug_record")
  local text_prop = nx_widestr("")
  if nx_int(rows) > nx_int(0) then
    for i = 0, rows do
      for j = 1, table.getn(str_lst) do
        prop_name = jingmai:QueryRecord("plug_record", i, 0)
        prop_value = jingmai:QueryRecord("plug_record", i, 1)
        if nx_string(prop_name) ~= "" and nx_int(prop_value) ~= nx_int(0) and nx_string(configid) ~= "" and nx_string(prop_name) == nx_string(str_lst[j]) then
          text_prop = nx_widestr(text_prop) .. nx_widestr(gui.TextManager:GetText("tips_qz_equip")) .. nx_widestr(gui.TextManager:GetText("ui_jm_" .. prop_name)) .. nx_widestr(prop_value) .. nx_widestr("<br>")
        end
      end
    end
  end
  if nx_widestr(text_prop) == nx_widestr("") then
    text_prop = nx_widestr(gui.TextManager:GetText("ui_tonic_noprop")) .. nx_widestr("<br>")
  end
  local maxamount = get_item_total_num(configid)
  if nx_int(maxamount) > nx_int(0) then
    local num = nx_widestr(gui.TextManager:GetFormatText("tips_item_amount", "#ffcc00", nx_int(maxamount)))
    form.mltbox_num.HtmlText = num
    local real_use_num = get_real_use_num(form)
    form.mbox_qz_max_num.HtmlText = nx_widestr(gui.TextManager:GetFormatText("desc_qz_num", nx_widestr(real_use_num)))
  else
    form.mltbox_num.HtmlText = nx_widestr(gui.TextManager:GetText("tips_tonic_count"))
    form.mbox_qz_max_num.HtmlText = nx_widestr(gui.TextManager:GetFormatText("desc_qz_num", nx_widestr(0)))
  end
  form.mltbox_prop.IsEditMode = true
  form.mltbox_prop.HtmlText = text_prop
  form.mltbox_prop.IsEditMode = false
  set_tonic_info(form)
end
function set_tonic_info(form)
  local item_obj = form.curitem
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return
  end
  local faculty_query = nx_value("faculty_query")
  if not nx_is_valid(faculty_query) then
    return
  end
  local configid = ""
  local propadd = ""
  local jingmai_name = ""
  if nx_is_valid(item_obj) then
    configid = item_obj:QueryProp("ConfigID")
    propadd = item_obj:QueryProp("propadd")
    jingmai_name = nx_execute("util_static_data", "queryprop_by_object", item_obj, "jingmai")
  else
    configid = form.item_config
    propadd = form.item_prop_add
    jingmai_name = form.jingmai_name
  end
  local jingmai = wuxue_query:GetLearnID_JingMai(nx_string(jingmai_name))
  if not nx_is_valid(jingmai) then
    return
  end
  local prop_name = propadd
  local gui = nx_value("gui")
  local str_lst = util_split_string(propadd, ",")
  if 0 == table.getn(str_lst) then
    return
  end
  local max_tonic = ""
  local max_tonic_value = 0
  for i = 1, table.getn(str_lst) do
    max_tonic_value = faculty_query:GetMaxTonicValue(jingmai, jingmai_name, nx_string(str_lst[i]))
    max_tonic = nx_widestr(max_tonic) .. nx_widestr(gui.TextManager:GetText("tips_qz_maxvalue")) .. nx_widestr(gui.TextManager:GetText("ui_jm_" .. str_lst[i])) .. nx_widestr(max_tonic_value) .. nx_widestr("<br>")
  end
  local desc_0 = nx_widestr(gui.TextManager:GetText("desc_" .. configid .. "_0")) .. nx_widestr("<br>")
  local desc = nx_widestr(gui.TextManager:GetText("desc_" .. configid))
  form.mltbox_tonic_info.HtmlText = max_tonic .. desc_0 .. desc
  form.mbox_qz_xuewei_desc.HtmlText = gui.TextManager:GetText("desc_xuewei_" .. configid)
  form.mbox_qz_xiaoguo_desc.HtmlText = gui.TextManager:GetText("desc_xiaoguo_" .. configid)
  form.lbl_use_num_title.Text = gui.TextManager:GetText("ui_qz_use_num")
end
function get_real_use_num(form)
  local CapitalModule = nx_value("CapitalModule")
  if not nx_is_valid(CapitalModule) then
    return
  end
  local item_obj = form.curitem
  local capital_type = get_capital_type_selected(form)
  if -1 == capital_type then
    return
  end
  local max_value = CapitalModule:GetCapital(capital_type)
  local cost_money = 0
  local configid = ""
  if not nx_is_valid(item_obj) then
    cost_money = form.item_cost_money
    configid = form.item_config
  else
    cost_money = item_obj:QueryProp("useprice")
    configid = item_obj:QueryProp("ConfigID")
  end
  local total_num = get_item_total_num(configid)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return
  end
  local price_mul = wuxue_query:GetTonicPriceMul(item_obj)
  if CAPITAL_TYPE_SILVER == capital_type then
    price_mul = 1
  end
  local can_use_num = max_value / (cost_money * price_mul)
  local real_use_num = 1
  if total_num >= can_use_num then
    real_use_num = can_use_num
  else
    real_use_num = total_num
  end
  return nx_int(real_use_num)
end
function request_use_tonic_item(form, type)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local item_obj = form.curitem
  if not nx_is_valid(item_obj) then
    return
  end
  if type < CAPITAL_TYPE_SILVER or type > CAPITAL_TYPE_BIND_CARD then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TONIC), nx_int(MSG_CLIENT_USE_TONIC), nx_string(form.uid), nx_int(type), nx_int(form.fipt_use_num_value.Text))
  form.fipt_use_num_value.Text = nx_widestr(1)
  LAST_SELECT_CAPITAL_TYPE = type
end
function get_item_total_num(config)
  game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local toolbox = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(toolbox) then
    return 0
  end
  local sum = 0
  local toolbox_objlist = toolbox:GetViewObjList()
  for i, obj in pairs(toolbox_objlist) do
    local config_id = obj:QueryProp("ConfigID")
    if nx_string(config_id) == nx_string(config) then
      sum = nx_int(sum) + nx_int(obj:QueryProp("Amount"))
    end
  end
  return sum
end
function on_fipt_use_num_value_changed(float_edit)
  modify_fipt_use_num_value(float_edit)
end
function modify_fipt_use_num_value(ctrl)
  local form = ctrl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local real_use_num = get_real_use_num(form)
  if nx_int(real_use_num) <= nx_int(form.fipt_use_num_value.Text) then
    form.fipt_use_num_value.Text = nx_widestr(real_use_num)
  elseif nx_int(form.fipt_use_num_value.Text) <= nx_int(0) then
    form.fipt_use_num_value.Text = nx_widestr(1)
  end
  fill_total_cost(form)
end
function on_rbtn_money_get_capture(ctrl)
  local form = ctrl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return
  end
  local item_obj = form.curitem
  if not nx_is_valid(item_obj) then
    return
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return
  end
  local item_obj = form.curitem
  if not nx_is_valid(item_obj) then
    return
  end
  local price_mul = wuxue_query:GetTonicPriceMul(item_obj)
  local price = item_obj:QueryProp("useprice")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local gui = nx_value("gui")
  local tips = nx_string("")
  tips = nx_string("tips_bag_silver1_0")
  if ctrl.TabIndex == 0 then
    tips = nx_string("tips_qizhen_silver01")
    price_mul = 1
  elseif ctrl.TabIndex == 1 then
    tips = nx_string("tips_qizhen_silver03")
  elseif ctrl.TabIndex == 2 then
    tips = nx_string("tips_qizhen_silver02")
  end
  local tips_text = gui.TextManager:GetFormatText(tips, nx_int64(price_mul * price * nx_int(form.fipt_use_num_value.Text) / 1000))
  local mouse_x, mouse_z = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), mouse_x, mouse_z)
end
function on_rbtn_money_lost_capture(ctrl)
  nx_execute("tips_game", "hide_tip")
end
function get_real_total_money(form)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local item_obj = form.curitem
  if not nx_is_valid(item_obj) then
    return 0
  end
  local price_mul = wuxue_query:GetTonicPriceMul(item_obj)
  if form.rbtn_sliver.Checked then
    price_mul = 1
  end
  local price = item_obj:QueryProp("useprice")
  return price_mul * price * nx_int(form.fipt_use_num_value.Text)
end
function fill_total_cost(form)
  local capital = get_real_total_money(form)
  local ding = math.floor(capital / 1000000)
  local liang = math.floor(capital % 1000000 / 1000)
  local wen = math.floor(capital % 1000)
  local gui = nx_value("gui")
  local textyZi = nx_widestr("")
  local htmlTextYinZi = nx_widestr("<center>")
  if 0 < ding then
    local text = gui.TextManager:GetText("ui_ding")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    if add_color then
      ding = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(nx_int(ding)) .. nx_widestr("</font>")
    end
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(ding) .. nx_widestr(htmlText)
  end
  if 0 < liang then
    local text = gui.TextManager:GetText("ui_liang")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    if add_color then
      liang = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(nx_int(liang)) .. nx_widestr("</font>")
    end
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(liang) .. nx_widestr(htmlText)
  end
  if 0 < wen then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    if add_color then
      wen = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(nx_int(wen)) .. nx_widestr("</font>")
    end
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(wen) .. nx_widestr(htmlText)
  end
  if capital == 0 then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinZi = htmlTextYinZi .. nx_widestr("0") .. nx_widestr(htmlText)
  end
  htmlTextYinZi = htmlTextYinZi .. nx_widestr("</center>")
  form.mltbox_8.HtmlText = htmlTextYinZi
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
