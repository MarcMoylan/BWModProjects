//=============================================================================
// AS50Rifle.
//
// This is actually not an AS50 so don't get excited.
// Fires bullets that are weaker than the X83, but are more sexy and glowy.
//
// For the record, this gun is even BIGGER than the X83. It's freaking huge.
//
// Uses new code by Azarael to not freeze when using IR view
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AS50Rifle extends BallisticCamoWeapon;
var bool		bRapidFire;			// Mash dat ass

var() name		ScopeBone;			// Bone to use for hiding scope
var name			BulletBone; //What it says on the tin

var() BUtil.FullSound	ThermalOnSound;	// Sound when activating thermal mode
var() BUtil.FullSound	ThermalOffSound;// Sound when deactivating thermal mode
var   Array<Pawn>		PawnList;		// A list of all the potential pawns to view in thermal mode
var() material			WallVisionSkin;	// Texture to assign to players when theyare viewed with Thermal mode
var   bool				bThermal;		// Is thermal mode active?
var   bool				bUpdatePawns;	// Should viewable pawn list be updated
var   Pawn				UpdatedPawns[16];// List of pawns to view in thermal scope
var() material			Flaretex;		// Texture to use to obscure vision when viewing enemies directly through the thermal scope
var() float				ThermalRange;	// Maximum range at which it is possible to see enemies through walls
var   ColorModifier		ColorMod;
var   actor			NVLight;
var   float				NextPawnListUpdateTime;
var() Texture ScopeViewTexThermal;



var	int	NumpadYOffset1; //Ammo tens
var	int	NumpadYOffset2; //Ammo ones
var() ScriptedTexture WeaponScreen;

var() Material	Screen;
var() Material	ScreenBaseX;
var() Material	ScreenBase1; //Norm
var() Material	ScreenBase2; //Stabilized
var() Material	ScreenBase3; //Empty
var() Material	ScreenBase4; //Stabilized + Empty
var() Material	Numbers;
var protected const color MyFontColor; //Why do I even need this?

replication
{

	// functions on server, called by client
   	reliable if( Role<ROLE_Authority )
		ServerAdjustThermal;
	reliable if(Role == ROLE_Authority)
		ClientScreenStart;

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
	Skins[5] = Screen;
	UpdateScreen();//Give it some numbers n shit
	if (Instigator.IsLocallyControlled())
		WeaponScreen.Revision++;
}

simulated event Destroyed()
{
	if (Instigator != None && AIController(Instigator.Controller) == None)
		WeaponScreen.client=None;

	if (ColorMod != None)
	{
		Level.ObjectPool.FreeObject(ColorMod);
		ColorMod = None;
	}
	AdjustThermalView(false);

	if (NVLight != None)
		NVLight.Destroy();
		
	Super.Destroyed();
	
}

simulated event RenderTexture( ScriptedTexture Tex )
{
	Tex.DrawTile(0,0,256,128,0,0,256,128,ScreenBaseX, MyFontColor);

	Tex.DrawTile(0,45,70,70,45,NumpadYOffset1,50,50,Numbers, MyFontColor); //Ammo
	Tex.DrawTile(20,45,70,70,40,NumpadYOffset2,50,50,Numbers, MyFontColor);

	
}
	
