//=============================================================================
// BulldogAssaultCannon
//
// A gigantic god damn AH104 on steroids. Uses a very complex alt fire mechanism.
// Alt fire shoots rockets that are loaded before (offline) or after (online)
// Full auto will let you load them faster. Both firemodes have splash damage.
// 
// This gun isnt nearly as accurate as the AH104, but has much more shock value.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class BulldogAssaultCannon extends BallisticWeapon;

var() Sound		GrenOpenSound;		//Sounds for rocket reloading
var() Sound		GrenLoadSound;		//
var() Sound		GrenCloseSound;		//


var() Sound		CockSoundQuick;		//
var() Sound		CockSoundAlt;		//
var() Sound		CockSoundAltQ;		//


var() name		GrenadeLoadAnim;	//Anim for rocket reload
var() name		SGPrepAnim;			//Anim for loading a rocket
var() name		SGPrepAnimQ;			//Anim for loading a rocket quickly
var() name		SingleGrenadeLoadAnim;	//Anim for rocket reload loop
var() name		GrenLoadStartAnim;
var() name		GrenLoadEndAnim;
var() name		CockingAnim;		//Restated here so the guns can call it
var() Name		ShovelAnim;		//Anim to play after shovel loop ends
var() name		AltIdleAnim;		//Anim for vert grip hang time

var() float       	VisGrenades;		//Rockets currently visible in tube.
var() float       	Grenades;		//Rockets currently in the gun.
var() bool		bReady;			//Weapon ready for alt fire
var() bool		bPrepping;		//Used to play an alt cocking noise
var() bool		bWantsToShoot;		//Are we cancelling a reload?

var() bool		bHaltHUDUpdate;		//Don't update the HUD until everything is pretty

var() byte		LastWeaponMode;		//Used to store the last referenced firemode pre Alt
/*
var() name		ShellBone1;			// Bones to use for hiding shells
var() name		ShellBone2;
var() name		ShellBone3;
var() name		ShellBone4;
var() name		ShellBone5;
var() name		ShellBone6; */

var name			BulletBone; //What it says on the tin

var   byte				ShellIndex;

struct RevInfo
{
	var() name	Shellname;
};
var() RevInfo	Shells[6];

replication
{
	// Things the server should send to the client.
	unreliable if( bNetOwner && bNetDirty && (Role==ROLE_Authority) )
		Grenades;
		
//	unreliable if (Role == Role_Authority)
//		ClientGrenadePickedUp;
}


// Apply accuracy scale and send client's view aim info to server
simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

	if (level.Netmode != NM_Standalone)
	{
		BFireMode[1].FireRate = 2.0;
		CockAnimRate = 1.3;
		BFireMode[1].ProjectileClass=Class'BWBP_SKC_Fix.BulldogLightRocket';
		BFireMode[1].bWaitForRelease=True;
//		Grenades = Ammo[1].AmmoAmount;
	}

   if (BCRepClass.default.bNoReloading)
      bNoMag = true;
   AimSpread *= BCRepClass.default.AccuracyScale;
   ChaosAimSpread *= BCRepClass.default.AccuracyScale;

   if (level.NetMode == NM_Client)
      ServerSetViewAimScale(ViewAimScale*255, ViewRecoilScale*255, bUseScopeViewAim);
}

simulated function bool CheckWeaponMode (int Mode)
{
	if (level.Netmode != NM_Standalone && Mode == 1 && WeaponModes[CurrentWeaponMode].ModeID ~= "WM_FullAuto" && FireCount >= 1) //Rapidfire is disabled online
		return false;
	if (WeaponModes[CurrentWeaponMode].ModeID ~= "WM_FullAuto" || WeaponModes[CurrentWeaponMode].ModeID ~= "WM_None")
		return true;
	if (FireCount >= WeaponModes[CurrentWeaponMode].Value)
		return false;
	return true;
}


