//=============================================================================
// SRSM2PrimaryFire.
//
// Accurate medium power rifle fire.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class SRSM2PrimaryFire extends BallisticInstantFire;

var() sound		SuperFireSound;
var() sound		MegaFireSound;
var() sound		ExtraFireSound;
var() sound		SilentFireSound;
var() sound		BlackFireSound;

var() sound		Amp1FireSound; //Incendiary Red
var() sound		Amp2FireSound; //???
var() sound		RegularFireSound;
var bool		bFlashAmp1;
var bool		bFlashAmp2;
var() Actor						MuzzleFlashAmp1;		
var() class<Actor>				MuzzleFlashClassAmp1;	
var() Actor						MuzzleFlashAmp2;		
var() class<Actor>				MuzzleFlashClassAmp2;	
var() Name						AmpFlashBone;
var() float						AmpFlashScaleFactor;

var() Actor						SMuzzleFlash;		// Silenced Muzzle flash stuff
var() class<Actor>				SMuzzleFlashClass;
var() Name						SFlashBone;
var() float						SFlashScaleFactor;


simulated function bool AllowFire()
{
	if (level.TimeSeconds < SRSM2BattleRifle(Weapon).SilencerSwitchTime)
		return false;
//	if (level.TimeSeconds < SRSM2BattleRifle(Weapon).AmplifierSwitchTime)
//		return false;
	return super.AllowFire();
}

function InitEffects()
{
	if (AIController(Instigator.Controller) != None)
		return;
    if ((MuzzleFlashClass != None) && ((MuzzleFlash == None) || MuzzleFlash.bDeleteMe) )
		class'BUtil'.static.InitMuzzleFlash (MuzzleFlash, MuzzleFlashClass, Weapon.DrawScale*FlashScaleFactor, weapon, FlashBone);
    if ((SMuzzleFlashClass != None) && ((SMuzzleFlash == None) || SMuzzleFlash.bDeleteMe) )
		class'BUtil'.static.InitMuzzleFlash (SMuzzleFlash, SMuzzleFlashClass, Weapon.DrawScale*SFlashScaleFactor, weapon, SFlashBone);
	if ((MuzzleFlashClassAmp1 != None) && ((MuzzleFlashAmp1 == None) || MuzzleFlashAmp1.bDeleteMe) )
		class'BUtil'.static.InitMuzzleFlash (MuzzleFlashAmp1, MuzzleFlashClassAmp1, Weapon.DrawScale*FlashScaleFactor, weapon, FlashBone);
    if ((MuzzleFlashClassAmp2 != None) && ((MuzzleFlashAmp2 == None) || MuzzleFlashAmp2.bDeleteMe) )
		class'BUtil'.static.InitMuzzleFlash (MuzzleFlashAmp2, MuzzleFlashClassAmp2, Weapon.DrawScale*AmpFlashScaleFactor, weapon, FlashBone);
}

//Trigger muzzleflash emitter
function FlashMuzzleFlash()
{
    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;
	if (!Instigator.IsFirstPerson() || PlayerController(Instigator.Controller).ViewTarget != Instigator)
		return;
    if (!SRSM2BattleRifle(Weapon).bSilenced && MuzzleFlash != None)
        MuzzleFlash.Trigger(Weapon, Instigator);
    else if (SRSM2BattleRifle(Weapon).bSilenced && SMuzzleFlash != None)
        SMuzzleFlash.Trigger(Weapon, Instigator);
    else if (MuzzleFlashAmp1 != None && bFlashAmp1)
       	MuzzleFlashAmp1.Trigger(Weapon, Instigator);
    else if (MuzzleFlashAmp2 != None && bFlashAmp2)
        MuzzleFlashAmp2.Trigger(Weapon, Instigator);

	if (!bBrassOnCock)
		EjectBrass();
}

// Remove effects
simulated function DestroyEffects()
{
	Super.DestroyEffects();
	class'BUtil'.static.KillEmitterEffect (SMuzzleFlash);
	class'BUtil'.static.KillEmitterEffect (MuzzleFlashAmp1);
	class'BUtil'.static.KillEmitterEffect (MuzzleFlashAmp2);
}

