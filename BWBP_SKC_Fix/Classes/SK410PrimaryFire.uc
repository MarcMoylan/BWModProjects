//=============================================================================
// SK410PrimaryFire.
//
// Moderately strong shotgun blast with decent spread and fair range for a shotgun.
// Can do more damage than the M763, but requires more shots normally.
//
// Can fire its shells HE mode, however it's nowhere near as strong as a FRAG.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class SK410PrimaryFire extends BallisticShotgunFire;
var() sound		SpecialFireSound;
var() sound		PlasmaFireSound;
var() sound		SlugFireSound;

var() Vector			SpawnOffset;		// Projectile spawned at this offset
var	  Projectile		Proj;				// The projectile actor

simulated event ModeDoFire()
{
	if (SK410Shotgun(Weapon).CamoIndex == 6) 
		     BallisticFireSound.Sound=PlasmaFireSound;
	Super.ModeDoFire();

}


simulated function SwitchCannonMode (byte NewMode)
{
	if (NewMode == 1)
	{
		XInaccuracy=128;
		YInaccuracy=128;
		SK410Attachment(Weapon.ThirdPersonActor).bNoEffect=true;
		ProjectileClass=Class'SK410HEProjectile';
		BallisticFireSound.Sound=SlugFireSound;
		bLeadTarget=true;
		bInstantHit=false;
		GotoState('HESlug');
		bSplashDamage=True;
		bRecommendSplashDamage=True;
		WarnTargetPct=0.10000;
	}
	if (NewMode == 2)
	{
		BallisticFireSound.Sound=PlasmaFireSound;
		BallisticFireSound.Slot=SLOT_Interact;
		BallisticFireSound.bNoOverride=False;
		TraceRange.Max=6500;
     		RangeAtten=1.000000;
     		VelocityRecoil=1.000000;
		FireRate=0.145;
     		FlashScaleFactor=0.500000;
		RecoilPerShot=64;
     		FireChaos=0.05;
     		XInaccuracy=333;
     		YInaccuracy=333;
     		TraceCount= 3;
		AmmoPerFire = 0;
		Damage = 25;
		DamageHead = 40;
		DamageLimb = 13;
     		MuzzleFlashClass=Class'BWBP_SKC_Fix.PlasmaFlashEmitter';
     		ImpactManager=Class'BWBP_SKC_Fix.IM_LS14Impacted';
		ProjectileClass=None;
		bLeadTarget=false;
		bInstantHit=true;
		GotoState('HEShot');
		bSplashDamage=false;
		bRecommendSplashDamage=false;
		WarnTargetPct=0.010000;
	}
	if (NewMode == 3)
	{
		BallisticFireSound.Sound=SpecialFireSound;
		BallisticFireSound.Slot=default.BallisticFireSound.Slot;
		BallisticFireSound.bNoOverride=default.BallisticFireSound.bNoOverride;
		FireRate=0.18;
     		FlashScaleFactor=1.400000;
//		RecoilPerShot=64;
     		FireChaos=0.05;
     		XInaccuracy=900;
     		YInaccuracy=900;
		ProjectileClass=None;
		bLeadTarget=false;
		bInstantHit=true;
		GotoState('HEShot');
		bSplashDamage=false;
		bRecommendSplashDamage=false;
		WarnTargetPct=0.010000;
	}
	else if (NewMode == 0)
	{
		SK410Attachment(Weapon.ThirdPersonActor).bNoEffect=false;
		RangeAtten=Default.RangeAtten;
		BallisticFireSound.Sound=default.BallisticFireSound.Sound;
		BallisticFireSound.Slot=default.BallisticFireSound.Slot;
		BallisticFireSound.bNoOverride=default.BallisticFireSound.bNoOverride;
		FireAnim=default.FireAnim;
    	 	KickForce=Default.KickForce;
		RecoilPerShot=Default.RecoilPerShot;
     		FireChaos=Default.FireChaos;
		Damage = Default.Damage;
		DamageHead = Default.DamageHead;
		DamageLimb = Default.DamageLimb;
		XInaccuracy=Default.XInaccuracy;
		YInaccuracy=Default.YInaccuracy;
		ProjectileClass=None;
		bLeadTarget=false;
		bInstantHit=true;
		GotoState('HEShot');
		bSplashDamage=false;
		bRecommendSplashDamage=false;
		WarnTargetPct=0.010000;
	}
}

