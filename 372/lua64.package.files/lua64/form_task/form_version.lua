require("theme")
require("form_language_version\\version_main")
local VERSION_EXPORT = "text\\version_export\\"
local NPC_IDRES = "text\\ChineseS\\stringname.idres"
local PROP_DESC = {
  TitleId = "TitleId",
  ContextId = "ContextId",
  TaskTargetId = "TaskTargetId",
  LineNextInfo = "LineNextInfo",
  TrackInfo = "TrackInfo",
  TrackInfoID = "TrackInfoID",
  SubmitNpcEx = "SubmitNpcEx",
  AcceptDialogId = "AcceptDialogId",
  CanAcceptMenu = "CanAcceptMenu",
  CompleteDialogId = "CompleteDialogId",
  CompleteMenu = "CompleteMenu",
  DialogID = "DialogID",
  OkMenu = "okMenu",
  AcceptNpc = "AcceptNpc",
  SubmitNpc = "SubmitNpc",
  TaskItemList = "TaskItemList",
  DramaAccept = "DramaAccept",
  DramaSubmit = "DramaSubmit",
  NpcId = "NpcId",
  GetItems = "GetItems",
  LostItems = "LostItems",
  ItemId = "ItemId",
  QuestionNpc = "QuestionNpc",
  AddItems = "AddItems",
  DeleteItems = "DeleteItems",
  TargetConfig = "TargetConfig",
  HideNpcID = "HideNpcID",
  ChooseNpc = "ChooseNpc"
}
function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.id_grid:SetColTitle(0, nx_widestr("Id"))
  self.id_grid:SetColTitle(1, nx_widestr("\195\232\202\246"))
  self.id_grid:SetColTitle(2, nx_widestr("\176\230\177\190\186\197"))
  self.id_grid:SetColTitle(3, nx_widestr("\182\212\211\166\210\235\206\196\206\196\188\254"))
  self.id_grid:SetColWidth(0, 200)
  self.id_grid:SetColWidth(1, 120)
  self.id_grid:SetColWidth(2, 120)
  self.id_grid:SetColWidth(3, 520)
  update_grid(self)
  return 1
end
function update_grid(self)
  self.id_grid:BeginUpdate()
  self.id_grid.Visible = false
  local task_form = nx_value("task_form")
  local node = task_form.work_dir_form.task_list.SelectNode
  if nx_is_valid(node.ParentNode) and nx_is_valid(node.ParentNode.ParentNode) and nx_is_valid(node.ParentNode.ParentNode.ParentNode) and nx_id_equal(node.ParentNode.ParentNode.ParentNode, task_form.work_dir_form.task_list.RootNode) then
    local node_list = node:GetNodeList()
    local count = node:GetNodeCount()
    for i = 1, count do
      task_form.work_dir_form.task_list.SelectNode = node_list[i]
      if i % 100 == 0 then
        nx_pause(0.1)
      end
      get_task_config_text(self.id_grid)
      get_sub_task_text(self.id_grid)
      get_task_form_text(self.id_grid)
      get_process_dialog_text(self.id_grid)
    end
    task_form.work_dir_form.task_list.SelectNode = node
  else
    get_task_config_text(self.id_grid)
    get_sub_task_text(self.id_grid)
    get_task_form_text(self.id_grid)
    get_process_dialog_text(self.id_grid)
  end
  self.id_grid.Visible = true
  self.id_grid:EndUpdate()
end
function main_form_close(self)
  nx_destroy(self)
  return 1
end
local function insert_grid(grid, prop, id, text_file)
  if id == nil or id == "" then
    return false
  end
  if text_file == nil then
    text_file = ""
  end
  local split_list = {";", "|"}
  local count = table.getn(split_list)
  for i = 1, count do
    local pos = string.find(id, split_list[i])
    if nil ~= pos then
      insert_grid(grid, prop, string.sub(id, 1, pos - 1), text_file)
      insert_grid(grid, prop, string.sub(id, pos + 1, string.len(id)), text_file)
      return true
    end
  end
  for i = 0, grid.RowCount - 1 do
    if id == nx_string(grid:GetGridText(i, 0)) then
      return false
    end
  end
  local row = grid:InsertRow(-1)
  grid:SetGridText(row, 0, nx_widestr(id))
  local desc = prop
  if PROP_DESC[prop] ~= nil then
    desc = PROP_DESC[prop]
  end
  grid:SetGridText(row, 1, nx_widestr(desc))
  local pos = string.find(text_file, "ChineseS\\")
  local idresfile = text_file
  if nil ~= pos then
    text_file = string.sub(idresfile, pos + string.len("ChineseS\\"), string.len(idresfile))
  end
  local version = query_version(text_file, id)
  grid:SetGridText(row, 2, nx_widestr(version))
  grid:SetGridText(row, 3, nx_widestr(text_file))
  return 1
