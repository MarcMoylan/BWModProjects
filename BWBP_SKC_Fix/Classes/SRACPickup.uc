//=============================================================================
// SKASPickup.
//=============================================================================
class SRACPickup extends BallisticCamoPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BWBP_SKC_Static.usx
#exec OBJ LOAD FILE=BallisticHardware2.usx



simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Shader'BWBP_SKC_Tex.SRAC.SRAC-MainShine');
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
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_Static.SKAS.SKASShotgunPickupHi');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_Static.SKAS.SKASShotgunPickupLow');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_Static.SKAS.SKASShotgunPickup'
     InventoryType=Class'BWBP_SKC_Fix.SRACGrenadeLauncher'
     RespawnTime=90.000000
     PickupMessage="You picked up the SRAC-21/G Auto Cannon"
     PickupSound=Sound'BallisticSounds2.M763.M763Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_Static.SKAS.SKASShotgunPickup'
     Physics=PHYS_None
     DrawScale=0.800000
     PickupDrawScale=0.800000
     Skins(0)=Shader'BWBP_SKC_Tex.SRAC.SRAC-MainShine'
     CollisionHeight=3.000000
}
