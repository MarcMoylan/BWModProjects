//=============================================================================
// AK47BattleRifle.
//
// A powerful 7.62mm powerhouse. Fills a similar role to the CYLO UAW, albiet is
// far more reliable and has a launchable bayonet in place of the shotgun.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AK47AssaultRifle extends BallisticCamoWeapon;

var   Emitter		LaserDot;
var   bool			bLaserOn;
var bool		bFirstDraw;
var() name		GrenadeLoadAnim;	//Anim for grenade reload
var   bool		bLoaded;

var() name		GrenBone;	//Pretend that grenade == knife!
var() name		GrenBoneBase;
var() Sound		GrenLoadSound;		
var() Sound		GrenFireSound;		
var() Sound		GrenDropSound;			

var   bool			bThrowingKnife; //knife stuff
var() name			KnifeBackAnim;
var() name			KnifeThrowAnim;
var   float			NextThrowTime;

var name			BulletBone;
var name			BulletBone2;


replication
{
	reliable if(Role == ROLE_Authority)
		ClientAttachKnife, ClientLaunchKnife;
}

//=======================================
//=========== Two Round Burst Code ======
//=======================================

simulated function SetBurstModeProps()
{
	if (CurrentWeaponMode == 1)
	{
		BFireMode[0].FireRate = 0.033;
		BFireMode[0].RecoilPerShot = 256;
		BFireMode[0].FireChaos = 0.05;
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

simulated function TickFireCounter (float DT)
{
    if (CurrentWeaponMode == 1 && level.Netmode == NM_Standalone)
    {
        if (!IsFiring() && FireCount > 0 && FireMode[0].NextFireTime - level.TimeSeconds < -0.15)
            FireCount = 0;
    }
    else
        super.TickFireCounter(DT);
}


//=======================================
//=========== Ballistic Knife Spawning Code
//=======================================

function GiveTo(Pawn Other, optional Pickup Pickup)
{
    local int m;
    local weapon w;
    local bool bPossiblySwitch, bJustSpawned;

    Instigator = Other;
    W = Weapon(Other.FindInventoryType(class));
    if ( W == None || class != W.Class)
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

	if ( (Instigator.Weapon != None) && Instigator.Weapon.IsFiring() )
		bPossiblySwitch = false;

	if ( Instigator.Weapon != W )
		W.ClientWeaponSet(bPossiblySwitch);
		
	//Disable aim for weapons picked up by AI-controlled pawns
	bAimDisabled = default.bAimDisabled || !Instigator.IsHumanControlled();

    if ( !bJustSpawned )
	{
        for (m = 0; m < NUM_FIRE_MODES; m++)
			Ammo[m] = None;
		Destroy();
	}
	
    if ( Instigator.FindInventoryType(class'BCGhostWeapon') != None ) //ghosts are scary
		return;

    if(Instigator.FindInventoryType(class'BWBP_SKC_Fix.X8Knife')==None )
    {
        W = Instigator.Spawn(class'BWBP_SKC_Fix.X8Knife',,,Instigator.Location);
		
        if( W != None)
            W.GiveTo(Instigator);

    }

	if (!bAllowCamo)
		CamoIndex = 0;
	else if (BallisticCamoPickup(Pickup) != None && BallisticCamoPickup(Pickup).CamoIndex != -1)
		CamoIndex = BallisticCamoPickup(Pickup).CamoIndex;
	
	AdjustCamoProperties(CamoIndex);
	ClientAdjustCamoProperties(CamoIndex);
}

simulated function DrawWeaponInfo(Canvas C)
{
	NewDrawWeaponInfo(C, 0.705*C.ClipY);
}

simulated function NewDrawWeaponInfo(Canvas C, float YPos)
{
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
    	if(bLoaded) //Put some freaking knives on the freaking hud
    	{
		C.SetPos(C.ClipX - (2.5) * ScaleFactor2, C.ClipY - 110 * ScaleFactor * class'HUD'.default.HudScale);
		C.DrawTile( Texture'BWBP_SKC_TexExp.AK490.AK490-KnifeIcon',ScaleFactor2*2, ScaleFactor2, 0, 0, 256, 128);
	}
}

simulated event AnimEnd (int Channel)
{
    local name anim;
    local float frame, rate;

    GetAnimParams(0, anim, frame, rate);

	if (anim == 'KnifeFire' && bThrowingKnife)
		return;
	if (Anim == GrenadeLoadAnim && Role == ROLE_Authority)
		bServerReloading=false;
	if (Anim == 'Fire' || Anim == 'KnifeFire' || Anim == 'ReloadEmpty')
	{
		if (MagAmmo - BFireMode[0].ConsumedLoad < 2)
		{
			SetBoneScale(2,0.0,BulletBone);
			SetBoneScale(3,0.0,BulletBone2);
		}
	}
	super.AnimEnd(Channel);
}

//11032013 - Azarael - Reload dependent on byte sent
//Reload Ballistic Knives with Reload
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
	if (!bLoaded && Ammo[1].AmmoAmount > 0)
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

//11032013 - Azarael - Reworked WS and SWS
exec simulated function WeaponSpecial(optional byte i)
{
	ServerWeaponSpecial(i);
}

function ServerWeaponSpecial(optional byte i)
{
	if (IsFiring() || ReloadState != RS_None)
		return;

	if (!bLoaded)
	{
		if (Ammo[1].AmmoAmount < 1)
			return;
		if (ReloadState == RS_None)
		{
			PlayAnim(GrenadeLoadAnim, 1.1, , 0);
			ReloadState = RS_PreClipOut;
		}
		if (!Instigator.IsLocallyControlled())
			ClientAttachKnife();
		return;
	}
	
	if (Level.TimeSeconds < NextThrowTime || bThrowingKnife || ReloadState != RS_None)
		return;
	
	PlaySound(GrenFireSound, SLOT_Misc,1.5,,32,,);
	PlayAnim('KnifeFire');
	bThrowingKnife=true;
	if (!Instigator.IsLocallyControlled())
		ClientLaunchKnife();
}

simulated function ClientLaunchKnife()
{
	PlayAnim('KnifeFire');
	bThrowingKnife=true;
}

simulated function ClientAttachKnife()
{
	if (ReloadState == RS_None)
	{
		PlayAnim(GrenadeLoadAnim, 1.1, , 0);
		ReloadState = RS_PreClipOut;
	}
	if (SightingState != SS_None)
		TemporaryScopeDown(Default.SightingTime*Default.SightingTimeScale);
}

simulated function Notify_BladeLaunch()
{
	SetBoneScale(0, 0.0, GrenBone);
	ThrowKnife();
}

simulated function Notify_BladeDrop()
{	
	PlaySound(GrenDropSound, SLOT_Misc,1.5,,32,,);
	ReloadState = RS_PreClipIn;
}

simulated function Notify_BladeAppear()
{
	SetBoneScale(0, 1.0, GrenBone);
	SetBoneScale(1, 1.0, GrenBoneBase);
}
simulated function Notify_BladeLoaded()	
{
    local Inventory Inv;
	
	bLoaded = true;	
	PlaySound(GrenLoadSound, SLOT_Misc,1.5,,32,,);

	if (Role == Role_Authority)
	{
		Ammo[1].UseAmmo(1, True);
		if (Ammo[1].AmmoAmount == 0)
		{
			for ( Inv=Instigator.Inventory; Inv!=None; Inv=Inv.Inventory ) //Destroy X8 Knife weapon if empty
				if (X8Knife(Inv) != None)
				{
					X8Knife(Inv).RemoteKill();	
					break;	
				}
		}
	}
	AK47SecondaryFire(FireMode[1]).SwitchBladeMode(bLoaded);
}

simulated function Notify_BladeReady()	
{
	ReloadState = RS_None; 
}

simulated function ThrowKnife()
{
	bThrowingKnife=false;
	bLoaded=False;
	NextThrowTime = Level.TimeSeconds + 0.15;

	if (Role == ROLE_Authority)
		DoFireEffect();

	AK47SecondaryFire(FireMode[1]).SwitchBladeMode(bLoaded);
}

// Get aim then spawn projectile
function DoFireEffect()
{
    local Vector StartTrace, X, Y, Z, Start, End, HitLocation, HitNormal;
    local Rotator RAim;
	local actor Other;
	local Projectile Proj;

    GetViewAxes(X,Y,Z);
    // the to-hit trace always starts right in front of the eye
    Start = Instigator.Location + Instigator.EyePosition();
    StartTrace = Start + X*10;
    if (!WeaponCentered())
	    StartTrace = StartTrace + Hand * Y*10 + Z*0;

	RAim = BFireMode[0].GetFireAim(StartTrace);
	RAim = Rotator(BFireMode[0].GetFireSpread() >> RAim);

	End = Start + (Vector(RAim)*2000);
	Other = Trace (HitLocation, HitNormal, End, Start, true);

	if (Other != None)
		RAim = Rotator(HitLocation-StartTrace);

	Proj = Spawn (class'X8Projectile',,, StartTrace, RAim);
	Proj.Instigator = Instigator;
}

//=======================================
//=========== Camouflage
//=======================================

simulated function BringUp(optional Weapon PrevWeapon)
{
	if (Instigator != None && AIController(Instigator.Controller) != None) //Bot accuracy BOOST
	{
		AimSpread *= 0.50;
		ChaosAimSpread *= 0.30;
	}

	if (bFirstDraw && MagAmmo > 0)
	{
     		BringUpTime=2.0;
     		SelectAnim='PulloutFancy';
		bFirstDraw=false;
		bLoaded=True;
	}
	else
	{
     	BringUpTime=default.BringUpTime;
		SelectAnim='Pullout';
	}
	if (bLoaded)
		AK47SecondaryFire(FireMode[1]).SwitchBladeMode(bLoaded);
		
	else
	{
		SetBoneScale (0, 0.0, GrenBone);
		SetBoneScale (1, 0.0, GrenBoneBase);
	}
	
	if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
	{

		SetBoneScale(2,0.0,BulletBone);
		SetBoneScale(3,0.0,BulletBone2);
		ReloadAnim = 'ReloadEmpty';
	}
	
	else
		ReloadAnim = 'Reload';

	super.BringUp(PrevWeapon);
}

simulated function AdjustCamoProperties(optional int Index)
{
	local float f;
		f = FRand();

		if ((Index == -1 && f > 0.99) || Index == 6) // 1%
		{
			Skins[1]=CamoMaterials[6];
			if (bAllowCamoEffects)
			{
				ReloadAnimRate=2;
				CockAnimRate=2;
     				RecoilXFactor		=0.001;
     				RecoilYFactor		=0.001;
     				RecoilYawFactor		=0.001;
     				RecoilPitchFactor	=0.001;
				RecoilDeclineDelay=0;
				RecoilDeclineTime=0.2;
				ChaosDeclineTime=0.2;
			}
			CamoIndex=6;
		}

		else if ((Index == -1 && f > 0.97) || Index == 5) // 2%
		{
			Skins[1]=CamoMaterials[5];
			CamoIndex=5;
		}
		else if ((Index == -1 && f > 0.95) || Index == 4) // 2%
		{
			Skins[1]=CamoMaterials[4];
			CamoIndex=4;
		}
		else if ((Index == -1 && f > 0.90) || Index == 3) // 5%
		{
			Skins[1]=CamoMaterials[3];
			CamoIndex=3;
		}
		else if ((Index == -1 && f > 0.85) || Index == 2) //5%
		{	
			Skins[1]=CamoMaterials[2];
			CamoIndex=2;
		}
		else if ((Index == -1 && f > 0.70) || Index == 1) //10%
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

// Animation notify for when cocking action starts. Used to time sounds
simulated function Notify_CockSim()
{
	PlayOwnedSound(CockSound.Sound,CockSound.Slot,CockSound.Volume,CockSound.bNoOverride,CockSound.Radius,CockSound.Pitch,CockSound.bAtten);
}


simulated function PlayCocking(optional byte Type)
{
	if (Type == 2)
		PlayAnim('ReloadEndCock', CockAnimRate, 0.2);
	else
		PlayAnim(CockAnim, CockAnimRate, 0.2);
}

simulated function PlayReload()
{
    if (MagAmmo < 1)
    {
       ReloadAnim='ReloadEmpty';
    }
    else
    {
       ReloadAnim='Reload';
    }

	SafePlayAnim(ReloadAnim, ReloadAnimRate, , 0, "RELOAD");
}

// Animation notify for when the clip is stuck in
simulated function Notify_ClipUp()
{
	SetBoneScale(2,1.0,BulletBone);
	SetBoneScale(3,1.0,BulletBone2);
}

simulated function Notify_ClipOut()
{
	Super.Notify_ClipOut();

	if(MagAmmo < 1)
	{
		SetBoneScale(2,0.0,BulletBone);
		SetBoneScale(3,0.0,BulletBone2);
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
	if (Result < 0.34)
	{
		if (CurrentWeaponMode != 2)
		{
			CurrentWeaponMode = 2;
		}
	}

	return Result;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return 0.0;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.5;	}
// End AI Stuff =====

defaultproperties
{
	 
	 
     AimSpread=(X=(Min=-128.125000,Max=128.125000),Y=(Min=-128.125000,Max=128.125000))
     AIRating=0.600000
     AIReloadTime=1.000000
     AttachmentClass=Class'BWBP_SKC_Fix.AK47Attachment'
     BallisticInventoryGroup=5
     bCockOnEmpty=False
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bFirstDraw=True
     BigIconMaterial=Texture'BWBP_SKC_TexExp.AK490.BigIcon_AK490'
     bLoaded=True
     bNeedCock=False
     bNoCrosshairInScope=True
     BobDamping=2.000000
     BringUpSound=(Sound=Sound'BallisticSounds2.M50.M50Pullout')

     BringUpTime=0.900000

     BulletBone2="Bullet2"
     BulletBone="Bullet1"
     bWT_Bullet=True
     CamoMaterials[0]=Texture'BWBP_SKC_TexExp.AK490.AK490-Main'
     CamoMaterials[1]=Texture'BWBP_SKC_TexExp.AK490.AK490-C-CamoDesert'// SDescamo.
     CamoMaterials[2]=Texture'BWBP_SKC_TexExp.AK490.AK490-UC-CamoGerman' // Geramo.
     CamoMaterials[3]=Texture'BWBP_SKC_TexExp.AK490.AK490-UC-CamoBlood' // VLOODamo.
     CamoMaterials[4]=Texture'BWBP_SKC_TexExp.AK490.AK490-R-CamoRed' // TRedcamo.
     CamoMaterials[5]=Texture'BWBP_SKC_TexExp.AK490.AK490-R-CamoBlue'// Blueamo.
     CamoMaterials[6]=Shader'BWBP_SKC_TexExp.AK490.GoldAK-Shine' // cGOLDamo.
     ChaosAimSpread=(X=(Min=-1024.000000,Max=1024.000000),Y=(Min=-1024.000000,Max=1024.000000))
     ChaosDeclineTime=0.500000
     ClipHitSound=(Sound=Sound'BWBP_SKC_SoundsExp.AK47.AK47-ClipHit',Volume=3.500000)
     ClipInFrame=0.650000
     ClipInSound=(Sound=Sound'BWBP_SKC_SoundsExp.AK47.AK47-ClipIn',Volume=3.500000)
     ClipOutSound=(Sound=Sound'BWBP_SKC_SoundsExp.AK47.AK47-ClipOut',Volume=3.500000)
     CockAnimPostReload="ReloadEndCock"
     CockSound=(Sound=Sound'BWBP_SKC_SoundsExp.AK47.AK47-Cock',Volume=3.500000)
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.M353OutA',pic2=Texture'BallisticUI2.Crosshairs.M50In',USize1=256,VSize1=256,USize2=128,VSize2=128,Color1=(B=255,G=255,R=255,A=172),Color2=(B=0,G=0,R=255,A=197),StartSize1=71,StartSize2=55)
     CurrentRating=0.600000
     CurrentWeaponMode=2
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     Description="AK-490 Battle Rifle||Manufacturer: Zavod Tochnogo Voorujeniya (ZTV Export)|Primary: 7.62 AP Rounds|Secondary: Stock Smack||Chambering 7.62mm armor piercing rounds, this rifle is a homage to its' distant predecessor, the AK-47. Though the weapons' looks have hardly changed at all, this model features a vastly improved firing mechanism, allowing it to operate in the most punishing of conditions. Equipped with a heavy reinforced stock, launchable ballistic bayonet, and 20 round box mag, this automatic powerhouse is guaranteed to cut through anything in its way. ZVT Exports designed this weapon to be practical and very easy to maintain. With its rugged and reliable design, the AK490 has spread throughout the cosmos and can be found just about anywhere."
     DrawScale=0.350000
     FireModeClass(0)=Class'BWBP_SKC_Fix.AK47PrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.AK47SecondaryFire'
     GrenadeLoadAnim="ReloadKnife"
     GrenBone="KnifeBlade"
     GrenBoneBase="AttachKnife"
     GrenDropSound=Sound'BWBP_SKC_SoundsExp.AK47.Knife-Drop'
     GrenFireSound=Sound'BWBP_SKC_SoundsExp.AK47.AK47-KnifeFire'
     GrenLoadSound=Sound'BWBP_SKC_SoundsExp.AK47.Knife-Load'
     IconCoords=(X2=127,Y2=31)
     IconMaterial=Texture'BWBP_SKC_TexExp.AK490.SmallIcon_AK490'
     IdleAnimRate=0.400000
     InventoryGroup=4
     ItemName="AK-490 Battle Rifle"
     LightBrightness=150.000000
     LightEffect=LE_NonIncidence
     LightHue=30
     LightRadius=4.000000
     LightSaturation=150
     LightType=LT_Pulse
     MagAmmo=20
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.AK490_FP'
     PickupClass=Class'BWBP_SKC_Fix.AK47Pickup'
     PickupTextureIndex=1
     PlayerViewOffset=(X=-4.000000,Y=13.000000,Z=-16.000000)
     Priority=65
     PutDownSound=(Sound=Sound'BallisticSounds2.M50.M50Putaway')
     PutDownTime=0.700000
     RecoilDeclineTime=1.500000
     RecoilMax=1524.000000
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.300000),(InVal=0.800000,OutVal=-0.400000),(InVal=1.000000,OutVal=-0.200000)))
     RecoilXFactor=0.300000
     RecoilYawFactor=0.400000
     RecoilYCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.650000),(InVal=0.600000,OutVal=0.800000),(InVal=0.800000,OutVal=0.900000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYFactor=0.200000
     SelectForce="SwitchToAssaultRifle"
     SightDisplayFOV=20.000000
     SightingTime=0.300000
     SightOffset=(X=-5.000000,Y=-10.020000,Z=20.600000)
     SightPivot=(Pitch=64)
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Texture'BWBP_SKC_TexExp.AK490.AK490-Main'
     Skins(2)=Texture'BWBP_SKC_TexExp.AK490.AK490-Misc'
     SpecialInfo(0)=(Info="320.0;25.0;1.0;110.0;0.5;0.8;0.0")
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     ViewAimFactor=0.200000
     ViewRecoilFactor=0.600000
     WeaponModes(1)=(ModeName="Rapid Burst",Value=2.000000)
//     WeaponModes(0)=(bUnavailable=True,ModeID="WM_None")
//     WeaponModes(1)=(ModeName="Semi-Auto",Value=1.000000)
}
