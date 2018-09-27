unit TempDS;

interface
uses
 SQLiteTable3;

type
 TTempRec = record
  rDateTime: TDateTime;
  rTemp    : Double;
 end;

 TTempDataSource = class
 private
  f_DB   : TSQLiteDatabase;
  f_Query: TSQLiteTable;
  procedure DropQuery;
  function pm_GetQueryCount: Integer;
  function pm_GetQueryData(Index: Integer): TTempRec;
  procedure DeleteInvalid;
 public
  constructor Create;
  destructor  Destroy; override;
  procedure Put(const aDT: TDateTime; const aTemp: Double);
  procedure Query(const aFrom, aTo: TDateTime);
  function MaxTemp(const aFrom, aTo: TDateTime): TTempRec;
  function AverageTemp(const aFrom, aTo: TDateTime): Double;
  function MinTemp(const aFrom, aTo: TDateTime): TTempRec;
  procedure QueryAll;
  property QueryCount: Integer read pm_GetQueryCount;
  property QueryData[Index: Integer]: TTempRec read pm_GetQueryData;
 end;

implementation
uses
 Forms,
 DateUtils,
 SysUtils;

const
 fldMoment = 1;
 fldTemp   = 2;

 c_DBName    = 'tempdata.db';
 c_TableName = 'templog';

 c_SQL_CreateTable = 'CREATE TABLE '+ c_TableName + ' (_id INTEGER PRIMARY KEY, moment INTEGER, temperature FLOAT);';
 c_SQL_CreateIndex = 'CREATE INDEX idx_datetime ON '+ c_TableName +' (moment);';

constructor TTempDataSource.Create;
var
 l_Path: string;
begin
 inherited;
 l_Path := ExtractFilePath(Application.ExeName) + c_DBName;
 f_DB := TSQLiteDatabase.Create(l_Path);
 if not f_DB.TableExists(c_TableName) then
 begin
  f_DB.ExecSQL(c_SQL_CreateTable);
  f_DB.ExecSQL(c_SQL_CreateIndex);
 end
 else
  DeleteInvalid;
end;

procedure TTempDataSource.DeleteInvalid;
begin
 f_DB.ExecSQL('DELETE FROM '+ c_TableName+ ' WHERE (temperature < -40) or (temperature > 120)');

end;

destructor TTempDataSource.Destroy;
begin
 DropQuery;
 FreeAndNil(f_DB);
 inherited;
end;

procedure TTempDataSource.DropQuery;
begin
 FreeAndNil(f_Query);
end;

function TTempDataSource.pm_GetQueryCount: Integer;
begin
 if Assigned(f_Query) then
  Result := f_Query.Count
 else
  Result := 0;
end;

function TTempDataSource.pm_GetQueryData(Index: Integer): TTempRec;
begin
 Assert(Assigned(f_Query), 'Call Query method beforehand!');
 Assert(f_Query.MoveTo(Index), 'Invalid Index!');
 Result.rDateTime := UnixToDateTime(f_Query.FieldAsInteger(fldMoment));
 Result.rTemp := f_Query.FieldAsDouble(fldTemp);
end;

procedure TTempDataSource.Put(const aDT: TDateTime; const aTemp: Double);
var
 l_Sep: Char;
 l_FS: TFormatSettings;
begin
 DropQuery;
 l_FS:= TFormatSettings.Create;
 l_Sep := l_FS.DecimalSeparator;
 l_FS.DecimalSeparator := '.';
 f_DB.ExecSQL(Format('INSERT INTO '+c_TableName+' (moment, temperature) VALUES (%d, %.6f);', [DateTimeToUnix(aDT), aTemp], l_FS));
 l_FS.DecimalSeparator := l_Sep;
end;

procedure TTempDataSource.Query(const aFrom, aTo: TDateTime);
begin
 Assert(aFrom < aTo);
 DropQuery;
 f_Query := f_DB.GetTable(Format('SELECT * FROM '+c_TableName+' WHERE (moment >= %d) and (moment <= %d) ORDER BY moment;',
    [DateTimeToUnix(aFrom), DateTimeToUnix(aTo)]));
end;

function TTempDataSource.MaxTemp(const aFrom, aTo: TDateTime): TTempRec;
var
 l_Res: TSQLiteTable;
begin
 Assert(aFrom < aTo);
 l_Res := f_DB.GetTable(Format('SELECT * FROM '+c_TableName+' WHERE (moment >= %0:d) and (moment <= %1:d) and' +
     '(temperature in (SELECT max(temperature) FROM '+c_TableName+' WHERE (moment >= %0:d) and (moment <= %1:d)))'+
     ' ORDER BY moment;',
    [DateTimeToUnix(aFrom), DateTimeToUnix(aTo)]));
 try
  if l_Res.Count > 0 then
  begin
    Result.rDateTime := UnixToDateTime(l_Res.FieldAsInteger(fldMoment));
    Result.rTemp     := l_Res.FieldAsDouble(fldTemp);
  end
  else
  begin
    Result.rDateTime := MinDateTime;
    Result.rTemp     := MaxInt;
  end;
 finally
  FreeAndNil(l_Res);
 end;
 DropQuery;
end;

function TTempDataSource.AverageTemp(const aFrom, aTo: TDateTime): Double;
var
 l_Res: TSQLiteTable;
begin
 Assert(aFrom < aTo);
 l_Res := f_DB.GetTable(Format('SELECT avg(temperature) FROM '+c_TableName+' WHERE (moment >= %d) and (moment <= %d) ORDER BY moment;',
    [DateTimeToUnix(aFrom), DateTimeToUnix(aTo)]));
 try
  Result := l_Res.FieldAsDouble(0);
 finally
  FreeAndNil(l_Res);
 end;
 DropQuery;
end;

function TTempDataSource.MinTemp(const aFrom, aTo: TDateTime): TTempRec;
var
 l_Res: TSQLiteTable;
begin
 Assert(aFrom < aTo);
 l_Res := f_DB.GetTable(Format('SELECT * FROM '+c_TableName+' WHERE (moment >= %0:d) and (moment <= %1:d) and' +
     '(temperature in (SELECT min(temperature) FROM '+c_TableName+' WHERE (moment >= %0:d) and (moment <= %1:d)));'+
     ' ORDER BY moment;',
    [DateTimeToUnix(aFrom), DateTimeToUnix(aTo)]));
 try
  if l_Res.Count > 0 then
  begin
   Result.rDateTime := UnixToDateTime(l_Res.FieldAsInteger(fldMoment));
   Result.rTemp     := l_Res.FieldAsDouble(fldTemp);
  end;
 finally
  FreeAndNil(l_Res);
 end;
 DropQuery;
end;

procedure TTempDataSource.QueryAll;
begin
 DropQuery;
 f_Query := f_DB.GetTable('SELECT * FROM '+c_TableName+' ORDER BY moment;');
end;

end.