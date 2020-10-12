//=============================================================================
// FG50Pickup.
//=============================================================================
class FG50Pickup extends BallisticCamoPickup
	placeable;

#exec OBJ LOAD FILE=BallisticWeapons2.utx
#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx
#exec OBJ LOAD FILE=BWBP_SKC_StaticExp.usx


simulated function PostNetReceive()
{
	if (CamoIndex != OldCamoIndex)
	{
		OldCamoIndex = CamoIndex;
		Skins[1] = class<BallisticCamoWeapon>(InventoryType).default.CamoMaterials[CamoIndex];
	}
		
	Super(BallisticWeaponPickup).PostNetReceive();
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'ONSstructureTextures.CoreGroup.Invisible');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.Brass.EmptyRifleRound');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_StaticExp.FG50.FG50PickupHi');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_StaticExp.FG50.FG50PickupHi'
     InventoryType=Class'BWBP_SKC_Fix.FG50MachineGun'
     RespawnTime=20.000000
     PickupMessage="You picked up the FG50 .50 MG"
     PickupSound=Sound'BallisticSounds2.M50.M50Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.FG50.FG50PickupHi'
     Physics=PHYS_None
     DrawScale=1.100000
     PrePivot=(X=0.000000,Y=-10.000000,Z=0.000000)
     CollisionHeight=4.000000
}
