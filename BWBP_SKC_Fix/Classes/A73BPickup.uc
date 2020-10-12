//=============================================================================
// A73Pickup.
//=============================================================================
class A73BPickup extends BallisticWeaponPickup
	placeable;

#exec OBJ LOAD FILE=BallisticWeapons2.utx
#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.A73B.A73BAmmoSkin');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.A73B.A73BBladeSkin0');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.A73B.A73BSkinA0');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.A73B.A73BSkinB0');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.A73B.A73BScorch');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.A73B.A73BMuzzleFlash');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.A73B.A73BProjectile');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.A73B.A73BProjectile2');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.A73.A73Projectile');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.A73.A73MuzzleFlash');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.A73.A73PickupHi');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.A73.A73PickupLo');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BallisticHardware2.A73.A73PickupLo'
     InventoryType=Class'BWBP_SKC_Fix.A73BSkrithRifle'
     RespawnTime=20.000000
     PickupMessage="You picked up the A73-E Skrith Rifle"
     PickupSound=Sound'BallisticSounds2.A73.A73Putaway'
     StaticMesh=StaticMesh'BallisticHardware2.A73.A73PickupHi'
     Physics=PHYS_None
     DrawScale=0.187500
     Skins(0)=Shader'BWBP_SKC_Tex.A73b.A73BSkin_SD'
     Skins(1)=Shader'BWBP_SKC_Tex.A73b.A73BBladeShader'
     Skins(2)=Texture'BWBP_SKC_Tex.A73b.A73BSkinB0'
     Skins(3)=Texture'BWBP_SKC_Tex.A73b.A73BAmmoSkin'
     Skins(4)=TexOscillator'BWBP_SKC_Tex.A73b.A73BEnergyOsc'
     CollisionHeight=4.500000
}
