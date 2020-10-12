//=============================================================================
// DTM30A2AssaultHeadPwr.
//
// DamageType for Super M30A2 headshots
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DTM30A2AssaultHeadPwr extends DT_BWBullet;

// HeadShot stuff from old sniper damage ------------------
static function IncrementKills(Controller Killer)
{
	local xPlayerReplicationInfo xPRI;

	if ( PlayerController(Killer) == None )
		return;

	PlayerController(Killer).ReceiveLocalizedMessage( Class'XGame.SpecialKillMessage', 0, Killer.PlayerReplicationInfo, None, None );
	xPRI = xPlayerReplicationInfo(Killer.PlayerReplicationInfo);
	if ( xPRI != None )
	{
		xPRI.headcount++;
		if ( (xPRI.headcount == 15) && (UnrealPlayer(Killer) != None) )
			UnrealPlayer(Killer).ClientDelayedAnnouncementNamed('HeadHunter',15);
	}
}
// --------------------------------------------------------

defaultproperties
{
     bHeaddie=True
     DeathStrings(0)="%o's head was blown away by %k's powered M30A2."
     DeathStrings(1)="%o skull shattered thanks to %k's M30A2 gauss mode."
     DeathStrings(2)="%k targeted %o's head and gaussed it off."
     ShieldDamage=100
     WeaponClass=Class'BWBP_SKC_Fix.M30A2AssaultRifle'
     DeathString="%o's head was blown away by %k's powered M30A2."
     FemaleSuicide="%o saw a super bullet coming up the barrel of her M30A2."
     MaleSuicide="%o saw a super bullet coming up the barrel of his M30A2."
     bArmorStops=False
     bFastInstantHit=True
     bAlwaysSevers=True
     bSpecial=True
     PawnDamageSounds(0)=SoundGroup'BallisticSounds2.BulletImpacts.Headshot'
     GibPerterbation=0.200000
     KDamageImpulse=1000.000000
}
