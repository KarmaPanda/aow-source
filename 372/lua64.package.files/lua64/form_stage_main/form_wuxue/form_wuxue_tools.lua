function find_tips_ids(varpropno, ini_filename)
  local varpropini = nx_execute("util_functions", "get_ini", ini_filename)
  if not nx_is_valid(varpropini) then
    return
  end
  varpropno = nx_string(varpropno)
  if not varpropini:FindSection(varpropno) then
    return
  end
  local sec_index = varpropini:FindSectionIndex(varpropno)
  if sec_index < 0 then
    return
  end
  local tips_id_rec = {}
  local pack_id_rec = {}
  local level = 0
  level = varpropini:ReadString(sec_index, "Level", "")
  pack_id_rec = varpropini:GetItemValueList(sec_index, "@PropModifyPackRec")
  for i = 1, table.getn(pack_id_rec) do
    table.insert(tips_id_rec, "tips_proppack_" .. nx_string(pack_id_rec[i]))
  end
  pack_id_rec = varpropini:GetItemValueList(sec_index, "@EquipModifyPackRec")
  for i = 1, table.getn(pack_id_rec) do
    table.insert(tips_id_rec, "tips_equippack_" .. nx_string(pack_id_rec[i]))
  end
  pack_id_rec = varpropini:GetItemValueList(sec_index, "@SkillModifyPackRec")
  for i = 1, table.getn(pack_id_rec) do
    table.insert(tips_id_rec, "tips_skillpack_" .. nx_string(pack_id_rec[i]))
  end
  pack_id_rec = varpropini:GetItemValueList(sec_index, "@BuffModifyPackRec")
  for i = 1, table.getn(pack_id_rec) do
    table.insert(tips_id_rec, "tips_buffpack_" .. nx_string(pack_id_rec[i]))
  end
  pack_id_rec = varpropini:GetItemValueList(sec_index, "@TaskModifyPackRec")
  for i = 1, table.getn(pack_id_rec) do
    table.insert(tips_id_rec, "tips_taskpack_" .. nx_string(pack_id_rec[i]))
  end
  return tips_id_rec, level
end
