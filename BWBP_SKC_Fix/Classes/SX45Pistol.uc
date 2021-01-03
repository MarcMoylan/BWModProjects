//=============================================================================
// SX45Pistol.
//
// A medium power pistol with a fancy amp technology!
// Main amp element is cryo, which is a slow firing radius dmg shot that slows enemies
// Secondary amp element is rad, which stacks a DoT on tgts which damages nearby foes
// Freeze them to irradiate them!
//
// by Sarge, donated by Storm X!
// Copyright(c) 2020 Sarge
//=============================================================================
class SX45Pistol extends BallisticHandGun;


var	  byte			CurrentWeaponMode2;

var Projector	FlashLightProj;
var Emitter		FlashLightEmitter;
var bool		bLightsOn;
var() name		FlashlightAnim;

var bool		bFirstDraw;
var vector		TorchOffset;
var() Sound		TorchOnSound;
var() Sound		TorchOffSound;


var   bool		bAmped;				// ARE YOU AMPED? BECAUSE THIS GUN IS!
var() name		AmplifierBone;			// Bone to use for hiding cool shit
var() name		AmplifierOnAnim;			//
var() name		AmplifierOffAnim;		//
var() sound		AmplifierOnSound;		// 
var() sound		AmplifierOffSound;		//
var() sound		AmplifierPowerOnSound;		// Electrical noises?
var() sound		AmplifierPowerOffSound;		//
var() float		AmplifierSwitchTime;		//

var() array<Material> CamoMaterials; //We're using this for the amp

replication
{
	reliable if (Role < ROLE_Authority)
		ServerFlashLight, ServerSwitchAmplifier;
}

simulated function bool SlaveCanUseMode(int Mode) {return Mode == 0;}
simulated function bool MasterCanSendMode(int Mode) {return Mode == 0;}

//==============================================
// Amp Code
//==============================================

function ServerSwitchAmplifier(bool bNewValue)
{
	AmplifierSwitchTime = level.TimeSeconds + 2.0;
	bAmped = bNewValue;
	if (bAmped)
	{
			WeaponModes[0].bUnavailable=true;
			WeaponModes[1].bUnavailable=false;
			WeaponModes[2].bUnavailable=false;
			CurrentWeaponMode=1;
			ServerSwitchWeaponMode(1);
	}
	else
	{
			WeaponModes[0].bUnavailable=false;
			WeaponModes[1].bUnavailable=true;
			WeaponModes[2].bUnavailable=true;
			CurrentWeaponMode=2;
			ServerSwitchWeaponMode(0);
	}
}

exec simulated function CommonSwitchAmplifier(optional byte i)
{
	if (level.TimeSeconds < AmplifierSwitchTime || ReloadState != RS_None)
		return;
	TemporaryScopeDown(0.5);
	AmplifierSwitchTime = level.TimeSeconds + 2.0;
	bAmped = !bAmped;
	ServerSwitchAmplifier(bAmped);
	SwitchAmplifier(bAmped);
}
simulated function SwitchAmplifier(bool bNewValue)
{
	if (bNewValue)
		PlayAnim(AmplifierOnAnim);
	else
		PlayAnim(AmplifierOffAnim);
}
simulated function Notify_AmplifierOn()	{	PlaySound(AmplifierOnSound,,0.5);	}
simulated function Notify_AmplifierOff()	{	PlaySound(AmplifierOffSound,,0.5);	}

simulated function Notify_AmplifierShow()
{	
	SetBoneScale (0, 1.0, AmplifierBone);		
}
simulated function Notify_AmplifierHide()
{	
	SetBoneScale (0, 0.0, AmplifierBone);	
}
simulated function Notify_ClipOutOfSight()
{
	SetBoneScale (1, 1.0, 'Bullet');
}


