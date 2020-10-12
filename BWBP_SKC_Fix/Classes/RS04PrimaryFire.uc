//=============================================================================
// RS04PrimaryFire.
//
// Med power, med range, low recoil pistol fire
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class RS04PrimaryFire extends BallisticInstantFire;
var() Actor						SMuzzleFlash;		// Silenced Muzzle flash stuff
var() class<Actor>				SMuzzleFlashClass;
var() Name						SFlashBone;
var() float						SFlashScaleFactor;

var() sound		ClassicFireSound;
var() sound		AltFireSound;


simulated event ModeDoFire()
{
	if (RS04Pistol(Weapon).CamoIndex == 6) 
		     BallisticFireSound.Sound=ClassicFireSound;
	else if (RS04Pistol(Weapon).CamoIndex == 4 || RS04Pistol(Weapon).CamoIndex == 5) 
		     BallisticFireSound.Sound=AltFireSound;
	Super.ModeDoFire();

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
    if (RS04Pistol(Weapon).CamoIndex != 1 && MuzzleFlash != None)
        MuzzleFlash.Trigger(Weapon, Instigator);
    else if (RS04Pistol(Weapon).CamoIndex == 1 && SMuzzleFlash != None)
        SMuzzleFlash.Trigger(Weapon, Instigator);

	if (!bBrassOnCock)
		EjectBrass();
}

// Remove effects
simulated function DestroyEffects()
{
	Super.DestroyEffects();

	class'BUtil'.static.KillEmitterEffect (MuzzleFlash);
	class'BUtil'.static.KillEmitterEffect (SMuzzleFlash);
}

simulated function SendFireEffect(Actor Other, vector HitLocation, vector HitNormal, int Surf, optional vector WaterHitLoc)
{
	BallisticAttachment(Weapon.ThirdPersonActor).BallisticUpdateHit(Other, HitLocation, HitNormal, Surf, RS04Pistol(Weapon).CamoIndex == 1, WaterHitLoc);
}

function ServerPlayFiring()
{
	if (RS04Pistol(Weapon) != None && RS04Pistol(Weapon).CamoIndex == 1 && SilencedFireSound.Sound != None)
		Weapon.PlayOwnedSound(SilencedFireSound.Sound,SilencedFireSound.Slot,SilencedFireSound.Volume,SilencedFireSound.bNoOverride,SilencedFireSound.Radius,SilencedFireSound.Pitch,SilencedFireSound.bAtten);
	else if (BallisticFireSound.Sound != None)
		Weapon.PlayOwnedSound(BallisticFireSound.Sound,BallisticFireSound.Slot,BallisticFireSound.Volume,BallisticFireSound.bNoOverride,BallisticFireSound.Radius,BallisticFireSound.Pitch,BallisticFireSound.bAtten);

    if (FireCount > 0)
    {
        if (Weapon.HasAnim(FireLoopAnim))
            BW.SafePlayAnim(FireLoopAnim, FireLoopAnimRate, 0.0, ,"FIRE");
        else
            BW.SafePlayAnim(FireAnim, FireAnimRate, TweenTime, ,"FIRE");
    }
    else
        BW.SafePlayAnim(FireAnim, FireAnimRate, TweenTime, ,"FIRE");
}


//Do the spread on the client side
function PlayFiring()
{

	if (BW.MagAmmo - ConsumedLoad < 1)
	{
		BW.IdleAnim = 'IdleOpen';
		BW.ReloadAnim = 'ReloadOpen';
    		if (RS04Pistol(Weapon).bScopeView)
		{
			if (RS04Pistol(Weapon).CurrentWeaponMode == 1)
				FireAnim = 'FireOpen';
			else
				FireAnim = 'FireSightsOpen';
		}
		else if (RS04Pistol(Weapon).CurrentWeaponMode == 1)
			FireAnim = 'FireDualOpen';
		else
			FireAnim = 'FireOpen';
	}
	else
	{
		BW.IdleAnim = 'Idle';
		BW.ReloadAnim = 'Reload';
    		if (RS04Pistol(Weapon).bScopeView)
		{
			if (RS04Pistol(Weapon).CurrentWeaponMode == 1)
				FireAnim = 'Fire';
			else
				FireAnim = 'FireSights';
		}
		else if (RS04Pistol(Weapon).CurrentWeaponMode == 1)
			FireAnim = 'FireDual';
		else
			FireAnim = 'Fire';
	}

	BW.SafePlayAnim(FireAnim, FireAnimRate, TweenTime, ,"FIRE");

    ClientPlayForceFeedback(FireForce);  // jdf
    FireCount++;

	if (RS04Pistol(Weapon) != None && RS04Pistol(Weapon).CamoIndex == 1 && SilencedFireSound.Sound != None)
		Weapon.PlayOwnedSound(SilencedFireSound.Sound,SilencedFireSound.Slot,SilencedFireSound.Volume,,SilencedFireSound.Radius,,true);
	else if (BallisticFireSound.Sound != None)
		Weapon.PlayOwnedSound(BallisticFireSound.Sound,BallisticFireSound.Slot,BallisticFireSound.Volume,,BallisticFireSound.Radius);

}

defaultproperties
{

     ClassicFireSound=Sound'BWBP_SKC_Sounds.M1911.M1911-FireOld'
     AltFireSound=Sound'BWBP_SKC_Sounds.M1911.M1911-Fire2'

     SMuzzleFlashClass=Class'BallisticFix.XK2SilencedFlash'
     SFlashBone="tip"
     SFlashScaleFactor=1.000000
     TraceRange=(Max=5500.000000)
     WaterRangeFactor=0.600000
     MaxWallSize=32.000000
     MaxWalls=2
     Damage=32
     DamageHead=85
     DamageLimb=12
     RangeAtten=0.900000
     WaterRangeAtten=0.500000
     DamageType=Class'BWBP_SKC_Fix.DTM1911Pistol'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTM1911PistolHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTM1911Pistol'
     KickForce=15000
     PenetrateForce=150
     bPenetrate=True
     MuzzleFlashClass=Class'BallisticFix.XK2FlashEmitter'
     BrassClass=Class'BallisticFix.Brass_Pistol'
     BrassBone="ejector"
     BrassOffset=(X=-25.000000,Y=0.000000)
     RecoilPerShot=640.000000
     FireChaos=0.050000
     XInaccuracy=11.500000
     YInaccuracy=11.500000
     SilencedFireSound=(Sound=Sound'BWBP_SKC_Sounds.M1911.M1911-FireSil',Volume=0.800000,Radius=24.000000,bAtten=True)
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.M1911.M1911-Fire',Volume=1.200000)
     bModeExclusive=False
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.070000
     AmmoClass=Class'BallisticFix.Ammo_45HV'
     ShakeRotMag=(X=64.000000,Y=32.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-5.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.300000
     WarnTargetPct=0.100000
}
