require("utils")
require("util_functions")
require("share\\capital_define")
require("share\\view_define")
local FORM_DBOMALL = "form_stage_main\\form_dbomall\\form_dbortreasure"
local FORM_SUB = "form_stage_main\\form_dbomall\\form_dbortreasure_exchange"
local INI_FILE = "share\\Item\\royal_treasure_map.ini"
local COUNT_LIMIT_INI_FILE = "share\\Rule\\count_limit.ini"
local CLIENT_SUB_MSG_EXCHANGE = 4
local CLIENT_SUB_MSG_ACCEPT_TASK = 5
local grid_group_w = 163
local grid_group_h = 138
function main_form_init(form)
  local IniManager = nx_value("IniManager")
  if not IniManager:IsIniLoadedToManager(INI_FILE) then
    IniManager:LoadIniToManager(INI_FILE)
  end
  if not IniManager:IsIniLoadedToManager(COUNT_LIMIT_INI_FILE) then
    IniManager:LoadIniToManager(COUNT_LIMIT_INI_FILE)
  end
  form.Fixed = true
end
function on_main_form_open(form)
  show_item_info(form)
  bind_table(form)
end
function on_main_form_close(form)
  unbind_table(form)
  nx_destroy(form)
end
function on_btn_get_task_click(btn)
  send_server_msg(nx_int(CLIENT_SUB_MSG_ACCEPT_TASK))
end
function send_server_msg(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(236), unpack(arg))
end
function show_item_info(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_FILE)
  if ini == nil then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string("exchange"))
  if sec_index < 0 then
    return
  end
  local item_count = ini:GetSectionItemCount(sec_index)
  form.gsbox_exchange.IsEditMode = true
  form.gsbox_exchange:DeleteAll()
  local items = util_split_string(text, ",")
  local index = 1
  local row = 0
  local cols = 2
  local remainder = item_count % cols
  local added = 0
  if 0 < remainder then
    added = 1
  end
  local groupbox
  for i = 1, nx_int(item_count / cols) + added do
    for sub_i = 1, cols do
      if sub_i == 1 then
        groupbox = gui:Create("GroupBox")
        groupbox.BackColor = "0,0,0,0"
        groupbox.NoFrame = true
        groupbox.Width = grid_group_w * cols
        groupbox.Height = grid_group_h
      end
      local gbox_item = create_item_view(form, gui, i, sub_i, ini, sec_index, (i - 1) * cols + sub_i)
      if gbox_item ~= nil then
        gbox_item.Top = 0
        gbox_item.Left = (sub_i - 1) * grid_group_w
        groupbox:Add(gbox_item)
        nx_set_custom(form, nx_string(gbox_item.Name), gbox_item)
      end
    end
    form.gsbox_exchange:Add(groupbox)
  end
  form.gsbox_exchange.IsEditMode = false
  form.gsbox_exchange:ResetChildrenYPos()
end
function get_item_info_by_index(ini, index)
  local sec_index = ini:FindSectionIndex(nx_string("item_pack"))
  if sec_index < 0 then
    return nil, nil
  end
  local var = ini:ReadString(sec_index, nx_string(index), "")
  if var == "" then
    return nil, nil
  end
  local var_array = util_split_string(var, ":")
  if table.getn(var_array) < 2 then
    return nil, nil
  end
  return var_array[1], var_array[2]
