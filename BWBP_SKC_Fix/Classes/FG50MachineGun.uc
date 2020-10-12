//=============================================================================
// FG50MachineGun.
//
// Yeah. Good luck aiming this thing. It weighs more than the X83 and that says
// something. Fires full length 50 cals instead of whatever the M925 fires, so
// it packs one hell of a punch.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class FG50MachineGun extends BallisticCamoWeapon;

var   Emitter		LaserDot;
var   LaserActor	Laser;
var() Sound			LaserOnSound;
var() Sound			LaserOffSound;
var   bool			bLaserOn;
var   FG50Heater		Heater;
var   float				HeatLevel;

var() name		ScopeBone;			// Bone to use for hiding scope
var name			BulletBone; //What it says on the tin

var	int	NumpadYOffset1; //Ammo tens
var	int	NumpadYOffset2; //Ammo ones
//var	int	NumpadYOffset3; //RoF 100s
//var	int	NumpadYOffset4; //RoF 10s
//var	int	NumpadYOffset5; //RoF 1s
var() ScriptedTexture WeaponScreen;

var() Material	Screen;
var() Material	ScreenBaseX;
var() Material	ScreenBase1; //Norm
var() Material	ScreenBase2; //Stabilized
var() Material	ScreenBase3; //Empty
var() Material	ScreenBase4; //Stabilized + Empty
var() Material	ScreenRedBar; //Red crap for the heat bar
var() Material	Numbers;
var protected const color MyFontColor; //Why do I even need this?

