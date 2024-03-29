' Copyright (c) 2008-2022 Bruce A Henderson
' 
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
' 
' The above copyright notice and this permission notice shall be included in
' all copies or substantial portions of the Software.
' 
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
' THE SOFTWARE.
' 
SuperStrict

Rem
bbdoc: Box2D
End Rem
Module Physics.Box2D

ModuleInfo "Version: 1.07"
ModuleInfo "License: MIT"
ModuleInfo "Copyright: Box2D (c) 2006-2016 Erin Catto http://www.gphysics.com"
ModuleInfo "Copyright: BlitzMax port - 2008-2022 Bruce A Henderson"

ModuleInfo "History: 1.07"
ModuleInfo "History: Fixed for macOS build."
ModuleInfo "History: Refactored to use some more structs."
ModuleInfo "History: 1.06"
ModuleInfo "History: Refactored to use structs where appropriate."
ModuleInfo "History: 1.05"
ModuleInfo "History: Updated for NG"
ModuleInfo "History: 1.04"
ModuleInfo "History: Updated to box2d svn (rev 207)"
ModuleInfo "History: Added b2LineJoint type."
ModuleInfo "History: Added b2ShapeDef.SetUserData() method."
ModuleInfo "History: Added b2Mat22.GetAngle() method."
ModuleInfo "History: Added b2Mat22 Create... methods, and others."
ModuleInfo "History: Added shape SetFriction() and SetRestitution() methods."
ModuleInfo "History: Fixed contact filter example and docs."
ModuleInfo "History: Added b2EdgeShape type."
ModuleInfo "History: Added staticedges, dynamicedges, pyramidstaticedges and buoyancy examples."
ModuleInfo "History: Added buoyancy types + methods."
ModuleInfo "History: Added b2Body SetMass() method."
ModuleInfo "History: Added b2BodyDef GetMassData() method."
ModuleInfo "History: Converted bool handling in glue to use ints instead."
ModuleInfo "History: Added b2Vec2 SetX() and SetY() methods."
ModuleInfo "History: 1.03"
ModuleInfo "History: Updated to box2d svn (rev 172)"
ModuleInfo "History: Added b2CircleShape and b2PolygonShape types."
ModuleInfo "History: Added b2OBB type."
ModuleInfo "History: Added b2Segment type."
ModuleInfo "History: Added b2World Raycast(), RaycastOne() and InRange() methods."
ModuleInfo "History: Added b2Body.GetWorld() method."
ModuleInfo "History: Added raycast example."
ModuleInfo "History: 1.02"
ModuleInfo "History: Updated to box2d svn (rev 169)"
ModuleInfo "History: API CHANGES : DoStep() - changed iteration parameters"
ModuleInfo "History: API CHANGES : joints - GetReactionForce() And GetReactionTorque() added 'dt' parameter."
ModuleInfo "History: Added car example."
ModuleInfo "History: Added revolute example."
ModuleInfo "History: Added b2ShapeDef - SetIsSensor and IsSensor methods."
ModuleInfo "History: Fixed typo in b2ContactListener - Remove()."
ModuleInfo "History: Added b2World.Refilter() and several missing b2Shape methods."
ModuleInfo "History: Updated Documentation."
ModuleInfo "History: 1.01"
ModuleInfo "History: Fixed filterdata problem. Fixed collisionfiltering example."
ModuleInfo "History: Added Theo Jansen example."
ModuleInfo "History: 1.00 Initial Release"

Import "common.bmx"

' NOTES :
'  b2Controller.h - Added userData fields/methods.
'
'  b2Math.h - added __APPLE__ test for isfinite() use.
'

