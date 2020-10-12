//=============================================================================
// AP_Frag12Box
//
// some boom booms for the boom boom gun
//
// by George W. Bush
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AP_Frag12Box extends BallisticAmmoPickup;

simulated event PreBeginplay()
{
}

defaultproperties
{
     AmmoAmount=9
     InventoryType=Class'BWBP_SKC_Fix.Ammo_20mmGrenade'
     PickupMessage="You picked up 9 FRAG-12 explosives"
     PickupSound=Sound'BallisticSounds2.Ammo.GrenadePickup'
     StaticMesh=StaticMesh'BWBP_SKC_Static.Bulldog.FRAG12Ammo'
     DrawScale=0.300000
     CollisionRadius=8.000000
     CollisionHeight=10.000000
     PrePivot=(Z=-2.000000)
}
