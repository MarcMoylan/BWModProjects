//  =============================================================================
//   JohnsonPrimaryFire.
//  
//   Powerful projectile attack.
//  
//  =============================================================================
class JohnsonPrimaryFire extends BallisticProjectileFire;


defaultproperties
{
     DryFireSound=(Sound=Sound'BallisticSounds2.D49.D49-DryFire',Volume=0.700000)
     bDryUncock=True
     MuzzleFlashClass=Class'BallisticFix.M925FlashEmitter'
     FlashScaleFactor=1.100000
     BrassClass=Class'BWBP_SKC_Fix.Brass_BOLT'
     BrassBone="ejector"
     BrassOffset=(X=-30.000000,Y=1.000000)
     RecoilPerShot=2048.000000
     VelocityRecoil=200.000000
//     FireChaos=10.000000
     FireRate=0.550000
     FireAnimRate=1.5
     XInaccuracy=16.500000
     YInaccuracy=9.500000
     BallisticFireSound=(Sound=SoundGroup'BWBP_SKC_SoundsExp.Johnson.Johnson-Fire',Volume=7.500000)
     FireEndAnim=
     TweenTime=0.000000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_75BOLT'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-5.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     ProjectileClass=Class'BWBP_SKC_Fix.JohnsonStakeProj'
     BotRefireRate=0.900000
     WarnTargetPct=0.100000
}
