//=============================================================================
// GRSXXPistol.
//
// Golden Glock
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class GRSXXPistol extends BallisticHandGun;

var   bool			bLaserOn;
var   LaserActor	Laser;
var   Emitter		LaserBlast;
var   Emitter		LaserDot;
var	  byte			CurrentWeaponMode2;
var	  Actor			GlowFX;// SightFX;
var() float			LaserAmmo;
var   bool			bBigLaser;

replication
{
	reliable if (Role == ROLE_Authority)
		bLaserOn, LaserAmmo;
}

//simulated function bool MasterCanSendMode(int Mode) {return Mode == 0;}
simulated function bool SlaveCanUseMode(int Mode)
{
	return Mode == 0 || GRSXXPistol(OtherGun) != None;
}
simulated function bool CanAlternate(int Mode)
{
	if (Mode != 0 && OtherGun != None && GRSXXPistol(Othergun) != None)
		return false;
	return super.CanAlternate(Mode);
}

simulated function SetBurstModeProps()
{
	if (CurrentWeaponMode == 1)
	{
		BFireMode[0].FireRate = 0.05;
		BFireMode[0].FireChaos = 0.04;
		BFireMode[0].RecoilPerShot = 64;
		RecoilDeclineTime = 0.5;
	}
	else if (CurrentWeaponMode == 2)
	{
		BFireMode[0].FireRate = 0.1;
		BFireMode[0].FireChaos = 0.05;
		BFireMode[0].RecoilPerShot = 96;
		RecoilDeclineTime = 0.5;
	}
	else
	{
		BFireMode[0].FireRate = BFireMode[0].default.FireRate;
		BFireMode[0].RecoilPerShot = BFireMode[0].default.RecoilPerShot;
		BFireMode[0].FireChaos = BFireMode[0].default.FireChaos;
		RecoilDeclineTime = default.RecoilDeclineTime;
	}
}
simulated function ServerSwitchWeaponMode (byte NewMode)
{
	super.ServerSwitchWeaponMode (NewMode);
	SetBurstModeProps();
}
// Add recoil effect
simulated function AddRecoil (float Amount, optional byte Mode)
{
	if (Mode == 0 && CurrentWeaponMode == 1 && (FireCount > 2 || MagAmmo - BFireMode[Mode].ConsumedLoad < 1))
		Amount = 1024;
	super.AddRecoil(Amount, Mode);
}
simulated event StopFire(int Mode)
{
	super.StopFire(Mode);
	if (CurrentWeaponMode == 1 && FireCount > 0 && FireCount < 3 && MagAmmo - BFireMode[Mode].ConsumedLoad > 0)
	 AddRecoil(2048, Mode);
}

simulated event WeaponTick(float DT)
{
	super.WeaponTick(DT);
	if (GlowFX != None)
	{
		GRSXXAmbientFX(GlowFX).SetReadyIndicator (FireMode[1]!=None && !FireMode[1].IsFiring() && level.TimeSeconds - GRSXXSecondaryFire(FireMode[1]).StopFireTime >= 0.8 && LaserAmmo > 0);
		if (FireMode[1]!=None && FireMode[1].IsFiring())
		{
			GRSXXAmbientFX(GlowFX).SetRedIndicator (2);
			GRSXXAmbientFX(GlowFX).SetFireGlow(true);
		}
		else if (FireMode[1]!=None && LaserAmmo < default.LaserAmmo)
		{
			GRSXXAmbientFX(GlowFX).SetRedIndicator (1);
			GRSXXAmbientFX(GlowFX).SetFireGlow(false);
		}
		else
		{
			GRSXXAmbientFX(GlowFX).SetRedIndicator (0);
			GRSXXAmbientFX(GlowFX).SetFireGlow(false);
		}
	}

}
simulated event Tick (float DT)
{
	super.Tick(DT);
	if (LaserAmmo < default.LaserAmmo && ( FireMode[1]==None || !FireMode[1].IsFiring() ))
		LaserAmmo = FMin(default.LaserAmmo, LaserAmmo + (DT / 12) * (1 + LaserAmmo/default.LaserAmmo) );
}