end
function add_movie_id(grid, id)
  local ini = nx_create("IniDocument")
  local work_path = nx_value("work_path")
  ini.FileName = work_path .. "ini\\Task\\Movie\\MovieTalkList.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return
  end
  local value_list = ini:GetItemValueList(id, "r")
  local count = table.getn(value_list)
  for i = 1, count do
    local list = nx_function("ext_split_string", value_list[i], ",")
    local pos = string.find(value_list[i], ",")
    if pos ~= nil then
      value_list[i] = string.sub(value_list[i], 1, pos - 1)
    end
    insert_grid(grid, "Movie", value_list[i], "text\\ChineseS\\stringmovie.idres")
  end
  nx_destroy(ini)
end
function get_task_config_text(grid)
  local task_form = nx_value("task_form")
  local accept_npc = nx_custom(task_form.task_info, "AcceptNpc")
  local submit_npc = nx_custom(task_form.task_info, "SubmitNpc")
  local task_item_list = nx_custom(task_form.task_info, "TaskItemList")
  local drama_accept = nx_custom(task_form.task_info, "DramaAccept")
  local drama_submit = nx_custom(task_form.task_info, "DramaSubmit")
  insert_grid(grid, "AcceptNpc", accept_npc, "text\\ChineseS\\stringname_npc.idres")
  insert_grid(grid, "SubmitNpc", submit_npc, "text\\ChineseS\\stringname_npc.idres")
  insert_grid(grid, "DramaAccept", drama_accept, "text\\ChineseS\\StringDrama.idres")
  insert_grid(grid, "DramaSubmit", drama_submit, "text\\ChineseS\\StringDrama.idres")
  local accept_movie = nx_custom(task_form.task_info, "AcceptMovie")
  local submit_movie = nx_custom(task_form.task_info, "SubmitMovie")
  add_movie_id(grid, accept_movie)
  add_movie_id(grid, submit_movie)
  return 1
