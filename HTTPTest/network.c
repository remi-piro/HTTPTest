//
//  network.c
//  HTTPTest
//
//  Created by lion on 2/11/13.
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

#define EXTRACT_HTTP 2
#define EXTRACT_VIDEO 3

int openSocket()
{
    int socket_fd = socket(AF_INET, SOCK_STREAM, 0);
    
    if (socket_fd == -1) {
        return -1;
    }
    
    struct sockaddr_in serv_addr;
    struct hostent *server;
    
    server = gethostbyname("www3.r3gis.fr");
    
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
    /*
    int flags = 1;
    
    res = ioctl(socket_fd, FIONBIO, &flags);

    if (res == -1) {
        return -4;
    }
    */
    return socket_fd;
}

int sendRequest(int socket_fd, char *data)
{
    int ret = send(socket_fd, data, strlen(data), 0);    
    return ret;
}

char *processHTTPResponse(char *response, unsigned int length, int *content_length)
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

int receiveResponse(int socket_fd)
{
    ssize_t size = 0;
	char buffer[CHUNK_BUFFER_SIZE];
    
    char *received_data = 0;
    int received_data_size = 0;
    
    char *video_data = 0;
    int video_data_size = 0;
    
    int mode = EXTRACT_HTTP;

    int video_length = 0;
    
    while (1) {

        size = recv(socket_fd, (void*)&buffer, CHUNK_BUFFER_SIZE, 0);
        
        if (size > 0) {
            
            if (mode == EXTRACT_HTTP) {

                if (received_data == 0) {
                    received_data = (char *)malloc(size);
                    received_data_size = 0;
                }
                else {
                    received_data = (char *)realloc(received_data, received_data_size+size);
                }
                
                memcpy(received_data+received_data_size, buffer, size);
                received_data_size += size;
                
                if (received_data_size > 0) {
                    printf("got\n%s\n", received_data);
                }
                
                char *video_offset = processHTTPResponse(received_data, received_data_size, &video_length);
                
                if (video_offset != 0) {
                    // begin of video found
                    video_data_size = received_data_size - (video_offset - received_data);
                    video_data = (char *)malloc(video_data_size);
                    memcpy(video_data, video_offset, video_data_size);
                    
                    printf("found size %d\n", video_length);
                    
                    mode = EXTRACT_VIDEO;
                }
            }
            else {
                
                video_data = (char *)realloc(video_data, received_data_size+video_data_size);
                
                memcpy(video_data+video_data_size, buffer, size);
                video_data_size += size;
                
                printf("size is now %d\n", video_data_size);
                
                if (video_data_size == video_length) {
                    printf("exact size\n");
                    
                    FILE *f = fopen("/Users/lion/Documents/vid.mp4", "w");
                    fwrite(video_data, video_data_size, 1, f);
                    fclose(f);
                    break;
                }
                else if (video_data_size > video_length) {
                    printf("oversize!\n");
                    break;
                }
            }
            
            //break;
            
        }
        else if (size == 0) {
            // Connection reset by peer
            return -1;
        }
        else if (errno != EAGAIN && errno != EWOULDBLOCK) {
            break;
        }
    }
    
    return received_data_size;
}

int closeSocket(int socket_fd)
{
    return close(socket_fd);
}
