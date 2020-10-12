//=============================================================================
// FG50PrimaryFire.
//
// Very automatic, bullet style instant hit. Not kinda automatic. Very automatic.
// 50 cal fire. Stronger than M925. Hits like truck. Makes pretty effects.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class FG50PrimaryFire extends BallisticInstantFire;
var() sound		SpecialFireSound;
var   Actor		Heater;

simulated function SwitchCannonMode (byte NewMode)
{
	if (NewMode == 0)
	{
		     BallisticFireSound.Sound=SpecialFireSound;
			FireAnim='CFire';
			BallisticFireSound.Pitch=1.0;
     			RecoilPerShot=256.000000;
     			VelocityRecoil=64.000000;
     			FG50MachineGun(Weapon).RecoilDeclineDelay=0.15;
			FireRate 	= 0.65;
	}
	else
	{
		     BallisticFireSound.Sound=default.BallisticFireSound.sound;
			FireAnim='Fire';
			BallisticFireSound.Pitch=default.BallisticFireSound.pitch;
			RecoilPerShot=default.RecoilPerShot;
			VelocityRecoil=default.VelocityRecoil;
     			FG50MachineGun(Weapon).RecoilDeclineDelay=FG50MachineGun(Weapon).default.RecoilDeclineDelay;
			FireRate = default.FireRate;
	}
	if (Weapon.bBerserk)
		FireRate *= 0.75;
	if ( Level.GRI.WeaponBerserk > 1.0 )
	    FireRate /= Level.GRI.WeaponBerserk;

}


simulated function DestroyEffects()
{
	Super.DestroyEffects();
	if (Heater != None)
		Heater.Destroy();
}

simulated function bool ImpactEffect(vector HitLocation, vector HitNormal, Material HitMat, Actor Other, optional vector WaterHitLoc)
{
	Weapon.HurtRadius(5, 96, DamageType, 1, HitLocation);
	return super.ImpactEffect(HitLocation, HitNormal, HitMat, Other, WaterHitLoc);
}


simulated function InitEffects()
{
	if (AIController(Instigator.Controller) != None)
		return;
	if (Heater == None || Heater.bDeleteMe )
		class'BUtil'.static.InitMuzzleFlash (Heater, class'FG50Heater', Weapon.DrawScale*FlashScaleFactor, weapon, 'tip3');
	FG50Heater(Heater).SetHeat(0.0);
	FG50MachineGun(Weapon).Heater = FG50Heater(Heater);
	super.InitEffects();
}


defaultproperties
{
     SpecialFireSound=Sound'BWBP_SKC_Sounds.X82.X82-Fire2'
     TraceRange=(Min=7500000.000000,Max=7500000.000000)
     WaterRangeFactor=0.800000
     PDamageFactor=0.800000
     WallPDamageFactor=0.800000
     MaxWallSize=72.000000
     MaxWalls=4
     Damage=65
     DamageHead=145
     DamageLimb=35
     WaterRangeAtten=0.800000
     DamageType=Class'BWBP_SKC_Fix.DT_FG50Torso'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_FG50Head'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_FG50Limb'
     KickForce=20000
     PenetrateForce=200
     bPenetrate=True
     DryFireSound=(Sound=Sound'BallisticSounds2.D49.D49-DryFire',Volume=0.700000)
     bCockAfterEmpty=True
     MuzzleFlashClass=Class'BWBP_SKC_Fix.FG50FlashEmitter'
     FlashScaleFactor=1.500000
     BrassClass=Class'BWBP_SKC_Fix.Brass_BMGInc'
     BrassBone="tip"
     BrassOffset=(X=-80.000000,Y=1.000000)
     RecoilPerShot=512.000000
     XInaccuracy=3.000000
     YInaccuracy=3.750000
//     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.X82.X82-Fire3',Pitch=0.700000,Volume=7.100000,Slot=SLOT_Interact,bNoOverride=False)
     BallisticFireSound=(Sound=Sound'BWBP_SKC_SoundsExp.AS50.FG50-Fire',Volume=7.100000,Slot=SLOT_Interact,bNoOverride=False)
     bPawnRapidFireAnim=True
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.200000
     VelocityRecoil=125.000000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_50Inc'
     ShakeRotMag=(X=512.000000,Y=512.000000)
     ShakeRotRate=(X=20000.000000,Y=20000.000000,Z=20000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-30.000000)
     ShakeOffsetRate=(X=-2000.000000)
     ShakeOffsetTime=2.000000
     WarnTargetPct=0.200000
     aimerror=900.000000
}