simulated function UpdateScreen()
{

	if (Instigator != None && AIController(Instigator.Controller) != None) //Bots cannot update your screen
		return;

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


function ServerSwitchWeaponMode (byte NewMode)
{
	super.ServerSwitchWeaponMode (NewMode);
	UpdateScreen();

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

//=====================================================================

//=================================
// "CAMERFLAGE"
//=================================


simulated function AdjustCamoProperties(optional int Index)
{
	local float f;

		f = FRand();
		if ( (Index == -1 && f > 0.98) || Index == 2) //No holosight
		{
			CamoIndex=2;
			if (bAllowCamoEffects)
			{
				SetBoneScale (0, 0.0, ScopeBone);
				SightOffset = vect(12,25,8.2);
     				ChaosDeclineTime=0.9;
				RecoilDeclineTime=1.5;

     				ScopeViewTex=None;
     				ScopeViewTexThermal=None;
     				ZoomInSound.Sound=None;
     				ZoomOutSound.Sound=None;
     				FullZoomFOV=30.000000;
     				SightDisplayFOV=30.000000;
     				bNoMeshInScope=False;
			}

		}
		else if ( (Index == -1 && f > 0.90) || Index == 1) //N6-BMG
		{
			Skins[2]=CamoMaterials[1];
			CamoIndex=1;
			if (bAllowCamoEffects)
			{
				BallisticInstantFire(FireMode[0]).Damage = 125;
				BallisticInstantFire(FireMode[0]).DamageHead = 190;
				BallisticInstantFire(FireMode[0]).DamageLimb = 70;
				BallisticInstantFire(FireMode[0]).RecoilPerShot=1950;
				BallisticInstantFire(FireMode[0]).XInaccuracy = 1.25;
				BallisticInstantFire(FireMode[0]).YInaccuracy = 1.75;
				BallisticInstantFire(FireMode[0]).AmmoClass = Class'BWBP_SKC_Fix.Ammo_50BMG';
				BallisticInstantFire(FireMode[1]).AmmoClass = Class'BWBP_SKC_Fix.Ammo_50BMG';
			}
		}
		else
		{
			CamoIndex=0;
			Skins[2]=CamoMaterials[0];
		}

}

///==============================================================
/// Infa Red Scope View
///==============================================================


simulated function SetScopeView(bool bNewValue)
{
	super.SetScopeView(bNewValue);
		
	if (!bNewValue)
	{
		if (Level.NetMode == NM_Client)
			AdjustThermalView(false);
		else ServerAdjustThermal(false);
	}
	else if (bThermal)
	{
		if (Level.NetMode == NM_Client)
			AdjustThermalView(true);
		else ServerAdjustThermal(true);
	}	
}


simulated function BringUp(optional Weapon PrevWeapon)
{

	if (Instigator != None && AIController(Instigator.Controller) != None) //Botaccuracy ++
	{
		AimSpread *= 0.15;
		ChaosAimSpread *= 0.15;
	}
	else if (Instigator != None && AIController(Instigator.Controller) == None) //Player Screen ON
	{
		ScreenStart();
		if (!Instigator.IsLocallyControlled())
			ClientScreenStart();
	}

	super.BringUp(PrevWeapon);
	if (ColorMod != None)
		return;
	ColorMod = ColorModifier(Level.ObjectPool.AllocateObject(class'ColorModifier'));
	if ( ColorMod != None )
	{
		ColorMod.Material = FinalBlend'BallisticEffects.M75.OrangeFinal';
		ColorMod.Color.R = 255;
		ColorMod.Color.G = 255;
		ColorMod.Color.B = 255;
		ColorMod.Color.A = 255;
		ColorMod.AlphaBlend = false;
		ColorMod.RenderTwoSided=True;
	}
}


simulated function bool PutDown()
{
	if (Super.PutDown())
	{
		if (Level.NetMode == NM_Client)
			AdjustThermalView(false);
		else ServerAdjustThermal(false);

		return true;
	}
	return false;
}


exec simulated function WeaponSpecial(optional byte i)
{
	if (ClientState != WS_ReadyToFire || ReloadState != RS_None || CamoIndex == 2)
		return;
		
	bThermal = !bThermal;
	if (bThermal)
	{
    	class'BUtil'.static.PlayFullSound(self, ThermalOnSound);
    	ServerWeaponSpecial(1);
    }
	else
	{
    	class'BUtil'.static.PlayFullSound(self, ThermalOffSound);
    	ServerWeaponSpecial(0);
    }
    
    AdjustThermalView(bThermal);
}

function ServerWeaponSpecial(optional byte i)
{
	bThermal = bool(i);
	ServerAdjustThermal(bThermal);
}



simulated function AdjustThermalView(bool bNewValue)
{
	if (AIController(Instigator.Controller) != None)
		return;
	if (!bNewValue)
	{
		bUpdatePawns = false;
	}
	else
	{
		bUpdatePawns = true;
		UpdatePawnList();
		NextPawnListUpdateTime = Level.TimeSeconds + 1;
	}
}

function ServerAdjustThermal(bool bNewValue)
{
	local int i;
	
	if (bNewValue)
	{
		bUpdatePawns = true;
		UpdatePawnList();
		NextPawnListUpdateTime = Level.TimeSeconds + 1;
	}
	else
	{
		bUpdatePawns = false;
		for (i=0;i<ArrayCount(UpdatedPawns);i++)
		{
			if (UpdatedPawns[i] != None)
				UpdatedPawns[i].bAlwaysRelevant = false;
		}
	}
}

//Moved here because Timer broke the weapon
simulated function WeaponTick (float DeltaTime)
{
	local actor T;
	local vector HitLoc, HitNorm, Start, End;

	Super.WeaponTick(DeltaTime);

	if (Level.TimeSeconds >= NextPawnListUpdateTime)
		UpdatePawnList();

	if (!Instigator.IsLocallyControlled())
		return;

	if (bThermal && bScopeView)
	{
		SetNVLight(true);

		Start = Instigator.Location+Instigator.EyePosition();
		End = Start+vector(Instigator.GetViewRotation())*1500;
		T = Trace(HitLoc, HitNorm, End, Start, true, vect(16,16,16));
		if (T==None)
			HitLoc = End;

		if (VSize(HitLoc-Start) > 400)
			NVLight.SetLocation(Start + (HitLoc-Start)*0.5);
		else
			NVLight.SetLocation(HitLoc + HitNorm*30);
	}
	else
		SetNVLight(false);

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


simulated event RenderOverlays (Canvas Canvas)
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

	if (!bScopeView)
	{
		Super.RenderOverlays(Canvas);
		if (SightFX != None)
			RenderSightFX(Canvas);
		return;
	}
	if (bThermal)
	{
		DrawThermalMode(Canvas);
	}
	if (!bNoMeshInScope)
	{
		Super.RenderOverlays(Canvas);
		if (SightFX != None)
			RenderSightFX(Canvas);
	}
	else
	{
		SetLocation(Instigator.Location + Instigator.CalcDrawOffset(self));
		SetRotation(Instigator.GetViewRotation());
	}

	Canvas.SetDrawColor(255,255,255,255);
	Canvas.SetPos(Canvas.OrgX, Canvas.OrgY);
	Canvas.Style = ERenderStyle.STY_Alpha;

	if (bThermal)
	{
    		Canvas.DrawTile(ScopeViewTexThermal, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1024);

        	Canvas.SetPos((Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTexThermal, Canvas.SizeY, Canvas.SizeY, 0, 0, 1024, 1024);

        	Canvas.SetPos(Canvas.SizeX - (Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTexThermal, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1024);
	}
	else
    	{

    		Canvas.DrawTile(ScopeViewTex, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1024);

        	Canvas.SetPos((Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTex, Canvas.SizeY, Canvas.SizeY, 0, 0, 1024, 1024);

        	Canvas.SetPos(Canvas.SizeX - (Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTex, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1024);
		
	}

}


simulated function UpdatePawnList()
{
	local Pawn P;
	local int i;
	local float Dist;

	PawnList.Length=0;
	ForEach DynamicActors( class 'Pawn', P)
	{
		PawnList[PawnList.length] = P;
		Dist = VSize(P.Location - Instigator.Location);
		if (Dist <= ThermalRange &&
			( Normal(P.Location-(Instigator.Location+Instigator.EyePosition())) Dot Vector(Instigator.GetViewRotation()) > 1-((Instigator.Controller.FovAngle*0.9)/180) ) &&
			((Instigator.LineOfSightTo(P)) || Normal(P.Location - Instigator.Location) Dot Vector(Instigator.GetViewRotation()) > 0.985 + 0.015 * (Dist/ThermalRange)))
		{
			if (!Instigator.IsLocallyControlled())
			{
				P.NetUpdateTime = Level.TimeSeconds - 1;
				P.bAlwaysRelevant = true;
			}
			UpdatedPawns[i]=P;
			i++;
		}
	}
}


// Draws players through walls and all the other Thermal Mode stuff
simulated event DrawThermalMode (Canvas C)
{
	local Pawn P;
	local int i, j;
	local float Dist, DotP, ImageScaleRatio;//, OtherRatio;
	local Array<Material>	OldSkins;
	local int OldSkinCount;
	local bool bLOS, bFocused;
	local vector Start;
	local Array<Material>	AttOldSkins0;
	local Array<Material>	AttOldSkins1;

	ImageScaleRatio = 1.3333333;

	C.Style = ERenderStyle.STY_Modulated;
	// Draw Spinning Sweeper thing
	C.SetPos((C.SizeX - C.SizeY)/2, C.OrgY);
	C.SetDrawColor(255,255,255,255);
	C.DrawTile(FinalBlend'BWBP_SKC_TexExp.FSG50.FSGIRFinal', C.SizeY, C.SizeY, 0, 0, 1024, 1024);
	// Draw some panning lines 
	C.SetPos(C.OrgX, C.OrgY);
	C.DrawTile(FinalBlend'BWBP_SKC_TexExp.SKAR.SKAR-StaticFinal', C.SizeX, C.SizeY, 0, 0, 512, 512); 

	if (ColorMod == None)
		return;
	// Draw the players with an orange effect
	C.Style = ERenderStyle.STY_Alpha;
	Start = Instigator.Location + Instigator.EyePosition();
	for (j=0;j<PawnList.length;j++)
	{
		if (PawnList[j] != None && PawnList[j] != Level.GetLocalPlayerController().Pawn)
		{
			P = PawnList[j];
			bFocused=false;
			bLos=false;
			ThermalRange = default.ThermalRange + 2000 * FMin(1, VSize(P.Velocity) / 450);
			Dist = VSize(P.Location - Instigator.Location);
			if (Dist > ThermalRange)
				continue;
			DotP = Normal(P.Location - Start) Dot Vector(Instigator.GetViewRotation());
			if ( DotP < Cos((Instigator.Controller.FovAngle/1.7) * 0.017453) )
				continue;
			// If we have a clear LOS then they can be drawn
			if (Instigator.LineOfSightTo(P))
				bLOS=true;
			if (bLOS)
			{
				DotP = (DotP-0.6) / 0.4;

				DotP = FMax(DotP, 0);

				if (Dist < 500)
					ColorMod.Color.R = DotP * 255.0;
				else
					ColorMod.Color.R = DotP * ( 255 - FClamp((Dist-500)/((ThermalRange-500)*0.8), 0, 1) * 255 );
				ColorMod.Color.G = DotP * ( 128.0 - (Dist/ThermalRange)*96.0 );

				// Remember old skins, set new skins, turn on unlit...
				OldSkinCount = P.Skins.length;
				for (i=0;i<Max(2, OldSkinCount);i++)
				{	if (OldSkinCount > i) OldSkins[i] = P.Skins[i]; else OldSkins[i]=None;	P.Skins[i] = ColorMod;	}
				P.bUnlit=true;

				for (i=0;i<P.Attached.length;i++)
					if (P.Attached[i] != None)
					{
						if (Pawn(P.Attached[i]) != None || ONSWeapon(P.Attached[i]) != None/* || InventoryAttachment(P.Attached[i])!= None*/)
						{
							if (P.Attached[i].Skins.length > 0)
							{	AttOldSkins0[i] = P.Attached[i].Skins[0];	P.Attached[i].Skins[0] = ColorMod;	}
							else
							{	AttOldSkins0[i] = None;	P.Attached[i].Skins[0] = ColorMod;	}
							if (P.Attached[i].Skins.length > 1)
							{	AttOldSkins1[i] = P.Attached[i].Skins[1];	P.Attached[i].Skins[1] = ColorMod;	}
							if (P.Attached[i].Skins.length > 1)
							{	AttOldSkins1[i] = None;	P.Attached[i].Skins[1] = ColorMod;	}
						}
						else
							P.Attached[i].SetDrawType(DT_None);
					}

				C.DrawActor(P, false, true);

				// Set old skins back, Unlit off
				P.Skins.length = OldSkinCount;
				for (i=0;i<P.Skins.length;i++)
					P.Skins[i] = OldSkins[i];
				P.bUnlit=false;

				for (i=0;i<P.Attached.length;i++)
					if (P.Attached[i] != None)
					{
						if (Pawn(P.Attached[i]) != None || ONSWeapon(P.Attached[i]) != None/* || InventoryAttachment(P.Attached[i])!= None*/)
						{
							if (AttOldSkins1[i] == None)
							{
								if (AttOldSkins0[i] == None)
									P.Attached[i].Skins.length = 0;
								else
								{
									P.Attached[i].Skins.length = 1;
									P.Attached[i].Skins[0] = AttOldSkins0[i];
								}
							}
							else
							{
								P.Attached[i].Skins[0] = AttOldSkins0[i];
								P.Attached[i].Skins[1] = AttOldSkins1[i];
							}
						}
						else
							P.Attached[i].SetDrawType(P.Attached[i].default.DrawType);
					}
				AttOldSkins0.length = 0;
				AttOldSkins1.length = 0;
			}
			else
				continue;
		}
	}
}

simulated function SetNVLight(bool bOn)
{
	if (!Instigator.IsLocallyControlled())
		return;
	if (bOn)
	{
		if (NVLight == None)
		{
			NVLight = Spawn(class'HKARNVLight',,,Instigator.location);
			NVLight.SetBase(Instigator);
		}
		NVLight.bDynamicLight = true;
	}
	else if (NVLight != None)
		NVLight.bDynamicLight = false;
}

///================================================
///
///================================================

static function class<Pickup> RecommendAmmoPickup(int Mode)
{
	return class'AP_50IncMag';
}


simulated function bool HasAmmo()
{
	//First Check the magazine
	if (FireMode[0] != None && MagAmmo >= FireMode[0].AmmoPerFire)
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

defaultproperties
{
//     PlayerSpeedFactor=0.900000
//     PlayerJumpFactor=0.850000
     PlayerSpeedFactor=0.900000
     PlayerJumpFactor=0.750000

	 ZoomType=ZT_Logarithmic
     FullZoomFOV=15.000000
	 MinZoom=4.000000
     MaxZoom=12.000000
     ZoomStages=3
//     FullZoomFOV=15.000000
//	 ZoomType=ZT_Smooth
//     MinimumZoom=40.000000

     ScopeBone="Scope"
     BulletBone="Bullet"

     ThermalOnSound=(Sound=Sound'BallisticSounds2.M75.M75ThermalOn',Volume=0.500000,Pitch=1.000000)
     ThermalOffSound=(Sound=Sound'BallisticSounds2.M75.M75ThermalOff',Volume=0.500000,Pitch=1.000000)
     WallVisionSkin=FinalBlend'BallisticEffects.M75.OrangeFinal'
     Flaretex=FinalBlend'BallisticEffects.M75.OrangeFlareFinal'
     ThermalRange=4500.000000

     CamoMaterials[0]=Texture'BWBP_SKC_TexExp.FSG50.FSG-Misc'
     CamoMaterials[1]=Texture'BWBP_SKC_TexExp.FSG50.FSG-MiscN6'
     CamoMaterials[2]=Texture'BWBP_SKC_TexExp.FSG50.FSG-Scope'
     CamoMaterials[3]=Texture'ONSstructureTextures.CoreGroup.Invisible'


     	Screen=Shader'BWBP_SKC_TexExp.FSG50.FSG50-ScriptLCD-SD'
	 ScreenBase1=Texture'BWBP_SKC_TexExp.FG50.FG50-Screen'
	 ScreenBase2=Texture'BWBP_SKC_TexExp.FG50.FG50-Screen2'
	 ScreenBase3=Texture'BWBP_SKC_TexExp.FG50.FG50-Screen3'
	 ScreenBase4=Texture'BWBP_SKC_TexExp.FG50.FG50-Screen4'
	 Numbers=Texture'BWBP_SKC_TexExp.PUMA.PUMA-Numbers'
	 MyFontColor=(R=255,G=255,B=255,A=255)
     	WeaponScreen=ScriptedTexture'BWBP_SKC_TexExp.FSG50.FSG50-ScriptLCD'

     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     BigIconMaterial=Texture'BWBP_SKC_TexExp.FSG50.BigIcon_FSG50'
     BallisticInventoryGroup=7
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Bullet=True
     SpecialInfo(0)=(Info="360.0;35.0;1.0;90.0;10.0;0.0;0.1")
     BringUpSound=(Sound=Sound'BWBP4-Sounds.MRL.MRL-BigOn')
     PutDownSound=(Sound=Sound'BWBP4-Sounds.MRL.MRL-BigOff')
     MagAmmo=10
     InventorySize=45
     CockAnimPostReload="Cock"
     CockSound=(Sound=Sound'BWBP_SKC_SoundsExp.AS50.FG50-Cock',Volume=2.500000)
     ClipInSound=(Sound=Sound'BWBP_SKC_SoundsExp.AS50.FG50-MagIn',Volume=1.500000)
     ClipOutSound=(Sound=Sound'BWBP_SKC_SoundsExp.AS50.FG50-MagOut',Volume=1.500000)
     ClipInFrame=0.850000
        IdleAnimRate=0.600000
     bCockOnEmpty=True
     bNeedCock=True
     WeaponModes(0)=(ModeName="Semi-Automatic")
     WeaponModes(1)=(bUnavailable=True)
     CurrentWeaponMode=0
     ScopeViewTex=Texture'BWBP_SKC_TexExp.FSG50.FSG-ScopeView'
     ScopeViewTexThermal=Texture'BWBP_SKC_TexExp.FSG50.FSG-ScopeViewThermal'
     ZoomInSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomIn',Volume=0.500000,Pitch=1.000000)
     ZoomOutSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomOut',Volume=0.500000,Pitch=1.000000)
     bNoMeshInScope=True
     bNoCrosshairInScope=True
     SightOffset=(X=-5.000000,Y=25.000000,Z=10.300000)
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.Cross4',pic2=Texture'BallisticUI2.Crosshairs.M353OutA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=0,G=255,R=0,A=153),Color2=(B=0,G=0,R=0,A=255),StartSize1=22,StartSize2=61)
     GunLength=80.000000
     CrouchAimFactor=0.700000
     SightAimFactor=0.850000
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     JumpChaos=0.800000
     AimAdjustTime=0.900000
     AimSpread=(X=(Min=-128.000000,Max=128.000000),Y=(Min=-128.000000,Max=128.000000))
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.300000),(InVal=0.800000,OutVal=-0.400000),(InVal=1.000000,OutVal=-0.200000)))
     RecoilYCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.650000),(InVal=0.600000,OutVal=0.800000),(InVal=0.800000,OutVal=0.900000),(InVal=1.000000,OutVal=1.000000)))
     ViewAimFactor=0.550000
     RecoilMax=6000
     ChaosDeclineTime=1.800000
     ChaosTurnThreshold=90000.000000
     ChaosSpeedThreshold=300.000000
     ChaosAimSpread=(X=(Min=-3840.000000,Max=3840.000000))
     RecoilYawFactor=1.000000
     RecoilPitchFactor=1.000000
     RecoilXFactor=0.250000
     RecoilYFactor=0.550000
     RecoilDeclineTime=2.500000
     RecoilDeclineDelay=0.000000
     FireModeClass(0)=Class'BWBP_SKC_Fix.AS50PrimaryFire'
     FireModeClass(1)=Class'BCoreFix.BallisticScopeFire'
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.650000
     CurrentRating=0.600000
     bSniping=True
     Description="FSSG-50 .50 Marksman Rifle||Manufacturer: NDTR Industries |Primary: Accurate .50 Fire|Secondary: Activate Scope|Special:Toggle IR Scope||[Fallschirmjägerscharfschützengewehr] FSsG-50 is the name given to high-performance FG50 Machineguns that are then equipped with match-grade barrels and high-quality custom marksman stocks. FG-50s with exceptional target groupings and perfect reliability ratings are the primary candidates for the FSsG upgrade, though some production plants with extremely tight tolerances and quality control specifically produce the FSsG variant. The result is a very accurate sniper rifle with a muzzle velocity far higher than its standard cousin. These elite rifles are very rarely mounted on vehicle platforms and are often utilized by sharpshooters equipped with enhanced scopes and match-grade N6-BMG rounds for hard target interdiction. This FSSG-50 is firing the mass produced N1-Incendiary round and has an Aeris Mark 2 Suresight scope attached."
     DisplayFOV=55.000000
     PutDownTime=0.6
     Priority=207
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=9
     PickupClass=Class'BWBP_SKC_Fix.AS50Pickup'
     PlayerViewOffset=(X=5.000000,Y=-7.000000,Z=-8.000000)
     BobDamping=1.800000
     AttachmentClass=Class'BWBP_SKC_Fix.AS50Attachment'
     IconMaterial=Texture'BWBP_SKC_TexExp.FSG50.SmallIcon_FSG50'
     IconCoords=(X2=127,Y2=31)
     ItemName="FSSG-50 Marksman Rifle"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=5.000000
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.FSG-50_FP'
     DrawScale=0.500000
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Texture'BWBP_SKC_TexExp.FSG50.FSG-Main'
     Skins(2)=Texture'BWBP_SKC_TexExp.FSG50.FSG-Misc'
     Skins(3)=Texture'BWBP_SKC_TexExp.FSG50.FSG-Stock'
     Skins(4)=Texture'BWBP_SKC_TexExp.FSG50.FSG-Scope'
     Skins(5)=Texture'BWBP_SKC_TexExp.FG50.FG50-Screen'
}
