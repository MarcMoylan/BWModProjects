//=============================================================================
// HMCBeamCannon.
//
// An extremely damn complicated beam cannon.
// Filled with useless code that is not necessarily commented out.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class HMCBeamCannon extends BallisticWeapon;

var float NextAmmoTickTime;
var() Material          MatRed;       	// Red skin.
var bool Overheat;
var bool		bCamoChoosen;		// Set and store camo.
var	  byte			    CurrentWeaponMode2;
var   bool			bLaserOn;
var   bool			bRedTeam;		//Owned by red team?
var   bool			bIsCharging;
var   bool			bCamoActive;		//Does our pickup already arf
var   LaserActor	Laser;
var   Emitter		LaserDot;
var Actor	Glow1;				// Blue charge effect
var Actor	Glow2;				// Red charge effect
var   bool			bBigLaser;
var() Sound		OverHeatSound;		// Sound to play when it overheats
var bool bTeamSet;

var()     float Heat;
var()     float CoolRate;
var       bool bRunOffsetting;
var()     rotator RunOffset;

replication
{
	reliable if (Role == ROLE_Authority)
		ClientOverCharge, ClientSetHeat, bLaserOn, bRedTeam;
}

simulated function PlayIdle()
{
	if (bPendingSightUp)
		ScopeBackUp();
	else if (SightingState != SS_None)
	{
		if (SafePlayAnim(IdleAnim, 1.0))
			FreezeAnimAt(0.0);
	}
	else if (bScopeView)
	{
		if(SafePlayAnim(ZoomOutAnim, 1.0))
			FreezeAnimAt(0.0);
	}
	else
	    SafeLoopAnim(IdleAnim, IdleAnimRate, IdleTweenTime, ,"IDLE");
}

function GiveTo(Pawn Other, optional Pickup Pickup)
{
    local int m;
    local weapon w;
    local bool bPossiblySwitch, bJustSpawned;

    Instigator = Other;
    W = Weapon(Other.FindInventoryType(class));
    if ( W == None )
    {
		bJustSpawned = true;
        Super(Inventory).GiveTo(Other);
        bPossiblySwitch = true;
        W = self;
		if (Pickup != None && BallisticWeaponPickup(Pickup) != None)
			MagAmmo = BallisticWeaponPickup(Pickup).MagAmmo;
    }
    else if ( !W.HasAmmo() )
	    bPossiblySwitch = true;

    if ( Pickup == None )
        bPossiblySwitch = true;

    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
        if ( FireMode[m] != None )
        {
            FireMode[m].Instigator = Instigator;
            GiveAmmo(m,WeaponPickup(Pickup),bJustSpawned);
        }
    }
if (Level.NetMode == NM_Standalone && HMCPickup(Pickup) != None)
{
	if (HMCPickup(Pickup).bRedTeam)
		bRedTeam=true;

	if (HMCPickup(Pickup).bCamoChoosen && !bCamoChoosen)
		bCamoActive=true;
}
	if ( (Instigator.Weapon != None) && Instigator.Weapon.IsFiring() )
		bPossiblySwitch = false;

	if ( Instigator.Weapon != W )
		W.ClientWeaponSet(bPossiblySwitch);

    if ( !bJustSpawned )
	{
        for (m = 0; m < NUM_FIRE_MODES; m++)
			Ammo[m] = None;
		Destroy();
	}
}

simulated function ClientOverCharge()
{
	if (Firemode[1].bIsFiring)
		StopFire(1);
}

simulated function HMCTargetedHurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation, Optional actor Victim )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Victims.Role == ROLE_Authority) && UnrealPawn(Victim)==None && (!Victims.IsA('FluidSurfaceInfo')) && Victims != Victim)
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


simulated function ClientSetHeat(float NewHeat)
{
	Heat = NewHeat;
}

