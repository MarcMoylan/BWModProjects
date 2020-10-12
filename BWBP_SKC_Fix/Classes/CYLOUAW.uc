//=============================================================================
// CYLOUAW.
//
// CYLO Versitile Urban Assault Weapon.
//
// This nasty little gun has all sorts of tricks up its sleeve. Primary fire is
// a somewhat unreliable assault rifle with random fire rate and a chance to jam.
// Secondary fire is a semi-auto shotgun with its own magazine system. Special
// fire utilizes the bayonet in an attack by modifying properties of primary fire
// when activated.
//
// The gun is small enough to allow dual wielding, but because the left hand is
// occupied with the other gun, the shotgun can not be used, so that attack is
// swapped with a melee attack.
//
// by Casey 'Xavious' Johnson and Marc 'Sergeant Kelly'
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class CYLOUAW extends BallisticWeapon;

// Wishlist (*) and To do list (+):
// * GET DUALWIELDING IN?! If done, alt fire simply couldn't work as the shotgun
//   > while dual wielded. My idea would be to make a new fireclass for the melee
//   > attack. When it switches to bDualMode, it makes a check and swaps the fire
//   > class. Haven't got this to work yet though. Also, if dual wielding can
//   > make it in, I think maybe moving the gun a bit further to the right would
//   > be a good idea. Also, if the swapping fire modes idea works, we have to
//   > make sure it doesn't think it needs to reload the shotgun. My experiments
//   > showed that it likes to reload after meleeing...
// + Check bot code. I did nothing with it!
// + Check balance. Some to look for specifically would be the Weapon Special
//   > (melee stab) and weapon tick (semi-auto more accurate). Besides that, you
//   > may want to check recoil and chaos and all that jazz. As of now its probably
//   > the M50's numbers. Or SAR-12.
// + Get shotgun reload working properly.
// + Get melee stab's sounds and fire effects proper.

var() sound		MeleeFireSound;

var   bool			bMeleeing;		//I put this here and it doesn't really work so I'm sad.
var	bool			bSGNeedCock;	//Should SG cock after reloading
var	bool			bReloadingShotgun;	//Used to disable primary fire if reloading the shotgun
var() name		ShotgunLoadAnim;
var() name		ShotgunSGAnim;
var() name		CockSGAnim;
var() Sound		SGCockSound;
var() name		PreMeleeAnim;
var() Sound		TubeOpenSound;
var() Sound		TubeInSound;
var() Sound		TubeCloseSound;
//var() Sound		ShotgunCloseSound;
//var   byte		ModeBefore; //Check Weapon Mode Switch code, maybe
var() float       SGShells;
var byte OldWeaponMode;
var() float		GunCockTime;		// Used so players cant interrupt the shotgun.


replication
{
	reliable if (Role == ROLE_Authority)
	    /*ClientSwitchCYLOMode,*/ SGShells;
//	unreliable if( bNetOwner && bNetDirty && (Role==ROLE_Authority) )
//		SGShells;
}


simulated function DrawWeaponInfo(Canvas C)
{
	NewDrawWeaponInfo(C, 0.705*C.ClipY);
}

