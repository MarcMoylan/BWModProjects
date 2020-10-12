//=============================================================================
// SKASPrimaryFire.
//
// Triple barrel 10-gauge blast. Not survivable at close range!! 
// Requires a charge time.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class SKASSecondaryFire extends BallisticShotgunFire;

var   float RailPower;
var   float ChargeRate;
var   float PowerLevel;
var   float MaxCharge;
var   sound	ChargeSound;
var   sound	UltraChargeSound;
var() sound		UltraFireSound;

simulated function bool AllowFire()
{
    return super.AllowFire();
}
simulated function SwitchCannonMode (byte NewMode)
{

	if (NewMode == 5)
	{
		BallisticFireSound.Sound=UltraFireSound;
     		RangeAtten=0.600000;
		FireRate=0.70;
     		FlashScaleFactor=0.900000;
		RecoilPerShot=512;
     		FireChaos=0.01;
     		XInaccuracy=400;
     		YInaccuracy=400;
     		TraceCount	= 12;
		Damage = 45;
		DamageHead = 100;
		DamageLimb = 13;
     		MuzzleFlashClass=Class'BWBP_SKC_Fix.LS14FlashEmitter';
     		ImpactManager=Class'BWBP_SKC_Fix.IM_LS14Impacted';
     		ChargeRate=1.750000;
     		ChargeSound=UltraChargeSound;
	}
	
	else
	{
		FireRate=default.FireRate;
		RangeAtten=Default.RangeAtten;
		BallisticFireSound.Sound=default.BallisticFireSound.Sound;
		FireAnim=default.FireAnim;
    	 	KickForce=Default.KickForce;
		RecoilPerShot=Default.RecoilPerShot;
     		FireChaos=Default.FireChaos;
		Damage = Default.Damage;
		DamageHead = Default.DamageHead;
		DamageLimb = Default.DamageLimb;
	}
}


simulated event ModeDoFire()
{
    if (!AllowFire() || SKASShotgun(BW).CamoIndex==6)
        return;

    if (RailPower + 0.01 >= PowerLevel)
    {
        super.ModeDoFire();
        SKASShotgun(BW).CoolRate = SKASShotgun(BW).default.CoolRate;
    }
    else
    {
        SKASShotgun(BW).CoolRate = SKASShotgun(BW).default.CoolRate * 3;
    }

    SKASShotgun(BW).Heat += RailPower;
    RailPower = 0;
}

function float GetDamage (Actor Other, vector HitLocation, vector Dir, out Actor Victim, optional out class<DamageType> DT)
{
	return super.GetDamage (Other, HitLocation, Dir, Victim, DT) * RailPower;
}

simulated function ModeTick(float DT)
{
	Super.ModeTick(DT);

    if (SKASShotgun(BW).Heat <= 0)
    {
        MaxCharge = RailPower;
        if (bIsFiring && SKASShotgun(BW).CamoIndex!=6)
        {
            RailPower = FMin(RailPower + ChargeRate*DT, PowerLevel);
            Instigator.AmbientSound = ChargeSound;

        }
        else
        {
            Instigator.AmbientSound = BW.UsedAmbientSound;

        }

    }
    else
    {
        Instigator.AmbientSound = BW.UsedAmbientSound;
    }



    if (!bIsFiring)
        return;

    if (RailPower >= PowerLevel)// && PowerLevel > 0.2)
    {
        Weapon.StopFire(ThisModeNum);
    }
}

simulated function SendFireEffect(Actor Other, vector HitLocation, vector HitNormal, int Surf, optional vector WaterHitLoc)
{
	SKASAttachment(Weapon.ThirdPersonActor).SKASUpdateHit(Other, HitLocation, HitNormal, Surf);
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
     UltraFireSound=Sound'BWBP_SKC_Sounds.SKAS.SKAS-Ultra'
     UltraChargeSound=Sound'BWBP_SKC_Sounds.SKAS.SKAS-UltraCharge'
     TraceCount=30
     TracerClass=Class'BallisticFix.TraceEmitter_Shotgun'
     ImpactManager=Class'BallisticFix.IM_Shell'
     TraceRange=(Min=3000.000000,Max=4000.000000)
     Damage=42
     DamageHead=58
     DamageLimb=15
     RangeAtten=0.850000
     DamageType=Class'BWBP_SKC_Fix.DTSKASShotgunAlt'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTSKASShotgunHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTSKASShotgunAlt'
     KickForce=20000
	AmmoPerFire=3
     PenetrateForce=100
     bPenetrate=True
     bCockAfterEmpty=True
     bFireOnRelease=True
     bWaitForRelease=True
	FireAnim="FireBig"
     MuzzleFlashClass=Class'BallisticFix.M763FlashEmitter'
     FlashScaleFactor=1.000000
     BrassClass=Class'BallisticFix.Brass_MRS138Shotgun'
     BrassOffset=(X=-1.000000,Z=-1.000000)
     RecoilPerShot=2048.000000
     VelocityRecoil=850.000000
     XInaccuracy=1600.000000
     YInaccuracy=1600.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.SKAS.SKAS-Triple',Volume=2.200000)
     FireEndAnim=
	PreFireAnim="ChargeUp"
     TweenTime=0.000000
     FireRate=1.700000
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
