
function content.walk_documents (_store_id, fn)
    for doc_id, store_id in content.documents(_store_id) do
  
      local path = content.stores[store_id] .. doc_id
      local file_content = fs.read_file(path)
      if not file_content then
        log.error("could not open " .. path)
      end
  
      local header, body = content.split_header(file_content)
  
      -- If the fn applied on this file returns values, stop walking
      local results = { fn(doc_id, header, body, store_id) }
      if results[1] then
        return table.unpack(results)
      end
    end
  end
  