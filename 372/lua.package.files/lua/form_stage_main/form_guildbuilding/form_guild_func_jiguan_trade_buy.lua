require("util_gui")
require("share\\view_define")
require("custom_sender")
local money_ding_wen = 1000000
local money_siliver_wen = 1000
CLIENT_CUSTOMMSG_GUILD_FUNC_OPER = 1018
local buy_jiguan = 0
local show_jiguan = 1
local JIGUANBUILD_ADD_VIEWPORT = 2
local JIGUANBUILD_DEL_VIEWPORT = 3
local JIGUANBUILD_DELETE_JIGUAN = 4
local JIGUANBUILD_RES_JIGUAN_LIST = 5
local tbl_config_id = {}
local tbl_btn_list = {}
function form_init(form)
  form.Fixed = false
  form.area_index = -1
  form.pos_index = -1
  form.select_index = -1
  form.last_btn_index = 0
  form.cost_silver = 0
end
function on_form_trade_buy_open(form)
  init_pos_info(form)
  get_jiguan_info(form)
  clear_choose_jiguan_info(form)
  custom_guild_viewport_jiguan(JIGUANBUILD_ADD_VIEWPORT)
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_JIGUAN, form, nx_current(), "on_self_view_operat")
  init_btn_image(form)
  res_jiguan_list()
end
function on_form_trade_buy_close(form)
  local databinder = nx_value("data_binder")
  databinder:DelViewBind(form)
  custom_guild_viewport_jiguan(JIGUANBUILD_DEL_VIEWPORT)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_guildbuilding\\form_guild_func_jiguan_trade_buy")
end
function on_btn_buy_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if nx_int(form.area_index) < nx_int(0) or nx_int(form.pos_index) < nx_int(0) or nx_int(form.select_index) < nx_int(0) then
    local info = gui.TextManager:GetText("85151")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(gui.TextManager:GetFormatText("85153", nx_int(form.cost_silver)))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_FUNC_OPER), buy_jiguan, form.select_index, form.area_index, form.pos_index)
  form.area_index = -1
  form.pos_index = -1
  form.select_index = -1
  form.cost_silver = 0
  clear_choose_jiguan_info(form)
end
function on_btn_destroy_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if nx_int(form.pos_index) < nx_int(0) then
    local info = gui.TextManager:GetText("85152")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(gui.TextManager:GetFormatText("85154"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_FUNC_OPER), JIGUANBUILD_DELETE_JIGUAN, form.pos_index)
  form.area_index = -1
  form.pos_index = -1
  form.select_index = -1
  clear_choose_jiguan_info(form)
end
function custom_guild_viewport_jiguan(subtype)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_FUNC_OPER), nx_int(subtype))
end
function get_jiguan_info(form)
  form.cmb_jiguan.DropListBox:ClearString()
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return false
  end
  local gb_manager = nx_value("GuildJiGuanManager")
  if not nx_is_valid(gb_manager) then
    return false
  end
  local info_list = gb_manager:GetGuildJiGuanInfoList()
  local length = table.getn(info_list)
  tbl_config_id = {}
  for i = 1, length do
    local config_id = info_list[i]
    local jiguan_name = ItemQuery:GetItemPropByConfigID(nx_string(config_id), nx_string("Name"))
    form.cmb_jiguan.DropListBox:AddString(nx_widestr(jiguan_name))
    table.insert(tbl_config_id, config_id)
  end
  form.cmb_jiguan.DropListBox.SelectIndex = 0
  form.btn_buy.Enabled = false
  form.btn_buy.Visible = false
  form.btn_destroy.Enabled = false
  form.btn_destroy.Visible = false
end
function on_cmb_jiguan_selected(combobox)
  local form = combobox.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local select_index = combobox.DropListBox.SelectIndex
  local length = table.getn(tbl_config_id)
  if select_index > length then
    return
  end
  local config_id = tbl_config_id[select_index + 1]
  init_jiguan_info(form, config_id)
  form.select_index = select_index
