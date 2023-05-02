require("util_gui")
local DSD_ASK_ACPICTY = 4
local DSD_BUY_ACPICTY = 5
local DSD_BUY_ACPICTY_ITEM = 6
local DSD_BUY_ACPICTY_NEWITEM = 8
local DSD_BUY_ACPICTY_SILVER = 10
local DSD_BUY_ACPICTY_CARD = 11
local DSD_BUY_ACPICTY_XIUWEI = 12
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  local form_depot = nx_value("form_stage_main\\form_depot")
  if not nx_is_valid(form_depot) then
    return
  end
  local next_type = form_depot.next_type
  if next_type == -1 then
    return
  end
  if form_depot.next_type < 0 then
    form.cbtn_wuxue.Enabled = false
  end
  if 0 > form_depot.next_type_item then
    form.cbtn_item.Enabled = false
  end
  if 0 > form_depot.next_type_newitem then
    form.cbtn_newitem.Enabled = false
  end
  if 0 > form_depot.next_type_silver then
    form.cbtn_silver.Enabled = false
  end
  if 0 > form_depot.next_type_card then
    form.cbtn_card.Enabled = false
  end
  if 0 > form_depot.next_type_xiuwei then
    form.cbtn_xiuwei.Enabled = false
  end
  local depot_price = {
    300,
    400,
    500,
    600
  }
  local depot_cap = {
    3,
    4,
    5,
    6
  }
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_addpot_tip")
  gui.TextManager:Format_AddParam(nx_int(depot_price[next_type + 1]))
  gui.TextManager:Format_AddParam(nx_int(depot_cap[next_type + 1]))
  local text = gui.TextManager:Format_GetText()
  form.info_mltbox.HtmlText = nx_widestr(text)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_cbtn_wuxue_click(cbtn)
  local form = cbtn.ParentForm
  cbtn.Checked = true
  form.cbtn_item.Checked = false
  form.cbtn_newitem.Checked = false
  form.cbtn_silver.Checked = false
  form.cbtn_card.Checked = false
  form.cbtn_xiuwei.Checked = false
  form.btn_confirm.Enabled = false
  local form_depot = nx_value("form_stage_main\\form_depot")
  if not nx_is_valid(form_depot) then
    return
  end
  local gui = nx_value("gui")
  local next_type = form_depot.next_type
  if next_type == -1 then
    form.info_mltbox.HtmlText = nx_widestr(gui.TextManager:GetText("ui_addpot_tip_4"))
    return
  end
  local depot_price = {
    300,
    400,
    500,
    600
  }
  local depot_cap = {
    3,
    4,
    5,
    6
  }
  form.btn_confirm.Enabled = true
  gui.TextManager:Format_SetIDName("ui_addpot_tip")
  gui.TextManager:Format_AddParam(nx_int(depot_price[next_type + 1]))
  gui.TextManager:Format_AddParam(nx_int(depot_cap[next_type + 1]))
  local text = gui.TextManager:Format_GetText()
  form.info_mltbox.HtmlText = nx_widestr(text)
end
function on_cbtn_item_click(cbtn)
  local form = cbtn.ParentForm
  cbtn.Checked = true
  form.cbtn_wuxue.Checked = false
  form.cbtn_newitem.Checked = false
  form.cbtn_silver.Checked = false
  form.cbtn_card.Checked = false
  form.cbtn_xiuwei.Checked = false
  form.btn_confirm.Enabled = false
  local form_depot = nx_value("form_stage_main\\form_depot")
  if not nx_is_valid(form_depot) then
    return
  end
  local gui = nx_value("gui")
  local next_type = form_depot.next_type_item
  if next_type == -1 then
    form.info_mltbox.HtmlText = nx_widestr(gui.TextManager:GetText("ui_addpot_tip_4"))
    return
  end
  local depot_price = {
    3,
    4,
    5,
    6
  }
  local depot_cap = {
    3,
    4,
    5,
    6
  }
  form.btn_confirm.Enabled = true
  gui.TextManager:Format_SetIDName("ui_addpot_tip_2")
  gui.TextManager:Format_AddParam(nx_int(depot_price[next_type + 1]))
  gui.TextManager:Format_AddParam(nx_int(depot_cap[next_type + 1]))
  local text = gui.TextManager:Format_GetText()
  form.info_mltbox.HtmlText = nx_widestr(text)
