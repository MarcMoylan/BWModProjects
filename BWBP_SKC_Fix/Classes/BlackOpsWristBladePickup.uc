//=============================================================================
// EKS43Pickup.
//=============================================================================
class BlackOpsWristBladePickup extends BallisticWeaponPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BWBP_SKC_Static.usx

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.BlkOpsBlade.BlkOpsBlade');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.KnifeCut');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.KnifeCutWood');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_Static.X5W.X5W');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_Static.X5W.X5W'
     PickupDrawScale=0.500000
     InventoryType=Class'BWBP_SKC_Fix.BlackOpsWristBlade'
     RespawnTime=10.000000
     PickupMessage="You picked up the X5W Black Ops Blade"
     PickupSound=Sound'BallisticSounds2.EKS43.EKS-Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_Static.X5W.X5W'
     Physics=PHYS_None
     DrawScale=0.200000
     CollisionHeight=4.000000
}
