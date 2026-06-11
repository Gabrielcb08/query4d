unit Query4D.Shared.Exceptions;

interface

uses
  System.SysUtils;

type
  EQuery4D            = class(Exception);
  EInvalidQuery       = class(EQuery4D);
  EInvalidAlias       = class(EQuery4D);
  EInvalidColumn      = class(EQuery4D);
  EInvalidTable       = class(EQuery4D);
  EUnsafeOperation    = class(EQuery4D);
  EDialectNotSupported = class(EQuery4D);
  EDialectNotInjected    = class(EQuery4D);
  EGuardViolation        = class(EQuery4D);
  ESubqueryRequiresAlias = class(EQuery4D);
  EBindError          = class(EQuery4D);

implementation

end.
