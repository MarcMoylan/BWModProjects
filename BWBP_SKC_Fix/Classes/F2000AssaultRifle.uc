//=============================================================================
// MARSAssaultRifle.
//
// The MARS-3 Assault Carbine. Fires extremely fast with decent accuracy and power.
// Bad chaos means scope use is essential. An attached laser improves control
// while on the move.
//
// Falls in between SAR and M50.
//
// Makes use of Camo System V3.
//
// by Marc "Sergeant Kelly" Moylan.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class F2000AssaultRifle extends BallisticCamoWeapon;

var bool		bFirstDraw;

var   bool		bSilenced;				// Silencer on. Silenced
var() name		SilencerBone;			// Bone to use for hiding silencer
var() name		SilencerOnAnim;			// Think hard about this one...
var() name		SilencerOffAnim;		//
var() sound		SilencerOnSound;		// Silencer stuck on sound
var() sound		SilencerOffSound;		//
var() sound		SilencerOnTurnSound;	// Silencer screw on sound
var() sound		SilencerOffTurnSound;	//
var() float		SilencerSwitchTime;		//

var() Sound		GrenOpenSound;		//Sounds for grenade reloading
var() Sound		GrenLoadSound;		//
var() Sound		GrenCloseSound;		//
var() name		GrenadeLoadAnim;	//Anim for grenade reload

var(F2000AssaultRifle) name		ScopeBone;			// Bone to use for hiding scope
var(F2000AssaultRifle) name		GrenBone;			// Bone to use for hiding grenade slug

replication
{
	reliable if (Role == ROLE_Authority)
		ClientGrenadePickedUp;
	reliable if (Role < ROLE_Authority)
		ServerSwitchSilencer;
}

//=====================================================================
// GRENADE CODE
//=====================================================================


// Notifys for greande loading sounds
simulated function Notify_F2000GrenOpen()	
{
	PlaySound(GrenOpenSound, SLOT_Misc, 0.5, ,64);	
	SetBoneScale (3, 0.0, GrenBone);
}
simulated function Notify_F2000GrenLoad()		
{	
	PlaySound(GrenLoadSound, SLOT_Misc, 0.5, ,64);	
	F2000SecondaryFire(FireMode[1]).bLoaded = true;	
	SetBoneScale (3, 1.0, GrenBone);
}
simulated function Notify_F2000GrenClose()	
{	
	PlaySound(GrenCloseSound, SLOT_Misc, 0.5, ,64);	
	ReloadState = RS_None; 
}

simulated function Notify_F2000GrenDrop()
{
	local vector start;
	ReloadState = RS_PreClipIn;

	if (level.NetMode != NM_DedicatedServer)
	{
		Start = Instigator.Location + Instigator.EyePosition() + class'BUtil'.static.AlignedOffset(Instigator.GetViewRotation(), vect(5,10,-5));
		Spawn(class'Brass_Shockwave', self,, Start, Instigator.GetViewRotation() + rot(8192,0,0));

	}

}

// A grenade has just been picked up. Loads one in if we're empty
function GrenadePickedUp ()
{/*
	if (Ammo[1].AmmoAmount < Ammo[1].MaxAmmo)
	{
		if (Instigator.Weapon == self)
			LoadGrenade();
		else
			F2000SecondaryFire(FireMode[1]).bLoaded=true;
	}
	if (!Instigator.IsLocallyControlled())
		ClientGrenadePickedUp();*/
}

simulated function ClientGrenadePickedUp()
{
/*
	if (Ammo[1].AmmoAmount < Ammo[1].MaxAmmo)
	{
		if (ClientState == WS_ReadyToFire)
			LoadGrenade();
		else
			F2000SecondaryFire(FireMode[1]).bLoaded=true;
	}
*/
}

simulated function bool IsGrenadeLoaded()
{
	return F2000SecondaryFire(FireMode[1]).bLoaded;
}