end
function get_fresh_monster_text(grid)
end
function get_tool_text(grid)
end
function get_process_dialog_text(grid)
  local task_form = nx_value("task_form")
  local task_id = task_form.task_info.ID
  local subtask_pro_info = nx_value("subtask_process_info")
  if not nx_is_valid(subtask_pro_info) then
    return 0
  end
  local task_step_info = subtask_pro_info:GetChild(task_id)
  if not nx_is_valid(task_step_info) then
    return 0
  end
  local text2 = task_form.sect_node:GetChild("text2").file_name
  local text3 = task_form.sect_node:GetChild("text3").file_name
  local task_step_info_count = task_step_info:GetChildCount()
  for i = 0, task_step_info_count - 1 do
    local info = task_step_info:GetChildByIndex(i)
    local id_sect = nx_execute("form_task\\form_subtask_overview", "get_subtask_info", info.type, info.subfunction)
    local type = info.type
    local id = info.subfunction
    if nx_is_valid(id_sect) then
      local id_sect_count = id_sect:GetChildCount()
      local prop_list_text = {}
      local split = false
      local label
      if type == "hunter" then
        prop_list_text = {}
        split = true
      elseif type == "interact" then
        prop_list_text = {"DialogID", "OkMenu"}
        split = true
      elseif type == "story" then
        prop_list_text = {
          "contextId",
          "titleId",
          "LeaveTextID"
        }
        split = true
      elseif type == "question" then
        prop_list_text = {
          "MainText",
          "FalseBuffer",
          "FalseTalk"
        }
        split = true
      end
      if "story" == type or "question" == type then
        local title, text_key
        if "story" == type then
          title = "\185\202\202\194\200\235\191\218"
          text_key = "story_menu_" .. id
        else
          title = "\180\240\204\226\200\235\191\218"
          text_key = "quest_menu_" .. id
        end
        insert_grid(grid, title, text_key, text2)
      end
      for i = 0, id_sect_count - 1 do
        local sect = id_sect:GetChildByIndex(i)
        if type == "question" then
          if sect:FindChild("QuestionID") then
            local question_id = sect:GetChild("QuestionID").item_name
            local questiongroup_sect = nx_execute("form_task\\form_subtask_overview", "get_subtask_info", "questiongroup", question_id)
            if nx_is_valid(questiongroup_sect) then
              local questiongroup_sect_count = questiongroup_sect:GetChildCount()
              local question_contend = nx_value("question_contend")
              for j = 0, questiongroup_sect_count - 1 do
                local question = questiongroup_sect:GetChildByIndex(j)
                local question_count = question:GetChildCount()
                insert_grid(grid, "QuestionID", question.Name, text3)
                for k = 0, question_count - 1 do
                  local pro = question:GetChildByIndex(k)
                  if nil ~= string.find(pro.Name, "questid") then
                    local pro_id = pro.item_name
                    if pro_id ~= "" then
                      local info
                      if question_contend:FindChild(pro_id) then
                        info = question_contend:GetChild(pro_id)
                      elseif question_contend:FindChild("title_info") then
                        info = question_contend:CreateChild(pro_id)
                        local title_info = question_contend:GetChild("title_info")
                        local title_info_count = title_info:GetChildCount()
                        for m = 0, title_info_count - 1 do
                          local title_child = title_info:GetChildByIndex(m)
                          local title_name = title_child.item_name
                          local child = info:CreateChild(title_name)
                          child.item_name = ""
                        end
                      end
                      if info ~= nil then
                        for m = 1, table.getn(prop_list_text) do
                          if info:FindChild(prop_list_text[m]) then
                            local val = info:GetChild(prop_list_text[m]).item_name
                            insert_grid(grid, prop_list_text[m], val, text2)
                          end
                        end
                        local m = 1
                        while true do
                          local child = info:GetChild("ZZAnswerText" .. nx_string(m))
                          if nx_is_valid(child) and child.item_name ~= "" then
                            insert_grid(grid, "ZZAnswerText", child.item_name, text2)
                          elseif true then
                            break
                          else
                            break
                          end
                          m = m + 1
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        else
          if type == "hunter" then
            local child = sect:GetChild("IsQieCuo")
            if nx_is_valid(child) and child.item_name == "1" then
              prop_list_text = {
                "QiecuoTitle",
                "QiecuoMenu"
              }
            end
          end
          for j = 1, table.getn(prop_list_text) do
            if sect:FindChild(prop_list_text[j]) then
              local val = sect:GetChild(prop_list_text[j]).item_name
              insert_grid(grid, prop_list_text[j], val, text2)
            end
          end
          if type == "convoy" and sect:FindChild("PathID") then
            local path_id = sect:GetChild("PathID").item_name
            local path_item = nx_execute("form_task\\form_path_overview", "get_path_info", path_id)
            if nx_is_valid(path_item) then
              local path_info_count = path_item:GetChildCount()
              for k = 0, path_info_count - 1 do
                local path_info = path_item:GetChildByIndex(k)
                if nx_is_valid(path_info) then
                  insert_grid(grid, nx_custom(path_info, "TalkID"), "text2")
                end
              end
            end
          end
        end
      end
    end
  end
  return 1
