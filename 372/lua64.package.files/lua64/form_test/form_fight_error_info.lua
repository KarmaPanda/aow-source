require("utils")
require("util_functions")
local CLIENT_FIGHT_ERROR_INFO = {
  [1] = "IGameClient\187\242\213\223\202\199IGameClient \214\184\213\235\206\170NULL",
  [2] = "\205\230\188\210\182\212\207\243\206\170NULL",
  [3] = "\188\188\196\220\214\184\213\235\206\170NULL",
  [4] = "result <= WAIT_ERROR",
  [5] = "\206\239\198\183\202\205\183\197\188\188\196\220\163\172\206\239\198\183\178\187\180\230\212\218",
  [6] = "custom_item_id\206\170NULL",
  [7] = "\193\189\181\227\214\174\188\228\178\187\191\201\205\168\185\253",
  [8] = "\182\212\209\161\212\241\182\212\207\243\202\185\211\195\181\196\188\188\196\220\163\172\209\161\212\241\210\187\184\246\188\188\196\220\181\196\215\247\211\195\182\212\207\243,\182\212\207\243\178\187\180\230\212\218",
  [9] = "data_query_manager\187\241\200\161\214\184\213\235\182\212\207\243\206\170NULL",
  [10] = "\209\161\212\241\196\191\177\234\205\230\188\210\214\184\213\235\182\212\207\243\206\170NULL",
  [11] = "NULL == pClientPlayer || NULL == pSelObj || NULL == pSkill",
  [12] = "\181\177\199\176\188\188\196\220\202\199\203\248\182\168\213\208\202\189\197\208\182\207\194\223\188\173",
  [13] = "\181\177\199\176\188\188\196\220\202\199\210\187\176\227\188\188\196\220",
  [14] = "szViewId = 42\163\172Buffer\200\221\198\247\214\184\213\235\182\212\207\243\206\170NULL",
  [15] = "\205\230\188\210\207\214\212\218\180\166\211\218\211\178\214\177\215\180\204\172",
  [16] = "CanUse\202\244\208\212\178\187\181\200\211\2181",
  [17] = "\181\177\199\176\188\188\196\220\206\170\180\242\215\248\188\188\196\220\163\172\181\177\199\176\215\180\204\172\206\170\213\189\182\183\215\180\204\172",
  [18] = "\181\177\199\176\188\188\196\220\206\170\180\242\215\248\188\188\196\220\163\172\181\177\199\176\215\180\204\172\206\170\213\189\182\183\215\180\204\172",
  [19] = "\188\188\196\220\207\251\186\196\181\196HP\178\187\215\227",
  [20] = "\188\188\196\220\207\251\186\196\181\196MP\178\187\215\227",
  [21] = "\188\188\196\220\207\251\186\196\181\196AirSkillPoint\178\187\215\227",
  [22] = "\188\188\196\220\207\251\186\196\181\196SP\178\187\215\227",
  [23] = "\188\188\196\220\207\251\186\196\181\196\181\192\190\223\178\187\215\227",
  [26] = "\181\177\199\176\205\230\188\210\187\242\213\223\202\199\209\161\212\241\181\196\196\191\177\234\210\209\190\173\203\192\205\246",
  [27] = "\181\177\199\176\205\230\188\210\187\242\213\223\202\199\209\161\212\241\181\196\196\191\177\234\178\187\180\230\212\218",
  [30] = "\181\177\199\176\188\188\196\220\206\170\198\213\205\168\176\181\198\247\185\165\187\247\188\188\196\220\163\172\195\187\211\208\215\176\177\184\207\224\211\166\181\196\176\181\198\247",
  [31] = "\181\177\199\176\188\188\196\220\206\170\198\213\205\168\176\181\198\247\185\165\187\247\188\188\196\220\163\172\215\176\177\184\181\196\176\181\198\247\192\224\208\205\180\237\206\243"
}
local CLIENT_FIGHT_ERROE_INFO_INDEX_MAX = 31
local SHIELD_FIFHT_ERROR_INDEX = {
  19,
  20,
  21,
  22,
  26
}
local COL_1_WIDTH = 150
local COL_2_WIDTH = 65
local TIME_DELAY_MAX = 1
local SERVER_FIGHT_ERROR_INFO = {
  [1] = "\188\188\196\220\178\187\180\230\212\218",
  [2] = "\212\221\205\163\214\208\178\187\196\220\202\185\211\195\179\229\180\204\188\188\196\220",
  [3] = "\195\187\211\208\185\165\187\247\196\191\177\234\163\172\188\188\196\220\177\187\180\242\182\207",
  [4] = "\193\237\210\187\184\246\188\188\196\220\213\253\212\218\215\188\177\184\198\218\163\172\195\187\211\208\180\242\182\207",
  [5] = "\193\237\210\187\184\246\188\188\196\220\213\253\212\218\210\253\181\188\214\208\163\172\195\187\211\208\180\242\182\207",
  [6] = "\196\191\177\234\192\224\208\205\183\199\183\168",
  [7] = "\208\222\213\253\188\188\196\220\196\191\177\234 \210\209\190\173\196\191\177\234\206\187\214\195\202\167\176\220",
  [8] = "\179\162\202\212\202\185\211\195\191\213\214\208\188\188\196\220\202\167\176\220",
  [9] = "\210\209\180\230\212\218\210\187\184\246\193\247\179\204\163\172\178\187\196\220\205\172\202\177\180\230\212\218\182\224\184\246\193\247\179\204",
  [10] = "\210\209\190\173\212\218\210\187\184\246\214\184\182\168\193\247\179\204\214\208",
  [11] = "leadseptime \202\177\188\228\206\1700",
  [12] = "\195\187\211\208\213\210\181\189\195\252\214\208\202\177\188\228\193\208\177\237flow_hittime_rec",
  [13] = "\195\187\211\208\213\210\181\189\185\165\187\247\193\247\179\204",
  [14] = "\195\187\211\208\213\210\181\189\207\224\211\166\181\196\215\188\177\184\193\247\179\204",
  [15] = "\181\177\199\176\193\247\179\204\202\199\177\187\212\221\205\163\193\203",
  [16] = "\205\230\188\210\203\192\205\246",
  [17] = "\205\230\188\210\181\177\199\176\178\187\191\201\191\216\214\198",
  [18] = "\189\251\214\185\208\233\213\208",
  [19] = "\189\251\214\185\202\181\213\208",
  [20] = " \189\251\214\185\188\220\213\208",
  [21] = "\181\177\199\176\215\212\188\186\212\218\203\248\182\168\214\208,\178\187\196\220\202\185\211\195\188\188\196\220",
  [22] = "\211\178\214\177\215\180\204\172,\178\187\196\220\202\185\211\195\188\188\196\220",
  [23] = "LogicState\179\172\185\253100,\178\187\196\220\202\185\211\195\188\188\196\220",
  [24] = "\203\217\182\200\204\171\194\253,\206\222\183\168\179\229\180\204",
  [25] = "\205\230\188\210\206\187\214\195\184\250\196\191\177\234\190\224\192\235\180\243\211\21820\163\172\206\222\183\168\202\185\211\195\188\188\196\220",
  [26] = "\181\177\199\176\210\209\190\173\211\208\210\187\184\246\215\188\177\184\188\188\196\220\163\172\178\187\196\220\212\217\180\206\202\185\211\195\188\188\196\220",
  [27] = "\205\230\188\210\180\166\211\218\177\187\180\242\189\215\182\206\163\172\178\187\196\220\202\185\211\195\188\188\196\220",
  [28] = "\193\247\179\204\178\187\212\217\212\221\205\163\214\208\163\172\178\187\196\220\179\229\180\204",
  [29] = "\178\187\196\220\214\216\184\180\201\234\199\235\202\185\211\195\179\229\180\204\188\188\196\220",
  [30] = "\214\187\196\220\202\199\182\212\196\191\177\234\202\185\211\195\181\196\188\188\196\220",
  [31] = "\195\187\211\208\209\161\212\241\196\191\177\234\182\212\207\243",
  [32] = "\209\161\212\241\181\196\196\191\177\234\192\224\208\205\178\187\202\199\181\216\195\230\163\172\178\187\196\220\182\212\181\216\195\230\202\185\211\195\188\188\196\220",
  [33] = "\205\230\188\210\213\253\212\218\180\242\215\248\181\247\207\162\214\208",
  [34] = "\212\218\193\180\189\211\215\180\204\172\207\194\178\187\196\220\202\185\211\195\188\188\196\220",
  [35] = "\207\214\212\218\205\230\188\210\180\166\211\218\176\243\188\220\161\162\177\187\176\243\188\220\187\242\213\223\202\199\177\187\176\243\188\220\186\243\181\196\185\216\209\186\215\180\204\172",
  [36] = "\207\214\212\218\205\230\188\210\180\166\211\218\198\239\179\203\215\180\204\172"
}
local SERVER_FIGHT_ERROE_INFO_INDEX_MAX = 36
local NO_DISPOSE_FIGHT_ERROR_TABLE = {
  9491,
  9492,
  9493,
  9495
}
function main_form_init(self)
  self.Fixed = false
  self.end_error_info_index = 0
  self.end_error_info_time = 0
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.textbox_fight_error_info:SetColTitle(0, nx_widestr("\180\237\206\243\194\235"))
  self.textbox_fight_error_info:SetColTitle(1, nx_widestr("\204\225\202\190\208\197\207\162\196\218\200\221"))
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
  return 1
