//=============================================================================
// EKS43Pickup.
//=============================================================================
class NEXPickup extends BallisticWeaponPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BWBP_SKC_Static.usx

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.NEX.NEX-Main');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.KnifeCut');
	Level.AddPrecacheMaterial(Texture'BallisticEffects.Decals.KnifeCutWood');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_Static.PlasEdge.PlasEdgePickup');

}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_Static.PlasEdge.PlasEdgePickup'
     PickupDrawScale=0.220000
     InventoryType=Class'BWBP_SKC_Fix.NEXPlasEdge'
     RespawnTime=10.000000
     PickupMessage="You picked up the NEX Plas-Edge Sword"
     PickupSound=Sound'BWBP_SKC_Sounds.Nex.NEX-Pullout
     StaticMesh=StaticMesh'BWBP_SKC_Static.PlasEdge.PlasEdgePickup'
     Physics=PHYS_None
     DrawScale=0.220000
     CollisionHeight=4.000000
}