end
function get_sub_task_text(grid)
  local task_form = nx_value("task_form")
  local task_id = task_form.task_info.ID
  local subtask_pro_info = nx_value("subtask_process_info")
  if not nx_is_valid(subtask_pro_info) then
    return 0
  end
  local task_step_info = subtask_pro_info:GetChild(task_id)
  if not nx_is_valid(task_step_info) then
    return 0
  end
  local text2 = task_form.sect_node:GetChild("text2").file_name
  local task_step_info_count = task_step_info:GetChildCount()
  for i = 0, task_step_info_count - 1 do
    local info = task_step_info:GetChildByIndex(i)
    local info_struct = nx_execute("form_task\\form_subtask_overview", "get_subtask_info", info.type, info.subfunction)
    if nx_is_valid(info_struct) then
      for j = 0, info_struct:GetChildCount() - 1 do
        local struct = info_struct:GetChildByIndex(j)
        local track_info = struct:GetChild("TrackInfo")
        local track_info_id = struct:GetChild("TrackInfoID")
        if info.type == "interact" then
          local npc_id = struct:GetChild("NpcId")
          local get_items = struct:GetChild("GetItems")
          local lost_items = struct:GetChild("LostItems")
          insert_grid(grid, "NpcId", npc_id.item_name, "text\\ChineseS\\stringname_npc.idres")
          insert_grid(grid, "GetItems", get_items.item_name, "text\\ChineseS\\stringname.idres")
          insert_grid(grid, "LostItems", lost_items.item_name, "text\\ChineseS\\stringname.idres")
          insert_grid(grid, "TrackInfo", track_info.item_name, text2)
        elseif info.type == "collect" then
          local item_id = struct:GetChild("ItemId")
          local npc_id = struct:GetChild("NpcId")
          insert_grid(grid, "ItemId", item_id.item_name, "text\\ChineseS\\stringname.idres")
          insert_grid(grid, "NpcId", npc_id.item_name, "text\\ChineseS\\stringname_npc.idres")
          insert_grid(grid, "TrackInfo", track_info.item_name, text2)
        elseif info.type == "hunter" then
          local npc_id = struct:GetChild("NpcId")
          insert_grid(grid, "NpcId", npc_id.item_name, "text\\ChineseS\\stringname_npc.idres")
          insert_grid(grid, "TrackInfo", track_info.item_name, text2)
        elseif info.type == "story" then
          local npc_id = struct:GetChild("NpcId")
          if not nx_is_valid(npc_id) then
            npc_id = struct:GetChild("NpcID")
          end
          insert_grid(grid, "NpcId", npc_id.item_name, "text\\ChineseS\\stringname_npc.idres")
          insert_grid(grid, "TrackInfoID", track_info_id.item_name, text2)
        elseif info.type == "question" then
          local question_npc = struct:GetChild("QuestionNpc")
          insert_grid(grid, "QuestionNpc", question_npc.item_name, "text\\ChineseS\\stringname_npc.idres")
          insert_grid(grid, "TrackInfoID", track_info_id.item_name, text2)
        elseif info.type == "useitem" then
          local item_id = struct:GetChild("ItemID")
          local add_items = struct:GetChild("AddItems")
          local delete_items = struct:GetChild("DeleteItems")
          local target_config = struct:GetChild("TargetConfig")
          insert_grid(grid, "ItemID", item_id.item_name, "text\\ChineseS\\stringname.idres")
          insert_grid(grid, "AddItems", add_items.item_name, "text\\ChineseS\\stringname.idres")
          insert_grid(grid, "DeleteItems", delete_items.item_name, "text\\ChineseS\\stringname.idres")
          insert_grid(grid, "TargetConfig", target_config.item_name, "text\\ChineseS\\stringname_npc.idres")
          insert_grid(grid, "TrackInfoID", track_info_id.item_name, text2)
        elseif info.type == "convoy" then
          local npc_id = struct:GetChild("NpcId")
          local hide_npc_id = struct:GetChild("HideNpcID")
          insert_grid(grid, "NpcId", npc_id.item_name, "text\\ChineseS\\stringname_npc.idres")
          insert_grid(grid, "HideNpcID", hide_npc_id.item_name, "text\\ChineseS\\stringname_npc.idres")
          insert_grid(grid, "TrackInfo", track_info.item_name, text2)
        elseif info.type == "choose" then
          local choose_npc = struct:GetChild("ChooseNpc")
          insert_grid(grid, "ChooseNpc", choose_npc.item_name, "text\\ChineseS\\stringname_npc.idres")
          insert_grid(grid, "TrackInfoId", track_info_id.item_name, text2)
        elseif info.type == "special" then
          insert_grid(grid, "TrackInfoId", track_info_id.item_name, text2)
        end
      end
    end
  end
end
function get_task_form_text(grid)
  local task_form = nx_value("task_form")
  local list = {
    [1] = {prop = "TitleId", text = "text1"},
    [2] = {prop = "ContextId", text = "text1"},
    [3] = {
      prop = "TaskTargetId",
      text = "text1"
    },
    [4] = {
      prop = "LineNextInfo",
      text = "text1"
    },
    [5] = {prop = "TrackInfo", text = "text2"},
    [6] = {
      prop = "TrackInfoID",
      text = "text2"
    },
    [7] = {
      prop = "SubmitNpcEx",
      text = "text2"
    },
    [8] = {
      prop = "AcceptDialogId",
      text = "text1"
    },
    [9] = {
      prop = "CanAcceptMenu",
      text = "text1"
    },
    [10] = {
      prop = "CompleteDialogId",
      text = "text1"
    },
    [11] = {
      prop = "CompleteMenu",
      text = "text1"
    },
    [12] = {prop = "DialogID", text = "text2"},
    [13] = {prop = "OkMenu", text = "text2"}
  }
  local text1 = task_form.sect_node:GetChild("text1")
  local text2 = task_form.sect_node:GetChild("text2")
  local count = table.getn(list)
  for i = 1, count do
    local id = nx_custom(task_form.task_info, list[i].prop)
    local text = text1
    if list[i].text == "text2" then
      text = text2
    end
    insert_grid(grid, list[i].prop, id, text.file_name)
  end