// Tell our ammo that this is the F2000 it must notify about grenade pickups
function GiveAmmo(int m, WeaponPickup WP, bool bJustSpawned)
{
	Super.GiveAmmo(m, WP, bJustSpawned);
	if (Ammo[1] != None && Ammo_F2000Grenades(Ammo[1]) != None)
		Ammo_F2000Grenades(Ammo[1]).DaF2K = self;
}

//======================================
// GRENADE RELOAD CODE
//======================================


simulated event AnimEnd (int Channel)
{
    local name anim;
    local float frame, rate;

    GetAnimParams(0, anim, frame, rate);
	if (Anim == GrenadeLoadAnim && Role == ROLE_Authority)
		bServerReloading=false;
	if (anim == GrenadeLoadAnim)
	{
		IdleTweenTime=0.0;
		PlayIdle();
	}
	else
		IdleTweenTime=default.IdleTweenTime;
//	if (Anim == FireMode[1].FireAnim && !F2000SecondaryFire(FireMode[1]).bLoaded)
//		LoadGrenade();
//	else
		Super.AnimEnd(Channel);
}

// Load in a grenade
simulated function LoadGrenade()
{
	if (Ammo[1].AmmoAmount < 1 || F2000SecondaryFire(FireMode[1]).bLoaded)
	{
		if(!F2000SecondaryFire(FireMode[1]).bLoaded)
			PlayIdle();
		return;
	}
	if (ReloadState == RS_None)
		PlayAnim(GrenadeLoadAnim, 1.1, , 0);
}

function ServerStartReload (optional byte i)
{
	local int m;
	local array<byte> Loadings[2];
	
	if (bPreventReload)
		return;
	if (ReloadState != RS_None)
		return;
	if (MagAmmo < default.MagAmmo && Ammo[0].AmmoAmount > 0)
		Loadings[0] = 1;
	if (!IsGrenadeLoaded() && Ammo[1].AmmoAmount > 0)
		Loadings[1] = 1;
	if (Loadings[0] == 0 && Loadings[1] == 0)
		return;

	for (m=0; m < NUM_FIRE_MODES; m++)
		if (FireMode[m] != None && FireMode[m].bIsFiring)
			StopFire(m);

	bServerReloading = true;
	
	if (i == 1)
		m = 0;
	else m = 1;
	
	if (Loadings[i] == 1)
	{
		ClientStartReload(i);
		CommonStartReload(i);
	}
	
	else if (Loadings[m] == 1)
	{
		ClientStartReload(m);
		CommonStartReload(m);
	}
}

simulated function ClientStartReload(optional byte i)
{
	if (Level.NetMode == NM_Client)
	{
		if (i == 1)
			CommonStartReload(1);
		else
			CommonStartReload(0);
	}
}

// Prepare to reload, set reload state, start anims. Called on client and server
simulated function CommonStartReload (optional byte i)
{
	local int m;
	if (ClientState == WS_BringUp)
		ClientState = WS_ReadyToFire;
	if (i == 1)
	{
		ReloadState = RS_PreClipOut;
		PlayAnim(GrenadeLoadAnim, 1.1, , 0);
	}
	else
	{
		ReloadState = RS_PreClipOut;
		PlayReload();
	}

	if (bScopeView && Instigator.IsLocallyControlled())
		TemporaryScopeDown(Default.SightingTime*Default.SightingTimeScale);
	for (m=0; m < NUM_FIRE_MODES; m++)
		if (BFireMode[m] != None)
			BFireMode[m].ReloadingGun(i);

	if (bCockAfterReload)
		bNeedCock=true;
	if (bCockOnEmpty && MagAmmo < 1)
		bNeedCock=true;
	bNeedReload=false;
}


simulated function bool CheckWeaponMode (int Mode)
{
	if (Mode == 1)
		return FireCount < 1;
	return super.CheckWeaponMode(Mode);
}

