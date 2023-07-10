require("util_gui")
local CLIENT_CUSTOMMSG_GUILD = 1014
local SUB_CUSTOMMSG_REQUEST_SELF_GUILD_CHASE_INFO = 67
local CHASE_OTHER = 0
local BE_CHASED_BY_OTHER = 1
local MLTBOX_ROW_HEIGHT = 20
local HEIGHT_OFFSET = 50
local FORM_NAME = "form_stage_main\\form_guild_war\\form_guild_chase_info"
local FORM_GUILD_CHASE_NAME = "form_stage_main\\form_guild_war\\form_guild_chase"
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  nx_set_value(FORM_NAME, form)
  request_guild_chase_data()
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  end_info_count_timer()
  nx_set_value(FORM_NAME, nx_null())
  nx_destroy(form)
end
function on_main_form_shut(form)
end
function on_btn_close_click(btn_close)
  local form = btn_close.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function request_guild_chase_data()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_SELF_GUILD_CHASE_INFO))
end
function on_rec_data(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local mltbox = form.mltbox
  if not nx_is_valid(mltbox) then
    return
  end
  mltbox.LeftTimeStr = nx_widestr(arg[1])
  mltbox.HtmlText = nx_widestr("")
  refresh_detail_info(form)
  start_info_count_timer()
end
function start_info_count_timer()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(1000, -1, nx_current(), "refresh_detail_info", form, -1, -1)
  end
end
function end_info_count_timer()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "refresh_detail_info", form)
  end
end
function refresh_detail_info(form)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local mltbox = form.mltbox
  if not nx_is_valid(mltbox) then
    return
  end
  local main_str = mltbox.LeftTimeStr
  if nx_ws_length(nx_widestr(main_str)) <= 0 then
    mltbox.HtmlText = nx_widestr(util_text("ui_None"))
    end_info_count_timer()
    mltbox.Height = MLTBOX_ROW_HEIGHT
    form.Height = mltbox.Height + HEIGHT_OFFSET
    form.lbl_bg.Height = mltbox.Height + HEIGHT_OFFSET - 10
    return
  end
  local show_text = nx_widestr("")
  local new_main_str = nx_widestr("")
  local new_count = 0
  local main_table = util_split_wstring(nx_widestr(main_str), "|")
  for i = 1, table.getn(main_table) do
    local sub_table = util_split_wstring(nx_widestr(main_table[i]), ",")
    if table.getn(sub_table) == 3 then
      local chase_type = nx_int(sub_table[1])
      local cur_guild_name = nx_widestr(sub_table[2])
      local left_time = nx_number(sub_table[3]) - nx_number(1)
      if nx_number(left_time) > nx_number(0) then
        if nx_int(chase_type) == nx_int(BE_CHASED_BY_OTHER) then
          show_text = show_text .. nx_widestr((gui.TextManager:GetFormatText("ui_be_chased_left_time", nx_widestr(cur_guild_name))))
        elseif nx_int(chase_type) == nx_int(CHASE_OTHER) then
          show_text = show_text .. nx_widestr((gui.TextManager:GetFormatText("ui_chase_other_left_time", nx_widestr(cur_guild_name))))
        end
        show_text = show_text .. nx_widestr(nx_execute(nx_string(FORM_GUILD_CHASE_NAME), "get_format_time", nx_number(left_time)))
        show_text = show_text .. nx_widestr("<br>")
        new_count = new_count + 1
        new_main_str = nx_widestr(new_main_str) .. nx_widestr(chase_type) .. nx_widestr(",") .. nx_widestr(cur_guild_name) .. nx_widestr(",") .. nx_widestr(left_time) .. nx_widestr("|")
      end
    end
  end
  mltbox.LeftTimeStr = new_main_str
  local new_mltbox_height = new_count * MLTBOX_ROW_HEIGHT
  if nx_int(new_mltbox_height) ~= nx_int(mltbox.Height) then
    mltbox.Height = new_count * MLTBOX_ROW_HEIGHT
    form.Height = mltbox.Height + HEIGHT_OFFSET
    form.lbl_bg.Height = mltbox.Height + HEIGHT_OFFSET - 10
  end
  mltbox.HtmlText = nx_widestr(show_text)
end
