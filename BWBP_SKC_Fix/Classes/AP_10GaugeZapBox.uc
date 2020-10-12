//=============================================================================
// AP_10GaugeZapBox.
//
// A box of 18 10 gauge dartshotgun shells.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AP_10GaugeZapBox extends BallisticAmmoPickup;

defaultproperties
{
     AmmoAmount=6
     InventoryType=Class'BWBP_SKC_Fix.Ammo_10GaugeZap'
     PickupMessage="You picked up 6 X-007s for the Mk.781"
     PickupSound=Sound'BallisticSounds2.Ammo.ShotBoxPickup'
     StaticMesh=StaticMesh'BallisticHardware2.Ammo.M763ShellBox'
     DrawScale=0.300000
     CollisionRadius=8.000000
     CollisionHeight=4.500000
}
