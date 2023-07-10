require("util_gui")
local FORM_NAME = "form_stage_main\\form_helper\\form_royal_treasure_helper"
local TYPE_SET = {
  royal_treasure = {
    title = "ui_royal_helper_title",
    info = {
      {
        "gui\\special\\freshman\\wcbz\\1.png",
        "ui_royal_helper_1"
      },
      {
        "gui\\special\\freshman\\wcbz\\2.png",
        "ui_royal_helper_2"
      },
      {
        "gui\\special\\freshman\\wcbz\\3.png",
        "ui_royal_helper_3"
      },
      {
        "gui\\special\\freshman\\wcbz\\4.png",
        "ui_royal_helper_4"
      },
      {
        "gui\\special\\freshman\\wcbz\\5.png",
        "ui_royal_helper_5"
      }
    }
  },
  guild_cross_match = {
    title = "ui_guild_cross_match_title",
    info = {
      {
        "gui\\special\\yhg_wuque\\1.png",
        "ui_guild_cross_match_help_1"
      },
      {
        "gui\\special\\yhg_wuque\\2.png",
        "ui_guild_cross_match_help_2"
      },
      {
        "gui\\special\\yhg_wuque\\1.png",
        "ui_guild_cross_match_help_3"
      },
      {
        "gui\\special\\yhg_wuque\\2.png",
        "ui_guild_cross_match_help_4"
      },
      {
        "gui\\special\\yhg_wuque\\1.png",
        "ui_guild_cross_match_help_5"
      }
    }
  }
}
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  if nx_find_custom(form, "open_type") then
    form.lbl_title_1.Text = util_text(TYPE_SET[form.open_type].title)
  end
  form.cur_page = 1
  form.btn_priv.Enabled = false
  refresh_info(form)
end
function on_main_form_close(form)
  nx_destroy(form)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(812) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("ui_actreward_onekey_switch"))
    return
  end
  local dbomall_path = "form_stage_main\\form_dbomall\\form_dbomall"
  if nx_is_valid(dbomall_form) and dbomall_form.Visible ~= false then
    dbomall_form.Visible = false
    dbomall_form:Close()
  else
    util_auto_show_hide_form(dbomall_path)
    nx_execute(dbomall_path, "open_form", "form_stage_main\\form_dbomall\\form_dbortreasure")
  end
end
function open_form(type)
  local form = util_get_form(FORM_NAME, true)
  form.open_type = type
  form:Show()
  form.Visible = true
end
function refresh_info(form)
  if not nx_is_valid(form) then
    return
  end
  if form.cur_page > get_total_pages(form) then
    return
  end
  local image_path = TYPE_SET[form.open_type].info[form.cur_page][1]
  local desc_id = TYPE_SET[form.open_type].info[form.cur_page][2]
  form.lbl_pic.BackImage = image_path
  form.mltbox_desc:Clear()
  form.mltbox_desc:AddHtmlText(util_text(desc_id), -1)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  return
end
function on_btn_priv_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.cur_page = form.cur_page - 1
  if form.cur_page < 1 then
    form.cur_page = 1
  end
  if form.cur_page == 1 then
    form.btn_priv.Enabled = false
  else
    form.btn_priv.Enabled = true
  end
  local total_page = get_total_pages(form)
  if total_page > form.cur_page then
    form.btn_ok.Visible = false
    form.btn_next.Visible = true
  end
  refresh_info(form)
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.cur_page = form.cur_page + 1
  local total_page = get_total_pages(form)
  if total_page <= form.cur_page then
    form.cur_page = total_page
    form.btn_ok.Visible = true
    form.btn_next.Visible = false
  end
  form.btn_priv.Enabled = true
  refresh_info(form)
end
function get_total_pages(form)
  if not nx_find_custom(form, "open_type") then
    return 0
  end
  return table.getn(TYPE_SET[form.open_type].info)
end
