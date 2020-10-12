//=============================================================================
// AP_50IncDrum.
//
// 50 Rounds of 50 cal incendiary ammo for the FSSG-50 and FG50
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AP_50IncDrum extends BallisticAmmoPickup;

defaultproperties
{
     AmmoAmount=40
     InventoryType=Class'BWBP_SKC_Fix.Ammo_50Inc'
     PickupMessage="You picked up a 50 round drum of .50 incendiary ammo"
     PickupSound=Sound'BallisticSounds2.Ammo.MGBoxPickup'
     StaticMesh=StaticMesh'BWBP_SKC_StaticExp.FG50.FG50AmmoPickup'
     DrawScale=0.500000
     CollisionRadius=8.000000
     CollisionHeight=5.500000
}
