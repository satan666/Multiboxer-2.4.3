function LazyMultibox_ReturnLeaderUnit()
	local InRaid = UnitInRaid("player")
	local PLAYER = "player"
	local PET = ""
	local group = nil
	local NumMembers = nil
	local counter = nil
	local u = nil

	if InRaid then
		NumMembers = GetNumRaidMembers()
		counter = 1
		group = "raid"
	else
		NumMembers = GetNumPartyMembers()
		counter = 0
		group = "party"
	end

	while counter <= NumMembers do
		if counter == 0 then
			u = PLAYER
		else
			u = group..""..counter
		end
		if UnitIsPartyLeader(u) then
			return u
		end
		counter = counter + 1
	end
	return nil
end

function LazyMultibox_IsLeaderUnit(unit_name)
	local leader = LazyMultibox_ReturnLeaderUnit()
	if not leader then 
		return nil
	end
	local leader_name = UnitName(leader);
	if (leader_name == nil) then
		return nil
	end
	if unit_name ~= leader_name then
		return nil
	end
	return true
end