function ServerSwitchWeaponMode (byte newMode)
{
	super.ServerSwitchWeaponMode (newMode);
	if (!Instigator.IsLocallyControlled())
		SX45PrimaryFire(FireMode[0]).SwitchWeaponMode(CurrentWeaponMode);
	ClientSwitchWeaponMode (CurrentWeaponMode);
}
simulated function ClientSwitchWeaponMode (byte newMode)
{
	SX45PrimaryFire(FireMode[0]).SwitchWeaponMode(newMode);
	if (newMode == 1)
	{
		Skins[6]=CamoMaterials[1];
		Skins[7]=CamoMaterials[3];
	}
	else if (newMode == 2)
	{
		Skins[6]=CamoMaterials[0];
		Skins[7]=CamoMaterials[2];
	}
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	super.BringUp(PrevWeapon);

	if (AIController(Instigator.Controller) != None)
	{
		bAmped = (FRand() > 0.5);
		bLightsOn == (FRand() > 0.5);
	}

	if (bAmped)
	{
		SetBoneScale (0, 1.0, AmplifierBone);
	}		
	else
	{
		SetBoneScale (0, 0.0, AmplifierBone);
	}
	
}


//======================================================

exec simulated function WeaponSpecial(optional byte i)
{
	SafePlayAnim(FlashlightAnim, 1, 0, ,"FIRE");
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

function ServerFlashLight (bool bNew)
{
	bLightsOn = bNew;
	SX45Attachment(ThirdPersonActor).bLightsOn = bLightsOn;
}

simulated function StartProjector()
{
	if (FlashLightProj == None)
		FlashLightProj = Spawn(class'MRS138TorchProjector',self,,location);
	AttachToBone(FlashLightProj, 'tip3');
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
	if (bLightsOn)
	{
		TazLoc = GetBoneCoords('tip3').Origin;
		TazRot = GetBoneRotation('tip3');
		if (FlashLightEmitter != None)
		{
			FlashLightEmitter.SetLocation(TazLoc);
			FlashLightEmitter.SetRotation(TazRot);
			Canvas.DrawActor(FlashLightEmitter, false, false, DisplayFOV);
		}
	}
}


// Is this flashlight code??
simulated function PlayerSprint (bool bSprinting)
{
	if (BCRepClass.default.bNoJumpOffset)
		return;
	if (bScopeView && Instigator.IsLocallyControlled())
		StopScopeView();
	if (bAimDisabled)
		return;
	SetNewAimOffset(CalcNewAimOffset(), AimAdjustTime);
	Reaim(0.05, AimAdjustTime, 0.05);
}
// Aim goes bad when player takes damage
function AdjustPlayerDamage( out int Damage, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	local float DF;

	DF = FMin(1, float(Damage)/480);
	Reaim(0.1, 0.3*AimAdjustTime, DF, DF*(-4000 + 8000 * FRand()), DF*(-3000 + 6000 * FRand()));
	ClientPlayerDamaged(255*DF);
	bForceReaim=true;
}
simulated function ClientPlayerDamaged(byte DamageFactor)
{
	local float DF;
	if (level.NetMode != NM_Client)
		return;
	DF = float(DamageFactor)/255;
	Reaim(0.1, 0.3*AimAdjustTime, DF, DF*(-3500 + 7000 * FRand()), DF*(-3000 + 6000 * FRand()));
	bForceReaim=true;
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
		Reaim(DT, , 0.05);	}
	// Moved, Reaim
	else if (bForceReaim || GetPlayerAim() != OldLookDir || VSize(Instigator.Velocity) > 100)
		Reaim(DT);

	if (bScopeView)
		CheckScope();

	// Interpolate the AimOffset
	if (AimOffset != NewAimOffset)
		AimOffset = class'BUtil'.static.RSmerp(FMax(0.0,(AimOffsetTime-level.TimeSeconds)/AimAdjustTime), NewAimOffset, OldAimOffset);

	// Align the gun mesh and player view
	if (LastFireTime > Level.TimeSeconds - RecoilDeclineDelay)
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
	// Recoil Deciline
	if (Recoil > 0)
		Recoil -= FMin(Recoil, RecoilMax * (DT / RecoilDeclineTime));
	// Set crosshair size
	if (bReaiming)
		CrosshairInfo.CurrentScale = FMin(1, Lerp(ReaimPhase/ReaimTime, OldChaos, NewChaos)*CrosshairChaosFactor + (Recoil/RecoilMax)) * CrosshairInfo.MaxScale * CrosshairScaleFactor;
	else
		CrosshairInfo.CurrentScale = FMin(1, NewChaos*CrosshairChaosFactor + (Recoil/RecoilMax)) * CrosshairInfo.MaxScale * CrosshairScaleFactor;

	// Align the gun mesh and player view
	ApplyAimRotation();

	// Remember the player's view rotation for this tick
	OldLookDir = GetPlayerAim();
}

