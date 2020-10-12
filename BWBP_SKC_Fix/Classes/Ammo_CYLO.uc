//=============================================================================
// Ammo_CYLO.
//
// 7.62mm Caseless Ammo. Used by CYLO.
//
// by Casey 'Xavious' Johnson
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class Ammo_CYLO extends BallisticAmmo;

defaultproperties
{
     MaxAmmo=168
     InitialAmount=84
     IconFlashMaterial=Shader'BWBP_SKC_Tex.CYLO.AmmoIcon_CYLOFlash'
     PickupClass=Class'BWBP_SKC_Fix.AP_CYLOClip'
     IconMaterial=Texture'BWBP_SKC_Tex.CYLO.AmmoIcon_CYLO'
     IconCoords=(X2=64,Y2=64)
     ItemName="7.62mm Caseless Ammo"
}
