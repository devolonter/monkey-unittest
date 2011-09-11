Strict

Import mojo

#Rem 
Header: Simple unit testing framework
#End

Interface IUnitTest
	
	#Rem
	summary: Run test
	#End
	Method Run:Bool()

	#Rem
	summary: Get name of the test
	#End
	Method GetName:String()
	
End Interface

Class CompletedUnitTest
	
	Const SUCCESS:Int = 1
	Const FAILURE:Int = 2	

	Field test:IUnitTest
	Field status:Int
	
	Method New(test:IUnitTest, status:Int)
		Self.test = test
		Self.status = status
	End Method

End Class

Class UnitTestApp Extends App 

	Method OnCreate:Int()
		Self.Setup()
		Self._countTests = Self._tests.Count()
		
		If (Self._countTests = 0) Then
			Error("No tests to run")
		End If
		
		SetUpdateRate(30)
		Return 0
	End Method
	
	Method OnUpdate:Int()
		If (Self._isCompleted) Return 0
	
		Self._currentTest = Self._tests.RemoveFirst()
		
		Local completedTest:CompletedUnitTest
		
		if (Self._currentTest.Run()) Then
			completedTest = New CompletedUnitTest(Self._currentTest, CompletedUnitTest.SUCCESS)
			Print(Self._currentTest.GetName()+" unit test... SUCCESS")
		Else
			completedTest = New CompletedUnitTest(Self._currentTest, CompletedUnitTest.FAILURE)
			Print(Self._currentTest.GetName()+" unit test... FAILURE")
			Self._countFailedTests+=1
		End If 
		
		Self._completedTests.AddLast(completedTest)
		
		If (Self._tests.Count() = 0) Self._isCompleted = True
		Return 0	
	End
	
	Method OnRender:Int()
		Cls(0, 0, 0)
		
		Local offsetY:Int = 5
		For Local completed:CompletedUnitTest = EachIn Self._completedTests
			If (completed.status = CompletedUnitTest.SUCCESS) Then
				SetColor(0,255,0)
				DrawText(completed.test.GetName()+" unit test... SUCCESS", 5, offsetY)
			Else
				SetColor(255,0,0)
				DrawText(completed.test.GetName()+" unit test... FAILURE", 5, offsetY)
			End If			
			
			offsetY+=12	
		Next

		If (Self._isCompleted) Then
			If (Self._countFailedTests > 0) Then
				SetColor(255,0,0)
			Else
				SetColor(0,255,0)		
			End If
			
			DrawText("---", 5, offsetY)
			
			offsetY+=12	
			DrawText(Self.GetName()+" unit testing complete.", 5, offsetY)
				
			offsetY+=12	
			DrawText("Total tests: "+Self._countTests+
				", successful tests: "+(Self._countTests-Self._countFailedTests)+
				", failed tests: "+Self._countFailedTests, 5, offsetY)
		End If
		
		SetColor(255, 255, 255)
		Return 0	
	End Method
	
	#Rem
	summary: Add unit test for running
	#End
	Method AddTest:Void(test:IUnitTest)
		Self._tests.AddLast(test)	
	End Method
	
	#Rem
	summary: Setup application for unit testing
	#End	
	Method Setup:Void() Abstract
	
	#Rem
	summary: Get name of the tests collection
	#End
	Method GetName:String() Abstract
	
Private
	
	Field _countTests:Int
	Field _countFailedTests:Int
	
	Field _tests:List<IUnitTest> = New List<IUnitTest>
	Field _completedTests:List<CompletedUnitTest> = New List<CompletedUnitTest>
	
	Field _currentTest:IUnitTest
	Field _isCompleted:Bool = False
	
End Class

Class UnitTest 
	
	#Rem
	summary: Asserts that a condition is true.
	#End	
	Function AssertTrue:Bool(value:Bool, message:String = "")
		If (Not value) Return UnitTest._AssertError("AssertTrue(): " + _ErrorFormat(message))
		Return True			
	End Function
	
	#Rem
	summary: Asserts that a condition is false.
	#End
	Function AssertFalse:Bool(value:Bool, message:String = "")	
		If (value) Return _AssertError("AssertFalse(): " + _ErrorFormat(message))
		Return True			
	End Function
	
	#Rem
	summary: Asserts that two objects are equal.
	#End
	Function AssertSame:Bool(expected:Object, actual:Object, message:String = "")		
		If (expected <> actual) Then
			Return _AssertError("AssertEquals(): " + _ErrorFormat(message))
		End If
		Return True		
	End Function
	
	#Rem
	summary: Asserts that two ints are equal.
	#End
  	Function AssertEqualsI:Bool(expected:Int, actual:Int, message:String = "")
		If (expected <> actual) Then
			Return _AssertError("AssertEqualsI(): " + _ErrorFormatEqualI(expected, actual, message))
		End If
		Return True	
  	End Function
	
	#Rem
	summary: Asserts that two floats are equal.
	#End
  	Function AssertEqualsF:Bool(expected:Float, actual:Float, delta:Float = 0, message:String = "")
		If (Abs(expected - actual) > delta) Then
			Return _AssertError("AssertEqualsF(): " + _ErrorFormatEqualF(expected, actual, delta, message))
		End If
		Return True	
  	End Function
	
	#Rem
	summary: Asserts that two strings are equal.
	#End
  	Function AssertEqualsS:Bool(expected:String, actual:String, message:String = "")
		If (expected.Compare(actual) <> 0) Then
			Return _AssertError("AssertEqualsS(): " + _ErrorFormatEqualS(expected, actual, message))
		End If
		Return True	
  	End Function
	
	#Rem
	summary: Asserts that an object isn't null.
	#End
	Function AssertNotNull:Bool(obj:Object, message:String = "")
		If (obj = Null) Then
			Return _AssertError("AssertNotNull(): " + _ErrorFormat(message))
		End If
		Return True	
	End Function

	#Rem
	summary: Asserts that an Object is null.
	#End
	Function AssertNull:Bool(obj:Object, message:String = "")
		If (obj <> Null) Then
			Return _AssertError("AssertNull(): " + _ErrorFormat(message))
		End If
		Return True	
	End Function
	
Private
	Const DEFAULT_MESSAGE:String = "failure"

	Function _ErrorFormat:String(message:String)
		Local formatted:String
		If message <> "" Then
			formatted = message + " "
		Else
			formatted = DEFAULT_MESSAGE + " "
		End If
		Return formatted
	End Function
	
	Function _ErrorFormatEqualI:String(expected:Int, actual:Int, message:String)
		Return _ErrorFormat(message) + "expected:<"+expected+"> but was:<"+actual+">"
	End Function
	
	Function _ErrorFormatEqualF:String(expected:Float, actual:Float, delta:Float, message:String)
		Return _ErrorFormat(message) + "expected:<"+expected+"> with delat:<"+delta+"> but was:<"+actual+">"
	End Function
	
	Function _ErrorFormatEqualS:String(expected:String, actual:String, message:String)
		Return _ErrorFormat(message) + "expected:<"+expected+"> but was:<"+actual+">"
	End Function
	
	Function _AssertError:Bool(message:String)
		#If (CONFIG = "debug")
			Print(message)
			Error(message)
		#End
		
		Return False
	End Function	

End Class