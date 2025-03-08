class RudolphGoatComponent extends GGMutatorComponent;

var GGGoat gMe;
var GGMutator myMut;

var StaticMeshComponent redNose;
var StaticMeshComponent horns;
var ParticleSystem redGlowTemplate;
var ParticleSystemComponent redGlow;
var ParticleSystem vanishTemplate;
var AnimTree mOldAnimTreeTemplate;

/**
 * See super.
 */
function AttachToPlayer( GGGoat goat, optional GGMutator owningMutator )
{
	super.AttachToPlayer(goat, owningMutator);

	if(mGoat != none)
	{
		gMe=goat;
		myMut=owningMutator;

		redNose.SetLightEnvironment( gMe.mesh.LightEnvironment );
		gMe.mesh.AttachComponentToSocket( redNose, 'hairSocket' );
		horns.SetLightEnvironment( gMe.mesh.LightEnvironment );
		gMe.mesh.AttachComponentToSocket( horns, 'hairSocket' );
		redGlow = gMe.WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment( redGlowTemplate, gMe.mesh, 'hairSocket', true );
		redGlow.SetScale3D(vect(0.05f, 0.05f, 0.05f));
		redGlow.SetTranslation(vect(0.f, 21.f, -9.f));
	}
}

function KeyState( name newKey, EKeyState keyState, PlayerController PCOwner )
{
	local GGPlayerInputGame localInput;

	if(PCOwner != gMe.Controller)
		return;

	localInput = GGPlayerInputGame( PCOwner.PlayerInput );

	if( keyState == KS_Down )
	{
		if(localInput.IsKeyIsPressed( "GBA_Baa", string( newKey ) ))
		{
			gMe.SetTimer(2.0f, false, NameOf( SwitchGoatRider ), self);
			//ShowDebugInfos();
		}
	}
	else if( keyState == KS_Up )
	{
		if(localInput.IsKeyIsPressed( "GBA_Baa", string( newKey ) ))
		{
			if(gMe.IsTimerActive(NameOf( SwitchGoatRider ), self))
			{
				gMe.ClearTimer(NameOf( SwitchGoatRider ), self);
			}
		}
	}
}

function ShowDebugInfos()
{
	myMut.WorldInfo.Game.Broadcast(myMut, "Rider=" $ gMe.mGoatRider);
	if(gMe.mGoatRider == none)
		return;

 	myMut.WorldInfo.Game.Broadcast(myMut, "Physics=" $ gMe.mGoatRider.Physics);
 	myMut.WorldInfo.Game.Broadcast(myMut, "CollisionType=" $ gMe.mGoatRider.CollisionType);
 	myMut.WorldInfo.Game.Broadcast(myMut, "PhysicsAsset=" $ gMe.mGoatRider.mesh.PhysicsAsset);
 	myMut.WorldInfo.Game.Broadcast(myMut, "IsHuman=" $ IsHuman(gMe.mGoatRider));
}

function SwitchGoatRider()
{
	if(gMe.mGoatRider == none)
	{
		GetGoatRider(GetClosestNpc());
	}
	else
	{
		RemoveGoatRider();
	}
}

/**
 * Spawn an NPC and make it the goat rider!
 */
function GetGoatRider(GGNpc npc)
{
    local GGAIController oldContr;

	if(gMe.mGoatRider != none)
        return;

	if(npc.mIsRagdoll)
	{
		npc.SetRagdoll(false);
	}

	gMe.mGoatRider = npc;
	oldContr=GGAIController(npc.Controller);
	MakeGoatRider();
	SetMeshOffset();
	if(oldContr != none)
	{
		oldContr.Destroy();
	}
}

