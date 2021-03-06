//
// Toro Multithreading Example
//
// I have implemented three task (T1, T2 and T3), T1 runs in core 0 while T2 and T3 runs in core1.
// T1 and T2 have a data dependency, hence while T1 runs T2 must not, this was implemented with a few
// boolean variables like a semaphore. It could be great to implemented at kernel level thus the user has not
// take in care about that stuff.
// Besides, this is a good example about static scheduling where we are sure about the execution order previusly.
//
// Changes :
// 
// 22/06/2012 First Version by Matias E. Vara.
//
// Copyright (c) 2003-2011 Matias Vara <matiasvara@yahoo.com>
// All Rights Reserved
//
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

program ToroThread;


{$IFDEF FPC}
 {$mode delphi}
{$ENDIF}


// Adding support for FPC 2.0.4 ;)
{$IMAGEBASE 4194304}

// they are declared just the necessary units
// the units used depend the hardware where you are running the application
uses
  Kernel in 'rtl\Kernel.pas',
  Process in 'rtl\Process.pas',
  Memory in 'rtl\Memory.pas',
  Debug in 'rtl\Debug.pas',
  Arch in 'rtl\Arch.pas',
  Filesystem in 'rtl\Filesystem.pas',
  Console in 'rtl\Drivers\Console.pas';


var
 tmp: TThreadID;
 var1, var2, var3: longint;
 // sincronization variable to avoid the execution of task2 and task1 at the same time
 n1: boolean = true;
 n2: boolean = false;

// task 2
function ThreadF2(Param: Pointer):PtrInt;
begin
  while true do
  begin
    while n2=false do SysThreadSwitch;
    var3:=var2+7;
    n2:= false;
    n1:= true ;
  end
end;


// task3
function ThreadF3(Param: Pointer):PtrInt;
begin
  while true do
  begin
      var1:=var3 mod 11;
      SysThreadSwitch;
  end;
end;


begin

  WriteConsole('\c',[0]);
  // initial values
  var1:=0;
  var2:=4;
  var3:=11;
 
  // we create a remote thread
  tmp:= BeginThread(nil, 4096, ThreadF3, nil, 1, tmp);
  tmp:= BeginThread(nil, 4096, ThreadF2, nil, 1, tmp);
 
  // task1 is implemented using main thread in order to keep the scheduler
  // as stable as possible
  while true do
  begin
      while n1=false do SysThreadSwitch;
      var2:=var1+5;
      // this WriteConsole() adds much noise given that it implements atomic operations
      WriteConsole('%d',[var1]);
      // syncro flags
      n1:=false;
      n2:=true;
  end;

end.
