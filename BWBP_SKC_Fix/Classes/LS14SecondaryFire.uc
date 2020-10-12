//=============================================================================
// M50SecondaryFire.
//
// A grenade that bonces off walls and detonates a certain time after impact
// Good for scaring enemies out of dark corners and not much else
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class LS14SecondaryFire extends BallisticProjectileFire;

var() int ProjPerFire;

var   bool		bLoaded;
/*
function DoFireEffect()
{
    local Vector StartTrace, StartProj, X, Y, Z, Start, End, HitLocation, HitNormal;
    local Rotator R, Aim;
	local actor Other;
	local actor Other2;
    local int p;
    local int SpawnCount;
    local float theta;

    Weapon.GetViewAxes(X,Y,Z);
    // the to-hit trace always starts right in front of the eye
    Start = Instigator.Location + Instigator.EyePosition();

    StartTrace = Start + X*SpawnOffset.X + Z*SpawnOffset.Z;
    if ( !Weapon.WeaponCentered() )
	    StartTrace = StartTrace + Weapon.Hand * Y*SpawnOffset.Y;


    // Inserted Epic code segment.
    // check if projectile would spawn through a wall and adjust start location accordingly
    Other = Trace (HitLocation, HitNormal, StartTrace, Start, true);
   if (Other != None)
   {
       StartProj = HitLocation;
   }

 switch (SpreadStyle)
    {
    case SS_Random:
        X = Vector(Aim);
        for (p = 0; p < SpawnCount; p++)
        {
            R.Yaw = Spread * (FRand()-0.5);
            R.Pitch = Spread * (FRand()-0.5);
            R.Roll = Spread * (FRand()-0.5);
            SpawnProjectile(StartProj, Rotator(X >> R));
        }
        break;
    case SS_Line:
        for (p = 0; p < SpawnCount; p++)
        {
            theta = Spread*PI/32768*(p - float(SpawnCount-1)/2.0);
            X.X = Cos(theta);
            X.Y = Sin(theta);
            X.Z = 0.0;
            SpawnProjectile(StartProj, Rotator(X >> Aim));
        }
        break;
    default:
        SpawnProjectile(StartProj, Aim);
    }


	Aim = GetFireAim(StartTrace);
	Aim = Rotator(GetFireSpread() >> Aim);
      SpawnCount = Max(1, ProjPerFire * int(Load));

	End = Start + (Vector(Aim)*MaxRange());
	Other2 = Trace (HitLocation, HitNormal, End, Start, true);

	if (Other == None)
	{
		if (Other2 != None)
			Aim = Rotator(HitLocation-StartTrace);
		SpawnProjectile(StartTrace, Aim);
	}
	else //If too close, fire at wall instead.
		SpawnProjectile(StartProj, Aim);


	SendFireEffect(none, vect(0,0,0), StartTrace, 0);
	Super.DoFireEffect();
}*/


simulated function bool AllowFire()
{
	if (LS14Carbine(Weapon).bOverloaded || !super.AllowFire())
		return false;
	if (LS14Carbine(Weapon).Rockets < 1)
	{
		if (!bPlayedDryFire && DryFireSound.Sound != None)
		{
			Weapon.PlayOwnedSound(DryFireSound.Sound,DryFireSound.Slot,DryFireSound.Volume,DryFireSound.bNoOverride,DryFireSound.Radius,DryFireSound.Pitch,DryFireSound.bAtten);
			bPlayedDryFire=true;
		}
		BW.bNeedReload = BW.MayNeedReload(ThisModeNum, 0);

		LS14Carbine(Weapon).EmptyAltFire(1);
		return false;		// Is there ammo in weapon's mag
	}
	return true;
}

simulated event ModeDoFire()
{
	if (!AllowFire())
		return;

	Super.ModeDoFire();
    	LS14Carbine(Weapon).Rockets -= 1;

	LS14Carbine(Weapon).UpdateGLIndicator();
}

defaultproperties
{
     bLoaded=True
     SpawnOffset=(X=15.000000,Y=10.000000,Z=-9.000000)
     bUseWeaponMag=False
     MuzzleFlashClass=Class'BallisticFix.M50M900FlashEmitter'
     FlashBone="tip3"
     RecoilPerShot=256.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.LS14.Rocket-Launch')
     bSplashDamage=True
     bRecommendSplashDamage=True
     bTossed=True
     bModeExclusive=False
     PreFireAnim="GrenadePrepFire"
     FireAnim="RLFire"
     FireForce="AssaultRifleAltFire"
     FireRate=0.020000
     FlashScaleFactor=2.600000
	AmmoPerFire=0
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_LS14Rocket'
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-20.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     ProjectileClass=Class'BWBP_SKC_Fix.LS14Rocket'
     BotRefireRate=0.300000
     WarnTargetPct=0.300000
     SpreadStyle=SS_Random
}
