//=============================================================================
// AP_A73Clip
//
// The charge module from the A73 Skrith Rifle. Gives ammo between 30 amd 50.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AP_NEXCell extends BallisticAmmoPickup;

defaultproperties
{
     AmmoAmount=100
     InventoryType=Class'BWBP_SKC_Fix.Ammo_NEXCells'
     PickupMessage="You picked up a Skrith energy cell"
     PickupSound=Sound'BallisticSounds2.Ammo.A73CellPickup'
     StaticMesh=StaticMesh'BallisticHardware2.Ammo.A73Clip'
     DrawScale=0.300000
     CollisionRadius=8.000000
     CollisionHeight=4.800000
}
