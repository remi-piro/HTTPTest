//
//  HTTPNetwork.h
//  HTTPTest
//
//  Created by Remi on 11/02/13.
//  Copyright (c) 2013 lion. All rights reserved.
//

#ifndef HTTPTest_HTTPNetwork_h
#define HTTPTest_HTTPNetwork_h

int HTTPNetworkConnectToHost(const char *host);
void HTTPNetworkDisconnectFromHost(int socketFd);
int HTTPNetworkSend(int socketFd, const char *request);
int HTTPNetworkReceive(int socketFd, char **responseBody, int *responseLength);
void HTTPNetworkFreeResponseBody(char *responseBody);

#endif