simulated function NewDrawWeaponInfo(Canvas C, float YPos)
{
	local int i,Count;
	local float ScaleFactor2;

	local float		ScaleFactor, XL, YL, YL2, SprintFactor;
	local string	Temp;
	local int	TempNum;

//	Super.NewDrawWeaponInfo (C, YPos);

	ScaleFactor = C.ClipX / 1600;
	// Draw the spare ammo amount
	C.Font = GetFontSizeIndex(C, -2 + int(2 * class'HUD'.default.HudScale));
	C.DrawColor = class'hud'.default.WhiteColor;
	if (!bNoMag)
	{
		Temp = GetHUDAmmoText(0);
		C.TextSize(Temp, XL, YL);
		C.CurX = C.ClipX - 20 * ScaleFactor * class'HUD'.default.HudScale - XL;
		C.CurY = C.ClipY - 120 * ScaleFactor * class'HUD'.default.HudScale - YL;
		C.DrawText(Temp, false);
	}
	if (Ammo[1] != None && Ammo[1] != Ammo[0])
	{

//		if (level.Netmode == NM_Standalone)
//			TempNum = (Ammo[1].AmmoAmount-SGShells);
//		else
			TempNum = Ammo[1].AmmoAmount;
		C.TextSize(Temp, XL, YL);
		C.CurX = C.ClipX - 160 * ScaleFactor * class'HUD'.default.HudScale - XL;
		C.CurY = C.ClipY - 120 * ScaleFactor * class'HUD'.default.HudScale - YL;
		C.DrawText(TempNum, false);
	}

	if (CurrentWeaponMode < WeaponModes.length && !WeaponModes[CurrentWeaponMode].bUnavailable && WeaponModes[CurrentWeaponMode].ModeName != "")
	{
		C.Font = GetFontSizeIndex(C, -3 + int(2 * class'HUD'.default.HudScale));
		C.TextSize(WeaponModes[CurrentWeaponMode].ModeName, XL, YL2);
		C.CurX = C.ClipX - 15 * ScaleFactor * class'HUD'.default.HudScale - XL;
		C.CurY = C.ClipY - 130 * ScaleFactor * class'HUD'.default.HudScale - YL2 - YL;
		C.DrawText(WeaponModes[CurrentWeaponMode].ModeName, false);
	}

	// This is pretty damn disgusting, but the weapon seems to be the only way we can draw extra info on the HUD
	// Would be nice if someone could have a HUD function called along the inventory chain
	if (SprintControl != None && SprintControl.Stamina < SprintControl.MaxStamina)
	{
		SprintFactor = SprintControl.Stamina / SprintControl.MaxStamina;
		C.CurX = C.OrgX  + 5    * ScaleFactor * class'HUD'.default.HudScale;
		C.CurY = C.ClipY - 330  * ScaleFactor * class'HUD'.default.HudScale;
		if (SprintFactor < 0.2)
			C.SetDrawColor(255, 0, 0);
		else if (SprintFactor < 0.5)
			C.SetDrawColor(64, 128, 255);
		else
			C.SetDrawColor(0, 0, 255);
		C.DrawTile(Texture'Engine.MenuWhite', 200 * ScaleFactor * class'HUD'.default.HudScale * SprintFactor, 30 * ScaleFactor * class'HUD'.default.HudScale, 0, 0, 1, 1);
	}

	DrawCrosshairs(C);

	ScaleFactor2 = 99 * C.ClipX/3200;
	C.Style = ERenderStyle.STY_Alpha;
	C.DrawColor = class'HUD'.Default.WhiteColor;
	Count = Min(8,SGShells);
    	for( i=0; i<Count; i++ )
    	{
		C.SetPos(C.ClipX - (0.5*i+1) * ScaleFactor2, C.ClipY - 100 * ScaleFactor * class'HUD'.default.HudScale);
		C.DrawTile( Texture'BWBP_SKC_Tex.CYLO.CYLO-SGIcon',ScaleFactor2, ScaleFactor2, 0, 0, 128, 128);
	}
	if ( SGShells > 8 )
	{
		Count = Min(16,SGShells);
		for( i=8; i<Count; i++ )
		{
			C.SetPos(C.ClipX - (0.5*(i-8)+1) * ScaleFactor2, YPos - ScaleFactor2);
		C.DrawTile( Texture'BWBP_SKC_Tex.CYLO.CYLO-SGIcon',ScaleFactor2, ScaleFactor2, 0, 0, 128, 128);
		}
	}
}