// Only skips for alternate reload
simulated function FirePressed(float F)
{
	if ((ReloadState == RS_Shovel) || (ReloadState == RS_PostShellIn))
	{
		ServerSkipReload();
		if (Level.NetMode == NM_Client)
			SkipReload();
	}
	if (!HasAmmo())
		OutOfAmmo();
	else if (bNeedReload && ClientState == WS_ReadyToFire)
	{
		// Removed and replaced by EmptyFire()
//		ServerStartReload();
	}
	else if (reloadState == RS_None && bNeedCock && MagAmmo > 0 && !IsFiring() && level.TimeSeconds > FireMode[0].NextfireTime)
	{
		CommonCockGun();
		if (Level.NetMode == NM_Client)
			ServerCockGun();
	}
}
//simulated function Fire(float F)	{	FirePressed(F);	}
simulated function AltFire(float F)	{	FirePressed(F);	}


simulated function EmptyAltFire (byte Mode)
{
	if (Grenades <= 0 && ClientState == WS_ReadyToFire && FireCount < 1 && Instigator.IsLocallyControlled())
		ServerStartReload();
}

//Skip reloading if fire is pressed in time
simulated function SkipReload()
{
	if (ReloadState == RS_Shovel || ReloadState == RS_PostShellIn)
	{//Leave shovel loop and go to EndShovel
		PlayShovelEnd();
		ReloadState = RS_EndShovel;
	}
	else if (ReloadState == RS_PreClipOut)
	{//skip reload if clip has not yet been pulled out
		ReloadState = RS_PostClipIn;
		SetAnimFrame(ClipInFrame);
	}
}

simulated function DrawWeaponInfo(Canvas Canvas)
{
	NewDrawWeaponInfo(Canvas, 0.705*Canvas.ClipY);
}
//Modified to subtract active grenades and add little icons
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
		C.CurY = C.ClipY - 140 * ScaleFactor * class'HUD'.default.HudScale - YL;
		C.DrawText(Temp, false);
	}
	if (Ammo[1] != None && Ammo[1] != Ammo[0])
	{
		
//			if (level.Netmode == NM_Standalone)
//			{
//				if (BulldogSecondaryFire(FireMode[1]).HUDRefreshTime - Level.TimeSeconds <= -0.5)
//					TempNum = (Ammo[1].AmmoAmount-Grenades);
//				LastTempNum = TempNum;
//			}
//			else
				TempNum = Ammo[1].AmmoAmount;
			C.TextSize(TempNum, XL, YL);
			C.CurX = C.ClipX - 160 * ScaleFactor * class'HUD'.default.HudScale - XL;
			C.CurY = C.ClipY - 140 * ScaleFactor * class'HUD'.default.HudScale - YL;
//			if (BulldogSecondaryFire(FireMode[1]).HUDRefreshTime - Level.TimeSeconds <= -0.5)
				C.DrawText(TempNum, false);
//			else
//				C.DrawText("--", false);


	}

	if (CurrentWeaponMode < WeaponModes.length && !WeaponModes[CurrentWeaponMode].bUnavailable && WeaponModes[CurrentWeaponMode].ModeName != "")
	{
		C.Font = GetFontSizeIndex(C, -3 + int(2 * class'HUD'.default.HudScale));
		C.TextSize(WeaponModes[CurrentWeaponMode].ModeName, XL, YL2);
		C.CurX = C.ClipX - 15 * ScaleFactor * class'HUD'.default.HudScale - XL;
		C.CurY = C.ClipY - 150 * ScaleFactor * class'HUD'.default.HudScale - YL2 - YL;
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
	Count = Min(8,Grenades);
    	for( i=0; i<Count; i++ )
    	{
		C.SetPos(C.ClipX - (0.5*i+1) * ScaleFactor2, C.ClipY - 100 * ScaleFactor * class'HUD'.default.HudScale);
		C.DrawTile( Texture'BWBP_SKC_Tex.Bulldog.Bulldog-FRAGIcon',ScaleFactor2, ScaleFactor2, 0, 0, 128, 128);
	}
	if ( Grenades > 8 )
	{
		Count = Min(16,Grenades);
		for( i=8; i<Count; i++ )
		{
			C.SetPos(C.ClipX - (0.5*(i-8)+1) * ScaleFactor2, C.ClipY - 100 * ScaleFactor * class'HUD'.default.HudScale - YL);
		C.DrawTile( Texture'BWBP_SKC_Tex.Bulldog.Bulldog-FRAGIcon',ScaleFactor2, ScaleFactor2, 0, 0, 128, 128);
		}
	}
}


