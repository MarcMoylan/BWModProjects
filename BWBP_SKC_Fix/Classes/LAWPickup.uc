//=============================================================================
// LAWPickup.
//=============================================================================
class LAWPickup extends BallisticWeaponPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_TexExp.utx
#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx
#exec OBJ LOAD FILE=BWBP_SKC_StaticExp.usx

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_TexExp.LAW.LAW-Main');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_TexExp.LAW.LAW-Rocket');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_TexExp.LAW.LAW-ScopeView');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Particles.Explode2');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Particles.Shockwave');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.Explosion1');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.Explosion2');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.Explosion3');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.Explosion4');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_StaticExp.LAW.LAWRocket');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.G5.BazookaMuzzleFlash');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.G5.BazookaBackFlash');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_StaticExp.LAW.LAWAmmo');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_StaticExp.LAW.LAWPickup');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_StaticExp.LAW.LAWPickup'
     PickupDrawScale=0.700000
     InventoryType=Class'BWBP_SKC_Fix.LAWLauncher'
     RespawnTime=30.000000
     PickupMessage="You picked up the FGM-70 'Shockwave' LAW"
     PickupSound=Sound'BallisticSounds2.G5.G5-Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.LAW.LAWPickup'
     Physics=PHYS_None
     DrawScale=0.700000
     CollisionHeight=6.000000
}