// Check Weapon Mode Switch code
// Was used in an attempt to get the semi-auto to fire off more than one shot at
// times. Didn't work. Feel free to change/remove.
/*simulated event PostNetBeginPlay()
{
	super.PostNetBeginPlay();
	CYLOPriFire(FireMode[0]).SwitchWeaponMode(CurrentWeaponMode);
}

function ServerSwitchWeaponMode (byte NewMode)
{
	super.ServerSwitchWeaponMode(NewMode);
	if (!Instigator.IsLocallyControlled())
		CYLOPriFire(FireMode[0]).SwitchWeaponMode(CurrentWeaponMode);
	ClientSwitchCYLOMode (CurrentWeaponMode);
}
simulated function ClientSwitchCYLOMode (byte NewMode)
{
	CYLOPriFire(FireMode[0]).SwitchWeaponMode(NewMode);
}*/
simulated function Notify_TubeOut()
{
	if (SGShells == 0)
		bSGNeedCock=true;
	else
		bSGNeedCock=false;
}
simulated function Notify_TubeSlideOut()	
{	
	PlaySound(TubeOpenSound, SLOT_Misc, 0.5, ,64);	
	ReloadState = RS_PreClipIn;
}
simulated function Notify_TubeIn()          
{   
	local int AmmoNeeded;
	
	PlaySound(TubeInSound, SLOT_Misc, 0.5, ,64);    
	ReloadState = RS_PostClipIn; 
//	SGShells = 6;    
	if (level.NetMode != NM_Client)
	{
		AmmoNeeded = default.SGShells-SGShells;
		if (AmmoNeeded > Ammo[1].AmmoAmount)
			SGShells+=Ammo[1].AmmoAmount;
		else
			SGShells = default.SGShells;
		CYLOSecondaryFire(FireMode[1]).bLoaded = true;   
		Ammo[1].UseAmmo (AmmoNeeded, True);
	}
	CYLOSecondaryFire(FireMode[1]).bLoaded = true;   
}
simulated function Notify_TubeSlideIn()	    
{	
	PlaySound(TubeCloseSound, SLOT_Misc, 0.5, ,64);	
}
simulated function Notify_SGCockStart()	
{
	PlaySound(SGCockSound, SLOT_Misc, 0.5, ,64);					
}
simulated function Notify_SGCockEnd()	
{
	bSGNeedCock=false;
	ReloadState = RS_None;					
}

simulated function Notify_CockSGAfterReload()
{
	if (bSGNeedCock)
	{

		ReloadState = RS_Cocking;
		if (SightingState != SS_None)
			TemporaryScopeDown(0.5);
      	SafePlayAnim('CockSG', 1.0, 0.1);	
	}
}




simulated function CockShotgun()
{
	if (ReloadState == RS_None)
	{
		PlayAnim(CockSGAnim, 1.0, , 0);
	}
}


// A grenade has just been picked up. Loads one in if we're empty
function ShotShellsPickedUp ()
{
	if (Ammo[1].AmmoAmount < Ammo[1].MaxAmmo)
	{
		if (Instigator.Weapon == self)
			LoadShotgun();
		else
			CYLOSecondaryFire(FireMode[1]).bLoaded=true;
	}
	if (!Instigator.IsLocallyControlled())
		ClientShotShellPickedUp();
}

simulated function ClientShotShellPickedUp()
{
	if (Ammo[1].AmmoAmount < Ammo[1].MaxAmmo)
	{
		if (ClientState == WS_ReadyToFire)
			LoadShotgun();
		else
			CYLOSecondaryFire(FireMode[1]).bLoaded=true;
	}
}

simulated function bool IsShotgunLoaded()
{
	return CYLOSecondaryFire(FireMode[1]).bLoaded;
}


// Tell our ammo that this is the CYL0 it must notify about SH pickups
function GiveAmmo(int m, WeaponPickup WP, bool bJustSpawned)
{
	Super.GiveAmmo(m, WP, bJustSpawned);
	if (Ammo[1] != None && Ammo_CYLOSG(Ammo[1]) != None)
		Ammo_CYLOSG(Ammo[1]).DaCYLO = self;
}

