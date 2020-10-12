//=============================================================================
// T10Pickup.
//=============================================================================
class G28Pickup extends BallisticWeaponPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BWBP_SKC_Static.usx


simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.G28.G28-Main');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_Static.G28.G28Proj');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_Static.G28.G28Pickup');
}

defaultproperties
{
     bOnSide=False
     LowPolyStaticMesh=StaticMesh'BallisticHardware2.T10.T10Pickup'
     PickupDrawScale=0.200000
     bWeaponStay=False
     InventoryType=Class'BWBP_SKC_Fix.G28Grenade'
     RespawnTime=20.000000
     PickupMessage="You picked up the FMD G28 Medicinal Aerosol"
     PickupSound=Sound'BallisticSounds2.Ammo.GrenadePickup'
     StaticMesh=StaticMesh'BWBP_SKC_Static.G28.G28Pickup'
     bOrientOnSlope=True
     Physics=PHYS_None
     DrawScale=0.400000
     CollisionHeight=5.600000
}
