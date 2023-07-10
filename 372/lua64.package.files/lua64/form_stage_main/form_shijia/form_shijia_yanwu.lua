require("util_gui")
require("util_static_data")
require("share\\client_custom_define")
local FORM = "form_stage_main\\form_shijia\\form_shijia_yanwu"
local MATCH_BEGIN = 1
local MATCH_END = 2
local RESULT_SCALE = 1.8
local DELAY_CLOSE = 2500
local YANWU_START = 0
local YANWU_FINISH = 1
local YANWU_RESULT = 2
local YANWU_WEAPON = 3
local YANWU_MATCH = 0
local YANWU_QUERY_WEAPON = 1
local NUM_RAND_COUNT = 50
local COUNT_DOWN = 30
local TIME_OUT = 5
function on_main_form_init(self)
  self.Fixed = true
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  self.AbsLeft = gui.Width / 2 - self.Width / 2
  self.AbsTop = gui.Height - self.Height - gui.Height / 7
  self.lbl_result.Rotate = true
  self.lbl_result.Visible = false
end
function on_main_form_close(self)
  clear_timer(self)
  nx_destroy(self)
end
function on_btn_click(self)
end
function on_server_msg(sub_msg, ...)
  if sub_msg == YANWU_START then
    on_yanwu_start(unpack(arg))
  elseif sub_msg == YANWU_FINISH then
    on_yanwu_end(unpack(arg))
  elseif sub_msg == YANWU_RESULT then
    on_yanwu_result(unpack(arg))
  elseif sub_msg == YANWU_WEAPON then
    on_yanwu_weapon_info(unpack(arg))
  end
end
function on_yanwu_weapon_info(...)
  if table.getn(arg) < 2 then
    return
  end
  local form = nx_value(FORM)
  if nx_is_valid(form) then
    form.weapon_uid = nx_string(arg[1])
    form.weapon_info = nx_string(arg[2])
    if nx_find_custom(form, "is_mouse_in") and form.is_mouse_in == true then
      show_hyper_link_iteminfo(form.weapon_info, form.weapon_uid)
    end
  end
end
function on_yanwu_start(...)
  if table.getn(arg) < 1 then
    return
  end
  local form = nx_execute("util_gui", "util_show_form", FORM, true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.groupbox_result.Visible = false
  form.groupbox_match.Visible = true
  clear_timer()
  form.cur_step = MATCH_BEGIN
  if nx_int(arg[1]) ~= nx_int(-1) then
    refresh_weapon_icon(form)
    show_num(form, arg[1])
  else
    show_num(form, 0)
  end
  form.cur_count = 0
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "count_down", form)
  timer:Register(1000, -1, nx_current(), "count_down", form, -1, -1)
end
function on_yanwu_result(...)
  local form = nx_execute("util_gui", "util_show_form", FORM, true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.groupbox_result.Visible = true
  form.groupbox_match.Visible = false
  clear_timer()
  form.cur_step = MATCH_END
  form.lbl_p_name.Text = nx_widestr(arg[1])
  form.lbl_b_name.Text = nx_widestr(arg[2])
  local ItemQuery = nx_value("ItemQuery")
  local data_query = nx_value("data_query_manager")
  if nx_is_valid(ItemQuery) and nx_is_valid(data_query) then
    local art_pack = ItemQuery:GetItemPropByConfigID(nx_string(arg[3]), nx_string("ArtPack"))
    local photo = data_query:Query(STATIC_DATA_ITEM_ART, nx_int(art_pack), "Photo")
    form.imagegrid_icon:Clear()
    form.imagegrid_icon:AddItem(0, photo, "", 0, -1)
  end
  refresh_ability(form, arg[4])
  refresh_ability_boss(form, arg[5])
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "show_result", form)
  timer:Register(50 * NUM_RAND_COUNT, 1, nx_current(), "show_result", form, nx_int(arg[4]) >= nx_int(arg[5]), -1)
