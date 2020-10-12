//=============================================================================
// AH104Pistol.
//
// A powerful sidearm designed for long range combat. The .600 bulelts are very
// powerful. Secondary is a laser attachment.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class AH104Pistol extends BallisticWeapon;

var   bool			bLaserOn;

var   LaserActor	Laser;
var() Sound			LaserOnSound;
var() Sound			ModeCycleSound;
var() Sound			LaserOffSound;

var   Emitter		LaserDot;

var bool		bCamoChoosen;		// Set and store camo.
var bool		bIsSuper;			// Extended Mags + Stopping Power!
var bool		bIsUltra;			// Extended Mags + Grip!


replication
{
	reliable if (Role == ROLE_Authority)
		bLaserOn;
}

simulated function BringUp(optional Weapon PrevWeapon)
{

	local float f;

	if (!bCamoChoosen)
	{
		f = FRand();
		if (f > 0.90)
		{
			bIsUltra=True;


		}
		else if (f > 0.50)
		{
			bIsSuper=True;
		}
		else
		{
			bIsSuper=False;
			bIsUltra=False;
		}
		bCamoChoosen=true;
	}


	Super.BringUp(PrevWeapon);
	if (Instigator != None && Laser == None && PlayerController(Instigator.Controller) != None)
		Laser = Spawn(class'BallisticFix.LaserActor');
	if (Instigator != None && LaserDot == None && PlayerController(Instigator.Controller) != None)
		SpawnLaserDot();
	if (Instigator != None && AIController(Instigator.Controller) != None)
		ServerSwitchLaser(FRand() > 0.5);

	if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
	{
		IdleAnim = 'Idle';
		ReloadAnim = 'Reload';
	}
	else
	{
		IdleAnim = 'Idle';
		ReloadAnim = 'Reload';
	}

	if ( ThirdPersonActor != None )
		AH104Attachment(ThirdPersonActor).bLaserOn = bLaserOn;
}

simulated function PlayCocking(optional byte Type)
{
	if (Type == 2)
		PlayAnim('ReloadEndCock', CockAnimRate, 0.2);
	else
		PlayAnim(CockAnim, CockAnimRate, 0.2);
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
	bLaserOn = bNewLaserOn;
	bUseNetAim = default.bUseNetAim || bScopeView || bLaserOn;
	if (ThirdPersonActor!=None)
		AH104Attachment(ThirdPersonActor).bLaserOn = bLaserOn;
	if (bLaserOn)
		AimAdjustTime = default.AimAdjustTime * 1.5;
	else
		AimAdjustTime = default.AimAdjustTime;
    if (Instigator.IsLocallyControlled())
		ClientSwitchLaser();
		
	AdjustControlProperties();
}

simulated function AdjustControlProperties ()
{
	AimAdjustTime		= default.AimAdjustTime;
	AimSpread 			= default.AimSpread;
	ViewAimFactor		= default.ViewAimFactor;
	ViewRecoilFactor	= default.ViewRecoilFactor;
	ChaosDeclineTime	= default.ChaosDeclineTime;
	ChaosTurnThreshold	= default.ChaosTurnThreshold;
	ChaosSpeedThreshold	= default.ChaosSpeedThreshold;
	ChaosAimSpread		= default.ChaosAimSpread;
	RecoilPitchFactor	= default.RecoilPitchFactor;
	RecoilYawFactor		= default.RecoilYawFactor;
	RecoilXFactor		= default.RecoilXFactor;
	RecoilYFactor		= default.RecoilYFactor;
//	RecoilMax			= default.RecoilMax;
	RecoilDeclineTime	= default.RecoilDeclineTime;
	RecoilDeclineDelay  = default.RecoilDeclineDelay;
	
	if (bLaserOn && bScopeView)
	{
	AimSpread.X.Min /= 4;
	AimSpread.X.Max /= 4;
	AimSpread.Y.Min /= 4;
	AimSpread.Y.Max /= 4;
	}
	else if (bLaserOn || bScopeView)
	{
	AimSpread.X.Min /= 3;
	AimSpread.X.Max /= 3;
	AimSpread.Y.Min /= 3;
	AimSpread.Y.Max /= 3;
	}

}

