require("util_functions")
require("util_gui")
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = 0
  self.AbsTop = 100
  init_grid(self.textgrid_freefight_rank)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function init_grid(self)
  self.ColCount = 3
  for i = 1, self.ColCount do
    self:SetColAlign(i - 1, "center")
  end
  self.HeaderColWidth = 30
  self.HeaderBackColor = "0,255,0,0"
  self:SetColTitle(0, nx_widestr(util_text("ui_PaiMing")))
  self:SetColTitle(1, nx_widestr(util_text("ui_mzi")))
  self:SetColTitle(2, nx_widestr(util_text("ui_crshu")))
  self.cur_editor_row = -1
  self.current_task_id = ""
  self:ClearRow()
  for i = 0, 4 do
    self:InsertRow(-1)
  end
end
function openform(...)
  local form = util_get_form("form_stage_main\\form_school_war\\form_free_fight_rank", true)
  if not nx_is_valid(form) then
    return
  end
  util_show_form("form_stage_main\\form_school_war\\form_free_fight_rank", true)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local playername = client_player:QueryProp("Name")
  local row = arg[1]
  for i = 0, nx_number(row) - 1 do
    local rank = arg[i * 3 + 2]
    local name = arg[i * 3 + 3]
    local credit = arg[i * 3 + 4]
    if rank < 3 then
      form.textgrid_freefight_rank:SetGridText(nx_int(rank), 0, nx_widestr(rank + 1))
      form.textgrid_freefight_rank:SetGridText(nx_int(rank), 1, nx_widestr(name))
      form.textgrid_freefight_rank:SetGridText(nx_int(rank), 2, nx_widestr(credit))
    end
    if name == playername then
      form.textgrid_freefight_rank:SetGridText(nx_int(4), 0, nx_widestr(rank + 1))
      form.textgrid_freefight_rank:SetGridText(nx_int(4), 1, nx_widestr(name))
      form.textgrid_freefight_rank:SetGridText(nx_int(4), 2, nx_widestr(credit))
    end
  end
end
