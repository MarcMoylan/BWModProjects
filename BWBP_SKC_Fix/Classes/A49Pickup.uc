//=============================================================================
// A49Pickup.
//=============================================================================
class A49Pickup extends BallisticHandgunPickup
	placeable;

#exec OBJ LOAD FILE=BallisticWeapons2.utx
#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx


simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BallisticWeapons2.A42.A42_Exp');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.A42Scorch');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.GunFire.A73MuzzleFlash');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.GunFire.A42Projectile');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.GunFire.A42Projectile2');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.A42.A42Projectile');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.A42.A42MuzzleFlash');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.A42.A42PickupHi');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.A42.A42PickupLo');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_Static.A49.A49Pickup'
     PickupDrawScale=0.187000
     InventoryType=Class'BWBP_SKC_Fix.A49SkrithBlaster'
     RespawnTime=20.000000
     PickupMessage="You picked up the A49 Skrith Blaster"
     PickupSound=Sound'BallisticSounds2.A42.A42-Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_Static.A49.A49Pickup'
     Physics=PHYS_None
     DrawScale=0.300000
     CollisionHeight=4.500000
}