function bool BotShouldReloadGrenade ()
{
	if ( (Level.TimeSeconds - Instigator.LastPainTime > 1.0) )
		return true;
	return false;
}

simulated event WeaponTick(float DT)
{
	super.WeaponTick(DT);

	if (AIController(Instigator.Controller) != None && !IsGrenadeLoaded()&& AmmoAmount(1) > 0 && BotShouldReloadGrenade() && !IsReloadingGrenade())
		LoadGrenade();
}

//==============================================
//=========== Camouflage =======================
//==============================================

simulated function AdjustCamoProperties(optional int Index)
{
	local float f;

		f = FRand();


			if ((Index == -1 && f > 0.95) || Index == 3) //5%
			{
     				ItemName="MARS-3 CQB-LE Assault Rifle";
				Skins[1]=CamoMaterials[3];
				GrenadeLoadAnim='GLReload2';
     				RecoilPitchFactor=1.000000;
				RecoilDeclineTime=1.100000;
				RecoilDeclineTime=0.250000;
				CamoIndex=3;
			}
			else if ((Index == -1 && f > 0.85) || Index == 2) //10%
			{
				Skins[1]=CamoMaterials[2];
				SetBoneScale (2, 0.0, ScopeBone);
				SetBoneScale (0, 1.0, SilencerBone);
				bSilenced=True;
				WeaponModes[0].bUnavailable=false;
				WeaponModes[1].bUnavailable=true;
				WeaponModes[2].bUnavailable=true;
				WeaponModes[3].bUnavailable=false;
				SetBoneRotation('SightPost', rot(0,-16384,0));
				SightOffset = vect(-5.5,-6.25,22.1);
				CurrentWeaponMode=3;
     				RecoilPitchFactor=1.000000;
				RecoilDeclineTime=1.000000;
				RecoilDeclineTime=0.200000;
				CamoIndex=2;
			}
			else if ((Index == -1 && f > 0.65) || Index == 1) // 20%
			{
				Skins[1]=CamoMaterials[1];
				CamoIndex=1;
			}
			else
			{
				Skins[1]=CamoMaterials[0];
				CamoIndex=0;
			}

}

//=====================================================================
// SUPPRESSOR CODE
//=====================================================================



function ServerSwitchSilencer(bool bNewValue)
{
	if (!Instigator.IsLocallyControlled())
		F2000PrimaryFire(FireMode[0]).SwitchSilencerMode(bNewValue);
	SilencerSwitchTime = level.TimeSeconds + 1.5;
	bSilenced = bNewValue;
	BFireMode[0].bAISilent = bSilenced;
}
//simulated function DoWeaponSpecial(optional byte i)
exec simulated function WeaponSpecial(optional byte i)
{
	if (level.TimeSeconds < SilencerSwitchTime || ReloadState != RS_None)
		return;
	if (Clientstate != WS_ReadyToFire)
		return;
	TemporaryScopeDown(0.5);
	SilencerSwitchTime = level.TimeSeconds + 1.5;
	bSilenced = !bSilenced;
	ServerSwitchSilencer(bSilenced);
	SwitchSilencer(bSilenced);
}


simulated function SwitchSilencer(bool bNewValue)
{
	F2000PrimaryFire(FireMode[0]).SwitchSilencerMode(bNewValue);
	if (bNewValue)
		PlayAnim(SilencerOnAnim);
	else
		PlayAnim(SilencerOffAnim);
}
simulated function Notify_MARSSilencerOn()
{
	PlaySound(SilencerOnSound,,0.5);
}
simulated function Notify_MARSSilencerOnTurn()
{
	PlaySound(SilencerOnTurnSound,,0.5);
}
simulated function Notify_MARSSilencerOff()
{
	PlaySound(SilencerOffSound,,0.5);
}
simulated function Notify_MARSSilencerOffTurn()
{
	PlaySound(SilencerOffTurnSound,,0.5);
}
simulated function Notify_MARSSilencerShow()
{
	SetBoneScale (0, 1.0, SilencerBone);
	SetBoneScale (4, 0.0, 'SpareSilencer');
}
simulated function Notify_MARSSilencerSpareShow()
{
	SetBoneScale (4, 1.0, 'SpareSilencer');
}
simulated function Notify_MARSSilencerHide()
{
	SetBoneScale (0, 0.0, SilencerBone);
	SetBoneScale (4, 1.0, 'SpareSilencer');
}
simulated function Notify_ClipOutOfSight()
{
	SetBoneScale (1, 1.0, 'Bullet');
}


