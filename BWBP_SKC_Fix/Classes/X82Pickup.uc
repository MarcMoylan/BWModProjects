//=============================================================================
// X82Pickup.
//=============================================================================
class X82Pickup extends BallisticWeaponPickup
	placeable;


#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx
#exec OBJ LOAD FILE=BWBP_SKC_Static.usx


simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.X82.X82Skin');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.Brass.EmptyRifleRound');
//	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.R78.RifleMuzzleFlash');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_Static.X83.X82A2Mag');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_Static.X83.X83A1_ST');

}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_Static.X83.X83A1_ST'
     PickupDrawScale=0.400000
     MaxDesireability=0.750000
     InventoryType=Class'BWBP_SKC_Fix.X82Rifle'
     RespawnTime=20.000000
     PickupMessage="You got the X83A1 Anti-Materiel Rifle"
     PickupSound=Sound'BWBP4-Sounds.MRL.MRL-BigOn'
     StaticMesh=StaticMesh'BWBP_SKC_Static.X83.X83A1_ST'
     Physics=PHYS_None
     DrawScale=0.400000
     CollisionHeight=3.000000
}
