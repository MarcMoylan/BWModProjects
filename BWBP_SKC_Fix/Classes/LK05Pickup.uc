//=============================================================================
// red bullets.
//=============================================================================
class LK05Pickup extends BallisticCamoPickup
	placeable;

#exec OBJ LOAD FILE=BallisticWeapons2.utx
#exec OBJ LOAD FILE=BWBP_SKC_TexExp.utx
#exec OBJ LOAD FILE=BallisticEffects.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx
#exec OBJ LOAD FILE=BWBP_SKC_StaticExp.utx

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'ONSstructureTextures.CoreGroup.Invisible');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.Brass.EmptyRifleRound');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_StaticExp.LK05.LK05AmmoPickup');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_StaticExp.LK05.LK05Pickup'
     InventoryType=Class'BWBP_SKC_Fix.LK05Carbine'
     RespawnTime=20.000000
     PickupMessage="You picked up the LK-05 Advanced Carbine"
     PickupSound=Sound'BallisticSounds2.M50.M50Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.LK05.LK05Pickup'
     Physics=PHYS_None
     DrawScale=0.260000
     CollisionHeight=4.000000
}
