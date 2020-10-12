//=============================================================================
// RS04Pistol.
//
// A medium power pistol with a flasht lgIJELHtn
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class RS04Pistol extends BallisticCamoHandGun;

var() name		SilencerBone;			// Bone to use for hiding silencer

var	  byte			CurrentWeaponMode2;

var Projector	FlashLightProj;
var Emitter		FlashLightEmitter;
var bool		bLightsOn;
var bool		bFirstDraw;
var vector		TorchOffset;
var() Sound		TorchOnSound;
var() Sound		TorchOffSound;
var() Sound		DrawSoundQuick;		//For first draw

var() name		FlashlightAnim;
var() sound		SilencerOnSound;		// Silencer stuck on sound
var() sound		SilencerOffSound;		//
var() sound		SilencerOnTurnSound;	// Silencer screw on sound
var() sound		SilencerOffTurnSound;	//

replication
{
	reliable if (Role < ROLE_Authority)
		ServerFlashLight, ServerSwitchSilencer;
}

simulated function bool SlaveCanUseMode(int Mode) {return Mode == 0;}
simulated function bool MasterCanSendMode(int Mode) {return Mode == 0;}



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
	RS04Attachment(ThirdPersonActor).bLightsOn = bLightsOn;
}

simulated function StartProjector()
{
	if (FlashLightProj == None)
		FlashLightProj = Spawn(class'MRS138TorchProjector',self,,location);
	AttachToBone(FlashLightProj, 'tip2');
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
		TazLoc = GetBoneCoords('tip2').Origin;
		TazRot = GetBoneRotation('tip2');
		if (FlashLightEmitter != None)
		{
			FlashLightEmitter.SetLocation(TazLoc);
			FlashLightEmitter.SetRotation(TazRot);
			Canvas.DrawActor(FlashLightEmitter, false, false, DisplayFOV);
		}
	}
}



simulated function SetBurstModeProps()
{
	if (CurrentWeaponMode == 1)
	{
		BFireMode[0].FireRate = 0.04;
		BFireMode[0].RecoilPerShot = 256;
		BFireMode[0].FireChaos = 0.05;
	}
	else if (CurrentWeaponMode == 2)
	{
		BFireMode[0].FireRate = 0.2;
		BFireMode[0].RecoilPerShot = 128;
		BFireMode[0].FireChaos = 0.1;
	}
	else
	{
		BFireMode[0].FireRate = BFireMode[0].default.FireRate;
		BFireMode[0].RecoilPerShot = BFireMode[0].default.RecoilPerShot;
		BFireMode[0].FireChaos = BFireMode[0].default.FireChaos;
		RecoilYawFactor=default.RecoilYawFactor;
		RecoilPitchFactor=default.RecoilPitchFactor;
	}
}
simulated function ServerSwitchWeaponMode (byte NewMode)
{
	super.ServerSwitchWeaponMode (NewMode);
	SetBurstModeProps();
}

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

simulated event PostNetReceive()
{
	if (level.NetMode != NM_Client)
		return;
	if (CurrentWeaponMode != CurrentWeaponMode2)
	{
		SetBurstModeProps();
		CurrentWeaponMode2 = CurrentWeaponMode;
	}
	Super.PostNetReceive();
}


