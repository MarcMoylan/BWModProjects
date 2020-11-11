//=============================================================================
// X8Pickup.
//
// by Logan "BlackEagle" Richert.
// uses code by Nolan "Dark Carnivour" Richert.
// Copyright© 2011 RuneStorm. All Rights Reserved.
//=============================================================================
class X8Pickup extends BallisticWeaponPickup
	placeable;

#exec OBJ LOAD FILE=BallisticWeapons2.utx
#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BallisticWeapons2.X3.KnifeA1');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.KnifeCut');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.KnifeCutWood');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.X3.X3PickupHi');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.X3.X3PickupLo');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BallisticHardware_25.X4.X4_PickupLo'
     PickupDrawScale=0.270000
     InventoryType=Class'BWBP_SKC_Fix.X8Knife'
     RespawnTime=10.000000
     PickupMessage="You picked up the X8 Ballistic Knife"
     PickupSound=Sound'BallisticSounds2.Knife.KnifePutaway'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.X8.X8Pickup'
     Physics=PHYS_None
     DrawScale=0.300000
     CollisionHeight=4.000000
     bOnSide=false
}
