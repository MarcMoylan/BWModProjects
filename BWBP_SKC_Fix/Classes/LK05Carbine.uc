//=============================================================================
// LK05Carbine
//
// An accurate and controllable carbine that is absolutely tricked out.
// Has a holosight, laser, silencer, and flashlight!
//
// Uses sledgehammer rounds that slow down enemies. Comes with low ammo and low
// reserve ammo.
//
// Has less range and power than long barreled rifles.
// Has better accuracy and control than fellow long barrel rifles.
//
// by Sarge.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class LK05Carbine extends BallisticCamoWeapon;

var   byte		GearStatus;

var   bool		bLaserOn;
var   LaserActor	Laser;
var() Sound		LaserOnSound;
var() Sound		LaserOffSound;
var   Emitter		LaserDot;

var   bool		bSilenced;				// Silencer on. Silenced
var() name		SilencerBone;			// Bone to use for hiding silencer
var() name		SilencerBone2;			// Bone to use for hiding silencer
var() sound		SilencerOnSound;		// Silencer stuck on sound
var() sound		SilencerOffSound;		//
var() name		SilencerOnAnim;			// Think hard about this one...
var() name		SilencerOffAnim;		//
var() float		SilencerSwitchTime;		//

var Projector		FlashLightProj;
var Emitter		FlashLightEmitter;
var bool		bLightsOn;
var bool		bFirstDraw;
var vector		TorchOffset;
var() Sound		TorchOnSound;
var() Sound		TorchOffSound;

var() name		ScopeBone;			// Bone to use for hiding scope


replication
{
	reliable if (Role < ROLE_Authority)
		ServerFlashLight, ServerSwitchSilencer;
	reliable if (Role == ROLE_Authority)
		bLaserOn;
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
	}
	Super.PostNetReceive();
}

//=================================
// "Camouflage"
//=================================


simulated function AdjustCamoProperties(optional int Index)
{
	local float f;

		f = FRand();
		if ( (Index == -1 && f > 0.80) || Index == 1) //No holosight
		{
			CamoIndex=1;
			SetBoneScale (2, 0.0, ScopeBone);
			SightOffset = vect(12,-8.55,24.2);
			SightPivot.Pitch = 64;
		}
		else
		{
			CamoIndex=0;
			SetBoneScale (2, 1.0, ScopeBone);
			SightOffset = default.SightOffset;
			SightPivot.Pitch = default.SightPivot.Pitch;
		}
}

//=================================
//Silencer Code
//=================================

function ServerSwitchSilencer(bool bNewValue)
{
	if (!Instigator.IsLocallyControlled())
		LK05PrimaryFire(FireMode[0]).SwitchSilencerMode(bNewValue);

	LK05Attachment(ThirdPersonActor).bSilenced=bNewValue;	
	SilencerSwitchTime = level.TimeSeconds + 1.5;
	bSilenced = bNewValue;
	BFireMode[0].bAISilent = bSilenced;
}


exec simulated function SwitchSilencer(optional byte i) //Was previously weapon special
{
	if (level.TimeSeconds < SilencerSwitchTime || ReloadState != RS_None)
		return;
	if (Clientstate != WS_ReadyToFire)
		return;
	SilencerSwitchTime = level.TimeSeconds + 1.5;
	bSilenced = !bSilenced;
	ServerSwitchSilencer(bSilenced);
	LK05PrimaryFire(FireMode[0]).SwitchSilencerMode(bSilenced);
	LK05Attachment(ThirdPersonActor).IAOverride(bSilenced);
	if (bSilenced)
		PlayAnim(SilencerOnAnim);
	else
		PlayAnim(SilencerOffAnim);

}
simulated function Notify_SilencerOn()
{
	PlaySound(SilencerOnSound,,0.5);
}
simulated function Notify_SilencerOff()
{
	PlaySound(SilencerOffSound,,0.5);
	SetBoneScale (0, 0.0, SilencerBone);
	SetBoneScale (1, 1.0, SilencerBone2);
}
simulated function Notify_SilencerShow()
{
	SetBoneScale (0, 1.0, SilencerBone);
	SetBoneScale (1, 0.0, SilencerBone2);
}

