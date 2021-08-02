local Spoofer = {}

---------------------------------------------------------------

Spoofer.SpoofedProperties = {}

local GetSpoofedProperty = function(Obj, Property)
	for _, Spoof in pairs(Spoofer.SpoofedProperties) do
		if Spoof[1] == Obj and Spoof[2] == Property then
			return Spoof
		end
	end
	return nil
end

function Spoofer:SpoofProperty(Obj, Property, Value)
	if GetSpoofedProperty(Obj, Property) then return false end
	table.insert(self.SpoofedProperties, {Obj, Property, Value}) 
	return true
end

function Spoofer:UnspoofProperty(Obj, Property)
	for i, Spoof in pairs(self.SpoofedProperties) do
		if Spoof[1] == Obj and Spoof[2] == Property then
			table.remove(self.SpoofedProperties, i)
			return true
		end
	end
	return false
end

local OldIndex = nil
OldIndex = hookmetamethod(game, '__index', function(...) -- spoofing properties
	local Self, Key = ...

	if not checkcaller() then
		local Response = GetSpoofedProperty(Self, Key)
		if Response ~= nil then return Response.Value end
	end
	
	return OldIndex(...)
end)

---------------------------------------------------------------

Spoofer.SpoofedFunctions = {}

local GetSpoofedFunction = function(Obj, Name)
	for _, Spoof in pairs(Spoofer.SpoofedFunctions) do
		if Spoof[1] == Obj and Spoof[2] == Name then
			return Spoof
		end
	end
	return nil
end

function Spoofer:SpoofFunction(Obj, Name, NewFunction)
	if GetSpoofedFunction(Obj, Name) then return false end
	table.insert(self.SpoofedFunctions, {Obj, Name, NewFunction})
	return true
end

function Spoofer:UnspoofFunction(Obj, Name)
	for i, Spoof in pairs(Spoofer.SpoofedFunctions) do
		if Spoof[1] == Obj and Spoof[2] == Name then
			table.remove(self.SpoofedFunctions, i)
			return true
		end
	end
	return false
end

local OldNameCall = nil
OldNameCall = hookmetamethod(game, '__namecall', function(...) -- spoofing functions
	local Args = {...}
	local Self = Args[1]
	local NamecallMethod = getnamecallmethod()
	local Caller = getcallingscript()
	
	if not checkcaller() then
		local Response = GetSpoofedProperty(Self, NamecallMethod)
		if Response then 
			local Arguments = {}
			table.foreach(Args, function(i, v)
				if i > 1 then table.insert(Arguments, v) end
			end)
			
			return Response[3]({
				Self = Self,
				Function = NamecallMethod,
				Script = Caller,
				Args = Arguments,
				OldNameCall = function()
					return OldNameCall(unpack(Args))
				end,
			}) 
		end
	end
	return OldNameCall(...)
end)

---------------------------------------------------------------

getgenv().Spoofer = Spoofer
