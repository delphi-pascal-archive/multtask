unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, ExtCtrls;

type
  TfmMain = class(TForm)
    laFactors: TLabel;
    laAFactor: TLabel;
    sedAFactor: TSpinEdit;
    laBFactor: TLabel;
    sedBFactor: TSpinEdit;
    laCFactor: TLabel;
    sedCFactor: TSpinEdit;
    btCalc: TButton;
    laX1: TLabel;
    laX2: TLabel;
    Image1: TImage;
    laMadeInRussia: TLabel;
    laDeveloper: TLabel;
    laName: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btCalcClick(Sender: TObject);
  private
  public
  end;

var
  fmMain: TfmMain;

implementation

{$R *.DFM}

type
  TOperandType = Double;

  TOperands = packed record
    dO1, dO2: TOperandType;
  end;

const
  Copyright = 'Multitasking Copyright © 2007 Loonies Software';

  MailslotPrefix = '\\.\mailslot\';

  MulOpsReadyEventName = Copyright + ' - Mul_OpsReady';
  MulResReadyEventName = Copyright + ' - Mul_ResReady';
  MulMailslotOpsName = MailslotPrefix + 'Lab2_Mul_Operands';
  MulMailslotResName = MailslotPrefix + 'Lab2_Mul_Result';

  DivOpsReadyEventName = Copyright + ' - Div_OpsReady';
  DivResReadyEventName = Copyright + ' - Div_ResReady';
  DivMailslotOpsName = MailslotPrefix + 'Lab2_Div_Operands';
  DivMailslotResName = MailslotPrefix + 'Lab2_Div_Result';

  SubOpsReadyEventName = Copyright + ' - Sub_OpsReady';
  SubResReadyEventName = Copyright + ' - Sub_ResReady';
  SubMailslotOpsName = MailslotPrefix + 'Lab2_Sub_Operands';
  SubMailslotResName = MailslotPrefix + 'Lab2_Sub_Result';

  AddOpsReadyEventName = Copyright + ' - Add_OpsReady';
  AddResReadyEventName = Copyright + ' - Add_ResReady';
  AddMailslotOpsName = MailslotPrefix + 'Lab2_Add_Operands';
  AddMailslotResName = MailslotPrefix + 'Lab2_Add_Result';

  RootOpsReadyEventName = Copyright + ' - Root_OpsReady';
  RootResReadyEventName = Copyright + ' - Root_ResReady';
  RootMailslotOpsName = MailslotPrefix + 'Lab2_Root_Operands';
  RootMailslotResName = MailslotPrefix + 'Lab2_Root_Result';

var
  hMulOpsReadyEvent, hDivOpsReadyEvent, hSubOpsReadyEvent, hAddOpsReadyEvent, hRootOpsReadyEvent,
  hMulResReadyEvent, hDivResReadyEvent, hSubResReadyEvent, hAddResReadyEvent, hRootResReadyEvent: THandle;

  MulThreadHandle, DivThreadHandle, SubThreadHandle, AddThreadHandle, RootThreadHandle: THandle;
 
  hMulResMailslot, hDivResMailslot, hSubResMailslot, hAddResMailslot, hRootResMailslot: THandle;

procedure MulThreadProc(lpParameter: Pointer);
var
  OpsReadyEvent, ResReadyEvent: THandle;
  OpsMailslot, ResMailslot: THandle;
  Operands: TOperands;
  Res: TOperandType;
  ReadBytes, WrittenBytes: DWORD;
