//
//  HTTPNetwork.c
//  HTTPTest
//
//  Created by Remi on 11/02/13.
//  Copyright (c) 2013 lion. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/socket.h>
#include <netdb.h>
#include <netinet/in.h>
#include <sys/ioctl.h>
#include <errno.h>

#define CHUNK_BUFFER_SIZE 4096

#define WAITING 1
#define EXTRACT_HTTP 2
#define EXTRACT_BODY 3

int HTTPNetworkConnectToHost(const char *host)
{
    int socket_fd = socket(AF_INET, SOCK_STREAM, 0);
    
    if (socket_fd == -1) {
        return -1;
    }
    
    struct sockaddr_in serv_addr;
    struct hostent *server;
    
    server = gethostbyname(host);
    
    if (server == 0) {
        return -2;
    }
    
    memcpy(&(serv_addr.sin_addr), server->h_addr_list[0], server->h_length);
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_port = htons(80);
    
    // Connect to the server
    int res = connect(socket_fd, (struct sockaddr*)&serv_addr , sizeof(serv_addr));
    
    if (res == -1) {
        return -3;
    }
    
    // Set non blocking
    int flags = 1;
     
    res = ioctl(socket_fd, FIONBIO, &flags);
     
    if (res == -1) {
        return -4;
    }

    return socket_fd;
}

void HTTPNetworkDisconnectFromHost(int socket_fd)
{
    close(socket_fd);
}

int HTTPNetworkSend(int socket_fd, const char *request)
{
    int len = strlen(request);
    
    int ret = send(socket_fd, request, len, 0);
    
    if (len == ret) {
        return 0;
    }
    
    return -1;
}

static char *processHTTPResponse(char *response, unsigned int length, int *content_length)
{
    char *begin = response;
    
    char *contentlength = "Content-Length: ";
    int contentlengthsize = strlen(contentlength);
    
    unsigned int index = 0;
    
    while (index < length) {
        
        index++;
        
        if (*response == '\n') {
            
            if (response - begin == 1 && *begin == '\r') {
                // end of HTTP header
                printf("found end of HTTP header\n");
                return response+1;
            }
            else {
                if (strncmp(begin, contentlength, contentlengthsize) == 0) {
                    begin += contentlengthsize;
                    *response = 0;
                    *content_length = atoi(begin);
                }
            }
            
            begin = response + 1;
            response = begin;
        }
        else {
            response++;
        }
    }
    
    return 0;
}

int HTTPNetworkReceive(int socket_fd, char **response_body, int *response_length)
{
    int ret = 0;
    ssize_t size = 0;
	char buffer[CHUNK_BUFFER_SIZE];
    
    char *received_data = 0;
    int received_data_size = 0;
    
    char *body_data = 0;
    int body_data_size = 0;
    
    int mode = WAITING;
    
    int body_length = 0;
    
    while (1) {
        
        size = recv(socket_fd, (void*)&buffer, CHUNK_BUFFER_SIZE, 0);
        
        if (size > 0) {
            
            if (mode == WAITING) {
                
                mode = EXTRACT_HTTP;
            }
            
            if (mode == EXTRACT_HTTP) {
                
                if (received_data == 0) {
                    received_data = (char *)malloc(size);
                    received_data_size = 0;
                }
                else {
                    received_data = (char *)realloc(received_data, received_data_size + size);
                }
                
                memcpy(received_data+received_data_size, buffer, size);
                received_data_size += size;
                
                if (received_data_size > 0) {
                    printf("got\n%s\n", received_data);
                }
                
                char *body_offset = processHTTPResponse(received_data, received_data_size, &body_length);
                
                if (body_offset != 0) {
                    // beginning of body found
                    body_data_size = received_data_size - (body_offset - received_data);
                    body_data = (char *)malloc(body_data_size);
                    memcpy(body_data, body_offset, body_data_size);
                    
                    printf("found size %d\n", body_length);
                    
                    mode = EXTRACT_BODY;
                }
            }
            else {
                
                body_data = (char *)realloc(body_data, body_data_size + size);
                
                memcpy(body_data+body_data_size, buffer, size);
                body_data_size += size;
                
                printf("size is now %d\n", body_data_size);
                
                if (body_data_size == body_length) {
                    printf("exact size\n");                    
                    break;
                }
                else if (body_data_size > body_length) {
                    printf("oversize!\n");
                    ret = -1;
                    break;
                }
            }
        }
        else if (size == 0) {
            // Connection reset by peer
            ret = -3;
            break;
        }
        else if (errno != EAGAIN && errno != EWOULDBLOCK) {
            
            if (mode != WAITING) {
                ret = -2;
                break;
            }
        }
    }
    
    free(received_data);
    
    if (ret == 0) {
        *response_body = body_data;
        *response_length = body_length;
    }
    else {
        free(body_data);
        *response_body = 0;
        *response_length = 0;
    }
    
    return ret;
}

void HTTPNetworkFreeResponseBody(char *responseBody)
{
    free(responseBody);
}


