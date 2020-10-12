//=============================================================================
// AP_GoldenBullet
//
// A single golden bullet.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AP_GoldenBullet extends BallisticAmmoPickup;

defaultproperties
{
     AmmoAmount=1
     InventoryType=Class'BWBP_SKC_Fix.Ammo_GoldenBullet'
     PickupMessage="You got a Golden Bullet"
     PickupSound=Sound'BallisticSounds2.Ammo.ClipPickup'
     StaticMesh=StaticMesh'BallisticHardware2.D49.D49AmmoBox'
     DrawScale=0.400000
     PrePivot=(Z=75.000000)
     Skins(0)=Shader'BWBP_SKC_Tex.GoldEagle.GoldBullets-Shine'
     CollisionRadius=8.000000
     CollisionHeight=18.000000
}