Rem
bbdoc: The world type manages all physics entities, dynamic simulation, and asynchronous queries. 
about: The world also contains efficient memory management facilities. 
End Rem
Type b2World

	Field b2ObjectPtr:Byte Ptr
	
	Field filter:b2ContactFilter
	Field contactListener:b2ContactListener
	Field boundaryListener:b2BoundaryListener
	Field destructionListener:b2DestructionListener

	Field groundBody:b2Body
	
	Function _create:b2World(b2ObjectPtr:Byte Ptr)
		If b2ObjectPtr Then
			Local this:b2World = New b2World
			this.b2ObjectPtr = b2ObjectPtr
			Return this
		End If
	End Function

	Rem
	bbdoc: Construct a world object. 
	End Rem
	Function CreateWorld:b2World(worldAABB:b2AABB, gravity:b2Vec2, doSleep:Int)
		Return New b2World.Create(worldAABB, gravity, doSleep)
	End Function
	
	Rem
	bbdoc: Construct a world object. 
	End Rem
	Method Create:b2World(worldAABB:b2AABB, gravity:b2Vec2, doSleep:Int)
		b2ObjectPtr = bmx_b2world_create(worldAABB, gravity, doSleep)
		
		' setup default destruction listener
		SetDestructionListener(New b2DestructionListener)
		
		Return Self
	End Method

	Method Free()
		If b2ObjectPtr Then
			bmx_b2world_free(b2ObjectPtr)
			b2ObjectPtr = Null
		End If
	End Method
	
	Method Delete()
		Free()
	End Method
	
	Rem
	bbdoc: Register a destruction listener.
	End Rem
	Method SetDestructionListener(listener:b2DestructionListener)
		destructionListener = listener
		bmx_b2world_setdestructionlistener(b2ObjectPtr, listener.b2ObjectPtr)
	End Method

	Rem
	bbdoc: Register a broad-phase boundary listener.
	End Rem
	Method SetBoundaryListener(listener:b2BoundaryListener)
		boundaryListener = listener
		bmx_b2world_setboundarylistener(b2ObjectPtr, listener.b2ObjectPtr)
	End Method

	Rem
	bbdoc: Register a contact filter to provide specific control over collision.
	about: Otherwise the default filter is used.
	End Rem
	Method SetFilter(_filter:b2ContactFilter)
		filter = _filter
		bmx_b2world_setfilter(b2ObjectPtr, filter.b2ObjectPtr)
	End Method

	Rem
	bbdoc: Register a contact event listener
	End Rem
	Method SetContactListener(listener:b2ContactListener)
		contactListener = listener
		bmx_b2world_setcontactlistener(b2ObjectPtr, listener.b2ObjectPtr)
	End Method

	Rem
	bbdoc: Register a routine for debug drawing.
	about: The debug draw functions are called inside the b2World::DoStep method, so make sure your renderer is ready to
	consume draw commands when you call DoStep().
	End Rem
	Method SetDebugDraw(debugDraw:b2DebugDraw)
		bmx_b2world_setdebugDraw(b2ObjectPtr, debugDraw.b2ObjectPtr)
	End Method

	Rem
	bbdoc: Create a rigid body given a definition
	about: No reference to the definition is retained.
	<p>
	Warning: This method is locked during callbacks.
	</p>
	End Rem
	Method CreateBody:b2Body(def:b2BodyDef)
		Local body:b2Body = New b2Body
		body.userData = def.userData ' copy the userData
		body.b2ObjectPtr = bmx_b2world_createbody(b2ObjectPtr, def.b2ObjectPtr, body)
		Return body
	End Method

	Rem
	bbdoc: Destroy a rigid body given a definition.
	about: No reference to the definition is retained.
	<p>
	Warning: This automatically deletes all associated shapes and joints.
	</p>
	<p>
	Warning: This method is locked during callbacks.
	</p>
	End Rem
	Method DestroyBody(body:b2Body)
		bmx_b2world_destroybody(b2ObjectPtr, body.b2ObjectPtr)
	End Method

	Rem
	bbdoc: Create a joint to constrain bodies together.
	about: No reference to the definition is retained. This may cause the connected bodies to cease
	colliding.
	<p>
	Warning: This method is locked during callbacks.
	</p>
	End Rem
	Method CreateJoint:b2Joint(def:b2JointDef)
		Local joint:b2Joint = b2Joint._create(bmx_b2world_createjoint(b2ObjectPtr, def.b2ObjectPtr))
		joint.userData = def.userData ' copy the userData
		Return joint
	End Method
	
	' 
	Function _createJoint:b2Joint(jointType:Int) { nomangle }
		Local joint:b2Joint
		Select jointType
			Case e_unknownJoint
				joint = New b2Joint
			Case e_revoluteJoint
				joint = New b2RevoluteJoint
			Case e_prismaticJoint
				joint = New b2PrismaticJoint
			Case e_distanceJoint
				joint = New b2DistanceJoint
			Case e_pulleyJoint
				joint = New b2PulleyJoint
			Case e_mouseJoint
				joint = New b2MouseJoint
			Case e_gearJoint
				joint = New b2GearJoint
			Case e_lineJoint
				joint = New b2LineJoint
			Default
				DebugLog "Warning, joint type '" + jointType + "' is not defined in module."
				joint = New b2Joint
		End Select
		Return joint
	End Function

	Rem
	bbdoc: Destroy a joint.
	about: This may cause the connected bodies to begin colliding.
	<p>
	Warning: This method is locked during callbacks.
	</p>
	End Rem
	Method DestroyJoint(joint:b2Joint)
		bmx_b2world_destroyjoint(b2ObjectPtr, joint.b2ObjectPtr)
	End Method

	Rem
	bbdoc: Add a controller to the world.
	End Rem
	Method CreateController:b2Controller(def:b2ControllerDef)
		Local controller:b2Controller = b2Controller._create(bmx_b2world_createcontroller(b2ObjectPtr, def.b2ObjectPtr, def._type))
		controller.userData = def.userData ' copy the userData
		Return controller
	End Method
	' 
	Function __createController:b2Controller(controllerType:Int) { nomangle }
		Local controller:b2Controller
		Select controllerType
			Case e_buoyancyController
				controller = New b2BuoyancyController
			Case e_constantAccelController
				controller = New b2ConstantAccelController
			Case e_tensorDampingController
				controller = New b2TensorDampingController
			Case e_gravityController
				controller = New b2GravityController
			Case e_constantForceController
				controller = New b2ConstantForceController
			Default
				DebugLog "Warning, controller type '" + controllerType + "' is not defined in module."
				controller = New b2Controller
		End Select
		Return controller
	End Function

	Rem
	bbdoc: Removes a controller from the world.
	End Rem
	Method DestroyController(controller:b2Controller)
		bmx_b2world_destroycontroller(b2ObjectPtr, controller.b2ObjectPtr)
	End Method

	Rem
	bbdoc: The world provides a single static ground body with no collision shapes.
	about: You can use this to simplify the creation of joints and static shapes.
	End Rem
	Method GetGroundBody:b2Body()
		If Not groundBody Then
			groundBody = b2Body._create(bmx_b2world_getgroundbody(b2ObjectPtr))
		End If
		Return groundBody
	End Method

	Rem
	bbdoc: Take a time Step.
	about: This performs collision detection, integration, and constraint solution.
	<p>Parameters: 
	<ul>
	<li><b> timeStep </b> : the amount of time To simulate, this should Not vary. </li>
	<li><b> velocityIterations </b> : for the velocity constraint solver.</li>
	<li><b> positionIterations </b> : for the position constraint solver.</li>
	</ul>
	</p>
	End Rem
	Method DoStep(timeStep:Float, velocityIterations:Int, positionIterations:Int)
		bmx_b2world_dostep(b2ObjectPtr, timeStep, velocityIterations, positionIterations)
	End Method

	Rem
	bbdoc: Get the world body list. 
	returns: The head of the world body list. 
	about: With the returned body, use b2Body::GetNext to get the next body in the world list. A NULL body indicates
	the end of the list. 
	End Rem
	Method GetBodyList:b2Body()
		Return b2Body._create(bmx_b2world_getbodylist(b2ObjectPtr))
	End Method

	Rem
	bbdoc: Get the world joint list.
	returns: The head of the world joint list. 
	about: With the returned joint, use b2Joint::GetNext to get the next joint in the world list. A NULL joint indicates
	the end of the list.
	End Rem
	Method GetJointList:b2Joint()
		Return b2Joint._create(bmx_b2world_getjointlist(b2ObjectPtr))
	End Method

	Rem
	bbdoc: Enable/disable warm starting. For testing. 
	End Rem
	Method SetWarmStarting(flag:Int)
		bmx_b2world_setwarmstarting(b2ObjectPtr, flag)
	End Method

	Rem
	bbdoc: Enable/disable continuous physics. For testing. 
	End Rem
	Method SetContinuousPhysics(flag:Int)
		bmx_b2world_setcontinuousphysics(b2ObjectPtr, flag)
	End Method

	Rem
	bbdoc: Perform validation of internal data structures.
	End Rem
	Method Validate()
		bmx_b2world_validate(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc:  Change the global gravity vector.
	End Rem
	Method SetGravity(gravity:b2Vec2)
		bmx_b2world_setgravity(b2ObjectPtr, gravity)
	End Method
	
	Rem
	bbdoc: Get the number of broad-phase proxies.
	End Rem
	Method GetProxyCount:Int()
		Return bmx_b2world_getproxycount(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the number of broad-phase pairs. 
	End Rem
	Method GetPairCount:Int()
		Return bmx_b2world_getpaircount(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the number of bodies. 
	End Rem
	Method GetBodyCount:Int()
		Return bmx_b2world_getbodycount(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the number joints. 
	End Rem
	Method GetJointCount:Int()
		Return bmx_b2world_getjointcount(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Query the world for all shapes that potentially overlap the provided AABB.
	returns: The number of shapes found in aabb. 
	about: You provide a shape array for populating. The number of shapes found is returned. 
	End Rem
	Method Query:Int(aabb:b2AABB, shapes:b2Shape[])
		Return bmx_b2world_query(b2ObjectPtr, aabb, shapes)
	End Method
	
	Rem
	bbdoc: Re-filter a shape.
	about: This re-runs contact filtering on a shape.
	End Rem
	Method Refilter(shape:b2Shape)
		bmx_b2world_refilter(b2ObjectPtr, shape.b2ObjectPtr)
	End Method

	Rem
	bbdoc:  Query the world for all shapes that intersect a given segment.
	about: You provide a shape array of an appropriate size. The number of shapes found is returned, and the array
	is filled in order of intersection.
	End Rem
	Method Raycast:Int(segment:b2Segment Var, shapes:b2Shape[], solidShapes:Int)
		Return bmx_b2world_raycast(b2ObjectPtr, segment, shapes, solidShapes)
	End Method

	Rem
	bbdoc: Performs a raycast as with Raycast, finding the first intersecting shape.
	End Rem
	Method RaycastOne:b2Shape(segment:b2Segment Var, lambda:Float Var, normal:b2Vec2 Var, solidShapes:Int)
		Return b2Shape._create(bmx_b2world_raycastone(b2ObjectPtr, segment, Varptr lambda, normal, solidShapes))
	End Method
	
	Rem
	bbdoc: Check if the AABB is within the broadphase limits.
	End Rem
	Method InRange:Int(aabb:b2AABB)
		Return bmx_b2world_inrange(b2ObjectPtr, aabb)
	End Method
	
	Function _setShape(shapes:b2Shape[], index:Int, shape:Byte Ptr) { nomangle }
		shapes[index] = b2Shape._create(shape)
	End Function
	
End Type


Rem
bbdoc: An axis aligned bounding box.
End Rem
Struct b2AABB

	Field lowerBound:b2Vec2
	Field upperBound:b2Vec2

	Method Create:b2AABB()
		Return Self
	End Method

	Rem
	bbdoc: Creates a new AABB
	End Rem
	Function CreateAABB:b2AABB(lowerBound:b2Vec2, upperBound:b2Vec2)
		Return New b2AABB.Create(lowerBound, upperBound)
	End Function
	
	Rem
	bbdoc: Creates a new AABB
	End Rem
	Method Create:b2AABB(lowerBound:b2Vec2, upperBound:b2Vec2)
		Self.lowerBound = lowerBound
		Self.upperBound = upperBound
		Return Self
	End Method
	
	Rem
	bbdoc: Sets the lower vertex.
	End Rem
	Method SetLowerBound(lowerBound:b2Vec2)
		Self.lowerBound = lowerBound
	End Method

	Rem
	bbdoc: Sets the upper vertex.
	End Rem
	Method SetUpperBound(upperBound:b2Vec2)
		Self.upperBound = upperBound
	End Method
	
	Rem
	bbdoc: Verify that the bounds are sorted. 
	End Rem
	Method IsValid:Int()
		Return bmx_b2abb_isvalid(Self)
	End Method

End Struct

Rem
bbdoc: A 2D column vector. 
End Rem
Struct b2Vec2

	Field x:Float
	Field y:Float
	
	Method New()
	End Method
	
	Method New(x:Float, y:Float)
		Self.x = x
		Self.y = y
	End Method
	
	Rem
	bbdoc: Creates a new vector with the given coordinates.
	End Rem
	Function CreateVec2:b2Vec2(x:Float = 0, y:Float = 0)
		Return New b2Vec2.Create(x, y)
	End Function
	
	Rem
	bbdoc: Creates a new vector with the given coordinates.
	End Rem
	Method Create:b2Vec2(x:Float = 0, y:Float = 0)
		Self.x = x
		Self.y = y
		Return Self
	End Method
	
	Rem
	bbdoc: Returns the X coordinate.
	about: Synonym for X().
	End Rem
	Method GetX:Float()
		Return x
	End Method

	Rem
	bbdoc: Returns the Y coordinate.
	about: Synonym for Y().
	End Rem
	Method GetY:Float()
		Return y
	End Method

	Rem
	bbdoc: Adds @vec to this vector.
	End Rem	
	Method Add(vec:b2Vec2)
		x :+ vec.x
		y :+ vec.y
	End Method

	Rem
	bbdoc: Adds @vec to this vector, returning the a new b2Vec2.
	about: This object is not modified.
	End Rem	
	Method Plus:b2Vec2(vec:b2Vec2)
		Return New b2Vec2(x + vec.x, y + vec.y)
	End Method

	Rem
	bbdoc: Multiplies the vector by @value.
	End Rem	
	Method Multiply:b2Vec2(value:Float)
		x :* value
		y :* value
		Return Self
	End Method

	Rem
	bbdoc: Divides the vector by @value.
	End Rem	
	Method Divide:b2Vec2(value:Float)
		Local v:Float = 1.0 / value
		x :* v
		y :* v
		Return Self
	End Method

	Rem
	bbdoc: Copies @vec into this object.
	End Rem	
	Method Copy(vec:b2Vec2)
		x = vec.x
		y = vec.y
	End Method
	
	Rem
	bbdoc: Subtracts @vec from this object, returning a new b2Vec2.
	about: This object is not modified.
	End Rem	
	Method Subtract:b2Vec2(vec:b2Vec2)
		Return New b2Vec2(x - vec.x, y - vec.y)
	End Method
	
	Rem
	bbdoc: Sets the x and y parts.
	End Rem	
	Method Set(x:Float, y:Float)
		Self.x = x
		Self.y = y
	End Method
	
	Rem
	bbdoc: Sets the x part.
	End Rem
	Method SetX(x:Float)
		Self.x = x
	End Method

	Rem
	bbdoc: Sets the y part.
	End Rem
	Method SetY(y:Float)
		Self.y = y
	End Method
	
	Rem
	bbdoc: Returns the length of this vector.
	End Rem	
	Method Length:Float()
		Return bmx_b2vec2_length(Self)
	End Method
	
	Rem
	bbdoc: Convert this vector into a unit vector.
	returns: The length. 
	End Rem
	Method Normalize:Float()
		Return bmx_b2vec2_normalize(Self)
	End Method
	
	Rem
	bbdoc: Get the length squared.
	about: For performance, use this instead of b2Vec2::Length (if possible).
	End Rem
	Method LengthSquared:Float()
		Return bmx_b2vec2_lengthsquared(Self)
	End Method

	Function _newVecArray:b2Vec2[](count:Int) { nomangle }
		Return New b2Vec2[count]
	End Function
	
	Rem
	bbdoc: A zero vector (0,0)
	End Rem
	Global ZERO:b2Vec2 = New b2Vec2
	
End Struct

Rem
bbdoc: Convenience function for creating a b2Vec2 object.
End Rem
Function Vec2:b2Vec2(x:Float, y:Float)
	Return New b2Vec2(x, y)
End Function

Rem
bbdoc: Joints and shapes are destroyed when their associated body is destroyed. 
about: Implement this listener so that you may nullify references to these joints and shapes. 
End Rem
Type b2DestructionListener

	Field b2ObjectPtr:Byte Ptr

	Method New()
		b2ObjectPtr = bmx_b2destructionlistener_new(Self)
	End Method

	Rem
	bbdoc: Called when any joint is about to be destroyed due to the destruction of one of its attached bodies. 
	End Rem
	Method SayGoodbyeJoint(joint:b2Joint)
	End Method

	Function _SayGoodbyeJoint(listener:b2DestructionListener, joint:Byte Ptr) { nomangle }
		listener.SayGoodbyeJoint(b2Joint._create(joint))
	End Function
	
	Rem
	bbdoc: Called when any shape is about to be destroyed due to the destruction of its parent body. 
	End Rem
	Method SayGoodbyeShape(shape:b2Shape)
	End Method
	
	Function _SayGoodbyeShape(listener:b2DestructionListener, shape:Byte Ptr) { nomangle }
		listener.SayGoodbyeShape(b2Shape._create(shape))
	End Function

	Method Delete()
		If b2ObjectPtr Then
			bmx_b2destructionlistener_delete(b2ObjectPtr)
			b2ObjectPtr = Null
		End If
	End Method

End Type

Rem
bbdoc: Use this type for when a body's shape passes outside of the world boundary.
about: Override Violation().
End Rem
Type b2BoundaryListener

	Field b2ObjectPtr:Byte Ptr

	Method New()
		b2ObjectPtr = bmx_b2boundarylistener_new(Self)
	End Method
	
	Rem
	bbdoc: This is called for each body that leaves the world boundary.
	about: Warning: you can't modify the world inside this callback.
	End Rem
	Method Violation(body:b2Body)
	End Method

	Function _Violation(listener:b2BoundaryListener, body:Byte Ptr) { nomangle }
		listener.Violation(b2Body._create(body))
	End Function

	Method Delete()
		If b2ObjectPtr Then
			bmx_b2boundarylistener_delete(b2ObjectPtr)
			b2ObjectPtr = Null
		End If
	End Method

End Type

Rem
bbdoc: Implement this type to get collision results. 
about: You can use these results for things like sounds and game logic. You can also get contact results by traversing
the contact lists after the time step. However, you might miss some contacts because continuous physics leads to
sub-stepping. Additionally you may receive multiple callbacks for the same contact in a single time step.
You should strive to make your callbacks efficient because there may be many callbacks per time step. 
End Rem
Type b2ContactListener

	Field b2ObjectPtr:Byte Ptr

	Method New()
		b2ObjectPtr = bmx_b2contactlistener_new(Self)
	End Method

	Rem
	bbdoc: Called when a contact point is added.
	about: This includes the geometry and the forces.
	End Rem
	Method Add(point:b2ContactPoint)
	End Method
	
	Function _Add(listener:b2ContactListener, point:b2ContactPoint) { nomangle }
		listener.Add(point)
	End Function

	Rem
	bbdoc: Called when a contact point persists.
	about: This includes the geometry and the forces.
	End Rem
	Method Persist(point:b2ContactPoint)
	End Method
	
	Function _Persist(listener:b2ContactListener, point:b2ContactPoint) { nomangle }
		listener.Persist(point)
	End Function

	Rem
	bbdoc: Called when a contact point is removed.
	about: This includes the last computed geometry and forces.
	End Rem
	Method Remove(point:b2ContactPoint)
	End Method

	Function _Remove(listener:b2ContactListener, point:b2ContactPoint) { nomangle }
		listener.Remove(point)
	End Function

	Rem
	bbdoc: Called after a contact point is solved.
	End Rem
	Method Result(result:b2ContactResult)
	End Method
	
	Function _Result(listener:b2ContactListener, result:b2ContactResult) { nomangle }
		listener.Result(result)
	End Function

	Method Delete()
		If b2ObjectPtr Then
			bmx_b2contactlistener_delete(b2ObjectPtr)
			b2ObjectPtr = Null
		End If
	End Method

End Type

Rem
bbdoc: Implement this type and override ShouldCollide() to provide collision filtering.
about: In other words, you can implement this type if you want finer control over contact creation.
End Rem
Type b2ContactFilter

	Field b2ObjectPtr:Byte Ptr

	Method New()
		b2ObjectPtr = bmx_b2contactfilter_new(Self)
	End Method

	Rem
	bbdoc: Return True if contact calculations should be performed between these two shapes.
	about: Warning:  for performance reasons this is only called when the AABBs begin to overlap.
	End Rem
	Method ShouldCollide:Int(shape1:b2Shape, shape2:b2Shape)
		Return True
	End Method

	Function _ShouldCollide:Int(filter:b2ContactFilter, shape1:Byte Ptr, shape2:Byte Ptr) { nomangle }
		Return filter.ShouldCollide(b2Shape._create(shape1), b2Shape._create(shape2))
	End Function
	
	Method Delete()
		If b2ObjectPtr Then
			bmx_b2contactfilter_delete(b2ObjectPtr)
			b2ObjectPtr = Null
		End If
	End Method
	
End Type

Rem
bbdoc: This type manages contact between two shapes.
about: A contact exists for each overlapping AABB in the broad-phase (except if filtered). Therefore a contact
object may exist that has no contact points.
End Rem
Type b2Contact

	Field b2ObjectPtr:Byte Ptr

	Function _create:b2Contact(b2ObjectPtr:Byte Ptr)
		If b2ObjectPtr Then
			Local contact:b2Contact = New b2Contact
			contact.b2ObjectPtr = b2ObjectPtr
			Return contact
		End If
	End Function

	Rem
	bbdoc: Get the first shape in this contact.
	End Rem
	Method GetShape1:b2Shape()
		Return b2Shape._create(bmx_b2contact_getshape1(b2ObjectPtr))
	End Method
	
	Rem
	bbdoc: Get the second shape in this contact.
	End Rem
	Method GetShape2:b2Shape()
		Return b2Shape._create(bmx_b2contact_getshape2(b2ObjectPtr))
	End Method
	
	Rem
	bbdoc: Get the next contact in the world's contact list.
	End Rem
	Method GetNext:b2Contact()
		Return b2Contact._create(bmx_b2contact_getnext(b2ObjectPtr))
	End Method
	
	Rem
	bbdoc: Is this contact solid?
	returns: True if this contact should generate a response.
	End Rem
	Method IsSolid:Int()
		Return bmx_b2contact_issolid(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Get the number of manifolds.
	about: This is 0 or 1 between convex shapes.
	This may be greater than 1 for convex-vs-concave shapes. Each
	manifold holds up to two contact points with a shared contact normal.
	End Rem
	Method GetManifoldCount:Int()
		Return bmx_b2contact_getmanifoldcount(b2ObjectPtr)
	End Method
	
End Type

Rem
bbdoc: This type is used to report contact points. 
End Rem
Struct b2ContactPoint

	Field shape1:Byte Ptr
	Field shape2:Byte Ptr
	Field position:b2Vec2
	Field velocity:b2Vec2
	Field normal:b2Vec2
	Field separation:Float
	Field friction:Float
	Field restitution:Float
	Field id:UInt

	Rem
	bbdoc: Returns the first shape.
	End Rem
	Method GetShape1:b2Shape()
		Return b2Shape._create(shape1)
	End Method
	
	Rem
	bbdoc: Returns the second shape.
	End Rem
	Method GetShape2:b2Shape()
		Return b2Shape._create(shape2)
	End Method
	
	Rem
	bbdoc: Returns position in world coordinates.
	End Rem
	Method GetPosition:b2Vec2()
		Return position
	End Method

	Rem
	bbdoc: Returns the velocity of point on body2 relative to point on body1 (pre-solver).
	End Rem
	Method GetVelocity:b2Vec2()
		Return velocity
	End Method
	
	Rem
	bbdoc: Points from shape1 to shape2.
	End Rem
	Method GetNormal:b2Vec2()
		Return normal
	End Method

	Rem
	bbdoc: The separation is negative when shapes are touching 
	End Rem
	Method GetSeparation:Float()
		Return separation
	End Method

	Rem
	bbdoc: Returns the combined friction coefficient.
	End Rem
	Method GetFriction:Float()
		Return friction
	End Method

	Rem
	bbdoc: Returns the combined restitution coefficient.
	End Rem
	Method GetRestitution:Float()
		Return restitution
	End Method

End Struct

Rem
bbdoc: This type is used to report contact point results.
End Rem
Struct b2ContactResult

	Field shape1:Byte Ptr
	Field shape2:Byte Ptr
	Field position:b2Vec2
	Field normal:b2Vec2
	Field normalImpulse:Float
	Field tangentImpulse:Float
	Field id:UInt

	Rem
	bbdoc: Returns the first shape.
	End Rem
	Method GetShape1:b2Shape()
		Return b2Shape._create(shape1)
	End Method
	
	Rem
	bbdoc: Returns the second shape.
	End Rem
	Method GetShape2:b2Shape()
		Return b2Shape._create(shape2)
	End Method
	
	Rem
	bbdoc: Returns position in world coordinates.
	End Rem
	Method GetPosition:b2Vec2()
		Return position
	End Method
	
	Rem
	bbdoc: Points from shape1 to shape2.
	End Rem
	Method GetNormal:b2Vec2()
		Return normal
	End Method
	
	Rem
	bbdoc: Returns the normal impulse applied to body2.
	End Rem
	Method GetNormalImpulse:Float()
		Return normalImpulse
	End Method
	
	Rem
	bbdoc: Returns the tangent impulse applied to body2.
	End Rem
	Method GetTangentImpulse:Float()
		Return tangentImpulse
	End Method
	
End Struct

Rem
bbdoc: The base joint type.
about: Joints are used to constraint two bodies together in various fashions.
Some joints also feature limits and motors. 
End Rem
Type b2Joint

	Field b2ObjectPtr:Byte Ptr
	Field userData:Object

	Function _create:b2Joint(b2ObjectPtr:Byte Ptr)
		If b2ObjectPtr Then
			Local joint:b2Joint = b2Joint(bmx_b2joint_getmaxjoint(b2ObjectPtr))
			If Not joint Then
				joint = New b2Joint
				joint.b2ObjectPtr = b2ObjectPtr
			Else
				If Not joint.b2ObjectPtr Then
					joint.b2ObjectPtr = b2ObjectPtr
				EndIf
			End If
			Return joint
		End If
	End Function
	
	Rem
	bbdoc: Get the first body attached to this joint.
	end rem
	Method GetBody1:b2Body()
		Return b2Body._create(bmx_b2joint_getbody1(b2ObjectPtr))
	End Method
	
	Rem
	bbdoc: Get the second body attached to this joint.
	end rem
	Method GetBody2:b2Body()
		Return b2Body._create(bmx_b2joint_getbody2(b2ObjectPtr))
	End Method
	
	Rem
	bbdoc: Get the next joint the world joint list.
	end rem
	Method GetNext:b2Joint()
		Return b2Joint._create(bmx_b2joint_getnext(b2ObjectPtr))
	End Method

	Rem
	bbdoc: Get the user data pointer that was provided in the joint definition.
	End Rem
	Method GetUserData:Object()
		Return userData
	End Method


End Type

Rem
bbdoc: Bodies are the backbone for shapes.
about: Bodies carry shapes and move them around in the world. Bodies are always rigid bodies in Box2D. That
means that two shapes attached to the same rigid body never move relative to each other.
<p>
Bodies have position and velocity. You can apply forces, torques, and impulses to bodies. Bodies can be
static or dynamic. Static bodies never move and don't collide with other static bodies.
</p>
End Rem
Type b2Body
	Field b2ObjectPtr:Byte Ptr
	Field userData:Object

	Function _create:b2Body(b2ObjectPtr:Byte Ptr)
		If b2ObjectPtr Then
			Local body:b2Body = b2Body(bmx_b2body_getmaxbody(b2ObjectPtr))
			If Not body Then
				body = New b2Body
				body.b2ObjectPtr = b2ObjectPtr
				bmx_b2body_setmaxbody(b2ObjectPtr, body)
			End If
			Return body
		End If
	End Function
	
	Rem
	bbdoc: Creates a shape and attach it to this body. 
	about: Warning: This method is locked during callbacks.
	<p>Parameters:
	<ul>
	<li><b>def </b> : the shape definition.</li>
	</ul>
	</p>
	End Rem
	Method CreateShape:b2Shape(def:b2ShapeDef)
		Local shape:b2Shape
		shape = b2Shape._create(bmx_b2body_createshape(b2ObjectPtr, def.b2ObjectPtr))
		shape.userData = def.userData ' copy the userData
		Return shape
	End Method

	Function _createShape:b2Shape(shapeType:Int) { nomangle }
		Local shape:b2Shape
		Select shapeType
			Case e_unknownShape
				shape = New b2Shape
			Case e_circleShape
				shape = New b2CircleShape
			Case e_polygonShape
				shape = New b2PolygonShape
			Case e_edgeShape
				shape = New b2EdgeShape
			Default
				DebugLog "Warning, shape type '" + shapeType + "' is not defined in module."
				shape = New b2Shape
		End Select
		Return shape
	End Function

	Rem
	bbdoc: Destroy a shape. 
	about: This removes the shape from the broad-phase and therefore destroys any contacts associated with this shape.
	All shapes attached to a body are implicitly destroyed when the body is destroyed.
	<p>
	Warning: This method is locked during callbacks.
	</p>
	End Rem
	Method DestroyShape(shape:b2Shape)
		bmx_b2body_destroyshape(b2ObjectPtr, shape.b2ObjectPtr)
	End Method

	Rem
	bbdoc: Compute the mass properties from the attached shapes. 
	about: You typically call this after adding all the shapes. If you add or remove shapes later, you may
	want to call this again. Note that this changes the center of mass position. 
	End Rem
	Method SetMassFromShapes()
		bmx_b2body_setmassfromshapes(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Get the world body origin position. 
	End Rem
	Method GetPosition:b2Vec2()
		Return bmx_b2body_getposition(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Get the angle in degrees.
	returns: The current world rotation angle in degrees.
	End Rem
	Method GetAngle:Float()
		Return bmx_b2body_getangle(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Get the world position of the center of mass.
	End Rem
	Method GetWorldCenter:b2Vec2()
		Return bmx_b2body_getworldcenter(b2ObjectPtr)
	End Method

	Rem
	bbdoc:Get the Local position of the center of mass.
	End Rem
	Method GetLocalCenter:b2Vec2()
		Return bmx_b2body_getlocalcenter(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Set the linear velocity of the center of mass.
	about: Parameters:
	<ul>
	<li><b>v </b> : the New linear velocity of the center of mass.</li>
	</ul>
	End Rem
	Method SetLinearVelocity(v:b2Vec2)
		bmx_b2body_setlinearvelocity(b2ObjectPtr, v)
	End Method

	Rem
	bbdoc: Get the linear velocity of the center of mass.
	returns: The linear velocity of the center of mass.
	End Rem
	Method GetLinearVelocity:b2Vec2()
		Return bmx_b2body_getlinearvelocity(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Set the angular velocity.
	about: Parameters:
	<ul>
	<li><b>omega </b> : the New angular velocity in degrees/Second.</li>
	</ul>
	End Rem
	Method SetAngularVelocity(omega:Float)
		bmx_b2body_setangularvelocity(b2ObjectPtr, omega)
	End Method

	Rem
	bbdoc: Get the angular velocity.
	returns: The angular velocity in degrees/Second.
	End Rem
	Method GetAngularVelocity:Float()
		Return bmx_b2body_getangularvelocity(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Apply a force at a world point.
	about: If the force is not applied at the center of mass, it will generate a torque and affect the angular velocity.
	This wakes up the body.
	<p>Parameters:
	<ul>
	<li><b>force </b> : the world force vector, usually in Newtons (N).</li>
	<li><b>point </b> : the world position of the point of application.</li>
	</ul>
	</p>
	End Rem
	Method ApplyForce(force:b2Vec2, point:b2Vec2)
		bmx_b2body_applyforce(b2ObjectPtr, force, point)
	End Method

	Rem
	bbdoc: Apply a torque.
	about: This affects the angular velocity without affecting the linear velocity of the center of mass.
	This wakes up the body.
	<p>Parameters:
	<ul>
	<li><b> torque </b> : about the z-axis (out of the screen), usually in N-m.</li>
	</ul>
	</p>
	End Rem
	Method ApplyTorque(torque:Float)
		bmx_b2body_applytorque(b2ObjectPtr, torque)
	End Method

	Rem
	bbdoc: Apply an impulse at a point.
	about: This immediately modifies the velocity.
	It also modifies the angular velocity If the point of application is not at the center of mass. This wakes up the body.
	<p>Parameters:
	<ul>
	<li><b> impulse </b> : the world impulse vector, usually in N-seconds Or kg-m/s.</li>
	<li><b> point </b> : the world position of the point of application.</li>
	</ul>
	</p>
	End Rem
	Method ApplyImpulse(impulse:b2Vec2, point:b2Vec2)
		bmx_b2body_applyimpulse(b2ObjectPtr, impulse, point)
	End Method

	Rem
	bbdoc: Get the total mass of the body.
	returns: The mass, usually in kilograms (kg).
	End Rem
	Method GetMass:Float()
		Return bmx_b2body_getmass(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Get the central rotational inertia of the body.
	returns: The rotational inertia, usually in kg-m^2.
	End Rem
	Method GetInertia:Float()
		Return bmx_b2body_getinertia(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Get the world coordinates of a point given the local coordinates.
	returns: The same point expressed in world coordinates.
	about: Parameters:
	<ul>
	<li><b>localPoint </b> : a point on the body measured relative the the body's origin.</li>
	</ul>
	End Rem
	Method GetWorldPoint:b2Vec2(localPoint:b2Vec2)
		Return bmx_b2body_getworldpoint(b2ObjectPtr, localPoint)
	End Method

	Rem
	bbdoc: Get the world coordinates of a vector given the local coordinates.
	returns: The same vector expressed in world coordinates.
	about: Parameters:
	<ul>
	<li><b>localVector </b> : a vector fixed in the body.</li>
	</ul>
	End Rem
	Method GetWorldVector:b2Vec2(localVector:b2Vec2)
		Return bmx_b2body_getworldvector(b2ObjectPtr, localVector)
	End Method

	Rem
	bbdoc: Gets a local point relative to the body's origin given a world point.
	returns: The corresponding local point relative to the body's origin.
	about: Parameters:
	<ul>
	<li><b>worldPoint </b> : a point in world coordinates.</li>
	</ul>
	End Rem
	Method GetLocalPoint:b2Vec2(worldPoint:b2Vec2)
		Return bmx_b2body_getlocalpoint(b2ObjectPtr, worldPoint)
	End Method

	Rem
	bbdoc: Gets a local vector given a world vector.
	returns: The corresponding local vector.
	about: Parameters:
	<ul>
	<li><b>worldVector </b> : a vector in world coordinates.</li>
	</ul>
	End Rem
	Method GetLocalVector:b2Vec2(worldVector:b2Vec2)
		Return bmx_b2body_getlocalvector(b2ObjectPtr, worldVector)
	End Method

	Rem
	bbdoc: Is this body treated like a bullet for continuous collision detection?
	End Rem
	Method IsBullet:Int()
		Return bmx_b2body_isbullet(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Should this body be treated like a bullet for continuous collision detection?
	End Rem
	Method SetBullet(flag:Int)
		bmx_b2body_setbullet(b2ObjectPtr, flag)
	End Method

	Rem
	bbdoc: Is this body static (immovable)?
	End Rem
	Method IsStatic:Int()
		Return bmx_b2body_isstatic(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Is this body dynamic (movable)?
	End Rem
	Method IsDynamic:Int()
		Return bmx_b2body_isdynamic(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Is this body frozen?
	End Rem
	Method IsFrozen:Int()
		Return bmx_b2body_isfrozen(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Is this body sleeping (not simulating).
	End Rem
	Method IsSleeping:Int()
		Return bmx_b2body_issleeping(b2ObjectPtr)
	End Method

	Rem
	bbdoc: You can disable sleeping on this body.
	End Rem
	Method AllowSleeping(flag:Int)
		bmx_b2body_allowsleeping(b2ObjectPtr, flag)
	End Method

	Rem
	bbdoc: Wake up this body so it will begin simulating.
	End Rem
	Method WakeUp()
		bmx_b2body_wakeup(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Put this body to sleep so it will stop simulating.
	about: This also sets the velocity to zero.
	End Rem
	Method PutToSleep()
		bmx_b2body_puttosleep(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Get the list of all shapes attached to this body.
	End Rem
	Method GetShapeList:b2Shape()
		Return b2Shape._create(bmx_b2body_getshapelist(b2ObjectPtr))
	End Method

	Rem
	bbdoc: Get the list of all joints attached to this body.
	End Rem
	Method GetJointList:b2JointEdge()
		Return New b2JointEdge(bmx_b2body_getjointlist(b2ObjectPtr))
	End Method

	Rem
	bbdoc: Get the next body in the world's body list.
	End Rem
	Method GetNext:b2Body()
		Return _create(bmx_b2body_getnext(b2ObjectPtr))
	End Method

	Rem
	bbdoc: Get the user data pointer that was provided in the body definition.
	End Rem
	Method GetUserData:Object()
		Return userData
	End Method

	Rem
	bbdoc: Get the body transform for the body's origin. 
	End Rem
	Method GetXForm:b2XForm()
		Return bmx_b2body_getxform(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Set the position of the body's origin and rotation (degrees). 
	about: This breaks any contacts and wakes the other bodies. 
	End Rem
	Method SetXForm:Int(position:b2Vec2, angle:Float)
		Return bmx_b2body_setxform(b2ObjectPtr, position, angle)
	End Method
	
	Rem
	bbdoc: Get the parent world of this body.
	End Rem
	Method GetWorld:b2World()
		Return b2World._create(bmx_b2body_getworld(b2ObjectPtr))
	End Method
	
	Rem
	bbdoc: Set the mass properties.
	about: Note that this changes the center of mass position.
	<p>
	If you are not sure how to compute mass properties, use SetMassFromShapes.
	</p>
	<p>
	The inertia tensor is assumed to be relative to the center of mass.
	</p>
	End Rem
	Method SetMass(massData:b2MassData)
		bmx_b2body_setmass(b2ObjectPtr, massData.b2ObjectPtr)
	End Method
	
End Type

Rem
bbdoc: A shape is used for collision detection. 
about: Shapes are created in b2World. You can use shape for collision detection before they are attached to the world.
<p>
Warning: You cannot reuse shapes.
</p>
End Rem
Type b2Shape

	Field b2ObjectPtr:Byte Ptr
	Field userData:Object

	Function _create:b2Shape(b2ObjectPtr:Byte Ptr)
		If b2ObjectPtr Then
			Local shape:b2Shape = b2Shape(bmx_b2shape_getmaxshape(b2ObjectPtr))
			If Not shape Then
				shape = New b2Shape
				shape.b2ObjectPtr = b2ObjectPtr
				bmx_b2shape_setmaxshape(b2ObjectPtr, shape)
			Else
				If Not shape.b2ObjectPtr Then
					shape.b2ObjectPtr = b2ObjectPtr
				EndIf
			End If
			Return shape
		End If
	End Function

	Rem
	bbdoc: Is this shape a sensor (non-solid)? 
	End Rem
	Method IsSensor:Int()
		Return bmx_b2shape_issensor(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the parent body of this shape. 
	End Rem
	Method GetBody:b2Body()
		Return b2Body._create(bmx_b2shape_getbody(b2ObjectPtr))
	End Method
	
	Rem
	bbdoc: Get the user data that was assigned in the shape definition.
	End Rem
	Method GetUserData:Object()
		Return userData
	End Method
	
	Rem
	bbdoc: Sets the user data.
	End Rem
	Method SetUserData(data:Object)
		userData = data
	End Method
	
	Rem
	bbdoc: Get the next shape in the parent body's shape list. 
	End Rem
	Method GetNext:b2Shape()
		Return _create(bmx_b2shape_getnext(b2ObjectPtr))
	End Method
	
	Rem
	bbdoc: Test a point for containment in this shape. 
	about: This only works for convex shapes. 
	End Rem
	Method TestPoint:Int(xf:b2XForm, p:b2Vec2)
		Return bmx_b2shape_testpoint(b2ObjectPtr, xf, p)
	End Method
	
	Rem
	bbdoc: Get the contact filtering data. 
	End Rem
	Method GetFilterData:b2FilterData()
		Return bmx_b2shape_getfilterdata(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Set the contact filtering data. 
	about: You must call b2World::Refilter to correct existing contacts/non-contacts. 
	End Rem
	Method SetFilterData(data:b2FilterData)
		bmx_b2shape_setfilterdata(b2ObjectPtr, data)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method TestSegment:Int(xf:b2XForm, lambda:Float Var, normal:b2Vec2 Var, segment:b2Segment, maxLambda:Float)
	End Method
	
	Rem
	bbdoc: Get the maximum radius about the parent body's center of mass. 
	End Rem
	Method GetSweepRadius:Float()
		Return bmx_b2shape_getsweepradius(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the coefficient of friction. 
	End Rem
	Method GetFriction:Float()
		Return bmx_b2shape_getfriction(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Set the coefficient of friction.
	End Rem
	Method SetFriction(friction:Float)
		bmx_b2shape_setfriction(b2ObjectPtr, friction)
	End Method
	
	Rem
	bbdoc: Get the coefficient of restitution. 
	End Rem
	Method GetRestitution:Float()
		Return bmx_b2shape_getrestitution(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Set the coefficient of restitution.
	End Rem
	Method SetRestitution(restitution:Float)
		bmx_b2shape_setrestitution(b2ObjectPtr, restitution)
	End Method
	
	Rem
	bbdoc: Given a transform, compute the associated axis aligned bounding box for this shape.
	End Rem
	Method ComputeAABB(aabb:b2AABB, xf:b2XForm)
		bmx_b2shape_computeaabb(b2ObjectPtr, aabb, xf)
	End Method

	Rem
	bbdoc: Given two transforms, compute the associated swept axis aligned bounding box for this shape. 
	End Rem
	Method ComputeSweptAABB(aabb:b2AABB, xf1:b2XForm, xf2:b2XForm)
		bmx_b2shape_computesweptaabb(b2ObjectPtr, aabb, xf1, xf2)
	End Method
	
	Rem
	bbdoc: Compute the mass properties of this shape using its dimensions and density. 
	returns: the mass data for this shape.
	about: The inertia tensor is computed about the local origin, not the centroid. 
	End Rem
	Method ComputeMass(data:b2MassData)
		bmx_b2shape_computemass(b2ObjectPtr, data.b2ObjectPtr)
	End Method
	
End Type

Rem
bbdoc: Implement and register this type with a b2World to provide debug drawing of physics entities in your game. 
End Rem
Type b2DebugDraw

	Field b2ObjectPtr:Byte Ptr

	Const e_shapeBit:Int = $0001        ' draw shapes
	Const e_jointBit:Int = $0002        ' draw joint connections
	Const e_coreShapeBit:Int = $0004    ' draw core (TOI) shapes
	Const e_aabbBit:Int = $0008         ' draw axis aligned bounding boxes
	Const e_obbBit:Int = $0010          ' draw oriented bounding boxes
	Const e_pairBit:Int = $0020         ' draw broad-phase pairs
	Const e_centerOfMassBit:Int = $0040 ' draw center of mass frame
	Const e_controllerBit:Int = $0080
	
	Method New()
		b2ObjectPtr = bmx_b2debugdraw_create(Self)
	End Method
	
	Rem
	bbdoc: Set the drawing flags.
	End Rem
	Method SetFlags(flags:Int)
		bmx_b2debugdraw_setflags(b2ObjectPtr, flags)
	End Method
	
	Rem
	bbdoc: Get the drawing flags.
	End Rem
	Method GetFlags:Int()
		Return bmx_b2debugdraw_getflags(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Append flags to the current flags.
	End Rem
	Method AppendFlags(flags:Int)
		bmx_b2debugdraw_appendflags(b2ObjectPtr, flags)
	End Method
	
	Rem
	bbdoc: Clear flags from the current flags.
	End Rem
	Method ClearFlags(flags:Int)
		bmx_b2debugdraw_clearflags(b2ObjectPtr, flags)
	End Method

	Rem
	bbdoc: Draw a closed polygon provided in CCW order. 
	End Rem
	Method DrawPolygon(vertices:b2Vec2[], color:b2Color) Abstract


	Function _DrawPolygon(obj:b2DebugDraw , vertices:b2Vec2[], r:Int, g:Int, b:Int) { nomangle }
		obj.DrawPolygon(vertices, b2Color.Set(r, g, b))
	End Function
	
	Rem
	bbdoc: Draw a solid closed polygon provided in CCW order
	End Rem
	Method DrawSolidPolygon(vertices:b2Vec2[], color:b2Color) Abstract

	Function _DrawSolidPolygon(obj:b2DebugDraw , vertices:b2Vec2[], r:Int, g:Int, b:Int) { nomangle }
		obj.DrawSolidPolygon(vertices, b2Color.Set(r, g, b))
	End Function

	Rem
	bbdoc: Draw a circle.
	End Rem
	Method DrawCircle(center:b2Vec2, radius:Float, color:b2Color) Abstract
	
	Rem
	bbdoc: Draw a solid circle.
	End Rem
	Method DrawSolidCircle(center:b2Vec2, radius:Float, axis:b2Vec2, color:b2Color) Abstract
	
	Function _DrawSolidCircle(obj:b2DebugDraw, center:b2Vec2, radius:Float, axis:b2Vec2, r:Int, g:Int, b:Int) { nomangle }
		obj.DrawSolidCircle(center, radius, axis, b2Color.Set(r, g, b))
	End Function
	
	Rem
	bbdoc: Draw a line segment.
	End Rem
	Method DrawSegment(p1:b2Vec2, p2:b2Vec2, color:b2Color) Abstract

	Function _DrawSegment(obj:b2DebugDraw, p1:b2Vec2, p2:b2Vec2, r:Int, g:Int, b:Int) { nomangle }
		obj.DrawSegment(p1, p2, b2Color.Set(r, g, b))
	End Function
	
	Rem
	bbdoc: Draw a transform. Choose your own length scale.
	/// @param xf a transform.
	End Rem
	Method DrawXForm(xf:b2XForm) Abstract


End Type

Rem
bbdoc: Color for debug drawing.
about: Each value has the range [0,1]. 
End Rem
Type b2Color
	
	Field red:Int, green:Int, blue:Int

	Function Set:b2Color(r:Int, g:Int, b:Int)
		Local this:b2Color = New b2Color
		this.red = r
		this.green = g
		this.blue = b
		Return this
	End Function

End Type

Rem
bbdoc: A body definition holds all the data needed to construct a rigid body. 
about: You can safely re-use body definitions. 
End Rem
Type b2BodyDef

	Field b2ObjectPtr:Byte Ptr
	Field userData:Object

	Method New()
		b2ObjectPtr = bmx_b2bodydef_create()
	End Method
	
	Rem
	bbdoc: You can use this to initialize the mass properties of the body.
	about: If you prefer, you can set the mass properties after the shapes have been added using b2Body.SetMassFromShapes.
	End Rem
	Method SetMassData(data:b2MassData)
		bmx_b2bodydef_setmassdata(b2ObjectPtr, data.b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Returns mass property data.
	End Rem
	Method GetMassData:b2MassData()
		Return b2MassData._create(bmx_b2bodydef_getmassdata(b2ObjectPtr))
	End Method

	Rem
	bbdoc: Use this to store application specific body data.
	End Rem
	Method SetUserData(data:Object)
		userData = data
	End Method
	
	Rem
	bbdoc: Returns the application specific body data, if any.
	End Rem
	Method GetUserData:Object()
		Return userData
	End Method
	
	Rem
	bbdoc: The world position of the body.
	about: Avoid creating bodies at the origin since this can lead to many overlapping shapes.
	End Rem
	Method SetPosition(position:b2Vec2)
		bmx_b2bodydef_setposition(b2ObjectPtr, position)
	End Method

	Rem
	bbdoc: The world position of the body.
	about: Avoid creating bodies at the origin since this can lead to many overlapping shapes.
	End Rem
	Method SetPositionXY(x:Float, y:Float)
		bmx_b2bodydef_setpositionxy(b2ObjectPtr, x, y)
	End Method
	
	Rem
	bbdoc: Returns the world position of the body. 
	End Rem
	Method GetPosition:b2Vec2()
		Return bmx_b2bodydef_getposition(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: The world angle of the body in degrees.
	End Rem
	Method SetAngle(angle:Float)
		bmx_b2bodydef_setangle(b2ObjectPtr, angle)
	End Method
	
	Rem
	bbdoc: Returns the world angle of the body in degrees
	End Rem
	Method GetAngle:Float()
		Return bmx_b2bodydef_getangle(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Linear damping is used to reduce the linear velocity.
	about: The damping parameter can be larger than 1.0 but the damping effect becomes sensitive To the
	time Step when the damping parameter is large.
	End Rem
	Method SetLinearDamping(damping:Float)
		bmx_b2bodydef_setlineardamping(b2ObjectPtr, damping)
	End Method
	
	Rem
	bbdoc: Returns the linear damping.
	End Rem
	Method GetLinearDamping:Float()
		Return bmx_b2bodydef_getlineardamping(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Angular damping is used to reduce the angular velocity.
	about: The damping parameter can be larger than 1.0 but the damping effect becomes sensitive to the
	time Step when the damping parameter is large.
	End Rem
	Method SetAngularDamping(damping:Float)
		bmx_b2bodydef_setangulardamping(b2ObjectPtr, damping)
	End Method
	
	Rem
	bbdoc: Returns the angular damping.
	End Rem
	Method GetAngularDamping:Float()
		Return bmx_b2bodydef_getangulardamping(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Set this flag to False if this body should never fall asleep.
	about: Note that this increases CPU usage.
	End Rem
	Method SetAllowSleep(allow:Int)
		bmx_b2bodydef_setallowsleep(b2ObjectPtr, allow)
	End Method
	
	Rem
	bbdoc: Returns true if the body is allowed to sleep.
	End Rem
	Method GetAllowSleep:Int()
		Return bmx_b2bodydef_getallowsleep(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Is this body initially sleeping?
	End Rem
	Method isSleeping:Int()
		Return bmx_b2bodydef_issleeping(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Enables/Disables the sleeping state of the body.
	End Rem
	Method SetIsSleeping(sleeping:Int)
		bmx_b2bodydef_setissleeping(b2ObjectPtr, sleeping)
	End Method

	Rem
	bbdoc: Should this body be prevented from rotating? Useful For characters.
	End Rem
	Method SetFixedRotation(fixed:Int)
		bmx_b2bodydef_setfixedrotation(b2ObjectPtr, fixed)
	End Method
	
	Rem
	bbdoc: Returns True if rotation is fixed.
	End Rem
	Method GetFixedRotation:Int()
		Return bmx_b2bodydef_getfixedrotation(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Is this a fast moving body that should be prevented from tunneling through other moving bodies?
	about: Note that all bodies are prevented from tunneling through static bodies.
	<p>
	Warning: You should use this flag sparingly since it increases processing time.
	</p>
	End Rem
	Method SetIsBullet(bullet:Int)
		bmx_b2bodydef_setisbullet(b2ObjectPtr, bullet)
	End Method
	
	Rem
	bbdoc: Returns whether this is a bullet type body.
	End Rem
	Method GetIsBullet:Int()
		Return bmx_b2bodydef_isbullet(b2ObjectPtr)
	End Method
	
	Method Delete()
		If b2ObjectPtr Then
			bmx_b2bodydef_delete(b2ObjectPtr)
			b2ObjectPtr = Null
		End If
	End Method
	
End Type

Rem
bbdoc: Joint definitions are used to construct joints. 
End Rem
Type b2JointDef

	Field b2ObjectPtr:Byte Ptr
	Field userData:Object

	Rem
	bbdoc: The First attached body.
	End Rem
	Method SetBody1(body:b2Body)
		bmx_b2jointdef_setbody1(b2ObjectPtr, body.b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Returns the first attached body.
	End Rem
	Method GetBody1:b2Body()
		Return b2Body._create(bmx_b2jointdef_getbody1(b2ObjectPtr))
	End Method

	Rem
	bbdoc: The Second attached body.
	End Rem
	Method SetBody2(body:b2Body)
		bmx_b2jointdef_setbody2(b2ObjectPtr, body.b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Returns the second attached body.
	End Rem
	Method GetBody2:b2Body()
		Return b2Body._create(bmx_b2jointdef_getbody2(b2ObjectPtr))
	End Method

	Rem
	bbdoc: Set this flag to True if the attached bodies should collide.
	End Rem
	Method SetCollideConnected(collideConnected:Int)
		bmx_b2jointdef_setcollideconnected(b2ObjectPtr, collideConnected)
	End Method

	Rem
	bbdoc: Returns True if the attached bodies should collide.
	End Rem
	Method GetCollideConnected:Int()
		Return bmx_b2jointdef_getcollideconnected(b2ObjectPtr)
	End Method

End Type

Rem
bbdoc: A joint edge is used to connect bodies and joints together in a joint graph where each body is a node and each joint is an edge.
about: A joint edge belongs to a doubly linked list maintained in each attached body. Each joint has two
joint nodes, one for each attached body.
End Rem
Struct b2JointEdge

	Field b2ObjectPtr:Byte Ptr

	Method New(b2ObjectPtr:Byte Ptr)
		Self.b2ObjectPtr = b2ObjectPtr
	End Method

	Rem
	bbdoc: Provides quick access to the other body attached. 
	End Rem
	Method GetOther:b2Body()
		Return b2Body._create(bmx_b2jointedge_getother(b2ObjectPtr))
	End Method
	
	Rem
	bbdoc: Returns the joint.
	End Rem
	Method GetJoint:b2Joint()
		Return b2Joint._create(bmx_b2jointedge_getjoint(b2ObjectPtr))
	End Method
	
	Rem
	bbdoc: Returns the previous joint edge in the body's joint list.
	End Rem
	Method GetPrev:b2JointEdge()
		Return New b2JointEdge(bmx_b2jointedge_getprev(b2ObjectPtr))
	End Method
	
	Rem
	bbdoc: Returns the next joint edge in the body's joint list.
	End Rem
	Method GetNext:b2JointEdge()
		Return new b2JointEdge(bmx_b2jointedge_getnext(b2ObjectPtr))
	End Method
	
End Struct

Rem
bbdoc: Holds the mass data computed for a shape.
End Rem
Type b2MassData

	Field b2ObjectPtr:Byte Ptr
	Field owner:Int

	Function _create:b2MassData(b2ObjectPtr:Byte Ptr)
		If b2ObjectPtr Then
			Local this:b2MassData = New b2MassData
			bmx_b2massdata_delete(this.b2ObjectPtr)
			this.b2ObjectPtr = b2ObjectPtr
			this.owner = False
			Return this
		End If
	End Function

	Method New()
		b2ObjectPtr = bmx_b2massdata_new()
		owner = True
	End Method
	
	Method Delete()
		If b2ObjectPtr Then
			If owner Then
			bmx_b2massdata_delete(b2ObjectPtr)
			End If
			b2ObjectPtr = Null
		End If
	End Method

	Rem
	bbdoc: Sets the mass of the shape, usually in kilograms.
	End Rem	
	Method SetMass(mass:Float)	
		bmx_b2massdata_setmass(b2ObjectPtr, mass)
	End Method
	
	Rem
	bbdoc: Sets the position of the shape's centroid relative to the shape's origin.
	End Rem
	Method SetCenter(center:b2Vec2)
		bmx_b2massdata_setcenter(b2ObjectPtr, center)
	End Method
	
	Rem
	bbdoc: Sets the rotational inertia of the shape.
	End Rem
	Method SetRotationalInertia(i:Float)
		bmx_b2massdata_seti(b2ObjectPtr, i)
	End Method
	
End Type

Rem
bbdoc: A shape definition is used to construct a shape.
about: You can reuse shape definitions safely. 
End Rem
Type b2ShapeDef

	Field b2ObjectPtr:Byte Ptr
	Field userData:Object

	Rem
	bbdoc: Sets the shape's friction coefficient, usually in the range [0,1].
	End Rem
	Method SetFriction(friction:Float)
		bmx_b2shapedef_setfriction(b2ObjectPtr, friction)
	End Method
	
	Rem
	bbdoc: Gets the shape's friction coefficient, usually in the range [0,1].
	End Rem
	Method GetFriction:Float()
		Return bmx_b2shapedef_getfriction(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the shape's restitution (elasticity) usually in the range [0,1]. 
	End Rem
	Method SetRestitution(restitution:Float)
		bmx_b2shapedef_setrestitution(b2ObjectPtr, restitution)
	End Method
	
	Rem
	bbdoc: Gets the shape's restitution (elasticity) usually in the range [0,1]. 
	End Rem
	Method GetRestitution:Float()
		Return bmx_b2shapedef_getrestitution(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the shape's density, usually in kg/m^2. 
	End Rem
	Method SetDensity(density:Float)
		bmx_b2shapedef_setdensity(b2ObjectPtr, density)
	End Method
	
	Rem
	bbdoc: Gets the shape's density, usually in kg/m^2. 
	End Rem
	Method GetDensity:Float()
		Return bmx_b2shapedef_getdensity(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the contact filtering data.
	End Rem
	Method SetFilter(filter:b2FilterData)
		bmx_b2shapedef_setfilter(b2ObjectPtr, filter)
	End Method
	
	Rem
	bbdoc: Sets the contact filtering group index.
	End Rem
	Method SetFilterGroupIndex(groupIndex:Int)
		bmx_b2shapedef_setfilter_groupindex(b2ObjectPtr, groupIndex)
	End Method

	Rem
	bbdoc: Sets the contact filtering category bits.
	End Rem
	Method SetFilterCategoryBits(categoryBits:Short)
		bmx_b2shapedef_setfilter_categorybits(b2ObjectPtr, categoryBits)
	End Method

	Rem
	bbdoc: Sets the contact filtering mask bits.
	End Rem
	Method SetFilterMaskBits(maskBits:Short)
		bmx_b2shapedef_setfilter_maskbits(b2ObjectPtr, maskBits)
	End Method

	Rem
	bbdoc: Returns the contact filtering data.
	about: If you change the field values of the returned #b2FilterData, you will need to call #SetFilter() with the new data. 
	End Rem
	Method GetFilter:b2FilterData()
		Return bmx_b2shapedef_getfilter(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: A sensor shape collects contact information but never generates a collision response.
	End Rem
	Method SetIsSensor(sensor:Int)
		bmx_b2shapedef_setissensor(b2ObjectPtr, sensor)
	End Method
	
	Rem
	bbdoc: Returns True if this shape is a sensor.
	about: A sensor shape collects contact information but never generates a collision response.
	End Rem
	Method IsSensor:Int()
		Return bmx_b2shapedef_issensor(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the user data.
	End Rem
	Method SetUserData(data:Object)
		userData = data
	End Method
	
End Type

Rem
bbdoc: Convex polygon.
about: Vertices must be in CCW order.
End Rem
Type b2PolygonDef Extends b2ShapeDef

	Field _vertices:b2Vec2[]

	Method New()
		b2ObjectPtr = bmx_b2polygondef_create()
	End Method
	
	Rem
	bbdoc: Build vertices to represent an axis-aligned box. 
	about: Parameters:
	<ul>
	<li><b>hx </b> : the half-width.</li>
	<li><b>hy </b> : the half-height. </li>
	</ul>
	End Rem
	Method SetAsBox(hx:Float, hy:Float)
		bmx_b2polygondef_setasbox(b2ObjectPtr, hx, hy)
	End Method

	Rem
	bbdoc: Build vertices to represent an oriented box. 
	about: Parameters:
	<ul>
	<li><b>hx </b> : the half-width.</li>
	<li><b>hy </b> : the half-height. </li>
	<li><b>center </b> : the center of the box in local coordinates. </li>
	<li><b>angle </b> : the rotation of the box in local coordinates. </li>
	</ul>
	End Rem
	Method SetAsOrientedBox(hx:Float, hy:Float, center:b2Vec2, angle:Float)
		bmx_b2polygondef_setasorientedbox(b2ObjectPtr, hx, hy, center, angle)
	End Method
	
	Rem
	bbdoc: Sets the polygon vertices in local coordinates.
	End Rem
	Method SetVertices(vertices:b2Vec2[])
		_vertices = vertices
		bmx_b2polygondef_setvertices(b2ObjectPtr, vertices)
	End Method
	
	Rem
	bbdoc: Gets the polygon vertices in local coordinates.
	End Rem
	Method GetVertices:b2Vec2[]()
		Return _vertices
	End Method

	Method Delete()
		If b2ObjectPtr Then
			_vertices = Null
			bmx_b2polygondef_delete(b2ObjectPtr)
			b2ObjectPtr = Null
		End If
	End Method
	
End Type

Rem
bbdoc: A convex polygon.
End Rem
Type b2PolygonShape Extends b2Shape

	Rem
	bbdoc: Get the oriented bounding box relative to the parent body.
	End Rem
	Method GetOBB:b2OBB()
		Return b2OBB._create(bmx_b2polygonshape_getobb(b2ObjectPtr))
	End Method

	Rem
	bbdoc: Get local centroid relative to the parent body.
	End Rem
	Method GetCentroid:b2Vec2()
		Return bmx_b2polygonshape_getcentroid(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Get the vertex count. 
	End Rem
	Method GetVertexCount:Int()
		Return bmx_b2polygonshape_getvertexcount(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Get the vertices in local coordinates.
	End Rem
	Method GetVertices:b2Vec2[]()
		Return bmx_b2polygonshape_getvertices(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Get the core vertices in local coordinates.
	End Rem
	Method GetCoreVertices:b2Vec2[]()
		Return bmx_b2polygonshape_getcorevertices(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Get the edge normal vectors.
	about: There is one for each vertex.
	End Rem
	Method GetNormals:b2Vec2[]()
		Return bmx_b2polygonshape_getnormals(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Get the first vertex and apply the supplied transform.
	End Rem
	Method GetFirstVertex:b2Vec2(xf:b2XForm)
		Return bmx_b2polygonshape_getfirstvertex(b2ObjectPtr, xf)
	End Method

	Rem
	bbdoc: Get the centroid and apply the supplied transform.
	End Rem
	Method Centroid:b2Vec2(xf:b2XForm)
		Return bmx_b2polygonshape_centroid(b2ObjectPtr, xf)
	End Method

	Rem
	bbdoc: Get the support point in the given world direction.
	End Rem
	Method Support:b2Vec2(xf:b2XForm, d:b2Vec2)
		Return bmx_b2polygonshape_support(b2ObjectPtr, xf, d)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method TestSegment:Int(xf:b2XForm, lambda:Float Var, normal:b2Vec2 Var, segment:b2Segment, maxLambda:Float)
		Return bmx_b2shape_testsegment(b2ObjectPtr, xf, lambda, normal, segment, maxLambda)
	End Method

End Type

Extern
	Function bmx_b2polygondef_setvertices(handle:Byte Ptr, vertices:b2Vec2[])
	Function bmx_b2world_query:Int(handle:Byte Ptr, aabb:b2AABB Var, shapes:b2Shape[])
	Function bmx_b2world_raycast:Int(handle:Byte Ptr, segment:b2Segment Var, shapes:b2Shape[], solidShapes:Int)
	Function bmx_b2polygonshape_getvertices:b2Vec2[](handle:Byte Ptr)
	Function bmx_b2polygonshape_getcorevertices:b2Vec2[](handle:Byte Ptr)
	Function bmx_b2polygonshape_getnormals:b2Vec2[](handle:Byte Ptr)
	Function bmx_b2edgechaindef_setvertices(handle:Byte Ptr, vertices:b2Vec2[])
	Function bmx_b2shape_testsegment:Int(handle:Byte Ptr, xf:b2XForm Var, lambda:Float Var, normal:b2Vec2 Var, segment:b2Segment Var, maxLambda:Float)
End Extern

Rem
bbdoc: Used to build circle shapes.
End Rem
Type b2CircleDef Extends b2ShapeDef

	Method New()
		b2ObjectPtr = bmx_b2circledef_create()
	End Method
	
	Rem
	bbdoc: Sets the circle radius.
	End Rem
	Method SetRadius(radius:Float)
		bmx_b2circledef_setradius(b2ObjectPtr, radius)
	End Method
	
	Rem
	bbdoc: Returns the circle radius.
	End Rem
	Method GetRadius:Float()
		Return bmx_b2circledef_getradius(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the local position.
	End Rem
	Method SetLocalPosition(pos:b2Vec2)
		bmx_b2circledef_setlocalposition(b2ObjectPtr, pos)
	End Method
	
	Rem
	bbdoc: Returns the local position.
	End Rem
	Method GetLocalPosition:b2Vec2()
		Return bmx_b2circledef_getlocalposition(b2ObjectPtr)
	End Method

	Method Delete()
		If b2ObjectPtr Then
			bmx_b2circledef_delete(b2ObjectPtr)
			b2ObjectPtr = Null
		End If
	End Method

End Type

Rem
bbdoc: A circle shape.
End Rem
Type b2CircleShape Extends b2Shape

	Rem
	bbdoc: Get the local position of this circle in its parent body.
	End Rem
	Method GetLocalPosition:b2Vec2()
		Return bmx_b2circleshape_getlocalposition(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Get the radius of this circle. 
	End Rem
	Method GetRadius:Float()
		Return bmx_b2circleshape_getradius(b2ObjectPtr)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method TestSegment:Int(xf:b2XForm, lambda:Float Var, normal:b2Vec2 Var, segment:b2Segment, maxLambda:Float)
		Return bmx_b2shape_testsegment(b2ObjectPtr, xf, lambda, normal, segment, maxLambda)
	End Method

End Type

Rem
bbdoc: 
End Rem
Type b2EdgeChainDef Extends b2ShapeDef

	Field shapeDefPtr:Byte Ptr

	Field vertices:b2Vec2[]

	Method New()
		shapeDefPtr = bmx_b2edgechaindef_create()
		b2ObjectPtr = bmx_b2edgechaindef_getdef(shapeDefPtr)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method SetVertices(vertices:b2Vec2[])
		Self.vertices = vertices
		bmx_b2edgechaindef_setvertices(shapeDefPtr, vertices)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method GetVertices:b2Vec2[]()
		Return vertices
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method isALoop:Int()
		Return bmx_b2edgechaindef_isaloop(shapeDefPtr)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method SetIsALoop(value:Int)
		bmx_b2edgechaindef_setisaloop(shapeDefPtr, value)
	End Method

	Method Delete()
		If b2ObjectPtr Then
			vertices = Null
			bmx_b2edgechaindef_delete(shapeDefPtr)
			b2ObjectPtr = Null
		End If
	End Method

End Type

Rem
bbdoc: 
End Rem
Type b2EdgeShape Extends b2Shape

	Function _create:b2EdgeShape(b2ObjectPtr:Byte Ptr)
		If b2ObjectPtr Then
			Local this:b2EdgeShape = New b2EdgeShape
			this.b2ObjectPtr = b2ObjectPtr
			Return this
		End If
	End Function

	Method GetLength:Float()
		Return bmx_b2edgeshape_getlength(b2ObjectPtr)
	End Method

	' Local position of vertex in parent body
	Method GetVertex1:b2Vec2()
		Return bmx_b2edgeshape_getvertex1(b2ObjectPtr)
	End Method


	' Local position of vertex in parent body
	Method GetVertex2:b2Vec2()
		Return bmx_b2edgeshape_getvertex2(b2ObjectPtr)
	End Method


	' "Core" vertex with TOI slop For b2Distance functions:
	Method GetCoreVertex1:b2Vec2()
		Return bmx_b2edgeshape_getcorevertex1(b2ObjectPtr)
	End Method


	' "Core" vertex with TOI slop For b2Distance functions:
	Method GetCoreVertex2:b2Vec2()
		Return bmx_b2edgeshape_getcorevertex2(b2ObjectPtr)
	End Method

	
	' Perpendicular unit vector point, pointing from the solid side To the empty side: 
	Method GetNormalVector:b2Vec2()
		Return bmx_b2edgeshape_getnormalvector(b2ObjectPtr)
	End Method

	
	' Parallel unit vector, pointing from vertex1 To vertex2:
	Method GetDirectionVector:b2Vec2()
		Return bmx_b2edgeshape_getdirectionvector(b2ObjectPtr)
	End Method

	
	Method GetCorner1Vector:b2Vec2()
		Return bmx_b2edgeshape_getcorner1vector(b2ObjectPtr)
	End Method

	
	Method GetCorner2Vector:b2Vec2()
		Return bmx_b2edgeshape_getcorner2vector(b2ObjectPtr)
	End Method

	
	Method Corner1IsConvex:Int()
		Return bmx_b2edgeshape_corner1isconvex(b2ObjectPtr)
	End Method

	
	Method Corner2IsConvex:Int()
		Return bmx_b2edgeshape_corner2isconvex(b2ObjectPtr)
	End Method


	Method GetFirstVertex:b2Vec2(xf:b2XForm)
		Return bmx_b2edgeshape_getfirstvertex(b2ObjectPtr, xf)
	End Method


	Method Support:b2Vec2(xf:b2XForm, d:b2Vec2)
		Return bmx_b2edgeshape_support(b2ObjectPtr, xf, d)
	End Method

	
	' Get the Next edge in the chain.
	Method GetNextEdge:b2EdgeShape()
		Return b2EdgeShape._create(bmx_b2edgeshape_getnextedge(b2ObjectPtr))
	End Method

	
	' Get the previous edge in the chain.
	Method GetPrevEdge:b2EdgeShape()
		Return b2EdgeShape._create(bmx_b2edgeshape_getprevedge(b2ObjectPtr))
	End Method

	Rem
	bbdoc: 
	End Rem
	Method TestSegment:Int(xf:b2XForm, lambda:Float Var, normal:b2Vec2 Var, segment:b2Segment, maxLambda:Float)
		Return bmx_b2shape_testsegment(b2ObjectPtr, xf, lambda, normal, segment, maxLambda)
	End Method

End Type

Rem
bbdoc: Revolute joint definition. 
about: This requires defining an anchor point where the bodies are joined. The definition uses local anchor points
so that the initial configuration can violate the constraint slightly. You also need to specify the initial
relative angle for joint limits. This helps when saving and loading a game. The local anchor points are measured
from the body's origin rather than the center of mass because: 1. you might not know where the center of mass
will be. 2. if you add/remove shapes from a body and recompute the mass, the joints will be broken. 
End Rem
Type b2RevoluteJointDef Extends b2JointDef

	Method New()
		b2ObjectPtr = bmx_b2revolutejointdef_create()
	End Method
	
	Rem
	bbdoc: Initialize the bodies, anchors, and reference angle using the world anchor.
	End Rem
	Method Initialize(body1:b2Body, body2:b2Body, anchor:b2Vec2)
		bmx_b2revolutejointdef_initialize(b2ObjectPtr, body1.b2ObjectPtr, body2.b2ObjectPtr, anchor)
	End Method
	
	Rem
	bbdoc: The local anchor point relative to body1's origin.
	end rem
	Method GetLocalAnchor1:b2Vec2()
		Return bmx_b2revolutejointdef_getlocalanchor1(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the local anchor point relative to body1's origin.
	End Rem
	Method SetLocalAnchor1(anchor:b2Vec2)
		bmx_b2revolutejointdef_setlocalanchor1(b2ObjectPtr, anchor)
	End Method
	
	Rem
	bbdoc: The local anchor point relative to body2's origin.
	end rem
	Method GetLocalAnchor2:b2Vec2()
		Return bmx_b2revolutejointdef_getlocalanchor2(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the local anchor point relative to body2's origin.
	End Rem
	Method SetLocalAnchor2(anchor:b2Vec2)
		bmx_b2revolutejointdef_setlocalanchor2(b2ObjectPtr, anchor)
	End Method
	
	Rem
	bbdoc: The body2 angle minus body1 angle in the reference state (degrees).
	End Rem
	Method GetReferenceAngle:Float()
		Return bmx_b2revolutejointdef_getreferenceangle(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the body2 angle minus body1 angle in the reference state (degrees).
	End Rem
	Method SetReferenceAngle(angle:Float)
		bmx_b2revolutejointdef_setreferenceangle(b2ObjectPtr, angle)
	End Method
	
	Rem
	bbdoc: A flag to enable joint limits.
	end rem
	Method IsLimitEnabled:Int()
		Return bmx_b2revolutejointdef_islimitenabled(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Enables joint limits.
	End Rem
	Method EnableLimit(limit:Int)
		bmx_b2revolutejointdef_enablelimit(b2ObjectPtr, limit)
	End Method
	
	Rem
	bbdoc: The lower angle for the joint limit (degrees).
	End Rem
	Method GetLowerAngle:Float()
		Return bmx_b2revolutejointdef_getlowerangle(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the lower angle for the joint limit (degrees).
	End Rem
	Method SetLowerAngle(angle:Float)
		bmx_b2revolutejointdef_setlowerangle(b2ObjectPtr, angle)
	End Method
	
	Rem
	bbdoc: The upper angle for the joint limit (degrees).
	End Rem
	Method GetUpperAngle:Float()
		Return bmx_b2revolutejointdef_getupperangle(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the upper angle for the joint limit (degrees).
	End Rem
	Method SetUpperAngle(angle:Float)
		bmx_b2revolutejointdef_setupperangle(b2ObjectPtr, angle)
	End Method
	
	Rem
	bbdoc: A flag to enable the joint motor.
	end rem
	Method IsMotorEnabled:Int()
		Return bmx_b2revolutejointdef_ismotorenabled(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Enables the joint motor.
	End Rem
	Method EnableMotor(value:Int)
		bmx_b2revolutejointdef_enablemotor(b2ObjectPtr, value)
	End Method
	
	Rem
	bbdoc: The desired motor speed, usually in degrees per second.
	End Rem
	Method GetMotorSpeed:Float()
		Return bmx_b2revolutejointdef_getmotorspeed(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the desired motor speed, usually in degrees per second.
	End Rem
	Method SetMotorSpeed(speed:Float)
		bmx_b2revolutejointdef_setmotorspeed(b2ObjectPtr, speed)
	End Method
	
	Rem
	bbdoc: The maximum motor torque used to achieve the desired motor speed, usually in N-m.
	End Rem
	Method GetMaxMotorTorque:Float()
		Return bmx_b2revolutejointdef_getmaxmotortorque(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the maximum motor torque used to achieve the desired motor speed, usually in N-m.
	End Rem
	Method SetMaxMotorTorque(torque:Float)
		bmx_b2revolutejointdef_setmaxmotortorque(b2ObjectPtr, torque)
	End Method

	Method Delete()
		If b2ObjectPtr Then
			bmx_b2revolutejointdef_delete(b2ObjectPtr)
			b2ObjectPtr = Null
		End If
	End Method
	
End Type

Rem
bbdoc:Pulley joint definition. 
about: This requires two ground anchors, two dynamic body anchor points, max lengths for each side, and a pulley ratio. 
End Rem
Type b2PulleyJointDef Extends b2JointDef

	Method New()
		b2ObjectPtr = bmx_b2pulleyjointdef_create()
	End Method
	
	Rem
	bbdoc: Initialize the bodies, anchors, lengths, max lengths, and ratio using the world anchors.
	End Rem
	Method Initialize(body1:b2Body, body2:b2Body, groundAnchor1:b2Vec2, groundAnchor2:b2Vec2, ..
	                anchor1:b2Vec2, anchor2:b2Vec2, ratio:Float)
		bmx_b2pulleyjointdef_initialize(b2ObjectPtr, body1.b2ObjectPtr, body2.b2ObjectPtr, groundAnchor1, ..
			groundAnchor2, anchor1, anchor2, ratio)
	End Method
	
	Rem
	bbdoc: The first ground anchor in world coordinates. This point never moves.
	end rem
	Method SetGroundAnchor1(anchor:b2Vec2)
		bmx_b2pulleyjointdef_setgroundanchor1(b2ObjectPtr, anchor)
	End Method
	
	Rem
	bbdoc: Returns the first ground anchor, in world coordinates.
	End Rem
	Method GetGroundAnchor1:b2Vec2()
		Return bmx_b2pulleyjointdef_getgroundanchor1(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: The second ground anchor in world coordinates. This point never moves.
	end rem
	Method SetGroundAnchor2(anchor:b2Vec2)
		bmx_b2pulleyjointdef_setgroundanchor2(b2ObjectPtr, anchor)
	End Method
	
	Rem
	bbdoc: Returns the second ground anchor, in world coordinates.
	End Rem
	Method GetGroundAnchor2:b2Vec2()
		Return bmx_b2pulleyjointdef_getgroundanchor2(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: The local anchor point relative to body1's origin.
	end rem
	Method SetLocalAnchor1(anchor:b2Vec2)
		bmx_b2pulleyjointdef_setlocalanchor1(b2ObjectPtr, anchor)
	End Method
	
	Rem
	bbdoc: Returns the local anchor point.
	End Rem
	Method GetLocalAnchor1:b2Vec2()
		Return bmx_b2pulleyjointdef_getlocalanchor1(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: The local anchor point relative to body2's origin.
	end rem
	Method SetLocalAnchor2(anchor:b2Vec2)
		bmx_b2pulleyjointdef_setlocalanchor2(b2ObjectPtr, anchor)
	End Method
	
	Rem
	bbdoc: Returns the local anchor point.
	End Rem
	Method GetLocalAnchor2:b2Vec2()
		Return bmx_b2pulleyjointdef_getlocalanchor2(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: The a reference length for the segment attached to body1.
	end rem
	Method SetLength1(length:Float)
		bmx_b2pulleyjointdef_setlength1(b2ObjectPtr, length)
	End Method
	
	Rem
	bbdoc: Returns the reference length for the segment attached to body1.
	End Rem
	Method GetLength1:Float()
		Return bmx_b2pulleyjointdef_getlength1(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: The maximum length of the segment attached to body1.
	end rem
	Method SetMaxLength1(maxLength:Float)
		bmx_b2pulleyjointdef_setmaxlength1(b2ObjectPtr, maxLength)
	End Method
	
	Rem
	bbdoc: Returns the maximum length of the segment attached to body1.
	End Rem
	Method GetMaxLength1:Float()
		Return bmx_b2pulleyjointdef_getmaxlength1(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: The a reference length for the segment attached to body2.
	end rem
	Method SetLength2(length:Float)
		bmx_b2pulleyjointdef_setlength2(b2ObjectPtr, length)
	End Method
	
	Rem
	bbdoc: Returns the reference length for the segment attached to body2.
	End Rem
	Method GetLength2:Float()
		Return bmx_b2pulleyjointdef_getlength2(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: The maximum length of the segment attached to body2.
	end rem
	Method SetMaxLength2(maxLength:Float)
		bmx_b2pulleyjointdef_setmaxlength2(b2ObjectPtr, maxLength)
	End Method
	
	Rem
	bbdoc: Returns the maximum length of the segment attached to body2.
	End Rem
	Method GetMaxLength2:Float()
		Return bmx_b2pulleyjointdef_getmaxlength2(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: The pulley ratio, used to simulate a block-and-tackle.
	end rem
	Method SetRatio(ratio:Float)
		bmx_b2pulleyjointdef_setratio(b2ObjectPtr, ratio)
	End Method
	
	Rem
	bbdoc: Returns the pulley ratio.
	End Rem
	Method GetRatio:Float()
		Return bmx_b2pulleyjointdef_getratio(b2ObjectPtr)
	End Method

	Method Delete()
		If b2ObjectPtr Then
			bmx_b2pulleyjointdef_delete(b2ObjectPtr)
			b2ObjectPtr = Null
		End If
	End Method
	
End Type

Rem
bbdoc: Prismatic joint definition. 
about: This requires defining a line of motion using an axis and an anchor point. The definition uses local
anchor points and a local axis so that the initial configuration can violate the constraint slightly. The
joint translation is zero when the local anchor points coincide in world space. Using local anchors and a
local axis helps when saving and loading a game. 
End Rem
Type b2PrismaticJointDef Extends b2JointDef

	Method New()
		b2ObjectPtr = bmx_b2prismaticjointdef_create()
	End Method
	
	Rem
	bbdoc: Initialize the bodies, anchors, axis, and reference angle using the world anchor and world axis.
	End Rem
	Method Initialize(body1:b2Body, body2:b2Body, anchor:b2Vec2, axis:b2Vec2)
		bmx_b2prismaticjointdef_initialize(b2ObjectPtr, body1.b2ObjectPtr, body2.b2ObjectPtr, ..
				anchor, axis)
	End Method
	
	Rem
	bbdoc: The local anchor point relative to body1's origin.
	End Rem
	Method SetLocalAnchor1(anchor:b2Vec2)
		bmx_b2prismaticjointdef_setlocalanchor1(b2ObjectPtr, anchor)
	End Method
	
	Rem
	bbdoc: Returns the local anchor point.
	End Rem
	Method GetLocalAnchor1:b2Vec2()
		Return bmx_b2prismaticjointdef_getlocalanchor1(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: The local anchor point relative to body2's origin.
	End Rem
	Method SetLocalAnchor2(anchor:b2Vec2)
		bmx_b2prismaticjointdef_setlocalanchor2(b2ObjectPtr, anchor)
	End Method
	
	Rem
	bbdoc: Returns the local anchor point.
	End Rem
	Method GetLocalAnchor2:b2Vec2()
		Return bmx_b2prismaticjointdef_getlocalanchor2(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: The local translation axis in body1.
	End Rem
	Method SetLocalAxis1(axis:b2Vec2)
		bmx_b2prismaticjointdef_setlocalaxis1(b2ObjectPtr, axis)
	End Method
	
	Rem
	bbdoc: Returns the local translation axis in body1.
	End Rem
	Method GetLocalAxis1:b2Vec2()
		Return bmx_b2prismaticjointdef_getlocalaxis1(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: The constrained angle between the bodies: body2_angle - body1_angle.
	End Rem
	Method SetReferenceAngle(angle:Float)
		bmx_b2prismaticjointdef_setreferenceangle(b2ObjectPtr, angle)
	End Method
	
	Rem
	bbdoc: Returns the constrained angle between the bodies.
	End Rem
	Method GetReferenceAngle:Float()
		Return bmx_b2prismaticjointdef_getreferenceangle(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Enable/disable the joint limit.
	End Rem
	Method EnableLimit(value:Int)
		bmx_b2prismaticjointdef_enablelimit(b2ObjectPtr, value)
	End Method
	
	Rem
	bbdoc: Returns True if the joint limit is enabled.
	End Rem
	Method IsLimitEnabled:Int()
		Return bmx_b2prismaticjointdef_islimitenabled(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: The lower translation limit, usually in meters.
	End Rem
	Method SetLowerTranslation(Translation:Float)
		bmx_b2prismaticjointdef_setlowertranslation(b2ObjectPtr, Translation)
	End Method
	
	Rem
	bbdoc: Returns the lower translation limit.
	End Rem
	Method GetLowerTranslation:Float()
		Return bmx_b2prismaticjointdef_getlowertranslation(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: The upper translation limit, usually in meters.
	End Rem
	Method SetUpperTranslation(Translation:Float)
		bmx_b2prismaticjointdef_setuppertranslation(b2ObjectPtr, Translation)
	End Method
	
	Rem
	bbdoc: Returns the upper translation limit.
	End Rem
	Method GetUpperTranslation:Float()
		Return bmx_b2prismaticjointdef_getuppertranslation(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Enable/disable the joint motor.
	end rem
	Method EnableMotor(value:Int)
		bmx_b2prismaticjointdef_enablemotor(b2ObjectPtr, value)
	End Method
	
	Rem
	bbdoc: Returns true if the joint motor is enabled.
	End Rem
	Method IsMotorEnabled:Int()
		Return bmx_b2prismaticjointdef_ismotorenabled(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: The maximum motor torque, usually in N-m.
	end rem
	Method SetMaxMotorForce(force:Float)
		bmx_b2prismaticjointdef_setmaxmotorforce(b2ObjectPtr, force)
	End Method
	
	Rem
	bbdoc: Returns the maximum motor torque.
	End Rem
	Method GetMaxMotorForce:Float()
		Return bmx_b2prismaticjointdef_getmaxmotorforce(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: The desired motor speed in degrees per second.
	End Rem
	Method SetMotorSpeed(speed:Float)
		bmx_b2prismaticjointdef_setmotorspeed(b2ObjectPtr, speed)
	End Method
	
	Rem
	bbdoc: The motorspeed, in degrees per second.
	End Rem
	Method GetMotorSpeed:Float()
		Return bmx_b2prismaticjointdef_getmotorspeed(b2ObjectPtr)
	End Method

	Method Delete()
		If b2ObjectPtr Then
			bmx_b2prismaticjointdef_delete(b2ObjectPtr)
			b2ObjectPtr = Null
		End If
	End Method

End Type

Rem
bbdoc: Mouse joint definition. 
about: This requires a world target point, tuning parameters, and the time step. 
End Rem
Type b2MouseJointDef Extends b2JointDef
	
	Method New()
		b2ObjectPtr = bmx_b2mousejointdef_new()
	End Method

	Rem
	bbdoc: The initial world target point.
	about: This is assumed to coincide with the body anchor initially.
	End Rem
	Method SetTarget(target:b2Vec2)
		bmx_b2mousejointdef_settarget(b2ObjectPtr, target)
	End Method
	
	Rem
	bbdoc: Returns the initial world target point.
	End Rem
	Method GetTarget:b2Vec2()
		Return bmx_b2mousejointdef_gettarget(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: The maximum constraint force that can be exerted to move the candidate body.
	about: Usually you will express as some multiple of the weight (multiplier * mass * gravity).
	End Rem
	Method SetMaxForce(maxForce:Float)
		bmx_b2mousejointdef_setmaxforce(b2ObjectPtr, maxForce)
	End Method
	
	Rem
	bbdoc: Returns the maximum constraint force that can be exerted to move the candidate body.
	End Rem
	Method GetMaxForce:Float()
		Return bmx_b2mousejointdef_getmaxforce(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: The response speed.
	end rem
	Method SetFrequencyHz(frequency:Float)
		bmx_b2mousejointdef_setfrequencyhz(b2ObjectPtr, frequency)
	End Method
	
	Rem
	bbdoc: Returns the response speed.
	End Rem
	Method GetFrequencyHz:Float()
		Return bmx_b2mousejointdef_getfrequencyhz(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: The damping ratio.
	about: 0 = no damping, 1 = critical damping.
	End Rem
	Method SetDampingRatio(ratio:Float)
		bmx_b2mousejointdef_setdampingration(b2ObjectPtr, ratio)
	End Method
	
	Rem
	bbdoc: Returns the damping ratio.
	End Rem
	Method GetDampingRatio:Float()
		Return bmx_b2mousejointdef_getdampingratio(b2ObjectPtr)
	End Method
	
	Method Delete()
		If b2ObjectPtr Then
			bmx_b2mousejointdef_delete(b2ObjectPtr)
			b2ObjectPtr = Null
		End If
	End Method

End Type

Rem
bbdoc: Gear joint definition. 
about: This definition requires two existing revolute or prismatic joints (any combination will work). The provided
joints must attach a dynamic body to a static body.
End Rem
Type b2GearJointDef Extends b2JointDef

	Method New()
		b2ObjectPtr = bmx_b2gearjointdef_new()
	End Method
	
	Rem
	bbdoc: Sets the first revolute/prismatic joint attached to the gear joint. 
	End Rem
	Method SetJoint1(joint:b2Joint)
		bmx_b2gearjointdef_setjoint1(b2ObjectPtr, joint.b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the second revolute/prismatic joint attached to the gear joint. 
	End Rem
	Method SetJoint2(joint:b2Joint)
		bmx_b2gearjointdef_setjoint2(b2ObjectPtr, joint.b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the gear ratio. 
	End Rem
	Method SetRatio(ratio:Float)
		bmx_b2gearjointdef_setratio(b2ObjectPtr, ratio)
	End Method

	Method Delete()
		If b2ObjectPtr Then
			bmx_b2gearjointdef_delete(b2ObjectPtr)
			b2ObjectPtr = Null
		End If
	End Method

End Type

Rem
bbdoc: Line joint definition.
about: This requires defining a line of motion using an axis and an anchor point. The definition uses local
anchor points and a local axis so that the initial configuration can violate the constraint slightly. The joint translation is zero
when the local anchor points coincide in world space. Using local anchors and a local axis helps when saving and loading a game.
End Rem
Type b2LineJointDef Extends b2JointDef

	Method New()
		b2ObjectPtr = bmx_b2linejointdef_create()
	End Method
	
	Rem
	bbdoc: Initialize the bodies, anchors, axis, and reference angle using the world anchor and world axis.
	End Rem
	Method Initialize(body1:b2Body, body2:b2Body, anchor:b2Vec2, axis:b2Vec2)
		bmx_b2linejointdef_initialize(b2ObjectPtr, body1.b2ObjectPtr, body2.b2ObjectPtr, ..
				anchor, axis)
	End Method

	Rem
	bbdoc: Sets the local anchor point relative to body1's origin. 
	End Rem
	Method SetLocalAnchor1(anchor:b2Vec2)
		bmx_b2linejointdef_setlocalanchor1(b2ObjectPtr, anchor)
	End Method

	Rem
	bbdoc: Returns the local anchor point relative to body1's origin. 
	End Rem
	Method GetLocalAnchor1:b2Vec2()
		Return bmx_b2linejointdef_getlocalanchor1(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Sets the Local anchor point relative to body2's origin.
	End Rem
	Method SetLocalAnchor2(anchor:b2Vec2)
		bmx_b2linejointdef_setlocalanchor2(b2ObjectPtr, anchor)
	End Method

	Rem
	bbdoc: Returns the Local anchor point relative to body2's origin.
	End Rem
	Method GetLocalAnchor2:b2Vec2()
		Return bmx_b2linejointdef_getlocalanchor2(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Sets the local translation axis in body1.
	End Rem
	Method SetLocalAxis1(axis:b2Vec2)
		bmx_b2linejointdef_setlocalaxis1(b2ObjectPtr, axis)
	End Method

	Rem
	bbdoc: Returns the local translation axis in body1.
	End Rem
	Method GetLocalAxis1:b2Vec2()
		Return bmx_b2linejointdef_getlocalaxis1(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Enables/disables the joint limit.
	End Rem
	Method EnableLimit(limit:Int)
		bmx_b2linejointdef_enablelimit(b2ObjectPtr, limit)
	End Method
	
	Rem
	bbdoc: Returns the joint limit.
	End Rem
	Method GetLimit:Int()
		Return bmx_b2linejointdef_getlimit(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the lower translation limit, usually in meters.
	End Rem
	Method SetLowerTranslation(Translation:Float)
		bmx_b2linejointdef_setlowertranslation(b2ObjectPtr, Translation)
	End Method
	
	Rem
	bbdoc: Gets the lower translation limit, usually in meters.
	End Rem
	Method GetLowerTranslation:Float()
		Return bmx_b2linejointdef_getlowertranslation(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Sets the upper translation limit, usually in meters.
	End Rem
	Method SetUpperTranslation(Translation:Float)
		bmx_b2linejointdef_setuppertranslation(b2ObjectPtr, Translation)
	End Method
	
	Rem
	bbdoc: Gets the upper translation limit, usually in meters.
	End Rem
	Method GetUpperTranslation:Float()
		Return bmx_b2linejointdef_getuppertranslation(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Enables/disables the joint motor.
	End Rem
	Method EnableMotor(enable:Int)
		bmx_b2linejointdef_enablemotor(b2ObjectPtr, enable)
	End Method
	
	Rem
	bbdoc: Is the motor enabled?
	End Rem
	Method IsMotorEnabled:Int()
		Return bmx_b2linejointdef_ismotorenabled(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the maximum motor torque, usually in N-m.
	End Rem
	Method SetMaxMotorForce(maxForce:Float)
		bmx_b2linejointdef_setmaxmotorforce(b2ObjectPtr, maxForce)
	End Method
	
	Rem
	bbdoc: Returns the maximum motor torque, usually in N-m.
	End Rem
	Method GetMaxMotorForce:Float()
		Return bmx_b2linejointdef_getmaxmotorforce(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the desired motor speed, in degrees per second.
	End Rem
	Method SetMotorSpeed(speed:Float)
		bmx_b2linejointdef_setmotorspeed(b2ObjectPtr, speed)
	End Method
	
	Rem
	bbdoc: Returns the desired motor speed, in degrees per second.
	End Rem
	Method GetMotorSpeed:Float()
		Return bmx_b2linejointdef_getmotorspeed(b2ObjectPtr)
	End Method

	Method Delete()
		If b2ObjectPtr Then
			bmx_b2linejointdef_delete(b2ObjectPtr)
			b2ObjectPtr = Null
		End If
	End Method

End Type

Rem
bbdoc: A line joint.
about: This joint provides one degree of freedom: translation along an axis fixed in body1. You can use a joint limit to restrict
the range of motion and a joint motor to drive the motion or to model joint friction.
End Rem
Type b2LineJoint Extends b2Joint

	Rem
	bbdoc: 
	End Rem
	Method GetAnchor1:b2Vec2()
		Return bmx_b2linejoint_getanchor1(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method GetAnchor2:b2Vec2()
		Return bmx_b2linejoint_getanchor2(b2ObjectPtr)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method GetReactionForce:b2Vec2(inv_dt:Float)
		Return bmx_b2linejoint_getreactionforce(b2ObjectPtr, inv_dt)
	End Method

	Rem
	bbdoc: 
	End Rem
	Method GetReactionTorque:Float(inv_dt:Float)
		Return bmx_b2linejoint_getreactiontorque(b2ObjectPtr, inv_dt)
	End Method

	Rem
	bbdoc: Get the current joint translation, usually in meters.
	End Rem
	Method GetJointTranslation:Float()
		Return bmx_b2linejoint_getjointtranslation(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Get the current joint translation speed, usually in meters per second.
	End Rem
	Method GetJointSpeed:Float()
		Return bmx_b2linejoint_getjointspeed(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Is the joint limit enabled?
	End Rem
	Method IsLimitEnabled:Int()
		Return bmx_b2linejoint_islimitenabled(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Enable/disable the joint limit.
	End Rem
	Method EnableLimit(flag:Int)
		bmx_b2linejoint_enablelimit(b2ObjectPtr, flag)
	End Method

	Rem
	bbdoc: Get the lower joint limit, usually in meters.
	End Rem
	Method GetLowerLimit:Float()
		Return bmx_b2linejoint_getlowerlimit(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Get the upper joint limit, usually in meters.
	End Rem
	Method GetUpperLimit:Float()
		Return bmx_b2linejoint_getupperlimit(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Set the joint limits, usually in meters.
	End Rem
	Method SetLimits(_lower:Float, _upper:Float)
		bmx_b2linejoint_setlimits(b2ObjectPtr, _lower, _upper)
	End Method

	Rem
	bbdoc: Is the joint motor enabled?
	End Rem
	Method IsMotorEnabled:Int()
		Return bmx_b2linejoint_ismotorenabled(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Enable/disable the joint motor.
	End Rem
	Method EnableMotor(flag:Int)
		bmx_b2linejoint_enablemotor(b2ObjectPtr, flag)
	End Method

	Rem
	bbdoc: Set the motor speed, usually in meters per second.
	End Rem
	Method SetMotorSpeed(speed:Float)
		bmx_b2linejoint_setmotorspeed(b2ObjectPtr, speed)
	End Method

	Rem
	bbdoc: Get the motor speed, usually in meters per second.
	End Rem
	Method GetMotorSpeed:Float()
		Return bmx_b2linejoint_getmotorspeed(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Set the maximum motor force, usually in N.
	End Rem
	Method SetMaxMotorForce(force:Float)
		bmx_b2linejoint_setmaxmotorforce(b2ObjectPtr, force)
	End Method

	Rem
	bbdoc: Get the current motor force, usually in N.
	End Rem
	Method GetMotorForce:Float()
		Return bmx_b2linejoint_getmotorforce(b2ObjectPtr)
	End Method
	
End Type

Rem
bbdoc: Distance joint definition.
about: This requires defining an anchor point on both bodies and the non-zero length of the
distance joint. The definition uses local anchor points so that the initial configuration can violate the
constraint slightly. This helps when saving and loading a game.
<p>
Warning: Do not use a zero or short length.
</p>
End Rem
Type b2DistanceJointDef Extends b2JointDef

	Method New()
		b2ObjectPtr = bmx_b2distancejointdef_new()
	End Method
	
	Rem
	bbdoc: Initialize the bodies, anchors, and length using the world anchors. 
	End Rem
	Method Initialize(body1:b2Body, body2:b2Body, anchor1:b2Vec2, anchor2:b2Vec2)
		bmx_b2distancejointdef_initialize(b2ObjectPtr, body1.b2ObjectPtr, body2.b2ObjectPtr, anchor1, anchor2)
	End Method
	
	Rem
	bbdoc: Sets the local anchor point relative to body1's origin. 
	End Rem
	Method SetLocalAnchor1(anchor:b2Vec2)
		bmx_b2distancejointdef_setlocalanchor1(b2ObjectPtr, anchor)
	End Method

	Rem
	bbdoc: Returns the local anchor point relative to body1's origin. 
	End Rem
	Method GetLocalAnchor1:b2Vec2()
		Return bmx_b2distancejointdef_getlocalanchor1(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Sets the Local anchor point relative to body2's origin.
	End Rem
	Method SetLocalAnchor2(anchor:b2Vec2)
		bmx_b2distancejointdef_setlocalanchor2(b2ObjectPtr, anchor)
	End Method

	Rem
	bbdoc: Returns the Local anchor point relative to body2's origin.
	End Rem
	Method GetLocalAnchor2:b2Vec2()
		Return bmx_b2distancejointdef_getlocalanchor2(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Sets the equilibrium length between the anchor points.
	End Rem
	Method SetLength(length:Float)
		bmx_b2distancejointdef_setlength(b2ObjectPtr, length)
	End Method

	Rem
	bbdoc: Returns the equilibrium length between the anchor points.
	End Rem
	Method GetLength:Float()
		Return bmx_b2distancejointdef_getlength(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Sets the response speed.
	End Rem
	Method SetFrequencyHz(freq:Float)
		bmx_b2distancejointdef_setfrequencyhz(b2ObjectPtr, freq)
	End Method

	Rem
	bbdoc: Sets the damping ratio. 0 = no damping, 1 = critical damping.
	End Rem
	Method SetDampingRatio(ratio:Float)
		bmx_b2distancejointdef_setdampingratio(b2ObjectPtr, ratio)
	End Method

	
	Method Delete()
		If b2ObjectPtr Then
			bmx_b2distancejointdef_delete(b2ObjectPtr)
			b2ObjectPtr = Null
		End If
	End Method

End Type

Rem
bbdoc: A distance joint constrains two points on two bodies to remain at a fixed distance from each other. 
about: You can view this as a massless, rigid rod. 
End Rem
Type b2DistanceJoint Extends b2Joint

	Rem
	bbdoc: Get the anchor point on body1 in world coordinates.
	End Rem
	Method GetAnchor1:b2Vec2()
		Return bmx_b2distancejoint_getanchor1(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the anchor point on body2 in world coordinates. 
	End Rem
	Method GetAnchor2:b2Vec2()
		Return bmx_b2distancejoint_getanchor2(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the reaction force on body2 at the joint anchor. 
	End Rem
	Method GetReactionForce:b2Vec2(inv_dt:Float)
		Return bmx_b2distancejoint_getreactionforce(b2ObjectPtr, inv_dt)
	End Method
	
	Rem
	bbdoc: Get the reaction torque on body2. 
	End Rem
	Method GetReactionTorque:Float(inv_dt:Float)
		Return bmx_b2distancejoint_getreactiontorque(b2ObjectPtr, inv_dt)
	End Method

End Type

Rem
bbdoc: A revolute joint constrains to bodies to share a common point while they are free to rotate about the point. 
about: The relative rotation about the shared point is the joint angle. You can limit the relative rotation
with a joint limit that specifies a lower and upper angle. You can use a motor to drive the relative rotation
about the shared point. A maximum motor torque is provided so that infinite forces are not generated. 
End Rem
Type b2RevoluteJoint Extends b2Joint
	
	Rem
	bbdoc: Get the anchor point on body1 in world coordinates.
	End Rem
	Method GetAnchor1:b2Vec2()
		Return bmx_b2revolutejoint_getanchor1(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the anchor point on body2 in world coordinates. 
	End Rem
	Method GetAnchor2:b2Vec2()
		Return bmx_b2revolutejoint_getanchor2(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the reaction force on body2 at the joint anchor. 
	End Rem
	Method GetReactionForce:b2Vec2(inv_dt:Float)
		Return bmx_b2revolutejoint_getreactionforce(b2ObjectPtr, inv_dt)
	End Method
	
	Rem
	bbdoc: Get the reaction torque on body2. 
	End Rem
	Method GetReactionTorque:Float(inv_dt:Float)
		Return bmx_b2revolutejoint_getreactiontorque(b2ObjectPtr, inv_dt)
	End Method
	
	Rem
	bbdoc: Get the current joint angle in degrees.
	End Rem
	Method GetJointAngle:Float()
		Return bmx_b2revolutejoint_getjointangle(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the current joint angle speed in degrees per second.
	End Rem
	Method GetJointSpeed:Float()
		Return bmx_b2revolutejoint_getjointspeed(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Is the joint limit enabled?
	end rem
	Method IsLimitEnabled:Int()
		Return bmx_b2revolutejoint_islimitenabled(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Enable/disable the joint limit.
	end rem
	Method EnableLimit(flag:Int)
		bmx_b2revolutejoint_enablelimit(b2ObjectPtr, flag)
	End Method
	
	Rem
	bbdoc: Get the lower joint limit in degrees.
	End Rem
	Method GetLowerLimit:Float()
		Return bmx_b2revolutejoint_getlowerlimit(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the upper joint limit in degrees.
	End Rem
	Method GetUpperLimit:Float()
		Return bmx_b2revolutejoint_getupperlimit(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Set the joint limits in degrees.
	End Rem
	Method SetLimits(lowerLimit:Float, upperLimit:Float)
		bmx_b2revolutejoint_setlimits(b2ObjectPtr, lowerLimit, upperLimit)
	End Method
	
	Rem
	bbdoc: Is the joint motor enabled?
	end rem
	Method IsMotorEnabled:Int()
		Return bmx_b2revolutejoint_ismotorenabled(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Enable/disable the joint motor.
	end rem
	Method EnableMotor(flag:Int)
		bmx_b2revolutejoint_enablemotor(b2ObjectPtr, flag)
	End Method
	
	Rem
	bbdoc: Set the motor speed in radians per second.
	end rem
	Method SetMotorSpeed(speed:Float)
		bmx_b2revolutejoint_setmotorspeed(b2ObjectPtr, speed)
	End Method
	
	Rem
	bbdoc: Get the motor speed in radians per second.
	end rem
	Method GetMotorSpeed:Float()
		Return bmx_b2revolutejoint_getmotorspeed(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Set the maximum motor torque, usually in N-m.
	end rem
	Method SetMaxMotorTorque(torque:Float)
		bmx_b2revolutejoint_setmaxmotortorque(b2ObjectPtr, torque)
	End Method
	
	Rem
	bbdoc: Get the current motor torque, usually in N-m.
	end rem
	Method GetMotorTorque:Float()
		Return bmx_b2revolutejoint_getmotortorque(b2ObjectPtr)
	End Method

End Type

Rem
bbdoc: 
End Rem
Type b2PrismaticJoint Extends b2Joint
	
	Rem
	bbdoc: Get the anchor point on body1 in world coordinates. 
	End Rem
	Method GetAnchor1:b2Vec2()
		Return bmx_b2prismaticjoint_getanchor1(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the anchor point on body2 in world coordinates. 
	End Rem
	Method GetAnchor2:b2Vec2()
		Return bmx_b2prismaticjoint_getanchor2(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the reaction force on body2 at the joint anchor. 
	End Rem
	Method GetReactionForce:b2Vec2(inv_dt:Float)
		Return bmx_b2prismaticjoint_getreactionforce(b2ObjectPtr, inv_dt)
	End Method
	
	Rem
	bbdoc: Get the reaction torque on body2. 
	End Rem
	Method GetReactionTorque:Float(inv_dt:Float)
		Return bmx_b2prismaticjoint_getreactiontorque(b2ObjectPtr, inv_dt)
	End Method
	
	Rem
	bbdoc: Get the current joint translation, usually in meters.
	End Rem
	Method GetJointTranslation:Float()
		Return bmx_b2prismaticjoint_getjointtranslation(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the current joint translation speed, usually in meters per second.
	end rem
	Method GetJointSpeed:Float()
		Return bmx_b2prismaticjoint_getjointspeed(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Is the joint limit enabled?
	end rem
	Method IsLimitEnabled:Int()
		Return bmx_b2prismaticjoint_islimitenabled(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Enable/disable the joint limit.
	end rem
	Method EnableLimit(flag:Int)
		bmx_b2prismaticjoint_enablelimit(b2ObjectPtr, flag)
	End Method
	
	Rem
	bbdoc: Get the lower joint limit, usually in meters.
	end rem
	Method GetLowerLimit:Float()
		Return bmx_b2prismaticjoint_getlowerlimit(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the upper joint limit, usually in meters.
	end rem
	Method GetUpperLimit:Float()
		Return bmx_b2prismaticjoint_getupperlimit(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Set the joint limits, usually in meters.
	end rem
	Method SetLimits(lowerLimit:Float, upperLimit:Float)
		bmx_b2prismaticjoint_setlimits(b2ObjectPtr, lowerLimit, upperLimit)
	End Method
	
	Rem
	bbdoc: Is the joint motor enabled?
	end rem
	Method IsMotorEnabled:Int()
		Return bmx_b2prismaticjoint_ismotorenabled(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Enable/disable the joint motor.
	end rem
	Method EnableMotor(flag:Int)
		bmx_b2prismaticjoint_enablemotor(b2ObjectPtr, flag)
	End Method
	
	Rem
	bbdoc: Set the motor speed, usually in meters per second.
	end rem
	Method SetMotorSpeed(speed:Float)
		bmx_b2prismaticjoint_setmotorspeed(b2ObjectPtr, speed)
	End Method
	
	Rem
	bbdoc: Get the motor speed, usually in meters per second.
	end rem
	Method GetMotorSpeed:Float()
		Return bmx_b2prismaticjoint_getmotorspeed(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Set the maximum motor force, usually in N.
	end rem
	Method SetMaxMotorForce(force:Float)
		bmx_b2prismaticjoint_setmaxmotorforce(b2ObjectPtr, force)
	End Method
	
	Rem
	bbdoc: Get the current motor force, usually in N.
	end rem
	Method GetMotorForce:Float()
		Return bmx_b2prismaticjoint_getmotorforce(b2ObjectPtr)
	End Method

End Type

Rem
bbdoc: The pulley joint is connected to two bodies and two fixed ground points. 
about: The pulley supports a ratio such that:
<pre>
		length1 + ratio * length2 <= constant
</pre>
Yes, the force transmitted is scaled by the ratio. The pulley also enforces a maximum length limit on both sides.
This is useful to prevent one side of the pulley hitting the top. 
End Rem
Type b2PulleyJoint Extends b2Joint
	
	Rem
	bbdoc: Get the anchor point on body1 in world coordinates. 
	End Rem
	Method GetAnchor1:b2Vec2()
		Return bmx_b2pulleyjoint_getanchor1(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the anchor point on body2 in world coordinates. 
	End Rem
	Method GetAnchor2:b2Vec2()
		Return bmx_b2pulleyjoint_getanchor2(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the reaction force on body2 at the joint anchor. 
	End Rem
	Method GetReactionForce:b2Vec2(inv_dt:Float)
		Return bmx_b2pulleyjoint_getreactionforce(b2ObjectPtr, inv_dt)
	End Method
	
	Rem
	bbdoc: Get the reaction torque on body2. 
	End Rem
	Method GetReactionTorque:Float(inv_dt:Float)
		Return bmx_b2pulleyjoint_getreactiontorque(b2ObjectPtr, inv_dt)
	End Method
	
	Rem
	bbdoc: Get the first ground anchor.
	End Rem
	Method GetGroundAnchor1:b2Vec2()
		Return bmx_b2pulleyjoint_getgroundanchor1(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the second ground anchor.
	end rem
	Method GetGroundAnchor2:b2Vec2()
		Return bmx_b2pulleyjoint_getgroundanchor2(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the current length of the segment attached to body1.
	end rem
	Method GetLength1:Float()
		Return bmx_b2pulleyjoint_getlength1(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the current length of the segment attached to body2.
	end rem
	Method GetLength2:Float()
		Return bmx_b2pulleyjoint_getlength2(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the pulley ratio.
	end rem
	Method GetRatio:Float()
		Return bmx_b2pulleyjoint_getratio(b2ObjectPtr)
	End Method

End Type

Rem
bbdoc: A mouse joint is used to make a point on a body track a specified world point. 
about: This a soft constraint with a maximum force. This allows the constraint to stretch and without applying huge forces. 
End Rem
Type b2MouseJoint Extends b2Joint

	Rem
	bbdoc: Get the anchor point on body1 in world coordinates. 
	End Rem
	Method GetAnchor1:b2Vec2()
		Return bmx_b2mousejoint_getanchor1(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the anchor point on body2 in world coordinates. 
	End Rem
	Method GetAnchor2:b2Vec2()
		Return bmx_b2mousejoint_getanchor2(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the reaction force on body2 at the joint anchor. 
	End Rem
	Method GetReactionForce:b2Vec2(inv_dt:Float)
		Return bmx_b2mousejoint_getreactionforce(b2ObjectPtr, inv_dt)
	End Method
	
	Rem
	bbdoc: Get the reaction torque on body2. 
	End Rem
	Method GetReactionTorque:Float(inv_dt:Float)
		Return bmx_b2mousejoint_getreactiontorque(b2ObjectPtr, inv_dt)
	End Method
	
	Rem
	bbdoc: Use this to update the target point.
	End Rem
	Method SetTarget(target:b2Vec2)
		bmx_b2mousejoint_settarget(b2ObjectPtr, target)
	End Method

	Rem
	bbdoc: Returns the target point.
	End Rem
	Method GetTarget:b2Vec2()
		Return bmx_b2mousejoint_gettarget(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Returns the local anchor.
	End Rem
	Method GetLocalAnchor:b2Vec2()
		Return bmx_b2mousejoint_getlocalanchor(b2ObjectPtr)
	End Method
	
End Type

Rem
bbdoc: A gear joint is used to connect two joints together.
about: Either joint can be a revolute or prismatic joint. You specify a gear ratio to bind the motions
together:
<pre>
	coordinate1 + ratio * coordinate2 = constant
</pre>
The ratio can be negative or positive. If one joint is a revolute joint and the other joint is a prismatic
joint, then the ratio will have units of length or units of 1/length.
<p>
Warning: The revolute and prismatic joints must be attached to fixed bodies (which must be body1 on those
joints).
</p>
End Rem
Type b2GearJoint Extends b2Joint

	Rem
	bbdoc: Get the anchor point on body1 in world coordinates.
	End Rem
	Method GetAnchor1:b2Vec2()
		Return bmx_b2gearjoint_getanchor1(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the anchor point on body2 in world coordinates. 
	End Rem
	Method GetAnchor2:b2Vec2()
		Return bmx_b2gearjoint_getanchor2(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the reaction force on body2 at the joint anchor. 
	End Rem
	Method GetReactionForce:b2Vec2(inv_dt:Float)
		Return bmx_b2gearjoint_getreactionforce(b2ObjectPtr, inv_dt)
	End Method
	
	Rem
	bbdoc: Get the reaction torque on body2.
	End Rem
	Method GetReactionTorque:Float(inv_dt:Float)
		Return bmx_b2gearjoint_getreactiontorque(b2ObjectPtr, inv_dt)
	End Method
	
	Rem
	bbdoc: Get the gear ratio.
	End Rem
	Method GetRatio:Float()
		Return bmx_b2gearjoint_getratio(b2ObjectPtr)
	End Method

End Type

Rem
bbdoc: A transform contains translation and rotation. 
about: It is used to represent the position and orientation of rigid frames.
End Rem
Struct b2XForm
	
	Field position:b2Vec2
	Field R:b2Mat22
	
	Rem
	bbdoc: 
	End Rem
	Method Create:b2XForm()
		Return Self
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method GetPosition:b2Vec2()
		Return position
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method SetPosition(pos:b2Vec2)
		position = pos
	End Method
	
	Rem
	bbdoc: 
	End Rem
	Method SetR(r:b2Mat22)
		Self.R = r
		'bmx_b2xform_setr(b2ObjectPtr, r.b2ObjectPtr)
	End Method
		
End Struct

Rem
bbdoc: A 2-by-2 matrix.
about: Stored in column-major order. 
End Rem
Struct b2Mat22

	Field col1:b2Vec2
	Field col2:b2Vec2
	
	Rem
	bbdoc: Constructs the matrix using scalars.
	End Rem
	Method Create:b2Mat22(a11:Float = 0, a12:Float = 0, a21:Float = 0, a22:Float = 0)
		col1.x = a11
		col1.y = a21
		
		col2.x = a12
		col2.y = a22
		Return Self
	End Method

	Rem
	bbdoc: Constructs the matrix using columns.
	End Rem
	Method CreateVec:b2Mat22(c1:b2Vec2, c2:b2Vec2)
		col1 = c1
		col2 = c2
		Return Self
	End Method

	Rem
	bbdoc: Constructs the matrix using an angle.
	about: This matrix becomes an orthonormal rotation matrix.
	End Rem
	Method CreateAngle:b2Mat22(angle:Float)
		bmx_b2mat22_createangle(Self, angle)
		Return Self
	End Method

	Rem
	bbdoc: Initialize this matrix using an angle.
	about: This matrix becomes an orthonormal rotation matrix.
	End Rem
	Method SetAngle(angle:Float)
		bmx_b2mat22_setangle(Self, angle)
	End Method
	
	Rem
	bbdoc: Returns the angle.
	End Rem
	Method GetAngle:Float()
		Return bmx_b2mat22_getangle(Self)
	End Method
	
	Rem
	bbdoc: Set this to the identity matrix.
	End Rem
	Method SetIdentity()
		col1.x = 1.0
		col2.x = 0.0
		col1.y = 0.0
		col2.y = 1.0
	End Method
	
	Rem
	bbdoc: Set this matrix to all zeros.
	End Rem
	Method SetZero()
		col1.x = 0.0
		col2.x = 0.0
		col1.y = 0.0
		col2.y = 0.0
	End Method
	
	Rem
	bbdoc: Computes the inverse of this matrix, such that inv(A) * A = identity.
	End Rem
	Method GetInverse:b2Mat22()
		Return bmx_b2mat22_getinverse(Self)
	End Method

End Struct

Rem
bbdoc: An oriented bounding box.
End Rem
Type b2OBB

	Field b2ObjectPtr:Byte Ptr
	
	Function _create:b2OBB(b2ObjectPtr:Byte Ptr)
		If b2ObjectPtr Then
			Local this:b2OBB = New b2OBB
			this.b2ObjectPtr = b2ObjectPtr
			Return this
		End If
	End Function

	Rem
	bbdoc: Returns the rotation matrix.
	End Rem
	Method GetRotationMatrix:b2Mat22()
		Return bmx_b2obb_getrotationmatrix(b2ObjectPtr)
	End Method

	Rem
	bbdoc: Returns the local centroid.
	End Rem
	Method GetCenter:b2Vec2()
		Return bmx_b2obb_getcenter(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Returns the half-widths.
	End Rem
	Method GetExtents:b2Vec2()
		Return bmx_b2obb_getextents(b2ObjectPtr)
	End Method

End Type

Rem
bbdoc: A line segment.
End Rem
Struct b2Segment

	Field p1:b2Vec2
	Field p2:b2Vec2

	Rem
	bbdoc: Creates a new b2Segment object.
	End Rem
	Method CreateXY:b2Segment(x1:Float, y1:Float, x2:Float, y2:Float)
		p1.x = x1
		p1.y = y1
		p2.x = x2
		p2.y = y2
		Return Self
	End Method
	
	Method Create:b2Segment()
		Return Self
	End Method

	Rem
	bbdoc: Creates a new b2Segment object.
	End Rem
	Method Create:b2Segment(p1:b2Vec2, p2:b2Vec2)
		Self.p1 = p1
		Self.p2 = p2
		Return Self
	End Method

	Rem
	bbdoc: Returns the start point of this segment.
	End Rem
	Method GetStartPoint:b2Vec2()
		Return p1
	End Method
	
	Rem
	bbdoc: Returns the end point of this segment.
	End Rem
	Method GetEndPoint:b2Vec2()
		Return p2
	End Method
	
	Rem
	bbdoc: Sets the start point of this segment.
	End Rem
	Method SetStartPoint(point:b2Vec2)
		p1 = point
	End Method
	
	Rem
	bbdoc: Sets the end point of this segment.
	End Rem
	Method SetEndPoint(point:b2Vec2)
		p2 = point
	End Method
	
End Struct

Rem
bbdoc: A controller edge is used to connect bodies and controllers together in a bipartite graph.
End Rem
Type b2ControllerEdge

	Field b2ObjectPtr:Byte Ptr

	Function _create:b2ControllerEdge(b2ObjectPtr:Byte Ptr)
		If b2ObjectPtr Then
			Local this:b2ControllerEdge = New b2ControllerEdge
			this.b2ObjectPtr = b2ObjectPtr
			Return this
		End If
	End Function
	
	Rem
	bbdoc: Provides quick access to other end of this edge.
	End Rem
	Method GetController:b2Controller()
		Return b2Controller._create(bmx_b2controlleredge_getcontroller(b2ObjectPtr))
	End Method
	
	Rem
	bbdoc: Returns the body.
	End Rem
	Method GetBody:b2Body()
		Return b2Body._create(bmx_b2controlleredge_getbody(b2ObjectPtr))
	End Method
	
	Rem
	bbdoc: Returns the previous controller edge in the controllers's joint list.
	End Rem
	Method GetPrevBody:b2ControllerEdge()
		Return b2ControllerEdge._create(bmx_b2controlleredge_getprevbody(b2ObjectPtr))
	End Method
	
	Rem
	bbdoc: Returns the next controller edge in the controllers's joint list.
	End Rem
	Method GetNexBody:b2ControllerEdge()
		Return b2ControllerEdge._create(bmx_b2controlleredge_getnextbody(b2ObjectPtr))
	End Method
	
	Rem
	bbdoc: Returns the previous controller edge in the body's joint list.
	End Rem
	Method GetPrevController:b2ControllerEdge()
		Return b2ControllerEdge._create(bmx_b2controlleredge_getprevcontroller(b2ObjectPtr))
	End Method
	
	Rem
	bbdoc: Returns the next controller edge in the body's joint list.
	End Rem
	Method GetNextController:b2ControllerEdge()
		Return b2ControllerEdge._create(bmx_b2controlleredge_getnextcontroller(b2ObjectPtr))
	End Method
	
End Type

Type b2ControllerDef

	Field b2ObjectPtr:Byte Ptr

	Field userData:Object
	
	Field _type:Int

End Type

Rem
bbdoc: Used to build buoyancy controllers
End Rem
Type b2BuoyancyControllerDef Extends b2ControllerDef

	Method New()
		b2ObjectPtr = bmx_b2buoyancycontrollerdef_create()
		_type = e_buoyancyController
	End Method
	
	Rem
	bbdoc: Returns the outer surface normal.
	End Rem
	Method GetNormal:b2Vec2()
		Return bmx_b2buoyancycontrollerdef_getnormal(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the outer surface normal.
	End Rem
	Method SetNormal(normal:b2Vec2)
		bmx_b2buoyancycontrollerdef_setnormal(b2ObjectPtr, normal)
	End Method
	
	Rem
	bbdoc: Returns the height of the fluid surface along the normal.
	End Rem
	Method GetOffset:Float()
		Return bmx_b2buoyancycontrollerdef_getoffset(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the height of the fluid surface along the normal.
	End Rem
	Method SetOffset(offset:Float)
		bmx_b2buoyancycontrollerdef_setoffset(b2ObjectPtr, offset)
	End Method
	
	Rem
	bbdoc: Returns the fluid density.
	End Rem
	Method GetDensity:Float()
		Return bmx_b2buoyancycontrollerdef_getdensity(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the fluid density.
	End Rem
	Method SetDensity(density:Float)
		bmx_b2buoyancycontrollerdef_setdensity(b2ObjectPtr, density)
	End Method
	
	Rem
	bbdoc: Returns the fluid velocity, for drag calculations.
	End Rem
	Method GetVelocity:b2Vec2()
		Return bmx_b2buoyancycontrollerdef_getvelocity(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the fluid velocity, for drag calculations.
	End Rem
	Method SetVelocity(velocity:b2Vec2)
		bmx_b2buoyancycontrollerdef_setvelocity(b2ObjectPtr, velocity)
	End Method
	
	Rem
	bbdoc: Returns the linear drag co-efficient.
	End Rem
	Method GetLinearDrag:Float()
		Return bmx_b2buoyancycontrollerdef_getlineardrag(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the linear drag co-efficient.
	End Rem
	Method SetLinearDrag(drag:Float)
		bmx_b2buoyancycontrollerdef_setlineardrag(b2ObjectPtr, drag)
	End Method
	
	Rem
	bbdoc: Returns the angular drag co-efficient.
	End Rem
	Method GetAngularDrag:Float()
		Return bmx_b2buoyancycontrollerdef_getangulardrag(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the angular drag co-efficient.
	End Rem
	Method SetAngularDrag(drag:Float)
		bmx_b2buoyancycontrollerdef_setangulardrag(b2ObjectPtr, drag)
	End Method
	
	Rem
	bbdoc: Returns False if bodies are assumed to be uniformly dense, otherwise use the shapes densities.
	End Rem
	Method UsesDensity:Int()
		Return bmx_b2buoyancycontrollerdef_usesdensity(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Set to False, if bodies are assumed to be uniformly dense, otherwise use the shapes densities.
	End Rem
	Method SetUsesDensity(value:Int)
		bmx_b2buoyancycontrollerdef_setusesdensity(b2ObjectPtr, value)
	End Method
	
	Rem
	bbdoc: Returns True, if gravity is taken from the world instead of the gravity parameter.
	End Rem
	Method UsesWorldGravity:Int()
		Return bmx_b2buoyancycontrollerdef_usesworldgravity(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Set to True, if gravity is to be taken from the world instead of the gravity parameter.
	End Rem
	Method SetUsesWorldGravity(value:Int)
		bmx_b2buoyancycontrollerdef_setusesworldgravity(b2ObjectPtr, value)
	End Method
	
	Rem
	bbdoc: Returns the gravity vector, if the world's gravity is not used.
	End Rem
	Method GetGravity:b2Vec2()
		Return bmx_b2buoyancycontrollerdef_getgravity(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Returns the gravity vector, if the world's gravity is not used.
	End Rem
	Method SetGravity(gravity:b2Vec2)
		bmx_b2buoyancycontrollerdef_setgravity(b2ObjectPtr, gravity)
	End Method

	Method Delete()
		If b2ObjectPtr Then
			bmx_b2buoyancycontrollerdef_delete(b2ObjectPtr)
			b2ObjectPtr = Null
		End If
	End Method

End Type

Rem
bbdoc: Used to build tensor damping controllers.
End Rem
Type b2TensorDampingControllerDef Extends b2ControllerDef

	Method New()
		b2ObjectPtr = bmx_b2tensordampingcontrollerdef_create()
		_type = e_tensorDampingController
	End Method
	
	Rem
	bbdoc: Returns the tensor to use in damping model.
	End Rem
	Method GetTensor:b2Mat22()
		Return bmx_b2tensordampingcontrollerdef_gettensor(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the tensor to use in damping model.
	about: Some examples (matrixes in format (row1; row2) )
	<table>
	<th><td>Matrix</td><td>Description</td></th>
	<tr><td>(-a 0;0 -a)</td><td>Standard isotropic damping with strength a</td></tr>
	<tr><td>(0 a;-a 0)</td><td>Electron in fixed field - a force at right angles to velocity with proportional magnitude</td></tr>
	<tr><td>(-a 0;0 -b)</td><td>Differing x and y damping. Useful e.g. for top-down wheels.</td></tr>
	</table>
	<p>
	By the way, tensor in this case just means matrix, don't let the terminology get you down.
	</p>
	End Rem
	Method SetTensor(tensor:b2Mat22)
		bmx_b2tensordampingcontrollerdef_settensor(b2ObjectPtr, tensor)
	End Method
	
	Rem
	bbdoc: Returns the maximum amount of damping.
	End Rem
	Method GetMaxTimestep:Float()
		Return bmx_b2tensordampingcontrollerdef_getmaxtimestep(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Set this to a positive number to clamp the maximum amount of damping done.
	End Rem
	Method SetMaxTimestep(timestep:Float)
		bmx_b2tensordampingcontrollerdef_setmaxtimestep(b2ObjectPtr, timestep)
	End Method
	
	Rem
	bbdoc: Sets damping independently along the x and y axes.
	End Rem
	Method SetAxisAligned(xDamping:Float, yDamping:Float)
		bmx_b2tensordampingcontrollerdef_setaxisaligned(b2ObjectPtr, xDamping, yDamping)
	End Method

	Method Delete()
		If b2ObjectPtr Then
			bmx_b2tensordampingcontrollerdef_delete(b2ObjectPtr)
			b2ObjectPtr = Null
		End If
	End Method

End Type

Rem
bbdoc: Used to build gravity controllers.
End Rem
Type b2GravityControllerDef Extends b2ControllerDef

	Method New()
		b2ObjectPtr = bmx_b2gravitycontrollerdef_create()
		_type = e_gravityController
	End Method
	
	Rem
	bbdoc: Returns the strength of the gravitiation force.
	End Rem
	Method GetForce:Float()
		Return bmx_b2gravitycontrollerdef_getforce(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the strength of the gravitiation force.
	End Rem
	Method SetForce(force:Float)
		bmx_b2gravitycontrollerdef_setforce(b2ObjectPtr, force)
	End Method
	
	Rem
	bbdoc: Returns whether gravity is proportional to r^-2 (True), otherwise r^-1 (False).
	End Rem
	Method IsInvSqr:Int()
		Return bmx_b2gravitycontrollerdef_isinvsqr(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets whether gravity is proportional to r^-2 (True), otherwise r^-1 (False).
	End Rem
	Method SetIsInvSqr(value:Int)
		bmx_b2gravitycontrollerdef_setisinvsqr(b2ObjectPtr, value)
	End Method

	Method Delete()
		If b2ObjectPtr Then
			bmx_b2gravitycontrollerdef_delete(b2ObjectPtr)
			b2ObjectPtr = Null
		End If
	End Method

End Type

Rem
bbdoc: Used to build constant force controllers.
End Rem
Type b2ConstantForceControllerDef Extends b2ControllerDef

	Method New()
		b2ObjectPtr = bmx_b2constantforcecontrollerdef_create()
		_type = e_constantForceController
	End Method

	Rem
	bbdoc: Returns the force to apply.
	End Rem
	Method GetForce:b2Vec2()
		Return bmx_b2constantforcecontrollerdef_getforce(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the force to apply.
	End Rem
	Method SetForce(force:b2Vec2)
		bmx_b2constantforcecontrollerdef_setforce(b2ObjectPtr, force)
	End Method

	Method Delete()
		If b2ObjectPtr Then
			bmx_b2constantforcecontrollerdef_delete(b2ObjectPtr)
			b2ObjectPtr = Null
		End If
	End Method

End Type

Rem
bbdoc: Used to build constant acceleration controllers.
End Rem
Type b2ConstantAccelControllerDef Extends b2ControllerDef

	Method New()
		b2ObjectPtr = bmx_b2constantaccelcontrollerdef_create()
		_type = e_constantAccelController
	End Method
	
	Rem
	bbdoc: Returns the force to apply.
	End Rem
	Method GetForce:b2Vec2()
		Return bmx_b2constantaccelcontrollerdef_getforce(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the force to apply.
	End Rem
	Method SetForce(force:b2Vec2)
		bmx_b2constantaccelcontrollerdef_setforce(b2ObjectPtr, force)
	End Method

	Method Delete()
		If b2ObjectPtr Then
			bmx_b2constantaccelcontrollerdef_delete(b2ObjectPtr)
			b2ObjectPtr = Null
		End If
	End Method

End Type

Rem
bbdoc: Base type for controllers.
about: Controllers are a convience for encapsulating common per-step functionality.
End Rem
Type b2Controller
	
	Field b2ObjectPtr:Byte Ptr
	
	Field userData:Object

	Function _create:b2Controller(b2ObjectPtr:Byte Ptr)
		If b2ObjectPtr Then
			Local controller:b2Controller = b2Controller(bmx_b2controller_getmaxcontroller(b2ObjectPtr))
			If Not controller Then
				controller = New b2Controller
				controller.b2ObjectPtr = b2ObjectPtr
			Else
				If Not controller.b2ObjectPtr Then
					controller.b2ObjectPtr = b2ObjectPtr
				EndIf
			End If
			Return controller
		End If
	End Function

	Rem
	bbdoc: Adds a body to the controller list.
	End Rem
	Method AddBody(body:b2Body)
		bmx_b2controller_addbody(b2ObjectPtr, body.b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Removes a body from the controller list.
	End Rem
	Method RemoveBody(body:b2Body)
		bmx_b2controller_removebody(b2ObjectPtr, body.b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Removes all bodies from the controller list.
	End Rem
	Method Clear()
		bmx_b2controller_clear(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Get the next controller in the world's body list.
	End Rem
	Method GetNext:b2Controller()
		Return b2Controller._create(bmx_b2controller_getnext(b2ObjectPtr))
	End Method
	
	Rem
	bbdoc: Get the parent world of this body.
	End Rem
	Method GetWorld:b2World()
		Return b2World._create(bmx_b2controller_getworld(b2ObjectPtr))
	End Method
	
	Rem
	bbdoc: Get the attached body list.
	End Rem
	Method GetBodyList:b2ControllerEdge()
		Return b2ControllerEdge._create(bmx_b2controller_getbodylist(b2ObjectPtr))
	End Method
	
	Rem
	bbdoc: Get the user data that was provided in the controller definition.
	End Rem
	Method GetUserData:Object()
		Return userData
	End Method

End Type

Rem
bbdoc: Applies a force every frame
End Rem
Type b2ConstantAccelController Extends b2Controller

	Rem
	bbdoc: Returns the force to apply.
	End Rem
	Method GetForce:b2Vec2()
		Return bmx_b2constantaccelcontroller_getforce(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the force to apply.
	End Rem
	Method SetForce(force:b2Vec2)
		bmx_b2constantaccelcontroller_setforce(b2ObjectPtr, force)
	End Method
	
End Type

Rem
bbdoc: Calculates buoyancy forces for fluids in the form of a half plane.
End Rem
Type b2BuoyancyController Extends b2Controller

	Rem
	bbdoc: Returns the outer surface normal.
	End Rem
	Method GetNormal:b2Vec2()
		Return bmx_b2buoyancycontroller_getnormal(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the outer surface normal.
	End Rem
	Method SetNormal(normal:b2Vec2)
		bmx_b2buoyancycontroller_setnormal(b2ObjectPtr, normal)
	End Method
	
	Rem
	bbdoc: Returns the height of the fluid surface along the normal.
	End Rem
	Method GetOffset:Float()
		Return bmx_b2buoyancycontroller_getoffset(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the height of the fluid surface along the normal.
	End Rem
	Method SetOffset(offset:Float)
		bmx_b2buoyancycontroller_setoffset(b2ObjectPtr, offset)
	End Method
	
	Rem
	bbdoc: Returns the fluid density.
	End Rem
	Method GetDensity:Float()
		Return bmx_b2buoyancycontroller_getdensity(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the fluid density.
	End Rem
	Method SetDensity(density:Float)
		bmx_b2buoyancycontroller_setdensity(b2ObjectPtr, density)
	End Method
	
	Rem
	bbdoc: Returns the fluid velocity, for drag calculations.
	End Rem
	Method GetVelocity:b2Vec2()
		Return bmx_b2buoyancycontroller_getvelocity(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the fluid velocity, for drag calculations.
	End Rem
	Method SetVelocity(velocity:b2Vec2)
		bmx_b2buoyancycontroller_setvelocity(b2ObjectPtr, velocity)
	End Method
	
	Rem
	bbdoc: Returns the linear drag co-efficient.
	End Rem
	Method GetLinearDrag:Float()
		Return bmx_b2buoyancycontroller_getlineardrag(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the linear drag co-efficient.
	End Rem
	Method SetLinearDrag(drag:Float)
		bmx_b2buoyancycontroller_setlineardrag(b2ObjectPtr, drag)
	End Method
	
	Rem
	bbdoc: Returns the angular drag co-efficient.
	End Rem
	Method GetAngularDrag:Float()
		Return bmx_b2buoyancycontroller_getangulardrag(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the angular drag co-efficient.
	End Rem
	Method SetAngularDrag(drag:Float)
		bmx_b2buoyancycontroller_setangulardrag(b2ObjectPtr, drag)
	End Method
	
	Rem
	bbdoc: Returns False if bodies are assumed to be uniformly dense, otherwise use the shapes densities.
	End Rem
	Method UsesDensity:Int()
		Return bmx_b2buoyancycontroller_usesdensity(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Set to False, if bodies are assumed to be uniformly dense, otherwise use the shapes densities.
	End Rem
	Method SetUsesDensity(value:Int)
		bmx_b2buoyancycontroller_setusesdensity(b2ObjectPtr, value)
	End Method
	
	Rem
	bbdoc: Returns True, if gravity is taken from the world instead of the gravity parameter.
	End Rem
	Method UsesWorldGravity:Int()
		Return bmx_b2buoyancycontroller_usesworldgravity(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Set to True, if gravity is to be taken from the world instead of the gravity parameter.
	End Rem
	Method SetUsesWorldGravity(value:Int)
		bmx_b2buoyancycontroller_setusesworldgravity(b2ObjectPtr, value)
	End Method
	
	Rem
	bbdoc: Returns the gravity vector, if the world's gravity is not used.
	End Rem
	Method GetGravity:b2Vec2()
		Return bmx_b2buoyancycontroller_getgravity(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Returns the gravity vector, if the world's gravity is not used.
	End Rem
	Method SetGravity(gravity:b2Vec2)
		bmx_b2buoyancycontroller_setgravity(b2ObjectPtr, gravity)
	End Method

End Type

Rem
bbdoc: Applies a force every frame.
End Rem
Type b2ConstantForceController Extends b2Controller

	Rem
	bbdoc: Returns the force to apply.
	End Rem
	Method GetForce:b2Vec2()
		Return bmx_b2constantaccelcontroller_getforce(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the force to apply.
	End Rem
	Method SetForce(force:b2Vec2)
		bmx_b2constantaccelcontroller_setforce(b2ObjectPtr, force)
	End Method

End Type

Rem
bbdoc: Applies simplified gravity between every pair of bodies.
End Rem
Type b2GravityController Extends b2Controller

	Rem
	bbdoc: Returns the strength of the gravitiation force.
	End Rem
	Method GetForce:Float()
		Return bmx_b2gravitycontroller_getforce(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the strength of the gravitiation force.
	End Rem
	Method SetForce(force:Float)
		bmx_b2gravitycontroller_setforce(b2ObjectPtr, force)
	End Method
	
	Rem
	bbdoc: Returns whether gravity is proportional to r^-2 (True), otherwise r^-1 (False).
	End Rem
	Method IsInvSqr:Int()
		Return bmx_b2gravitycontroller_isinvsqr(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets whether gravity is proportional to r^-2 (True), otherwise r^-1 (False).
	End Rem
	Method SetIsInvSqr(value:Int)
		bmx_b2gravitycontroller_setisinvsqr(b2ObjectPtr, value)
	End Method

End Type

Rem
bbdoc: Applies top down linear damping to the controlled bodies
about: The damping is calculated by multiplying velocity by a matrix in local co-ordinates.
End Rem
Type b2TensorDampingController Extends b2Controller

	Rem
	bbdoc: Returns the tensor to use in damping model.
	End Rem
	Method GetTensor:b2Mat22()
		Return bmx_b2tensordampingcontroller_gettensor(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Sets the tensor to use in damping model.
	about: Some examples (matrixes in format (row1; row2) )
	<table>
	<th><td>Matrix</td><td>Description</td></th>
	<tr><td>(-a 0;0 -a)</td><td>Standard isotropic damping with strength a</td></tr>
	<tr><td>(0 a;-a 0)</td><td>Electron in fixed field - a force at right angles to velocity with proportional magnitude</td></tr>
	<tr><td>(-a 0;0 -b)</td><td>Differing x and y damping. Useful e.g. for top-down wheels.</td></tr>
	</table>
	<p>
	By the way, tensor in this case just means matrix, don't let the terminology get you down.
	</p>
	End Rem
	Method SetTensor(tensor:b2Mat22)
		bmx_b2tensordampingcontroller_settensor(b2ObjectPtr, tensor)
	End Method
	
	Rem
	bbdoc: Returns the maximum amount of damping.
	End Rem
	Method GetMaxTimestep:Float()
		Return bmx_b2tensordampingcontroller_getmaxtimestep(b2ObjectPtr)
	End Method
	
	Rem
	bbdoc: Set this to a positive number to clamp the maximum amount of damping done.
	End Rem
	Method SetMaxTimestep(timestep:Float)
		bmx_b2tensordampingcontroller_setmaxtimestep(b2ObjectPtr, timestep)
	End Method

End Type

Rem
bbdoc: Perform the cross product on a vector and a scalar.
about: In 2D this produces a vector.
End Rem
Function b2Cross:b2Vec2(a:b2Vec2, s:Float)
	Return bmx_b2cross(a, s)
End Function

Rem
bbdoc: Perform the cross product on a scalar and a vector.
about: In 2D this produces a vector.
End Rem
Function b2CrossF:b2Vec2(s:Float, a:b2Vec2)
	Return bmx_b2crossf(s, a)
End Function

Rem
bbdoc: Peform the dot product on two vectors.
End Rem
Function b2Dot:Float(a:b2Vec2, b:b2Vec2)
	Return bmx_b2dot(a, b)
End Function

Rem
bbdoc: Multiply a matrix times a vector.
about: If a rotation matrix is provided, then this transforms the vector from one frame to another.
End Rem
Function b2Mul:b2Vec2(A:b2Mat22, v:b2Vec2)
	Return bmx_b2mul(A, v)
End Function

Rem
bbdoc: Multiply a matrix transpose times a vector.
about: If a rotation matrix is provided, then this transforms the vector from one frame to another
(inverse transform).
End Rem
Function b2MulT:b2Vec2(A:b2Mat22, v:b2Vec2)
	Return bmx_b2mult(A, v)
End Function

Rem
bbdoc: 
end rem
Function b2MulF:b2Vec2(T:b2XForm, v:b2Vec2)
	Return bmx_b2mulf(T, v)
End Function

Rem
bbdoc: 
end rem
Function b2MulTF:b2Vec2(T:b2XForm, v:b2Vec2)
	Return bmx_b2multf(T, v)
End Function

Extern
	Function bmx_b2world_create:Byte Ptr(worldAABB:b2AABB Var, gravity:b2Vec2 Var, doSleep:Int)
	Function bmx_b2world_setgravity(handle:Byte Ptr, gravity:b2Vec2 Var)
	Function bmx_b2world_raycastone:Byte Ptr(handle:Byte Ptr, segment:b2Segment Var, lambda:Float Ptr, normal:b2Vec2 Var, solidShapes:Int)
	Function bmx_b2world_inrange:Int(handle:Byte Ptr, aabb:b2AABB Var)

	Function bmx_b2abb_isvalid:Int(handle:b2AABB Var)

	Function bmx_b2vec2_add(v:b2Vec2 Var, vec:b2Vec2 Var)
	Function bmx_b2vec2_copy(v:b2Vec2 Var, vec:b2Vec2 Var)
	Function bmx_b2vec2_set(v:b2Vec2 Var, x:Float, y:Float)
	Function bmx_b2vec2_subtract:b2Vec2(v:b2Vec2 Var, vec:b2Vec2 Var)
	Function bmx_b2vec2_length:Float(v:b2Vec2 Var)
	Function bmx_b2vec2_multiply(v:b2Vec2 Var, value:Float)
	Function bmx_b2vec2_plus:b2Vec2(v:b2Vec2 Var, vec:b2Vec2 Var)
	Function bmx_b2vec2_normalize:Float(v:b2Vec2 Var)
	Function bmx_b2vec2_lengthsquared:Float(v:b2Vec2 Var)
	
	Function bmx_b2mat22_createangle(handle:b2Mat22 Var, angle:Float)
	Function bmx_b2mat22_setangle(handle:b2Mat22 Var, angle:Float)
	Function bmx_b2mat22_getangle:Float(handle:b2Mat22 Var)
	Function bmx_b2mat22_getinverse:b2Mat22(handle:b2Mat22 Var)

	Function bmx_b2obb_getrotationmatrix:b2Mat22(handle:Byte Ptr)
	Function bmx_b2obb_getcenter:b2Vec2(handle:Byte Ptr)
	Function bmx_b2obb_getextents:b2Vec2(handle:Byte Ptr)

	Function bmx_b2revolutejointdef_initialize(handle:Byte Ptr, body1:Byte Ptr, body2:Byte Ptr, anchor:b2Vec2 Var)
	Function bmx_b2revolutejointdef_setlocalanchor1(handle:Byte Ptr, anchor:b2Vec2 Var)
	Function bmx_b2revolutejointdef_setlocalanchor2(handle:Byte Ptr, anchor:b2Vec2 Var)
	Function bmx_b2revolutejointdef_getlocalanchor1:b2Vec2(handle:Byte Ptr)
	Function bmx_b2revolutejointdef_getlocalanchor2:b2Vec2(handle:Byte Ptr)

	Function bmx_b2cross:b2Vec2(a:b2Vec2 Var, s:Float)
	Function bmx_b2crossf:b2Vec2(s:Float, a:b2Vec2 Var)
	Function bmx_b2mul:b2Vec2(A:b2Mat22 Var, v:b2Vec2 Var)
	Function bmx_b2mult:b2Vec2(A:b2Mat22 Var, v:b2Vec2 Var)
	Function bmx_b2mulf:b2Vec2(T:b2XForm Var, v:b2Vec2 Var)
	Function bmx_b2multf:b2Vec2(T:b2XForm Var, v:b2Vec2 Var)
	Function bmx_b2dot:Float(a:b2Vec2 Var, b:b2Vec2 Var)

	Function bmx_b2body_setlinearvelocity(handle:Byte Ptr, v:b2Vec2 Var)
	Function bmx_b2body_getlinearvelocity:b2Vec2(handle:Byte Ptr)
	Function bmx_b2body_applyforce(handle:Byte Ptr, force:b2Vec2 Var, point:b2Vec2 Var)
	Function bmx_b2body_applyimpulse(handle:Byte Ptr, impulse:b2Vec2 Var, point:b2Vec2 Var)
	Function bmx_b2body_getworldpoint:b2Vec2(handle:Byte Ptr, localPoint:b2Vec2 Var)
	Function bmx_b2body_getworldvector:b2Vec2(handle:Byte Ptr, localVector:b2Vec2 Var)
	Function bmx_b2body_getlocalpoint:b2Vec2(handle:Byte Ptr, worldPoint:b2Vec2 Var)
	Function bmx_b2body_getlocalvector:b2Vec2(handle:Byte Ptr, worldVector:b2Vec2 Var)
	Function bmx_b2body_setxform:Int(handle:Byte Ptr, position:b2Vec2 Var, angle:Float)
	Function bmx_b2body_getxform:b2XForm(handle:Byte Ptr)
	Function bmx_b2body_getposition:b2Vec2(handle:Byte Ptr)
	Function bmx_b2body_getworldcenter:b2Vec2(handle:Byte Ptr)
	Function bmx_b2body_getlocalcenter:b2Vec2(handle:Byte Ptr)

	Function bmx_b2shape_testpoint:Int(handle:Byte Ptr, xf:b2XForm Var, p:b2Vec2 Var)
	Function bmx_b2shape_computeaabb(handle:Byte Ptr, aabb:b2AABB Var, xf:b2XForm Var)
	Function bmx_b2shape_computesweptaabb(handle:Byte Ptr, aabb:b2AABB Var, xf1:b2XForm Var, xf2:b2XForm Var)
	
	Function bmx_b2bodydef_setposition(handle:Byte Ptr, position:b2Vec2 Var)
	Function bmx_b2bodydef_getposition:b2Vec2(handle:Byte Ptr)

	Function bmx_b2massdata_setcenter(handle:Byte Ptr, center:b2Vec2 Var)
	
	Function bmx_b2polygondef_setasorientedbox(handle:Byte Ptr, hx:Float, hy:Float, center:b2Vec2 Var, angle:Float)
	
	Function bmx_b2polygonshape_getcentroid:b2Vec2(handle:Byte Ptr)
	Function bmx_b2polygonshape_getfirstvertex:b2Vec2(handle:Byte Ptr, xf:b2XForm Var)
	Function bmx_b2polygonshape_centroid:b2Vec2(handle:Byte Ptr, xf:b2XForm Var)
	Function bmx_b2polygonshape_support:b2Vec2(handle:Byte Ptr, xf:b2XForm Var, d:b2Vec2 Var)

	Function bmx_b2circledef_setlocalposition(handle:Byte Ptr, pos:b2Vec2 Var)
	Function bmx_b2circledef_getlocalposition:b2Vec2(handle:Byte Ptr)

	Function bmx_b2circleshape_getlocalposition:b2Vec2(handle:Byte Ptr)

	Function bmx_b2distancejointdef_initialize(handle:Byte Ptr, body1:Byte Ptr, body2:Byte Ptr, anchor1:b2Vec2 Var, anchor2:b2Vec2 Var)
	Function bmx_b2distancejointdef_setlocalanchor1(handle:Byte Ptr, anchor:b2Vec2 Var)
	Function bmx_b2distancejointdef_getlocalanchor1:b2Vec2(handle:Byte Ptr)
	Function bmx_b2distancejointdef_setlocalanchor2(handle:Byte Ptr, anchor:b2Vec2 Var)
	Function bmx_b2distancejointdef_getlocalanchor2:b2Vec2(handle:Byte Ptr)

	Function bmx_b2edgeshape_getvertex1:b2Vec2(handle:Byte Ptr)
	Function bmx_b2edgeshape_getvertex2:b2Vec2(handle:Byte Ptr)
	Function bmx_b2edgeshape_getcorevertex1:b2Vec2(handle:Byte Ptr)
	Function bmx_b2edgeshape_getcorevertex2:b2Vec2(handle:Byte Ptr)
	Function bmx_b2edgeshape_getnormalvector:b2Vec2(handle:Byte Ptr)
	Function bmx_b2edgeshape_getdirectionvector:b2Vec2(handle:Byte Ptr)
	Function bmx_b2edgeshape_getcorner1vector:b2Vec2(handle:Byte Ptr)
	Function bmx_b2edgeshape_getcorner2vector:b2Vec2(handle:Byte Ptr)
	Function bmx_b2edgeshape_getfirstvertex:b2Vec2(handle:Byte Ptr, xf:b2XForm Var)
	Function bmx_b2edgeshape_support:b2Vec2(handle:Byte Ptr, xf:b2XForm Var, d:b2Vec2 Var)

	Function bmx_b2pulleyjointdef_initialize(handle:Byte Ptr, body1:Byte Ptr, body2:Byte Ptr, groundAnchor1:b2Vec2 Var, ..
		groundAnchor2:b2Vec2 Var, anchor1:b2Vec2 Var, anchor2:b2Vec2 Var, ratio:Float)
	Function bmx_b2pulleyjointdef_setgroundanchor1(handle:Byte Ptr, anchor:b2Vec2 Var)
	Function bmx_b2pulleyjointdef_getgroundanchor1:b2Vec2(handle:Byte Ptr)
	Function bmx_b2pulleyjointdef_setgroundanchor2(handle:Byte Ptr, anchor:b2Vec2 Var)
	Function bmx_b2pulleyjointdef_getgroundanchor2:b2Vec2(handle:Byte Ptr)
	Function bmx_b2pulleyjointdef_setlocalanchor1(handle:Byte Ptr, anchor:b2Vec2 Var)
	Function bmx_b2pulleyjointdef_getlocalanchor1:b2Vec2(handle:Byte Ptr)
	Function bmx_b2pulleyjointdef_setlocalanchor2(handle:Byte Ptr, anchor:b2Vec2 Var)
	Function bmx_b2pulleyjointdef_getlocalanchor2:b2Vec2(handle:Byte Ptr)

	Function bmx_b2prismaticjointdef_initialize(handle:Byte Ptr, body1:Byte Ptr, body2:Byte Ptr, ..
			anchor:b2Vec2 Var, axis:b2Vec2 Var)
	Function bmx_b2prismaticjointdef_setlocalanchor1(handle:Byte Ptr, anchor:b2Vec2 Var)
	Function bmx_b2prismaticjointdef_getlocalanchor1:b2Vec2(handle:Byte Ptr)
	Function bmx_b2prismaticjointdef_setlocalanchor2(handle:Byte Ptr, anchor:b2Vec2 Var)
	Function bmx_b2prismaticjointdef_getlocalanchor2:b2Vec2(handle:Byte Ptr)
	Function bmx_b2prismaticjointdef_setlocalaxis1(handle:Byte Ptr, axis:b2Vec2 Var)
	Function bmx_b2prismaticjointdef_getlocalaxis1:b2Vec2(handle:Byte Ptr)

	Function bmx_b2mousejointdef_settarget(handle:Byte Ptr, target:b2Vec2 Var)
	Function bmx_b2mousejointdef_gettarget:b2Vec2(handle:Byte Ptr)

	Function bmx_b2linejointdef_initialize(handle:Byte Ptr, body1:Byte Ptr, body2:Byte Ptr, anchor:b2Vec2 Var, axis:b2Vec2 Var)
	Function bmx_b2linejointdef_setlocalanchor1(handle:Byte Ptr, anchor:b2Vec2 Var)
	Function bmx_b2linejointdef_getlocalanchor1:b2Vec2(handle:Byte Ptr)
	Function bmx_b2linejointdef_setlocalanchor2(handle:Byte Ptr, anchor:b2Vec2 Var)
	Function bmx_b2linejointdef_getlocalanchor2:b2Vec2(handle:Byte Ptr)
	Function bmx_b2linejointdef_setlocalaxis1(handle:Byte Ptr, axis:b2Vec2 Var)
	Function bmx_b2linejointdef_getlocalaxis1:b2Vec2(handle:Byte Ptr)

	Function bmx_b2linejoint_getanchor1:b2Vec2(handle:Byte Ptr)
	Function bmx_b2linejoint_getanchor2:b2Vec2(handle:Byte Ptr)
	Function bmx_b2linejoint_getreactionforce:b2Vec2(handle:Byte Ptr, inv_dt:Float)

	Function bmx_b2distancejoint_getanchor1:b2Vec2(handle:Byte Ptr)
	Function bmx_b2distancejoint_getanchor2:b2Vec2(handle:Byte Ptr)
	Function bmx_b2distancejoint_getreactionforce:b2Vec2(handle:Byte Ptr, inv_dt:Float)

	Function bmx_b2revolutejoint_getanchor1:b2Vec2(handle:Byte Ptr)
	Function bmx_b2revolutejoint_getanchor2:b2Vec2(handle:Byte Ptr)
	Function bmx_b2revolutejoint_getreactionforce:b2Vec2(handle:Byte Ptr, inv_dt:Float)

	Function bmx_b2prismaticjoint_getanchor1:b2Vec2(handle:Byte Ptr)
	Function bmx_b2prismaticjoint_getanchor2:b2Vec2(handle:Byte Ptr)
	Function bmx_b2prismaticjoint_getreactionforce:b2Vec2(handle:Byte Ptr, inv_dt:Float)

	Function bmx_b2gearjoint_getanchor1:b2Vec2(handle:Byte Ptr)
	Function bmx_b2gearjoint_getanchor2:b2Vec2(handle:Byte Ptr)
	Function bmx_b2gearjoint_getreactionforce:b2Vec2(handle:Byte Ptr, inv_dt:Float)

	Function bmx_b2mousejoint_getanchor1:b2Vec2(handle:Byte Ptr)
	Function bmx_b2mousejoint_getanchor2:b2Vec2(handle:Byte Ptr)
	Function bmx_b2mousejoint_getreactionforce:b2Vec2(handle:Byte Ptr, inv_dt:Float)
	Function bmx_b2mousejoint_getlocalanchor:b2Vec2(handle:Byte Ptr)
	Function bmx_b2mousejoint_settarget(handle:Byte Ptr, target:b2Vec2 Var)
	Function bmx_b2mousejoint_gettarget:b2Vec2(handle:Byte Ptr)

	Function bmx_b2pulleyjoint_getanchor1:b2Vec2(handle:Byte Ptr)
	Function bmx_b2pulleyjoint_getanchor2:b2Vec2(handle:Byte Ptr)
	Function bmx_b2pulleyjoint_getreactionforce:b2Vec2(handle:Byte Ptr, inv_dt:Float)
	Function bmx_b2pulleyjoint_getgroundanchor1:b2Vec2(handle:Byte Ptr)
	Function bmx_b2pulleyjoint_getgroundanchor2:b2Vec2(handle:Byte Ptr)

	Function bmx_b2buoyancycontrollerdef_getnormal:b2Vec2(handle:Byte Ptr)
	Function bmx_b2buoyancycontrollerdef_setnormal(handle:Byte Ptr, normal:b2Vec2 Var)
	Function bmx_b2buoyancycontrollerdef_getvelocity:b2Vec2(handle:Byte Ptr)
	Function bmx_b2buoyancycontrollerdef_setvelocity(handle:Byte Ptr, velocity:b2Vec2 Var)
	Function bmx_b2buoyancycontrollerdef_getgravity:b2Vec2(handle:Byte Ptr)
	Function bmx_b2buoyancycontrollerdef_setgravity(handle:Byte Ptr, gravity:b2Vec2 Var)

	Function bmx_b2tensordampingcontrollerdef_gettensor:b2Mat22(handle:Byte Ptr)
	Function bmx_b2tensordampingcontrollerdef_settensor(handle:Byte Ptr, tensor:b2Mat22 Var)

	Function bmx_b2constantforcecontrollerdef_getforce:b2Vec2(handle:Byte Ptr)
	Function bmx_b2constantforcecontrollerdef_setforce(handle:Byte Ptr, force:b2Vec2 Var)

	Function bmx_b2constantforcecontroller_getforce:b2Vec2(handle:Byte Ptr)
	Function bmx_b2constantforcecontroller_setforce(handle:Byte Ptr, force:b2Vec2 Var)

	Function bmx_b2constantaccelcontrollerdef_getforce:b2Vec2(handle:Byte Ptr)
	Function bmx_b2constantaccelcontrollerdef_setforce(handle:Byte Ptr, force:b2Vec2 Var)

	Function bmx_b2constantaccelcontroller_getforce:b2Vec2(handle:Byte Ptr)
	Function bmx_b2constantaccelcontroller_setforce(handle:Byte Ptr, force:b2Vec2 Var)

	Function bmx_b2buoyancycontroller_getnormal:b2Vec2(handle:Byte Ptr)
	Function bmx_b2buoyancycontroller_setnormal(handle:Byte Ptr, normal:b2Vec2 Var)
	Function bmx_b2buoyancycontroller_getvelocity:b2Vec2(handle:Byte Ptr)
	Function bmx_b2buoyancycontroller_setvelocity(handle:Byte Ptr, velocity:b2Vec2 Var)
	Function bmx_b2buoyancycontroller_getgravity:b2Vec2(handle:Byte Ptr)
	Function bmx_b2buoyancycontroller_setgravity(handle:Byte Ptr, gravity:b2Vec2 Var)

	Function bmx_b2tensordampingcontroller_gettensor:b2Mat22(handle:Byte Ptr)
	Function bmx_b2tensordampingcontroller_settensor(handle:Byte Ptr, tensor:b2Mat22 Var)

End Extern