simulated function PlayIdle()
{
	if (IsFiring())
		return;
	if (bPendingSightUp)
		ScopeBackUp();
	else if (SightingState != SS_None)
	{
		if (SafePlayAnim(IdleAnim, 1.0))
			FreezeAnimAt(0.0);
	}
	else if (bScopeView)
	{
		if (SafePlayAnim(IdleAnim, 1.0))
			FreezeAnimAt(0.0);
	}
	else 
	{
		if (CurrentWeaponMode == 3 || bReady)
			SafeLoopAnim(AltIdleAnim, IdleAnimRate, IdleTweenTime, ,"IDLE");
		else
			SafeLoopAnim(IdleAnim, IdleAnimRate, IdleTweenTime, ,"IDLE");
	}
	
}

//Remove one of the in-tube grenades
simulated function Notify_RemoveVisGrenade()
{
//	local int i;
//	VisGrenades=Grenades;
	VisGrenades-=1;
//	if (VisGrenades<0)
//		VisGrenades=0;
//	for(i=5;i>=VisGrenades;i--)
//		SetBoneScale(i, 0.0, Shells[i].ShellName);
//	SetBoneScale(ShellIndex, 0.0, Shells[ShellIndex].ShellName);
//	if (ShellIndex > 0)
//		ShellIndex--;
		
}
//Add one of the in-tube grenades
simulated function Notify_AddVisGrenade()
{
//	local int i;

//	VisGrenades=Grenades;
	VisGrenades+=1;
//	if (VisGrenades>5)
//		VisGrenades=5;
//	for(i=0;i<=VisGrenades;i++)
//		SetBoneScale(i, 1.0, Shells[i].ShellName);
//	SetBoneScale(ShellIndex, 1.0, Shells[ShellIndex].ShellName);
//	if (ShellIndex < 5)
//		ShellIndex++;
		
}
//Function called by alt fire to play SG Pump animation.
simulated function PrepAltFire()
{
		bPrepping=true;
		if (CurrentWeaponMode==0)
			PlayAnim(SGPrepAnim,1.0, 0.0);
		else if (CurrentWeaponMode==2)
			PlayAnim(SGPrepAnimQ,1.0, 0.0);
		ReloadState = RS_Cocking;
}

//Triggered when the SG pump animation finishes
simulated function Notify_GrenadeReady()
{
		ReloadState = RS_None;	
		bReady = true;
		WeaponModes[3].bUnavailable=false;
		LastWeaponMode=CurrentWeaponMode;
		CurrentWeaponMode=3;
//		ServerSwitchWeaponMode();
		WeaponModes[0].bUnavailable=true;
		WeaponModes[2].bUnavailable=true;
		
}

//Function called by primary fire to play AR Pump animation.
simulated function UnPrepAltFire()
{
		PlayAnim(CockingAnim, 1.75, 0.0);
		ReloadState = RS_Cocking;
}


//Triggered after Alt nade is shot.
simulated function PrepPriFire()
{
		WeaponModes[0].bUnavailable=false;
		WeaponModes[2].bUnavailable=false;
		CurrentWeaponMode=LastWeaponMode;
//		ServerSwitchWeaponMode();
		WeaponModes[3].bUnavailable=true;
		bHaltHUDUpdate = false;
}

//For inserting a shell while reloading
simulated function Notify_BulldogShellIn()
{
		PlaySound(GrenLoadSound, SLOT_Misc, 0.5, ,64);
//		BulldogSecondaryFire(FireMode[1]).bLoaded = true;
//		Grenades += 1;
		ReloadState = RS_PostShellIn;	
		if (Role == ROLE_Authority)
		{
			BulldogSecondaryFire(FireMode[1]).bLoaded = true;
			Grenades += 1;
			Ammo[1].UseAmmo (1, True);
		}
}
/*
//For reloading alt fire and begining shovel reload
simulated function BulldogGoToLoop()
{
		if (SightingState != SS_None)
			TemporaryScopeDown(0.5);
		
		SafePlayAnim(SingleGrenadeLoadAnim,1.0, 0.0, , "RELOAD");
//      	PlayAnim('SingleGrenadeLoadAnim', 1.0, 0.0);
		ReloadState = RS_Shovel;
}

//For after a shell is inserted into the gun
simulated function BulldogContinueLoop()
{
	if (Grenades == 6 || Ammo[1].AmmoAmount == 0)
	{
      		PlayAnim(GrenLoadEndAnim, 1.0, 0.0);
		ReloadState = RS_EndShovel;
		return;
	}
	else
	{
		PlayAnim(SingleGrenadeLoadAnim,1.0, 0.0);
		ReloadState = RS_Shovel;
	}
	return;
}
*/

