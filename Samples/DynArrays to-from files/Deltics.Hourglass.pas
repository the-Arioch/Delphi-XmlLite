{@@License

  <TITLE License and Contact Details>

  * X11 (MIT) LICENSE *

  Copyright © 2008 Jolyon Smith

  Permission is hereby granted, free of charge, to any person obtaining a copy of
   this software and associated documentation files (the "Software"), to deal in
   the Software without restriction, including without limitation the rights to
   use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
   of the Software, and to permit persons to whom the Software is furnished to do
   so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.


  * GPL and Other Licenses *

  The FSF deem this license to be compatible with version 3 of the GPL.
   Compatability with other licenses should be verified by reference to those
   other license terms.


  * Contact Details *

  Original author : Jolyon Smith
  e-mail          : <EXTLINK mailto: jsmith@deltics.co.nz>jsmith@deltics.co.nz</EXTLINK>

  For more information on this and other Delphi code and articles that I have
   written, please visit <EXTLINK http://www.deltics.co.nz/blog>www.deltics.co.nz</EXTLINK>
}

{@@Deltics.Hourglass.pas

    Provides a simple implementation of an automatically cancelling hourglass
     cursor comprising of two direct-call methods:

    HourglassOn()   - turns the hourglass cursor ON, if not already on.

    HourglassOff()  - provided if necessary to forcibly turn the hourglass
                       cursor OFF if required.  This is not usually necessary however.

    Examples Of Use

      uses
        Deltics.Hourglass;



      procedure TMyDialog.ButtonOKClick(Sender: TObject);
      begin
        HourglassOn;

        // perform potentially lengthy MyDialog processing here ...
      end;


      procedure TMyDialog.ButtonOKClick(Sender: TObject);
      begin
        HourglassOn;

        // perform potentially lengthy initialisation here ...
        //  after which we present a file open dialog before the rest
        //  of MyDialog processing can continue, so we wish ensure
        //  the hourglass is turned off at this point

        HourglassOff;

        if OpenDialog.Execute then
        begin
          HourglassOn;

          // perform potentially lengthy initialisation here ...
        end;
      end;
}

  unit Deltics.Hourglass;

interface

  function HourglassActive: Boolean;
  function HourglassOn: IUnknown;
  procedure HourglassOff;


implementation

  uses
    Controls,
    Forms;


  type
    THourglass = class(TInterfacedObject)
    {
      Simple interface object - the reference count (and lifetime) of
       an instance of this class is used to manage the hourglass cursor.
    }
      constructor Create;
      destructor Destroy; override;
    end;


  var
    // Maintains a reference to the current hourglass object (if any)
    _Hourglass: THourglass = NIL;



  {  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - }
  function HourglassActive: Boolean;
  {
    Indicates whether or not an hourglass object is currently active
     (i.e currently assigned).
  }
  begin
    result := Assigned(_Hourglass);
  end;


  {  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - }
  function HourglassOn: IUnknown;
  {
    Turns on the hourglass cursor if it is not already on.

    If there is no hourglass object we create one.  Whether we created one or
     not we always return an interface reference to the hourglass object.
     Once all such references have been released the hourglass object will
     be destroyed and the hourglass automatically turned off.

    The hourglass may be forcibly turned off before any references have
     expired by calling HourglassOff().
  }
  begin
    if NOT Assigned(_Hourglass) then
      THourglass.Create;

    result := _Hourglass;
  end;


  {  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - }
  procedure HourglassOff;
  {
    When turning the hourglass OFF, we simply turn it off.

    No if's and no but's.

    Any current hourglass object will eventually be destroyed - we cannot
     destroy it now ourselves because there may be interface references
     to it which have yet to be released, so in order to allow those
     references to naturally expire we simply NIL the hourglass object
     reference after turning the hourglass off.
  }
  begin
    Screen.Cursor := crDefault;
    _Hourglass    := NIL;
  end;



{ THourglass ------------------------------------------------------------------------------------- }

  {  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - }
  constructor THourglass.Create;
  {
    Initialises an instance of the hourglass object.  A new instance of
     this class indicates that the hourglass is being turned on and that
     this new instance is the new, current hourglass which we maintain
     a reference to in the unit variable.
  }
  begin
    inherited;
    _Hourglass    := self;
    Screen.Cursor := crHourglass;
  end;


  {  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - }
  destructor THourglass.Destroy;
  {
    Hourglass instances are destroyed when all references (one or more calls
     to HourglassOn()) to the object have been released.

    If the hourglass being destroyed is the current hourglass object then we
     need to reset the cursor back to default and clear the reference in the
     unit variable.

    If the hourglass is NOT the current hourglass object then the hourglass
     must have already been forcibly turned off via HourglassOff() and we
     simply silently shuffle off this mortal coil.
  }
  begin
    if (_Hourglass = self) then
    begin
      Screen.Cursor := crDefault;
      _Hourglass := NIL;
    end;

    inherited;
  end;



end.
