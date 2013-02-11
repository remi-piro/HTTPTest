//
//  network.h
//  HTTPTest
//
//  Created by lion on 2/11/13.
//  Copyright (c) 2013 lion. All rights reserved.
//

#ifndef HTTPTest_network_h
#define HTTPTest_network_h

int openSocket();
int sendRequest(int socket_fd, char *data);
int receiveResponse(int socket_fd);
int closeSocket(int socket_fd);

#endif
