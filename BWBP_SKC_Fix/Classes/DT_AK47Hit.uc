//=============================================================================
// DT_AK47Hit.
//
// Damagetype for AK47 Melee attack
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_AK47Hit extends DT_BWBlunt;

defaultproperties
{
     DeathStrings(0)="%k bludgeoned the vodka out of %o with %kh AK stock."
     DeathStrings(1)="%o couldn't withstand the bear-like attacks of %k."
     DeathStrings(2)="%k beat %o with %kh Wooden Stock of Killing."
     DeathStrings(3)="%o was killed by a raving %k's AK-490 stock."
     WeaponClass=Class'BWBP_SKC_Fix.AK47AssaultRifle'
     DeathString="%k bludgeoned the vodka out of %o with %kh AK stock."
     FemaleSuicide="%o beat herself to death with the AK47."
     MaleSuicide="%o beat himself to death with the AK47."
}
