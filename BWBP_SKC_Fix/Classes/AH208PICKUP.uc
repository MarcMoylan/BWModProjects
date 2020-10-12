//=============================================================================
// AH208Pickup. DE pickup.
//=============================================================================
class AH208Pickup extends BallisticCamoPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BallisticHardware2.usx
#exec OBJ LOAD FILE=BWBP_SKC_Static.usx


simulated function PostNetReceive()
{
	if (CamoIndex != OldCamoIndex)
	{
		OldCamoIndex = CamoIndex;
		if (CamoIndex == 6) //GG
		{
			Skins[0]=Texture'ONSstructureTextures.CoreGroup.Invisible';
			Skins[1]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[4];
		}
		else if (CamoIndex == 5) //SS
		{
			Skins[0]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[5];
			Skins[1]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[3];
		}
		else if (CamoIndex == 4) //Black RDS
		{
			Skins[0]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[6];
			Skins[1]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[2];
		}
		else if (CamoIndex == 3) //Silver
		{
			Skins[0]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[5];
			Skins[1]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[0];
		}
		else if (CamoIndex == 2) //Black
		{
			Skins[0]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[6];
			Skins[1]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[2];
		}
		else if (CamoIndex == 1) //Two Tone
		{
			Skins[0]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[5];
			Skins[1]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[1];
		}
		else
		{
			Skins[0]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[5];
			Skins[1]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[0];
		}
	}
		
	Super(BallisticHandgunPickup).PostNetReceive();
}


simulated function UpdatePrecacheMaterials()
{
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
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_Static.DesertEagle.DEaglePickupAlt'
     PickupDrawScale=1.000000
     InventoryType=Class'BWBP_SKC_Fix.AH208PISTOL'
     RespawnTime=10.000000
     PickupMessage="You picked up the AH208 .44 Eagle"
     PickupSound=Sound'BallisticSounds2.MRT6.MRT6Pullout'
     StaticMesh=StaticMesh'BWBP_SKC_Static.DesertEagle.DEaglePickupAlt'
     Physics=PHYS_None
     DrawScale=1.000000
     CollisionHeight=4.000000
}
