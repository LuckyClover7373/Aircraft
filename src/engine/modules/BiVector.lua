local BiVector = {}
BiVector.__index = BiVector

function BiVector.new(force: Vector3?, torque: Vector3?): any
    return setmetatable({
        ["force"] = force or Vector3.zero,
        ["torque"] = torque or Vector3.zero
    }, BiVector)
end

BiVector.__add = function(self: any, value: any): any
    return BiVector.new(self.force + value.force, self.torque + value.torque)
end

BiVector.__sub = function(self: any, value: any): any
    return BiVector.new(self.force - value.force, self.torque - value.torque)
end

BiVector.__mul = function(self: (any | number), value: (any | number)): any
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