simulated event PostNetReceive()
{
	if (level.NetMode != NM_Client)
		return;
/*	if (CurrentWeaponMode != CurrentWeaponMode2)
	{
		AdjustWeaponProperties();
		CurrentWeaponMode2 = CurrentWeaponMode;
	}*/
    if (bLaserOn != default.bLaserOn)
	{
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
		HMCAttachment(ThirdPersonActor).bLaserOn = bLaserOn;
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
	{
		if (bRedTeam)
			LaserDot = Spawn(class'BallisticFix.IE_GRS9LaserHit',,,Loc);
		else
          		LaserDot = Spawn(class'BWBP_SKC_Fix.IE_HMCLase',,,Loc);
	}
}

simulated function bool PutDown()
{
	if (Super.PutDown())
	{
		KillLaserDot();
		if (Glow1 != None)	Glow1.Destroy();
		if (Glow2 != None)	Glow2.Destroy();
		if (ThirdPersonActor != None)
			HMCAttachment(ThirdPersonActor).bLaserOn = false;
		return true;
	}

		Instigator.AmbientSound = None;
		Instigator.SoundVolume = Instigator.default.SoundVolume;
		Instigator.SoundPitch = Instigator.default.SoundPitch;
		Instigator.SoundRadius = Instigator.default.SoundRadius;
		Instigator.bFullVolume = Instigator.default.bFullVolume;

	return false;
}

simulated function Destroyed ()
{
	default.bLaserOn = false;

	if (Laser != None)
		Laser.Destroy();
	if (LaserDot != None)
		LaserDot.Destroy();

	if (Glow1 != None)	Glow1.Destroy();
	if (Glow2 != None)	Glow2.Destroy();
	if (Instigator.AmbientSound == UsedAmbientSound)
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

simulated function DrawLaserSight ( Canvas Canvas )
{
	local Vector HitLocation, Start, End, HitNormal, Scale3D, Loc;
	local Rotator AimDir;
	local Actor Other;
    local bool bAimAligned;

	if ((ClientState == WS_Hidden) || (!bLaserOn))
		return;

	AimDir = BallisticFire(FireMode[0]).GetFireAim(Start);
	Loc = GetBoneCoords('muzzle').Origin;

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
		LaserDot.Emitters[0].AutomaticInitialSpawning = Other.bWorldGeometry;
		LaserDot.Emitters[3].AutomaticInitialSpawning = Other.bWorldGeometry;
		Canvas.DrawActor(LaserDot, false, false, Instigator.Controller.FovAngle);
	}

	// Draw beam from bone on gun to point on wall(This is tricky cause they are drawn with different FOVs)
	Laser.SetLocation(Loc);
	HitLocation = ConvertFOVs(End, Instigator.Controller.FovAngle, DisplayFOV, 400);
	if (bAimAligned)
		Laser.SetRotation(Rotator(HitLocation - Loc));
	else
	{
		AimDir = GetBoneRotation('muzzle');
		Laser.SetRotation(AimDir);
	}

	Scale3D.X = VSize(HitLocation-Loc)/128;
	if (bBigLaser)
	{
		Scale3D.Y = 16;
		Scale3D.Z = 16;
	}
	else
	{
		Scale3D.Y = 8;
		Scale3D.Z = 8;
	}
	Laser.SetDrawScale3D(Scale3D);
	Canvas.DrawActor(Laser, false, false, DisplayFOV);
}

simulated event RenderOverlays( Canvas Canvas )
{
	super.RenderOverlays(Canvas);
	if (IsInState('Lowered'))
		return;
	DrawLaserSight(Canvas);
}
/*
simulated function PreDrawFPWeapon()
{
	local float f;
	if (!bCamoChoosen && level.Netmode == NM_DedicatedServer)
	{
		f = FRand();
		if (f > 0.50 && Instigator.PlayerReplicationInfo.Team == None)
		{
			bRedTeam=True;
		}
	}
	bCamoChoosen=true;
	super.PreDrawFPWeapon();
}
*/
simulated function BringUp(optional Weapon PrevWeapon)
{
	local float g;

	if ( !bTeamSet && (Instigator.PlayerReplicationInfo != None) && (Instigator.PlayerReplicationInfo.Team != None) )
	{
		bTeamSet = true;
		if ( Instigator.PlayerReplicationInfo.Team.TeamIndex == 0 )
		{
			Skins[1] = Shader'BWBP_SKC_Tex.BeamCannon.RedCannonSD';
			bRedTeam=true;
		}
	}

	if (bRedTeam)
		{
			Skins[1] = Shader'BWBP_SKC_Tex.BeamCannon.RedCannonSD';
			if (ThirdPersonActor != None)
				HMCAttachment(ThirdPersonActor).bRedTeam=true;	
	}


	if (ThirdPersonActor != None && bRedTeam)
		HMCAttachment(ThirdPersonActor).bRedTeam=true;	

	if (!bCamoChoosen && level.Netmode == NM_Standalone)
	{
		g = FRand();
		if ((bRedTeam) && Instigator.PlayerReplicationInfo.Team == None)
		{
			bRedTeam=True;
			bCamoActive=true;
			Skins[1] = Shader'BWBP_SKC_Tex.BeamCannon.RedCannonSD';
			Skins[1]=MatRed;
			if (ThirdPersonActor != None)
				HMCAttachment(ThirdPersonActor).bRedTeam=true;
		}
		if ((!bCamoActive && g > 0.90) && Instigator.PlayerReplicationInfo.Team == None)
		{
			bRedTeam=True;
			bCamoActive=true;
			Skins[1] = Shader'BWBP_SKC_Tex.BeamCannon.RedCannonSD';
			Skins[1]=MatRed;
			if (ThirdPersonActor != None)
				HMCAttachment(ThirdPersonActor).bRedTeam=true;	
			//WeaponModes[3].bUnavailable=false;
			//CurrentWeaponMode=3;	
			if (!bTeamSet)
			{
			BallisticInstantFire(FireMode[0]).Damage = 275;
			BallisticInstantFire(FireMode[0]).DamageHead = 325;
			BallisticInstantFire(FireMode[0]).DamageLimb = 200;
			BallisticInstantFire(FireMode[1]).Damage = 20;
			BallisticInstantFire(FireMode[1]).DamageHead = 30;
			BallisticInstantFire(FireMode[1]).DamageLimb = 13;
			}
		}
		bCamoChoosen=true;
	}
	Super.BringUp(PrevWeapon);

	if (Instigator != None && Laser == None && PlayerController(Instigator.Controller) != None)
	{
		if ( (Instigator.PlayerReplicationInfo.Team != None) && (Instigator.PlayerReplicationInfo.Team.TeamIndex == 0) )
			Laser = Spawn(class'BWBP_SKC_Fix.LaserActor_HMCRed');
		else if (bRedTeam)
			Laser = Spawn(class'BWBP_SKC_Fix.LaserActor_HMCRed');
		else
			Laser = Spawn(class'BWBP_SKC_Fix.LaserActor_HMC');
	}


	if (Instigator != None && AIController(Instigator.Controller) != None)
	{
		WeaponModes[0].bUnavailable=false;
		ServerSwitchWeaponMode(0);
		CurrentWeaponMode=0;	
	}

	Instigator.AmbientSound = UsedAmbientSound;
	Instigator.SoundVolume = default.SoundVolume;
	Instigator.SoundPitch = default.SoundPitch;
	Instigator.SoundRadius = default.SoundRadius;
	Instigator.bFullVolume = false;
}

simulated event Tick (float DT)
{

	super.Tick(DT);
	if (FireMode[1].bIsFiring)
		CoolRate = 0;
	else 
		CoolRate = 0.5;
	if (FireMode[0].bIsFiring || HMCPrimaryFire(Firemode[0]).RailPower > 0)
		bIsCharging = true;
	else
		bIsCharging = false;
    	Heat = FMax(0, Heat - CoolRate*DT);

   	if (level.Netmode == NM_DedicatedServer)
		Heat = 0;

	
//	if (bRedTeam)
//		BallisticInstantFire(FireMode[1]).MuzzleFlashClass=Class'BWBP_SKC_Fix.HMCRedEmitter';
}



simulated event WeaponTick(float DT)
{
	super.WeaponTick(DT);

//	if (CurrentWeaponMode == 0)
//			HMCAttachment(ThirdPersonActor).bSmallCharge=True;
	if (Firemode[0].bIsFiring)
	{
		if (bRedTeam)
			class'bUtil'.static.InitMuzzleFlash(Glow1, class'HMCBarrelGlowRed', DrawScale, self, 'tip');
		else
			class'bUtil'.static.InitMuzzleFlash(Glow1, class'HMCBarrelGlow', DrawScale, self, 'tip');
	}
	else
	{
		if (Glow1 != None)	Glow1.Destroy();
		if (Glow2 != None)	Glow2.Destroy();
	}
/*	if (AmmoAmount(0) < 10)
	{
		HMCPrimaryFire(Firemode[0]).RailPower = 0;
		Heat = 0;
		Instigator.AmbientSound = None;
	}*/
}

simulated function AddHeat(float Amount)
{
	Heat += Amount;
	if (Heat > 1.0 && Heat < 1.2)
	{
		Heat = 1.4;
		PlaySound(OverHeatSound,,6.7,,64);
	}
}




simulated function bool MayNeedReload(byte Mode, float Load)
{
	return false;
}

function ServerStartReload (optional byte i);


simulated function TickFireCounter (float DT)
{
	/*if (CurrentWeaponMode == 0)
	{
		if (!IsFiring() && FireCount > 0 && FireMode[0].NextFireTime - level.TimeSeconds < -0.5)
			FireCount = 0;
	}
	else*/
		super.TickFireCounter(DT);
}


simulated function ServerSwitchWeaponMode (byte NewMode)
{
    if (Firemode[0].bIsFiring || Heat > 0)
        return;

    super.ServerSwitchWeaponMode(NewMode);
//    AdjustWeaponProperties();
	if (!Instigator.IsLocallyControlled())
		HMCPrimaryFire(FireMode[0]).SwitchHMCMode(CurrentWeaponMode);
	ClientSwitchHMCMode (CurrentWeaponMode);
}

simulated function ClientSwitchHMCMode (byte newMode)
{
	HMCPrimaryFire(FireMode[0]).SwitchHMCMode(newMode);
}
/*
simulated function AdjustWeaponProperties()
{
    HMCPrimaryFire(BFiremode[0]).PowerLevel = WeaponModes[CurrentWeaponMode].value;
}*/



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

	Dist = VSize(B.Enemy.Location - Instigator.Location);
	if (Dist > 1500)
		return 0;
	Result = 0.2 + FMin(0.65, MagAmmo / (default.MagAmmo));
	if (Dist < 500)
		Result += 0.5;
	else if (Dist > 1000)
		Result -= 0.3;
	if (Result > 0.5)
		return 1;
	return 0;

}