end
function create_item_view(form, gui, row, col, ini, section_index, item_index)
  item_index = item_index - 1
  local key = ini:GetSectionItemKey(section_index, item_index)
  local var = ini:GetSectionItemValue(section_index, item_index)
  local var_array = util_split_string(var, ";")
  if 1 > table.getn(var_array) then
    return
  end
  var_array = util_split_string(var_array[1], ",")
  if table.getn(var_array) < 2 then
    return
  end
  local exchange_id, exchange_count = get_item_info_by_index(ini, var_array[2])
  local desc_tips_id, need_tips_id = get_tips_desc_by_index(item_index - 1)
  local need_item_desc = nx_widestr("")
  if need_tips_id ~= nil then
    need_item_desc = nx_widestr(gui.TextManager:GetFormatText(need_tips_id))
  end
  local groupbox = gui:Create("GroupBox")
  groupbox.BackColor = "0,0,0,0"
  groupbox.NoFrame = true
  groupbox.Width = grid_group_w
  groupbox.Height = grid_group_h
  groupbox.Name = "gbox_item" .. nx_string(row) .. "_" .. nx_string(col)
  local button = gui:Create("Button")
  button.Name = "btn_item_" .. nx_string(key)
  button.ForeColor = "255,255,255,255"
  button.DataSource = exchange_id
  button.SectionName = key
  button.DrawMode = "FitWindow"
  button.Width = grid_group_w
  button.Height = grid_group_h
  button.NormalImage = nx_string("gui\\special\\dbomall\\daoju_bg_out.png")
  button.FocusImage = nx_string("gui\\special\\dbomall\\daoju_bg_on.png")
  button.PushImage = nx_string("gui\\special\\dbomall\\daoju_bg_down.png")
  button.Visible = true
  button.item_desc = need_item_desc
  nx_bind_script(button, nx_current())
  nx_callback(button, "on_click", "on_btn_exitem_click")
  groupbox:Add(button)
  local imagegrid = gui:Create("ImageControlGrid")
  imagegrid.AutoSize = false
  imagegrid.Name = "img_grid_" .. nx_string(row) .. "_" .. nx_string(col)
  imagegrid.DrawMode = "FitWindow"
  imagegrid.NoFrame = true
  imagegrid.HasVScroll = false
  imagegrid.Width = 60
  imagegrid.Height = 60
  imagegrid.Left = 50
  imagegrid.Top = 10
  imagegrid.RowNum = 1
  imagegrid.ClomnNum = 1
  imagegrid.GridBackOffsetX = -1
  imagegrid.GridBackOffsetY = -1
  imagegrid.GridWidth = 57
  imagegrid.GridHeight = 57
  imagegrid.GridsPos = "5,3"
  imagegrid.RoundGrid = false
  imagegrid.BackColor = "0,0,0,0"
  imagegrid.SelectColor = "0,0,0,0"
  imagegrid.MouseInColor = "0,0,0,0"
  imagegrid.CoverColor = "0,0,0,0"
  imagegrid.MouseDownAlpha = 255
  imagegrid.MouseDownScale = 1
  imagegrid.MouseDownOffsetX = 0
  imagegrid.MouseDownOffsetY = 0
  imagegrid.DataSource = exchange_id
  imagegrid.SectionName = key
  imagegrid.item_desc = need_item_desc
  local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", exchange_id, "Photo")
  imagegrid:AddItem(0, nx_string(photo), nx_widestr(exchange_id), nx_int(exchange_count), 0)
  nx_bind_script(imagegrid, nx_current())
  nx_callback(imagegrid, "on_mousein_grid", "on_exchange_imagegrid_mousein_grid")
  nx_callback(imagegrid, "on_mouseout_grid", "on_exchange_imagegrid_mouseout_grid")
  nx_callback(imagegrid, "on_select_changed", "on_grid_select_changed")
  groupbox:Add(imagegrid)
  local mltbox = gui:Create("MultiTextBox")
  mltbox.Name = "mlt_exitem_name_" .. nx_string(row) .. "_" .. nx_string(col)
  mltbox.Transparent = true
  mltbox.NoFrame = true
  mltbox.Font = "font_sns_list"
  local name = nx_widestr("<font color=\"#ffffff\" >") .. nx_widestr(gui.TextManager:GetText(exchange_id)) .. nx_widestr("</font>")
  mltbox:AddHtmlText(name, -1)
  local height = mltbox:GetContentHeight()
  local width = mltbox:GetContentWidth()
  local left = 0
  if width <= groupbox.Width then
    left = groupbox.Width / 2 - width / 2
  end
  mltbox.Height = height
  mltbox.Width = width
  mltbox.Left = left
  mltbox.Top = 80
  mltbox.ViewRect = "0,0," .. nx_string(mltbox.Width) .. "," .. nx_string(mltbox.Height)
  groupbox:Add(mltbox)
  local mltbox_need = gui:Create("MultiTextBox")
  mltbox_need.Name = "mlt_exitem_need_" .. nx_string(item_sec)
  mltbox_need.Transparent = true
  mltbox_need.NoFrame = true
  mltbox_need.Font = "font_sns_list"
  mltbox_need.item_desc = need_item_desc
  mltbox_need.HAlign = "Center"
  mltbox_need.VAlign = "Center"
  mltbox_need.Height = 30
  mltbox_need.Width = groupbox.Width
  mltbox_need.Left = 0
  mltbox_need.Top = mltbox.Top + mltbox.Height + 2
  mltbox_need.ViewRect = "0,0," .. nx_string(mltbox_need.Width) .. "," .. nx_string(mltbox_need.Height)
  local name = nx_widestr("<font color=\"#ffcc00\" >") .. need_item_desc .. nx_widestr("</font>")
  mltbox_need:AddHtmlText(name, -1)
  local width = mltbox_need:GetContentWidth()
  local left = 0
  if width <= groupbox.Width then
    left = groupbox.Width / 2 - width / 2
  end
  mltbox_need.Left = left
  groupbox:Add(mltbox_need)
  nx_set_custom(form, nx_string(mltbox_need.Name), mltbox_need)
  if table.getn(var_array) > 2 then
    local count_limit = var_array[3]
    local mltbox_limit = gui:Create("MultiTextBox")
    local limit_name = "mlt_exitem_limit_" .. nx_string(count_limit)
    mltbox_limit.Name = limit_name
    mltbox_limit.Transparent = true
    mltbox_limit.NoFrame = true
    mltbox_limit.Font = "font_sns_list"
    mltbox_limit.DataSource = groupbox.Name
    local ltype, lcount = get_limit_info_by_limit_count(count_limit)
    local tips = ""
    if ltype == 1 then
      tips = "tips_rtm_110"
    elseif ltype == 2 then
      tips = "tips_rtm_111"
    elseif ltype == 3 then
      tips = "tips_rtm_112"
    end
    local text = gui.TextManager:GetFormatText(tips, nx_int(0), nx_int(lcount))
    text = nx_widestr("<font color=\"#9c9c9c\" >") .. text .. nx_widestr("</font>")
    mltbox_limit:Clear()
    mltbox_limit:AddHtmlText(text, -1)
    local height = mltbox_limit:GetContentHeight()
    local width = mltbox_limit:GetContentWidth()
    local left = 0
    if width <= groupbox.Width then
      left = groupbox.Width / 2 - width / 2
    end
    mltbox_limit.Height = height
    mltbox_limit.Width = width
    mltbox_limit.Left = left
    mltbox_limit.Top = groupbox.Height - 25
    mltbox_limit.ViewRect = "0,0," .. nx_string(mltbox_limit.Width) .. "," .. nx_string(mltbox_limit.Height)
    groupbox:Add(mltbox_limit)
    nx_set_custom(form, nx_string(limit_name), mltbox_limit)
  end
  return groupbox
