//=============================================================================
// Ammo_68mm.
//
// 6.8mm bullet ammo. Advanced round with low spare capacity.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class Ammo_68mm extends BallisticAmmo;

defaultproperties
{
     MaxAmmo=150
     InitialAmount=75
     IconFlashMaterial=Shader'BWBP_SKC_TexExp.LK05.AmmoIcon_LK05Flash'
     PickupClass=Class'BWBP_SKC_Fix.AP_68mmMag'
     IconMaterial=Texture'BWBP_SKC_TexExp.LK05.AmmoIcon_LK05'
     IconCoords=(X2=64,Y2=64)
     ItemName="6.8mm HVHE ammo"
}