end
function is_find_dispose_fight_error_index(error_index)
  for index, value in pairs(NO_DISPOSE_FIGHT_ERROR_TABLE) do
    if nx_number(value) == nx_number(error_index) then
      return true
    end
  end
  return false
end
function client_add_fight_error_info(error_index)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if not form.Visible then
    return
  end
  local gui = nx_value("gui")
  if is_find_dispose_fight_error_index(error_index) then
    return
  end
  if nx_number(form.end_error_info_index) == nx_number(error_index) then
    local delay_time = os.time() - form.end_error_info_time
    if nx_number(delay_time) < nx_number(TIME_DELAY_MAX) then
      return
    end
  end
  local text = "<Client\163\186>"
  if nx_number(error_index) >= nx_number(9000) and nx_number(error_index) < nx_number(9500) then
    text = nx_string(text) .. nx_string(gui.TextManager:GetFormatText(nx_string(error_index)))
  elseif nx_number(error_index) > nx_number(0) and nx_number(error_index) <= nx_number(CLIENT_FIGHT_ERROE_INFO_INDEX_MAX) then
    text = nx_string(text) .. nx_string(CLIENT_FIGHT_ERROR_INFO[error_index])
  else
    return
  end
  form.end_error_info_index = error_index
  form.end_error_info_time = os.time()
  insert_finght_error_info(form, cur_time, error_index, text)
