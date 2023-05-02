require("util_gui")
require("role_composite")
require("util_functions")
require("share\\view_define")
require("share\\client_custom_define")
local FORM_NAME = "form_stage_main\\form_card\\form_collect_card"
local image_path = "gui\\language\\ChineseS\\card\\"
local max_info_count = 13
local CARD_INFO_MAIN_TYPE = 2
local CARD_INFO_SUB_TYPE = 3
local CARD_INFO_ITEM_TYPE = 4
local CARD_INFO_LEVEL = 5
local CARD_INFO_CONFIG_ID = 8
local CLIENT_CUSTOMMSG_CARD_COLLECT = 7
local CLIENT_CUSTOMMSG_CARD_GETAWARD = 8
local CARD_IS_COLLECTED = "gui\\language\\ChineseS\\card_collect\\yishouji.png"
local CARD_NO_COLLECTED = "gui\\language\\ChineseS\\card_collect\\weishouji.png"
local COLLECT_INI = "share\\Rule\\card_collect.ini"
function open_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return false
  end
  form:Show()
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Desktop.Width - form.Width) / 2
  form.Top = (gui.Desktop.Height - form.Height) / 2
  form.current_page = nx_int(1)
  form.select_page = nx_string("")
  form.total_count = 0
  form.first_card_id = ""
  create_collect_radiobutton(form)
  form.btn_card_get.Enabled = false
  form.ani_get.Visible = false