simulated function PlayReload()
{
//	if (MagAmmo < 1)
//		SetBoneScale (1, 0.0, 'Bullet');

    if (MagAmmo < 1)
    {
       ReloadAnim='ReloadEmpty';
    }
    else
    {
       ReloadAnim='Reload';
    }
	SafePlayAnim(ReloadAnim, ReloadAnimRate, , 0, "RELOAD");

	if (bSilenced)
		SetBoneScale (0, 1.0, SilencerBone);
	else
		SetBoneScale (0, 0.0, SilencerBone);
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	if (bFirstDraw && MagAmmo > 0)
	{
     		BringUpTime=1.200000;
     		SelectAnim='FancyPullout';
		bFirstDraw=false;
	}
	else
	{
     		BringUpTime=default.BringUpTime;
		SelectAnim='Pullout';
	}
	if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
	{
		ReloadAnim = 'ReloadEmpty';
	}
	else
	{
		ReloadAnim = 'Reload';
	}

	Super.BringUp(PrevWeapon);



	if (AIController(Instigator.Controller) != None)
		bSilenced = (FRand() > 0.5);

	if (bSilenced)
		SetBoneScale (0, 1.0, SilencerBone);
	else
		SetBoneScale (0, 0.0, SilencerBone);



	Instigator.AmbientSound = UsedAmbientSound;
	Instigator.SoundVolume = default.SoundVolume;
	Instigator.SoundPitch = default.SoundPitch;
	Instigator.SoundRadius = default.SoundRadius;
	Instigator.bFullVolume = true;
}

simulated function bool PutDown()
{
	if (Super.PutDown())
	{
		return true;
	}

	Instigator.AmbientSound = UsedAmbientSound;
	Instigator.SoundVolume = default.SoundVolume;
	Instigator.SoundPitch = default.SoundPitch;
	Instigator.SoundRadius = default.SoundRadius;
	Instigator.bFullVolume = false;

	return false;
}