replication
{
	reliable if (Role == ROLE_Authority)
		ClientSwitchCannonMode, ClientScreenStart, bLaserOn;
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



//=================================
// "Camouflage"
//=================================


simulated function AdjustCamoProperties(optional int Index)
{
	local float f;

		f = FRand();
		if ( (Index == -1 && f > 0.95) || Index == 3) //No holosight
		{
			CamoIndex=3;
			if (bAllowCamoEffects)
			{
				SetBoneScale (0, 0.0, ScopeBone);
				SightOffset = vect(0,25,8.2);
			}
		}
		else if ( (Index == -1 && f > 0.90) || Index == 2) //Green Sights
		{
			Skins[4]=CamoMaterials[2];
			CamoIndex=2;
		}
		else if ( (Index == -1 && f > 0.85) || Index == 1) //Blue Sights
		{
			Skins[4]=CamoMaterials[1];
			CamoIndex=1;
		}
		else
		{
			CamoIndex=0;
			SetBoneScale (0, 1.0, ScopeBone);
			SightOffset = default.SightOffset;
			SightPivot.Pitch = default.SightPivot.Pitch;
		}
}


//========================== AMMO COUNTER NON-STATIC TEXTURE ============



simulated function ClientScreenStart()
{
	ScreenStart();
}
// Called on clients from camera when it gets to postnetbegin
simulated function ScreenStart()
{
	if (Instigator.IsLocallyControlled())
		WeaponScreen.Client = self;
	Skins[3] = Screen; //Set up scripted texture.
	UpdateScreen();//Give it some numbers n shit
	if (Instigator.IsLocallyControlled())
		WeaponScreen.Revision++;
}

simulated function Destroyed()
{
	if (Instigator != None && AIController(Instigator.Controller) == None)
		WeaponScreen.client=None;
	default.bLaserOn = false;
	if (Laser != None)
		Laser.Destroy();
	if (LaserDot != None)
		LaserDot.Destroy();
	if (Heater != None)
		Heater.Destroy();
	Super.Destroyed();
	
}

simulated event RenderTexture( ScriptedTexture Tex )
{
	Tex.DrawTile(0,0,256,128,0,0,256,128,ScreenBaseX, MyFontColor); //Basic screen

	Tex.DrawTile(0,45,70,70,45,NumpadYOffset1,50,50,Numbers, MyFontColor); //Ammo
	Tex.DrawTile(20,45,70,70,40,NumpadYOffset2,50,50,Numbers, MyFontColor);


//	Tex.DrawTile(80,40,40,40,30,NumpadYOffset1,50,50,Numbers, MyFontColor); //Ammo old
//	Tex.DrawTile(100,40,40,40,30,NumpadYOffset2,50,50,Numbers, MyFontColor);

//	Tex.DrawTile(70,80,40,40,30,NumpadYOffset3,50,50,Numbers, MyFontColor);//ROF
//	Tex.DrawTile(90,80,40,40,30,NumpadYOffset4,50,50,Numbers, MyFontColor);
//	Tex.DrawTile(110,80,40,40,30,NumpadYOffset5,50,50,Numbers, MyFontColor);

	Tex.DrawTile(75,110,HeatLevel*180,10,5,5,10,10,ScreenRedBar, MyFontColor);//HEAT
	
}
	
simulated function UpdateScreen()
{
//	local int ROF;
//	ROF = int(60/BallisticInstantFire(FireMode[0]).FireRate);
	if (Instigator != None && AIController(Instigator.Controller) != None) //Bots cannot update your screen
		return;


/*		if (ROF >= 100)
		{
			NumpadYOffset3=(5+(ROF/100)*49); //Hundreds place
			NumpadYOffset4=(5+(ROF/10 % 10)*49);  //Tens place
			NumpadYOffset5=(5+((ROF%100)%10)*49);  //Ones place
		}
		else if (ROF >= 10)
		{
			NumpadYOffset3=(5);
			NumpadYOffset4=(5+(ROF/10)*49);
			NumpadYOffset5=(5+(ROF%10)*49);
		}
		else if (ROF >= 0)
		{
			NumpadYOffset3=(5);
			NumpadYOffset4=(5);
			NumpadYOffset5=(5+ROF*49);
		}
		else
		{
			NumpadYOffset3=(5);
			NumpadYOffset4=(5);
			NumpadYOffset5=(5);
		} */

	if (Instigator.IsLocallyControlled())
	{
			WeaponScreen.Revision++;
	}
}
	
// Consume ammo from one of the possible sources depending on various factors
simulated function bool ConsumeMagAmmo(int Mode, float Load, optional bool bAmountNeededIsMax)
{
	if (bNoMag || (BFireMode[Mode] != None && BFireMode[Mode].bUseWeaponMag == false))
		ConsumeAmmo(Mode, Load, bAmountNeededIsMax);
	else
	{
		if (MagAmmo < Load)
			MagAmmo = 0;
		else
			MagAmmo -= Load;
	}
	UpdateScreen();
	return true;
}




//=====================================================================


function ServerSwitchLaser(bool bNewLaserOn)
{
	bLaserOn = bNewLaserOn;
	bUseNetAim = default.bUseNetAim || bScopeView || bLaserOn;
	if (ThirdPersonActor!=None)
		FG50Attachment(ThirdPersonActor).bLaserOn = bLaserOn;
	if (bLaserOn)
		AimAdjustTime = default.AimAdjustTime * 1.5;
	else
		AimAdjustTime = default.AimAdjustTime;
    if (Instigator.IsLocallyControlled())
		ClientSwitchLaser();
}

simulated function ClientSwitchLaser()
{
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
	bUseNetAim = default.bUseNetAim || bScopeView || bLaserOn;
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

simulated function BringUp(optional Weapon PrevWeapon)
{

	if (Instigator != None && AIController(Instigator.Controller) != None) //Bot Accuracy++
	{
		AimSpread *= 0.30;
		ChaosAimSpread *= 0.20;
	}
	else if (Instigator != None && AIController(Instigator.Controller) == None) //Player Screen ON
	{
		ScreenStart();
		if (!Instigator.IsLocallyControlled())
			ClientScreenStart();
	}




	Super.BringUp(PrevWeapon);
	if (Instigator != None && Laser == None && PlayerController(Instigator.Controller) != None)
		Laser = Spawn(class'BallisticFix.LaserActor');
	if (Instigator != None && LaserDot == None && PlayerController(Instigator.Controller) != None)
		SpawnLaserDot();

	if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
	{
		IdleAnim = 'Idle';
		ReloadAnim = 'Reload';
	}
	else
	{
		IdleAnim = 'Idle';
		ReloadAnim = 'ReloadEmpty';
	}

	if ( ThirdPersonActor != None )
		FG50Attachment(ThirdPersonActor).bLaserOn = bLaserOn;
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

simulated function bool PutDown()
{
	if (Super.PutDown())
	{
		KillLaserDot();
		if (ThirdPersonActor != None)
			FG50Attachment(ThirdPersonActor).bLaserOn = false;
		return true;
	}
	return false;
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

	if (CurrentWeaponMode == 0)
	{
		if (MagAmmo == 0)
			ScreenBaseX=ScreenBase4;
		else
			ScreenBaseX=ScreenBase2;
	}
	else
	{
		if (MagAmmo == 0)
			ScreenBaseX=ScreenBase3;
		else
			ScreenBaseX=ScreenBase1;
	}
	
	NumpadYOffset1=(5+(MagAmmo/10)*49);
	NumpadYOffset2=(5+(MagAmmo%10)*49);


	if (Instigator.IsLocallyControlled())
	{
		WeaponScreen.Revision++;
	}

	super.RenderOverlays(Canvas);
	if (!IsInState('Lowered'))
		DrawLaserSight(Canvas);
}


function ServerUpdateLaser(bool bNewLaserOn)
{
	bUseNetAim = default.bUseNetAim || bScopeView || bNewLaserOn;
}

function ServerSwitchWeaponMode (byte newMode)
{
	super.ServerSwitchWeaponMode (newMode);
	if (!Instigator.IsLocallyControlled())
		FG50PrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);

	ClientSwitchCannonMode (CurrentWeaponMode);
	if (CurrentWeaponMode==0)
	{
			if (SafePlayAnim(IdleAnim, 1.0))
				FreezeAnimAt(0.0);
			IdleAnimRate=0;
			bLaserOn=true;
	}
	else
	{
			IdleAnimRate=0.8;
			bLaserOn=false;
	}

	if (Role == ROLE_Authority)
		ServerSwitchlaser(bLaserOn);
	bUseNetAim = default.bUseNetAim || bScopeView || bLaserOn;
	ServerUpdateLaser(bLaserOn);
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
				SightingPhase += DT/0.40;
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
				SightingPhase -= DT/0.40;
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

//Kaboodles' neat idle anim fix.
simulated function PlayIdle()
{
	if (BFireMode[0].IsFiring())
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
		if(SafePlayAnim(ZoomOutAnim, 1.0))
			FreezeAnimAt(0.0);
	}
	else
	    SafeLoopAnim(IdleAnim, IdleAnimRate, IdleTweenTime, ,"IDLE");
}

simulated function ClientSwitchCannonMode (byte newMode)
{
	FG50PrimaryFire(FireMode[0]).SwitchCannonMode(newMode);
	UpdateScreen();
}


//Draw special weapon info on the hud
simulated function NewDrawWeaponInfo(Canvas C, float YPos)
{
	if (bLaserOn)	{
		CrosshairCfg.Color1.A = 0;
		CrosshairCfg.Color2.A /= 2;
	}
	Super.NewDrawWeaponInfo (C, YPos);

	if (bLaserOn)	{
		CrosshairCfg.Color1.A = default.CrosshairCfg.Color1.A ;
		CrosshairCfg.Color2.A = default.CrosshairCfg.Color2.A ;
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


simulated event Tick (float DT)
{
	super.Tick(DT);
	if (HeatLevel > 0 && (LastFireTime < level.TimeSeconds - 4 || CurrentWeaponMode == 0))
		HeatLevel = FMax(0, HeatLevel - DT/10);
}

simulated event WeaponTick(float DT)
{
	super.WeaponTick(DT);
	if (FireMode[0].IsFiring() && CurrentWeaponMode != 0 && MagAmmo > 0)
		HeatLevel = FMin(1, HeatLevel + DT/15);
	if (Heater != None)
		Heater.SetHeat(HeatLevel);



}

//*
//
//
//
//
//TURRET CODE GOES HERE


function InitWeaponFromTurret(BallisticTurret Turret)
{
	bNeedCock = false;
	Ammo[0].AmmoAmount = Turret.AmmoAmount[0];
	if (!Instigator.IsLocallyControlled())
		ClientInitWeaponFromTurret(Turret);
}
simulated function ClientInitWeaponFromTurret(BallisticTurret Turret)
{
	bNeedCock=false;
}


simulated function TickAim(float DT)
{
	Super(BallisticWeapon).TickAim(DT);
}


// Animation notify for when the clip is stuck in
simulated function Notify_ClipUp()
{
	SetBoneScale(1,1.0,BulletBone);
}


simulated function Notify_ClipOut()
{
	Super.Notify_ClipOut();

	if(MagAmmo < 2)
		SetBoneScale(1,0.0,BulletBone);
}



// Animation notify for when the clip is stuck in
simulated function Notify_ClipIn()
{
	local int AmmoNeeded;

	if (ReloadState == RS_None)
		return;
	ReloadState = RS_PostClipIn;
	PlayOwnedSound(ClipInSound.Sound,ClipInSound.Slot,ClipInSound.Volume,ClipInSound.bNoOverride,ClipInSound.Radius,ClipInSound.Pitch,ClipInSound.bAtten);
	if (level.NetMode != NM_Client)
	{
		AmmoNeeded = default.MagAmmo-MagAmmo;
		if (AmmoNeeded > Ammo[0].AmmoAmount)
			MagAmmo+=Ammo[0].AmmoAmount;
		else
			MagAmmo = default.MagAmmo;
		Ammo[0].UseAmmo (AmmoNeeded, True);
	}
	UpdateScreen();
}

function Notify_Deploy()
{
	local vector HitLoc, HitNorm, Start, End;
	local actor T;
	local Rotator CompressedEq;
    local BallisticTurret Turret;
    local float Forward;

	if (Role < ROLE_Authority)
		return;
	if (Instigator.HeadVolume.bWaterVolume)
		return;
	// Trace forward and then down. make sure turret is being deployed:
	//   on world geometry, at least 30 units away, on level ground, not on the other side of an obstacle
	Start = Instigator.Location + Instigator.EyePosition();
	for (Forward=75;Forward>=45;Forward-=15)
	{
		End = Start + vector(Instigator.Rotation) * Forward;
		T = Trace(HitLoc, HitNorm, End, Start, true, vect(6,6,6));
		if (T != None && VSize(HitLoc - Start) < 30)
			return;
		if (T == None)
			HitLoc = End;
		End = HitLoc - vect(0,0,100);
		T = Trace(HitLoc, HitNorm, End, HitLoc, true, vect(6,6,6));
		if (T != None && T.bWorldGeometry && HitNorm.Z >= 0.7 && FastTrace(HitLoc, Start))
			break;
		if (Forward <= 45)
			return;
	}

	FireMode[1].bIsFiring = false;
   	FireMode[1].StopFiring();

	HitLoc.Z += class'BWBP_SKC_Fix.FG50Turret'.default.CollisionHeight - 9;

//Rotator compression causes disparity between server and client rotations,
//which then plays hob with the turret's aim.
//Do the compression first then use that to spawn the turret.

if(Level.NetMode == NM_DedicatedServer)
{
CompressedEq = Instigator.Rotation;
CompressedEq.Pitch = (CompressedEq.Pitch >> 8) & 255;
CompressedEq.Yaw = (CompressedEq.Yaw >> 8) & 255;
CompressedEq.Pitch = (CompressedEq.Pitch << 8);
CompressedEq.Yaw = (CompressedEq.Yaw << 8);

Turret = Spawn(class'BWBP_SKC_Fix.FG50Turret', None,, HitLoc, CompressedEq);
}

else Turret = Spawn(class'BWBP_SKC_Fix.FG50Turret', None,, HitLoc, Instigator.Rotation);

    if (Turret != None)
    {
		Turret.InitDeployedTurretFor(self);
//		PlaySound(DeploySound, Slot_Interact, 0.7,,64,1,true);
		Turret.TryToDrive(Instigator);
		Destroy();
    }
    else
		log("Notify_Deploy: Could not spawn turret for X82Rifle");
}



function ServerWeaponSpecial(optional byte i)
{

/*
   		if (BallisticTurret(Instigator) != None)
		{
			PlayAnim('Undeploy');
		}
    		if (ReloadState != RS_None)
		{
      		log("Barrett Deployment Failed = Reload");
      		return;
		}
		if (BallisticTurret(Instigator) == None && Instigator.HeadVolume.bWaterVolume)
		{
			log("Barrett Deployment Failed = Water");
      		return;
		}
//    	if (Clientstate != WS_ReadyToFire)
//		{
//    		log("Barrett Deployment Failed = Fire not ready");
//      		return;
//      	}
      	log("FG50 Deployment Success");
      	Notify_Deploy(); */
}



//T CODE ENDS HERE
//
//
//
//*/
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
	 MyFontColor=(R=255,G=255,B=255,A=255)
	 Numbers=Texture'BWBP_SKC_TexExp.PUMA.PUMA-Numbers'
	 ScreenBase1=Texture'BWBP_SKC_TexExp.FG50.FG50-Screen'
	 ScreenBase2=Texture'BWBP_SKC_TexExp.FG50.FG50-Screen2'

	 ScreenBase3=Texture'BWBP_SKC_TexExp.FG50.FG50-Screen3'
	 ScreenBase4=Texture'BWBP_SKC_TexExp.FG50.FG50-Screen4'
	 ScreenRedBar=Texture'BWBP_SKC_TexExp.M2020.M2020-ScreenOff'
	RecoilDeclineTime=2.2
	RecoilMax=2800
	ViewAimScale=2
	ViewRecoilScale=2

     	ChaosDeclineTime=1.500000
     	RecoilDeclineDelay=0.3
     	ReloadAnimRate=1.00
     	Screen=Shader'BWBP_SKC_TexExp.FG50.FG50-ScriptLCD-SD'
     	WeaponScreen=ScriptedTexture'BWBP_SKC_TexExp.FG50.FG50-ScriptLCD'
        IdleAnimRate=0.600000
     AIRating=0.600000
     AIReloadTime=1.000000
     AttachmentClass=Class'BWBP_SKC_Fix.FG50Attachment'

     BallisticInventoryGroup=6
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     BigIconMaterial=Texture'BWBP_SKC_TexExp.FG50.BigIcon_FG50'
     bNeedCock=True
     bNoCrosshairInScope=True
     BobDamping=2.000000
     BringUpSound=(Sound=Sound'BallisticSounds2.M50.M50Pullout')
     BulletBone="Bullet"
     bWT_Bullet=True
     CamoMaterials[0]=FinalBlend'BWBP_SKC_Tex.SKS650.SRS-HSight-FB'
     CamoMaterials[1]=FinalBlend'BWBP_SKC_Tex.SKS650.SRS-BSight-FB'
     CamoMaterials[2]=FinalBlend'BWBP_SKC_Tex.SKS650.SRS-GSight-FB'
     CamoMaterials[3]=Texture'ONSstructureTextures.CoreGroup.Invisible'
     ClipInFrame=0.650000
     ClipInSound=(Sound=Sound'BWBP_SKC_SoundsExp.AS50.FG50-DrumIn',Volume=1.500000)
     ClipOutSound=(Sound=Sound'BWBP_SKC_SoundsExp.AS50.FG50-DrumOut',Volume=1.500000)
     CockAnimPostReload="ReloadEndCock"
     CockSound=(Sound=Sound'BWBP_SKC_SoundsExp.AS50.FG50-Cock',Volume=2.500000)
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.M806InA',pic2=Texture'BallisticUI2.Crosshairs.M353OutA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=0,G=0,R=0,A=255),Color2=(B=67,G=66,R=58,A=255),StartSize1=99,StartSize2=86)
     CrouchAimFactor=0.100000
     CurrentRating=0.600000
     CurrentWeaponMode=2
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     Description="FG50 Heavy Machine Gun||Manufacturer: NDTR Industries|Primary: Automatic .50 Fire|Secondary: Holosight|Special: Laser Sight||The FG50 Heavy Machine Gun is a specialized .50 caliber weapon designed for use on automated weapons platforms and vehicles. Built under contract for the UTC, the NDTR FG50 is the primary weapon for many light assault vehicles and combat drones. An infantry version was developed for UTC's Sub-Orbital Insertion Troops as a high powered combat rifle, after complaints that the current M925 was too bulky to carry and store in Armored Insertion Pods and that the MG33 simply did not pack the punch required to stop a charging Skrith.||Hunter-killer SOIT teams swear by the FG50 now, and praise its ability to fire with precision and accuracy. However ask any veteran and you'll hear many stories about those who disrespected the power of the weapon and foolishly ended up with broken arms and damaged prides. The HMG is not a weapon to toy with."
     DrawScale=0.500000
     FireModeClass(0)=Class'BWBP_SKC_Fix.FG50PrimaryFire'
     FireModeClass(1)=Class'BCoreFix.BallisticScopeFire'
     FullZoomFOV=60.000000
     IconCoords=(X2=127,Y2=31)
     IconMaterial=Texture'BWBP_SKC_TexExp.FG50.SmallIcon_FG50'
     InventoryGroup=6
     InventorySize=40
     ItemName="FG50 Heavy Machine Gun"
     LaserOffSound=Sound'BallisticSounds2.M806.M806LSight'
     LaserOnSound=Sound'BallisticSounds2.M806.M806LSight'
     LightBrightness=150.000000
     LightEffect=LE_NonIncidence
     LightHue=30
     LightRadius=4.000000
     LightSaturation=150
     LightType=LT_Pulse
     MagAmmo=40
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.FG50_FP'
     PickupClass=Class'BWBP_SKC_Fix.FG50Pickup'
     PickupTextureIndex=1
     PlayerJumpFactor=0.750000
     PlayerSpeedFactor=0.890000
     PlayerViewOffset=(X=5.000000,Y=-7.000000,Z=-8.000000)
     Priority=65
     AimSpread=(X=(Min=-32.000000,Max=32.000000),Y=(Min=-32.000000,Max=32.000000))
     PutDownSound=(Sound=Sound'BallisticSounds2.M50.M50Putaway')
     PutDownTime=0.700000
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=-0.100000),(InVal=0.300000,OutVal=-0.200000),(InVal=1.000000,OutVal=-0.300000)))
     RecoilXFactor=0.300000
     RecoilYawFactor=0.300000
     RecoilYCurve=(Points=(,(InVal=0.250000,OutVal=0.500000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYFactor=0.300000
     ScopeBone="Holosight"
     SelectForce="SwitchToAssaultRifle"
     SightOffset=(X=-5.000000,Y=25.000000,Z=10.300000)
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Texture'BWBP_SKC_TexExp.FG50.FG50-Main'
     Skins(2)=Texture'BWBP_SKC_TexExp.FG50.FG50-Misc'
     Skins(3)=Texture'BWBP_SKC_TexExp.FG50.FG50-Screen'
     Skins(4)=FinalBlend'BWBP_SKC_Tex.SKS650.SRS-HSight-FB'
     SpecialInfo(0)=(Info="320.0;35.0;1.0;100.0;0.8;0.5;0.1")
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     ViewAimFactor=0.300000
     ViewRecoilFactor=0.700000
     WeaponModes(0)=(ModeName="Controlled")
     WeaponModes(1)=(bUnavailable=True)
//	RecoilMax=1600
//   PlayerJumpFactor=0.800000
//   PlayerSpeedFactor=0.850000
}
