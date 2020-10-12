//=============================================================================
// Ammo_CX61Flechette.
//
// 10mm Depleted Uranium AP flechettes. Cryon based, used in CX61.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class Ammo_CX61Flechette extends BallisticAmmo;

defaultproperties
{
     MaxAmmo=64
     InitialAmount=32
     bTryHeadShot=True
     IconFlashMaterial=Shader'BallisticUI2.Icons.AmmoIcon_SRSFlash'
     PickupClass=Class'BWBP_SKC_Fix.AP_CX61Mag'
     IconMaterial=Texture'BWBP3-Tex.SRS900.AmmoIcon_SRSClips'
     IconCoords=(X1=128,X2=191,Y2=63)
     ItemName="10mm DU Flechettes"
}
