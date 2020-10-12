//=============================================================================
// AH250Pickup. DE pickup.
//=============================================================================
class AH250Pickup extends BallisticCamoHandgunPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx
#exec OBJ LOAD FILE=BWBP_SKC_Static.usx


simulated function UpdatePrecacheMaterials()
{
//	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.AH104.AH104AmmoSkin');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.Eagle.DesertEagle-Skin');
	Level.AddPrecacheMaterial(Shader'BWBP_SKC_Tex.Eagle.DesertEagle-Shine');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.M925.M925MuzzleFlash');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.D49.D49AmmoBox');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_Static.DesertEagle.DesertEagle');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_Static.DesertEagle.DEaglePickup'
     PickupDrawScale=1.000000
     InventoryType=Class'BWBP_SKC_Fix.AH250Pistol'
     RespawnTime=10.000000
     PickupMessage="You picked up the AH250 .44 Hawk"
     PickupSound=Sound'BallisticSounds2.MRT6.MRT6Pullout'
     StaticMesh=StaticMesh'BWBP_SKC_Static.DesertEagle.DEaglePickup'
     Physics=PHYS_None
     DrawScale=1.000000
     CollisionHeight=4.000000
}