simulated function SwitchWeaponMode (byte NewMode)
{
	if (NewMode == 0) //Standard Fire
	{
		BallisticFireSound.Sound=default.BallisticFireSound.sound;
		BallisticFireSound.Volume=default.BallisticFireSound.Volume;
		RecoilPerShot=default.RecoilPerShot;
		Damage = default.Damage;
		DamageHead = default.DamageHead;
		DamageLimb = default.DamageLimb;
		FireRate=Default.FireRate;
		MaxWalls=default.MaxWalls;
		FlashScaleFactor=default.FlashScaleFactor;
		bFlashAmp1=false;
		bFlashAmp2=false;
		SX45Attachment(Weapon.ThirdPersonActor).bAmp1=false;
		SX45Attachment(Weapon.ThirdPersonActor).bAmp2=false;
		RangeAtten=default.RangeAtten;
	}
	else if (NewMode == 3) //Incendiary Amp
	{
		//BallisticFireSound.Sound=Amp1FireSound;
		BallisticFireSound.Volume=1.500000;
		//RecoilPerShot=512.000000;
		Damage=65.000000;
		//DamageHead=65.000000;
		DamageLimb=40.000000;
		FireRate=0.250000;
		MaxWalls=0;
		FlashScaleFactor=1.100000;
		bFlashAmp1=true;
		bFlashAmp2=false;
		SRSM2Attachment(Weapon.ThirdPersonActor).bAmp1=true;
		SRSM2Attachment(Weapon.ThirdPersonActor).bAmp2=false;
		RangeAtten=1.000000;
	}
	else if (NewMode == 4) //Radiation Amp
	{
		//BallisticFireSound.Sound=Amp2FireSound;
		BallisticFireSound.Volume=1.200000;
		RecoilPerShot=128.000000;
		Damage=15.000000;
		DamageHead=60.000000;
		DamageLimb=10.000000;
		FireRate=0.122500;
		MaxWalls=0;
		FlashScaleFactor=0.400000;
		bFlashAmp1=false;
		bFlashAmp2=true;
		SRSM2Attachment(Weapon.ThirdPersonActor).bAmp1=false;
		SRSM2Attachment(Weapon.ThirdPersonActor).bAmp2=true;
		RangeAtten=1.000000;
	}
	else
	{
		BallisticFireSound.Sound=default.BallisticFireSound.sound;
		BallisticFireSound.Volume=default.BallisticFireSound.Volume;
		RecoilPerShot=default.RecoilPerShot;
		Damage = default.Damage;
		DamageHead = default.DamageHead;
		DamageLimb = default.DamageLimb;
		FireRate=Default.FireRate;
		MaxWalls=default.MaxWalls;
		FlashScaleFactor=default.FlashScaleFactor;
		bFlashAmp1=false;
		bFlashAmp2=false;
		SRSM2Attachment(Weapon.ThirdPersonActor).bAmp1=false;
		SRSM2Attachment(Weapon.ThirdPersonActor).bAmp2=false;
		RangeAtten=default.RangeAtten;
	}
	if (Weapon.bBerserk)
		FireRate *= 0.75;
	if ( Level.GRI.WeaponBerserk > 1.0 )
	    FireRate /= Level.GRI.WeaponBerserk;

}

simulated function bool ImpactEffect(vector HitLocation, vector HitNormal, Material HitMat, Actor Other, optional vector WaterHitLoc)
{
	if (bFlashAmp1)
	{
		Weapon.HurtRadius(10, 92, DamageType, 1, HitLocation);
	}
	return super.ImpactEffect(HitLocation, HitNormal, HitMat, Other, WaterHitLoc);
}

simulated event ModeDoFire()
{
	if (SRSM2BattleRifle(Weapon).CamoIndex == 6) 
	{
		     BallisticFireSound.Sound=SuperFireSound;
			BallisticFireSound.Pitch=1.0;
	}
	else if (SRSM2BattleRifle(Weapon).bSilenced && (SRSM2BattleRifle(Weapon).CamoIndex == 5 || SRSM2BattleRifle(Weapon).CamoIndex == 4)) 
	{
		     SilencedFireSound.Sound=MegaFireSound;
			BallisticFireSound.Pitch=1.0;
	}
	else if (SRSM2BattleRifle(Weapon).CamoIndex == 5 || SRSM2BattleRifle(Weapon).CamoIndex == 4 || SRSM2BattleRifle(Weapon).CamoIndex == 3) 
	{
		     BallisticFireSound.Sound=ExtraFireSound;
			BallisticFireSound.Pitch=1.0;
	}
	else if (SRSM2BattleRifle(Weapon).CamoIndex == 0) 
	{
		     BallisticFireSound.Sound=BlackFireSound;
			BallisticFireSound.Pitch=1.0;
			BallisticFireSound.Volume=1.2;
	}
	Super.ModeDoFire();

}

