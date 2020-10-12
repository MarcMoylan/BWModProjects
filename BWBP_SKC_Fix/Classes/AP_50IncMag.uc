//=============================================================================
// AP_50IncMag.
//
// 50 Rounds of 50 cal incendiary ammo for the FSSG-50 and FG50
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AP_50IncMag extends BallisticAmmoPickup;

defaultproperties
{
     AmmoAmount=20
     InventoryType=Class'BWBP_SKC_Fix.Ammo_50Inc'
     PickupMessage="You picked up two 10 round mags of .50 incendiary ammo"
     PickupSound=Sound'BallisticSounds2.Ammo.MGBoxPickup'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.FSSG50.FSSG50AmmoPickup'
     DrawScale=0.700000
     CollisionRadius=8.000000
     CollisionHeight=5.500000
}
