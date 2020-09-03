//
//  ScreenDumper.m
//  Board3
//
//  Created by Dror Kessler on 8/23/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "ScreenDumper.h"
#import "SystemUtils.h"

#include <stdio.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>    /* sockaddr_in structure */
#import <QuartzCore/CALayer.h>


@implementation ScreenDumper
@synthesize onView = _onView;

-(void)startOnPort:(int)port withView:(UIView*)view
{
	_port = port;
	self.onView = view;

	[SystemUtils threadWithTarget:self selector:@selector(thread:) object:self];
	//[NSThread detachNewThreadSelector:@selector(thread:) toTarget:self withObject:self];
}

-(void)dealloc
{
	[_onView release];
	
	[super dealloc];
}

-(void)thread:(id)sender
{
	[[NSAutoreleasePool alloc] init];
	
	int		
			new_sd, sock,  /* server/listen socket descriptors */
			cnt;           /* number of bytes I/O */
	int		adrlen, rc;
	
	struct sockaddr_in myname;  /* Internet socket name */
	struct sockaddr_in *nptr;   /* ptr to get port number */
	struct sockaddr    addr;    /* generic socket name */

	
	char buf[0x1000];   /* I/O buffer, kind of small  */
	
	
	/* As in UNIX domain sockets, create a "listen" socket */
	if (( sock = socket(AF_INET, SOCK_STREAM, 0)) < 0 ) 
	{
		printf("network server socket failure %d\n", errno);
		perror("network server");
		exit(1);
	}
	NSLog(@"sock: %d", sock);
	
	/* Initialize the fields in the Internet socket name
		 structure.                                          */
	myname.sin_family = AF_INET;  /* Internet address */
	myname.sin_port = htons(_port);  /* System will assign port #  */
	myname.sin_addr.s_addr = INADDR_ANY;  /* "Wildcard" */
		
	/* Bind the Internet address to the Internet socket */
	if (bind(sock, (const struct sockaddr*)&myname, sizeof(myname) ) < 0 ) {
		close(sock);  /* defensive programming  */
		printf("network server bind failure %d\n", errno);
		perror("network server");
		exit(2);
	}
	
	adrlen = sizeof(addr); /* need int for return value */
	if ( ( rc = getsockname( sock, &addr, (socklen_t*)&adrlen ) ) < 0 )
    {
		printf("setwork server getsockname failure %d\n",
			   errno);
		perror("network server");
		close (sock);
		exit(3);
	}
	
	/*   DEBUG CODE: the generic address "addr" is used to
	 return the socket value obtained from the
	 getsockname() call.  Print this information.  In the
	 generic structure definition, all but the address
	 family is defined as a char string.  After this
	 call, the generic address structure addr is used to
	 hold information about the client process. */
	
	printf("\nAfter getsockname():");
	printf(" server listen socket data\n");
	printf("\taddr.sa_family field value is: %d\n",
		   addr.sa_family);
	printf("\taddr.sa_data string is %d bytes long;\n",
		   sizeof ( addr.sa_data ) );
	printf("\taddr.sa_data string is:");
	for ( cnt = 0 ; 
		 cnt < sizeof (addr.sa_data); cnt++)
        printf(" %x", addr.sa_data[cnt]);
	printf("\n");
	
	/*   Now "advertise" the port number assigned to the
	 socket.  In this example, this port number must be
	 used as the second command line parameter when
	 starting up the client process.  */
	
	/*   Note the use of the pointer nptr, with a different
	 mapping of the allocated memory, to point to the
	 generic address structure. */
	
	nptr = (struct sockaddr_in *) &addr;  /* port # */
	printf("\n\tnetwork server: server has port number: %d\n",
		   ntohs ( nptr -> sin_port ) );
	
	
		
	NSLog(@"before listen");
	if ( listen ( sock, 5 ) < 0 ) 
	{
		printf("network server bind failure %d\n", errno);
		perror("network server");
		close (sock);
		exit(4);
	}
	NSLog(@"after listen");
	
	while ( 1 )
	{
		//NSLog(@"before accept");
		if ( ( new_sd = accept ( sock, 0, 0 ) ) < 0 ) 
		{
			printf("network server accept failure %d\n", errno);
			perror("network server");
			close (sock);
			exit(5);
		}
		//NSLog(@"after accept: new_sd=%d", new_sd);
		
		do	
		{
			if (( cnt = read (new_sd, buf, sizeof(buf))) < 0 ) {
				printf("socket read failure &d\n", errno);
				perror("network server");
				close(new_sd);
				exit(7);
			}
			else if (cnt == 0) {
					printf("network server received message");
					printf(" of length %d\n", cnt);
					printf("network server closing");
					printf(" client connection...\n");
					close (new_sd);
					continue; /* break out of loop */
            }
            else {
				
				/*  Print out message received from client.  Send
				 a message back.        */
				
				/*
				printf(" of length %d\n", cnt);
				printf(" the message %s\n", buf);
				 */
				bzero (buf, sizeof(buf)); /* zero buf, BSD. */

				//UIImage*		image = [UIImage imageNamed:@"gigigo.png"];

				UIGraphicsBeginImageContext(_onView.bounds.size);
				[_onView.layer renderInContext:UIGraphicsGetCurrentContext()];
				UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
				UIGraphicsEndImageContext();
				NSData*			imageData = UIImageJPEGRepresentation(image, 0.8);
				
				sprintf(buf, "HTTP/1.1 200 OK\nConnection: close\nContent-Length: %d\nContent-Type: image/jpeg\n\n",
									[imageData length]);
				write(new_sd, buf, strlen(buf));
				/*
				printf("response %s\n", buf);

				printf("image length: %d\n", [imageData length]);
				 */
				write(new_sd, [imageData bytes], [imageData length]); 
				
				close(new_sd);
				cnt = 0;
            }  /* end of message-print else */
		
		}  while (cnt != 0);  /* do loop condition */
	}
	
	close(sock);
}

@end
