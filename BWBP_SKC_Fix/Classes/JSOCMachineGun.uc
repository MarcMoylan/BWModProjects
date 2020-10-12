//=============================================================================
// JSOCMachineGun
//
// A rapid fire, but inaccurate machine gun. Has two scope settings and bipod.
// Low zoom scope is an unmagified Red Dot Sight, High Zoom is a 3x G36 scope.
//
// Scope code by Kaboodles
// Gun code by Sergeant Kelly
// Ballisic Weapon Code by Dark Carnivour
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class JSOCMachineGun extends BallisticWeapon;

var Texture ScopeViewTex1X; //Red Dot
var Texture ScopeViewTex3X; //Zoomed Sight

var   bool		bSilenced;				// Silencer on. Silenced
var() name		SilencerBone;			// Bone to use for hiding silencer
var() name		SilencerOnAnim;			// Think hard about this one...
var() name		SilencerOffAnim;		//
var() sound		SilencerOnSound;		// Silencer stuck on sound
var() sound		SilencerOffSound;		//
var() sound		SilencerOnTurnSound;	// Silencer screw on sound
var() sound		SilencerOffTurnSound;	//
var() float		SilencerSwitchTime;		//

//Scope magnification stuff
var(KaboodleScope)     float    ZoomIncrements;        //Zoom is multiplied by this amount when adjusting with mousewheel.
var(KaboodleScope)     float    MinZoom;               //Lowest level of magnification.
var(KaboodleScope)     float    MaxZoom;               //Highest level of magnification


replication
{
	reliable if (Role < ROLE_Authority)
		ServerSwitchSilencer;
}

//=======================================
//		KABOODLES SCOPE CODE
//=======================================

// Relocate the weapon according to sight view.
simulated function PositionSights ()
{
	local PlayerController PC;
	local Vector SightPos, Offset, NewLoc, OldLoc;//, X,Y,Z;
	PC = PlayerController(Instigator.Controller);

	if (SightBone != '')
		SightPos = GetBoneCoords(SightBone).Origin - Location;

	OldLoc = Instigator.Location + Instigator.CalcDrawOffset(self);
	Offset = SightOffset; Offset.X += float(Normalize(Instigator.GetViewRotation()).Pitch) / 4096;
	NewLoc = (PlayerController(Instigator.Controller).CalcViewLocation-Instigator.WalkBob*0.3) - (SightPos + ViewAlignedOffset(Offset));

	if (SightingPhase >= 1.0 )
	{	// Weapon locked in sight view
		SetLocation(NewLoc);
		SetRotation(Instigator.GetViewRotation() + SightPivot);
		DisplayFOv = SightDisplayFOV;
	}
	else if (SightingPhase <= 0.0)
	{	// Weapon completely lowered
		SetLocation(OldLoc);
		SetRotation(Instigator.GetViewRotation());
		DisplayFOv = default.DisplayFOV;

 //       	if (PC != none)
  //         		PC.ResetFOV();
	}
	else
	{	// Gun is on the move...
		SetLocation(class'BUtil'.static.VSmerp(SightingPhase, OldLoc, NewLoc));
		SetRotation(Instigator.GetViewRotation() + SightPivot * SightingPhase);
		DisplayFOV = Smerp(SightingPhase, default.DisplayFOV, SightDisplayFOV);
	}

}

//fixes issues with the UI when using sights
simulated function bool AllowWeapPrevUI()
{
	if ((bScopeView ) || bScopeHeld)
		return false;
	return true;
}
simulated function bool AllowWeapNextUI()
{
	if ((bScopeView ) || bScopeHeld)
		return false;
	return true;
}

simulated event RenderOverlays (Canvas C)
{
	local float	ScaleFactor;//, XL, XY;


    if (!bScopeView)
	{
		super.RenderOverlays(C);
		return;
	}

    SetLocation(Instigator.Location + Instigator.CalcDrawOffset(self));
	SetRotation(Instigator.GetViewRotation());
    ScaleFactor = C.ClipY / 1200;


    if (ScopeViewTex != None)
    {
        C.SetDrawColor(255,255,255,255);

        C.SetPos(C.OrgX, C.OrgY);
    	C.DrawTile(ScopeViewTex, (C.SizeX - C.SizeY)/2, C.SizeY, 0, 0, 1, 1);

        C.SetPos((C.SizeX - C.SizeY)/2, C.OrgY);
        C.DrawTile(ScopeViewTex, C.SizeY, C.SizeY, 0, 0, 1024, 1024);

        C.SetPos(C.SizeX - (C.SizeX - C.SizeY)/2, C.OrgY);
        C.DrawTile(ScopeViewTex, (C.SizeX - C.SizeY)/2, C.SizeY, 0, 0, 1, 1);
	}
}