end
function on_yanwu_end()
  local form = nx_value(FORM)
  if nx_is_valid(form) then
    clear_timer(form)
    nx_destroy(form)
  end
end
function refresh_weapon_icon(form)
  if not nx_is_valid(form) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local equipbox_view = game_client:GetView(nx_string("1"))
  if not nx_is_valid(equipbox_view) then
    return
  end
  local viewobj_weapon = equipbox_view:GetViewObj("22")
  if not nx_is_valid(viewobj_weapon) then
    return
  end
  local config_id = viewobj_weapon:QueryProp("ConfigID")
  local art_pack = ItemQuery:GetItemPropByConfigID(nx_string(config_id), nx_string("ArtPack"))
  local photo = data_query:Query(STATIC_DATA_ITEM_ART, nx_int(art_pack), "Photo")
  form.imagegrid_icon:Clear()
  form.imagegrid_icon:AddItem(0, photo, "", 0, -1)
end
function on_mousein_grid(self)
  if not nx_is_valid(self.ParentForm) then
    return
  end
  local form = self.ParentForm
  if not nx_find_custom(form, "cur_step") then
    return
  end
  form.is_mouse_in = true
  if form.cur_step == MATCH_BEGIN then
    local game_client = nx_value("game_client")
    if not nx_is_valid(game_client) then
      return
    end
    local equipbox_view = game_client:GetView(nx_string("1"))
    if not nx_is_valid(equipbox_view) then
      return
    end
    local viewobj_weapon = equipbox_view:GetViewObj("22")
    if not nx_is_valid(viewobj_weapon) then
      return
    end
    nx_execute("tips_game", "show_goods_tip", viewobj_weapon, self.AbsLeft + self.Width, self:GetMouseInItemTop(), 32, 32, form, false)
  elseif form.cur_step == MATCH_END then
    if nx_find_custom(form, "weapon_uid") and nx_find_custom(form, "weapon_info") and form.weapon_uid ~= "" and form.weapon_info ~= "" then
      show_hyper_link_iteminfo(form.weapon_info, form.weapon_uid)
    else
      local game_visual = nx_value("game_visual")
      if nx_is_valid(game_visual) then
        game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SHIJIA_YANWU), nx_int(YANWU_QUERY_WEAPON))
      end
    end
  end
end
function refresh_ability(form, score)
  if not nx_is_valid(form) then
    return
  end
  form.randcount1 = 0
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "random_num", form)
  timer:Register(50, NUM_RAND_COUNT, nx_current(), "random_num", form, score, -1)
end
function refresh_ability_boss(form, score)
  if not nx_is_valid(form) then
    return
  end
  form.randcount2 = 0
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "random_num_boss", form)
  timer:Register(50, NUM_RAND_COUNT, nx_current(), "random_num_boss", form, score, -1)
end
function on_mouseout_grid(self)
  nx_execute("tips_game", "hide_tip")
  nx_execute("tips_game", "hide_link_tips")
  if not nx_is_valid(self.ParentForm) then
    return
  end
  self.ParentForm.is_mouse_in = false
end
function show_num(form, score)
  if not nx_is_valid(form) then
    return
  end
  local ctrl_pre = ""
  if form.cur_step == MATCH_BEGIN then
    ctrl_pre = "lbl_"
  elseif form.cur_step == MATCH_END then
    ctrl_pre = "lbl_p_"
  end
  if nx_find_custom(form, ctrl_pre .. "1") then
    local lbl_num = nx_custom(form, ctrl_pre .. "1")
    local num = nx_int(score % 10)
    lbl_num.BackImage = nx_string("gui\\language\\ChineseS\\ywt\\" .. nx_string(num) .. ".png")
  end
  if nx_find_custom(form, ctrl_pre .. "2") then
    local lbl_num = nx_custom(form, ctrl_pre .. "2")
    local num = nx_int(score % 100 / 10)
    lbl_num.BackImage = nx_string("gui\\language\\ChineseS\\ywt\\" .. nx_string(num) .. ".png")
  end
  if nx_find_custom(form, ctrl_pre .. "3") then
    local lbl_num = nx_custom(form, ctrl_pre .. "3")
    local num = nx_int(score % 1000 / 100)
    lbl_num.BackImage = nx_string("gui\\language\\ChineseS\\ywt\\" .. nx_string(num) .. ".png")
  end
  if nx_find_custom(form, ctrl_pre .. "4") then
    local lbl_num = nx_custom(form, ctrl_pre .. "4")
    local num = nx_int(score % 10000 / 1000)
    lbl_num.BackImage = nx_string("gui\\language\\ChineseS\\ywt\\" .. nx_string(num) .. ".png")
  end
  if nx_find_custom(form, ctrl_pre .. "5") then
    local lbl_num = nx_custom(form, ctrl_pre .. "5")
    local num = nx_int(score % 100000 / 10000)
    lbl_num.BackImage = nx_string("gui\\language\\ChineseS\\ywt\\" .. nx_string(num) .. ".png")
  end