simulated function LoadShotgun()
{
	if (Ammo[1].AmmoAmount < 1 || CYLOSecondaryFire(FireMode[1]).bLoaded)
		return;
	bReloadingShotgun=true;
//	M50SecondaryFire(FireMode[1]).bLoaded = true;
	if (ReloadState == RS_None)
		PlayAnim(ShotgunLoadAnim, 1.0, , 0);
}

simulated function MainLoadShotgun()
{
	if (Ammo[1].AmmoAmount < 1)
		return;
	if (ReloadState == RS_None)
	{
		ReloadState = RS_PreClipOut;
		PlayAnim(ShotgunLoadAnim, 1.0, , 0);
	}
}


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

simulated function bool IsReloadingShotgun()
{
    local name anim;
    local float frame, rate;
    GetAnimParams(0, anim, frame, rate);
	if (Anim == ShotgunLoadAnim)
 		return true;
	return false;
}

function bool BotShouldReloadShotgun ()
{
	if ( (Level.TimeSeconds - Instigator.LastPainTime > 1.0) )
		return true;
	return false;
}
simulated event Tick (float DT)
{

	if (level.Netmode != NM_Standalone )
			BallisticInstantFire(FireMode[0]).JamChance=0.00;
	super.Tick(DT);
}


simulated event WeaponTick(float DT)
{
	super.WeaponTick(DT);
	
	if (AIController(Instigator.Controller) != None && !IsShotgunLoaded()&& AmmoAmount(1) > 0 && BotShouldReloadShotgun() && !IsReloadingShotgun())
		LoadShotgun();

//	if (Ammo[1].AmmoAmount <= 6 && SGShells == 6)
//		SGShells = Ammo[1].AmmoAmount;

    // This would tweak the semi-auto mode so that is a bit easier to line up shots.
    // Feel free to adjust/remove.
	if (CurrentWeaponMode != OldWeaponMode)
	{
		if (CurrentWeaponMode == 1)
		{
			BFireMode[0].RecoilPerShot = BFireMode[0].default.RecoilPerShot * 0.8;
			RecoilDeclineTime = default.RecoilDeclineTime * 0.9;
		}
		else
		{
			BFireMode[0].RecoilPerShot = BFireMode[0].default.RecoilPerShot;
            RecoilDeclineTime = default.RecoilDeclineTime;
        }
		OldWeaponMode = CurrentWeaponMode;
	}
}

function ServerWeaponSpecial(optional byte i)
{
	if (ReloadState != RS_None)
		return;
    ClientWeaponSpecial(i);
    CommonWeaponSpecial(i);
}

simulated function ClientWeaponSpecial(optional byte i)
{
	if (level.NetMode == NM_Client && ReloadState == RS_None)
		CommonWeaponSpecial(i);
}

simulated event AnimEnd (int Channel)
{
    local name anim;
    local float frame, rate;

    GetAnimParams(0, anim, frame, rate);
	if (anim == ShotgunLoadAnim || anim == CockSGAnim)
	{
		IdleTweenTime=0.0;
		PlayIdle();
	}
	else
		IdleTweenTime=default.IdleTweenTime;
	if (anim == 'Melee')
	{
		bMeleeing=false;
		CYLOAttachment(ThirdPersonActor).bMeleeing=false;
	}
//   	if (Anim == FireMode[1].FireAnim && !CYLOSecondaryFire(FireMode[1]).bLoaded)
//		LoadShotgun();
	else
		Super.AnimEnd(Channel);
}

