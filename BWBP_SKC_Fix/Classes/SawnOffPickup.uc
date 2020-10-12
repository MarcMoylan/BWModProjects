//=============================================================================
// MRT6Pickup.
//=============================================================================
class SawnOffPickup extends BallisticHandgunPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BWBP_SKC_Static.usx

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Shader'BWBP_SKC_Tex.CoachGun.CoachShine');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.Shell_Concrete');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.Shell_Metal');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.Shell_Wood');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.M763Bash');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.M763BashWood');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.MRT6.MRT6MuzzleFlash');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.Brass.EmptyShell');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.Ammo.M763ShellBox');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_Static.SawnOff.SawnOffPickup');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_Static.CoachGun.CoachGun'
     PickupDrawScale=0.450000
     InventoryType=Class'BWBP_SKC_Fix.SawnOffShotgun'
     RespawnTime=15.000000
     PickupMessage="You picked up the Redwood Sawn-Off Shotgun"
     PickupSound=Sound'BallisticSounds2.M290.M290Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_Static.SawnOff.SawnOffPickup'
     Physics=PHYS_None
     DrawScale=0.350000
     CollisionHeight=3.500000
}
