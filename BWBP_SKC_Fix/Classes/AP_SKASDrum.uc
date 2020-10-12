//=============================================================================
// AP_SKASDrum
//
// Two ammunition drums for the SKAS-21
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AP_SKASDrum extends BallisticAmmoPickup;

defaultproperties
{
     AmmoAmount=36
     InventoryType=Class'BallisticFix.Ammo_MRS138Shells'
     PickupMessage="You got two 10-gauge ammo drums"
     PickupSound=Sound'BallisticSounds2.Ammo.ShotBoxPickup'
     StaticMesh=StaticMesh'BWBP_SKC_Static.SKAS.SKASShotgunAmmo'
     DrawScale=0.600000
     PrePivot=(Z=13.000000)
     CollisionRadius=8.000000
     CollisionHeight=4.800000
}