//Disable fire anim when scoped
function PlayFiring()
{
	if (ScopeDownOn == SDO_Fire)
		BW.TemporaryScopeDown(0.5, 0.9);

	if (SRSM2BattleRifle(Weapon).bSilenced)
	{
		Weapon.SetBoneScale (0, 1.0, SRSM2BattleRifle(Weapon).SilencerBone);
	}
	else
	{
		Weapon.SetBoneScale (0, 0.0, SRSM2BattleRifle(Weapon).SilencerBone);
	}

        BW.SafePlayAnim(FireAnim, FireAnimRate, TweenTime, ,"FIRE");

    ClientPlayForceFeedback(FireForce);  // jdf
    FireCount++;
	// End code from normal PlayFiring()

	if (SRSM2BattleRifle(Weapon) != None && SRSM2BattleRifle(Weapon).bSilenced && SilencedFireSound.Sound != None)
		Weapon.PlayOwnedSound(SilencedFireSound.Sound,SilencedFireSound.Slot,SilencedFireSound.Volume,,SilencedFireSound.Radius,,true);
	else if (SRSM2BattleRifle(Weapon) != None && bFlashAmp1 && Amp1FireSound != None)
		Weapon.PlayOwnedSound(Amp1FireSound,BallisticFireSound.Slot,BallisticFireSound.Volume,,BallisticFireSound.Radius);
	else if (SRSM2BattleRifle(Weapon) != None && bFlashAmp2 && Amp2FireSound != None)
		Weapon.PlayOwnedSound(Amp2FireSound,BallisticFireSound.Slot,BallisticFireSound.Volume,,BallisticFireSound.Radius);
	else if (BallisticFireSound.Sound != None)
		Weapon.PlayOwnedSound(BallisticFireSound.Sound,BallisticFireSound.Slot,BallisticFireSound.Volume,,BallisticFireSound.Radius);

	CheckClipFinished();
}

defaultproperties
{
     Amp1FireSound=Sound'BWBP_SKC_Sounds.SRSM2.SRSM2-LoudFire'
     Amp2FireSound=Sound'BWBP_SKC_Sounds.SRSM2.SRSM2-SpecialFire'
	 AmpFlashBone="tip2"
     AmpFlashScaleFactor=0.250000
	 
     SilentFireSound=Sound'BWBP_SKC_Sounds.SRSM2.SRSM2-Fire2'
	 SMuzzleFlashClass=Class'BallisticFix.XK2SilencedFlash'
     SFlashBone="tip2"
     SFlashScaleFactor=1.000000
	 
     TraceRange=(Min=15000.000000,Max=15000.000000)
     SuperFireSound=Sound'BWBP_SKC_Sounds.SRSM2.SRSM2-LoudFire'
     MegaFireSound=Sound'BWBP_SKC_Sounds.SRSM2.SRSM2-SpecialFire'
     ExtraFireSound=Sound'BWBP_SKC_Sounds.SRSM2.SRSM2-Fire4'
     BlackFireSound=Sound'BWBP_SKC_Sounds.SRSM2.SRSM2-Fire3'
     WaterRangeFactor=0.800000
     MaxWallSize=48.000000
     MaxWalls=3
     Damage=35
     DamageHead=110
     DamageLimb=20
     WaterRangeAtten=0.800000
     DamageType=Class'BWBP_SKC_Fix.DTM14Rifle'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTM14RifleHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTM14Rifle'
     KickForce=20000
     PenetrateForce=180
     bPenetrate=True
     ClipFinishSound=(Sound=Sound'BallisticSounds3.Misc.ClipEnd-1',Volume=0.800000,Pitch=0.900000,Radius=48.000000,bAtten=True)
     DryFireSound=(Sound=Sound'BallisticSounds3.Misc.DryRifle',Volume=0.700000)
     bCockAfterEmpty=True
     MuzzleFlashClass=Class'BallisticFix.R78FlashEmitter'
     FlashScaleFactor=1.200000
     BrassClass=Class'BallisticFix.Brass_Rifle'
     BrassOffset=(X=-10.000000,Y=1.000000,Z=-1.000000)
     RecoilPerShot=140.000000
     FireChaos=0.025000
     XInaccuracy=1.250000
     YInaccuracy=1.500000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.SRSM2.SRSM2-Fire',Pitch=0.900000,Volume=1.500000)
     SilencedFireSound=(Sound=Sound'BWBP_SKC_Sounds.SRSM2.SRSM2-Fire2',Volume=1.500000,Slot=SLOT_Interact,Radius=48.000000,bAtten=True,bNoOverride=False)
     bPawnRapidFireAnim=True
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.150000
     AmmoClass=Class'BallisticFix.Ammo_RS762mm'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-30.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     WarnTargetPct=0.200000
     aimerror=800.000000
     BotRefireRate=0.150000

}
