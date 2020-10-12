//=============================================================================
// Ammo_ICISStim. Stab yourself with fun!
//
// by Logan "BlackEagle" Richert.
// uses code by Nolan "Dark Carnivour" Richert.
// Copyright© 2011 RuneStorm. All Rights Reserved.
//=============================================================================
class Ammo_ICISStim extends BallisticAmmo;

defaultproperties
{
     MaxAmmo=4
     InitialAmount=2
     ItemName="ICIS Stim Ammo"
     IconFlashMaterial=Shader'BWBP_SKC_TexExp.Stim.AmmoIcon_StimFlash'
     PickupClass=Class'BWBP_SKC_Fix.ICISPickup'
     IconMaterial=Texture'BWBP_SKC_TexExp.Stim.AmmoIcon_Stim'
     IconCoords=(X1=128,Y1=64,X2=191,Y2=127)
}
