//  =============================================================================
//   AH104PrimaryFire.
//  
//   An extremely strong bullet. Insanely strong.
//  
//   
//   
//  =============================================================================
class GoldenFire extends BallisticInstantFire;

//Do the spread on the client side
function PlayFiring()
{
	if (BW.MagAmmo - ConsumedLoad < 2)
	{
		BW.IdleAnim = 'OpenIdle';
		BW.ReloadAnim = 'OpenReload';
		FireAnim = 'OpenFire';
	}
	else
	{
		BW.IdleAnim = 'Idle';
		BW.ReloadAnim = 'Reload';
		FireAnim = 'Fire';
	}
	super.PlayFiring();
}

defaultproperties
{
     TraceRange=(Min=50000.000000,Max=50000.000000)
     WaterRangeFactor=0.500000
     MaxWallSize=256.000000
     MaxWalls=15
     Damage=2500
     DamageHead=5000
     DamageLimb=1250
     DamageType=Class'BWBP_SKC_Fix.DTGolden'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTGoldenHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTGolden'
     KickForce=35000
     PenetrateForce=250
     bPenetrate=True
     DryFireSound=(Sound=Sound'BallisticSounds2.D49.D49-DryFire',Volume=0.700000)
     bDryUncock=True
     MuzzleFlashClass=Class'BallisticFix.M925FlashEmitter'
     FlashScaleFactor=1.100000
     BrassClass=Class'BallisticFix.Brass_Pistol'
     BrassBone="tip"
     BrassOffset=(X=-30.000000,Y=1.000000)
     RecoilPerShot=256.000000
     VelocityRecoil=25.000000
     FireChaos=0.000000
     XInaccuracy=0.000001
     YInaccuracy=0.000001
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.Eagle.GoldEagle-Fire',Volume=7.100000)
     FireEndAnim=
     TweenTime=0.000000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_GoldenBullet'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-5.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.900000
     WarnTargetPct=0.100000
}
