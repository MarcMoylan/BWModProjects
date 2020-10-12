//=============================================================================
// ChaffPickup.
//=============================================================================
class ChaffPickup extends BallisticWeaponPickup
	placeable;

#exec OBJ LOAD FILE=BallisticWeapons2.utx
#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BWBP_SKC_StaticExp.usx

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BallisticWeapons2.NRP57.Grenade');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Particles.Explode2');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Particles.Shockwave');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.Explosion1');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.Explosion2');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.Explosion3');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.Explosion4');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_StaticExp.MOAC.MOACPickup');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_StaticExp.MOAC.MOACProj');
}

defaultproperties
{
     bOnSide=False
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_StaticExp.MOAC.MOACPickup'
     PickupDrawScale=0.180000
     bWeaponStay=False
     InventoryType=Class'BWBP_SKC_Fix.ChaffGrenadeWeapon'
     RespawnTime=20.000000
     PickupMessage="You picked up the MOA-C Chaff Grenade"
     PickupSound=Sound'BallisticSounds2.Ammo.GrenadePickup'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.MOAC.MOACPickup'
     bOrientOnSlope=True
     Physics=PHYS_None
     DrawScale=0.180000
     CollisionHeight=5.600000
}