simulated function PlayIdle()
{
	super.PlayIdle();

	if (!bLaserOn || bPendingSightUp || SightingState != SS_None || bScopeView || !CanPlayAnim(IdleAnim, ,"IDLE"))
		return;
	FreezeAnimAt(0.0);
}

simulated event PostNetReceive()
{
	if (level.NetMode != NM_Client)
		return;
	if (CurrentWeaponMode != CurrentWeaponMode2)
	{
		SetBurstModeProps();
		CurrentWeaponMode2 = CurrentWeaponMode;
	}
	if (bLaserOn != default.bLaserOn)
	{
		if (bLaserOn)
			AimAdjustTime = default.AimAdjustTime * 1.5;
		else
			AimAdjustTime = default.AimAdjustTime;
		default.bLaserOn = bLaserOn;
		ClientSwitchLaser();
	}
	Super.PostNetReceive();
}

function ServerSwitchLaser(bool bNewLaserOn)
{
	if (bLaserOn == bNewLaserOn)
		return;
	bLaserOn = bNewLaserOn;
	bUseNetAim = default.bUseNetAim || bScopeView || bLaserOn;
	if (ThirdPersonActor != None)
		GRSXXAttachment(ThirdPersonActor).bLaserOn = bLaserOn;
	if (bLaserOn)
		AimAdjustTime = default.AimAdjustTime * 1.5;
	else
		AimAdjustTime = default.AimAdjustTime;
    if (Instigator.IsLocallyControlled())
		ClientSwitchLaser();
}

simulated function ClientSwitchLaser()
{
	if (!bLaserOn)
		KillLaserDot();
	PlayIdle();
	bUseNetAim = default.bUseNetAim || bScopeView || bLaserOn;
}

//Draw special weapon info on the hud
simulated function NewDrawWeaponInfo(Canvas C, float YPos)
{
	if (bLaserOn)	{
		CrosshairCfg.Color1.A /= 2;
		CrosshairCfg.Color2.A /= 2;
	}
	Super.NewDrawWeaponInfo (C, YPos);

	if (bLaserOn)	{
		CrosshairCfg.Color1.A = default.CrosshairCfg.Color1.A ;
		CrosshairCfg.Color2.A = default.CrosshairCfg.Color2.A ;
	}
}

simulated function KillLaserDot()
{
	if (LaserDot != None)
	{
		LaserDot.bHidden=false;
		LaserDot.Kill();
		LaserDot = None;
	}
}
simulated function SpawnLaserDot(vector Loc)
{
	if (LaserDot == None)
		LaserDot = Spawn(class'BWBP_SKC_Fix.IE_GRSXXLaserHit',,,Loc);
}

simulated function bool PutDown()
{
	if (Super.PutDown())
	{
		KillLaserDot();
		if (ThirdPersonActor != None)
			GRSXXAttachment(ThirdPersonActor).bLaserOn = false;
		return true;
	}
	return false;
}

simulated function Destroyed ()
{
	default.bLaserOn = false;

	if (GlowFX != None)
		GlowFX.Destroy();
	if (SightFX != None)
		SightFX.Destroy();
	if (Laser != None)
		Laser.Destroy();
	if (LaserDot != None)
		LaserDot.Destroy();
	if (Instigator.AmbientSound != none)
	{
		Instigator.AmbientSound = None;
		Instigator.SoundVolume = Instigator.default.SoundVolume;
		Instigator.SoundPitch = Instigator.default.SoundPitch;
		Instigator.SoundRadius = Instigator.default.SoundRadius;
		Instigator.bFullVolume = Instigator.default.bFullVolume;
	}
	Super.Destroyed();
}

simulated function vector ConvertFOVs (vector InVec, float InFOV, float OutFOV, float Distance)
{
	local vector ViewLoc, Outvec, Dir, X, Y, Z;
	local rotator ViewRot;

	ViewLoc = Instigator.Location + Instigator.EyePosition();
	ViewRot = Instigator.GetViewRotation();
	Dir = InVec - ViewLoc;
	GetAxes(ViewRot, X, Y, Z);

    OutVec.X = Distance / tan(OutFOV * PI / 360);
    OutVec.Y = (Dir dot Y) * (Distance / tan(InFOV * PI / 360)) / (Dir dot X);
    OutVec.Z = (Dir dot Z) * (Distance / tan(InFOV * PI / 360)) / (Dir dot X);
    OutVec = OutVec >> ViewRot;

	return OutVec + ViewLoc;
}