function MakeGoatRider()
{
	local name boneName;
	local GGNpc npc;

	npc=gMe.mGoatRider;
	if(npc == none)
		return;

	gMe.mActorsToIgnoreBlockingBy.AddItem( npc );
	npc.RideTheGoat( gMe );
	npc.CollisionComponent.SetActorCollision(false, false);
	npc.CollisionComponent.SetBlockRigidBody(false);
	npc.CollisionComponent.SetNotifyRigidBodyCollision(false);
	gMe.mesh.AttachComponent(npc.mesh, 'Spine_01');
	if(IsZero(gMe.mesh.GetBoneLocation('Spine_01')))
	{
		gMe.mesh.AttachComponent(npc.mesh, 'Root', vect(0, 0, 1) * gMe.GetCollisionHeight());
	}
	npc.mesh.SetLightEnvironment( gMe.mesh.LightEnvironment );
	// Fix bone update
	npc.mesh.MinDistFactorForKinematicUpdate = 0.0f;
	npc.mesh.ForceSkelUpdate();
	npc.mesh.UpdateRBBonesFromSpaceBases( true, true );
	// Fix random animatons playing
	mOldAnimTreeTemplate=npc.mesh.AnimTreeTemplate;
	npc.mesh.SetAnimTreeTemplate(none);
	npc.mAnimNodeSlot=none;

	//Multiple
	boneName = 'Back_Thigh_R';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	boneName = 'Back_Thigh_L';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	boneName = 'Front_Thigh_R';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	boneName = 'Front_Thigh_L';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	boneName = 'Tail_01';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	//G2
	boneName = 'Arm_R';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	boneName = 'Arm_L';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	boneName = 'Ear_R';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	boneName = 'Ear_L';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	//Donkey & Pig
	boneName = 'Quadruped_Skeleton_Spine2';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	boneName = 'Quadruped_Skeleton_BLFemur';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	boneName = 'Quadruped_Skeleton_BRFemur';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	boneName = 'Quadruped_Skeleton_Tail1';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	//Baguette
	boneName = 'upper_tip';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	boneName = 'lower_tip';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	//Cat
	boneName = 'R_Tight';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	boneName = 'L_Tight';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	//Chihuahua
	boneName = 'Hip';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	boneName = 'Shoulders';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	//Goats
	boneName = 'Neck';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	//Microwave
	boneName = 'Cable_01';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	boneName = 'door';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	//Spider
	boneName = 'Sack_01';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	boneName = 'Back_Thigh_L_02';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	boneName = 'Back_Thigh_R_02';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	//Bread
	boneName = 'bread_tl_corner';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	boneName = 'bread_tr_corner';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	boneName = 'bread_bl_corner';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	boneName = 'bread_br_corner';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	//Cow
	boneName = 'Udders';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );
	//Dobomination
	boneName = 'Wing_R_02';
	npc.mesh.PhysicsAssetInstance.ForceAllBodiesBelowUnfixed( boneName, npc.mesh.PhysicsAsset, npc.mesh, true );

}

function OnPlayerRespawn( PlayerController respawnController, bool died )
{
	super.OnPlayerRespawn(respawnController, died);

	GetGoatRider(RemoveGoatRider());
}

function SetMeshOffset()
{
	local vector offset;

	if(gMe.mIsRagdoll)
		return;

	if(gMe.mActorsToIgnoreBlockingBy.Find(gMe.mGoatRider) == INDEX_NONE)
	{
		gMe.mActorsToIgnoreBlockingBy.AddItem( gMe.mGoatRider );
	}

	if(gMe.mGoatRider.mIsRagdoll)
	{
		gMe.mGoatRider.SetRagdoll(false);
	}

	offset=gMe.mGoatRider.default.mesh.Translation;
	if(IsHuman(gMe.mGoatRider))
	{
		//offset.X+=43.787167f;// Cancel sitting position offset
		//offset.Z+=55.074585f;
		offset.Z+=-gMe.mGoatRider.GetCollisionHeight()*0.7f;
	}
	if(IsZero(gMe.mesh.GetBoneLocation('Spine_01')))
	{
		offset.Z+=gMe.GetCollisionHeight();
	}
	offset.X+=gMe.GetCollisionRadius() - gMe.mGoatRider.GetCollisionRadius();
	offset.Z+=gMe.mGoatRider.GetCollisionHeight() - 15.f;

	gMe.mGoatRider.mesh.SetTranslation(offset);
	//gMe.DrawDebugSphere(gMe.mGoatRider.mesh.GetPosition(), 8, 8, 255, 255, 255, true);
}

