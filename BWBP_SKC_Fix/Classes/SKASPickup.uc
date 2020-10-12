//=============================================================================
// SKASPickup. Modified for camo usage.
//=============================================================================
class SKASPickup extends BallisticCamoPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BWBP_SKC_Static.usx
#exec OBJ LOAD FILE=BallisticHardware2.usx


simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.SKAS.SKASShotgun');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.Shell_Concrete');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.Shell_Metal');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.Shell_Wood');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.M763.M763MuzzleFlash');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.M763.M763Flash1');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.Brass.EmptyShell');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_Static.SKAS.SKASShotgunAmmo');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_Static.SKAS.SKASShotgunPickup');
//	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_Static.SKAS.SKASShotgunPickupLow');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_Static.SKAS.SKASShotgunPickup'
     InventoryType=Class'BWBP_SKC_Fix.SKASShotgun'
     RespawnTime=90.000000
     PickupMessage="You picked up the SKAS-21 Super Shotgun"
     PickupSound=Sound'BallisticSounds2.M763.M763Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_Static.SKAS.SKASShotgunPickup'
     Physics=PHYS_None
     DrawScale=0.950000
     PickupDrawScale=0.950000
     Skins(0)=Texture'BWBP_SKC_Tex.SKAS.SKASShotgun'
     CollisionHeight=3.000000
}
