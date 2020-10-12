//=============================================================================
// SMATPickup.
//=============================================================================
class FlakPickup extends BallisticWeaponPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Shader'BWBP_SKC_Tex.SMAA.SMAA-Shine');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.SMAA.SMAARocket');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.SMAA.SMAAScope');
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
     LowPolyStaticMesh=StaticMesh'BallisticHardware2.G5.G5PickupLo'
     PickupDrawScale=0.500000
     InventoryType=Class'BWBP_SKC_Fix.FlakLauncher'
     RespawnTime=20.000000
     PickupMessage="You picked up the [Beta] REX-M2 CAWS"
     PickupSound=Sound'BallisticSounds2.G5.G5-Putaway'
     StaticMesh=StaticMesh'BallisticHardware2.G5.G5PickupHi'
     Physics=PHYS_None
     DrawScale=0.400000
     Skins(0)=Shader'BWBP_SKC_Tex.SMAA.SMAA-Shine'
     Skins(1)=Shader'BWBP_SKC_Tex.SMAA.SMAA-Shine'
     Skins(2)=Shader'BWBP_SKC_Tex.SMAA.SMAA-Shine'
     Skins(3)=Texture'BWBP_SKC_Tex.SMAA.SMAARocket'
     Skins(4)=Texture'BWBP_SKC_Tex.SMAA.SMAAScope'
     Skins(5)=Texture'BWBP_SKC_Tex.SMAA.SMAAScope'
     CollisionHeight=6.000000
}
