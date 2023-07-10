require("util_functions")
require("util_gui")
OPEN_FORM = 1
CLICK_KAPAI = 2
GET_PRESTIGE = 3
GET_PRIZE = 4
CLOSE_KAPAI = 5
TIME_OUT = 6
TOTAL_NUM = 7
CHECK_CONDITION = 8
KAPAI_REC_ID = 0
KAPAI_REC_SUB_ID = 1
KAPAI_REC_TYPE = 2
KAPAI_REC_STATE = 3
KAPAI_REC_REWARD_LIST = 4
KAPAI_REC_DEADLINE = 5
KAPAI_REC_LAST_TIME = 6
KAPAI_REC_VALID_LIST = 7
KAPAI_STATE_UNKNOW = -1
KAPAI_STATE_OPENING = 0
KAPAI_STATE_CLOSING = 1
KAPAI_STATE_CAN_OPEN = 2
KAPAI_STATE_DONE = 3
KAPAI_STATE_COOLDOWN = 4
TITLE_REWARD = 1
PROP_REWARD = 2
ITEM_REWARD = 3
BUFF_REWARD = 4
TASK_REWARD = 5
RIGHT_REWARD = 6
FASHION_REWARD = 7
PET_REWARD = 8
MAIN_KAPAI_FORM = 1
SUB_KAPAI_FORM = 2
state_name = {
  [0] = "ui_prestige_open",
  [1] = "ui_prestige_cantsee",
  [2] = "ui_prestige_cansee",
  [3] = "ui_prestige_got",
  [4] = "ui_prestige_cd"
}
function clone_groupbox(source)
  local gui = nx_value("gui")
  local clone = gui:Create("GroupBox")
  clone.AutoSize = source.AutoSize
  clone.Name = source.Name
  clone.BackColor = source.BackColor
  clone.NoFrame = source.NoFrame
  clone.Left = 0
  clone.Top = 0
  clone.Width = source.Width
  clone.Height = source.Height
  clone.BackImage = source.BackImage
  return clone
end
function clone_label(source)
  local gui = nx_value("gui")
  local clone = gui:Create("Label")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.ForeColor = source.ForeColor
  clone.ShadowColor = source.ShadowColor
  clone.Font = source.Font
  clone.Text = source.Text
  clone.BackImage = source.BackImage
  clone.Align = source.Align
  clone.DrawMode = source.DrawMode
  return clone
end
function clone_button(source)
  local gui = nx_value("gui")
  local clone = gui:Create("Button")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.ForeColor = source.ForeColor
  clone.ShadowColor = source.ShadowColor
  clone.Font = source.Font
  clone.NormalImage = source.NormalImage
  clone.FocusImage = source.FocusImage
  clone.PushImage = source.PushImage
  clone.NormalColor = source.NormalColor
  clone.FocusColor = source.FocusColor
  clone.PushColor = source.PushColor
  clone.DisableColor = source.DisableColor
  clone.BackColor = source.BackColor
  clone.ShadowColor = source.ShadowColor
  clone.Text = source.Text
  clone.AutoSize = source.AutoSize
  return clone
end
function clone_richedit(source)
  local gui = nx_value("gui")
  local clone = gui:Create("RichEdit")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.ViewRect = source.ViewRect
  clone.ReadOnly = source.ReadOnly
  clone.Caret = source.Caret
  clone.ShadowColor = source.ShadowColor
  clone.Font = source.Font
  clone.Cursor = source.Cursor
  clone.NoFrame = source.NoFrame
  clone.Align = source.Align
  clone.BackColor = source.BackColor
  return clone
end
function clone_multitextbox(source)
  local gui = nx_value("gui")
  local clone = gui:Create("MultiTextBox")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.ViewRect = source.ViewRect
  clone.NoFrame = source.NoFrame
  clone.ShadowColor = source.ShadowColor
  clone.BackColor = source.BackColor
  clone.SelectBarColor = source.SelectBarColor
  clone.MouseInBarColor = source.MouseInBarColor
  clone.Font = source.Font
  return clone
end
function clone_radiobutton(source)
  local gui = nx_value("gui")
  local clone = gui:Create("RadioButton")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.ForeColor = source.ForeColor
  clone.ShadowColor = source.ShadowColor
  clone.Font = source.Font
  clone.NormalImage = source.NormalImage
  clone.FocusImage = source.FocusImage
  clone.CheckedImage = source.CheckedImage
  clone.TabIndex = source.TabIndex
  clone.TabStop = source.TabStop
  clone.NormalColor = source.NormalColor
  clone.FocusColor = source.FocusColor
  clone.PushColor = source.PushColor
  clone.DisableColor = source.DisableColor
  clone.BackColor = source.BackColor
  clone.ShadowColor = source.ShadowColor
  clone.Text = source.Text
  clone.AutoSize = source.AutoSize
  clone.BoxSize = source.BoxSize
  clone.InSound = source.InSound
  clone.ClickSound = source.ClickSound
  local icon = gui:Create("Label")
  icon.Width = 23
  icon.Height = 22
  clone.icon = icon
  return clone
end
function format_time(date)
  local day = math.floor(date)
  if nx_int(day) == nx_int(0) then
    local str_dt = nx_function("format_date_time", nx_double(date))
    local table_dt = util_split_string(str_dt, ";")
    if table.getn(table_dt) ~= 2 then
      return ""
    end
    local format_time = format_time_text(table_dt[2])
    return format_time
  else
    local gui = nx_value("gui")
    if nx_int(day) > nx_int(30) then
      day = 30
    end
    local format_time = nx_string(day) .. nx_string(gui.TextManager:GetText("ui_prestige_time_day"))
    return format_time
  end
end
function format_time_text(text)
  local len = string.len(text)
  if nx_number(len) ~= 8 then
    return text
  end
  local format_time = string.sub(nx_string(text), 1, 5)
  if nx_string(format_time) == "00:00" then
    format_time = "00:01"
  end
  return format_time
end
function test()
  local temp = util_create_model([[
objitem
pcitem
pcitem167
pcitem167.xmod]], "", "", "", "")
  nx_msgbox(nx_string(temp))
end