end
function init_pos_info(form)
  local gb_manager = nx_value("GuildJiGuanManager")
  if not nx_is_valid(gb_manager) then
    return false
  end
  tbl_btn_list = {}
  local info_list = gb_manager:GetGuildJiGuanPosInfoList()
  local length = table.getn(info_list)
  if length <= 0 or length % 3 ~= 0 then
    return false
  end
  local rows = length / 3
  for i = 1, rows do
    local base = (i - 1) * 3
    local btn_name = nx_string("btn_") .. nx_string(i)
    local area_index = info_list[base + 1]
    local pos_index = info_list[base + 2]
    local jiguan_type = info_list[base + 3]
    table.insert(tbl_btn_list, {
      btn_name,
      nx_int(area_index),
      nx_int(pos_index),
      nx_int(jiguan_type)
    })
  end
end
function init_jiguan_info(form, config_id)
  if config_id == nil then
    return false
  end
  local gui = nx_value("gui")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return false
  end
  local photo = "gui\\guild\\jiguan\\" .. config_id .. ".png"
  form.pic_jiguan_photo.Image = photo
  form.mltbox_introduce.HtmlText = nx_widestr(gui.TextManager:GetText("ui_jiguan_info_" .. nx_string(config_id)))
  form.mltbox_damage.HtmlText = nx_widestr(gui.TextManager:GetText("ui_jiguan_damage_" .. nx_string(config_id)))
  local jg_manager = nx_value("GuildJiGuanManager")
  if not nx_is_valid(jg_manager) then
    return
  end
  local remove_info = jg_manager:GetGuildJiGuanRemoveInfo(nx_string(config_id))
  local remove_type = remove_info[1]
  local money_gold = ""
  local money_silver = ""
  local goods_info = ""
  local silver_card = remove_info[2]
  local silver = remove_info[3]
  form.cost_silver = silver
  if nx_int(silver_card) > nx_int(0) then
    money_changed(form, silver_card)
  elseif nx_int(silver) > nx_int(0) then
    money_changed(form, silver)
  end
  local jiguan_type = remove_info[4]
  local txt_jiguan_type = nx_widestr(gui.TextManager:GetText("ui_jiguan_type_" .. nx_string(jiguan_type)))
  form.mltbox_type.HtmlText = nx_widestr(nx_string(txt_jiguan_type))
end
function money_changed(form, silver)
  local d = nx_int(silver / money_ding_wen)
  local l = nx_int((silver - d * money_ding_wen) / money_siliver_wen)
  local w = silver - d * money_ding_wen - l * money_siliver_wen
  form.ipt_price_ding.Text = nx_widestr(d)
  form.ipt_price_liang.Text = nx_widestr(l)
  form.ipt_price_wen.Text = nx_widestr(w)