end
function on_cbtn_newitem_click(cbtn)
  local form = cbtn.ParentForm
  cbtn.Checked = true
  form.cbtn_wuxue.Checked = false
  form.cbtn_item.Checked = false
  form.cbtn_silver.Checked = false
  form.cbtn_card.Checked = false
  form.cbtn_xiuwei.Checked = false
  form.btn_confirm.Enabled = false
  local form_depot = nx_value("form_stage_main\\form_depot")
  if not nx_is_valid(form_depot) then
    return
  end
  local gui = nx_value("gui")
  local next_type = form_depot.next_type_newitem
  if next_type == -1 then
    form.info_mltbox.HtmlText = nx_widestr(gui.TextManager:GetText("ui_addpot_tip_4"))
    return
  end
  local depot_price = {
    3,
    4,
    5,
    6
  }
  local depot_cap = {
    3,
    4,
    5,
    6
  }
  form.btn_confirm.Enabled = true
  gui.TextManager:Format_SetIDName("ui_addpot_tip_3")
  gui.TextManager:Format_AddParam(nx_int(depot_price[next_type + 1]))
  gui.TextManager:Format_AddParam(nx_int(depot_cap[next_type + 1]))
  local text = gui.TextManager:Format_GetText()
  form.info_mltbox.HtmlText = nx_widestr(text)
end
function on_cbtn_silver_click(cbtn)
  local form = cbtn.ParentForm
  cbtn.Checked = true
  form.cbtn_wuxue.Checked = false
  form.cbtn_item.Checked = false
  form.cbtn_newitem.Checked = false
  form.cbtn_card.Checked = false
  form.cbtn_xiuwei.Checked = false
  form.btn_confirm.Enabled = false
  local form_depot = nx_value("form_stage_main\\form_depot")
  if not nx_is_valid(form_depot) then
    return
  end
  local gui = nx_value("gui")
  local next_type = form_depot.next_type_silver
  if next_type == -1 then
    form.info_mltbox.HtmlText = nx_widestr(gui.TextManager:GetText("ui_addpot_tip_4"))
    return
  end
  local depot_price = {
    90,
    120,
    150,
    180
  }
  local depot_cap = {
    3,
    4,
    5,
    6
  }
  form.btn_confirm.Enabled = true
  gui.TextManager:Format_SetIDName("ui_addpot_tip_5")
  gui.TextManager:Format_AddParam(nx_int(depot_price[next_type + 1]))
  gui.TextManager:Format_AddParam(nx_int(depot_cap[next_type + 1]))
  local text = gui.TextManager:Format_GetText()
  form.info_mltbox.HtmlText = nx_widestr(text)
end
function on_cbtn_card_click(cbtn)
  local form = cbtn.ParentForm
  cbtn.Checked = true
  form.cbtn_wuxue.Checked = false
  form.cbtn_item.Checked = false
  form.cbtn_newitem.Checked = false
  form.cbtn_silver.Checked = false
  form.cbtn_xiuwei.Checked = false
  form.btn_confirm.Enabled = false
  local form_depot = nx_value("form_stage_main\\form_depot")
  if not nx_is_valid(form_depot) then
    return
  end
  local gui = nx_value("gui")
  local next_type = form_depot.next_type_card
  if next_type == -1 then
    form.info_mltbox.HtmlText = nx_widestr(gui.TextManager:GetText("ui_addpot_tip_4"))
    return
  end
  local depot_price = {
    30,
    40,
    50,
    60,
    60,
    60,
    60,
    60,
    60,
    60,
    60,
    60,
    60,
    60,
    60,
    60,
    60,
    60,
    60,
    60,
    60,
    60
  }
  local depot_cap = {
    3,
    4,
    5,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    6
  }
  form.btn_confirm.Enabled = true
  gui.TextManager:Format_SetIDName("ui_addpot_tip_6")
  gui.TextManager:Format_AddParam(nx_int(depot_price[next_type + 1]))
  gui.TextManager:Format_AddParam(nx_int(depot_cap[next_type + 1]))
  local text = gui.TextManager:Format_GetText()
  form.info_mltbox.HtmlText = nx_widestr(text)
end
function on_cbtn_xiuwei_click(cbtn)
  local form = cbtn.ParentForm
  cbtn.Checked = true
  form.cbtn_wuxue.Checked = false
  form.cbtn_item.Checked = false
  form.cbtn_newitem.Checked = false
  form.cbtn_silver.Checked = false
  form.cbtn_card.Checked = false
  form.btn_confirm.Enabled = false
  local form_depot = nx_value("form_stage_main\\form_depot")
  if not nx_is_valid(form_depot) then
    return
  end
  local gui = nx_value("gui")
  local next_type = form_depot.next_type_xiuwei
  if next_type == -1 then
    form.info_mltbox.HtmlText = nx_widestr(gui.TextManager:GetText("ui_addpot_tip_4"))
    return
  end
  local depot_price = {
    450000,
    600000,
    750000,
    900000,
    900000,
    900000,
    900000,
    900000,
    900000,
    900000
  }
  local depot_cap = {
    3,
    4,
    5,
    6,
    6,
    6,
    6,
    6,
    6,
    6
  }
  form.btn_confirm.Enabled = true
  gui.TextManager:Format_SetIDName("ui_addpot_tip_7")
  gui.TextManager:Format_AddParam(nx_int(depot_price[next_type + 1]))
  gui.TextManager:Format_AddParam(nx_int(depot_cap[next_type + 1]))
  local text = gui.TextManager:Format_GetText()
  form.info_mltbox.HtmlText = nx_widestr(text)