simulated function StartScopeView()
{
    local PlayerController PC;

    PC = PlayerController(Instigator.Controller);

	if (PC != None)
	{
        	if (bPendingSightUp)
    			PC.DesiredFOV = OldZoomFOV;
      		else
      		{
    			PC.ZoomLevel = loge(MinZoom)/loge(MaxZoom);
            		PC.DesiredFOV = PC.DefaultFOV / 2**((loge(MaxZoom)/loge(2)) * PC.ZoomLevel);
        	}
    	}

    	SetScopeView(true);
	if (bPendingSightUp)
		bPendingSightUp=false;
	if (!bNeedCock)
		PlayIdle();
}

simulated function StopScopeView(optional bool bNoAnim)
{
    if (Instigator.Controller.IsA( 'PlayerController' ))
    {
        OldZoomFOV = PlayerController(Instigator.Controller).FovAngle;
	PlayerController(Instigator.Controller).ResetFOV();
    }
    SetScopeView(false);
	PlayScopeDown(bNoAnim);

    Instigator.Controller.bRun = 0;
}
simulated function ChangeZoom (float Value)
{
	local PlayerController PC;
	local float OldZoomLevel;
    	local float NewZoomLevel;


	PC = PlayerController(Instigator.Controller);
	if (PC == None)
		return;
	if (bInvertScope)
		Value*=-1;

    	OldZoomLevel = PC.ZoomLevel;
	NewZoomLevel = FClamp(PC.ZoomLevel + Value, loge(MinZoom)/loge(MaxZoom), 1.0);
	if (NewZoomLevel > OldZoomLevel)
	{
		ScopeViewTex=ScopeViewTex3X;
		if (ZoomInSound.Sound != None)	class'BUtil'.static.PlayFullSound(self, ZoomInSound);
		
	}
	else if (NewZoomLevel < OldZoomLevel)
	{	
		ScopeViewTex=ScopeViewTex1X;
		if (ZoomOutSound.Sound != None)	class'BUtil'.static.PlayFullSound(self, ZoomOutSound);
	}

	PC.ZoomLevel = NewZoomLevel;
    	PC.DesiredFOV = FClamp(PC.DefaultFOV / 2**((loge(MaxZoom)/loge(2)) * PC.ZoomLevel), 1, 170);
}
//More consistent zooming increments when scope view
simulated function Weapon PrevWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
	if (bScopeHeld)
        	return none;
    	// Adjust zoom level when in scope...
	if (bScopeView && CurrentWeapon == self)
	{
		ChangeZoom(1/ZoomIncrements);
		return None;
	}

    if ( HasAmmo() )
    {
        if ( (CurrentChoice == None) )
        {
            if ( CurrentWeapon != self )
                CurrentChoice = self;
        }
        else if ( InventoryGroup == CurrentWeapon.InventoryGroup )
        {
            if ( (GroupOffset < CurrentWeapon.GroupOffset)
                && ((CurrentChoice.InventoryGroup != InventoryGroup) || (GroupOffset > CurrentChoice.GroupOffset) || (CurrentWeapon.GroupOffset < CurrentChoice.GroupOffset)) )
                CurrentChoice = self;
		}
        else if ( InventoryGroup == CurrentChoice.InventoryGroup )
        {
            if ( GroupOffset > CurrentChoice.GroupOffset )
                CurrentChoice = self;
        }
        else if ( InventoryGroup > CurrentChoice.InventoryGroup )
        {
			if ( (InventoryGroup < CurrentWeapon.InventoryGroup)
                || (CurrentChoice.InventoryGroup > CurrentWeapon.InventoryGroup) )
                CurrentChoice = self;
        }
        else if ( (CurrentChoice.InventoryGroup > CurrentWeapon.InventoryGroup)
                && (InventoryGroup < CurrentWeapon.InventoryGroup) )
            CurrentChoice = self;
        else if ( InventoryGroup < CurrentChoice.InventoryGroup &&
        		CurrentChoice.InventoryGroup == CurrentWeapon.InventoryGroup &&
        		CurrentChoice.GroupOffset > CurrentWeapon.GroupOffset &&
				InventoryGroup < CurrentWeapon.InventoryGroup)
            CurrentChoice = self;
    }
    if ( Inventory == None )
        return CurrentChoice;
    else
		return Inventory.PrevWeapon(CurrentChoice,CurrentWeapon);
}
//Better zooming increments when scope view
simulated function Weapon NextWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
	// Adjust zoom level when in scope...
	if (bScopeHeld)
        return none;
    if (bScopeView && CurrentWeapon == self)
	{
		ChangeZoom(-1/ZoomIncrements);
		return None;
	}

    if (bScopeHeld)
        return none;

    if ( HasAmmo() )
    {
        if ( (CurrentChoice == None) )
        {
            if ( CurrentWeapon != self )
                CurrentChoice = self;
        }
        else if ( InventoryGroup == CurrentWeapon.InventoryGroup )
        {
            if ( (GroupOffset > CurrentWeapon.GroupOffset)
                && ((CurrentChoice.InventoryGroup != InventoryGroup) || (GroupOffset < CurrentChoice.GroupOffset) || (CurrentWeapon.GroupOffset > CurrentChoice.GroupOffset)) )
                CurrentChoice = self;
        }
        else if ( InventoryGroup == CurrentChoice.InventoryGroup )
        {
			if ( GroupOffset < CurrentChoice.GroupOffset )
                CurrentChoice = self;
        }

        else if ( InventoryGroup < CurrentChoice.InventoryGroup )
        {
            if ( (InventoryGroup > CurrentWeapon.InventoryGroup)
                || (CurrentChoice.InventoryGroup < CurrentWeapon.InventoryGroup) )
                CurrentChoice = self;
        }
        else if ( (CurrentChoice.InventoryGroup < CurrentWeapon.InventoryGroup)
                && (InventoryGroup > CurrentWeapon.InventoryGroup) )
            CurrentChoice = self;
        else if ( InventoryGroup > CurrentChoice.InventoryGroup &&
        		CurrentChoice.InventoryGroup == CurrentWeapon.InventoryGroup &&
        		CurrentChoice.GroupOffset < CurrentWeapon.GroupOffset &&
				InventoryGroup > CurrentWeapon.InventoryGroup)
            CurrentChoice = self;
    }
    if ( Inventory == None )
        return CurrentChoice;
    else
        return Inventory.NextWeapon(CurrentChoice,CurrentWeapon);
}
simulated function bool PutDown()
{
    StopScopeView();
    return super.PutDown();
}
simulated function Destroyed()
{
    StopScopeView();

    super.Destroyed();
}