function ServerStartReload (optional byte i)
{
	local int channel;
	local name seq;
	local float frame, rate;

	if (ReloadState != RS_None)
		return;
//	if (bIsPendingHandGun || PendingHandGun!=None)
//		return;
//	if (Othergun != None)
//	{
//		if (Othergun.Clientstate != WS_ReadyToFire)
//			return;
//		if (IsinState('DualAction'))
//			return;
//	}

	GetAnimParams(channel, seq, frame, rate);
	if (seq == ShotgunLoadAnim)
		return;

	if (SGShells < 6 && Ammo[1].AmmoAmount != 0 && (MagAmmo >= default.MagAmmo/2 || Ammo[0].AmmoAmount < 1))
	{
		if (AmmoAmount(1) > 0 && !IsReloadingShotgun())
		{
//			ReloadState = RS_PreClipOut;
			LoadShotgun();
			PlayAnim(ShotgunLoadAnim, 1.0, , 0);
			ClientStartReload(1);
		}
		return;
	}
	super.ServerStartReload();
}

simulated function ClientStartReload(optional byte i)
{
	if (Level.NetMode == NM_Client)
	{
		if (i == 1)
		{
			if (AmmoAmount(1) > 0 && !IsReloadingShotgun())
			{
				LoadShotgun();
				PlayAnim(ShotgunLoadAnim, 1.0, , 0);
			}
		}
		else
			CommonStartReload(i);
	}
}


//simulated function DoWeaponSpecial(optional byte i)
exec simulated function WeaponSpecial(optional byte i)
{
	if (level.Netmode != NM_Standalone)
		return;
	if (ReloadState != RS_None)
		return;
//	if (bMeleeing)
//		return;
	PlayAnim(PreMeleeAnim);
	bReloadingShotgun=false;
	ReloadState = RS_PreClipOut; //Because we are obviously reloading. Brute force code ftw
	bMeleeing=true;
	ServerWeaponSpecial(i);
	CYLOAttachment(ThirdPersonActor).bMeleeing=true;
}