begin
  OpsReadyEvent:=OpenEvent(EVENT_ALL_ACCESS, false, MulOpsReadyEventName);
  ResReadyEvent:=OpenEvent(EVENT_ALL_ACCESS, false, MulResReadyEventName);

  OpsMailslot:=CreateMailslot(MulMailslotOpsName, 0, MAILSLOT_WAIT_FOREVER, nil);
  ResMailslot:=CreateFile(MulMailslotResName, GENERIC_WRITE, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

  while WaitForSingleObject(OpsReadyEvent, INFINITE) = WAIT_OBJECT_0 do
    begin
      ResetEvent(OpsReadyEvent);

      ReadFile(OpsMailslot, Operands, SizeOf(TOperands), ReadBytes, nil);
      Res:=Operands.dO1 * Operands.dO2;
      WriteFile(ResMailslot, Res, SizeOf(TOperandType), WrittenBytes, nil);

      SetEvent(ResReadyEvent);
    end;

  CloseHandle(OpsMailslot);
  CloseHandle(ResMailslot);
  ExitThread(0);
end;

procedure DivThreadProc(lpParameter: Pointer);
var
  OpsReadyEvent, ResReadyEvent: THandle;
  OpsMailslot, ResMailslot: THandle;
  Operands: TOperands;
  Res: TOperandType;
  ReadBytes, WrittenBytes: DWORD;
begin
  OpsReadyEvent:=OpenEvent(EVENT_ALL_ACCESS, false, DivOpsReadyEventName);
  ResReadyEvent:=OpenEvent(EVENT_ALL_ACCESS, false, DivResReadyEventName);

  OpsMailslot:=CreateMailslot(DivMailslotOpsName, 0, MAILSLOT_WAIT_FOREVER, nil);
  ResMailslot:=CreateFile(DivMailslotResName, GENERIC_WRITE, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

  while WaitForSingleObject(OpsReadyEvent, INFINITE) = WAIT_OBJECT_0 do
    begin
      ResetEvent(OpsReadyEvent);

      ReadFile(OpsMailslot, Operands, SizeOf(TOperands), ReadBytes, nil);
      Res:=Operands.dO1 / Operands.dO2;
      WriteFile(ResMailslot, Res, SizeOf(TOperandType), WrittenBytes, nil);

      SetEvent(ResReadyEvent);
    end;

  CloseHandle(OpsMailslot);
  CloseHandle(ResMailslot);
  ExitThread(0);
end;

procedure SubThreadProc(lpParameter: Pointer);
var
  OpsReadyEvent, ResReadyEvent: THandle;
  OpsMailslot, ResMailslot: THandle;
  Operands: TOperands;
  Res: TOperandType;
  ReadBytes, WrittenBytes: DWORD;
begin
  OpsReadyEvent:=OpenEvent(EVENT_ALL_ACCESS, false, SubOpsReadyEventName);
  ResReadyEvent:=OpenEvent(EVENT_ALL_ACCESS, false, SubResReadyEventName);

  OpsMailslot:=CreateMailslot(SubMailslotOpsName, 0, MAILSLOT_WAIT_FOREVER, nil);
  ResMailslot:=CreateFile(SubMailslotResName, GENERIC_WRITE, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

  while WaitForSingleObject(OpsReadyEvent, INFINITE) = WAIT_OBJECT_0 do
    begin
      ResetEvent(OpsReadyEvent);

      ReadFile(OpsMailslot, Operands, SizeOf(TOperands), ReadBytes, nil);
      Res:=Operands.dO1 - Operands.dO2;
      WriteFile(ResMailslot, Res, SizeOf(TOperandType), WrittenBytes, nil);

      SetEvent(ResReadyEvent);
    end;

  CloseHandle(OpsMailslot);
  CloseHandle(ResMailslot);
  ExitThread(0);
end;

procedure AddThreadProc(lpParameter: Pointer);
var
  OpsReadyEvent, ResReadyEvent: THandle;
  OpsMailslot, ResMailslot: THandle;
  Operands: TOperands;
  Res: TOperandType;
  ReadBytes, WrittenBytes: DWORD;
begin
  OpsReadyEvent:=OpenEvent(EVENT_ALL_ACCESS, false, AddOpsReadyEventName);
  ResReadyEvent:=OpenEvent(EVENT_ALL_ACCESS, false, AddResReadyEventName);

  OpsMailslot:=CreateMailslot(AddMailslotOpsName, 0, MAILSLOT_WAIT_FOREVER, nil);
  ResMailslot:=CreateFile(AddMailslotResName, GENERIC_WRITE, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

  while WaitForSingleObject(OpsReadyEvent, INFINITE) = WAIT_OBJECT_0 do
    begin
      ResetEvent(OpsReadyEvent);

      ReadFile(OpsMailslot, Operands, SizeOf(TOperands), ReadBytes, nil);
      Res:=Operands.dO1 + Operands.dO2;
      WriteFile(ResMailslot, Res, SizeOf(TOperandType), WrittenBytes, nil);

      SetEvent(ResReadyEvent);
    end;

  CloseHandle(OpsMailslot);
  CloseHandle(ResMailslot);
  ExitThread(0);
end;

procedure RootThreadProc(lpParameter: Pointer);
var
  OpsReadyEvent, ResReadyEvent: THandle;
  OpsMailslot, ResMailslot: THandle;
  Operands: TOperands;
  Res: TOperandType;
  ReadBytes, WrittenBytes: DWORD;
begin
  OpsReadyEvent:=OpenEvent(EVENT_ALL_ACCESS, false, RootOpsReadyEventName);
  ResReadyEvent:=OpenEvent(EVENT_ALL_ACCESS, false, RootResReadyEventName);

  OpsMailslot:=CreateMailslot(RootMailslotOpsName, 0, MAILSLOT_WAIT_FOREVER, nil);
  ResMailslot:=CreateFile(RootMailslotResName, GENERIC_WRITE, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

  while WaitForSingleObject(OpsReadyEvent, INFINITE) = WAIT_OBJECT_0 do
    begin
      ResetEvent(OpsReadyEvent);

      ReadFile(OpsMailslot, Operands, SizeOf(TOperands), ReadBytes, nil);
      Res:=Sqrt(Operands.dO1);
      WriteFile(ResMailslot, Res, SizeOf(TOperandType), WrittenBytes, nil);

      SetEvent(ResReadyEvent);
    end;

  CloseHandle(OpsMailslot);
  CloseHandle(ResMailslot);
  ExitThread(0);
end; 

procedure TfmMain.FormCreate(Sender: TObject);
var
  ThreadId: DWORD;
begin
  hMulOpsReadyEvent:=CreateEvent(nil, true, false, MulOpsReadyEventName);
  hDivOpsReadyEvent:=CreateEvent(nil, true, false, DivOpsReadyEventName);
  hSubOpsReadyEvent:=CreateEvent(nil, true, false, SubOpsReadyEventName);
  hAddOpsReadyEvent:=CreateEvent(nil, true, false, AddOpsReadyEventName);
  hRootOpsReadyEvent:=CreateEvent(nil, true, false, RootOpsReadyEventName);

  hMulResReadyEvent:=CreateEvent(nil, true, false, MulResReadyEventName);
  hDivResReadyEvent:=CreateEvent(nil, true, false, DivResReadyEventName);
  hSubResReadyEvent:=CreateEvent(nil, true, false, SubResReadyEventName);
  hAddResReadyEvent:=CreateEvent(nil, true, false, AddResReadyEventName);
  hRootResReadyEvent:=CreateEvent(nil, true, false, RootResReadyEventName);

  hMulResMailslot:=CreateMailslot(MulMailslotResName, 0, MAILSLOT_WAIT_FOREVER, nil);
  hDivResMailslot:=CreateMailslot(DivMailslotResName, 0, MAILSLOT_WAIT_FOREVER, nil);
  hSubResMailslot:=CreateMailslot(SubMailslotResName, 0, MAILSLOT_WAIT_FOREVER, nil);
  hAddResMailslot:=CreateMailslot(AddMailslotResName, 0, MAILSLOT_WAIT_FOREVER, nil);
  hRootResMailslot:=CreateMailslot(RootMailslotResName, 0, MAILSLOT_WAIT_FOREVER, nil);

  MulThreadHandle:=CreateThread(nil, 0, @MulThreadProc, nil, 0, ThreadId);
  DivThreadHandle:=CreateThread(nil, 0, @DivThreadProc, nil, 0, ThreadId);
  SubThreadHandle:=CreateThread(nil, 0, @SubThreadProc, nil, 0, ThreadId);
  AddThreadHandle:=CreateThread(nil, 0, @AddThreadProc, nil, 0, ThreadId);
  RootThreadHandle:=CreateThread(nil, 0, @RootThreadProc, nil, 0, ThreadId);
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  CloseHandle(hMulOpsReadyEvent);
  CloseHandle(hDivOpsReadyEvent);
  CloseHandle(hSubOpsReadyEvent);
  CloseHandle(hAddOpsReadyEvent);
  CloseHandle(hRootOpsReadyEvent);

  CloseHandle(hMulResReadyEvent);
  CloseHandle(hDivResReadyEvent);
  CloseHandle(hSubResReadyEvent);
  CloseHandle(hAddResReadyEvent);
  CloseHandle(hRootResReadyEvent);

  CloseHandle(hMulResMailslot);
  CloseHandle(hDivResMailslot);
  CloseHandle(hSubResMailslot);
  CloseHandle(hAddResMailslot);
  CloseHandle(hRootResMailslot);


  TerminateThread(MulThreadHandle, 0);
  CloseHandle(MulThreadHandle);

  TerminateThread(DivThreadHandle, 0);
  CloseHandle(DivThreadHandle);

  TerminateThread(SubThreadHandle, 0);
  CloseHandle(SubThreadHandle);

  TerminateThread(AddThreadHandle, 0);
  CloseHandle(AddThreadHandle);

  TerminateThread(RootThreadHandle, 0);
  CloseHandle(RootThreadHandle);
end;

procedure WriteOperandsUsingFileMapping(OpsMailslotName: PChar; Operands: TOperands; hEvent: THandle);
var
  OpsMailslot: THandle;
  WrittenBytes: DWORD;
begin
  OpsMailslot:=CreateFile(OpsMailslotName, GENERIC_WRITE, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  WriteFile(OpsMailslot, Operands, SizeOf(TOperands), WrittenBytes, nil);
  CloseHandle(OpsMailslot);

  SetEvent(hEvent);
end;

function ReadResultUsingFileMapping(hResReadyEvent: THandle; MailslotHandle: THandle): TOperandType;
var
  Res: TOperandType;
  ReadBytes: DWORD;
begin
  if WaitForSingleObject(hResReadyEvent, INFINITE) = WAIT_OBJECT_0 then
    begin
      ReadFile(MailslotHandle, Res, SizeOf(TOperandType), ReadBytes, nil);
      Result:=Res;
    end;
end;

procedure TfmMain.btCalcClick(Sender: TObject);
var
  Operands: TOperands;
  dRes, dRes2, dRes3: Double;
  A, B, C: Integer;
begin
  A:=sedAFactor.Value;
  B:=sedBFactor.Value;
  C:=sedCFactor.Value;

  Operands.dO1:=B;
  Operands.dO2:=B;
  WriteOperandsUsingFileMapping(MulMailslotOpsName, Operands, hMulOpsReadyEvent);
  dRes:=ReadResultUsingFileMapping(hMulResReadyEvent, hMulResMailslot);

  Operands.dO1:=4;
  Operands.dO2:=A;
  WriteOperandsUsingFileMapping(MulMailslotOpsName, Operands, hMulOpsReadyEvent);
  dRes2:=ReadResultUsingFileMapping(hMulResReadyEvent, hMulResMailslot);

  Operands.dO1:=dRes2;
  Operands.dO2:=C;
  WriteOperandsUsingFileMapping(MulMailslotOpsName, Operands, hMulOpsReadyEvent);
  dRes2:=ReadResultUsingFileMapping(hMulResReadyEvent, hMulResMailslot);

  Operands.dO1:=dRes;
  Operands.dO2:=dRes2;
  WriteOperandsUsingFileMapping(SubMailslotOpsName, Operands, hSubOpsReadyEvent);
  dRes3:=ReadResultUsingFileMapping(hSubResReadyEvent, hSubResMailslot);

  if dRes3 < 0 then
    begin
      laX1.Caption:='Дискриминант меньше нуля!';
      laX2.Caption:='';
    end
  else
    begin
      Operands.dO1:=0;
      Operands.dO2:=B;
      WriteOperandsUsingFileMapping(SubMailslotOpsName, Operands, hSubOpsReadyEvent);
      dRes:=ReadResultUsingFileMapping(hSubResReadyEvent, hSubResMailslot);

      Operands.dO1:=dRes3;
      WriteOperandsUsingFileMapping(RootMailslotOpsName, Operands, hRootOpsReadyEvent);
      dRes3:=ReadResultUsingFileMapping(hRootResReadyEvent, hRootResMailslot);

      Operands.dO1:=dRes;
      Operands.dO2:=dRes3;
      WriteOperandsUsingFileMapping(AddMailslotOpsName, Operands, hAddOpsReadyEvent);
      dRes2:=ReadResultUsingFileMapping(hAddResReadyEvent, hAddResMailslot);

      Operands.dO1:=dRes;
      Operands.dO2:=dRes3;
      WriteOperandsUsingFileMapping(SubMailslotOpsName, Operands, hSubOpsReadyEvent);
      dRes:=ReadResultUsingFileMapping(hSubResReadyEvent, hSubResMailslot);

      Operands.dO1:=2;
      Operands.dO2:=A;
      WriteOperandsUsingFileMapping(MulMailslotOpsName, Operands, hMulOpsReadyEvent);
      dRes3:=ReadResultUsingFileMapping(hMulResReadyEvent, hMulResMailslot);

      Operands.dO1:=dRes;
      Operands.dO2:=dRes3;
      WriteOperandsUsingFileMapping(DivMailslotOpsName, Operands, hDivOpsReadyEvent);
      dRes:=ReadResultUsingFileMapping(hDivResReadyEvent, hDivResMailslot);

      Operands.dO1:=dRes2;
      Operands.dO2:=dRes3;
      WriteOperandsUsingFileMapping(DivMailslotOpsName, Operands, hDivOpsReadyEvent);
      dRes2:=ReadResultUsingFileMapping(hDivResReadyEvent, hDivResMailslot);

      laX1.Caption:='x1 = ' + FloatToStrF(dRes, ffFixed, 15, 2);
      laX2.Caption:='x2 = ' + FloatToStrF(dRes2, ffFixed, 15, 2);
    end; 
end;

end.
