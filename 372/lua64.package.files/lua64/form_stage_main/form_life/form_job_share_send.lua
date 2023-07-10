require("share\\itemtype_define")
require("share\\view_define")
local g_form_path = "form_stage_main\\form_life\\form_job_share_send"
local g_share_pack = {
  VIEWPORT_TOOL,
  VIEWPORT_EQUIP_TOOL,
  VIEWPORT_MATERIAL_TOOL
}
local g_share_type = {
  compose = "ui_FuWuType_0",
  enhance = "ui_FuWuType_1",
  pizhushu = "ui_FuWuType_2",
  pizhuhua = "ui_FuWuType_3",
  chaolu = "ui_FuWuType_4"
}
local g_share_proc = {
  sendrequest = "ui_fuwuinfo_0",
  requestsuccess = "ui_fuwuinfo_1",
  requestfailed = "ui_fuwuinfo_2",
  requestend = "ui_fuwuinfo_3",
  requestbreak = "ui_fuwuinfo_4",
  requestunknowerror = "ui_fuwuinfo_5",
  requestlookserver = "ui_fuwuinfo_6"
}
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  clear_form(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form.Visible = false
  form:Close()
end
function clear_form(form)
  form.lbl_share_name.Text = ""
  form.lbl_name.Text = ""
  form.ImageControlGrid_prop:Clear()
  form.mltbox_msg.HtmlText = ""
end
function open_form_job(arg_num, ...)
  local form = nx_value(g_form_path)
  if not nx_is_valid(form) then
    if nx_string(arg[2]) == "sendrequest" then
      form = nx_execute("util_gui", "util_get_form", g_form_path, true, false)
      if not nx_is_valid(form) then
        nx_log(g_form_path .. "open filed")
        return
      end
      form:Show()
    else
      return
    end
  elseif nx_string(arg[2]) == "sendrequest" then
    clear_form(form)
  end
  form.Visible = true
  message_sort_function(form, arg_num, unpack(arg))
end
function message_sort_function(form, num, ...)
  local gui = nx_value("gui")
  if nx_string(arg[2]) == "sendrequest" then
    if nx_string(arg[1]) ~= "compose" then
      show_name(form, arg[3], arg[4], true)
    else
      show_name(form, arg[3], arg[4], false)
    end
    local Text_title = gui.TextManager:GetText(nx_string(g_share_type[arg[1]]))
    form.lbl_share_name.Text = nx_widestr(nx_string(Text_title))
  end
  local ui_str = nx_string(g_share_proc[arg[2]])
  local showtext = ""
  if ui_str == "ui_fuwuinfo_5" or ui_str == "ui_fuwuinfo_0" then
    showtext = gui.TextManager:GetText(ui_str)
  else
    showtext = gui.TextManager:GetFormatText(ui_str, nx_string(form.lbl_name.Text))
  end
  form.mltbox_msg:AddHtmlText(nx_widestr(showtext), -1)
end
function show_name(form, name, propid, isskill)
  form.lbl_name.Text = nx_widestr(nx_string(name))
  local photo = ""
  local name = ""
  if isskill then
    photo, name = get_skill_info(propid)
  else
    photo, name = get_compose_info(propid)
  end
  form.ImageControlGrid_prop:AddItem(0, photo, name, nx_int(1), nx_int(1))
  form.ImageControlGrid_prop:SetItemAddInfo(0, nx_int(1), nx_widestr(propid))
end
function get_skill_info(skillid)
  local game_client = nx_value("game_client")
  local gui = nx_value("gui")
  if not nx_is_valid(gui) or not nx_is_valid(game_client) then
    return "", ""
  end
  local photo = ""
  local name = ""
  for i, szview in pairs(g_share_pack) do
    local view = game_client:GetView(nx_string(szview))
    if not nx_is_valid(view) then
      return "", ""
    end
    local viewobj_list = view:GetViewObjList()
    for j, obj in pairs(viewobj_list) do
      local unquid = obj:QueryProp("UniqueID")
      if nx_string(skillid) == nx_string(unquid) then
        local confid = obj:QueryProp("ConfigID")
        name = gui.TextManager:GetFormatText(confid)
        photo = nx_execute("util_static_data", "queryprop_by_object", obj, "Photo")
        break
      end
    end
  end
  return photo, name
end
function get_compose_info(formulaid)
  local gui = nx_value("gui")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(gui) or not nx_is_valid(ItemQuery) then
    return "", ""
  end
  local job_compose_ini = nx_execute("util_functions", "get_ini", "share\\Item\\life_formula.ini")
  if not nx_is_valid(job_compose_ini) then
    return "", ""
  end
  local sec_index = job_compose_ini:FindSectionIndex(formulaid)
  if sec_index < 0 then
    nx_log("share\\Item\\life_formula.ini sec_index = " .. nx_string(formulaid))
    return "", ""
  end
  local porduct_item = job_compose_ini:ReadString(sec_index, "ComposeResult", "")
  local bExist = ItemQuery:FindItemByConfigID(porduct_item)
  if bExist then
    local item_type = nx_number(ItemQuery:GetItemPropByConfigID(porduct_item, "ItemType"))
    local photo = ""
    if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
      photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", porduct_item, "Photo")
    else
      photo = ItemQuery:GetItemPropByConfigID(porduct_item, "Photo")
    end
    local name = gui.TextManager:GetFormatText(porduct_item)
    return photo, name
  end
  return "", ""
end
function on_ImageControlGrid_prop_mousein_grid(grid, index)
end
function on_ImageControlGrid_prop_mouseout_grid(grid, index)
end
