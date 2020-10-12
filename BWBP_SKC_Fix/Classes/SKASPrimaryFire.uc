//=============================================================================
// SKASPrimaryFire.
//
// 10-gauge automatic shotgun fire. Quite powerful, deals coach gun dmg.
// Manual mode is the most accurate and powerful single shotgun shot bar CAWS.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class SKASPrimaryFire extends BallisticShotgunFire;
var() sound		SuperFireSound;
var() sound		ClassicFireSound;
var() sound		RapidFireSound;
var() sound		UltraFireSound;
var() sound		XR4FireSound;
var   sound	ChargeSound;
var   float RailPower;
var   float ChargeRate;
var   float PowerLevel;
var   float MaxCharge;

simulated function SwitchCannonMode (byte NewMode)
{
	if (NewMode == 6)
	{
		BallisticFireSound.Sound=XR4FireSound;
		TraceRange.Max=6500;
     		RangeAtten=1.000000;
     		VelocityRecoil=1.000000;
		FireRate=0.13;
     		FlashScaleFactor=0.500000;
		RecoilPerShot=64;
     		FireChaos=0.05;
     		XInaccuracy=333;
     		YInaccuracy=333;
     		TraceCount	= 1;
		AmmoPerFire = 0;
		Damage = 25;
		DamageHead = 40;
		DamageLimb = 13;
     		MuzzleFlashClass=Class'BWBP_SKC_Fix.PlasmaFlashEmitter';
     		ImpactManager=Class'BWBP_SKC_Fix.IM_LS14Impacted';
	}
	else if (NewMode == 5)
	{
		BallisticFireSound.Sound=UltraFireSound;
     		RangeAtten=0.600000;
		FireRate=0.25;
     		FlashScaleFactor=0.500000;
		RecoilPerShot=32;
     		FireChaos=0.01;
     		XInaccuracy=300;
     		YInaccuracy=300;
     		TraceCount= 4;
		Damage = 45;
		DamageHead = 100;
		DamageLimb = 13;
     		MuzzleFlashClass=Class'BWBP_SKC_Fix.LS14FlashEmitter';
     		ImpactManager=Class'BWBP_SKC_Fix.IM_LS14Impacted';
	}
	else if (NewMode == 4)
	{
		BallisticFireSound.Sound=ClassicFireSound;
		FireRate=0.45;
     		RangeAtten=0.300000;
		FireAnim='Fire';
		RecoilPerShot=100;
     		FireChaos=0.01;
     		XInaccuracy=900;
     		YInaccuracy=700;
		Damage = 25;
     		TraceCount	= 12;
		DamageHead = 35;
		DamageLimb = 6;
	}
	else if (NewMode == 3)
	{
		BallisticFireSound.Sound=RapidFireSound;
		FireRate=0.22;
     		RangeAtten=0.250000;
     		XInaccuracy=1200.000000;
     		YInaccuracy=1200.000000;
     		FlashScaleFactor=0.9;
	}
	
	else if (NewMode == 1)
	{
		BallisticFireSound.Sound=SuperFireSound;
		FireRate=2.0;
     		RangeAtten=0.400000;
		FireAnim='SemiFire';
    	 	KickForce=13000;
		RecoilPerShot=1024;
     		XInaccuracy=450.000000;
     		YInaccuracy=450.000000;
     		FireChaos=0.25;
     		FlashScaleFactor=2;
		Damage = 45;
		DamageHead = 100;
		DamageLimb = 13;
	}
	
	else
	{
		if (SKASShotgun(Weapon).CamoIndex==4)
			FireRate=0.30;
		else
			FireRate=default.FireRate;
		RangeAtten=Default.RangeAtten;
		BallisticFireSound.Sound=default.BallisticFireSound.Sound;
		FireAnim=default.FireAnim;
    	 	KickForce=Default.KickForce;
     		XInaccuracy=default.XInaccuracy;
     		YInaccuracy=default.YInaccuracy;
		RecoilPerShot=Default.RecoilPerShot;
     		FireChaos=Default.FireChaos;
		Damage = Default.Damage;
		DamageHead = Default.DamageHead;
		DamageLimb = Default.DamageLimb;
	}
}



simulated event ModeDoFire()
{
    	if (!AllowFire())
        return;
    	if (SKASShotgun(BW).CurrentWeaponMode == 3)
	{
    		if (RailPower + 0.01 >= 1.0)
    		{
        		super.ModeDoFire();
        		SKASShotgun(BW).CoolRate = SKASShotgun(BW).default.CoolRate;
    		}
		else
        		SKASShotgun(BW).CoolRate = SKASShotgun(BW).default.CoolRate * 3;

    		SKASShotgun(BW).Heat += RailPower;
	}
	else
		super.ModeDoFire();
}


function StopFiring()
{
	RailPower = 0;
	super.StopFiring();
}


simulated function ModeTick(float DT)
{
	Super.ModeTick(DT);

	if (SKASShotgun(BW).CurrentWeaponMode == 3)
	{
        	if (bIsFiring)
        	{
            		RailPower = FMin(RailPower + ChargeRate*DT, 1.0);
            		Instigator.AmbientSound = ChargeSound;
        	}
        	else
            		Instigator.AmbientSound = BW.UsedAmbientSound;
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
     ChargeRate=0.850000
     PowerLevel=1.000000
     ChargeSound=Sound'BWBP_SKC_Sounds.SKAS.SKAS-TriCharge'
     SuperFireSound=Sound'BWBP_SKC_Sounds.SKAS.SKAS-Power'
     UltraFireSound=Sound'BWBP_SKC_Sounds.SKAS.SKAS-Ultra2'
     ClassicFireSound=Sound'BWBP_SKC_Sounds.SKAS.SKAS-Classic'
     RapidFireSound=Sound'BWBP_SKC_Sounds.SKAS.SKAS-Rapid'
     XR4FireSound=Sound'BWBP_SKC_Sounds.XR4.XR4-Fire'
     TraceCount=10
     TracerClass=Class'BallisticFix.TraceEmitter_Shotgun'
     ImpactManager=Class'BallisticFix.IM_Shell'
     TraceRange=(Min=2000.000000,Max=4000.000000)
     Damage=30
     DamageHead=42
     DamageLimb=10
     RangeAtten=0.300000
     DamageType=Class'BWBP_SKC_Fix.DTSKASShotgun'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTSKASShotgunHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTSKASShotgun'
     KickForce=10000
     PenetrateForce=100
     bPenetrate=False
     FireAnim="FireRot"
     bCockAfterEmpty=True
     MuzzleFlashClass=Class'BallisticFix.MRT6FlashEmitter'
     FlashScaleFactor=1.000000
     BrassClass=Class'BallisticFix.Brass_MRS138Shotgun'
     BrassOffset=(X=-1.000000,Z=-1.000000)
     RecoilPerShot=300.000000
     VelocityRecoil=180.000000
     XInaccuracy=900.000000
     YInaccuracy=900.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.SKAS.SKAS-Single',Volume=1.300000)
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.400000
     AmmoClass=Class'BallisticFix.Ammo_MRS138Shells'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-30.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.900000
     WarnTargetPct=0.100000
}
