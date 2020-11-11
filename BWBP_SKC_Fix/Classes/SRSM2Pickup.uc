//=============================================================================
// SRSM2Pickup.
//=============================================================================
class SRSM2Pickup extends BallisticCamoPickup
	placeable;

#exec OBJ LOAD FILE=BWBP3-Tex.utx
#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BWBP3Hardware.usx


simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BWBP3-Tex.SRS900.SRS900Main');
	Level.AddPrecacheMaterial(Texture'BWBP3-Tex.SRS900.SRS900Scope');
	Level.AddPrecacheMaterial(Texture'BWBP3-Tex.SRS900.SRS900Ammo');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.Brass.EmptyRifleRound');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP3Hardware.SRS900.SRS900Clip');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP3Hardware.SRS900.SRS900PickupHi');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP3Hardware.SRS900.SRS900PickupLo');
}

simulated function PostNetReceive()
{
	if (CamoIndex != OldCamoIndex)
	{
		OldCamoIndex = CamoIndex;
		Skins[0] = class<BallisticCamoWeapon>(InventoryType).default.CamoMaterials[CamoIndex];
		if (CamoIndex ==6)
     			PickupMessage="You picked up the SRS-655 Battle Rifle";
	}
		
	Super.PostNetReceive();
}


defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP3Hardware.SRS900.SRS900PickupLo'
     PickupDrawScale=0.500000
     InventoryType=Class'BWBP_SKC_Fix.SRSM2BattleRifle'
     RespawnTime=20.000000
     PickupMessage="You picked up the SRS Mod-2 Battle Rifle"
     PickupSound=Sound'BallisticSounds2.R78.R78Putaway'
     StaticMesh=StaticMesh'BWBP3Hardware.SRS900.SRS900PickupHi'
     Physics=PHYS_None
     DrawScale=0.500000
     CollisionHeight=3.000000
     Skins(1)=Texture'ONSstructureTextures.CoreGroup.Invisible'
     Skins(2)=Texture'BWBP3-Tex.SRS900.SRS900Ammo'
}
