local MODULE = {}

--Pointshop2 TTT integration
MODULE.Name = "TTT Integration"
MODULE.Author = "Kamshak"
MODULE.RestrictGamemodes = { "terrortown" } --Only load for TTT

MODULE.Blueprints = {}

MODULE.SettingButtons = {
	{
		label = "Point Rewards",
		icon = "pointshop2/hand129.png",
		control = "DTerrortownConfigurator"
	}
}

MODULE.Settings = {}

--These are sent to the client on join
MODULE.Settings.Shared = { }

--TTT2 specific settings
MODULE.Settings.Server = {
		Kills = {
			info = {
				label = "Kill Rewards"
			},

			DelayReward = {
				value = true,
				label = "Delay Rewards",
				tooltip = "Use this to prevent players to meta-game using the kill notifications. Kill points are collected and awarded at round end.",
			},

			TeamKill = {
				value = -75,
				label = "Team kill",
				tooltip = "Points awarded/removed when killing a teammate. This will only trigger if no other exception is made for specific roles.",
				message = "Teammate killed",
				delay = true
			},

			EnemyKill = {
				value = 25,
				label = "Enemy Kill",
				tooltip = "Points awarded/removed when killing somebody not in your team. This will only trigger if no other exception is made for specific roles.",
				message = "Enemy killed",
				delay = true
			},

			TraitorKillsInnocent = {
				value = 75,
				role1 = TEAM_TRAITOR,
				role2 = TEAM_INNOCENT,
				label = "Traitor kills Innocent",
				tooltip = "Points awarded/removed when a Traitor kills an Innocent.",
				message = "Innocent killed",
				delay = true
			},

			InnocentKillsTraitor = {
				value = 150,
				role1 = TEAM_INNOCENT,
				role2 = TEAM_TRAITOR,
				label = "Innocent kills Traitor",
				tooltip = "Points awarded/removed when an Innocent kills a Traitor.",
				message = "Traitor killed",
				delay = true
			},
			
			InnocentKillsJester = {
				value = 0,
				role1 = TEAM_INNOCENT,
				role2 = TEAM_JESTER,
				label = "Innocent kills Jester",
				tooltip = "Points awarded/removed when an Innocent kills a Traitor.",
				message = "Jester killed",
				delay = true
			},
			
			TraitorKillsJester = {
				value = 0,
				role1 = TEAM_TRAITOR,
				role2 = TEAM_JESTER,
				label = "Traitor kills Jester",
				tooltip = "Points awarded/removed when an Traitor kills a Traitor.",
				message = "Jester killed",
				delay = true
			},
		},
		RoundWin = {
			info = {
				label = "Round Win Rewards"
			},
			Default = {
				value = 75,
				label = "Default win",
				tooltip = "Points awarded/removed for Teams that have no special exception.",
				message = "Round win"
			},

			Jesters = {
				value = 225,
				team = TEAM_JESTER,
				label = "Jesters win",
				tooltip = "Points awarded/removed when Jesters win the round.",
				message = "Jester win"
			},			

			Traitors = {
				value = 100,
				team = TEAM_TRAITOR,
				label = "Traitors win",
				tooltip = "Points awarded/removed when Traitors win the round.",
				message = "Traitor win"
			},

			Innocents = {
				value = 25,
				team = TEAM_INNOCENT,
				label = "Innocents win",
				tooltip = "Points awarded/removed when Innocents win the round.",
				message = "Innocent win"
			}
		}
}

--MODULE.Settings.Server = MODULE.TTT2Settings

--These are not sent
--[[MODULE.Settings.Server = {
	Kills = {
		info = {
			label = "Kill Rewards"
		},

		DelayReward = {
			value = true,
			label = "Delay Rewards until round endddd",
			tooltip = "Use this to prevent players to meta-game using the kill notifications. Kill points are collected and awarded at round end.",
		},

		TraitorKillsInno = {
			value = 100,
			label = "Traitor kills Innocent",
			tooltip = "Points awarded to a traitor when he kills an innocent player",
		},

		TraitorKillsDetective = {
			value = 150,
			label = "Traitor kills Detective",
			tooltip = "Points awarded to a traitor when he kills a detective",
		},

		DetectiveKillsTraitor = {
			value = 200,
			label = "Detective kills Traitor",
			tooltip = "Points awarded to a detective when he kills a traitor",
		},

		DetectiveDnaBonus = {
			value = 50,
			label = "Detective DNA Bonus",
			tooltip = "Additional points awarded to a detective if he had DNA on a traitor he killed"
		},

		InnoKillsTraitor = {
			value = 250,
			label = "Innocent kills Traitor",
			tooltip = "Points awarded to an innocent when he kills a traitor",
		},
	},
	RoundWin = {
		info = {
			label = "Round Win Rewards"
		},
		Innocent = {
			value = 300,
			label = "Innocents win",
			tooltip = "Points awarded to every innocent when they win the round"
		},

		CleanRound = {
			value = 100,
			label = "Clean round bonus",
			tooltip = "Bonus given to players if they did not hurt a teammate (no karma loss)"
		},

		InnocentAlive = {
			value = 100,
			label = "Innocent alive bonus",
			tooltip = "Bonus given to innocents that are alive at the end of the round",
		},

		Traitor = {
			value = 300,
			label = "Traitors win",
			tooltip = "Points awarded to every traitor when they win the round"
		},

		TraitorAlive = {
			value = 100,
			label = "Traitor alive bonus",
			tooltip = "Bonus given to traitors if they are alive at the end of the round"
		}
	},
	Detective = {
		info = {
			label = "Detective Rewards"
		},
		DnaFound = {
			value = 50,
			label = "DNA Found",
			tooltip = "Points awarded to a detective upon collecting DNA"
		},
	},
}]]--

-- For Drops integration: Returns players that can get a drop once the round ends
function MODULE.GetPlayersForDrops( )
	local players = {}
	for k, v in pairs( player.GetAll( ) ) do
		if v:ShouldScore() then
			table.insert( players, v )
		end
	end
	return players
end

Pointshop2.RegisterModule( MODULE )
Pointshop2.NotifyGamemodeModuleLoaded( "terrortown", MODULE )
