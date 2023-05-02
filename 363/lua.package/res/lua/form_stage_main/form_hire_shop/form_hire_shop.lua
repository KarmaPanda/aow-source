require("util_gui")
require("util_functions")
function main_form_init(form)
  form.Fixed = false
  form.FirstInflag = true
  form.npcid = nil
  form.owner = ""
  form.remain_time = 0
  form.is_online = 0
  form.CurMaxCapacity = 0
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  if form.FirstInflag then
    local page_additem = util_get_form("form_stage_main\\form_hire_shop\\form_hire_shop_additem", true, false)
    if form:Add(page_additem) then
      form.page_additem = page_additem
      form.page_additem.Visible = true
      form.page_additem.Fixed = true
      form.page_additem.Left = 0
      form.page_additem.Top = 40
      form.page_additem.npcid = form.npcid
      nx_execute("form_stage_main\\form_hire_shop\\form_hire_shop_additem", "init_shop_info", page_additem)
    end
    local page_style = util_get_form("form_stage_main\\form_hire_shop\\form_hire_shop_style", true, false)
    if form:Add(page_style) then
      form.page_style = page_style
      form.page_style.Visible = false
      form.page_style.Fixed = true
      form.page_style.Left = 18
      form.page_style.Top = 50
      form.page_style.npcid = form.npcid
    end
    local page_npc = util_get_form("form_stage_main\\form_hire_shop\\form_hire_shop_npc", true, false)
    if form:Add(page_npc) then
      form.page_npc = page_npc
      form.page_npc.Visible = false
      form.page_npc.Fixed = true
      form.page_npc.Left = 18
      form.page_npc.Top = 50
      form.page_npc.npcid = form.npcid
    end
    local page_shop = util_get_form("form_stage_main\\form_hire_shop\\form_hire_shop_show", true, false)
    if form:Add(page_shop) then
      form.page_shop = page_shop
      form.page_shop.Visible = false
      form.page_shop.Fixed = true
      form.page_shop.Left = 18
      form.page_shop.Top = 50
      form.page_shop.npcid = form.npcid
      form.page_shop.owner = form.owner
      form.page_shop.remain_time = form.remain_time
      form.page_shop.is_online = form.is_online
      form.page_shop.CurMaxCapacity = form.CurMaxCapacity
      nx_execute("form_stage_main\\form_hire_shop\\form_hire_shop_show", "on_main_form_open", page_shop)
    end
    form.FirstInflag = false
  end
  form.page_shop.npcid = form.npcid
  form.page_style.npcid = form.npcid
  form.page_additem.npcid = form.npcid
  form.page_npc.npcid = form.npcid
  form.page_shop.remain_time = form.remain_time
  local game_client = nx_value("game_client")
  local ident = nx_string(form.npcid)
  local npc = game_client:GetSceneObj(ident)
  local owner_name = ""
  if nx_is_valid(npc) then
    owner_name = npc:QueryProp("ShopOwner")
  else
    owner_name = form.owner
  end
  local client_player = game_client:GetPlayer()
  local player_name = client_player:QueryProp("Name")
  if owner_name ~= player_name then
    form.rbtn_1.Visible = false
    form.rbtn_2.Visible = false
    form.rbtn_3.Visible = true
    form.rbtn_NPC.Visible = false
    form.lbl_shangpu.Visible = false
    form.lbl_guyong.Visible = false
    form.lbl_shezhi.Visible = false
    form.page_shop.Visible = true
    form.page_additem.Visible = false
  else
    nx_execute("form_stage_main\\form_hire_shop\\form_hire_shop_additem", "set_shop_state", form.page_additem)
  end
  return 1
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return false
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local ident = nx_string(form.npcid)
  local npc = game_client:GetSceneObj(ident)
  local owner_name = ""
  if nx_is_valid(npc) then
    owner_name = npc:QueryProp("ShopOwner")
  else
    owner_name = form.owner
  end
  local client_player = game_client:GetPlayer()
  local player_name = client_player:QueryProp("Name")
  if owner_name == player_name then
    if not nx_is_valid(npc) then
      return false
    end
    local shopState = npc:QueryProp("ShopState")
    if shopState == 0 then
      local gui = nx_value("gui")
      local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
      local text = gui.TextManager:GetText("37023", name)
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
      dialog:ShowModal()
      local res = nx_wait_event(100000000, dialog, "confirm_return")
      if res == "ok" then
        if not nx_is_valid(form) then
          return
        end
        local game_visual = nx_value("game_visual")
        if nx_is_valid(game_visual) then
          game_visual:CustomSend(nx_int(7), nx_int(9), nx_int(1), form.npcid)
        end
      end
    end
  end
  if not nx_is_valid(form) then
    return false
  end
  nx_execute("form_stage_main\\form_hire_shop\\form_hire_shop_additem", "on_main_form_close", form.page_additem)
  nx_execute("form_stage_main\\form_hire_shop\\form_hire_shop_show", "on_main_form_close", form.page_shop)
  form:Close()
  return 1
