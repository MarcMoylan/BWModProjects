//=============================================================================
// Ammo_SMAT.
//
// Ammo for the SMAA launcher
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class Ammo_SMAT extends BallisticAmmo;

defaultproperties
{
     MaxAmmo=12
     InitialAmount=2
     IconFlashMaterial=Shader'BallisticUI2.Icons.AmmoIconsFlashing'
     PickupClass=Class'BWBP_SKC_Fix.AP_SMATAmmo'
     IconMaterial=Texture'BWBP_SKC_Tex.SMAA.AmmoIcon_SMAT'
     IconCoords=(X1=128,Y1=64,X2=191,Y2=127)
}
