//=============================================================================
// Ammo_Longhorn. The fart monkey ate all my muffins.
//
// 40mm cluster grenades used by the longhorn
//
// By Sergeant Kelly
// by Logan "BlackEagle" Richert.
// uses code by Nolan "Dark Carnivour" Richert.
// Copyright© 2011 RuneStorm. All Rights Reserved.
//=============================================================================
class Ammo_Longhorn extends BallisticAmmo;

defaultproperties
{
     MaxAmmo=24
     InitialAmount=8
     IconFlashMaterial=Shader'BWBP_SKC_TexExp.Longhorn.AmmoIcon_LonghornFlash'
     PickupClass=Class'BWBP_SKC_Fix.AP_SMRTGrenade'
     IconMaterial=Texture'BWBP_SKC_TexExp.Longhorn.AmmoIcon_Longhorn'
     ItemName="X2 SMRT Grenade"
     IconCoords=(X2=64,Y2=64)
}
