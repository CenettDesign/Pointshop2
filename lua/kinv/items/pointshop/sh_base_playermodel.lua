ITEM.PrintName = "Pointshop Playermodel Base"
ITEM.baseClass = "base_pointshop_item"

ITEM.playerModel = "models/player/kleiner.mdl"
ITEM.bodygroups = "0"
ITEM.skin = 0

ITEM.category = "Playermodels"

/*
	Inventory icon
*/
function ITEM:getIcon( )
	self.icon = vgui.Create( "DPointshopPlayerModelInvIcon" )
	self.icon:SetItem( self )
	self.icon:SetSize( 64, 64 )
	return self.icon
end

function ITEM:ApplyModel( )
	if CLIENT then
		return
	end
	
	local ply = self:GetOwner( )
	
	if not IsValid( ply ) then
		ErrorNoHalt( "[PS2] Invalid owner for item " .. self.id .. ": " .. tostring( ply ) )
		return
	end
	
	ply:SetModel( self.playerModel )
	
	local groups = string.Explode( " ", self.bodygroups ) 
	for k = 0, ply:GetNumBodyGroups( ) - 1 do
		if ( ply:GetBodygroupCount( k ) <= 1 ) then continue end
		ply:SetBodygroup( k, groups[ k + 1 ] or 0 )
	end
	
	if ply:SkinCount( ) - 1 > 0 then
		ply:SetSkin( self.skin )
	end
end

function ITEM:OnEquip( ply )
	self:ApplyModel( )
	timer.Simple( 1, function( )
		self:ApplyModel( )
		hook.Run( "PS2_DoUpdatePreviewModel" )
	end )
	hook.Run( "PS2_DoUpdatePreviewModel" )
end

function ITEM:OnHolster( ply )
	timer.Simple( 0, function( )
		hook.Run( "PS2_DoUpdatePreviewModel" )
	end )
	hook.Run( "PS2_ModelHolstered" )
	timer.Simple( 1, function( )
		hook.Run( "PlayerSetModel", ply )
	end )
end

function ITEM:PlayerSetModel( ply )
	self:ApplyModel( )
end
Pointshop2.AddItemHook( "PlayerSetModel", ITEM )

function ITEM:PlayerSpawn( ply )
	print( "Player Spawn called", ply, self:GetOwner( ) )
	if ply == self:GetOwner( ) then
		self:OnEquip( ply )
	end
end
Pointshop2.AddItemHook( "PlayerSpawn", ITEM )

function ITEM.static:GetPointshopIconControl( )
	return "DPointshopPlayerModelIcon"
end

function ITEM.static.getPersistence( )
	return Pointshop2.PlayermodelPersistence
end

function ITEM.static.generateFromPersistence( itemTable, persistenceItem )
	ITEM.super.generateFromPersistence( itemTable, persistenceItem.ItemPersistence )
	itemTable.playerModel = persistenceItem.playerModel
	util.PrecacheModel( itemTable.playerModel )
	itemTable.skin = persistenceItem.skin
	itemTable.bodygroups = persistenceItem.bodygroups
end

function ITEM.static.GetPointshopIconDimensions( )
	return Pointshop2.GenerateIconSize( 4, 6 )
end