function float GetAIRating()
{
	local Bot B;
	local float Result, Dist;
	local vector Dir;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return Super.GetAIRating();

	Dir = B.Enemy.Location - Instigator.Location;
	Dist = VSize(Dir);

	Result = Super.GetAIRating();
	if (Dist > 700)
	{
		if (FRand() > 0.6 && Frand() < 0.7)
		{
			if (CurrentWeaponMode != 0)
			{
				CurrentWeaponMode = 0;
			}
		}
		Result += 0.3;
	}
	else if (B.Enemy.Weapon != None && B.Enemy.Weapon.bMeleeWeapon)
		Result -= 0.05 * B.Skill;
	if (Dist > 2000)
		Result -= (Dist-2000) / 4000;

	return Result;
}
// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return 0.1;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.5;	}
// End AI Stuff =====

simulated function float ChargeBar()
{
    return FMin((Heat + HMCPrimaryFire(Firemode[0]).RailPower), 1);
}

defaultproperties
{
     OverHeatSound=Sound'BWBP2-Sounds.LightningGun.LG-Overheat'
     CoolRate=0.500000
     MatRed=Shader'BWBP_SKC_Tex.BeamCannon.RedCannonSD'
     RunOffset=(Pitch=-3000,Yaw=-4000)
     PlayerSpeedFactor=0.880000
     PlayerJumpFactor=0.850000
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     BigIconMaterial=Texture'BWBP_SKC_Tex.BeamCannon.BigIcon_HMC'
     BallisticInventoryGroup=9
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     InventorySize=50
     bWT_Energy=True
     bWT_Super=True
     SpecialInfo(0)=(Info="300.0;20.0;1.80;80.0;0.8;0.8;0.1")
     BringUpSound=(Sound=Sound'BWBP_SKC_Sounds.BeamCannon.Beam-Up')
     PutDownSound=(Sound=Sound'BWBP_SKC_Sounds.BeamCannon.Beam-Down')
     MagAmmo=250
     bNoMag=True
     bNonCocking=True
     WeaponModes(0)=(ModeName="25% Power",bUnavailable=True,ModeID="WM_FullAuto",Value=0.250000)
     WeaponModes(1)=(ModeName="Full Power",ModeID="WM_FullAuto",Value=1.000000)
     WeaponModes(2)=(ModeName="Low Power BOT",bUnavailable=True,Value=0.100000)
     WeaponModes(3)=(ModeName="Overcharged",bUnavailable=True,ModeID="WM_FullAuto",Value=1.000000)
     CurrentWeaponMode=1
     SightPivot=(Pitch=748)
     SightOffset=(X=-12.000000,Z=14.300000)
     SightDisplayFOV=40.000000
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.Misc8',Pic2=Texture'BallisticUI2.Crosshairs.M50OutA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=255,G=255,A=94),Color2=(B=255,G=89,R=77),StartSize1=77,StartSize2=17)
     CrosshairInfo=(SpreadRatios=(X1=0.250000,Y1=0.375000,X2=1.000000,Y2=1.000000),MaxScale=3.000000)
     CrosshairChaosFactor=0.700000
     CrouchAimFactor=0.300000
     SprintOffSet=(Pitch=-1024,Yaw=-2048)
     JumpChaos=0.350000
     ViewAimFactor=0.650000
     ViewRecoilFactor=0.950000
     AimDamageThreshold=150.000000
     ChaosDeclineTime=2.500000
     ChaosSpeedThreshold=800.000000
     ChaosAimSpread=(Y=(Min=-1276.000000,Max=1276.000000))
     RecoilXCurve=(Points=(,(InVal=0.100000,OutVal=0.010000),(InVal=0.200000,OutVal=0.250000),(InVal=0.300000,OutVal=-0.300000),(InVal=0.600000,OutVal=-0.250000),(InVal=0.700000,OutVal=0.250000),(InVal=1.000000,OutVal=-0.300000)))
     RecoilYCurve=(Points=(,(InVal=0.100000,OutVal=0.180000),(InVal=0.200000,OutVal=-0.200000),(InVal=0.300000,OutVal=0.300000),(InVal=0.600000,OutVal=-0.150000),(InVal=0.700000,OutVal=0.300000),(InVal=1.000000,OutVal=0.600000)))
     RecoilPitchFactor=0.800000
     RecoilYawFactor=0.800000
     RecoilXFactor=0.700000
     RecoilYFactor=0.900000
     RecoilDeclineTime=3.000000
     FireModeClass(0)=Class'BWBP_SKC_Fix.HMCPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.HMCSecondaryFire'
     BringUpTime=0.500000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.550000
     CurrentRating=0.550000
     bShowChargingBar=True
     Description="HMC-117 Volatile Photon Cannon||Manufacturer: Nexron Defence|Primary: Charged Photon Blast|Secondary: Sweeping Plasma Beam|Special: None|The HMC-117 Volatile Photon Cannon, often nicknamed 'The Sentinel', was created originally as a tool for testing heat shielding on space craft. It was often used by shuttle crews for zero-G EVA repairs during rough space trips. Due to a couple horrifying accidents and its tendency to melt through bulkheads, the HMC was scrapped in favor of other testing and repair methods. Deemed an overall failure, somehow a variant of this bulky device managed to find its way onto the field and proved to be quite effective at taking out Cryon units. The power and reliability of its industrial grade photon generator was praised by many troopers and not even the strongest of Cryons could withstand a fully charged photon blast. While the original HMC power cells are long gone, Nexron modified HMCs can successfully run on HVPC power cells."
     Priority=72
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=5
     GroupOffset=5
     PickupClass=Class'BWBP_SKC_Fix.HMCPickup'
     PlayerViewOffset=(X=6.000000,Y=6.000000,Z=-8.000000)
     BobDamping=1.600000
     AttachmentClass=Class'BWBP_SKC_Fix.HMCAttachment'
     IconMaterial=Texture'BWBP_SKC_Tex.BeamCannon.SmallIcon_HMC'
     IconCoords=(X2=127,Y2=31)
     ItemName="HMC-117 Photon Cannon"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=64
     LightSaturation=96
     LightBrightness=192.000000
     LightRadius=12.000000
     Mesh=SkeletalMesh'BallisticAnims2.RX22AFlamer'
     DrawScale=0.350000
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Shader'BWBP_SKC_Tex.BeamCannon.BeamCannonSkin_SD'
     Skins(2)=FinalBlend'BWBP_SKC_Tex.BeamCannon.BeamCannonShieldFB'
     bFullVolume=True
     SoundRadius=512.000000
}