simulated function ClientSwitchLaser()
{
	if (bLaserOn)
	{
		SpawnLaserDot();
		PlaySound(LaserOnSound,,3.7,,32);
	}
	else
	{
		KillLaserDot();
		PlaySound(LaserOffSound,,3.7,,32);
	}
	if (!IsinState('DualAction') && !IsinState('PendingDualAction'))
		PlayIdle();
	bUseNetAim = default.bUseNetAim || bScopeView || bLaserOn;
	AdjustControlProperties();
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
		LaserDot.Kill();
		LaserDot = None;
	}
}
simulated function SpawnLaserDot(optional vector Loc)
{
	if (LaserDot == None)
		LaserDot = Spawn(class'BWBP_SKC_Fix.AH104LaserDot',,,Loc);
}

simulated function bool PutDown()
{
	if (Super.PutDown())
	{
		KillLaserDot();
		if (ThirdPersonActor != None)
			AH104Attachment(ThirdPersonActor).bLaserOn = false;
		return true;
	}
	return false;
}

simulated function Destroyed ()
{
	default.bLaserOn = false;
	if (Laser != None)
		Laser.Destroy();
	if (LaserDot != None)
		LaserDot.Destroy();
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

	if ((ClientState == WS_Hidden) || (!bLaserOn) || Instigator == None || Instigator.Controller == None || Laser==None)
		return;

	AimDir = BallisticFire(FireMode[0]).GetFireAim(Start);
	Loc = GetBoneCoords('tip2').Origin;

	End = Start + Normal(Vector(AimDir))*5000;
	Other = FireMode[0].Trace (HitLocation, HitNormal, End, Start, true);
	if (Other == None)
		HitLocation = End;

	// Draw dot at end of beam
	if (ReloadState == RS_None && ClientState == WS_ReadyToFire && !IsInState('DualAction') && Level.TimeSeconds - FireMode[0].NextFireTime > 0.2)
		SpawnLaserDot(HitLocation);
	else
		KillLaserDot();
	if (LaserDot != None)
		LaserDot.SetLocation(HitLocation);
	Canvas.DrawActor(LaserDot, false, false, Instigator.Controller.FovAngle);

	// Draw beam from bone on gun to point on wall(This is tricky cause they are drawn with different FOVs)
	Laser.SetLocation(Loc);
	HitLocation = ConvertFOVs(End, Instigator.Controller.FovAngle, DisplayFOV, 400);
	if (ReloadState == RS_None && ClientState == WS_ReadyToFire && !IsInState('DualAction') && Level.TimeSeconds - FireMode[0].NextFireTime > 0.2)
		Laser.SetRotation(Rotator(HitLocation - Loc));
	else
	{
		AimDir = GetBoneRotation('tip2');
		Laser.SetRotation(AimDir);
	}
	Scale3D.X = VSize(HitLocation-Loc)/128;
	Scale3D.Y = 1;
	Scale3D.Z = 1;
	Laser.SetDrawScale3D(Scale3D);
	Canvas.DrawActor(Laser, false, false, DisplayFOV);
}

simulated event RenderOverlays( Canvas Canvas )
{
	super.RenderOverlays(Canvas);
	if (!IsInState('Lowered'))
		DrawLaserSight(Canvas);
}

simulated event AnimEnd (int Channel)
{
    local name Anim;
    local float Frame, Rate;

    GetAnimParams(0, Anim, Frame, Rate);

	if (Anim == 'Fire' || Anim == 'Fire' || Anim == CockAnim || Anim == ReloadAnim)
	{
		if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
		{
			IdleAnim = 'Idle';
			ReloadAnim = 'Reload';
		}
		else
		{
			IdleAnim = 'Idle';
			ReloadAnim = 'Reload';
		}
	}
	Super.AnimEnd(Channel);
}

// Secondary fire doesn't count for this weapon
simulated function bool HasAmmo()
{
	//First Check the magazine
	if (!bNoMag && FireMode[0] != None && MagAmmo >= FireMode[0].AmmoPerFire)
		return true;
	//If it is a non-mag or the magazine is empty
	if (Ammo[0] != None && FireMode[0] != None && Ammo[0].AmmoAmount >= FireMode[0].AmmoPerFire)
			return true;
	return false;	//This weapon is empty
}
// Change some properties when using sights...
simulated function SetScopeBehavior()
{
	AdjustControlProperties();
	super.SetScopeBehavior();

	bUseNetAim = default.bUseNetAim || bScopeView || bLaserOn;
	if (bScopeView)
	{
		ViewRecoilFactor = 0.3;
		ChaosDeclineTime *= 1.5;
	}
}


