//=============================================================================
// GoldenPickup. Gold DE pickup.
//=============================================================================
class GoldenPickup extends BallisticHandgunPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx
#exec OBJ LOAD FILE=BWBP_SKC_Static.usx


simulated function UpdatePrecacheMaterials()
{
//	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.AH104.AH104AmmoSkin');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.GoldEagle.GoldEagle-Skin');
	Level.AddPrecacheMaterial(Shader'BWBP_SKC_Tex.GoldEagle.GoldEagle-Shine');
}
simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.M925.M925MuzzleFlash');
	Level.AddPrecacheStaticMesh(StaticMesh'BallisticHardware2.D49.D49AmmoBox');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_Static.DesertEagle.DesertEagle');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_Static.DesertEagle.DesertEagle'
     PickupDrawScale=0.400000
     InventoryType=Class'BWBP_SKC_Fix.GoldenPistol'
     RespawnTime=90.000000
     PickupMessage="You picked up the Golden Gun"
     PickupSound=Sound'BallisticSounds2.M806.M806Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_Static.DesertEagle.DesertEagle'
     Physics=PHYS_None
     DrawScale=0.400000
     Skins(0)=Shader'BWBP_SKC_Tex.GoldEagle.GoldEagle-Shine'
     CollisionHeight=4.000000
}
