require("util_functions")
require("util_gui")
require("custom_handler")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_outland\\form_outland_play_achievement"
local OutLand_Ini = "ini\\form_outland\\play_achievement.ini"
local btn_list = {}
local label_list = {}
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function main_form_init(form)
  form.section_count = -1
  form.current_achieve_id = -1
  form.first_achieve_id = -1
  form.select_id = -1
  form.a_ok = false
  form.b_ok = false
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.btn_price.Enabled = false
  show_reward_info(form)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local parent_form = nx_value("form_stage_main\\form_outland\\form_outland_play")
  if not nx_is_valid(parent_form) then
    return
  end
  local groupbox_main = parent_form.groupbox_main
  if not nx_is_valid(groupbox_main) then
    return
  end
  groupbox_main.Visible = true
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function get_player()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nx_null()
  end
  return game_client:GetPlayer()
end
function on_btn_price_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OUTLAND), 1)
  form.btn_price.Enabled = false
  local current_select = form.current_achieve_id
  local btn = btn_list[current_select]
  if nx_is_valid(btn) then
    btn.NormalImage = "gui\\special\\outland\\rbtn_2_forbid.png"
    btn.FocusImage = "gui\\special\\outland\\rbtn_2_forbid.png"
    btn.PushImage = "gui\\special\\outland\\rbtn_2_forbid.png"
  end
  form.imagegrid_1:Clear()
end
function refresh_form(form)
  if not nx_is_valid(form) then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local select_id = form.select_id
  if select_id < 0 then
    return
  end
  for i = 1, form.section_count do
    local lbl = label_list[i]
    if not nx_is_valid(lbl) then
      return
    end
    if i == select_id then
      lbl.Visible = true
    else
      lbl.Visible = false
    end
  end
end
function on_server_msg(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local argnum = table.getn(arg)
  if nx_number(argnum) < nx_number(1) then
    return
  end
  local select_id = arg[1]
  if select_id < 0 then
    return
  end
  form.select_id = select_id
  refresh_form(form)
end
function show_reward_info(form)
  if not nx_is_valid(form) then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local outland_ini = nx_execute("util_functions", "get_ini", OutLand_Ini)
  if not nx_is_valid(outland_ini) then
    return
  end
  form.first_achieve_id = nx_string(outland_ini:GetSectionByIndex(0))
  local count = outland_ini:GetSectionCount()
  form.section_count = count
  form.groupscrollbox_cj:DeleteAll()
  btn_list = {}
  label_list = {}
  for i = 1, count do
    local btn = gui:Create("Button")
    if not nx_is_valid(btn) then
      return
    end
    local domain_id = outland_ini:ReadString(i - 1, "Name", "")
    local desc = outland_ini:ReadString(i - 1, "Desc", "")
    btn.Name = "btn_" .. nx_string(i)
    btn.Text = util_text(nx_string(domain_id))
    btn.NormalImage = "gui\\special\\outland\\rbtn_2_out.png"
    btn.FocusImage = "gui\\special\\outland\\rbtn_2_on.png"
    btn.PushImage = "gui\\special\\outland\\rbtn_2_down.png"
    btn.DrawMode = "FitWindow"
    btn.ForeColor = "255,255,255,255"
    btn.Font = "font_main"
    btn.Height = 57
    btn.Width = 230
    btn.Left = 0
    btn.Top = 48 * (i - 1)
    btn.count = i
    btn.desc = desc
    nx_bind_script(btn, nx_current())
    nx_callback(btn, "on_click", "on_btn_select_click")
    table.insert(btn_list, btn)
    form.groupscrollbox_cj:Add(btn)
    local lbl = gui:Create("Label")
    if not nx_is_valid(lbl) then
      return
    end
    lbl.Name = "lbl_" .. nx_string(i)
    lbl.BackImage = "neigongxuanze"
    lbl.DrawMode = "Expand"
    lbl.ForeColor = "255,255,255,255"
    lbl.Height = 62
    lbl.Width = 62
    lbl.Left = 2
    lbl.Top = 48 * (i - 1) - 2
    lbl.Visible = false
    table.insert(label_list, lbl)
    form.groupscrollbox_cj:Add(lbl)
  end
  update_selected_achieve_info(form, 1)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OUTLAND), 2, 2)
end
function on_btn_select_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  update_selected_achieve_info(form, btn.count)
  form.current_achieve_id = btn.count