end
function on_self_view_operat(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_JIGUAN))
  if not nx_is_valid(view) then
    return 1
  end
  if not view:FindRecord("JiGuanPosNumRec") then
    return 1
  end
  for i = 1, 3 do
    local row = view:FindRecordRow("JiGuanPosNumRec", 0, nx_int(i), 0)
    if nx_int(row) >= nx_int(0) then
      local curJiGuanNum = view:QueryRecord("JiGuanPosNumRec", nx_int(row), nx_int(1))
      local jiGuanTotalNum = view:QueryRecord("JiGuanPosNumRec", nx_int(row), nx_int(2))
      local curType0Num = view:QueryRecord("JiGuanPosNumRec", nx_int(row), nx_int(3))
      local Type0TotalNum = view:QueryRecord("JiGuanPosNumRec", nx_int(row), nx_int(4))
      local curType1Num = view:QueryRecord("JiGuanPosNumRec", nx_int(row), nx_int(5))
      local Type1TotalNum = view:QueryRecord("JiGuanPosNumRec", nx_int(row), nx_int(6))
      local show_num = nx_string(curJiGuanNum) .. "/" .. nx_string(jiGuanTotalNum)
      local type_0_num = nx_string(curType0Num) .. "/" .. nx_string(Type0TotalNum)
      local type_1_num = nx_string(curType1Num) .. "/" .. nx_string(Type1TotalNum)
      if nx_int(i) == nx_int(1) then
        form.lbl_all_1.Text = nx_widestr(show_num)
        form.lbl_touzhi_1.Text = nx_widestr(type_0_num)
        form.lbl_trap_1.Text = nx_widestr(type_1_num)
      elseif nx_int(i) == nx_int(2) then
        form.lbl_all_2.Text = nx_widestr(show_num)
        form.lbl_touzhi_2.Text = nx_widestr(type_0_num)
        form.lbl_trap_2.Text = nx_widestr(type_1_num)
      elseif nx_int(i) == nx_int(3) then
        form.lbl_all_3.Text = nx_widestr(show_num)
        form.lbl_touzhi_3.Text = nx_widestr(type_0_num)
        form.lbl_trap_3.Text = nx_widestr(type_1_num)
      end
    end
  end
  init_btn_image(form)
  res_jiguan_list()
end
function on_btn_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local index = nx_int(btn.DataSource)
  local length = table.getn(tbl_btn_list)
  if nx_int(index) > nx_int(length) then
    return false
  end
  local temp_info = tbl_btn_list[nx_number(index)]
  if temp_info == nil then
    return false
  end
  form.area_index = temp_info[2]
  form.pos_index = temp_info[3]
  if not nx_find_custom(btn, "is_buy") then
    btn.is_buy = 0
  end
  local is_buy = btn.is_buy
  if is_buy == 1 then
    form.btn_buy.Enabled = false
    form.btn_buy.Visible = false
    form.btn_destroy.Enabled = true
    form.btn_destroy.Visible = true
    clear_choose_jiguan_info(form)
    init_jiguan_info(form, btn.config_id)
    btn.NormalImage = "gui\\guild\\jiguan\\" .. btn.config_id .. "_3.png"
  else
    form.btn_buy.Enabled = true
    form.btn_buy.Visible = true
    form.btn_destroy.Enabled = false
    form.btn_destroy.Visible = false
    local jiguan_type = btn.jiguan_type
    if jiguan_type == 0 then
      btn.NormalImage = "gui\\guild\\jiguan\\jiguan_type_0_3.png"
    else
      btn.NormalImage = "gui\\guild\\jiguan\\jiguan_type_1_3.png"
    end
  end
  if 0 < form.last_btn_index then
    set_last_choose_btn_image(form, form.last_btn_index)
  end
  form.last_btn_index = index
end
function res_jiguan_list()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_FUNC_OPER), JIGUANBUILD_RES_JIGUAN_LIST)
end
function on_recv_jiguan_list(...)
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_func_jiguan_trade_buy")
  if not nx_is_valid(form) then
    return 0
  end
  local size = table.getn(arg)
  if size < 0 or size % 3 ~= 0 then
    return 0
  end
  local rows = size / 3
  for i = 1, rows do
    local base = (i - 1) * 3
    local pos_index = nx_int(arg[base + 1])
    local config_id = nx_string(arg[base + 2])
    local jiguan_type = nx_int(arg[base + 3])
    reset_btn_image(form, pos_index, config_id, jiguan_type)
  end
