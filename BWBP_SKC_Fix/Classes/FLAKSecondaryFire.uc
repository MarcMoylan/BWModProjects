//=============================================================================
// M50SecondaryFire.
//
// A grenade that bonces off walls and detonates a certain time after impact
// Good for scaring enemies out of dark corners and not much else
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class FLAKSecondaryFire extends BallisticProjectileFire;

// Get aim then spawn projectile
function DoFireEffect()
{
    local Vector StartTrace, X, Y, Z, Start, End, HitLocation, HitNormal;
    local Rotator Aim;
	local actor Other;

    Weapon.GetViewAxes(X,Y,Z);
    // the to-hit trace always starts right in front of the eye
    Start = Instigator.Location + Instigator.EyePosition();
//	StartTrace = Start + X*SpawnOffset.X;
//	if (!Weapon.WeaponCentered())
//		StartTrace = StartTrace + Weapon.Hand * Y*SpawnOffset.Y + Z*SpawnOffset.Z;

    StartTrace = Start + X*SpawnOffset.X + Z*SpawnOffset.Z;
    if ( !Weapon.WeaponCentered() )
	    StartTrace = StartTrace + Weapon.Hand * Y*SpawnOffset.Y;

	Aim = GetFireAim(StartTrace);
	Aim = Rotator(GetFireSpread() >> Aim);

	End = Start + (Vector(Aim)*MaxRange());
	Other = Trace (HitLocation, HitNormal, End, Start, true);

	if (Other != None)
		Aim = Rotator(HitLocation-StartTrace);
    SpawnProjectile(StartTrace, Aim);

	SendFireEffect(none, vect(0,0,0), StartTrace, 0);
	Super(BallisticFire).DoFireEffect();

}

defaultproperties
{
     SpawnOffset=(X=15.000000,Y=10.000000,Z=-9.000000)
     MuzzleFlashClass=Class'BallisticFix.M50M900FlashEmitter'
     RecoilPerShot=2048.000000
     XInaccuracy=4.000000
     YInaccuracy=4.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.Misc.Flak-GrenadeFire',Volume=2.800000)
     bSplashDamage=True
     bRecommendSplashDamage=True
     bModeExclusive=False
     FireRate=2.000000
     AmmoClass=Class'BallisticFix.Ammo_M900Grenades'
     ShakeRotMag=(X=128.000000,Y=64.000000,Z=16.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-20.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     ProjectileClass=Class'BWBP_SKC_Fix.FLAKGrenade'
     BotRefireRate=0.300000
     WarnTargetPct=0.300000
}
