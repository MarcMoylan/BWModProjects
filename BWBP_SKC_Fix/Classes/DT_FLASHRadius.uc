//=============================================================================
// DT_FLASHRadius.
//
// DamageType for the FLASH incendiary rocket radius
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_FLASHRadius extends DT_BWExplode;

defaultproperties
{
     DeathStrings(0)="%o suffered a firey death thanks to %k's STREAK."
     DeathStrings(1)="%o was flash roasted by %k's incendiary rocket."
     DeathStrings(2)="%k gave %o a good burn with %kh AT40 STREAK."
     DeathStrings(3)="%k's MD40 rocket seared the skin off %o."
     DeathStrings(4)="%k's STREAK rendered %o into a smoldering pile of ash."
     WeaponClass=Class'BWBP_SKC_Fix.FLASHLauncher'
     DeathString="%o suffered a firey death thanks to %k's STREAK."
     FemaleSuicide="%o didn't realize rockets are bad for close range combat."
     MaleSuicide="%o didn't realize rockets are bad for close range combat."
     bDelayedDamage=True
     VehicleDamageScaling=0.300000
     VehicleMomentumScaling=0.400000
}