//simulated function DoWeaponSpecialRelease(optional byte i)
exec simulated function WeaponSpecialRelease(optional byte i) //This code is disgustingly brute forcey :D
{
	if (ReloadState != RS_PreClipOut)
		return; //Turns out it doesnt work
		
    BallisticInstantFire(FireMode[0]).AmmoPerFire = 0;
	BallisticInstantFire(FireMode[0]).Damage = 35;
	BallisticInstantFire(FireMode[0]).DamageHead = 110;
	BallisticInstantFire(FireMode[0]).DamageLimb = 20;
    BallisticInstantFire(FireMode[0]).TraceRange.Min=110.00;
    BallisticInstantFire(FireMode[0]).TraceRange.Max=110.00;
    BallisticInstantFire(FireMode[0]).BallisticFireSound.Sound=MeleeFireSound;
    BallisticInstantFire(FireMode[0]).RangeAtten=1.000000;
    BallisticInstantFire(FireMode[0]).WaterRangeAtten=1.000000;
    BallisticInstantFire(FireMode[0]).DamageType=Class'BWBP_SKC_Fix.DTCYLOStab';
    BallisticInstantFire(FireMode[0]).DamageTypeHead=Class'BWBP_SKC_Fix.DTCYLOStabHead';
    BallisticInstantFire(FireMode[0]).DamageTypeArm=Class'BWBP_SKC_Fix.DTCYLOStabLimb';
    BallisticInstantFire(FireMode[0]).PreFireAnim='PrepMelee';
	BallisticInstantFire(FireMode[0]).FireAnim='Melee';
    BallisticInstantFire(FireMode[0]).bFireOnRelease=True;
    BallisticInstantFire(FireMode[0]).bWaitForRelease=True;
    BallisticInstantFire(FireMode[0]).JamChance=0.00;
    BallisticInstantFire(FireMode[0]).MuzzleFlashClass=None;
    BallisticInstantFire(FireMode[0]).bUseRunningDamage=True;
    BallisticInstantFire(FireMode[0]).bUseWeaponMag=False;
    BallisticInstantFire(FireMode[0]).bIgnoreReload=True;
    BallisticInstantFire(FireMode[0]).Load=BallisticInstantFire(FireMode[0]).AmmoPerFire;
	FireMode[0].ModeDoFire();
	BallisticInstantFire(FireMode[0]).Damage = BallisticInstantFire(FireMode[0]).default.Damage;
	BallisticInstantFire(FireMode[0]).DamageHead = BallisticInstantFire(FireMode[0]).default.DamageHead;
	BallisticInstantFire(FireMode[0]).DamageLimb = BallisticInstantFire(FireMode[0]).default.DamageLimb;
    BallisticInstantFire(FireMode[0]).AmmoPerFire = BallisticInstantFire(FireMode[0]).default.AmmoPerFire;
    BallisticInstantFire(FireMode[0]).TraceRange = BallisticInstantFire(FireMode[0]).default.TraceRange;
    BallisticInstantFire(FireMode[0]).BallisticFireSound=BallisticInstantFire(FireMode[0]).default.BallisticFireSound;
    BallisticInstantFire(FireMode[0]).RangeAtten = BallisticInstantFire(FireMode[0]).default.RangeAtten;
    BallisticInstantFire(FireMode[0]).WaterRangeAtten = BallisticInstantFire(FireMode[0]).default.WaterRangeAtten;
    BallisticInstantFire(FireMode[0]).DamageType = BallisticInstantFire(FireMode[0]).default.DamageType;
    BallisticInstantFire(FireMode[0]).DamageTypeHead = BallisticInstantFire(FireMode[0]).default.DamageTypeHead;
    BallisticInstantFire(FireMode[0]).DamageTypeArm = BallisticInstantFire(FireMode[0]).default.DamageTypeArm;
    BallisticInstantFire(FireMode[0]).PreFireAnim = BallisticInstantFire(FireMode[0]).default.PreFireAnim;
	BallisticInstantFire(FireMode[0]).FireAnim = BallisticInstantFire(FireMode[0]).default.FireAnim;
    BallisticInstantFire(FireMode[0]).bFireOnRelease = BallisticInstantFire(FireMode[0]).default.bFireOnRelease;
    BallisticInstantFire(FireMode[0]).bWaitForRelease = BallisticInstantFire(FireMode[0]).default.bWaitForRelease;
    BallisticInstantFire(FireMode[0]).JamChance = BallisticInstantFire(FireMode[0]).default.JamChance;
    BallisticInstantFire(FireMode[0]).MuzzleFlashClass = BallisticInstantFire(FireMode[0]).default.MuzzleFlashClass;
    BallisticInstantFire(FireMode[0]).bUseRunningDamage = BallisticInstantFire(FireMode[0]).default.bUseRunningDamage;
    BallisticInstantFire(FireMode[0]).bUseWeaponMag = BallisticInstantFire(FireMode[0]).default.bUseWeaponMag;
    BallisticInstantFire(FireMode[0]).bIgnoreReload = BallisticInstantFire(FireMode[0]).default.bIgnoreReload;
    BallisticInstantFire(FireMode[0]).AmmoPerFire = BallisticInstantFire(FireMode[0]).default.AmmoPerFire;
	CYLOAttachment(ThirdPersonActor).bMeleeing=false;
    BallisticInstantFire(FireMode[0]).Load=BallisticInstantFire(FireMode[0]).AmmoPerFire;
    FireMode[0].NextFireTime -= 0.3;
	ServerWeaponSpecialRelease(i);
		Settimer(0.3, false);
}

