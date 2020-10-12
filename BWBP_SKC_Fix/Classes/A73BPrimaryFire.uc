//=============================================================================
// A73PrimaryFire.
//
// A73 primary fire is a fast moving projectile that goes through enemies and
// isn't hard to spot ITS ALSO A FIRE
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class A73BPrimaryFire extends BallisticProjectileFire;

var() sound		ChargeFireSound;
var() sound		PowerFireSound;

simulated event ModeTick(float DT)
{
	Super.ModeTick(DT);

	if (Weapon.SoundPitch != 36)
	{
		if (Instigator.DrivenVehicle!=None)
			Weapon.SoundPitch = 36;
		else
			Weapon.SoundPitch = Max(36, Weapon.SoundPitch - 8*DT);
	}
}

function PlayFiring()
{
	Super.PlayFiring();

	Weapon.SoundPitch = Min(120, Weapon.SoundPitch + 8);
}


simulated function SwitchCannonMode (byte NewMode)
{
	if (NewMode == 0)
	{
		ProjectileClass=Class'A73BProjectile';
//     		SpawnOffset.X=10.000000;
		BallisticFireSound.Sound=ChargeFireSound;
		FireRate=0.157500;
		FireAnim='Fire';
		FireLoopAnim='';
		FireEndAnim='';
		bLeadTarget=true;
		bInstantHit=false;
		GotoState('');
		AmmoPerFire=2;
		RecoilPerShot=102;
		FireChaos = 0.005;
		bSplashDamage=false;
		bRecommendSplashDamage=false;
	}
	
	else if (NewMode == 1)
	{
		ProjectileClass=Class'A73BPower';
//     		SpawnOffset.X=80.000000;
		FireRate=0.850000;
		BallisticFireSound.Sound=PowerFireSound;
		FireAnim='Fire';
		FireLoopAnim='';
		FireEndAnim='';
		bLeadTarget=true;
		bInstantHit=false;
		GotoState('');
		AmmoPerFire=8;
		RecoilPerShot=241;
		FireChaos = 0.02;
		bSplashDamage=True;
		bRecommendSplashDamage=True;
	}
	else
	{
		ProjectileClass=Class'A73BProjectile';
//     		SpawnOffset.X=10.000000;
		FireRate=0.157500;
		BallisticFireSound.Sound=ChargeFireSound;
		FireAnim='Fire';
		FireLoopAnim='';
		FireEndAnim='';
		bLeadTarget=true;
		bInstantHit=false;
		GotoState('');
		AmmoPerFire=2;
		RecoilPerShot=102;
		FireChaos = 0.005;
		bSplashDamage=false;
		bRecommendSplashDamage=false;
	}
	if (Weapon.bBerserk)
		FireRate *= 0.75;
	if ( Level.GRI.WeaponBerserk > 1.0 )
	    FireRate /= Level.GRI.WeaponBerserk;

	Load=AmmoPerFire;
}

function StartBerserk()
{

	if (BW.CurrentWeaponMode == 1)
    	FireRate = 0.85;
	else
    	FireRate = 0.15;
   	FireRate *= 0.75;
    FireAnimRate = default.FireAnimRate/0.75;
    ReloadAnimRate = default.ReloadAnimRate/0.75;
}

function StopBerserk()
{

	if (BW.CurrentWeaponMode == 1)
    	FireRate = 0.85;
	else
    	FireRate = 0.15;
    FireAnimRate = default.FireAnimRate;
    ReloadAnimRate = default.ReloadAnimRate;
}

function StartSuperBerserk()
{

	if (BW.CurrentWeaponMode == 1)
    	FireRate = 0.85;
	else
    	FireRate = 0.15;
    FireRate /= Level.GRI.WeaponBerserk;
    FireAnimRate = default.FireAnimRate * Level.GRI.WeaponBerserk;
    ReloadAnimRate = default.ReloadAnimRate * Level.GRI.WeaponBerserk;
}

defaultproperties
{
     ChargeFireSound=Sound'BWBP_SKC_Sounds.A73E.A73E-Fire'
     PowerFireSound=Sound'BWBP_SKC_Sounds.A73E.A73E-Power'
     SpawnOffset=(X=10.000000,Y=10.000000,Z=-9.000000)
     MuzzleFlashClass=Class'BWBP_SKC_Fix.A73BFlashEmitter'
     RecoilPerShot=102.000000
     XInaccuracy=9.000000
     YInaccuracy=6.000000
     AmmoPerFire=2
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.A73E.A73E-Fire',Volume=1.200000,Slot=SLOT_Interact,bNoOverride=False)
     bPawnRapidFireAnim=True
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.157500
     AmmoClass=Class'BallisticFix.Ammo_Cells'
     ShakeRotMag=(X=32.000000,Y=10.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=1.750000
     ShakeOffsetMag=(X=-3.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=1.750000
     ProjectileClass=Class'BWBP_SKC_Fix.A73BProjectile'
     WarnTargetPct=0.200000
}