end
function server_add_fight_error_info(error_index)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if not form.Visible then
    return
  end
  local gui = nx_value("gui")
  if is_find_dispose_fight_error_index(error_index) then
    return
  end
  if nx_number(form.end_error_info_index) == nx_number(error_index) then
    local delay_time = os.time() - form.end_error_info_time
    if nx_number(delay_time) < nx_number(TIME_DELAY_MAX) then
      return
    end
  end
  local text = "<Server\163\186>"
  if nx_number(error_index) >= nx_number(9000) and nx_number(error_index) < nx_number(9500) then
    text = nx_string(text) .. nx_string(gui.TextManager:GetFormatText(nx_string(error_index)))
  elseif nx_number(error_index) > nx_number(0) and nx_number(error_index) <= nx_number(SERVER_FIGHT_ERROE_INFO_INDEX_MAX) then
    text = nx_string(text) .. nx_string(SERVER_FIGHT_ERROR_INFO[error_index])
  else
    return
  end
  form.end_error_info_index = error_index
  form.end_error_info_time = os.time()
  insert_finght_error_info(form, cur_time, error_index, text)
end
function insert_finght_error_info(self, info_time, error_index, text_info)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local row = form.textbox_fight_error_info:InsertRow(-1)
  form.textbox_fight_error_info:SetGridText(row, 0, nx_widestr(error_index))
  form.textbox_fight_error_info:SetGridText(row, 1, nx_widestr(text_info))
  form.textbox_fight_error_info:SetColAlign(1, "left")
  form.textbox_fight_error_info:SelectRow(row)
end
function clear_fight_error_info(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.textbox_fight_error_info:ClearRow()
end
