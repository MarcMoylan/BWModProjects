//=============================================================================
// MJ51Pickup.
//=============================================================================
class HKARPickup extends BallisticWeaponPickup
	placeable;

#exec OBJ LOAD FILE=BallisticWeapons2.utx
#exec OBJ LOAD FILE=BWBP_SKC_TexExp.utx
#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx
#exec OBJ LOAD FILE=BWBP_SKC_StaticExp.usx

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_TexExp.M4A1.M4-Main');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_TexExp.M4A1.M4-Ord');
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
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_StaticExp.MJ51.MJ51Pickup'
     InventoryType=Class'BWBP_SKC_Fix.HKARCarbine'
     RespawnTime=20.000000
     PickupMessage="You picked up the JSOC Mk.16 SKAR"
     PickupSound=Sound'BallisticSounds2.M50.M50Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.MJ51.MJ51Pickup'
     Physics=PHYS_None
     DrawScale=0.260000
     CollisionHeight=4.000000
}
