//=============================================================================
// Ammo_50AP.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class Ammo_50AP extends BallisticAmmo;

defaultproperties
{
     MaxAmmo=70
     InitialAmount=14
     bTryHeadShot=True
     IconFlashMaterial=Shader'BWBP_SKC_Tex.AH104.AmmoIcon_600Flash'
     PickupClass=Class'BWBP_SKC_Fix.AP_50AP'
     IconMaterial=Texture'BWBP_SKC_Tex.AH104.AmmoIcon_600'
     IconCoords=(X2=63,Y2=63)
     ItemName=".600 Armor Piercing HE Rounds"
}