end
function bind_table(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("count_limit_rec", form, FORM_DBOMALL, "on_count_limit_rec_change")
    databinder:AddViewBind(VIEWPORT_TOOL, form, FORM_DBOMALL, "on_view_operat")
    databinder:AddViewBind(VIEWPORT_TASK_TOOL, form, FORM_DBOMALL, "on_view_operat")
  end
end
function get_limit_info_by_limit_count(id)
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(COUNT_LIMIT_INI_FILE)
  if ini == nil then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(id))
  if sec_index < 0 then
    return
  end
  local t = ini:ReadInteger(sec_index, "limit_type", 0)
  local c = ini:ReadInteger(sec_index, "max_count", 0)
  return t, c
end
function on_count_limit_rec_change(self, recordname, optype, row, col)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if nx_string("count_limit_rec") ~= nx_string(recordname) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local rows = client_player:GetRecordRows("count_limit_rec")
  for i = 1, nx_number(rows) do
    local id = client_player:QueryRecord("count_limit_rec", i - 1, 0)
    local ctrl_name = "mlt_exitem_limit_" .. nx_string(id)
    if nx_find_custom(self, ctrl_name) then
      local ctrl = nx_custom(self, ctrl_name)
      local pctrl = nx_custom(self, ctrl.DataSource)
      local ltype, lcount = get_limit_info_by_limit_count(id)
      if ltype <= 0 or lcount <= 0 then
        return
      end
      local cur_count = client_player:QueryRecord("count_limit_rec", i - 1, 1)
      local tips = ""
      if ltype == 1 then
        tips = "tips_rtm_110"
      elseif ltype == 2 then
        tips = "tips_rtm_111"
      elseif ltype == 3 then
        tips = "tips_rtm_112"
      end
      local text = gui.TextManager:GetFormatText(tips, nx_int(cur_count), nx_int(lcount))
      text = nx_widestr("<font color=\"#9c9c9c\" >") .. text .. nx_widestr("</font>")
      ctrl:Clear()
      ctrl:AddHtmlText(text, -1)
      local height = ctrl:GetContentHeight()
      local width = ctrl:GetContentWidth()
      local left = 0
      if width <= pctrl.Width then
        left = pctrl.Width / 2 - width / 2
      end
      ctrl.Height = height
      ctrl.Width = width
      ctrl.Left = left
      ctrl.Top = pctrl.Height - 25
      ctrl.ViewRect = "0,0," .. nx_string(ctrl.Width) .. "," .. nx_string(ctrl.Height)
    end
  end