end
function close_button_click(self)
  local form = self.Parent
  form:Close()
  return 1
end
function id_grid_select_grid(self, row, col)
  if col ~= 2 then
    return 0
  end
  local text = self:GetGridText(row, col)
  local edit = CREATE_CONTROL("Edit")
  edit.Text = text
  edit.grid = self
  edit.row = row
  edit.col = col
  local gui = nx_value("gui")
  gui.Focused = edit
  nx_bind_script(edit, nx_current())
  nx_callback(edit, "on_lost_focus", "on_lost_focus_edit")
  self:SetGridControl(row, 2, edit)
  return 1
end
function on_lost_focus_edit(self)
  local grid = self.grid
  local row = self.row
  local col = self.col
  grid:SetGridText(row, col, self.Text)
  grid:ClearGridControl(row, col)
  return 1
end
function save_button_click(self)
  local form = self.Parent
  local grid = form.id_grid
  for i = 0, grid.RowCount - 1 do
    local id = nx_string(grid:GetGridText(i, 0))
    local version = nx_string(grid:GetGridText(i, 2))
    local idresfile = nx_string(grid:GetGridText(i, 3))
    local pos = string.find(idresfile, "ChineseS\\")
    if nil ~= pos then
      idresfile = string.sub(idresfile, pos + string.len("ChineseS\\"), string.len(idresfile))
    end
    local last_pos = string.find(id, "-")
    if nil ~= last_pos then
      id = string.sub(1, last_pos - 1)
    end
    set_version(idresfile, id, nx_int(version))
  end
  save_version_all()
  return 1
end
function set_version_button_click(self)
  local form = self.Parent
  local grid = form.id_grid
  local version_num = form.ver_num_edit.Text
  for i = 0, grid.RowCount - 1 do
    grid:SetGridText(i, 2, version_num)
  end
  return 1
end
function export_button_click(self)
  local language = get_language()
  if not nx_is_valid(language) then
    return 0
  end
  if not nx_path_exists(nx_resource_path() .. VERSION_EXPORT) then
    nx_path_create(nx_resource_path() .. VERSION_EXPORT)
  end
  local gui = nx_value("gui")
  local file_list = language:GetFileList()
  local file_count = table.getn(file_list)
  local form = self.Parent
  local export_version = nx_string(form.export_edit.Text)
  for i = 1, file_count do
    local item_list = language:GetItemList(file_list[i])
    local item_count = table.getn(item_list)
    local pos = string.find(file_list[i], "\\")
    local last_pos = pos
    while pos ~= nil do
      last_pos = pos
      pos = string.find(file_list[i], "\\", pos + 1)
    end
    local path = ""
    local file = file_list[i]
    if last_pos ~= nil then
      path = string.sub(file_list[i], 1, last_pos)
      file = string.sub(file_list[i], last_pos + 1, string.len(file_list[i]))
    end
    if path ~= "" and not nx_path_exists(nx_resource_path() .. VERSION_EXPORT .. path) then
      nx_path_create(nx_resource_path() .. VERSION_EXPORT .. path)
    end
    local idres_doc = nx_create("IdresDocument")
    local tmp_idres_doc = nx_create("IdresDocument")
    idres_doc.FileName = nx_resource_path() .. VERSION_EXPORT .. file_list[i]
    tmp_idres_doc.FileName = nx_resource_path() .. "text\\ChineseS\\" .. file_list[i]
    if tmp_idres_doc:LoadFromFile() then
      for j = 1, item_count do
        local id = item_list[j]
        local last_pos = string.find(id, "-")
        if last_pos ~= nil then
          id = string.sub(id, 1, last_pos - 1)
        end
        local text = tmp_idres_doc:ReadString(id)
        local version = query_version(file_list[i], id)
        if version ~= -1 and (export_version == "" or version <= nx_number(export_version)) then
          idres_doc:AddString(id, text)
        end
      end
      idres_doc:SaveToFile()
    end
    nx_destroy(idres_doc)
    nx_destroy(tmp_idres_doc)
  end
  return 1
end