function bool IsHuman(GGPawn gpawn)
{
	local GGAIControllerMMO AIMMO;

	if(InStr(string(gpawn.Mesh.PhysicsAsset), "CasualGirl_Physics") != INDEX_NONE)
	{
		return true;
	}
	else if(InStr(string(gpawn.Mesh.PhysicsAsset), "CasualMan_Physics") != INDEX_NONE)
	{
		return true;
	}
	else if(InStr(string(gpawn.Mesh.PhysicsAsset), "SportyMan_Physics") != INDEX_NONE)
	{
		return true;
	}
	else if(InStr(string(gpawn.Mesh.PhysicsAsset), "HeistNPC_Physics") != INDEX_NONE)
	{
		return true;
	}
	else if(InStr(string(gpawn.Mesh.PhysicsAsset), "Explorer_Physics") != INDEX_NONE)
	{
		return true;
	}
	else if(InStr(string(gpawn.Mesh.PhysicsAsset), "SpaceNPC_Physics") != INDEX_NONE)
	{
		return true;
	}
	AIMMO=GGAIControllerMMO(gpawn.Controller);
	if(AIMMO == none)
	{
		return false;
	}
	else
	{
		return AIMMO.PawnIsHuman();
	}
}

/**
 * Remove goat rider
 */
function GGNpc RemoveGoatRider()
{
    local vector loc;
    local GGNpc newNpc;

	if( gMe.mGoatRider != none )
    {
		newNpc=RespawnGoatRider();
		gMe.mesh.GetSocketWorldLocationAndRotation('RideSocket', loc);
		if(IsZero(loc))
		{
			loc=gMe.mesh.GetPosition() + (vect(0, 0, 1) * gMe.GetCollisionHeight());
		}
		gMe.WorldInfo.MyEmitterPool.SpawnEmitter( vanishTemplate, loc );
		gMe.RemoveGoatRider();
    }

    return newNpc;
}

