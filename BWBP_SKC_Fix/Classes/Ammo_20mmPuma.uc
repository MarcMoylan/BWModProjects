//=============================================================================
// Ammo_20mmPuma.
//
// 20mm power cells for the PUMA
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class Ammo_20mmPuma extends BallisticAmmo;

defaultproperties
{
     MaxAmmo=40
     InitialAmount=8
     IconFlashMaterial=Shader'BallisticUI2.Icons.AmmoIcon_12GaugeFlash'
     PickupClass=Class'BWBP_SKC_Fix.AP_PumaCells'
     IconMaterial=Texture'BWBP_SKC_TexExp.M1014.AmmoIcon_10GaugeDartBox'
     IconCoords=(X2=63,Y2=63)
     ItemName="20mm PUMA Power Cells"
}
