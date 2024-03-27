-- require("behaviourtree")

-- SequenceNode = Class(BehaviourNode, function(self, children)
--     BehaviourNode._ctor(self, "Sequence", children)
--     self.idx = 1
-- end)

-- function SequenceNode:DBString()
--     return tostring(self.idx)
-- end


-- function SequenceNode:Reset()
--     self._base.Reset(self)
--     self.idx = 1
-- end

-- function SequenceNode:Visit()

--     if self.status ~= RUNNING then
--         self.idx = 1
--     end

--     local done = false
--     while self.idx <= #self.children do

--         local child = self.children[self.idx]
--         child:Visit()
--         if child.status == RUNNING or child.status == FAILED then
--             self.status = child.status
--             return
--         end

--         self.idx = self.idx + 1
--     end

--     self.status = SUCCESS
-- end