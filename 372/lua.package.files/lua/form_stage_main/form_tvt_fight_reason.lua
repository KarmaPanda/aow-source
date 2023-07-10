require("util_functions")
require("util_gui")
local FORM_MAIN = "form_stage_main\\form_tvt_fight_reason"
function save_serve_tvt_msg(main_type, ...)
  local form = nx_value(FORM_MAIN)
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", FORM_MAIN, true, false)
  end
  if not nx_is_valid(form) then
    return
  end
  local form_logic = nx_value("form_main_map_logic")
  if not nx_is_valid(form_logic) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local client_role = get_player()
  local role_name = client_role:QueryProp("Name")
  if 1 == main_type then
    local argnum = table.getn(arg)
    if argnum < 1 then
      return
    end
    local lbl_mvp = gui:Create("Label")
    lbl_mvp.BackImage = "gui\\special\\tianti\\tvt_fight\\best.png"
    lbl_mvp.AutoSize = true
    local grid = form.textgrid_1
    grid:BeginUpdate()
    grid:ClearRow()
    grid.ColCount = 5
    grid.ColWidths = "120, 32, 140, 70, 70"
    grid:SetColTitle(0, util_text("ui_TVT_fight_C1"))
    grid:SetColTitle(1, util_text("ui_TVT_fight_C2"))
    grid:SetColTitle(2, util_text("ui_TVT_fight_C3"))
    grid:SetColTitle(3, util_text("ui_TVT_fight_C4"))
    grid:SetColTitle(4, util_text("ui_TVT_fight_C5"))
    local name_value = {}
    if 1 < argnum and math.mod(argnum, 2) == 0 then
      for i = 1, argnum, 2 do
        local mem_name = nx_string(arg[i])
        table.insert(name_value, mem_name)
        if nx_ws_equal(role_name, nx_widestr(mem_name)) == true then
          form.lbl_win.BackImage = "gui\\special\\tianti\\tvt_fight\\we.png"
          form.lbl_lose.BackImage = "gui\\special\\tianti\\tvt_fight\\enemy.png"
        end
        local mem_info = nx_string(arg[i + 1])
        local lst = util_split_string(mem_info, ";")
        local mvp = lst[1]
        local attack_num = nx_number(lst[2])
        local kill_num = nx_number(lst[3])
        local row = grid:InsertRow(-1)
        grid:SetGridText(row, 0, nx_widestr(mem_name))
        if 1 == nx_number(mvp) then
          grid:SetGridControl(row, 1, lbl_mvp)
        else
          grid:SetGridText(row, 1, nx_widestr(""))
        end
        grid:SetGridText(row, 2, nx_widestr(value))
        grid:SetGridText(row, 3, nx_widestr(attack_num))
        grid:SetGridText(row, 4, nx_widestr(kill_num))
      end
      for i = 1, table.getn(name_value) do
        local name = nx_widestr(name_value[i])
        local persistid = form_logic:UtilFindClientPlayerByName(name)
        if persistid ~= -1 and nx_is_valid(persistid) then
          local title_info = persistid:QueryProp("SwornTitleInfo")
          if title_info ~= "" and title_info ~= 0 then
            local list = util_split_wstring(nx_widestr(title_info), nx_widestr(","))
            local counts = table.getn(list)
            if counts < 4 then
              return ""
            end
            local title_name = nx_widestr(list[1])
            local player_num = nx_int(list[2])
            local title_id = nx_int(list[4])
            if nx_int(player_num) >= nx_int(2) and nx_int(player_num) <= nx_int(6) then
              value = gui.TextManager:GetFormatText("role_title_" .. nx_string(player_num) .. "_" .. nx_string(title_id), nx_widestr(title_name))
            end
          else
            value = ""
          end
        else
          value = ""
        end
        grid:SetGridText(i - 1, 2, nx_widestr(value))
      end
      grid:EndUpdate()
    end
  elseif 0 == main_type then
    local argnum = table.getn(arg)
    if argnum < 1 then
      return
    end
    local grid = form.textgrid_2
    grid:BeginUpdate()
    grid:ClearRow()
    grid.ColCount = 5
    grid.ColWidths = "120, 32, 140, 70, 70"
    grid:SetColTitle(0, util_text("ui_TVT_fight_C1"))
    grid:SetColTitle(1, util_text("ui_TVT_fight_C2"))
    grid:SetColTitle(2, util_text("ui_TVT_fight_C3"))
    grid:SetColTitle(3, util_text("ui_TVT_fight_C4"))
    grid:SetColTitle(4, util_text("ui_TVT_fight_C5"))
    local name_value_1 = {}
    if 1 < argnum and math.mod(argnum, 2) == 0 then
      for i = 1, argnum, 2 do
        local mem_name = nx_string(arg[i])
        table.insert(name_value_1, mem_name)
        if nx_ws_equal(role_name, nx_widestr(mem_name)) == true then
          form.lbl_win.BackImage = "gui\\special\\tianti\\tvt_fight\\enemy.png"
          form.lbl_lose.BackImage = "gui\\special\\tianti\\tvt_fight\\we.png"
        end
        local mem_info = nx_string(arg[i + 1])
        local lst = util_split_string(mem_info, ";")
        local mvp = lst[1]
        local attack_num = nx_number(lst[2])
        local kill_num = nx_number(lst[3])
        local row = grid:InsertRow(-1)
        grid:SetGridText(row, 0, nx_widestr(mem_name))
        grid:SetGridText(row, 1, nx_widestr(""))
        grid:SetGridText(row, 3, nx_widestr(attack_num))
        grid:SetGridText(row, 4, nx_widestr(kill_num))
      end
      for i = 1, table.getn(name_value_1) do
        local name = nx_widestr(name_value_1[i])
        local persistid = form_logic:UtilFindClientPlayerByName(name)
        if persistid ~= -1 and nx_is_valid(persistid) then
          local title_info = persistid:QueryProp("SwornTitleInfo")
          if title_info ~= "" and title_info ~= 0 then
            local list = util_split_wstring(nx_widestr(title_info), nx_widestr(","))
            local counts = table.getn(list)
            if counts < 4 then
              return ""
            end
            local title_name = nx_widestr(list[1])
            local player_num = nx_int(list[2])
            local title_id = nx_int(list[4])
            if nx_int(player_num) >= nx_int(2) and nx_int(player_num) <= nx_int(6) then
              value_1 = gui.TextManager:GetFormatText("role_title_" .. nx_string(player_num) .. "_" .. nx_string(title_id), nx_widestr(title_name))
            end
          else
            value_1 = ""
          end
        else
          value_1 = ""
        end
        grid:SetGridText(i - 1, 2, nx_widestr(value_1))
      end
      grid:EndUpdate()
    end
  end
  form.Visible = false
end
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "form_close", form)
    timer:Register(25000, 1, nx_current(), "form_close", form, -1, -1)
  end
  form.groupbox_4.Visible = false
  change_form_size(form)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "form_close", form)
  end
  nx_destroy(form)
end
function change_form_size(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_cbtn_1_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if cbtn.Checked then
    form.groupbox_4.Visible = true
    form.textgrid_1.Visible = true
    form.textgrid_2.Visible = true
  else
    form.groupbox_4.Visible = false
  end
end
function on_btn_2_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function get_player()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  return client_player
end
function form_close()
  local form = nx_value(FORM_MAIN)
  if nx_is_valid(form) then
    form:Close()
  end
end
function fresh_state_msg(...)
  local form = nx_value(FORM_MAIN)
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", FORM_MAIN, true, false)
  end
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  form.lbl_6.Text = nx_widestr(nx_number(arg[1]))
  form.lbl_7.Text = nx_widestr(nx_number(arg[2]))
end
