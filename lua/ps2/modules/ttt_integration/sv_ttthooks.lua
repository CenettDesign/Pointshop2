local S = function( id )
	return Pointshop2.GetSetting( "TTT Integration", id )
end

local delayedRewards = {}
local function delayReward( ply, points, message, small )
	if S("Kills.DelayReward") then
		table.insert( delayedRewards, { ply = ply, points = points, message = message, small = small } )
	else
		ply:PS2_AddStandardPoints( points, message, small )
	end
end

local function applyDelayedRewards( )
	for k, v in ipairs( delayedRewards ) do
		v.ply:PS2_AddStandardPoints( v.points, v.message, v.small )
	end

	delayedRewards = {}
end

local playersInRound = {}
hook.Add( "TTTBeginRound", "PS2_TTTBeginRound", function( )
	for k, v in pairs( player.GetAll( ) ) do
		if not v:IsSpec( ) then
			playersInRound[k] = v
		end
	end
end )

hook.Add( "TTTEndRound", "PS2_TTTEndRound", function( result )
	Pointshop2.StandardPointsBatch:begin( )

	applyDelayedRewards( )

	local prevRoles = {
		[ROLE_INNOCENT] = {},
		[ROLE_TRAITOR] = {},
		[ROLE_DETECTIVE] = {}
	};

	if not GAMEMODE.LastRole then GAMEMODE.LastRole = {} end
	if not TTT2 then
		if result == WIN_INNOCENT then
			for k, v in pairs( player.GetAll( ) ) do
				if not table.HasValue( playersInRound, v ) then
					continue
				end

				if v:IsTraitor( ) then
					continue
				end

				if v:IsSpec( ) then
					continue
				end

				if v:GetCleanRound( ) and S("RoundWin.CleanRound") then
					v:PS2_AddStandardPoints( S("RoundWin.CleanRound"), "Clean round bonus", true )
				end
				if v:Alive( ) and not ( v.IsGhost and v:IsGhost() ) and S("RoundWin.InnocentAlive") then
					v:PS2_AddStandardPoints( S("RoundWin.InnocentAlive"), "Alive bonus", true )
				end
				if S("RoundWin.Innocent") then
					v:PS2_AddStandardPoints( S("RoundWin.Innocent"), "Winning the round" )
				end

			end
		elseif result == WIN_TRAITOR then
			for k, v in pairs( player.GetAll( ) ) do
				if not v:IsTraitor( ) then
					continue
				end

				if ( v:Alive( ) and not v:IsSpec( ) ) and not ( v.IsGhost and v:IsGhost( ) ) and S("RoundWin.TraitorAlive") then
					v:PS2_AddStandardPoints( S("RoundWin.TraitorAlive"), "Alive bonus", true )
				end
				if S("RoundWin.Traitor") then
					v:PS2_AddStandardPoints( S("RoundWin.Traitor"), "Winning the round" )
				end
			end
		end
	else
		local points
		local message

		local exception_found = false

		for v in pairs(Pointshop2.GetModule('TTT Integration').Settings.Server.RoundWin) do
			local tmp_table = Pointshop2.GetModule('TTT Integration').Settings.Server.RoundWin[v]
			if not tmp_table.value or not tmp_table.team or tmp_table.team ~= result then continue end

			points = tmp_table.value
			message = tmp_table.message
			exception_found = true
		end

		if not exception_found then
			points = Pointshop2.GetModule('TTT Integration').Settings.Server.RoundWin.Default.value
			message = Pointshop2.GetModule('TTT Integration').Settings.Server.RoundWin.Default.message
		end

		for k, v in pairs( player.GetAll( ) ) do
			if v:GetTeam() ~= result or (v.IsGhost and v:IsGhost()) or not table.HasValue( playersInRound, v ) then continue end

			v:PS2_AddStandardPoints(points, message)
		end

	end
	playersInRound = {}

	Pointshop2.StandardPointsBatch:finish( )

	hook.Call( "Pointshop2GmIntegration_RoundEnded" )
end )

hook.Add( "TTTFoundDNA", "PS2_TTTFoundDNA", function( ply, dnaOwner, ent )
	if TTT2 then return end
	ply.hasDnaOn = ply.hasDnaOn or {}
	if S("Detective.DnaFound") and not ply.hasDnaOn[dnaOwner] then
		ply:PS2_AddStandardPoints( S("Detective.DnaFound"), "Retrieved DNA", true )
	end
	ply.hasDnaOn[dnaOwner] = true
end )

hook.Add( "PlayerDeath", "PS2_PlayerDeath", function( victim, inflictor, attacker )
	victim.hasDnaOn = {}
	if GetRoundState() ~= ROUND_ACTIVE then return end
	if victim == attacker then
		return
	end
	if (attacker.IsGhost and attacker:IsGhost()) then return end --SpecDM Support.

	if not victim.GetTeam then
		return
	end
	local victimTeam = TTT2 and victim:GetTeam()

	if not attacker.GetTeam then
		return
	end
	local attackerTeam = TTT2 and attacker:GetTeam()

	local points
	local message
	local delay = false

	local exception_found = false

	for v in pairs(Pointshop2.GetModule('TTT Integration').Settings.Server.Kills) do
		local tmp_table = Pointshop2.GetModule('TTT Integration').Settings.Server.Kills[v]
		if tmp_table.label == "Teamkill" or tmp_table.label == "EnemyKill" or not tmp_table.role1 or not tmp_table.role2 or not tmp_table.value or not (tmp_table.role1 == attackerTeam and tmp_table.role2 == victimTeam) then continue end

		points = tmp_table.value
		message = tmp_table.message
		delay = tmp_table.delay
		exception_found = true
	end

	if not exception_found then
		if attacker:IsInTeam(victim) then
			points = Pointshop2.GetModule('TTT Integration').Settings.Server.Kills.TeamKill.value
			message = Pointshop2.GetModule('TTT Integration').Settings.Server.Kills.TeamKill.message
			delay = Pointshop2.GetModule('TTT Integration').Settings.Server.Kills.TeamKill.delay
		else
			points = Pointshop2.GetModule('TTT Integration').Settings.Server.Kills.EnemyKill.value
			message = Pointshop2.GetModule('TTT Integration').Settings.Server.Kills.EnemyKill.message
			delay = Pointshop2.GetModule('TTT Integration').Settings.Server.Kills.EnemyKill.delay
		end
	end

	if delay then
		delayReward(attacker, points, message)
	else
		attacker:PS2_AddStandardPoints(points, message)
	end

end )

hook.Add( "PS2_WeaponShouldSpawn", "PreventForSpectators", function( ply )
	if ply:Team( ) == TEAM_SPECTATOR then
		return false
	end
end )
