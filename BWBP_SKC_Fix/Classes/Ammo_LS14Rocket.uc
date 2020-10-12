//=============================================================================
// Ammo_LS14Rocket
//
// Ammo for Carbine's rocket launcher.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class Ammo_LS14Rocket extends BallisticAmmo;
/*
var   LS14Carbine		DaM50;

function bool HandlePickupQuery(Pickup Item)
{
	if (Super.HandlePickupQuery(Item))
	{
		if (DaM50 != None)
			DaM50.GrenadePickedUp();
		return true;
	}
	return false;
}*/

defaultproperties
{
     MaxAmmo=15
     InitialAmount=3
     IconFlashMaterial=Shader'BallisticUI2.Icons.AmmoIconsFlashing'
     PickupClass=Class'BWBP_SKC_Fix.AP_LS14Rockets'
     IconMaterial=Texture'BallisticUI2.Icons.AmmoIconPage'
     IconCoords=(X1=128,X2=191,Y2=63)
     ItemName="LS14 Rockets"
}