end
function on_rbtn_checked_changed(rbtn)
  if rbtn.Checked ~= true then
    return false
  end
  local form = rbtn.ParentForm
  local tab = rbtn.TabIndex
  hide_all_sub_form(form)
  if tab == 1 then
    if not nx_is_valid(form.page_additem) then
      local page_additem = util_get_form("form_stage_main\\form_hire_shop\\form_hire_shop_additem", true, false)
      if form:Add(page_additem) then
        form.page_additem = page_additem
        form.page_additem.Visible = true
        form.page_additem.Fixed = true
        form.page_additem.Left = 18
        form.page_additem.Top = 50
        form.page_additem.npcid = form.npcid
      end
    end
    form.page_additem.Visible = true
    form:ToFront(form.page_additem)
  elseif tab == 2 then
    if not nx_is_valid(form.page_style) then
      local page_style = util_get_form("form_stage_main\\form_hire_shop\\form_hire_shop_style", true, false)
      if form:Add(page_style) then
        form.page_style = page_style
        form.page_style.Visible = true
        form.page_style.Fixed = true
        form.page_style.Left = 18
        form.page_style.Top = 50
        form.page_style.npcid = form.npcid
      end
    end
    form.page_style.Visible = true
    form:ToFront(form.page_style)
    nx_execute("form_stage_main\\form_hire_shop\\form_hire_shop_style", "reset_grid_data", form.page_style)
  elseif tab == 3 then
    if not nx_is_valid(form.page_shop) then
      local page_shop = util_get_form("form_stage_main\\form_hire_shop\\form_hire_shop_show", true, false)
      if form:Add(page_shop) then
        form.page_shop = page_shop
        form.page_shop.Visible = true
        form.page_shop.Fixed = true
        form.page_shop.Left = 18
        form.page_shop.Top = 50
        form.page_shop.npcid = form.npcid
        form.page_shop.remain_time = form.remain_time
      end
    end
    form.page_shop.Visible = true
    form:ToFront(form.page_shop)
    nx_execute("form_stage_main\\form_hire_shop\\form_hire_shop_show", "on_main_form_open", form.page_shop)
  elseif tab == 4 then
    if not nx_is_valid(form.page_npc) then
      local page_npc = util_get_form("form_stage_main\\form_hire_shop\\form_hire_shop_npc", true, false)
      if form:Add(page_npc) then
        form.page_npc = page_npc
        form.page_npc.Visible = true
        form.page_npc.Fixed = true
        form.page_npc.Left = 18
        form.page_npc.Top = 50
        form.page_npc.npcid = form.npcid
      end
    end
    form.page_npc.Visible = true
    form:ToFront(form.page_npc)
    nx_execute("form_stage_main\\form_hire_shop\\form_hire_shop_npc", "reset_grid_data", form.page_npc)
  end
end
function hide_all_sub_form(form)
  if nx_is_valid(form.page_shop) then
    form.page_shop.Visible = false
  end
  if nx_is_valid(form.page_style) then
    form.page_style.Visible = false
  end
  if nx_is_valid(form.page_additem) then
    form.page_additem.Visible = false
  end
  if nx_is_valid(form.page_npc) then
    form.page_npc.Visible = false
  end
end
function close_form(...)
  local bShow = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_hire_shop\\form_hire_shop")
  if bShow then
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(util_text("37021"), 0, 0)
    end
    local form_shop = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_hire_shop\\form_hire_shop", true, false)
    form_shop:Close()
  end
end
