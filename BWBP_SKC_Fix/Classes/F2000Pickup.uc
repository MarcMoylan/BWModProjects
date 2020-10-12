//=============================================================================
// MRASPickup. Jason MRAS.
//=============================================================================
class F2000Pickup extends BallisticCamoPickup
	placeable;

#exec OBJ LOAD FILE=BallisticWeapons2.utx
#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx

simulated function PostNetReceive()
{
	if (CamoIndex != OldCamoIndex)
	{
		OldCamoIndex = CamoIndex;
		Skins[0] = class<BallisticCamoWeapon>(InventoryType).default.CamoMaterials[CamoIndex];
		if (CamoIndex == 3)
     			PickupMessage="You picked up the MARS-3 CQB-LE Assault Rifle";
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
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_StaticExp.MARS.MARS3_Pickup'
     InventoryType=Class'BWBP_SKC_Fix.F2000AssaultRifle'
     RespawnTime=20.000000
     PickupMessage="You picked up the MARS-3 CQB Assault Rifle"
     PickupSound=Sound'BallisticSounds2.M50.M50Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.MARS.MARS3_Pickup'
     Physics=PHYS_None
     DrawScale=0.250000
     PickupDrawScale=0.140000
     Skins(0)=Texture'BWBP_SKC_TexExp.MARS.F2000-Irons'
     Skins(1)=Texture'BWBP_SKC_TexExp.LK05.LK05-EOTech'
     Skins(2)=Texture'BWBP_SKC_TexExp.MARS.F2000-Misc'
     CollisionHeight=4.000000
}