//Plays different sounds depending on animation. Also changes alt and primary fire states
simulated function Notify_CockStart()
{
	if (ReloadState == RS_None)	return;
	if (bReady)
	{
		PlayOwnedSound(CockSoundQuick,CockSound.Slot,CockSound.Volume,CockSound.bNoOverride,CockSound.Radius,CockSound.Pitch,CockSound.bAtten);
		bReady=false;
		BulldogPrimaryFire(FireMode[0]).EjectFRAGBrass();
		Grenades -= 1;
		if (Grenades <= 0)
			BulldogSecondaryFire(FireMode[1]).bLoaded = false;
		WeaponModes[0].bUnavailable=false;
		WeaponModes[2].bUnavailable=false;
		CurrentWeaponMode=LastWeaponMode;
		WeaponModes[3].bUnavailable=true;
	}
	else if (bPrepping && CurrentWeaponMode == 0)
	{
		PlayOwnedSound(CockSoundAlt,CockSound.Slot,CockSound.Volume,CockSound.bNoOverride,CockSound.Radius,CockSound.Pitch,CockSound.bAtten);
		bPrepping=false;
	}
	else if (bPrepping && CurrentWeaponMode == 2)
	{
		PlayOwnedSound(CockSoundAltQ,CockSound.Slot,CockSound.Volume,CockSound.bNoOverride,CockSound.Radius,CockSound.Pitch,CockSound.bAtten);
		bPrepping=false;
	}
	else
		PlayOwnedSound(CockSound.Sound,CockSound.Slot,CockSound.Volume,CockSound.bNoOverride,CockSound.Radius,CockSound.Pitch,CockSound.bAtten);
}


// Animation notify for when the clip is stuck in
simulated function Notify_ClipUp()
{
	SetBoneScale(6,1.0,BulletBone);
}
simulated function Notify_ClipOut()
{
	Super.Notify_ClipOut();

	if(MagAmmo < 2)
		SetBoneScale(6,0.0,BulletBone);
}


/*
// A grenade has just been picked up. Loads one in if we're empty
function GrenadePickedUp ()
{
	if (Ammo[1].AmmoAmount == 0)
	{
		if (Instigator.Weapon == self)
			LoadGrenadeLoop();
		else
			BulldogSecondaryFire(FireMode[1]).bLoaded=true;
	}
	if (!Instigator.IsLocallyControlled())
		ClientGrenadePickedUp();
}

simulated function ClientGrenadePickedUp()
{
	if (Ammo[1].AmmoAmount == 0)
	{
		if (ClientState == WS_ReadyToFire)
			LoadGrenadeLoop();
		else
			BulldogSecondaryFire(FireMode[1]).bLoaded=true;
	}
}*/

simulated function bool IsGrenadeLoaded()
{
	return BulldogSecondaryFire(FireMode[1]).bLoaded;
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	if (Instigator != None && AIController(Instigator.Controller) != None)
	{
		AimSpread *= 0.30;
		ChaosAimSpread *= 0.30;
	}
	VisGrenades=Grenades;
	ShellIndex = FMin(Grenades-1, 5);
	super.BringUp(PrevWeapon);


}
simulated event AnimEnd (int Channel) //=========================================================================
{
    local name anim;
    local float frame, rate;

    GetAnimParams(0, anim, frame, rate);
	if (anim == GrenadeLoadAnim)
	{
		IdleTweenTime=0.0;
		PlayIdle();
	}
	else
		IdleTweenTime=default.IdleTweenTime;
	if (Anim == FireMode[1].FireAnim && bNeedCock)
	{
		bPreventReload=false;
		if(bNeedCock && MagAmmo > 0)
			ClientCockGun(1);
	}
	if (Anim == 'Fire' || Anim == 'ReloadEmpty')
	{
		if (MagAmmo - BFireMode[0].ConsumedLoad < 2) //If we shot our last bullet, hide them!
		{
			SetBoneScale(6,0.0,BulletBone);
		}
	}
//	if (Anim == FireMode[1].FireAnim && !BulldogSecondaryFire(FireMode[1]).bLoaded)
//	{
//		LoadGrenadeLoop();
//		return;
//	}

	if (ReloadState == RS_PostShellIn)
	{
		if (Grenades == 6 || Ammo[1].AmmoAmount == 0)
		{
			PlayShovelEnd();
			ReloadState = RS_EndShovel;
			return;
		}
		ReloadState = RS_Shovel;
		PlayShovelLoop();
		return;
	}

	if (bReady || CurrentWeaponMode == 3)
		IdleAnim='IdleAlt';
	else
		IdleAnim='Idle';

	Super.AnimEnd(Channel);


}

