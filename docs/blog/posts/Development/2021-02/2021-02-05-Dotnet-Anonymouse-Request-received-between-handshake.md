---
title: "An anonymous request was received in between authentication handshake requests"
date: 2021-02-05
categories:
  - Development
tags:
  - Development/C#
  - Development/.NET
---

# An anonymous request was received in between authentication handshake requests

I was receiving this error while hosting a webapi project on .net 5, using kestrel.

```
fail: Microsoft.AspNetCore.Authentication.Negotiate.NegotiateHandler[5]
      An exception occurred while processing the authentication request.
      System.InvalidOperationException: An anonymous request was received in between authentication handshake requests.
         at Microsoft.AspNetCore.Authentication.Negotiate.NegotiateHandler.HandleRequestAsync()
fail: Microsoft.AspNetCore.Server.Kestrel[13]
      Connection id "0HM6A34N67LO5", Request id "0HM6A34N67LO5:00000005": An unhandled exception was thrown by the application.
      System.InvalidOperationException: An anonymous request was received in between authentication handshake requests.
         at Microsoft.AspNetCore.Authentication.Negotiate.NegotiateHandler.HandleRequestAsync()
         at Microsoft.AspNetCore.Authentication.Negotiate.NegotiateHandler.HandleRequestAsync()
         at Microsoft.AspNetCore.Authentication.AuthenticationMiddleware.Invoke(HttpContext context)
         at Swashbuckle.AspNetCore.SwaggerUI.SwaggerUIMiddleware.Invoke(HttpContext httpContext)
         at Swashbuckle.AspNetCore.Swagger.SwaggerMiddleware.Invoke(HttpContext httpContext, ISwaggerProvider swaggerProvider)
         at Microsoft.AspNetCore.Server.Kestrel.Core.Internal.Http.HttpProtocol.ProcessRequests[TContext](IHttpApplication`1 application)
```

<!-- more -->

## Symptoms

Windows authentication works just fine when debugging locally, however, fails when deployed to a server, or accessing remotely via dns, with this error: `System.InvalidOperationException: An anonymous request was received in between authentication handshake requests.`

## How I corrected it

My kestrel endpoints were configured to `https://0.0.0.0:1234`, with a certificate from `myservice.mydomain.com`.

I resolve the issue by setting my endpoint to `https://myservice.mydomain.com:1234`

As well, ensure you have a SPN configured using `setspn -S HTTP/myserver.mydomain.com myserviceaccount`

## Why am I blogging about this?

Because all of the advice I found while googling was incredibly unhelpful.

* [Github Issue #1](https://github.com/dotnet/aspnetcore/issues/20100){target=_blank} Closed by Microsoft bot. No help.
* [Github Issue #2](https://github.com/dotnet/aspnetcore/issues/13124){target=_blank} Closed, states does not work by design.
* [Stackoverflow #1](https://stackoverflow.com/questions/59185648/kestrel-an-anonymous-request-was-received-in-between-authentication-handshake-r){target=_blank}. No help at all.
* [Stackoverflow #2](https://stackoverflow.com/questions/59111331/windows-authentication-works-on-iis-but-not-kestrel-microsoft-aspnetcore-authe){target=_blank}. No Help.
* [Stackoverflow #3](https://stackoverflow.com/questions/59204346/blazor-windows-authentication-on-kestrel-works-locally-only-an-anonymous-reques){target=_blank} Links back to a github article stating windows auth is not supported.
* [Microsoft Documentation](https://docs.microsoft.com/en-us/aspnet/core/security/authentication/windowsauth?view=aspnetcore-5.0&tabs=visual-studio#kestrel){target=_blank} Says to use http.sys instead of kestrel, and/or update SPN.

So, If I helped a single person, by taking the 5 minutes to write this article, it has served its purpose.

If you do stumble upon this, and it helps you, leave a comment down below.