end
function on_btn_confirm_click(btn)
  local form_pot = nx_value("form_stage_main\\form_addpot")
  if not nx_is_valid(form_pot) then
    return
  end
  local form_depot = nx_value("form_stage_main\\form_depot")
  if not nx_is_valid(form_depot) then
    return
  end
  local form = btn.ParentForm
  local gui = nx_value("gui")
  if form.cbtn_wuxue.Checked == true then
    local next_type = form_depot.next_type
    if next_type == -1 then
      return
    end
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local depot_price = {
      300,
      400,
      500,
      600
    }
    local depot_cap = {
      3,
      4,
      5,
      6
    }
    gui.TextManager:Format_SetIDName("ui_addpot_tip")
    gui.TextManager:Format_AddParam(nx_int(depot_price[next_type + 1]))
    gui.TextManager:Format_AddParam(nx_int(depot_cap[next_type + 1]))
    local text = gui.TextManager:Format_GetText()
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "send_depot_msg", DSD_BUY_ACPICTY, next_type)
    end
  elseif form.cbtn_item.Checked == true then
    local next_type = form_depot.next_type_item
    if next_type == -1 then
      return
    end
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local depot_price = {
      3,
      4,
      5,
      6
    }
    local depot_cap = {
      3,
      4,
      5,
      6
    }
    gui.TextManager:Format_SetIDName("ui_addpot_tip_2")
    gui.TextManager:Format_AddParam(nx_int(depot_price[next_type + 1]))
    gui.TextManager:Format_AddParam(nx_int(depot_cap[next_type + 1]))
    local text = gui.TextManager:Format_GetText()
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "send_depot_msg", DSD_BUY_ACPICTY_ITEM, next_type)
    end
  elseif form.cbtn_newitem.Checked == true then
    local next_type = form_depot.next_type_newitem
    if next_type == -1 then
      return
    end
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local depot_price = {
      3,
      4,
      5,
      6
    }
    local depot_cap = {
      3,
      4,
      5,
      6
    }
    gui.TextManager:Format_SetIDName("ui_addpot_tip_3")
    gui.TextManager:Format_AddParam(nx_int(depot_price[next_type + 1]))
    gui.TextManager:Format_AddParam(nx_int(depot_cap[next_type + 1]))
    local text = gui.TextManager:Format_GetText()
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "send_depot_msg", DSD_BUY_ACPICTY_NEWITEM, next_type)
    end
  elseif form.cbtn_silver.Checked == true then
    local next_type = form_depot.next_type_silver
    if next_type == -1 then
      return
    end
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local depot_price = {
      90,
      120,
      150,
      180
    }
    local depot_cap = {
      3,
      4,
      5,
      6
    }
    gui.TextManager:Format_SetIDName("ui_addpot_tip_5")
    gui.TextManager:Format_AddParam(nx_int(depot_price[next_type + 1]))
    gui.TextManager:Format_AddParam(nx_int(depot_cap[next_type + 1]))
    local text = gui.TextManager:Format_GetText()
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "send_depot_msg", DSD_BUY_ACPICTY_SILVER, next_type)
    end
  elseif form.cbtn_card.Checked == true then
    local next_type = form_depot.next_type_card
    if next_type == -1 then
      return
    end
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local depot_price = {
      30,
      40,
      50,
      60,
      60,
      60,
      60,
      60,
      60,
      60,
      60,
      60,
      60,
      60,
      60,
      60,
      60,
      60,
      60,
      60,
      60,
      60
    }
    local depot_cap = {
      3,
      4,
      5,
      6,
      6,
      6,
      6,
      6,
      6,
      6,
      6,
      6,
      6,
      6,
      6,
      6,
      6,
      6,
      6,
      6,
      6,
      6
    }
    gui.TextManager:Format_SetIDName("ui_addpot_tip_6")
    gui.TextManager:Format_AddParam(nx_int(depot_price[next_type + 1]))
    gui.TextManager:Format_AddParam(nx_int(depot_cap[next_type + 1]))
    local text = gui.TextManager:Format_GetText()
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "send_depot_msg", DSD_BUY_ACPICTY_CARD, next_type)
    end
  elseif form.cbtn_xiuwei.Checked == true then
    local next_type = form_depot.next_type_xiuwei
    if next_type == -1 then
      return
    end
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local depot_price = {
      450000,
      600000,
      750000,
      900000,
      900000,
      900000,
      900000,
      900000,
      900000,
      900000
    }
    local depot_cap = {
      3,
      4,
      5,
      6,
      6,
      6,
      6,
      6,
      6,
      6
    }
    gui.TextManager:Format_SetIDName("ui_addpot_tip_7")
    gui.TextManager:Format_AddParam(nx_int(depot_price[next_type + 1]))
    gui.TextManager:Format_AddParam(nx_int(depot_cap[next_type + 1]))
    local text = gui.TextManager:Format_GetText()
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "send_depot_msg", DSD_BUY_ACPICTY_XIUWEI, next_type)
    end
  end
  form_pot:Close()