end
function unbind_table(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("CardRec", form)
    databinder:DelViewBind(form)
  end
end
function on_exchange_imagegrid_mousein_grid(grid)
  local ConfigID = grid.DataSource
  nx_execute("tips_game", "show_tips_by_config", ConfigID, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_exchange_imagegrid_mouseout_grid(grid)
  nx_execute("tips_game", "hide_tip")
end
function on_grid_select_changed(grid)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute(FORM_SUB, "open_form")
  nx_execute(FORM_SUB, "show_exchange_item_info_rtm", grid.DataSource, grid.SectionName)
end
function on_btn_exitem_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute(FORM_SUB, "open_form")
  nx_execute(FORM_SUB, "show_exchange_item_info_rtm", btn.DataSource, btn.SectionName)
end
function on_view_operat(grid, optype, view_ident, index, prop_name)
  local form = nx_value(FORM_DBOMALL)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_FILE)
  if ini == nil then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string("show_replace_item"))
  if sec_index < 0 then
    return
  end
  local tips = ini:ReadString(sec_index, "tips_id", "")
  local items = ini:ReadString(sec_index, "show_count", "")
  local item_id = util_split_string(items, ",")
  gui.TextManager:Format_SetIDName(tips)
  for i = 1, table.getn(item_id) do
    local count = goods_grid:GetItemCount(item_id[i])
    gui.TextManager:Format_AddParam(nx_int(count))
  end
  text = gui.TextManager:Format_GetText()
  form.mltbox_capital:Clear()
  form.mltbox_capital:AddHtmlText(text, -1)
end
function get_tips_desc_by_index(index)
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_FILE)
  if ini == nil then
    return "", ""
  end
  local sec_index = ini:FindSectionIndex("exchange_desc")
  if sec_index < 0 then
    return "", ""
  end
  local var = ini:ReadString(sec_index, nx_string(index), "")
  if nx_string(var) == nx_string("") then
    return "", ""
  end
  local vars = util_split_string(vars, ",")
  return vars[1], vars[2]
end
