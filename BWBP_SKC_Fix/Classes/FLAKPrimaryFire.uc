//=============================================================================
// M763PrimaryFire.
//
// Powerful shotgun blast with moderate spread and fair range for a shotgun.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class FLAKPrimaryFire extends BallisticShotgunFire;

simulated function DestroyEffects()
{
    if (MuzzleFlash != None)
		MuzzleFlash.Destroy();
	Super.DestroyEffects();
}


// Get aim then run several individual traces using different spread for each one
function DoFireEffect()
{
    local Vector StartTrace;
    local Rotator R, Aim;
	local int i;

	Aim = GetFireAim(StartTrace);
	for (i=0;i<TraceCount;i++)
	{
		R = Rotator(GetFireSpread() >> Aim);
		DoTrace(StartTrace, R);
	}
	// Tell the attachment the aim. It will calculate the rest for the clients
	SendFireEffect(none, Vector(Aim)*TraceRange.Max, StartTrace, 0);

	Super(BallisticFire).DoFireEffect();

/*	if (Instigator.Base != none && VSize(Instigator.velocity - Instigator.base.velocity) > 220)
		{
		if (Instigator != None)
			Instigator.TakeDamage(Rand(10), Instigator, Instigator.Location, -Vector(Instigator.GetViewRotation())*10, class'DT_MAC');
		}*/

}

defaultproperties
{
     TraceCount=30
     TracerClass=Class'BallisticFix.TraceEmitter_Shotgun'
     ImpactManager=Class'BallisticFix.IM_Shell'
     TraceRange=(Min=2000.000000,Max=4000.000000)
     Damage=55
     DamageHead=70
     DamageLimb=25
     RangeAtten=0.300000
     DamageType=Class'BWBP_SKC_Fix.DT_MD402Flak'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_MD402Flak'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_MD402Flak'
     KickForce=20000
     PenetrateForce=500
     bPenetrate=True
     bCockAfterEmpty=True
     MuzzleFlashClass=Class'BallisticFix.M50FlashEmitter'
     FlashScaleFactor=1.000000
     BrassOffset=(X=-1.000000,Z=-1.000000)
     RecoilPerShot=2048.000000
     VelocityRecoil=1850.000000
     XInaccuracy=1600.000000
     YInaccuracy=1600.000000
     BallisticFireSound=(Sound=SoundGroup'BWBP_SKC_Sounds.Misc.FLAK-Fire',Volume=1.800000)
     FireEndAnim=
     TweenTime=0.000000
     FireRate=1.500000
     AmmoClass=Class'BallisticFix.Ammo_MRS138Shells'
     ShakeRotMag=(X=256.000000,Y=128.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.500000
     ShakeOffsetMag=(X=-50.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.500000
     BotRefireRate=0.900000
     WarnTargetPct=0.100000
}