simulated function bool PutDown()
{
	if (Super.PutDown())
	{
		if (ThirdPersonActor != None)
			CYLOAttachment(ThirdPersonActor).bMeleeing = false;
		bMeleeing=false;
		bReloadingShotgun=false;
		return true;
	}
	return false;
}
/*
// Dual wielding code (I think this one is)
simulated function bool CanAlternate(int Mode)
{
	if (Mode != 0)
		return false;
	return super.CanAlternate(Mode);
}*/
/*
// Dual wielding code
simulated function SetDualMode (bool bDualMode)
{
	AdjustCYLOProperties(bDualMode);
}
// My attempt to make the FireModeClass[1] swap with the melee fire mode
simulated function AdjustCYLOProperties (bool bDualMode)
{
//	AimAdjustTime		= default.AimAdjustTime;
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
//	RecoilMax			= default.RecoilMax;
	RecoilDeclineTime	= default.RecoilDeclineTime;
	FireModeClass[1]    = Class'BWBP_SKC_Fix.CYLOSecondaryFire';
//	PlayerViewOffset.Y  = 4;

	if (bDualMode)
	{
		if (Instigator.IsLocallyControlled() && SightingState == SS_Active)
			StopScopeView();
//		SetBoneScale(8, 0.0, SupportHandBone);
		if (AIController(Instigator.Controller) == None)
			bUseSpecialAim = true;
//		AimAdjustTime		*= 1.0;
		AimSpread			*= 1.4;
		ViewAimFactor		*= 0.6;
		ViewRecoilFactor	*= 0.75;
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
		FireModeClass[1]     = Class'BWBP_SKC_Fix.CYLOMeleeFire';
//		PlayerViewOffset.Y   = 6;
	}
}*/

