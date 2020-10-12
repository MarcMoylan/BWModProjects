//=============================================================================
// ICISPickup.
//
// by Logan "BlackEagle" Richert.
// uses code by Nolan "Dark Carnivour" Richert.
// Copyright© 2011 RuneStorm. All Rights Reserved.
//=============================================================================
class ICISPickup extends BallisticWeaponPickup
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
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_StaticExp.Stim.StimpackPickup'
     PickupDrawScale=0.270000
     InventoryType=Class'BWBP_SKC_Fix.ICISStimpack'
     RespawnTime=10.000000
     PickupMessage="You picked up the FMD ICIS-25 Stimulant Autoinjector"
     PickupSound=Sound'BallisticSounds2.Knife.KnifePutaway'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.Stim.StimpackPickup'
     Physics=PHYS_None
     DrawScale=0.300000
     CollisionHeight=4.000000
     bOnSide=false
}
