'
' Part of the examples framework... imported by test.bmx
'
SuperStrict

Import BRL.GLMax2D

Global xScale:Float = 8
Global yScale:Float = 8
Global detailFont:TImageFont

Type debugDraw Extends b2DebugDraw

	Field showDetails:Int = False

	Method DrawPolygon(vertices:b2Vec2[], color:b2Color)
	End Method

	Rem
	bbdoc: Draw a solid closed polygon provided in CCW order
	End Rem
	Method DrawSolidPolygon(vertices:b2Vec2[], color:b2Color)
		SetImageFont(detailFont)
		SetAlpha 0.5
		SetColor(color.red / 2, color.green / 2, color.blue / 2)
		
		Local poly:Float[] = New Float[vertices.length * 2]
		For Local i:Int = 0 Until vertices.length
			poly[i * 2] = vertices[i].x * xScale
			poly[i * 2 + 1] = vertices[i].y * (-yScale)
		Next
		DrawPoly(poly)
		
		SetAlpha 1
		SetColor(color.red / 2, color.green / 2, color.blue / 2)
		
		For Local i:Int = 0 Until vertices.length - 1
			DrawLine poly[i * 2], poly[i * 2 + 1], poly[i * 2 + 2], poly[i * 2 + 3]
			
			If showDetails Then
				DrawText StripPlaces(vertices[i + 1].x) + "," + StripPlaces(vertices[i + 1].y), poly[i * 2 + 2] + 5, poly[i * 2 + 3] + 5
			End If
		Next
		DrawLine poly[0], poly[1], poly[poly.length - 2], poly[poly.length - 1]

		If showDetails Then
			DrawText StripPlaces(vertices[0].x) + "," + StripPlaces(vertices[1].y), poly[0] + 5, poly[1] + 5
		End If
		
		SetImageFont(Null)
	End Method

	Rem
	bbdoc: Draw a circle.
	End Rem
	Method DrawCircle(center:b2Vec2, radius:Float, color:b2Color)
	End Method
	
	Rem
	bbdoc: Draw a solid circle.
	End Rem
	Method DrawSolidCircle(center:b2Vec2, radius:Float, axis:b2Vec2, color:b2Color)
		SetAlpha 1
		SetColor(color.red / 2, color.green / 2, color.blue / 2)

		DrawOval (center.x - radius) * xScale, (center.y - radius) * (-yScale), (radius * 2) * xScale, (radius * 2) * (-yScale)
		
'		SetAlpha 1
'		SetColor(color.red / 2, color.green / 2, color.blue / 2)

	End Method
	
	Rem
	bbdoc: Draw a line segment.
	End Rem
	Method DrawSegment(p1:b2Vec2, p2:b2Vec2, color:b2Color)
		SetColor(color.red, color.green, color.blue)
		DrawLine p1.x * xScale, p1.y * (-yScale), p2.x * xScale, p2.y * (-yScale)
	End Method
	
	Rem
	bbdoc: Draw a transform. Choose your own length scale.
	/// @param xf a transform.
	End Rem
	Method DrawXForm(xf:b2XForm)
	End Method

	Method DrawPoint(p:b2Vec2, size:Float, color:b2Color)
		glPointSize(size)
		
		SetColor(color.red, color.green, color.blue)
		Plot(p.x * xScale, p.y * (-yScale))
		
		glPointSize(1.0)
	End Method

End Type

Function StripPlaces:String(Text:String, size:Int = 2)
	Local pos:Int = Text.find(".")
	If pos < 0 Or Text.length < pos + size Then
		Return Text
	End If
	Return Text[..pos + size]
End Function
