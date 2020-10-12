//=============================================================================
// Ammo_MetalStorm.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class Ammo_MetalStorm extends BallisticAmmo;

defaultproperties
{
     MaxAmmo=1800
     InitialAmount=450
     bTryHeadShot=True
     IconFlashMaterial=Shader'BallisticUI2.Icons.AmmoIconsFlashing'
     PickupClass=Class'BWBP_SKC_Fix.AP_42MachineGun'
     IconMaterial=Texture'BWBP_SKC_Tex.M30A2.AmmoIcon_M30A2'
     IconCoords=(X1=128,X2=191,Y2=63)
     ItemName="3mm Metal Storm Projectiles"
}
