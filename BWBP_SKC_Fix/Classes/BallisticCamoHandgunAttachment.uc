//==========================================================
// Ballistic Camo Attachment.
//
// Reads the camo from the weapon, then sets itself up with a beautiful new skin.
//
// by Azarael
//===========================================================
class BallisticCamoHandgunAttachment extends HandgunAttachment;

var() class<BallisticCamoHandgun> CamoWeapon;
var int CamoIndex;

replication
{
	reliable if (bNetInitial && Role == ROLE_Authority)
		CamoIndex;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if (Role == ROLE_Authority && BallisticCamoHandgun(Instigator.Weapon) != None)
		CamoIndex = BallisticCamoHandgun(Instigator.Weapon).CamoIndex;
}

//Do your camo changes here
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	
	if (CamoIndex != default.CamoIndex) 
		Skins[0] = CamoWeapon.default.CamoMaterials[CamoIndex];
}

defaultproperties
{
	CamoIndex=-1
}
			
	