simulated state HESlug
{
	// Became complicated when acceleration came into the picture
	// Override for even wierder situations
	function float MaxRange()
	{
		if (ProjectileClass.default.MaxSpeed > ProjectileClass.default.Speed)
		{
			// We know BW projectiles have AccelSpeed
			if (class<BallisticProjectile>(ProjectileClass) != None && class<BallisticProjectile>(ProjectileClass).default.AccelSpeed > 0)
			{
				if (ProjectileClass.default.LifeSpan <= 0)
					return FMin(ProjectileClass.default.MaxSpeed, (ProjectileClass.default.Speed + class<BallisticProjectile>(ProjectileClass).default.AccelSpeed * 2) * 2);
				else
					return FMin(ProjectileClass.default.MaxSpeed, (ProjectileClass.default.Speed + class<BallisticProjectile>(ProjectileClass).default.AccelSpeed * ProjectileClass.default.LifeSpan) * ProjectileClass.default.LifeSpan);
			}
			// For the rest, just use the max speed
			else
			{
				if (ProjectileClass.default.LifeSpan <= 0)
					return ProjectileClass.default.MaxSpeed * 2;
				else
					return ProjectileClass.default.MaxSpeed * ProjectileClass.default.LifeSpan*0.75;
			}
		}
		else // Hopefully this proj doesn't change speed.
		{
			if (ProjectileClass.default.LifeSpan <= 0)
				return ProjectileClass.default.Speed * 2;
			else
				return ProjectileClass.default.Speed * ProjectileClass.default.LifeSpan;
		}
	}

	// Get aim then spawn projectile
	function DoFireEffect()
	{
		local Vector StartTrace, X, Y, Z, Start, End, HitLocation, HitNormal;
		local Rotator Aim;
		local actor Other;

	    Weapon.GetViewAxes(X,Y,Z);
    	// the to-hit trace always starts right in front of the eye
	    Start = Instigator.Location + Instigator.EyePosition();

	    StartTrace = Start + X*SpawnOffset.X + Z*SpawnOffset.Z;
    	if ( !Weapon.WeaponCentered() )
		    StartTrace = StartTrace + Weapon.Hand * Y*SpawnOffset.Y;

		Aim = GetFireAim(StartTrace);
		Aim = Rotator(GetFireSpread() >> Aim);

		End = Start + (Vector(Aim)*MaxRange());
		Other = Trace (HitLocation, HitNormal, End, Start, true);

		if (Other != None)
			Aim = Rotator(HitLocation-StartTrace);
	    SpawnProjectile(StartTrace, Aim);

		SendFireEffect(none, vect(0,0,0), StartTrace, 0);
		// Skip the instant fire version which would cause instant trace damage.
		Super(BallisticFire).DoFireEffect();
	}

	function SpawnProjectile (Vector Start, Rotator Dir)
	{
		Proj = Spawn (ProjectileClass,,, Start, Dir);
		Proj.Instigator = Instigator;
	}
}

