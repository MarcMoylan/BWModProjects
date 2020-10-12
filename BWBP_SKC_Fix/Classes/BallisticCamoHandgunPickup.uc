//=============================================
// Ballistic Camo Pickup
//
// Sweet-ass pickup with different skins.
//
// by Azarael
//=============================================

class BallisticCamoHandgunPickup extends BallisticHandgunPickup;

var int 		CamoIndex, OldCamoIndex;

replication
{
	reliable if (Role == ROLE_Authority)
		CamoIndex;
}

simulated function PostNetReceive()
{
	if (CamoIndex != OldCamoIndex)
	{
		OldCamoIndex = CamoIndex;
		Skins[0] = class<BallisticCamoHandgun>(InventoryType).default.CamoMaterials[CamoIndex];
	}
		
	Super.PostNetReceive();
}

defaultproperties
{
	CamoIndex=-1
	OldCamoIndex=-1
	bNetNotify=True
}
