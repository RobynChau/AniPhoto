//
//  EPSCompileDefines.h
//  AniPhoto
//
//  Created by PhatCH on 20/6/24.
//

/// Endpoint for authentication calls
/// Modify this for correct authentication setup
#define kAuthEndPointURL                @"https://keycloak.vohuynh19.info/realms/ios-entertainment-photography/protocol/openid-connect/auth"
#define kAuthTokenEndpointURL           @"https://keycloak.vohuynh19.info/realms/ios-entertainment-photography/protocol/openid-connect/token"
#define kAuthIssuerURL                  @"https://keycloak.vohuynh19.info/realms/ios-entertainment-photography"
#define kAuthRegistrationEndpointURL    @"https://keycloak.vohuynh19.info/realms/ios-entertainment-photography/clients-registrations/openid-connect"
#define kAuthEndSessionEndpointURL      @"https://keycloak.vohuynh19.info/realms/ios-entertainment-photography/protocol/openid-connect/logout"
#define kAuthClientID                   @"iOS_AniPhoto"
#define kAuthClientSecret               @"TkYf2zOddqj58mELgXkAIYVmShAobQgm"
#define kAuthRedirectURI                @"aniphoto://login"

/// Endpoint for backend API calls
/// Modify this for correct API calls to backend
#define kServerEndPointURL @"https://vohuynh19-animegan-server.hf.space"
