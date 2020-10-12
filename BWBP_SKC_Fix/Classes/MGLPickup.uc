//=============================================================================
// MGLPickup.
//[6:14:17 PM] Marc Moylan: because I need those maps soon to start coding
//[6:14:24 PM] Marc Moylan: before I get bored and run off to catch butterflies
//[6:14:36 PM] Marc Moylan: I catch them and put them in my mouth
//[6:14:45 PM] Blade Sword: lol
//=============================================================================
class MGLPickup extends BallisticWeaponPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx

simulated function UpdatePrecacheMaterials()
{
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
     LowPolyStaticMesh=StaticMesh'BallisticHardware2.M763.M763PickupLo'
     InventoryType=Class'BWBP_SKC_Fix.MGLLauncher'
     RespawnTime=20.000000
     PickupMessage="You picked up the VMDW-620c Conqueror MGL"
     PickupSound=Sound'BallisticSounds2.M763.M763Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.MGL.MGLPickupHi'
     Physics=PHYS_None
     DrawScale=0.90000
     CollisionHeight=3.000000
}
