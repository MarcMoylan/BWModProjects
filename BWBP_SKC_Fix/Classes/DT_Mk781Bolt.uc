//=============================================================================
// DTA49Skrith.
//
// Damage type for A49 projectiles
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_Mk781Bolt extends DT_BWMiscDamage;

defaultproperties
{
     DeathStrings(0)="%k plugged %o into an X-007 bolt."
     DeathStrings(1)="%o's was overstimulated by %k's X-007 bolt."
     DeathStrings(2)="%k happily defibrilated %o with an X-007."
     DeathStrings(3)="%k dropped an electric bolt into %o's bath."
     BloodManagerName="BallisticFix.BloodMan_A73Burn"
     bIgniteFires=True
     DamageDescription=",Plasma,"
     WeaponClass=Class'BWBP_SKC_Fix.Mk781Shotgun'
     DeathString="%k plugged %o into an X-007 bolt."
     FemaleSuicide="%o brought a capacitor to a wall fight."
     MaleSuicide="%o brought a capacitor to a wall fight."
     GibPerterbation=0.200000
     VehicleDamageScaling=0.100000
     KDamageImpulse=1000.000000
     PawnDamageSounds(0)=Sound'BWBP_SKC_Sounds.Misc.XM84-StunEffect'
     DamageOverlayMaterial=Shader'XGameShaders.PlayerShaders.LightningHit'
     DamageOverlayTime=0.900000
     bCauseConvulsions=True
}
