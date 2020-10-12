//=============================================================================
// FLASHPickup.
//=============================================================================
class FLASHPickup extends BallisticCamoPickup
	placeable;

#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BallisticWeapons2.G5.G5Inner');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Particles.Explode2');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Particles.Shockwave');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.Explosion1');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.Explosion2');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.Explosion3');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.Explosion4');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.G5.G5Rocket');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.G5.BazookaMuzzleFlash');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.G5.BazookaBackFlash');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.Ammo.G5Rockets');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.G5.G5PickupHi');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.G5.G5PickupLo');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_StaticExp.Flash.FLASHPickup'
     PickupDrawScale=0.600000
     InventoryType=Class'BWBP_SKC_Fix.FLASHLauncher'
     RespawnTime=40.000000
     PickupMessage="You picked up the AT40 FLASH"
     PickupSound=Sound'BallisticSounds2.G5.G5-Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.Flash.FLASHPickup'
     Physics=PHYS_None
     DrawScale=0.600000
     CollisionHeight=6.000000
}
