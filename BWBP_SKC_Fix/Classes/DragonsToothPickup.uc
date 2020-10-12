//=============================================================================
// DragonsToothPickup.
//=============================================================================
class DragonsToothPickup extends BallisticWeaponPickup
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
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_Static.DTS.DragonsToothPickup'
     PickupDrawScale=1.000000
     InventoryType=Class'BWBP_SKC_Fix.DragonsToothSword'
     RespawnTime=50.000000
     PickupMessage="You picked up the XM300 Dragon Nanoblade."
     PickupSound=Sound'BWBP_SKC_Sounds.NEX.NEX-Pullout'
     StaticMesh=StaticMesh'BWBP_SKC_Static.DTS.DragonsToothPickup'
     Physics=PHYS_None
     DrawScale=0.600000
     CollisionHeight=4.000000
}