simulated function PlayReload()
{
//	if (MagAmmo < 1)
//		SetBoneScale (1, 0.0, 'Bullet');

	super.PlayReload();

	if (bSilenced)
		SetBoneScale (0, 1.0, SilencerBone);
	else
		SetBoneScale (0, 0.0, SilencerBone);
}



//=================================
// Flashlight + Laser Code
//=================================


exec simulated function WeaponSpecial(optional byte i)
{
	GearStatus++;
	if (GearStatus > 4)
		GearStatus = 1;

	if (GearStatus % 2 == 1) //Flashlight
	{
		bLightsOn = !bLightsOn;
		ServerFlashLight(bLightsOn);
		if (bLightsOn)
		{
			PlaySound(TorchOnSound,,0.7,,32);
			if (FlashLightEmitter == None)
				FlashLightEmitter = Spawn(class'MRS138TorchEffect',self,,location);
			class'BallisticEmitter'.static.ScaleEmitter(FlashLightEmitter, DrawScale);
			StartProjector();
		}
		else
		{
			PlaySound(TorchOffSound,,0.7,,32);
			if (FlashLightEmitter != None)
				FlashLightEmitter.Destroy();
			KillProjector();
		}
	}
	else if (GearStatus > 1) //Laser
	{
		bLaserOn = !bLaserOn;
		ServerSwitchLaser(bLaserOn);
		if (bLaserOn)
		{
			SpawnLaserDot();
			PlaySound(LaserOnSound,,0.7,,32);
		}
		else
		{
			KillLaserDot();
			PlaySound(LaserOffSound,,0.7,,32);
		}

		PlayIdle();
		bUseNetAim = default.bUseNetAim || bScopeView || bLaserOn;
	}


//	ServerSwitchGear(GearStatus);
//	SwitchGear(GearStatus);

}


//=================================
// Flashlight
//=================================


function ServerFlashLight (bool bNew)
{
	bLightsOn = bNew;
	LK05Attachment(ThirdPersonActor).bLightsOn = bLightsOn;
}

simulated function StartProjector()
{
	if (FlashLightProj == None)
		FlashLightProj = Spawn(class'MRS138TorchProjector',self,,location);
	AttachToBone(FlashLightProj, 'tip4');
	FlashLightProj.SetRelativeLocation(TorchOffset);
}
simulated function KillProjector()
{
	if (FlashLightProj != None)
		FlashLightProj.Destroy();
}

simulated event Tick(float DT)
{
	super.Tick(DT);

	if (!bLightsOn || ClientState != WS_ReadyToFire)
		return;
	if (!Instigator.IsFirstPerson())
		KillProjector();
	else if (FlashLightProj == None)
		StartProjector();
}


simulated event RenderOverlays( Canvas Canvas )
{
	local Vector TazLoc;
	local Rotator TazRot;
	super.RenderOverlays(Canvas);
	if (!IsInState('Lowered'))
		DrawLaserSight(Canvas);
	if (bLightsOn)
	{
		TazLoc = GetBoneCoords('tip4').Origin;
		TazRot = GetBoneRotation('tip4');
		if (FlashLightEmitter != None)
		{
			FlashLightEmitter.SetLocation(TazLoc);
			FlashLightEmitter.SetRotation(TazRot);
			Canvas.DrawActor(FlashLightEmitter, false, false, DisplayFOV);
		}
	}
}


//=================================
// Laser
//=================================


