//=============================================================================
// Ammo_NEXCells.
//
// Ammo for the Nexron Plas Edge
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class Ammo_NEXCells extends BallisticAmmo;

defaultproperties
{
     MaxAmmo=100
     InitialAmount=100
     IconFlashMaterial=Shader'BallisticUI2.Icons.AmmoIcon_LGFlash'
     PickupClass=Class'BallisticFix.AP_A73Clip'
     IconMaterial=Texture'BWBP_SKC_Tex.XavPlasCannon.AmmoIconXav'
     IconCoords=(X2=63,Y2=63)
     ItemName="NEX Plas-Edge Cell Ammo"
}
