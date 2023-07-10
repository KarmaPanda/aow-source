require("const_define")
require("util_gui")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\view_define")
require("game_object")
local StallLiuYan_Rec = "LiuYanNotes_Rec"
function main_form_init(self)
  self.Fixed = true
  return 1
end
function on_main_form_open(self)
  init_info(self)
  return 1
end
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
  return 1
end
function on_btn_clear_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_STALL_LIUYAN_CLEAR))
  return 1
end
function init_info(form)
  local game_client = nx_value("game_client")
  local gui = nx_value("gui")
  local client_role = game_client:GetPlayer()
  if not nx_is_valid(client_role) then
    return
  end
  if not client_role:FindRecord(StallLiuYan_Rec) then
    return
  end
  local CheckWords = nx_value("CheckWords")
  form.mltbox_notes:Clear()
  local item_row_num = client_role:GetRecordRows(StallLiuYan_Rec)
  if 0 < item_row_num then
    for i = item_row_num - 1, 0, -1 do
      local otherPlayerName = nx_widestr(client_role:QueryRecord(StallLiuYan_Rec, i, 0))
      local content = nx_widestr(client_role:QueryRecord(StallLiuYan_Rec, i, 1))
      local time1 = client_role:QueryRecord(StallLiuYan_Rec, i, 2)
      local str_date = nx_string(time1)
      local filter_content = CheckWords:CleanWords(nx_widestr(content))
      local info = gui.TextManager:GetFormatText("ui_stall_liuyan_notes", str_date, otherPlayerName, filter_content)
      form.mltbox_notes:AddHtmlText(nx_widestr(info), nx_int(-1))
    end
  end
end