//=====================================================================
// SUPPRESSOR CODE
//=====================================================================


function ServerSwitchSilencer(bool bNewValue)
{
	if (!Instigator.IsLocallyControlled())
		JSOCPrimaryFire(FireMode[0]).SwitchSilencerMode(bNewValue);
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
	JSOCPrimaryFire(FireMode[0]).SwitchSilencerMode(bNewValue);
	if (bNewValue)
		PlayAnim(SilencerOnAnim);
	else
		PlayAnim(SilencerOffAnim);
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
simulated function Notify_SilencerHide()
{
	SetBoneScale (0, 0.0, SilencerBone);
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp(PrevWeapon);

	if (AIController(Instigator.Controller) != None)
		bSilenced = (FRand() > 0.5);

	if (bSilenced)
		SetBoneScale (0, 1.0, SilencerBone);
	else
		SetBoneScale (0, 0.0, SilencerBone);
}


//=======================================
//		BOT CODE
//=======================================

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
     ZoomStages=1.000000
     MinZoom=1.000000
     MaxZoom=3.000000
	 ZoomType=ZT_Logarithmic
//    FullZoomFOV=45.000000
//     FullZoomFOV=0.900000
	 
	 SilencerBone="Silencer"
     SilencerOnAnim="SilencerOn"
     SilencerOffAnim="SilencerOff"
     SilencerOnSound=Sound'BallisticSounds2.XK2.XK2-SilenceOn'
     SilencerOffSound=Sound'BallisticSounds2.XK2.XK2-SilenceOff'
     SilencerOnTurnSound=SoundGroup'BallisticSounds2.XK2.XK2-SilencerTurn'
     SilencerOffTurnSound=SoundGroup'BallisticSounds2.XK2.XK2-SilencerTurn'
	 
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=1.000000
     PlayerSpeedFactor=0.900000
     BigIconMaterial=Texture'BWBP_SKC_Tex.M30A2.BigIcon_M30A2'
     BallisticInventoryGroup=6
     SightFXClass=Class'BallisticFix.M50SightLEDs'
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Bullet=True
     SpecialInfo(0)=(Info="320.0;25.0;1.0;110.0;0.8;0.5;0.0")
     BringUpSound=(Sound=Sound'BallisticSounds2.M50.M50Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.M50.M50Putaway')
     MagAmmo=100
     InventorySize=40
     AimSpread=(X=(Min=-32.000000,Max=32.000000),Y=(Min=-32.000000,Max=32.000000))
     CockAnimPostReload="ReloadEndCock"
     CockSound=(Sound=Sound'BallisticSounds2.M50.M50Cock')
     ClipHitSound=(Sound=Sound'BallisticSounds2.M50.M50ClipHit')
     ClipOutSound=(Sound=Sound'BWBP_SKC_SoundsExp.JSOC.JSOC-MagOut')
     ClipInSound=(Sound=Sound'BWBP_SKC_SoundsExp.JSOC.JSOC-MagIn')
     ClipInFrame=0.650000
     	ReloadAnimRate=1.0
     bNeedCock=True
     WeaponModes(0)=(ModeName="Semi-Automatic")
     CurrentWeaponMode=2
     bNoCrosshairInScope=true
     ScopeViewTex=Texture'BWBP_SKC_TexExp.MG36.G36ScopeViewDot'
     ScopeViewTex1X=Texture'BWBP_SKC_TexExp.MG36.G36ScopeViewDot'
     ScopeViewTex3X=Texture'BWBP_SKC_TexExp.MG36.G36ScopeView'
     ZoomInSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomIn',Volume=0.500000,Pitch=1.000000)
     ZoomOutSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomOut',Volume=0.500000,Pitch=1.000000)

     	ChaosDeclineTime=1.500000
     	RecoilDeclineDelay=0.3
	RecoilDeclineTime=2.2
	RecoilMax=1600
     bNoMeshInScope=True
     SightOffset=(X=10.000000,Y=-0.500000,Z=25.000000)
//     SightDisplayFOV=20.000000
     SightDisplayFOV=36.000000
//     DisplayFOV=55.000000
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.M353OutA',Pic2=Texture'BallisticUI2.Crosshairs.M50InA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=0,G=0,R=255,A=197),Color2=(B=0,G=255,R=255,A=255),StartSize1=79,StartSize2=55)
     CrouchAimFactor=0.500000
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     ViewAimFactor=0.300000
     ViewRecoilFactor=0.700000
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.300000),(InVal=0.800000,OutVal=-0.400000),(InVal=1.000000,OutVal=-0.200000)))
     RecoilYCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.650000),(InVal=0.600000,OutVal=0.800000),(InVal=0.800000,OutVal=0.900000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYawFactor=0.300000
     RecoilXFactor=0.200000
     RecoilYFactor=0.200000
     FireModeClass(0)=Class'BWBP_SKC_Fix.JSOCPrimaryFire'
     FireModeClass(1)=Class'BCoreFix.BallisticScopeFire'
     PutDownTime=0.700000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.600000
     CurrentRating=0.600000
     Description="JSOC Mk.88 Light Support Weapon||Manufacturer: Majestic Firearms 12|Primary: 5.56mm CAP Rifle Rounds|Secondary: Deploy Bipod|Special: Shock Defense System||A limited production weapon, the Mk.88 was Majestic's first foray into infantry support weaponry. After the first Skrith war jump-started the ballistic weapons business, Majestic Firearms 12 designed the Mk.88 to replace the aging M353's still in use by the UTC. The fast-firing and powerful Mk.88 was well received by troops, however its high recoil and prohibitive cost prevented it from seeing mainstream adoption. The Mk.88 currently sees limited service in special operations units and private military groups."
     Priority=65
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=9
     PickupClass=Class'BWBP_SKC_Fix.MG33Pickup'
     PlayerViewOffset=(X=10.000000,Y=7.000000,Z=-15.000000)
     BobDamping=2.000000
     AttachmentClass=Class'BWBP_SKC_Fix.MG33Attachment'
     IconMaterial=Texture'BWBP_SKC_Tex.M30A2.SmallIcon_M30A2'
     IconCoords=(X2=127,Y2=31)
     ItemName="[B]JSOC Mk.88 LSW"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=4.000000
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.MG36_FP'
     DrawScale=0.350000
	 ViewAimScale=0.3
	 ViewRecoilScale=0.3
}
