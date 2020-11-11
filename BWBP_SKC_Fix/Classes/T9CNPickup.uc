//=============================================================================
// T9CNPickup.
//=============================================================================
class T9CNPickup extends BallisticCamoHandgunPickup
	placeable;

#exec OBJ LOAD FILE=BWBP_SKC_Tex.utx
#exec OBJ LOAD FILE=BWBP4-Tex.utx
#exec OBJ LOAD FILE=BWBP4-Hardware.usx
#exec OBJ LOAD FILE=BWBP_SKC_Static.usx

simulated function PostNetReceive()
{
	if (CamoIndex != OldCamoIndex)
	{
		OldCamoIndex = CamoIndex;
		if (CamoIndex == 4) //BB
		{
			Skins[0]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[2];
			Skins[1]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[6];
		}
		else if (CamoIndex == 3) //CA
		{
			Skins[0]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[3];
			Skins[1]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[5];
		}
		else if (CamoIndex == 2) //DA
		{
			Skins[0]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[4];
			Skins[1]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[5];
		}
		else if (CamoIndex == 1) //DC
		{
     			PickupMessage="You picked up the T9CN-R Machine Pistol";
			Skins[0]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[4];
			Skins[1]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[7];
		}
		else
		{
			Skins[0]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[1];
			Skins[1]=class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[5];
		}
	}
		
	Super(BallisticHandgunPickup).PostNetReceive();
}

static function StaticPrecache(LevelInfo L)
{
	L.AddPrecacheMaterial(Texture'BWBP4-Tex.Brass.Cart_Silver');
	L.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.T9CN.Ber-Main');
	L.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.T9CN.Ber-Slide');
	L.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.T9CN.Ber-Mag');

	L.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_Static.M9.M9Pickup');
	L.AddPrecacheStaticMesh(StaticMesh'BWBP4-Hardware.Glock.Glock-Ammo');
}
simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Texture'BWBP4-Tex.Brass.Cart_Silver');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.T9CN.Ber-Main');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.T9CN.Ber-Slide');
	Level.AddPrecacheMaterial(Texture'BWBP_SKC_Tex.T9CN.Ber-Mag');
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP_SKC_Static.M9.M9Pickup');
	Level.AddPrecacheStaticMesh(StaticMesh'BWBP4-Hardware.Glock.Glock-Ammo');
}

defaultproperties
{
     LowPolyStaticMesh=StaticMesh'BWBP_SKC_Static.M9.M9Pickup'
     PickupDrawScale=0.900000
     InventoryType=Class'BWBP_SKC_Fix.T9CNMachinePistol'
     RespawnTime=20.000000
     PickupMessage="You picked up the T9CN Machine Pistol"
     PickupSound=Sound'BallisticSounds2.M806.M806Putaway'
     StaticMesh=StaticMesh'BWBP_SKC_Static.M9.M9Pickup'
     Physics=PHYS_None
     DrawScale=0.900000
     CollisionHeight=4.000000
     Skins[0]=Shader'BWBP_SKC_Tex.T9CN.Ber-MainShine'
     Skins[1]=Shader'BWBP_SKC_Tex.T9CN.Ber-SlideShine'
     Skins[2]=Texture'BWBP_SKC_Tex.T9CN.Ber-Mag'
}
