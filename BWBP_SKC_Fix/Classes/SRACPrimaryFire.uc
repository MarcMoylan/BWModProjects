//=============================================================================
// M763PrimaryFire.
//
// Powerful shotgun blast with moderate spread and fair range for a shotgun.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class SRACPrimaryFire extends BallisticProjectileFire;

var() sound		SuperFireSound;
var() sound		FabulousFireSound;

simulated function SwitchCannonMode (byte NewMode)
{
	if (NewMode == 4)
	{
		BallisticFireSound.Sound=FabulousFireSound;
     		ProjectileClass=Class'BWBP_SKC_Fix.LS14Rocket';
		FireRate=0.25;
		RecoilPerShot=150;
		FireAnim=default.FireAnim;
     		FireChaos=Default.FireChaos;
     		FlashScaleFactor=Default.FlashScaleFactor;


	}
	else if (NewMode == 3)
	{
		BallisticFireSound.Sound=SuperFireSound;
     		ProjectileClass=Class'BWBP_SKC_Fix.SRACRocket';
		FireRate=0.5;
		RecoilPerShot=512;
     		FireChaos=0.25;
     		FlashScaleFactor=2;
		FireAnim=default.FireAnim;


	}
	else if (NewMode == 2)
	{
		BallisticFireSound.Sound=SuperFireSound;
     		ProjectileClass=Class'BWBP_SKC_Fix.SRACRocket';
		FireRate=2.0;
		FireAnim='SemiFire';
		RecoilPerShot=1024;
     		FireChaos=0.25;
     		FlashScaleFactor=2;

	}
	
	else
	{
		BallisticFireSound.Sound=default.BallisticFireSound.Sound;
     		ProjectileClass=default.ProjectileClass;
		FireRate=default.FireRate;
		FireAnim=default.FireAnim;
		RecoilPerShot=Default.RecoilPerShot;
     		FireChaos=Default.FireChaos;
     		FlashScaleFactor=Default.FlashScaleFactor;
	}
}

simulated function DestroyEffects()
{
    if (MuzzleFlash != None)
		MuzzleFlash.Destroy();
	Super.DestroyEffects();
}

defaultproperties
{          
     SuperFireSound=Sound'BWBP_SKC_Sounds.SRAC.SRAC-Fire'
	FabulousFireSound=Sound'BWBP_SKC_Sounds.M1911.M1911-Fire2'
     SpawnOffset=(X=15.000000,Y=10.000000,Z=-9.000000)
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.SRAC.SRAC-Fire2',Volume=1.750000)
     bSplashDamage=True
     bRecommendSplashDamage=True
     FireAnim="FireRot"
     bCockAfterEmpty=True
     MuzzleFlashClass=Class'BallisticFix.M50M900FlashEmitter'
     FlashScaleFactor=1.000000
     BrassClass=Class'BWBP_SKC_Fix.Brass_FRAGSpent'
     BrassOffset=(X=-1.000000,Z=-1.000000)
     RecoilPerShot=300.000000
     VelocityRecoil=180.000000
     XInaccuracy=32.000000
     YInaccuracy=32.000000
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.400000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_20mmGrenade'
     ProjectileClass=Class'BWBP_SKC_Fix.SRACLightRocket'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-30.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.900000
     WarnTargetPct=0.100000
}
