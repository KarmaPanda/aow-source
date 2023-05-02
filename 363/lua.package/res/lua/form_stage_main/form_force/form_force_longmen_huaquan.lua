require("util_gui")
require("custom_sender")
local cmd_image = {
  [2] = {
    [1] = "gui\\language\\ChineseS\\huaquan\\2_out.png",
    [2] = "gui\\language\\ChineseS\\huaquan\\2_on.png",
    [3] = "gui\\language\\ChineseS\\huaquan\\2_down.png",
    [4] = "gui\\language\\ChineseS\\huaquan\\2_forbid.png"
  },
  [3] = {
    [1] = "gui\\language\\ChineseS\\huaquan\\3_out.png",
    [2] = "gui\\language\\ChineseS\\huaquan\\3_on.png",
    [3] = "gui\\language\\ChineseS\\huaquan\\3_down.png",
    [4] = "gui\\language\\ChineseS\\huaquan\\3_forbid.png"
  },
  [4] = {
    [1] = "gui\\language\\ChineseS\\huaquan\\4_out.png",
    [2] = "gui\\language\\ChineseS\\huaquan\\4_on.png",
    [3] = "gui\\language\\ChineseS\\huaquan\\4_down.png",
    [4] = "gui\\language\\ChineseS\\huaquan\\4_forbid.png"
  },
  [5] = {
    [1] = "gui\\language\\ChineseS\\huaquan\\5_out.png",
    [2] = "gui\\language\\ChineseS\\huaquan\\5_on.png",
    [3] = "gui\\language\\ChineseS\\huaquan\\5_down.png",
    [4] = "gui\\language\\ChineseS\\huaquan\\5_forbid.png"
  },
  [6] = {
    [1] = "gui\\language\\ChineseS\\huaquan\\6_out.png",
    [2] = "gui\\language\\ChineseS\\huaquan\\6_on.png",
    [3] = "gui\\language\\ChineseS\\huaquan\\6_down.png",
    [4] = "gui\\language\\ChineseS\\huaquan\\6_forbid.png"
  },
  [7] = {
    [1] = "gui\\language\\ChineseS\\huaquan\\7_out.png",
    [2] = "gui\\language\\ChineseS\\huaquan\\7_on.png",
    [3] = "gui\\language\\ChineseS\\huaquan\\7_down.png",
    [4] = "gui\\language\\ChineseS\\huaquan\\7_forbid.png"
  },
  [8] = {
    [1] = "gui\\language\\ChineseS\\huaquan\\8_out.png",
    [2] = "gui\\language\\ChineseS\\huaquan\\8_on.png",
    [3] = "gui\\language\\ChineseS\\huaquan\\8_down.png",
    [4] = "gui\\language\\ChineseS\\huaquan\\8_forbid.png"
  },
  [9] = {
    [1] = "gui\\language\\ChineseS\\huaquan\\9_out.png",
    [2] = "gui\\language\\ChineseS\\huaquan\\9_on.png",
    [3] = "gui\\language\\ChineseS\\huaquan\\9_down.png",
    [4] = "gui\\language\\ChineseS\\huaquan\\9_forbid.png"
  },
  [10] = {
    [1] = "gui\\language\\ChineseS\\huaquan\\10_out.png",
    [2] = "gui\\language\\ChineseS\\huaquan\\10_on.png",
    [3] = "gui\\language\\ChineseS\\huaquan\\10_down.png",
    [4] = "gui\\language\\ChineseS\\huaquan\\10_forbid.png"
  }
}
local cmd_tips = {
  [2] = "ui_han_2",
  [3] = "ui_han_3",
  [4] = "ui_han_4",
  [5] = "ui_han_5",
  [6] = "ui_han_6",
  [7] = "ui_han_7",
  [8] = "ui_han_8",
  [9] = "ui_han_9",
  [10] = "ui_han_10"
}
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = gui.Height - form.Height - 120
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_time", form)
  timer:Register(1000, -1, nx_current(), "on_update_time", form, -1, -1)
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", form)
  end
  nx_destroy(form)
end
function on_update_time(form, param1, param2)
  form.pbar_time.Value = nx_int(form.pbar_time.Value) + 10
  if nx_int(form.pbar_time.Value) >= nx_int(100) then
    form:Close()
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_rbtn_1_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    local index = nx_int(rbtn.DataSource)
    for i = index + 1, index + 5 do
      local rbtn_2 = form.groupbox_2:Find("rbtn_" .. nx_string(5 + i - index))
      if nx_is_valid(rbtn_2) then
        rbtn_2.NormalImage = nx_string(cmd_image[i][1])
        rbtn_2.FocusImage = nx_string(cmd_image[i][2])
        rbtn_2.CheckedImage = nx_string(cmd_image[i][3])
        rbtn_2.DisableImage = nx_string(cmd_image[i][4])
        rbtn_2.HintText = nx_widestr(util_text(cmd_tips[i]))
      end
    end
    form.groupbox_2.Visible = true
    form.select1 = nx_int(rbtn.DataSource)
    nx_execute("custom_sender", "custom_send_bodyguardoffice_sender", 13, form.select1)
  end
end
function on_rbtn_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    nx_execute("custom_sender", "custom_send_bodyguardoffice_sender", 14, form.select1 + nx_int(rbtn.DataSource))
  end
end
function show_form(max_time)
  local form = util_get_form("form_stage_main\\form_force\\form_force_longmen_huaquan", true)
  form.Visible = true
  form:Show()
  form.pbar_time.Maximum = nx_int(max_time) * 10
end
function close_form()
  local form = util_get_form("form_stage_main\\form_force\\form_force_longmen_huaquan", false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