// Change some properties when using sights...
simulated function SetScopeBehavior()
{

	super.SetScopeBehavior();
	bUseNetAim = default.bUseNetAim || bScopeView;
	if (bScopeView)
	{
        	FireMode[0].FireAnim='SightFire';
	}
	else
	{
        	FireMode[0].FireAnim='Fire';
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
				SightingPhase += DT/0.30;
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
				SightingPhase -= DT/0.30;
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

//=====================================================================
// AI INTERFACE CODE
//=====================================================================


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
	local float Result, Height, Dist, VDot;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	if (AmmoAmount(1) < 1 || !IsGrenadeLoaded())
		return 0;
	else if (MagAmmo < 1)
		return 1;

	Dist = VSize(B.Enemy.Location - Instigator.Location);
	Height = B.Enemy.Location.Z - Instigator.Location.Z;
	VDot = Normal(B.Enemy.Velocity) Dot Normal(Instigator.Location - B.Enemy.Location);

	Result = FRand()-0.3;
	// Too far for grenade
	if (Dist > 800)
		Result -= (Dist-800) / 2000;
	// Too close for grenade
	if (Dist < 500 &&  VDot > 0.3)
		result -= (500-Dist) / 1000;
	if (VSize(B.Enemy.Velocity) > 50)
	{
		// Straight lines
		if (Abs(VDot) > 0.8)
			Result += 0.1;
		// Enemy running away
		if (VDot < 0)
			Result -= 0.2;
		else
			Result += 0.2;
	}
	// Higher than enemy
//	if (Height < 0)
//		Result += 0.1;
	// Improve grenade acording to height, but temper using horizontal distance (bots really like grenades when right above you)
	Dist = VSize(B.Enemy.Location*vect(1,1,0) - Instigator.Location*vect(1,1,0));
	if (Height < -100)
		Result += Abs((Height/2) / Dist);

	if (Result > 0.5)
		return 1;
	return 0;
}

simulated function bool IsReloadingGrenade()
{
    local name anim;
    local float frame, rate;
    GetAnimParams(0, anim, frame, rate);
	if (Anim == GrenadeLoadAnim)
 		return true;
	return false;
}

function bool CanAttack(Actor Other)
{
	if (!IsGrenadeLoaded())
	{
		if (IsReloadingGrenade())
		{
			if ((Level.TimeSeconds - Instigator.LastPainTime > 1.0))
				return false;
		}
		else if (AmmoAmount(1) > 0 && BotShouldReloadGrenade())
		{
			LoadGrenade();
			return false;
		}
	}
	return super.CanAttack(Other);
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
		Result += 0.3;
	else if (B.Enemy.Weapon != None && B.Enemy.Weapon.bMeleeWeapon)
		Result -= 0.05 * B.Skill;
	if (Dist > 3000)
		Result -= (Dist-3000) / 4000;

	return Result;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return 0.1;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.5;	}
// End AI Stuff =====

defaultproperties
{
     GrenadeLoadAnim="GLReload"
     GrenBone="GrenadeSlug"
     GrenOpenSound=Sound'BallisticSounds2.M50.M50GrenOpen'
     GrenLoadSound=Sound'BallisticSounds2.M50.M50GrenLoad'
     GrenCloseSound=Sound'BallisticSounds2.M50.M50GrenClose'

     SilencerBone="tip2"
     SilencerOnAnim="SilencerOn"
     SilencerOffAnim="SilencerOff"
     SilencerOnSound=Sound'BallisticSounds2.XK2.XK2-SilenceOn'
     SilencerOffSound=Sound'BallisticSounds2.XK2.XK2-SilenceOff'
     SilencerOnTurnSound=SoundGroup'BallisticSounds2.XK2.XK2-SilencerTurn'
     SilencerOffTurnSound=SoundGroup'BallisticSounds2.XK2.XK2-SilencerTurn'

     ScopeBone="EOTech"

     CamoMaterials[3]=Texture'BWBP_SKC_TexExp.MARS.F2000-IronWhite'
     CamoMaterials[2]=Texture'BWBP_SKC_TexExp.MARS.F2000-IronArctic'
     CamoMaterials[1]=Texture'BWBP_SKC_TexExp.MARS.F2000-IronBlack'
     CamoMaterials[0]=Texture'BWBP_SKC_TexExp.MARS.F2000-Irons'

     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=1.000000
     BigIconMaterial=Texture'BWBP_SKC_TexExp.MARS.BigIcon_F2000Alt'
     BallisticInventoryGroup=5
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Bullet=True
     SpecialInfo(0)=(Info="320.0;25.0;1.0;110.0;0.8;0.5;0.0")
     BringUpSound=(Sound=Sound'BallisticSounds2.M50.M50Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.M50.M50Putaway')
     MagAmmo=30
     CockAnimPostReload="ReloadEndCock"
     CockSound=(Sound=Sound'BWBP_SKC_SoundsExp.MARS.MARS-BoltPull',Volume=1.100000)
     ClipHitSound=(Sound=Sound'BWBP_SKC_SoundsExp.MARS.MARS-MagFiddle',Volume=1.200000)
     ClipOutSound=(Sound=Sound'BWBP_SKC_SoundsExp.MARS.MARS-MagOut',Volume=1.200000)
     ClipInSound=(Sound=Sound'BWBP_SKC_SoundsExp.MARS.MARS-MagIn',Volume=1.200000)
     ClipInFrame=0.650000
     WeaponModes(0)=(ModeName="Semi-Automatic")
     WeaponModes(1)=(ModeName="2-Round Burst",Value=2.000000)
     WeaponModes(2)=(ModeName="Automatic")
     WeaponModes(3)=(ModeName="3-Round Burst",Value=3.000000,bUnavailable=True)
     CurrentWeaponMode=2
     bNeedCock=False
     bFirstDraw=True
     bNoCrosshairInScope=True
     bCockOnEmpty=False
     	ChaosDeclineTime=0.500000
	RecoilDeclineTime=1.5
     SightOffset=(X=-5.500000,Y=-6.350000,Z=23.150000)
     SightDisplayFOV=40.000000
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.M50OutA',Pic2=Texture'BallisticUI2.Crosshairs.M50InA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=0,G=255,R=255,A=134),Color2=(B=0,G=0,R=255,A=255),StartSize1=50,StartSize2=51)
     CrouchAimFactor=0.800000
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     ViewAimFactor=0.300000
     ViewRecoilFactor=0.500000
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.300000),(InVal=0.800000,OutVal=0.400000),(InVal=1.000000,OutVal=0.500000)))
     RecoilYCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.150000),(InVal=0.600000,OutVal=0.800000),(InVal=0.800000,OutVal=0.900000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYawFactor=0.100000
     RecoilPitchFactor=4.000000
     RecoilXFactor=0.600000
     RecoilYFactor=0.500000
	RecoilMax=7000
     FireModeClass(0)=Class'BWBP_SKC_Fix.F2000PrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.F2000SecondaryFire'
     PutDownTime=0.700000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.600000
     CurrentRating=0.600000
     Description="MARS-3 CQB Assault Rifle||Manufacturer: NDTR Industries|Primary: Rapid Rifle Fire|Secondary: 40mm Pulse Mine|Special: Suppressor ||The 3 variant of the Modular Assault Rifle System is one of many rifles built under NDTR Industries' MARS project. The project, which was aimed to produce a successor to the army's current M50 and M30 rifles, has produced a number of functional prototypes. The 3 variant is a short barreled model designed for CQC use with non-standard ammunition. Field tests have shown excellent results when loaded with Snowstorm or Firestorm rounds, and above-average performance with Zero-G, toxic and electro rounds. This specific MARS-3 is loaded with 5.45mm suppressor-ready low velocity rounds and is set to fire at a blistering 850 RPM. Unlike the sharpshooter MARS-2 variant, the MARS-3 also comes with an advanced grenade launcher that can chamber 40mm JRGM Fission shockwave grenades. These grenades were developed during the first Skrith war and were invaluable for disrupting Skrith ambushes."
     Priority=65
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=9
     PickupClass=Class'BWBP_SKC_Fix.F2000Pickup'
     PlayerViewOffset=(X=0.500000,Y=12.000000,Z=-18.000000)
     BobDamping=2.000000
     AttachmentClass=Class'BWBP_SKC_Fix.F2000Attachment'
     IconMaterial=Texture'BWBP_SKC_TexExp.MARS.SmallIcon_F2000Alt'
     IconCoords=(X2=127,Y2=31)
     ItemName="MARS-3 CQB Assault Rifle"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=4.000000
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.MARS3_FP'
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Texture'BWBP_SKC_TexExp.MARS.F2000-Irons'
     Skins(2)=Texture'BWBP_SKC_TexExp.LK05.LK05-EOTech'
     Skins(4)=Shader'BWBP_SKC_TexExp.LK05.LK05-EOTechGlow'
     Skins(3)=Texture'BWBP_SKC_TexExp.MARS.F2000-Misc'
     DrawScale=0.300000
}
