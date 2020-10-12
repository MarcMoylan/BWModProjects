//==========================================================
// Ballistic Camo Attachment.
//
// Reads the camo from the weapon, then sets itself up with a beautiful new skin.
//
// by Azarael
//===========================================================
class BallisticCamoShotgunAttachment extends BallisticShotgunAttachment;

var() class<BallisticCamoWeapon> CamoWeapon;
var int CamoIndex;

replication
{
	reliable if (bNetInitial && Role == ROLE_Authority)
		CamoIndex;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if (Role == ROLE_Authority && BallisticCamoWeapon(Instigator.Weapon) != None)
		CamoIndex = BallisticCamoWeapon(Instigator.Weapon).CamoIndex;
}

//Do your camo changes here
simulated function PostNetBeginPlay()
{
	if (CamoIndex != default.CamoIndex) 
		Skins[0] = CamoWeapon.default.CamoMaterials[CamoIndex];
//		Skins[0] = BallisticCamoWeapon(Instigator.Weapon).CamoMaterials[CamoIndex];
}

defaultproperties
{
	CamoIndex=-1
}
			
	