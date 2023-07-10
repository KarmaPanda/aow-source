require("form_task\\common")
function get_file_svn_status(file_name, path_name)
  local se = nx_create("SVNEntries")
  se:SearchEntries(path_name)
  local fs = nx_create("FileSearch")
  fs:SearchFile(path_name, "*")
  if se:GetEntryLocked(file_name) then
    return LOCKED
  end
  if not se:GetEntryExists(file_name) then
    if fs:SearchFile(path_name, file_name) then
      nx_destroy(se)
      nx_destroy(fs)
      return NONE
    else
      nx_destroy(se)
      nx_destroy(fs)
      return NOT_VALID
    end
  elseif not fs:SearchFile(path_name, file_name) then
    nx_destroy(se)
    nx_destroy(fs)
    return DELETE
  elseif se:GetEntryNewAdded(file_name) then
    nx_destroy(se)
    nx_destroy(fs)
    return ADD
  elseif svn_is_modify_file(file_name, path_name, fs, se) then
    nx_destroy(se)
    nx_destroy(fs)
    return MODIFY
  else
    nx_destroy(se)
    nx_destroy(fs)
    return NEWEST
  end
end
function svn_is_modify_file(file_name, path_name, fs, se)
  if not se:GetEntryExists(file_name) then
    return false
  end
  if not fs:SearchFile(path_name, file_name) then
    return false
  end
  local file_size_svn = se:GetEntryFileSize(file_name)
  local file_size = nx_function("ext_get_file_size", path_name .. file_name)
  if file_size_svn ~= file_size then
    return true
  else
    local md5_svn = se:GetEntryFileMD5(file_name)
    local md5 = se:GetFileMD5(path_name .. file_name)
    if nx_string(md5_svn) ~= nx_string(md5) then
      return true
    end
  end
  return false
end
function svn_command(path_name, op)
  local command = "TortoiseProc.exe /path:" .. nx_string(path_name) .. " /command:" .. op
  local ret = nx_function("ext_win_exec", command)
  if false == ret then
    nx_msgbox("[\206\222\183\168\214\180\208\208SVN\195\252\193\238] \199\235\188\236\178\233SVN\207\224\185\216\201\232\214\195")
  end
  return ret
end
function svn_update(path_name)
  svn_command(path_name, "update")
end
function svn_commit(path_name)
  svn_command(path_name, "commit")
end
function svn_add(path_name)
  svn_command(path_name, "add")
end
function svn_remove(path_name)
  svn_command(path_name, "remove")
end
function svn_rename(path_name)
  svn_command(path_name, "rename")
end
function svn_log(path_name)
  svn_command(path_name, "log")
end
function svn_diff(file_name)
  svn_command(file_name, "diff")
end
function svn_revert(path_name)
  svn_command(path_name, "revert")
end
function svn_cleanup(path_name)
  svn_command(path_name, "cleanup")
end
function svn_lock(path_name)
  svn_command(path_name, "lock")
end
function svn_unlock(path_name)
  svn_command(path_name, "unlock")
end
function svn_checkout(path_name)
  svn_command(path_name, "checkout")
end
function svn_import(path_name)
  svn_command(path_name, "import")
end
function svn_export(path_name)
  svn_command(path_name, "export")
end
function svn_properties(path_name)
  svn_command(path_name, "properties")
end