end
function on_cbtn_wuxue_get_capture(cbtn)
  local form_depot = nx_value("form_stage_main\\form_depot")
  if not nx_is_valid(form_depot) then
    return
  end
  local gui = nx_value("gui")
  local mouse_x, mouse_z = gui:GetCursorPosition()
  local next_type = form_depot.next_type
  local text = ""
  if 0 <= next_type then
    return
  elseif next_type == -1 then
    text = gui.TextManager:GetText("tip_depot_limit_02")
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), mouse_x, mouse_z)
end
function on_cbtn_wuxue_lost_capture(cbtn)
  nx_execute("tips_game", "hide_tip")
end
function on_cbtn_item_get_capture(cbtn)
  local form_depot = nx_value("form_stage_main\\form_depot")
  if not nx_is_valid(form_depot) then
    return
  end
  local gui = nx_value("gui")
  local mouse_x, mouse_z = gui:GetCursorPosition()
  local next_type = form_depot.next_type_item
  local text = ""
  if 0 <= next_type then
    return
  elseif next_type == -1 then
    text = gui.TextManager:GetText("tip_depot_limit_02")
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), mouse_x, mouse_z)
end
function on_cbtn_item_lost_capture(cbtn)
  nx_execute("tips_game", "hide_tip")
end
function on_cbtn_newitem_get_capture(cbtn)
  local form_depot = nx_value("form_stage_main\\form_depot")
  if not nx_is_valid(form_depot) then
    return
  end
  local gui = nx_value("gui")
  local mouse_x, mouse_z = gui:GetCursorPosition()
  local next_type = form_depot.next_type_newitem
  local text = ""
  if 0 <= next_type then
    return
  elseif next_type == -1 then
    text = gui.TextManager:GetText("tip_depot_limit_02")
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), mouse_x, mouse_z)
end
function on_cbtn_newitem_lost_capture(cbtn)
  nx_execute("tips_game", "hide_tip")
end
function on_cbtn_silver_get_capture(cbtn)
  local form_depot = nx_value("form_stage_main\\form_depot")
  if not nx_is_valid(form_depot) then
    return
  end
  local gui = nx_value("gui")
  local mouse_x, mouse_z = gui:GetCursorPosition()
  local next_type = form_depot.next_type_silver
  local text = ""
  if 0 <= next_type then
    return
  elseif next_type == -1 then
    text = gui.TextManager:GetText("tip_depot_limit_02")
  elseif next_type == -2 then
    text = gui.TextManager:GetText("tip_depot_limit_01")
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), mouse_x, mouse_z)
end
function on_cbtn_silver_lost_capture(cbtn)
  nx_execute("tips_game", "hide_tip")
end
function on_cbtn_card_get_capture(cbtn)
  local form_depot = nx_value("form_stage_main\\form_depot")
  if not nx_is_valid(form_depot) then
    return
  end
  local gui = nx_value("gui")
  local mouse_x, mouse_z = gui:GetCursorPosition()
  local next_type = form_depot.next_type_card
  local text = ""
  if 0 <= next_type then
    return
  elseif next_type == -1 then
    text = gui.TextManager:GetText("tip_depot_limit_02")
  elseif next_type == -2 then
    text = gui.TextManager:GetText("tip_depot_limit_01")
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), mouse_x, mouse_z)
end
function on_cbtn_card_lost_capture(cbtn)
  nx_execute("tips_game", "hide_tip")
end
function on_cbtn_xiuwei_get_capture(cbtn)
  local form_depot = nx_value("form_stage_main\\form_depot")
  if not nx_is_valid(form_depot) then
    return
  end
  local gui = nx_value("gui")
  local mouse_x, mouse_z = gui:GetCursorPosition()
  local next_type = form_depot.next_type_xiuwei
  local text = ""
  if 0 <= next_type then
    return
  elseif next_type == -1 then
    text = gui.TextManager:GetText("tip_depot_limit_02")
  elseif next_type == -2 then
    text = gui.TextManager:GetText("tip_depot_limit_01")
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), mouse_x, mouse_z)
end
function on_cbtn_xiuwei_lost_capture(cbtn)
  nx_execute("tips_game", "hide_tip")
end