// Draw a laser beam and dot to show exact path of bullets before they're fired
simulated function DrawLaserSight ( Canvas Canvas )
{
	local Vector HitLocation, Start, End, HitNormal, Scale3D, Loc;
	local Rotator AimDir;
	local Actor Other;
    local bool bAimAligned;

	if ((ClientState == WS_Hidden) || (!bLaserOn))
		return;

	AimDir = BallisticFire(FireMode[0]).GetFireAim(Start);
	Loc = GetBoneCoords('tip2').Origin;

	End = Start + Normal(Vector(AimDir))*3000;
	Other = FireMode[0].Trace (HitLocation, HitNormal, End, Start, true);
	if (Other == None)
		HitLocation = End;

	// Draw dot at end of beam
	if (ReloadState == RS_None && ClientState == WS_ReadyToFire && !IsInState('DualAction') && Level.TimeSeconds - FireMode[0].NextFireTime > 0.1)
		bAimAligned = true;

	if (bAimAligned && Other != None)
		SpawnLaserDot(HitLocation);
	else
		KillLaserDot();
	if (LaserDot != None)
	{
		LaserDot.SetLocation(HitLocation);
		LaserDot.SetRotation(rotator(HitNormal));
		Canvas.DrawActor(LaserDot, false, false, Instigator.Controller.FovAngle);
	}

	// Draw beam from bone on gun to point on wall(This is tricky cause they are drawn with different FOVs)
	Laser.SetLocation(Loc);
	HitLocation = ConvertFOVs(End, Instigator.Controller.FovAngle, DisplayFOV, 400);
	if (bAimAligned)
		Laser.SetRotation(Rotator(HitLocation - Loc));
	else
	{
		AimDir = GetBoneRotation('tip2');
		Laser.SetRotation(AimDir);
	}

	if (LaserBlast != None)
	{
		LaserBlast.SetLocation(Laser.Location);
		LaserBlast.SetRotation(Laser.Rotation);
		Canvas.DrawActor(LaserBlast, false, false, DisplayFOV);
	}

	Scale3D.X = VSize(HitLocation-Loc)/128;
	if (bBigLaser)
	{
		Scale3D.Y = 7;
		Scale3D.Z = 7;
	}
	else
	{
		Scale3D.Y = 3.5;
		Scale3D.Z = 3.5;
	}
	Laser.SetDrawScale3D(Scale3D);
	Canvas.DrawActor(Laser, false, false, DisplayFOV);
}

simulated event RenderOverlays( Canvas Canvas )
{
	local Vector V;
	local Rotator R;
	local Coords C;

	super.RenderOverlays(Canvas);
	if (IsInState('Lowered'))
		return;
	DrawLaserSight(Canvas);

///	if (IsInState('Lowered'))
//		return;
	if (GlowFX != None)
	{
		C = GetBoneCoords('tip2');
		V = C.Origin;
		if ((IsSlave() && Othergun.Hand >= 0) || (!IsSlave() && Hand < 0))
			R = OrthoRotation(C.XAxis, -C.YAxis, C.ZAxis);
		else
			R = OrthoRotation(C.XAxis, C.YAxis, C.ZAxis);
		GlowFX.SetLocation(V);
		GlowFX.SetRotation(R);
		Canvas.DrawActor(GlowFX, false, false, DisplayFOV);
	}
/*	if (SightFX != None)
	{
		C = GetBoneCoords('SightBone');
		V = C.Origin;
		if ((IsSlave() && Othergun.Hand >= 0) || (!IsSlave() && Hand < 0))
			R = OrthoRotation(C.XAxis, -C.YAxis, C.ZAxis);
		else
			R = OrthoRotation(C.XAxis, C.YAxis, C.ZAxis);
		SightFX.SetLocation(V);
		SightFX.SetRotation(R);
		Canvas.DrawActor(SightFX, false, false, DisplayFOV);
	}
*/
}