end
function random_num(form, score)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cur_step") then
    return
  end
  if not nx_find_custom(form, "randcount1") then
    return
  end
  local ctrl_pre = ""
  if form.cur_step == MATCH_BEGIN then
    ctrl_pre = "lbl_"
  elseif form.cur_step == MATCH_END then
    ctrl_pre = "lbl_p_"
  end
  if nx_find_custom(form, ctrl_pre .. "1") then
    local lbl_num = nx_custom(form, ctrl_pre .. "1")
    local num = 0
    if form.randcount1 >= NUM_RAND_COUNT / 6 * 5 then
      num = nx_int(score % 10)
    else
      num = math.random(0, 9)
    end
    lbl_num.BackImage = nx_string("gui\\language\\ChineseS\\ywt\\" .. nx_string(num) .. ".png")
  end
  if nx_find_custom(form, ctrl_pre .. "2") then
    local lbl_num = nx_custom(form, ctrl_pre .. "2")
    local num = 0
    if form.randcount1 >= NUM_RAND_COUNT / 6 * 4 then
      num = nx_int(score % 100 / 10)
    else
      num = math.random(0, 9)
    end
    lbl_num.BackImage = nx_string("gui\\language\\ChineseS\\ywt\\" .. nx_string(num) .. ".png")
  end
  if nx_find_custom(form, ctrl_pre .. "3") then
    local lbl_num = nx_custom(form, ctrl_pre .. "3")
    local num = 0
    if form.randcount1 >= NUM_RAND_COUNT / 6 * 3 then
      num = nx_int(score % 1000 / 100)
    else
      num = math.random(0, 9)
    end
    lbl_num.BackImage = nx_string("gui\\language\\ChineseS\\ywt\\" .. nx_string(num) .. ".png")
  end
  if nx_find_custom(form, ctrl_pre .. "4") then
    local lbl_num = nx_custom(form, ctrl_pre .. "4")
    local num = 0
    if form.randcount1 >= NUM_RAND_COUNT / 6 * 2 then
      num = nx_int(score % 10000 / 1000)
    else
      num = math.random(0, 9)
    end
    lbl_num.BackImage = nx_string("gui\\language\\ChineseS\\ywt\\" .. nx_string(num) .. ".png")
  end
  if nx_find_custom(form, ctrl_pre .. "5") then
    local lbl_num = nx_custom(form, ctrl_pre .. "5")
    local num = 0
    if form.randcount1 >= NUM_RAND_COUNT / 6 then
      num = nx_int(score % 100000 / 10000)
    else
      num = math.random(0, 9)
    end
    lbl_num.BackImage = nx_string("gui\\language\\ChineseS\\ywt\\" .. nx_string(num) .. ".png")
  end
  form.randcount1 = form.randcount1 + 1