function GGNpc RespawnGoatRider()
{
	local vector spawnLoc;
	local rotator spawnRot;
	local GGNpc newNpc, oldNpc;
	local GGNPCMMOAbstract newNpcMMO, oldNpcMMO;
	local GGNpcZombieGameModeAbstract newZombie, oldZombie;
	local GGNpcHeist newHeist, oldHeist;
	local array< Actor > attachedActorsCopy;
	local Actor attachedActor;
	local bool attachedActorHardAttach;
	local vector attachedRelativeLoc;
	local rotator attachedRelativeRot;
	local name attachedBoneName;

	oldNpc=gMe.mGoatRider;
	if(oldNpc == none)
		return none;
	//Spawn randomly left or right
	spawnLoc=gMe.mesh.GetPosition() + Normal(vector(gMe.Rotation + rot(0, 16384, 0))) * (gMe.GetCollisionRadius() + oldNpc.GetCollisionRadius() + 1.f) * (2*Rand(2)-1);
	spawnLoc.Z += gMe.mGoatRider.GetCollisionHeight();
	spawnRot.Yaw=gMe.Rotation.Yaw;
	newNpc=gMe.Spawn(oldNpc.class,,, spawnLoc, spawnRot,, true);

	if(oldNpc.mesh.SkeletalMesh != none) newNpc.mesh.SetSkeletalMesh( oldNpc.mesh.SkeletalMesh );
	if(oldNpc.mesh.PhysicsAsset != none) newNpc.mesh.SetPhysicsAsset( oldNpc.Mesh.PhysicsAsset );
	if(oldNpc.mesh.Materials.Length > 0) newNpc.mesh.SetMaterial( 0, oldNpc.mesh.GetMaterial( 0 ) );
	if(mOldAnimTreeTemplate != none) newNpc.mesh.SetAnimTreeTemplate( mOldAnimTreeTemplate );
	if(oldNpc.mesh.AnimSets[0] != none) newNpc.mesh.AnimSets[0] = oldNpc.mesh.AnimSets[0];

	newNpc.mesh.SetScale(oldNpc.mesh.Scale);
	newNpc.mesh.SetScale3D(oldNpc.mesh.Scale3D);

	newNpc.SetReactionSounds();//Fix sounds after changing mesh

	// We need to do this because objects in the array can't be removed while iterating over it.
	attachedActorsCopy = oldNpc.Attached;

	// Go through each attached actor and attach them to the new npc
	foreach attachedActorsCopy( attachedActor )
	{
		attachedRelativeLoc = attachedActor.RelativeLocation;
		attachedRelativeRot = attachedActor.RelativeRotation;
		attachedActorHardAttach = attachedActor.bHardAttach;
		attachedBoneName = attachedActor.BaseBoneName;

		attachedActor.SetBase( none );

		if( attachedBoneName != '' )
		{
			attachedActor.SetBase( newNpc,, newNpc.mesh, attachedBoneName );
		}
		else
		{
			attachedActor.SetBase( newNpc,, newNpc.mesh );
		}
		attachedActor.SetHardAttach( attachedActorHardAttach );
		attachedActor.SetRelativeLocation( attachedRelativeLoc );
		attachedActor.SetRelativeRotation( attachedRelativeRot );
		attachedActor.SetCollision( false, false );
	}

	newNpc.mDefaultAnimationInfo=oldNpc.mDefaultAnimationInfo.AnimationNames.Length>0?oldNpc.mDefaultAnimationInfo:newNpc.mDefaultAnimationInfo;
	newNpc.mDanceAnimationInfo=oldNpc.mDanceAnimationInfo.AnimationNames.Length>0?oldNpc.mDanceAnimationInfo:newNpc.mDanceAnimationInfo;
	newNpc.mPanicAtWallAnimationInfo=oldNpc.mPanicAtWallAnimationInfo.AnimationNames.Length>0?oldNpc.mPanicAtWallAnimationInfo:newNpc.mPanicAtWallAnimationInfo;
	newNpc.mPanicAnimationInfo=oldNpc.mPanicAnimationInfo.AnimationNames.Length>0?oldNpc.mPanicAnimationInfo:newNpc.mPanicAnimationInfo;
	newNpc.mAttackAnimationInfo=oldNpc.mAttackAnimationInfo.AnimationNames.Length>0?oldNpc.mAttackAnimationInfo:newNpc.mAttackAnimationInfo;
	newNpc.mAngryAnimationInfo=oldNpc.mAngryAnimationInfo.AnimationNames.Length>0?oldNpc.mAngryAnimationInfo:newNpc.mAngryAnimationInfo;
	newNpc.mIdleAnimationInfo=oldNpc.mIdleAnimationInfo.AnimationNames.Length>0?oldNpc.mIdleAnimationInfo:newNpc.mIdleAnimationInfo;
	newNpc.mApplaudAnimationInfo=oldNpc.mApplaudAnimationInfo.AnimationNames.Length>0?oldNpc.mApplaudAnimationInfo:newNpc.mApplaudAnimationInfo;
	newNpc.mRunAnimationInfo=oldNpc.mRunAnimationInfo.AnimationNames.Length>0?oldNpc.mRunAnimationInfo:newNpc.mRunAnimationInfo;
	newNpc.mNoticeGoatAnimationInfo=oldNpc.mNoticeGoatAnimationInfo.AnimationNames.Length>0?oldNpc.mNoticeGoatAnimationInfo:newNpc.mNoticeGoatAnimationInfo;
	newNpc.mIdleSittingAnimationInfo=oldNpc.mIdleSittingAnimationInfo.AnimationNames.Length>0?oldNpc.mIdleSittingAnimationInfo:newNpc.mIdleSittingAnimationInfo;

	newNpc.mStandUpBoneName=oldNpc.mStandUpBoneName;
	newNpc.mAttackRange=oldNpc.mAttackRange;
	newNpc.mAttackMomentum=oldNpc.mAttackMomentum;

	newNpc.mApplaudAndNoticeGoat=oldNpc.mApplaudAndNoticeGoat;
	newNpc.mNPCSoundEnabled=oldNpc.mNPCSoundEnabled;
	newNpc.mCanBeAddedToInventory=oldNpc.mCanBeAddedToInventory;
	newNpc.mPickupSocketName=oldNpc.mPickupSocketName;
	newNpc.mCanPanic=oldNpc.mCanPanic;

	oldNpcMMO=GGNPCMMOAbstract(oldNpc);
	if(oldNpcMMO != none)
	{
		newNpcMMO=GGNPCMMOAbstract(newNpc);

		newNpcMMO.mNPCName=oldNpcMMO.mNPCName;
		newNpcMMO.mHealth=oldNpcMMO.mHealth;
		newNpcMMO.mRagdollLifeSpan=oldNpcMMO.mRagdollLifeSpan;
		newNpcMMO.mNameTagBoneName=oldNpcMMO.mNameTagBoneName;
		newNpcMMO.mNameTagColor=oldNpcMMO.mNameTagColor;
		newNpcMMO.mKnockedOverSounds=oldNpcMMO.mKnockedOverSounds;
		if( newNpcMMO.mHealth <= 0 )
		{
			newNpcMMO.mNameTagColor = MakeColor( 128, 128, 128, 255 );
			newNpcMMO.LifeSpan = newNpcMMO.mRagdollLifeSpan;
		}
	}

	oldZombie=GGNpcZombieGameModeAbstract(oldNpc);
	if(oldZombie != none)
	{
		newZombie=GGNpcZombieGameModeAbstract(newNpc);

		newZombie.mHealth=oldZombie.mHealth;
		newZombie.mIsPendingDeath=oldZombie.mIsPendingDeath;
	}

	oldHeist=GGNpcHeist(oldNpc);
	if(oldHeist != none)
	{
		newHeist=GGNpcHeist(newNpc);

		newHeist.mPickupAnimationInfo=oldHeist.mPickupAnimationInfo.AnimationNames.Length>0?oldHeist.mPickupAnimationInfo:newHeist.mPickupAnimationInfo;
	}

	newNpc.SpawnDefaultController();
	AssignScriptedPath( newNpc, oldNpc );
	newNpc.SetPhysics( PHYS_Falling );

	return newNpc;
}