// Load in a grenade
simulated function LoadGrenadeLoop()
{
	if (Ammo[1].AmmoAmount < 1 && Grenades > 6)
		return;
	if ((ReloadState == RS_None || ReloadState == RS_StartShovel)&& Ammo[1].AmmoAmount >= 1)
	{
		PlayAnim(GrenLoadStartAnim, 1.0, , 0);
		ReloadState = RS_StartShovel;
	}
}

simulated function CommonStartReload (optional byte i)
{
	local int m;
	if (ClientState == WS_BringUp)
		ClientState = WS_ReadyToFire;
	if (i == 1)
	{
		ReloadState = RS_StartShovel;
		PlayReloadAlt();
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

simulated function PlayReloadAlt()
{
	SafePlayAnim(StartShovelAnim, StartShovelAnimRate, , 0, "RELOAD");
}



function ServerStartReload (optional byte i)
{
	local int m;

	if (bPreventReload)
		return;
	if (ReloadState != RS_None)
		return;
	if (MagAmmo >= default.MagAmmo && (Ammo[1].AmmoAmount < 1 || Grenades >= 6)) //Pri Full - Alt Can't
		return;

	if (Grenades >= 6 && Ammo[0].AmmoAmount < 1) //Can't reload pri
		return;
	if (Ammo[0].AmmoAmount < 1 && Ammo[1].AmmoAmount < 1) //Can't reload any
		return;

	for (m=0; m < NUM_FIRE_MODES; m++)
		if (FireMode[m] != None && FireMode[m].bIsFiring)
			StopFire(m);

	bServerReloading = true;
	if (Grenades < 6 && Ammo[1].AmmoAmount != 0 && (MagAmmo >= default.MagAmmo/2 || Ammo[0].AmmoAmount < 1))
	{
		CommonStartReload(1);	//Server animation
		ClientStartReload(1);
	}
	else
	{
		CommonStartReload(0);	//Server animation
		ClientStartReload(0);	//Client animation
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
function bool BotShouldReloadGrenade ()
{
	if ( (Level.TimeSeconds - Instigator.LastPainTime > 1.0) )
		return true;
	return false;
}

simulated event WeaponTick(float DT)
{

	local int i;
	super.WeaponTick(DT);


//	if (Ammo[1].AmmoAmount < 1)
//		Grenades = 0;
	if (AIController(Instigator.Controller) != None && !IsGrenadeLoaded()&& AmmoAmount(1) > 0 && BotShouldReloadGrenade() && !IsReloadingGrenade())
		LoadGrenadeLoop();

	if (VisGrenades<0)
		VisGrenades=0;
	for(i=5;i>=VisGrenades;i--)
		SetBoneScale(i, 0.0, Shells[i].ShellName);
	if (VisGrenades>5)
		VisGrenades=6;
	for(i=0;i<VisGrenades;i++)
		SetBoneScale(i, 1.0, Shells[i].ShellName);

/*    if (VisGrenades >= 6)
    {
       SetBoneScale(0, 1.0, ShellBone1);
       SetBoneScale(1, 1.0, ShellBone2);
       SetBoneScale(2, 1.0, ShellBone3);
       SetBoneScale(3, 1.0, ShellBone4);
       SetBoneScale(4, 1.0, ShellBone5);
       SetBoneScale(5, 1.0, ShellBone6);
    }
    else if (VisGrenades == 5)
    {
       SetBoneScale(5, 0.0, ShellBone6);
    }
    else if (VisGrenades == 4)
    {
       SetBoneScale(4, 0.0, ShellBone5);
    }
    else if (VisGrenades == 3)
    {
       SetBoneScale(3, 0.0, ShellBone4);
    }
    else if (VisGrenades == 2)
    {
       SetBoneScale(2, 0.0, ShellBone3);
    }
    else if (VisGrenades == 1)
    {
       SetBoneScale(1, 0.0, ShellBone2);
    }
    else if (VisGrenades <= 0)
    {
       SetBoneScale(0, 0.0, ShellBone1);
    }*/
}

simulated function PositionSights ()
{
	super.PositionSights();
	if (SightingPhase <= 0.0 || !bReady)
		SetBoneRotation('Sight', rot(0,0,0));
	else if (SightingPhase >= 1.0  && bReady)
		SetBoneRotation('Sight', rot(0,0,-16384));
	else
		SetBoneRotation('Sight', class'BUtil'.static.RSmerp(SightingPhase, rot(0,0,0), rot(0,0,-16384)));
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
			LoadGrenadeLoop();
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
	Result += (Dist-1000) / 2000;

	return Result;
}
// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return -0.5;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.8;	}
// End AI Stuff =====

//simulated function float ChargeBar()
//{
//	return FClamp(Grenades/default.Grenades, 0, 1);
//}


simulated function PlayShovelLoop()
{
	SafePlayAnim(ShovelAnim, ReloadAnimRate, 0.0, , "RELOAD");
}


defaultproperties
{
     GrenOpenSound=Sound'BallisticSounds2.M50.M50GrenOpen'
     GrenLoadSound=Sound'BallisticSounds2.M50.M50GrenLoad'
     GrenCloseSound=Sound'BallisticSounds2.M50.M50GrenClose'
     CockSoundQuick=Sound'BWBP_SKC_Sounds.Bulldog.Bulldog-CockQuick'
     CockSoundAlt=Sound'BWBP_SKC_Sounds.Bulldog.Bulldog-CockAlt'
     CockSoundAltQ=Sound'BWBP_SKC_Sounds.Bulldog.Bulldog-CockAltQuick'
     GrenadeLoadAnim="SGReloadStart"
     SingleGrenadeLoadAnim="SGReload"
     GrenLoadStartAnim="SGReloadStart"
     GrenLoadEndAnim="SGReloadEnd"
	EndShovelAnim="SGReloadEnd"
	StartShovelAnim="SGReloadStart"
	ShovelAnim="SGReload"
     CockingAnim="Cock"
     AltIdleAnim="IdleAlt"
	SGPrepAnim="SGPrep"
	SGPrepAnimQ="SGCock"
	ReloadAnim="Reload2"
     BulletBone="Bullet1"
     Shells(0)=(ShellName="Shell1")
     Shells(1)=(ShellName="Shell2")
     Shells(2)=(ShellName="Shell3")
     Shells(3)=(ShellName="Shell4")
     Shells(4)=(ShellName="Shell5")
     Shells(5)=(ShellName="Shell6")
	bShowChargingBar=false
     Grenades=6.000000
     PlayerSpeedFactor=0.900000
     PlayerJumpFactor=0.750000
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=1.500000
     BigIconMaterial=Texture'BWBP_SKC_Tex.Bulldog.BigIcon_Bulldog'
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Bullet=True
     SpecialInfo(0)=(Info="120.0;15.0;0.8;70.0;0.75;0.5;0.0")
     BringUpSound=(Sound=Sound'BWBP_SKC_Sounds.Bulldog.Bulldog-Pullout',Volume=1.600000)
     PutDownSound=(Sound=Sound'BWBP_SKC_Sounds.Bulldog.Bulldog-Putaway',Volume=1.400000)
     MagAmmo=8
     CockSound=(Sound=Sound'BWBP_SKC_Sounds.Bulldog.Bulldog-Cock',Volume=1.500000)
     ClipHitSound=(Sound=Sound'BWBP_SKC_Sounds.Bulldog.Bulldog-MagHit')
     ClipOutSound=(Sound=Sound'BWBP_SKC_Sounds.Bulldog.Bulldog-MagOut',Volume=1.000000)
     ClipInSound=(Sound=Sound'BWBP_SKC_Sounds.Bulldog.Bulldog-MagIn',Volume=1.700000)
     ClipInFrame=0.650000
     bCockOnEmpty=True
     bNeedCock=True
     WeaponModes(1)=(ModeName="Laser-Auto",bUnavailable=True,Value=7.000000)
     WeaponModes(2)=(ModeName="Full Auto",ModeID="WM_FullAuto")
     WeaponModes(3)=(ModeName="FRAG-12 Loaded",ModeID="WM_FullAuto",bUnavailable=True)
     WeaponModes(4)=(ModeName="ERROR",ModeID="WM_FullAuto",bUnavailable=True)
     WeaponModes(5)=(ModeName="ERROR",ModeID="WM_FullAuto",bUnavailable=True)
     CurrentWeaponMode=0
//     SightPivot=(Pitch=512)
//     SightOffset=(X=-20.000000,Y=4.500000,Z=7.000000)
     SightPivot=(Pitch=256)
     SightOffset=(X=-30.000000,Y=9.000000,Z=12.500000)
     SightDisplayFOV=40.000000
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.Misc9',pic2=Texture'BallisticUI2.Crosshairs.M50OutA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=0,G=0,R=255,A=192),Color2=(B=0,G=255,R=255,A=255),StartSize1=61,StartSize2=22)
     CrosshairInfo=(SpreadRatios=(X1=0.750000,Y1=0.750000,X2=0.300000,Y2=0.300000))
     GunLength=48.000000
     JumpOffSet=(Pitch=1000,Yaw=-500)
     JumpChaos=0.300000
     AimAdjustTime=0.600000
     ViewAimFactor=0.300000
     ViewRecoilFactor=0.300000
     ChaosDeclineTime=0.450000
     ChaosTurnThreshold=200000.000000
     ChaosSpeedThreshold=1250.000000
     AimSpread=(X=(Min=-720.000000,Max=720.000000),Y=(Min=-750.000000,Max=750.000000))
     ChaosAimSpread=(X=(Min=-3824.000000,Max=3824.000000),Y=(Min=-750.000000,Max=3824.000000))
     RecoilYawFactor=0.450000
     RecoilPitchFactor=1.000000
     RecoilXFactor=0.450000
     RecoilYFactor=0.450000
     RecoilMax=4096.000000
     RecoilDeclineTime=0.700000
     RecoilDeclineDelay=0.100000
     FireModeClass(0)=Class'BWBP_SKC_Fix.BulldogPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.BulldogSecondaryFire'
     PutDownTime=0.900000
     BringUpTime=0.900000
     SelectForce="SwitchToAssaultRifle"
     Description="R20 Bulldog .75 Assault Cannon||Manufacturer: Black & Wood|Primary: .75 BOLT Rounds|Secondary: FRAG-12 Grenade||In the large universe of guns, Black & Wood's R20 Bulldog is a cannon. In keeping up with their excellent reputation, Black & Wood's Bulldog was designed as an extremely reliable and high powered dual-feed munition launcher. Capable of punching a 2 foot hole in the toughest of Cryon grunts at 50 yards and shattering enemy structures with relative ease, the massive .75 caliber BOLT rounds devastate anything they smash into. Designated 'thermoBaric Ordinance, Lead Trajectory', the acronym desicribes the payload and trajectory of the massive primary munition of the Bulldog. The secondary ammo feed can be chambered with a number of different 20mm rounds, but the preferred shells are an adaption of the potent FRAG-12 explosive slugs, used for ripping a hole in thicker armor to allow the BOLT rounds to finish the job."
     Priority=162
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=6
     GroupOffset=13
     PickupClass=Class'BWBP_SKC_Fix.BulldogPickup'
//     PlayerViewOffset=(X=11.000000,Y=2.000000,Z=-6.000000)
     PlayerViewOffset=(X=22.000000,Y=3.000000,Z=-12.000000)
     BobDamping=1.600000
     AttachmentClass=Class'BWBP_SKC_Fix.BulldogAttachment'
     IconMaterial=Texture'BWBP_SKC_Tex.Bulldog.SmallIcon_Bulldog'
     IconCoords=(X2=127,Y2=31)
     ItemName="Bulldog .75 Assault Cannon"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=4.000000
     Mesh=SkeletalMesh'BWBP_SKC_Anim.BulldogFP'
     DrawScale=0.400000
//     DrawScale=0.200000
}
