local BiVector = {}
BiVector.__Index = BiVector

function BiVector.new(force: Vector3?, torque: Vector3?)
    local new = {
        ["force"] = force or Vector3.zero,
        ["torque"] = torque or Vector3.zero
    }
    return setmetatable(new, BiVector)
end

BiVector.__add = function(self: table, value: table)
    return BiVector.new(self.force + value.force, self.torque + value.torque)
end

BiVector.__sub = function(self: table, value: table)
    return BiVector.new(self.force - value.force, self.torque - value.torque)
end

BiVector.__mul = function(self: (table | number), value: (table | number))
	local calcBiVector = nil
	
	if typeof(self) == "table" and typeof(value) == "table" then
		calcBiVector = BiVector.new(self.force * value.force, self.torque * value.torque)
	elseif typeof(self) == "table" and typeof(value) == "number" then
		calcBiVector = BiVector.new(self.force * value, self.torque * value)
	elseif typeof(self) == "number" and typeof(value) == "table" then
		calcBiVector = BiVector.new(self * value.force, self * value.torque)
	end
	
	return calcBiVector
end


return BiVector