function AssignScriptedPath( GGNPC newNpc, GGNPC oldNpc )
{
	local Pathnode node;

	newNpc.mAutoPathToNewObjects = oldNpc.mAutoPathToNewObjects;
	newNpc.mUseScriptedRoute = oldNpc.mUseScriptedRoute;
	newNpc.mScriptedRouteType = oldNpc.mScriptedRouteType;
	newNpc.mScriptedPath = oldNpc.mScriptedPath;
	if(newNpc.mUseScriptedRoute && newNpc.mScriptedPath.Length == 0)
	{
		foreach myMut.AllActors(class'Pathnode', node)
		{
			newNpc.mScriptedPath.AddItem(node);
		}
		if(newNpc.mScriptedPath.Length > 0)
		{
			newNpc.mScriptedRouteType=SRT_RANDOM;
		}
		else
		{
			newNpc.mUseScriptedRoute=false;
		}
	}

	GGAIController( newNpc.Controller ).ResumeDefaultAction();
}

function GGNpc GetClosestNpc()
{
	local GGNpc npc, currentNpc;

	currentNpc = none;

	foreach gMe.VisibleCollidingActors(class'GGNpc', npc, 7500, gMe.mesh.GetPosition())
	{
		if(!npc.IsInState( 'GoatRider' ))
		{
			if(currentNpc == none || (VSize(npc.mesh.GetPosition() - gMe.mesh.GetPosition()) < VSize(currentNpc.mesh.GetPosition() - gMe.mesh.GetPosition())))
			{
				currentNpc = npc;
			}
		}
	}

	return currentNpc;
}

function OnRagdoll( Actor ragdolledActor, bool isRagdoll )
{
	if(gMe.mGoatRider != none)
	{
		if((!isRagdoll && ragdolledActor == gMe)
		|| (isRagdoll && ragdolledActor == gMe.mGoatRider))
		{
			SetMeshOffset();
		}
	}
}

function OnLanded( Actor actorLanded, Actor actorLandedOn )
{
	if(gMe.mGoatRider != none && actorLanded == gMe)
	{
		SetMeshOffset();
	}
}

simulated event TickMutatorComponent( float delta )
{
	if(gMe.mGoatRider != none)
	{
		if(gMe.mGrabbedItem == gMe.mGoatRider)
		{
			gMe.DropGrabbedItem();
			SetMeshOffset();
		}
		gMe.mGoatRider.mIsRagdollAllowed=false;
	}
}

defaultproperties
{
	Begin Object class=StaticMeshComponent Name=StaticMeshComp1
		StaticMesh=StaticMesh'Food.Mesh.Food_AppleRed_01'
		Rotation=(Yaw=0,Pitch=32768,Roll=0)
		Translation=(X=0,Y=21,Z=-5)
		Scale=0.2f
	End Object
	redNose=StaticMeshComp1

	Begin Object class=StaticMeshComponent Name=StaticMeshComp2
		StaticMesh=StaticMesh'Hats.Mesh.HornedWood'
		Translation=(X=-0.5,Y=-1,Z=-0.6)
		Scale=0.66f
	End Object
	horns=StaticMeshComp2

	redGlowTemplate=ParticleSystem'Zombie_Particles.Particles.Crate_Light_PS'
	vanishTemplate=ParticleSystem'MMO_Effects.Effects.Effects_Hit_Props_Metall_01'
}