simulated function PreDrawFPWeapon()
{
	super.PreDrawFPWeapon();
}

// Change some properties when using sights...
simulated function SetScopeBehavior()
{
	super.SetScopeBehavior();

	bUseNetAim = default.bUseNetAim || bScopeView || bLaserOn;
	if (bScopeView)
	{
		ViewRecoilFactor = 0.3;
		ChaosDeclineTime *= 1.5;
	}

	if (Hand < 0)
		SightOffset.Y = default.SightOffset.Y * -1;
}


simulated function PlayCocking(optional byte Type)
{
	if (Type == 2)
		PlayAnim('ReloadEndCock', CockAnimRate, 0.2);
	else
		PlayAnim(CockAnim, CockAnimRate, 0.2);
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp(PrevWeapon);

	if (Instigator != None && Laser == None && PlayerController(Instigator.Controller) != None)
		Laser = Spawn(class'BWBP_SKC_Fix.LaserActor_GRSXX');
	if (Instigator != None && LaserBlast == None && PlayerController(Instigator.Controller) != None)
	{
		LaserBlast = Spawn(class'BWBP_SKC_Fix.GRSXXLaserOnFX');
		class'DGVEmitter'.static.ScaleEmitter(LaserBlast, DrawScale);
	}
	if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
	{
		IdleAnim = 'OpenIdle';
		ReloadAnim = 'OpenReload';
	}
	else
	{
		IdleAnim = 'Idle';
		ReloadAnim = 'Reload';
	}

	SetBurstModeProps();

	if (GlowFX != None)
		GlowFX.Destroy();
	if (SightFX != None)
		SightFX.Destroy();
    if (Instigator.IsLocallyControlled() && level.DetailMode == DM_SuperHigh && class'BallisticMod'.default.EffectsDetailMode >= 2)
    {
    	GlowFX = None;
    	SightFX = None;

		GlowFX = Spawn(class'GRSXXAmbientFX');
		class'BallisticEmitter'.static.ScaleEmitter(Emitter(GlowFX), DrawScale);

		SightFX = Spawn(class'GRSXXSightLEDs');
		class'BallisticEmitter'.static.ScaleEmitter(Emitter(SightFX), DrawScale);


		if ((IsSlave() && Othergun.Hand >= 0) || (!IsSlave() && Hand < 0))
		{
			GRSXXAmbientFX(GlowFX).InvertY();
			GRSXXSightLEDs(SightFX).InvertY();
		}
	}
}

simulated event Timer()
{
	if (bBigLaser)
	{
		FireMode[1].StopFiring();
		bBigLaser=false;
		if (ThirdPersonActor != None)
			GRSXXAttachment(ThirdPersonActor).bBigLaser=false;
	}
	if (Clientstate == WS_PutDown)
	{
		class'BUtil'.static.KillEmitterEffect (GlowFX);
		class'BUtil'.static.KillEmitterEffect (SightFX);
	}
	super.Timer();
}

simulated event AnimEnd (int Channel)
{
    local name Anim;
    local float Frame, Rate;

    GetAnimParams(0, Anim, Frame, Rate);

	if (Anim == 'OpenFire' || Anim == 'Fire' || Anim == CockAnim || Anim == ReloadAnim)
	{
		if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
		{
			IdleAnim = 'OpenIdle';
			ReloadAnim = 'OpenReload';
		}
		else
		{
			IdleAnim = 'Idle';
			ReloadAnim = 'Reload';
		}
	}
	Super.AnimEnd(Channel);
}

simulated function Notify_ClipOutOfSight()
{
	SetBoneScale (1, 1.0, 'Bullet');
}

simulated function PlayReload()
{
	super.PlayReload();

	if (MagAmmo < 1)
		SetBoneScale (1, 0.0, 'Bullet');
}

