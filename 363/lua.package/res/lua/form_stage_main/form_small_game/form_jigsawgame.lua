require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("const_define")
require("util_functions")
local game_time_now = 0
local indexReleate_table = {}
local indexcurrent = 1
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function main_form_init(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
end
function close_game_form()
  local form_talk = nx_value("form_stage_main\\form_small_game\\form_jigsawgame")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
end
function on_btn_close_click(btn)
  local JigsawGame = nx_value("JigsawGame")
  JigsawGame:SendGameResult(1)
  JigsawGame:Close()
end
function on_btn_down_click(btn)
  local form = btn.ParentForm
  local lbl = form:Find(nx_string(indexcurrent))
  if nx_is_valid(lbl) then
    lbl.BackImage = "gui\\mainform\\pingturound" .. nx_string(indexcurrent) .. ".png"
  end
  indexcurrent = indexcurrent + 1
  if 7 < indexcurrent then
    indexcurrent = 1
  end
end
function on_lbl_click(self)
  indexcurrent = nx_number(self.Name)
  nx_msgbox(nx_string(indexcurrent))
  self.BackImage = "gui\\mainform\\pingturound" .. nx_string(indexcurrent) .. ".png"
end
function on_btn_up_click(btn)
  local form = btn.ParentForm
  local lbl = form:Find(nx_string(indexcurrent))
  if nx_is_valid(lbl) then
    lbl.BackImage = "gui\\mainform\\pingturound" .. nx_string(indexcurrent) .. ".png"
  end
  indexcurrent = indexcurrent - 1
  if indexcurrent < 1 then
    indexcurrent = 7
  end
end
function on_btn_rightround_click(btn)
  local form = btn.ParentForm
  roundLab(form, nx_string(indexcurrent), 0.157)
  roundLab(form, nx_string(indexReleate_table[indexcurrent]), 0.157)
end
function on_btn_leftround_click(btn)
  local form = btn.ParentForm
  roundLab(form, nx_string(indexcurrent), -0.157)
  roundLab(form, nx_string(indexReleate_table[indexcurrent]), -0.157)
end
function game_init(form)
  game_time_now = 0
  local JigsawGame = nx_value("JigsawGame")
  GameInfo = JigsawGame:GetGameInfo()
  local res = GameInfo[1]
  if res ~= true then
    return 0
  end
  for row = 1, 7 do
    roundLab(form, nx_string(row), GameInfo[1 + row] * 0.314)
    console_log("lbl_round is :" .. nx_string(row))
    console_log("indexReleate_table[i] is :" .. nx_string(GameInfo[8 + row]))
    table.insert(indexReleate_table, GameInfo[8 + row])
  end
  indexcurrent = 1
  local timer = nx_value(GAME_TIMER)
  nx_execute(nx_current(), "on_update_time", form, 1)
  timer:Register(40, -1, nx_current(), "on_update_time", form, 1, -1)
  return 1
end
function roundLab(form, name, AngleZ)
  local lbl1 = form:Find(name)
  if nx_is_valid(lbl1) then
    lbl1.AngleZ = lbl1.AngleZ + AngleZ
  end
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  game_init(self)
end
function on_update_time(form, level)
  game_time_now = game_time_now + 40
  form.lbl_Time.Text = nx_widestr(game_time_now / 1000)
  local lbl = form:Find(nx_string(indexcurrent))
  if nx_is_valid(lbl) then
    lbl.BackImage = "gui\\mainform\\pingturoundon" .. nx_string(indexcurrent) .. ".png"
  end
  if checkgame(form) then
    local JigsawGame = nx_value("JigsawGame")
    stop_timer(form)
    JigsawGame:SendGameResult(1)
  end
end
function checkgame(form)
  for row = 1, 7 do
    local lbl = form:Find(nx_string(row))
    if nx_is_valid(lbl) then
      if lbl.AngleZ % 6.28 > 0.01 then
        return false
      else
        lbl.AngleZ = 0
      end
    end
  end
  return true
end
function stop_timer(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_time", form)
end