function ServerSwitchLaser(bool bNewLaserOn)
{
	bLaserOn = bNewLaserOn;
	bUseNetAim = default.bUseNetAim || bScopeView || bLaserOn;
	if (ThirdPersonActor!=None)
		LK05Attachment(ThirdPersonActor).bLaserOn = bLaserOn;
	if (bLaserOn)
		AimAdjustTime = default.AimAdjustTime * 1.5;
	else
		AimAdjustTime = default.AimAdjustTime;
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
		LaserDot = Spawn(class'BallisticFix.MD24LaserDot',,,Loc);
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
	Loc = GetBoneCoords('tip3').Origin;

	End = Start + Normal(Vector(AimDir))*5000;
	Other = FireMode[0].Trace (HitLocation, HitNormal, End, Start, true);
	if (Other == None)
		HitLocation = End;

	// Draw dot at end of beam
	if (ReloadState == RS_None && ClientState == WS_ReadyToFire && Level.TimeSeconds - FireMode[0].NextFireTime > 0.2 && level.TimeSeconds - SilencerSwitchTime > 0.2)
		SpawnLaserDot(HitLocation);
	else
		KillLaserDot();
	if (LaserDot != None)
		LaserDot.SetLocation(HitLocation);
	Canvas.DrawActor(LaserDot, false, false, Instigator.Controller.FovAngle);

	// Draw beam from bone on gun to point on wall(This is tricky cause they are drawn with different FOVs)
	Laser.SetLocation(Loc);
	HitLocation = class'BUtil'.static.ConvertFOVs(Instigator.Location + Instigator.EyePosition(), Instigator.GetViewRotation(), End, Instigator.Controller.FovAngle, DisplayFOV, 400);

	if (ReloadState == RS_None && ClientState == WS_ReadyToFire && level.TimeSeconds - SilencerSwitchTime > 0.2 &&
	   ((FireMode[0].IsFiring() && Level.TimeSeconds - FireMode[0].NextFireTime > -0.05) || (!FireMode[0].IsFiring() && Level.TimeSeconds - FireMode[0].NextFireTime > 0.2)))
		Laser.SetRotation(Rotator(HitLocation - Loc));
	else
	{
		AimDir = GetBoneRotation('tip3');
		Laser.SetRotation(AimDir);
	}
	Scale3D.X = VSize(HitLocation-Loc)/128;
	Scale3D.Y = 1;
	Scale3D.Z = 1;
	Laser.SetDrawScale3D(Scale3D);
	Canvas.DrawActor(Laser, false, false, DisplayFOV);
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

//=================================
// Destroy Cleanup
//=================================


simulated function bool PutDown()
{
	if (Super.PutDown())
	{
		KillLaserDot();
		if (ThirdPersonActor != None)
			LK05Attachment(ThirdPersonActor).bLaserOn = false;
		KillProjector();
		if (FlashLightEmitter != None)
			FlashLightEmitter.Destroy();

		Instigator.AmbientSound = UsedAmbientSound;
		Instigator.SoundVolume = default.SoundVolume;
		Instigator.SoundPitch = default.SoundPitch;
		Instigator.SoundRadius = default.SoundRadius;
		Instigator.bFullVolume = false;
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
	if (FlashLightEmitter != None)
		FlashLightEmitter.Destroy();
	KillProjector();

	Instigator.AmbientSound = UsedAmbientSound;
	Instigator.SoundVolume = default.SoundVolume;
	Instigator.SoundPitch = default.SoundPitch;
	Instigator.SoundRadius = default.SoundRadius;
	Instigator.bFullVolume = false;

	Super.Destroyed();
}


//=================================
// Sights and custom anim support
//=================================



simulated function BringUp(optional Weapon PrevWeapon)
{
	if (bFirstDraw && MagAmmo > 0)
	{
     		BringUpTime=1.100000;
     		SelectAnim='PulloutFancy';
		bFirstDraw=false;
	}
	else
	{
     		BringUpTime=default.BringUpTime;
		SelectAnim='Pullout';
	}

	if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
	{
		IdleAnim = 'IdleOpen';
		ReloadAnim = 'ReloadEmpty';
	}
	else
	{
		IdleAnim = 'Idle';
		ReloadAnim = 'Reload';
	}


	Super.BringUp(PrevWeapon);
	if (Instigator != None && Laser == None && PlayerController(Instigator.Controller) != None)
		Laser = Spawn(class'BallisticFix.LaserActor');
	if (Instigator != None && LaserDot == None && PlayerController(Instigator.Controller) != None)
		SpawnLaserDot();
	if (Instigator != None && AIController(Instigator.Controller) != None)
	{
		ServerSwitchLaser(FRand() > 0.5);
		ServerFlashlight(FRand() > 0.5);
	}


	if (AIController(Instigator.Controller) != None)
		bSilenced = (FRand() > 0.5);

	if (bSilenced)
		SetBoneScale (0, 1.0, SilencerBone);
	else
		SetBoneScale (0, 0.0, SilencerBone);

	if ( ThirdPersonActor != None )
		LK05Attachment(ThirdPersonActor).bLaserOn = bLaserOn;


	Instigator.AmbientSound = UsedAmbientSound;
	Instigator.SoundVolume = default.SoundVolume;
	Instigator.SoundPitch = default.SoundPitch;
	Instigator.SoundRadius = default.SoundRadius;
	Instigator.bFullVolume = true;

}

simulated event AnimEnd (int Channel)
{
    local name Anim;
    local float Frame, Rate;

    GetAnimParams(0, Anim, Frame, Rate);

	if (Anim == 'OpenFire' || Anim == 'Pullout' || Anim == 'PulloutFancy' || Anim == 'Fire' || Anim == 'SightFire' || Anim == 'OpenSightFire' ||Anim == CockAnim || Anim == ReloadAnim)
	{
		if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
		{
			IdleAnim = 'OpenIdle';
			ReloadAnim = 'ReloadEmpty';
		}
		else
		{
			IdleAnim = 'Idle';
			ReloadAnim = 'Reload';
		}
	}
	Super.AnimEnd(Channel);
}



// Change some properties when using sights...
simulated function SetScopeBehavior()
{
	super.SetScopeBehavior();
	bUseNetAim = default.bUseNetAim || bScopeView || bLaserOn;
	if (bScopeView)
	{
		SightAimFactor = 0.4;
	}
	else
	{
		SightAimFactor = default.ViewRecoilFactor;
	}
}



// HARDCODED SIGHTING TIME
simulated function TickSighting (float DT)
{
	if (SightingState == SS_None || SightingState == SS_Active)
		return;

	if (SightingState == SS_Raising)
	{	// Raising gun to sight position
		if (SightingPhase < 1.0)
		{
			if ((bScopeHeld || bPendingSightUp) && CanUseSights())
				SightingPhase += DT/0.20;
			else
			{
				SightingState = SS_Lowering;

				Instigator.Controller.bRun = 0;
			}
		}
		else
		{	// Got all the way up. Now go to scope/sight view
			SightingPhase = 1.0;
			SightingState = SS_Active;
			ScopeUpAnimEnd();
		}
	}
	else if (SightingState == SS_Lowering)
	{	// Lowering gun from sight pos
		if (SightingPhase > 0.0)
		{
			if (bScopeHeld && CanUseSights())
				SightingState = SS_Raising;
			else
				SightingPhase -= DT/0.20;
		}
		else
		{	// Got all the way down. Tell the system our anim has ended...
			SightingPhase = 0.0;
			SightingState = SS_None;
			ScopeDownAnimEnd();
			DisplayFOv = default.DisplayFOV;
		}
	}
}


//=================================
// Bot crap
//=================================


simulated function float RateSelf()
{
	if (!HasAmmo())
		CurrentRating = 0;
	else if (Ammo[0].AmmoAmount < 1 && MagAmmo < 1)
		CurrentRating = Instigator.Controller.RateWeapon(self)*0.3;
	else
		return Super.RateSelf();
	return CurrentRating;
}
// AI Interface =====
// choose between regular or alt-fire
function byte BestMode()
{
	local Bot B;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	if (B.Skill > Rand(6))
	{
		if (Chaos < 0.1 || Chaos < 0.5 && VSize(B.Enemy.Location - Instigator.Location) > 500)
			return 1;
	}
	else if (FRand() > 0.75)
		return 1;
	return 0;
}

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
function float SuggestAttackStyle()	{	return 0.0;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.5;	}
// End AI Stuff =====



defaultproperties
{
     TorchOffset=(X=-50.000000,Y=0.000000,Z=0.000000)
     TorchOnSound=Sound'BWAddPack-RS-Sounds.MRS38.RSS-FlashClick'
     TorchOffSound=Sound'BWAddPack-RS-Sounds.MRS38.RSS-FlashClick'

     LaserOnSound=Sound'BallisticSounds2.M806.M806LSight'
     LaserOffSound=Sound'BallisticSounds2.M806.M806LSight'

     SilencerBone="Silencer"
     SilencerBone2="Silencer2"
     SilencerOnAnim="SilencerOn"
     SilencerOffAnim="SilencerOff"
     SilencerOnSound=Sound'BWBP3-Sounds.SRS900.SRS-SilencerOn'
     SilencerOffSound=Sound'BWBP3-Sounds.SRS900.SRS-SilencerOff'

     ScopeBone="EOTech"

     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=1.000000
     BigIconMaterial=Texture'BWBP_SKC_TexExp.LK05.BigIcon_LK05'
     BallisticInventoryGroup=5
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Bullet=True
     SpecialInfo(0)=(Info="240.0;25.0;0.9;80.0;0.7;0.7;0.4")
     BringUpSound=(Sound=Sound'BWBP_SKC_SoundsExp.MJ51.MJ51-PullOut',Volume=1.600000)
     PutDownSound=(Sound=Sound'BWBP_SKC_SoundsExp.MJ51.MJ51-Putaway',Volume=1.600000)
     MagAmmo=25
     CockSound=(Sound=Sound'BWBP_SKC_SoundsExp.LK05.LK05-Cock',Volume=1.200000)
     ClipInSound=(Sound=Sound'BWBP_SKC_SoundsExp.LK05.LK05-MagIn',Volume=1.400000)
     ClipOutSound=(Sound=Sound'BWBP_SKC_SoundsExp.LK05.LK05-MagOut',Volume=1.400000)
     ClipInFrame=0.650000
     bNeedCock=False
     bFirstDraw=True
     bNoCrosshairInScope=True
     bCockOnEmpty=False
     WeaponModes(1)=(ModeName="Burst")
     WeaponModes(3)=(bUnavailable=True)
     SightOffset=(X=10.000000,Y=-8.550000,Z=24.660000)
     SightDisplayFOV=40.000000
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.M50Out',Pic2=Texture'BallisticUI2.Crosshairs.M50In',Color1=(A=158),StartSize1=75,StartSize2=72)
     CrouchAimFactor=0.450000
     ChaosAimSpread=(X=(Min=-2250.000000,Max=2250.000000),Y=(Min=-2250.000000,Max=2250.000000))
     ViewAimFactor=0.200000
     ViewRecoilFactor=0.600000
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.300000),(InVal=0.800000,OutVal=-0.400000),(InVal=1.000000,OutVal=-0.200000)))
     RecoilYCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.650000),(InVal=0.600000,OutVal=0.800000),(InVal=0.800000,OutVal=0.900000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYawFactor=0.800000
     RecoilPitchFactor=1.000000
     RecoilXFactor=0.200000
     RecoilYFactor=0.200000
     RecoilDeclineDelay=0.150000
     RecoilDeclineTime=1.7
     ChaosDeclineTime=1.0
     SightingTime=0.200000
     FireModeClass(0)=Class'BWBP_SKC_Fix.LK05PrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.LK05SecondaryFire'
     PutDownTime=0.700000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.600000
     IdleAnimRate=0.500000
     CurrentRating=0.600000
     Description="LK-05 Advanced Carbine||Manufacturer: XWI Elite Systems|Primary: Accurate Rifle Fire|Secondary: Attach Suprressor|Special: Toggle Flashlight/Laser||The LK-05 Carbine is an extremely high-quality assault weapon manufactured exclusively for select PMCs and paramilitary groups. It is very rarely seen on the battlefield as no Terran-recongized militaries publicly use it, and XWI does not admit to manufacturing firearms or weapons of any kind. Despite this, a large amount of casualities on both the Terran and Skrith sides are attributed to the LK-05. It notably uses specialized, custom-tooled 5.56mm ammunition that is both match-grade and disintigrating, much to the chagrin of crime scene investigators. Investigations into XWI's ties to various PMC groups and high-profile assassinations are on-going, but unlikely to succeed."
     Priority=41
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=9
     PickupClass=Class'BWBP_SKC_Fix.LK05Pickup'
     PlayerViewOffset=(X=-6.000000,Y=12.000000,Z=-17.000000)
     BobDamping=2.000000
     AttachmentClass=Class'BWBP_SKC_Fix.LK05Attachment'
     IconMaterial=Texture'BWBP_SKC_TexExp.LK05.SmallIcon_LK05'
     IconCoords=(X2=127,Y2=31)
     ItemName="LK-05 Advanced Carbine"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=4.000000
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.LK05_FP'
     DrawScale=0.300000
}