// AI Interface =====
// choose between regular or alt-fire
function byte BestMode()
{
	local Bot B;
	local float Result, Height, Dist, VDot;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	if (AmmoAmount(1) < 1 || !IsShotgunLoaded())
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

function bool CanAttack(Actor Other)
{
	if (!IsShotgunLoaded())
	{
		if (IsReloadingShotgun())
		{
			if ((Level.TimeSeconds - Instigator.LastPainTime > 1.0))
				return false;
		}
		else if (AmmoAmount(1) > 0 && BotShouldReloadShotgun())
		{
			LoadShotgun();
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

simulated function bool HasAmmo()
{
	return true;
}

defaultproperties
{
     MeleeFireSound=Sound'BallisticSounds3.A73.A73Stab'
     ShotgunLoadAnim="ReloadSG"
     CockSGAnim="CockSG"
     PreMeleeAnim="PrepMelee"
     SGCockSound=Sound'BWBP_SKC_Sounds.CYLO.CYLO-CockSG'
     TubeOpenSound=Sound'BallisticSounds2.M50.M50GrenOpen'
     TubeInSound=Sound'BallisticSounds2.M50.M50GrenLoad'
     TubeCloseSound=Sound'BallisticSounds2.M50.M50GrenClose'
     SGShells=6.000000
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=1.000000
     BigIconMaterial=Texture'BWBP_SKC_Tex.CYLO.BigIcon_CYLO'
     BallisticInventoryGroup=5
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Bullet=True
     bWT_Shotgun=True
     bWT_Machinegun=True
     SpecialInfo(0)=(Info="240.0;25.0;0.9;85.0;0.1;0.9;0.4")
     BringUpSound=(Sound=Sound'BallisticSounds2.M50.M50Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.M50.M50Putaway')
     MagAmmo=28
     CockAnimPostReload="Cock"
     CockSound=(Sound=Sound'BallisticSounds2.M50.M50Cock')
     ClipHitSound=(Sound=Sound'BallisticSounds2.M50.M50ClipHit')
     ClipOutSound=(Sound=Sound'BallisticSounds2.M50.M50ClipOut')
     ClipInSound=(Sound=Sound'BallisticSounds2.M50.M50ClipIn')
     ClipInFrame=0.700000
     bNeedCock=True
     WeaponModes(0)=(bUnavailable=True,ModeID="WM_None")
     WeaponModes(1)=(ModeName="Semi-Auto",Value=1.000000)
     SightPivot=(Pitch=900)
     SightOffset=(X=-25.000000,Z=8.000000)
     SightDisplayFOV=40.000000
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.M763OutA',Pic2=Texture'BallisticUI2.Crosshairs.G5InA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(G=112,R=196),Color2=(B=38,R=0),StartSize1=114,StartSize2=93)
     GunLength=16.000000
     LongGunPivot=(Pitch=2000,Yaw=-1024)
     LongGunOffset=(X=-10.000000,Y=0.000000,Z=-5.000000)
     CrouchAimFactor=0.900000
     JumpOffSet=(Pitch=1000,Yaw=-500)
     JumpChaos=0.300000
     AimAdjustTime=0.400000
     AimSpread=(X=(Min=-32.000000,Max=32.000000),Y=(Min=-32.000000,Max=32.000000))
     ChaosAimSpread=(X=(Min=-1600.000000,Max=1600.000000),Y=(Min=-1600.000000,Max=1600.000000))
     ViewAimFactor=0.050000
     ViewRecoilFactor=0.400000
     ChaosDeclineTime=1.000000
     ChaosTurnThreshold=170000.000000
     ChaosSpeedThreshold=1200.000000
     RecoilXCurve=(Points=(,(InVal=0.050000,OutVal=0.050000),(InVal=0.100000,OutVal=0.060000),(InVal=0.150000,OutVal=-0.060000),(InVal=0.200000),(InVal=0.400000,OutVal=-0.200000),(InVal=0.600000,OutVal=0.300000),(InVal=0.800000,OutVal=-0.300000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYCurve=(Points=(,(InVal=0.050000,OutVal=0.050000),(InVal=0.100000,OutVal=-0.050000),(InVal=0.150000),(InVal=0.200000,OutVal=0.300000),(InVal=0.400000,OutVal=0.500000),(InVal=0.600000,OutVal=0.600000),(InVal=1.000000,OutVal=1.000000)))
     RecoilXFactor=0.250000
     RecoilYFactor=0.250000
     RecoilMax=1024.000000
     RecoilDeclineTime=0.800000
     FireModeClass(0)=Class'BWBP_SKC_Fix.CYLOPriFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.CYLOSecondaryFire'
     PutDownTime=0.700000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.600000
     CurrentRating=0.600000
     Description="CYLO Versatile Urban Assault Weapon||Manufacturer: Dipheox Combat Arms|Primary: Select Fire Assault Rifle|Secondary: Semi-Automatic 16 Gauge Shotgun|Special: Melee Slash||Dipheox's most popular weapon, the CYLO Versatile Urban Assault Weapon is designed with one goal in mind: Brutal close quarters combat. The CYLO accomplishes this goal quite well, earning itself the nickname of Badger with its small frame, brutal effectiveness, and unpredictability. UTC refuses to let this weapon in the hands of its soldiers because of its erratic firing and tendency to jam.||The CYLO Versatile UAW is fully capable for urban combat. The rifle's caseless 7.62mm rounds can easily shoot through doors and thin walls, while the shotgun can clear a room quickly with its semi-automatic firing. Proper training with the bayonet can turn the gun itself into a deadly melee weapon."
     DisplayFOV=55.000000
     Priority=41
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=4
     PickupClass=Class'BWBP_SKC_Fix.CYLOMk1Pickup'
     PlayerViewOffset=(X=15.000000,Y=5.000000,Z=-5.000000)
     BobDamping=2.000000
     AttachmentClass=Class'BWBP_SKC_Fix.CYLOAttachment'
     IconMaterial=Texture'BWBP_SKC_Tex.CYLO.SmallIcon_CYLO'
     IconCoords=(X2=127,Y2=31)
     ItemName="CYLO Assault Weapon"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=4.000000
     Mesh=SkeletalMesh'BWBP_SKC_Anim.CYLO.CYLO'
     DrawScale=0.300000
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Texture'BWBP_SKC_Tex.CYLO.CYLO-Main'
}