end
function show_award_config(achieve_id)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local condition_mgr = nx_value("ConditionManager")
  if not nx_is_valid(condition_mgr) then
    return
  end
  local outland_ini = nx_execute("util_functions", "get_ini", OutLand_Ini)
  if not nx_is_valid(outland_ini) then
    return
  end
  local gift_id = ""
  local condition_1 = outland_ini:ReadString(achieve_id - 1, "Award_Condition", "")
  local gift_id_1 = outland_ini:ReadString(achieve_id - 1, "Award_1", "")
  local condition_2 = outland_ini:ReadString(achieve_id - 1, "Award_Condition_1", "")
  local gift_id_2 = outland_ini:ReadString(achieve_id - 1, "Award_1_1", "")
  local gift_id_3 = outland_ini:ReadString(achieve_id - 1, "Award_2", "")
  local a_ok = condition_mgr:CanSatisfyCondition(player, player, nx_int(condition_1))
  form.a_ok = a_ok
  local b_ok = condition_mgr:CanSatisfyCondition(player, player, nx_int(condition_2))
  form.b_ok = b_ok
  local rows = player:GetRecordRows("BadGuyVallyAwardRec")
  local sward_vally = 0
  for i = 1, rows do
    local vally = player:QueryRecord("BadGuyVallyAwardRec", i - 1, 0)
    if achieve_id == vally then
      sward_vally = i
    end
  end
  if 0 < sward_vally then
    local award = player:QueryRecord("BadGuyVallyAwardRec", sward_vally - 1, 1)
    if 0 < award then
      if a_ok and b_ok then
        gift_id = gift_id_3
      else
        gift_id = ""
      end
    end
  elseif a_ok and b_ok then
    gift_id = gift_id_2
  else
    gift_id = gift_id_1
  end
  return gift_id, a_ok, b_ok
end
function update_selected_achieve_info(form, achieve_id)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ItemsQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemsQuery) then
    return
  end
  local gift_id, a_ok, b_ok = show_award_config(achieve_id)
  local str_lst = util_split_string(gift_id, ",")
  local index = 0
  local photo = ""
  local grid = form.imagegrid_1
  grid:Clear()
  for i = 1, table.getn(str_lst) do
    local ConfigID = str_lst[i]
    photo = ItemsQuery:GetItemPropByConfigID(ConfigID, "Photo")
    grid:AddItem(index, photo, util_text(ConfigID), 1, -1)
    index = index + 1
    nx_bind_script(grid, nx_current())
    nx_callback(grid, "on_mousein_grid", "on_imagegrid_mousein_grid")
    nx_callback(grid, "on_mouseout_grid", "on_imagegrid_mouseout_grid")
  end
  form.mltbox_info:Clear()
  local btn = btn_list[achieve_id]
  if not nx_is_valid(btn) then
    return
  end
  local desc_text = btn.desc
  form.mltbox_info.HtmlText = nx_widestr(gui.TextManager:GetText(desc_text))
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local rows = player:GetRecordRows("BadGuyVallyAwardRec")
  local select_id = form.select_id
  local sward_vally = 0
  for i = 1, rows do
    local vally = player:QueryRecord("BadGuyVallyAwardRec", i - 1, 0)
    if select_id == vally then
      sward_vally = i
    end
  end
  local limit = player:QueryProp("BadGuyVallyAwardDayLimit")
  if 0 < limit then
    form.btn_price.Enabled = false
  elseif achieve_id == select_id then
    if 0 < sward_vally then
      local award = player:QueryRecord("BadGuyVallyAwardRec", sward_vally - 1, 1)
      if 0 < award then
        if form.a_ok and form.b_ok then
          form.btn_price.Enabled = true
        else
          form.btn_price.Enabled = false
        end
      else
        form.btn_price.Enabled = true
      end
    elseif a_ok then
      form.btn_price.Enabled = true
    else
      form.btn_price.Enabled = false
    end
  else
    form.btn_price.Enabled = false
  end
  for i = 1, rows do
    local vally = player:QueryRecord("BadGuyVallyAwardRec", i - 1, 0)
    local btn = btn_list[vally]
    if nx_is_valid(btn) then
      btn.NormalImage = "gui\\special\\outland\\rbtn_2_forbid.png"
      btn.FocusImage = "gui\\special\\outland\\rbtn_2_on.png"
      btn.PushImage = "gui\\special\\outland\\rbtn_2_down.png"
    end
  end
  refresh_form(form)
end
function on_imagegrid_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if 3 < index then
    return
  end
  local gift_id = ""
  local current_achieve_id = form.current_achieve_id
  if current_achieve_id < 1 then
    gift_id = show_award_config(form.first_achieve_id)
  else
    gift_id = show_award_config(form.current_achieve_id)
  end
  local str_lst = util_split_string(gift_id, ",")
  local ConfigID = str_lst[index + 1]
  nx_execute("tips_game", "show_tips_by_config", ConfigID, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
