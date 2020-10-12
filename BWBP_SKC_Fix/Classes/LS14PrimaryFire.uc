//=============================================================================
// R9PrimaryFire.
//
// Accurate medium-high power rifle fire.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class LS14PrimaryFire extends BallisticInstantFire;


var() Actor						MuzzleFlash2;		// The muzzleflash actor
var   bool			bSecondBarrel;
var   bool			bIsDouble;
var() sound		SpecialFireSound;

function InitEffects()
{
	super.InitEffects();
    if ((MuzzleFlashClass != None) && ((MuzzleFlash2 == None) || MuzzleFlash2.bDeleteMe) )
		class'BUtil'.static.InitMuzzleFlash (MuzzleFlash2, MuzzleFlashClass, Weapon.DrawScale*FlashScaleFactor, weapon, 'tip2');
}

simulated function SwitchCannonMode (byte NewMode)
{
	if (NewMode == 0)
	{
		AmmoPerFire=1;
		RecoilPerShot=100;
		FireChaos = default.FireChaos;
		bIsDouble=false;
     		Damage=default.Damage;
     		DamageHead=default.DamageHead;
     		DamageLimb=default.DamageLimb;
	}
	
	else if (NewMode == 1)
	{
		AmmoPerFire=2;
		RecoilPerShot=2000;
		FireChaos = 1.5;
		bIsDouble=true;
     		Damage=70;
     		DamageHead=150;
     		DamageLimb=50;
	}
	else if (NewMode == 2)
	{
		AmmoPerFire=1;
		RecoilPerShot=50;
		FireChaos = 0.1;
		FireRate= 0.3;
		bIsDouble=false;
     		Damage=default.Damage;
     		DamageHead=default.DamageHead;
     		DamageLimb=default.DamageLimb;
	}
	else
	{
		AmmoPerFire=1;
		RecoilPerShot=100;
     		FireRate=0.100000;
		FireChaos = default.FireChaos;
		bIsDouble=false;
     		Damage=default.Damage;
     		DamageHead=default.DamageHead;
     		DamageLimb=default.DamageLimb;
	}
	if (Weapon.bBerserk)
		FireRate *= 0.75;
	if ( Level.GRI.WeaponBerserk > 1.0 )
	    FireRate /= Level.GRI.WeaponBerserk;

	Load=AmmoPerFire;
}