simulated function TickFireCounter (float DT)
{
    if (CurrentWeaponMode == 1)
    {
        if (!IsFiring() && FireCount > 0 && FireMode[0].NextFireTime - level.TimeSeconds < -0.5)
            FireCount = 0;
    }
    else
        super.TickFireCounter(DT);
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
		if (CamoIndex == 3)
		{
//			SightOffset = vect(-11,-1.5,17);
//			SightPivot.pitch = 0;
			ViewRecoilFactor = 0.3;
		}
		else
		{
			SightOffset = default.SightOffset;
			SightPivot.pitch = default.SightPivot.pitch;
		}

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

function ServerSwitchSilencer(bool bNewValue)
{
	BFireMode[0].bAISilent = true;
     	BFireMode[0].RecoilPerShot=64.000000;
}
simulated function SwitchSilencer(bool bNewValue)
{
}
simulated function Notify_SilencerOn()
{
	PlaySound(SilencerOnSound,,0.5);
}
simulated function Notify_SilencerOnTurn()
{
	PlaySound(SilencerOnTurnSound,,0.5);
}
simulated function Notify_SilencerOff()
{
	PlaySound(SilencerOffSound,,0.5);
}
simulated function Notify_SilencerOffTurn()
{
	PlaySound(SilencerOffTurnSound,,0.5);
}
simulated function Notify_SilencerShow()
{
	SetBoneScale (0, 1.0, SilencerBone);
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


simulated function BringUp(optional Weapon PrevWeapon)
{
	if (bFirstDraw && MagAmmo > 0)
	{
		BringUpSound.Sound=DrawSoundQuick;
     		BringUpTime=1.200000;
     		SelectAnim='PulloutAlt';
		bFirstDraw=false;
	}
	else
	{
		BringUpSound.Sound=default.BringUpSound.sound;
     		BringUpTime=default.BringUpTime;
		SelectAnim='Pullout';
	}

	if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
	{
		IdleAnim = 'IdleOpen';
		ReloadAnim = 'ReloadOpen';
	}
	else
	{
		IdleAnim = 'Idle';
		ReloadAnim = 'Reload';
	}



	Super.BringUp(PrevWeapon);
	if (Instigator != None && AIController(Instigator.Controller) != None)
	{
     			CurrentWeaponMode=2;
			ServerSwitchWeaponMode(2);
	}
	if (Instigator != None && AIController(Instigator.Controller) != None && FRand() > 0.5)
		WeaponSpecial();
	else if (bLightsOn && Instigator.IsLocallyControlled())
	{
		bLightsOn=false;
		WeaponSpecial();
	}


	SetBurstModeProps();
}


function ServerSwitchCamo(int bNewValue)
{
	AdjustCamoProperties(bNewValue);
}


simulated function AdjustCamoProperties(optional int Index)
{
	local float f;

		f = FRand();
			if ((Index == -1 && f > 0.98 ) || Index == 6) //2%
			{
				SightAimFactor=0.25;
				Skins[1]=CamoMaterials[6];
				ReloadAnimRate=2;
				CockAnimRate=2;
				WeaponModes[0].bUnavailable=true;
				WeaponModes[1].bUnavailable=true;
				WeaponModes[2].bUnavailable=true;
				WeaponModes[3].bUnavailable=false;
     				RecoilXFactor		=0.01;
     				RecoilYFactor		=0.01;
     				RecoilYawFactor		=0.01;
     				RecoilPitchFactor	=1.50;
				RecoilDeclineDelay=0.08;
				RecoilDeclineTime=0.2;
				ChaosDeclineTime=0.2;
     				CurrentWeaponMode=3;
				ServerSwitchWeaponMode(3);
				CamoIndex=6;
			}
			else if ((Index == -1 && f > 0.95) || Index == 5) //3%
			{
				RecoilDeclineDelay=0.08;
				RecoilDeclineTime=0.400000;
				Skins[1]=CamoMaterials[5];
				CamoIndex=5;
			}
			else if ((Index == -1 && f > 0.92) || Index == 4) //3%
			{
				RecoilDeclineDelay=0.08;
				RecoilDeclineTime=0.400000;
				Skins[1]=CamoMaterials[4];
				CamoIndex=4;
			}
			else if ((Index == -1 && f > 0.87) || Index == 3) // 5%
			{
				SightAimFactor=0.45;
				Skins[1]=CamoMaterials[3];
				CamoIndex=3;
			}
			else if ((Index == -1 && f > 0.82) || Index == 2) //5%
			{	
				Skins[1]=CamoMaterials[2];
				CamoIndex=2;
			}
			else if ((Index == -1 && f > 0.75) || Index == 1) //7%
			{	
				Skins[1]=CamoMaterials[1];
				ServerSwitchSilencer(true);
				SwitchSilencer(true);
				CamoIndex=1;
			}
			else//75%
			{
				Skins[1]=CamoMaterials[0];
				CamoIndex=0;
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

simulated function Notify_ClipOutOfSight()
{
	SetBoneScale (1, 1.0, 'Bullet');
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
		//     SightOffset=(X=-11.000000,Y=-1.500000,Z=23.000000)
		//     SightPivot=(Pitch=1024)
		AimAdjustTime=0.550000
		AimSpread=(X=(Min=-36.000000,Max=36.000000),Y=(Min=-36.000000,Max=36.000000))
		AIRating=0.400000
		AIReloadTime=1.000000
		AttachmentClass=Class'BWBP_SKC_Fix.RS04Attachment'
		BallisticInventoryGroup=2
		BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
		bFirstDraw=True
		BigIconMaterial=Texture'BWBP_SKC_Tex.M1911.BigIcon_RS04'
		bNeedCock=False
		BobDamping=1.700000
		BringUpSound=(Sound=Sound'BWBP_SKC_Sounds.M1911.RS04-Draw')
		BringUpTime=0.800000
		bWT_Bullet=True
		CamoMaterials[0]=Shader'BWBP_SKC_Tex.M1911.RS04-MainShine'
		CamoMaterials[1]=Shader'BWBP_SKC_Tex.M1911.RS04-MainShineX1'
		CamoMaterials[2]=Texture'BWBP_SKC_Tex.M1911.RS04-UC-CamoJungle'
		CamoMaterials[3]=Shader'BWBP_SKC_Tex.M1911.RS04-MainShineX2' //2 Tone
		CamoMaterials[4]=Texture'BWBP_SKC_Tex.M1911.RS04-R-CamoAutumn'
		CamoMaterials[5]=Texture'BWBP_SKC_Tex.M1911.RS04-R-CamoHunter'
		CamoMaterials[6]=Texture'BWBP_SKC_Tex.M1911.RS04-X-CamoTiger'
		ChaosAimSpread=(X=(Min=-2048.000000,Max=2048.000000),Y=(Min=-2048.000000,Max=2048.000000))
		ChaosDeclineTime=0.500000
		ChaosSpeedThreshold=1200.000000
		ChaosTurnThreshold=1000000.000000
		ClipHitSound=(Sound=Sound'BWBP_SKC_Sounds.M1911.Rs04-SlideLock',Volume=0.400000)
		ClipInFrame=0.650000
		ClipInSound=(Sound=Sound'BWBP_SKC_Sounds.M1911.RS04-ClipIn',Volume=1.100000)
		ClipOutSound=(Sound=Sound'BallisticSounds3.SAR.SAR-StockOut',Volume=1.100000)
		CockSound=(Sound=Sound'BallisticSounds2.M806.M806-Cock',Volume=1.100000)
		CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.M806OutA',Pic2=Texture'BallisticUI2.Crosshairs.M50InA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=175,G=178,R=176,A=160),Color2=(G=0),StartSize1=52,StartSize2=40)
		CrosshairInfo=(SpreadRatios=(Y1=0.800000,Y2=1.000000),MaxScale=6.000000)
		CurrentWeaponMode=0
		CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
		Description="RS04 .45 Compact||Manufacturer: Drake & Co Firearms|Primary: .45 Fire|Secondary: Flashlight||A brand new precision handgun designed by Drake & Co firearms, the Redstrom .45 is to be the military version of the current 10mm RS8. Dubbed the RS04, this unique and accurate pistol is still in its prototype stages. The .45 HV rounds used in the RS04 prototype allow for much improved stopping power at the expense of clip capacity and recoil. Current features include a tactical flashlight and a quick loading double shot firemode. Currently undergoing combat testing by private military contractors, the 8-round Redstrom is seen frequently in the battlefields of corporate warfare. The RS04 .45 Compact model is the latest variant."
		DrawScale=0.350000
		DrawSoundQuick=Sound'BWBP_SKC_Sounds.M1911.RS04-QuickDraw'
		FireModeClass(0)=Class'BWBP_SKC_Fix.RS04PrimaryFire'
		FireModeClass(1)=Class'BWBP_SKC_Fix.RS04SecondaryFire'
		FlashLightAnim="FlashLightToggle"
		GroupOffset=3
		IconCoords=(X2=127,Y2=31)
		IconMaterial=Texture'BWBP_SKC_Tex.M1911.SmallIcon_RS04'
		InventoryGroup=2
		ItemName="RS04 .45 Compact"
		JumpChaos=0.250000
		JumpOffSet=(Pitch=1000,Yaw=-500)
		LightBrightness=130.000000
		LightEffect=LE_NonIncidence
		LightHue=30
		LightRadius=3.000000
		LightSaturation=150
		LightType=LT_Pulse
		MagAmmo=8
		Mesh=SkeletalMesh'BWBP_SKC_Anim.RS04_FP'
		PickupClass=Class'BWBP_SKC_Fix.RS04Pickup'
		PlayerSpeedFactor=1.000000
		PlayerViewOffset=(X=0.000000,Y=9.000000,Z=-14.000000)
		Priority=155
		PutDownSound=(Sound=Sound'BallisticSounds2.XK2.XK2-Putaway')
		PutDownTime=0.6
		RecoilDeclineDelay=0.100000
		RecoilDeclineTime=0.600000
		RecoilXFactor=0.350000
		RecoilYawFactor=0.100000
		RecoilYFactor=0.350000
		SelectForce="SwitchToAssaultRifle"
		SightAimFactor=0.700000
		SightDisplayFOV=40.000000
		SightingTime=0.200000
		SightOffset=(X=-11.000000,Y=-1.500000,Z=17.000000)
		Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
		Skins(1)=Shader'BWBP_SKC_Tex.M1911.RS04-MainShine'
		SpecialInfo(0)=(Info="60.0;6.0;1.0;110.0;0.2;0.0;0.0")
		TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
		TorchOffset=(X=-75.000000,Y=0.000000,Z=0.000000)
		TorchOffSound=Sound'BWAddPack-RS-Sounds.MRS38.RSS-FlashClick'
		TorchOnSound=Sound'BWAddPack-RS-Sounds.MRS38.RSS-FlashClick'
		ViewAimFactor=0.050000
		WeaponModes(0)=(ModeName="Semi-Automatic")
		WeaponModes(1)=(ModeName="Small Burst",Value=2.000000)
		WeaponModes(2)=(bUnavailable=True)
		WeaponModes(3)=(ModeName="Automatic",bUnavailable=True,ModeID="WM_FullAuto")
}