simulated function TickAim (float DT)
{
	if (bAimDisabled)
	{
		Aim = Rot(0,0,0);
		Recoil = 0;
		return;
	}
	// Interpolate aim
	if (bReaiming)
	{	ReaimPhase += DT;
		if (ReaimPhase >= ReaimTime)
			StopAim();
		else
			Aim = class'BUtil'.static.RSmerp(ReaimPhase/ReaimTime, OldAim, NewAim);
	}
	// Fell, Reaim
	else if (Instigator.Physics == PHYS_Falling)	{
		if (bScopeView)		StopScopeView();
		Reaim(DT, , FallingChaos);	}
	// Moved, Reaim
	else if (bForceReaim || GetPlayerAim() != OldLookDir || (Instigator.Physics != PHYS_None && VSize(Instigator.Velocity) > 100))
		Reaim(DT);

	// Check if scope view can continue
	if (bScopeView)
		CheckScope();

	// Interpolate the AimOffset
	if (AimOffset != NewAimOffset)
		AimOffset = class'BUtil'.static.RSmerp(FMax(0.0,(AimOffsetTime-level.TimeSeconds)/AimAdjustTime), NewAimOffset, OldAimOffset);

	// Align the gun mesh and player view
	if (LastFireTime >= Level.TimeSeconds - (RecoilDeclineDelay))
	{
		ApplyAimRotation();
		OldLookDir = GetPlayerAim();
		return;
	}
	// Chaos decline
	if (Chaos > 0)
	{
		if (Instigator.bIsCrouched)
			Chaos -= FMin(Chaos, DT / (ChaosDeclineTime*CrouchAimFactor));
		else
			Chaos -= FMin(Chaos, DT / ChaosDeclineTime);
	}

	// Recoil Decline	
	if (Recoil > 0 && LastFireTime < Level.TimeSeconds - RecoilDeclineDelay)
		Recoil -= FMin(Recoil, RecoilMax * (DT / RecoilDeclineTime));


	// Recoil Deciline
	if (Recoil > 0)
		Recoil -= FMin(Recoil, RecoilMax * (DT / RecoilDeclineTime));
	// Set crosshair size
	if (bReaiming)
		CrosshairInfo.CurrentScale = FMin(1, Lerp(ReaimPhase/ReaimTime, OldChaos, NewChaos)*CrosshairChaosFactor*BCRepClass.default.AccuracyScale + (Recoil/RecoilMax)*BCRepClass.default.RecoilScale) * CrosshairInfo.MaxScale * CrosshairScaleFactor;
	else
		CrosshairInfo.CurrentScale = FMin(1, NewChaos*CrosshairChaosFactor*BCRepClass.default.AccuracyScale + (Recoil/RecoilMax)*BCRepClass.default.RecoilScale) * CrosshairInfo.MaxScale * CrosshairScaleFactor;

	// Align the gun mesh and player view
	ApplyAimRotation();

	// Remember the player's view rotation for this tick
	OldLookDir = GetPlayerAim();
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
function byte BestMode()	{	return 0;	}


function float GetAIRating()
{
	local Bot B;
	local float Result, Dist;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	Dist = VSize(B.Enemy.Location - Instigator.Location);

	Result = Super.GetAIRating();
	if (Dist < 500)
		Result -= 1-Dist/500;
	else if (Dist < 3000)
		Result += (Dist-1000) / 2000;
	else
		Result = (Result + 0.66) - (Dist-3000) / 2500;
	return Result;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return 0.3;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.5;	}
// End AI Stuff =====

defaultproperties
{
     LaserOnSound=Sound'BWBP_SKC_Sounds.AH104.AH104-SightOn'
     ModeCycleSound=Sound'BWBP_SKC_Sounds.AH104.AH104-ModeCycle'
     LaserOffSound=Sound'BWBP_SKC_Sounds.AH104.AH104-SightOff'
     PlayerSpeedFactor=1.000000
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=1.500000
     BigIconMaterial=Texture'BWBP_SKC_Tex.AH104.BigIcon_AH104'
     SightFXClass=Class'BallisticFix.AM67SightLEDs'
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Bullet=True
     SpecialInfo(0)=(Info="120.0;15.0;0.8;70.0;0.75;0.5;0.0")
     BringUpSound=(Sound=Sound'BallisticSounds2.M806.M806Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.M806.M806Putaway')
     MagAmmo=7
     CockSound=(Sound=Sound'BWBP_SKC_Sounds.AH104.AH104-Cock',Volume=6.100000)
     ClipHitSound=(Sound=Sound'BallisticSounds2.AM67.AM67-ClipHit')
     ClipOutSound=(Sound=Sound'BWBP_SKC_Sounds.AH104.AH104-ClipOut',Volume=3.100000)
     ClipInSound=(Sound=Sound'BWBP_SKC_Sounds.AH104.AH104-ClipIn',Volume=3.100000)
     ClipInFrame=0.650000
     bCockOnEmpty=True
     bNeedCock=True
     WeaponModes(1)=(ModeName="Laser-Auto",bUnavailable=True,Value=7.000000)
     WeaponModes(2)=(bUnavailable=True)
     CurrentWeaponMode=0
     SightPivot=(Pitch=1024,Roll=-1024)
     SightOffset=(X=-15.000000,Y=-0.700000,Z=12.300000)
     SightDisplayFOV=40.000000
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.M806OutA',Pic2=Texture'BallisticUI2.Crosshairs.R78InA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(A=192),StartSize1=61,StartSize2=62)
     CrosshairInfo=(SpreadRatios=(X1=0.750000,Y1=0.750000,X2=0.300000,Y2=0.300000))
     GunLength=4.000000
     JumpOffSet=(Pitch=1000,Yaw=-500)
     JumpChaos=0.300000
     AimAdjustTime=0.600000
     ViewAimFactor=0.300000
     ViewRecoilFactor=0.300000
     ChaosDeclineTime=0.450000
     ChaosTurnThreshold=200000.000000
     ChaosSpeedThreshold=1250.000000
     AimSpread=(X=(Min=-40.000000,Max=40.000000),Y=(Min=-20.000000,Max=30.000000))
     ChaosAimSpread=(X=(Min=-1024.000000,Max=1024.000000),Y=(Min=-1024.000000,Max=1024.000000))
     RecoilYawFactor=0.000000
     RecoilXFactor=0.450000
     RecoilYFactor=0.450000
     RecoilMax=5000.000000
     RecoilDeclineTime=1.000000
     RecoilDeclineDelay=0.400000
     FireModeClass(0)=Class'BWBP_SKC_Fix.AH104PrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.AH104SecondaryFire'
     PutDownTime=1.000000
     BringUpTime=1.300000
     SelectForce="SwitchToAssaultRifle"
     Description="AH-104 'Pounder' Handcannon||Manufacturer: Enravion Combat Solutions|Primary: HEAP Rounds|Secondary: Laser Sight||'The handcannon of the future.' Those were the words of Enravion as they publically released this modified version of the AM67. Nicknamed the 'Pounder' for its potent .600 explosive armor piercing rounds; the AH104 can legally carry the name handcannon. Its immense stopping power and anti-armor capability make this weapon a favorite of military leaders and personnel across the worlds. The full-steel AH104 is known to be absurdly heavy (12 lbs unloaded) in order to compensate for the power of its large rounds and cannot be dual wielded. It also comes equipped with a laser targeting system in place of the usual AM67 flash bulb."
     Priority=162
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=2
     GroupOffset=12
     PickupClass=Class'BWBP_SKC_Fix.AH104Pickup'
     PlayerViewOffset=(X=3.000000,Y=7.000000,Z=-7.000000)
     BobDamping=1.200000
     AttachmentClass=Class'BWBP_SKC_Fix.AH104Attachment'
     IconMaterial=Texture'BWBP_SKC_Tex.AH104.SmallIcon_AH104'
     IconCoords=(X2=127,Y2=31)
     ItemName="AH104 Assault Pistol"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=4.000000
     Mesh=SkeletalMesh'BallisticAnims2.AM67Pistol'
     DrawScale=0.200000
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Texture'BWBP_SKC_Tex.AH104.AH104-MainMk2'
}
