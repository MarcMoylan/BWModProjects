//=============================================================================
// MJ51Carbine.
//
// Medium range, controllable 3-round burst carbine.
// Lacks power and accuracy at range, but is easier to aim
//
// by Sarge.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class HKARCarbine extends BallisticWeapon;

var bool		bFirstDraw;
var() name		GrenadeLoadAnim;	//Anim for grenade reload
var   bool		bLoaded;


var() name		GrenBone;			
var() name		GrenBoneBase;
var() Sound		GrenSlideSound;		//Sounds for grenade reloading
var() Sound		ClipInSoundEmpty;		//			

var   float			MinimumZoom;
var   Texture			ScopeviewTexIR;

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


replication
{
	reliable if (Role < ROLE_Authority)
		ServerAdjustThermal;
	reliable if(Role == ROLE_Authority)
        	ClientSwitchCannonMode, ClientSwitchRapidMode;
}

simulated function ClientSwitchCannonMode (byte newMode)
{
	HKARPrimaryFire(FireMode[0]).SwitchCannonMode(newMode);
}

//Modified burst
simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();
	if (CurrentWeaponMode == 1)	
	{
		HKARPrimaryFire(BFireMode[0]).bRapidMode = True;
 	}
}


simulated function BringUp(optional Weapon PrevWeapon)
{

	if (Instigator != None && AIController(Instigator.Controller) != None)
	{
		AimSpread *= 0.30;
		ChaosAimSpread *= 0.10;
		BFireMode[0].FireRate = 0.092500;
	}
	if (bFirstDraw && MagAmmo > 0)
	{
     		BringUpTime=2.0;
     		SelectAnim='PulloutFancy';
		bFirstDraw=false;
		bLoaded=False;
	}
	else
	{
     		BringUpTime=default.BringUpTime;
		SelectAnim='Pullout';
	}
	if (!bLoaded)
	{
		SetBoneScale (0, 0.0, GrenBone);
		SetBoneScale (1, 0.0, GrenBoneBase);
	}
	if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
	{
		ReloadAnim = 'ReloadEmpty';
	}
	else
	{
		ReloadAnim = 'Reload';
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

//	AdjustThermalView(bThermal);

}

simulated event Destroyed()
{
	if (ColorMod != None)
	{
		Level.ObjectPool.FreeObject(ColorMod);
		ColorMod = None;
	}
	AdjustThermalView(false);

	if (NVLight != None)
		NVLight.Destroy();
		

	super.Destroyed();
}

simulated function bool PutDown()
{

	if (!bLoaded)
	{
		SetBoneScale (0, 0.0, GrenBone);
		SetBoneScale (1, 0.0, GrenBoneBase);
	}

	if (super.PutDown())
	{
		AdjustThermalView(false);
		return true;
	}
	return false;
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

function ServerWeaponSpecial(optional byte i)
{
	if (bScopeView)
	{
		bThermal = !bThermal;
		if (bThermal)
    			class'BUtil'.static.PlayFullSound(self, ThermalOnSound);
		else
    			class'BUtil'.static.PlayFullSound(self, ThermalOffSound);
	}

}

simulated event WeaponTick(float DT)
{
	local actor T;

	local vector HitLoc, HitNorm, Start, End;

	super.WeaponTick(DT);



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

	if (!bScopeView || Role < Role_Authority)
		return;

}


simulated event RenderOverlays (Canvas Canvas)
{
	local float ImageScaleRatio;

	if (!bScopeView)
	{
		Super.RenderOverlays(Canvas);
		if (SightFX != None)
			RenderSightFX(Canvas);
		return;
	}
	if (bScopeView && ( (PlayerController(Instigator.Controller).DesiredFOV == PlayerController(Instigator.Controller).DefaultFOV && PlayerController(Instigator.Controller).bZooming==false)
		|| (Level.bClassicView && (PlayerController(Instigator.Controller).DesiredFOV == 90)) ))
	{
		SetScopeView(false);
		PlayAnim(ZoomOutAnim);
	}

    	if (bThermal)
		DrawThermalMode(Canvas);

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

	// Draw Scope View
	// Draw the Scope View Tex
	Canvas.SetDrawColor(255,255,255,255);
	Canvas.SetPos(Canvas.OrgX, Canvas.OrgY);
	Canvas.Style = ERenderStyle.STY_Alpha;
	ImageScaleRatio = 1.3333333;

	if (bThermal)
	{
	        Canvas.SetDrawColor(255,255,255,255);

        	Canvas.SetPos(Canvas.OrgX, Canvas.OrgY);
    		Canvas.DrawTile(ScopeViewTexIR, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1024);

        	Canvas.SetPos((Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTexIR, Canvas.SizeY, Canvas.SizeY, 0, 0, 1024, 1024);

        	Canvas.SetPos(Canvas.SizeX - (Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTexIR, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1024);
	}
	else
	{
        	Canvas.SetPos(Canvas.OrgX, Canvas.OrgY);
    		Canvas.DrawTile(ScopeViewTex, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1024);

        	Canvas.SetPos((Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTex, Canvas.SizeY, Canvas.SizeY, 0, 0, 1024, 1024);

        	Canvas.SetPos(Canvas.SizeX - (Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTex, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1024);
	}
		
}


simulated function SetScopeView(bool bNewValue)
{
	bScopeView = bNewValue;
	if (Level.NetMode == NM_Client)
		ServerSetScopeView(bNewValue);
	bScopeView = bNewValue;
	SetScopeBehavior();
	if (bScopeView)
		AdjustThermalView(true);

}


// Scope up anim has ended. Now view through the scope or sights
simulated function StartScopeView()
{
	PlayerController(Instigator.Controller).DesiredFOV = FullZoomFOV;
	SetScopeView(true);
	if (ZoomInSound.Sound != None)	class'BUtil'.static.PlayFullSound(self, ZoomInSound);
	if (bPendingSightUp)
		bPendingSightUp=false;
	if (!bNeedCock)
		PlayIdle();
}

simulated function Weapon PrevWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
	if (bScopeView && CurrentWeapon == self)
	{
		ChangeZoom(1.5);
		return None;
	}
	return super.PrevWeapon(CurrentChoice, CurrentWeapon);
}

simulated function Weapon NextWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
	if (bScopeView && CurrentWeapon == self )
	{
		ChangeZoom(-1.5);
		return None;
	}
	return super.NextWeapon(CurrentChoice, CurrentWeapon);
}


// Adjust the zoom level
simulated function ChangeZoom (float Value)
{
	local PlayerController PC;
	local float OldZoomLevel;

	PC = PlayerController(Instigator.Controller);
	if (PC == None)
		return;
	if (bInvertScope)
		Value*=-1;
	OldZoomLevel = PC.ZoomLevel;
	PC.ZoomLevel = FClamp(PC.ZoomLevel+Value, 0.05, 1.0);
	if (PC.ZoomLevel > OldZoomLevel)
		if (ZoomInSound.Sound != None)	class'BUtil'.static.PlayFullSound(self, ZoomInSound);
	else if (PC.ZoomLevel < OldZoomLevel)
		if (ZoomOutSound.Sound != None)	class'BUtil'.static.PlayFullSound(self, ZoomOutSound);
	PC.DesiredFOV = FClamp(PC.DefaultFOV - (PC.ZoomLevel * (PC.DefaultFOV-FullZoomFOV)), FullZoomFOV, MinimumZoom);
}



simulated event Timer()
{
	if (bUpdatePawns)
		UpdatePawnList();
	else
		super.Timer();
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
//	C.DrawTile(FinalBlend'BWBP_SKC_TexExp.MARS.F2000TargetFinal', C.SizeY, C.SizeY, 0, 0, 1024, 1024);
	C.DrawTile(FinalBlend'BWBP_SKC_TexExp.SKAR.SKAR-IRFinal', C.SizeY, C.SizeY, 0, 0, 1024, 1024);
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


simulated function AdjustThermalView(bool bNewValue)
{
	if (AIController(Instigator.Controller) != None)
		return;
	if (!bNewValue)
	{
		bUpdatePawns = false;
//		SetTimer(0.0, false);
	}
	else
	{
		bUpdatePawns = true;
		UpdatePawnList();
		SetTimer(1.0, true);
	}
	ServerAdjustThermal(bNewValue);
}
function ServerAdjustThermal(bool bNewValue)
{
	local int i;
//	bThermal = bNewValue;
	if (bNewValue)
	{
		bUpdatePawns = true;
		UpdatePawnList();
		SetTimer(1.0, true);
	}
	else
	{
		bUpdatePawns = false;
//		SetTimer(0.0, false);
		for (i=0;i<ArrayCount(UpdatedPawns);i++)
		{
			if (UpdatedPawns[i] != None)
				UpdatedPawns[i].bAlwaysRelevant = false;
		}
	}
}


//simulated function DoWeaponSpecial(optional byte i)
exec simulated function WeaponSpecial(optional byte i)
{

	if (bScopeView)
	{
		bThermal = !bThermal;
		if (bThermal)
    			class'BUtil'.static.PlayFullSound(self, ThermalOnSound);
		else
    			class'BUtil'.static.PlayFullSound(self, ThermalOffSound);
		AdjustThermalView(bThermal);
		return;
		
	}
	/*
	else if (!bScopeView)
	{
		HKARSecondaryFire.DoFireEffect(); //DU. DU HAST.
		HKARAttachment.InstantFireEffects(1);
		HKARAttachment.FlashMuzzleFlash(1);
	}*/
}


// Load in a grenade
simulated function LoadGrenade()
{
	if (Ammo[1].AmmoAmount < 1 || bLoaded)
		return;
	if (ReloadState == RS_None)
		PlayAnim(GrenadeLoadAnim, 1.1, , 0);
}


// Notifys for greande loading sounds
simulated function Notify_GrenVisible()	{	SetBoneScale (0, 1.0, GrenBone); SetBoneScale (1, 1.0, GrenBoneBase);	ReloadState = RS_PreClipOut;}
simulated function Notify_GrenSlide()	{	PlaySound(GrenSlideSound, SLOT_Misc, 2.2, ,64);	}
simulated function Notify_GrenLoaded()	
{
    	local Inventory Inv;

	Ammo[1].UseAmmo (1, True);
	if (Ammo[1].AmmoAmount == 0)
	{
		for ( Inv=Instigator.Inventory; Inv!=None; Inv=Inv.Inventory )
			if (ChaffGrenadeWeapon(Inv) != None)
			{
				ChaffGrenadeWeapon(Inv).RemoteKill();	
				break;
			}
	}
}
simulated function Notify_GrenReady()	{	ReloadState = RS_None; bLoaded = true;	}
simulated function Notify_GrenLaunch()	{	SetBoneScale (0, 0.0, GrenBone); 	}
simulated function Notify_GrenInvisible()	{ SetBoneScale (1, 0.0, GrenBoneBase);	}


simulated function PlayReload()
{

    if (MagAmmo < 1)
    {
       ReloadAnim='ReloadEmpty';
       ClipHitSound.Sound=ClipInSoundEmpty;
    }
    else
    {
       ReloadAnim='Reload';
       ClipHitSound.Sound=default.ClipHitSound.Sound;
    }
	if (!bLoaded)
	{
		SetBoneScale (0, 0.0, GrenBone);
		SetBoneScale (1, 0.0, GrenBoneBase);
	}
	SafePlayAnim(ReloadAnim, ReloadAnimRate, , 0, "RELOAD");
}

simulated function IndirectLaunch()
{
//	StartFire(1);
}


// Change some properties when using sights...
simulated function SetScopeBehavior()
{
	super.SetScopeBehavior();
	bUseNetAim = default.bUseNetAim || bScopeView;
	if (bScopeView)
	{
//		SightAimFactor = 0.6;
        	FireMode[0].FireAnim='SightFire';
	}
	else
	{
//		SightAimFactor = default.ViewRecoilFactor;
        	FireMode[0].FireAnim='Fire';
	}
}


//===============================================
// Azarael Fixed Burst Netcode
//===============================================


// Cycle through the various weapon modes
function ServerSwitchWeaponMode (byte NewMode)
{


	if (CurrentWeaponMode > 0 && FireMode[0].IsFiring())
		return;

	NewMode = CurrentWeaponMode + 1;
	while (NewMode != CurrentWeaponMode && (NewMode >= WeaponModes.length || WeaponModes[NewMode].bUnavailable) )
	{
		if (NewMode >= WeaponModes.length)
			NewMode = 0;
		else
			NewMode++;
	}
	if (!WeaponModes[NewMode].bUnavailable)
  		CurrentWeaponMode = NewMode;
  
	// Azarael - This assumes that all firemodes implementing burst modify the primary fire alone.
	// To my knowledge, this is the case.
	// Sarge - Hard coding to work with the SKAR - Cut down
	if (CurrentWeaponMode == 1)
	{
		HKARPrimaryFire(BFireMode[0]).bRapidMode = True;
		if (!Instigator.IsLocallyControlled())
			ClientSwitchRapidMode(True);
	}
	else if (HKARPrimaryFire(BFireMode[0]).bRapidMode)
	{ 
		HKARPrimaryFire(BFireMode[0]).bRapidMode = False;
		if (!Instigator.IsLocallyControlled())
			ClientSwitchRapidMode(False);
	}

	if (!Instigator.IsLocallyControlled())
		HKARPrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
	ClientSwitchCannonMode (CurrentWeaponMode);
}

simulated function ClientSwitchRapidMode(bool bRapid, optional int Max)
{
	HKARPrimaryFire(BFireMode[0]).bRapidMode = bRapid;
}

//===============================================
// AI Crap
//===============================================


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

/*
simulated function TickFireCounter (float DT)
{
    if (CurrentWeaponMode == 1 && level.Netmode == NM_Standalone)
    {
        if (!IsFiring() && FireCount > 0 && FireMode[0].NextFireTime - level.TimeSeconds < -0.1)
            FireCount = 0;
    }
    else
        super.TickFireCounter(DT);
}*/



defaultproperties
{
     ThermalOnSound=(Sound=Sound'BallisticSounds2.M75.M75ThermalOn',Volume=0.500000,Pitch=1.000000)
     ThermalOffSound=(Sound=Sound'BallisticSounds2.M75.M75ThermalOff',Volume=0.500000,Pitch=1.000000)
     WallVisionSkin=FinalBlend'BallisticEffects.M75.OrangeFinal'
     Flaretex=FinalBlend'BallisticEffects.M75.OrangeFlareFinal'
     ThermalRange=25000.000000
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=1.000000
     GrenSlideSound=Sound'BWBP_SKC_SoundsExp.MJ51.MJ51-GrenLock'
     GrenBone="Grenade"
     GrenBoneBase="GrenadeHandle"
     GrenadeLoadAnim="LoadGrenade"
     GunLength=64.000000
     LongGunOffset=(x=10.000000,Y=10.000000,Z=-11.000000)
     BigIconMaterial=Texture'BWBP_SKC_TexExp.M4A1.BigIcon_M4'
     BallisticInventoryGroup=5
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Bullet=True
     SpecialInfo(0)=(Info="240.0;25.0;0.9;80.0;0.7;0.7;0.4")
     BringUpSound=(Sound=Sound'BWBP_SKC_SoundsExp.MJ51.MJ51-PullOut',Volume=2.200000)
     PutDownSound=(Sound=Sound'BWBP_SKC_SoundsExp.MJ51.MJ51-Putaway',Volume=2.200000)
     MagAmmo=28
     CockSound=(Sound=Sound'BWBP_SKC_SoundsExp.MJ51.MJ51-Cock',Volume=2.200000)
     ClipHitSound=(Sound=Sound'BWBP_SKC_SoundsExp.MJ51.MJ51-MagIn',Volume=4.800000)
     ClipOutSound=(Sound=Sound'BWBP_SKC_SoundsExp.MJ51.MJ51-MagOut',Volume=4.800000)
     ClipInSoundEmpty=Sound'BWBP_SKC_SoundsExp.MJ51.MJ51-MagInEmpty'
     ClipInFrame=0.650000
     bNeedCock=False
     bCockOnEmpty=False
     bFirstDraw=True
     bNoCrosshairInScope=True
     CurrentWeaponMode=1
     ScopeViewTex=Texture'BWBP_SKC_TexExp.SKAR.SKAR-Scope'
     ScopeViewTexIR=Texture'BWBP_SKC_TexExp.SKAR.SKAR-IRScope'
     ZoomInSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomIn',Volume=0.500000,Pitch=1.000000)
     ZoomOutSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomOut',Volume=0.500000,Pitch=1.000000)
     FullZoomFOV=35.000000
     MinimumZoom=65.000000
     bThermal=True
     bNoMeshInScope=True
//     WeaponModes(0)=(ModeName="2-Burst",ModeID="WM_Burst",Value=2.000000)
     WeaponModes(1)=(ModeName="4-Burst",Value=4.000000)
//     WeaponModes(2)=(bUnavailable=True)
     WeaponModes(3)=(bUnavailable=True)
     SightOffset=(X=15.000000,Y=-6.450000,Z=20.500000)
     SightDisplayFOV=40.000000
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.M50Out',pic2=Texture'BallisticUI2.Crosshairs.M50In',USize1=128,VSize1=128,USize2=128,VSize2=128,Color1=(B=0,G=0,R=255,A=158),Color2=(B=0,G=255,R=255,A=255),StartSize1=75,StartSize2=72)
     CrouchAimFactor=0.500000
     SprintOffSet=(Pitch=-3500,Roll=3000,Yaw=-3000)
//     AimSpread=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000))
//     ChaosAimSpread=(X=(Min=-2250.000000,Max=2250.000000),Y=(Min=-2250.000000,Max=2250.000000))
     ViewAimFactor=0.200000
     ViewRecoilFactor=0.600000
     SightAimFactor = 0.700000
//     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.300000),(InVal=0.800000,OutVal=-0.400000),(InVal=1.000000,OutVal=-0.200000)))
//     RecoilYCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.650000),(InVal=0.600000,OutVal=0.800000),(InVal=0.800000,OutVal=0.900000),(InVal=1.000000,OutVal=1.000000)))
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=-0.100000),(InVal=0.400000,OutVal=-0.300000),(InVal=0.800000,OutVal=0.400000),(InVal=1.000000,OutVal=0.100000)))
     RecoilYCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.650000),(InVal=0.600000,OutVal=0.800000),(InVal=0.800000,OutVal=0.900000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYawFactor=0.400000
     RecoilPitchFactor=1.500000
     RecoilXFactor=1.000000
     RecoilYFactor=1.000000
     RecoilDeclineDelay=0.100000
     RecoilDeclineTime=1.0
     ChaosDeclineTime=1.0
     SightingTime=0.200000
     FireModeClass(0)=Class'BWBP_SKC_Fix.HKARPrimaryFire'
     FireModeClass(1)=Class'BallisticFix.AM67SecondaryFire'
//     FireModeClass(1)=Class'BCoreFix.BallisticScopeFire'
     PutDownTime=0.700000
     BringUpTime=0.900000
     IdleAnimRate=0.200000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.600000
     CurrentRating=0.600000
     Description="JSOC Mk.16 HKAR||Manufacturer: Majestic Firearms 12|Primary: 5.56mm CAP Rifle Rounds|Secondary: Attach Smoke Grenade||"
     Priority=41
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=9
     PickupClass=Class'BWBP_SKC_Fix.HKARPickup'
     PlayerViewOffset=(X=-8.000000,Y=10.000000,Z=-14.000000)
     BobDamping=2.000000
     AttachmentClass=Class'BWBP_SKC_Fix.HKARAttachment'
     IconMaterial=Texture'BWBP_SKC_TexExp.M4A1.SmallIcon_M4'
     IconCoords=(X2=127,Y2=31)
     ItemName="[B] JSOC Mk.16 HKAR"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=4.000000
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.M4Carbine_FP'
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Shader'BWBP_SKC_TexExp.M4A1.M4-ShineBlack'
     Skins(2)=Texture'BWBP_SKC_TexExp.M4A1.M4-Ord'
     Skins(3)=Texture'BWBP_SKC_TexExp.M4A1.M4-Ord'
     DrawScale=0.300000
}
