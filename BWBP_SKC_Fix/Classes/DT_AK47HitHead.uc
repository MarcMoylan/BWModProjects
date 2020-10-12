//=============================================================================
// DT_AK47HitHead.
//
// Damagetype for AK47 Melee attack to the head
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_AK47HitHead extends DT_BWBlunt;

defaultproperties
{
     DeathStrings(0)="%k RAGED LIKE BEAR and beat %o's face with an AK!"
     DeathStrings(1)="%o fell to comrade %k's AK stock in the face."
     DeathStrings(2)="%k smacked the smile off a drunken %o's face with an AK."
     DeathStrings(3)="%k's AK-490 cruelly crushed %o's skull."
     WeaponClass=Class'BWBP_SKC_Fix.AK47AssaultRifle'
     DeathString="%k RAGED LIKE BEAR and beat %o's face with an AK!"
     FemaleSuicide="A drunken %o beat herself with her AK47."
     MaleSuicide="A drunken %o beat himself with his AK47."
}