function ServerWeaponSpecial(optional byte i)
{
	if (!FireMode[1].IsFiring() && level.TimeSeconds - GRSXXSecondaryFire(FireMode[1]).StopFireTime >= 0.8 && LaserAmmo >= default.LaserAmmo/1.8 && !IsInState('DualAction') && !IsInState('PendingDualAction'))
	{
		ClientWeaponSpecial(i);
		CommonWeaponSpecial(i);
	}
	else if (IsMaster() && GRSXXPistol(OtherGun)!=None)
	 	OtherGun.ServerWeaponSpecial(i);
}
simulated function ClientWeaponSpecial(optional byte i)
{
	if (level.NetMode == NM_Client)
		CommonWeaponSpecial(i);
}

simulated function CommonWeaponSpecial(optional byte i)
{
	bBigLaser=true;
	if (ThirdPersonActor != None)
		GRSXXAttachment(ThirdPersonActor).bBigLaser=true;
	BallisticInstantFire(FireMode[1]).Damage = 270;
	BallisticInstantFire(FireMode[1]).DamageHead = 410;
	BallisticInstantFire(FireMode[1]).DamageLimb = 170;
	FireMode[1].ModeDoFire();
	LaserAmmo = FMax(0, LaserAmmo - default.LaserAmmo/1.0);
	BallisticInstantFire(FireMode[1]).Damage = BallisticInstantFire(FireMode[1]).default.Damage;
	BallisticInstantFire(FireMode[1]).DamageHead = BallisticInstantFire(FireMode[1]).default.DamageHead;
	BallisticInstantFire(FireMode[1]).DamageLimb = BallisticInstantFire(FireMode[1]).default.DamageLimb;
	if (ClientState != WS_PutDown && ClientState != WS_BringUp)
		Settimer(0.15, false);
}


simulated function float ChargeBar()
{
	return FClamp(LaserAmmo/default.LaserAmmo, 0, 1);
}

// Rechargable laser unit means it always has ammo!
simulated function bool HasAmmo()
{
	return true;
}


// Targeted hurt radius moved here to avoid crashing

simulated function TargetedHurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation, optional Pawn ExcludedPawn )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if( bHurtEntry ) //not handled well...
		return;

	bHurtEntry = true;
	
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') && (ExcludedPawn == None || Victims != ExcludedPawn))
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			class'BallisticDamageType'.static.GenericHurt
			(
				Victims,
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);
		}
	}
	bHurtEntry = false;
}


// AI Interface =====
// choose between regular or alt-fire
function byte BestMode()
{
	local Bot B;
	local float Result, Dist;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	if (LaserAmmo < 0.3 || level.TimeSeconds - GRSXXSecondaryFire(FireMode[1]).StopFireTime < 0.8)
		return 0;

	Dist = VSize(B.Enemy.Location - Instigator.Location);
	if (Dist > 3000)
		return 0;
	Result = FRand()*0.2 + FMin(1.0, LaserAmmo / (default.LaserAmmo/2));
	if (Dist < 500)
		Result += 0.5;
	else if (Dist > 1500)
		Result -= 0.3;
	if (Result > 0.5)
		return 1;
	return 0;
}
function float GetAIRating()
{
	local Bot B;
	local float Result, Dist;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return Super.GetAIRating();

	Dist = VSize(B.Enemy.Location - Instigator.Location);

	Result = Super.GetAIRating();
	if (Dist > 500)
		Result += 0.2;
	if (Dist > 1500)
		Result -= (Dist-1500) / 4000;

	return Result;
}
// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return -0.3 + FRand();	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.5;	}
// End AI Stuff =====

