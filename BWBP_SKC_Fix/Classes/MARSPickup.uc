//=============================================================================
// MRASPickup. Jason MRAS.
//=============================================================================
class MARSPickup extends BallisticCamoPickup
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
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_StaticExp.MARS.MARS2_Pickup'
     InventoryType=Class'BWBP_SKC_Fix.MARSAssaultRifle'
     RespawnTime=20.000000
     PickupMessage="You picked up the MARS-2 Assault Rifle"
     PickupSound=Sound'BallisticSounds2.M50.M50Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.MARS.MARS2_Pickup'
     Physics=PHYS_None
     DrawScale=0.250000
     PickupDrawScale=0.140000
     Skins(0)=Shader'BWBP_SKC_TexExp.MARS.F2000-LensShine'
     Skins(1)=Shader'BWBP_SKC_TexExp.MARS.F2000-Shine'
     Skins(2)=Shader'BWBP_SKC_TexExp.MARS.F2000-ScopeShine'
     CollisionHeight=4.000000
}
