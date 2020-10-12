//=============================================================================
// AH104Pickup. Longhorn pickup.
//=============================================================================
class LonghornPickup extends BallisticWeaponPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.AH104.AH104-MainMk2');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.M806.PistolMuzzleFlash');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.AM67.AM67Clips');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_StaticExp.Longhorn.LonghornPickup'
     PickupDrawScale=0.090000
     InventoryType=Class'BWBP_SKC_Fix.LonghornLauncher'
     RespawnTime=10.000000
     PickupMessage="You picked up the Longhorn Grenade Launcher."
     PickupSound=Sound'BallisticSounds2.M806.M806Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.Longhorn.LonghornPickup'
     Physics=PHYS_None
     DrawScale=0.110000
     CollisionHeight=4.000000
}
