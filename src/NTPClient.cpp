#include "NTPClient.h"

/** Default port to  use for UDP if not defined*/
const unsigned int DEFAULT_LOCAL_PORT = 2990;
/** Default port to  use for UDP if not defined*/
const char* DEFAULT_TIME_SERVER = "time.google.com";

/*----------------------------------------------------------------------*
 * Default constructor                                                  *
 *----------------------------------------------------------------------*/
NTPClient::NTPClient(){ 
  serverName = DEFAULT_TIME_SERVER;
  localPort = DEFAULT_LOCAL_PORT;
}

/*----------------------------------------------------------------------*
 * Create an DeloreanNTP object from the given NTP Server Name.           *
 *----------------------------------------------------------------------*/
NTPClient::NTPClient(const char* ntpServerName, unsigned int port)
{
  serverName = ntpServerName;
  localPort =  port;
}

// send an NTP request to the time server at the given address
void NTPClient::sendPacket(){
  // set all bytes in the buffer to 0
  memset(packetBuffer, 0, NTP_PACKET_SIZE);
  // Initialize values needed to form NTP request
  // (see URL above for details on the packets)
  packetBuffer[0] = 0b11100011;   // LI, Version, Mode
  packetBuffer[1] = 0;     // Stratum, or type of clock
  packetBuffer[2] = 6;     // Polling Interval
  packetBuffer[3] = 0xEC;  // Peer Clock Precision
  // 8 bytes of zero for Root Delay & Root Dispersion
  packetBuffer[12]  = 49;
  packetBuffer[13]  = 0x4E;
  packetBuffer[14]  = 49;
  packetBuffer[15]  = 52;

  // all NTP fields have been given values, now
  // you can send a packet requesting a timestamp:
  udp.beginPacket(timeServerIP, 123); //NTP requests are to port 123
  udp.write(packetBuffer, NTP_PACKET_SIZE);
  udp.endPacket();
}

void NTPClient::start(){
  udp.begin(localPort);
}

bool NTPClient::receivePacket(){
  int cb = udp.parsePacket();
  if (!cb) {
    return false;
  }
  // We've received a packet, read the data from it
  udp.read(packetBuffer, NTP_PACKET_SIZE); // read the packet into the buffer
  return true;
}

unsigned long NTPClient::processPacket(){  
  //the timestamp starts at byte 40 of the received packet and is four bytes,
  // or two words, long. First, esxtract the two words:
  unsigned long highWord = word(packetBuffer[40], packetBuffer[41]);
  unsigned long lowWord = word(packetBuffer[42], packetBuffer[43]);
  // combine the four bytes (two words) into a long integer
  // this is NTP time (seconds since Jan 1 1900):
  unsigned long secsSince1900 = highWord << 16 | lowWord;
  // now convert NTP time into everyday time:
  // Unix time starts on Jan 1 1970. In seconds, that's 2208988800:
  const unsigned long seventyYears = 2208988800UL;
  // subtract seventy years:
  unsigned long epoch = secsSince1900 - seventyYears;
  return epoch;
}

unsigned long NTPClient::getTime(){
  //get a random server from the pool
  WiFi.hostByName(serverName, timeServerIP);
  // wait to see if a reply is available
  int curAttempt = 0;
  int maxAttempts = 3;
  while(curAttempt<maxAttempts){
    // send an NTP packet to a time server
    sendPacket();
    // wait to see if a reply is available
    delay(1000);
    if(receivePacket()){
      return processPacket();  
    }
    ++curAttempt;
  }
  return 0;
}