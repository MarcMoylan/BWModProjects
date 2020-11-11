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

var() Actor						SMuzzleFlash;		// Silenced Muzzle flash stuff
var() class<Actor>				SMuzzleFlashClass;
var() Name						SFlashBone;
var() float						SFlashScaleFactor;


simulated function bool AllowFire()
{
	if (level.TimeSeconds < SRSM2BattleRifle(Weapon).SilencerSwitchTime)
		return false;
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

	if (!bBrassOnCock)
		EjectBrass();
}

// Remove effects
simulated function DestroyEffects()
{
	Super.DestroyEffects();
	class'BUtil'.static.KillEmitterEffect (SMuzzleFlash);
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
     			FireRate=0.200000;
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
	else if (BallisticFireSound.Sound != None)
		Weapon.PlayOwnedSound(BallisticFireSound.Sound,BallisticFireSound.Slot,BallisticFireSound.Volume,,BallisticFireSound.Radius);

	CheckClipFinished();
}

defaultproperties
{
     SMuzzleFlashClass=Class'BallisticFix.XK2SilencedFlash'
     SFlashBone="tip2"
     SFlashScaleFactor=1.000000
     TraceRange=(Min=15000.000000,Max=15000.000000)
     SuperFireSound=Sound'BWBP_SKC_Sounds.SRSM2.SRSM2-LoudFire'
     MegaFireSound=Sound'BWBP_SKC_Sounds.SRSM2.SRSM2-SpecialFire'
     SilentFireSound=Sound'BWBP_SKC_Sounds.SRSM2.SRSM2-Fire2'
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
