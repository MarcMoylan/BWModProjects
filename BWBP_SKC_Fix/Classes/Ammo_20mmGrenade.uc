//=============================================================================
// Ammo_20mmGrenade
//
// Ammo for the Bulldog Alt Fire
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class Ammo_20mmGrenade extends BallisticAmmo;


defaultproperties
{
     MaxAmmo=30
     InitialAmount=6
     IconFlashMaterial=Shader'BWBP_SKC_Tex.SRAC.AmmoIcon_FRAGFlash'
     PickupClass=Class'BWBP_SKC_Fix.AP_Frag12Box'
     IconMaterial=Texture'BWBP_SKC_Tex.SRAC.AmmoIcon_FRAG'
     IconCoords=(X2=64,Y2=64)
     ItemName="FRAG-12 Grenades"
}