end
function random_num_boss(form, score)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cur_step") then
    return
  end
  if not nx_find_custom(form, "randcount2") then
    return
  end
  local ctrl_pre = "lbl_b_"
  if nx_find_custom(form, ctrl_pre .. "1") then
    local lbl_num = nx_custom(form, ctrl_pre .. "1")
    local num = 0
    if form.randcount2 >= NUM_RAND_COUNT / 6 * 5 then
      num = nx_int(score % 10)
    else
      num = math.random(0, 9)
    end
    lbl_num.BackImage = nx_string("gui\\language\\ChineseS\\ywt\\" .. nx_string(num) .. ".png")
  end
  if nx_find_custom(form, ctrl_pre .. "2") then
    local lbl_num = nx_custom(form, ctrl_pre .. "2")
    local num = 0
    if form.randcount2 >= NUM_RAND_COUNT / 6 * 4 then
      num = nx_int(score % 100 / 10)
    else
      num = math.random(0, 9)
    end
    lbl_num.BackImage = nx_string("gui\\language\\ChineseS\\ywt\\" .. nx_string(num) .. ".png")
  end
  if nx_find_custom(form, ctrl_pre .. "3") then
    local lbl_num = nx_custom(form, ctrl_pre .. "3")
    local num = 0
    if form.randcount2 >= NUM_RAND_COUNT / 6 * 3 then
      num = nx_int(score % 1000 / 100)
    else
      num = math.random(0, 9)
    end
    lbl_num.BackImage = nx_string("gui\\language\\ChineseS\\ywt\\" .. nx_string(num) .. ".png")
  end
  if nx_find_custom(form, ctrl_pre .. "4") then
    local lbl_num = nx_custom(form, ctrl_pre .. "4")
    local num = 0
    if form.randcount2 >= NUM_RAND_COUNT / 6 * 2 then
      num = nx_int(score % 10000 / 1000)
    else
      num = math.random(0, 9)
    end
    lbl_num.BackImage = nx_string("gui\\language\\ChineseS\\ywt\\" .. nx_string(num) .. ".png")
  end
  if nx_find_custom(form, ctrl_pre .. "5") then
    local lbl_num = nx_custom(form, ctrl_pre .. "5")
    local num = 0
    if form.randcount2 >= NUM_RAND_COUNT / 6 then
      num = nx_int(score % 100000 / 10000)
    else
      num = math.random(0, 9)
    end
    lbl_num.BackImage = nx_string("gui\\language\\ChineseS\\ywt\\" .. nx_string(num) .. ".png")
  end
  form.randcount2 = form.randcount2 + 1
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_shijia\\form_shijia_yanwu")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = gui.Width / 2 - form.Width / 2
  form.AbsTop = gui.Height - form.Height - gui.Height / 7
end
function count_down(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cur_count") then
    return
  end
  local time = 0
  if form.cur_count < COUNT_DOWN then
    time = COUNT_DOWN - form.cur_count
  end
  form.lbl_time.Text = nx_widestr(time)
  if form.cur_count > COUNT_DOWN then
    clear_timer(form)
    nx_destroy(form)
  end
  if nx_is_valid(form) then
    form.cur_count = form.cur_count + 1
  end
end
function on_btn_match_click(btn)
  if not nx_is_valid(btn.ParentForm) then
    return
  end
  local form = btn.ParentForm
  if not nx_find_custom(form, "cur_step") then
    return
  end
  if form.cur_step ~= MATCH_BEGIN then
    return
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SHIJIA_YANWU), nx_int(YANWU_MATCH))
  end
end
function clear_timer(form)
end
function show_result(form, result)
  if not nx_is_valid(form) then
    return
  end
  local photo
  if result == 1 then
    photo = nx_string("gui\\language\\ChineseS\\ywt\\win.png")
  else
    photo = nx_string("gui\\language\\ChineseS\\ywt\\lose.png")
  end
  form.lbl_result.BackImage = photo
  form.lbl_result.Visible = true
  form.lbl_result.ScaleX = RESULT_SCALE
  form.lbl_result.ScaleY = RESULT_SCALE
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "scale_result", form)
  timer:Register(50, -1, nx_current(), "scale_result", form, -1, -1)
