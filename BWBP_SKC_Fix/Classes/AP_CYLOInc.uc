//=============================================================================
// AP_CYLOINC.
//
// A 25 round 7.62mm incendiary magazine.
//
// by Casey 'Xavious' Johnson
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AP_CYLOInc extends BallisticAmmoPickup;

defaultproperties
{
     AmmoAmount=70
     InventoryType=Class'BWBP_SKC_Fix.Ammo_CYLOInc'
     PickupMessage="You got two 35 round 5.56mm incendiary magazines"
     PickupSound=Sound'BallisticSounds2.Ammo.ClipPickup'
     StaticMesh=StaticMesh'BWBP_SKC_Static.CYLO.CYLOAmmo'
     DrawScale=2.350000
     Skins(0)=Shader'BWBP_SKC_Tex.CYLO.CYLO-MainShine'
     CollisionRadius=8.000000
     CollisionHeight=5.200000
}