event ModeDoFire()
{

	if (bIsDouble) 
		     BallisticFireSound.Sound=SpecialFireSound;
	else
		     BallisticFireSound.Sound=default.BallisticFireSound.sound;
	if (AllowFire() && !LS14Carbine(Weapon).bIsReloadingGrenade)
	{
		if (LS14Carbine(Weapon).HeatLevel >= 13)
			FireAnim='Overheat';
		else if (bIsDouble && LS14Carbine(Weapon).HeatLevel >= 10)
			FireAnim='FiddleOne';
		else if ((LS14Carbine(Weapon).HeatLevel > 10.0 && LS14Carbine(Weapon).HeatLevel < 13) || bIsDouble)
			FireAnim='FireBig';
		else
			FireAnim='Fire';

			if (!bSecondBarrel)
			{
				bSecondBarrel=true;
				LS14Carbine(Weapon).bBarrelsOnline=true;
			}
			else
			{
				bSecondBarrel=false;
				LS14Carbine(Weapon).bBarrelsOnline=false;
			}
		super.ModeDoFire();	
	}
	if (LS14Carbine(Weapon).bIsReloadingGrenade)
		LS14Carbine(Weapon).bWantsToShoot=true;
}
//Trigger muzzleflash emitter
function FlashMuzzleFlash()
{
	local Coords C;
	local vector Start, X, Y, Z;

    	if ((Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;
	if (!Instigator.IsFirstPerson() || PlayerController(Instigator.Controller).ViewTarget != Instigator)
		return;

    	if ((bIsDouble /*|| LS14Carbine(Weapon).HeatLevel > 10.0*/) && MuzzleFlash2 !=None && MuzzleFlash != None)
	{
        	MuzzleFlash2.Trigger(Weapon, Instigator);
        	MuzzleFlash.Trigger(Weapon, Instigator);
	}

    	if (bSecondBarrel && MuzzleFlash2 != None) //Checks to alternate
    	{
		C = Weapon.GetBoneCoords('tip2');
        	MuzzleFlash2.Trigger(Weapon, Instigator);
    	}
    	else if (MuzzleFlash != None)
    	{
		C = Weapon.GetBoneCoords('tip');
        	MuzzleFlash.Trigger(Weapon, Instigator);
    	}

    	if (!class'BallisticMod'.default.bMuzzleSmoke)
    		return;
    	Weapon.GetViewAxes(X,Y,Z);
	Start = C.Origin + X * -180 + Y * 3;
//	MuzzleSmoke = Spawn(class'MRT6Smoke', weapon,, Start, Rotator(X));
}


function DoDamage (Actor Other, vector HitLocation, vector TraceStart, vector Dir, int PenetrateCount, int WallCount, optional vector WaterHitLocation)
{
	super.DoDamage(Other, HitLocation, TraceStart, Dir, PenetrateCount, WallCount, WaterHitLocation);
	if (Mover(Other) != None || Vehicle(Other) != None)
		return;
	LS14Carbine(BW).TargetedHurtRadius(5, 48, class'DTLS14Body', 0, HitLocation, Pawn(Other));
}

simulated function bool AllowFire()
{
	if ((LS14Carbine(Weapon).HeatLevel >= 14.5) || !super.AllowFire())
		return false;
	return true;
}

simulated function bool ImpactEffect(vector HitLocation, vector HitNormal, Material HitMat, Actor Other, optional vector WaterHitLoc)
{
	Weapon.HurtRadius(5, 48, DamageType, 0, HitLocation);
	return super.ImpactEffect(HitLocation, HitNormal, HitMat, Other, WaterHitLoc);
}


/*simulated event ModeDoFire()
{
	FireAnim = SliceAnims[SliceAnim];
	SliceAnim++;
	if (SliceAnim >= SliceAnims.Length)
		SliceAnim = 0;

	Super.ModeDoFire();
}*/

function PlayFiring()
{
	Super.PlayFiring();
	if (bIsDouble)
		LS14Carbine(BW).AddHeat(5.50);
	else
		LS14Carbine(BW).AddHeat(1.50);
}


// Get aim then run trace...
function DoFireEffect()
{
	if (level.Netmode == NM_DedicatedServer)
	{
	if (bIsDouble)
		LS14Carbine(BW).AddHeat(5.50);
	else
		LS14Carbine(BW).AddHeat(1.50);
	}
	Super.DoFireEffect();
}

defaultproperties
{
     SpecialFireSound=Sound'BWBP_SKC_Sounds.LS14.Gauss-FireDouble'
     TraceRange=(Min=1500000.000000,Max=1500000.000000)
     MaxWallSize=64.000000
     MaxWalls=3
     Damage=35
     DamageHead=95
     DamageLimb=22
     DamageType=Class'BWBP_SKC_Fix.DTLS14Body'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTLS14Head'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTLS14Limb'
     KickForce=25000
     PenetrateForce=400
     bPenetrate=True
     ClipFinishSound=(Sound=Sound'BWBP_SKC_Sounds.LS14.Gauss-LastShot',Volume=1.000000,Radius=48.000000,bAtten=True)
     DryFireSound=(Sound=Sound'BWBP_SKC_Sounds.LS14.Gauss-Empty',Volume=1.200000)
     MuzzleFlashClass=Class'BWBP_SKC_Fix.LS14FlashEmitter'
//     MuzzleFlashClass=Class'BWBP_SKC_Fix.GRSXXLaserFlashEmitter'
//     MuzzleFlashClass=Class'BWBP_SKC_Fix.VSKSilencedFlash'
     FlashScaleFactor=0.400000
     RecoilPerShot=100.000000
     BallisticFireSound=(Sound=SoundGroup'BWBP_SKC_Sounds.LS14.Gauss-Fire',Volume=0.900000)
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.100000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_Laser'
     ShakeRotMag=(X=200.000000,Y=16.000000)
     ShakeRotRate=(X=5000.000000,Y=5000.000000,Z=5000.000000)
     ShakeRotTime=1.000000
     ShakeOffsetMag=(X=-2.500000)
     ShakeOffsetRate=(X=-500.000000)
     ShakeOffsetTime=1.000000
     BotRefireRate=1.050000
     WarnTargetPct=0.050000
     aimerror=800.000000
}
