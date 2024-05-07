local GaleReadablePaper = Class(function(self, inst)
    self.inst = inst
    self.title = "MISSING_TITLE"
    self.content = "MISSING_CONTENT"
    self.index = nil
end)

function GaleReadablePaper:ReadBy(reader)
    if self.index then
        SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["show_readable_paper"], reader.userid, self.index)
    else
        SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["show_readable_paper"], reader.userid, self.title, self.content)
    end
    return true
end

return GaleReadablePaper
