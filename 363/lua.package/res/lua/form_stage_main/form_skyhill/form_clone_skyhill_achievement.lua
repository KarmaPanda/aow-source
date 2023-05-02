require("util_functions")
require("util_gui")
require("custom_sender")
local MT_Day = 4
local ea_player_height = 80
local ea_achieve_height = 230
local FORM_NAME = "form_stage_main\\form_skyhill\\form_clone_skyhill_achievement"
local index_table = {}
function main_form_init(form)
  form.Fixed = true
  form.ea_sec_count = 0
  form.matchType = MT_Day
end
function on_main_form_open(form)
  Init_TreeView(form)
  init_achieve_info(form)
end
function Init_TreeView(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ini_doc = get_ini("ini\\ui\\skyhill\\skyhill_UI.ini")
  if nx_is_null(ini_doc) then
    return false
  end
  local NodeCount = 0
  local selectNode
  local map_root = form.tree_job:CreateRootNode(nx_widestr("@match_root"))
  map_root.search_id = "match_root"
  local count_node1 = ini_doc:GetSectionCount()
  for i = 0, count_node1 - 1 do
    local name_nodeid1 = ini_doc:GetSectionByIndex(i)
    local name_node1 = nx_widestr("   ") .. gui.TextManager:GetFormatText(name_nodeid1)
    if nx_ws_equal(name_node1, nx_widestr("")) then
      return
    end
    local map_node1 = map_root:CreateNode(name_node1)
    map_node1.search_id = name_nodeid1
    set_main_node_style(map_node1)
    local count_node2 = ini_doc:GetSectionItemCount(i)
    for j = 0, count_node2 - 1 do
      local infos = ini_doc:GetSectionItemValue(i, j)
      local info_list = util_split_string(infos, nx_string(","))
      local nCount = table.getn(info_list)
      if nCount < 2 then
        return
      end
      local name_nodeid2 = nx_int(info_list[1])
      local name_node2 = nx_widestr("   ") .. gui.TextManager:GetFormatText(info_list[2])
      if nx_ws_equal(name_node2, nx_widestr("")) then
        return
      end
      local map_node2 = map_node1:CreateNode(name_node2)
      map_node2.search_id = name_nodeid2
      if nx_int(4) == name_nodeid2 then
        selectNode = map_node2
      end
      set_sub_node_style(map_node2)
    end
  end
  form.tree_job.SelectNode = selectNode
  form.tree_job.IsNoDrawRoot = true
  form.tree_job.Width = 182
  map_root:ExpandAll()
  if form.tree_job.VScrollBar.Visible == false then
    form.tree_job.Width = 179
  end
  nx_execute("custom_sender", "custom_skyhill_achievement", MT_Day)
end
function set_main_node_style(node)
  node.Font = "font_main"
  node.TextOffsetX = 0
  node.TextOffsetY = 8
  node.ItemHeight = 38
  node.NodeBackImage = "gui\\clone_new\\form_ttf_achievement\\b1.png"
  node.NodeFocusImage = "gui\\clone_new\\form_ttf_achievement\\b1.png"
  node.NodeSelectImage = "gui\\clone_new\\form_ttf_achievement\\b1.png"
  node.ExpandCloseOffsetX = 140
  node.ExpandCloseOffsetY = 11
  node.NodeOffsetY = 3
end
function set_sub_node_style(node)
  node.Font = "font_main"
  node.LevelWidth = 2
  node.TextOffsetX = 10
  node.TextOffsetY = 4
  node.NodeImageOffsetX = 30
  node.ItemHeight = 25
  node.NodeBackImage = "gui\\clone_new\\form_ttf_achievement\\b2out.png"
  node.NodeFocusImage = "gui\\clone_new\\form_ttf_achievement\\b2on.png"
  node.NodeSelectImage = "gui\\clone_new\\form_ttf_achievement\\b2on.png"
end
function on_tree_job_select_changed(treeView)
  local form = treeView.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.tree_job.VScrollBar.Visible == false then
    form.tree_job.Width = 179
  end
  if form.tree_job.VScrollBar.Visible == true then
    form.tree_job.Width = 182
  end
  local node = treeView.SelectNode
  local node_list = node:GetNodeList()
  local node_count = node:GetNodeCount()
  if 0 < node_count then
    return
  end
  form.matchType = nx_int(node.search_id)
  if form.matchType == 1 then
    nx_execute("custom_sender", "custom_skyhill_achievement", form.matchType)
    show_ea(form, form.matchType)
  elseif form.matchType == 4 then
    nx_execute("custom_sender", "custom_skyhill_achievement", form.matchType)
    show_ea(form, form.matchType)
  elseif form.matchType == 5 then
    nx_execute("custom_sender", "custom_skyhill_achievement", form.matchType)
    show_ea(form, form.matchType)
  elseif form.matchType == 6 then
    nx_execute("custom_sender", "custom_skyhill_achievement", form.matchType)
    show_ea(form, form.matchType)
  elseif form.matchType == 7 then
    nx_execute("custom_sender", "custom_skyhill_achievement", form.matchType)
    show_ea(form, form.matchType)
  end
end
function update_form(sub_type, ...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local SwitchManager = nx_value("SwitchManager")
  if not nx_is_valid(SwitchManager) then
    return
  end
  local MainGameStep = SwitchManager:GetMainGameStep()
  local ini = get_ini("share\\SkyHill\\TTFachievement.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:GetSectionCount()
  if sub_type == 4 then
    local argnum_1 = table.getn(arg)
    if argnum_1 < 2 then
      return
    end
    for i = 0, argnum_1 / 2 - 1 do
      local sec_arg = arg[2 * i + 1]
      for j = 0, sec_count - 1 do
        local sec_name = ini:GetSectionByIndex(j)
        if nx_string(sec_arg) == nx_string(sec_name) then
          local groupbox_one = form.gsb_1:Find("groupbox_reward_info_" .. nx_string(j + 1))
          if not nx_is_valid(groupbox_one) then
            return
          end
          local mltbox_reward_info1 = groupbox_one:Find("mltbox_reward_info1_" .. nx_string(j + 1))
          if nx_is_valid(mltbox_reward_info1) then
            mltbox_reward_info1:Clear()
          else
            return
          end
          local mltbox_reward_info2 = groupbox_one:Find("mltbox_reward_info2_" .. nx_string(j + 1))
          if nx_is_valid(mltbox_reward_info2) then
            mltbox_reward_info2:Clear()
          else
            return
          end
          local ea_info_wstr = nx_widestr(arg[2 * i + 2])
          local ea_info_rec = util_split_wstring(ea_info_wstr, ";")
          if table.getn(ea_info_rec) < 1 then
            return
          end
          local count = table.getn(ea_info_rec)
          for k = 1, (count - 1) / 2 do
            local player_name = ea_info_rec[k * 2 - 1]
            local finish_time = ea_info_rec[k * 2]
            if nx_is_valid(groupbox_one) then
              local mltbox_reward_info1 = groupbox_one:Find("mltbox_reward_info1_" .. nx_string(j + 1))
              if nx_is_valid(mltbox_reward_info1) then
                mltbox_reward_info1:AddHtmlText(gui.TextManager:GetText(nx_string(player_name)), -1)
              end
              if nx_is_valid(mltbox_reward_info1) then
                mltbox_reward_info2:AddHtmlText(gui.TextManager:GetText(nx_string(finish_time)), -1)
              end
            end
          end
        end
      end
    end
  else
    local argnum = table.getn(arg)
    if argnum < 3 then
      return
    end
    for i = 0, argnum / 3 - 1 do
      local sec_arg = arg[3 * i + 1]
      for j = 0, sec_count - 1 do
        local sec_name = ini:GetSectionByIndex(j)
        local game_step = ini:ReadInteger(j, "GameStepID", 0)
        if nx_string(sec_arg) == nx_string(sec_name) and (MainGameStep == game_step or game_step == 1) then
          local arg_1 = arg[3 * i + 2]
          local arg_2 = arg[3 * i + 3]
          local index = j + 1
          local groupbox_qf = form.gsb_1:Find("groupbox_ea_" .. nx_string(index))
          if not nx_is_valid(groupbox_qf) then
            return
          end
          if nx_is_valid(groupbox_qf) then
            local btn = groupbox_qf:Find("btn_prize_" .. nx_string(index))
            if not nx_is_valid(btn) then
              return
            end
            local lbl = groupbox_qf:Find("lbl_finish_" .. nx_string(index))
            if not nx_is_valid(lbl) then
              return
            end
            if nx_int(arg_2) == nx_int(1) then
              if btn.DataSource == sec_name then
                lbl.Visible = true
                btn.Enabled = false
                btn.Visible = false
              end
            elseif nx_int(arg_1) == nx_int(0) then
              if btn.DataSource == sec_name then
                btn.Enabled = false
                btn.Text = gui.TextManager:GetText("ui_skyhill_achievement_prize")
              end
            elseif btn.DataSource == sec_name then
              btn.Enabled = true
              btn.Text = gui.TextManager:GetText("ui_skyhill_achievement_prize")
            end
          end
        end
      end
    end
  end
end
function on_imagegrid_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(grid, "binditemid") then
    return
  end
  local itemid = grid.binditemid
  if itemid ~= nil and itemid ~= "" then
    nx_execute("tips_game", "show_tips_by_config", nx_string(itemid), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), form)
  else
    nx_execute("tips_game", "hide_tip", form)
  end
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_cbtn_ea_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = cbtn.DataSource
  local gb_2 = form.gsb_1:Find("groupbox_ea_player_" .. nx_string(index))
  local gb_one = form.gsb_1:Find("groupbox_reward_info_" .. nx_string(index))
  if not nx_is_valid(gb_2) and not nx_is_valid(gb_one) then
    return
  end
  if cbtn.Checked then
    if nx_is_valid(gb_2) then
      gb_2.Height = nx_int(ea_player_height)
      gb_2.Visible = true
    elseif nx_is_valid(gb_one) then
      gb_one.Height = nx_int(ea_achieve_height)
      gb_one.Visible = true
    end
  elseif nx_is_valid(gb_2) then
    gb_2.Height = 0
    gb_2.Visible = false
  elseif nx_is_valid(gb_one) then
    gb_one.Height = 0
    gb_one.Visible = false
  end
  form.gsb_1:ResetChildrenYPos()
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  ctrl.Name = name
  return ctrl
end
function init_achieve_info(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local SwitchManager = nx_value("SwitchManager")
  if not nx_is_valid(SwitchManager) then
    return
  end
  local MainGameStep = SwitchManager:GetMainGameStep()
  form.gsb_1.IsEditMode = true
  form.gsb_1:DeleteAll()
  local ini = get_ini("share\\SkyHill\\TTFachievement.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:GetSectionCount()
  form.ea_sec_count = nx_int(sec_count)
  local ItemsQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemsQuery) then
    return
  end
  index_table = {}
  for i = 1, sec_count do
    local sec_name = ini:GetSectionByIndex(i - 1)
    local desc = ini:ReadString(i - 1, "Content", "")
    local name = ini:ReadString(i - 1, "Name", "")
    local prize = ini:ReadString(i - 1, "PrizeItem", "")
    local prize_type = ini:ReadString(i - 1, "PrizeType", "")
    local times = ini:ReadString(i - 1, "Times", "")
    local achieve_type = ini:ReadString(i - 1, "Type", "")
    local game_step = ini:ReadInteger(i - 1, "GameStepID", 0)
    if game_step == MainGameStep or game_step == 1 then
      table.insert(index_table, i)
      local groupbox_1 = create_ctrl("GroupBox", "groupbox_ea_" .. nx_string(i), form.groupbox_module_1, form.gsb_1)
      if nx_is_valid(groupbox_1) then
        groupbox_1.sec = nx_int(achieve_type)
        local cbtn = create_ctrl("CheckButton", "cbtn_ea_" .. nx_string(i), form.cbtn_achieve, groupbox_1)
        if nx_is_valid(cbtn) then
          nx_bind_script(cbtn, nx_current())
          nx_callback(cbtn, "on_checked_changed", "on_cbtn_ea_checked_changed")
        end
        local lbl_title = create_ctrl("Label", "lbl_title_" .. nx_string(i), form.lbl_title, groupbox_1)
        local lbl_achieve = create_ctrl("Label", "lbl_achieve_" .. nx_string(i), form.lbl_achieve, groupbox_1)
        lbl_title.Text = util_format_string("ui_skyhill_achievement")
        lbl_achieve.Text = util_format_string(name)
        local lbl_prize = create_ctrl("Label", "lbl_prize_" .. nx_string(i), form.lbl_prize, groupbox_1)
        if nx_int(prize_type) == nx_int(0) then
          local imagegrid = create_ctrl("ImageGrid", "imagegrid_" .. nx_string(i), form.imagegrid, groupbox_1)
          photo = ItemsQuery:GetItemPropByConfigID(prize, "Photo")
          imagegrid:AddItem(0, photo, util_text(prize), 1, -1)
          imagegrid.binditemid = prize
          nx_bind_script(imagegrid, nx_current())
          nx_callback(imagegrid, "on_mousein_grid", "on_imagegrid_mousein_grid")
          nx_callback(imagegrid, "on_mouseout_grid", "on_imagegrid_mouseout_grid")
          lbl_prize.BackImage = "gui\\clone_new\\form_ttf_achievement\\daoju.png"
        elseif nx_int(prize_type) == nx_int(2) then
          lbl_prize.BackImage = "gui\\clone_new\\form_ttf_achievement\\daoju.png"
        else
          lbl_prize.BackImage = "gui\\clone_new\\form_ttf_achievement\\renwu.png"
        end
        cbtn.DataSource = nx_string(i)
        groupbox_1.DataSource = nx_string(sec_name)
      end
      if nx_int(achieve_type) == nx_int(1) then
        local groupbox_one = create_ctrl("GroupBox", "groupbox_reward_info_" .. nx_string(i), form.groupbox_reward, form.gsb_1)
        if nx_is_valid(groupbox_one) then
          local mltbox_title = create_ctrl("MultiTextBox", "mltbox_title_" .. nx_string(i), form.mltbox_title, groupbox_one)
          mltbox_title:Clear()
          mltbox_title:AddHtmlText(gui.TextManager:GetText(desc), -1)
          local mltbox_reward_info1 = create_ctrl("MultiTextBox", "mltbox_reward_info1_" .. nx_string(i), form.mltbox_reward_info1, groupbox_one)
          if not nx_is_valid(mltbox_reward_info1) then
            return
          end
          local mltbox_reward_info2 = create_ctrl("MultiTextBox", "mltbox_reward_info2_" .. nx_string(i), form.mltbox_reward_info2, groupbox_one)
          if not nx_is_valid(mltbox_reward_info2) then
            return
          end
          mltbox_reward_info1:Clear()
          mltbox_reward_info2:Clear()
        end
        groupbox_one.Height = 0
        groupbox_one.Visible = false
      else
        local groupbox_2 = create_ctrl("GroupBox", "groupbox_ea_player_" .. nx_string(i), form.groupbox_module_2, form.gsb_1)
        if nx_is_valid(groupbox_2) then
          local mltbox_info = create_ctrl("MultiTextBox", "mltbox_info_" .. nx_string(i), form.mltbox_info, groupbox_2)
          mltbox_info:Clear()
          mltbox_info:AddHtmlText(gui.TextManager:GetText(desc), -1)
          groupbox_2.Height = 0
          groupbox_2.Visible = false
        end
        local lbl_finish = create_ctrl("Label", "lbl_finish_" .. nx_string(i), form.lbl_finish, groupbox_1)
        if nx_is_valid(lbl_finish) then
          lbl_finish.Visible = false
        end
        local btn = create_ctrl("Button", "btn_prize_" .. nx_string(i), form.btn_prize, groupbox_1)
        if nx_is_valid(btn) then
          btn.Enabled = false
          nx_bind_script(btn, nx_current())
          nx_callback(btn, "on_click", "on_btn_prize_click")
        end
        btn.DataSource = nx_string(sec_name)
      end
    end
  end
  form.gsb_1.IsEditMode = false
  form.gsb_1:ResetChildrenYPos()
  show_ea(form, MT_Day)
end
function show_ea(form, sec)
  if not nx_is_valid(form) then
    return
  end
  local count = table.getn(index_table)
  if count < 1 then
    return
  end
  for i = 1, count do
    local index = index_table[i]
    local gb_player = form.gsb_1:Find("groupbox_ea_player_" .. nx_string(index))
    local gb_one = form.gsb_1:Find("groupbox_reward_info_" .. nx_string(index))
    if not nx_is_valid(gb_player) and not nx_is_valid(gb_one) then
      return
    end
    local gb = form.gsb_1:Find("groupbox_ea_" .. nx_string(index))
    if not nx_is_valid(gb) then
      return
    end
    if nx_int(gb.sec) == nx_int(sec) then
      gb.Visible = true
      local cbtn = gb:Find("cbtn_ea_" .. nx_string(index))
      if cbtn.Checked then
        if nx_is_valid(gb_player) then
          gb_player.Visible = true
        elseif nx_is_valid(gb_one) then
          gb_one.Visible = true
        end
      end
    else
      gb.Visible = false
      if nx_is_valid(gb_player) then
        gb_player.Visible = false
      elseif nx_is_valid(gb_one) then
        gb_one.Visible = false
      end
    end
  end
  form.gsb_1:ResetChildrenYPos()
end
function on_btn_prize_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = btn.DataSource
  nx_execute("custom_sender", "custom_skyhill_get_reward", index)
  btn.Enabled = false
  btn.Visible = false
  if not nx_find_custom(form, "matchType") or form.matchType == nil then
    form.matchType = MT_Day
  end
  local matchType = form.matchType
  nx_execute("custom_sender", "custom_skyhill_achievement", matchType)
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
end
