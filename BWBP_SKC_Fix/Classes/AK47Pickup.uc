//=============================================================================
// AK47Pickup.
//=============================================================================
class AK47Pickup extends BallisticCamoPickup
	placeable;

#exec OBJ LOAD FILE=BallisticWeapons2.utx
#exec OBJ LOAD FILE=BWBP_SKC_TexExp.utx
#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx

simulated function PostNetReceive()
{
	if (CamoIndex != OldCamoIndex)
	{
		OldCamoIndex = CamoIndex;
		Skins[1] = class<BallisticCamoWeapon>(InventoryType).default.CamoMaterials[CamoIndex];
	}
		
	Super.PostNetReceive();
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.M30A2.M30A2-SA');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.M30A2.M30A2-SB');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.M30A2.M30A2-Laser');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.M30A2.M30A2-Gauss');
	Level.AddPrecacheMaterial(Texture'ONSstructureTextures.CoreGroup.Invisible');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.M900.M900Grenade');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.M900.M900MuzzleFlash');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.Brass.EmptyRifleRound');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.Ammo.M50Magazine');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.M50.M50PickupHi');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.M50.M50PickupLo');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_StaticExp.AK490.AK490Pickup'
     InventoryType=Class'BWBP_SKC_Fix.AK47AssaultRifle'
     RespawnTime=20.000000
     PickupMessage="You picked up the AK-490 Battle Rifle"
     PickupSound=Sound'BallisticSounds2.M50.M50Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.AK490.AK490Pickup'
     Physics=PHYS_None
     DrawScale=0.250000
     PickupDrawScale=0.140000
     CollisionHeight=4.000000
}