simulated state HEShot
{
// Get aim then run several individual traces using different spread for each one
function DoFireEffect()
{
    local Vector StartTrace;
    local Rotator R, Aim;
	local int i;

	Aim = GetFireAim(StartTrace);
	for (i=0;i<TraceCount;i++)
	{
		R = Rotator(GetFireSpread() >> Aim);
		DoTrace(StartTrace, R);
	}
	// Tell the attachment the aim. It will calculate the rest for the clients
	SendFireEffect(none, Vector(Aim)*TraceRange.Max, StartTrace, 0);

	Super(BallisticFire).DoFireEffect();
}

// Even if we hit nothing, this is already taken care of in DoFireEffects()...
function NoHitEffect (Vector Dir, optional vector Start, optional vector HitLocation, optional vector WaterHitLoc)
{
	local Vector V;

	V = Instigator.Location + Instigator.EyePosition() + Dir * TraceRange.Min;
	if (TracerClass != None && Level.DetailMode > DM_Low && class'BallisticMod'.default.EffectsDetailMode > 0 && VSize(V - BallisticAttachment(Instigator.Weapon.ThirdPersonActor).GetTipLocation()) > 200 && FRand() < TracerChance)
		Spawn(TracerClass, instigator, , BallisticAttachment(Instigator.Weapon.ThirdPersonActor).GetTipLocation(), Rotator(V - BallisticAttachment(Instigator.Weapon.ThirdPersonActor).GetTipLocation()));
	if (ImpactManager != None && WaterHitLoc != vect(0,0,0) && Weapon.EffectIsRelevant(WaterHitLoc,false) && bDoWaterSplash)
		ImpactManager.static.StartSpawn(WaterHitLoc, Normal((Instigator.Location + Instigator.EyePosition()) - WaterHitLoc), 9, Instigator);
}

// Spawn the impact effects here for StandAlone and ListenServers cause the attachment won't do it
simulated function bool ImpactEffect(vector HitLocation, vector HitNormal, Material HitMat, Actor Other, optional vector WaterHitLoc)
{
	local int Surf;

	if (ImpactManager != None && WaterHitLoc != vect(0,0,0) && Weapon.EffectIsRelevant(WaterHitLoc,false) && bDoWaterSplash)
		ImpactManager.static.StartSpawn(WaterHitLoc, Normal((Instigator.Location + Instigator.EyePosition()) - WaterHitLoc), 9, Instigator);

	if (!Other.bWorldGeometry && Mover(Other) == None)
		return false;

	if (!bAISilent)
		Instigator.MakeNoise(1.0);
	if (ImpactManager != None && Weapon.EffectIsRelevant(HitLocation,false))
	{
		if (Vehicle(Other) != None)
			Surf = 3;
		else if (HitMat == None)
			Surf = int(Other.SurfaceType);
		else
			Surf = int(HitMat.SurfaceType);
		ImpactManager.static.StartSpawn(HitLocation, HitNormal, Surf, instigator);
		if (TracerClass != None && Level.DetailMode > DM_Low && class'BallisticMod'.default.EffectsDetailMode > 0 && VSize(HitLocation - BallisticAttachment(Weapon.ThirdPersonActor).GetTipLocation()) > 200 && FRand() < TracerChance)
			Spawn(TracerClass, instigator, , BallisticAttachment(Weapon.ThirdPersonActor).GetTipLocation(), Rotator(HitLocation - BallisticAttachment(Weapon.ThirdPersonActor).GetTipLocation()));
	}
	Weapon.HurtRadius(1, 128, DamageType, 1, HitLocation);
	return true;
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
     TraceCount=8
     TracerClass=Class'BWBP_SKC_Fix.TraceEmitter_ShotgunHE'

     SlugFireSound=Sound'BWBP_SKC_Sounds.M781.M781-FireFRAG'
     SpecialFireSound=Sound'BWBP_SKC_Sounds.M781.M783-Single'
     PlasmaFireSound=Sound'BWBP_SKC_Sounds.Misc.Plasma-Fire'

     SpawnOffset=(X=20.000000,Y=9.000000,Z=-9.000000)
     ProjectileClass=Class'BWBP_SKC_Fix.SK410HEProjectile'
     ImpactManager=Class'BWBP_SKC_Fix.IM_ShellHE'
     TraceRange=(Min=4000.000000,Max=6000.000000)
     Damage=(Min=20.000000,Max=30.000000)
     DamageHead=(Min=25.000000,Max=45.000000)
     DamageLimb=(Min=7.000000,Max=14.000000)
     RangeAtten=0.600000
     DamageType=Class'BWBP_SKC_Fix.DT_SK410Shotgun'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_SK410ShotgunHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_SK410Shotgun'
     KickForce=8000
     PenetrateForce=100
     bPenetrate=True
//     bCockAfterEmpty=True
     MuzzleFlashClass=Class'BWBP_SKC_Fix.SK410HeatEmitter'
     FlashScaleFactor=1.600000
     BrassClass=Class'BWBP_SKC_Fix.Brass_ShotgunHE'
     BrassOffset=(X=-1.000000,Z=-1.000000)
     RecoilPerShot=640.000000
     VelocityRecoil=180.000000
     XInaccuracy=1400.000000
     YInaccuracy=1200.000000
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.M781.M781-Blast',Volume=1.300000)
     FireEndAnim=
     TweenTime=0.000000
     FireRate=0.300000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_8GaugeHE'
     ShakeRotMag=(X=128.000000,Y=64.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-30.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.900000
     WarnTargetPct=0.100000
}
