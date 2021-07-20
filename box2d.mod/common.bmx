' Copyright (c) 2008-2021 Bruce A Henderson
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

Import "source.bmx"

Extern

	Function bmx_b2world_createbody:Byte Ptr(handle:Byte Ptr, def:Byte Ptr, body:Object)
	Function bmx_b2world_destroybody(handle:Byte Ptr, body:Byte Ptr)
	Function bmx_b2world_getgroundbody:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2world_setwarmstarting(handle:Byte Ptr, flag:Int)
	Function bmx_b2world_setcontinuousphysics(handle:Byte Ptr, flag:Int)
	Function bmx_b2world_validate(handle:Byte Ptr)
	Function bmx_b2world_setdebugDraw(handle:Byte Ptr, debugDraw:Byte Ptr)
	Function bmx_b2world_createjoint:Byte Ptr(handle:Byte Ptr, def:Byte Ptr)
	Function bmx_b2world_destroyjoint(handle:Byte Ptr, joint:Byte Ptr)
	Function bmx_b2world_getbodylist:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2world_getjointlist:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2world_setfilter(handle:Byte Ptr, filter:Byte Ptr)
	Function bmx_b2world_setcontactlistener(handle:Byte Ptr, listener:Byte Ptr)
	Function bmx_b2world_setboundarylistener(handle:Byte Ptr, listener:Byte Ptr)
	Function bmx_b2world_getcontactlist:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2world_getproxycount:Int(handle:Byte Ptr)
	Function bmx_b2world_getpaircount:Int(handle:Byte Ptr)
	Function bmx_b2world_getbodycount:Int(handle:Byte Ptr)
	Function bmx_b2world_getjointcount:Int(handle:Byte Ptr)
	Function bmx_b2world_free(handle:Byte Ptr)
	Function bmx_b2world_setdestructionlistener(handle:Byte Ptr, listener:Byte Ptr)
	Function bmx_b2world_refilter(handle:Byte Ptr, shape:Byte Ptr)
	Function bmx_b2world_createcontroller:Byte Ptr(handle:Byte Ptr, def:Byte Ptr, _type:Int)
	Function bmx_b2world_destroycontroller(handle:Byte Ptr, controller:Byte Ptr)

	Function bmx_b2bodydef_create:Byte Ptr()
	Function bmx_b2bodydef_delete(handle:Byte Ptr)
	Function bmx_b2bodydef_setpositionxy(handle:Byte Ptr, x:Float, y:Float)
	Function bmx_b2bodydef_setangle(handle:Byte Ptr, angle:Float)
	Function bmx_b2bodydef_setmassdata(handle:Byte Ptr, data:Byte Ptr)
	Function bmx_b2bodydef_issleeping:Int(handle:Byte Ptr)
	Function bmx_b2bodydef_setissleeping(handle:Byte Ptr, sleeping:Int)
	Function bmx_b2bodydef_setfixedrotation(handle:Byte Ptr, fixed:Int)
	Function bmx_b2bodydef_getfixedrotation:Int(handle:Byte Ptr)
	Function bmx_b2bodydef_setisbullet(handle:Byte Ptr, bullet:Int)
	Function bmx_b2bodydef_setlineardamping(handle:Byte Ptr, damping:Float)
	Function bmx_b2bodydef_getlineardamping:Float(handle:Byte Ptr)
	Function bmx_b2bodydef_setangulardamping(handle:Byte Ptr, damping:Float)
	Function bmx_b2bodydef_getangulardamping:Float(handle:Byte Ptr)
	Function bmx_b2bodydef_setallowsleep(handle:Byte Ptr, allow:Int)
	Function bmx_b2bodydef_getallowsleep:Int(handle:Byte Ptr)
	Function bmx_b2bodydef_getangle:Float(handle:Byte Ptr)
	Function bmx_b2bodydef_isbullet:Int(handle:Byte Ptr)
	Function bmx_b2bodydef_getmassdata:Byte Ptr(handle:Byte Ptr)

	Function bmx_b2world_dostep(handle:Byte Ptr, timeStep:Float, velocityIterations:Int, positionIterations:Int)

	Function bmx_b2shapedef_setfriction(handle:Byte Ptr, friction:Float)
	Function bmx_b2shapedef_setrestitution(handle:Byte Ptr, restitution:Float)
	Function bmx_b2shapedef_setdensity(handle:Byte Ptr, density:Float)
	Function bmx_b2shapedef_setfilter(handle:Byte Ptr, filter:Byte Ptr)
	Function bmx_b2shapedef_getfilter:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2shapedef_setissensor(handle:Byte Ptr, sensor:Int)
	Function bmx_b2shapedef_issensor:Int(handle:Byte Ptr)
	Function bmx_b2shapedef_getfriction:Float(handle:Byte Ptr)
	Function bmx_b2shapedef_getrestitution:Float(handle:Byte Ptr)
	Function bmx_b2shapedef_getdensity:Float(handle:Byte Ptr)

	Function bmx_b2polygondef_create:Byte Ptr()
	Function bmx_b2polygondef_setasbox(handle:Byte Ptr, hx:Float, hy:Float)
	Function bmx_b2polygondef_delete(handle:Byte Ptr)

	Function bmx_b2body_createshape:Byte Ptr(handle:Byte Ptr, def:Byte Ptr)
	Function bmx_b2body_destroyshape(handle:Byte Ptr, shape:Byte Ptr)
	Function bmx_b2body_setmassfromshapes(handle:Byte Ptr)
	Function bmx_b2body_getangle:Float(handle:Byte Ptr)
	Function bmx_b2body_getmaxbody:Object(handle:Byte Ptr)
	Function bmx_b2body_getnext:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2body_getshapelist:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2body_isstatic:Int(handle:Byte Ptr)
	Function bmx_b2body_isdynamic:Int(handle:Byte Ptr)
	Function bmx_b2body_isfrozen:Int(handle:Byte Ptr)
	Function bmx_b2body_issleeping:Int(handle:Byte Ptr)
	Function bmx_b2body_allowsleeping(handle:Byte Ptr, flag:Int)
	Function bmx_b2body_wakeup(handle:Byte Ptr)
	Function bmx_b2body_puttosleep(handle:Byte Ptr)
	Function bmx_b2body_isbullet:Int(handle:Byte Ptr)
	Function bmx_b2body_setbullet(handle:Byte Ptr, flag:Int)
	Function bmx_b2body_setangularvelocity(handle:Byte Ptr, omega:Float)
	Function bmx_b2body_getangularvelocity:Float(handle:Byte Ptr)
	Function bmx_b2body_applytorque(handle:Byte Ptr, torque:Float)
	Function bmx_b2body_getmass:Float(handle:Byte Ptr)
	Function bmx_b2body_getinertia:Float(handle:Byte Ptr)
	Function bmx_b2body_getjointlist:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2body_getworld:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2body_setmass(handle:Byte Ptr, massData:Byte Ptr)

	Function bmx_b2debugdraw_create:Byte Ptr(handle:Object)
	Function bmx_b2debugdraw_setflags(handle:Byte Ptr, flags:Int)
	Function bmx_b2debugdraw_getflags:Int(handle:Byte Ptr)
	Function bmx_b2debugdraw_appendflags(handle:Byte Ptr, flags:Int)
	Function bmx_b2debugdraw_clearflags(handle:Byte Ptr, flags:Int)

	Function bmx_b2circledef_create:Byte Ptr()
	Function bmx_b2circledef_setradius(handle:Byte Ptr, radius:Float)
	Function bmx_b2circledef_delete(handle:Byte Ptr)
	Function bmx_b2circledef_getradius:Float(handle:Byte Ptr)

	Function bmx_b2shape_issensor:Int(handle:Byte Ptr)
	Function bmx_b2shape_getbody:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2shape_getmaxshape:Object(handle:Byte Ptr)
	Function bmx_b2shape_getnext:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2shape_getsweepradius:Float(handle:Byte Ptr)
	Function bmx_b2shape_getfriction:Float(handle:Byte Ptr)
	Function bmx_b2shape_getrestitution:Float(handle:Byte Ptr)
	Function bmx_b2shape_computemass(handle:Byte Ptr, data:Byte Ptr)
	Function bmx_b2shape_getfilterdata:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2shape_setfilterdata(handle:Byte Ptr, data:Byte Ptr)
	Function bmx_b2shape_setfriction(handle:Byte Ptr, friction:Float)
	Function bmx_b2shape_setrestitution(handle:Byte Ptr, restitution:Float)
	Function bmx_b2shape_getdensity:Float(handle:Byte Ptr)
	Function bmx_b2shape_setdensity(handle:Byte Ptr, density:Float)

	Function bmx_b2jointdef_setcollideconnected(handle:Byte Ptr, collideConnected:Int)
	Function bmx_b2jointdef_getcollideconnected:Int(handle:Byte Ptr)
	Function bmx_b2jointdef_setbody1(handle:Byte Ptr, body:Byte Ptr)
	Function bmx_b2jointdef_getbody1:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2jointdef_setbody2(handle:Byte Ptr, body:Byte Ptr)
	Function bmx_b2jointdef_getbody2:Byte Ptr(handle:Byte Ptr)

	Function bmx_b2revolutejointdef_create:Byte Ptr()
	Function bmx_b2revolutejointdef_delete(handle:Byte Ptr)
	Function bmx_b2revolutejointdef_islimitenabled:Int(handle:Byte Ptr)
	Function bmx_b2revolutejointdef_enablelimit(handle:Byte Ptr, limit:Int)
	Function bmx_b2revolutejointdef_getlowerangle:Float(handle:Byte Ptr)
	Function bmx_b2revolutejointdef_setlowerangle(handle:Byte Ptr, angle:Float)
	Function bmx_b2revolutejointdef_getupperangle:Float(handle:Byte Ptr)
	Function bmx_b2revolutejointdef_setupperangle(handle:Byte Ptr, angle:Float)
	Function bmx_b2revolutejointdef_ismotorenabled:Int(handle:Byte Ptr)
	Function bmx_b2revolutejointdef_enablemotor(handle:Byte Ptr, value:Int)
	Function bmx_b2revolutejointdef_getmotorspeed:Float(handle:Byte Ptr)
	Function bmx_b2revolutejointdef_setmotorspeed(handle:Byte Ptr, speed:Float)
	Function bmx_b2revolutejointdef_getmaxmotortorque:Float(handle:Byte Ptr)
	Function bmx_b2revolutejointdef_setmaxmotortorque(handle:Byte Ptr, torque:Float)
	Function bmx_b2revolutejointdef_getreferenceangle:Float(handle:Byte Ptr)
	Function bmx_b2revolutejointdef_setreferenceangle(handle:Byte Ptr, angle:Float)

	Function bmx_b2joint_getmaxjoint:Object(handle:Byte Ptr)
	Function bmx_b2joint_getbody1:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2joint_getbody2:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2joint_getnext:Byte Ptr(handle:Byte Ptr)

	Function bmx_b2massdata_new:Byte Ptr()
	Function bmx_b2massdata_delete(handle:Byte Ptr)
	Function bmx_b2massdata_setmass(handle:Byte Ptr, mass:Float)
	Function bmx_b2massdata_seti(handle:Byte Ptr, i:Float)

	Function bmx_b2jointedge_getother:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2jointedge_getjoint:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2jointedge_getprev:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2jointedge_getnext:Byte Ptr(handle:Byte Ptr)

	Function bmx_b2contactfilter_new:Byte Ptr(handle:Object)
	Function bmx_b2contactfilter_delete(handle:Byte Ptr)

	Function bmx_b2contactlistener_new:Byte Ptr(handle:Object)
	Function bmx_b2contactlistener_delete(handle:Byte Ptr)

	Function bmx_b2boundarylistener_new:Byte Ptr(handle:Object)
	Function bmx_b2boundarylistener_delete(handle:Byte Ptr)

	Function bmx_b2distancejointdef_new:Byte Ptr()
	Function bmx_b2distancejointdef_setlength(handle:Byte Ptr, length:Float)
	Function bmx_b2distancejointdef_getlength:Float(handle:Byte Ptr)
	Function bmx_b2distancejointdef_delete(handle:Byte Ptr)
	Function bmx_b2distancejointdef_setfrequencyhz(handle:Byte Ptr, freq:Float)
	Function bmx_b2distancejointdef_setdampingratio(handle:Byte Ptr, ratio:Float)

	Function bmx_b2prismaticjointdef_create:Byte Ptr()
	Function bmx_b2prismaticjointdef_enablelimit(handle:Byte Ptr, value:Int)
	Function bmx_b2prismaticjointdef_islimitenabled:Int(handle:Byte Ptr)
	Function bmx_b2prismaticjointdef_setlowertranslation(handle:Byte Ptr, Translation:Float)
	Function bmx_b2prismaticjointdef_getlowertranslation:Float(handle:Byte Ptr)
	Function bmx_b2prismaticjointdef_setuppertranslation(handle:Byte Ptr, Translation:Float)
	Function bmx_b2prismaticjointdef_getuppertranslation:Float(handle:Byte Ptr)
	Function bmx_b2prismaticjointdef_enablemotor(handle:Byte Ptr, value:Int)
	Function bmx_b2prismaticjointdef_ismotorenabled:Int(handle:Byte Ptr)
	Function bmx_b2prismaticjointdef_setmaxmotorforce(handle:Byte Ptr, force:Float)
	Function bmx_b2prismaticjointdef_getmaxmotorforce:Float(handle:Byte Ptr)
	Function bmx_b2prismaticjointdef_setmotorspeed(handle:Byte Ptr, speed:Float)
	Function bmx_b2prismaticjointdef_getmotorspeed:Float(handle:Byte Ptr)
	Function bmx_b2prismaticjointdef_delete(handle:Byte Ptr)
	Function bmx_b2prismaticjointdef_setreferenceangle(handle:Byte Ptr, angle:Float)
	Function bmx_b2prismaticjointdef_getreferenceangle:Float(handle:Byte Ptr)

	Function bmx_b2revolutejoint_getlowerlimit:Float(handle:Byte Ptr)
	Function bmx_b2revolutejoint_getupperlimit:Float(handle:Byte Ptr)
	Function bmx_b2revolutejoint_setlimits(handle:Byte Ptr, lowerLimit:Float, upperLimit:Float)
	Function bmx_b2revolutejoint_ismotorenabled:Int(handle:Byte Ptr)
	Function bmx_b2revolutejoint_enablemotor(handle:Byte Ptr, flag:Int)
	Function bmx_b2revolutejoint_setmotorspeed(handle:Byte Ptr, speed:Float)
	Function bmx_b2revolutejoint_getmotorspeed:Float(handle:Byte Ptr)
	Function bmx_b2revolutejoint_setmaxmotortorque(handle:Byte Ptr, torque:Float)
	Function bmx_b2revolutejoint_getmotortorque:Float(handle:Byte Ptr)
	Function bmx_b2revolutejoint_islimitenabled:Int(handle:Byte Ptr)
	Function bmx_b2revolutejoint_enablelimit(handle:Byte Ptr, flag:Int)
	Function bmx_b2revolutejoint_getreactiontorque:Float(handle:Byte Ptr, inv_dt:Float)
	Function bmx_b2revolutejoint_getjointangle:Float(handle:Byte Ptr)
	Function bmx_b2revolutejoint_getjointspeed:Float(handle:Byte Ptr)

	Function bmx_b2prismaticjoint_getjointspeed:Float(handle:Byte Ptr)
	Function bmx_b2prismaticjoint_islimitenabled:Int(handle:Byte Ptr)
	Function bmx_b2prismaticjoint_enablelimit(handle:Byte Ptr, flag:Int)
	Function bmx_b2prismaticjoint_getlowerlimit:Float(handle:Byte Ptr)
	Function bmx_b2prismaticjoint_getupperlimit:Float(handle:Byte Ptr)
	Function bmx_b2prismaticjoint_setlimits(handle:Byte Ptr, lowerLimit:Float, upperLimit:Float)
	Function bmx_b2prismaticjoint_ismotorenabled:Int(handle:Byte Ptr)
	Function bmx_b2prismaticjoint_enablemotor(handle:Byte Ptr, flag:Int)
	Function bmx_b2prismaticjoint_setmotorspeed(handle:Byte Ptr, speed:Float)
	Function bmx_b2prismaticjoint_getmotorspeed:Float(handle:Byte Ptr)
	Function bmx_b2prismaticjoint_setmaxmotorforce(handle:Byte Ptr, force:Float)
	Function bmx_b2prismaticjoint_getmotorforce:Float(handle:Byte Ptr)
	Function bmx_b2prismaticjoint_getreactiontorque:Float(handle:Byte Ptr, inv_dt:Float)
	Function bmx_b2prismaticjoint_getjointtranslation:Float(handle:Byte Ptr)

	Function bmx_b2xform_create:Byte Ptr()
	Function bmx_b2xform_getposition:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2xform_setposition(handle:Byte Ptr, pos:Byte Ptr)
	Function bmx_b2xform_getr:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2xform_setr(handle:Byte Ptr, r:Byte Ptr)
	Function bmx_b2xform_delete(handle:Byte Ptr)

	Function bmx_b2contact_getshape1:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2contact_getshape2:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2contact_getnext:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2contact_issolid:Int(handle:Byte Ptr)
	Function bmx_b2contact_getmanifoldcount:Int(handle:Byte Ptr)

	Function bmx_b2filterdata_create:Byte Ptr()
	Function bmx_b2filterdata_getcategorybits:Short(handle:Byte Ptr)
	Function bmx_b2filterdata_setcategorybits(handle:Byte Ptr, categoryBits:Short)
	Function bmx_b2filterdata_getmaskbits:Short(handle:Byte Ptr)
	Function bmx_b2filterdata_setmaskbits(handle:Byte Ptr, maskBits:Short)
	Function bmx_b2filterdata_getgroupindex:Short(handle:Byte Ptr)
	Function bmx_b2filterdata_setgroupindex(handle:Byte Ptr, index:Int)
	Function bmx_b2filterdata_delete(handle:Byte Ptr)

	Function bmx_b2gearjointdef_new:Byte Ptr()
	Function bmx_b2gearjointdef_setjoint1(handle:Byte Ptr, joint:Byte Ptr)
	Function bmx_b2gearjointdef_setjoint2(handle:Byte Ptr, joint:Byte Ptr)
	Function bmx_b2gearjointdef_setratio(handle:Byte Ptr, ratio:Float)
	Function bmx_b2gearjointdef_delete(handle:Byte Ptr)

	Function bmx_b2gearjoint_getreactiontorque:Float(handle:Byte Ptr, inv_dt:Float)
	Function bmx_b2gearjoint_getratio:Float(handle:Byte Ptr)

	Function bmx_b2mousejoint_getreactiontorque:Float(handle:Byte Ptr, inv_dt:Float)

	Function bmx_b2pulleyjoint_getreactiontorque:Float(handle:Byte Ptr, inv_dt:Float)
	Function bmx_b2pulleyjoint_getlength1:Float(handle:Byte Ptr)
	Function bmx_b2pulleyjoint_getlength2:Float(handle:Byte Ptr)
	Function bmx_b2pulleyjoint_getratio:Float(handle:Byte Ptr)

	Function bmx_b2distancejoint_getreactiontorque:Float(handle:Byte Ptr, inv_dt:Float)

	Function bmx_b2mousejointdef_new:Byte Ptr()
	Function bmx_b2mousejointdef_setmaxforce(handle:Byte Ptr, maxForce:Float)
	Function bmx_b2mousejointdef_getmaxforce:Float(handle:Byte Ptr)
	Function bmx_b2mousejointdef_setfrequencyhz(handle:Byte Ptr, frequency:Float)
	Function bmx_b2mousejointdef_getfrequencyhz:Float(handle:Byte Ptr)
	Function bmx_b2mousejointdef_setdampingration(handle:Byte Ptr, ratio:Float)
	Function bmx_b2mousejointdef_getdampingratio:Float(handle:Byte Ptr)
	Function bmx_b2mousejointdef_delete(handle:Byte Ptr)

	Function bmx_b2pulleyjointdef_create:Byte Ptr()
	Function bmx_b2pulleyjointdef_setlength1(handle:Byte Ptr, length:Float)
	Function bmx_b2pulleyjointdef_getlength1:Float(handle:Byte Ptr)
	Function bmx_b2pulleyjointdef_setmaxlength1(handle:Byte Ptr, maxLength:Float)
	Function bmx_b2pulleyjointdef_getmaxlength1:Float(handle:Byte Ptr)
	Function bmx_b2pulleyjointdef_setlength2(handle:Byte Ptr, length:Float)
	Function bmx_b2pulleyjointdef_getlength2:Float(handle:Byte Ptr)
	Function bmx_b2pulleyjointdef_setmaxlength2(handle:Byte Ptr, maxLength:Float)
	Function bmx_b2pulleyjointdef_getmaxlength2:Float(handle:Byte Ptr)
	Function bmx_b2pulleyjointdef_setratio(handle:Byte Ptr, ratio:Float)
	Function bmx_b2pulleyjointdef_getratio:Float(handle:Byte Ptr)
	Function bmx_b2pulleyjointdef_delete(handle:Byte Ptr)

	Function bmx_b2destructionlistener_new:Byte Ptr(handle:Object)
	Function bmx_b2destructionlistener_delete(handle:Byte Ptr)

	Function bmx_b2polygonshape_getobb:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2polygonshape_getvertexcount:Int(handle:Byte Ptr)

	Function bmx_b2circleshape_getradius:Float(handle:Byte Ptr)

	Function bmx_b2linejointdef_create:Byte Ptr()
	Function bmx_b2linejointdef_enablelimit(handle:Byte Ptr, limit:Int)
	Function bmx_b2linejointdef_getlimit:Int(handle:Byte Ptr)
	Function bmx_b2linejointdef_setlowertranslation(handle:Byte Ptr, Translation:Float)
	Function bmx_b2linejointdef_getlowertranslation:Float(handle:Byte Ptr)
	Function bmx_b2linejointdef_setuppertranslation(handle:Byte Ptr, Translation:Float)
	Function bmx_b2linejointdef_getuppertranslation:Float(handle:Byte Ptr)
	Function bmx_b2linejointdef_enablemotor(handle:Byte Ptr, enable:Int)
	Function bmx_b2linejointdef_ismotorenabled:Int(handle:Byte Ptr)
	Function bmx_b2linejointdef_setmaxmotorforce(handle:Byte Ptr, maxForce:Float)
	Function bmx_b2linejointdef_getmaxmotorforce:Float(handle:Byte Ptr)
	Function bmx_b2linejointdef_setmotorspeed(handle:Byte Ptr, speed:Float)
	Function bmx_b2linejointdef_getmotorspeed:Float(handle:Byte Ptr)
	Function bmx_b2linejointdef_delete(handle:Byte Ptr)

	Function bmx_b2linejoint_getreactiontorque:Float(handle:Byte Ptr, inv_dt:Float)
	Function bmx_b2linejoint_getjointtranslation:Float(handle:Byte Ptr)
	Function bmx_b2linejoint_getjointspeed:Float(handle:Byte Ptr)
	Function bmx_b2linejoint_islimitenabled:Int(handle:Byte Ptr)
	Function bmx_b2linejoint_enablelimit(handle:Byte Ptr, flag:Int)
	Function bmx_b2linejoint_getlowerlimit:Float(handle:Byte Ptr)
	Function bmx_b2linejoint_getupperlimit:Float(handle:Byte Ptr)
	Function bmx_b2linejoint_setlimits(handle:Byte Ptr, _lower:Float, _upper:Float)
	Function bmx_b2linejoint_ismotorenabled:Int(handle:Byte Ptr)
	Function bmx_b2linejoint_enablemotor(handle:Byte Ptr, flag:Int)
	Function bmx_b2linejoint_setmotorspeed(handle:Byte Ptr, speed:Float)
	Function bmx_b2linejoint_getmotorspeed:Float(handle:Byte Ptr)
	Function bmx_b2linejoint_setmaxmotorforce(handle:Byte Ptr, force:Float)
	Function bmx_b2linejoint_getmotorforce:Float(handle:Byte Ptr)

	Function bmx_b2edgechaindef_create:Byte Ptr()
	Function bmx_b2edgechaindef_getdef:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2edgechaindef_isaloop:Int(handle:Byte Ptr)
	Function bmx_b2edgechaindef_setisaloop(handle:Byte Ptr, value:Int)
	Function bmx_b2edgechaindef_delete(handle:Byte Ptr)

	Function bmx_b2edgeshape_getlength:Float(handle:Byte Ptr)
	Function bmx_b2edgeshape_corner1isconvex:Int(handle:Byte Ptr)
	Function bmx_b2edgeshape_corner2isconvex:Int(handle:Byte Ptr)
	Function bmx_b2edgeshape_getnextedge:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2edgeshape_getprevedge:Byte Ptr(handle:Byte Ptr)

	Function bmx_b2buoyancycontrollerdef_create:Byte Ptr()
	Function bmx_b2buoyancycontrollerdef_getoffset:Float(handle:Byte Ptr)
	Function bmx_b2buoyancycontrollerdef_setoffset(handle:Byte Ptr, offset:Float)
	Function bmx_b2buoyancycontrollerdef_getdensity:Float(handle:Byte Ptr)
	Function bmx_b2buoyancycontrollerdef_setdensity(handle:Byte Ptr, density:Float)
	Function bmx_b2buoyancycontrollerdef_getlineardrag:Float(handle:Byte Ptr)
	Function bmx_b2buoyancycontrollerdef_setlineardrag(handle:Byte Ptr, drag:Float)
	Function bmx_b2buoyancycontrollerdef_getangulardrag:Float(handle:Byte Ptr)
	Function bmx_b2buoyancycontrollerdef_setangulardrag(handle:Byte Ptr, drag:Float)
	Function bmx_b2buoyancycontrollerdef_usesdensity:Int(handle:Byte Ptr)
	Function bmx_b2buoyancycontrollerdef_setusesdensity(handle:Byte Ptr, value:Int)
	Function bmx_b2buoyancycontrollerdef_usesworldgravity:Int(handle:Byte Ptr)
	Function bmx_b2buoyancycontrollerdef_setusesworldgravity(handle:Byte Ptr, value:Int)
	Function bmx_b2buoyancycontrollerdef_delete(handle:Byte Ptr)

	Function bmx_b2buoyancycontroller_getoffset:Float(handle:Byte Ptr)
	Function bmx_b2buoyancycontroller_setoffset(handle:Byte Ptr, offset:Float)
	Function bmx_b2buoyancycontroller_getdensity:Float(handle:Byte Ptr)
	Function bmx_b2buoyancycontroller_setdensity(handle:Byte Ptr, density:Float)
	Function bmx_b2buoyancycontroller_getlineardrag:Float(handle:Byte Ptr)
	Function bmx_b2buoyancycontroller_setlineardrag(handle:Byte Ptr, drag:Float)
	Function bmx_b2buoyancycontroller_getangulardrag:Float(handle:Byte Ptr)
	Function bmx_b2buoyancycontroller_setangulardrag(handle:Byte Ptr, drag:Float)
	Function bmx_b2buoyancycontroller_usesdensity:Int(handle:Byte Ptr)
	Function bmx_b2buoyancycontroller_setusesdensity(handle:Byte Ptr, value:Int)
	Function bmx_b2buoyancycontroller_usesworldgravity:Int(handle:Byte Ptr)
	Function bmx_b2buoyancycontroller_setusesworldgravity(handle:Byte Ptr, value:Int)

	Function bmx_b2tensordampingcontrollerdef_create:Byte Ptr()
	Function bmx_b2tensordampingcontrollerdef_delete(handle:Byte Ptr)
	Function bmx_b2tensordampingcontrollerdef_getmaxtimestep:Float(handle:Byte Ptr)
	Function bmx_b2tensordampingcontrollerdef_setmaxtimestep(handle:Byte Ptr, timestep:Float)
	Function bmx_b2tensordampingcontrollerdef_setaxisaligned(handle:Byte Ptr, xDamping:Float, yDamping:Float)

	Function bmx_b2tensordampingcontroller_getmaxtimestep:Float(handle:Byte Ptr)
	Function bmx_b2tensordampingcontroller_setmaxtimestep(handle:Byte Ptr, timestep:Float)

	Function bmx_b2gravitycontrollerdef_create:Byte Ptr()
	Function bmx_b2gravitycontrollerdef_delete(handle:Byte Ptr)
	Function bmx_b2gravitycontrollerdef_getforce:Float(handle:Byte Ptr)
	Function bmx_b2gravitycontrollerdef_setforce(handle:Byte Ptr, force:Float)
	Function bmx_b2gravitycontrollerdef_isinvsqr:Int(handle:Byte Ptr)
	Function bmx_b2gravitycontrollerdef_setisinvsqr(handle:Byte Ptr, value:Int)

	Function bmx_b2gravitycontroller_getforce:Float(handle:Byte Ptr)
	Function bmx_b2gravitycontroller_setforce(handle:Byte Ptr, force:Float)
	Function bmx_b2gravitycontroller_isinvsqr:Int(handle:Byte Ptr)
	Function bmx_b2gravitycontroller_setisinvsqr(handle:Byte Ptr, value:Int)

	Function bmx_b2constantforcecontrollerdef_create:Byte Ptr()
	Function bmx_b2constantforcecontrollerdef_delete(handle:Byte Ptr)

	Function bmx_b2constantaccelcontrollerdef_create:Byte Ptr()
	Function bmx_b2constantaccelcontrollerdef_delete(handle:Byte Ptr)

	Function bmx_b2controlleredge_getcontroller:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2controlleredge_getbody:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2controlleredge_getprevbody:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2controlleredge_getnextbody:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2controlleredge_getprevcontroller:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2controlleredge_getnextcontroller:Byte Ptr(handle:Byte Ptr)

	Function bmx_b2controller_getmaxcontroller:Object(handle:Byte Ptr)
	Function bmx_b2controller_addbody(handle:Byte Ptr, body:Byte Ptr)
	Function bmx_b2controller_removebody(handle:Byte Ptr, body:Byte Ptr)
	Function bmx_b2controller_clear(handle:Byte Ptr)
	Function bmx_b2controller_getnext:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2controller_getworld:Byte Ptr(handle:Byte Ptr)
	Function bmx_b2controller_getbodylist:Byte Ptr(handle:Byte Ptr)

End Extern

Const e_unknownJoint:Int = 0
Const e_revoluteJoint:Int = 1
Const e_prismaticJoint:Int = 2
Const e_distanceJoint:Int = 3
Const e_pulleyJoint:Int = 4
Const e_mouseJoint:Int = 5
Const e_gearJoint:Int = 6
Const e_lineJoint:Int = 7

Const e_unknownShape:Int = -1
Const e_circleShape:Int = 0
Const e_polygonShape:Int = 1
Const e_edgeShape:Int = 2

Const e_buoyancyController:Int = 1
Const e_constantAccelController:Int = 2
Const e_tensorDampingController:Int = 3
Const e_gravityController:Int = 4
Const e_constantForceController:Int = 5

