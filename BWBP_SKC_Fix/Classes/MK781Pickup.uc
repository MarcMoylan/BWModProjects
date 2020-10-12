//=============================================================================
// Mk781Pickup.
//=============================================================================
class Mk781Pickup extends BallisticCamoPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx


simulated function PostNetReceive()
{
	if (CamoIndex != OldCamoIndex)
	{
		OldCamoIndex = CamoIndex;
		Skins[2] = class<BallisticCamoWeapon>(InventoryType).default.CamoMaterials[CamoIndex];
	}
		
	Super.PostNetReceive();
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Shader'BWBP_SKC_Tex.M781.M781_LargeShine');
	Level.AddPrecacheMaterial(Shader'BWBP_SKC_Tex.M781.M781_SmallShine');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.Shell_Concrete');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.Shell_Metal');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.Shell_Wood');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.M763Bash');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.M763BashWood');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.M763.M763MuzzleFlash');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.M763.M763Flash1');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.Brass.EmptyShell');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.Ammo.M763ShellBox');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.M763.M763PickupHi');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.M763.M763PickupLo');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_StaticExp.M1014.M1014Pickup'
     PickupDrawScale=1.000000
     InventoryType=Class'BWBP_SKC_Fix.MK781Shotgun'
     RespawnTime=20.000000
     PickupMessage="You picked up the Mk. 781 Combat Shotgun"
     PickupSound=Sound'BallisticSounds2.M763.M763Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.M1014.M1014Pickup'
     Physics=PHYS_None
     DrawScale=1.000000
     CollisionHeight=3.000000
}
