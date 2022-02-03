#include <NTPClient.h>

NTPClient ntpClient;

void setup() {
  ntpClient.start();
}

void loop() {
  ntpClient.getTime();
  delay(60000);
}
