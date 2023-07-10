require("form_task\\common")
require("theme")
local TITLE_COL_WIDTH = 120
local VALUE_COL_WIDTH = 120
local GRID_ROW_HEIGHT = 22
local HYPER_STYLE_INFO = {
  [1] = {
    [1] = {
      name = "Previous",
      desc = "Npc\215\183\215\217\208\197\207\162"
    },
    [2] = {name = "NpcId", desc = "Npc\177\224\186\197"},
    [3] = {name = "SceneId", desc = "\179\161\190\176\177\224\186\197"},
    [4] = {name = "Text", desc = "\206\196\177\190\208\222\213\253"}
  },
  [2] = {
    [1] = {name = "Previous", desc = "\181\192\190\223\215\183\215\217"},
    [2] = {name = "ToolId", desc = "\181\192\190\223\177\224\186\197"},
    [3] = {name = "Text", desc = "\206\196\177\190\208\222\213\253"}
  },
  [3] = {
    [1] = {name = "Previous", desc = "\215\248\177\234\215\183\215\217"},
    [2] = {name = "PosX", desc = "\215\248\177\234 X"},
    [3] = {name = "PosY", desc = "\215\248\177\234 Y"},
    [4] = {name = "PosZ", desc = "\215\248\177\234 X"},
    [5] = {name = "SceneId", desc = "\179\161\190\176\177\224\186\197"},
    [6] = {name = "Text", desc = "\206\196\177\190\208\222\213\253"}
  }
}
local get_hyper_style_grid_by_number = function(self, number)
  local ctl_name = "hyper_style" .. number .. "_grid"
  local ctl = self:Find(ctl_name)
  if not nx_is_valid(ctl) then
    nx_msgbox("\206\180\213\210\181\189\209\249\202\189\191\216\188\254")
  end
  return ctl
end
function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  local title_grid = self.title_grid
  local trace_info_id = self.grid:GetGridText(0, 1)
  title_grid:SetColTitle(0, nx_widestr("TrackInfo"))
  title_grid:SetColTitle(1, trace_info_id)
  title_grid:SetColWidth(0, TITLE_COL_WIDTH)
  title_grid:SetColWidth(1, VALUE_COL_WIDTH)
  local gui = nx_value("gui")
  for i = 1, table.getn(HYPER_STYLE_INFO) do
    local grid = get_hyper_style_grid_by_number(self, i)
    grid.function_number = i
    local info = HYPER_STYLE_INFO[i]
    local info_count = table.getn(info)
    grid.RowHeight = GRID_ROW_HEIGHT
    for j = 1, info_count do
      local row = grid:InsertRow(-1)
      local title = info[j].desc
      local value = ""
      grid:SetGridText(row, 0, nx_widestr(title))
      if j == 1 then
        local richedit = CREATE_CONTROL("RichEdit")
        richedit.ReadOnly = true
        richedit.Solid = false
        richedit.ViewRect = "1,1,119,21"
        richedit.BackColor = EDIT_BACKCOLOR
        grid:SetGridControl(row, 1, richedit)
      elseif 2 <= j then
        local edit = CREATE_CONTROL("Edit")
        edit.grid = grid
        edit.BackColor = GRID_HEADER_COLOR
        nx_bind_script(edit, nx_current())
        nx_callback(edit, "on_lost_focus", "on_eidt_lost_focus")
        nx_callback(edit, "on_enter", "on_eidt_lost_focus")
        grid:SetGridControl(row, 1, edit)
      end
    end
  end
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function main_form_close(self)
  nx_destroy(self)
  return 1
end
function close_btn_click(self)
  local form = self.Parent
  form:Close()
  return 1
end
function on_eidt_lost_focus(self)
  local grid = self.grid
  local ret
  local style_info = HYPER_STYLE_INFO[grid.function_number]
  local count = table.getn(style_info)
  if grid.function_number == 1 then
    local scene_id, npc_id, text
    for i = 1, count - 1 do
      local name = style_info[i + 1].name
      local ctrl = grid:GetGridControl(i, 1)
      local val = nx_string(ctrl.Text)
      if name == "SceneId" then
        scene_id = val
      elseif name == "NpcId" then
        npc_id = val
      elseif name == "Text" then
        text = val
      end
    end
    ret = nx_execute("form_task\\form_text", "make_default_text_1", scene_id, npc_id, text)
  elseif grid.function_number == 2 then
    local scene_id
    local target_config = ""
    local tool_id, text
    for i = 1, count - 1 do
      local name = style_info[i + 1].name
      local ctrl = grid:GetGridControl(i, 1)
      local val = nx_string(ctrl.Text)
      if name == "SceneId" then
        scene_id = val
      elseif name == "ToolId" then
        tool_id = val
      elseif name == "Text" then
        text = val
      end
    end
    ret = nx_execute("form_task\\form_text", "make_default_text_2", 0, "", tool_id, text)
  elseif grid.function_number == 3 then
    local scene_id, npc_id, target_pos_x, target_pos_y, target_pos_z, text
    for i = 1, count - 1 do
      local name = style_info[i + 1].name
      local ctrl = grid:GetGridControl(i, 1)
      local val = nx_string(ctrl.Text)
      if name == "SceneId" then
        scene_id = val
      elseif name == "NpcId" then
        npc_id = val
      elseif name == "PosX" then
        target_pos_x = val
      elseif name == "PosY" then
        target_pos_y = val
      elseif name == "PosZ" then
        target_pos_z = val
      elseif name == "Text" then
        text = val
      end
    end
    ret = nx_execute("form_task\\form_text", "make_default_text_3", scene_id, 0, "1", target_pos_x, target_pos_y, target_pos_z, text)
  end
  local richedit = grid:GetGridControl(0, 1)
  richedit.Text = nx_widestr(ret)
  return 1
end
function add_btn_click(self)
  local form = self.Parent
  local name = nx_string(self.Name)
  local name_len = string.len(name)
  local number = string.sub(name, name_len, name_len)
  local grid = get_hyper_style_grid_by_number(form, number)
  local richedit = grid:GetGridControl(0, 1)
  local text = richedit.Text
  form.ret_richedit.Text = form.ret_richedit.Text .. text
  return 1
end
function clear_richedit_btn_click(self)
  local form = self.Parent
  local richedit = form.ret_richedit
  richedit.Text = ""
  return 1
end
function apply_btn_click(self)
  local form = self.Parent
  local richedit = form.ret_richedit
  if form.grid.groupbox.richedit.Text ~= richedit.Text then
    form.grid.groupbox.richedit.Text = richedit.Text
    form.grid.groupbox.edit.Text = richedit.Text
    nx_execute("form_task\\form_text", "leave_the_changes", form.grid.groupbox.richedit)
  end
  return 1
end
