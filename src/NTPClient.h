#ifndef NTPCLIENT_H
#define NTPCLIENT_H

#include <WiFiUdp.h>

#ifdef ESP8266
    #include <ESP8266WiFi.h>
#else
    #include <WiFi.h>
#endif


// NTP time stamp is in the first 48 bytes of the message
const int NTP_PACKET_SIZE = 48;

class NTPClient
{
    public:
        NTPClient();
        NTPClient(const char* ntpServerName,unsigned int port);
        unsigned long getTime();
        void start();
    private:
    	bool receivePacket();
    	void sendPacket();
    	unsigned long processPacket();
        unsigned int localPort;
        //String timeServer = DEFAULT_TIME_SERVER;
    	WiFiUDP udp;// A UDP instance to let us send and receive packets over UDP
    	const char* serverName;
    	IPAddress timeServerIP; 
		byte packetBuffer[ NTP_PACKET_SIZE]; //buffer to hold incoming and outgoing packets
};

#endif