end
function init_btn_image(form)
  if tbl_btn_list == nil then
    return false
  end
  local length = table.getn(tbl_btn_list)
  if nx_int(length) == nx_int(0) then
    return false
  end
  for i = 1, length do
    local temp_info = tbl_btn_list[i]
    local btn_name = temp_info[1]
    local area_index = temp_info[2]
    local pos_index = temp_info[3]
    local jiguan_type = temp_info[4]
    local btn_name = "btn_" .. nx_string(i)
    local btn_jiguan = form.grb_points:Find(btn_name)
    if nx_is_valid(btn_jiguan) then
      btn_jiguan.is_buy = 0
      btn_jiguan.config_id = ""
      btn_jiguan.jiguan_type = jiguan_type
      if jiguan_type == 0 then
        btn_jiguan.FocusImage = "gui\\guild\\jiguan\\jiguan_type_0_1.png"
        btn_jiguan.NormalImage = "gui\\guild\\jiguan\\jiguan_type_0_2.png"
      else
        btn_jiguan.FocusImage = "gui\\guild\\jiguan\\jiguan_type_1_1.png"
        btn_jiguan.NormalImage = "gui\\guild\\jiguan\\jiguan_type_1_2.png"
      end
    end
  end
end
function reset_btn_image(form, pos_index, config_id, jiguan_type)
  local index = pos_index + 1
  local btn_name = "btn_" .. nx_string(index)
  local btn_jiguan = form.grb_points:Find(btn_name)
  if not nx_is_valid(btn_jiguan) then
    return false
  end
  btn_jiguan.is_buy = 1
  btn_jiguan.config_id = config_id
  btn_jiguan.NormalImage = "gui\\guild\\jiguan\\" .. config_id .. "_1.png"
  btn_jiguan.FocusImage = "gui\\guild\\jiguan\\" .. config_id .. "_2.png"
end
function set_last_choose_btn_image(form, last_btn_index)
  local btn_name = "btn_" .. nx_string(last_btn_index)
  local btn = form.grb_points:Find(btn_name)
  if not nx_is_valid(btn) then
    return false
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  if not nx_find_custom(btn, "is_buy") then
    btn.is_buy = 0
  end
  if not nx_find_custom(btn, "config_id") then
    btn.config_id = ""
  end
  if not nx_find_custom(btn, "jiguan_type") then
    btn.config_id = ""
  end
  local is_buy = btn.is_buy
  local config_id = btn.config_id
  local jiguan_type = btn.jiguan_type
  if is_buy == 1 then
    btn.NormalImage = "gui\\guild\\jiguan\\" .. config_id .. "_1.png"
    btn.FocusImage = "gui\\guild\\jiguan\\" .. config_id .. "_2.png"
    return
  end
  if jiguan_type == 0 then
    btn.FocusImage = "gui\\guild\\jiguan\\jiguan_type_0_1.png"
    btn.NormalImage = "gui\\guild\\jiguan\\jiguan_type_0_2.png"
  else
    btn.FocusImage = "gui\\guild\\jiguan\\jiguan_type_1_1.png"
    btn.NormalImage = "gui\\guild\\jiguan\\jiguan_type_1_2.png"
  end
end
function clear_choose_jiguan_info(form)
  if not nx_is_valid(form) then
    return
  end
  form.cmb_jiguan.Text = nx_widestr("")
  form.pic_jiguan_photo.Image = ""
  form.mltbox_introduce.HtmlText = nx_widestr("")
  form.mltbox_damage.HtmlText = nx_widestr("")
  form.mltbox_type.HtmlText = nx_widestr("")
  form.ipt_price_ding.Text = nx_widestr("")
  form.ipt_price_liang.Text = nx_widestr("")
  form.ipt_price_wen.Text = nx_widestr("")
  local btn_name = "btn_" .. nx_string(form.last_btn_index)
  local btn = form.grb_points:Find(btn_name)
  if not nx_is_valid(btn) then
    return false
  end
  if not nx_find_custom(btn, "is_buy") then
    btn.is_buy = 0
  end
  if not nx_find_custom(btn, "config_id") then
    btn.config_id = ""
  end
  btn.is_buy = 0
  btn.config_id = ""
  set_last_choose_btn_image(form, form.last_btn_index)
  form.last_btn_index = 0
end
