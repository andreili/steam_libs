unit IClientHTTP_;

interface

uses
  SteamTypes;

const
  CLIENTHTTP_INTERFACE_VERSION = 'CLIENTHTTP_INTERFACE_VERSION001';

type
  EHTTPMethod =
    (k_EHTTPMethodInvalid = 0,
     k_EHTTPMethodGET = 1,
     k_EHTTPMethodHEAD = 2,
     k_EHTTPMethodPOST = 3);

  EHTTPStatusCode =
    (k_EHTTPStatusCodeInvalid = 0,
     k_EHTTPStatusCode100Continue = 100,
     k_EHTTPStatusCode101SwitchingProtocols = 101,
     k_EHTTPStatusCode200OK = 200,
     k_EHTTPStatusCode201Created = 201,
     k_EHTTPStatusCode202Accepted = 202,
     k_EHTTPStatusCode203NonAuthoritative = 203,
     k_EHTTPStatusCode204NoContent = 204,
     k_EHTTPStatusCode205ResetContent = 205,
     k_EHTTPStatusCode206PartialContent = 206,
     k_EHTTPStatusCode300MultipleChoices = 300,
     k_EHTTPStatusCode301MovedPermanently = 301,
     k_EHTTPStatusCode302Found = 302,
     k_EHTTPStatusCode303SeeOther = 303,
     k_EHTTPStatusCode304NotModified = 304,
     k_EHTTPStatusCode305UseProxy = 305,
     k_EHTTPStatusCode307TemporaryRedirect = 307,
     k_EHTTPStatusCode400BadRequest = 400,
     k_EHTTPStatusCode401Unauthorized = 401,
     k_EHTTPStatusCode402PaymentRequired = 402,
     k_EHTTPStatusCode403Forbidden = 403,
     k_EHTTPStatusCode404NotFound = 404,
     k_EHTTPStatusCode405MethodNotAllowed = 405,
     k_EHTTPStatusCode406NotAcceptable = 406,
     k_EHTTPStatusCode407ProxyAuthRequired = 407,
     k_EHTTPStatusCode408RequestTimeout = 408,
     k_EHTTPStatusCode409Conflict = 409,
     k_EHTTPStatusCode410Gone = 410,
     k_EHTTPStatusCode411LengthRequired = 411,
     k_EHTTPStatusCode412PreconditionFailed = 412,
     k_EHTTPStatusCode413RequestEntityTooLarge = 413,
     k_EHTTPStatusCode414RequestURITooLong = 414,
     k_EHTTPStatusCode415UnsupportedMediaType = 415,
     k_EHTTPStatusCode416RequestedRangeNotSatisfiable = 416,
     k_EHTTPStatusCode417ExpectationFailed = 417,
     k_EHTTPStatusCode500InternalServerError = 500,
     k_EHTTPStatusCode501NotImplemented = 501,
     k_EHTTPStatusCode502BadGateway = 502,
     k_EHTTPStatusCode503ServiceUnavailable = 503,
     k_EHTTPStatusCode504GatewayTimeout = 504,
     k_EHTTPStatusCode505HTTPVersionNotSupported = 505);

  IClientHTTP = class
    function CreateHTTPRequest(eHTTPRequestMethod: EHTTPMethod; pchAbsoluteURL: pAnsiChar): HTTPRequestHandle; virtual; abstract;

    function SetHTTPRequestContextValue(hRequest: HTTPRequestHandle; ulContextValue: uint64): boolean; virtual; abstract;
    function SetHTTPRequestNetworkActivityTimeout(hRequest: HTTPRequestHandle; unTimeoutSeconds: uint32): boolean; virtual; abstract;
    function SetHTTPRequestHeaderValue(hRequest: HTTPRequestHandle; pchHeaderName, pchHeaderValue: pAnsiChar): boolean; virtual; abstract;
    function SetHTTPRequestGetOrPostParameter(hRequest: HTTPRequestHandle; pchParamName, pchParamValue: pAnsiChar): boolean; virtual; abstract;

    function SendHTTPRequest(hRequest: HTTPRequestHandle; var pCallHandle: SteamAPICall_t): boolean; virtual; abstract;
    function DeferHTTPRequest(hRequest: HTTPRequestHandle): boolean; virtual; abstract;
    function PrioritizeHTTPRequest(hRequest: HTTPRequestHandle): boolean; virtual; abstract;

    function GetHTTPResponseHeaderSize(hRequest: HTTPRequestHandle; pchHeaderName: pAnsiChar; var unResponseHeaderSize: uint32): boolean; virtual; abstract;
    function GetHTTPResponseHeaderValue(hRequest: HTTPRequestHandle; pchHeaderName: pAnsiChar; pHeaderValueBuffer: puint8; uBufferSize: uint32): boolean; virtual; abstract;
    function GetHTTPResponseBodySize(hRequest: HTTPRequestHandle; var unBodySize: uint32): boolean; virtual; abstract;
    function GetHTTPResponseBodyData(hRequest: HTTPRequestHandle; pBodyDataBuffer: puint8; unBufferSize: uint32): boolean; virtual; abstract;

    function ReleaseHTTPRequest(hRequest: HTTPRequestHandle): boolean; virtual; abstract;
  end;

implementation

end.
