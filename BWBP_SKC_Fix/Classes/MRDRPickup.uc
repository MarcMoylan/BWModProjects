//=============================================================================
// MRDRPickup.
//=============================================================================
class MRDRPickup extends BallisticHandgunPickup
	placeable;

#exec OBJ LOAD FILE=BallisticWeapons2.utx
#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BallisticWeapons2.Fifty9.Fifty9Skin');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.Ammo.XK2Clip');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.XK2.XK2PickupHi');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.XK2.XK2PickupLo');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_Static.MRDR.MRDR88Pickup'
     PickupDrawScale=0.250000
     InventoryType=Class'BWBP_SKC_Fix.MRDRMachinePistol'
     RespawnTime=20.000000
     PickupMessage="You picked up the MR-DR88 Machine-Pistol"
     PickupSound=Sound'BallisticSounds2.XK2.XK2-Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_Static.MRDR.MRDR88Pickup'
     Physics=PHYS_None
     DrawScale=0.500000
     PrePivot=(Y=-16.000000)
     CollisionHeight=4.000000
}