end
function scale_result(form)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_result.ScaleX = form.lbl_result.ScaleX - 0.2
  form.lbl_result.ScaleY = form.lbl_result.ScaleY - 0.2
  if form.lbl_result.ScaleX <= 1 or form.lbl_result.ScaleY <= 1 then
    form.lbl_result.ScaleX = 1
    form.lbl_result.ScaleY = 1
    local timer = nx_value("timer_game")
    timer:UnRegister(nx_current(), "scale_result", form)
    local timer = nx_value("timer_game")
    timer:UnRegister(nx_current(), "delay_close", form)
    timer:Register(DELAY_CLOSE, 1, nx_current(), "delay_close", form, -1, -1)
  end
end
function delay_close(form)
  if not nx_is_valid(form) then
    return
  end
  on_main_form_close(form)
end
function show_hyper_link_iteminfo(item_info, uniqueid)
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  local xmldoc = nx_create("XmlDocument")
  if not xmldoc:ParseXmlData(item_info, 1) then
    nx_destroy(xmldoc)
    return
  end
  local xmlroot = xmldoc.RootElement
  local array_data = nx_call("util_gui", "get_arraylist", "form_shijia_yanwu:show_hyper_link_iteminfo")
  array_data:ClearChild()
  local xmlelement = xmlroot:GetChildByIndex(0)
  if not nx_is_valid(xmlelement) then
    nx_destroy(xmldoc)
    return
  end
  for i = 0, xmlelement:GetAttrCount() - 1 do
    local name = xmlelement:GetAttrName(i)
    local value = xmlelement:GetAttrValue(i)
    nx_set_custom(array_data, name, value)
  end
  local xml_element_record = xmlroot:GetChildByIndex(1)
  if nx_is_valid(xml_element_record) then
    local record_num = xml_element_record:GetChildCount()
    local str_record_group = ""
    for i = 0, record_num - 1 do
      local child = xml_element_record:GetChildByIndex(i)
      local record_name = child:QueryAttr("name")
      local record_rows = child:QueryAttr("rows")
      local sz_child_info = nx_string(record_name) .. "," .. nx_string(record_rows)
      local record_prop_num = 0
      for index = 0, record_rows - 1 do
        local child_child = child:GetChildByIndex(index)
        record_prop_num = nx_int(record_prop_num) + (nx_int(child_child:GetAttrCount()) - 1)
      end
      sz_child_info = nx_string(sz_child_info) .. "," .. nx_string(record_prop_num / record_rows)
      for index = 0, record_rows - 1 do
        local child_child = child:GetChildByIndex(index)
        local record_prop_num = child_child:GetAttrCount()
        for record_index = 1, record_prop_num - 1 do
          local prop_name = child_child:GetAttrName(record_index)
          local prop_value = child_child:GetAttrValue(record_index)
          sz_child_info = nx_string(sz_child_info) .. "," .. nx_string(prop_value)
        end
      end
      if str_record_group == "" then
        str_record_group = nx_string(sz_child_info)
      else
        str_record_group = nx_string(str_record_group) .. "," .. nx_string(sz_child_info)
      end
    end
    if nx_int(record_num) > nx_int(0) then
      array_data.item_rec_data_info = str_record_group
    end
  end
  array_data.is_chat_link = true
  show_link_weapon_tips(array_data, form.imagegrid_icon.AbsLeft + form.imagegrid_icon.Width, form.imagegrid_icon:GetMouseInItemTop(), 32, 32, form, uniqueid)
  nx_destroy(array_data)
  nx_destroy(xmldoc)
end
function show_link_weapon_tips(item, x, y, width, height, owner, uniqueid)
  if not nx_is_valid(item) then
    return
  end
  if owner == nil or nx_string(owner) == "" then
    owner = "0-0"
  end
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    local item_id = nx_execute("tips_data", "get_prop_in_item", item, "ConfigID")
    local item_type = nx_execute("tips_func_equip", "get_item_type", item)
    tips_manager:ShowLinkTips(item_id, item, nx_int(item_type), x, y, owner, false, uniqueid)
  end
end