simulated function PlayIdle()
{
	super.PlayIdle();

	if (bPendingSightUp || SightingState != SS_None || bScopeView || !CanPlayAnim(IdleAnim, ,"IDLE"))
		return;
	FreezeAnimAt(0.0);
}




simulated function bool PutDown()
{
	if (Super.PutDown())
	{
		KillProjector();
		if (FlashLightEmitter != None)
			FlashLightEmitter.Destroy();
		return true;
	}
	return false;
}

simulated function Destroyed ()
{
	if (FlashLightEmitter != None)
		FlashLightEmitter.Destroy();
	KillProjector();
	super.Destroyed();
}




// Change some properties when using sights...
simulated function SetScopeBehavior()
{
	super.SetScopeBehavior();

	bUseNetAim = default.bUseNetAim || bScopeView;
	if (bScopeView)
	{
		ViewRecoilFactor = 0.2;
		ChaosDeclineTime *= 0.9;
		SightOffset = default.SightOffset;
		SightPivot.pitch = default.SightPivot.pitch;
	}
	else
		SightOffset = default.SightOffset;
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

simulated function SetDualMode (bool bDualMode)
{
	if (bDualMode)
	{
		if (Instigator.IsLocallyControlled() && SightingState == SS_Active)
			StopScopeView();
		SetBoneScale(8, 0.0, SupportHandBone);
		if (AIController(Instigator.Controller) == None)
			bUseSpecialAim = true;
		if (bAimDisabled)
			return;
//		AimAdjustTime		*= 1.0;
		AimSpread			*= 1.4;
		ViewAimFactor		*= 0.6;
		ViewRecoilFactor	*= 0.25;
		ChaosDeclineTime	*= 1.2;
		ChaosTurnThreshold	*= 0.8;
		ChaosSpeedThreshold	*= 0.8;
		ChaosAimSpread		*= 1.2;
		RecoilPitchFactor	*= 1.2;
		RecoilYawFactor		*= 1.2;
		RecoilXFactor		*= 1.2;
		RecoilYFactor		*= 1.2;
//		RecoilMax			*= 1.0;
		RecoilDeclineTime	*= 1.2;
     	SelectAnim = 'Pullout';
		
	}
	else
	{
		SetBoneScale(8, 1.0, SupportHandBone);
		bUseSpecialAim = false;
		if (bAimDisabled)
			return;
//		AimAdjustTime		= default.AimAdjustTime;
		AimSpread 			= default.AimSpread;
		ViewAimFactor		= default.ViewAimFactor;
		ViewRecoilFactor	= default.ViewRecoilFactor;
		ChaosDeclineTime	= default.ChaosDeclineTime;
		ChaosTurnThreshold	= default.ChaosTurnThreshold;
		ChaosSpeedThreshold	= default.ChaosSpeedThreshold;
		ChaosAimSpread		= default.ChaosAimSpread;
		ChaosAimSpread 		*= BCRepClass.default.AccuracyScale;
		RecoilPitchFactor	= default.RecoilPitchFactor;
		RecoilYawFactor		= default.RecoilYawFactor;
		RecoilXFactor		= default.RecoilXFactor;
		RecoilYFactor		= default.RecoilYFactor;
//		RecoilMax			= default.RecoilMax;
		RecoilDeclineTime	= default.RecoilDeclineTime;
	}
}



simulated event AnimEnd (int Channel)
{
    local name Anim;
    local float Frame, Rate;

    GetAnimParams(0, Anim, Frame, Rate);

	if (Anim == 'FireOpen' || Anim == 'Pullout' || Anim == 'PulloutAlt' || Anim == 'Fire' || Anim == 'FireDualOpen' || Anim == 'FireDual' ||Anim == CockAnim || Anim == ReloadAnim)
	{
		if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
		{
			IdleAnim = 'IdleOpen';
			PutDownAnim = 'PutawayOpen';
			ReloadAnim = 'ReloadOpen';
			FlashlightAnim = 'FlashLightToggleOpen';
		}
		else
		{
			IdleAnim = 'Idle';
			PutDownAnim = 'Putaway';
			ReloadAnim = 'Reload';
			FlashlightAnim = 'FlashLightToggle';
		}
	}
	Super.AnimEnd(Channel);
}

simulated function PlayReload()
{
	super.PlayReload();

	if (MagAmmo < 2)
		SetBoneScale (1, 0.0, 'Bullet');
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

// AI Interface =====
// choose between regular or alt-fire
function byte BestMode()
{
CurrentWeaponMode=2;
	return 0;
}
function float GetAIRating()
{
	local Bot B;
	local float Result, Dist;
	local vector Dir;

	if (IsSlave())
		return 0;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return Super.GetAIRating();

	Dir = B.Enemy.Location - Instigator.Location;
	Dist = VSize(Dir);

	Result = Super.GetAIRating();
	if (Dist > 500)
		Result += 0.2;
	else if (B.Enemy.Weapon != None && B.Enemy.Weapon.bMeleeWeapon)
		Result -= 0.05 * B.Skill;
	if (Dist > 1000)
		Result -= (Dist-1000) / 4000;

	return Result;
}
// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return 0.1;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.5;	}
// End AI Stuff =====

static function class<Pickup> RecommendAmmoPickup(int Mode)
{
	return class'AP_M806Clip';
}

defaultproperties
{
     CamoMaterials[0]=Shader'BWBP_SKC_TexExp.Amp.Amp-FinalYellow'
     CamoMaterials[1]=Shader'BWBP_SKC_TexExp.Amp.Amp-FinalCyan'
     CamoMaterials[2]=Shader'BWBP_SKC_TexExp.Amp.Amp-GlowYellowShader'
     CamoMaterials[3]=Shader'BWBP_SKC_TexExp.Amp.Amp-GlowCyanShader'
     AmplifierBone="Amp"
     AmplifierOnAnim="AMPAdd"
     AmplifierOffAnim="AMPRemove"
     AmplifierOnSound=Sound'BWBP3-Sounds.SRS900.SRS-SilencerOn'
     AmplifierOffSound=Sound'BWBP3-Sounds.SRS900.SRS-SilencerOff'
     AmplifierPowerOnSound=Sound'BWBP4-Sounds.VPR.VPR-ClipIn'
     AmplifierPowerOffSound=Sound'BWBP4-Sounds.VPR.VPR-ClipOut'
	 
		AimAdjustTime=0.550000
		AimSpread=(X=(Min=-48.000000,Max=48.000000),Y=(Min=-48.000000,Max=48.000000))
		AIRating=0.400000
		AIReloadTime=1.000000
		AttachmentClass=Class'BWBP_SKC_Fix.SX45Attachment'
		BallisticInventoryGroup=2
		BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
		bFirstDraw=True
		BigIconMaterial=Texture'BWBP_SKC_Tex.M1911.BigIcon_RS04'
		bNeedCock=False
		BobDamping=1.700000
		BringUpSound=(Sound=Sound'BWBP_SKC_Sounds.M1911.RS04-Draw')
		BringUpTime=0.800000
		bWT_Bullet=True
		ChaosAimSpread=(X=(Min=-2048.000000,Max=2048.000000),Y=(Min=-2048.000000,Max=2048.000000))
		ChaosDeclineTime=0.500000
		ChaosSpeedThreshold=1200.000000
		ChaosTurnThreshold=1000000.000000
		ClipHitSound=(Sound=Sound'BWBP_SKC_SoundsExp.SX45.SX45-SlideRelease',Volume=0.400000)
		ClipInFrame=0.650000
		ClipInSound=(Sound=Sound'BWBP_SKC_SoundsExp.SX45.SX45-MagIn',Volume=1.100000)
		ClipOutSound=(Sound=Sound'BWBP_SKC_SoundsExp.SX45.SX45-MagOut',Volume=1.100000)
		CockSound=(Sound=Sound'BWBP_SKC_SoundsExp.SX45.SX45-Cock',Volume=1.100000)
		CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.M806OutA',Pic2=Texture'BallisticUI2.Crosshairs.M50InA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=175,G=178,R=176,A=160),Color2=(G=0),StartSize1=52,StartSize2=40)
		CrosshairInfo=(SpreadRatios=(Y1=0.800000,Y2=1.000000),MaxScale=6.000000)
		CurrentWeaponMode=0
		CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
		Description="SX-45K Tech Pistol||Manufacturer: Drake & Co Firearms|Primary: .45 Fire|Secondary: Flashlight||A brand new precision handgun designed by Drake & Co firearms, the Redstrom .45 is to be the military version of the current 10mm RS8. Dubbed the RS04, this unique and accurate pistol is still in its prototype stages. The .45 HV rounds used in the RS04 prototype allow for much improved stopping power at the expense of clip capacity and recoil. Current features include a tactical flashlight and a quick loading double shot firemode. Currently undergoing combat testing by private military contractors, the 8-round Redstrom is seen frequently in the battlefields of corporate warfare. The RS04 .45 Compact model is the latest variant."
		DrawScale=0.350000
		FireModeClass(0)=Class'BWBP_SKC_Fix.SX45PrimaryFire'
		FireModeClass(1)=Class'BWBP_SKC_Fix.SX45SecondaryFire'
		FlashLightAnim="FlashLightToggle"
		GroupOffset=3
		IconCoords=(X2=127,Y2=31)
		IconMaterial=Texture'BWBP_SKC_Tex.M1911.SmallIcon_RS04'
		InventoryGroup=2
		ItemName="SX-45K Tech Pistol"
		JumpChaos=0.250000
		JumpOffSet=(Pitch=1000,Yaw=-500)
		LightBrightness=130.000000
		LightEffect=LE_NonIncidence
		LightHue=30
		LightRadius=3.000000
		LightSaturation=150
		LightType=LT_Pulse
		MagAmmo=15
		Mesh=SkeletalMesh'BWBP_SKC_AnimExp.SX45_FP'
		PickupClass=Class'BWBP_SKC_Fix.SX45Pickup'
		PlayerSpeedFactor=1.000000
		PlayerViewOffset=(X=0.000000,Y=9.000000,Z=-14.000000)
		Priority=155
		PutDownSound=(Sound=Sound'BallisticSounds2.XK2.XK2-Putaway')
		PutDownTime=0.6
		RecoilDeclineDelay=0.100000
		RecoilDeclineTime=0.500000
		RecoilXFactor=0.350000
		RecoilYawFactor=0.100000
		RecoilYFactor=0.350000
		SelectForce="SwitchToAssaultRifle"
		SightAimFactor=0.200000
		SightDisplayFOV=40.000000
		SightingTime=0.200000
		SightOffset=(X=-11.000000,Y=-3.650000,Z=16.800000)
		SpecialInfo(0)=(Info="60.0;6.0;1.0;110.0;0.2;0.0;0.0")
		TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
		TorchOffset=(X=-75.000000,Y=0.000000,Z=0.000000)
		TorchOffSound=Sound'BWAddPack-RS-Sounds.MRS38.RSS-FlashClick'
		TorchOnSound=Sound'BWAddPack-RS-Sounds.MRS38.RSS-FlashClick'
		ViewAimFactor=0.050000
		ViewRecoilFactor=0.200000
     WeaponModes(0)=(ModeName="Semi-Auto")
     WeaponModes(1)=(ModeName="Amplified: Cryogenic",ModeID="WM_SemiAuto",Value=1.000000,bUnavailable=True)
     WeaponModes(2)=(ModeName="Amplified: Radiation",ModeID="WM_SemiAuto",Value=1.000000,bUnavailable=True)
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Texture'BWBP_SKC_TexExp.SX45.SX45-Mag'
     Skins(2)=Shader'BWBP_SKC_TexExp.SX45.SX45-SightReticle_S'
     Skins(3)=Texture'BWBP_SKC_TexExp.SX45.SX45-Sight'
     Skins(4)=Texture'BWBP_SKC_TexExp.SX45.SX45-Main'
     Skins(5)=Texture'BWBP_SKC_TexExp.SX45.SX45-Laser'
     Skins(6)=Shader'BWBP_SKC_TexExp.Amp.Amp-FinalCyan'
	 Skins(7)=Shader'BWBP_SKC_TexExp.Amp.Amp-GlowCyanShader'
}