defaultproperties
{
     LaserAmmo=1.500000
     PlayerSpeedFactor=1.000000
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=1.000000
     BigIconMaterial=Texture'BWBP_SKC_Tex.Glock_Gold.BigIcon_GoldGlock'
     BallisticInventoryGroup=2
     SightFXBone="SightBone"
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     SpecialInfo(0)=(Info="1200.0;65.0;4.0;150.0;2.0;2.0;1.0")
     BringUpSound=(Sound=Sound'BWBP_SKC_Sounds.Glock_Gold.GRSXX-Select')
     PutDownSound=(Sound=Sound'BallisticSounds2.XK2.XK2-Putaway')
     MagAmmo=45
     CockSound=(Sound=Sound'BWBP4-Sounds.Glock.Glk-Cock',Volume=0.600000)
     ReloadAnimRate=0.750000
     ClipHitSound=(Sound=Sound'BWBP4-Sounds.Glock.Glk-ClipHit',Volume=0.700000)
     ClipOutSound=(Sound=Sound'BWBP4-Sounds.Glock.Glk-ClipOut')
     ClipInSound=(Sound=Sound'BWBP4-Sounds.Glock.Glk-ClipIn')
     ClipInFrame=0.650000
     bNeedCock=True
     CurrentWeaponMode=2
//     SightPivot=(Pitch=768,Roll=-1024)
     SightOffset=(X=-15.000000,Y=0.000000,Z=6.500000)
     SightDisplayFOV=40.000000
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.M50Out',Pic2=Texture'BallisticUI2.Crosshairs.M806InA',USize2=256,VSize2=256,Color1=(B=12,G=108,R=157,A=163),Color2=(B=255),StartSize1=79,StartSize2=124)
     CrosshairInfo=(SpreadRatios=(Y1=0.800000,Y2=1.000000),MaxScale=6.000000)
     CrouchAimFactor=0.800000
     JumpOffSet=(Pitch=1000,Yaw=-500)
     JumpChaos=0.025000
     FallingChaos=0.050000
     SprintChaos=0.050000
     AimAdjustTime=0.350000
     AimSpread=(X=(Min=-32.000000,Max=32.000000),Y=(Min=-32.000000,Max=32.000000))
     ViewAimFactor=0.050000
     ViewRecoilFactor=0.200000
     AimDamageThreshold=480.000000
     ChaosDeclineTime=0.450000
     ChaosTurnThreshold=1000000.000000
     ChaosSpeedThreshold=11200.000000
     ChaosAimSpread=(X=(Min=-8192.000000,Max=8192.000000),Y=(Min=-8192.000000,Max=8192.000000))
     RecoilYawFactor=0.000000
     RecoilXFactor=0.250000
     RecoilYFactor=0.250000
     RecoilMax=8192.000000
     RecoilDeclineTime=0.350000
     RecoilDeclineDelay=0.100000
     FireModeClass(0)=Class'BWBP_SKC_Fix.GRSXXPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.GRSXXSecondaryFire'
     PutDownTime=0.600000
     BringUpTime=0.600000
     SelectForce="SwitchToAssaultRifle"
     bShowChargingBar=True
     Description="GRSXX Pistol||Manufacturer: Drake & Co Firearms|Primary: Accelerated 9mm Rounds|Secondary: Focused Beam Matrix|| The Golden GRSXX is a truly rare sight. With only thirty-two ever produced, prices range in the tens of millions. A much improved version of the GRS9, the GRSXX boasts an enhanced UTC Mk6 Power Coil and a Model 8 magnetic accelerator in the lining of the barrel. The power coil boosts the laser's power output while substantially decreasing battery drainage. At the cost of battery damage, the laser matrix generator can also fire a compact energy burst by overloading and detonating the Mk6 coils. [Barrel is made of 24-Karat gold with an underlying platinum-titanium casing.]"
     Priority=250
     InventoryGroup=2
     GroupOffset=3
     PickupClass=Class'BWBP_SKC_Fix.GRSXXPickup'
     PlayerViewOffset=(X=6.000000,Y=8.000000,Z=-9.000000)
     BobDamping=1.700000
     AttachmentClass=Class'BWBP_SKC_Fix.GRSXXAttachment'
     IconMaterial=Texture'BWBP_SKC_Tex.Glock_Gold.SmallIcon_GoldGlock'
     IconCoords=(X2=127,Y2=31)
     ItemName="GRSXX Golden Pistol"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=130.000000
     LightRadius=3.000000
     Mesh=SkeletalMesh'BWBP_SKC_Anim.GRSXX_FP'
     DrawScale=0.150000
//     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
//     Skins(1)=Shader'BWBP_SKC_Tex.Glock_Gold.Glock_GoldShine'
     bFullVolume=True
     SoundVolume=255
     SoundRadius=256.000000
}
