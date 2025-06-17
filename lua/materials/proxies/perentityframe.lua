matproxy.Add({
    name = "PerEntityFrame",

    init = function(self, mat, values)
        self.frameVar = values.framevar or "$frame"
    end,

    bind = function(self, mat, ent)
        if not IsValid(ent) then return end
        print("--    Proxy Changed    --")
        local frame = ent:GetNWInt("AnimFrame", 0) -- Use NWInt for per-entity frame control
        mat:SetFloat(self.frameVar, frame)
    end
})
