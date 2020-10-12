//=============================================================================
// CX61 pickup
//=============================================================================
class CX61Pickup extends BallisticWeaponPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_TexExp.utx
#exec OBJ LOAD FILE=BWBP_SKC_StaticExp.usx

simulated function UpdatePrecacheMaterials()
{
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.M900.M900Grenade');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.M900.M900MuzzleFlash');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.Brass.EmptyRifleRound');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.Ammo.M50Magazine');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_StaticExp.CX61.CX61Pickup');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.M50.M50PickupLo');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_StaticExp.CX61.CX61PickupLow'
     InventoryType=Class'BWBP_SKC_Fix.CX61AssaultRifle'
     RespawnTime=20.000000
     PickupMessage="You picked up the CX61 'Spectre' Flechette Rifle."
     PickupSound=Sound'BallisticSounds2.M50.M50Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.CX61.CX61Pickup'
     Physics=PHYS_None
     DrawScale=0.550000
     PickupDrawScale=0.550000
     CollisionHeight=4.000000
}