end
function on_main_form_init(self)
  form.Fixed = false
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function create_collect_radiobutton(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.groupbox_card_btb:DeleteAll()
  local ini = get_ini(COLLECT_INI, true)
  if not nx_is_valid(ini) then
    return
  end
  local section_count = ini:GetSectionCount()
  if section_count <= 0 then
    return
  end
  form.first_card_id = nx_string(ini:GetSectionByIndex(0))
  local section_name = ""
  for i = 0, section_count - 1 do
    section_name = ini:GetSectionByIndex(i)
    local rbtn = gui:Create("RadioButton")
    if nx_is_valid(rbtn) then
      rbtn.Name = "rbtn_" .. nx_string(section_name)
      rbtn.config = section_name
      rbtn.NormalImage = "gui\\language\\ChineseS\\card_collect\\b_but_out.png"
      rbtn.FocusImage = "gui\\language\\ChineseS\\card_collect\\b_but_on.png"
      rbtn.CheckedImage = "gui\\language\\ChineseS\\card_collect\\b_but_down.png"
      rbtn.ForeColor = "255,37,16,15"
      rbtn.Height = 38
      rbtn.Width = 180
      rbtn.Left = 0
      rbtn.Top = 40 * i
      rbtn.Font = "font_task_name"
      rbtn.InSound = "MouseOn1"
      rbtn.ClickSound = "MouseClick1"
      rbtn.Text = nx_widestr(gui.TextManager:GetText(section_name))
      nx_bind_script(rbtn, nx_current())
      nx_callback(rbtn, "on_checked_changed", "on_rbtn_checked_changed")
      form.groupbox_card_btb:Add(rbtn)
    end
  end
  local first_rbtn = form.groupbox_card_btb:Find("rbtn_" .. nx_string(form.first_card_id))
  if nx_is_valid(first_rbtn) then
    first_rbtn.Checked = true
  else
    show_total_collect_need(form.first_card_id)
  end
end
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local str_type = rbtn.config
  if rbtn.Checked then
    form.current_page = 1
    show_total_collect_need(str_type)
  end
end
function show_total_collect_need(str_type)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return false
  end
  local pack = {}
  local item_count = 0
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.groupbox_collect:DeleteAll()
  form.select_page = nx_string(str_type)
  if nx_string(str_type) == "" then
    return
  end
  pack, item_count = get_config_list(nx_string(str_type))
  for i = 1 + 6 * (form.current_page - 1), 6 * form.current_page do
    if pack[i] ~= nil then
      page_index = i - 6 * (form.current_page - 1)
      local control = copy_control(form, form.groupbox_clt_card, page_index, pack[i])
      if nx_is_valid(control) then
        form.groupbox_collect:Add(control)
      end
    end
  end
  local total_page_count = math.floor((table.getn(pack) - 1) / 6) + 1
  if nx_int(total_page_count) == nx_int(0) then
    form.current_page = "0"
  end
  local cur_page = nx_int(form.current_page)
  if nx_int(cur_page) <= nx_int(0) and nx_int(table.getn(pack)) > nx_int(0) then
    cur_page = 1
  end
  local page_text = nx_string(nx_string(cur_page) .. "/" .. nx_string(total_page_count))
  form.lbl_page.Text = nx_widestr(page_text)
  check_is_get_allcard(form, str_type)
  form.lbl_collect_info.Text = gui.TextManager:GetFormatText("ui_card_collect_get", nx_int(form.total_count), nx_int(item_count))
  show_reward_card(form, str_type)
end
function get_config_list(str_type)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local CollectCardManager = nx_value("CollectCardManager")
  if not nx_is_valid(CollectCardManager) then
    return
  end
  local pack = {}
  local ini = nx_execute("util_functions", "get_ini", COLLECT_INI)
  if not nx_is_valid(ini) then
    return
  end
  if not ini:FindSection(str_type) then
    return
  end
  local section_index = ini:FindSectionIndex(str_type)
  if section_index < 0 then
    return
  end
  local item_count = ini:GetSectionItemCount(section_index)
  for i = 0, item_count - 1 do
    local item = ini:GetSectionItemValue(section_index, i)
    local tmp_lst = util_split_string(item, ",")
    local max_count = table.getn(tmp_lst)
    if max_count == 1 then
      table.insert(pack, tmp_lst[1])
    elseif 1 < max_count then
      local b_show = false
      for i = 1, max_count do
        if tmp_lst[i] ~= nil and CollectCardManager:IsGetCard(nx_int(tmp_lst[i])) then
          table.insert(pack, tmp_lst[i])
          b_show = true
        end
      end
      if not b_show then
        table.insert(pack, tmp_lst[1])
      end
    end
  end
  return pack, item_count
end
function show_request_reason(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if table.getn(arg) < 2 then
    return
  end
  local is_show = arg[2]
  if is_show == 0 then
    form.btn_card_get.Enabled = false
    form.btn_card_get.Text = nx_widestr(util_text("ui_card_collect_btn_get"))
    form.ani_get.Visible = false
  elseif is_show == 1 then
    form.btn_card_get.Enabled = true
    form.btn_card_get.Text = nx_widestr(util_text("ui_card_collect_btn_get"))
    form.ani_get.Visible = true
    form.ani_get:Play()
  elseif is_show == 2 then
    form.btn_card_get.Enabled = false
    form.btn_card_get.Text = nx_widestr(util_text("ui_yilingqu"))
    form.ani_get.Visible = false
  elseif is_show == 3 then
    form.btn_card_get.Enabled = false
    form.btn_card_get.Text = nx_widestr(util_text("ui_card_collect_close"))
    form.ani_get.Visible = false
  end
end
function show_reward_card(form, str_type)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return false
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local card_id = nx_int(ItemQuery:GetItemPropByConfigID(str_type, "CardID"))
  local reward_card_info = {}
  reward_card_info = collect_card_manager:GetCardInfo(card_id)
  if table.getn(reward_card_info) < max_info_count then
    return
  end
  local item_type = reward_card_info[CARD_INFO_ITEM_TYPE]
  local level = reward_card_info[CARD_INFO_LEVEL]
  local main_type = reward_card_info[CARD_INFO_MAIN_TYPE]
  local sub_type = reward_card_info[CARD_INFO_SUB_TYPE]
  local grid = form.imagegrid_get
  grid:Clear()
  local photo = nx_resource_path() .. image_path .. nx_string(card_id) .. ".png"
  grid:AddItem(0, photo, util_text(str_type), 1, -1)
  grid.photo = photo
  grid.config = str_type
  grid.item_type = item_type
  nx_bind_script(grid, nx_current())
  local mltbox_1 = form.mltbox_1
  mltbox_1:Clear()
  local str_name = gui.TextManager:GetFormatText(str_type)
  form.lbl_main_title.Text = nx_widestr(util_text(nx_string(str_name)))
  local mltbox_1 = form.mltbox_1
  mltbox_1:Clear()
  local color_level = nx_widestr(gui.TextManager:GetText("ui_card_level_" .. nx_string(level)))
  mltbox_1.HtmlText = gui.TextManager:GetFormatText("ui_card_collect_mlt_" .. nx_string(level), nx_string(color_level))
  local mltbox_2 = form.mltbox_2
  mltbox_2:Clear()
  local type_name = gui.TextManager:GetFormatText("ui_card_" .. nx_string(main_type) .. "_" .. nx_string(sub_type))
  mltbox_2.HtmlText = gui.TextManager:GetFormatText("ui_card_collect_mlt04", nx_string(type_name))
  local mltbox_3 = form.mltbox_3
  mltbox_3:Clear()
  local desc = gui.TextManager:GetFormatText("ui_" .. nx_string(str_type))
  mltbox_3.HtmlText = nx_widestr(desc)
end
function copy_control(form, btn_info, index, card_id)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return false
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return false
  end
  if not nx_is_valid(btn_info) then
    return false
  end
  local control = gui.Designer:Clone(btn_info)
  if not nx_is_valid(control) then
    return false
  end
  control.DesignMode = false
  local child_list = btn_info:GetChildControlList()
  if table.getn(child_list) == nx_int(0) then
    return false
  end
  local card_info = {}
  card_info = collect_card_manager:GetCardInfo(nx_int(card_id))
  if table.getn(card_info) < max_info_count then
    return
  end
  local item_type = card_info[CARD_INFO_ITEM_TYPE]
  local level = card_info[CARD_INFO_LEVEL]
  local main_type = card_info[CARD_INFO_MAIN_TYPE]
  local sub_type = card_info[CARD_INFO_SUB_TYPE]
  local config = "card_item_10" .. nx_string(card_id)
  for _, copy_child in pairs(child_list) do
    if not nx_is_valid(copy_child) then
      return false
    end
    local child = gui.Designer:Clone(copy_child)
    child.DesignMode = false
    if nx_string(child.Name) == "imagegrid_cards" then
      child.Name = "imagegrid_cards_" .. nx_string(index)
      local photo = nx_resource_path() .. image_path .. nx_string(card_id) .. ".png"
      child:AddItem(0, photo, util_text(config), 1, -1)
      child.photo = photo
      child.config = config
      child.item_type = item_type
      nx_bind_script(child, nx_current())
      nx_callback(child, "on_select_changed", "on_main_shortcut_lmouse_click")
    elseif nx_string(child.Name) == "lbl_name" then
      child.Name = "lbl_name_" .. nx_string(index)
      szMountName = gui.TextManager:GetFormatText(config)
      child.Text = util_text(nx_string(szMountName))
    elseif nx_string(child.Name) == "mltbox_clt_color" then
      child.Name = "mltbox_clt_color_" .. nx_string(index)
      local desc = nx_widestr(gui.TextManager:GetText("ui_card_level_" .. nx_string(level)))
      child.HtmlText = gui.TextManager:GetFormatText("ui_card_collect_mlt_" .. nx_string(level), nx_string(desc))
    elseif nx_string(child.Name) == "mltbox_clt_type" then
      child.Name = "mltbox_clt_type_" .. nx_string(index)
      local type_name = gui.TextManager:GetFormatText("ui_card_" .. nx_string(main_type) .. "_" .. nx_string(sub_type))
      child.HtmlText = gui.TextManager:GetFormatText("ui_card_collect_mlt04", nx_string(type_name))
    elseif nx_string(child.Name) == "lbl_collect" then
      child.Name = "lbl_collect_" .. nx_string(index)
      local is_get = collect_card_manager:IsGetCard(nx_int(card_id))
      if is_get then
        child.BackImage = CARD_IS_COLLECTED
      else
        child.BackImage = CARD_NO_COLLECTED
      end
    end
    control:Add(child)
  end
  control.Name = "groupbox_clt_card_" .. nx_string(index)
  control.Left = math.floor((index - 1) % 3) * control.Width
  control.Top = math.floor((index - 1) / 3) * (control.Height + 2) + 5
  return control
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local pack = {}
  pack = get_config_list(form.select_page)
  local cur_page = form.current_page
  local max_page = math.floor((table.getn(pack) - 1) / 6) + 1
  if nx_number(cur_page) < nx_number(max_page) then
    cur_page = cur_page + 1
    form.groupbox_collect:DeleteAll()
    for i = 1 + 6 * (cur_page - 1), 6 * cur_page do
      if pack[i] ~= "" and pack[i] ~= nil then
        index = i - 6 * (cur_page - 1)
        local control = copy_control(form, form.groupbox_clt_card, index, pack[i])
        if nx_is_valid(control) then
          form.groupbox_collect:Add(control)
        end
      end
    end
    form.current_page = cur_page
    local page_text = nx_string(cur_page .. "/" .. max_page)
    form.lbl_page.Text = nx_widestr(page_text)
  end
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local pack = {}
  pack = get_config_list(form.select_page)
  local cur_page = form.current_page
  local max_page = math.floor((table.getn(pack) - 1) / 6) + 1
  if 1 < nx_number(cur_page) then
    cur_page = nx_int(cur_page) - 1
    form.groupbox_collect:DeleteAll()
    for i = 1 + 6 * (cur_page - 1), 6 * cur_page do
      if pack[i] ~= "" and pack[i] ~= nil then
        index = i - 6 * (cur_page - 1)
        local control = copy_control(form, form.groupbox_clt_card, index, pack[i])
        if nx_is_valid(control) then
          form.groupbox_collect:Add(control)
        end
      end
    end
    form.current_page = cur_page
    local page_text = nx_string(cur_page .. "/" .. max_page)
    form.lbl_page.Text = nx_widestr(page_text)
  end
end
function img_grid_mouseout_grid(grid)
  nx_execute("tips_game", "hide_tip")
end
function img_grid_mousein_grid(grid)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local config_id = grid.config
  if nx_string(config_id) == nx_string("") then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", config_id, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function check_is_get_allcard(form, str_type)
  if not nx_is_valid(form) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local card_id = nx_int(ItemQuery:GetItemPropByConfigID(str_type, "CardID"))
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", COLLECT_INI)
  if not nx_is_valid(ini) then
    return
  end
  if not ini:FindSection(str_type) then
    return
  end
  local section_index = ini:FindSectionIndex(str_type)
  if section_index < 0 then
    return
  end
  local count = 0
  local item_count = ini:GetSectionItemCount(section_index)
  for i = 0, item_count - 1 do
    local card_list = ini:GetSectionItemValue(section_index, i)
    local tmp_lst = util_split_string(card_list, ",")
    local max_count = table.getn(tmp_lst)
    local b_collect = false
    for j = 1, max_count do
      if tmp_lst[j] ~= nil and collect_card_manager:IsGetCard(nx_int(tmp_lst[j])) and not b_collect then
        count = count + 1
        b_collect = true
      end
    end
  end
  form.total_count = count
  if nx_int(count) == nx_int(item_count) then
    form.btn_card_get.Enabled = true
  else
    form.btn_card_get.Enabled = false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CARD), nx_int(CLIENT_CUSTOMMSG_CARD_COLLECT), nx_int(card_id))
end
function on_btn_card_get_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local str_type = form.select_page
  local card_id = nx_int(ItemQuery:GetItemPropByConfigID(str_type, "CardID"))
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CARD), nx_int(CLIENT_CUSTOMMSG_CARD_GETAWARD), nx_int(card_id))
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
